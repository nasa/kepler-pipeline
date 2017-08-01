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
import gov.nasa.kepler.hibernate.fc.Geometry;
import gov.nasa.kepler.hibernate.fc.GeometryHistoryModel;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterGeometry extends ImporterParentNonImage {

	private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.GEOMETRY;
	public static final String DATAFILE_DIRECTORY_NAME = "geometry";
	public static final String DATAFILE_REGEX = "kplr\\d+_geometry.txt";
    public static final int NUM_ELEMENTS = Geometry.ELEMENT_COUNT_NO_PLATESCALE + 84*2;

	public ImporterGeometry() {
		;
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
	public List<Geometry> parseFilesInDirectory(String directoryName,
			String regex) throws NumberFormatException,
			IOException {
		List<Geometry> geometrys = new ArrayList<Geometry>();

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
			geometrys.add(parseFile(filename));
		}

		return geometrys;
	}

	public Geometry parseFile(String filename) throws NumberFormatException,
			IOException {
		log.debug("Reading file " + filename);

		// Read data from file:
		//
		BufferedReader buf = new BufferedReader(new FileReader(filename));
		String line = new String();
		double mjd = -1.0;
		List<Double> coefficients = new ArrayList<Double>();

		int lineNumber = 1;
		while (null != (line = buf.readLine())) {
			if (1 == lineNumber) {
				String[] vals = line.split(",");
				mjd = Double.parseDouble(vals[0]);
			} else {
				// Geometry, platescale, and pincushion:
				//
				String[] vals = line.split("\\s+");
				for (String val : vals) {
					coefficients.add(Double.parseDouble(val));
				}
			}
			++lineNumber;

			if (mjd < 0) {
				throw new FocalPlaneException("bad MJD read from file");
			}
		}

		// Throw an error if platescale and pincushion wasn't included:
		//
		if (coefficients.size() != NUM_ELEMENTS) {
			throw new FocalPlaneException("Input file " + filename + " contains "
					+ coefficients.size() + " coeffients, but the importer requires "
					+ NUM_ELEMENTS);
		}

		// Verify the platescale and pincushion are both the same for outputs on
		// the same CCD (e.g., channels 1&2, 3&4, ..., 83&84 should have the
		// same value for both platescale and pincushion).
		//
		int FIRST_PLATESCALE_INDEX = 252;
		int LAST_PLATESCALE_INDEX = 419;
		for (int ipair = FIRST_PLATESCALE_INDEX; ipair <= LAST_PLATESCALE_INDEX; ipair += 2) {
			double coeffOutputA = coefficients.get(ipair);
			double coeffOutputB = coefficients.get(ipair + 1);

			if (coeffOutputA != coeffOutputB) {
				double ccdNumber = Math.ceil((ipair - 252 + 1) / 2) % 42 + 1;
				String message = "The "
						+ ((ipair < 336) ? "platescale" : "pincushion")
						+ " coeffients for the two outputs on CCD " + ccdNumber
						+ " are not the same.  Quitting.";
				throw new FocalPlaneException(message);
			}
		}

		log.debug("Done reading file " + filename);
		
		Geometry geometry = new Geometry(mjd, coefficients);
		buf.close();

		return geometry;
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
			ImporterGeometry importer = new ImporterGeometry();
			dbService.beginTransaction();
			importer.run(args);
			dbService.commitTransaction();
		} finally {
			dbService.rollbackTransactionIfActive();
			dbService.closeCurrentSession();
		}
	}

	@Override
	protected void appendNew(int ccdModule, int ccdOutput, String reason, Date date)
			throws IOException {
		throw new FocalPlaneException("not implemented for ImporterGeometry");
	}

	@Override
	protected void appendNew(int ccdModule, int ccdOutput, String dataDirectory,
			String reason, Date date) throws IOException {
		throw new FocalPlaneException("not implemented for ImporterGeometry");
	}

	@Override
	protected void appendNew(String dataDirectory, String reason, Date date)
			throws IOException {
		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

		// Get the most recent history (create one if there aren't any (first
		// run case))
		//
		History history = fcCrud.retrieveHistory(HistoryModelName.GEOMETRY);
		if (history == null) {
			String description = "created by ImporterGeometry.appendNew becausethere were no Geometry historys; "
					+ reason;
			int version = 1;
			double now = ModifiedJulianDate.dateToMjd(new Date());
			history = new History(now, HistoryModelName.GEOMETRY, description,
					version);
			fcCrud.create(history);
		}

		// Get Geometrys from directory
		List<Geometry> geometrys = parseFilesInDirectory(dataDirectory,
				DATAFILE_REGEX);

		// Check if all Geometrys to be persisted are later than the latest
		// Geometry associated
		// with the History. If this is not the case, throw an error
		//
		for (Geometry geometry : geometrys) {
			// Get the most recent entry for this History/module/output:
			//
			Geometry mostRecentDatabaseGeometry = fcCrud
					.retrieveMostRecentGeometry(history);

			// mostRecentDatabase == null indicates this is the first time data
			// has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseGeometry == null);
			boolean isTooEarly = !isMostRecentNull
					&& geometry.getStartTime() <= mostRecentDatabaseGeometry
							.getStartTime();

			if (isTooEarly) {
				throw new FocalPlaneException(
						"appendNew requires new data to occur after existing data."
								+ " New data is " + geometry.getStartTime()
								+ "(id=" + geometry.getId()
								+ ") and the existing data is "
								+ mostRecentDatabaseGeometry.getStartTime()
								+ "(id=" + mostRecentDatabaseGeometry.getId()
								+ ")");
			}
		}
		// Persist Geometrys and GeometryHistoryModels for each Geometry
		//
		for (Geometry geometry : geometrys) {
			GeometryHistoryModel geometryHistoryModel = new GeometryHistoryModel(
					geometry, history);
			fcCrud.create(geometry);
			fcCrud.create(geometryHistoryModel);
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
		throw new FocalPlaneException("not implemented for ImporterGeometry");
	}

	@Override
	public void changeExisting(int ccdModule, int ccdOutput, String reason)
			throws IOException {
		throw new FocalPlaneException("not implemented for ImporterGeometry");

	}

	@Override
	public void changeExisting(String dataDirectory, String reason)
			throws IOException {
		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

		// extract current History for this model
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GEOMETRY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history exists for Geometry in changeExisting-- error.  "
							+ "Must use appendNew to add initial data.");
		}

		List<GeometryHistoryModel> geometryHistoryModels = fcCrud
				.retrieveGeometryHistoryModels(oldHistory);
		List<Geometry> geometrysDB = new ArrayList<Geometry>();
		for (GeometryHistoryModel geometryHistoryModel : geometryHistoryModels) {
			Geometry geometry = geometryHistoryModel.getGeometry();
			geometrysDB.add(geometry);
		}

		// Parse input data and verify it will replace existing data. Throw an
		// error if not:
		//
		List<Geometry> geometrysFromFile = parseFilesInDirectory(dataDirectory,
				DATAFILE_REGEX);
		boolean match = false;
		for (int ii = 0; ii < geometrysFromFile.size(); ++ii) {
			if (!match) {
				for (Geometry geometry : geometrysDB) {
					match = geometrysFromFile.get(ii).getStartTime() == geometry
							.getStartTime();
					geometrysFromFile.get(ii).setConstants(
							geometry.getConstants());
					geometrysFromFile.get(ii).setUncertainty(
							geometry.getUncertainty());
				}
			}
		}
		if (!match) {
			throw new FocalPlaneException(
					"Input Geometry is not a replacement for "
							+ "existing data.  Use appendNew or insertBetween instead.");
		}

		// create new history
		String description = "created by ImporterGeometry.changeExisting; "
				+ reason;
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History history = new History(now, HistoryModelName.GEOMETRY,
				description, oldHistory.getVersion() + 1);
		fcCrud.create(history);

		// create new GeometryHistoryModels linking new history to old data +
		// new replacement data
		//
		for (Geometry geometry : geometrysDB) {
			GeometryHistoryModel hm = new GeometryHistoryModel(geometry,
					history);
			fcCrud.create(hm);
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
		throw new FocalPlaneException("not implemented for ImporterGeometry");
	}

	@Override
	public void insertBetween(int ccdModule, int ccdOutput, String reason)
			throws IOException {
		throw new FocalPlaneException("not implemented for ImporterGeometry");
	}

	@Override
	public void insertBetween(String dataDirectory, String reason)
			throws IOException {
		FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

		// Get the current History
		History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GEOMETRY);
		if (oldHistory == null) {
			throw new FocalPlaneException(
					"no history found in insertBetween-- something is wrong!");
		}

		// Get all the Geometry for that History
		List<GeometryHistoryModel> geometryHistoryModels = fcCrud
				.retrieveGeometryHistoryModels(oldHistory);
		List<Geometry> databaseGeometrys = new ArrayList<Geometry>();
		for (GeometryHistoryModel geometryHistoryModel : geometryHistoryModels) {
			databaseGeometrys.add(geometryHistoryModel.getGeometry());
		}

		// Parse the data out of the file
		List<Geometry> geometrys = new ArrayList<Geometry>();
		for (String filename : getDataFilenames(DATAFILE_REGEX, dataDirectory)) {
			geometrys.add(parseFile(filename));
		}

		// Create new History, iterate the version
		double now = ModifiedJulianDate.dateToMjd(new Date());
		History newHistory = new History(now, HistoryModelName.GEOMETRY,
				reason, oldHistory.getVersion() + 1);
		fcCrud.create(newHistory);

		// Create HistoryGeometryModels for each Geometry and persist them.
		// Also
		// persist the Geometry object.
		for (Geometry geometry : geometrys) {
			GeometryHistoryModel geometryHistoryModel = new GeometryHistoryModel(
					geometry, newHistory);
			fcCrud.create(geometryHistoryModel);
			fcCrud.create(geometry);
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
