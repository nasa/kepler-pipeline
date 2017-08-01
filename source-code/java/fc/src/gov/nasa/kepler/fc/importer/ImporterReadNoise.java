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

import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.ReadNoise;
import gov.nasa.kepler.hibernate.fc.ReadNoiseHistoryModel;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterReadNoise extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.READNOISE;
	public static final String DATAFILE_DIRECTORY_NAME = "read-noise";
	public static final String DATAFILE_REGEX = "kplr\\d+_read-noise\\.txt";
    
	/**
	 * 
	 * @param directoryName
	 * @param regex
	 * @return
	 * @throws FocalPlaneException
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	public List<ReadNoise> parseFilesInDirectory(String directoryName,
			String regex) throws NumberFormatException,
			IOException {
		List<ReadNoise> readNoises = new ArrayList<ReadNoise>();
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
            readNoises.addAll(parseFile(filename));
        }

        return readNoises;
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
	public List<ReadNoise> parseFilesInDirectory(String directoryName,
			String regex, int ccdModule, int ccdOutput)
			throws NumberFormatException, IOException {
		// Filter the results of parseFilesInDirectory(directoryName) for
		// mod/out:
		//
		List<ReadNoise> readNoises = new ArrayList<ReadNoise>();
		for (ReadNoise readNoise : parseFilesInDirectory(directoryName, regex)) {
			if (readNoise.getCcdModule() == ccdModule
					&& readNoise.getCcdOutput() == ccdOutput) {
				readNoises.add(readNoise);
			}
		}

		return readNoises;
	}

	/**
	 * Generate a list of ReadNoises from the file filename
	 * 
	 * @param filename
	 * @return
	 * @throws IOException
	 * @throws NumberFormatException
	 */
	public List<ReadNoise> parseFile(String filename)
			throws NumberFormatException, IOException {
        log.debug("Reading file " + filename);

		List<ReadNoise> readNoises = new ArrayList<ReadNoise>();

		// Read data from file:
		//
		BufferedReader buf = new BufferedReader(new FileReader(filename));
		String line = new String();
		while (null != (line = buf.readLine())) {
			String[] vals = line.split("\\|");
			double mjd = Double.parseDouble(vals[0]);
			int module = Integer.parseInt(vals[1]);
			int output = Integer.parseInt(vals[2]);
			double noiseVal = Double.parseDouble(vals[3]);

			ReadNoise readNoise = new ReadNoise(mjd, module, output, noiseVal);
			readNoises.add(readNoise);
		}
		buf.close();
		log.debug("Done reading file " + filename);
		
		return readNoises;
	}

	/**
	 * Generate a list of ReadNoises from the file filename
	 * 
	 * @param filename
	 * @return
	 * @throws IOException
	 * @throws NumberFormatException
	 */
	public List<ReadNoise> parseFile(String filename, int ccdModule,
			int ccdOutput) throws NumberFormatException, IOException {

		List<ReadNoise> readNoises = new ArrayList<ReadNoise>();

		// Read data from file:
		//
		BufferedReader buf = new BufferedReader(new FileReader(filename));
		String line = new String();
		while (null != (line = buf.readLine())) {
			String[] vals = line.split("\\|");
			double mjd = Double.parseDouble(vals[0]);
			int module = Integer.parseInt(vals[1]);
			int output = Integer.parseInt(vals[2]);
			double noiseVal = Double.parseDouble(vals[3]);

			if (ccdModule == module && ccdOutput == output) {
				ReadNoise readNoise = new ReadNoise(mjd, module, output,
						noiseVal);
				readNoises.add(readNoise);
			}
		}
		buf.close();

		return readNoises;
	}

	// /**
	// * Check if data is already persisted for this date. If so, error out,
	// * update must be used instead.
	// *
	// *
	// * @param pointings
	// * @return
	// * @throws FocalPlaneException
	// */
	// private boolean isAlreadyLoaded(List<ReadNoise> readNoises,
	// ReadNoiseOperations ops) {
	//
	// for (ReadNoise readNoise : readNoises) {
	// ReadNoise r = ops.retrieveReadNoiseExact(readNoise);
	// if (null != r) {
	// return true;
	// }
	// }
	// return false;
	// }

	public static void seedReadNoise() throws IOException {
		new ImporterReadNoise().seed();
	}

	public void seed() throws IOException {
		String[] args = {
				"load",
				"importerLoad",
				FilenameConstants.SOC_ROOT
						+ "/recdels/so/rec/read_noise/read_noise2008020722.txt" };
		run(args);
	}

	public static void main(String[] args) throws
			IOException {
		DatabaseService dbService = DatabaseServiceFactory.getInstance();
		try {
			dbService.beginTransaction();
			ImporterReadNoise importer = new ImporterReadNoise();
			importer.run(args);
			dbService.commitTransaction();
		} finally {
			dbService.rollbackTransactionIfActive();
			dbService.closeCurrentSession();
		}

	}

	/**
	 * Append new data to the current History (or create the first History, if
	 * this is a clean database) for the module/output given, using the
	 * dataDirectory given.
	 * 
	 */
	@Override
	protected void appendNew(int ccdModule, int ccdOutput, String dataDirectory,
			String reason, Date date) throws IOException {

		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

		// Get the most recent history (create one if there aren't any (first
		// run case))
		//
		History history = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (history == null) {
			String description = "created by ImporterReadNoise.appendNew becausethere were no ReadNoise historys; " + reason;
			int version = 1;
			date = new Date();
			double now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.READNOISE, description,
					version);
			fcCrud.create(history);
		}

		// Get the most recent entry for this History:
		//
		ReadNoise mostRecentDatabaseReadNoise = fcCrud
				.retrieveMostRecentReadNoise(history, ccdModule, ccdOutput);

		// Get ReadNoises for the right module/output from the given
		// dataDirectory:
		//
		List<ReadNoise> readNoises = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);
		
		// Check if all ReadNoises to be persisted are later than the latest
		// ReadNoise associated
		// with the History. If this is not the case, throw an error
		//
		// null mostRecentDatabaseReadNoise means this is the first load
		for (ReadNoise readNoise : readNoises) {

			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseReadNoise == null);
			boolean isTooEarly = !isMostRecentNull && readNoise.getMjd() <= mostRecentDatabaseReadNoise.getMjd();
			
			if (isTooEarly) {		        
				throw new FocalPlaneException(
		            "appendNew requires new data to occur after existing data."
		            + " Your data is "
		            + mostRecentDatabaseReadNoise.getMjd()
		            + " and the existing data is "
		            + readNoise.getMjd());
		    }
		}

		// Persist ReadNoises and ReadNoiseHistoryModels for each ReadNoise
		//
		for (ReadNoise readNoise : readNoises) {
			ReadNoiseHistoryModel readNoiseHistoryModel = new ReadNoiseHistoryModel(
					readNoise, history);
			fcCrud.create(readNoise);
			fcCrud.create(readNoiseHistoryModel);
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
		History history = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (history == null) {
			String description = "created by ImporterReadNoise.appendNew becausethere were no ReadNoise historys; " + reason;
			int version = 1;
			date = new Date();
			double now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.READNOISE, description,
					version);
			fcCrud.create(history);
		}

		// Get ReadNoises from directory
		List<ReadNoise> readNoises = parseFilesInDirectory(dataDirectory,
				DATAFILE_REGEX);

		// Check if all ReadNoises to be persisted are later than the latest
		// ReadNoise associated
		// with the History. If this is not the case, throw an error
		//
		for (ReadNoise readNoise : readNoises) {
			// Get the most recent entry for this History/module/output:
			//
			ReadNoise mostRecentDatabaseReadNoise = fcCrud
					.retrieveMostRecentReadNoise(history, readNoise
							.getCcdModule(), readNoise.getCcdOutput());

			// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseReadNoise == null);
			boolean isTooEarly = !isMostRecentNull && readNoise.getMjd() <= mostRecentDatabaseReadNoise.getMjd();
			
			if (isTooEarly) {		       
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is "
								+ mostRecentDatabaseReadNoise.getMjd()
								+ " and the existing data is "
								+ readNoise.getMjd());
			}
		}
		// Persist ReadNoises and ReadNoiseHistoryModels for each ReadNoise
		//
		for (ReadNoise readNoise : readNoises) {
			ReadNoiseHistoryModel readNoiseHistoryModel = new ReadNoiseHistoryModel(
					readNoise, history);
			fcCrud.create(readNoise);
			fcCrud.create(readNoiseHistoryModel);
		}
        updateModelMetaData(dataDirectory, history, date);
	}

	@Override
	protected void appendNew(String reason, Date date) throws IOException {
		appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
	}

	@Override
	public void changeExisting(int ccdModule, int ccdOutput,
			String dataDirectory, String reason) throws IOException,
			FocalPlaneException {

		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

		// extract current History for this model
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for ReadNoise in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<ReadNoiseHistoryModel> readNoiseHistoryModels = fcCrud.retrieveReadNoiseHistoryModels(oldHistory);
		List<ReadNoise> readNoisesDB = new ArrayList<ReadNoise>();
		for (ReadNoiseHistoryModel readNoiseHistoryModel : readNoiseHistoryModels) {
			ReadNoise readNoise = readNoiseHistoryModel.getReadNoise();
			if (readNoise.getCcdModule() == ccdModule && readNoise.getCcdOutput() == ccdOutput) {
				readNoisesDB.add(readNoise);
			}
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<ReadNoise> readNoisesFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < readNoisesFromFile.size(); ++ii) {
			if (!match) {
				for (ReadNoise readNoise : readNoisesDB) {
					match = readNoisesFromFile.get(ii).getMjd() == readNoise
							.getMjd();
					readNoisesFromFile.get(ii).setReadNoise(
							readNoise.getReadNoise());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input ReadNoise  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterReadNoise.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.READNOISE,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new ReadNoiseHistoryModels linking new history to old data +
		// new replacement data
		//
		for (ReadNoise readNoise : readNoisesDB) {
			ReadNoiseHistoryModel rnhm = new ReadNoiseHistoryModel(readNoise,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for ReadNoise in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<ReadNoiseHistoryModel> readNoiseHistoryModels = fcCrud
				.retrieveReadNoiseHistoryModels(oldHistory);
		List<ReadNoise> readNoisesDB = new ArrayList<ReadNoise>();
		for (ReadNoiseHistoryModel readNoiseHistoryModel : readNoiseHistoryModels) {
			readNoisesDB.add(readNoiseHistoryModel.getReadNoise());
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<ReadNoise> readNoisesFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < readNoisesFromFile.size(); ++ii) {
			if (!match) {
				for (ReadNoise readNoise : readNoisesDB) {
					match = readNoisesFromFile.get(ii).getMjd() == readNoise
							.getMjd();
					readNoisesFromFile.get(ii).setReadNoise(
							readNoise.getReadNoise());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input ReadNoise  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterReadNoise.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.READNOISE,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new ReadNoiseHistoryModels linking new history to old data +
		// new replacement data
		//
		for (ReadNoise readNoise : readNoisesDB) {
			ReadNoiseHistoryModel rnhm = new ReadNoiseHistoryModel(readNoise,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the ReadNoise for that History
		List<ReadNoiseHistoryModel> readNoiseHistoryModels = fcCrud
				.retrieveReadNoiseHistoryModels(oldHistory);
		List<ReadNoise> databaseReadNoises = new ArrayList<ReadNoise>();
		for (ReadNoiseHistoryModel readNoiseHistoryModel : readNoiseHistoryModels) {
			databaseReadNoises.add(readNoiseHistoryModel.getReadNoise());
		}

		// Parse the data out of the file
		List<ReadNoise> readNoises = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.READNOISE,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryReadNoiseModels for each ReadNoise and persist them.
		// Also
		// persist the ReadNoise object.
		for (ReadNoise readNoise : readNoises) {
			ReadNoiseHistoryModel readNoiseHistoryModel = new ReadNoiseHistoryModel(
					readNoise, newHistory);
			fcCrud.create(readNoiseHistoryModel);
			fcCrud.create(readNoise);
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.READNOISE);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the ReadNoise for that History
		List<ReadNoiseHistoryModel> readNoiseHistoryModels = fcCrud
				.retrieveReadNoiseHistoryModels(oldHistory);
		List<ReadNoise> databaseReadNoises = new ArrayList<ReadNoise>();
		for (ReadNoiseHistoryModel readNoiseHistoryModel : readNoiseHistoryModels) {
			databaseReadNoises.add(readNoiseHistoryModel.getReadNoise());
		}

		// Parse the data out of the file
		List<ReadNoise> readNoises = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.READNOISE,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryReadNoiseModels for each ReadNoise and persist them.
		// Also
		// persist the ReadNoise object.
		for (ReadNoise readNoise : readNoises) {
			ReadNoiseHistoryModel readNoiseHistoryModel = new ReadNoiseHistoryModel(
					readNoise, newHistory);
			fcCrud.create(readNoiseHistoryModel);
			fcCrud.create(readNoise);
		}
	}
	
    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }

	@Override
	public void insertBetween(String reason) throws IOException {
		insertBetween(DATAFILE_DIRECTORY_NAME, reason);
	}
    
    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }
}
