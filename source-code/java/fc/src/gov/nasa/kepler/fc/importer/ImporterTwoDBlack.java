/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.fc.importer;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.TwoDBlackImage;
import gov.nasa.kepler.hibernate.fc.TwoDBlackImageHistoryModel;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Import small flat field models from files
 * 
 * @author kester
 * 
 */

public class ImporterTwoDBlack extends ImporterParentImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.TWODBLACK;
    public static final String DATAFILE_DIRECTORY_NAME = "two-d-black";
    public static final String DATAFILE_REGEX = "kplr\\d+-\\d\\d\\d_2d-black\\.txt";

    /**
     * @param args
     * @throws IOException
     * @throws FocalPlaneException
     * @throws FocalPlaneException
     * @throws IOException
     */
    public static void main(String[] args) throws
        IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterTwoDBlack importer = new ImporterTwoDBlack();
            importer.run(args);
            dbService.flush();
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput, String dataDirectory,
        String reason, Date date) throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.TWODBLACK);
        if (history == null) {
            String description = "created by ImporterTwoDBlackImage.appendNew becausethere were no TwoDBlackImage historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.TWODBLACK,
                description, version);
            fcCrud.create(history);
        }

        // Get the most recent entry for this History:
        //
        TwoDBlackImageHistoryModel mostRecentHm = fcCrud.retrieveMostRecentTwoDBlackImageHistoryModel(history, ccdModule, ccdOutput);

        // Check if all TwoDBlackImages to be persisted are later than the
		// latest TwoDBlackImage associated with the History. If this is not the
		// case, throw an error
        //
        String[] filenames = getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory);
        for (String filename : filenames) {
        	double mjd = getMjdFromFile(filename);
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentHm == null);
			boolean isTooEarly = !isMostRecentNull && mjd <= mostRecentHm.getMjd();
			
			if (isTooEarly) {
                throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                        + " Your data is "
                        + mostRecentHm.getMjd()
                        + " and the existing data is "
                        + mjd);
            }
        }

        // Persist TwoDBlackImages and TwoDBlackImageHistoryModels for each
        // TwoDBlackImage
        //
        for (String filename : filenames) {
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	if (modOut.left == ccdModule && modOut.right == ccdOutput) {
                log.info(String.format("import two-d black from %s", filename));
            	double mjd = getMjdFromFile(filename);

            	TwoDBlackImage image = parseFile(filename);
            	TwoDBlackImageHistoryModel twoDBlackImageHistoryModel = new TwoDBlackImageHistoryModel(image, history, mjd, modOut.left, modOut.right);
                fcCrud.create(image);
                fcCrud.create(twoDBlackImageHistoryModel);

                DatabaseService dbService = DatabaseServiceFactory.getInstance();
                dbService.flush();
                dbService.evict(twoDBlackImageHistoryModel);
                dbService.evict(image);
        	}
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput, String reason, Date date)
        throws IOException {
        appendNew(ccdModule, ccdOutput, getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
    }

    @Override
    protected void appendNew(String dataDirectory, String reason, Date date)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.TWODBLACK);
        if (history == null) {
            String description = "created by ImporterTwoDBlackImage.appendNew becausethere were no TwoDBlackImage historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.TWODBLACK,
                description, version);
            fcCrud.create(history);
        }

        // Check if all TwoDBlackImages to be persisted are later than the
        // latest TwoDBlackImage associated with the History. If this is not the case, throw an error
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {

        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	
            // Get the most recent entry for this History:
            //
            TwoDBlackImageHistoryModel hm = fcCrud.retrieveMostRecentTwoDBlackImageHistoryModel(
                history, modOut.left, modOut.right);

			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (hm == null);
			boolean isTooEarly = !isMostRecentNull && mjd <= hm.getMjd();
			
			if (isTooEarly) {
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is " + mjd
								+ " and the existing data is " + hm.getMjd());
            }
        }

        // Persist TwoDBlackImages and TwoDBlackImageHistoryModels for each
        // TwoDBlackImage
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {

        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	
        	TwoDBlackImage image = parseFile(filename);
        	TwoDBlackImageHistoryModel twoDBlackImageHistoryModel = new TwoDBlackImageHistoryModel(
                image, history, mjd, modOut.left, modOut.right);
            fcCrud.create(image);
            fcCrud.create(twoDBlackImageHistoryModel);

            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            dbService.flush();
            dbService.evict(twoDBlackImageHistoryModel);
            dbService.evict(image);
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(String reason, Date date) throws IOException,
        FocalPlaneException {
        appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
    }
    
    @Override
    public void insertBetween(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.TWODBLACK);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history found in insertBetween-- something is wrong!");
        }

        // Get all the TwoDBlackImage for that History
        List<TwoDBlackImageHistoryModel> twoDBlackImageHistoryModels = fcCrud.retrieveTwoDBlackImageHistoryModels(oldHistory);
        List<TwoDBlackImage> databaseTwoDBlackImages = new ArrayList<TwoDBlackImage>();
        for (TwoDBlackImageHistoryModel twoDBlackImageHistoryModel : twoDBlackImageHistoryModels) {
            databaseTwoDBlackImages.add(twoDBlackImageHistoryModel.getTwoDBlackImage());
        }

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.TWODBLACK,
            reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryTwoDBlackImageModels for each TwoDBlackImage
        // and persist them. Also persist the TwoDBlackImage object.
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {

        	TwoDBlackImage twoDBlackImage = parseFile(filename);
            double mjd = getMjdFromFile(filename);
            Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);

            TwoDBlackImageHistoryModel twoDBlackImageHistoryModel = new TwoDBlackImageHistoryModel(
                twoDBlackImage, newHistory, mjd, modOut.left, modOut.right);
            fcCrud.create(twoDBlackImageHistoryModel);
            fcCrud.create(twoDBlackImage);
        }
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        insertBetween(ccdModule, ccdOutput, DATAFILE_DIRECTORY_NAME, reason);

    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
        throws IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.TWODBLACK);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history found in insertBetween-- something is wrong!");
        }

        // Get all the TwoDBlackImage for that History
        List<TwoDBlackImageHistoryModel> twoDBlackImageHistoryModels = fcCrud.retrieveTwoDBlackImageHistoryModels(oldHistory);
        List<TwoDBlackImage> databaseTwoDBlackImages = new ArrayList<TwoDBlackImage>();
        for (TwoDBlackImageHistoryModel twoDBlackImageHistoryModel : twoDBlackImageHistoryModels) {
            databaseTwoDBlackImages.add(twoDBlackImageHistoryModel.getTwoDBlackImage());
        }
