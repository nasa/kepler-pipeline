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

package gov.nasa.kepler.pdc;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.mc.TransitParameter;
import gov.nasa.kepler.hibernate.pdc.CbvBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DiscontinuityParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.PdcBand;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PseudoTargetListParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.TransitOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.collections.map.DefaultedMap;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;

/**
 * PDC unit test functionality. Unit tests are contained in a subclass,
 * {@link PdcPipelineModuleTest}.
 * 
 * @author Forrest Girouard
 */
public abstract class AbstractPdcPipelineModuleTest extends JMockTest {

    private static final Log log = LogFactory.getLog(AbstractPdcPipelineModuleTest.class);

    private static final String PROPERTIES_FILE = Filenames.ETC
        + FilenameConstants.KEPLER_CONFIG;
    private static final int EXE_TIMEOUT_SECS = 60;
    private static final long INSTANCE_ID = 42;
    private static final long PIPELINE_TASK_ID = INSTANCE_ID * 3;
    protected static final int CCD_MODULE = 12;
    protected static final int CCD_OUTPUT = 3;
    private static final int TABLE_ID = 1;
    private static final int MAX_PIXELS_PER_TARGET = 32;
    private static final int TARGETS_PER_TABLE = 2;
    private static final String ANCILLARY_MNEMONIC_ENGINEERING = "engineeringMnemonic";
    private static final String THRUSTER_ANCILLARY_MNEMONIC_ENGINEERING = "thrusterEngineeringMnemonic";
    private static final String ANCILLARY_MNEMONIC_PA = "SOC_PA_ENCIRCLED_ENERGY";
    private static final String ANCILLARY_MNEMONIC_CAL = "SOC_CAL_BLACK_LEVEL";
    private static final String ANCILLARY_MNEMONIC_PPA = "SOC_PPA_BACKGROUND_LEVEL";
    private static final long ANCILLARY_TASK_ID = 2;
    private static final long FLOAT_TIME_SERIES_ID = 3;
    private static final long DOUBLE_TIME_SERIES_ID = 4;
    private static final long MOTION_BLOB_ID = 5;
    private static final long PDC_BLOB_ID = 6;
    private static final long CBV_BLOB_ID = 7;
    private static final int SC_CONFIG_ID = 11;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final int OBSERVING_SEASON = 2;
    private static final int SKY_GROUP_ID = 67;
    private static final String PRIOR_FIT_TYPE = "prior";
    private static final String REGULAR_METHOD = "regularMap";
    private static final String MAT_FILE_EXTENSION = ".mat";
    private static final String[] PSEUDO_TARGET_LISTS = new String[] { "pseudo-target-list" };
    private static final int MAX_ROW_COLUMN_OFFSET = 250;
    private static final int DEFAULT_REFERENCE_COLUMN = 500;
    private static final int DEFAULT_REFERENCE_ROW = 500;
    static final File MATLAB_WORKING_DIR = new File(Filenames.BUILD_TEST,
        "pdc-matlab-1-1");

    private String quarter = "3";
    private List<String> quartersList = newArrayList(quarter);

    private boolean value = true;
    private List<Boolean> values = newArrayList(value);

    private static final String ALERT_MESSAGE = "PDC alert test message.";

    private final Set<Long> producerTaskIds = newHashSet();

    private AlertService alertService;
    private AncillaryOperations ancillaryOperations;
    private BlobOperations blobOperations;
    private CelestialObjectOperations celestialObjectOperations;
    private ConfigMapOperations configMapOperations;
    private DataAnomalyOperations dataAnomalyOperations;
    private LogCrud logCrud;
    private KicCrud kicCrud;
    private MjdToCadence mjdToCadence;
    private MjdToCadence mjdToLongCadence;
    private ObservingLogModel observingLogModel;
    private PdcCrud pdcCrud;
    private RaDec2PixOperations raDec2PixOperations;
    private RollTimeOperations rollTimeOperations;
    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private QuarterToParameterValueMap parameterValues;
    private FileStoreClient fsClient;
    private TransitOperations transitOperations;

    private AncillaryEngineeringParameters ancillaryEngineeringParameters = new AncillaryEngineeringParameters();
    private ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters();
    private AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private PdcInputsRetriever pdcInputsRetriever = new PdcInputsRetriever();
    private PdcOutputsStorer pdcOutputsStorer = new PdcOutputsStorer();

    private File matlabWorkingDir;

    private UnitTestDescriptor unitTestDescriptor;
    private double startMjd;
    private double endMjd;

    private Integer debugLevel;

