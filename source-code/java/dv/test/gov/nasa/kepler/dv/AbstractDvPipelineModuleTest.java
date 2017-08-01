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

package gov.nasa.kepler.dv;

import static gov.nasa.kepler.dv.DvTestUtils.createCentroidOffsets;
import static gov.nasa.kepler.dv.DvTestUtils.createImageCentroid;
import static gov.nasa.kepler.dv.DvTestUtils.createQualityMetric;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.DETRENDED;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.TRAPEZOIDAL_MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.WHITENED_MODEL_LIGHT_CURVE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.dv.io.CentroidTestParameters;
import gov.nasa.kepler.dv.io.DvBinaryDiscriminationResults;
import gov.nasa.kepler.dv.io.DvBootstrapHistogram;
import gov.nasa.kepler.dv.io.DvCentroidMotionResults;
import gov.nasa.kepler.dv.io.DvCentroidResults;
import gov.nasa.kepler.dv.io.DvComparisonTests;
import gov.nasa.kepler.dv.io.DvDifferenceImageMotionResults;
import gov.nasa.kepler.dv.io.DvDifferenceImagePixelData;
import gov.nasa.kepler.dv.io.DvDifferenceImageResults;
import gov.nasa.kepler.dv.io.DvDoubleQuantity;
import gov.nasa.kepler.dv.io.DvDoubleQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvGhostDiagnosticResults;
import gov.nasa.kepler.dv.io.DvImageArtifactResults;
import gov.nasa.kepler.dv.io.DvInputs;
import gov.nasa.kepler.dv.io.DvLimbDarkeningModel;
import gov.nasa.kepler.dv.io.DvModelParameter;
import gov.nasa.kepler.dv.io.DvMqCentroidOffsets;
import gov.nasa.kepler.dv.io.DvMqImageCentroid;
import gov.nasa.kepler.dv.io.DvOutputs;
import gov.nasa.kepler.dv.io.DvPixelCorrelationMotionResults;
import gov.nasa.kepler.dv.io.DvPixelCorrelationResults;
import gov.nasa.kepler.dv.io.DvPixelData;
import gov.nasa.kepler.dv.io.DvPixelStatistic;
import gov.nasa.kepler.dv.io.DvPlanetCandidate;
import gov.nasa.kepler.dv.io.DvPlanetModelFit;
import gov.nasa.kepler.dv.io.DvPlanetParameters;
import gov.nasa.kepler.dv.io.DvPlanetResults;
import gov.nasa.kepler.dv.io.DvPlanetStatistic;
import gov.nasa.kepler.dv.io.DvQuantity;
import gov.nasa.kepler.dv.io.DvQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvRollingBandContaminationHistogram;
import gov.nasa.kepler.dv.io.DvSecondaryEventResults;
import gov.nasa.kepler.dv.io.DvSingleEventStatistics;
import gov.nasa.kepler.dv.io.DvStatistic;
import gov.nasa.kepler.dv.io.DvSummaryOverlapMetric;
import gov.nasa.kepler.dv.io.DvSummaryQualityMetric;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvTargetData;
import gov.nasa.kepler.dv.io.DvTargetResults;
import gov.nasa.kepler.dv.io.DvTargetTableData;
import gov.nasa.kepler.dv.io.PixelCorrelationParameters;
import gov.nasa.kepler.dv.io.TrapezoidalFitParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.hibernate.mc.TransitNameModel;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.CalibratedPixel;
import gov.nasa.kepler.mc.CompoundTimeSeries.Centroids;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DifferenceImageParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.HarmonicsIdentificationParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PlanetFitModuleParameters;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pdc.PdcHarmonicsIdentificationParameters;
import gov.nasa.kepler.pdc.PdcModuleParameters;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.tip.TipImporter;
import gov.nasa.kepler.tps.TpsHarmonicsIdentificationParameters;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.PersistableUtils;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

