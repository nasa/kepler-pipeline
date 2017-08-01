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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.hibernate.fc.RollTimeHistoryModel;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Importer for the rollTimeModel.
 * 
 * @author Forrest Girouard
 * 
 */
public class ImporterRollTime extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.ROLLTIME;
    public static final String DATAFILE_DIRECTORY_NAME = "roll-time";
    public static final String DATAFILE_REGEX = "kplr\\d+_rolltime\\.txt";

    @SuppressWarnings("resource")
    public List<RollTime> parseFile(String filename) throws IOException {
        log.debug("Reading file " + filename);

        List<RollTime> rollTimes = new ArrayList<RollTime>();

        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(filename));
            while (null != (line = reader.readLine())) {
                RollTime rollTime = null;
                String[] values = line.split("\\s*,\\s*");
                if (values.length > 1) {
                    double mjd = Double.parseDouble(values[0]);
                    int season = Integer.parseInt(values[1]);
                    if (values.length == 2) {
                        if (mjd <= FcConstants.KEPLER_END_OF_MISSION_MJD) {
                            rollTime = new RollTime(mjd, season);
                        } else {
                            log.warn(String.format(
                                "Skipping invalid entry, MJD can't be > to %f: %s",
                                FcConstants.KEPLER_END_OF_MISSION_MJD, line));
                        }
                    } else if (values.length > 5) {
                        double rollTimeOffset = Double.parseDouble(values[2]);
                        double fovCenterRa = Double.parseDouble(values[3]);
                        double fovCenterDeclination = Double.parseDouble(values[4]);
                        double fovCenterRoll = Double.parseDouble(values[5]);
                        if (mjd > FcConstants.KEPLER_END_OF_MISSION_MJD) {
                            rollTime = new RollTime(mjd, season,
                                rollTimeOffset, fovCenterRa,
                                fovCenterDeclination, fovCenterRoll);
                        } else {
                            log.warn(String.format(
                                "Skipping invalid entry, MJD can't be <= to %f: %s",
                                FcConstants.KEPLER_END_OF_MISSION_MJD, line));
                        }
                    } else {
                        throw new PipelineException(
                            "invalid RollTimeModel entry, invalid number of colums: "
                                + line);
                    }
                    if (rollTime != null) {
                        rollTimes.add(rollTime);
                    }
                } else {
                    throw new PipelineException(
                        "invalid RollTimeModel entry, invalid number of colums: "
                            + line);
                }
            }
        } catch (NumberFormatException e) {
            throw new PipelineException("invalid RollTime entry: " + line, e);
        } finally {
            FileUtil.close(reader);
        }
        log.debug("Done reading file " + filename);

        return rollTimes;
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
    public List<RollTime> parseFilesInDirectory(String directoryName,
        String regex) throws NumberFormatException, IOException {
        List<RollTime> rollTimes = new ArrayList<RollTime>();

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
            rollTimes.addAll(parseFile(filename));
        }

        return rollTimes;
    }

    public static void main(String[] args) throws IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterRollTime importer = new ImporterRollTime();
            importer.run(args);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput,
        String dataDirectory, String reason, Date date) throws IOException {
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput, String reason,
        Date date) throws IOException {
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    protected void appendNew(String dataDirectory, String reason, Date date)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.ROLLTIME);
        if (history == null) {
            String description = "created by ImporterRollTime.appendNew becausethere were no RollTime historys; "
                + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.ROLLTIME, description,
                version);
            fcCrud.create(history);
        }

        // Get RollTimes from directory
        List<RollTime> rollTimes = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);

        // Check if all RollTimes to be persisted are later than the latest
        // RollTime associated
        // with the History. If this is not the case, throw an error
        //
        for (RollTime rollTime : rollTimes) {
            // Get the most recent entry for this History/module/output:
            //
            RollTime mostRecentDatabaseRollTime = fcCrud.retrieveMostRecentRollTime(history);

            // mostRecentDatabase == null indicates this is the first time data
            // has been put into this table:
            //
            boolean isMostRecentNull = mostRecentDatabaseRollTime == null;
            boolean isTooEarly = !isMostRecentNull
                && rollTime.getMjd() <= mostRecentDatabaseRollTime.getMjd();

            if (isTooEarly) {
                throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                        + " Your data is "
                        + mostRecentDatabaseRollTime.getMjd()
                        + " and the existing data is " + rollTime.getMjd());
            }
        }
        // Persist RollTimes and RollTimeHistoryModels for each RollTime
        //
        for (RollTime rollTime : rollTimes) {
            RollTimeHistoryModel rollTimeHistoryModel = new RollTimeHistoryModel(
                rollTime, history);
            fcCrud.create(rollTime);
            fcCrud.create(rollTimeHistoryModel);
        }
        updateModelMetaData(dataDirectory, history, date);
    }

    @Override
    protected void appendNew(String reason, Date date) throws IOException,
        FocalPlaneException {
        appendNew(getDataDirectory(DATAFILE_DIRECTORY_NAME).getAbsolutePath(),
            reason, date);
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput,
        String dataDirectory, String reason) throws IOException,
        FocalPlaneException {
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    public void changeExisting(String dataDirectory, String reason)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.ROLLTIME);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history exists for RollTime in changeExisting-- error.  "
                    + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<RollTimeHistoryModel> rollTimeHistoryModels = fcCrud.retrieveRollTimeHistoryModels(oldHistory);
        List<RollTime> rollTimesDB = new ArrayList<RollTime>();
        for (RollTimeHistoryModel rollTimeHistoryModel : rollTimeHistoryModels) {
            rollTimesDB.add(rollTimeHistoryModel.getRollTime());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<RollTime> rollTimesFromFile = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < rollTimesFromFile.size(); ++ii) {
            if (!match) {
                for (RollTime rollTime : rollTimesDB) {
                    match = rollTimesFromFile.get(ii)
                        .getMjd() == rollTime.getMjd();
                    rollTimesFromFile.get(ii)
                        .setSeason(rollTime.getSeason());
                    rollTimesFromFile.get(ii)
                        .setRollOffset(rollTime.getRollOffset());
                    rollTimesFromFile.get(ii)
                        .setFovCenterRa(rollTime.getFovCenterRa());
                    rollTimesFromFile.get(ii)
                        .setFovCenterDeclination(
                            rollTime.getFovCenterDeclination());
                    rollTimesFromFile.get(ii)
                        .setFovCenterRoll(rollTime.getFovCenterRoll());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                "Input RollTime  is not a replacement for "
                    + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterRollTime.changeExisting; "
            + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.ROLLTIME,
            description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new RollTimeHistoryModels linking new history to old data +
        // new replacement data
        //
        for (RollTime rollTime : rollTimesDB) {
            RollTimeHistoryModel rnhm = new RollTimeHistoryModel(rollTime,
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
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        throw new FocalPlaneException("not implemented for RollTime");
    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.ROLLTIME);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history found in insertBetween-- something is wrong!");
        }

        // Get all the RollTime for that History
        List<RollTimeHistoryModel> rollTimeHistoryModels = fcCrud.retrieveRollTimeHistoryModels(oldHistory);
        List<RollTime> databaseRollTimes = new ArrayList<RollTime>();
        for (RollTimeHistoryModel rollTimeHistoryModel : rollTimeHistoryModels) {
            databaseRollTimes.add(rollTimeHistoryModel.getRollTime());
        }

        // Parse the data out of the file
        List<RollTime> rollTimes = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.ROLLTIME,
            reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryRollTimeModels for each RollTime and persist them.
        // Also
        // persist the RollTime object.
        for (RollTime rollTime : rollTimes) {
            RollTimeHistoryModel rollTimeHistoryModel = new RollTimeHistoryModel(
                rollTime, newHistory);
            fcCrud.create(rollTimeHistoryModel);
            fcCrud.create(rollTime);
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
