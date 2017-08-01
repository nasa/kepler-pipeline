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

package gov.nasa.kepler.fpg;

import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.getMatlabBlobFsId;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_GEOMETRY;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_IMPORT;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_RESULTS;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.fc.GeometryModel;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.kepler.hibernate.mc.AbstractCadenceBlob;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
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
import gov.nasa.kepler.hibernate.prf.FpgGeometryBlobMetadata;
import gov.nasa.kepler.hibernate.prf.FpgImportBlobMetadata;
import gov.nasa.kepler.hibernate.prf.FpgResultsBlobMetadata;
import gov.nasa.kepler.hibernate.prf.PrfCrud;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jmock.Expectations;
import org.jmock.Mockery;

/**
 * @author Sean McCauliff
 * 
 */
abstract class AbstractFpgPipelineModuleTest {
    protected static final Log log = LogFactory.getLog(AbstractFpgPipelineModuleTest.class);

    public static final String PROP_FILE = Filenames.ETC + "/kepler.properties";

    private static final long TASK_ID = System.currentTimeMillis();
    private static final long INSTANCE_ID = TASK_ID - 42;

    protected static final Long MOTION_BLOB_ORIGINATOR = 7L;
    protected static final Long GEOMETRY_BLOB_ORIGINATOR = 8L;
    protected static final String MATLAB_EXE_DIR = Filenames.BUILD_TEST
        + "AbstractFpgPipelineModuleTest.test";

    private static final String GEOMETRY_OUT_FNAME = "geometry-out-fname.mat";
    private static final String REPORT_FNAME = "report-fname.jpg";

    private static final String IMPORT_OUT_FNAME = "import-fname.txt";

    private static final String RESULTS_OUT_FNAME = "results.mat";

    private RaDec2PixOperations raDec2PixOperations;
    private MjdToCadence mjdToCadence;
    private BlobOperations blobOperations;
    private DataAccountabilityTrailCrud daTrailCrud;
    private PrfCrud prfCrud;

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private PipelineDefinitionNode pipelineDefinitionNode;
    private PipelineInstanceNode pipelineInstanceNode;
    private PipelineModuleDefinition pipelineModuleDefinition;
    private FileStoreClient fsClient;
    private DoubleDbTimeSeriesCrud dddCrud;
    private GenericReportOperations reportOps;

    private Random rand = new Random(7);

    AbstractFpgPipelineModuleTest() {
    }

    protected void populateObjects() throws IOException {
        fsClient = getMockery().mock(FileStoreClient.class);
        raDec2PixOperations = getMockery().mock(RaDec2PixOperations.class);
        mjdToCadence = getMockery().mock(MjdToCadence.class);
        blobOperations = getMockery().mock(BlobOperations.class);
        daTrailCrud = getMockery().mock(DataAccountabilityTrailCrud.class);
        prfCrud = getMockery().mock(PrfCrud.class);
        dddCrud = getMockery().mock(DoubleDbTimeSeriesCrud.class);
        reportOps = getMockery().mock(GenericReportOperations.class);

        pipelineInstance = createPiplineInstance();
        pipelineModuleDefinition = createPipelineModuleDefinition();
        pipelineDefinitionNode = createPipelineDefinitionNode(pipelineModuleDefinition);
        pipelineInstanceNode = createPipelineInstanceNode(pipelineInstance,
            pipelineDefinitionNode, pipelineModuleDefinition);

        pipelineTask = createPipelineTask(pipelineInstance,
            pipelineDefinitionNode, pipelineInstanceNode, getStartCadence(),
            getEndCadence());

        createBlobOperations();
        createMjdToCadence();
        createRaDec2PixOperations();
        createFileStore();
        createPrfCrud();
        createDataAccountabilityTrailCrud();
        createReportOps();

        getPipelineModule().setBlobOperations(blobOperations);
        getPipelineModule().setDaTrailCrud(daTrailCrud);
        getPipelineModule().setMjdToCadence(mjdToCadence);
        getPipelineModule().setPrfCrud(prfCrud);
        getPipelineModule().setRaDec2PixOperations(raDec2PixOperations);
        getPipelineModule().setDddCrud(dddCrud);
        getPipelineModule().setReportOps(reportOps);
        FileStoreClientFactory.setInstance(fsClient);
    }

    private static PipelineDefinitionNode createPipelineDefinitionNode(
        PipelineModuleDefinition pipelineModuleDefinition) {

        return new PipelineDefinitionNode(pipelineModuleDefinition.getName());

    }

