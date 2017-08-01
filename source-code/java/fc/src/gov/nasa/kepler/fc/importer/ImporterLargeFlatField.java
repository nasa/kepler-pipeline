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
import gov.nasa.kepler.hibernate.fc.LargeFlatField;
import gov.nasa.kepler.hibernate.fc.LargeFlatFieldHistoryModel;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterLargeFlatField extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.LARGEFLATFIELD;
    public static final String DATAFILE_DIRECTORY_NAME = "large-flat";
    public static final String DATAFILE_REGEX = "kplr\\d+_lsflat\\.txt";

    /**
     * 
     * @param filename
     * @return
     * @throws NumberFormatException
     * @throws IOException
     * @throws FocalPlaneException
     */
    public List<LargeFlatField> parseFile(String filename)
        throws NumberFormatException, IOException,
        FocalPlaneException {

        log.debug("Reading file " + filename);

        List<LargeFlatField> flats = new ArrayList<LargeFlatField>();

        int numHeaderFields = 13;

        // Read data from file:
        //
        BufferedReader buf = new BufferedReader(new FileReader(filename));
        String line = new String();
        while (null != (line = buf.readLine())) {
            String[] values = line.split("\\|");
            if (numHeaderFields > values.length) {
                throw new FocalPlaneException(
                    "bad line in ImporterLargeFlatField::parseFile.  There should be more than "
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

            int yIndex = Integer.parseInt(values[9]);
            double offsetY = Double.parseDouble(values[10]);
            double scaleY = Double.parseDouble(values[11]);
            double originY = Double.parseDouble(values[12]);

            // Read out the row coefficients:
            //
            int numCoeffs = (polynomialOrder + 1) * polynomialOrder / 2
                + (polynomialOrder + 1);
            double[] coeffs = new double[numCoeffs];
            double[] covars = new double[numCoeffs * numCoeffs];

            int numTotalFields = numHeaderFields + numCoeffs + numCoeffs
                * numCoeffs;

            if (numTotalFields != values.length) {
                throw new FocalPlaneException(
                    "bad line in ImporterLargeFlatField::parseFile.  There should be "
                        + numTotalFields + " in the line, instead there are "
                        + values.length + ".  The line is \\n: " + line);
            }

            for (int ii = 0; ii < numCoeffs; ++ii) {
                int index = numHeaderFields + ii;
                coeffs[ii] = Double.parseDouble(values[index]);
            }
            for (int ii = 0; ii < numCoeffs * numCoeffs; ++ii) {
                int index = numCoeffs + numHeaderFields + ii;
                covars[ii] = Double.parseDouble(values[index]);
            }

            LargeFlatField flat = new LargeFlatField(module, output, mjd,
                polynomialOrder, type, xIndex, offsetX, 
                scaleX, originX, yIndex, offsetY, 
                scaleY, originY, coeffs,
                covars);
            flats.add(flat);
        }
        buf.close();

        log.debug("Done reading " + filename);

        return flats;
    }
    
    public List<LargeFlatField> parseFile(String filename, int ccdModule, int ccdOutput) throws NumberFormatException, IOException {
    	List<LargeFlatField> flats = new ArrayList<LargeFlatField>();
    	for (LargeFlatField flat : parseFile(filename)) {
			if (flat.getCcdModule() == ccdModule && flat.getCcdOutput() == ccdOutput) {
				flats.add(flat);
			}
		}
    	
    	return flats;
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
    public List<LargeFlatField> parseFilesInDirectory(String directoryName,
            String regex) throws NumberFormatException,
            IOException {
        List<LargeFlatField> largeFlatFields = new ArrayList<LargeFlatField>();

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
            largeFlatFields.addAll(parseFile(filename));
        }

        return largeFlatFields;
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
    public List<LargeFlatField> parseFilesInDirectory(String directoryName,
            String regex, int ccdModule, int ccdOutput)
            throws NumberFormatException, IOException {
        // Filter the results of parseFilesInDirectory(directoryName) for
        // mod/out:
        //
        List<LargeFlatField> largeFlatFields = new ArrayList<LargeFlatField>();
        for (LargeFlatField largeFlatField : parseFilesInDirectory(directoryName, regex)) {
            if (largeFlatField.getCcdModule() == ccdModule
                    && largeFlatField.getCcdOutput() == ccdOutput) {
                largeFlatFields.add(largeFlatField);
            }
        }

        return largeFlatFields;
    }

    public static void main(String[] args) throws
        IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterLargeFlatField importer = new ImporterLargeFlatField();        
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
        History history = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (history == null) {
            String description = "created by ImporterLargeFlatField.appendNew becausethere were no LargeFlatField historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.LARGEFLATFIELD, description,
                    version);
            fcCrud.create(history);
        }

        // Get LargeFlatFields from directory
        List<LargeFlatField> largeFlatFields = parseFilesInDirectory(dataDirectory,DATAFILE_REGEX, ccdModule, ccdOutput);

        // Check if all LargeFlatFields to be persisted are later than the latest
        // LargeFlatField associated
        // with the History. If this is not the case, throw an error
        //
        for (LargeFlatField largeFlatField : largeFlatFields) {
            // Get the most recent entry for this History/module/output:
            //
            LargeFlatField mostRecentDatabaseLargeFlatField = fcCrud
                    .retrieveMostRecentLargeFlatField(history, largeFlatField
                            .getCcdModule(), largeFlatField.getCcdOutput());

	       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseLargeFlatField == null);
			boolean isTooEarly = !isMostRecentNull && largeFlatField.getStartTime() <= mostRecentDatabaseLargeFlatField.getStartTime();
			
			if (isTooEarly){
                throw new FocalPlaneException(
                        "appendNew requires new data to occur after existing data."
                                + " Your data is "
                                + mostRecentDatabaseLargeFlatField.getStartTime()
                                + " and the existing data is "
                                + largeFlatField.getStartTime());
            }
        }
        // Persist LargeFlatFields and LargeFlatFieldHistoryModels for each LargeFlatField
        //
        for (LargeFlatField largeFlatField : largeFlatFields) {
            LargeFlatFieldHistoryModel largeFlatFieldHistoryModel = new LargeFlatFieldHistoryModel(
                    largeFlatField, history);
            fcCrud.create(largeFlatField);
            fcCrud.create(largeFlatFieldHistoryModel);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (history == null) {
            String description = "created by ImporterLargeFlatField.appendNew becausethere were no LargeFlatField historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.LARGEFLATFIELD, description,
                    version);
            fcCrud.create(history);
        }

        // Get LargeFlatFields from directory
        List<LargeFlatField> largeFlatFields = parseFilesInDirectory(dataDirectory,
                DATAFILE_REGEX);

        // Check if all LargeFlatFields to be persisted are later than the latest
        // LargeFlatField associated
        // with the History. If this is not the case, throw an error
        //
        for (LargeFlatField largeFlatField : largeFlatFields) {
            // Get the most recent entry for this History/module/output:
            //
            LargeFlatField mostRecentDatabaseLargeFlatField = fcCrud
                    .retrieveMostRecentLargeFlatField(history, largeFlatField
                            .getCcdModule(), largeFlatField.getCcdOutput());

	       	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseLargeFlatField == null);
			boolean isTooEarly = !isMostRecentNull && largeFlatField.getStartTime() <= mostRecentDatabaseLargeFlatField.getStartTime();
			
			if (isTooEarly){
                throw new FocalPlaneException(
                        "appendNew requires new data to occur after existing data."
                                + " Your data is "
                                + mostRecentDatabaseLargeFlatField.getStartTime()
                                + " and the existing data is "
                                + largeFlatField.getStartTime());
            }
        }
        // Persist LargeFlatFields and LargeFlatFieldHistoryModels for each LargeFlatField
        //
        for (LargeFlatField largeFlatField : largeFlatFields) {
            LargeFlatFieldHistoryModel largeFlatFieldHistoryModel = new LargeFlatFieldHistoryModel(
                    largeFlatField, history);
            fcCrud.create(largeFlatField);
            fcCrud.create(largeFlatFieldHistoryModel);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for LargeFlatField in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<LargeFlatFieldHistoryModel> largeFlatFieldHistoryModels = fcCrud.retrieveLargeFlatFieldHistoryModels(oldHistory);
        List<LargeFlatField> largeFlatFieldsDB = new ArrayList<LargeFlatField>();
        for (LargeFlatFieldHistoryModel largeFlatFieldHistoryModel : largeFlatFieldHistoryModels) {
            LargeFlatField largeFlatField = largeFlatFieldHistoryModel.getLargeFlatField();
            if (largeFlatField.getCcdModule() == ccdModule && largeFlatField.getCcdOutput() == ccdOutput) {
                largeFlatFieldsDB.add(largeFlatField);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<LargeFlatField> largeFlatFieldsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < largeFlatFieldsFromFile.size(); ++ii) {
            if (!match) {
                for (LargeFlatField largeFlatField : largeFlatFieldsDB) {
                    match = largeFlatFieldsFromFile.get(ii).getStartTime() == largeFlatField
                            .getStartTime();

                    largeFlatFieldsFromFile.get(ii).setPolynomialOrder(largeFlatField.getPolynomialOrder());
                    largeFlatFieldsFromFile.get(ii).setType(largeFlatField.getType());
                    largeFlatFieldsFromFile.get(ii).setXIndex(largeFlatField.getXIndex());
                    largeFlatFieldsFromFile.get(ii).setOffsetX(largeFlatField.getOffsetX());
                    largeFlatFieldsFromFile.get(ii).setScaleX(largeFlatField.getScaleX());
                    largeFlatFieldsFromFile.get(ii).setOriginX(largeFlatField.getOriginX());
                    largeFlatFieldsFromFile.get(ii).setYIndex(largeFlatField.getYIndex());
                    largeFlatFieldsFromFile.get(ii).setOffsetY(largeFlatField.getOffsetY());
                    largeFlatFieldsFromFile.get(ii).setScaleY(largeFlatField.getScaleY());
                    largeFlatFieldsFromFile.get(ii).setOriginY(largeFlatField.getOriginY());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input LargeFlatField  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterLargeFlatField.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.LARGEFLATFIELD,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new LargeFlatFieldHistoryModels linking new history to old data +
        // new replacement data
        //
        for (LargeFlatField largeFlatField : largeFlatFieldsDB) {
            LargeFlatFieldHistoryModel rnhm = new LargeFlatFieldHistoryModel(largeFlatField,
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for LargeFlatField in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<LargeFlatFieldHistoryModel> largeFlatFieldHistoryModels = fcCrud
                .retrieveLargeFlatFieldHistoryModels(oldHistory);
        List<LargeFlatField> largeFlatFieldsDB = new ArrayList<LargeFlatField>();
        for (LargeFlatFieldHistoryModel largeFlatFieldHistoryModel : largeFlatFieldHistoryModels) {
            largeFlatFieldsDB.add(largeFlatFieldHistoryModel.getLargeFlatField());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<LargeFlatField> largeFlatFieldsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < largeFlatFieldsFromFile.size(); ++ii) {
            if (!match) {
                for (LargeFlatField largeFlatField : largeFlatFieldsDB) {
                    match = largeFlatFieldsFromFile.get(ii).getStartTime() == largeFlatField
                            .getStartTime();
                    
                    largeFlatFieldsFromFile.get(ii).setPolynomialOrder(largeFlatField.getPolynomialOrder());
                    largeFlatFieldsFromFile.get(ii).setType(largeFlatField.getType());
                    largeFlatFieldsFromFile.get(ii).setXIndex(largeFlatField.getXIndex());
                    largeFlatFieldsFromFile.get(ii).setOffsetX(largeFlatField.getOffsetX());
                    largeFlatFieldsFromFile.get(ii).setScaleX(largeFlatField.getScaleX());
                    largeFlatFieldsFromFile.get(ii).setOriginX(largeFlatField.getOriginX());
                    largeFlatFieldsFromFile.get(ii).setYIndex(largeFlatField.getYIndex());
                    largeFlatFieldsFromFile.get(ii).setOffsetY(largeFlatField.getOffsetY());
                    largeFlatFieldsFromFile.get(ii).setScaleY(largeFlatField.getScaleY());
                    largeFlatFieldsFromFile.get(ii).setOriginY(largeFlatField.getOriginY());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input LargeFlatField  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterLargeFlatField.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.LARGEFLATFIELD,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new LargeFlatFieldHistoryModels linking new history to old data +
        // new replacement data
        //
        for (LargeFlatField largeFlatField : largeFlatFieldsDB) {
            LargeFlatFieldHistoryModel rnhm = new LargeFlatFieldHistoryModel(largeFlatField,
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the LargeFlatField for that History
        List<LargeFlatFieldHistoryModel> largeFlatFieldHistoryModels = fcCrud
                .retrieveLargeFlatFieldHistoryModels(oldHistory);
        List<LargeFlatField> databaseLargeFlatFields = new ArrayList<LargeFlatField>();
        for (LargeFlatFieldHistoryModel largeFlatFieldHistoryModel : largeFlatFieldHistoryModels) {
            databaseLargeFlatFields.add(largeFlatFieldHistoryModel.getLargeFlatField());
        }

        // Parse the data out of the file
        List<LargeFlatField> largeFlatFields = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.LARGEFLATFIELD,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryLargeFlatFieldModels for each LargeFlatField and persist them.
        // Also
        // persist the LargeFlatField object.
        for (LargeFlatField largeFlatField : largeFlatFields) {
            LargeFlatFieldHistoryModel largeFlatFieldHistoryModel = new LargeFlatFieldHistoryModel(
                    largeFlatField, newHistory);
            fcCrud.create(largeFlatFieldHistoryModel);
            fcCrud.create(largeFlatField);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.LARGEFLATFIELD);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the LargeFlatField for that History
        List<LargeFlatFieldHistoryModel> largeFlatFieldHistoryModels = fcCrud
                .retrieveLargeFlatFieldHistoryModels(oldHistory);
        List<LargeFlatField> databaseLargeFlatFields = new ArrayList<LargeFlatField>();
        for (LargeFlatFieldHistoryModel largeFlatFieldHistoryModel : largeFlatFieldHistoryModels) {
            databaseLargeFlatFields.add(largeFlatFieldHistoryModel.getLargeFlatField());
        }

        // Parse the data out of the file
        List<LargeFlatField> largeFlatFields = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.LARGEFLATFIELD,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryLargeFlatFieldModels for each LargeFlatField and persist them.
        // Also
        // persist the LargeFlatField object.
        for (LargeFlatField largeFlatField : largeFlatFields) {
            LargeFlatFieldHistoryModel largeFlatFieldHistoryModel = new LargeFlatFieldHistoryModel(
                    largeFlatField, newHistory);
            fcCrud.create(largeFlatFieldHistoryModel);
            fcCrud.create(largeFlatField);
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
