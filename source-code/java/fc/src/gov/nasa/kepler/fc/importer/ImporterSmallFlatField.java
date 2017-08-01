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
import gov.nasa.kepler.hibernate.fc.SmallFlatFieldImage;
import gov.nasa.kepler.hibernate.fc.SmallFlatFieldImageHistoryModel;
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

public class ImporterSmallFlatField extends ImporterParentImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.SMALLFLATFIELD;
    public static final String DATAFILE_DIRECTORY_NAME = "small-flat";
    public static final String DATAFILE_REGEX = "kplr\\d+-\\d\\d\\d_ssflat\\.txt";

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
            ImporterSmallFlatField importer = new ImporterSmallFlatField();
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
        History history = fcCrud.retrieveHistory(HistoryModelName.SMALLFLATFIELD);
        if (history == null) {
            String description = "created by ImporterSmallFlatField.appendNew becausethere were no SmallFlatField historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.SMALLFLATFIELD, description, version);
            fcCrud.create(history);
        }

        // Get the most recent entry for this History:
        //
        SmallFlatFieldImageHistoryModel mostRecentHistoryModel= fcCrud.retrieveMostRecentSmallFlatFieldImageHistoryModel(history, ccdModule, ccdOutput);

        // Check if all SmallFlatFields to be persisted are later than the latest
		// SmallFlatField associated with the History. If this is not the case, throw an error
		//
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentHistoryModel == null);
			boolean isTooEarly = !isMostRecentNull && mjd <= mostRecentHistoryModel.getMjd();
			
			if (isTooEarly) {		       
				throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                        + " Your data is "
                        + mostRecentHistoryModel.getMjd()
                        + " and the existing data is "
                        + mjd);
            }
        }

        // Persist SmallFlatFields and SmallFlatFieldHistoryModels for each
        // SmallFlatField
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);

        	if (ccdModule == modOut.left && ccdOutput == modOut.right) {
        	    log.info(String.format("import small flat from %s", filename));
        		SmallFlatFieldImage image = parseFile(filename);
        		SmallFlatFieldImageHistoryModel smallFlatFieldHistoryModel = new SmallFlatFieldImageHistoryModel(mjd, modOut.left, modOut.right, image, history);
                fcCrud.create(image);
                fcCrud.create(smallFlatFieldHistoryModel);

                DatabaseService dbService = DatabaseServiceFactory.getInstance();
                dbService.flush();
                dbService.evict(smallFlatFieldHistoryModel);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.SMALLFLATFIELD);
        if (history == null) {
            String description = "created by ImporterSmallFlatField.appendNew becausethere were no SmallFlatField historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.SMALLFLATFIELD, description,
                version);
            fcCrud.create(history);
        }

        // Check if all SmallFlatFields to be persisted are later than the
        // latest
        // SmallFlatField associated
        // with the History. If this is not the case, throw an error
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	
            // Get the most recent entry for this History:
            //
            SmallFlatFieldImageHistoryModel hm = fcCrud.retrieveMostRecentSmallFlatFieldImageHistoryModel(history, modOut.left, modOut.right);
            
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (hm == null);
			boolean isTooEarly = !isMostRecentNull && mjd <= hm.getMjd();
			
			if (isTooEarly) {	
                throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                        + " Your data is "
                        + hm.getMjd()
                        + " and the existing data is "
                        + mjd);
            }
        }

        // Persist SmallFlatFields and SmallFlatFieldHistoryModels for each
        // SmallFlatField
        //
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	
        	SmallFlatFieldImage image = parseFile(filename);
        	SmallFlatFieldImageHistoryModel smallFlatFieldHistoryModel = new SmallFlatFieldImageHistoryModel(mjd, modOut.left, modOut.right, image, history);        	
            fcCrud.create(image);
            fcCrud.create(smallFlatFieldHistoryModel);

            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            dbService.flush();
            dbService.evict(smallFlatFieldHistoryModel);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SMALLFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the SmallFlatFieldImage for that History
        List<SmallFlatFieldImageHistoryModel> smallFlatHistoryModels = fcCrud
                .retrieveSmallFlatFieldImageHistoryModels(oldHistory);
        List<SmallFlatFieldImage> databaseSmallFlatFieldImages = new ArrayList<SmallFlatFieldImage>();
        for (SmallFlatFieldImageHistoryModel smallFlatHistoryModel : smallFlatHistoryModels) {
            databaseSmallFlatFieldImages.add(smallFlatHistoryModel.getSmallFlatFieldImage());
        }

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SMALLFLATFIELD,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySmallFlatFieldImageModels for each SmallFlatFieldImage and persist them.
        // Also
        // persist the SmallFlatFieldImage object.
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	SmallFlatFieldImage image = parseFile(filename);
        	
        	SmallFlatFieldImageHistoryModel smallFlatHistoryModel = new SmallFlatFieldImageHistoryModel(
                    mjd, modOut.left, modOut.right, image, newHistory);
            fcCrud.create(smallFlatHistoryModel);
            fcCrud.create(image);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SMALLFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the SmallFlatFieldImage for that History
        List<SmallFlatFieldImageHistoryModel> smallFlatHistoryModels = fcCrud
                .retrieveSmallFlatFieldImageHistoryModels(oldHistory);
        List<SmallFlatFieldImage> databaseSmallFlatFieldImages = new ArrayList<SmallFlatFieldImage>();
        for (SmallFlatFieldImageHistoryModel smallFlatHistoryModel : smallFlatHistoryModels) {
            databaseSmallFlatFieldImages.add(smallFlatHistoryModel.getSmallFlatFieldImage());
        }

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SMALLFLATFIELD,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySmallFlatFieldImageModels for each SmallFlatFieldImage and persist them.
        // Also
        // persist the SmallFlatFieldImage object.
        for (String filename : getFilenamesFromDirectory(DATAFILE_REGEX, dataDirectory)) {
        	double mjd = getMjdFromFile(filename);
        	Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        	SmallFlatFieldImage image = parseFile(filename);
        	
        	SmallFlatFieldImageHistoryModel smallFlatHistoryModel = new SmallFlatFieldImageHistoryModel(
                    mjd, modOut.left, modOut.right, image, newHistory);
        	
            fcCrud.create(smallFlatHistoryModel);
            fcCrud.create(image);
        }
    }

    @Override
    public void insertBetween(String reason) throws IOException,
        FocalPlaneException {
        insertBetween(DATAFILE_DIRECTORY_NAME, reason);
    }

    

    /**
     * Get a smallFlatFieldImage from a filename
     * @param filename
     * @return
     * @throws IOException
     */
    public SmallFlatFieldImage parseFile(String filename) throws IOException {
        log.debug("Reading file " + filename);

        @SuppressWarnings("unused")
		double mjd = getMjdFromFile(filename);
        @SuppressWarnings("unused")
		Pair<Integer, Integer> modOut = getModuleOutputNumberFromFile(filename);
        Map<String, float[][]> dataUncert = getDataAndUncertaintyFromFile(filename);

        log.debug("Done reading file " + filename);
        
        SmallFlatFieldImage smallFlatFieldImage = new SmallFlatFieldImage(dataUncert.get(DATA), dataUncert.get(UNCERTAINTY));
        
        return smallFlatFieldImage;
    }
    
    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }
    
    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }

}
