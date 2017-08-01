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
import gov.nasa.kepler.hibernate.fc.Linearity;
import gov.nasa.kepler.hibernate.fc.LinearityHistoryModel;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterLinearity extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.LINEARITY;
    public static final String DATAFILE_DIRECTORY_NAME = "linearity";
    public static final String DATAFILE_REGEX = "kplr\\d+_linearity\\.txt";

    /**
	 * 
	 * @param directoryName
	 * @param regex
	 * @return
	 * @throws FocalPlaneException
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	public List<Linearity> parseFilesInDirectory(String directoryName,
			String regex) throws NumberFormatException,
			IOException {
		List<Linearity> linearitys = new ArrayList<Linearity>();

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
			linearitys.addAll(parseFile(filename));
		}

		return linearitys;
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
	public List<Linearity> parseFilesInDirectory(String directoryName,
			String regex, int ccdModule, int ccdOutput)
			throws NumberFormatException, IOException {
		// Filter the results of parseFilesInDirectory(directoryName) for
		// mod/out:
		//
		List<Linearity> linearitys = new ArrayList<Linearity>();
		for (Linearity linearity : parseFilesInDirectory(directoryName, regex)) {
			if (linearity.getCcdModule() == ccdModule
					&& linearity.getCcdOutput() == ccdOutput) {
				linearitys.add(linearity);
			}
		}

		return linearitys;
	}
	
    /**
     * Generate a list of linearities from the file filename
     * 
     * @param filename
     * @return
     * @throws IOException
     * @throws FocalPlaneException
     * @throws NumberFormatException
     */
    public List<Linearity> parseFile(String filename) throws IOException {
        log.debug("Reading " + filename);

        List<Linearity> linearities = new ArrayList<Linearity>();

        int numHeaderFields = 10;

        // Load data from file:
        //
        BufferedReader buf = new BufferedReader(new FileReader(filename));
        String line = new String();
        while (null != (line = buf.readLine())) {
            String[] values = line.split("\\|");
            if (numHeaderFields > values.length) {
                throw new FocalPlaneException(
                    "bad line in ImporterLinearity::parseFile.  There should be more than "
                        + numHeaderFields + " in the line, instead there are "
                        + values.length + ".  The line is \\n: " + line);
            }

            
            double mjd = Double.parseDouble(values[0]);
            int module = Integer.parseInt(values[1]);
            int output = Integer.parseInt(values[2]);
            int polynomialOrder = Integer.parseInt(values[3]);
            String type = values[4];
            int xIndex = Integer.parseInt(values[5]);
            double offsetX = Double.parseDouble(values[6]);
            double scaleX = Double.parseDouble(values[7]);
            double originX = Double.parseDouble(values[8]);
            int maxDomain = Integer.parseInt(values[9]);


            double[] coefficients = new double[polynomialOrder+1];
            double[] covariance = new double[(polynomialOrder+1) * (polynomialOrder+1)];

            int numTotalFields = numHeaderFields + (1+polynomialOrder)
                + (1+polynomialOrder) * (1+polynomialOrder);
            if (numTotalFields != values.length) {
                throw new FocalPlaneException(
                    "bad line in ImporterLinearity::parseFile.  There should be "
                        + numTotalFields + " in the line, instead there are "
                        + values.length + ".  The line is \\n: " + line);
            }
            
            // Parse out the next polynomialOrder entries as the coefficients:
            //
            for (int ii = 0; ii < polynomialOrder+1; ++ii) {
                int index = numHeaderFields + ii;
                coefficients[ii] = Double.parseDouble(values[index]);
            }

            // Parse out the next polynomialOrder^2 entries as the covariance:
            //
            for (int ii = 0; ii < (polynomialOrder+1)*(polynomialOrder+1); ++ii) {
                int index = numHeaderFields + polynomialOrder + 1 + ii;
                covariance[ii] = Double.parseDouble(values[index]);
            }

            Linearity linearity = new Linearity(
                module, output, mjd,
                offsetX, scaleX, originX, 
                type, xIndex, maxDomain, 
                coefficients, covariance);
            linearities.add(linearity);
        }
        buf.close();
        
        log.debug("Done reading " + filename);
        return linearities;
    }
    
    public List<Linearity> parseFile(String filename, int ccdModule, int ccdOutput) throws IOException {
    	List<Linearity> linearitys = parseFile(filename);
    	for (Linearity linearity : linearitys) {
    		if (linearity.getCcdModule() != ccdModule || linearity.getCcdOutput() != ccdOutput) {
    			linearitys.remove(linearity);
    		}
		}
    	return linearitys;
    }

    public static void main(String[] args) throws
        IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterLinearity importer = new ImporterLinearity();        
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
		History history = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (history == null) {
			String description = "created by ImporterLinearity.appendNew becausethere were no Linearity historys; " + reason;
			int version = 1;
			date = new Date();
			double now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.LINEARITY, description,
					version);
			fcCrud.create(history);
		}

		// Get the most recent entry for this History:
		//
		Linearity mostRecentDatabaseLinearity = fcCrud
				.retrieveMostRecentLinearity(history, ccdModule, ccdOutput);

		// Get Linearitys for the right module/output from the given
		// dataDirectory:
		//
		List<Linearity> linearitys = new ArrayList<Linearity>();

		File dataDirectoryFile = new File(dataDirectory);
		if (!dataDirectoryFile.isDirectory()) {
			throw new FocalPlaneException("Input directory "
					+ dataDirectoryFile.getAbsolutePath()
					+ " is not a directory");
		}
		for (String filename : getFilenamesFromDirectory(dataDirectoryFile,
				DATAFILE_REGEX)) {
			List<Linearity> linearitysFromFileForModOUt = parseFile(filename,
					ccdModule, ccdOutput);

			// Check if all Linearitys to be persisted are later than the latest
			// Linearity associated
			// with the History. If this is not the case, throw an error
			//
			for (Linearity linearity : linearitysFromFileForModOUt) {
		       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
				//
				boolean isMostRecentNull = (mostRecentDatabaseLinearity == null);
				boolean isTooEarly = !isMostRecentNull && linearity.getStartMjd() <= mostRecentDatabaseLinearity.getStartMjd();
				
				if (isTooEarly){
					throw new FocalPlaneException(
							"appendNew requires new data to occur after existing data."
									+ " Your data is "
									+ mostRecentDatabaseLinearity.getStartMjd()
									+ " and the existing data is "
									+ linearity.getStartMjd());
				}
			}

			linearitys.addAll(linearitysFromFileForModOUt);
		}

		// Persist Linearitys and LinearityHistoryModels for each Linearity
		//
		for (Linearity linearity : linearitys) {
			LinearityHistoryModel linearityHistoryModel = new LinearityHistoryModel(
					linearity, history);
			fcCrud.create(linearity);
			fcCrud.create(linearityHistoryModel);
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
		History history = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (history == null) {
			String description = "created by ImporterLinearity.appendNew becausethere were no Linearity historys; " + reason;
			int version = 1;
			date = new Date();
			double now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.LINEARITY, description,
					version);
			fcCrud.create(history);
		}

		// Get Linearitys from directory
		List<Linearity> linearitys = parseFilesInDirectory(dataDirectory,
				DATAFILE_REGEX);

		// Check if all Linearitys to be persisted are later than the latest
		// Linearity associated
		// with the History. If this is not the case, throw an error
		//
		for (Linearity linearity : linearitys) {
			// Get the most recent entry for this History/module/output:
			//
			Linearity mostRecentDatabaseLinearity = fcCrud
					.retrieveMostRecentLinearity(history, linearity
							.getCcdModule(), linearity.getCcdOutput());

	       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseLinearity == null);
			boolean isTooEarly = !isMostRecentNull && linearity.getStartMjd() <= mostRecentDatabaseLinearity.getStartMjd();
			
			if (isTooEarly){
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is "
								+ mostRecentDatabaseLinearity.getStartMjd()
								+ " and the existing data is "
								+ linearity.getStartMjd());
			}
		}
		// Persist Linearitys and LinearityHistoryModels for each Linearity
		//
		for (Linearity linearity : linearitys) {
			LinearityHistoryModel linearityHistoryModel = new LinearityHistoryModel(
					linearity, history);
			fcCrud.create(linearity);
			fcCrud.create(linearityHistoryModel);
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for Linearity in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<LinearityHistoryModel> linearityHistoryModels = fcCrud.retrieveLinearityHistoryModels(oldHistory);
		List<Linearity> linearitysDB = new ArrayList<Linearity>();
		for (LinearityHistoryModel linearityHistoryModel : linearityHistoryModels) {
			Linearity linearity = linearityHistoryModel.getLinearity();
			if (linearity.getCcdModule() == ccdModule && linearity.getCcdOutput() == ccdOutput) {
				linearitysDB.add(linearity);
			}
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<Linearity> linearitysFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < linearitysFromFile.size(); ++ii) {
			if (!match) {
				for (Linearity linearity : linearitysDB) {
					match = linearitysFromFile.get(ii).getStartMjd() == linearity
							.getStartMjd();
					linearitysFromFile.get(ii).setCoefficients(linearity.getCoefficients());
					linearitysFromFile.get(ii).setUncertainties(linearity.getUncertainties());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input Linearity  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterLinearity.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.LINEARITY,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new LinearityHistoryModels linking new history to old data +
		// new replacement data
		//
		for (Linearity linearity : linearitysDB) {
			LinearityHistoryModel rnhm = new LinearityHistoryModel(linearity,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for Linearity in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<LinearityHistoryModel> linearityHistoryModels = fcCrud
				.retrieveLinearityHistoryModels(oldHistory);
		List<Linearity> linearitysDB = new ArrayList<Linearity>();
		for (LinearityHistoryModel linearityHistoryModel : linearityHistoryModels) {
			linearitysDB.add(linearityHistoryModel.getLinearity());
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<Linearity> linearitysFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < linearitysFromFile.size(); ++ii) {
			if (!match) {
				for (Linearity linearity : linearitysDB) {
					match = linearitysFromFile.get(ii).getStartMjd() == linearity.getStartMjd();
		
					linearitysFromFile.get(ii).setCoefficients(linearity.getCoefficients());
					linearitysFromFile.get(ii).setUncertainties(linearity.getUncertainties());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input Linearity  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterLinearity.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.LINEARITY,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new LinearityHistoryModels linking new history to old data +
		// new replacement data
		//
		for (Linearity linearity : linearitysDB) {
			LinearityHistoryModel rnhm = new LinearityHistoryModel(linearity,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the Linearity for that History
		List<LinearityHistoryModel> linearityHistoryModels = fcCrud
				.retrieveLinearityHistoryModels(oldHistory);
		List<Linearity> databaseLinearitys = new ArrayList<Linearity>();
		for (LinearityHistoryModel linearityHistoryModel : linearityHistoryModels) {
			databaseLinearitys.add(linearityHistoryModel.getLinearity());
		}

		// Parse the data out of the file
		List<Linearity> linearitys = new ArrayList<Linearity>();
		File dataDirectoryFile = new File(dataDirectory);
		if (!dataDirectoryFile.isDirectory()) {
			throw new FocalPlaneException("Input directory "
					+ dataDirectoryFile.getAbsolutePath()
					+ " is not a directory");
		}
		for (String filename : getFilenamesFromDirectory(dataDirectoryFile,
				DATAFILE_REGEX)) {
			linearitys.addAll(parseFile(filename, ccdModule, ccdOutput));
		}

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.LINEARITY,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryLinearityModels for each Linearity and persist them.
		// Also
		// persist the Linearity object.
		for (Linearity linearity : linearitys) {
			LinearityHistoryModel linearityHistoryModel = new LinearityHistoryModel(
					linearity, newHistory);
			fcCrud.create(linearityHistoryModel);
			fcCrud.create(linearity);
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LINEARITY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the Linearity for that History
		List<LinearityHistoryModel> linearityHistoryModels = fcCrud.retrieveLinearityHistoryModels(oldHistory);
		List<Linearity> databaseLinearitys = new ArrayList<Linearity>();
		for (LinearityHistoryModel linearityHistoryModel : linearityHistoryModels) {
			databaseLinearitys.add(linearityHistoryModel.getLinearity());
		}

		// Parse the data out of the file
		List<Linearity> linearitys = new ArrayList<Linearity>();
		for (String filename : getDataFilenames(DATAFILE_REGEX, dataDirectory)) {
			linearitys.addAll(parseFile(filename));
		}

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.LINEARITY,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryLinearityModels for each Linearity and persist them.
		// Also
		// persist the Linearity object.
		for (Linearity linearity : linearitys) {
			LinearityHistoryModel linearityHistoryModel = new LinearityHistoryModel(
					linearity, newHistory);
			fcCrud.create(linearityHistoryModel);
			fcCrud.create(linearity);
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