//
//        // Parse the data out of the file
//        List<TwoDBlackImage> twoDBlackImages = parseFilesInDirectory(
//            dataDirectory, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.TWODBLACK,
            reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryTwoDBlackImageModels for each TwoDBlackImage
        // and persist them.
        // Also
        // persist the TwoDBlackImage object.
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {

        	TwoDBlackImage twoDBlackImage = parseFile(filename);
            double mjd = getMjdFromFile(filename);
            Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);

            TwoDBlackImageHistoryModel twoDBlackImageHistoryModel = new TwoDBlackImageHistoryModel(
                twoDBlackImage, newHistory, mjd, modOut.left, modOut.right);
            fcCrud.create(twoDBlackImageHistoryModel);
            fcCrud.create(twoDBlackImage);
        }
    }

    @Override
    public void insertBetween(String reason) throws IOException,
        FocalPlaneException {
        insertBetween(DATAFILE_DIRECTORY_NAME, reason);
    }

    /**
     * Get a twoDBlackImage from a filename
     * 
     * @param filename
     * @return
     * @throws IOException
     */
    public TwoDBlackImage parseFile(String filename) throws IOException {
        log.debug("Reading file " + filename);

        Map<String, float[][]> dataUncert = getDataAndUncertaintyFromFile(filename);

        TwoDBlackImage twoDBlackImage = new TwoDBlackImage(
				dataUncert.get(DATA), dataUncert.get(UNCERTAINTY));

        log.debug("Done reading file " + filename);
        
        return twoDBlackImage;
    }
    
    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }
    
    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }

}
