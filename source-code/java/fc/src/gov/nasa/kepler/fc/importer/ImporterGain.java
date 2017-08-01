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
import gov.nasa.kepler.hibernate.fc.Gain;
import gov.nasa.kepler.hibernate.fc.GainHistoryModel;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterGain extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.GAIN;
    public static final String DATAFILE_DIRECTORY_NAME = "gain";
    public static final String DATAFILE_REGEX = "kplr\\d+_gain\\.txt";
    
    /**
     * 
     * @param directoryName
     * @param regex
     * @return
     * @throws FocalPlaneException
     * @throws NumberFormatException
     * @throws IOException
     */
    public List<Gain> parseFilesInDirectory(String directoryName,
            String regex) throws NumberFormatException,
            IOException {
        List<Gain> gains = new ArrayList<Gain>();

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
            gains.addAll(parseFile(filename));
        }

        return gains;
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
    public List<Gain> parseFilesInDirectory(String directoryName,
            String regex, int ccdModule, int ccdOutput)
            throws NumberFormatException, IOException {
        // Filter the results of parseFilesInDirectory(directoryName) for
        // mod/out:
        //
        List<Gain> gains = new ArrayList<Gain>();
        for (Gain gain : parseFilesInDirectory(directoryName, regex)) {
            if (gain.getCcdModule() == ccdModule
                    && gain.getCcdOutput() == ccdOutput) {
                gains.add(gain);
            }
        }

        return gains;
    }

    
    /**
     * Generate a list of gains from the file filename
     * (public for testing)
     * @param filename
     * @return
     * @throws IOException
     * @throws NumberFormatException
     */
    public List<Gain> parseFile(String filename) throws IOException {

        log.debug("Reading file " + filename);

        List<Gain> gains = new ArrayList<Gain>();

        // Load data from file:
        //
        BufferedReader buf = new BufferedReader(new FileReader(filename));
        String line = new String();
        while (null != (line = buf.readLine())) {
            String[] values = line.split("\\|");
            double mjd   = Double.parseDouble(values[0]);
            int module   = Integer.parseInt(values[1]);
            int output   = Integer.parseInt(values[2]);
            double value = Double.parseDouble(values[3]);
            Gain gain    = new Gain(module, output, value, mjd);
            gains.add(gain);
        }
        buf.close();
        log.debug("Done reading file " + filename);
        return gains;
    }

    public static void main(String[] args) throws IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterGain importer = new ImporterGain();        
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
        History history = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (history == null) {
            String description = "created by ImporterGain.appendNew becausethere were no Gain historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.GAIN, description,
                    version);
            fcCrud.create(history);
        }

        // Get the most recent entry for this History:
        //
        Gain mostRecentDatabaseGain = fcCrud
                .retrieveMostRecentGain(history, ccdModule, ccdOutput);

        // Get Gains for the right module/output from the given
        // dataDirectory:
        //
        List<Gain> gains = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Check if all Gains to be persisted are later than the latest
        // Gain associated
        // with the History. If this is not the case, throw an error
        //
        for (Gain gain : gains) {

        	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseGain == null);
			boolean isTooEarly = !isMostRecentNull && gain.getMjd() <= mostRecentDatabaseGain.getMjd();
			
			if (isTooEarly) {
				throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                    + " Your data is "
                    + mostRecentDatabaseGain.getMjd()
                    + " and the existing data is "
                    + gain.getMjd());
            }
        }


        // Persist Gains and GainHistoryModels for each gain
        //
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                gain, history);
            fcCrud.create(gain);
            fcCrud.create(gainHistoryModel);
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput, String reason, Date date)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (history == null) {
            String description = "created by ImporterGain.appendNew becausethere were no Gain historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.GAIN, description,
                    version);
            fcCrud.create(history);
        }

        // Get the most recent entry for this History:
        //
        Gain mostRecentDatabaseGain = fcCrud
                .retrieveMostRecentGain(history, ccdModule, ccdOutput);

        // Get Gains for the right module/output:
        //
        List<Gain> gains = parseFilesInDirectory(
                DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Check if all Gains to be persisted are later than the latest
        // Gain associated
        // with the History. If this is not the case, throw an error
        //
        for (Gain gain : gains) {
           	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseGain == null);
			boolean isTooEarly = !isMostRecentNull && gain.getMjd() <= mostRecentDatabaseGain.getMjd();
			
			if (isTooEarly) {
				throw new FocalPlaneException(
                        "appendNew requires new data to occur after existing data."
                                + " Your data is "
                                + mostRecentDatabaseGain.getMjd()
                                + " and the existing data is "
                                + gain.getMjd());
            }
        }

        // Persist Gains and GainHistoryModels for each Gain
        //
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, history);
            fcCrud.create(gain);
            fcCrud.create(gainHistoryModel);
        }
        updateModelMetaData(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), history, date);
    }

    @Override
    protected void appendNew(String dataDirectory, String reason, Date date)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (history == null) {
            String description = "created by ImporterGain.appendNew becausethere were no Gain historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.GAIN, description,
                    version);
            fcCrud.create(history);
        }

        // Get Gains from directory
        List<Gain> gains = parseFilesInDirectory(dataDirectory,
                DATAFILE_REGEX);

        // Check if all Gains to be persisted are later than the latest
        // Gain associated
        // with the History. If this is not the case, throw an error
        //
        for (Gain gain : gains) {
            // Get the most recent entry for this History/module/output:
            //
            Gain mostRecentDatabaseGain = fcCrud
                    .retrieveMostRecentGain(history, gain
                            .getCcdModule(), gain.getCcdOutput());

           	// mostRecentDatabase == null indicates this is the first time data has been put into this table:
			//
			boolean isMostRecentNull = (mostRecentDatabaseGain == null);
			boolean isTooEarly = !isMostRecentNull && gain.getMjd() <= mostRecentDatabaseGain.getMjd();
			
			if (isTooEarly) {
                throw new FocalPlaneException(
                        "appendNew requires new data to occur after existing data."
                                + " Your data is "
                                + mostRecentDatabaseGain.getMjd()
                                + " and the existing data is "
                                + gain.getMjd());
            }
        }
        // Persist Gains and GainHistoryModels for each Gain
        //
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, history);
            fcCrud.create(gain);
            fcCrud.create(gainHistoryModel);
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(String reason, Date date) throws IOException {
        appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(), reason, date);
    }
    
    @Override
    protected HistoryModelName getHistoryModelName() {
        return HISTORY_MODEL_NAME;
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput,
            String dataDirectory, String reason) throws IOException,
            FocalPlaneException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Gain in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<GainHistoryModel> gainHistoryModels = fcCrud.retrieveGainHistoryModels(oldHistory);
        List<Gain> gainsDB = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            Gain gain = gainHistoryModel.getGain();
            if (gain.getCcdModule() == ccdModule && gain.getCcdOutput() == ccdOutput) {
                gainsDB.add(gain);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Gain> gainsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < gainsFromFile.size(); ++ii) {
            if (!match) {
                for (Gain gain : gainsDB) {
                    match = gainsFromFile.get(ii).getMjd() == gain
                            .getMjd();
                    gainsFromFile.get(ii).setGain(
                            gain.getGain());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Gain  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterGain.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.GAIN,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new GainHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Gain gain : gainsDB) {
            GainHistoryModel rnhm = new GainHistoryModel(gain,
                    history);
            fcCrud.create(rnhm);
        }
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput, String reason)
            throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Gain in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> gainsDB = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            Gain gain = gainHistoryModel.getGain();
            if (gain.getCcdModule() == ccdModule && gain.getCcdOutput() == ccdOutput) {
                gainsDB.add(gain);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Gain> gainsFromFile = parseFilesInDirectory(
                DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < gainsFromFile.size(); ++ii) {
            if (!match) {
                for (Gain gain : gainsDB) {
                    match = gainsFromFile.get(ii).getMjd() == gain
                            .getMjd();
                    gainsFromFile.get(ii).setGain(
                            gain.getGain());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Gain  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterGain.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.GAIN,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new GainHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Gain gain : gainsDB) {
            GainHistoryModel rnhm = new GainHistoryModel(gain,
                    history);
            fcCrud.create(rnhm);
        }
    }

    @Override
    public void changeExisting(String dataDirectory, String reason)
            throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Gain in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> gainsDB = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            gainsDB.add(gainHistoryModel.getGain());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Gain> gainsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < gainsFromFile.size(); ++ii) {
            if (!match) {
                for (Gain gain : gainsDB) {
                    match = gainsFromFile.get(ii).getMjd() == gain
                            .getMjd();
                    gainsFromFile.get(ii).setGain(
                            gain.getGain());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Gain  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterGain.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.GAIN,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new GainHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Gain gain : gainsDB) {
            GainHistoryModel rnhm = new GainHistoryModel(gain,
                    history);
            fcCrud.create(rnhm);
        }
    }

    @Override
    public void changeExisting(String reason) throws IOException,
            FocalPlaneException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Gain in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> gainsDB = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            gainsDB.add(gainHistoryModel.getGain());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Gain> gainsFromFile = parseFilesInDirectory(
                DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < gainsFromFile.size(); ++ii) {
            if (!match) {
                for (Gain gain : gainsDB) {
                    match = gainsFromFile.get(ii).getMjd() == gain
                            .getMjd();
                    gainsFromFile.get(ii).setGain(
                            gain.getGain());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Gain  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterGain.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.GAIN,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new GainHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Gain gain : gainsDB) {
            GainHistoryModel rnhm = new GainHistoryModel(gain,
                    history);
            fcCrud.create(rnhm);
        }
    }


    @Override
    public void insertBetween(int ccdModule, int ccdOutput,
            String dataDirectory, String reason) throws IOException,
            FocalPlaneException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Gain for that History
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> databaseGains = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            databaseGains.add(gainHistoryModel.getGain());
        }

        // Parse the data out of the file
        List<Gain> gains = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.GAIN,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryGainModels for each Gain and persist them.
        // Also
        // persist the Gain object.
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, newHistory);
            fcCrud.create(gainHistoryModel);
            fcCrud.create(gain);
        }
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
            throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Gain for that History
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> databaseGains = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            databaseGains.add(gainHistoryModel.getGain());
        }

        // Parse the data out of the file
        List<Gain> gains = parseFilesInDirectory(DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.GAIN,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryGainModels for each Gain and persist them.
        // Also
        // persist the Gain object.
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, newHistory);
            fcCrud.create(gainHistoryModel);
            fcCrud.create(gain);
        }
    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
            throws IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Gain for that History
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> databaseGains = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            databaseGains.add(gainHistoryModel.getGain());
        }

        // Parse the data out of the file
        List<Gain> gains = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.GAIN,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryGainModels for each Gain and persist them.
        // Also
        // persist the Gain object.
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, newHistory);
            fcCrud.create(gainHistoryModel);
            fcCrud.create(gain);
        }

    }

    @Override
    public void insertBetween(String reason) throws IOException,
            FocalPlaneException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.GAIN);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Gain for that History
        List<GainHistoryModel> gainHistoryModels = fcCrud
                .retrieveGainHistoryModels(oldHistory);
        List<Gain> databaseGains = new ArrayList<Gain>();
        for (GainHistoryModel gainHistoryModel : gainHistoryModels) {
            databaseGains.add(gainHistoryModel.getGain());
        }

        // Parse the data out of the file
        List<Gain> gains = parseFilesInDirectory(DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.GAIN,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryGainModels for each Gain and persist them.
        // Also
        // persist the Gain object.
        for (Gain gain : gains) {
            GainHistoryModel gainHistoryModel = new GainHistoryModel(
                    gain, newHistory);
            fcCrud.create(gainHistoryModel);
            fcCrud.create(gain);
        }
    }

    public void loadSeedData() throws Exception {
    	appendNew("loadSeedData", new Date());
    }

}
