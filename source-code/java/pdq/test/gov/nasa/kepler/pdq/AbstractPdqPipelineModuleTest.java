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

package gov.nasa.kepler.pdq;

import static gov.nasa.kepler.mc.refpixels.RefPixelFileReader.GAP_INDICATOR_VALUE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.dr.SclkCoefficients;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.pdq.PdqCrud;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeries;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pdq.PdqDoubleTimeSeriesType;
import gov.nasa.kepler.hibernate.pdq.RefPixelPipelineParameters;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.BoundsReport;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DrConstants;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Base class for unit testing the PDQ wrapper classes.
 * 
 * Note that this class does not annotate any methods to be unit tests as that
 * is done by subclasses.
 * 
 * @author Forrest Girouard (forrestg)
 * 
 */
public abstract class AbstractPdqPipelineModuleTest extends JMockTest {

    private static final Log log = LogFactory.getLog(AbstractPdqPipelineModuleTest.class);

    private static final int SECONDS_PER_DAY = 86400;

    public static final int EXE_TIMEOUT_SECS = 4 * 60 * 60;
    protected static final String GENERIC_REPORT_FILENAME = "PdqReport.pdf";
    protected static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pdq-matlab-1-1");

    public static final byte GAP_BYTE0 = (byte) ((GAP_INDICATOR_VALUE & 0xFF000000) >> 24);
    public static final byte GAP_BYTE1 = (byte) ((GAP_INDICATOR_VALUE & 0x00FF0000) >> 16);
    public static final byte GAP_BYTE2 = (byte) ((GAP_INDICATOR_VALUE & 0x0000FF00) >> 8);
    public static final byte GAP_BYTE3 = (byte) ((GAP_INDICATOR_VALUE & 0x000000FF) >> 0);

    private static final long INSTANCE_ID = 1;
    private static final int TARGET_TABLE_ID = 1;
    private static final int SPACECRAFT_CONFIG_ID = 123;
    private static final long REFPIXEL_FILE_TIME = 64210176000L;
    private static final int NUM_PIXEL_GAPS = 4;

    private static final int MAX_PIXELS_PER_TARGET = 3;
    private static final int TARGETS_PER_MODULE_OUTPUT = 6;
    private static final int REFERENCE_PIXELS = TARGETS_PER_MODULE_OUTPUT
        * MAX_PIXELS_PER_TARGET * FcConstants.MODULE_OUTPUTS;
    private static final double DEFAULT_RA = 10;
    private static final double DEFAULT_DEC = 10;
    private static final float DEFAULT_MAG = 10;

    private static final float[] DELTA_QUATERNION = new float[] { (float) 1.0,
        (float) 1.1, (float) 1.2, (float) 1.3 };
    public static final String ALERT_MESSAGE = "This is a PDQ forceAlert message.";

    private static final long PIPELINE_TASK_ID = 100;

    private static final long PREVIOUS_PIPELINE_TASK_ID = 10;

    private UnitTestDescriptor unitTestDescriptor;
    private boolean outputExpectations;

    private int nextTargetLabelIndex = 0;
    private final Random random = new Random(System.currentTimeMillis());

    private List<RefPixelLog> refPixelLogs;
    private TargetTable targetTable;

    protected PdqPipelineModule pipelineModule = new PdqPipelineModuleNullScience(
        this);
    private PipelineTask pipelineTask;
    private Set<Long> producerTaskIds;
    private AlertService alertService;
    private CompressionCrud compressionCrud;
    private ConfigMapOperations configMapOperations;
    private DataAccountabilityTrailCrud daCrud;
    private FileStoreClient fsClient;
    private FlatFieldOperations flatFieldOperations;
    private GainOperations gainOperations;
    private GenericReportOperations genericReportOperations;
    private CelestialObjectOperations celestialObjectOperations;
    private LogCrud logCrud;
    private PdqCrud pdqCrud;
    private PdqDbTimeSeriesCrud pdqDbTimeSeriesCrud;
    private PrfOperations prfOperations;
    private ReadNoiseOperations readNoiseOperations;
    private RaDec2PixOperations raDec2PixOperations;
    private TargetCrud targetCrud;
    private TwoDBlackOperations twoDBlackOperations;
    private UndershootOperations undershootOperations;
    private File matlabWorkingDir;

    // True iff excluded cadences force reprocessing.
    private boolean excludeReprocessing = false;

    private Set<RefPixelLog> excludeRefPixelLogs;
    private List<RefPixelLog> includeRefPixelLogs;
    private List<PdqAttitudeAdjustment> pdqAttitudeAdjustments;