    private static PipelineInstance createPiplineInstance() {
        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(INSTANCE_ID);

        return pipelineInstance;

    }

    private static PipelineModuleDefinition createPipelineModuleDefinition() {
        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "fpg");
        pipelineModuleDefinition.setDescription("Description.");
        pipelineModuleDefinition.setExeTimeoutSecs(Integer.MAX_VALUE);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            FpgPipelineModule.class));

        return pipelineModuleDefinition;
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode,
        PipelineModuleDefinition pipelineModuleDefinition) {

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode();
        pipelineInstanceNode = new PipelineInstanceNode(pipelineInstance,
            pipelineDefinitionNode, pipelineModuleDefinition);

        FpgModuleParameters fpgModuleParameters = new FpgModuleParameters();
        fpgModuleParameters.setBootstrapGeometryModel(false);

        ParameterSet fpgParameterSet = new ParameterSet("fpg");
        fpgParameterSet.setParameters(new BeanWrapper<Parameters>(
            fpgModuleParameters));

        ParameterSet cadenceParameterSet = new ParameterSet("cadence");
        CadenceRangeParameters cRangeParameters = new CadenceRangeParameters(
            getStartCadence(), getEndCadence());
        cadenceParameterSet.setParameters(new BeanWrapper<Parameters>(
            cRangeParameters));

        pipelineInstanceNode.putModuleParameterSet(FpgModuleParameters.class,
            fpgParameterSet);
        pipelineInstanceNode.putModuleParameterSet(
            CadenceRangeParameters.class, cadenceParameterSet);
        return pipelineInstanceNode;
    }

    private static PipelineTask createPipelineTask(
        PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode,
        PipelineInstanceNode pipelineInstanceNode, int startCadence,
        int endCadence) {

        PipelineTask task = new PipelineTask(pipelineInstance,
            pipelineDefinitionNode, pipelineInstanceNode);
        task.setId(TASK_ID);

        SingleUowTask uow = SingleUowTask.INSTANCE;

        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(uow));

        return task;
    }

    private FpgAttitudeSolution createDoubleDbTimeSeriesCrud() {
        double[] raValues = randDoubles(getCadenceLength());
        double[] raUncert = randDoubles(getCadenceLength());
        FpgAttitudeTimeSeries ra = new FpgAttitudeTimeSeries(raValues,
            raUncert, ArrayUtils.EMPTY_INT_ARRAY);
        double[] decValues = randDoubles(getCadenceLength());
        double[] decUncert = randDoubles(getCadenceLength());

        FpgAttitudeTimeSeries dec = new FpgAttitudeTimeSeries(decValues,
            decUncert, ArrayUtils.EMPTY_INT_ARRAY);

        double[] rollValues = randDoubles(getCadenceLength());
        double[] rollUncert = randDoubles(getCadenceLength());

        FpgAttitudeTimeSeries roll = new FpgAttitudeTimeSeries(rollValues,
            rollUncert, ArrayUtils.EMPTY_INT_ARRAY);

        final FpgAttitudeSolution attitudeSolution = new FpgAttitudeSolution(
            ra, dec, roll);

        getMockery().checking(new Expectations() {
            {
                for (DoubleDbTimeSeries aSeries : attitudeSolution.toDoubleDbTimeSeries(
                    getStartCadence(), getEndCadence(), TASK_ID)) {
                    one(dddCrud).create(aSeries);
                }
            }
        });

        return attitudeSolution;

    }

    private double[] randDoubles(int size) {
        double[] rv = new double[size];
        for (int i = 0; i < rv.length; i++) {
            rv[i] = rand.nextDouble();
        }
        return rv;
    }

    private void createBlobOperations() {
        final int[] blobIndices = new int[getEndCadence() - getStartCadence()
            + 1];
        final boolean[] gapIndicators = new boolean[blobIndices.length];
        final String[] blobFileNames = { "motion-blob.mat" };
        final long[] originators = { MOTION_BLOB_ORIGINATOR };

        getMockery().checking(new Expectations() {
            {
                for (int ccdModule : FcConstants.modulesList) {
                    for (int ccdOutput : FcConstants.outputsList) {
                        one(blobOperations).retrieveMotionBlobFileSeries(
                            ccdModule, ccdOutput, getStartCadence(),
                            getEndCadence());

                        BlobSeries<String> blobSeries = new BlobSeries<String>(
                            blobIndices, gapIndicators, blobFileNames,
                            originators, getStartCadence(), getEndCadence());
                        will(returnValue(blobSeries));
                    }
                }
            }
        });
    }

    private void createReportOps() throws IOException {
        final File reportFile = new File(getMatlabWorkingDir(), REPORT_FNAME).getCanonicalFile();
        getMockery().checking(new Expectations() {
            {
                one(reportOps).createReport(getPipelineTask(), reportFile);
            }
        });
    }

    private void createDataAccountabilityTrailCrud() {
        @SuppressWarnings("serial")
        final Set<Long> producerTaskIds = new HashSet<Long>() {
            {
                add(MOTION_BLOB_ORIGINATOR);
                add(GEOMETRY_BLOB_ORIGINATOR);
            }
        };
        MockUtils.mockDataAccountabilityTrail(getMockery(), daTrailCrud,
            pipelineTask, producerTaskIds);
    }

    private void createRaDec2PixOperations() {
        List<Pointing> pointings = new ArrayList<Pointing>();
        pointings.add(new Pointing(1.0, 55.0, 33.0, 0.1, 1.0));

        PointingModel pointingModel = new PointingModel(pointings);
        GeometryModel geometryModel = new GeometryModel(new double[] { 1.0 },
            new double[][] { { 1.0, 2.0, 3.0, 4.0, 5.0 } });
        RollTimeModel rolltimeModel = new RollTimeModel(new double[] { 90.0,
            180.0, 270.0, 360.0 }, new int[] { 1, 2, 3, 4 });

        final RaDec2PixModel raDec2PixModel = new RaDec2PixModel(0.0,
            Double.MAX_VALUE, pointingModel, geometryModel, rolltimeModel,
            "spiceFileDirName", "spiceFileName", "planetaryEphermerisFile",
            "leapsecondsFile");

        getMockery().checking(new Expectations() {
            {
                one(raDec2PixOperations).retrieveRaDec2PixModel(
                    getMjdStartTime(), getMjdEndTime());
                will(returnValue(raDec2PixModel));
            }
        });

    }

    private void createMjdToCadence() {
        double[] startTimeStamps = new double[getEndCadence()
            - getStartCadence() + 1];
        double[] midTimeStamps = new double[startTimeStamps.length];
        double[] endTimeStamps = new double[startTimeStamps.length];
        boolean[] booleanJunk = new boolean[startTimeStamps.length];
        int[] cadenceNumbers = new int[startTimeStamps.length];

        for (int i = 0; i < startTimeStamps.length; i++) {
            startTimeStamps[i] = i + getMjdStartTime();
            midTimeStamps[i] = i + getMjdStartTime() + 0.5;
            endTimeStamps[i] = i + getMjdStartTime() + 1.0;
            cadenceNumbers[i] = getStartCadence() + i;
        }

        final TimestampSeries compressedSeries = new TimestampSeries(
            startTimeStamps, midTimeStamps, endTimeStamps, booleanJunk,
            booleanJunk, cadenceNumbers, booleanJunk, booleanJunk, booleanJunk,
            booleanJunk, booleanJunk, booleanJunk, booleanJunk);

        getMockery().checking(new Expectations() {
            {
                one(mjdToCadence).cadenceTimes(getStartCadence(),
                    getEndCadence());
                will(returnValue(compressedSeries));

            }
        });
    }

    private void createPrfCrud() {
        final FpgGeometryBlobMetadata fpgGeoIn = new FpgGeometryBlobMetadata(
            getStartCadence(), getEndCadence(), GEOMETRY_BLOB_ORIGINATOR,
            ".mat");

        final FpgGeometryBlobMetadata fpgGeoOut = new FpgGeometryBlobMetadata(
            getStartCadence(), getEndCadence(), TASK_ID, ".mat");

        final FpgImportBlobMetadata importMeta = new FpgImportBlobMetadata(
            TASK_ID, getStartCadence(), getEndCadence(), ".txt");

        final FpgResultsBlobMetadata resultsMeta = new FpgResultsBlobMetadata(
            TASK_ID, getStartCadence(), getEndCadence(), ".mat");

        getMockery().checking(new Expectations() {
            {
                one(prfCrud).retrieveLastGeometryBlobMetadata();
                will(returnValue(fpgGeoIn));

                one(prfCrud).create((AbstractCadenceBlob) fpgGeoOut);

                one(prfCrud).create((AbstractCadenceBlob) importMeta);

                one(prfCrud).create((AbstractCadenceBlob) resultsMeta);
            }
        });
    }

    private void createFileStore() throws IOException {
        final FsId inGeoFsId = getMatlabBlobFsId(FPG_GEOMETRY,
            getStartCadence(), getEndCadence(), GEOMETRY_BLOB_ORIGINATOR);

        final File inGeoFile = new File(getMatlabWorkingDir(), "geometry-"
            + inGeoFsId.name() + ".mat");

        final FsId outGeoFsId = getMatlabBlobFsId(FPG_GEOMETRY,
            getStartCadence(), getEndCadence(), TASK_ID);
        final File outGeoFile = new File(getMatlabWorkingDir(),
            GEOMETRY_OUT_FNAME).getCanonicalFile();

        final FsId outImportId = getMatlabBlobFsId(FPG_IMPORT,
            getStartCadence(), getEndCadence(), TASK_ID);
        final File outImportFile = new File(getMatlabWorkingDir(),
            IMPORT_OUT_FNAME).getCanonicalFile();

        final FsId outResultId = getMatlabBlobFsId(FPG_RESULTS,
            getStartCadence(), getEndCadence(), TASK_ID);
        final File outResultsFile = new File(getMatlabWorkingDir(),
            RESULTS_OUT_FNAME).getCanonicalFile();

        getMockery().checking(new Expectations() {
            {
                one(fsClient).readBlob(inGeoFsId, inGeoFile);
                will(returnValue(GEOMETRY_BLOB_ORIGINATOR));

                one(fsClient).writeBlob(outGeoFsId, TASK_ID, outGeoFile);

                one(fsClient).writeBlob(outImportId, TASK_ID, outImportFile);

                one(fsClient).writeBlob(outResultId, TASK_ID, outResultsFile);
            }
        });
    }

    void generateOutputs(FpgInputs fpgInputs, FpgOutputs fpgOutputs) {

        try {
            File inputsFile = new File(getMatlabWorkingDir(),
                "fpg-test-inputs.0");
            testSerialization(fpgInputs, fpgInputs, inputsFile, false);

            File outputsFile = new File(getMatlabWorkingDir(),
                "fpg-test-ouputs.0");
            fpgOutputs.setGeometryBlobFileName(GEOMETRY_OUT_FNAME);
            fpgOutputs.setReportFileName(REPORT_FNAME);
            fpgOutputs.setFpgImportFileName(IMPORT_OUT_FNAME);
            fpgOutputs.setResultBlobFileName(RESULTS_OUT_FNAME);

            FpgAttitudeSolution prfAttitudeSolution = createDoubleDbTimeSeriesCrud();
            fpgOutputs.setSpacecraftAttitudeSolution(prfAttitudeSolution);
            testSerialization(fpgOutputs, fpgOutputs, outputsFile, true);

        } catch (Exception e) {
            throw new PipelineException(e);
        }
    }

    protected int getStartCadence() {
        return 1;
    }

    protected int getEndCadence() {
        return 350;
    }

    protected int getCadenceLength() {
        return getEndCadence() - getStartCadence() + 1;
    }

    protected double getMjdStartTime() {
        return getStartCadence() - 0.5;
    }

    protected double getMjdEndTime() {
        return getCadenceLength() + getMjdStartTime();
    }

    protected void testSerialization(Persistable expected, Persistable actual,
        File file, boolean validate) throws Exception {

        // Save.
        FileOutputStream fos = new FileOutputStream(file);
        BufferedOutputStream bout = new BufferedOutputStream(fos, 1024 * 32);
        DataOutputStream dos = new DataOutputStream(bout);
        BinaryPersistableOutputStream bpos = new BinaryPersistableOutputStream(
            dos);
        bpos.save(expected);
        dos.flush();
        fos.close();

        // Load.
        if (validate) {
            FileInputStream fis = new FileInputStream(file);
            BufferedInputStream bin = new BufferedInputStream(fis);
            DataInputStream dis = new DataInputStream(bin);
            BinaryPersistableInputStream bpis = new BinaryPersistableInputStream(
                dis);
            bpis.load(actual);

            // Test.
            new ReflectionEquals().assertEquals(expected, actual);
        }
    }

    File getMatlabWorkingDir() {
        return new File(MATLAB_EXE_DIR);
    }

    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    protected abstract Mockery getMockery();

    protected abstract FpgPipelineModule getPipelineModule();

}
