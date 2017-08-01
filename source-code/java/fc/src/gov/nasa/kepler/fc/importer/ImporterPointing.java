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
import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.kepler.hibernate.fc.PointingHistoryModel;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterPointing extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.POINTING;
    public static final String DATAFILE_DIRECTORY_NAME = "pointing";
    public static final String DATAFILE_REGEX = "kplr\\d+_pointing\\.txt";

    /**
     * Generate a list of pointings from the file filename
     * 
     * @param filename
     * @return
     * @throws IOException
     * @throws NumberFormatException
     */
    public List<Pointing> parseFile(String filename) throws IOException {

        log.debug("Reading file " + filename);

        List<Pointing> pointings = new ArrayList<Pointing>();

        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(filename));
            Double firstMjd = null;
            while (null != (line = reader.readLine())) {
                Pointing pointing = null;
                String[] values = line.split("\\s+");
                if (values.length > 3) {
                    double mjd = Double.parseDouble(values[0]);
                    double ra = Double.parseDouble(values[1]);
                    double declination = Double.parseDouble(values[2]);
                    double roll = Double.parseDouble(values[3]);
                    if (firstMjd == null) {
                        firstMjd = mjd;
                    }
                    if (values.length == 4) {
                        if (mjd <= FcConstants.KEPLER_END_OF_MISSION_MJD) {
                            pointing = new Pointing(mjd, ra, declination, roll,
                                firstMjd.doubleValue());
                        } else {
                            log.warn(String.format(
                                "Skipping invalid entry, MJD can't be > to %f: %s",
                                FcConstants.KEPLER_END_OF_MISSION_MJD, line));
                        }
                    } else if (mjd > FcConstants.KEPLER_END_OF_MISSION_MJD) {
                        double segmentStartMjd = Double.parseDouble(values[4]);
                        pointing = new Pointing(mjd, ra, declination, roll,
                            segmentStartMjd);
                    }
                } else {
                    log.warn("Skipping invalid entry, invalid number of colums: "
                        + line);
                }
                if (pointing != null) {
                    pointings.add(pointing);
                }
            }
        } catch (NumberFormatException e) {
            throw new PipelineException("invalid Pointing entry: " + line, e);
        } finally {
            FileUtil.close(reader);
        }

        log.debug("Done reading file " + filename);

        return pointings;
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
    public List<Pointing> parseFilesInDirectory(String directoryName,
        String regex) throws NumberFormatException, IOException {
        List<Pointing> pointings = new ArrayList<Pointing>();

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
            pointings.addAll(parseFile(filename));
        }

        return pointings;
    }

    public static void main(String[] args) throws IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterPointing importer = new ImporterPointing();
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
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    protected void appendNew(int ccdModule, int ccdOutput, String reason,
        Date date) throws IOException {
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    protected void appendNew(String dataDirectory, String reason, Date date)
        throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        Date nowDate = date;
        double nowMjd = ModifiedJulianDate.dateToMjd(nowDate);
        // Get the most recent history (create one if there aren't any (first
        // run case))
        //
        History history = fcCrud.retrieveHistory(HistoryModelName.POINTING);
        if (history == null) {
            String description = "created by ImporterPointing.appendNew becausethere were no Pointing historys; "
                + reason;
            int version = 1;
            history = new History(nowMjd, HistoryModelName.POINTING,
                description, version);
            fcCrud.create(history);
        }

        // Get Pointings from directory
        List<Pointing> pointings = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);

        // Check if all Pointings to be persisted are later than the latest
        // Pointing associated
        // with the History. If this is not the case, throw an error
        //
        for (Pointing pointing : pointings) {
            // Get the most recent entry for this History/module/output:
            //
            Pointing mostRecentDatabasePointing = fcCrud.retrieveMostRecentPointing(history);

            // mostRecentDatabase == null indicates this is the first time data
            // has been put into this table:
            //
            boolean isMostRecentNull = (mostRecentDatabasePointing == null);
            boolean isTooEarly = !isMostRecentNull
                && pointing.getMjd() <= mostRecentDatabasePointing.getMjd();

            if (isTooEarly) {
                throw new FocalPlaneException(
                    "appendNew requires new data to occur after existing data."
                        + " Your data is "
                        + mostRecentDatabasePointing.getMjd()
                        + " and the existing data is " + pointing.getMjd());
            }
        }
        // Persist Pointings and PointingHistoryModels for each Pointing
        //
        for (Pointing pointing : pointings) {
            PointingHistoryModel pointingHistoryModel = new PointingHistoryModel(
                pointing, history);
            fcCrud.create(pointing);
            fcCrud.create(pointingHistoryModel);
        }
        updateModelMetaData(dataDirectory, history, nowDate);
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
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    public void changeExisting(String dataDirectory, String reason)
        throws IOException {
        FcCrud fcCrud = new FcCrud();

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.POINTING);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history exists for Pointing in changeExisting-- error.  "
                    + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<PointingHistoryModel> pointingHistoryModels = fcCrud.retrievePointingHistoryModels(oldHistory);
        List<Pointing> pointingsDB = new ArrayList<Pointing>();
        for (PointingHistoryModel pointingHistoryModel : pointingHistoryModels) {
            pointingsDB.add(pointingHistoryModel.getPointing());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Pointing> pointingsFromFile = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);
        boolean match = false;
        for (int i = 0; i < pointingsFromFile.size(); ++i) {
            if (!match) {
                for (Pointing pointing : pointingsDB) {
                    match = pointingsFromFile.get(i)
                        .getMjd() == pointing.getMjd();

                    pointingsFromFile.get(i)
                        .setRa(pointing.getRa());
                    pointingsFromFile.get(i)
                        .setDeclination(pointing.getDeclination());
                    pointingsFromFile.get(i)
                        .setRoll(pointing.getRoll());
                    pointingsFromFile.get(i)
                        .setSegmentStartMjd(pointing.getSegmentStartMjd());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                "Input Pointing  is not a replacement for "
                    + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterPointing.changeExisting; "
            + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.POINTING,
            description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new PointingHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Pointing pointing : pointingsDB) {
            PointingHistoryModel rnhm = new PointingHistoryModel(pointing,
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
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
        throws IOException {
        throw new FocalPlaneException("not implemented for Pointing");
    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
        throws IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.POINTING);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Pointing for that History
        List<PointingHistoryModel> pointingHistoryModels = fcCrud.retrievePointingHistoryModels(oldHistory);
        List<Pointing> databasePointings = new ArrayList<Pointing>();
        for (PointingHistoryModel pointingHistoryModel : pointingHistoryModels) {
            databasePointings.add(pointingHistoryModel.getPointing());
        }

        // Parse the data out of the file
        List<Pointing> pointings = parseFilesInDirectory(dataDirectory,
            DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.POINTING,
            reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistoryPointingModels for each Pointing and persist them.
        // Also
        // persist the Pointing object.
        for (Pointing pointing : pointings) {
            PointingHistoryModel pointingHistoryModel = new PointingHistoryModel(
                pointing, newHistory);
            fcCrud.create(pointingHistoryModel);
            fcCrud.create(pointing);
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
