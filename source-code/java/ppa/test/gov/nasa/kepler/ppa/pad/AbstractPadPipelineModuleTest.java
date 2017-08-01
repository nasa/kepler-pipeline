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

package gov.nasa.kepler.ppa.pad;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.ppa.MetricReport;
import gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ppa.AttitudeSolution;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModuleTest;
import gov.nasa.kepler.ppa.PpaMetricReport;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class AbstractPadPipelineModuleTest extends
    AbstractPpaPipelineModuleTest {

    private static final Log log = LogFactory.getLog(AbstractPadPipelineModuleTest.class);

    private static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pad-matlab-1-1");

    private Map<FsId, FloatTimeSeries> outputTsByFsId;

    private PadPipelineModule pipelineModule;
    private PadModuleParameters moduleParameters;
    private BlobFileSeries[] motionBlobs;
    private Set<Long> producerTaskIds;

    private DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud;

    public AbstractPadPipelineModuleTest() {
        super();
    }

    protected void createAndRetrieveInputs() {

        populateObjects();

        // Create test data and set expectations
        createInputs(false);

        validate();

        PadInputs padInputs = (PadInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(padInputs, getTargetTable());

        validate(padInputs);
    }

    protected void createAndStoreOutputs() {

        populateObjects();

        // Create test data and set expectations
        createInputs(false);

        PadInputs padInputs = (PadInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(padInputs, getTargetTable());

        PadOutputs padOutputs = (PadOutputs) getPipelineModule().createOutputs();

        createOutputs(padInputs, padOutputs);

        getPipelineModule().storeOutputs(padOutputs, getTargetTable());

        validate(padOutputs);
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

    void createOutputs(PadInputs padInputs, PadOutputs padOutputs) {

        padOutputs.setAttitudeSolution(MockUtils.mockCreateAttitudeSolution(
            this, getFsClient(), doubleDbTimeSeriesCrud, START_CADENCE,
            END_CADENCE, PIPELINE_TASK_ID));
        outputTsByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(padOutputs.getAttitudeSolution()
            .getAllFloatTimeSeries(START_CADENCE, END_CADENCE, PIPELINE_TASK_ID)
            .toArray(new FloatTimeSeries[0]));

        createReports(padOutputs);
        createOutputAlert(padOutputs);
        createGenericReport(padOutputs);

        if (producerTaskIds != null) {
            createDataAccountabilityTrail(producerTaskIds);
        }
    }

    protected void populateObjects() {

        reset();

        createMockObjects();
        setMockObjects(getPipelineModule());
        setMatlabWorkingDir(MATLAB_WORKING_DIR);
        getPipelineModule().setMatlabWorkingDir(getMatlabWorkingDir());
        setPipelineTask(createPipelineTask());
        getPipelineTask().setPipelineInstance(getPipelineInstance());
        getPipelineModule().setPipelineTask(getPipelineTask());
        getPipelineModule().setPipelineInstance(getPipelineInstance());
    }

    private void setMockObjects(PadPipelineModule pipelineModule) {
        pipelineModule.setMjdToCadence(getMjdToCadence());
        pipelineModule.setDaCrud(getDaCrud());
        pipelineModule.setPpaCrud(getPpaCrud());
        pipelineModule.setTargetCrud(getTargetCrud());
        pipelineModule.setRaDec2PixOperations(getRaDec2PixOperations());
        pipelineModule.setConfigMapOperations(getConfigMapOperations());
        pipelineModule.setBlobOperations(getBlobOperations());
        pipelineModule.setGenericReportOperations(getGenericReportOperations());
        pipelineModule.setDoubleDbTimeSeriesCrud(doubleDbTimeSeriesCrud);
    }

    @Override
    protected void createMockObjects() {
        super.createMockObjects();
        doubleDbTimeSeriesCrud = mock(DoubleDbTimeSeriesCrud.class);
    }

    @Override
    protected PipelineInstanceNode createPipelineInstanceNode() {

        initializeModuleParameters(getModuleParameters());

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            getPipelineInstance(), getPipelineDefinitionNode(),
            getPipelineModuleDefinition());

        ParameterSet parameterSet = new ParameterSet("pad");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            getModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(PadModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pad cadence type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        pipelineInstanceNode.putModuleParameterSet(
            CadenceTypePipelineParameters.class, parameterSet);

        return pipelineInstanceNode;
    }

    @Override
    protected PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
        // "PAD");
        // "Photometer Performance Assessment - PPA Attitude
        // Determination");
            "Photometer_Performance_Assessment_-_PPA_Attitude_Determination");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PadPipelineModule.class));
        pipelineModuleDefinition.setExeName("pad");

        return pipelineModuleDefinition;
    }

    private PipelineTask createPipelineTask() {

        PipelineTask task = new PipelineTask(getPipelineInstance(),
            getPipelineDefinitionNode(), getPipelineInstanceNode());
        task.setId(PIPELINE_TASK_ID);
        task.setUowTask(createUowTask(START_CADENCE, END_CADENCE));

        getPipelineModule().setPipelineTask(task);

        return task;
    }

    private static BeanWrapper<UnitOfWorkTask> createUowTask(int startCadence,
        int endCadence) {
        return new BeanWrapper<UnitOfWorkTask>(new CadenceUowTask(startCadence,
            endCadence));
    }

    private void initializeModuleParameters(PadModuleParameters moduleParameters) {

        moduleParameters.setDebugLevel(debugLevel);
        moduleParameters.setPlottingEnabled(plottingEnabled);
        // moduleParameters.setExcludeTargets(new int[0]);
    }

    protected PadPipelineModule getPipelineModule() {
        if (pipelineModule == null) {
            pipelineModule = new PadPipelineModuleNullScience(this,
                isForceFatalException());
        }
        return pipelineModule;
    }

    private PadModuleParameters getModuleParameters() {
        if (moduleParameters == null) {
            moduleParameters = new PadModuleParameters();
        }
        return moduleParameters;
    }

    protected void createInputs(boolean processingTask) {
        producerTaskIds = new HashSet<Long>();
        long producerTaskId = 0;

        setCadenceTimes(createCadenceTimes());

        setTargetTable(createTargetTable());
        if (!processingTask) {
            creatTargetTableLogExpectations();
        }

        createRaDec2PixModel();
        setConfigMaps(createConfigMaps());

        if (processingTask) {
            oneOf(getBlobOperations()).setOutputDir(getMatlabWorkingDir());
        }
        motionBlobs = createMotionBlobs(producerTaskId);
        producerTaskIds.add(producerTaskId);
    }

    private BlobFileSeries[] createMotionBlobs(long producerTaskId) {
        BlobFileSeries[] blobDataSeries = new BlobFileSeries[FcConstants.MODULE_OUTPUTS];
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                blobDataSeries[FcConstants.getChannelNumber(ccdModule,
                    ccdOutput) - 1] = new BlobFileSeries(
                    MockUtils.mockMotionBlobFileSeries(this,
                        getBlobOperations(), ccdModule, ccdOutput,
                        START_CADENCE, END_CADENCE, producerTaskId));
            }
        }

        return blobDataSeries;
    }

    private void createReports(PadOutputs padOutputs) {
        final PadReport padReport = new PadReport();
        padOutputs.setReport(padReport);

        final PadMetricReport report = new PadMetricReport();
        padOutputs.getReport()
            .setDeltaRa(report);
        padOutputs.getReport()
            .setDeltaDec(report);
        padOutputs.getReport()
            .setDeltaRoll(report);

        MetricReport metricReport = report.createReport(ReportType.DELTA_RA,
            getPipelineTask(), getTargetTable(), START_CADENCE, END_CADENCE);

        oneOf(getPpaCrud()).createMetricReport(metricReport);

        metricReport = report.createReport(ReportType.DELTA_DEC,
            getPipelineTask(), getTargetTable(), START_CADENCE, END_CADENCE);

        oneOf(getPpaCrud()).createMetricReport(metricReport);

        metricReport = report.createReport(ReportType.DELTA_ROLL,
            getPipelineTask(), getTargetTable(), START_CADENCE, END_CADENCE);

        oneOf(getPpaCrud()).createMetricReport(metricReport);
    }

    private void createOutputAlert(PadOutputs padOutputs) {
        if (isForceAlert()) {
            List<ModuleAlert> moduleAlerts = new ArrayList<ModuleAlert>();
            moduleAlerts.add(new ModuleAlert(ALERT_MESSAGE));
            padOutputs.getReport()
                .getDeltaRa()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(),
                ReportType.DELTA_RA.toString());
            createAlert(getPipelineModule().getModuleName(),
                ReportType.DELTA_DEC.toString());
            createAlert(getPipelineModule().getModuleName(),
                ReportType.DELTA_ROLL.toString());
        }
    }

    private void createGenericReport(PadOutputs padOutputs) {
        padOutputs.setReportFilename(createGenericReport().getFilename());
    }

    private void validate() {

        assertNotNull("targetTable null", getTargetTable());
        assertNotNull("motionPolyBlobs null", motionBlobs);
    }

    protected void validate(PadInputs padInputs) {

        log.info("validating inputs");

        assertNotNull(padInputs);

        assertNotNull("raDec2PixModel null", padInputs.getRaDec2PixModel());

        assertNotNull("cadenceTimes null", padInputs.getCadenceTimes());
        assertEquals("cadenceTimes length", CADENCE_COUNT,
            padInputs.getCadenceTimes().startTimestamps.length);

        BlobFileSeries[] bs = padInputs.getMotionBlobs();
        assertNotNull("motionBlobs null", bs);
        assertEquals("motionBlobs size", FcConstants.MODULE_OUTPUTS, bs.length);
        for (int i = 0; i < bs.length; i++) {
            assertNotNull("motionBlobs[" + i + "]");
        }
    }

    private void validate(int numCadences, boolean checkTimes,
        AttitudeSolution padTsData) {

        assertNotNull("padTsData null", padTsData);

        validate(numCadences, padTsData.getRa());
        validate(numCadences, padTsData.getDec());
        validate(numCadences, padTsData.getRoll());
        validate(numCadences, padTsData.getMaxAttitudeFocalPlaneResidual());
    }

    protected void validate(PadOutputs padOutputs) {

        log.info("validating outputs");

        validate(CADENCE_COUNT, false, padOutputs.getAttitudeSolution());

        validate(padOutputs.getReport()
            .getDeltaRa());
        validate(padOutputs.getReport()
            .getDeltaDec());
        validate(padOutputs.getReport()
            .getDeltaRoll());

        assertEquals(GENERIC_REPORT_FILENAME, padOutputs.getReportFilename());

        validateOriginators(outputTsByFsId.values());
    }

    private void validate(PpaMetricReport report) {

        assertNotNull("report", report);
    }
}