/**
 * Tests the {@link DvPipelineModule}.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public abstract class AbstractDvPipelineModuleTest extends DvJMockTest {

    private static final String IMPACT_PARAMETER = "impactParameter";

    static final int CONTROL_CENTROID_OFFSETS_OFFSET = 0;
    static final int CONTROL_IMAGE_CENTROID_OFFSET = 6;
    static final int DIFFERENCE_IMAGE_CENTROID_OFFSET = 10;
    static final int KIC_CENTROID_OFFSETS_OFFSET = 16;
    static final int KIC_REFERENCE_CENTROID_OFFSET = 20;
    static final float BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA = 9.3F;
    static final float MODEL_CHI_SQUARE_GOF = 24.1F;
    static final int MODEL_CHI_SQUARE_GOF_DOF = 24;
    static final float BOOTSTRAP_MES_MEAN = 123.456f;
    static final float BOOTSTRAP_MES_STD = 456.789f;

    static final int DETREND_FILTER_LENGTH = 42;

    private static final Log log = LogFactory.getLog(AbstractDvPipelineModuleTest.class);

    private static final String PROPERTIES_FILE = Filenames.ETC
        + FilenameConstants.KEPLER_CONFIG;
    public static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "dv-matlab-1-1");
    public static final File SUB_TASK_DIR = new File(Filenames.BUILD_TEST,
        "dv-matlab-1-1/st-0");
    private static final long INSTANCE_ID = System.currentTimeMillis();
    private static final long PIPELINE_TASK_ID = INSTANCE_ID - 1000;
    private static final int SC_CONFIG_ID = 42;
    private static final int QUARTER = 9;
    private static final int TARGET_TABLE_ID = 17;
    private static final float TRIAL_TRANSIT_PULSE_DURATION = 3.0F;
    private static final String ALERT_MESSAGE = "Test alert.";
    private static final String QUARTERS_OBSERVED = "-OOO----------------------------";
    private static final FluxType FLUX_TYPE = FluxType.SAP;

    private static final long TIME_SERIES_TASK_ID = 10;
    private static final long MJD_TIME_SERIES_TASK_ID = 11;
    private static final Set<Long> PRODUCER_TASK_IDS = new HashSet<Long>(
        Arrays.asList(TIME_SERIES_TASK_ID, MJD_TIME_SERIES_TASK_ID));
    private static final int TEST_PULSE_DURATION_LC = 10;

    private static final int[] PULSE_DURATIONS = { 21 };

    private final Set<Long> producerTaskIds = new HashSet<Long>();

    private LogCrud logCrud;
    private MjdToCadence mjdToCadence;
    private DataAnomalyOperations dataAnomalyOperations;
    private AncillaryOperations ancillaryOperations;
    private DataAccountabilityTrailCrud daCrud;
    private ConfigMapOperations configMapOperations;
    private RaDec2PixOperations raDec2PixOperations;
    private PrfOperations prfOperations;
    private RollTimeOperations rollTimeOperations;
    private DvCrud dvCrud;
    private GenericReportOperations genericReportOperations;
    private ModelOperations<TransitNameModel> transitNameModelOperations;
    private ModelOperations<TransitParameterModel> transitParameterModelOperations;
    private FileStoreClient fsClient;
    private AlertService alertService;
    private ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance;

    private TargetTableOperationsTest targetTableOperationsTest;

    private AncillaryEngineeringParameters ancillaryEngineeringParameters = new AncillaryEngineeringParameters();
    private AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();
    private DvModuleParameters dvModuleParameters = new DvModuleParameters();
    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private final DvPipelineModule pipelineModule = new DvPipelineModule();
    private UnitTestDescriptor unitTestDescriptor;
    private Integer debugLevel;

    private List<ConfigMap> configMaps;
    private RaDec2PixModel raDec2PixModel;
    private List<TimeSeries> timeSeriesList = new ArrayList<TimeSeries>();
    private List<DvTarget> dvTargets;
    private List<TimeSeriesBatch> timeSeriesBatchList = new ArrayList<TimeSeriesBatch>();
    private List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList = new ArrayList<MjdTimeSeriesBatch>();
    private String[] prfModelFileNames;
    private DvInputsRetriever dvInputsRetriever = new DvInputsRetriever();
    private DvOutputsStorer dvOutputsStorer = new DvOutputsStorer();
    private InputsHandler inputsHandler;

    protected AbstractDvPipelineModuleTest() {
        loadProperties();

        Configuration config = ConfigurationServiceFactory.getInstance();
        config.setProperty(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            Filenames.BUILD_TMP);
    }

    private void loadProperties() {
        try {
            log.debug("Loading " + PROPERTIES_FILE);
            PropertiesConfiguration config = new PropertiesConfiguration(
                PROPERTIES_FILE);
            debugLevel = config.getInteger("debugLevel", 0);
        } catch (ConfigurationException e) {
            throw new PipelineException(PROPERTIES_FILE + ": failed to load: "
                + e.getMessage(), e);
        }
    }

    protected void setDvInputsRetriever(DvInputsRetriever dvInputsRetriever) {
        this.dvInputsRetriever = dvInputsRetriever;
    }

    protected DvInputsRetriever getDvInputsRetriever() {
        return dvInputsRetriever;
    }

    protected DvOutputsStorer getDvOutputsStorer() {
        return dvOutputsStorer;
    }

    protected DvPipelineModule getPipelineModule() {
        return pipelineModule;
    }

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    protected InputsHandler getInputsHandler() {
        return inputsHandler;
    }

    protected void setUnitTestDescriptor(
        final UnitTestDescriptor unitTestDescriptor) {
        this.unitTestDescriptor = unitTestDescriptor;
    }

    protected boolean isSerializeInputs() {
        return unitTestDescriptor.isSerializeInputs();
    }

    protected boolean isSerializeOutputs() {
        return unitTestDescriptor.isSerializeOutputs();
    }

    protected boolean isValidateInputs() {
        return unitTestDescriptor.isValidateInputs();
    }

    protected boolean isValidateOutputs() {
        return unitTestDescriptor.isValidateOutputs();
    }

    protected void serializeInputs(final DvInputs dvInputs)
        throws IllegalAccessException {

        testSerialization(dvInputs, new DvInputs(), new File(
            Filenames.BUILD_TMP, getClass().getSimpleName() + "-inputs.bin"));
    }

    private static void testSerialization(DvInputs expected, DvInputs actual,
        File file) throws IllegalAccessException {

        // Save and read file.
        PersistableUtils.writeBinFile(expected, file);
        PersistableUtils.readBinFile(actual, file);

        // Test.
        ReflectionEquals re = new ReflectionEquals();
        re.excludeField(".*\\.targetDataStruct.*\\.pixels");
        re.excludeField(".*\\.targetStruct.*\\.fluxType");
        re.excludeField(".*\\.targetStruct.*\\.fsIdSets");
        re.excludeField(".*\\.targetStruct.*\\.mjdFsIdSets");
        re.excludeField(".*\\.targetStruct.*\\.pixelDataStruct");
        re.excludeField(".*\\.dvConfigurationStruct.*\\.storeRobustWeightsEnabled");
        re.excludeField(".*\\.kicsByKeplerId");

        re.assertEquals(expected, actual);
    }

    protected void serializeOutputs(final DvOutputs dvOutputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(dvOutputs, new DvOutputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-outputs.bin"));
    }

    protected void populateObjects() {
        createMockObjects();
        setMockObjects(getDvInputsRetriever());
        setMockObjects(getDvOutputsStorer());

        ancillaryEngineeringParameters.setMnemonics(unitTestDescriptor.getAncillaryEngineeringMnemonics());
        ancillaryPipelineParameters.setMnemonics(unitTestDescriptor.getAncillaryPipelineMnemonics());
        ancillaryPipelineParameters.setModelOrders(new int[unitTestDescriptor.getAncillaryPipelineMnemonics().length]);
        pipelineTask = createPipelineTask(PIPELINE_TASK_ID,
            unitTestDescriptor.getSkyGroupId(),
            unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId());
        pipelineInstance = pipelineTask.getPipelineInstance();

        getDvInputsRetriever().setMatlabWorkingDir(MATLAB_WORKING_DIR);
    }

    @SuppressWarnings("unchecked")
    private void createMockObjects() {
        targetTableOperationsTest = new TargetTableOperationsTest();
        targetTableOperationsTest.setDvJMockTest(this);
        targetTableOperationsTest.createMockObjects();

        alertService = mock(AlertService.class);
        ancillaryOperations = targetTableOperationsTest.getAncillaryOperations();
        configMapOperations = mock(ConfigMapOperations.class);
        daCrud = mock(DataAccountabilityTrailCrud.class);
        dataAnomalyOperations = targetTableOperationsTest.getDataAnomalyOperations();
        dvCrud = mock(DvCrud.class);
        fsClient = targetTableOperationsTest.getFsClient();
        genericReportOperations = mock(GenericReportOperations.class);
        inputsHandler = mock(InputsHandler.class);
        logCrud = targetTableOperationsTest.getLogCrud();
        mjdToCadence = targetTableOperationsTest.getMjdToCadence();
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        prfOperations = mock(PrfOperations.class);
        rollTimeOperations = targetTableOperationsTest.getRollTimeOperations();
        transitNameModelOperations = mock(ModelOperations.class, "transitNames");
        transitParameterModelOperations = mock(ModelOperations.class,
            "transitParameters");
        modelMetadataRetrieverPipelineInstance = mock(ModelMetadataRetrieverPipelineInstance.class);
    }

    private void setMockObjects(DvInputsRetriever dvInputsRetriever) {
        dvInputsRetriever.setLogCrud(logCrud);
        dvInputsRetriever.setMjdToCadence(mjdToCadence);
        dvInputsRetriever.setDataAnomalyOperations(dataAnomalyOperations);
        dvInputsRetriever.setConfigMapOperations(configMapOperations);
        dvInputsRetriever.setRaDec2PixOperations(raDec2PixOperations);
        dvInputsRetriever.setPrfOperations(prfOperations);
        dvInputsRetriever.setAncillaryOperations(ancillaryOperations);
        dvInputsRetriever.setBlobOperations(targetTableOperationsTest.getBlobOperations());
        dvInputsRetriever.setKicCrud(targetTableOperationsTest.getKicCrud());
        dvInputsRetriever.setCelestialObjectOperations(targetTableOperationsTest.getCelestialObjectOperations());
        dvInputsRetriever.setRollTimeOperations(rollTimeOperations);
        dvInputsRetriever.setTargetCrud(targetTableOperationsTest.getTargetCrud());
        dvInputsRetriever.setTargetSelectionCrud(targetTableOperationsTest.getTargetSelectionCrud());
        dvInputsRetriever.setTpsOperations(targetTableOperationsTest.getTpsOperations());
        dvInputsRetriever.setTpsCrud(targetTableOperationsTest.getTpsCrud());
        dvInputsRetriever.setModelMetadataRetrieverPipelineInstance(modelMetadataRetrieverPipelineInstance);
        dvInputsRetriever.setExternalTceModelOperations(targetTableOperationsTest.getExternalTceModelOperations());
        dvInputsRetriever.setTransitNameModelOperations(transitNameModelOperations);
        dvInputsRetriever.setTransitParameterModelOperations(transitParameterModelOperations);
    }

    private void setMockObjects(DvOutputsStorer dvOutputsStorer) {
        dvOutputsStorer.setDaCrud(daCrud);
        dvOutputsStorer.setGenericReportOperations(genericReportOperations);
        dvOutputsStorer.setAlertService(alertService);
        dvOutputsStorer.setDvCrud(dvCrud);
        dvOutputsStorer.setLogCrud(logCrud);
    }

    protected void createInputs() {
        int startCadence = unitTestDescriptor.getStartCadence();
        int endCadence = unitTestDescriptor.getEndCadence();

        MockUtils.mockFirstAndLastCadences(this, logCrud, Cadence.CADENCE_LONG,
            startCadence, endCadence);

        createTimeSeries(unitTestDescriptor);

        double startMjd = targetTableOperationsTest.getStartMjd();
        double endMjd = targetTableOperationsTest.getEndMjd();

        MockUtils.mockAncillaryEngineeringData(this, ancillaryOperations,
            startMjd, endMjd, ancillaryEngineeringParameters.getMnemonics());

        configMaps = MockUtils.mockConfigMaps(this, configMapOperations,
            SC_CONFIG_ID, startMjd, endMjd);
        raDec2PixModel = MockUtils.mockRaDec2PixModel(this,
            raDec2PixOperations, startMjd, endMjd);

        targetTableOperationsTest.setMatlabWorkingDir(MATLAB_WORKING_DIR);

        DvMockUtils.mockMjdsToQuarters(this, rollTimeOperations,
            targetTableOperationsTest.getCadenceTimes(), QUARTER);

        DvMockUtils.mockPixelLogForCadence(this,
            targetTableOperationsTest.getMjdToCadence(),
            targetTableOperationsTest.getCadenceTimes(), TARGET_TABLE_ID);

        DvMockUtils.mockMjdToCadenceMjdToCadence(this,
            targetTableOperationsTest.getMjdToCadence(),
            targetTableOperationsTest.getCadenceTimes());

        prfModelFileNames = DvMockUtils.mockPrfModels(this,
            targetTableOperationsTest.getKicCrud(), prfOperations,
            unitTestDescriptor.getSkyGroupId(), startMjd);

        if (unitTestDescriptor.isSimulatedTransitsEnabled()) {
            MockUtils.mockTipBlob(this, modelMetadataRetrieverPipelineInstance,
                targetTableOperationsTest.getBlobOperations(),
                TipImporter.MODEL_TYPE, unitTestDescriptor.getSkyGroupId(),
                new Date());
        }

        DvMockUtils.mockInputsHandler(this, inputsHandler, SUB_TASK_DIR);

        if (unitTestDescriptor.isKoiMatchingEnabled()) {
            DvMockUtils.mockTransitNameModel(this, transitNameModelOperations,
                targetTableOperationsTest.getAllTargets(unitTestDescriptor));
            DvMockUtils.mockTransitParameterModel(this,
                transitParameterModelOperations,
                targetTableOperationsTest.getAllTargets(unitTestDescriptor));
        }

        // Populate targetTableOperationsTest again for the pipeline's use of
        // targetTableOperations.getAllTargets.
        targetTableOperationsTest.populateObjects(unitTestDescriptor);

        producerTaskIds.addAll(targetTableOperationsTest.latestProducerTaskIds());
        producerTaskIds.addAll(PRODUCER_TASK_IDS);
    }

    private void createTimeSeries(UnitTestDescriptor unitTestDescriptor) {

        targetTableOperationsTest.populateObjects(unitTestDescriptor);

        TargetTableOperations targetTableOperations = targetTableOperationsTest.createTargetTableOperations(unitTestDescriptor);
        dvTargets = targetTableOperations.getAllTargets();

        if (dvTargets.size() > 0) {
            Map<Pair<Integer, Integer>, Set<FsId>> fsIdsByCadenceRange = new HashMap<Pair<Integer, Integer>, Set<FsId>>();
            Map<Pair<Double, Double>, Set<FsId>> mjdFsIdsByTimeRange = new HashMap<Pair<Double, Double>, Set<FsId>>();
            double startMjd = targetTableOperationsTest.getStartMjd();
            double endMjd = targetTableOperationsTest.getEndMjd();
            
            int fsIdCount = 0;
            for (DvTarget target : dvTargets) {

                List<FsIdSet> fsIdSets = target.getFsIdSets(
                    unitTestDescriptor.getStartCadence(),
                    unitTestDescriptor.getEndCadence(),
                    PULSE_DURATIONS);
                fsIdCount += timeSeriesCount(fsIdSets);
                DvUtils.addAllFsIds(fsIdSets, fsIdsByCadenceRange);

                timeSeriesBatchList.addAll(DvMockUtils.mockReadTimeSeriesBatch(
                    this, fsClient, unitTestDescriptor.isPrfCentroidsEnabled(),
                    TIME_SERIES_TASK_ID,
                    DvUtils.createFsIdSets(fsIdsByCadenceRange)));

                List<MjdFsIdSet> mjdFsIdSets = target.getMjdFsIdSets(startMjd,
                    endMjd);
                fsIdCount += mjdTimeSeriesCount(mjdFsIdSets);
                DvUtils.addAllMjdFsIds(mjdFsIdSets, mjdFsIdsByTimeRange);

                TimestampSeries cadenceTimes = targetTableOperationsTest.getCadenceTimes();
                double[] outlierMjds = new double[] { cadenceTimes.midTimestamps[0] };
                mjdTimeSeriesBatchList.addAll(DvMockUtils.mockMjdTimeSeriesBatchList(
                    this, fsClient, startMjd, endMjd, MJD_TIME_SERIES_TASK_ID,
                    DvUtils.createMjdFsIdSets(mjdFsIdsByTimeRange), outlierMjds));

                fsIdsByCadenceRange.clear();
                mjdFsIdsByTimeRange.clear();

                for (DvTargetData targetData : target.getTargetData()) {

                    fsIdSets = Arrays.asList(new FsIdSet(
                        targetData.getStartCadence(),
                        targetData.getEndCadence(),
                        Pixel.getAllFsIds(targetData.getPixels())));
                    fsIdCount += timeSeriesCount(fsIdSets);

                    timeSeriesBatchList.addAll(DvMockUtils.mockReadTimeSeriesBatch(
                        this, fsClient, false, TIME_SERIES_TASK_ID, fsIdSets));

                    mjdFsIdSets = Arrays.asList(new MjdFsIdSet(
                        targetData.getStartMjd(), targetData.getEndMjd(),
                        Pixel.getAllMjdFsIds(targetData.getPixels())));
                    fsIdCount += mjdTimeSeriesCount(mjdFsIdSets);

                    mjdTimeSeriesBatchList.addAll(DvMockUtils.mockMjdTimeSeriesBatchList(
                        this, fsClient, startMjd, endMjd,
                        MJD_TIME_SERIES_TASK_ID, mjdFsIdSets, new double[0]));
                }
            }

            log.debug("total fsIdCount: " + fsIdCount);
        }
    }

    private int timeSeriesCount(List<FsIdSet> fsIdSets) {
        int count = 0;
        for (FsIdSet fsIdSet : fsIdSets) {
            count += fsIdSet.ids()
                .size();
        }

        return count;
    }

    private int mjdTimeSeriesCount(List<MjdFsIdSet> mjdFsIdSets) {
        int count = 0;
        for (MjdFsIdSet mjdFsIdSet : mjdFsIdSets) {
            count += mjdFsIdSet.ids()
                .size();
        }

        return count;
    }

    protected void validate(DvInputs dvInputs) {
        assertNotNull(dvInputs);

        validateAncillary(dvInputs);
        validateTargetTableData(dvInputs.getTargetTableData());

        validateCadenceTimes(dvInputs.getMqCadenceTimes());
        validateCentroidTestParameters(dvInputs.getCentroidTestParameters());
        validateConfigMaps(dvInputs.getConfigMaps());
        validateDvModuleParameters(dvInputs.getDvModuleParameters());
        validateFcConstants(dvInputs.getFcConstants());
        validateFluxType(dvInputs.getFluxTypeParameters());
        validateGapFillModuleParameters(dvInputs.getGapFillModuleParameters());
        validateHarmonicsIdentificationParameters(dvInputs.getPdcHarmonicsIdentificationParameters());
        validateHarmonicsIdentificationParameters(dvInputs.getTpsHarmonicsIdentificationParameters());
        validatePdcModuleParameters(dvInputs.getPdcModuleParameters());
        validatePixelCorrelationParameters(dvInputs.getPixelCorrelationParameters());
        validateBootstrapModuleParameters(dvInputs.getBootstrapModuleParameters());
        validatePlanetFitModuleParameters(dvInputs.getPlanetFitModuleParameters());
        validateSaturationSegmentModuleParameters(dvInputs.getSaturationSegmentModuleParameters());
        validateDifferenceImageParameters(dvInputs.getDifferenceImageParameters());
        validateTpsModuleParameters(dvInputs.getTpsModuleParameters());
        validateTrapezoidalFitParameters(dvInputs.getTrapezoidalFitParameters());
        validateRaDec2PixModel(dvInputs.getRaDec2PixModel());
        validatePrfModels(dvInputs.getPrfModelFileNames());
        validateTargets(dvInputs.getTargets());
        validateMjd(mjdTimeSeriesBatchList, dvInputs.getTargets());
        validateAllTargetTableData(dvInputs.getTargetTableData());
    }

    private void validateAncillary(final DvInputs dvInputs) {

        assertNotNull(dvInputs.getAncillaryDesignMatrixParameters());

        assertEquals(ancillaryEngineeringParameters,
            dvInputs.getAncillaryEngineeringParameters());

        String[] mnemonics = dvInputs.getAncillaryEngineeringParameters()
            .getMnemonics();
        if (mnemonics.length > 0) {
            assertNotNull(dvInputs.getAncillaryEngineeringDataFileName());
            assertTrue(dvInputs.getAncillaryEngineeringDataFileName()
                .length() > 0);
        }
    }

    private void validateCadenceTimes(final MqTimestampSeries mqCadenceTimes) {
        assertNotNull(mqCadenceTimes);
        assertNotNull(mqCadenceTimes.startTimestamps);
        assertEquals(
            unitTestDescriptor.getEndCadence()
                - unitTestDescriptor.getStartCadence() + 1,
            mqCadenceTimes.startTimestamps.length);
    }

    private void validateCentroidTestParameters(
        CentroidTestParameters actualCentroidTestParameters) {
        assertNotNull(actualCentroidTestParameters);
    }

    private void validateConfigMaps(List<ConfigMap> actualConfigMaps) {
        assertNotNull(actualConfigMaps);
        assertEquals(configMaps, actualConfigMaps);
    }

    private void validateDvModuleParameters(
        DvModuleParameters actualDvModuleParameters) {
        assertNotNull(actualDvModuleParameters);
    }

    private void validateFcConstants(FcConstants actualFcConstants) {
        assertNotNull(actualFcConstants);
    }

    private void validateFluxType(FluxTypeParameters fluxTypeParameters) {
        assertNotNull(fluxTypeParameters);
        assertEquals(FLUX_TYPE.toString(), fluxTypeParameters.getFluxType());
    }

    private void validateGapFillModuleParameters(
        GapFillModuleParameters gapFillModuleParameters) {
        assertNotNull(gapFillModuleParameters);
    }

    private void validateHarmonicsIdentificationParameters(
        HarmonicsIdentificationParameters harmonicsIdentificationParameters) {
        assertNotNull(harmonicsIdentificationParameters);
    }

    private void validatePdcModuleParameters(
        PdcModuleParameters pdcModuleParameters) {
        assertNotNull(pdcModuleParameters);
    }

    private void validatePixelCorrelationParameters(
        PixelCorrelationParameters actualPixelCorrelationParameters) {
        assertNotNull(actualPixelCorrelationParameters);
    }

    private void validateBootstrapModuleParameters(
        BootstrapModuleParameters bootstrapModuleParameters) {
        assertNotNull(bootstrapModuleParameters);
    }

    private void validatePlanetFitModuleParameters(
        PlanetFitModuleParameters planetFitModuleParameters) {
        assertNotNull(planetFitModuleParameters);
    }

    private void validateSaturationSegmentModuleParameters(
        SaturationSegmentModuleParameters saturationSegmentModuleParameters) {
        assertNotNull(saturationSegmentModuleParameters);
    }

    private void validateDifferenceImageParameters(
        DifferenceImageParameters differenceImageParameters) {
        assertNotNull(differenceImageParameters);
    }

    private void validateTargetTableData(List<DvTargetTableData> targetTableData) {
        targetTableOperationsTest.validateAllTargetTableData(
            unitTestDescriptor, targetTableData);
    }

    private void validateTpsModuleParameters(
        TpsModuleParameters tpsModuleParameters) {
        assertNotNull(tpsModuleParameters);
    }

    private void validateTrapezoidalFitParameters(
        TrapezoidalFitParameters actualTrapezoidalFitParameters) {
        assertNotNull(actualTrapezoidalFitParameters);
    }

    private void validateRaDec2PixModel(RaDec2PixModel actualRaDec2PixModel) {
        assertNotNull(actualRaDec2PixModel);
        assertEquals(raDec2PixModel, actualRaDec2PixModel);
    }

    private void validatePrfModels(String[] prfModelFileNames) {
        assertEquals(4, prfModelFileNames.length);
        assertTrue(Arrays.equals(this.prfModelFileNames, prfModelFileNames));
        for (String prfModelFileName : prfModelFileNames) {
            assertNotNull(prfModelFileName);
            assertTrue(prfModelFileName.endsWith(".sdf"));
            File prfModel = new File(MATLAB_WORKING_DIR, prfModelFileName);
            assertTrue(prfModel.exists());
        }
    }

    private void validateTargets(List<DvTarget> dvTargets) {

        List<List<ObservedTarget>> observedTargetsList = targetTableOperationsTest.getObservedTargetsList();
        Map<Integer, List<ObservedTarget>> observedTargetsByKeplerId = new HashMap<Integer, List<ObservedTarget>>();
        for (List<ObservedTarget> observedTargets : observedTargetsList) {
            for (ObservedTarget observedTarget : observedTargets) {
                List<ObservedTarget> targets = observedTargetsByKeplerId.get(observedTarget.getKeplerId());
                if (targets == null) {
                    targets = new ArrayList<ObservedTarget>();
                    observedTargetsByKeplerId.put(observedTarget.getKeplerId(),
                        targets);
                }
                targets.add(observedTarget);
            }
        }

        int timeSeriesLength = unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1;
        for (DvTarget dvTarget : dvTargets) {
            assertTrue("target isn't populated", dvTarget.isPopulated());

            validateCentroidTimeSeries(timeSeriesBatchList, timeSeriesLength,
                dvTarget.getKeplerId(), CentroidType.FLUX_WEIGHTED,
                dvTarget.getCentroids()
                    .getFluxWeightedCentroids());
            validateCentroidTimeSeries(timeSeriesBatchList, timeSeriesLength,
                dvTarget.getKeplerId(), CentroidType.PRF,
                dvTarget.getCentroids()
                    .getPrfCentroids());
            validateCorrectedFluxTimeSeries(
                PdcFluxTimeSeriesType.CORRECTED_FLUX,
                PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
                timeSeriesLength, timeSeriesBatchList, dvTarget.getKeplerId(),
                dvTarget.getCorrectedFluxTimeSeries());

            validateTargetData(dvTarget.getTargetData(),
                observedTargetsByKeplerId.get(dvTarget.getKeplerId()));
        }
    }

    private static void validateCentroidTimeSeries(
        List<TimeSeriesBatch> timeSeriesBatchList, int length, int keplerId,
        CentroidType centroidType, CentroidTimeSeries centroidTimeSeries) {

        assertTrue(Arrays.equals(
            extractDoubleTimeSeries(length, timeSeriesBatchList,
                Centroids.getRowFsId(FluxType.SAP, centroidType,
                    CadenceType.LONG, keplerId)),
            centroidTimeSeries.getRowTimeSeries()
                .getValues()));
        assertTrue(Arrays.equals(
            extractFloatTimeSeries(length, timeSeriesBatchList,
                Centroids.getRowUncertaintiesFsId(FluxType.SAP, centroidType,
                    CadenceType.LONG, keplerId)),
            centroidTimeSeries.getRowTimeSeries()
                .getUncertainties()));
        assertTrue(Arrays.equals(
            extractDoubleTimeSeries(length, timeSeriesBatchList,
                Centroids.getColFsId(FluxType.SAP, centroidType,
                    CadenceType.LONG, keplerId)),
            centroidTimeSeries.getColumnTimeSeries()
                .getValues()));
        assertTrue(Arrays.equals(
            extractFloatTimeSeries(length, timeSeriesBatchList,
                Centroids.getColUncertaintiesFsId(FluxType.SAP, centroidType,
                    CadenceType.LONG, keplerId)),
            centroidTimeSeries.getColumnTimeSeries()
                .getUncertainties()));
    }

    private static void validateCorrectedFluxTimeSeries(
        PdcFluxTimeSeriesType valuesType,
        PdcFluxTimeSeriesType uncertaintiesType, int length,
        List<TimeSeriesBatch> timeSeriesBatchList, int keplerId,
        CorrectedFluxTimeSeries correctedFluxTimeSeries) {

        assertTrue(Arrays.equals(
            extractFloatTimeSeries(length, timeSeriesBatchList,
                PdcFsIdFactory.getFluxTimeSeriesFsId(valuesType, FluxType.SAP,
                    CadenceType.LONG, keplerId)),
            correctedFluxTimeSeries.getValues()));
        assertTrue(Arrays.equals(
            extractFloatTimeSeries(length, timeSeriesBatchList,
                PdcFsIdFactory.getFluxTimeSeriesFsId(uncertaintiesType,
                    FluxType.SAP, CadenceType.LONG, keplerId)),
            correctedFluxTimeSeries.getUncertainties()));

        assertTrue(Arrays.equals(new int[] { 0 },
            correctedFluxTimeSeries.getFilledIndices()));
    }

    private static float[] extractFloatTimeSeries(int length,
        List<TimeSeriesBatch> timeSeriesBatchList, FsId fsId) {

        for (TimeSeriesBatch timeSeriesBatch : timeSeriesBatchList) {
            Map<FsId, TimeSeries> timeSeriesByFsId = timeSeriesBatch.timeSeries();
            TimeSeries timeSeries = timeSeriesByFsId.get(fsId);
            if (timeSeries != null && timeSeries.exists()) {
                return ((FloatTimeSeries) timeSeriesByFsId.get(fsId)).fseries();
            }
        }

        return new float[length];
    }

    private static double[] extractDoubleTimeSeries(int length,
        List<TimeSeriesBatch> timeSeriesBatchList, FsId fsId) {

        for (TimeSeriesBatch timeSeriesBatch : timeSeriesBatchList) {
            Map<FsId, TimeSeries> timeSeriesByFsId = timeSeriesBatch.timeSeries();
            TimeSeries timeSeries = timeSeriesByFsId.get(fsId);
            if (timeSeries != null && timeSeries.exists()) {
                return ((DoubleTimeSeries) timeSeriesByFsId.get(fsId)).dseries();
            }
        }

        return new double[length];
    }

    private void validateTargetData(List<DvTargetData> targetDataList,
        List<ObservedTarget> observedTargets) {

        assertNotNull(targetDataList);
        assertEquals(unitTestDescriptor.getTargetTableCount(),
            targetDataList.size());
        assertEquals(targetDataList.size(),
            targetTableOperationsTest.getTargetTableLogs()
                .size());

        List<SkyGroup> skyGroups = targetTableOperationsTest.getSkyGroups();
        List<Integer> quarters = targetTableOperationsTest.getQuarters();

        int timeSeriesLength = unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1;

        for (int i = 0; i < targetDataList.size(); i++) {
            DvTargetData targetData = targetDataList.get(i);
            TargetTableLog targetTableLog = targetTableOperationsTest.getTargetTableLogs()
                .get(i);
            ObservedTarget observedTarget = observedTargets.get(i);
            int season = targetTableLog.getTargetTable()
                .getObservingSeason();
            SkyGroup skyGroup = skyGroups.get(season);

            assertEquals(season, skyGroup.getObservingSeason());
            assertEquals(skyGroup.getCcdModule(), targetData.getCcdModule());
            assertEquals(skyGroup.getCcdOutput(), targetData.getCcdOutput());
            assertEquals(observedTarget.getCrowdingMetric(),
                targetData.getCrowdingMetric(), 0);
            assertEquals(targetTableLog.getCadenceEnd(),
                targetData.getEndCadence());
            assertEquals(observedTarget.getFluxFractionInAperture(),
                targetData.getFluxFractionInAperture(), 0);
            assertTrue(Arrays.equals(observedTarget.getLabels()
                .toArray(new String[0]), targetData.getLabels()));
            assertEquals(
                TargetTableOperationsTest.pixelCountInOptimalAperture(targetData.getPixels()),
                targetData.getPixels()
                    .size());
            if (targetData.getPixelDataFileName() == null
                || targetData.getPixelDataFileName()
                    .length() == 0) {
                assertEquals(targetData.getPixels()
                    .size(), targetData.getPixelData()
                    .size());
                for (int j = 0; j < targetData.getPixelData()
                    .size(); j++) {
                    DvPixelData pixelData = targetData.getPixelData()
                        .get(j);
                    CalibratedPixel pixel = findPixel(pixelData.getCcdRow(),
                        pixelData.getCcdColumn(), targetData.getPixels());
                    assertNotNull(pixel);
                    assertEquals(pixel.isInOptimalAperture(),
                        pixelData.isInOptimalAperture());
                    assertTrue(Arrays.equals(
                        extractFloatTimeSeries(timeSeriesLength,
                            timeSeriesBatchList, pixel.getFsId()),
                        pixelData.getCalibratedTimeSeries()
                            .getValues()));
                    assertTrue(Arrays.equals(
                        extractFloatTimeSeries(timeSeriesLength,
                            timeSeriesBatchList, pixel.getUncertaintiesFsId()),
                        pixelData.getCalibratedTimeSeries()
                            .getUncertainties()));
                    assertTrue(Arrays.equals(
                        extractFloatMjdTimeSeries(mjdTimeSeriesBatchList,
                            pixel.getCosmicRayEventsFsId()).mjd(),
                        pixelData.getCosmicRayEvents()
                            .getTimes()));
                    assertTrue(Arrays.equals(
                        extractFloatMjdTimeSeries(mjdTimeSeriesBatchList,
                            pixel.getCosmicRayEventsFsId()).values(),
                        pixelData.getCosmicRayEvents()
                            .getValues()));
                }
            }
            assertEquals(quarters.get(i)
                .intValue(), targetData.getQuarter());
            assertEquals(targetTableLog.getCadenceStart(),
                targetData.getStartCadence());
            assertEquals(targetTableLog.getTargetTable()
                .getExternalId(), targetData.getTargetTableId());
        }
    }

    private CalibratedPixel findPixel(int ccdRow, int ccdColumn,
        Set<Pixel> pixels) {

        for (Pixel pixel : pixels) {
            if (pixel.getRow() == ccdRow && pixel.getColumn() == ccdColumn) {
                return (CalibratedPixel) pixel;
            }
        }

        return null;
    }

    private void validateMjd(List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList,
        List<DvTarget> targets) {

        for (DvTarget dvTarget : targets) {
            assertTrue("target isn't populated", dvTarget.isPopulated());

            validateOutliersTimeSeries(PdcOutliersTimeSeriesType.OUTLIERS,
                PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES,
                unitTestDescriptor, dvTarget.getKeplerId(),
                mjdTimeSeriesBatchList, dvTarget.getOutliers());
        }
    }

    private void validateOutliersTimeSeries(
        PdcOutliersTimeSeriesType valuesType,
        PdcOutliersTimeSeriesType uncertaintiesType,
        UnitTestDescriptor unitTestDescriptor, int keplerId,
        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList,
        OutliersTimeSeries outliers) {

        FsId valuesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(valuesType,
            FluxType.SAP, CadenceType.LONG, keplerId);
        FsId uncertaintiesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
            uncertaintiesType, FluxType.SAP, CadenceType.LONG, keplerId);

        assertTrue(
            valuesFsId.toString(),
            Arrays.equals(
                extractFloatMjdTimeSeries(mjdTimeSeriesBatchList, valuesFsId).values(),
                outliers.toTimeSeries(valuesFsId, uncertaintiesFsId,
                    unitTestDescriptor.getStartCadence(),
                    targetTableOperationsTest.getStartMjd(),
                    targetTableOperationsTest.getEndMjd(), 0L,
                    targetTableOperationsTest.getMjdToCadence())
                    .get(0)
                    .values()));

        assertTrue(
            valuesFsId.toString(),
            Arrays.equals(
                extractFloatMjdTimeSeries(mjdTimeSeriesBatchList, valuesFsId).mjd(),
                outliers.toTimeSeries(valuesFsId, uncertaintiesFsId,
                    unitTestDescriptor.getStartCadence(),
                    targetTableOperationsTest.getStartMjd(),
                    targetTableOperationsTest.getEndMjd(), 0L,
                    targetTableOperationsTest.getMjdToCadence())
                    .get(0)
                    .mjd()));

        assertTrue(
            uncertaintiesFsId.toString(),
            Arrays.equals(
                extractFloatMjdTimeSeries(mjdTimeSeriesBatchList,
                    uncertaintiesFsId).values(),
                outliers.toTimeSeries(valuesFsId, uncertaintiesFsId,
                    unitTestDescriptor.getStartCadence(),
                    targetTableOperationsTest.getStartMjd(),
                    targetTableOperationsTest.getEndMjd(), 0L,
                    targetTableOperationsTest.getMjdToCadence())
                    .get(1)
                    .values()));

        assertTrue(
            uncertaintiesFsId.toString(),
            Arrays.equals(
                extractFloatMjdTimeSeries(mjdTimeSeriesBatchList,
                    uncertaintiesFsId).mjd(),
                outliers.toTimeSeries(valuesFsId, uncertaintiesFsId,
                    unitTestDescriptor.getStartCadence(),
                    targetTableOperationsTest.getStartMjd(),
                    targetTableOperationsTest.getEndMjd(), 0L,
                    targetTableOperationsTest.getMjdToCadence())
                    .get(1)
                    .mjd()));
    }

    private FloatMjdTimeSeries extractFloatMjdTimeSeries(
        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList, FsId outliersFsId) {

        for (MjdTimeSeriesBatch mjdTimeSeriesBatch : mjdTimeSeriesBatchList) {
            Map<FsId, FloatMjdTimeSeries> mjdTimeSeriesByFsId = mjdTimeSeriesBatch.timeSeries();
            if (mjdTimeSeriesByFsId.containsKey(outliersFsId)) {
                return mjdTimeSeriesByFsId.get(outliersFsId);
            }
        }
        return new FloatMjdTimeSeries();
    }

    private void validateAllTargetTableData(
        List<DvTargetTableData> targetTableData) {

        targetTableOperationsTest.validateAllTargetTableData(
            unitTestDescriptor, targetTableData);
    }

    protected void createOutputs(final DvInputs dvInputs,
        final DvOutputs dvOutputs) {

        int targetCount = dvInputs.getTargets()
            .size();
        List<DvTargetResults> targetResultsList = new ArrayList<DvTargetResults>(
            targetCount);
        List<Integer> keplerIds = new ArrayList<Integer>(targetCount);
        Map<Integer, String> reportFilenames = new HashMap<Integer, String>(
            targetCount);
        Map<String, String> reportSummaryFilenames = new HashMap<String, String>(
            targetCount);
        int count = 1;
        for (DvTarget target : dvInputs.getTargets()) {
            keplerIds.add(target.getKeplerId());
            List<DvPlanetResults> planetResults = createPlanetResults(target.getKeplerId());
            String reportFilename = Integer.toString(target.getKeplerId())
                + "/dv-" + Integer.toString(target.getKeplerId()) + ".pdf";
            reportFilenames.put(target.getKeplerId(), reportFilename);
            for (DvPlanetResults dvPlanetResults : planetResults) {
                reportSummaryFilenames.put(String.format("%09d-%02d",
                    target.getKeplerId(), dvPlanetResults.getPlanetNumber()),
                    dvPlanetResults.getReportFilename());
            }
            CorrectedFluxTimeSeries residualFluxTimeSeries = createResidualFluxTimeSeries(target.getKeplerId());
            List<DvSingleEventStatistics> singleEventStatistics = createSingleEventStatistics(target.getKeplerId());
            double[] barycentricCorrectedTimestamps = createBarycentricCorrectedTimestamps(target.getKeplerId());
            List<DvLimbDarkeningModel> limbDarkeningModels = createLimbDarkeningModels(target.getKeplerId());
            DvQuantityWithProvenance effectiveTemp = new DvQuantityWithProvenance(
                1.0F, 0.01F, "KIC");
            DvQuantityWithProvenance log10Metallicity = new DvQuantityWithProvenance(
                2.0F, 0.01F, "KIC");
            DvQuantityWithProvenance log10SurfaceGravity = new DvQuantityWithProvenance(
                3.0F, 0.01F, "KIC");
            DvQuantityWithProvenance radius = new DvQuantityWithProvenance(
                4.0F, 0.01F, "KIC");
            DvDoubleQuantityWithProvenance decDegrees = new DvDoubleQuantityWithProvenance(
                5.0F, 0.01F, "KIC");
            DvQuantityWithProvenance keplerMag = new DvQuantityWithProvenance(
                6.0F, 0.01F, "KIC");
            DvDoubleQuantityWithProvenance raHours = new DvDoubleQuantityWithProvenance(
                7.0F, 0.01F, "KIC");
            String keplerName = "Kepler-" + count + " b";
            String koiId = String.format("K05%d.01", count);
            DvTargetResults targetResults = new DvTargetResults(
                target.getKeplerId(), barycentricCorrectedTimestamps,
                decDegrees, effectiveTemp, keplerMag, keplerName, koiId,
                limbDarkeningModels, log10Metallicity, log10SurfaceGravity,
                ArrayUtils.EMPTY_STRING_ARRAY, planetResults,
                QUARTERS_OBSERVED, radius, raHours, reportFilename,
                residualFluxTimeSeries, singleEventStatistics,
                new String[] { koiId });
            targetResultsList.add(targetResults);
        }
        dvOutputs.setFluxType(FluxType.SAP.toString());
        dvOutputs.setTargetResults(targetResultsList);
        dvOutputs.setAlerts(ImmutableList.of(new ModuleAlert(ALERT_MESSAGE)));
        dvOutputs.setExternalTceModelDescription(dvInputs.getExternalTceModelDescription());
        dvOutputs.setTransitNameModelDescription(dvInputs.getTransitNameModelDescription());
        dvOutputs.setTransitParameterModelDescription(dvInputs.getTransitParameterModelDescription());

        if (unitTestDescriptor.isValidateOutputs()) {
            for (Entry<Integer, String> entry : reportFilenames.entrySet()) {
                MockUtils.mockGenericReport(this, genericReportOperations,
                    pipelineTask, entry.getKey()
                        .toString(), MATLAB_WORKING_DIR, entry.getValue());
            }
            for (Entry<String, String> entry : reportSummaryFilenames.entrySet()) {
                MockUtils.mockGenericReport(this, genericReportOperations,
                    pipelineTask, entry.getKey(), MATLAB_WORKING_DIR,
                    entry.getValue());
            }
            MockUtils.mockWriteTimeSeries(this, fsClient,
                timeSeriesList.toArray(new TimeSeries[0]));
            DvHibernateUtils.mockPlanetResults(this, dvCrud,
                unitTestDescriptor, pipelineTask, keplerIds);
            DvHibernateUtils.mockLimbDarkeningModels(this, dvCrud,
                unitTestDescriptor, pipelineTask, keplerIds);
            DvHibernateUtils.mockTargetResults(this, dvCrud,
                unitTestDescriptor, pipelineTask, targetResultsList);
            MockUtils.mockAlert(this, alertService,
                DvPipelineModule.MODULE_NAME, pipelineTask.getId(),
                Severity.ERROR, String.format("%s: time=0.0", ALERT_MESSAGE));
            DvMockUtils.mockExternalTceModelDescription(this, dvCrud,
                pipelineTask, unitTestDescriptor.isExternalTcesEnabled());
            if (dvModuleParameters.isKoiMatchingEnabled()) {
                DvMockUtils.mockTransitModelDescriptions(this, dvCrud,
                    pipelineTask);
            }
            MockUtils.mockDataAccountabilityTrail(this, daCrud, pipelineTask,
                producerTaskIds);
        }
    }

    private List<DvPlanetResults> createPlanetResults(int keplerId) {

        List<DvPlanetResults> planetResultsList = new ArrayList<DvPlanetResults>(
            unitTestDescriptor.getPlanetCount());

        for (int planetNumber = 1; planetNumber <= unitTestDescriptor.getPlanetCount(); planetNumber++) {

            String reportFilename = String.format(
                "%09d-%02d-planet-summary.pdf", keplerId, planetNumber);

            DvBinaryDiscriminationResults binaryDiscriminationResults = new DvBinaryDiscriminationResults.Builder().longerPeriodComparisonStatistic(
                new DvPlanetStatistic(planetNumber, 0, 0))
                .oddEvenTransitDepthComparisonStatistic(new DvStatistic())
                .oddEvenTransitEpochComparisonStatistic(new DvStatistic())
                .shorterPeriodComparisonStatistic(
                    new DvPlanetStatistic(planetNumber, 0, 0))
                .singleTransitDepthComparisonStatistic(new DvStatistic())
                .singleTransitDurationComparisonStatistic(new DvStatistic())
                .singleTransitEpochComparisonStatistic(new DvStatistic())
                .build();

            DvMqCentroidOffsets mqControlCentroidOffsets = new DvMqCentroidOffsets(
                new DvQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvQuantity(), new DvQuantity());
            DvMqCentroidOffsets mqKicCentroidOffsets = new DvMqCentroidOffsets(
                new DvQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvQuantity(), new DvQuantity());
            DvMqImageCentroid mqControlImageCentroid = new DvMqImageCentroid(
                new DvDoubleQuantity(), new DvDoubleQuantity());
            DvMqImageCentroid mqDifferenceImageCentroid = new DvMqImageCentroid(
                new DvDoubleQuantity(), new DvDoubleQuantity());
            DvMqImageCentroid mqCorrelationImageCentroid = new DvMqImageCentroid(
                new DvDoubleQuantity(), new DvDoubleQuantity());
            DvDifferenceImageMotionResults differenceImageMotionResults = new DvDifferenceImageMotionResults(
                mqControlCentroidOffsets, mqKicCentroidOffsets,
                mqControlImageCentroid, mqDifferenceImageCentroid,
                new DvSummaryQualityMetric(), new DvSummaryOverlapMetric());
            DvCentroidMotionResults fluxWeightedMotionResults = new DvCentroidMotionResults(
                new DvStatistic(), new DvDoubleQuantity(),
                new DvDoubleQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvDoubleQuantity(),
                new DvDoubleQuantity());
            DvPixelCorrelationMotionResults pixelCorrelationMotionResults = new DvPixelCorrelationMotionResults(
                mqControlCentroidOffsets, mqKicCentroidOffsets,
                mqControlImageCentroid, mqCorrelationImageCentroid);
            DvCentroidMotionResults prfMotionResults = new DvCentroidMotionResults(
                new DvStatistic(), new DvDoubleQuantity(),
                new DvDoubleQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvQuantity(), new DvQuantity(),
                new DvQuantity(), new DvDoubleQuantity(),
                new DvDoubleQuantity());
            DvCentroidResults centroidResults = new DvCentroidResults(
                fluxWeightedMotionResults, prfMotionResults,
                differenceImageMotionResults, pixelCorrelationMotionResults);

            List<DvDifferenceImagePixelData> differenceImagePixelData = new ArrayList<DvDifferenceImagePixelData>();
            differenceImagePixelData.add(new DvDifferenceImagePixelData(
                unitTestDescriptor.getCcdRow(),
                unitTestDescriptor.getCcdColumn(), new DvQuantity(0, 0),
                new DvQuantity(0, 0), new DvQuantity(0, 0),
                new DvQuantity(0, 0)));
            List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();
            differenceImageResults.add(new DvDifferenceImageResults.Builder(
                unitTestDescriptor.getTargetTableId()).ccdModule(
                unitTestDescriptor.getCcdModule())
                .ccdOutput(unitTestDescriptor.getCcdOutput())
                .endCadence(unitTestDescriptor.getEndCadence())
                .quarter(unitTestDescriptor.getQuarter())
                .startCadence(unitTestDescriptor.getStartCadence())
                .controlCentroidOffsets(
                    createCentroidOffsets(CONTROL_CENTROID_OFFSETS_OFFSET))
                .controlImageCentroid(
                    createImageCentroid(CONTROL_IMAGE_CENTROID_OFFSET))
                .differenceImageCentroid(
                    createImageCentroid(DIFFERENCE_IMAGE_CENTROID_OFFSET))
                .kicCentroidOffsets(
                    createCentroidOffsets(KIC_CENTROID_OFFSETS_OFFSET))
                .kicReferenceCentroid(
                    createImageCentroid(KIC_REFERENCE_CENTROID_OFFSET))
                .numberOfTransits(unitTestDescriptor.getNumberOfTransits())
                .numberOfCadencesInTransit(
                    unitTestDescriptor.getNumberOfCadencesInTransit())
                .numberOfCadenceGapsInTransit(
                    unitTestDescriptor.getNumberOfCadenceGapsInTransit())
                .numberOfCadencesOutOfTransit(
                    unitTestDescriptor.getNumberOfCadencesOutOfTransit())
                .numberOfCadenceGapsOutOfTransit(
                    unitTestDescriptor.getNumberOfCadenceGapsOutOfTransit())
                .qualityMetric(createQualityMetric())
                .overlappedTransits(unitTestDescriptor.isOverlappedTransits())
                .differenceImagePixels(differenceImagePixelData)
                .build());

            DvGhostDiagnosticResults ghostDiagnosticResults = new DvGhostDiagnosticResults(
                new DvStatistic(), new DvStatistic());

            List<DvPixelStatistic> pixelCorrelationStatistics = new ArrayList<DvPixelStatistic>();
            pixelCorrelationStatistics.add(new DvPixelStatistic(0, 0,
                unitTestDescriptor.getCcdRow(),
                unitTestDescriptor.getCcdColumn()));
            List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
            pixelCorrelationResults.add(new DvPixelCorrelationResults.Builder(
                unitTestDescriptor.getTargetTableId()).ccdModule(
                unitTestDescriptor.getCcdModule())
                .ccdOutput(unitTestDescriptor.getCcdOutput())
                .endCadence(unitTestDescriptor.getEndCadence())
                .quarter(unitTestDescriptor.getQuarter())
                .startCadence(unitTestDescriptor.getStartCadence())
                .controlCentroidOffsets(
                    createCentroidOffsets(CONTROL_CENTROID_OFFSETS_OFFSET))
                .controlImageCentroid(
                    createImageCentroid(CONTROL_IMAGE_CENTROID_OFFSET))
                .correlationImageCentroid(
                    createImageCentroid(DIFFERENCE_IMAGE_CENTROID_OFFSET))
                .kicCentroidOffsets(
                    createCentroidOffsets(KIC_CENTROID_OFFSETS_OFFSET))
                .kicReferenceCentroid(
                    createImageCentroid(KIC_REFERENCE_CENTROID_OFFSET))
                .pixelCorrelationStatistics(pixelCorrelationStatistics)
                .build());

            DvBootstrapHistogram bootstrapHistogram = new DvBootstrapHistogram(
                0, new float[1], new float[1]);
            CorrectedFluxTimeSeries initialFluxTimeSeries = createCorrectedFluxTimeSeries(
                DvCorrectedFluxType.INITIAL, keplerId, planetNumber);
            DvPlanetCandidate planetCandidate = new DvPlanetCandidate.Builder(
                keplerId).bootstrapHistogram(bootstrapHistogram)
                .bootstrapMesMean(BOOTSTRAP_MES_MEAN)
                .bootstrapMesStd(BOOTSTRAP_MES_STD)
                .bootstrapThresholdForDesiredPfa(
                    BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA)
                .initialFluxTimeSeries(initialFluxTimeSeries)
                .modelChiSquareGof(MODEL_CHI_SQUARE_GOF)
                .modelChiSquareGofDof(MODEL_CHI_SQUARE_GOF_DOF)
                .planetNumber(planetNumber)
                .weakSecondary(new WeakSecondary())
                .build();

            float[] foldedPhase = createFoldedPhaseTimeSeries(keplerId,
                planetNumber);
            SimpleFloatTimeSeries modelLightCurve = createLightCurveTimeSeries(
                MODEL_LIGHT_CURVE, keplerId, planetNumber);
            SimpleFloatTimeSeries whitenedModelLightCurve = createLightCurveTimeSeries(
                WHITENED_MODEL_LIGHT_CURVE, keplerId, planetNumber);
            SimpleFloatTimeSeries trapezoidalModelLightCurve = createLightCurveTimeSeries(
                TRAPEZOIDAL_MODEL_LIGHT_CURVE, keplerId, planetNumber);
            SimpleFloatTimeSeries whitenedFluxTimeSeries = createFluxTimeSeries(
                "WhitenedFlux", keplerId, planetNumber);
            CorrectedFluxTimeSeries detrendedFluxTimeSeries = createCorrectedFluxTimeSeries(
                DETRENDED, keplerId, planetNumber);

            DvPlanetModelFit allTransitsFit = createPlanetModelFit(
                PlanetModelFitType.ALL, keplerId, planetNumber);
            DvPlanetModelFit evenTransitsFit = createPlanetModelFit(
                PlanetModelFitType.EVEN, keplerId, planetNumber);
            DvPlanetModelFit oddTransitsFit = createPlanetModelFit(
                PlanetModelFitType.ODD, keplerId, planetNumber);
            DvPlanetModelFit trapezoidalFit = createPlanetModelFit(
                PlanetModelFitType.TRAPEZOIDAL, keplerId, planetNumber);
            List<DvPlanetModelFit> reducedParameterFits = createReducedParameterPlanetModelFits(
                keplerId, planetNumber);
            DvImageArtifactResults imageArtifactResults = createImageArtifactResults();
            DvSecondaryEventResults secondaryEventResults = createSecondaryEventResults();

            planetResultsList.add(new DvPlanetResults.Builder(keplerId,
                planetNumber).alltransitsFit(allTransitsFit)
                .binaryDiscriminationResults(binaryDiscriminationResults)
                .centroidResults(centroidResults)
                .detrendFilterLength(DETREND_FILTER_LENGTH)
                .differenceImageResults(differenceImageResults)
                .evenTransitsFit(evenTransitsFit)
                .foldedPhase(foldedPhase)
                .imageArtifactResults(imageArtifactResults)
                .modelLightCurve(modelLightCurve)
                .whitenedModelLightCurve(whitenedModelLightCurve)
                .whitenedFluxTimeSeries(whitenedFluxTimeSeries)
                .detrendedFluxTimeSeries(detrendedFluxTimeSeries)
                .oddTransitsFit(oddTransitsFit)
                .ghostDiagnosticResults(ghostDiagnosticResults)
                .pixelCorrelationResults(pixelCorrelationResults)
                .planetCandidate(planetCandidate)
                .reducedParameterFits(reducedParameterFits)
                .secondaryEventResults(secondaryEventResults)
                .trapezoidalFit(trapezoidalFit)
                .trapezoidalModelLightCurve(trapezoidalModelLightCurve)
                .reportFilename(reportFilename)
                .build());
        }

        return planetResultsList;
    }

    private DvSecondaryEventResults createSecondaryEventResults() {

        return new DvSecondaryEventResults(new DvPlanetParameters(
            new DvQuantity(), new DvQuantity()), new DvComparisonTests(
            new DvStatistic(), new DvStatistic()));
    }

    private DvImageArtifactResults createImageArtifactResults() {

        return new DvImageArtifactResults(
            createRollingBandContaminationHistogram());
    }

    private DvRollingBandContaminationHistogram createRollingBandContaminationHistogram() {

        final int testPulseDurationLc = TEST_PULSE_DURATION_LC;
        return new DvRollingBandContaminationHistogram(testPulseDurationLc,
            new float[0], new int[0], new float[0]);
    }

    private DvPlanetModelFit createPlanetModelFit(PlanetModelFitType type,
        int keplerId, int planetNumber) {

        List<DvModelParameter> modelParameters = Arrays.asList(new DvModelParameter(
            "foo", false, 0, 0));

        FsId[] fsIds = new FsId[] { DvFsIdFactory.getRobustWeightsTimeSeriesFsId(
            FluxType.SAP, type, pipelineInstance.getId(), keplerId,
            planetNumber) };
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pipelineTask.getId(), fsIds);
        timeSeriesList.add(floatTimeSeries[0]);

        return new DvPlanetModelFit.Builder(keplerId, planetNumber).fullConvergence(
            true)
            .limbDarkeningModelName(
                unitTestDescriptor.getLimbDarkeningModelName())
            .modelChiSquare(0)
            .modelDegreesOfFreedom(1.0F)
            .modelFitSnr(2.0F)
            .modelParameterCovariance(new float[1])
            .modelParameters(modelParameters)
            .robustWeights(floatTimeSeries[0].fseries())
            .transitModelName(unitTestDescriptor.getTransitModelName())
            .build();
    }

    private List<DvPlanetModelFit> createReducedParameterPlanetModelFits(
        int keplerId, int planetNumber) {

        List<DvModelParameter> modelParameters = Arrays.asList(new DvModelParameter(
            IMPACT_PARAMETER, false, 0, 0));

        FsId[] fsIds = new FsId[] { DvFsIdFactory.getReducedParameterRobustWeightsTimeSeriesFsId(
            FluxType.SAP, pipelineInstance.getId(), keplerId, planetNumber,
            IMPACT_PARAMETER, 0) };
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pipelineTask.getId(), fsIds);
        timeSeriesList.add(floatTimeSeries[0]);

        return Arrays.asList(new DvPlanetModelFit.Builder(keplerId,
            planetNumber).fullConvergence(true)
            .limbDarkeningModelName(
                unitTestDescriptor.getLimbDarkeningModelName())
            .modelChiSquare(0)
            .modelDegreesOfFreedom(1.0F)
            .modelFitSnr(2.0F)
            .modelParameterCovariance(new float[1])
            .modelParameters(modelParameters)
            .robustWeights(floatTimeSeries[0].fseries())
            .transitModelName(unitTestDescriptor.getTransitModelName())
            .build());
    }

    private CorrectedFluxTimeSeries createResidualFluxTimeSeries(int keplerId) {

        FsId valuesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(FluxType.SAP,
            DvTimeSeriesType.FLUX, pipelineInstance.getId(), keplerId);
        FsId uncertaintiesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            FluxType.SAP, DvTimeSeriesType.UNCERTAINTIES,
            pipelineInstance.getId(), keplerId);
        FsId filledIndicesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            FluxType.SAP, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId);

        return createCorrectedFluxTimeSeries(keplerId, valuesFsId,
            uncertaintiesFsId, filledIndicesFsId);
    }

    private CorrectedFluxTimeSeries createCorrectedFluxTimeSeries(
        DvCorrectedFluxType correctedFluxType, int keplerId, int planetNumber) {

        FsId valuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            FluxType.SAP, correctedFluxType, DvTimeSeriesType.FLUX,
            pipelineInstance.getId(), keplerId, planetNumber);
        FsId uncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            FluxType.SAP, correctedFluxType, DvTimeSeriesType.UNCERTAINTIES,
            pipelineInstance.getId(), keplerId, planetNumber);
        FsId filledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            FluxType.SAP, correctedFluxType, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId, planetNumber);

        return createCorrectedFluxTimeSeries(keplerId, valuesFsId,
            uncertaintiesFsId, filledIndicesFsId);
    }

    private CorrectedFluxTimeSeries createCorrectedFluxTimeSeries(int keplerId,
        FsId valuesFsId, FsId uncertaintiesFsId, FsId filledIndicesFsId) {

        Map<FsId, TimeSeries> timeSeriesByFsId = new HashMap<FsId, TimeSeries>();

        FsId[] fsIds = new FsId[] { valuesFsId, uncertaintiesFsId };
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pipelineTask.getId(), fsIds);
        for (TimeSeries timeSeries : floatTimeSeries) {
            timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            timeSeriesList.add(timeSeries);
        }

        int length = unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1;
        int[] iseries = new int[length];
        iseries[0] = 1;
        boolean[] gaps = new boolean[length];
        Arrays.fill(gaps, true);
        gaps[0] = false;
        IntTimeSeries timeSeries = new IntTimeSeries(filledIndicesFsId,
            iseries, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), gaps, pipelineTask.getId());
        timeSeriesByFsId.put(timeSeries.id(), timeSeries);
        timeSeriesList.add(timeSeries);

        return CorrectedFluxTimeSeries.getInstance(
            valuesFsId,
            uncertaintiesFsId,
            filledIndicesFsId,
            unitTestDescriptor.getEndCadence()
                - unitTestDescriptor.getStartCadence() + 1, timeSeriesByFsId);
    }

    private float[] createFoldedPhaseTimeSeries(int keplerId, int planetNumber) {

        FsId fsId = DvFsIdFactory.getFoldedPhaseTimeSeriesFsId(FluxType.SAP,
            pipelineInstance.getId(), keplerId, planetNumber);
        float[] values = new float[unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1];
        Arrays.fill(values, 2.5F);
        FloatTimeSeries timeSeries = new FloatTimeSeries(fsId, values,
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), new boolean[values.length],
            pipelineTask.getId());
        timeSeriesList.add(timeSeries);

        return timeSeries.fseries();
    }

    private double[] createBarycentricCorrectedTimestamps(int keplerId) {

        FsId fsId = DvFsIdFactory.getBarycentricCorrectedTimestampsFsId(
            FluxType.SAP, pipelineInstance.getId(), keplerId);
        double[] values = new double[unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1];
        Arrays.fill(values, 1.5);
        DoubleTimeSeries timeSeries = new DoubleTimeSeries(fsId, values,
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), new boolean[values.length],
            pipelineTask.getId());
        timeSeriesList.add(timeSeries);

        return timeSeries.dseries();
    }

    private List<DvLimbDarkeningModel> createLimbDarkeningModels(int keplerId) {

        DvLimbDarkeningModel limbDarkeningModel = new DvLimbDarkeningModel.Builder(
            unitTestDescriptor.getTargetTableId(), keplerId).ccdModule(
            unitTestDescriptor.getCcdModule())
            .ccdOutput(unitTestDescriptor.getCcdOutput())
            .startCadence(unitTestDescriptor.getStartCadence())
            .endCadence(unitTestDescriptor.getEndCadence())
            .quarter(unitTestDescriptor.getQuarter())
            .modelName("kepler_nonlinear_limb_darkening_model")
            .coefficient1(1.0F)
            .coefficient2(2.0F)
            .coefficient3(3.0F)
            .coefficient4(4.0F)
            .build();

        return Arrays.asList(limbDarkeningModel);
    }

    private SimpleFloatTimeSeries createLightCurveTimeSeries(
        DvLightCurveType lightCurveType, int keplerId, int planetNumber) {

        FsId valuesFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
            FluxType.SAP, lightCurveType, pipelineInstance.getId(), keplerId,
            planetNumber);
        return createSimpleFloatTimeSeries(valuesFsId);
    }

    private SimpleFloatTimeSeries createSimpleFloatTimeSeries(FsId valuesFsId) {

        Map<FsId, TimeSeries> timeSeriesByFsId = new HashMap<FsId, TimeSeries>();

        FsId[] fsIds = new FsId[] { valuesFsId };
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pipelineTask.getId(), fsIds);
        for (TimeSeries timeSeries : floatTimeSeries) {
            timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            timeSeriesList.add(timeSeries);
        }

        return SimpleTimeSeries.getFloatInstance(valuesFsId, timeSeriesByFsId);
    }

    private SimpleFloatTimeSeries createFluxTimeSeries(String lightCurveType,
        int keplerId, int planetNumber) {

        FsId valuesFsId = DvFsIdFactory.getFluxTimeSeriesFsId(FluxType.SAP,
            lightCurveType, pipelineInstance.getId(), keplerId, planetNumber);
        return createSimpleFloatTimeSeries(valuesFsId);
    }

    private List<DvSingleEventStatistics> createSingleEventStatistics(
        int keplerId) {

        List<DvSingleEventStatistics> singleEventStatisticsList = new ArrayList<DvSingleEventStatistics>();

        FsId normalizationFsId = DvFsIdFactory.getSingleEventStatisticsFsId(
            FluxType.SAP, DvSingleEventStatisticsType.NORMALIZATION,
            pipelineInstance.getId(), keplerId, TRIAL_TRANSIT_PULSE_DURATION);

        FsId correlationFsId = DvFsIdFactory.getSingleEventStatisticsFsId(
            FluxType.SAP, DvSingleEventStatisticsType.CORRELATION,
            pipelineInstance.getId(), keplerId, TRIAL_TRANSIT_PULSE_DURATION);

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>();
        FsId[] fsIds = new FsId[] { normalizationFsId, correlationFsId };
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pipelineTask.getId(), fsIds);
        for (FloatTimeSeries timeSeries : floatTimeSeries) {
            timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            timeSeriesList.add(timeSeries);
        }
        singleEventStatisticsList.add(DvSingleEventStatistics.getInstance(
            FluxType.SAP, pipelineInstance.getId(), keplerId,
            TRIAL_TRANSIT_PULSE_DURATION, timeSeriesByFsId));

        return singleEventStatisticsList;
    }

    private PipelineTask createPipelineTask(final long pipelineTaskId,
        int skyGroupId, int startKeplerId, int endKeplerId) {

        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance();
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            skyGroupId, startKeplerId, endKeplerId)));
        task.setPipelineDefinitionNode(definitionNode);
        task.setSoftwareRevision("software revision");

        return task;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {
        PipelineModuleDefinition moduleDefinition = new PipelineModuleDefinition(
            DvPipelineModule.MODULE_NAME);
        moduleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            DvPipelineModule.class));
        moduleDefinition.setExeName("dv");

        return moduleDefinition;
    }

    private PipelineInstance createPipelineInstance() {
        PipelineInstance instance = new PipelineInstance();
        instance.setId(INSTANCE_ID);

        ParameterSet cadenceTypeParameterSet = new ParameterSet("cadenceType");
        cadenceTypeParameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        instance.putParameterSet(new ClassWrapper<Parameters>(
            CadenceTypePipelineParameters.class), cadenceTypeParameterSet);

        return instance;
    }

    /**
     * When the set of required input parameters undergoes a change, edit this
     * method to insert the required parameter set(s) or to no longer insert
     * the no-longer-required parameter set(s).
     */
    private PipelineInstanceNode createPipelineInstanceNode(
        final PipelineModuleDefinition moduleDefinition,
        final PipelineInstance instance,
        final PipelineDefinitionNode definitionNode) {

        PipelineInstanceNode instanceNode = new PipelineInstanceNode(instance,
            definitionNode, moduleDefinition);

        dvModuleParameters.setDebugLevel(debugLevel);
        dvModuleParameters.setBinaryDiscriminationTestsEnabled(unitTestDescriptor.isBinaryDiscriminationTestsEnabled());
        dvModuleParameters.setBootstrapEnabled(unitTestDescriptor.isBootstrapEnabled());
        dvModuleParameters.setCentroidTestsEnabled(unitTestDescriptor.isCentroidTestsEnabled());
        dvModuleParameters.setLimbDarkeningModelName(unitTestDescriptor.getLimbDarkeningModelName());
        dvModuleParameters.setMultiplePlanetSearchEnabled(unitTestDescriptor.isMultiplePlanetSearchEnabled());
        dvModuleParameters.setReportEnabled(unitTestDescriptor.isReportEnabled());
        dvModuleParameters.setStoreRobustWeightsEnabled(unitTestDescriptor.isStoreRobustWeightsEnabled());
        dvModuleParameters.setTransitModelName(unitTestDescriptor.getTransitModelName());
        dvModuleParameters.setSimulatedTransitsEnabled(unitTestDescriptor.isSimulatedTransitsEnabled());
        dvModuleParameters.setExternalTcesEnabled(unitTestDescriptor.isExternalTcesEnabled());
        dvModuleParameters.setKoiMatchingEnabled(unitTestDescriptor.isKoiMatchingEnabled());

        BootstrapModuleParameters bootstrapModuleParameters = new BootstrapModuleParameters();
        bootstrapModuleParameters.setSkipCount(unitTestDescriptor.getBootstrapSkipCount());
        bootstrapModuleParameters.setHistogramBinWidth(unitTestDescriptor.getHistogramBinWidth());

        insertParameterSet(instanceNode, dvModuleParameters);
        insertParameterSet(instanceNode, new CadenceRangeParameters());
        insertParameterSet(instanceNode, new AncillaryDesignMatrixParameters());
        insertParameterSet(instanceNode, ancillaryEngineeringParameters);
        insertParameterSet(instanceNode, ancillaryPipelineParameters);
        insertParameterSet(instanceNode, new CentroidTestParameters());
        CustomTargetParameters customTargetParameters = new CustomTargetParameters();
        insertParameterSet(instanceNode, customTargetParameters);
        FluxTypeParameters fluxTypeParameters = new FluxTypeParameters();
        fluxTypeParameters.setFluxType(FLUX_TYPE.toString());
        insertParameterSet(instanceNode, fluxTypeParameters);
        insertParameterSet(instanceNode, new GapFillModuleParameters());
        insertParameterSet(instanceNode,
            new PdcHarmonicsIdentificationParameters());
        insertParameterSet(instanceNode,
            new TpsHarmonicsIdentificationParameters());
        insertParameterSet(instanceNode, new PdcModuleParameters());
        insertParameterSet(instanceNode, bootstrapModuleParameters);
        insertParameterSet(instanceNode, new PixelCorrelationParameters());
        insertParameterSet(instanceNode, new PlanetFitModuleParameters());
        insertParameterSet(instanceNode,
            unitTestDescriptor.getPlanetaryCandidatesFilterParameters());
        insertParameterSet(instanceNode,
            new SaturationSegmentModuleParameters());
        insertParameterSet(instanceNode, new TpsModuleParameters());
        DifferenceImageParameters differenceImageParameters = new DifferenceImageParameters();
        differenceImageParameters.setBoundedBoxWidth(unitTestDescriptor.getBoundedBoxWidth());
        insertParameterSet(instanceNode, differenceImageParameters);
        insertParameterSet(instanceNode, new TrapezoidalFitParameters());
        PaModuleParameters paModuleParameters = new PaModuleParameters();
        paModuleParameters.setTestPulseDurations(PULSE_DURATIONS);
        insertParameterSet(instanceNode, paModuleParameters);

        return instanceNode;
    }

    private void insertParameterSet(PipelineInstanceNode instanceNode,
        Parameters parameters) {
        ParameterSet parameterSet = new ParameterSet(parameters.getClass()
            .getSimpleName());
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
        instanceNode.putModuleParameterSet(parameters.getClass(), parameterSet);
    }

    private static UnitOfWorkTask createUowTask(final int skyGroupId,
        final int startKeplerId, final int endKeplerId) {

        PlanetaryCandidatesChunkUowTask uowTask = new PlanetaryCandidatesChunkUowTask(
            skyGroupId, startKeplerId, endKeplerId);

        return uowTask;
    }
}
