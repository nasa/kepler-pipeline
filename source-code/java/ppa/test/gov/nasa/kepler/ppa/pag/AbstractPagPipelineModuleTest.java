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

package gov.nasa.kepler.ppa.pag;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModuleTest;
import gov.nasa.kepler.ppa.pmd.PmdCdppMagReport;
import gov.nasa.kepler.ppa.pmd.PmdCdppReport;
import gov.nasa.kepler.ppa.pmd.PmdMetricReport;
import gov.nasa.kepler.ppa.pmd.PmdPipelineModule;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
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

public abstract class AbstractPagPipelineModuleTest extends
    AbstractPpaPipelineModuleTest {

    private static final Log log = LogFactory.getLog(AbstractPagPipelineModuleTest.class);

    private static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pag-matlab-1-1");

    private static final FluxType FLUX_TYPE = FluxType.SAP;

    private static final int MODULE_OUTPUT_COUNT = FcConstants.MODULE_OUTPUTS;

    private FluxTypeParameters fluxTypeParameters = new FluxTypeParameters();
    private Set<Long> producerTaskIds;
    private Map<FsId, FloatTimeSeries> outputTsByFsId;

    private PagModuleParameters moduleParameters = new PagModuleParameters();
    private PagPipelineModule pipelineModule;

    private List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> allReports;

    public AbstractPagPipelineModuleTest() {
    }

    protected void createAndRetrieveInputs() {
        populateObjects();

        createInputs();

        validate();

        PagInputs pagInputs = (PagInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(pagInputs, getTargetTable());

        validate(pagInputs);
    }

    protected void createAndStoreOutputs() {
        populateObjects();

        createInputs();

        PagInputs pagInputs = (PagInputs) getPipelineModule().createInputs();

        getPipelineModule().initializeTask();

        getPipelineModule().retrieveInputs(pagInputs, getTargetTable());

        PagOutputs pagOutputs = (PagOutputs) getPipelineModule().createOutputs();
        createOutputs(pagOutputs);
        validate(pagOutputs);

        getPipelineModule().storeOutputs(pagOutputs, getTargetTable());
    }

    protected void createAndSerializeInputs() throws Exception {
        createAndRetrieveInputs();
        SerializationTest.testSerialization(getPipelineModule().getInputs(),
            getPipelineModule().createInputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-inputs.bin"));
    }

    protected void createAndSerializeOutputs() throws Exception {
        createAndStoreOutputs();
        SerializationTest.testSerialization(getPipelineModule().getOutputs(),
            getPipelineModule().createOutputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-outputs.bin"));
    }

    protected void populateObjects() {
        reset();

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
        task.setUowTask(createUowTask(START_CADENCE, END_CADENCE));

        return task;
    }

    private BeanWrapper<UnitOfWorkTask> createUowTask(int startCadence,
        int endCadence) {

        BeanWrapper<UnitOfWorkTask> uowTask = new BeanWrapper<UnitOfWorkTask>(
            new CadenceUowTask(startCadence, endCadence));

        return uowTask;
    }

    private void setMockObjects(PagPipelineModule pipelineModule) {
        pipelineModule.setMjdToCadence(getMjdToCadence());
        pipelineModule.setBlobOperations(getBlobOperations());
        pipelineModule.setDaCrud(getDaCrud());
        pipelineModule.setPpaCrud(getPpaCrud());
        pipelineModule.setTargetCrud(getTargetCrud());
        pipelineModule.setGenericReportOperations(getGenericReportOperations());
    }

    @Override
    protected PipelineInstanceNode createPipelineInstanceNode() {
        initializeModuleParameters();

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            getPipelineInstance(), getPipelineDefinitionNode(),
            getPipelineModuleDefinition());

        ParameterSet parameterSet = new ParameterSet("pag");
        parameterSet.setParameters(new BeanWrapper<Parameters>(moduleParameters));
        pipelineInstanceNode.putModuleParameterSet(PagModuleParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("pag cadence type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        pipelineInstanceNode.putModuleParameterSet(
            CadenceTypePipelineParameters.class, parameterSet);

        parameterSet = new ParameterSet("pag flux type parameters");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            fluxTypeParameters));
        pipelineInstanceNode.putModuleParameterSet(FluxTypeParameters.class,
            parameterSet);

        return pipelineInstanceNode;
    }

    private void initializeModuleParameters() {
        moduleParameters.setDebugLevel(debugLevel);

        fluxTypeParameters.setFluxType(FLUX_TYPE.toString());
    }

    @Override
    protected PipelineModuleDefinition createPipelineModuleDefinition() {
        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Photometer Performance Assessment - PMD Aggregator");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            PmdPipelineModule.class));
        pipelineModuleDefinition.setExeName("pag");

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

        if (processingTask) {
            oneOf(getBlobOperations()).setOutputDir(getMatlabWorkingDir());
        }

        List<FsId> intFsIds = new ArrayList<FsId>();
        List<FsId> floatFsIds = new ArrayList<FsId>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                intFsIds.addAll(PagInputTsData.getIntFsIds(ccdModule, ccdOutput));
                floatFsIds.addAll(PagInputTsData.getFloatFsIds(ccdModule,
                    ccdOutput));
            }
        }
        createIntTimeSeries(intFsIds, producerTaskId);
        createFloatTimeSeries(floatFsIds, producerTaskId);
        producerTaskIds.add(producerTaskId++);

        createReports(producerTaskId);
    }

    private long createReports(long producerTaskId) {
        log.info("Creating reports");

        long currentProducerTaskId = producerTaskId;
        PagInputReport report = createPagInputReport();
        allReports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                PipelineTask pipelineTask = createPipelineTask(currentProducerTaskId);
                allReports.addAll(report.createReports(pipelineTask,
                    getTargetTable(), ccdModule, ccdOutput, START_CADENCE,
                    END_CADENCE));
                producerTaskIds.add(currentProducerTaskId++);
            }
        }

        allowing(getPpaCrud()).retrievePmdMetricReports(getPipelineInstance());
        will(returnValue(allReports));

        return currentProducerTaskId;
    }

    private PagInputReport createPagInputReport() {
        PagInputReport report = new PagInputReport();
        PmdMetricReport metricReport = new PmdMetricReport();
        PmdMetricReport[] metricReports = new PmdMetricReport[2];
        metricReports[0] = metricReport;
        metricReports[1] = metricReport;
        report.setLdeUndershoot(metricReports);
        report.setTwoDBlack(metricReports);

        PmdCdppReport pmdCdppReport = new PmdCdppReport();
        PmdCdppMagReport pmdCdppMagReport = new PmdCdppMagReport();
        pmdCdppMagReport.setThreeHour(new PmdMetricReport());
        pmdCdppMagReport.setSixHour(new PmdMetricReport());
        pmdCdppMagReport.setTwelveHour(new PmdMetricReport());
        pmdCdppReport.setMag10(pmdCdppMagReport);
        pmdCdppReport.setMag11(pmdCdppMagReport);
        pmdCdppReport.setMag12(pmdCdppMagReport);
        pmdCdppReport.setMag13(pmdCdppMagReport);
        pmdCdppReport.setMag14(pmdCdppMagReport);
        pmdCdppReport.setMag15(pmdCdppMagReport);
        report.setCdppExpected(pmdCdppReport);

        return report;
    }

    private void validate() {
        assertNotNull(getTargetTable());
    }

    protected void validate(PagInputs pagInputs) {
        log.info("Validating inputs");

        assertNotNull(pagInputs);

        assertNotNull(pagInputs.getPagModuleParameters());
        assertNotNull(pagInputs.getFcConstants());

        validate(getConfigMaps(), pagInputs.getSpacecraftConfigMaps());

        assertNotNull(pagInputs.getCadenceTimes());
        assertEquals(CADENCE_COUNT,
            pagInputs.getCadenceTimes().startTimestamps.length);

        validateInputTsData(pagInputs.getInputTsData());

        validateReports(pagInputs.getReports());
    }

    private void validateInputTsData(List<PagInputTsData> inputTsData) {
        log.info("Validating inputTsData");

        assertNotNull(inputTsData);
        assertEquals(MODULE_OUTPUT_COUNT, inputTsData.size());

        for (PagInputTsData inputTsDataElement : inputTsData) {
            validate(CADENCE_COUNT,
                inputTsDataElement.getTheoreticalCompressionEfficiency());
            validate(CADENCE_COUNT,
                inputTsDataElement.getAchievedCompressionEfficiency());
        }
    }

    private void validate(int expectedLength,
        PagCompressionTimeSeries timeSeries) {

        assertNotNull(timeSeries);

        validate(expectedLength, (SimpleFloatTimeSeries) timeSeries);

        if (timeSeries.getCodeSymbolCounts() != null
            && timeSeries.getCodeSymbolCounts().length != 0) {
            validate(expectedLength, timeSeries.getCodeSymbolCounts());
        }
    }

    private void validateReports(List<PagInputReport> reports) {
        log.info("Validating reports");

        assertNotNull(reports);
        assertEquals(MODULE_OUTPUT_COUNT, reports.size());
    }

    void createOutputs(PagOutputs pagOutputs) {
        outputTsByFsId = createOutputTimeSeries(PagOutputTsData.getAllFsIds());
        pagOutputs.getOutputTsData()
            .setAllTimeSeries(outputTsByFsId);

        createReports(pagOutputs);
        createGenericReport(pagOutputs);
        createOutputAlert(pagOutputs);

        if (producerTaskIds != null) {
            createDataAccountabilityTrail(producerTaskIds);
        }
    }

    private void createReports(PagOutputs pagOutputs) {
        PagReport report = createPagReport();
        pagOutputs.setReport(report);

        final List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = report.createReports(
            getPipelineTask(), getTargetTable(), START_CADENCE, END_CADENCE);

        oneOf(getPpaCrud()).createMetricReports(reports);
    }

    private PagReport createPagReport() {
        PagReport report = new PagReport();
        PmdMetricReport metricReport = new PmdMetricReport();
        report.setTheoreticalCompressionEfficiency(metricReport);
        report.setAchievedCompressionEfficiency(metricReport);

        return report;
    }

    private void createGenericReport(PagOutputs pagOutputs) {
        pagOutputs.setReportFilename(createGenericReport().getFilename());
    }

    private void createOutputAlert(PagOutputs pagOutputs) {
        if (isForceAlert()) {
            List<ModuleAlert> moduleAlerts = new ArrayList<ModuleAlert>();
            moduleAlerts.add(new ModuleAlert(ALERT_MESSAGE));
            pagOutputs.getReport()
                .getTheoreticalCompressionEfficiency()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(), "["
                + ReportType.THEORETICAL_COMPRESSION_EFFICIENCY.toString()
                + "]");
            pagOutputs.getReport()
                .getAchievedCompressionEfficiency()
                .setAlerts(moduleAlerts);
            createAlert(getPipelineModule().getModuleName(), "["
                + ReportType.ACHIEVED_COMPRESSION_EFFICIENCY.toString() + "]");
        }
    }

    protected void validate(PagOutputs pagOutputs) {
        log.info("Validating outputs");

        assertNotNull(pagOutputs);

        validateOriginators(outputTsByFsId.values());
        validate(pagOutputs.getReport());

        assertEquals(GENERIC_REPORT_FILENAME, pagOutputs.getReportFilename());
    }

    private void validate(PagReport reports) {
        assertNotNull(reports);

        List<List<String>> reportTypes = new ArrayList<List<String>>();
        List<String> type = new ArrayList<String>();
        type.add(ReportType.THEORETICAL_COMPRESSION_EFFICIENCY.toString());
        reportTypes.add(type);
        type = new ArrayList<String>();
        type.add(ReportType.ACHIEVED_COMPRESSION_EFFICIENCY.toString());
        reportTypes.add(type);

        validatePmdMetricReports(reports.createReports(getPipelineTask(),
            getTargetTable(), START_CADENCE, END_CADENCE), reportTypes);
    }

    protected PagPipelineModule getPipelineModule() {
        if (pipelineModule == null) {
            pipelineModule = new PagPipelineModuleNullScience(this,
                isForceFatalException());
        }

        return pipelineModule;
    }
}
