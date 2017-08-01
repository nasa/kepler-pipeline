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

package gov.nasa.kepler.mr;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.importer.ImporterInvalidPixels;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.ConfigMap;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.mr.MrReportCrud;
import gov.nasa.kepler.hibernate.mr.MrReportCrudTest;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mr.users.pi.Permissions;
import gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Seeds the database with data that is useful for MR development. If you're
 * adding a report and want to seed the data with your own data, append a new
 * {@code seedFoo} method to the end and call it from {@link #loadAll()}.
 * 
 * @author Bill Wohler
 */
public class MrSeedTestData {
    private static final Log log = LogFactory.getLog(MrSeedTestData.class);

    private static final int MILLIS_PER_MINUTE = 60 * 1000;
    private static final long MILLIS_PER_HOUR = 60 * MILLIS_PER_MINUTE;
    private static final long MILLIS_PER_DAY = 24 * MILLIS_PER_HOUR;

    public static void main(String[] args) {
        log.info("Initializing database");
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        try {
            databaseService.beginTransaction();
            fsClient.beginLocalFsTransaction();
            new MrSeedTestData().loadSeedData();
            log.info("Committing transactions");
            fsClient.commitLocalFsTransaction();
            databaseService.commitTransaction();
        } catch (Exception e) {
            log.error("Load failed", e);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        System.exit(0); // take out the fs server
    }

    /**
     * Creates data for testing MR.
     */
    public void loadAll() {
        log.info("Loading data for MR use");

        seedUsers();
        seedPipeline();
        seedDataReceipt();
        seedAlerts();
        seedConfigMaps();
        seedFcHistory();
        seedBadPixels();
        seedReports();
    }

    /**
     * Creates a minimal data set for testing MR by adding MR roles and a
     * "report" user.
     */
    public void loadSeedData() {
        // Add MR roles.
        new ProductionUserDbSeed().loadSeedData();

        // Add MR users.
        seedUsers();
    }

    /**
     * Seeds the admin and SO user.
     */
    private void seedUsers() {
        // Add permissions to admin.
        UserCrud userCrud = new UserCrud();

        User user = userCrud.retrieveUser("admin");
        if (user == null) {
            throw new PipelineException(
                "admin user not present; run \"runjava seed-security\"");
        }
        if (user.hasPrivilege(Permissions.EDIT_DRAFTMODE)) {
            log.info("MR users already exist");
            return;
        }
        user.addRole(userCrud.retrieveRole(ProductionUserDbSeed.GROUP_ADMIN));
        ArrayList<String> privs = new ArrayList<String>();
        privs.add(Permissions.EDIT_DRAFTMODE);
        user.setPrivileges(privs);
        userCrud.createUser(user);

        user = new User("so", "Science Office", "so", "so@kepler.nasa.gov",
            "x41111");
        user.addRole(userCrud.retrieveRole(ProductionUserDbSeed.GROUP_SO));
        userCrud.createUser(user);

        user = new User("reports", "Random Report User", "reports",
            "reports@kepler.nasa.gov", "x41111");
        user.addRole(userCrud.retrieveRole(ProductionUserDbSeed.GROUP_REPORTS));
        userCrud.createUser(user);

        // Create user without reports role to reproduce bug 1138.
        user = new User("noReports", "Random Non-Report User", "noReports",
            "noReports@kepler.nasa.gov", "x41111");
        userCrud.createUser(user);
    }

    /**
     * Seeds the pipeline.
     */
    private void seedPipeline() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        if (config.getBoolean("bw.using-pig", false)) {
            log.warn("Skipping load of pipeline data bw.using-pig is true");
            return;
        }

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();

        // Check for existing data.
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        if (pipelineInstances.size() > 0) {
            for (PipelineInstance pipelineInstance : pipelineInstances) {
                if (pipelineInstance.getPipelineDefinition()
                    .getName()
                    .toString()
                    .equals("Pipeline 0")) {
                    log.info("Pipeline tables already seeded");
                    return;
                }
            }
        }

        // Create one pipeline instance for each state for each day starting
        // with today and going backwards in time. Each instance has a duration
        // of one hour. The ID and priority is the ordinal value of the state.
        long startTime = System.currentTimeMillis();
        for (State state : State.values()) {
            String name = "Pipeline " + state.ordinal();

            PipelineInstance pipelineInstance = createPipelineInstance(name,
                CadenceType.LONG, state.ordinal(), state, new Date(startTime),
                new Date(startTime + MILLIS_PER_HOUR));
            pipelineInstanceCrud.create(pipelineInstance);
            startTime -= MILLIS_PER_DAY;

            PipelineInstanceNode pipelineInstanceNode = createPipelineInstanceNode(
                name, pipelineInstance);
            pipelineInstanceNodeCrud.create(pipelineInstanceNode);

            createPipelineTasks(pipelineInstance);
        }
    }

    private PipelineInstance createPipelineInstance(String name,
        CadenceType cadenceType, long id, State state, Date startTime,
        Date endTime) {

        PipelineDefinition pipelineDefinition = createPipelineDefinition(name);
        PipelineInstance pipelineInstance = new PipelineInstance(
            pipelineDefinition);
        pipelineInstance.setName(name + " instance");
        pipelineInstance.setTriggerName("Pipeline trigger " + id);
        pipelineInstance.setId(id);
        pipelineInstance.setState(state);
        pipelineInstance.setStartProcessingTime(startTime);
        pipelineInstance.setEndProcessingTime(endTime);
        pipelineInstance.setPriority((int) id);
        pipelineInstance.setPipelineParameterSets(createParamSets(name + id,
            new CadenceTypePipelineParameters(cadenceType)));

        return pipelineInstance;
    }

    private PipelineInstanceNode createPipelineInstanceNode(String name,
        PipelineInstance pipelineInstance) {

        String nodeName = name + "-node";
        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode();
        pipelineInstanceNode.setPipelineInstance(pipelineInstance);
        pipelineInstanceNode.setPipelineModuleDefinition(createPipelineModuleDefinition(nodeName));
        pipelineInstanceNode.setModuleParameterSets(createParamSets(nodeName,
            new PlannedSpacecraftConfigParameters()));

        return pipelineInstanceNode;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition(
        String nodeName) {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            nodeName);
        new PipelineModuleDefinitionCrud().create(pipelineModuleDefinition);

        return pipelineModuleDefinition;
    }

    private Map<ClassWrapper<Parameters>, ParameterSet> createParamSets(
        String name, Parameters parameters) {
        Map<ClassWrapper<Parameters>, ParameterSet> pipelineParameterSets = new HashMap<ClassWrapper<Parameters>, ParameterSet>();

        ParameterSet paramSet = new ParameterSet(name + "-params");
        paramSet.setDescription("Created by MrSeedTestData");
        paramSet.setParameters(new BeanWrapper<Parameters>(parameters));
        new ParameterSetCrud().create(paramSet);

        pipelineParameterSets.put(new ClassWrapper<Parameters>(parameters),
            paramSet);

        return pipelineParameterSets;
    }

    private PipelineDefinition createPipelineDefinition(String name) {
        PipelineDefinition pipelineDefinition = new PipelineDefinition(name);
        new PipelineDefinitionCrud().create(pipelineDefinition);

        return pipelineDefinition;
    }

    private void createPipelineTasks(PipelineInstance pipelineInstance) {
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

        for (PipelineTask.State state : PipelineTask.State.values()) {
            PipelineTask pipelineTask = new PipelineTask(pipelineInstance,
                null, null);
            pipelineTask.setState(state);
            pipelineTaskCrud.create(pipelineTask);
        }
    }

    /**
     * Seeds the data receipt tables.
     */
    private void seedDataReceipt() {
        LogCrud logCrud = new LogCrud();

        // Check for existing data.
        if (logCrud.retrieveReceiveLogs(new Date(0), new Date(Long.MAX_VALUE))
            .size() > 0) {
            log.info("ReceiveLog and DispatchLog tables already seeded");
            return;
        }

        PipelineDefinition pipelineDefinitionA = createPipelineDefinition("Pipeline A");
        PipelineDefinition pipelineDefinitionB = createPipelineDefinition("Pipeline B");

        // Create one receive log and one dispatch log for each type for each
        // day starting with today and going backwards in time day by day.
        long startTime = System.currentTimeMillis();
        int i = 0;
        char c = 'a';
        for (DispatcherType type : DispatchLog.DispatcherType.values()) {
            Date start = new Date(startTime);
            ReceiveLog receiveLog = new ReceiveLog(start, "sdnm",
                "kplr2009001015800" + c++ + "_sdnm.xml");
            i++;
            receiveLog.setState(i % 3 == 1 ? ReceiveLog.State.PROCESSING
                : i % 3 == 2 ? ReceiveLog.State.SUCCESS
                    : ReceiveLog.State.FAILURE);
            logCrud.createReceiveLog(receiveLog);

            DispatchLog dispatchLog = createDispatchLog(receiveLog, type);
            dispatchLog.setPipelineInstances(createPipelineInstances(
                pipelineDefinitionA, pipelineDefinitionB, start));
            logCrud.createDispatchLog(dispatchLog);

            startTime -= MILLIS_PER_DAY;
        }
    }

    private List<PipelineInstance> createPipelineInstances(
        PipelineDefinition pipelineDefinitionA,
        PipelineDefinition pipelineDefinitionB, Date start) {

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = new ArrayList<PipelineInstance>();

        PipelineInstance pipelineInstance = new PipelineInstance(
            pipelineDefinitionA);
        pipelineInstance.setStartProcessingTime(start);
        pipelineInstance.setEndProcessingTime(new Date(start.getTime() + 2
            * MILLIS_PER_HOUR + 3 * MILLIS_PER_MINUTE));
        pipelineInstanceCrud.create(pipelineInstance);
        pipelineInstances.add(pipelineInstance);

        pipelineInstance = new PipelineInstance(pipelineDefinitionB);
        pipelineInstance.setStartProcessingTime(start);
        pipelineInstance.setEndProcessingTime(new Date(start.getTime() + 4
            * MILLIS_PER_HOUR + 5 * MILLIS_PER_MINUTE));
        pipelineInstanceCrud.create(pipelineInstance);
        pipelineInstances.add(pipelineInstance);

        return pipelineInstances;
    }

    private DispatchLog createDispatchLog(ReceiveLog receiveLog,
        DispatcherType type) {

        DispatchLog dispatchLog = new DispatchLog(receiveLog, type);

        return dispatchLog;
    }

    /**
     * Seeds the {@link AlertLog} table.
     */
    private void seedAlerts() {
        AlertLogCrud alertLogCrud = new AlertLogCrud();

        // Check for existing data.
        if (alertLogCrud.retrieve(new Date(0), new Date(Long.MAX_VALUE))
            .size() > 0) {
            log.info("AlertLog table already seeded");
            return;
        }

        // Create one alert per hour starting with now and going backwards in
        // time one week.
        long time = System.currentTimeMillis();
        for (int i = 0; i < 24 * 7; i++) {

            // Don't expect more than a few billion task IDs.
            Date date = new Date(time);
            alertLogCrud.create(new AlertLog(new Alert(date, "source-" + i / 7,
                time % 999999999999L, "name", "host", (int) time,
                randomAlert(), randomMessage())));

            time -= MILLIS_PER_HOUR;
        }
    }

    private String randomMessage() {
        String batmanPhrases[] = {
            "Ooof!",
            "Pow!",
            "Wam!",
            "Ringggg!",
            "I'm a lumberjack, and I'm okay. I sleep all night and I work all day. "
                + "I cut down trees. I eat my lunch. I go to the lavatory. "
                + "On Wednesdays I go shoppin' And have buttered scones for tea." };

        return batmanPhrases[(int) (Math.random() * batmanPhrases.length)];
    }

    private String randomAlert() {
        String logLevels[] = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" };

        return logLevels[(int) (Math.random() * logLevels.length)];
    }

    /**
     * Seeds the {@link ConfigMap} table.
     */
    private void seedConfigMaps() {
        ConfigMapCrud configMapCrud = new ConfigMapCrud();

        // Check for existing data.
        if (configMapCrud.retrieveAllConfigMaps()
            .size() > 0) {
            log.info("Config map tables already seeded");
            return;
        }

        Map<String, String> map = new HashMap<String, String>();
        map.put("Item A", "2");
        map.put("Item B", "1");
        map.put("Item C", "0");

        long now = new Date().getTime();

        for (int i = 0; i < 3; i++) {
            Date date = new Date(now + i * MILLIS_PER_DAY);
            double mjd = ModifiedJulianDate.dateToMjd(date);
            ConfigMap configMap = new ConfigMap(i, mjd, map);
            configMapCrud.createConfigMap(configMap);
        }
    }

    /**
     * Seeds the {@link History} table.
     */
    private void seedFcHistory() {
        FcCrud fcCrud = new FcCrud();

        // Check for existing data.
        if (fcCrud.retrieveHistoryByIngestDate(new Date(0),
            new Date(Long.MAX_VALUE))
            .size() > 0) {
            log.info("FC history already seeded");
            return;
        }

        for (double time : new double[] { 50000.0, 50500.0 }) {
            for (HistoryModelName model : HistoryModelName.values()) {

                // Leave out to demonstrate that "No data" message works.
                if (model == HistoryModelName.UNDERSHOOT) {
                    continue;
                }

                History history = new History(time, model,
                    "Created by MrSeedTestData", 1);
                history.setDescription("Changing " + model + " at " + time);
                history.setIngestTime(time - 10.0);
                fcCrud.create(history);
            }
        }
    }

    /**
     * Seeds the {@link Pixel} table.
     */
    private void seedBadPixels() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        if (!config.getBoolean("bw.seed-bad-pixels", false)) {
            log.warn("Skipping load of bad pixels because bw.seed-bad-pixels is false or unset");
            return;
        }

        String file = SocEnvVars.getLocalDataDir()
            + "/so/invalid-pixels/latest/bad_pixels2008020721.txt";

        try {
            log.info("Loading bad pixels from " + file);
            new ImporterInvalidPixels().rewriteHistory("Test import");
        } catch (PipelineException e) {
            log.info("Bad pixels table already seeded");
        } catch (IOException e) {
            log.error("Could not load bad pixels from " + e.getMessage());
        }
    }

    /**
     * Seeds the {@link MrReport} table.
     */
    private void seedReports() {
        MrReportCrud mrReportCrud = new MrReportCrud();
        MrReportCrudTest mrReportCrudTest = new MrReportCrudTest();
        GenericReportOperations genericReportOperations = new GenericReportOperations();

        if (new PipelineDefinitionCrud().retrieveLatestVersionForName("cal") != null) {
            log.info("Reports already seeded");
            return;
        }

        String[] moduleNames = { "cal", "gar", "pdq" };
        String[] filenames = { "resources/smiley.pdf", "resources/test.txt",
            "resources/test.html" };
        String[] mimeTypes = { "application/pdf", "text/plain", "text/html" };
        assert moduleNames.length == filenames.length;
        assert moduleNames.length == mimeTypes.length;

        for (int i = 0; i < moduleNames.length; i++) {
            String moduleName = moduleNames[i];
            String filename = filenames[i];
            String mimeType = mimeTypes[i];

            // Run "ant test" to put this file in the classpath.
            URL url = GenericReportOperations.class.getClassLoader()
                .getResource(filename);
            if (url == null) {
                throw new IllegalStateException("Can't find " + filename
                    + "; need to run ant test in mr to make it available");
            }
            File file = new File(url.getFile());

            // Create two reports with the same pipeline instance to reproduce
            // bug 962.
            for (int j = 0; j < 2; j++) {
                List<MrReport> scratchReports = mrReportCrudTest.createReports(
                    moduleName, filename, mimeType);

                for (MrReport scratchReport : scratchReports) {
                    genericReportOperations.createReport(
                        scratchReport.getPipelineTask(), file);
                    mrReportCrud.delete(scratchReport);
                }
            }
        }
    }
}
