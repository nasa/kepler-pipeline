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
import gov.nasa.kepler.hibernate.fc.Undershoot;
import gov.nasa.kepler.hibernate.fc.UndershootHistoryModel;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterUndershoot extends ImporterParentNonImage {
    
    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.UNDERSHOOT;
    public static final String DATAFILE_DIRECTORY_NAME = "undershoot";
    public static final String DATAFILE_REGEX = "kplr\\d+_undershoot\\.txt";

	/**
	 * 
	 * @param filename
	 * @return
	 * @throws NumberFormatException
	 * @throws IOException
	 * @throws FocalPlaneException
	 * @throws FocalPlaneException
	 */
	public List<Undershoot> parseFile(String filename)
			throws NumberFormatException, IOException {
	    log.debug("Reading file " + filename);
	    
		List<Undershoot> undershoots = new ArrayList<Undershoot>();

		// Read data from file:
		//
		final int NUM_HEADER_FIELDS = 4; // MJD, module, output, numCoeffs
		BufferedReader buf = new BufferedReader(new FileReader(filename));
		String line = new String();
		while (null != (line = buf.readLine())) {
			String[] vals = line.split("\\|");
			double mjd = Double.parseDouble(vals[0]);
			int module = Integer.parseInt(vals[1]);
			int output = Integer.parseInt(vals[2]);
			
			// Read out how many coeffs there should be:
			//
            int numCoeffs = Integer.parseInt(vals[3]);

            // Read out the data for coeffs:
            //
            double[] coeffs = new double[numCoeffs];
            for (int ii = 0; ii < numCoeffs; ++ii) {
                coeffs[ii] = Double.parseDouble(vals[NUM_HEADER_FIELDS + ii]);
            }
            
            double[] uncertainties = new double[numCoeffs];
            for (int ii = 0; ii < numCoeffs; ++ii) {
                uncertainties[ii] = Double.parseDouble(vals[NUM_HEADER_FIELDS + numCoeffs + ii]);
            }
            
			// Sanity check for fieldnames:
            //
			int expectedNumberOfFields = NUM_HEADER_FIELDS + 2*numCoeffs;
			if (expectedNumberOfFields != vals.length) {
				throw new FocalPlaneException("Bad number of fields in line "
						+ vals + ". Expected " + expectedNumberOfFields
						+ ", actual=" + vals.length
						+ " in ImporterUndershoot::parseFile!");
			}

			Undershoot undershoot = new Undershoot(module, output, mjd, coeffs, uncertainties);
			undershoots.add(undershoot);
		}
		buf.close();
		log.debug("Done reading file " + filename);

		return undershoots;
	}

	   /**
     * 
     * @param directoryName
     * @param regex
     * @return
     * @throws FocalPlaneException
     * @throws NumberFormatException
     * @throws IOException
     */
    public List<Undershoot> parseFilesInDirectory(String directoryName,
            String regex) throws NumberFormatException,
            IOException {
        List<Undershoot> undershoots = new ArrayList<Undershoot>();

        // Verify directory exists
        //
        File directory = getDataDirectory(directoryName);
        if (!directory.isDirectory()) {
            throw new FocalPlaneException("Input directory "
                    + directory.getAbsolutePath() + " is not a directory");
        }

        // Extract the objects from each file in the directory:
        //
        for (String filename : getFilenamesFromDirectory(directory, regex)) {
            undershoots.addAll(parseFile(filename));
        }

        return undershoots;
    }

    /**
     * 
     * @param directoryName
     * @param regex
     * @param ccdModule
     * @param ccdOutput
     * @return
     * @throws FocalPlaneException
     * @throws NumberFormatException
     * @throws IOException
     */
    public List<Undershoot> parseFilesInDirectory(String directoryName,
            String regex, int ccdModule, int ccdOutput)
            throws NumberFormatException, IOException {
        // Filter the results of parseFilesInDirectory(directoryName) for
        // mod/out:
        //
        List<Undershoot> undershoots = new ArrayList<Undershoot>();
        for (Undershoot undershoot : parseFilesInDirectory(directoryName, regex)) {
            if (undershoot.getCcdModule() == ccdModule
                    && undershoot.getCcdOutput() == ccdOutput) {
                undershoots.add(undershoot);
            }
        }

        return undershoots;
    }
    
	public static void main(String[] args) throws
			IOException {
		DatabaseService dbService = DatabaseServiceFactory.getInstance();
		try {
			dbService.beginTransaction();
			ImporterUndershoot importer = new ImporterUndershoot();
			importer.run(args);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (history == null) {
            String description = "created by ImporterUndershoot.appendNew becausethere were no Undershoot historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.UNDERSHOOT, description,
                    version);
            fcCrud.create(history);
        }

        // Get the most recent entry for this History:
        //
        Undershoot mostRecentDatabaseUndershoot = fcCrud
                .retrieveMostRecentUndershoot(history, ccdModule, ccdOutput);

        // Get Undershoots for the right module/output from the given
        // dataDirectory:
        //
        List<Undershoot> undershoots = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Check if all Undershoots to be persisted are later than the latest
        // Undershoot associated
        // with the History. If this is not the case, throw an error
        //
        for (Undershoot undershoot : undershoots) {
        	
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseUndershoot == null);
			boolean isTooEarly = !isMostRecentNull && undershoot.getStartMjd() <= mostRecentDatabaseUndershoot.getStartMjd();

            if (isTooEarly) {
                throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                    + " Your data is "
                    + mostRecentDatabaseUndershoot.getStartMjd()
                    + " and the existing data is "
                    + undershoot.getStartMjd());
            }
        }


        // Persist Undershoots and UndershootHistoryModels for each undershoot
        //
        for (Undershoot undershoot : undershoots) {
            UndershootHistoryModel undershootHistoryModel = new UndershootHistoryModel(
                undershoot, history);
            fcCrud.create(undershoot);
            fcCrud.create(undershootHistoryModel);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (history == null) {
            String description = "created by ImporterUndershoot.appendNew becausethere were no Undershoot historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.UNDERSHOOT, description,
                    version);
            fcCrud.create(history);
        }

        // Get Undershoots from directory
        List<Undershoot> undershoots = parseFilesInDirectory(dataDirectory,
                DATAFILE_REGEX);

        // Check if all Undershoots to be persisted are later than the latest
        // Undershoot associated
        // with the History. If this is not the case, throw an error
        //
        for (Undershoot undershoot : undershoots) {
            // Get the most recent entry for this History/module/output:
            //
            Undershoot mostRecentDatabaseUndershoot = fcCrud
                    .retrieveMostRecentUndershoot(history, undershoot
                            .getCcdModule(), undershoot.getCcdOutput());

            
			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseUndershoot == null);
			boolean isTooEarly = !isMostRecentNull && undershoot.getStartMjd() <= mostRecentDatabaseUndershoot.getStartMjd();
			
			if (isTooEarly) {
				throw new FocalPlaneException(
                        "appendNew requires new data to occur after existing data."
                                + " Your data is "
                                + mostRecentDatabaseUndershoot.getStartMjd()
                                + " and the existing data is "
                                + undershoot.getStartMjd());
            }
        }
        // Persist Undershoots and UndershootHistoryModels for each Undershoot
        //
        for (Undershoot undershoot : undershoots) {
            UndershootHistoryModel undershootHistoryModel = new UndershootHistoryModel(
                    undershoot, history);
            fcCrud.create(undershoot);
            fcCrud.create(undershootHistoryModel);
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(String reason, Date date) throws IOException,
        FocalPlaneException {
        appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);        
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Undershoot in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<UndershootHistoryModel> undershootHistoryModels = fcCrud.retrieveUndershootHistoryModels(oldHistory);
        List<Undershoot> undershootsDB = new ArrayList<Undershoot>();
        for (UndershootHistoryModel undershootHistoryModel : undershootHistoryModels) {
            Undershoot undershoot = undershootHistoryModel.getUndershoot();
            if (undershoot.getCcdModule() == ccdModule && undershoot.getCcdOutput() == ccdOutput) {
                undershootsDB.add(undershoot);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Undershoot> undershootsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < undershootsFromFile.size(); ++ii) {
            if (!match) {
                for (Undershoot undershoot : undershootsDB) {
                    match = undershootsFromFile.get(ii).getStartMjd() == undershoot.getStartMjd();

                    undershootsFromFile.get(ii).setCoefficients(
                        undershoot.getCoefficients());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Undershoot  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterUndershoot.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.UNDERSHOOT,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new UndershootHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Undershoot undershoot : undershootsDB) {
            UndershootHistoryModel rnhm = new UndershootHistoryModel(undershoot,
                    history);
            fcCrud.create(rnhm);
        }        
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        changeExisting(ccdModule, ccdOutput, DATAFILE_DIRECTORY_NAME, reason);        
    }

    @Override
    public void changeExisting(String dataDirectory, String reason)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Undershoot in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<UndershootHistoryModel> undershootHistoryModels = fcCrud
                .retrieveUndershootHistoryModels(oldHistory);
        List<Undershoot> undershootsDB = new ArrayList<Undershoot>();
        for (UndershootHistoryModel undershootHistoryModel : undershootHistoryModels) {
            undershootsDB.add(undershootHistoryModel.getUndershoot());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Undershoot> undershootsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < undershootsFromFile.size(); ++ii) {
            if (!match) {
                for (Undershoot undershoot : undershootsDB) {
                    match = undershootsFromFile.get(ii).getStartMjd() == undershoot
                            .getStartMjd();
                    undershootsFromFile.get(ii).setCoefficients(
                            undershoot.getCoefficients());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Undershoot  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterUndershoot.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.UNDERSHOOT,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new UndershootHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Undershoot undershoot : undershootsDB) {
            UndershootHistoryModel rnhm = new UndershootHistoryModel(undershoot,
                    history);
            fcCrud.create(rnhm);
        }        
    }

    @Override
    public void changeExisting(String reason) throws IOException,
        FocalPlaneException {
        changeExisting(DATAFILE_DIRECTORY_NAME, reason);        
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Undershoot for that History
        List<UndershootHistoryModel> undershootHistoryModels = fcCrud
                .retrieveUndershootHistoryModels(oldHistory);
        List<Undershoot> databaseUndershoots = new ArrayList<Undershoot>();
        for (UndershootHistoryModel undershootHistoryModel : undershootHistoryModels) {
            databaseUndershoots.add(undershootHistoryModel.getUndershoot());
        }

        // Parse the data out of the file
        List<Undershoot> undershoots = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.UNDERSHOOT,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryUndershootModels for each Undershoot and persist them.
        // Also
        // persist the Undershoot object.
        for (Undershoot undershoot : undershoots) {
            UndershootHistoryModel undershootHistoryModel = new UndershootHistoryModel(
                    undershoot, newHistory);
            fcCrud.create(undershootHistoryModel);
            fcCrud.create(undershoot);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.UNDERSHOOT);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Undershoot for that History
        List<UndershootHistoryModel> undershootHistoryModels = fcCrud
                .retrieveUndershootHistoryModels(oldHistory);
        List<Undershoot> databaseUndershoots = new ArrayList<Undershoot>();
        for (UndershootHistoryModel undershootHistoryModel : undershootHistoryModels) {
            databaseUndershoots.add(undershootHistoryModel.getUndershoot());
        }

        // Parse the data out of the file
        List<Undershoot> undershoots = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.UNDERSHOOT,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryUndershootModels for each Undershoot and persist them.
        // Also
        // persist the Undershoot object.
        for (Undershoot undershoot : undershoots) {
            UndershootHistoryModel undershootHistoryModel = new UndershootHistoryModel(
                    undershoot, newHistory);
            fcCrud.create(undershootHistoryModel);
            fcCrud.create(undershoot);
        }        
    }

    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }

    @Override
    public void insertBetween(String reason) throws IOException,
        FocalPlaneException {
        insertBetween(DATAFILE_DIRECTORY_NAME, reason);        
    }

    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }

}
