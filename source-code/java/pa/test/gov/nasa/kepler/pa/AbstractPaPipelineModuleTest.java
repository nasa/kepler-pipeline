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

package gov.nasa.kepler.pa;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithExpectedSize;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Maps.newHashMapWithExpectedSize;
import static com.google.common.collect.Maps.newTreeMap;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newHashSetWithExpectedSize;
import static com.google.common.collect.Sets.newTreeSet;
import static gov.nasa.kepler.mc.TimeSeriesOperations.getTimeSeriesByFsId;
import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pa.CentroidPixel;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsLiteDbResult;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.PseudoTargetListParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.pa.PaCosmicRayMetrics;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.SimulatedTransitsModuleParameters;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.tip.TipImporter;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.PersistableUtils;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;
import java.util.Set;

import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public abstract class AbstractPaPipelineModuleTest extends JMockTest {

    private static final Log log = LogFactory.getLog(AbstractPaPipelineModuleTest.class);

    private static final int EXE_TIMEOUT_SECS = 60;
    private static final String PROP_FILE = Filenames.ETC
        + FilenameConstants.KEPLER_CONFIG;
    private static final int SC_CONFIG_ID = 42;
    private static final long INSTANCE_ID = System.currentTimeMillis();
    private static final long PIPELINE_TASK_ID = INSTANCE_ID - 1000;
    private static final int CCD_MODULE = 12;
    private static final int CCD_OUTPUT = 3;
    private static final int OBSERVING_SEASON = 2;
    private static final int SKY_GROUP_ID = 67;
    private static final int MAX_PIXELS_PER_TARGET = 32;
    private static final int TARGETS_PER_TABLE = 10;
    private static final int PPA_TARGETS_PER_TABLE = 2;
    private static final float COSMIC_RAY_DELTA_FACTOR = 0.01F;
    private static final String ALERT_MESSAGE = "This is a PA forceAlert message.";
    private static final String ANCILLARY_MNEMONIC_PA = "SOC_PA_ENCIRCLED_ENERGY";
    private static final String ANCILLARY_MNEMONIC_CAL = "SOC_CAL_BLACK_LEVEL";
    private static final String ANCILLARY_MNEMONIC_PPA = "SOC_PPA_BACKGROUND_LEVEL";
    private static final String[] PSEUDO_TARGET_LISTS = new String[] { "pseudo-target-list" };
    private static final int MAX_ROW_COLUMN_OFFSET = 250;
    private static final int DEFAULT_REFERENCE_COLUMN = 500;
    private static final int DEFAULT_REFERENCE_ROW = 500;
    public static final int SUBTASK_NUMBER = 5;
    public static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pa-matlab-1-1");
    private static final Random RANDOM = new Random(42);
    private static final Float RMS_CDPP = 42.0F;
    private static final float[] TRIAL_TRANSIT_DURATIONS = new float[] { 3.0F,
        6.0F, 12.0F };
    private static final Date now = new Date();
    private static final int QUARTER = 43;
    private static final String QUARTERS = "q" + QUARTER;
    private static final List<String> QUARTERS_LIST = newArrayList(QUARTERS);

    private int debugFlag;

    protected PipelineTask pipelineTask;
    protected PaInputsRetriever paInputsRetriever;
    protected PaOutputsStorer paOutputsStorer;
    private TargetTable targetTable;
    private UnitTestDescriptor unitTestDescriptor;

    private AlertService alertService;
    private BlobOperations blobOperations;
    private ConfigMapOperations configMapOperations;
    private DataAnomalyOperations dataAnomalyOperations;
    private FileStoreClient fsClient;
    private CelestialObjectOperations celestialObjectOperations;
    private KicCrud kicCrud;
    private LogCrud logCrud;
    private MjdToCadence mjdToCadence;
    private MjdToCadence mjdToLongCadence;
    private ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance;
    private PaCrud paCrud;
    private PrfOperations prfOperations;
    private RaDec2PixOperations raDec2PixOperations;
    private ReadNoiseOperations readNoiseOperations;
    private GainOperations gainOperations;
    private LinearityOperations linearityOperations;
    private RollTimeOperations rollTimeOperations;
    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private TpsCrud tpsCrud;
    private QuarterToParameterValueMap tadParameterValues;

    private RollingBandArtifactParameters rollingBandArtifactParameters = new RollingBandArtifactParameters();
    private OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters = new OapAncillaryEngineeringParameters();
    private ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters = new ReactionWheelAncillaryEngineeringParameters();
    private ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters();
    private AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();

    private List<PaPixelTimeSeries> targetPixelTimeSeries = newArrayList();

    AbstractPaPipelineModuleTest() {

        try {
            log.debug(PROP_FILE + ": loading ...");
            PropertiesConfiguration config = new PropertiesConfiguration(
                PROP_FILE);

            debugFlag = config.getInteger("debugFlag", 0);
        } catch (ConfigurationException ce) {
            throw new PipelineException(PROP_FILE + ": failed to load: "
                + ce.getMessage(), ce);
        }
    }

    private void createMockObjects() {

        alertService = mock(AlertService.class);
        blobOperations = mock(BlobOperations.class);
        configMapOperations = mock(ConfigMapOperations.class);
        dataAnomalyOperations = mock(DataAnomalyOperations.class);
        fsClient = mock(FileStoreClient.class);
        celestialObjectOperations = mock(CelestialObjectOperations.class);

        kicCrud = mock(KicCrud.class);
        logCrud = mock(LogCrud.class);
        mjdToCadence = mock(MjdToCadence.class);
        mjdToLongCadence = mock(MjdToCadence.class, "Long Cadence");
        modelMetadataRetrieverPipelineInstance = mock(ModelMetadataRetrieverPipelineInstance.class);
        paCrud = mock(PaCrud.class);
        prfOperations = mock(PrfOperations.class);
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        readNoiseOperations = mock(ReadNoiseOperations.class);
        gainOperations = mock(GainOperations.class);
        linearityOperations = mock(LinearityOperations.class);
        rollTimeOperations = mock(RollTimeOperations.class);
        targetCrud = mock(TargetCrud.class);
        targetSelectionCrud = mock(TargetSelectionCrud.class);
        tpsCrud = mock(TpsCrud.class);
        tadParameterValues = mock(QuarterToParameterValueMap.class);
    }

    private void setMockObjects(PaIoProcessor paInputsRetriever) {
        paInputsRetriever.setBlobOperations(blobOperations);
        paInputsRetriever.setConfigMapOperations(configMapOperations);
        paInputsRetriever.setDataAnomalyOperations(dataAnomalyOperations);
        paInputsRetriever.setCelestialObjectOperations(celestialObjectOperations);
        paInputsRetriever.setLogCrud(logCrud);
        paInputsRetriever.setKicCrud(kicCrud);
        paInputsRetriever.setMjdToCadence(mjdToCadence);
        paInputsRetriever.setMjdToLongCadence(mjdToLongCadence);
        paInputsRetriever.setModelMetadataRetrieverPipelineInstance(modelMetadataRetrieverPipelineInstance);
        paInputsRetriever.setPrfOperations(prfOperations);
        paInputsRetriever.setRaDec2PixOperations(raDec2PixOperations);
        paInputsRetriever.setReadNoiseOperations(readNoiseOperations);
        paInputsRetriever.setGainOperations(gainOperations);
        paInputsRetriever.setLinearityOperations(linearityOperations);
        paInputsRetriever.setRollTimeOperations(rollTimeOperations);
        paInputsRetriever.setTargetCrud(targetCrud);
        paInputsRetriever.setTargetSelectionCrud(targetSelectionCrud);
        paInputsRetriever.setTpsCrud(tpsCrud);
        paInputsRetriever.setTadParameterValues(tadParameterValues);

        FileStoreClientFactory.setInstance(fsClient);
        AlertServiceFactory.setInstance(alertService);
    }

    private void setMockObjects(PaOutputsStorer paOutputsStorer) {
        paOutputsStorer.setDataAnomalyOperations(dataAnomalyOperations);
        paOutputsStorer.setLogCrud(logCrud);
        paOutputsStorer.setMjdToLongCadence(mjdToLongCadence);
        paOutputsStorer.setPaCrud(paCrud);
        paOutputsStorer.setTargetCrud(targetCrud);
        paOutputsStorer.setTadParameterValues(tadParameterValues);

        FileStoreClientFactory.setInstance(fsClient);
        AlertServiceFactory.setInstance(alertService);
    }

    protected void populateObjects() {

        createMockObjects();
        pipelineTask = createPipelineTask(PIPELINE_TASK_ID, CCD_MODULE,
            CCD_OUTPUT, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence());

        paInputsRetriever = new PaInputsRetriever(pipelineTask, CCD_MODULE,
            CCD_OUTPUT);
        setMockObjects(paInputsRetriever);

        paOutputsStorer = new PaOutputsStorer(pipelineTask, CCD_MODULE,
            CCD_OUTPUT);
        setMockObjects(paOutputsStorer);
    }

    protected void createInputs() {

        Set<Pixel> pixelsInUse = newHashSet();
        Set<Long> producerTaskIds = newHashSet();
        int nextTableId = 0;
        long nextTaskId = 1L;

        CadenceType cadenceType = unitTestDescriptor.getCadenceType();
        int startCadence = unitTestDescriptor.getStartCadence();
        int endCadence = unitTestDescriptor.getEndCadence();
        TargetType targetType = TargetType.valueOf(cadenceType);

        TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(this,
            mjdToCadence, cadenceType, startCadence, endCadence);

        targetTable = MockUtils.mockTargetTable(this, targetCrud, targetType,
            nextTableId++);
        MockUtils.mockTargetTableLogs(this, targetCrud, targetType,
            startCadence, endCadence, targetTable);

        Set<FsId> sortedFsIds = newTreeSet();
        List<ObservedTarget> observedTargets = newArrayList();
        if (cadenceType == CadenceType.LONG) {
            List<Set<String>> labels = newArrayListWithExpectedSize(TARGETS_PER_TABLE);
            Set<String> ppaLabels = newHashSetWithExpectedSize(1);
            ppaLabels.add(TargetLabel.PPA_STELLAR.name());
            for (int i = 0; i < PPA_TARGETS_PER_TABLE; i++) {
                labels.add(ppaLabels);
            }
            observedTargets = MockUtils.mockTargets(this, targetCrud,
                celestialObjectOperations, false, targetTable,
                PPA_TARGETS_PER_TABLE, labels, MAX_PIXELS_PER_TARGET,
                CCD_MODULE, CCD_OUTPUT, pixelsInUse, sortedFsIds);

            MockUtils.mockReadFloatTimeSeries(this, fsClient, startCadence,
                endCadence, nextTaskId,
                sortedFsIds.toArray(new FsId[sortedFsIds.size()]), false);
            sortedFsIds.clear();

            producerTaskIds.add(nextTaskId);
            mockRollingBandArtifactFlags(this, fsClient, CCD_MODULE,
                CCD_OUTPUT, cadenceType, startCadence, endCadence,
                observedTargets, new ArrayList<PlannedTarget>(), nextTaskId++);
            if (unitTestDescriptor.isSimulatedTransitsEnabled()) {
                MockUtils.mockCelestialObjectParameters(this,
                    celestialObjectOperations, getKeplerIds(observedTargets),
                    SKY_GROUP_ID);
                mockTpsResults(this, tpsCrud, cadenceTimes,
                    getKeplerIds(observedTargets));
            }
        }

        List<ObservedTarget> stellarObservedTargets = newArrayList();
        if (!unitTestDescriptor.isOnlyProcessPpaTargetsEnabled()) {
            stellarObservedTargets = MockUtils.mockTargets(this, targetCrud,
                celestialObjectOperations, false, targetTable,
                TARGETS_PER_TABLE, new ArrayList<Set<String>>(),
                MAX_PIXELS_PER_TARGET, CCD_MODULE, CCD_OUTPUT, pixelsInUse,
                sortedFsIds);
            observedTargets.addAll(stellarObservedTargets);
        }
        List<Integer> keplerIds = getKeplerIds(observedTargets);

        MockUtils.mockCelestialObjectParameters(this,
            celestialObjectOperations, keplerIds, SKY_GROUP_ID);

        List<PlannedTarget> plannedTargets = null;
        if (cadenceType == CadenceType.LONG
            && unitTestDescriptor.isPseudoTargetListEnabled()) {
            cadenceTimes = MockUtils.mockCadenceTimes(null, null,
                CadenceType.LONG, startCadence, endCadence);
            MockUtils.mockMjdToSeason(this, rollTimeOperations,
                cadenceTimes.startMjd(), OBSERVING_SEASON);
            MockUtils.mockSkyGroupId(this, kicCrud, CCD_MODULE, CCD_OUTPUT,
                OBSERVING_SEASON, SKY_GROUP_ID);
            List<TargetList> targetLists = MockUtils.mockPseudoTargetLists(
                this, targetSelectionCrud, PSEUDO_TARGET_LISTS);
            plannedTargets = MockUtils.mockPlannedTargets(this,
                targetSelectionCrud, TargetType.LONG_CADENCE, targetLists,
                TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
                TARGETS_PER_TABLE, CCD_MODULE, CCD_OUTPUT,
                DEFAULT_REFERENCE_ROW, DEFAULT_REFERENCE_COLUMN,
                MAX_ROW_COLUMN_OFFSET, SKY_GROUP_ID, sortedFsIds);
            MockUtils.mockPlannedTargets(this, celestialObjectOperations,
                plannedTargets);
        }

        producerTaskIds.add(nextTaskId);
        MockUtils.mockReadFloatTimeSeries(this, fsClient, startCadence,
            endCadence, nextTaskId++,
            sortedFsIds.toArray(new FsId[sortedFsIds.size()]), false);

        if (unitTestDescriptor.getCadenceType() == CadenceType.LONG) {

            TargetTable backgroundTargetTable = MockUtils.mockTargetTable(this,
                targetCrud, TargetType.BACKGROUND, nextTableId++);
            MockUtils.mockTargetTableLogs(this, targetCrud,
                TargetType.BACKGROUND, startCadence, endCadence,
                backgroundTargetTable);

            sortedFsIds = newTreeSet();
            MockUtils.mockTargets(this, targetCrud, celestialObjectOperations,
                false, backgroundTargetTable, TARGETS_PER_TABLE,
                MAX_PIXELS_PER_TARGET, CCD_MODULE, CCD_OUTPUT, pixelsInUse,
                sortedFsIds);

            producerTaskIds.add(nextTaskId);
            MockUtils.mockReadFloatTimeSeries(this, fsClient, startCadence,
                endCadence, nextTaskId++,
                sortedFsIds.toArray(new FsId[sortedFsIds.size()]), false);
        } else {
            int startLongCadence = unitTestDescriptor.getStartCadence(CadenceType.LONG);
            int endLongCadence = unitTestDescriptor.getEndCadence(CadenceType.LONG);

            MockUtils.mockShortCadenceToLongCadence(this, logCrud,
                startCadence, endCadence, startLongCadence, endLongCadence);

            MockUtils.mockCadenceTimes(this, mjdToLongCadence,
                CadenceType.LONG, startLongCadence, endLongCadence);
        }

        int startLongCadence = unitTestDescriptor.getStartCadence(CadenceType.LONG);
        int endLongCadence = unitTestDescriptor.getEndCadence(CadenceType.LONG);

        if (cadenceType == CadenceType.SHORT
            || unitTestDescriptor.isSimulatedTransitsEnabled()) {

            producerTaskIds.add(nextTaskId);
            MockUtils.mockBackgroundBlobFileSeries(this, blobOperations,
                CCD_MODULE, CCD_OUTPUT, startLongCadence, endLongCadence,
                nextTaskId++);
        }

        if (cadenceType == CadenceType.SHORT
            || unitTestDescriptor.isSimulatedTransitsEnabled()
            || unitTestDescriptor.isMotionBlobsInputEnabled()) {
            producerTaskIds.add(nextTaskId);
            MockUtils.mockMotionBlobFileSeries(this, blobOperations,
                CCD_MODULE, CCD_OUTPUT, startLongCadence, endLongCadence,
                nextTaskId++);
        }

        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        MockUtils.mockConfigMaps(this, configMapOperations, SC_CONFIG_ID,
            startMjd, endMjd);
        MockUtils.mockPrfModel(this, prfOperations, startMjd, CCD_MODULE,
            CCD_OUTPUT);
        MockUtils.mockRaDec2PixModel(this, raDec2PixOperations, startMjd,
            endMjd);
        MockUtils.mockReadNoiseModel(this, readNoiseOperations, startMjd,
            endMjd);
        MockUtils.mockGainModel(this, gainOperations, startMjd, endMjd);
        MockUtils.mockLinearityModel(this, linearityOperations, CCD_MODULE,
            CCD_OUTPUT, startMjd, endMjd);

        if (unitTestDescriptor.isOapEnabled()) {
            MockUtils.mockAncillaryEngineeringData(this, fsClient,
                oapAncillaryEngineeringParameters.getMnemonics(), startMjd,
                endMjd);
            producerTaskIds.add(nextTaskId);
            MockUtils.mockAncillaryPipelineData(this, fsClient,
                ancillaryPipelineParameters.getMnemonics(), targetTable,
                CCD_MODULE, CCD_OUTPUT, startCadence, endCadence, nextTaskId++);
        }
        MockUtils.mockAncillaryEngineeringData(this, fsClient,
            reactionWheelAncillaryEngineeringParameters.getMnemonics(),
            startMjd, endMjd);
        MockUtils.mockAncillaryEngineeringData(this, fsClient,
            thrusterDataAncillaryEngineeringParameters.getMnemonics(),
            startMjd, endMjd);

        if (unitTestDescriptor.isSimulatedTransitsEnabled()) {
            MockUtils.mockMjdToSeason(this, rollTimeOperations,
                cadenceTimes.startMjd(), OBSERVING_SEASON);
            MockUtils.mockSkyGroupId(this, kicCrud, CCD_MODULE, CCD_OUTPUT,
                OBSERVING_SEASON, SKY_GROUP_ID);
            MockUtils.mockTipBlob(this, modelMetadataRetrieverPipelineInstance,
                blobOperations, TipImporter.MODEL_TYPE, SKY_GROUP_ID, now);
            MockUtils.mockCelestialObjectParameters(this,
                celestialObjectOperations, keplerIds, SKY_GROUP_ID);
            mockTpsResults(this, tpsCrud, cadenceTimes, keplerIds);
        }

        producerTaskIds.add(nextTaskId);
        mockRollingBandArtifactFlags(this, fsClient, CCD_MODULE, CCD_OUTPUT,
            cadenceType, startLongCadence, endLongCadence, observedTargets,
            plannedTargets, nextTaskId++);

        if (!unitTestDescriptor.isError()) {
            producerTaskIds.add(nextTaskId);
            MockUtils.mockCalUncertaintiesBlobSeries(this, blobOperations,
                MATLAB_WORKING_DIR, CCD_MODULE, CCD_OUTPUT, cadenceType,
                startCadence, endCadence, nextTaskId++);
        }

        allowing(tadParameterValues).getQuarter(QUARTERS_LIST, QUARTERS_LIST,
            cadenceType, startCadence, endCadence);
        will(returnValue(QUARTER));
        allowing(tadParameterValues).getValue(QUARTERS_LIST, QUARTERS_LIST,
            cadenceType, startCadence, endCadence);
        will(returnValue(QUARTERS));
    }

    private List<Integer> getKeplerIds(List<ObservedTarget> observedTargets) {

        List<Integer> keplerIds = newArrayList();
        for (ObservedTarget target : observedTargets) {
            keplerIds.add(target.getKeplerId());
        }

        return keplerIds;
    }

    protected void createOutputs(final PaInputs paInputs,
        final PaOutputs paOutputs) throws IOException {

        CadenceType cadenceType = unitTestDescriptor.getCadenceType();
        TargetType targetType = TargetType.valueOf(unitTestDescriptor.getCadenceType());
        boolean coaEnabled = paInputs.getPaModuleParameters()
            .isPaCoaEnabled() && !paInputs.getPaModuleParameters()
            .isOnlyProcessPpaTargetsEnabled()
            && cadenceType == CadenceType.LONG && paInputs.getProcessingState()
                .equals(PaPipelineModule.ProcessingState.TARGETS.toString());

        paOutputs.setProcessingState(paInputs.getProcessingState());

        if ((cadenceType != CadenceType.SHORT || !paInputs.isFirstCall())
            && paInputs.getProcessingState()
                .equals(PaPipelineModule.ProcessingState.TARGETS.toString())) {
            for (PaTarget target : paInputs.getTargets()) {
                targetPixelTimeSeries.addAll(target.getPaPixelTimeSeries());
            }
        }

        if (paInputs.isFirstCall() && !paInputs.getPaModuleParameters()
            .isSimulatedTransitsEnabled()) {
            int[] zeroCrossingIndices = mockZeroCrossings(this, fsClient,
                cadenceType, paInputs.getCcdModule(), paInputs.getCcdOutput(),
                paInputs.getStartCadence(), paInputs.getEndCadence());
            paOutputs.setReactionWheelZeroCrossingIndices(zeroCrossingIndices);
        }

        if (!paInputs.getPaModuleParameters()
            .isSimulatedTransitsEnabled()) {
            if (cadenceType == CadenceType.LONG && paInputs.isFirstCall()) {
                String blobFileName = MockUtils.mockBackgroundBlobFile(this,
                    paCrud, fsClient, MATLAB_WORKING_DIR,
                    paInputs.getCcdModule(), paInputs.getCcdOutput(),
                    paInputs.getStartCadence(), paInputs.getEndCadence(),
                    pipelineTask.getId());
                paOutputs.setBackgroundBlobFileName(blobFileName);

                List<PaPixelCosmicRay> pixelCosmicRays = mockPaPixelCosmicRays(
                    this, fsClient, TargetType.BACKGROUND,
                    paInputs.getCcdModule(), paInputs.getCcdOutput(),
                    paInputs.getStartCadence(), paInputs.getEndCadence(),
                    paInputs.getCadenceTimes(), paInputs.getBackgroundPixels(),
                    pipelineTask.getId(), paInputs.getPaModuleParameters()
                        .isCosmicRayCleaningEnabled());
                paOutputs.setBackgroundCosmicRayEvents(pixelCosmicRays);

                PaCosmicRayMetrics metrics = mockCosmicRayMetrics(this,
                    fsClient, TargetType.BACKGROUND, paInputs.getCcdModule(),
                    paInputs.getCcdOutput(), paInputs.getStartCadence(),
                    paInputs.getEndCadence(), pipelineTask.getId(),
                    paInputs.getPaModuleParameters()
                        .isCosmicRayCleaningEnabled());
                paOutputs.setBackgroundCosmicRayMetrics(metrics);
            } else if (!paInputs.isFirstCall()) {

                FluxType fluxType = unitTestDescriptor.isOapEnabled() ? FluxType.OAP
                    : FluxType.SAP;
                List<PaFluxTarget> paFluxTargets = mockPaFluxTargets(this,
                    fsClient, paCrud, pipelineTask, targetTable, cadenceType,
                    paInputs.getStartCadence(), paInputs.getEndCadence(),
                    pipelineTask.getId(), fluxType, coaEnabled,
                    new HashSet<Integer>(), paInputs.getTargets());
                paOutputs.setFluxTargets(paFluxTargets);

                List<Integer> keplerIds = newArrayList();
                for (PaFluxTarget paFluxTarget : paFluxTargets) {
                    keplerIds.add(paFluxTarget.getKeplerId());
                }
                mockDeleteExistingApertures(this, paCrud, targetTable,
                    keplerIds);
            }
        }

        if (paInputs.isLastCall()
            && !unitTestDescriptor.isSimulatedTransitsEnabled()) {
            if (unitTestDescriptor.isPouEnabled()) {
                String blobFileName = MockUtils.mockPaUncertaintyBlobFile(this,
                    paCrud, fsClient, MATLAB_WORKING_DIR,
                    paInputs.getCcdModule(), paInputs.getCcdOutput(),
                    cadenceType, paInputs.getStartCadence(),
                    paInputs.getEndCadence(), pipelineTask.getId());
                paOutputs.setUncertaintyBlobFileName(blobFileName);
            }

            if (cadenceType == CadenceType.LONG) {
                if (!unitTestDescriptor.isMotionBlobsInputEnabled()) {
                    String blobFileName = MockUtils.mockMotionBlobFile(this,
                        paCrud, fsClient, MATLAB_WORKING_DIR,
                        paInputs.getCcdModule(), paInputs.getCcdOutput(),
                        paInputs.getStartCadence(), paInputs.getEndCadence(),
                        pipelineTask.getId());
                    paOutputs.setMotionBlobFileName(blobFileName);
                }

                if (!unitTestDescriptor.isOnlyProcessPpaTargetsEnabled()) {
                    createMetricTimeSeries(paInputs, paOutputs);
                }
            }

            if (!unitTestDescriptor.isOnlyProcessPpaTargetsEnabled()) {
                List<PaPixelCosmicRay> pixelCosmicRays = mockPaPixelCosmicRays(
                    this, fsClient, targetType, paInputs.getCcdModule(),
                    paInputs.getCcdOutput(), paInputs.getStartCadence(),
                    paInputs.getEndCadence(), paInputs.getCadenceTimes(),
                    targetPixelTimeSeries, pipelineTask.getId(),
                    paInputs.getPaModuleParameters()
                        .isCosmicRayCleaningEnabled());
                paOutputs.setTargetStarCosmicRayEvents(pixelCosmicRays);

                PaCosmicRayMetrics metrics = mockCosmicRayMetrics(this,
                    fsClient, targetType, paInputs.getCcdModule(),
                    paInputs.getCcdOutput(), paInputs.getStartCadence(),
                    paInputs.getEndCadence(), pipelineTask.getId(),
                    paInputs.getPaModuleParameters()
                        .isCosmicRayCleaningEnabled());
                paOutputs.setTargetCosmicRayMetrics(metrics);

                int[] argabrighteningIndices = mockArgabrightening(this,
                    fsClient, targetTable.getExternalId(), cadenceType,
                    paInputs.getCcdModule(), paInputs.getCcdOutput(),
                    paInputs.getStartCadence(), paInputs.getEndCadence());
                paOutputs.setArgabrighteningIndices(argabrighteningIndices);
            }
        }

        if (unitTestDescriptor.isGenerateAlerts()) {
            ModuleAlert alert = new ModuleAlert(Severity.ERROR, ALERT_MESSAGE);
            MockUtils.mockAlert(this, alertService,
                PaPipelineModule.MODULE_NAME, pipelineTask.getId(),
                Severity.ERROR, alert.getMessage() + ": time=0.0");
            paOutputs.setAlerts(Arrays.asList(alert));
        }
    }

    private void createMetricTimeSeries(PaInputs paInputs, PaOutputs paOutputs) {

        List<FsId> fsIds = newArrayList();
        fsIds.add(PaFsIdFactory.getMetricTimeSeriesFsId(
            MetricTimeSeriesType.BRIGHTNESS, paInputs.getCcdModule(),
            paInputs.getCcdOutput()));
        fsIds.add(PaFsIdFactory.getMetricTimeSeriesFsId(
            MetricTimeSeriesType.BRIGHTNESS_UNCERTAINTIES,
            paInputs.getCcdModule(), paInputs.getCcdOutput()));
        fsIds.add(PaFsIdFactory.getMetricTimeSeriesFsId(
            MetricTimeSeriesType.ENCIRCLED_ENERGY, paInputs.getCcdModule(),
            paInputs.getCcdOutput()));
        fsIds.add(PaFsIdFactory.getMetricTimeSeriesFsId(
            MetricTimeSeriesType.ENCIRCLED_ENERGY_UNCERTAINTIES,
            paInputs.getCcdModule(), paInputs.getCcdOutput()));

        FloatTimeSeries[] floatTimeSeries = MockUtils.mockWriteFloatTimeSeries(
            this, fsClient, paInputs.getStartCadence(),
            paInputs.getEndCadence(), PIPELINE_TASK_ID,
            fsIds.toArray(new FsId[0]));

        paOutputs.setBrightnessMetrics(new CompoundFloatTimeSeries(
            floatTimeSeries[0].fseries(), floatTimeSeries[1].fseries(),
            floatTimeSeries[0].getGapIndicators()));
        paOutputs.setEncircledEnergyMetrics(new CompoundFloatTimeSeries(
            floatTimeSeries[2].fseries(), floatTimeSeries[3].fseries(),
            floatTimeSeries[2].getGapIndicators()));
    }

    public void validate(final PaInputs paInputs) {

        assertNotNull(paInputs);
        validateAncillary(paInputs);
        validateBackgroundBlobs(paInputs);
        validateBackgroundPixels(paInputs);
        validateCadenceTimes(paInputs);
        validateCalUncertaintiesBlob(paInputs);
        validateConfigMaps(paInputs);
        validateMotionBlobs(paInputs);
        validateParameters(paInputs);
        validatePrfModel(paInputs);
        validateTargets(paInputs);
    }

    protected void serializeInputs(final PaInputs paInputs)
        throws IllegalAccessException {

        testSerialization(paInputs, new PaInputs(), new File(
            Filenames.BUILD_TMP, getClass().getSimpleName() + "-inputs.bin"));
    }

    protected void serializeOutputs(final PaOutputs paOutputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(paOutputs, new PaOutputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-outputs.bin"));
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

    protected void setUnitTestDescriptor(
        final UnitTestDescriptor unitTestDescriptor) {
        this.unitTestDescriptor = unitTestDescriptor;
    }

    private static UnitOfWorkTask createUowTask(final int ccdModule,
        final int ccdOutput, final int startCadence, final int endCadence) {
        ModOutCadenceUowTask uowTask = new ModOutCadenceUowTask(ccdModule,
            ccdOutput, startCadence, endCadence);

        return uowTask;
    }

    private void mockRollingBandArtifactFlags(JMockTest jMockTest,
        FileStoreClient fsClient, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        List<ObservedTarget> targets, List<PlannedTarget> pseudoTargets,
        long producerTaskId) {

        Set<FsId> intFsIdsSet = newTreeSet();
        Set<FsId> doubleFsIdsSet = newTreeSet();
        Set<FsId> fsIdsSet = newTreeSet();
        Set<Integer> rows = getAllRows(targets, pseudoTargets);
        Set<Integer> durations = PaIoProcessor.getAllDurations(rollingBandArtifactParameters.getTestPulseDurations());
        for (int row : rows) {
            for (int duration : durations) {
                intFsIdsSet.add(DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(
                    ccdModule, ccdOutput, row, duration));
                doubleFsIdsSet.add(DynablackFsIdFactory.getRollingBandArtifactVariationFsId(
                    ccdModule, ccdOutput, row, duration));
            }
        }
        FsId[] intFsIds = intFsIdsSet.toArray(new FsId[intFsIdsSet.size()]);
        FsId[] doubleFsIds = doubleFsIdsSet.toArray(new FsId[doubleFsIdsSet.size()]);

        IntTimeSeries[] intTimeSeriesArray = MockUtils.createIntTimeSeries(
            startCadence, endCadence, producerTaskId, intFsIds);
        Map<FsId, TimeSeries> timeSeriesByFsId = getTimeSeriesByFsId(intTimeSeriesArray);
        DoubleTimeSeries[] doubleTimeSeriesArray = MockUtils.createDoubleTimeSeries(
            startCadence, endCadence, producerTaskId, doubleFsIds);
        timeSeriesByFsId = getTimeSeriesByFsId(timeSeriesByFsId,
            doubleTimeSeriesArray);

        fsIdsSet.addAll(intFsIdsSet);
        fsIdsSet.addAll(doubleFsIdsSet);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeries(fsIdsSet, startCadence, endCadence, false);
            jMockTest.will(returnValue(timeSeriesByFsId));
        }
    }

    private Set<Integer> getAllRows(List<ObservedTarget> targets,
        List<PlannedTarget> pseudoTargets) {

        Set<Integer> rows = newHashSet();
        for (ObservedTarget target : targets) {
            for (TargetDefinition targetDefinition : target.getTargetDefinitions()) {
                int referenceRow = targetDefinition.getReferenceRow();
                Mask mask = targetDefinition.getMask();
                for (Offset offset : mask.getOffsets()) {
                    rows.add(referenceRow + offset.getRow());
                }
            }
        }

        if (pseudoTargets != null) {
            for (PlannedTarget target : pseudoTargets) {
                int referenceRow = target.getAperture()
                    .getReferenceRow();
                for (Offset offset : target.getAperture()
                    .getOffsets()) {
                    rows.add(referenceRow + offset.getRow());
                }
            }
        }

        return rows;
    }

    protected Set<Integer> getAllDurations() {
        return PaIoProcessor.getAllDurations(rollingBandArtifactParameters.getTestPulseDurations());
    }

    private int[] mockArgabrightening(JMockTest jMockTest,
        FileStoreClient fsClient, int targetTableId, CadenceType cadenceType,
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        int length = endCadence - startCadence + 1;
        int[] indices = new int[] { length / 2 };
        int[] iseries = new int[length];
        boolean[] gapIndicators = new boolean[length];

        Arrays.fill(gapIndicators, true);
        for (int index : indices) {
            gapIndicators[index] = false;
            iseries[index] = 1;
        }

        FsId fsId = PaFsIdFactory.getArgabrighteningFsId(cadenceType,
            targetTableId, ccdModule, ccdOutput);
        final IntTimeSeries intTimeSeries = new IntTimeSeries(fsId, iseries,
            startCadence, endCadence, gapIndicators, pipelineTask.getId());

        if (jMockTest != null && fsClient != null) {
            jMockTest.oneOf(fsClient)
                .writeTimeSeries(new IntTimeSeries[] { intTimeSeries });
        }

        return indices;
    }

    private int[] mockZeroCrossings(JMockTest jMockTest,
        FileStoreClient fsClient, CadenceType cadenceType, int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        int length = endCadence - startCadence + 1;
        int[] indices = new int[] { length / 2 };
        int[] iseries = new int[length];
        boolean[] gapIndicators = new boolean[length];

        Arrays.fill(gapIndicators, true);
        for (int index : indices) {
            gapIndicators[index] = false;
            iseries[index] = 1;
        }

        FsId fsId = PaFsIdFactory.getZeroCrossingFsId(cadenceType);
        final IntTimeSeries intTimeSeries = new IntTimeSeries(fsId, iseries,
            startCadence, endCadence, gapIndicators, pipelineTask.getId());

        if (jMockTest != null && fsClient != null) {
            jMockTest.oneOf(fsClient)
                .writeTimeSeries(new IntTimeSeries[] { intTimeSeries });
        }

        return indices;
    }

    private static void mockDeleteExistingApertures(JMockTest jMockTest,
        PaCrud paCrud, TargetTable targetTable, List<Integer> keplerIds) {

        List<TargetAperture> existingApertures = newArrayList();
        if (jMockTest != null && paCrud != null) {
            jMockTest.allowing(paCrud)
                .retrieveTargetApertures(targetTable, CCD_MODULE, CCD_OUTPUT,
                    keplerIds);
            jMockTest.will(returnValue(existingApertures));
            if (!existingApertures.isEmpty()) {
                jMockTest.oneOf(paCrud)
                    .deleteTargetApertures(existingApertures);
            }
        }
    }

    private static List<PaFluxTarget> mockPaFluxTargets(JMockTest jMockTest,
        FileStoreClient fsClient, PaCrud paCrud, PipelineTask pipelineTask,
        TargetTable targetTable, CadenceType cadenceType, int startCadence,
        int endCadence, long producerTaskId, FluxType fluxType,
        boolean coaEnabled, Set<Integer> testPulseDurationsLc,
        List<PaTarget> paTargets) {

        List<PaFluxTarget> paFluxTargets = newArrayList();
        List<FsId> fsIds = newArrayList();
        List<FsId> doubleFsIds = newArrayList();
        Map<FsId, FsId> targetToSourceFsIds = newHashMapWithExpectedSize(paTargets.size() * 4);
        List<TargetAperture> targetApertures = newArrayListWithExpectedSize(paTargets.size());
        for (PaTarget paTarget : paTargets) {
            PaFluxTarget paFluxTarget = new PaFluxTarget(
                paTarget.getKeplerId(), paTarget.getRaHours(),
                paTarget.getDecDegrees(), paTarget.getReferenceRow(),
                paTarget.getReferenceColumn());

            List<FsId> targetFsIds = paFluxTarget.getAllFsIds(fluxType,
                cadenceType, coaEnabled, testPulseDurationsLc);
            List<FsId> prfCentroidFsIds = paFluxTarget.getCentroidsFsIds(
                fluxType, CentroidType.PRF, cadenceType);
            List<FsId> fluxWeightedCentroidFsIds = paFluxTarget.getCentroidsFsIds(
                fluxType, CentroidType.FLUX_WEIGHTED, cadenceType);
            List<FsId> centroidFsIds = null;
            List<FsId> attributeFsIds = paFluxTarget.getAttributeFsIds(
                fluxType, cadenceType, coaEnabled);

            targetFsIds.removeAll(attributeFsIds);
            doubleFsIds.addAll(attributeFsIds);
            boolean reusePrfCentroids = false;
            if (!Arrays.asList(paTarget.getLabels())
                .contains(TargetLabel.PPA_STELLAR)) {
                targetFsIds.removeAll(prfCentroidFsIds);
            } else {
                reusePrfCentroids = true;
                centroidFsIds = centroidValues(prfCentroidFsIds);
                doubleFsIds.addAll(centroidFsIds);
            }
            centroidFsIds = centroidValues(fluxWeightedCentroidFsIds);
            doubleFsIds.addAll(centroidFsIds);

            // update map of target to source FsIds
            centroidFsIds = paFluxTarget.getCentroidsFsIds(fluxType,
                cadenceType);
            targetFsIds.removeAll(centroidFsIds);
            Iterator<FsId> defaultFsIds = centroidFsIds.iterator();
            centroidFsIds = centroidValues(centroidFsIds);
            doubleFsIds.addAll(centroidFsIds);

            centroidFsIds = paFluxTarget.getCentroidsFsIds(cadenceType);
            targetFsIds.removeAll(centroidFsIds);
            Iterator<FsId> originalFsIds = centroidFsIds.iterator();
            centroidFsIds = centroidValues(centroidFsIds);
            doubleFsIds.addAll(centroidFsIds);

            for (FsId sourceFsId : reusePrfCentroids ? prfCentroidFsIds
                : fluxWeightedCentroidFsIds) {
                FsId targetFsId = originalFsIds.next();
                targetToSourceFsIds.put(targetFsId, sourceFsId);
                targetFsId = defaultFsIds.next();
                targetToSourceFsIds.put(targetFsId, sourceFsId);
            }
            targetFsIds.removeAll(doubleFsIds);
            fsIds.addAll(targetFsIds);

            List<PaCentroidPixel> aperturePixelFlags = newArrayListWithExpectedSize(paTarget.getPixels()
                .size());
            List<CentroidPixel> centroidPixels = newArrayListWithExpectedSize(paTarget.getPixels()
                .size());
            for (Pixel pixel : paTarget.getPixels()) {
                PaCentroidPixel pixelFlags = new PaCentroidPixel(
                    pixel.getRow(), pixel.getColumn(),
                    pixel.isInOptimalAperture(), false);
                aperturePixelFlags.add(pixelFlags);
                CentroidPixel centroidPixel = new CentroidPixel(pixel.getRow(),
                    pixel.getColumn(), pixel.isInOptimalAperture(), false);
                centroidPixels.add(centroidPixel);
            }
            paFluxTarget.setPixelAperture(aperturePixelFlags);

            TargetAperture targetAperture = new TargetAperture.Builder(
                pipelineTask, targetTable, paTarget.getKeplerId()).ccdModule(
                CCD_MODULE)
                .ccdOutput(CCD_OUTPUT)
                .pixels(centroidPixels)
                .build();
            targetApertures.add(targetAperture);
            paFluxTargets.add(paFluxTarget);
        }

        final FloatTimeSeries[] floatTimeSeries = MockUtils.mockReadFloatTimeSeries(
            jMockTest, null, startCadence, endCadence, producerTaskId,
            fsIds.toArray(new FsId[fsIds.size()]), false);
        final DoubleTimeSeries[] doubleTimeSeries = MockUtils.mockReadDoubleTimeSeries(
            jMockTest, null, startCadence, endCadence, producerTaskId,
            doubleFsIds.toArray(new FsId[doubleFsIds.size()]), false);

        // copy time series as appropriate
        Map<FsId, TimeSeries> timeSeriesByFsId = newTreeMap();
        timeSeriesByFsId.putAll(TimeSeriesOperations.getTimeSeriesByFsId(floatTimeSeries));
        timeSeriesByFsId.putAll(TimeSeriesOperations.getTimeSeriesByFsId(doubleTimeSeries));
        for (PaFluxTarget paFluxTarget : paFluxTargets) {
            copyTimeSeries(timeSeriesByFsId, targetToSourceFsIds);
            paFluxTarget.setTimeSeries(testPulseDurationsLc, fluxType,
                cadenceType, endCadence - startCadence + 1, timeSeriesByFsId);
        }

        // update array
        final TimeSeries[] timeSeries = new TimeSeries[timeSeriesByFsId.size()];
        Iterator<TimeSeries> values = timeSeriesByFsId.values()
            .iterator();
        for (int i = 0; i < timeSeries.length; i++) {
            timeSeries[i] = values.next();
        }

        log.debug(String.format("timeSeries.length=%d", timeSeries.length));
        if (jMockTest != null && fsClient != null && timeSeries.length > 0) {
            jMockTest.oneOf(fsClient)
                .writeTimeSeries(timeSeries);
        }
        if (jMockTest != null && paCrud != null && !targetApertures.isEmpty()) {
            jMockTest.oneOf(paCrud)
                .createTargetApertures(targetApertures);
        }
        return paFluxTargets;
    }

    private void mockTpsResults(JMockTest jMockTest, TpsCrud tpsCrud,
        TimestampSeries cadenceTimes, List<Integer> keplerIds) {

        List<TpsLiteDbResult> tpsResults = newArrayList();
        for (Integer keplerId : keplerIds) {
            for (float duration : TRIAL_TRANSIT_DURATIONS) {
                tpsResults.add(createTpsLiteDbResult(
                    keplerId,
                    RMS_CDPP,
                    duration,
                    cadenceTimes.cadenceNumbers[0],
                    cadenceTimes.cadenceNumbers[cadenceTimes.cadenceNumbers.length - 1]));
            }
        }

        if (jMockTest != null && tpsCrud != null) {
            jMockTest.allowing(tpsCrud)
                .retrieveAllLatestTpsLiteResults(keplerIds);
            jMockTest.will(returnValue(tpsResults));
        }
    }

    private TpsLiteDbResult createTpsLiteDbResult(Integer keplerId,
        Float rmsCdpp, float duration, int startCadence, int endCadence) {

        return new TpsLiteDbResult(keplerId, duration, new Float(1), rmsCdpp,
            startCadence, endCadence, FluxType.SAP, pipelineTask, Boolean.FALSE);
    }

    private static void copyTimeSeries(Map<FsId, TimeSeries> timeSeriesByFsId,
        Map<FsId, FsId> targetToSourceFsIds) {

        for (Entry<FsId, FsId> fsIds : targetToSourceFsIds.entrySet()) {
            TimeSeries sourceTimeSeries = timeSeriesByFsId.get(fsIds.getValue());
            if (sourceTimeSeries == null) {
                throw new NullPointerException(String.format(
                    "%s missing from time series map", fsIds.getValue()));
            }
            if (sourceTimeSeries.isFloat()) {
                FloatTimeSeries targetTimeSeries = new FloatTimeSeries(
                    fsIds.getKey(),
                    ((FloatTimeSeries) sourceTimeSeries).fseries(),
                    sourceTimeSeries.startCadence(),
                    sourceTimeSeries.endCadence(),
                    sourceTimeSeries.validCadences(),
                    sourceTimeSeries.originators());
                timeSeriesByFsId.put(targetTimeSeries.id(), targetTimeSeries);
            } else {
                DoubleTimeSeries targetTimeSeries = new DoubleTimeSeries(
                    fsIds.getKey(),
                    ((DoubleTimeSeries) sourceTimeSeries).dseries(),
                    sourceTimeSeries.startCadence(),
                    sourceTimeSeries.endCadence(),
                    sourceTimeSeries.validCadences(),
                    sourceTimeSeries.originators());
                timeSeriesByFsId.put(targetTimeSeries.id(), targetTimeSeries);
            }
        }
    }

    private static List<FsId> centroidValues(List<FsId> prfCentroidFsIds) {

        List<FsId> valuesFsIds = newArrayList();
        for (FsId centroidFsId : prfCentroidFsIds) {
            if (!centroidFsId.toString()
                .contains("Uncertainties/")) {
                valuesFsIds.add(centroidFsId);
            }
        }
        return valuesFsIds;
    }

    private static List<PaPixelCosmicRay> createPaPixelCosmicRays(
        final TargetType targetType, final int ccdModule, final int ccdOutput,
        final int startCadence, final int endCadence,
        final TimestampSeries cadenceTimes,
        final List<PaPixelTimeSeries> pixelTimeSeries,
        final Map<PaPixelCosmicRay, FsId> crsFsIdsByPaPixelCosmicRay) {

        List<PaPixelCosmicRay> pixelCosmicRays = newArrayList();
        if (!pixelTimeSeries.isEmpty()) {
            for (int cadence = 0; cadence < endCadence - startCadence + 1; cadence++) {
                PaPixelTimeSeries timeSeries = pixelTimeSeries.get(RANDOM.nextInt(pixelTimeSeries.size()));

                if (cadenceTimes.gapIndicators[cadence]
                    || timeSeries.getGapIndicators()[cadence]) {
                    continue; // hit gap
                }

                int row = timeSeries.getCcdRow();
                int column = timeSeries.getCcdColumn();
                PaPixelCosmicRay paPixelCosmicRay = new PaPixelCosmicRay(row,
                    column, cadenceTimes.midTimestamps[cadence],
                    timeSeries.getValues()[cadence] * COSMIC_RAY_DELTA_FACTOR);
                pixelCosmicRays.add(paPixelCosmicRay);

                FsId crsFsId = PaFsIdFactory.getCosmicRaySeriesFsId(targetType,
                    ccdModule, ccdOutput, row, column);
                crsFsIdsByPaPixelCosmicRay.put(paPixelCosmicRay, crsFsId);
            }
        }

        return pixelCosmicRays;
    }

    private static List<PaPixelCosmicRay> mockPaPixelCosmicRays(
        JMockTest jMockTest, FileStoreClient fsClient, TargetType targetType,
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        TimestampSeries cadenceTimes, List<PaPixelTimeSeries> pixels,
        long originator, boolean cosmicRayCleaningEnabled) {

        Map<PaPixelCosmicRay, FsId> crsFsIdsByPaPixelCosmicRay = newHashMap();
        List<PaPixelCosmicRay> pixelCosmicRays = newArrayList();
        if (cosmicRayCleaningEnabled) {
            pixelCosmicRays = createPaPixelCosmicRays(targetType, ccdModule,
                ccdOutput, startCadence, endCadence, cadenceTimes, pixels,
                crsFsIdsByPaPixelCosmicRay);
        }

        if (jMockTest != null && fsClient != null) {
            List<FloatMjdTimeSeries> cosmicRaySeries = PaOutputsStorer.createCosmicRaySeries(
                ccdModule, ccdOutput, originator, cadenceTimes,
                crsFsIdsByPaPixelCosmicRay, pixelCosmicRays);
            Collection<FsId> cosmicRayFsIds = crsFsIdsByPaPixelCosmicRay.values();
            for (PaPixelTimeSeries pixelTimeSeries : pixels) {
                FsId fsId = PaFsIdFactory.getCosmicRaySeriesFsId(targetType,
                    ccdModule, ccdOutput, pixelTimeSeries.getCcdRow(),
                    pixelTimeSeries.getCcdColumn());
                if (!cosmicRayFsIds.contains(fsId)) {
                    cosmicRaySeries.add(new FloatMjdTimeSeries(fsId,
                        cadenceTimes.startMjd(), cadenceTimes.endMjd(),
                        FloatMjdTimeSeries.EMPTY_MJD,
                        FloatMjdTimeSeries.EMPTY_VALUES, originator));
                }
            }

            final FloatMjdTimeSeries[] floatMjdTimeSeries = cosmicRaySeries.toArray(new FloatMjdTimeSeries[cosmicRaySeries.size()]);
            Arrays.sort(floatMjdTimeSeries,
                new Comparator<FloatMjdTimeSeries>() {
                    @Override
                    public int compare(final FloatMjdTimeSeries o1,
                        final FloatMjdTimeSeries o2) {
                        return o1.id()
                            .compareTo(o2.id());
                    }
                });
            jMockTest.oneOf(fsClient)
                .writeMjdTimeSeries(floatMjdTimeSeries);
        }
        return pixelCosmicRays;
    }

    private static PaCosmicRayMetrics mockCosmicRayMetrics(JMockTest jMockTest,
        FileStoreClient fsClient, TargetType targetType, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, long producerTaskId,
        boolean empty) {

        List<FsId> fsIds = PaCosmicRayMetrics.getFsIds(targetType, ccdModule,
            ccdOutput);
        FloatTimeSeries[] floatTimeSeries = MockUtils.mockWriteFloatTimeSeries(
            jMockTest, fsClient, startCadence, endCadence, producerTaskId,
            fsIds.toArray(new FsId[fsIds.size()]), empty);
        PaCosmicRayMetrics cosmicRayMetrics = new PaCosmicRayMetrics();
        cosmicRayMetrics.setTimeSeries(targetType, ccdModule, ccdOutput,
            TimeSeriesOperations.getFloatTimeSeriesByFsId(floatTimeSeries));
        return cosmicRayMetrics;
    }

    private static void testSerialization(final PaInputs expected,
        final PaInputs actual, final File file) throws IllegalAccessException {

        // Save and read file.
        PersistableUtils.writeBinFile(expected, file);
        PersistableUtils.readBinFile(actual, file);

        // Test.
        ReflectionEquals re = new ReflectionEquals();
        re.excludeField(".*\\.targetStarDataStruct.*\\.pixels");
        re.excludeField(".*\\.targetStarDataStruct.*\\.type");
        re.assertEquals(expected, actual);
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        final PipelineModuleDefinition moduleDefinition,
        final PipelineInstance instance,
        final PipelineDefinitionNode definitionNode) {

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            instance, definitionNode, moduleDefinition);

        ParameterSet parameterSet = new ParameterSet("ancillarydesignmatrix");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new AncillaryDesignMatrixParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            AncillaryDesignMatrixParameters.class, parameterSet);

        if (unitTestDescriptor.isOapEnabled()) {
            oapAncillaryEngineeringParameters = new OapAncillaryEngineeringParameters(
                new String[] { "oapEngineeringMnemonic" },
                ArrayUtils.EMPTY_STRING_ARRAY, new int[] { 1 },
                new float[] { 0.01F }, new float[] { 1.0F });
            ancillaryPipelineParameters = new AncillaryPipelineParameters(
                new String[] { ANCILLARY_MNEMONIC_CAL, ANCILLARY_MNEMONIC_PA,
                    ANCILLARY_MNEMONIC_PPA },
                new String[] { ANCILLARY_MNEMONIC_PA + "|"
                    + ANCILLARY_MNEMONIC_PPA }, new int[] { 1, 1, 1 });
        }
        parameterSet = new ParameterSet("oapancillaryengineering");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            oapAncillaryEngineeringParameters));
        pipelineInstanceNode.putModuleParameterSet(
            OapAncillaryEngineeringParameters.class, parameterSet);

        parameterSet = new ParameterSet("ancillarypipeline");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            ancillaryPipelineParameters));
        pipelineInstanceNode.putModuleParameterSet(
            AncillaryPipelineParameters.class, parameterSet);

        parameterSet = new ParameterSet("aperturemodel");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new ApertureModelParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            ApertureModelParameters.class, parameterSet);

        parameterSet = new ParameterSet("argabrightening");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new ArgabrighteningModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            ArgabrighteningModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("background");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new BackgroundModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            BackgroundModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("paCoa");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new PaCoaModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(PaCoaModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("cosmicray");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new PaCosmicRayParameters()));
        pipelineInstanceNode.putModuleParameterSet(PaCosmicRayParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("encircledenergy");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new EncircledEnergyModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            EncircledEnergyModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("gapfill");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new GapFillModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            GapFillModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("harmonicsid");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new PaHarmonicsIdentificationParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            PaHarmonicsIdentificationParameters.class, parameterSet);

        parameterSet = new ParameterSet("moduleOutputLists");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new ModuleOutputListsParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            ModuleOutputListsParameters.class, parameterSet);

        parameterSet = new ParameterSet("motion");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new MotionModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            MotionModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("paCoa");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new PaCoaModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(PaCoaModuleParameters.class,
            parameterSet);

        PouModuleParameters pouModuleParameters = new PouModuleParameters();
        pouModuleParameters.setPouEnabled(unitTestDescriptor.isPouEnabled());
        parameterSet = new ParameterSet("pou");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            pouModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(PouModuleParameters.class,
            parameterSet);

        PseudoTargetListParameters pseudoTargetListParameters = new PseudoTargetListParameters();
        if (unitTestDescriptor.isPseudoTargetListEnabled()) {
            pseudoTargetListParameters.setTargetListNames(PSEUDO_TARGET_LISTS);
        }
        parameterSet = new ParameterSet("pseudotargetlist");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            pseudoTargetListParameters));
        pipelineInstanceNode.putModuleParameterSet(
            PseudoTargetListParameters.class, parameterSet);

        reactionWheelAncillaryEngineeringParameters = new ReactionWheelAncillaryEngineeringParameters(
            new String[] { "reactionWheelEngineeringMnemonic" },
            ArrayUtils.EMPTY_STRING_ARRAY, new int[] { 1 },
            new float[] { 0.0F }, new float[] { 0.0F });
        parameterSet = new ParameterSet("reactionwheelancillaryengineering");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            reactionWheelAncillaryEngineeringParameters));
        pipelineInstanceNode.putModuleParameterSet(
            ReactionWheelAncillaryEngineeringParameters.class, parameterSet);

        thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters(
            new String[] { "thrusterDataEngineeringMnemonic" },
            ArrayUtils.EMPTY_STRING_ARRAY, new int[] { 1 },
            new float[] { 0.0F }, new float[] { 0.0F });
        parameterSet = new ParameterSet("thrusterdataancillaryengineering");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            thrusterDataAncillaryEngineeringParameters));
        pipelineInstanceNode.putModuleParameterSet(
            ThrusterDataAncillaryEngineeringParameters.class, parameterSet);

        parameterSet = new ParameterSet("saturationsegment");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new SaturationSegmentModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            SaturationSegmentModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("simulatedtransits");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new SimulatedTransitsModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            SimulatedTransitsModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("tad");
        TadParameters tadParameters = new TadParameters();
        tadParameters.setQuarters(QUARTERS);
        tadParameters.setTargetListSetName(QUARTERS);
        tadParameters.setAssociatedLcTargetListSetName(QUARTERS);
        tadParameters.setSupplementalFor(QUARTERS);
        parameterSet.setParameters(new BeanWrapper<Parameters>(tadParameters));
        pipelineInstanceNode.putModuleParameterSet(TadParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("rollingBand");
        rollingBandArtifactParameters = new RollingBandArtifactParameters();
        rollingBandArtifactParameters.setTestPulseDurations(unitTestDescriptor.getTestPulseDurationsLc());
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            rollingBandArtifactParameters));
        pipelineInstanceNode.putModuleParameterSet(
            RollingBandArtifactParameters.class, parameterSet);

        PaModuleParameters paModuleParameters = new PaModuleParameters();
        paModuleParameters.setDebugLevel(debugFlag);
        paModuleParameters.setCosmicRayCleaningEnabled(unitTestDescriptor.isCleanCosmicRays());
        paModuleParameters.setOapEnabled(unitTestDescriptor.isOapEnabled());
        paModuleParameters.setSimulatedTransitsEnabled(unitTestDescriptor.isSimulatedTransitsEnabled());
        paModuleParameters.setOnlyProcessPpaTargetsEnabled(unitTestDescriptor.isOnlyProcessPpaTargetsEnabled());
        paModuleParameters.setMotionBlobsInputEnabled(unitTestDescriptor.isMotionBlobsInputEnabled());
        parameterSet = new ParameterSet("pa");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            paModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(PaModuleParameters.class,
            parameterSet);

        return pipelineInstanceNode;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Photometric Analysis");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PaPipelineModule.class));
        pipelineModuleDefinition.setExeName("pa");

        return pipelineModuleDefinition;
    }

    private PipelineInstance createPipelineInstance(
        final CadenceType cadenceType) {

        PipelineInstance instance = new PipelineInstance();
        instance.setId(INSTANCE_ID);

        ParameterSet parameterSet = new ParameterSet("cadenceType");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(cadenceType)));
        instance.putParameterSet(new ClassWrapper<Parameters>(
            CadenceTypePipelineParameters.class), parameterSet);

        return instance;
    }

    private PipelineTask createPipelineTask(final long pipelineTaskId,
        final int ccdModule, final int ccdOutput, final int startCadence,
        final int endCadence) {

        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance(unitTestDescriptor.getCadenceType());
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            ccdModule, ccdOutput, startCadence, endCadence)));
        task.setPipelineDefinitionNode(definitionNode);

        return task;
    }

    protected void validateAncillary(final PaInputs paInputs) {

        // ancillary data iff first call and oapEnabled
        if (paInputs.isFirstCall()) {
            int mnemonicsCount = 0;
            if (paInputs.getPaModuleParameters()
                .isOapEnabled()) {
                String[] mnemonics = paInputs.getOapAncillaryEngineeringParameters()
                    .getMnemonics();
                if (mnemonics.length > 0) {
                    assertNotNull(paInputs.getAncillaryEngineeringData());
                    mnemonicsCount += mnemonics.length;
                }
                mnemonics = paInputs.getAncillaryPipelineParameters()
                    .getMnemonics();
                if (mnemonics.length > 0) {
                    assertNotNull(paInputs.getAncillaryPipelineData());
                    assertEquals(mnemonics.length,
                        paInputs.getAncillaryPipelineData()
                            .size());
                }
            }
            String[] mnemonics = paInputs.getReactionWheelAncillaryEngineeringParameters()
                .getMnemonics();
            if (mnemonics.length > 0) {
                assertNotNull(paInputs.getAncillaryEngineeringData());
                mnemonicsCount += mnemonics.length;
            }
            mnemonics = paInputs.getThrusterDataAncillaryEngineeringParameters()
                .getMnemonics();
            if (mnemonics.length > 0) {
                assertNotNull(paInputs.getAncillaryEngineeringData());
                mnemonicsCount += mnemonics.length;
            }
            assertEquals(mnemonicsCount, paInputs.getAncillaryEngineeringData()
                .size());
        } else {
            assertEquals(0, paInputs.getAncillaryEngineeringData()
                .size());
            assertEquals(0, paInputs.getAncillaryPipelineData()
                .size());
        }
    }

    protected void validateBackgroundBlobs(final PaInputs paInputs) {

        CadenceType cadenceType = CadenceType.valueOf(paInputs.getCadenceType());
        if ((cadenceType == CadenceType.SHORT || paInputs.getPaModuleParameters()
            .isSimulatedTransitsEnabled())
            && paInputs.isFirstCall()) {
            assertTrue(paInputs.getBackgroundBlobs()
                .getBlobIndices().length > 0);
        } else {
            assertEquals(0, paInputs.getBackgroundBlobs()
                .getBlobIndices().length);
        }
    }

    protected void validateBackgroundPixels(final PaInputs paInputs) {

        CadenceType cadenceType = CadenceType.valueOf(paInputs.getCadenceType());
        if (cadenceType == CadenceType.LONG && paInputs.isFirstCall()) {
            assertTrue(paInputs.getBackgroundPixels()
                .size() > 0);
        } else {
            assertEquals(0, paInputs.getBackgroundPixels()
                .size());
        }
    }

    protected void validateCadenceTimes(final PaInputs paInputs) {

        assertNotNull(paInputs.getCadenceTimes().startTimestamps);
        assertEquals(
            unitTestDescriptor.getEndCadence()
                - unitTestDescriptor.getStartCadence() + 1,
            paInputs.getCadenceTimes().startTimestamps.length);
        assertNotNull(paInputs.getLongCadenceTimes().startTimestamps);

        CadenceType cadenceType = CadenceType.valueOf(paInputs.getCadenceType());
        if (cadenceType == CadenceType.LONG) {
            assertEquals(paInputs.getCadenceTimes(),
                paInputs.getLongCadenceTimes());
        } else {
            assertTrue(!paInputs.getCadenceTimes()
                .equals(paInputs.getLongCadenceTimes()));
            assertEquals(unitTestDescriptor.getEndCadence(CadenceType.LONG)
                - unitTestDescriptor.getStartCadence(CadenceType.LONG) + 1,
                paInputs.getLongCadenceTimes().startTimestamps.length);
        }
    }

    protected void validateCalUncertaintiesBlob(final PaInputs paInputs) {

        if (paInputs.isFirstCall()) {
            assertTrue(paInputs.getCalUncertaintyBlobs()
                .getBlobIndices().length > 0);
        } else {
            assertEquals(0, paInputs.getCalUncertaintyBlobs()
                .getBlobIndices().length);
        }
    }

    protected void validateConfigMaps(final PaInputs paInputs) {

        assertTrue(paInputs.getConfigMaps()
            .size() > 0);
        assertEquals(SC_CONFIG_ID, paInputs.getConfigMaps()
            .get(0)
            .getId());
        assertEquals(paInputs.getCadenceTimes()
            .startMjd(), paInputs.getConfigMaps()
            .get(0)
            .getTime());
    }

    protected void validateMotionBlobs(final PaInputs paInputs) {

        CadenceType cadenceType = CadenceType.valueOf(paInputs.getCadenceType());
        if ((cadenceType == CadenceType.SHORT
            || paInputs.getPaModuleParameters()
                .isSimulatedTransitsEnabled() || paInputs.getPaModuleParameters()
            .isMotionBlobsInputEnabled())
            && paInputs.isFirstCall()) {
            assertTrue(paInputs.getMotionBlobs()
                .getBlobIndices().length > 0);
        } else {
            assertEquals(0, paInputs.getMotionBlobs()
                .getBlobIndices().length);
        }
    }

    protected void validateParameters(final PaInputs paInputs) {

        assertNotNull(paInputs.getAncillaryDesignMatrixParameters());
        assertNotNull(paInputs.getArgabrighteningModuleParameters());
        assertNotNull(paInputs.getBackgroundModuleParameters());
        assertNotNull(paInputs.getPaCosmicRayParameters());
        assertNotNull(paInputs.getEncircledEnergyModuleParameters());
        assertNotNull(paInputs.getGapFillModuleParameters());
        assertNotNull(paInputs.getMotionModuleParameters());
        assertNotNull(paInputs.getOapAncillaryEngineeringParameters());
        assertNotNull(paInputs.getPaModuleParameters());
        assertNotNull(paInputs.getPouModuleParameters());
        assertNotNull(paInputs.getReactionWheelAncillaryEngineeringParameters());
        assertNotNull(paInputs.getSaturationSegmentModuleParameters());
    }

    protected void validatePrfModel(final PaInputs paInputs) {

        assertEquals(CCD_MODULE, paInputs.getPrfModel()
            .getCcdModule());
        assertEquals(CCD_OUTPUT, paInputs.getPrfModel()
            .getCcdOutput());
    }

    protected void validateTargets(final PaInputs paInputs) {

        assertNotNull(paInputs.getTargets());
        assertNotNull(paInputs.getProcessingState());
        assertTrue(paInputs.getProcessingState()
            .length() > 0);
        PaPipelineModule.ProcessingState state = PaPipelineModule.ProcessingState.valueOf(paInputs.getProcessingState());
        if (state == PaPipelineModule.ProcessingState.BACKGROUND
            || state == PaPipelineModule.ProcessingState.GENERATE_MOTION_POLYNOMIALS
            || state == PaPipelineModule.ProcessingState.AGGREGATE_RESULTS) {
            assertEquals(0, paInputs.getTargets()
                .size());
        } else {
            assertTrue(paInputs.getTargets()
                .size() > 0);
            for (PaTarget target : paInputs.getTargets()) {
                assertNotNull(target.getPaPixelTimeSeries());
                for (PaPixelTimeSeries pixelTimeSeries : target.getPaPixelTimeSeries()) {
                    assertEquals(unitTestDescriptor.getEndCadence()
                        - unitTestDescriptor.getStartCadence() + 1,
                        pixelTimeSeries.size());
                }
            }
        }
    }

}
