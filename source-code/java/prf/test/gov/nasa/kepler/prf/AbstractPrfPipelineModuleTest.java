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

package gov.nasa.kepler.prf;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.GeometryModel;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
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
import gov.nasa.kepler.hibernate.prf.PrfBlobMetadata;
import gov.nasa.kepler.hibernate.prf.PrfConvergence;
import gov.nasa.kepler.hibernate.prf.PrfCrud;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.BrysonianCosmicRayModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PrfFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;

/**
 * Base class for unit testing the PRF MI wrapper class.
 * 
 * Note that this class does not annotate any methods to be unit tests as that
 * is done by subclasses.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
public abstract class AbstractPrfPipelineModuleTest {

    protected static final Log log = LogFactory.getLog(AbstractPrfPipelineModuleTest.class);

    private static final int EXE_TIMEOUT_SECS = 30;
    private static final double DEFAULT_RA = 17.13;
    private static final double DEFAULT_DEC = 31.71;
    private static final float DEFAULT_MAG = 10.0F;
    private static final long PIPELINE_INSTANCE_ID = System.currentTimeMillis();
    private static final long PIPELINE_TASK_ID = PIPELINE_INSTANCE_ID - 1000;
    private static final long PRODUCER_TASK_ID = PIPELINE_TASK_ID - 1000;
    private static final long FPG_PRODUCER_TASK_ID = 2342;
    private static final long CAL_PRODUCER_TASK_ID = 883838;
    private static final int CCD_MODULE = 12;
    private static final int CCD_OUTPUT = 3;
    private static final int NUM_CADENCES = 48;
    private static final int START_CADENCE = 1439;
    private static final int END_CADENCE = START_CADENCE + NUM_CADENCES - 1;
    private static final int TARGET_TABLE_ID = 117;
    private static final int OBSERVING_SEASON = 1;
    private static final int TARGETS_PER_MODULE_OUTPUT = 2;
    private static final int PIXELS_PER_TARGET = 16;
    private static final int MAX_KEPLER_ID = 200000;
    private static final int BLOB_SIZE = 1024;

    private static final String MOTION_BLOB_FILE_NAME = "motionPolyBlob.mat";
    private static final String PRF_BLOB_FILE_NAME = "prfCollectionBlob.mat";
    static final File MATLAB_WORKING_DIR = new File(Filenames.BUILD_TEST,
        "prf-matlab-1-1");

    private Set<Long> producerTaskIds;
    private TargetTable targetTable;
    private List<PrfTarget> prfTargets;
    private BlobFileSeries backgroundCoeffBlob;
    private BlobFileSeries motionPolyBlob;
    private BlobFileSeries fpgGeometryBlob;
    private BlobFileSeries calUncertaintiyBlob;
    private List<PrfCentroidTimeSeries> centroids;

    private boolean[] keplerIdInUse;
    private boolean[] columnInUse;
    private boolean[] rowInUse;

    private final Random random = new Random(System.currentTimeMillis());
    private boolean forceFatalException;
    private boolean forceMultipleTables;

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private PipelineModuleDefinition pipelineModuleDefinition;
    private PipelineDefinitionNode pipelineDefinitionNode;
    private PipelineInstanceNode pipelineInstanceNode;
    protected PrfPipelineModule pipelineModule;

    private Mockery mockery;
    private BlobOperations blobOperations;
    private DataAccountabilityTrailCrud daCrud;
    private FileStoreClient fsClient;
    private CelestialObjectOperations celestialObjectOperations;
    private LogCrud logCrud;
    private PaCrud paCrud;
    private PrfCrud prfCrud;
    private RaDec2PixOperations raDec2PixOperations;
    private TargetCrud targetCrud;

    public AbstractPrfPipelineModuleTest() {
    }

    protected PipelineInstance createPipelineInstance() {

        PipelineInstance instance = new PipelineInstance();
        instance.setId(PIPELINE_INSTANCE_ID);

        ParameterSet parameterSet = new ParameterSet("cadenceType");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        instance.putParameterSet(new ClassWrapper<Parameters>(
            CadenceTypePipelineParameters.class), parameterSet);

        return instance;
    }

    private PipelineInstanceNode createPipelineInstanceNode() {

        PrfModuleParameters prfModuleParameters = new PrfModuleParameters();
        PouModuleParameters pouModuleParameters = new PouModuleParameters();
        BrysonianCosmicRayModuleParameters cosmicRayModuleParameters = new BrysonianCosmicRayModuleParameters();
        MotionModuleParameters motionModuleParameters = new MotionModuleParameters();

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            getPipelineInstance(), getPipelineDefinitionNode(),
            getPipelineModuleDefinition());

        ParameterSet parameterSet = new ParameterSet("cosmicray");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            cosmicRayModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(
            BrysonianCosmicRayModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("prf");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            prfModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(PrfModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pou");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            pouModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(PouModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("motion");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            motionModuleParameters));
        pipelineInstanceNode.putModuleParameterSet(
            MotionModuleParameters.class, parameterSet);

        return pipelineInstanceNode;
    }

    private PipelineDefinitionNode getPipelineDefinitionNode() {

        if (pipelineDefinitionNode == null) {
            pipelineDefinitionNode = new PipelineDefinitionNode(
                getPipelineModuleDefinition().getName());
        }
        return pipelineDefinitionNode;
    }

    private PipelineInstance getPipelineInstance() {

        if (pipelineInstance == null) {
            pipelineInstance = createPipelineInstance();
        }
        return pipelineInstance;
    }

    private PipelineInstanceNode getPipelineInstanceNode() {

        if (pipelineInstanceNode == null) {
            pipelineInstanceNode = createPipelineInstanceNode();
        }
        return pipelineInstanceNode;
    }

    private PipelineModuleDefinition getPipelineModuleDefinition() {

        if (pipelineModuleDefinition == null) {
            pipelineModuleDefinition = createPipelineModuleDefinition();
        }
        return pipelineModuleDefinition;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Pixel Response Function - PRF Characterization");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PrfPipelineModule.class));
        pipelineModuleDefinition.setExeName("prf");

        return pipelineModuleDefinition;
    }

    private PipelineTask createPipelineTask(long pipelineTaskId, int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        PipelineTask task = new PipelineTask(getPipelineInstance(),
            getPipelineDefinitionNode(), getPipelineInstanceNode());
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            ccdModule, ccdOutput, startCadence, endCadence)));
        task.setPipelineDefinitionNode(getPipelineDefinitionNode());

        return task;
    }

    private static UnitOfWorkTask createUowTask(int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {
        ModOutCadenceUowTask uowTask = new ModOutCadenceUowTask(ccdModule,
            ccdOutput, startCadence, endCadence);

        return uowTask;
    }

    private void createMockObjects() {

        setMockery(new JUnit4Mockery() {
            {
                setImposteriser(ClassImposteriser.INSTANCE);
            }
        });

        setBlobOperations(getMockery().mock(BlobOperations.class));
        setDaCrud(getMockery().mock(DataAccountabilityTrailCrud.class));
        setFsClient(getMockery().mock(FileStoreClient.class));
        setCelestialObjectOperations(getMockery().mock(
            CelestialObjectOperations.class));
        setLogCrud(getMockery().mock(LogCrud.class));
        setPaCrud(getMockery().mock(PaCrud.class));
        setPrfCrud(getMockery().mock(PrfCrud.class));
        setRaDec2PixOperations(getMockery().mock(RaDec2PixOperations.class));
        setTargetCrud(getMockery().mock(TargetCrud.class));

        FileStoreClientFactory.setInstance(getFsClient());
    }

    protected void createOutputs(PrfInputs prfInputs, PrfOutputs prfOutputs)
        throws IOException {

        createOutputs();

        prfOutputs.setPrfBlobFileName(PRF_BLOB_FILE_NAME);
        prfOutputs.setMotionBlobFileName(MOTION_BLOB_FILE_NAME);
        prfOutputs.setCentroids(centroids);
    }

    protected PrfPipelineModule getPipelineModule() {
        if (pipelineModule == null) {
            if (forceMultipleTables) {
                pipelineModule = new PrfPipelineModuleNullScience(this, false);
            } else {
                pipelineModule = new PrfPipelineModuleNullScience(this);
            }
        }
        return pipelineModule;
    }

    protected void populateObjects() {

        createMockObjects();
        setMockObjects(getPipelineModule());
        setPipelineTask(createPipelineTask(PIPELINE_TASK_ID, CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE));
        getPipelineModule().setPipelineTask(getPipelineTask());
        getPipelineModule().setPipelineInstance(createPipelineInstance());
        getPipelineModule().setMatlabWorkingDir(MATLAB_WORKING_DIR);
        reset();
    }

    private void setMockObjects(PrfPipelineModule pipelineModule) {

        pipelineModule.setDaCrud(getDaCrud());
        pipelineModule.setBlobOperations(getBlobOperations());
        pipelineModule.setCelestialObjectOperations(getCelestialObjectOperations());
        pipelineModule.setPaCrud(getPaCrud());
        pipelineModule.setPrfCrud(getPrfCrud());
        pipelineModule.setRaDec2PixOperations(getRaDec2PixOperations());
        pipelineModule.setTargetCrud(getTargetCrud());
    }

    protected void createInputs(boolean createTargetTableLogs) {

        // create test data
        List<PixelLog> pixelLogs = MockUtils.mockPixelLogs(getMockery(),
            getLogCrud(), CadenceType.LONG, START_CADENCE, END_CADENCE);
        List<TargetTable> targetTables = createTargetTables(
            TargetType.LONG_CADENCE, TARGET_TABLE_ID, OBSERVING_SEASON,
            pixelLogs);
        setTargetTable(targetTables.get(0));
        if (createTargetTableLogs) {
            createTargetTableLogs(TargetType.LONG_CADENCE, targetTables,
                START_CADENCE, START_CADENCE, END_CADENCE);
        }
        createRaDec2PixModel(getStartMjd(pixelLogs), getEndMjd(pixelLogs));
        List<ObservedTarget> targets = createTargets(getTargetTable(),
            TARGETS_PER_MODULE_OUTPUT, PIXELS_PER_TARGET, CCD_MODULE,
            CCD_OUTPUT);
        prfTargets = createPrfTargets(targets);
        List<FloatTimeSeries> timeSeries = createPixelTimeSeries(CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE, prfTargets,
            PRODUCER_TASK_ID);

        createReadTimeSeriesExpectations(timeSeries, START_CADENCE, END_CADENCE);

        final Set<Long> taskIds = new HashSet<Long>();
        backgroundCoeffBlob = createBackgroundBlobSeries(CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE, PRODUCER_TASK_ID - 1);
        taskIds.add(PRODUCER_TASK_ID - 1);
        motionPolyBlob = createMotionBlobSeries(CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, PRODUCER_TASK_ID - 2);
        fpgGeometryBlob = createFpgGeometryBlobSeries(START_CADENCE,
            END_CADENCE);
        calUncertaintiyBlob = createCalUncertaintiyBlobSeries(START_CADENCE,
            END_CADENCE, CCD_MODULE, CCD_OUTPUT);

        taskIds.add(PRODUCER_TASK_ID - 2);
    }

    void validate(PrfInputs prfInputs) {

        assertNotNull(prfInputs);

        // verify target time series
        List<PrfTarget> targetStars = prfInputs.getTargetStarsStruct();
        assertNotNull(targetStars);
        assertEquals(prfTargets.size(), targetStars.size());
        assertEquals(prfTargets, targetStars);

        assertNotNull(prfInputs.getBackgroundBlobsStruct());
        assertEquals(1, prfInputs.getBackgroundBlobsStruct()
            .getBlobFilenames().length);
        assertEquals(backgroundCoeffBlob, prfInputs.getBackgroundBlobsStruct());

        assertNotNull(prfInputs.getMotionBlobsStruct());
        assertEquals(1, prfInputs.getMotionBlobsStruct()
            .getBlobFilenames().length);
        assertEquals(motionPolyBlob, prfInputs.getMotionBlobsStruct());
        assertEquals(fpgGeometryBlob, prfInputs.getFpgGeometryBlobsStruct());
        assertEquals(calUncertaintiyBlob,
            prfInputs.getCalUncertaintyBlobsStruct());
    }

    void validate(PrfOutputs prfOutputs) {

        assertNotNull(prfOutputs);
        assertNotNull(prfOutputs.getMotionBlobFileName());
        assertEquals(MOTION_BLOB_FILE_NAME, prfOutputs.getMotionBlobFileName());
        assertNotNull(prfOutputs.getPrfBlobFileName());
        assertEquals(PRF_BLOB_FILE_NAME, prfOutputs.getPrfBlobFileName());
        assertNotNull(prfOutputs.getCentroids());
        assertEquals(centroids, prfOutputs.getCentroids());
    }

    private void reset() {

        producerTaskIds = new HashSet<Long>();
        keplerIdInUse = new boolean[MAX_KEPLER_ID];
        columnInUse = new boolean[FcConstants.nColsImaging - PIXELS_PER_TARGET
            + FcConstants.nLeadingBlack];
        rowInUse = new boolean[FcConstants.nRowsImaging - PIXELS_PER_TARGET
            + FcConstants.nMaskedSmear];
    }

    private void createOutputs() throws IOException {

        createPrfCollectionBlob(CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, PIPELINE_TASK_ID);
        createMotionPolyBlob(CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, CadenceType.LONG, PIPELINE_TASK_ID);
        centroids = createCentroids(prfTargets, START_CADENCE, END_CADENCE,
            CadenceType.LONG, PIPELINE_TASK_ID);
        createPrfConvergence();

        MockUtils.mockDataAccountabilityTrail(getMockery(), getDaCrud(),
            getPipelineTask(), producerTaskIds);
    }

    private void createPrfConvergence() {
        final PrfConvergence prfConvergence = new PrfConvergence(false,
            getPipelineTask(), 0.0);
        getMockery().checking(new Expectations() {
            {
                one(getPrfCrud()).create(prfConvergence);
            }
        });

    }

    private List<TargetTable> createTargetTables(TargetType targetType,
        int targetTableId, int observingSeason, List<PixelLog> pixelLogs) {

        List<TargetTable> targetTables = new ArrayList<TargetTable>();

        TargetTable targetTable = new TargetTable(targetType);
        Date startMjd = ModifiedJulianDate.mjdToDate(getStartMjd(pixelLogs));
        Date endMjd = ModifiedJulianDate.mjdToDate(getEndMjd(pixelLogs));
        targetTable.setPlannedStartTime(startMjd);
        targetTable.setPlannedEndTime(endMjd);
        targetTable.setExternalId(targetTableId);
        targetTable.setObservingSeason(observingSeason);
        targetTables.add(targetTable);

        if (forceMultipleTables) {
            targetTable = new TargetTable(targetType);
            targetTable.setPlannedStartTime(startMjd);
            targetTable.setPlannedEndTime(endMjd);
            targetTable.setExternalId(targetTableId);
            targetTable.setObservingSeason(observingSeason);
            targetTables.add(targetTable);
        }

        return targetTables;
    }

    private List<TargetTableLog> createTargetTableLogs(
        final TargetType targetType, List<TargetTable> targetTables,
        final int tableStartCadence, final int startCadence,
        final int endCadence) {

        final List<TargetTableLog> targetTableLogs = new ArrayList<TargetTableLog>();
        if (!isForceFatalException()) {
            for (TargetTable targetTable : targetTables) {
                TargetTableLog targetTableLog = new TargetTableLog(targetTable,
                    tableStartCadence, endCadence);
                targetTableLogs.add(targetTableLog);
            }
        }

        getMockery().checking(new Expectations() {
            {
                log.debug("expecting: retrieveTargetTableLogs(): targetType="
                    + targetType + "; startCadence=" + startCadence
                    + "; endCadence=" + endCadence);
                one(getTargetCrud()).retrieveTargetTableLogs(
                    with(equal(targetType)), with(equal(startCadence)),
                    with(equal(endCadence)));
                will(returnValue(targetTableLogs));
            }
        });
        return targetTableLogs;
    }

    private List<ObservedTarget> createTargets(final TargetTable targetTable,
        int targetsPerModuleOutput, int pixelsPerTarget, final int ccdModule,
        final int ccdOutput) {

        final List<ObservedTarget> targets = new ArrayList<ObservedTarget>();

        for (int targetIndex = 0; targetIndex < targetsPerModuleOutput; targetIndex++) {
            int keplerId = getNextKeplerId();
            int referenceRow = getNextRow();
            int referenceColumn = getNextColumn();
            List<Offset> pixelsList = new ArrayList<Offset>();
            for (int p = 0; p < pixelsPerTarget; p++) {
                Offset aperturePixel = new Offset(p, p);
                pixelsList.add(aperturePixel);
            }
            MaskTable apertureTable = new MaskTable(MaskType.TARGET);
            apertureTable.setExternalId(targetIndex);
            Mask mask = new Mask(apertureTable, pixelsList);
            TargetDefinition targetDefinition = new TargetDefinition(
                referenceRow, referenceColumn, 0, mask);
            targetDefinition.setIndexInModuleOutput(targetIndex);
            List<TargetDefinition> targetDefinitions = new ArrayList<TargetDefinition>();
            targetDefinitions.add(targetDefinition);
            Aperture optimalAperture = new Aperture(false, referenceRow,
                referenceColumn, pixelsList);
            ObservedTarget target = new ObservedTarget(targetTable, ccdModule,
                ccdOutput, keplerId);
            target.setAperture(optimalAperture);
            target.setTargetDefinitions(targetDefinitions);
            targets.add(target);
        }

        getMockery().checking(new Expectations() {
            {
                one(getTargetCrud()).retrieveObservedTargets(
                    with(equal(targetTable)), with(equal(ccdModule)),
                    with(equal(ccdOutput)));
                will(returnValue(targets));
            }
        });
        return targets;
    }

    private List<PrfTarget> createPrfTargets(List<ObservedTarget> targets) {

        List<PrfTarget> prfTargets = new ArrayList<PrfTarget>();
        for (ObservedTarget target : targets) {

            final int keplerId = target.getKeplerId();

            Kic.Builder kicBuilder = new Kic.Builder(target.getKeplerId(),
                DEFAULT_RA, DEFAULT_DEC).keplerMag(DEFAULT_MAG);
            final Kic kic = kicBuilder.build();

            final CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
                kic).build();

            getMockery().checking(new Expectations() {
                {
                    one(getCelestialObjectOperations()).retrieveCelestialObjectParameters(
                        keplerId);
                    will(returnValue(celestialObjectParameters));
                }
            });

            PrfTarget prfTarget = new PrfTarget(keplerId, kic.getKeplerMag(),
                kic.getRa(), kic.getDec(), target.getAperture()
                    .getReferenceRow(), target.getAperture()
                    .getReferenceColumn(), (float) target.getCrowdingMetric(),
                (float) target.getFluxFractionInAperture());

            List<PrfPixelTimeSeries> pixels = new ArrayList<PrfPixelTimeSeries>();
            for (TargetDefinition definition : target.getTargetDefinitions()) {
                for (Offset offset : definition.getMask()
                    .getOffsets()) {
                    int row = target.getAperture()
                        .getReferenceRow() + offset.getRow();
                    int column = target.getAperture()
                        .getReferenceColumn() + offset.getColumn();
                    PrfPixelTimeSeries pixel = new PrfPixelTimeSeries(row,
                        column, true);
                    pixels.add(pixel);
                }
            }
            prfTarget.setPrfPixelTimeSeries(pixels);
            prfTargets.add(prfTarget);

        }

        return prfTargets;
    }

    private List<FloatTimeSeries> createPixelTimeSeries(int ccdModule,
        int ccdOutput, int startCadence, int endCadence,
        List<PrfTarget> prfTargets, long producerTaskId) {

        List<FsId> timeSeriesFsIds = new ArrayList<FsId>();
        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();
        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>();

        int numCadences = endCadence - startCadence + 1;

        List<TaggedInterval> originators = new ArrayList<TaggedInterval>();
        originators.add(new TaggedInterval(startCadence, endCadence,
            producerTaskId));
        producerTaskIds.add(producerTaskId);

        for (PrfTarget target : prfTargets) {

            List<FsId> ids = PrfCentroidTimeSeries.fsIdsFor(target.getKeplerId());
            for (FsId id : ids) {
                float[] data = new float[numCadences];
                Arrays.fill(data, random.nextFloat());
                FloatTimeSeries fts = new FloatTimeSeries(id, data,
                    startCadence, endCadence, new boolean[numCadences],
                    producerTaskId);
                timeSeriesFsIds.add(id);
                floatTimeSeries.add(fts);
                timeSeriesByFsId.put(id, fts);
            }

            int gapIndex = getRandomGap();
            int gapCadence = startCadence + gapIndex;
            for (PrfPixelTimeSeries pixel : target.getPrfPixelTimeSeries()) {

                float[] values = new float[numCadences];
                Arrays.fill(values, random.nextFloat());
                float[] uncerts = new float[numCadences];
                Arrays.fill(uncerts, random.nextFloat());

                List<SimpleInterval> validCadences = getValidCadences(
                    startCadence, endCadence, gapCadence);

                FsId fsId = CalFsIdFactory.getTimeSeriesFsId(
                    CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                    TargetType.LONG_CADENCE, ccdModule, ccdOutput,
                    pixel.getRow(), pixel.getColumn());
                FloatTimeSeries timeSeries = new FloatTimeSeries(fsId, values,
                    startCadence, endCadence, validCadences, originators);
                timeSeriesByFsId.put(fsId, timeSeries);
                timeSeriesFsIds.add(fsId);
                floatTimeSeries.add(timeSeries);

                fsId = CalFsIdFactory.getTimeSeriesFsId(
                    CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                    TargetType.LONG_CADENCE, ccdModule, ccdOutput,
                    pixel.getRow(), pixel.getColumn());
                timeSeries = new FloatTimeSeries(fsId, uncerts, startCadence,
                    endCadence, validCadences, originators);
                timeSeriesByFsId.put(fsId, timeSeries);
                timeSeriesFsIds.add(fsId);
                floatTimeSeries.add(timeSeries);

            }
            target.setAllTimeSeries(ccdModule, ccdOutput, startCadence,
                endCadence, timeSeriesByFsId);
        }
        return floatTimeSeries;
    }

    private void createReadTimeSeriesExpectations(
        final List<FloatTimeSeries> floatTimeSeries, final int startCadence,
        final int endCadence) {

        final FsId[] fsIds = new FsId[floatTimeSeries.size()];
        for (int i = 0; i < floatTimeSeries.size(); i++) {
            fsIds[i] = floatTimeSeries.get(i)
                .id();
        }

        getMockery().checking(new Expectations() {
            {
                one(getFsClient()).readTimeSeriesAsFloat(with(equal(fsIds)),
                    with(equal(startCadence)), with(equal(endCadence)));
                will(returnValue(floatTimeSeries.toArray(new FloatTimeSeries[0])));
            }
        });
    }

    // private List<FloatTimeSeries> createTimeSeries(List<FsId> fsIds,
    // int startCadence, int endCadence, int gapCadence, long producerTaskId,
    // Map<FsId, FloatTimeSeries> timeSeriesByFsId) {
    //
    // FloatTimeSeries[] floatTimeSeries = new FloatTimeSeries[fsIds.size()];
    // List<FloatTimeSeries> timeSeriesList = new ArrayList<FloatTimeSeries>();
    //
    // for (int i = 0; i < floatTimeSeries.length; i++) {
    // float[] values = new float[endCadence - startCadence + 1];
    // Arrays.fill(values, random.nextFloat());
    // floatTimeSeries[i] = new FloatTimeSeries(fsIds.get(i), values,
    // startCadence, endCadence,
    // new int[] { gapCadence - startCadence }, producerTaskId);
    // if (timeSeriesByFsId != null) {
    // timeSeriesByFsId.put(fsIds.get(i), floatTimeSeries[i]);
    // }
    // timeSeriesList.add(floatTimeSeries[i]);
    // }
    // producerTaskIds.add(producerTaskId);
    //
    // return timeSeriesList;
    // }

    private BlobFileSeries createBackgroundBlobSeries(final int ccdModule,
        final int ccdOutput, final int startCadence, final int endCadence,
        long producerTaskId) {

        producerTaskIds.add(producerTaskId);
        BlobSeries<String> blobSeries = MockUtils.mockBackgroundBlobFileSeries(
            getMockery(), getBlobOperations(), ccdModule, ccdOutput,
            startCadence, endCadence, producerTaskId);
        return new BlobFileSeries(blobSeries);
    }

    private BlobFileSeries createMotionBlobSeries(final int ccdModule,
        final int ccdOutput, final int startCadence, final int endCadence,
        long producerTaskId) {

        producerTaskIds.add(producerTaskId);
        BlobSeries<String> blobSeries = MockUtils.mockMotionBlobFileSeries(
            getMockery(), getBlobOperations(), ccdModule, ccdOutput,
            startCadence, endCadence, producerTaskId);
        return new BlobFileSeries(blobSeries);
    }

    private BlobFileSeries createFpgGeometryBlobSeries(final int startCadence,
        final int endCadence) {
        producerTaskIds.add(FPG_PRODUCER_TASK_ID);

        int cadenceLength = endCadence - startCadence;
        final BlobSeries<String> blobSeries = new BlobSeries<String>(
            new int[cadenceLength], new boolean[cadenceLength],
            new String[] { "fpggeometry.mat" },
            new long[] { FPG_PRODUCER_TASK_ID }, startCadence, endCadence);
        getMockery().checking(new Expectations() {
            {
                one(getBlobOperations()).retrieveFpgGeometryBlob(startCadence,
                    endCadence);
                will(returnValue(blobSeries));
            }
        });
        return new BlobFileSeries(blobSeries);
    }

    private BlobFileSeries createCalUncertaintiyBlobSeries(
        final int startCadence, final int endCadence, final int ccdModule,
        final int ccdOutput) {

        int cadenceLength = endCadence - startCadence;
        final BlobSeries<String> blobSeries = new BlobSeries<String>(
            new int[cadenceLength], new boolean[cadenceLength],
            new String[] { "caluncert" }, new long[] { CAL_PRODUCER_TASK_ID },
            startCadence, endCadence);

        getMockery().checking(new Expectations() {
            {
                one(getBlobOperations()).retrieveCalUncertaintiesBlobFileSeries(
                    ccdModule, ccdOutput, CadenceType.LONG, startCadence,
                    endCadence);
                will(returnValue(blobSeries));
            }
        });

        return new BlobFileSeries(blobSeries);
    }

    private List<PrfCentroidTimeSeries> createCentroids(
        List<PrfTarget> targets, int startCadence, int endCadence,
        CadenceType cadenceType, long pipelineTaskId) {

        final List<FloatTimeSeries> centroidTimeSeries = new ArrayList<FloatTimeSeries>();
        List<PrfCentroidTimeSeries> centroids = new ArrayList<PrfCentroidTimeSeries>();

        for (PrfTarget target : targets) {

            float[] row = new float[endCadence - startCadence + 1];
            Arrays.fill(row, random.nextFloat());
            float[] rowUncert = new float[endCadence - startCadence + 1];
            Arrays.fill(rowUncert, random.nextFloat());
            float[] column = new float[endCadence - startCadence + 1];
            Arrays.fill(column, random.nextFloat());
            float[] columnUncert = new float[endCadence - startCadence + 1];
            Arrays.fill(columnUncert, random.nextFloat());

            PrfCentroidTimeSeries centroid = new PrfCentroidTimeSeries(
                target.getKeplerId(), row, rowUncert, column, columnUncert,
                target.getGapIndices());
            centroids.add(centroid);

            centroidTimeSeries.addAll(centroid.getAllFloatTimeSeries(
                startCadence, endCadence, pipelineTaskId));
        }

        getMockery().checking(new Expectations() {
            {
                one(getFsClient()).writeTimeSeries(
                    with(equal(centroidTimeSeries.toArray(new FloatTimeSeries[0]))));
            }
        });
        return centroids;
    }

    private File createMotionPolyBlob(int ccdModule, int ccdOutput,
        final int startCadence, final int endCadence,
        final CadenceType cadenceType, final long pipelineTaskId)
        throws IOException {

        final File blobFile = createBlobFile(MOTION_BLOB_FILE_NAME);
        final MotionBlobMetadata metadata = new MotionBlobMetadata(
            pipelineTaskId, ccdModule, ccdOutput, startCadence, endCadence,
            FilenameUtils.getExtension(MOTION_BLOB_FILE_NAME));
        final FsId fsId = PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.MOTION, metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
        final List<MotionBlobMetadata> metadataList = new ArrayList<MotionBlobMetadata>();
        metadataList.add(metadata);
        getMockery().checking(new Expectations() {
            {
                one(getFsClient()).writeBlob(with(equal(fsId)),
                    with(equal(pipelineTaskId)), with(equal(blobFile)));
                one(getPaCrud()).createMotionBlobMetadata(with(equal(metadata)));
            }
        });

        return blobFile;
    }

    private void createRaDec2PixModel(final double startMjd, final double endMjd) {

        double[] mjds = new double[2];
        mjds[0] = startMjd;
        mjds[1] = endMjd;

        double[] ras = new double[2];
        double[] declinations = new double[2];
        double[] rolls = new double[2];
        double[] segmentStartMjds = new double[2];
        final PointingModel pointingModel = new PointingModel(mjds, ras,
            declinations, rolls, segmentStartMjds);

        double[][] constants = new double[2][2];
        final GeometryModel geometryModel = new GeometryModel(mjds, constants);

        int[] seasons = new int[2];
        final RollTimeModel rollTimeModel = new RollTimeModel(mjds, seasons);

        String spiceFileDir = new String();
        String spiceFileName = new String();
        String planetaryEphemerisFileName = new String();
        String leapSecondsFileName = new String();

        final RaDec2PixModel finalRaDec2PixModel = new RaDec2PixModel(startMjd,
            endMjd, pointingModel, geometryModel, rollTimeModel, spiceFileDir,
            spiceFileName, planetaryEphemerisFileName, leapSecondsFileName);
        getMockery().checking(new Expectations() {
            {
                one(getRaDec2PixOperations()).retrieveRaDec2PixModel(
                    with(equal(startMjd)), with(equal(endMjd)));
                will(returnValue(finalRaDec2PixModel));
            }
        });
    }

    private File createPrfCollectionBlob(final int ccdModule,
        final int ccdOutput, final int startCadence, final int endCadence,
        final long pipelineTaskId) throws IOException {

        final File blobFile = createBlobFile(PRF_BLOB_FILE_NAME);
        final PrfBlobMetadata metadata = new PrfBlobMetadata(pipelineTaskId,
            ccdModule, ccdOutput, startCadence, endCadence,
            FilenameUtils.getExtension(PRF_BLOB_FILE_NAME));
        final FsId fsId = PrfFsIdFactory.getMatlabBlobFsId(
            PrfFsIdFactory.BlobSeriesType.PRF_COLLECTION,
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getStartCadence(), metadata.getPipelineTaskId());
        getMockery().checking(new Expectations() {
            {
                one(getFsClient()).writeBlob(with(equal(fsId)),
                    with(equal(pipelineTaskId)), with(equal(blobFile)));
                one(getPrfCrud()).createPrfBlobMetadata(with(equal(metadata)));
            }
        });
        return blobFile;
    }

    private byte[] createBlob(int size) {

        byte[] blob = new byte[size];
        random.nextBytes(blob);
        return blob;
    }

    private File createBlobFile(String fileName) throws IOException {

        File blobFile = new File(MATLAB_WORKING_DIR, fileName);
        FileOutputStream output = new FileOutputStream(blobFile);
        output.write(createBlob(BLOB_SIZE));
        output.close();
        return blobFile;
    }

    private int getNextKeplerId() {
        int nextKeplerId = random.nextInt(MAX_KEPLER_ID);
        while (keplerIdInUse[nextKeplerId]) {
            nextKeplerId = random.nextInt(MAX_KEPLER_ID);
        }
        keplerIdInUse[nextKeplerId] = true;
        return nextKeplerId + 100000000;
    }

    private short getNextRow() {

        short nextRow = (short) (random.nextInt(FcConstants.nRowsImaging
            - PIXELS_PER_TARGET) + FcConstants.nMaskedSmear);
        while (rowInUse[nextRow]) {
            nextRow = (short) (random.nextInt(FcConstants.nRowsImaging
                - PIXELS_PER_TARGET) + FcConstants.nMaskedSmear);
        }
        rowInUse[nextRow] = true;
        return nextRow;
    }

    private short getNextColumn() {

        short nextColumn = (short) (random.nextInt(FcConstants.nColsImaging
            - PIXELS_PER_TARGET) + FcConstants.nLeadingBlack);
        while (columnInUse[nextColumn]) {
            nextColumn = (short) (random.nextInt(FcConstants.nColsImaging
                - PIXELS_PER_TARGET) + FcConstants.nLeadingBlack);
        }
        columnInUse[nextColumn] = true;
        return nextColumn;
    }

    private List<SimpleInterval> getValidCadences(int startCadence,
        int endCadence, int gapCadence) {

        List<SimpleInterval> cadences = new ArrayList<SimpleInterval>();
        int intervalStart = startCadence;
        int pixelGapCadence = startCadence + getRandomGap();
        for (int cadence = intervalStart; cadence <= endCadence; cadence++) {
            if (cadence == gapCadence || cadence == pixelGapCadence) {
                if (cadence != intervalStart) {
                    cadences.add(new SimpleInterval(intervalStart, cadence - 1));
                }
                intervalStart = cadence + 1;
            } else if (cadence == endCadence) {
                cadences.add(new SimpleInterval(intervalStart, cadence));
            }
        }
        return cadences;
    }

    private double getStartMjd(List<PixelLog> pixelLogs) {
        return pixelLogs.get(0)
            .getMjdStartTime();
    }

    private double getEndMjd(List<PixelLog> pixelLogs) {
        return pixelLogs.get(pixelLogs.size() - 1)
            .getMjdEndTime();
    }

    private int getRandomGap() {
        return random.nextInt(END_CADENCE - START_CADENCE + 1);
    }

    // accessors

    protected BlobOperations getBlobOperations() {
        return blobOperations;
    }

    private void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    protected DataAccountabilityTrailCrud getDaCrud() {
        return daCrud;
    }

    private void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    public boolean isForceFatalException() {
        return forceFatalException;
    }

    public void setForceFatalException(boolean forceFatalException) {
        this.forceFatalException = forceFatalException;
    }

    public void setForceMultipleTables(boolean forceMultipleTables) {
        this.forceMultipleTables = forceMultipleTables;
    }

    protected FileStoreClient getFsClient() {
        return fsClient;
    }

    private void setFsClient(FileStoreClient fsClient) {
        this.fsClient = fsClient;
    }

    protected CelestialObjectOperations getCelestialObjectOperations() {
        return celestialObjectOperations;
    }

    private void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    protected LogCrud getLogCrud() {
        return logCrud;
    }

    private void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    protected Mockery getMockery() {
        return mockery;
    }

    private void setMockery(Mockery mockery) {
        this.mockery = mockery;
    }

    protected PaCrud getPaCrud() {
        return paCrud;
    }

    private void setPaCrud(PaCrud paCrud) {
        this.paCrud = paCrud;
    }

    private PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    private void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    protected PrfCrud getPrfCrud() {
        return prfCrud;
    }

    private void setPrfCrud(PrfCrud prfCrud) {
        this.prfCrud = prfCrud;
    }

    protected RaDec2PixOperations getRaDec2PixOperations() {
        return raDec2PixOperations;
    }

    private void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    protected TargetCrud getTargetCrud() {
        return targetCrud;
    }

    private void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    private TargetTable getTargetTable() {
        return targetTable;
    }

    private void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

}
