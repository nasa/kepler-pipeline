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
import gov.nasa.kepler.fc.SaturationOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Saturation;
import gov.nasa.kepler.hibernate.fc.SaturationHistoryModel;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ImporterSaturation extends ImporterParentNonImage {

    private static final HistoryModelName HISTORY_MODEL_NAME = HistoryModelName.SATURATION;
    public static final String DATAFILE_DIRECTORY_NAME = "saturation";
    public static final String DATAFILE_REGEX = "kplr\\d+_saturation\\.txt";
    
    /**
     * 
     * @param directoryName
     * @param regex
     * @return
     * @throws IOException 
     * @throws NumberFormatException 
     * @throws Exception 
     */
    public List<Saturation> parseFilesInDirectory(String directoryName,
            String regex) throws NumberFormatException, IOException {
        List<Saturation> saturations = new ArrayList<Saturation>();

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
            saturations.addAll(parseFile(filename));
        }

        return saturations;
    }

    /**
     * 
     * @param directoryName
     * @param regex
     * @param ccdModule
     * @param ccdOutput
     * @return
     * @throws IOException 
     * @throws NumberFormatException 
     * @throws Exception 
     */
    public List<Saturation> parseFilesInDirectory(String directoryName,
            String regex, int ccdModule, int ccdOutput)
            throws NumberFormatException, IOException {
        // Filter the results of parseFilesInDirectory(directoryName) for
        // mod/out:
        //
        
        List<Saturation> saturations = new ArrayList<Saturation>();
        for (Saturation saturation : parseFilesInDirectory(directoryName, regex)) {
            
            int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);    
            if (channel == saturation.getChannel()) {
                saturations.add(saturation);
            }
        }

        return saturations;
    }

    
    /**
     * Generate a list of Saturations from the file filename
     * (public for testing)
     * @param filename
     * @return
     * @throws Exception 
     * @throws IOException 
     * @throws NumberFormatException 
     * @throws Exception 
     * @throws NumberFormatException
     * @throws FocalPlaneException 
     */
    public List<Saturation> parseFile(String filename) throws NumberFormatException, IOException {

        log.debug("Reading file " + filename);

        List<Saturation> saturations = new ArrayList<Saturation>();

        // Load data from file:
        //
        BufferedReader buf = new BufferedReader(new FileReader(filename));
        String line = new String();
        while (null != (line = buf.readLine())) {
            // Skip commented out lines (lines with leading #):
            if (line.matches("^#.*")) {
                continue;
            }
            String[] values = line.split("\\|");
            
            int keplerId  = Integer.parseInt(values[0]);
            int season    = Integer.parseInt(values[1]);
            if (season < 0 || season > 3) {
                throw new FocalPlaneException(
                    "The value of the Season value must be between 0 and 3.  This is violated in line +'"
                        + line
                        + "' of file '"
                        + filename
                        + "', which has value " + season);
            }
            int ccdModule = Integer.parseInt(values[2]);
            int ccdOutput = Integer.parseInt(values[3]);

            if (!FcConstants.validCcdModule(ccdModule)|| !FcConstants.validCcdOutput(ccdOutput)) {
                throw new FocalPlaneException("ccd module " + ccdModule + ", ccd outpzut " + ccdOutput + " is not a Kepler mod/out. Exiting."); 
            }
            
            // The saturation columns are specified in triplets of (column, rowStart, rowEnd).  There
            // can be different numbers of saturation columns for each keplerId, but there must 
            // be 4 + 3n elements in the values arrays (keplerId, season, module, output, and n column triplets)
            //
            int numLeaderColumns = 4;
            int saturationColumns = values.length - numLeaderColumns;
            boolean isBadNumberOfValues = saturationColumns % 3 != 0;
            int saturationColumnCount   = saturationColumns / 3;
            if (isBadNumberOfValues) {
                throw new FocalPlaneException("Bad number of values in line +'" + line + "'. There must be 4+3n values. Exiting");
            }
            
            int valuePos = numLeaderColumns;
            int[] cols = new int[saturationColumnCount];
            int[] rowsStart = new int[saturationColumnCount];
            int[] rowsEnd = new int[saturationColumnCount];            
            for (int ii = 0; ii < saturationColumnCount; ++ii) {
                cols[ii]      = Integer.parseInt(values[valuePos++]);
                rowsStart[ii] = Integer.parseInt(values[valuePos++]);
                rowsEnd[ii]   = Integer.parseInt(values[valuePos++]);
            }
            
            int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
            Saturation saturation = new Saturation(keplerId, channel, season, cols, rowsStart, rowsEnd);
            saturations.add(saturation);
        }
        buf.close();
        log.debug("Done reading file " + filename);
        return saturations;
    }

    public static void main(String[] args) throws IOException {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        try {
            dbService.beginTransaction();
            ImporterSaturation importer = new ImporterSaturation();        
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
        History history = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (history == null) {
            String description = "created by ImporterSaturation.appendNew becausethere were no Saturation historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.SATURATION, description,
                    version);
            fcCrud.create(history);
        }

        // Get Saturations for the right module/output from the given
        // dataDirectory:
        //
        List<Saturation> saturations = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Persist Saturations and SaturationHistoryModels for each Saturation
        //
        for (Saturation saturation : saturations) {
            SaturationHistoryModel saturationHistoryModel = new SaturationHistoryModel(
                saturation, history);
            fcCrud.create(saturation);
            fcCrud.create(saturationHistoryModel);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (history == null) {
            String description = "created by ImporterSaturation.appendNew becausethere were no Saturation historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.SATURATION, description,
                    version);
            fcCrud.create(history);
        }

        // Get Saturations for the right module/output:
        //
        List<Saturation> saturations = parseFilesInDirectory(
                DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Persist Saturations and SaturationHistoryModels for each Saturation
        //
        for (Saturation saturation : saturations) {
            SaturationHistoryModel SaturationHistoryModel = new SaturationHistoryModel(
                    saturation, history);
            fcCrud.create(saturation);
            fcCrud.create(SaturationHistoryModel);
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
        History history = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (history == null) {
            String description = "created by ImporterSaturation.appendNew becausethere were no Saturation historys; " + reason;
            int version = 1;
            date = new Date();
            double now = ModifiedJulianDate.dateToMjd(date);
            history = new History(now, HistoryModelName.SATURATION, description,
                    version);
            fcCrud.create(history);
        }

        // Get Saturations from directory
        List<Saturation> Saturations = parseFilesInDirectory(dataDirectory,
                DATAFILE_REGEX);

        // Persist Saturations and SaturationHistoryModels for each Saturation
        //
        SaturationOperations ops = new SaturationOperations();
        for (Saturation saturation : Saturations) {
            SaturationHistoryModel SaturationHistoryModel = new SaturationHistoryModel(
                    saturation, history);
            ops.create(saturation);
            fcCrud.create(SaturationHistoryModel);
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
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Saturation in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud.retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> saturationsDB = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            Saturation saturation = saturationHistoryModel.getSaturation();
            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(saturation.getChannel());    

            if (modOut.left == ccdModule && modOut.right == ccdOutput) {
                saturationsDB.add(saturation);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Saturation> saturationsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < saturationsFromFile.size(); ++ii) {
            if (!match) {
                for (Saturation saturation : saturationsDB) {
                    match = saturationsFromFile.get(ii).getSeason() == saturation.getSeason();
                    saturationsFromFile.get(ii).setSaturationCoordinates(saturation.getSaturationCoordinates());
                }
            }
            if (!match) {
                throw new FocalPlaneException(
                    "Input Saturation  is not a replacement for "
                    + "existing data.  Use appendNew or insertBetween instead.");
            }

            // create new history
            String description = "created by ImporterSaturation.changeExisting; " + reason;
            double now = ModifiedJulianDate.dateToMjd(new Date());
            History history = new History(now, HistoryModelName.SATURATION,
                description, oldHistory.getVersion() + 1);
            fcCrud.create(history);

            // create new SaturationHistoryModels linking new history to old data +
            // new replacement data
            //
            for (Saturation saturation : saturationsDB) {
                SaturationHistoryModel rnhm = new SaturationHistoryModel(saturation,
                    history);
                fcCrud.create(rnhm);
            }
        }
    }

    @Override
    public void changeExisting(int ccdModule, int ccdOutput, String reason)
            throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Saturation in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> saturationsDB = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            Saturation saturation = saturationHistoryModel.getSaturation();
            int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
            if (channel == saturation.getChannel()) {
                saturationsDB.add(saturation);
            }
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Saturation> saturationsFromFile = parseFilesInDirectory(
                DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < saturationsFromFile.size(); ++ii) {
            if (!match) {
                for (Saturation saturation : saturationsDB) {
                    match = saturationsFromFile.get(ii).getSeason() == saturation.getSeason();
                    saturationsFromFile.get(ii).setSaturationCoordinates(saturation.getSaturationCoordinates());                
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Saturation  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterSaturation.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.SATURATION,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new SaturationHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Saturation saturation : saturationsDB) {
            SaturationHistoryModel rnhm = new SaturationHistoryModel(saturation,
                    history);
            fcCrud.create(rnhm);
        }
    }

    @Override
    public void changeExisting(String dataDirectory, String reason)
            throws IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Saturation in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> saturationsDB = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            saturationsDB.add(saturationHistoryModel.getSaturation());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Saturation> saturationsFromFile = parseFilesInDirectory(
                dataDirectory, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < saturationsFromFile.size(); ++ii) {
            if (!match) {
                for (Saturation saturation : saturationsDB) {
                    match = saturationsFromFile.get(ii).getSeason() == saturation.getSeason();
                    saturationsFromFile.get(ii).setSaturationCoordinates(saturation.getSaturationCoordinates());                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Saturation  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterSaturation.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.SATURATION,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new SaturationHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Saturation saturation : saturationsDB) {
            SaturationHistoryModel rnhm = new SaturationHistoryModel(saturation,
                    history);
            fcCrud.create(rnhm);
        }
    }

    @Override
    public void changeExisting(String reason) throws IOException,
            FocalPlaneException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // extract current History for this model
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history exists for Saturation in changeExisting-- error.  "
                            + "Must use appendNew to add initial data.");
        }

        // get data linked to this history
        //
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> saturationsDB = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            saturationsDB.add(saturationHistoryModel.getSaturation());
        }

        // Parse input data and verify it will replace existing data. Throw an
        // error if not:
        //
        List<Saturation> saturationsFromFile = parseFilesInDirectory(DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);
        boolean match = false;
        for (int ii = 0; ii < saturationsFromFile.size(); ++ii) {
            if (!match) {
                for (Saturation saturation : saturationsDB) {
                    match = saturationsFromFile.get(ii).getSeason() == saturation.getSeason();
                    saturationsFromFile.get(ii).setSaturationCoordinates(saturation.getSaturationCoordinates());
                }
            }
        }
        if (!match) {
            throw new FocalPlaneException(
                    "Input Saturation  is not a replacement for "
                            + "existing data.  Use appendNew or insertBetween instead.");
        }

        // create new history
        String description = "created by ImporterSaturation.changeExisting; " + reason;
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History history = new History(now, HistoryModelName.SATURATION,
                description, oldHistory.getVersion() + 1);
        fcCrud.create(history);

        // create new SaturationHistoryModels linking new history to old data +
        // new replacement data
        //
        for (Saturation saturation : saturationsDB) {
            SaturationHistoryModel rnhm = new SaturationHistoryModel(saturation,
                    history);
            fcCrud.create(rnhm);
        }
    }


    @Override
    public void insertBetween(int ccdModule, int ccdOutput,
            String dataDirectory, String reason) throws NumberFormatException, IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Saturation for that History
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> databaseSaturations = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            databaseSaturations.add(saturationHistoryModel.getSaturation());
        }

        // Parse the data out of the file
        List<Saturation> saturations = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX, ccdModule, ccdOutput);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SATURATION,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySaturationModels for each Saturation and persist them.
        // Also
        // persist the Saturation object.
        for (Saturation saturation : saturations) {
            SaturationHistoryModel saturationHistoryModel = new SaturationHistoryModel(
                    saturation, newHistory);
            fcCrud.create(saturationHistoryModel);
            fcCrud.create(saturation);
        }
    }

    @Override
    public void insertBetween(int ccdModule, int ccdOutput, String reason)
            throws NumberFormatException, IOException {
        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Saturation for that History
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> databaseSaturations = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            databaseSaturations.add(saturationHistoryModel.getSaturation());
        }

        // Parse the data out of the file
        List<Saturation> saturations = parseFilesInDirectory(DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SATURATION,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySaturationModels for each Saturation and persist them.
        // Also
        // persist the Saturation object.
        for (Saturation saturation : saturations) {
            SaturationHistoryModel saturationHistoryModel = new SaturationHistoryModel(
                    saturation, newHistory);
            fcCrud.create(saturationHistoryModel);
            fcCrud.create(saturation);
        }
    }

    @Override
    public void insertBetween(String dataDirectory, String reason)
            throws NumberFormatException, IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Saturation for that History
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> databaseSaturations = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            databaseSaturations.add(saturationHistoryModel.getSaturation());
        }

        // Parse the data out of the file
        List<Saturation> saturations = parseFilesInDirectory(dataDirectory, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SATURATION,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySaturationModels for each Saturation and persist them.
        // Also
        // persist the Saturation object.
        for (Saturation saturation : saturations) {
            SaturationHistoryModel saturationHistoryModel = new SaturationHistoryModel(
                    saturation, newHistory);
            fcCrud.create(saturationHistoryModel);
            fcCrud.create(saturation);
        }

    }

    @Override
    public void insertBetween(String reason) throws NumberFormatException, IOException {

        FcCrud fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());

        // Get the current History
        History oldHistory = fcCrud.retrieveHistory(HistoryModelName.SATURATION);
        if (oldHistory == null) {
            throw new FocalPlaneException(
                    "no history found in insertBetween-- something is wrong!");
        }

        // Get all the Saturation for that History
        List<SaturationHistoryModel> saturationHistoryModels = fcCrud
                .retrieveSaturationHistoryModels(oldHistory);
        List<Saturation> databaseSaturations = new ArrayList<Saturation>();
        for (SaturationHistoryModel saturationHistoryModel : saturationHistoryModels) {
            databaseSaturations.add(saturationHistoryModel.getSaturation());
        }

        // Parse the data out of the file
        List<Saturation> saturations = parseFilesInDirectory(DATAFILE_DIRECTORY_NAME, DATAFILE_REGEX);

        // Create new History, iterate the version
        double now = ModifiedJulianDate.dateToMjd(new Date());
        History newHistory = new History(now, HistoryModelName.SATURATION,
                reason, oldHistory.getVersion() + 1);
        fcCrud.create(newHistory);

        // Create HistorySaturationModels for each Saturation and persist them.
        // Also
        // persist the Saturation object.
        for (Saturation saturation : saturations) {
            SaturationHistoryModel saturationHistoryModel = new SaturationHistoryModel(
                    saturation, newHistory);
            fcCrud.create(saturationHistoryModel);
            fcCrud.create(saturation);
        }
    }

    public void loadSeedData() throws Exception {
        appendNew("loadSeedData", new Date());
    }

}