    public AbstractPdqPipelineModuleTest() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        config.setProperty(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            Filenames.BUILD_TMP);
    }

    protected void createAndRetrieveInputs() {

        populateObjects();

        createInputs();

        PdqInputs pdqInputs = getPipelineModule().createInputs();

        getPipelineModule().retrieveInputs(pdqInputs);

        validate(pdqInputs);
    }

    protected void createAndStoreOutputs() {

        populateObjects();

        createInputs();

        PdqInputs pdqInputs = getPipelineModule().createInputs();

        getPipelineModule().retrieveInputs(pdqInputs);

        if (getPipelineModule().getPdqModuleParameters()
            .isExecuteAlgorithmEnabled()) {
            PdqOutputs pdqOutputs = getPipelineModule().createOutputs();
            createOutputs(pdqInputs, pdqOutputs);

            getPipelineModule().storeOutputs(pdqOutputs);

            validate(pdqOutputs);
        }
    }

    protected void createAndSerializeInputs() throws Exception {

        createAndRetrieveInputs();
        SerializationTest.testSerialization(getPipelineModule().getInputs(),
            getPipelineModule().createInputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-inputs.bin"));
    }

    protected void createAndSerializeOutputs() throws Exception {

        createAndRetrieveInputs();
        PdqOutputs pdqOutputs = getPipelineModule().createOutputs();
        createOutputs(getPipelineModule().getInputs(), pdqOutputs, false);
        SerializationTest.testSerialization(pdqOutputs,
            getPipelineModule().createOutputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-outputs.bin"));
    }

    protected void createInputs() {

        producerTaskIds = new HashSet<Long>();
        setRefPixelLogs(createRefPixelLogs(TARGET_TABLE_ID, REFERENCE_PIXELS,
            REFPIXEL_FILE_TIME, unitTestDescriptor.getTotalRefLogs()));
        setTargetTable(MockUtils.mockUplinkedTargetTable(this, targetCrud,
            TargetType.REFERENCE_PIXEL, TARGET_TABLE_ID));
        if (getRefPixelLogs().size() > 0) {

            List<ObservedTarget> targets = new ArrayList<ObservedTarget>();
            List<TargetDefinition> targetDefinitions = new ArrayList<TargetDefinition>();
            Map<Integer, List<TargetDefinition>> targetDefinitionsByModuleOutput = new HashMap<Integer, List<TargetDefinition>>();
            createTargetsAndDefinitions(getTargetTable(), pipelineTask,
                TARGETS_PER_MODULE_OUTPUT, MAX_PIXELS_PER_TARGET,
                unitTestDescriptor.getModuleOutputs(), targets,
                targetDefinitions, targetDefinitionsByModuleOutput);
            createKics(targets);
            createRefPixelLogFiles(getRefPixelLogs(), targetDefinitions);
            createTsData();

            double startMjd = includeRefPixelLogs.get(0)
                .getMjd();
            double endMjd = includeRefPixelLogs.get(
                includeRefPixelLogs.size() - 1)
                .getMjd();
            MockUtils.mockConfigMaps(this, configMapOperations,
                SPACECRAFT_CONFIG_ID, startMjd, endMjd);
            MockUtils.mockGainModel(this, gainOperations, startMjd, endMjd);
            MockUtils.mockReadNoiseModel(this, readNoiseOperations, startMjd,
                endMjd);
            MockUtils.mockRaDec2PixModel(this, raDec2PixOperations, startMjd,
                endMjd);
            MockUtils.mockUndershootModel(this, undershootOperations, startMjd,
                endMjd);
            MockUtils.mockTwoDBlackModels(this, twoDBlackOperations, startMjd,
                endMjd, unitTestDescriptor.getModuleOutputs(),
                targetDefinitionsByModuleOutput);
            MockUtils.mockFlatFieldModels(this, flatFieldOperations, startMjd,
                endMjd, unitTestDescriptor.getModuleOutputs(),
                targetDefinitionsByModuleOutput);
            MockUtils.mockPrfModels(this, prfOperations, startMjd,
                unitTestDescriptor.getModuleOutputs());
            MockUtils.mockRequantTable(this, compressionCrud, TARGET_TABLE_ID);
        }
    }

    private void createTsData() {

        if (!unitTestDescriptor.isForceReprocessing() && !excludeReprocessing) {
            int oldExcludes = 0;
            for (int excludeCadence : unitTestDescriptor.getExcludeCadences()) {
                if (excludeCadence < unitTestDescriptor.getNumOldRefLogs()) {
                    oldExcludes++;
                }
            }
            if (unitTestDescriptor.getNumOldRefLogs() - oldExcludes > 0) {
                createTsData(getTargetTable().getExternalId(),
                    PREVIOUS_PIPELINE_TASK_ID);
                producerTaskIds.add(PREVIOUS_PIPELINE_TASK_ID);
            }
        }
    }

    protected void populateObjects() {

        pipelineModule = new PdqPipelineModuleNullScience(this);
        createMockObjects();
        setMockObjects(getPipelineModule());
        setMatlabWorkingDir(MATLAB_WORKING_DIR);
        getPipelineModule().setMatlabWorkingDir(getMatlabWorkingDir());
        pipelineTask = createPipelineTask(PIPELINE_TASK_ID, TARGET_TABLE_ID);
        getPipelineModule().setPipelineTask(pipelineTask);
        getPipelineModule().setPipelineInstance(
            pipelineTask.getPipelineInstance());
    }

    protected PdqOutputs createOutputs(PdqInputs inputs, PdqOutputs outputs) {
        return createOutputs(inputs, outputs,
            unitTestDescriptor.isOutputExpectations());
    }

    protected PdqOutputs createOutputs(PdqInputs inputs, PdqOutputs outputs,
        boolean outputExpectations) {

        this.outputExpectations = outputExpectations;

        PdqOutputs pdqOutputs = outputs;
        if (pdqOutputs == null) {
            pdqOutputs = new PdqOutputs();
        }

        populateOutputPdqTsData(getTargetTable().getExternalId(),
            pipelineTask.getId(), pdqOutputs, inputs.getInputPdqTsData(),
            getRefPixelLogs());

        List<PdqModuleOutputReport> pdqModuleOutputReports = createModuleOutputReports(
            getTargetTable(), pipelineTask, pdqOutputs.getOutputPdqTsData());
        pdqOutputs.setPdqModuleOutputReports(pdqModuleOutputReports);

        PdqFocalPlaneReport pdqFocalPlaneReport = createFocalPlaneReport(
            getTargetTable(), pipelineTask, pdqOutputs.getOutputPdqTsData());
        pdqOutputs.setPdqFocalPlaneReport(pdqFocalPlaneReport);

        pdqAttitudeAdjustments = createAttitudeAdjustments(pipelineTask,
            getRefPixelLogs(), inputs.getPdqModuleParameters()
                .getExcludeCadences());
        pdqOutputs.setAttitudeAdjustments(pdqAttitudeAdjustments);

        if (unitTestDescriptor.isReportEnabled()) {
            MrReport genericReport = MockUtils.mockGenericReport(
                outputExpectations ? this : null, genericReportOperations,
                pipelineTask, new File(getMatlabWorkingDir(),
                    GENERIC_REPORT_FILENAME));
            pdqOutputs.setReportFilename(genericReport.getFilename());
        }

        MockUtils.mockDataAccountabilityTrail(outputExpectations ? this : null,
            daCrud, pipelineTask, producerTaskIds);

        return pdqOutputs;
    }

    protected void validate(PdqInputs pdqInputs) {

        log.info("validating inputs");

        assertNotNull(pdqInputs);

        validate(pdqInputs.getPdqModuleParameters());
        validate(pdqInputs.getPdqTimestampSeries());
        validate(pdqInputs.getGainModel());
        if (unitTestDescriptor.getNumOldRefLogs() > 0) {
            int length = 0;
            if (!excludeReprocessing
                && !unitTestDescriptor.isForceReprocessing()) {
                int oldExcludes = 0;
                for (int excludeCadence : unitTestDescriptor.getExcludeCadences()) {
                    if (excludeCadence < unitTestDescriptor.getNumOldRefLogs()) {
                        oldExcludes++;
                    }
                }
                length = unitTestDescriptor.getNumOldRefLogs() - oldExcludes;
            }
            validate(pdqInputs.getInputPdqTsData(), length);
        }
        validate(pdqInputs.getInputPdqTsData()
            .getCadenceTimes(), pdqInputs.getPdqTimestampSeries()
            .unprocessedTimes());
        validateTargets(pdqInputs.getBackgroundPdqTargets());
        validateTargets(pdqInputs.getCollateralPdqTargets());
        validateStellarTargets(pdqInputs.getStellarPdqTargets());
    }

    @SuppressWarnings("all")
    protected void validate(PdqOutputs pdqOutputs) {

        log.info("validating outputs");

        validate(pdqOutputs.getOutputPdqTsData(),
            unitTestDescriptor.getTotalRefLogs() - excludeRefPixelLogs.size());
        validate(pdqOutputs.getAttitudeAdjustments());
        validateOutputMetrics(pdqOutputs.getPdqModuleOutputReports());
    }

    private void createMockObjects() {

        alertService = mock(AlertService.class);
        compressionCrud = mock(CompressionCrud.class);
        configMapOperations = mock(ConfigMapOperations.class);
        daCrud = mock(DataAccountabilityTrailCrud.class);
        fsClient = mock(FileStoreClient.class);
        flatFieldOperations = mock(FlatFieldOperations.class);
        gainOperations = mock(GainOperations.class);
        genericReportOperations = mock(GenericReportOperations.class);
        celestialObjectOperations = mock(CelestialObjectOperations.class);
        logCrud = mock(LogCrud.class);
        pdqCrud = mock(PdqCrud.class);
        pdqDbTimeSeriesCrud = mock(PdqDbTimeSeriesCrud.class);
        prfOperations = mock(PrfOperations.class);
        readNoiseOperations = mock(ReadNoiseOperations.class);
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        targetCrud = mock(TargetCrud.class);
        twoDBlackOperations = mock(TwoDBlackOperations.class);
        undershootOperations = mock(UndershootOperations.class);
    }

    private void setMockObjects(PdqPipelineModule pdqPipelineModule) {

        AlertServiceFactory.setInstance(alertService);
        pdqPipelineModule.setCompressionCrud(compressionCrud);
        pdqPipelineModule.setConfigMapOperations(configMapOperations);
        pdqPipelineModule.setDaCrud(daCrud);
        FileStoreClientFactory.setInstance(fsClient);
        pdqPipelineModule.setFlatFieldOperations(flatFieldOperations);
        pdqPipelineModule.setGainOperations(gainOperations);
        pdqPipelineModule.setGenericReportOperations(genericReportOperations);
        pdqPipelineModule.setCelestialObjectOperations(celestialObjectOperations);
        pdqPipelineModule.setLogCrud(logCrud);
        pdqPipelineModule.setPdqCrud(pdqCrud);
        pdqPipelineModule.setPdqDoubleDbTimeSeriesCrud(pdqDbTimeSeriesCrud);
        pdqPipelineModule.setPrfOperations(prfOperations);
        pdqPipelineModule.setReadNoiseOperations(readNoiseOperations);
        pdqPipelineModule.setRaDec2PixOperations(raDec2PixOperations);
        pdqPipelineModule.setTargetCrud(targetCrud);
        pdqPipelineModule.setTwoDBlackOperations(twoDBlackOperations);
        pdqPipelineModule.setUndershootOperations(undershootOperations);
    }

    private void validate(double[] oldCadenceTimes, double[] newCadenceTimes) {
        if (excludeReprocessing || unitTestDescriptor.isForceReprocessing()) {
            assertEquals(0, oldCadenceTimes.length);
            assertEquals(unitTestDescriptor.getTotalRefLogs()
                - unitTestDescriptor.getExcludeCadences().length,
                newCadenceTimes.length);
        } else {
            assertEquals(
                "lengths time series",
                unitTestDescriptor.getTotalRefLogs()
                    - unitTestDescriptor.getExcludeCadences().length,
                oldCadenceTimes.length + newCadenceTimes.length);
        }
    }

    private void validate(PdqTimestampSeries pdqTimestampSeries) {
        assertNotNull(pdqTimestampSeries);
        validate(pdqTimestampSeries.unprocessedTimes());

        int[] excludeCadences = unitTestDescriptor.getExcludeCadences();
        for (int excludeCadence : excludeCadences) {
            assertTrue(pdqTimestampSeries.isExcluded(excludeCadence));
        }

        double[] startTimes = pdqTimestampSeries.getStartTimes();
        assertNotNull(startTimes);

        double previousTime = 0;
        for (double time : startTimes) {
            assertTrue(time > previousTime);
        }

        String[] fileNames = pdqTimestampSeries.getRefPixelFileNames();
        assertNotNull(fileNames);
        assertTrue(startTimes.length == fileNames.length);
        for (String fileName : fileNames) {
            assertNotNull(fileName);
            assertTrue(fileName.length() > 0);
        }
    }

    private void validate(double[] cadenceTimes) {

        int[] excludeCadences = unitTestDescriptor.getExcludeCadences();

        double[] times = null;
        if (excludeReprocessing || unitTestDescriptor.isForceReprocessing()) {
            times = new double[unitTestDescriptor.getTotalRefLogs()
                - unitTestDescriptor.getExcludeCadences().length];
            for (int i = 0, k = 0; i < getRefPixelLogs().size(); i++) {
                RefPixelLog refPixelLog = getRefPixelLogs().get(i);
                if (excludeRefPixelLogs.contains(refPixelLog)) {
                    continue;
                }
                times[k++] = refPixelLog.getMjd();
            }
        } else {
            int newExcludes = 0;
            for (int excludeCadence : excludeCadences) {
                if (excludeCadence >= unitTestDescriptor.getNumOldRefLogs()) {
                    newExcludes++;
                }
            }
            times = new double[unitTestDescriptor.getNumNewRefLogs()
                - newExcludes];
            for (int i = unitTestDescriptor.getNumOldRefLogs(), k = 0; i < unitTestDescriptor.getTotalRefLogs(); i++) {
                RefPixelLog refPixelLog = getRefPixelLogs().get(i);
                if (excludeRefPixelLogs.contains(refPixelLog)) {
                    continue;
                }
                times[k++] = refPixelLog.getMjd();
            }
        }
        assertTrue("cadenceTimes", Arrays.equals(times, cadenceTimes));
    }

    private void validate(GainModel gainModel) {
        assertNotNull(gainModel);
    }

    private void validate(PdqModuleParameters pdqModuleParameters) {

        assertEquals("forceReprocessing",
            unitTestDescriptor.isForceReprocessing(),
            pdqModuleParameters.isForceReprocessing());
    }

    private void validate(PdqTsData pdqTsData, int length) {

        assertNotNull("cadenceTimes", pdqTsData.getCadenceTimes());
        assertEquals("cadenceTimes length", length,
            pdqTsData.getCadenceTimes().length);

        assertNotNull("attitudeSolutionDec", pdqTsData.getAttitudeSolutionDec());
        assertEquals("attitudeSolutionDec length", length,
            pdqTsData.getAttitudeSolutionDec()
                .size());
        assertNotNull("attitudeSolutionRa", pdqTsData.getAttitudeSolutionRa());
        assertEquals("attitudeSolutionRa length", length,
            pdqTsData.getAttitudeSolutionRa()
                .size());
        assertNotNull("attitudeSolutionRoll",
            pdqTsData.getAttitudeSolutionRoll());
        assertEquals("attitudeSolutionRoll length", length,
            pdqTsData.getAttitudeSolutionRoll()
                .size());

        assertNotNull("desiredAttitudeDec", pdqTsData.getDesiredAttitudeDec());
        assertEquals("desiredAttitudeDec length", length,
            pdqTsData.getDesiredAttitudeDec()
                .size());
        assertNotNull("desiredAttitudeRa", pdqTsData.getDesiredAttitudeRa());
        assertEquals("desiredAttitudeRa length", length,
            pdqTsData.getDesiredAttitudeRa()
                .size());
        assertNotNull("desiredAttitudeRoll", pdqTsData.getDesiredAttitudeRoll());
        assertEquals("desiredAttitudeRoll length", length,
            pdqTsData.getDesiredAttitudeRoll()
                .size());

        assertNotNull("pdqModuleOutputTsData",
            pdqTsData.getPdqModuleOutputTsData());
        if (length > 0) {
            assertEquals("pdqModuleOutputTsData size",
                unitTestDescriptor.getModuleOutputs()
                    .size(), pdqTsData.getPdqModuleOutputTsData()
                    .size());
        }
    }

    private void validateTargets(List<PdqTarget> targets) {
        for (PdqTarget target : targets) {
            assertTrue("ccdModule",
                FcConstants.validCcdModule(target.getCcdModule()));
            assertTrue("ccdOutput",
                FcConstants.validCcdOutput(target.getCcdOutput()));
            assertTrue("pixel count", target.getReferencePixels()
                .size() > 0);
        }
    }

    private void validateStellarTargets(List<PdqStellarTarget> targets) {
        for (PdqStellarTarget target : targets) {
            assertTrue("ccdModule",
                FcConstants.validCcdModule(target.getCcdModule()));
            assertTrue("ccdOutput",
                FcConstants.validCcdOutput(target.getCcdOutput()));
            assertTrue("pixel count", target.getReferencePixels()
                .size() > 0);
            assertTrue("keplerId", target.getKeplerId() > 0);
            assertTrue("ra", target.getRaHours() > 0);
            assertTrue("dec", target.getDecDegrees() > 0);
        }
    }

    private void validate(List<PdqAttitudeAdjustment> pdqAttitudeAdjustments) {

        assertNotNull("attitude adjustments", pdqAttitudeAdjustments);
        if (excludeReprocessing || unitTestDescriptor.isForceReprocessing()) {
            assertEquals(unitTestDescriptor.getTotalRefLogs()
                - unitTestDescriptor.getExcludeCadences().length,
                pdqAttitudeAdjustments.size());
        }
        assertEquals(this.pdqAttitudeAdjustments.size(),
            pdqAttitudeAdjustments.size());
        assertTrue(this.pdqAttitudeAdjustments.equals(pdqAttitudeAdjustments));
    }

    private void validateOutputMetrics(List<PdqModuleOutputReport> reports) {

        assertNotNull("reports", reports);
        assertEquals("reports length", unitTestDescriptor.getModuleOutputs()
            .size(), reports.size());
    }

    private void createKics(List<ObservedTarget> targets) {
        for (ObservedTarget target : targets) {
            if (target.getKeplerId() != TargetManagementConstants.INVALID_KEPLER_ID) {
                Kic finalKic = new Kic.Builder(target.getKeplerId(),
                    DEFAULT_RA, DEFAULT_DEC).keplerMag(DEFAULT_MAG)
                    .build();

                allowing(celestialObjectOperations).retrieveCelestialObjectParameters(
                    target.getKeplerId());
                will(returnValue(new CelestialObjectParameters.Builder(finalKic).build()));
            }
        }
    }

    private void createTsData(int targetTableId, long producerTaskId) {

        if (unitTestDescriptor.getNumOldRefLogs() > 0) {
            FsId[] existingFsIds = PdqTsData.getAllTimeSeriesFsIds(
                targetTableId, unitTestDescriptor.getModuleOutputs());
            FsId[] allFsIds = PdqTsData.getAllTimeSeriesFsIds(targetTableId);
            int processedLogCount = 0;
            for (RefPixelLog refPixelLog : refPixelLogs) {
                if (refPixelLog.isProcessed()) {
                    processedLogCount++;
                }
            }
            MockUtils.mockReadFloatTimeSeries(this, fsClient, 0,
                processedLogCount - 1, producerTaskId, allFsIds, existingFsIds);

            mockRetrieveDbTimeSeries(pdqDbTimeSeriesCrud, targetTableId, 0,
                processedLogCount - 1, producerTaskId);
        }
    }

    private void mockRetrieveDbTimeSeries(
        PdqDbTimeSeriesCrud pdqDbTimeSeriesCrud, int targetTableId,
        int startCadence, int endCadence, long producerTaskId) {

        int length = endCadence - startCadence + 1;
        for (final PdqDoubleTimeSeriesType timeSeriesType : PdqDoubleTimeSeriesType.values()) {
            allowing(pdqDbTimeSeriesCrud).retrieve(targetTableId, startCadence,
                endCadence, timeSeriesType);
            will(returnValue(new PdqDbTimeSeries(timeSeriesType, targetTableId,
                startCadence, endCadence, new double[length],
                new double[length], new boolean[length], producerTaskId)));
        }
    }

    private void createRefPixelLogFiles(List<RefPixelLog> refPixelLogs,
        List<TargetDefinition> definitions) {

        int[] excludeCadences = unitTestDescriptor.getExcludeCadences();
        excludeRefPixelLogs = new HashSet<RefPixelLog>();
        includeRefPixelLogs = new ArrayList<RefPixelLog>();
        for (int i = 0, j = 0; i < refPixelLogs.size(); i++) {
            if (j < excludeCadences.length && excludeCadences[j] == i) {
                excludeRefPixelLogs.add(refPixelLogs.get(i));
                j++;
            } else {
                includeRefPixelLogs.add(refPixelLogs.get(i));
            }
        }

        int numPixels = getTotalPixels(definitions);
        for (int i = 0; i < unitTestDescriptor.getNumOldRefLogs(); i++) {
            RefPixelLog refPixelLog = refPixelLogs.get(i);
            if (!excludeRefPixelLogs.contains(refPixelLog)
                || unitTestDescriptor.isOldExcludedCadencesProcessed()) {
                refPixelLog.setProcessed(true);
            }
        }

        for (int excludeCadence : excludeCadences) {
            if (excludeCadence < unitTestDescriptor.getNumOldRefLogs()) {
                if (refPixelLogs.get(excludeCadence)
                    .isProcessed()) {
                    excludeReprocessing = true;
                    break;
                }
            }
        }

        for (int i = excludeReprocessing
            || unitTestDescriptor.isForceReprocessing() ? 0
            : unitTestDescriptor.getNumOldRefLogs(); i < refPixelLogs.size(); i++) {
            RefPixelLog refPixelLog = refPixelLogs.get(i);
            byte[] data = new byte[13 + 4 * numPixels];
            Arrays.fill(data, (byte) (i + 1));
            for (int g = 0; g < NUM_PIXEL_GAPS; g++) {
                int offset = getRandom().nextInt(numPixels);
                offset = 13 + offset * 4;
                data[offset++] = GAP_BYTE0;
                data[offset++] = GAP_BYTE1;
                data[offset++] = GAP_BYTE2;
                data[offset] = GAP_BYTE3;
            }

            if (excludeRefPixelLogs.contains(refPixelLog)) {
                continue;
            }

            allowing(fsClient).readBlob(
                DrFsIdFactory.getFile(DispatcherType.REF_PIXEL,
                    refPixelLog.getFileLog()
                        .getFilename()));
            will(returnValue(new BlobResult(DrConstants.DATA_RECEIPT_ORIGIN_ID,
                data)));
        }
    }

    private int getTotalPixels(List<TargetDefinition> definitions) {
        int numPixels = 0;
        for (TargetDefinition definition : definitions) {
            List<Offset> offsets = definition.getMask()
                .getOffsets();
            numPixels += offsets.size();
        }
        return numPixels;
    }

    private static PdqAttitudeAdjustment createPdqAttitudeAdjustment() {
        PdqAttitudeAdjustment attitudeAdjustment = new PdqAttitudeAdjustment();
        attitudeAdjustment.setX(DELTA_QUATERNION[AttitudeAdjustment.QUATERNION_X]);
        attitudeAdjustment.setY(DELTA_QUATERNION[AttitudeAdjustment.QUATERNION_Y]);
        attitudeAdjustment.setZ(DELTA_QUATERNION[AttitudeAdjustment.QUATERNION_Z]);
        attitudeAdjustment.setW(DELTA_QUATERNION[AttitudeAdjustment.QUATERNION_W]);
        return attitudeAdjustment;
    }

    private List<PdqAttitudeAdjustment> createAttitudeAdjustments(
        PipelineTask pipelineTask, List<RefPixelLog> refPixelLogs,
        int[] excludeCadences) {

        final List<AttitudeAdjustment> existingAttitudeAdjustments = new ArrayList<AttitudeAdjustment>();
        List<PdqAttitudeAdjustment> pdqAttitudeAdjustments = new ArrayList<PdqAttitudeAdjustment>();

        int excludeIndex = 0;
        for (int i = 0; i < unitTestDescriptor.getNumOldRefLogs(); i++) {
            RefPixelLog refPixelLog = refPixelLogs.get(i);
            AttitudeAdjustment attitudeAdjustment = new AttitudeAdjustment();
            PdqAttitudeAdjustment aa = createPdqAttitudeAdjustment();
            attitudeAdjustment.setRefPixelLog(refPixelLog);
            attitudeAdjustment.setX(aa.getX());
            attitudeAdjustment.setY(aa.getY());
            attitudeAdjustment.setZ(aa.getZ());
            attitudeAdjustment.setW(aa.getW());
            attitudeAdjustment.setPipelineTask(pipelineTask);
            existingAttitudeAdjustments.add(attitudeAdjustment);
            if (excludeIndex < excludeCadences.length
                && excludeCadences[excludeIndex] == i) {
                excludeIndex++;
                if (unitTestDescriptor.isOldExcludedCadencesProcessed()
                    && outputExpectations) {
                    oneOf(pdqCrud).delete(attitudeAdjustment);
                }
            } else if (excludeReprocessing
                || unitTestDescriptor.isForceReprocessing()) {
                pdqAttitudeAdjustments.add(aa);
            }
        }

        if (outputExpectations) {
            allowing(pdqCrud).retrieveLatestAttitudeAdjustments(0);
            will(returnValue(existingAttitudeAdjustments));
        }

        List<AttitudeAdjustment> attitudeAdjustments = new ArrayList<AttitudeAdjustment>();
        for (int i = unitTestDescriptor.getNumOldRefLogs(); i < unitTestDescriptor.getTotalRefLogs(); i++) {
            if (excludeIndex < excludeCadences.length
                && excludeCadences[excludeIndex] == i) {
                excludeIndex++;
                continue;
            }
            RefPixelLog refPixelLog = refPixelLogs.get(i);
            AttitudeAdjustment attitudeAdjustment = new AttitudeAdjustment();
            PdqAttitudeAdjustment aa = createPdqAttitudeAdjustment();
            pdqAttitudeAdjustments.add(aa);
            attitudeAdjustment.setRefPixelLog(refPixelLog);
            attitudeAdjustment.setX(aa.getX());
            attitudeAdjustment.setY(aa.getY());
            attitudeAdjustment.setZ(aa.getZ());
            attitudeAdjustment.setW(aa.getW());
            attitudeAdjustment.setPipelineTask(pipelineTask);
            attitudeAdjustments.add(attitudeAdjustment);
        }

        if (outputExpectations) {
            oneOf(pdqCrud).createAttitudeAdjustments(attitudeAdjustments);
        }
        return pdqAttitudeAdjustments;
    }

    private void populateOutputPdqTsData(int targetTableId,
        long pipelineTaskId, PdqOutputs pdqOutputs, PdqTsData inputPdqTsData,
        List<RefPixelLog> refPixelLogs) {

        PdqTsData outputPdqTsData = pdqOutputs.getOutputPdqTsData();
        int newLength = unitTestDescriptor.getTotalRefLogs()
            - excludeRefPixelLogs.size();
        int oldLength = inputPdqTsData.getCadenceTimes().length;

        double[] newCadenceTimes = Arrays.copyOf(
            inputPdqTsData.getCadenceTimes(), newLength);
        if (excludeReprocessing || unitTestDescriptor.isForceReprocessing()) {
            for (int i = 0; i < includeRefPixelLogs.size(); i++) {
                newCadenceTimes[i] = includeRefPixelLogs.get(i)
                    .getMjd();
            }
        } else {
            for (int i = unitTestDescriptor.getNumOldRefLogs(), j = oldLength; i < refPixelLogs.size(); i++) {
                RefPixelLog refPixelLog = refPixelLogs.get(i);
                if (!excludeRefPixelLogs.contains(refPixelLog)) {
                    newCadenceTimes[j++] = refPixelLog.getMjd();
                }
            }
        }

        outputPdqTsData.setCadenceTimes(newCadenceTimes);

        Map<Integer, PdqModuleOutputTsData> inputs = new HashMap<Integer, PdqModuleOutputTsData>();
        for (PdqModuleOutputTsData tsData : inputPdqTsData.getPdqModuleOutputTsData()) {
            inputs.put(
                FcConstants.getHdu(tsData.getCcdModule(), tsData.getCcdOutput()),
                tsData);
        }
        for (int channelNumber : unitTestDescriptor.getModuleOutputs()) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channelNumber);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            PdqModuleOutputTsData tsData = new PdqModuleOutputTsData();
            PdqModuleOutputTsData input = inputs.get(channelNumber);
            if (input == null) {
                input = new PdqModuleOutputTsData();
            }
            tsData.setCcdModule(ccdModule);
            tsData.setCcdOutput(ccdOutput);
            tsData.setBackgroundLevels(extendValues(newLength,
                input.getBackgroundLevels()));
            tsData.setBlackLevels(extendValues(newLength,
                input.getBlackLevels()));
            tsData.setCentroidsMeanCols(extendValues(newLength,
                input.getCentroidsMeanCols()));
            tsData.setCentroidsMeanRows(extendValues(newLength,
                input.getCentroidsMeanRows()));
            tsData.setDarkCurrents(extendValues(newLength,
                input.getDarkCurrents()));
            tsData.setDynamicRanges(extendValues(newLength,
                input.getDynamicRanges()));
            tsData.setEncircledEnergies(extendValues(newLength,
                input.getEncircledEnergies()));
            tsData.setMeanFluxes(extendValues(newLength, input.getMeanFluxes()));
            tsData.setPlateScales(extendValues(newLength,
                input.getPlateScales()));
            tsData.setSmearLevels(extendValues(newLength,
                input.getSmearLevels()));
            outputPdqTsData.getPdqModuleOutputTsData()
                .add(tsData);
        }

        outputPdqTsData.setAttitudeSolutionDec(extendValues(newLength,
            inputPdqTsData.getAttitudeSolutionDec()));
        outputPdqTsData.setAttitudeSolutionRa(extendValues(newLength,
            inputPdqTsData.getAttitudeSolutionRa()));
        outputPdqTsData.setAttitudeSolutionRoll(extendValues(newLength,
            inputPdqTsData.getAttitudeSolutionRoll()));
        outputPdqTsData.setDeltaAttitudeDec(extendValues(newLength,
            inputPdqTsData.getDeltaAttitudeDec()));
        outputPdqTsData.setDeltaAttitudeRa(extendValues(newLength,
            inputPdqTsData.getDeltaAttitudeRa()));
        outputPdqTsData.setDeltaAttitudeRoll(extendValues(newLength,
            inputPdqTsData.getDeltaAttitudeRoll()));
        outputPdqTsData.setDesiredAttitudeDec(extendValues(newLength,
            inputPdqTsData.getDesiredAttitudeDec()));
        outputPdqTsData.setDesiredAttitudeRa(extendValues(newLength,
            inputPdqTsData.getDesiredAttitudeRa()));
        outputPdqTsData.setDesiredAttitudeRoll(extendValues(newLength,
            inputPdqTsData.getDesiredAttitudeRoll()));

        outputPdqTsData.setMaxAttitudeResidualInPixels(extendValues(newLength,
            inputPdqTsData.getMaxAttitudeResidualInPixels()));

        List<FloatTimeSeries> timeSeries = outputPdqTsData.getAllFloatTimeSeries(
            targetTableId, pipelineTaskId,
            unitTestDescriptor.getNumOldRefLogs() - 1);
        List<PdqDbTimeSeries> dbTimeSeriesList = outputPdqTsData.getAllDbTimeSeries(
            targetTableId, pipelineTaskId,
            unitTestDescriptor.getNumOldRefLogs() - 1);
        if (outputExpectations) {
            oneOf(fsClient).writeTimeSeries(
                timeSeries.toArray(new FloatTimeSeries[0]));
            oneOf(pdqDbTimeSeriesCrud).create(dbTimeSeriesList);
        }
    }

    private CompoundFloatTimeSeries extendValues(int length,
        CompoundFloatTimeSeries pdqTimeSeries) {

        float[] extendedValues = null;
        float[] extendedUncertainties = null;
        boolean[] extendedGapIndicators = null;
        if (pdqTimeSeries != null && pdqTimeSeries.size() > 0) {
            int offset = pdqTimeSeries.size();
            extendedValues = Arrays.copyOf(pdqTimeSeries.getValues(), length);
            extendedUncertainties = Arrays.copyOf(
                pdqTimeSeries.getUncertainties(), length);
            extendedGapIndicators = Arrays.copyOf(
                pdqTimeSeries.getGapIndicators(), length);
            for (int i = offset; i < length; i++) {
                extendedValues[i] = extendedValues[i - offset];
                extendedUncertainties[i] = extendedUncertainties[i - offset];
                extendedGapIndicators[i] = extendedGapIndicators[i - offset];
            }
        } else {
            extendedValues = new float[length];
            extendedUncertainties = new float[length];
            extendedGapIndicators = new boolean[length];
            Arrays.fill(extendedValues, 0, length, getRandom().nextFloat());
            Arrays.fill(extendedUncertainties, 0, length,
                getRandom().nextFloat());
            Arrays.fill(extendedGapIndicators, 0, length, false);

        }
        CompoundFloatTimeSeries newTimeSeries = new CompoundFloatTimeSeries(
            extendedValues, extendedUncertainties, extendedGapIndicators);
        return newTimeSeries;
    }

    private PdqDoubleTimeSeries extendValues(int length,
        PdqDoubleTimeSeries timeSeries) {

        double[] extendedValues = null;
        double[] extendedUncertainties = null;
        boolean[] extendedGapIndicators = null;
        if (timeSeries != null && timeSeries.size() > 0) {
            int offset = timeSeries.size();
            extendedValues = Arrays.copyOf(timeSeries.getValues(), length);
            extendedUncertainties = Arrays.copyOf(
                timeSeries.getUncertainties(), length);
            extendedGapIndicators = Arrays.copyOf(
                timeSeries.getGapIndicators(), length);
            for (int i = offset; i < length; i++) {
                extendedValues[i] = extendedValues[i - offset];
                extendedUncertainties[i] = extendedUncertainties[i - offset];
                extendedGapIndicators[i] = extendedGapIndicators[i - offset];
            }
        } else {
            extendedValues = new double[length];
            extendedUncertainties = new double[length];
            extendedGapIndicators = new boolean[length];
            Arrays.fill(extendedValues, 0, length, getRandom().nextFloat());
            Arrays.fill(extendedUncertainties, 0, length,
                getRandom().nextFloat());
            Arrays.fill(extendedGapIndicators, 0, length, false);
        }

        PdqDoubleTimeSeries newTimeSeries = new PdqDoubleTimeSeries(
            extendedValues, extendedUncertainties, extendedGapIndicators);
        return newTimeSeries;
    }

    private static UnitOfWorkTask createUowTask() {
        SingleUowTask uowTask = new SingleUowTask();

        return uowTask;
    }

    private PipelineInstance createPipelineInstance(int targetTableId) {

        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(INSTANCE_ID);

        ParameterSet parameterSet = new ParameterSet("refPixel");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            createPipelineParams(targetTableId)));
        pipelineInstance.putParameterSet(new ClassWrapper<Parameters>(
            RefPixelPipelineParameters.class), parameterSet);
        return pipelineInstance;
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        PipelineModuleDefinition moduleDefinition, PipelineInstance instance,
        PipelineDefinitionNode definitionNode) {

        PdqModuleParameters pdqModuleParameters = new PdqModuleParameters();
        initializeModuleParameters(pdqModuleParameters);

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            instance, definitionNode, moduleDefinition);

        ParameterSet parameterSet = new ParameterSet("pdq");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            pdqModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(PdqModuleParameters.class,
            parameterSet);

        return pipelineInstanceNode;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Photometer Data Quality");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PdqPipelineModule.class));
        pipelineModuleDefinition.setExeName("pdq");

        return pipelineModuleDefinition;
    }

    private PipelineTask createPipelineTask(long pipelineTaskId,
        int targetTableId) {

        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance(targetTableId);
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask()));
        task.setPipelineDefinitionNode(definitionNode);

        return task;
    }

    private static RefPixelPipelineParameters createPipelineParams(
        int targetTableId) {

        RefPixelPipelineParameters pipelineParams = new RefPixelPipelineParameters(
            targetTableId);
        return pipelineParams;
    }

    private void initializeModuleParameters(
        PdqModuleParameters pdqModuleParameters) {

        pdqModuleParameters.setForceReprocessing(unitTestDescriptor.isForceReprocessing());
        pdqModuleParameters.setReportEnabled(unitTestDescriptor.isReportEnabled());
        pdqModuleParameters.setExcludeCadences(unitTestDescriptor.getExcludeCadences());
        pdqModuleParameters.setExecuteAlgorithmEnabled(unitTestDescriptor.isExecuteAlgorithmEnabled());
    }

    private PlannedTarget.TargetLabel getNextTargetLabel() {
        PlannedTarget.TargetLabel targetLabel = PlannedTarget.TargetLabel.PDQ_STELLAR;
        switch (nextTargetLabelIndex++ % 3) {
            case 0:
                targetLabel = PlannedTarget.TargetLabel.PDQ_STELLAR;
                break;
            case 1:
                targetLabel = PlannedTarget.TargetLabel.PDQ_BACKGROUND;
                break;
            case 2:
                targetLabel = PlannedTarget.TargetLabel.PDQ_BLACK_COLLATERAL;
                break;
        }
        return targetLabel;
    }

    private List<RefPixelLog> createRefPixelLogs(int targetTableId,
        int numPixels, long startVtc, int logs) {

        List<RefPixelLog> refPixelLogs = new ArrayList<RefPixelLog>();

        if (!unitTestDescriptor.isForceFatalException()) {
            double mjd = convertVtcToMjd(startVtc);
            long vtcValue = startVtc;
            for (int log = 0; log < logs; log++) {
                RefPixelLog refPixelLog = new RefPixelLog();
                refPixelLog.setTargetTableId(targetTableId);
                refPixelLog.setTimestamp(vtcValue);
                refPixelLog.setMjd(mjd);
                refPixelLog.setNumberOfReferencePixels(numPixels);
                refPixelLog.setCompressionTableId(targetTableId);
                refPixelLog.setFileLog(new FileLog(null, targetTableId + "_"
                    + vtcValue + "_rp.rp"));
                refPixelLogs.add(refPixelLog);

                mjd++;
                vtcValue = convertMjdToVtc(mjd);
            }
        }

        allowing(logCrud).retrieveAllRefPixelLogForTargetTable(targetTableId);
        will(returnValue(refPixelLogs));
        return refPixelLogs;
    }

    public double convertVtcToMjd(long vtcValue) {

        double vtcTime = vtcValue / 256.0;

        SclkCoefficients sclkCoefficients = retrieveSclkCoefficients(vtcTime);

        double secondsSinceJ2000 = sclkCoefficients.getSecondsSinceEpoch()
            + sclkCoefficients.getClockRate()
            * (vtcTime - sclkCoefficients.getVtcEventTime());

        double daysSinceJ2000 = secondsSinceJ2000 / SECONDS_PER_DAY;

        double mjd = FcConstants.J2000_MJD + daysSinceJ2000;

        return mjd;
    }

    private long convertMjdToVtc(double mjd) {

        long vtcValue = 0;
        double secondsSinceJ2000 = (mjd - FcConstants.J2000_MJD)
            * SECONDS_PER_DAY;
        List<SclkCoefficients> allSclkCoefficients = retrieveAllSclkCoefficients();
        if (allSclkCoefficients.size() > 0) {
            Map<Double, Long> vtcValueByVtcTime = new TreeMap<Double, Long>();
            for (int i = 0; i < allSclkCoefficients.size(); i++) {
                SclkCoefficients sclkCoefficients = allSclkCoefficients.get(allSclkCoefficients.size()
                    - i - 1);
                double vtcTime = sclkCoefficients.getVtcEventTime()
                    + (secondsSinceJ2000 - sclkCoefficients.getSecondsSinceEpoch())
                    / sclkCoefficients.getClockRate();
                vtcValueByVtcTime.put(sclkCoefficients.getVtcEventTime(),
                    (long) vtcTime * 256);
            }
            if (vtcValueByVtcTime.size() > 1) {
                double vtcTimeSinceLastEvent = Double.MAX_VALUE;
                for (double vtcTime : vtcValueByVtcTime.keySet()) {
                    long value = vtcValueByVtcTime.get(vtcTime);
                    if (value > vtcTime
                        && vtcTimeSinceLastEvent > value - vtcTime) {
                        vtcTimeSinceLastEvent = value - vtcTime;
                        vtcValue = value;
                    }
                }
            } else {
                vtcValue = vtcValueByVtcTime.values()
                    .iterator()
                    .next();
            }
        }
        if (vtcValue == 0) {
            throw new IllegalStateException(
                "conversion from MJD to VTC failed.");
        }

        return vtcValue;

    }

    private SclkCoefficients retrieveSclkCoefficients(double time) {
        SclkCoefficients sclkCoefficients = null;
        List<SclkCoefficients> allSclkCoefficients = retrieveAllSclkCoefficients();
        for (SclkCoefficients sclkCoeffs : allSclkCoefficients) {
            if (time > sclkCoeffs.getVtcEventTime()) {
                sclkCoefficients = sclkCoeffs;
            }
        }
        if (sclkCoefficients == null) {
            throw new IllegalStateException("no appropriate SCLK coefficients.");
        }
        return sclkCoefficients;
    }

    private List<SclkCoefficients> retrieveAllSclkCoefficients() {

        List<SclkCoefficients> sclkCoefficients = new ArrayList<SclkCoefficients>();
        sclkCoefficients.add(new SclkCoefficients(null, 0.0,
            6.4184000000000E+01, 1.0000000000000E+00));
        sclkCoefficients.add(new SclkCoefficients(null, 7.1575159086761E+10,
            2.7959046518266E+08, 9.9730398999001E-01));
        sclkCoefficients.add(new SclkCoefficients(null, 7.4904899887523E+10,
            2.9259726518564E+08, 1.0001884629544E+00));

        return sclkCoefficients;
    }

    private void createTargetsAndDefinitions(TargetTable targetTable,
        PipelineTask pipelineTask, int targetsPerModuleOutput,
        int maxPixelsPerTarget, List<Integer> moduleOutputs,
        List<ObservedTarget> targets,
        List<TargetDefinition> allTargetDefinitions,
        Map<Integer, List<TargetDefinition>> targetDefinitionsByModuleOutput) {

        Set<Pixel> pixelsInUse = new HashSet<Pixel>();
        Random random = new Random();
        for (int moduleOutputNumber = 1; moduleOutputNumber <= FcConstants.MODULE_OUTPUTS; moduleOutputNumber++) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(moduleOutputNumber);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            if (moduleOutputs.contains(moduleOutputNumber)) {
                List<ObservedTarget> ccdTargets = new ArrayList<ObservedTarget>();
                List<TargetDefinition> ccdDefinitions = new ArrayList<TargetDefinition>();
                for (int t = 0; t < targetsPerModuleOutput; t++) {
                    List<Offset> offsets = new ArrayList<Offset>();
                    int pixelsPerTarget = random.nextInt(maxPixelsPerTarget) + 1;
                    Pixel referencePixel = MockUtils.getNextPixel(
                        pixelsPerTarget, pixelsInUse, random);
                    for (int j = 0; j < pixelsPerTarget; j++) {
                        Offset offset = MockUtils.getNextOffset(
                            pixelsPerTarget, referencePixel, pixelsInUse,
                            random);
                        offsets.add(offset);
                    }

                    int keplerId = TargetManagementConstants.INVALID_KEPLER_ID;
                    PlannedTarget.TargetLabel label = getNextTargetLabel();
                    if (label.equals(PlannedTarget.TargetLabel.PDQ_STELLAR)) {
                        keplerId = t * moduleOutputNumber + 1;
                    }
                    int referenceRow = referencePixel.getRow();
                    int referenceColumn = referencePixel.getColumn();
                    List<TargetDefinition> targetDefinitions = new ArrayList<TargetDefinition>();
                    TargetDefinition targetDefinition = new TargetDefinition(0,
                        0, 0, null);
                    targetDefinition.setKeplerId(keplerId);
                    targetDefinition.setReferenceColumn(referenceColumn);
                    targetDefinition.setReferenceRow(referenceRow);
                    targetDefinition.setCcdModule(ccdModule);
                    targetDefinition.setCcdOutput(ccdOutput);
                    Mask mask = new Mask(null, null);
                    mask.setOffsets(offsets);
                    targetDefinition.setMask(mask);
                    ccdDefinitions.add(targetDefinition);
                    targetDefinitions.add(targetDefinition);

                    Aperture aperture = new Aperture(false, referenceRow,
                        referenceColumn, offsets);
                    ObservedTarget target = new ObservedTarget(targetTable,
                        ccdModule, ccdOutput, keplerId);
                    target.addLabel(label);
                    target.setAperture(aperture);
                    target.setTargetDefinitions(targetDefinitions);
                    ccdTargets.add(target);
                }
                targets.addAll(ccdTargets);
                allTargetDefinitions.addAll(ccdDefinitions);
                targetDefinitionsByModuleOutput.put(moduleOutputNumber,
                    ccdDefinitions);

                allowing(targetCrud).retrieveTargetDefinitions(targetTable,
                    ccdModule, ccdOutput);
                will(returnValue(ccdDefinitions));
                allowing(targetCrud).retrieveObservedTargets(targetTable,
                    ccdModule, ccdOutput);
                will(returnValue(ccdTargets));
            } else {
                allowing(targetCrud).retrieveTargetDefinitions(targetTable,
                    ccdModule, ccdOutput);
                will(returnValue(new ArrayList<TargetDefinition>()));
                allowing(targetCrud).retrieveObservedTargets(targetTable,
                    ccdModule, ccdOutput);
                will(returnValue(new ArrayList<ObservedTarget>()));
            }
        }
    }

    private List<PdqModuleOutputReport> createModuleOutputReports(
        TargetTable targetTable, PipelineTask pipelineTask,
        PdqTsData outputPdqTsData) {

        List<PdqModuleOutputReport> reports = new ArrayList<PdqModuleOutputReport>();
        for (PdqModuleOutputTsData tsData : outputPdqTsData.getPdqModuleOutputTsData()) {
            PdqModuleOutputReport report = createPdqModuleOutputReport(
                targetTable,
                tsData.getCcdModule(),
                tsData.getCcdOutput(),
                outputPdqTsData.getCadenceTimes()[outputPdqTsData.getCadenceTimes().length - 1]);
            reports.add(report);

            if (outputExpectations) {
                oneOf(pdqCrud).createModuleOutputMetricReports(
                    report.createModuleOutputMetricReports(targetTable,
                        pipelineTask));
            }
        }

        if (outputExpectations) {
            oneOf(pdqCrud).deleteModuleOutputMetricReports(targetTable);
        }

        if (unitTestDescriptor.isForceAlert() && reports.size() > 0) {
            ModuleAlert alert = new ModuleAlert(Severity.ERROR, ALERT_MESSAGE);
            PdqMetricReport metric = reports.get(0)
                .getMeanFlux();
            List<ModuleAlert> alerts = new ArrayList<ModuleAlert>();
            alerts.add(alert);
            metric.setAlerts(alerts);

            if (outputExpectations) {
                oneOf(alertService).generateAlert(
                    getPipelineModule().getModuleName(),
                    pipelineTask.getId(),
                    Severity.valueOf(alert.getSeverity()),
                    ALERT_MESSAGE
                        + ": ccdModule=2; ccdOutput=1; metricType=MEAN_FLUX");
            }
        }
        return reports;
    }

    private PdqFocalPlaneReport createFocalPlaneReport(TargetTable targetTable,
        PipelineTask pipelineTask, PdqTsData outputPdqTsData) {

        PdqFocalPlaneReport report = createPdqFocalPlaneReport(
            targetTable,
            pipelineTask,
            outputPdqTsData.getCadenceTimes()[outputPdqTsData.getCadenceTimes().length - 1]);

        if (outputExpectations) {
            oneOf(pdqCrud).deleteFocalPlaneMetricReports(targetTable);
            oneOf(pdqCrud).createFocalPlaneMetricReports(
                report.createFocalPlaneMetricReports(targetTable, pipelineTask));
        }

        return report;
    }

    private PdqModuleOutputReport createPdqModuleOutputReport(
        TargetTable targetTable, int ccdModule, int ccdOutput, double time) {

        PdqMetricReport backgroundLevel = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport blackLevel = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport centroidsMeanCol = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport centroidsMeanRow = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport darkCurrent = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport dynamicRange = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport encircledEnergy = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport meanFlux = new PdqMetricReport(getRandom().nextFloat(),
            getRandom().nextFloat(), time);
        PdqMetricReport plateScale = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport smearLevel = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);

        encircledEnergy.setAdaptiveBoundsReport(new BoundsReport());
        encircledEnergy.setFixedBoundsReport(new BoundsReport());

        PdqModuleOutputReport report = new PdqModuleOutputReport(ccdModule,
            ccdOutput, backgroundLevel, blackLevel, centroidsMeanCol,
            centroidsMeanRow, darkCurrent, dynamicRange, encircledEnergy,
            meanFlux, plateScale, smearLevel);
        return report;
    }

    private PdqFocalPlaneReport createPdqFocalPlaneReport(
        TargetTable targetTable, PipelineTask pipelineTask, double time) {

        PdqMetricReport maxAttitudeResidualInPixels = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport deltaAttitudeDec = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport deltaAttitudeRa = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);
        PdqMetricReport deltaAttitudeRoll = new PdqMetricReport(
            getRandom().nextFloat(), getRandom().nextFloat(), time);

        PdqFocalPlaneReport report = new PdqFocalPlaneReport(
            maxAttitudeResidualInPixels, deltaAttitudeDec, deltaAttitudeRa,
            deltaAttitudeRoll);
        return report;
    }

    // simple getters and setters

    protected PdqPipelineModule getPipelineModule() {
        return pipelineModule;
    }

    public Random getRandom() {
        return random;
    }

    public List<RefPixelLog> getRefPixelLogs() {
        return refPixelLogs;
    }

    public void setRefPixelLogs(List<RefPixelLog> refPixelLogs) {
        this.refPixelLogs = refPixelLogs;
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    public void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

    void setUnitTestDescriptor(UnitTestDescriptor unitTestDescriptor) {
        this.unitTestDescriptor = unitTestDescriptor;
    }

    protected File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    protected void setMatlabWorkingDir(final File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }
}
