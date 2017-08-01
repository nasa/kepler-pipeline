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
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelHistoryModel;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * File format must be:
 * 
 * MJD|MODULE|OUTPUT|ROW|COLUMN|TYPE|VALUE
 * 
 * where MJD and value are doubles, type is a string, and module, output, row,
 * and column are integers.
 * 
 * @author kester
 * 
 */
public class ImporterInvalidPixels extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.BAD_PIXELS;
    public static final String DATAFILE_DIRECTORY_NAME = "invalid-pixels";
    public static final String DATAFILE_REGEX = "kplr\\d+_bad-pixels\\.txt";

    public List<Pixel> parseFile(String filename) throws IOException,
        FocalPlaneException {
        log.debug("Reading file " + filename);

        BufferedReader buf = new BufferedReader(new FileReader(filename));
        String line = new String();

        List<Pixel> pixels = new ArrayList<Pixel>();
        try {
            while (null != (line = buf.readLine())) {
                String[] values = line.split("\\|");
                Pixel pixel = new Pixel(values);
                pixels.add(pixel);
            }
        } finally {
            buf.close();
        }
        log.debug("Done reading file " + filename);
        return pixels;
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
	public List<Pixel> parseFilesInDirectory(String directoryName,
			String regex) throws NumberFormatException,
			IOException {
		List<Pixel> pixels = new ArrayList<Pixel>();

        // Extract the objects from each file in the directory:
		//
        for (String filename : getFilenamesFromDirectory(getDataDirectory(directoryName), regex)) {
			pixels.addAll(parseFile(filename));
		}

		return pixels;
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
	public List<Pixel> parseFilesInDirectory(String directoryName,
			String regex, int ccdModule, int ccdOutput)
			throws NumberFormatException, IOException {
		// Filter the results of parseFilesInDirectory(directoryName) for
		// mod/out:
		//
		List<Pixel> pixels = new ArrayList<Pixel>();
		for (Pixel pixel : parseFilesInDirectory(directoryName, regex)) {
			if (pixel.getCcdModule() == ccdModule
					&& pixel.getCcdOutput() == ccdOutput) {
				pixels.add(pixel);
			}
		}

		return pixels;
	}

    /**
     * @param args
     * @throws IOException
     * @throws FocalPlaneException
     */
    public static void main(String[] args) throws
        IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterInvalidPixels importer = new ImporterInvalidPixels();        
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
		History history = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (history == null) {
			String description = "created by ImporterPixel.appendNew becausethere were no Pixel historys; " + reason;
			int version = 1;
			date = new Date();
			double now = ModifiedJulianDate.dateToMjd(date);
			history = new History(now, HistoryModelName.BAD_PIXELS, description,
					version);
			fcCrud.create(history);
		}

		// Get the most recent entry for this History:
		//
		Pixel mostRecentDatabasePixel = fcCrud
				.retrieveMostRecentPixel(history, ccdModule, ccdOutput);

		// Get Pixels for the right module/output from the given
		// dataDirectory:
		//
		List<Pixel> pixels = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);
		
		// Check if all Pixels to be persisted are later than the latest
		// Pixel associated
		// with the History. If this is not the case, throw an error
		//
		// If mostRecentDatabasePixel == null, this is the first append
		for (Pixel pixel : pixels) {
	       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabasePixel == null);
			boolean isTooEarly = !isMostRecentNull && pixel.getStartTime() <= mostRecentDatabasePixel.getStartTime();
			
			if (isTooEarly) {
		        throw new FocalPlaneException(
		            "appendNew requires new data to occur after existing data."
		            + " Your data is "
		            + mostRecentDatabasePixel.getStartTime()
		            + " and the existing data is "
		            + pixel.getStartTime());
		    }
		}

		// Persist Pixels and PixelHistoryModels for each Pixel
		//
		for (Pixel pixel : pixels) {
			PixelHistoryModel pixelHistoryModel = new PixelHistoryModel(
					pixel, history);
			fcCrud.create(pixel);
			fcCrud.create(pixelHistoryModel);
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
		History history = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (history == null) {
			String description = "created by ImporterPixel.appendNew becausethere were no Pixel historys; " + reason;
			int version = 1;
			double now = ModifiedJulianDate.dateToMjd(new Date());
			history = new History(now, HistoryModelName.BAD_PIXELS, description,
					version);
			fcCrud.create(history);
		}

		// Get Pixels from directory
		List<Pixel> pixels = parseFilesInDirectory(dataDirectory,
				DATAFILE_REGEX);

		// Check if all Pixels to be persisted are later than the latest
		// Pixel associated
		// with the History. If this is not the case, throw an error
		//
		for (Pixel pixel : pixels) {
			// Get the most recent entry for this History/module/output:
			//
			Pixel mostRecentDatabasePixel = fcCrud
					.retrieveMostRecentPixel(history, pixel
							.getCcdModule(), pixel.getCcdOutput());

	       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabasePixel == null);
			boolean isTooEarly = !isMostRecentNull && pixel.getStartTime() <= mostRecentDatabasePixel.getStartTime();
			
			if (isTooEarly){
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " Your data is "
								+ mostRecentDatabasePixel.getStartTime()
								+ " and the existing data is "
								+ pixel.getStartTime());
			}
		}
		// Persist Pixels and PixelHistoryModels for each Pixel
		//
		for (Pixel pixel : pixels) {
			PixelHistoryModel pixelHistoryModel = new PixelHistoryModel(
					pixel, history);
			fcCrud.create(pixel);
			fcCrud.create(pixelHistoryModel);
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for Pixel in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<PixelHistoryModel> pixelHistoryModels = fcCrud.retrievePixelHistoryModels(oldHistory);
		List<Pixel> pixelsDB = new ArrayList<Pixel>();
		for (PixelHistoryModel pixelHistoryModel : pixelHistoryModels) {
			Pixel pixel = pixelHistoryModel.getPixel();
			if (pixel.getCcdModule() == ccdModule && pixel.getCcdOutput() == ccdOutput) {
				pixelsDB.add(pixel);
			}
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<Pixel> pixelsFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < pixelsFromFile.size(); ++ii) {
			if (!match) {
				for (Pixel pixel : pixelsDB) {
					match = pixelsFromFile.get(ii).getStartTime() == pixel
							.getStartTime();
					
					pixelsFromFile.get(ii).setPixelValue(
							pixel.getPixelValue());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input Pixel  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterPixel.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.BAD_PIXELS,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new PixelHistoryModels linking new history to old data +
		// new replacement data
		//
		for (Pixel pixel : pixelsDB) {
			PixelHistoryModel rnhm = new PixelHistoryModel(pixel,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for Pixel in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		// get data linked to this history
		//
		List<PixelHistoryModel> pixelHistoryModels = fcCrud
				.retrievePixelHistoryModels(oldHistory);
		List<Pixel> pixelsDB = new ArrayList<Pixel>();
		for (PixelHistoryModel pixelHistoryModel : pixelHistoryModels) {
			pixelsDB.add(pixelHistoryModel.getPixel());
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<Pixel> pixelsFromFile = parseFilesInDirectory(
				dataDirectory, DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < pixelsFromFile.size(); ++ii) {
			if (!match) {
				for (Pixel pixel : pixelsDB) {
					match = pixelsFromFile.get(ii).getStartTime() == pixel
							.getStartTime();
					pixelsFromFile.get(ii).setPixelValue(
							pixel.getPixelValue());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input Pixel  is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterPixel.changeExisting; " + reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.BAD_PIXELS,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new PixelHistoryModels linking new history to old data +
		// new replacement data
		//
		for (Pixel pixel : pixelsDB) {
			PixelHistoryModel rnhm = new PixelHistoryModel(pixel,
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the Pixel for that History
		List<PixelHistoryModel> pixelHistoryModels = fcCrud
				.retrievePixelHistoryModels(oldHistory);
		List<Pixel> databasePixels = new ArrayList<Pixel>();
		for (PixelHistoryModel pixelHistoryModel : pixelHistoryModels) {
			databasePixels.add(pixelHistoryModel.getPixel());
		}

		// Parse the data out of the file
		List<Pixel> pixels = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.BAD_PIXELS,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryPixelModels for each Pixel and persist them.
		// Also
		// persist the Pixel object.
		for (Pixel pixel : pixels) {
			PixelHistoryModel pixelHistoryModel = new PixelHistoryModel(
					pixel, newHistory);
			fcCrud.create(pixelHistoryModel);
			fcCrud.create(pixel);
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
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.BAD_PIXELS);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the Pixel for that History
		List<PixelHistoryModel> pixelHistoryModels = fcCrud
				.retrievePixelHistoryModels(oldHistory);
		List<Pixel> databasePixels = new ArrayList<Pixel>();
		for (PixelHistoryModel pixelHistoryModel : pixelHistoryModels) {
			databasePixels.add(pixelHistoryModel.getPixel());
		}

		// Parse the data out of the file
		List<Pixel> pixels = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.BAD_PIXELS,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryPixelModels for each Pixel and persist them.
		// Also
		// persist the Pixel object.
		for (Pixel pixel : pixels) {
			PixelHistoryModel pixelHistoryModel = new PixelHistoryModel(
					pixel, newHistory);
			fcCrud.create(pixelHistoryModel);
			fcCrud.create(pixel);
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
