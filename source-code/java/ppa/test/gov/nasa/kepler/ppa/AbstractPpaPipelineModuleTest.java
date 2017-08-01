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

package gov.nasa.kepler.ppa;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import static junit.framework.Assert.fail;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.hibernate.ppa.PpaCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class AbstractPpaPipelineModuleTest extends JMockTest {

    private static final Log log = LogFactory.getLog(AbstractPpaPipelineModuleTest.class);

    protected static final String PROP_FILE = Filenames.ETC
        + "/kepler.properties";
    protected static final String GENERIC_REPORT_FILENAME = "PpaReport.pdf";

    protected static final long INSTANCE_ID = System.currentTimeMillis();
    protected static final long PIPELINE_TASK_ID = INSTANCE_ID - 1000;
    protected static final int MAX_TASK_ID = 400000000;
    protected static final String ALERT_MESSAGE = "This is a PPA forceAlert message.";

    protected static final int TARGET_TABLE_ID = 131;
    protected static final int OBSERVING_SEASON = 1;
    protected static final int CADENCE_COUNT = 1440;
    protected static final int START_CADENCE = 1;
    protected static final int END_CADENCE = 1440;
    protected static final int EXE_TIMEOUT_SECS = 4 * 60 * 60;

    private static final int SC_CONFIG_ID = 42;

    protected int debugLevel = 0;
    protected boolean plottingEnabled;
    private boolean forceFatalException;
    private boolean forceAlert;

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private PipelineModuleDefinition pipelineModuleDefinition;
    private PipelineInstanceNode pipelineInstanceNode;
    private PipelineDefinitionNode pipelineDefinitionNode;

    private TargetTable targetTable;
    private TimestampSeries cadenceTimes;
    private Map<FsId, FloatTimeSeries> timeSeriesByFsId;

    private Random random;

    private MjdToCadence mjdToCadence;
    private DataAccountabilityTrailCrud daCrud;
    private LogCrud logCrud;
    private PaCrud paCrud;
    private PpaCrud ppaCrud;
    private TargetCrud targetCrud;
    private FileStoreClient fsClient;
    private AlertService alertService;
    private RaDec2PixOperations raDec2PixOperations;
    private ConfigMapOperations configMapOperations;
    private List<ConfigMap> configMaps;
    private BlobOperations blobOperations;
    private GenericReportOperations genericReportOperations;
    private File matlabWorkingDir;

    public AbstractPpaPipelineModuleTest() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        config.setProperty(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            Filenames.BUILD_TMP);
    }

    protected abstract PipelineInstanceNode createPipelineInstanceNode();

    protected abstract PipelineModuleDefinition createPipelineModuleDefinition();

    protected PipelineInstance createPipelineInstance() {
        PipelineInstance instance = new PipelineInstance();
        instance.setId(INSTANCE_ID);

        return instance;
    }

    protected void createMockObjects() {
        setMjdToCadence(mock(MjdToCadence.class));
        setDaCrud(mock(DataAccountabilityTrailCrud.class));
        setLogCrud(mock(LogCrud.class));
        setPaCrud(mock(PaCrud.class));
        setPpaCrud(mock(PpaCrud.class));
        setTargetCrud(mock(TargetCrud.class));

        setFsClient(mock(FileStoreClient.class));
        FileStoreClientFactory.setInstance(getFsClient());

        setAlertService(mock(AlertService.class));
        AlertServiceFactory.setInstance(getAlertService());

        setRaDec2PixOperations(mock(RaDec2PixOperations.class));
        setConfigMapOperations(mock(ConfigMapOperations.class));
        setBlobOperations(mock(BlobOperations.class));
        setGenericReportOperations(mock(GenericReportOperations.class));
    }

    protected TimestampSeries createCadenceTimes() {
        return MockUtils.mockCadenceTimes(this, getMjdToCadence(),
            CadenceType.LONG, START_CADENCE, END_CADENCE);
    }

    protected RaDec2PixModel createRaDec2PixModel() {
        final double startMjd = getCadenceTimes().startMjd();
        final double endMjd = getCadenceTimes().endMjd();

        return MockUtils.mockRaDec2PixModel(this, getRaDec2PixOperations(),
            startMjd, endMjd);
    }

    protected List<ConfigMap> createConfigMaps() {
        final double startMjd = getCadenceTimes().startMjd();
        final double endMjd = getCadenceTimes().endMjd();

        return MockUtils.mockConfigMaps(this, getConfigMapOperations(),
            SC_CONFIG_ID, startMjd, endMjd);
    }

    protected MrReport createGenericReport() {
        return MockUtils.mockGenericReport(this, getGenericReportOperations(),
            pipelineTask, new File(getMatlabWorkingDir(),
                GENERIC_REPORT_FILENAME));
    }

    protected TargetTable createTargetTable() {
        TargetTable targetTable = MockUtils.mockTargetTable(this,
            getTargetCrud(), TargetType.LONG_CADENCE, TARGET_TABLE_ID);
        MockUtils.mockTargetTableLogs(this, getTargetCrud(),
            TargetType.LONG_CADENCE, START_CADENCE, END_CADENCE, targetTable);
        return targetTable;
    }

    protected void creatTargetTableLogExpectations() {
        getTargetCrud().retrieveTargetTableLogs(TargetType.LONG_CADENCE,
            START_CADENCE, END_CADENCE);
    }

    protected IntTimeSeries[] createIntTimeSeries(List<FsId> fsIds,
        long producerTaskId) {

        return MockUtils.mockReadIntTimeSeries(this, getFsClient(),
            START_CADENCE, END_CADENCE, producerTaskId,
            fsIds.toArray(new FsId[0]), false);
    }

    protected IntTimeSeries[] createIntTimeSeries(final List<FsId> fsIds,
        final long producerTaskId, int value) {

        return MockUtils.mockReadIntTimeSeries(this, getFsClient(),
            START_CADENCE, END_CADENCE, producerTaskId,
            fsIds.toArray(new FsId[0]), false, value);
    }

    protected FloatTimeSeries[] createFloatTimeSeries(List<FsId> fsIds,
        long producerTaskId) {

        return MockUtils.mockReadFloatTimeSeries(this, getFsClient(),
            START_CADENCE, END_CADENCE, producerTaskId,
            fsIds.toArray(new FsId[0]), false);
    }

    protected Map<FsId, FloatTimeSeries> createOutputTimeSeries(List<FsId> fsIds) {
        FloatTimeSeries[] outputTimeSeries = MockUtils.mockWriteFloatTimeSeries(
            this, getFsClient(), START_CADENCE, END_CADENCE, PIPELINE_TASK_ID,
            fsIds.toArray(new FsId[0]));

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>();
        for (int i = 0; i < fsIds.size(); i++) {
            timeSeriesByFsId.put(fsIds.get(i), outputTimeSeries[i]);
        }

        return timeSeriesByFsId;
    }

    protected void createAlert(String component, int ccdModule, int ccdOutput,
        String type) {

        String message = String.format(
            "%s (ccdModule=%d, ccdOutput=%d, type=%s)", ALERT_MESSAGE,
            ccdModule, ccdOutput, type);
        MockUtils.mockAlert(this, getAlertService(), component,
            PIPELINE_TASK_ID, Severity.ERROR, message);
    }

    protected void createAlert(String component, String type) {
        String message = String.format("%s (type=%s)", ALERT_MESSAGE, type);
        MockUtils.mockAlert(this, getAlertService(), component,
            PIPELINE_TASK_ID, Severity.ERROR, message);
    }

    protected void createDataAccountabilityTrail(Set<Long> producerTaskIds) {
        log.info(String.format(
            "Creating data accountability: taskId=%d, producerTaskIds=%s",
            getPipelineTask().getId(), producerTaskIds));
        MockUtils.mockDataAccountabilityTrail(this, getDaCrud(),
            getPipelineTask(), producerTaskIds);
    }

    protected void validate(int expectedLength, int[] values) {
        assertNotNull(values);
        assertEquals(expectedLength, values.length);
        assertTrue(values[0] != 0);
    }

    protected void validate(int expectedLength, float[] values) {
        assertNotNull(values);
        assertEquals(expectedLength, values.length);
        assertTrue(values[0] != 0);
    }

    protected void validate(int expectedLength, double[] values) {
        assertNotNull(values);
        assertEquals(expectedLength, values.length);
        assertTrue(values[0] != 0);
    }

    protected void validate(List<ConfigMap> expectedConfigMaps,
        List<ConfigMap> configMaps) {

        assertNotNull(configMaps);
        assertEquals(expectedConfigMaps.size(), configMaps.size());
        assertEquals(expectedConfigMaps, configMaps);
    }

    protected void validate(int expectedTargetCount, int expectedLength,
        PpaTargetTimeSeries[] timeSeries) {

        assertNotNull(timeSeries);
        assertEquals(expectedTargetCount, timeSeries.length);
        assertTrue(timeSeries[0].getKeplerId() != 0);

        validate(expectedLength, timeSeries[0]);
    }

    protected void validate(int expectedLength,
        CompoundFloatTimeSeries timeSeries) {
        assertNotNull(timeSeries);

        validate(expectedLength, (SimpleFloatTimeSeries) timeSeries);

        if (timeSeries.getUncertainties() != null
            && timeSeries.getUncertainties().length != 0) {
            validate(expectedLength, timeSeries.getUncertainties());
        }
    }

    protected void validate(int expectedCount, int expectedLength,
        SimpleFloatTimeSeries[] timeSeries) {

        assertNotNull(timeSeries);
        assertEquals(expectedCount, timeSeries.length);

        for (SimpleFloatTimeSeries simpleFloatTimeSeries : timeSeries) {
            validate(expectedLength, simpleFloatTimeSeries);
        }
    }

    protected void validate(int expectedLength, SimpleFloatTimeSeries timeSeries) {
        assertNotNull(timeSeries);

        validate(expectedLength, timeSeries.getValues());

        assertNotNull(timeSeries.getGapIndicators());
        assertEquals(expectedLength, timeSeries.getGapIndicators().length);
    }

    protected void validate(int expectedLength, FloatTimeSeries timeSeries) {
        assertNotNull(timeSeries);
        assertEquals(expectedLength, timeSeries.fseries().length);
        assertTrue(timeSeries.fseries()[0] != 0);
    }

    protected void validateOriginators(
        Collection<FloatTimeSeries> floatTimeSeries) {

        for (FloatTimeSeries timeSeries : floatTimeSeries) {
            List<TaggedInterval> originators = timeSeries.originators();
            for (TaggedInterval interval : originators) {
                assertEquals(PIPELINE_TASK_ID, interval.tag());
            }
        }
    }

    protected void validatePmdMetricReports(
        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> allReports,
        List<List<String>> reportTypes) {

        assertNotNull(allReports);

        // Ensure all reports are present.
        Map<List<String>, Boolean> typeSeen = new HashMap<List<String>, Boolean>();
        for (gov.nasa.kepler.hibernate.ppa.PmdMetricReport report : allReports) {
            typeSeen.put(append(report.getType(), report.getSubTypes()),
                Boolean.TRUE);
        }

        StringBuilder message = new StringBuilder();
        for (List<String> type : reportTypes) {
            if (typeSeen.get(type) == null) {
                if (message.length() != 0) {
                    message.append("; ");
                }
                message.append(type.toString());
            }
        }

        // The length of the message variable will be zero if all report types
        // are accounted for.
        if (message.length() > 0) {
            fail("Missing reports for: " + message);
        }
    }

    private List<String> append(ReportType type, Set<String> subTypes) {
        List<String> strings = new ArrayList<String>();
        strings.add(type.toString());
        if (subTypes != null) {
            strings.addAll(subTypes);
        }

        return strings;
    }

    protected int getNextCadence() {
        return START_CADENCE + getRandom().nextInt(CADENCE_COUNT);
    }

    protected void reset() {
        setRandom(new Random(System.currentTimeMillis()));
        setTimeSeriesByFsId(new HashMap<FsId, FloatTimeSeries>());
    }

    protected double getMjdStartTime(TimestampSeries cadenceTimes, int cadence) {
        double[] mjdStartTimes = cadenceTimes.startTimestamps;
        int[] cadences = getCadenceTimes().cadenceNumbers;
        return mjdStartTimes[cadence - cadences[0]];
    }

    protected double getMjdEndTime(TimestampSeries cadenceTimes, int cadence) {
        double[] mjdEndtTimes = cadenceTimes.endTimestamps;
        int[] cadences = getCadenceTimes().cadenceNumbers;
        return mjdEndtTimes[cadence - cadences[0]];
    }

    protected TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    protected void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    protected MjdToCadence getMjdToCadence() {
        return mjdToCadence;
    }

    protected void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    protected boolean isForceAlert() {
        return forceAlert;
    }

    protected void setForceAlert(boolean forceAlert) {
        this.forceAlert = forceAlert;
    }

    protected boolean isForceFatalException() {
        return forceFatalException;
    }

    protected void setForceFatalException(boolean forceFatalException) {
        this.forceFatalException = forceFatalException;
    }

    protected PipelineDefinitionNode getPipelineDefinitionNode() {
        if (pipelineDefinitionNode == null) {
            pipelineDefinitionNode = new PipelineDefinitionNode(
                getPipelineModuleDefinition().getName());
        }
        return pipelineDefinitionNode;
    }

    protected PipelineInstance getPipelineInstance() {
        if (pipelineInstance == null) {
            pipelineInstance = createPipelineInstance();
        }
        return pipelineInstance;
    }

    protected PipelineInstanceNode getPipelineInstanceNode() {
        if (pipelineInstanceNode == null) {
            pipelineInstanceNode = createPipelineInstanceNode();
        }
        return pipelineInstanceNode;
    }

    protected PipelineModuleDefinition getPipelineModuleDefinition() {
        if (pipelineModuleDefinition == null) {
            pipelineModuleDefinition = createPipelineModuleDefinition();
        }
        return pipelineModuleDefinition;
    }

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    protected void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    protected Random getRandom() {
        return random;
    }

    private void setRandom(Random random) {
        this.random = random;
    }

    protected TargetTable getTargetTable() {
        return targetTable;
    }

    protected void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

    protected Map<FsId, FloatTimeSeries> getTimeSeriesByFsId() {
        return timeSeriesByFsId;
    }

    private void setTimeSeriesByFsId(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {
        this.timeSeriesByFsId = timeSeriesByFsId;
    }

    protected List<ConfigMap> getConfigMaps() {
        return configMaps;
    }

    protected void setConfigMaps(List<ConfigMap> configMaps) {
        this.configMaps = configMaps;
    }

    protected LogCrud getLogCrud() {
        return logCrud;
    }

    private void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    protected TargetCrud getTargetCrud() {
        return targetCrud;
    }

    private void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    protected PaCrud getPaCrud() {
        return paCrud;
    }

    private void setPaCrud(PaCrud paCrud) {
        this.paCrud = paCrud;
    }

    protected PpaCrud getPpaCrud() {
        return ppaCrud;
    }

    private void setPpaCrud(PpaCrud ppaCrud) {
        this.ppaCrud = ppaCrud;
    }

    protected DataAccountabilityTrailCrud getDaCrud() {
        return daCrud;
    }

    private void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    protected FileStoreClient getFsClient() {
        return fsClient;
    }

    private void setFsClient(FileStoreClient fsClient) {
        this.fsClient = fsClient;
    }

    protected BlobOperations getBlobOperations() {
        return blobOperations;
    }

    protected void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    protected AlertService getAlertService() {
        return alertService;
    }

    protected void setAlertService(AlertService alertService) {
        this.alertService = alertService;
    }

    protected ConfigMapOperations getConfigMapOperations() {
        return configMapOperations;
    }

    protected void setConfigMapOperations(
        ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    protected RaDec2PixOperations getRaDec2PixOperations() {
        return raDec2PixOperations;
    }

    protected void setRaDec2PixOperations(
        RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    protected GenericReportOperations getGenericReportOperations() {
        return genericReportOperations;
    }

    protected void setGenericReportOperations(
        GenericReportOperations genericReportOperations) {
        this.genericReportOperations = genericReportOperations;
    }

    protected File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    protected void setMatlabWorkingDir(final File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }
}