    public AbstractPdcPipelineModuleTest() {
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

    protected PdcInputsRetriever getPdcInputsRetriever() {
        return pdcInputsRetriever;
    }

    protected PdcOutputsStorer getPdcOutputsStorer() {
        return pdcOutputsStorer;
    }

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    protected void setUnitTestDescriptor(UnitTestDescriptor unitTestDescriptor) {
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

    protected void serializeInputs(final PdcInputs pdcInputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(pdcInputs, new PdcInputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-inputs.bin"));
    }

    protected void serializeOutputs(PdcOutputs pdcOutputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(pdcOutputs, new PdcOutputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-outputs.bin"));
    }

    protected void populateObjects() {
        createMockObjects();
        setMockObjects(getPdcInputsRetriever());
        setMockObjects(getPdcOutputsStorer());

        pipelineTask = createPipelineTask(unitTestDescriptor.getCadenceType(),
            CCD_MODULE, CCD_OUTPUT, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence());
        pipelineInstance = pipelineTask.getPipelineInstance();

        setMatlabWorkingDir(MATLAB_WORKING_DIR);
    }

    private void createMockObjects() {
        alertService = mock(AlertService.class);
        ancillaryOperations = mock(AncillaryOperations.class);
        blobOperations = mock(BlobOperations.class);
        celestialObjectOperations = mock(CelestialObjectOperations.class);
        configMapOperations = mock(ConfigMapOperations.class);
        dataAnomalyOperations = mock(DataAnomalyOperations.class);
        logCrud = mock(LogCrud.class);
        kicCrud = mock(KicCrud.class);
        mjdToCadence = mock(MjdToCadence.class);
        mjdToLongCadence = mock(MjdToCadence.class, "Long Cadence");
        pdcCrud = mock(PdcCrud.class);
        observingLogModel = mock(ObservingLogModel.class);
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        rollTimeOperations = mock(RollTimeOperations.class);
        targetCrud = mock(TargetCrud.class);
        targetSelectionCrud = mock(TargetSelectionCrud.class);
        transitOperations = mock(TransitOperations.class);
        parameterValues = mock(QuarterToParameterValueMap.class);

        fsClient = mock(FileStoreClient.class);
        FileStoreClientFactory.setInstance(fsClient);
        AlertServiceFactory.setInstance(alertService);
    }

    private void setMockObjects(PdcInputsRetriever pdcInputsRetriever) {
        pdcInputsRetriever.setAncillaryOperations(ancillaryOperations);
        pdcInputsRetriever.setBlobOperations(blobOperations);
        pdcInputsRetriever.setCelestialObjectOperations(celestialObjectOperations);
        pdcInputsRetriever.setConfigMapOperations(configMapOperations);
        pdcInputsRetriever.setDataAnomalyOperations(dataAnomalyOperations);
        pdcInputsRetriever.setLogCrud(logCrud);
        pdcInputsRetriever.setKicCrud(kicCrud);
        pdcInputsRetriever.setMjdToCadence(mjdToCadence);
        pdcInputsRetriever.setMjdToLongCadence(mjdToLongCadence);
        pdcInputsRetriever.setObservingLogModel(observingLogModel);
        pdcInputsRetriever.setRaDec2PixOperations(raDec2PixOperations);
        pdcInputsRetriever.setRollTimeOperations(rollTimeOperations);
        pdcInputsRetriever.setTargetCrud(targetCrud);
        pdcInputsRetriever.setTargetSelectionCrud(targetSelectionCrud);
        pdcInputsRetriever.setTransitOperations(transitOperations);
        pdcInputsRetriever.setParameterValues(parameterValues);
    }

    private void setMockObjects(PdcOutputsStorer pdcOutputsStorer) {
        pdcOutputsStorer.setDataAnomalyOperations(dataAnomalyOperations);
        pdcOutputsStorer.setLogCrud(logCrud);
        pdcOutputsStorer.setMjdToCadence(mjdToCadence);
        pdcOutputsStorer.setMjdToLongCadence(mjdToLongCadence);
        pdcOutputsStorer.setPdcCrud(pdcCrud);
        pdcOutputsStorer.setTargetCrud(targetCrud);
    }

    protected void createInputs() {
        TargetType targetType = TargetType.valueOf(unitTestDescriptor.getCadenceType());
        int startCadence = unitTestDescriptor.getStartCadence();
        int endCadence = unitTestDescriptor.getEndCadence();
        int longStartCadence = unitTestDescriptor.getStartCadence(CadenceType.LONG);
        int longEndCadence = unitTestDescriptor.getEndCadence(CadenceType.LONG);

        mockParameterValues(this, parameterValues);
        mockTransitOperations(this);
        TargetTable targetTable = MockUtils.mockTargetTable(this, targetCrud,
            targetType, TABLE_ID);
        MockUtils.mockTargetTableLogs(this, targetCrud, targetType,
            startCadence, endCadence, targetTable);
        mockObservingSeason(this, targetTable);

        MockUtils.mockCadenceTimes(this, mjdToCadence,
            unitTestDescriptor.getCadenceType(), startCadence, endCadence);
        PdcTimestampSeries cadenceTimes = PdcMockUtils.mockPdcCadenceTimes(
            this, rollTimeOperations, mjdToCadence, observingLogModel,
            OBSERVING_SEASON, TABLE_ID, unitTestDescriptor.getCadenceType(),
            startCadence, endCadence);

        if (unitTestDescriptor.getCadenceType() == CadenceType.SHORT) {
            MockUtils.mockCadenceTimes(this, mjdToLongCadence,
                CadenceType.LONG, longStartCadence, longEndCadence);
            PdcMockUtils.mockPdcCadenceTimes(this, rollTimeOperations,
                mjdToLongCadence, observingLogModel, OBSERVING_SEASON,
                TABLE_ID, CadenceType.LONG, longStartCadence, longEndCadence);
        }

        if (unitTestDescriptor.getCadenceType() == CadenceType.SHORT) {
            mockShortCadenceToLongCadence(this, logCrud);

            MockUtils.mockPdcBlobFileSeries(this, blobOperations, CCD_MODULE,
                CCD_OUTPUT, CadenceType.LONG, longStartCadence, longEndCadence,
                PDC_BLOB_ID);
            producerTaskIds.add(PDC_BLOB_ID);
        } else if (unitTestDescriptor.getUseBasisVectorsFromBlob() != null
            && unitTestDescriptor.getUseBasisVectorsFromBlob().length > 0) {
            for (boolean useBasisVectorsFromBlob : unitTestDescriptor.getUseBasisVectorsFromBlob()) {
                if (useBasisVectorsFromBlob) {
                    MockUtils.mockCbvBlobFileSeries(this, blobOperations,
                        CCD_MODULE, CCD_OUTPUT, CadenceType.LONG, startCadence,
                        endCadence, CBV_BLOB_ID);
                    producerTaskIds.add(CBV_BLOB_ID);
                    break;
                }
            }
        }

        startMjd = cadenceTimes.startMjd();
        endMjd = cadenceTimes.endMjd();

        MockUtils.mockRaDec2PixModel(this, raDec2PixOperations, startMjd,
            endMjd);

        MockUtils.mockMotionBlobFileSeries(this, blobOperations, CCD_MODULE,
            CCD_OUTPUT, longStartCadence, longEndCadence, MOTION_BLOB_ID);
        producerTaskIds.add(MOTION_BLOB_ID);

        MockUtils.mockConfigMaps(this, configMapOperations, SC_CONFIG_ID,
            startMjd, endMjd);

        MockUtils.mockAncillaryEngineeringData(this, ancillaryOperations,
            startMjd, endMjd, ancillaryEngineeringParameters.getMnemonics());
        MockUtils.mockAncillaryEngineeringData(this, ancillaryOperations,
            startMjd, endMjd,
            thrusterDataAncillaryEngineeringParameters.getMnemonics());

        MockUtils.mockAncillaryPipelineData(this, ancillaryOperations,
            ancillaryPipelineParameters.getMnemonics(), targetTable,
            CCD_MODULE, CCD_OUTPUT, cadenceTimes, ANCILLARY_TASK_ID);
        if (ancillaryPipelineParameters.getMnemonics().length > 0) {
            producerTaskIds.add(ANCILLARY_TASK_ID);
        }

        List<ObservedTarget> observedTargets = MockUtils.mockTargets(this,
            targetCrud, celestialObjectOperations, false, targetTable,
            TARGETS_PER_TABLE, MAX_PIXELS_PER_TARGET, CCD_MODULE, CCD_OUTPUT,
            new HashSet<Pixel>(), new HashSet<FsId>());

        List<FsId> floatFsIds = newArrayList();
        List<FsId> doubleFsIds = newArrayList();
        for (ObservedTarget target : observedTargets) {
            floatFsIds.addAll(PdcTarget.getFluxFloatTimeSeriesFsIds(FLUX_TYPE,
                unitTestDescriptor.getCadenceType(), target.getKeplerId()));
        }

        MockUtils.mockReadFloatTimeSeries(this, fsClient, startCadence,
            endCadence, FLOAT_TIME_SERIES_ID, floatFsIds.toArray(new FsId[0]),
            false, true);
        producerTaskIds.add(FLOAT_TIME_SERIES_ID);

        if (doubleFsIds.size() > 0) {
            MockUtils.mockReadDoubleTimeSeries(this, fsClient, startCadence,
                endCadence, DOUBLE_TIME_SERIES_ID,
                doubleFsIds.toArray(new FsId[0]));
            producerTaskIds.add(DOUBLE_TIME_SERIES_ID);
        }

        if (unitTestDescriptor.isPseudoTargetListEnabled()
            && unitTestDescriptor.getCadenceType() == CadenceType.LONG) {
            MockUtils.mockMjdToSeason(this, rollTimeOperations, startMjd,
                OBSERVING_SEASON);
            MockUtils.mockSkyGroupId(this, kicCrud, CCD_MODULE, CCD_OUTPUT,
                OBSERVING_SEASON, SKY_GROUP_ID);
            List<TargetList> targetLists = MockUtils.mockPseudoTargetLists(
                this, targetSelectionCrud, PSEUDO_TARGET_LISTS);
            List<PlannedTarget> plannedTargets = MockUtils.mockPlannedTargets(
                this, targetSelectionCrud, TargetType.LONG_CADENCE,
                targetLists,
                TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
                TARGETS_PER_TABLE, CCD_MODULE, CCD_OUTPUT,
                DEFAULT_REFERENCE_ROW, DEFAULT_REFERENCE_COLUMN,
                MAX_ROW_COLUMN_OFFSET, SKY_GROUP_ID, new TreeSet<FsId>());
            MockUtils.mockPlannedTargets(this, celestialObjectOperations,
                plannedTargets);

            floatFsIds = newArrayList();
            doubleFsIds = newArrayList();
            for (PlannedTarget target : plannedTargets) {
                floatFsIds.addAll(PdcTarget.getFluxFloatTimeSeriesFsIds(
                    FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                    target.getKeplerId()));
            }

            MockUtils.mockReadFloatTimeSeries(this, fsClient, startCadence,
                endCadence, FLOAT_TIME_SERIES_ID,
                floatFsIds.toArray(new FsId[0]), false, true);
            producerTaskIds.add(FLOAT_TIME_SERIES_ID);

            if (doubleFsIds.size() > 0) {
                MockUtils.mockReadDoubleTimeSeries(this, fsClient,
                    startCadence, endCadence, DOUBLE_TIME_SERIES_ID,
                    doubleFsIds.toArray(new FsId[0]));
                producerTaskIds.add(DOUBLE_TIME_SERIES_ID);
            }
        }
    }

    void validate(PdcInputs pdcInputs) {

        assertNotNull(pdcInputs);
        assertEquals(unitTestDescriptor.getStartCadence(),
            pdcInputs.getStartCadence());
        assertEquals(
            unitTestDescriptor.getEndCadence(unitTestDescriptor.getCadenceType()),
            pdcInputs.getEndCadence());
        assertEquals(unitTestDescriptor.getCadenceType()
            .toString(), pdcInputs.getCadenceType());

        validate(pdcInputs.getAncillaryEngineeringParameters(),
            pdcInputs.getThrusterDataAncillaryEngineeringParameters(),
            pdcInputs.getAncillaryEngineeringData());
        assertNotNull(pdcInputs.getAncillaryDesignMatrixParameters());
        validate(pdcInputs.getCadenceTimes());
        assertNotNull(pdcInputs.getDiscontinuityParameters());
        assertNotNull(pdcInputs.getGapFillModuleParameters());
        assertNotNull(pdcInputs.getHarmonicsIdentificationParameters());
        assertNotNull(pdcInputs.getPdcGoodnessMetricParameters());
        assertNotNull(pdcInputs.getPdcMapParameters());
        assertNotNull(pdcInputs.getPdcModuleParameters());
        assertNotNull(pdcInputs.getSaturationSegmentParameters());
        assertNotNull(pdcInputs.getSpsdDetectionParameters());
        assertNotNull(pdcInputs.getSpsdDetectorParameters());
        assertNotNull(pdcInputs.getSpsdRemovalParameters());
        assertNotNull(pdcInputs.getSpacecraftConfigMap());
        assertTrue(pdcInputs.getSpacecraftConfigMap()
            .size() > 0);

        assertNotNull(pdcInputs.getChannelData());
        assertEquals(1, pdcInputs.getChannelData()
            .size());
        PdcInputChannelData pdcInputChannelData = pdcInputs.getChannelData()
            .get(0);
        assertEquals(CCD_MODULE, pdcInputChannelData.getCcdModule());
        assertEquals(CCD_OUTPUT, pdcInputChannelData.getCcdOutput());
        validate(pdcInputs.getAncillaryPipelineParameters(),
            pdcInputChannelData.getAncillaryPipelineData());
        validateTargets(pdcInputChannelData.getTargetData());
    }

    private void validate(
        AncillaryEngineeringParameters ancillaryEngineeringParameters,
        ThrusterDataAncillaryEngineeringParameters thrusterAncillaryEngineeringParameters,
        List<AncillaryEngineeringData> ancillaryEngineeringData) {

        validate(ancillaryEngineeringParameters);
        validate(thrusterAncillaryEngineeringParameters);

        assertNotNull(ancillaryEngineeringData);
        assertEquals(ancillaryEngineeringParameters.getMnemonics().length
            + thrusterAncillaryEngineeringParameters.getMnemonics().length,
            ancillaryEngineeringData.size());
    }

    private void validate(
        AncillaryEngineeringParameters ancillaryEngineeringParameters) {
        assertNotNull(ancillaryEngineeringParameters);
        assertTrue(ancillaryEngineeringParameters.getMnemonics().length == 1);
        assertEquals(ancillaryEngineeringParameters.getMnemonics().length,
            ancillaryEngineeringParameters.getIntrinsicUncertainties().length);
        assertEquals(ancillaryEngineeringParameters.getMnemonics().length,
            ancillaryEngineeringParameters.getModelOrders().length);
        assertEquals(ancillaryEngineeringParameters.getMnemonics().length,
            ancillaryEngineeringParameters.getQuantizationLevels().length);
    }

    private void validate(
        AncillaryPipelineParameters ancillaryPipelineParameters,
        List<AncillaryPipelineData> ancillaryPipelineData) {

        assertNotNull(ancillaryPipelineParameters);
        assertTrue(ancillaryPipelineParameters.getMnemonics().length == 3);
        assertEquals(ancillaryPipelineParameters.getMnemonics().length,
            ancillaryPipelineParameters.getModelOrders().length);

        assertNotNull(ancillaryPipelineData);
        assertEquals(ancillaryPipelineParameters.getMnemonics().length,
            ancillaryPipelineData.size());
    }

    private void validateTargets(List<PdcTarget> targets) {

        assertNotNull(targets);
        int length = unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1;
        int targetCount = TARGETS_PER_TABLE;
        if (unitTestDescriptor.isPseudoTargetListEnabled()
            && unitTestDescriptor.getCadenceType() == CadenceType.LONG) {
            targetCount += TARGETS_PER_TABLE;
        }
        assertEquals(targetCount, targets.size());
        for (PdcTarget target : targets) {
            assertTrue(!target.isEmpty());
            assertTrue(!target.isAllGaps());
            assertNotNull(target.getGapIndicators());
            assertEquals(length, target.getGapIndicators().length);
            assertNotNull(target.getUncertainties());
            assertEquals(length, target.getUncertainties().length);
            assertNotNull(target.getValues());
            assertEquals(length, target.getValues().length);
            assertTrue(target.getKeplerMag() > 0.0);
            assertTrue(target.getKeplerId() >= 0);
        }
    }

    private void validate(TimestampSeries cadenceTimes) {

        assertNotNull(cadenceTimes);
        assertNotNull(cadenceTimes.cadenceNumbers);
        assertNotNull(cadenceTimes.startTimestamps);
        assertNotNull(cadenceTimes.midTimestamps);
        assertNotNull(cadenceTimes.endTimestamps);

        int length = unitTestDescriptor.getEndCadence(unitTestDescriptor.getCadenceType())
            - unitTestDescriptor.getStartCadence() + 1;
        assertEquals(unitTestDescriptor.getStartCadence(),
            cadenceTimes.cadenceNumbers[0]);
        assertEquals(
            unitTestDescriptor.getEndCadence(unitTestDescriptor.getCadenceType()),
            cadenceTimes.cadenceNumbers[length - 1]);

        assertEquals(length, cadenceTimes.cadenceNumbers.length);
        assertEquals(length, cadenceTimes.startTimestamps.length);
        assertEquals(length, cadenceTimes.midTimestamps.length);
        assertEquals(length, cadenceTimes.endTimestamps.length);
    }

    void createOutputs(PdcInputs pdcInputs, PdcOutputs pdcOutputs)
        throws IOException {
        pdcOutputs.setCadenceType(pdcInputs.getCadenceType());
        pdcOutputs.setEndCadence(pdcInputs.getEndCadence());
        pdcOutputs.setStartCadence(pdcInputs.getStartCadence());
        pdcOutputs.setTargetResultsStruct(createTargetResults(pdcInputs));

        PdcOutputChannelData pdcOutputChannelData = new PdcOutputChannelData();
        pdcOutputChannelData.setCcdModule(pdcInputs.getChannelData()
            .get(0)
            .getCcdModule());
        pdcOutputChannelData.setCcdOutput(pdcInputs.getChannelData()
            .get(0)
            .getCcdOutput());
        if (unitTestDescriptor.isMapEnabled()
            && CadenceType.valueOf(pdcInputs.getCadenceType()) == CadenceType.LONG) {
            pdcOutputChannelData.setPdcBlobFileName(createPdcBlob(
                CadenceType.valueOf(pdcInputs.getCadenceType()),
                pdcInputs.getStartCadence(), pdcInputs.getEndCadence()));
            pdcOutputChannelData.setCbvBlobFileName(createCbvBlob(
                unitTestDescriptor.getCadenceType(),
                pdcInputs.getStartCadence(), pdcInputs.getEndCadence()));
        }
        pdcOutputs.getChannelData()
            .add(pdcOutputChannelData);
        pdcOutputs.setAlerts(createAlerts());
    }

    private List<PdcTargetOutputData> createTargetResults(PdcInputs pdcInputs) {

        List<PdcTargetOutputData> outputTargets = newArrayList();
        List<TimeSeries> timeSeriesList = newArrayList();
        List<FloatMjdTimeSeries> mjdTimeSeriesList = newArrayList();

        for (PdcTarget pdcTarget : pdcInputs.getChannelData()
            .get(0)
            .getTargetData()) {
            FsId valuesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX, FLUX_TYPE,
                unitTestDescriptor.getCadenceType(), pdcTarget.getKeplerId());
            FsId uncertaintiesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
                FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                pdcTarget.getKeplerId());
            FsId filledFsId = PdcFsIdFactory.getFilledIndicesFsId(
                PdcFilledIndicesTimeSeriesType.FILLED_INDICES, FLUX_TYPE,
                unitTestDescriptor.getCadenceType(), pdcTarget.getKeplerId());
            CorrectedFluxTimeSeries correctedFlux = createCorrectedFluxTimeSeries(
                valuesFsId, uncertaintiesFsId, filledFsId, timeSeriesList);

            valuesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX,
                FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                pdcTarget.getKeplerId());
            uncertaintiesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX_UNCERTAINTIES,
                FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                pdcTarget.getKeplerId());
            filledFsId = PdcFsIdFactory.getFilledIndicesFsId(
                PdcFilledIndicesTimeSeriesType.HARMONIC_FREE_FILLED_INDICES,
                FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                pdcTarget.getKeplerId());
            CorrectedFluxTimeSeries harmonicFreeCorrectedFlux = createCorrectedFluxTimeSeries(
                valuesFsId, uncertaintiesFsId, filledFsId, timeSeriesList);

            FsId discontinuitiesFsId = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                pdcTarget.getKeplerId());
            int[] discontinuities = createDiscontinuitiesTimeSeries(
                discontinuitiesFsId, timeSeriesList);

            PdcProcessingCharacteristics pdcProcessingCharacteristics = createPdcProcessingCharacteristics(pdcTarget.getKeplerId());

            PdcGoodnessMetric pdcGoodnessMetric = createPdcGoodnessMetric(
                pdcTarget.getKeplerId(), correctedFlux.getGapIndicators(),
                timeSeriesList);

            OutliersTimeSeries outliers = new OutliersTimeSeries();
            mjdTimeSeriesList.addAll(outliers.toTimeSeries(
                PdcFsIdFactory.getOutlierTimerSeriesId(
                    PdcOutliersTimeSeriesType.OUTLIERS, FLUX_TYPE,
                    unitTestDescriptor.getCadenceType(),
                    pdcTarget.getKeplerId()),
                PdcFsIdFactory.getOutlierTimerSeriesId(
                    PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES, FLUX_TYPE,
                    unitTestDescriptor.getCadenceType(),
                    pdcTarget.getKeplerId()), pdcInputs.getStartCadence(),
                startMjd, endMjd, PIPELINE_TASK_ID, null));

            OutliersTimeSeries harmonicFreeOutliers = new OutliersTimeSeries();
            mjdTimeSeriesList.addAll(harmonicFreeOutliers.toTimeSeries(
                PdcFsIdFactory.getOutlierTimerSeriesId(
                    PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS,
                    FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                    pdcTarget.getKeplerId()),
                PdcFsIdFactory.getOutlierTimerSeriesId(
                    PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES,
                    FLUX_TYPE, unitTestDescriptor.getCadenceType(),
                    pdcTarget.getKeplerId()), pdcInputs.getStartCadence(),
                startMjd, endMjd, PIPELINE_TASK_ID, null));

            PdcTargetOutputData targetOutputData = new PdcTargetOutputData(
                pdcTarget.getKeplerId(), correctedFlux, outliers,
                harmonicFreeCorrectedFlux, harmonicFreeOutliers,
                discontinuities, pdcProcessingCharacteristics,
                pdcGoodnessMetric);

            outputTargets.add(targetOutputData);
        }

