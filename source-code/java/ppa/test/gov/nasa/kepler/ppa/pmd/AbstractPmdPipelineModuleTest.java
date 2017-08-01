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

package gov.nasa.kepler.ppa.pmd;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.common.pi.TpsTypeParameters;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.EnergyDistributionMetrics;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModuleTest;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class AbstractPmdPipelineModuleTest extends
    AbstractPpaPipelineModuleTest {

    private static final Log log = LogFactory.getLog(AbstractPmdPipelineModuleTest.class);

    private static final int CCD_MODULE = 12;
    private static final int CCD_OUTPUT = 3;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final TpsType TPS_TYPE = TpsType.TPS_LITE;
    private static final int HOT_PIXELS_PER_MODULE_OUTPUT = 2;
    private static final String[] ANCILLARY_DATA_MNEMONICS = new String[] {
        "SOC_PPA_PLATE_SCALE", "SOC_PPA_BACKGROUND_LEVEL" };
    private static final String[] ANCILLARY_DATA_INTERACTIONS = new String[] {
        "empty-strings", "dont-work" };
    private static final int[] ANCILLARY_DATA_MODULE_ORDERS = new int[] { 1, 2 };
    private static final float[] ANCILLARY_DATA_QUANTIZATION_LEVELS = new float[] {
        1F, 1F };
    private static final float[] ANCILLARY_DATA_INTRINSIC_UNCERTAINTIES = new float[] {
        0.01F, 0.01F };
    private static final int TARGETS_PER_MODULE_OUTPUT = 10;
    private static final int MAX_KEPLER_ID = 200000;
    static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pmd-matlab-1-1");

    private List<ObservedTarget> targets;
    private Map<Integer, Kic> kicByKeplerId;
    private Random randomKeplerId;
    private boolean[] keplerIdInUse;
    private Pixel[] hotPixels;
    private BlobFileSeries backgroundBlobs;
    private BlobFileSeries motionBlobs;
    private FluxTypeParameters fluxTypeParameters = new FluxTypeParameters();
    private TpsTypeParameters tpsTypeParameters = new TpsTypeParameters();
    private AncillaryEngineeringParameters ancillaryEngineeringParameters;
    private List<AncillaryEngineeringData> ancillaryEngineeringData;
    private AncillaryPipelineParameters ancillaryPipelineParameters;
    private List<AncillaryPipelineData> ancillaryPipelineData;
    private Map<FsId, FloatTimeSeries> outputTsByFsId;
    private Set<Long> producerTaskIds;

    private PmdModuleParameters moduleParameters = new PmdModuleParameters();
    private PmdPipelineModule pipelineModule;

    private AncillaryOperations ancillaryOperations;
    private PixelOperations pixelOperations;
    private CelestialObjectOperations celestialObjectOperations;
    private TpsCrud tpsCrud;
    private PipelineInstance tpsPipelineInstance;
    private long tpsPipelineInstanceId = 46456565999L;

    public AbstractPmdPipelineModuleTest() {
    }

    protected void createAndRetrieveInputs() {
        populateObjects();

        createInputs();

        validate();

        PmdInputs pmdInputs = (PmdInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(pmdInputs, getTargetTable());

        validate(pmdInputs);
    }

    protected void createAndStoreOutputs() {
        populateObjects();

        createInputs();

        PmdInputs pmdInputs = (PmdInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(pmdInputs, getTargetTable());

        PmdOutputs pmdOutputs = (PmdOutputs) getPipelineModule().createOutputs();
        createOutputs(pmdOutputs);

        getPipelineModule().storeOutputs(pmdOutputs, getTargetTable());
    }

    protected void createAndSerializeInputs() throws Exception {
        createAndRetrieveInputs();
        SerializationTest.testSerialization(getPipelineModule().getInputs(),
            getPipelineModule().createInputs(), new File(
                Filenames.BUILD_TMP, getClass().getSimpleName()
                    + "-inputs.bin"));
    }

    protected void createAndSerializeOutputs() throws Exception {
        createAndStoreOutputs();
        SerializationTest.testSerialization(getPipelineModule().getOutputs(),
            getPipelineModule().createOutputs(), new File(
                Filenames.BUILD_TMP, getClass().getSimpleName()
                    + "-outputs.bin"));
    }

    protected void populateObjects() {
        reset();

        tpsPipelineInstance = new PipelineInstance();
        tpsPipelineInstance.setId(tpsPipelineInstanceId);
        createMockObjects();
        setMockObjects(getPipelineModule());
        setMatlabWorkingDir(MATLAB_WORKING_DIR);
        getPipelineModule().setMatlabWorkingDir(getMatlabWorkingDir());
        setPipelineTask(createPipelineTask(PIPELINE_TASK_ID));
        getPipelineTask().setPipelineInstance(getPipelineInstance());
        getPipelineModule().setPipelineInstance(getPipelineInstance());
        getPipelineModule().setPipelineTask(getPipelineTask());
        getPipelineModule().setConfigMapOperations(getConfigMapOperations());
    }

    private PipelineTask createPipelineTask(long taskId) {
        PipelineTask task = new PipelineTask(getPipelineInstance(),
            getPipelineDefinitionNode(), getPipelineInstanceNode());
        task.setId(taskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE)));

        return task;
    }

    private UnitOfWorkTask createUowTask(int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {

        ModOutCadenceUowTask uowTask = new ModOutCadenceUowTask(ccdModule,
            ccdOutput, startCadence, endCadence);

        return uowTask;
    }

    @Override
    protected void createMockObjects() {
        super.createMockObjects();

        ancillaryOperations = mock(AncillaryOperations.class);
        pixelOperations = mock(PixelOperations.class);
        celestialObjectOperations = mock(CelestialObjectOperations.class);
        tpsCrud = mock(TpsCrud.class);
    }

    private void setMockObjects(PmdPipelineModule pipelineModule) {
        pipelineModule.setMjdToCadence(getMjdToCadence());
        pipelineModule.setAncillaryOperations(ancillaryOperations);
        pipelineModule.setDaCrud(getDaCrud());
        pipelineModule.setPixelOperations(pixelOperations);
        pipelineModule.setCelestialObjectOperations(celestialObjectOperations);
        pipelineModule.setPpaCrud(getPpaCrud());
        pipelineModule.setRaDec2PixOperations(getRaDec2PixOperations());
        pipelineModule.setTargetCrud(getTargetCrud());
        pipelineModule.setBlobOperations(getBlobOperations());
        pipelineModule.setGenericReportOperations(getGenericReportOperations());
        pipelineModule.setTpsCrud(getTpsCrud());
    }

    @Override
    protected PipelineInstanceNode createPipelineInstanceNode() {
        initializeModuleParameters();

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            getPipelineInstance(), getPipelineDefinitionNode(),
            getPipelineModuleDefinition());

        ParameterSet parameterSet = new ParameterSet("pmd");
        parameterSet.setParameters(new BeanWrapper<Parameters>(moduleParameters));
        pipelineInstanceNode.putModuleParameterSet(PmdModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pmd cadence type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        pipelineInstanceNode.putModuleParameterSet(
            CadenceTypePipelineParameters.class, parameterSet);

        parameterSet = new ParameterSet("pmd flux type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            fluxTypeParameters));
        pipelineInstanceNode.putModuleParameterSet(FluxTypeParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pmd tps type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            tpsTypeParameters));
        pipelineInstanceNode.putModuleParameterSet(TpsTypeParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pmd ancillary engineering parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            ancillaryEngineeringParameters));
        pipelineInstanceNode.putModuleParameterSet(
            AncillaryEngineeringParameters.class, parameterSet);

        parameterSet = new ParameterSet("pmd ancillary pipeline parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            ancillaryPipelineParameters));
        pipelineInstanceNode.putModuleParameterSet(
            AncillaryPipelineParameters.class, parameterSet);

        return pipelineInstanceNode;
    }

    private void initializeModuleParameters() {
        moduleParameters.setDebugLevel(debugLevel);
        moduleParameters.setPlottingEnabled(plottingEnabled);

        fluxTypeParameters.setFluxType(FLUX_TYPE.toString());
        tpsTypeParameters.setTpsType(TPS_TYPE.toString());

        // Default value is insufficient for unit tests.
        ancillaryEngineeringParameters = new AncillaryEngineeringParameters(
            ANCILLARY_DATA_MNEMONICS, ANCILLARY_DATA_INTERACTIONS,
            ANCILLARY_DATA_MODULE_ORDERS, ANCILLARY_DATA_QUANTIZATION_LEVELS,
            ANCILLARY_DATA_INTRINSIC_UNCERTAINTIES);
        ancillaryPipelineParameters = new AncillaryPipelineParameters(
            ANCILLARY_DATA_MNEMONICS, ANCILLARY_DATA_INTERACTIONS,
            ANCILLARY_DATA_MODULE_ORDERS);
    }

    @Override
    protected PipelineModuleDefinition createPipelineModuleDefinition() {
        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Photometer Performance Assessment - PPA Metrics Determination");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PmdPipelineModule.class));
        pipelineModuleDefinition.setExeName("pmd");

        return pipelineModuleDefinition;
    }

    private void createInputs() {
        createInputs(false);
    }

    protected void createInputs(boolean processingTask) {
        producerTaskIds = new HashSet<Long>();
        long producerTaskId = 0;

        setCadenceTimes(createCadenceTimes());
        setConfigMaps(createConfigMaps());
        setTargetTable(createTargetTable());
        if (!processingTask) {
            creatTargetTableLogExpectations();
        }

        targets = createTargets(getTargetTable(), producerTaskId);

        kicByKeplerId = createKics(targets);

        createRaDec2PixModel();

        createFloatTimeSeries(
            PmdInputTsData.getFsIds(CCD_MODULE, CCD_OUTPUT, targets),
            producerTaskId);
        producerTaskIds.add(producerTaskId++);

        createFloatTimeSeries(getCdppFsIds(targets), producerTaskId);
        producerTaskIds.add(producerTaskId++);

        createIntTimeSeries(getCdppIntFsIds(targets), producerTaskId, 1);
        producerTaskIds.add(producerTaskId++);

        hotPixels = createInvalidPixels(START_CADENCE, END_CADENCE,
            getCadenceTimes());

        if (processingTask) {
            oneOf(getBlobOperations()).setOutputDir(getMatlabWorkingDir());
        }
        backgroundBlobs = createBackgroundBlobs(producerTaskId);
        producerTaskIds.add(producerTaskId++);
        motionBlobs = createMotionBlobs(producerTaskId);
        producerTaskIds.add(producerTaskId++);

        ancillaryEngineeringData = createAncillaryEngineeringData();
        ancillaryPipelineData = createAncillaryPipelineData(producerTaskId);
        producerTaskIds.add(producerTaskId++);
    }

    private List<ObservedTarget> createTargets(final TargetTable targetTable,
        long producerTaskId) {

        PipelineTask pipelineTask = createPipelineTask(producerTaskId);
        List<ObservedTarget> targets = new ArrayList<ObservedTarget>();
        for (int targetIndex = 0; targetIndex < TARGETS_PER_MODULE_OUTPUT; targetIndex++) {
            int keplerId = getNextKeplerId();
            ObservedTarget target = new ObservedTarget(targetTable, CCD_MODULE,
                CCD_OUTPUT, keplerId);
            target.addLabel(PlannedTarget.TargetLabel.PPA_2DBLACK);
            target.addLabel(PlannedTarget.TargetLabel.PPA_LDE_UNDERSHOOT);
            target.addLabel(PlannedTarget.TargetLabel.PLANETARY);
            target.setPipelineTask(pipelineTask);
            targets.add(target);
        }

        allowing(getTargetCrud()).retrieveObservedTargets(targetTable,
            CCD_MODULE, CCD_OUTPUT);
        will(returnValue(targets));

        return targets;
    }

    private Map<Integer, Kic> createKics(List<ObservedTarget> targets) {
        Map<Integer, Kic> kicByKeplerId = new HashMap<Integer, Kic>();
        for (final ObservedTarget target : targets) {
            Kic kic = new Kic.Builder(target.getKeplerId(),
                getRandom().nextDouble(), getRandom().nextDouble()).keplerMag(
                getRandom().nextFloat())
                .effectiveTemp(getRandom().nextInt())
                .log10SurfaceGravity(getRandom().nextFloat())
                .build();
            kicByKeplerId.put(target.getKeplerId(), kic);

            CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
                kic).build();

            allowing(celestialObjectOperations).retrieveCelestialObjectParameters(
                target.getKeplerId());
            will(returnValue(celestialObjectParameters));
        }

        return kicByKeplerId;
    }
    private List<FsId> getCdppFsIds(List<ObservedTarget> targets) {
        List<FsId> fsIds = new ArrayList<FsId>();
        for (ObservedTarget target : targets) {
            fsIds.addAll(PmdCdppTsData.getFsIds(tpsPipelineInstanceId, target.getKeplerId(),
                FLUX_TYPE, TPS_TYPE));
        }

        allowing(tpsCrud).retrieveLatestTpsRunForCadenceRange(TPS_TYPE, START_CADENCE, END_CADENCE);
        will(returnValue(tpsPipelineInstance));
        return fsIds;
    }

    private List<FsId> getCdppIntFsIds(List<ObservedTarget> targets) {
        List<FsId> fsIds = new ArrayList<FsId>();
        for (ObservedTarget target : targets) {
            fsIds.addAll(PmdCdppTsData.getIntFsIds(target.getKeplerId(),
                FLUX_TYPE));
        }

        return fsIds;
    }

    private Pixel[] createInvalidPixels(int startCadence, int endCadence,
        TimestampSeries cadenceTimes) {

        Pixel[] hotPixels = new Pixel[HOT_PIXELS_PER_MODULE_OUTPUT];

        for (int i = 0; i < hotPixels.length; i++) {
            int start = getNextCadence();
            int stop = getNextCadence();
            Pixel hotPixel = new Pixel(PixelType.HOT);
            hotPixel.setCcdModule(CCD_MODULE);
            hotPixel.setCcdOutput(CCD_OUTPUT);
            hotPixel.setStartTime(getMjdStartTime(cadenceTimes, start));
            if (start < stop) {
                hotPixel.setEndTime(getMjdEndTime(cadenceTimes, stop));
            }
            hotPixels[i] = hotPixel;
        }

        double startTime = cadenceTimes.startMjd();
        double endTime = cadenceTimes.endMjd();
        allowing(pixelOperations).retrievePixelRange(CCD_MODULE, CCD_OUTPUT,
            startTime, endTime);
        will(returnValue(hotPixels));

        return hotPixels;
    }

    private BlobFileSeries createBackgroundBlobs(long producerTaskId) {
        BlobSeries<String> blobSeries = MockUtils.mockBackgroundBlobFileSeries(
            this, getBlobOperations(), CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, producerTaskId);

        return new BlobFileSeries(blobSeries);
    }

    private BlobFileSeries createMotionBlobs(long producerTaskId) {
        BlobSeries<String> blobSeries = MockUtils.mockMotionBlobFileSeries(
            this, getBlobOperations(), CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, producerTaskId);

        return new BlobFileSeries(blobSeries);
    }

    private List<AncillaryEngineeringData> createAncillaryEngineeringData() {

        final double startMjd = getCadenceTimes().startMjd();
        final double endMjd = getCadenceTimes().endMjd();

        return MockUtils.mockAncillaryEngineeringData(this,
            ancillaryOperations, startMjd, endMjd, ANCILLARY_DATA_MNEMONICS);
    }

    private List<AncillaryPipelineData> createAncillaryPipelineData(
        final long producerTaskId) {

        final List<AncillaryPipelineData> ancillaryPipelineData = new ArrayList<AncillaryPipelineData>();
        for (String mnemonic : ANCILLARY_DATA_MNEMONICS) {
            AncillaryPipelineData data = new AncillaryPipelineData();
            data.setMnemonic(mnemonic);
            ancillaryPipelineData.add(data);
        }

        allowing(ancillaryOperations).retrieveAncillaryPipelineData(
            ANCILLARY_DATA_MNEMONICS, getTargetTable(), CCD_MODULE, CCD_OUTPUT,
            getCadenceTimes());
        will(returnValue(ancillaryPipelineData));

        Set<Long> producerTaskIds = new HashSet<Long>(1);
        producerTaskIds.add(producerTaskId);
        allowing(ancillaryOperations).producerTaskIds();
        will(returnValue(producerTaskIds));

        return ancillaryPipelineData;
    }

    private void validate() {
        assertNotNull(getTargetTable());
        assertNotNull(targets);
        assertEquals(TARGETS_PER_MODULE_OUTPUT, targets.size());
        assertNotNull(backgroundBlobs);
        assertNotNull(motionBlobs);
        assertNotNull(kicByKeplerId);
        assertEquals(TARGETS_PER_MODULE_OUTPUT, kicByKeplerId.size());
        assertNotNull(hotPixels);
        assertEquals(HOT_PIXELS_PER_MODULE_OUTPUT, hotPixels.length);
    }

    protected void validate(PmdInputs pmdInputs) {
        log.info("Validating inputs");

        assertNotNull(pmdInputs);
        assertEquals(CCD_MODULE, pmdInputs.getCcdModule());
        assertEquals(CCD_OUTPUT, pmdInputs.getCcdOutput());

        assertNotNull(pmdInputs.getPmdModuleParameters());
        assertNotNull(pmdInputs.getFcConstants());

        validate(getConfigMaps(), pmdInputs.getSpacecraftConfigMaps());

        assertNotNull(pmdInputs.getCadenceTimes());
        assertEquals(CADENCE_COUNT,
            pmdInputs.getCadenceTimes().startTimestamps.length);

        assertNotNull(pmdInputs.getRaDec2PixModel());

        validate(pmdInputs.getInputTsData());
        validate(pmdInputs.getCdppTsData());

        assertNotNull(pmdInputs.getBadPixels());
        assertEquals(HOT_PIXELS_PER_MODULE_OUTPUT, pmdInputs.getBadPixels()
            .size());

        assertNotNull(pmdInputs.getBackgroundBlobs());
        assertEquals(backgroundBlobs, pmdInputs.getBackgroundBlobs());

        assertNotNull(pmdInputs.getMotionBlobs());
        assertEquals(1, pmdInputs.getMotionBlobs()
            .getBlobFilenames().length);
        assertEquals(motionBlobs, pmdInputs.getMotionBlobs());

        assertNotNull(pmdInputs.getAncillaryEngineeringParameters());
        assertEquals(ancillaryEngineeringParameters,
            pmdInputs.getAncillaryEngineeringParameters());
        assertNotNull(pmdInputs.getAncillaryPipelineParameters());
        assertEquals(ancillaryPipelineParameters,
            pmdInputs.getAncillaryPipelineParameters());
        validateAncillaryData(pmdInputs.getAncillaryEngineeringData(),
            pmdInputs.getAncillaryPipelineData());
    }

    private void validate(PmdInputTsData inputTsData) {
        log.info("Validating inputTsData");

        assertNotNull(inputTsData);

        validate(inputTsData.getBlackCosmicRayMetrics());
        validate(inputTsData.getMaskedSmearCosmicRayMetrics());
        validate(inputTsData.getVirtualSmearCosmicRayMetrics());

        validate(TARGETS_PER_MODULE_OUTPUT, CADENCE_COUNT,
            inputTsData.getTwoDBlack());
        validate(TARGETS_PER_MODULE_OUTPUT, CADENCE_COUNT,
            inputTsData.getLdeUndershoot());

        validate(CADENCE_COUNT, inputTsData.getBlackLevel());
        validate(CADENCE_COUNT, inputTsData.getDarkCurrent());
        validate(CADENCE_COUNT, inputTsData.getSmearLevel());

        validate(CADENCE_COUNT,
            inputTsData.getTheoreticalCompressionEfficiency());
        validate(CADENCE_COUNT, inputTsData.getAchievedCompressionEfficiency());

        validate(inputTsData.getBackgroundCosmicRayMetrics());
        validate(inputTsData.getTargetStarCosmicRayMetrics());

        validate(CADENCE_COUNT, inputTsData.getEncircledEnergy());
        validate(CADENCE_COUNT, inputTsData.getBrightness());
    }

    private void validate(EnergyDistributionMetrics cosmicRayMetrics) {
        assertNotNull(cosmicRayMetrics);

        assertNotNull(cosmicRayMetrics.getHitRate());
        assertEquals(CADENCE_COUNT, cosmicRayMetrics.getHitRate()
            .getValues().length);
        assertNotNull(cosmicRayMetrics.getMeanEnergy());
        assertEquals(CADENCE_COUNT, cosmicRayMetrics.getMeanEnergy()
            .getValues().length);
        assertNotNull(cosmicRayMetrics.getEnergyVariance());
        assertEquals(CADENCE_COUNT, cosmicRayMetrics.getEnergyVariance()
            .getValues().length);
        assertNotNull(cosmicRayMetrics.getEnergySkewness());
        assertEquals(CADENCE_COUNT, cosmicRayMetrics.getEnergySkewness()
            .getValues().length);
        assertNotNull(cosmicRayMetrics.getEnergyKurtosis());
        assertEquals(CADENCE_COUNT, cosmicRayMetrics.getEnergyKurtosis()
            .getValues().length);
    }

    private void validate(List<PmdCdppTsData> cdppTsData) {
        log.info("Validating cdppTsData");

        assertNotNull(cdppTsData);
        assertEquals(TARGETS_PER_MODULE_OUTPUT, cdppTsData.size());

        for (PmdCdppTsData cdppTsDataRecord : cdppTsData) {
            assertTrue(cdppTsDataRecord.getKeplerId() != 0);
            assertTrue(cdppTsDataRecord.getKeplerMag() != 0);
            assertTrue(cdppTsDataRecord.getEffectiveTemp() != 0);
            assertTrue(cdppTsDataRecord.getLog10SurfaceGravity() != 0);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getCdpp3Hr().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getCdpp6Hr().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getCdpp12Hr().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getFluxTimeSeries()
                .getValues().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getFluxTimeSeries()
                .getUncertainties().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getFluxTimeSeries()
                .getGapIndicators().length);
            assertEquals(CADENCE_COUNT, cdppTsDataRecord.getFluxTimeSeries()
                .getFilledIndices().length);
        }
    }

    private void validateAncillaryData(
        List<AncillaryEngineeringData> actualAncillaryEngineeringData,
        List<AncillaryPipelineData> actualAncillaryPipelineData) {

        assertNotNull(actualAncillaryEngineeringData);
        assertEquals(ANCILLARY_DATA_MNEMONICS.length,
            actualAncillaryEngineeringData.size());

        Map<String, AncillaryEngineeringData> ancillaryEngineeringDataByMnemonic = new HashMap<String, AncillaryEngineeringData>();
        for (AncillaryEngineeringData data : actualAncillaryEngineeringData) {
            ancillaryEngineeringDataByMnemonic.put(data.getMnemonic(), data);
        }
        for (String mnemonic : ANCILLARY_DATA_MNEMONICS) {
            assertNotNull(mnemonic,
                ancillaryEngineeringDataByMnemonic.get(mnemonic));
        }

        assertEquals(ancillaryEngineeringData, actualAncillaryEngineeringData);

        assertNotNull(actualAncillaryPipelineData);
        assertEquals(ANCILLARY_DATA_MNEMONICS.length,
            actualAncillaryPipelineData.size());

        Map<String, AncillaryPipelineData> ancillaryPipelineDataByMnemonic = new HashMap<String, AncillaryPipelineData>();
        for (AncillaryPipelineData data : actualAncillaryPipelineData) {
            ancillaryPipelineDataByMnemonic.put(data.getMnemonic(), data);
        }
        for (String mnemonic : ANCILLARY_DATA_MNEMONICS) {
            assertNotNull(mnemonic,
                ancillaryPipelineDataByMnemonic.get(mnemonic));
        }

        assertEquals(ancillaryPipelineData, actualAncillaryPipelineData);
    }

    void createOutputs(PmdOutputs pmdOutputs) {
        outputTsByFsId = createOutputTimeSeries(PmdOutputTsData.getAllFsIds(
            CCD_MODULE, CCD_OUTPUT));
        pmdOutputs.getOutputTsData()
            .setAllTimeSeries(CCD_MODULE, CCD_OUTPUT, outputTsByFsId);

        createReports(pmdOutputs);
        createOutputAlert(pmdOutputs);
        createGenericReport(pmdOutputs);

        if (producerTaskIds != null) {
            createDataAccountabilityTrail(producerTaskIds);
        }

        validate(pmdOutputs);
    }

    private void createReports(PmdOutputs pmdOutputs) {
        PmdReport report = createPmdReport();
        pmdOutputs.setReport(report);

        final List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = report.createReports(
            getPipelineTask(), getTargetTable(), CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE);

        oneOf(getPpaCrud()).createMetricReports(reports);
    }

    private PmdReport createPmdReport() {
        PmdReport report = new PmdReport();
        PmdMetricReport metricReport = new PmdMetricReport();
        PmdMetricReport[] metricReports = new PmdMetricReport[2];
        metricReports[0] = metricReport;
        metricReports[1] = metricReport;
        report.setLdeUndershoot(metricReports);
        report.setTwoDBlack(metricReports);

        PmdCdppReport pmdCdppReport = new PmdCdppReport();
        PmdCdppMagReport pmdCdppMagReport = new PmdCdppMagReport();
        pmdCdppMagReport.setSixHour(new PmdMetricReport());
        pmdCdppReport.setMag10(pmdCdppMagReport);
        report.setCdppExpected(pmdCdppReport);

        return report;
    }

    private void createOutputAlert(PmdOutputs pmdOutputs) {
        if (isForceAlert()) {
            List<ModuleAlert> moduleAlerts = new ArrayList<ModuleAlert>();
            moduleAlerts.add(new ModuleAlert(ALERT_MESSAGE));
            pmdOutputs.getReport()
                .getAchievedCompressionEfficiency()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(), CCD_MODULE,
                CCD_OUTPUT,
                "[" + ReportType.ACHIEVED_COMPRESSION_EFFICIENCY.toString()
                    + "]");
            pmdOutputs.getReport()
                .getBlackCosmicRayMetrics()
                .getEnergyKurtosis()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(), CCD_MODULE,
                CCD_OUTPUT, "[" + ReportType.BLACK_COSMIC_RAY.toString() + ", "
                    + EnergyDistribution.ENERGY_KURTOSIS.toString() + "]");
            pmdOutputs.getReport()
                .getCdppExpected()
                .getMag10()
                .getSixHour()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(), CCD_MODULE,
                CCD_OUTPUT, "[" + ReportType.CDPP_EXPECTED.toString() + ", "
                    + CdppMagnitude.MAG10.toString() + ", "
                    + CdppDuration.SIX_HOUR.toString() + "]");
        }
    }

    private void createGenericReport(PmdOutputs pmdOutputs) {
        pmdOutputs.setReportFilename(createGenericReport().getFilename());
    }

    protected void validate(PmdOutputs pmdOutputs) {
        log.info("Validating outputs");

        assertNotNull(pmdOutputs);

        validate(pmdOutputs.getOutputTsData());
        validate(pmdOutputs.getReport());

        assertEquals(GENERIC_REPORT_FILENAME, pmdOutputs.getReportFilename());

        validateOriginators(outputTsByFsId.values());
    }

    private void validate(PmdOutputTsData outputTsData) {
        assertNotNull(outputTsData);

        validate(CADENCE_COUNT, outputTsData.getBackgroundLevel());
        validate(CADENCE_COUNT, outputTsData.getCentroidsMeanRow());
        validate(CADENCE_COUNT, outputTsData.getCentroidsMeanColumn());
        validate(CADENCE_COUNT, outputTsData.getPlateScale());

        validate(outputTsData.getCdppExpected());
        validate(outputTsData.getCdppMeasured());
        validate(outputTsData.getCdppRatio());
    }

    private void validate(PmdCdppMetrics cdppMetrics) {
        validate(cdppMetrics.getMag9());
        validate(cdppMetrics.getMag10());
        validate(cdppMetrics.getMag11());
        validate(cdppMetrics.getMag12());
        validate(cdppMetrics.getMag13());
        validate(cdppMetrics.getMag14());
        validate(cdppMetrics.getMag15());
    }

    private void validate(PmdCdppMagMetrics cdppMagMetrics) {
        validate(CADENCE_COUNT, cdppMagMetrics.getThreeHour());
        validate(CADENCE_COUNT, cdppMagMetrics.getSixHour());
        validate(CADENCE_COUNT, cdppMagMetrics.getTwelveHour());
    }

    private void validate(PmdReport reports) {
        assertNotNull(reports);

        validatePmdMetricReports(reports.createReports(getPipelineTask(),
            getTargetTable(), CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE), ReportType.allValues());
    }

    private int getNextKeplerId() {
        int nextKeplerId = randomKeplerId.nextInt(MAX_KEPLER_ID);
        while (keplerIdInUse[nextKeplerId]) {
            nextKeplerId = randomKeplerId.nextInt(MAX_KEPLER_ID);
        }
        keplerIdInUse[nextKeplerId] = true;

        return nextKeplerId;
    }

    @Override
    protected void reset() {
        super.reset();
        randomKeplerId = new Random(System.currentTimeMillis());
        keplerIdInUse = new boolean[MAX_KEPLER_ID];
        tpsCrud = null;
    }

    protected PmdPipelineModule getPipelineModule() {
        if (pipelineModule == null) {
            pipelineModule = new PmdPipelineModuleNullScience(this,
                isForceFatalException());
        }

        return pipelineModule;
    }
    
    private TpsCrud getTpsCrud() {
        return tpsCrud;
    }
}