        if (isValidateOutputs()) {
            MockUtils.mockWriteTimeSeries(this, fsClient,
                timeSeriesList.toArray(new TimeSeries[0]));
            mockWriteFloatMjdTimeSeries(this, fsClient,
                mjdTimeSeriesList.toArray(new FloatMjdTimeSeries[0]));
        }

        return outputTargets;
    }

    private int mockObservingSeason(JMockTest jMockTest, TargetTable targetTable) {

        if (jMockTest != null && logCrud != null) {
            allowing(targetTable).getObservingSeason();
            will(returnValue(OBSERVING_SEASON));
        }

        return OBSERVING_SEASON;
    }

    private void mockShortCadenceToLongCadence(JMockTest jMockTest,
        LogCrud logCrud) {

        int startCadence = unitTestDescriptor.getStartCadence();
        int endCadence = unitTestDescriptor.getEndCadence();
        int longStartCadence = unitTestDescriptor.getStartCadence(CadenceType.LONG);
        int longEndCadence = unitTestDescriptor.getEndCadence(CadenceType.LONG);
        if (jMockTest != null && logCrud != null) {
            jMockTest.allowing(logCrud)
                .shortCadenceToLongCadence(startCadence, endCadence);
            jMockTest.will(returnValue(Pair.of(longStartCadence, longEndCadence)));
        }
    }

    private void mockWriteFloatMjdTimeSeries(JMockTest jMockTest,
        FileStoreClient fsClient, FloatMjdTimeSeries[] timeSeries) {

        if (jMockTest != null && fsClient != null) {
            jMockTest.oneOf(fsClient)
                .writeMjdTimeSeries(timeSeries);
        }
    }

    private void mockTransitOperations(JMockTest jMockTest) {
        if (jMockTest == null || transitOperations == null) {
            return;
        }

        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(42, "K00001.01",
            "koi_period", "265.2"));

        Transit transit = new Transit(42, "K00001.01", false, Double.NaN,
            Float.parseFloat("265.2"), Float.NaN);
        // Return empty lists when the key is not present as the actual map
        // returned from getTransits() would return.

        @SuppressWarnings("unchecked")
        Map<Integer, List<Transit>> rv = DefaultedMap.decorate(
            Maps.newHashMap(), Collections.emptyList());

        rv.put(transit.getKeplerId(), ImmutableList.of(transit));

        jMockTest.allowing(transitOperations)
            .getTransits(ImmutableList.of(transit.getKeplerId()));
        jMockTest.will(returnValue(rv));

        jMockTest.allowing(transitOperations)
            .getTransits(ImmutableList.of(0, 1));
        jMockTest.will(returnValue(rv));

        jMockTest.allowing(transitOperations)
            .getTransits(ImmutableList.of(0, 1, 100000001, 100000002));
        jMockTest.will(returnValue(rv));
    }

    private void mockParameterValues(JMockTest jMockTest,
        QuarterToParameterValueMap parameterValues) {

        if (jMockTest != null && parameterValues != null) {
            jMockTest.allowing(parameterValues)
                .getValue(quartersList, values,
                    unitTestDescriptor.getCadenceType(),
                    unitTestDescriptor.getStartCadence(),
                    unitTestDescriptor.getEndCadence());
            jMockTest.will(returnValue(true));
        }
    }

    private CorrectedFluxTimeSeries createCorrectedFluxTimeSeries(
        FsId valuesFsId, FsId uncertaintiesFsId, FsId filledIndicesFsId,
        List<TimeSeries> timeSeriesList) {

        Map<FsId, TimeSeries> timeSeriesByFsId = newHashMap();

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

    private int[] createDiscontinuitiesTimeSeries(FsId discontinuitiesFsId,
        List<TimeSeries> timeSeriesList) {

        int length = unitTestDescriptor.getEndCadence()
            - unitTestDescriptor.getStartCadence() + 1;
        int[] iseries = new int[length];
        iseries[1] = 1;
        boolean[] gaps = new boolean[length];
        Arrays.fill(gaps, true);
        gaps[1] = false;

        IntTimeSeries timeSeries = new IntTimeSeries(discontinuitiesFsId,
            iseries, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), gaps, pipelineTask.getId());
        timeSeriesList.add(timeSeries);

        return new int[] { 1 };
    }

    private PdcProcessingCharacteristics createPdcProcessingCharacteristics(
        int keplerId) {

        List<PdcBand> bands = new ArrayList<PdcBand>();
        bands.add(new PdcBand(PRIOR_FIT_TYPE, 1.0F, 1.0F));
        PdcProcessingCharacteristics pdcProcessingCharacteristics = new PdcProcessingCharacteristics();
        pdcProcessingCharacteristics.setBands(bands);
        pdcProcessingCharacteristics.setHarmonicsFitted(true);
        pdcProcessingCharacteristics.setHarmonicsRestored(true);
        pdcProcessingCharacteristics.setNumDiscontinuitiesDetected(3);
        pdcProcessingCharacteristics.setPdcMethod(REGULAR_METHOD);
        pdcProcessingCharacteristics.setTargetVariability(3.0F);

        mockPdcProcessingCharacteristics(isValidateOutputs() ? this : null,
            pdcCrud, pipelineTask, FluxType.SAP,
            unitTestDescriptor.getCadenceType(), keplerId,

            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), pdcProcessingCharacteristics);

        return pdcProcessingCharacteristics;
    }

    private static void mockPdcProcessingCharacteristics(JMockTest jMockTest,
        PdcCrud pdcCrud, PipelineTask pipelineTask, FluxType fluxType,
        CadenceType cadenceType, int keplerId, int startCadence,
        int endCadence,
        PdcProcessingCharacteristics pdcProcessingCharacteristics) {

        if (jMockTest != null && pdcCrud != null) {
            jMockTest.oneOf(pdcCrud)
                .createPdcProcessingCharacteristics(
                    pdcProcessingCharacteristics.getDbInstance(
                        pipelineTask.getId(), fluxType, cadenceType, keplerId,
                        startCadence, endCadence));
        }
    }

    private PdcGoodnessMetric createPdcGoodnessMetric(int keplerId,
        boolean[] gapIndicators, List<TimeSeries> timeSeriesList) {
        PdcGoodnessMetric pdcGoodnessMetric = new PdcGoodnessMetric(
            new PdcGoodnessComponent(0.1F, 0.001F), new PdcGoodnessComponent(
                0.2F, 0.002F), new PdcGoodnessComponent(0.3F, 0.003F),
            new PdcGoodnessComponent(0.4F, 0.004F), new PdcGoodnessComponent(
                5.00F, 0.0005F));

        timeSeriesList.addAll(pdcGoodnessMetric.toTimeSeries(FLUX_TYPE,
            unitTestDescriptor.getCadenceType(),
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), keplerId, gapIndicators,
            PIPELINE_TASK_ID));

        return pdcGoodnessMetric;
    }

    private String createPdcBlob(CadenceType cadenceType, int startCadence,
        int endCadence) throws IOException {

        return mockPdcBlobFile(isValidateOutputs() ? this : null, pdcCrud,
            fsClient, matlabWorkingDir, CCD_MODULE, CCD_OUTPUT, cadenceType,
            startCadence, endCadence, PIPELINE_TASK_ID);
    }

    private String createCbvBlob(CadenceType cadenceType, int startCadence,
        int endCadence) throws IOException {

        return mockCbvBlobFile(isValidateOutputs() ? this : null, pdcCrud,
            fsClient, matlabWorkingDir, CCD_MODULE, CCD_OUTPUT, cadenceType,
            startCadence, endCadence, PIPELINE_TASK_ID);
    }

    private static String mockPdcBlobFile(JMockTest jMockTest, PdcCrud pdcCrud,
        FileStoreClient fsClient, File matlabWorkingDir, int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence,
        int endCadence, long pipelineTaskId) throws IOException {

        File blobFile = MockUtils.createBlobFile(matlabWorkingDir,
            BlobSeriesType.PDC.getName() + MAT_FILE_EXTENSION);
        PdcBlobMetadata metadata = new PdcBlobMetadata(pipelineTaskId,
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            FilenameUtils.getExtension(blobFile.getName()));

        if (jMockTest != null && pdcCrud != null) {
            jMockTest.oneOf(pdcCrud)
                .createPdcBlobMetadata(metadata);
            jMockTest.oneOf(fsClient)
                .writeBlob(BlobOperations.getFsId(metadata), pipelineTaskId,
                    blobFile);
        }

        return blobFile.getName();
    }

    private static String mockCbvBlobFile(JMockTest jMockTest, PdcCrud pdcCrud,
        FileStoreClient fsClient, File matlabWorkingDir, int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence,
        int endCadence, long pipelineTaskId) throws IOException {

        File blobFile = MockUtils.createBlobFile(matlabWorkingDir,
            BlobSeriesType.CBV.getName() + MAT_FILE_EXTENSION);
        CbvBlobMetadata metadata = new CbvBlobMetadata(pipelineTaskId,
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            FilenameUtils.getExtension(blobFile.getName()));

        if (jMockTest != null && pdcCrud != null) {
            jMockTest.oneOf(pdcCrud)
                .createCbvBlobMetadata(metadata);
            jMockTest.oneOf(fsClient)
                .writeBlob(BlobOperations.getFsId(metadata), pipelineTaskId,
                    blobFile);
        }

        return blobFile.getName();
    }

    private List<ModuleAlert> createAlerts() {

        if (unitTestDescriptor.isGenerateAlerts()) {
            ModuleAlert alert = new ModuleAlert(Severity.ERROR, ALERT_MESSAGE);
            if (isValidateOutputs()) {
                MockUtils.mockAlert(this, alertService,
                    PdcPipelineModule.MODULE_NAME, pipelineTask.getId(),
                    Severity.ERROR, alert.getMessage() + ": time=0.0");
            }
            return Arrays.asList(alert);
        }

        return newArrayList();
    }

    private PipelineTask createPipelineTask(CadenceType cadenceType,
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance(cadenceType);
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(PIPELINE_TASK_ID);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            ccdModule, ccdOutput, startCadence, endCadence)));
        task.setPipelineDefinitionNode(definitionNode);

        return task;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            PdcPipelineModule.MODULE_NAME);
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PdcPipelineModule.class));
        pipelineModuleDefinition.setExeName("pdc");

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

    private PipelineInstanceNode createPipelineInstanceNode(
        final PipelineModuleDefinition moduleDefinition,
        final PipelineInstance instance,
        final PipelineDefinitionNode definitionNode) {

        PipelineInstanceNode instanceNode = new PipelineInstanceNode(instance,
            definitionNode, moduleDefinition);

        PdcModuleParameters pdcModuleParameters = new PdcModuleParameters();
        pdcModuleParameters.setDebugLevel(debugLevel);
        pdcModuleParameters.setMapEnabled(unitTestDescriptor.isMapEnabled());
        pdcModuleParameters.setBandSplittingEnabledQuarters(quarter);
        pdcModuleParameters.setBandSplittingEnabled(new boolean[] { value });

        insertParameterSet(instanceNode, pdcModuleParameters);

        ancillaryEngineeringParameters = new AncillaryEngineeringParameters(
            new String[] { ANCILLARY_MNEMONIC_ENGINEERING },
            ArrayUtils.EMPTY_STRING_ARRAY, new int[] { 1 },
            new float[] { 0.01F }, new float[] { 1.0F });
        insertParameterSet(instanceNode, ancillaryEngineeringParameters);
        thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters(
            new String[] { THRUSTER_ANCILLARY_MNEMONIC_ENGINEERING },
            ArrayUtils.EMPTY_STRING_ARRAY, new int[] { 1 },
            new float[] { 0.01F }, new float[] { 1.0F });
        insertParameterSet(instanceNode,
            thrusterDataAncillaryEngineeringParameters);

        ancillaryPipelineParameters = new AncillaryPipelineParameters(
            new String[] { ANCILLARY_MNEMONIC_CAL, ANCILLARY_MNEMONIC_PA,
                ANCILLARY_MNEMONIC_PPA }, new String[] { ANCILLARY_MNEMONIC_PA
                + "|" + ANCILLARY_MNEMONIC_PPA }, new int[] { 1, 1, 1 });
        insertParameterSet(instanceNode, ancillaryPipelineParameters);

        insertParameterSet(instanceNode, new AncillaryDesignMatrixParameters());
        FluxTypeParameters fluxTypeParameters = new FluxTypeParameters();
        fluxTypeParameters.setFluxType(FLUX_TYPE.toString());
        insertParameterSet(instanceNode, fluxTypeParameters);
        insertParameterSet(instanceNode, new GapFillModuleParameters());
        insertParameterSet(instanceNode,
            new SaturationSegmentModuleParameters());
        insertParameterSet(instanceNode,
            new PdcHarmonicsIdentificationParameters());
        insertParameterSet(instanceNode, new DiscontinuityParameters());
        insertParameterSet(instanceNode, new CustomTargetParameters());
        insertParameterSet(instanceNode, new SpsdDetectionParameters());
        insertParameterSet(instanceNode, new SpsdDetectorParameters());
        insertParameterSet(instanceNode, new SpsdRemovalParameters());
        insertParameterSet(instanceNode, new PdcGoodnessMetricParameters());
        insertParameterSet(instanceNode, new BandSplittingParameters());

        PdcMapParameters pdcMapParameters = new PdcMapParameters();
        pdcMapParameters.setUseBasisVectorsFromBlob(unitTestDescriptor.getUseBasisVectorsFromBlob());
        insertParameterSet(instanceNode, pdcMapParameters);
        PseudoTargetListParameters pseudoTargetListParameters = new PseudoTargetListParameters();
        if (unitTestDescriptor.isPseudoTargetListEnabled()) {
            pseudoTargetListParameters.setTargetListNames(PSEUDO_TARGET_LISTS);
        }
        insertParameterSet(instanceNode, pseudoTargetListParameters);

        return instanceNode;
    }

    private static UnitOfWorkTask createUowTask(int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {
        ModOutCadenceUowTask uowTask = new ModOutCadenceUowTask(ccdModule,
            ccdOutput, startCadence, endCadence);

        return uowTask;
    }

    private static void insertParameterSet(PipelineInstanceNode instanceNode,
        Parameters parameters) {

        ParameterSet parameterSet = new ParameterSet(parameters.getClass()
            .getSimpleName());
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
        instanceNode.putModuleParameterSet(parameters.getClass(), parameterSet);
    }

    File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    void setMatlabWorkingDir(final File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
        oneOf(blobOperations).setOutputDir(matlabWorkingDir);
    }
}
