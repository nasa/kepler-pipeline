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

package gov.nasa.kepler.tip;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
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
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.TpsPipelineInstanceSelectionParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.SimulatedTransitsModuleParameters;
import gov.nasa.kepler.mc.uow.TargetListChunkUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.PersistableUtils;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class AbstractTipPipelineModuleTest extends JMockTest {

    // private static final Log log =
    // LogFactory.getLog(AbstractTipPipelineModuleTest.class);

    private static final int EXE_TIMEOUT_SECS = 60;
    private static final long INSTANCE_ID = System.currentTimeMillis();
    private static final long PIPELINE_TASK_ID = INSTANCE_ID - 1000;
    private static final int SC_CONFIG_ID = 42;
    private static final int SKY_GROUP_ID = 67;
    private static final int KEPLER_ID = 123456789;
    private static final float TRIAL_TRANSIT_PULSE_DURATION = 5.0F;
    private static final Float RMS_CDPP = new Float(1.0);
    public static final File MATLAB_WORKING_DIR = new File(
        Filenames.BUILD_TEST, "pa-matlab-1-1");

    protected PipelineTask pipelineTask;
    protected TipInputsRetriever tipInputsRetriever;
    protected TipOutputsStorer tipOutputsStorer;
    private UnitTestDescriptor unitTestDescriptor;
    private List<ConfigMap> configMaps;

    private CelestialObjectOperations celestialObjectOperations;
    private LogCrud logCrud;
    private MjdToCadence mjdToCadence;
    private RaDec2PixOperations raDec2PixOperations;
    private ConfigMapOperations configMapOperations;
    private TargetSelectionCrud targetSelectionCrud;
    private TpsCrud tpsCrud;

    public void validate(final TipInputs tipInputs) {

        assertNotNull(tipInputs);
        validateParameters(tipInputs);
        validateTargets(tipInputs);
        validateConfigMaps(tipInputs.getConfigMaps());
    }

    private void validateParameters(final TipInputs tipInputs) {

        assertNotNull(tipInputs.getSimulatedTransitsModuleParameters());
    }

    protected void validateTargets(final TipInputs tipInputs) {

        assertNotNull(tipInputs.getCadenceType());
        assertNotNull(tipInputs.getTargets());
        assertTrue("targets is empty", tipInputs.getTargets()
            .size() > 0);
        for (PaTarget target : tipInputs.getTargets()) {
            assertNotNull(target.getPaPixelTimeSeries());
            assertTrue(target.getPaPixelTimeSeries()
                .isEmpty());
        }
    }

    private void validateConfigMaps(List<ConfigMap> actualConfigMaps) {
        assertNotNull(actualConfigMaps);
        assertEquals(configMaps, actualConfigMaps);
    }

    protected void createInputs() {

        CadenceType cadenceType = unitTestDescriptor.getCadenceType();
        int startCadence = unitTestDescriptor.getStartCadence();
        int endCadence = unitTestDescriptor.getEndCadence();

        TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(this,
            mjdToCadence, cadenceType, startCadence, endCadence);

        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        MockUtils.mockRaDec2PixModel(this, raDec2PixOperations, startMjd,
            endMjd);
        configMaps = MockUtils.mockConfigMaps(this, configMapOperations,
            SC_CONFIG_ID, startMjd, endMjd);

        List<Integer> keplerIds = mockKeplerIdsForTargetList(this,
            targetSelectionCrud, Arrays.asList("targetListsName"),
            SKY_GROUP_ID, 0, Integer.MAX_VALUE);
        mockKeplerIdsForTargetList(this, targetSelectionCrud,
            new ArrayList<String>(), SKY_GROUP_ID, 0, Integer.MAX_VALUE);

        MockUtils.mockCelestialObjectParameters(this,
            celestialObjectOperations, keplerIds, SKY_GROUP_ID);

        mockTpsResultsForPipelineInstance(this, tpsCrud, keplerIds,
            unitTestDescriptor.getTpsPipelineInstanceId(), startCadence,
            endCadence);
    }

    protected void createOutputs(final TipInputs tipInputs,
        final TipOutputs tipOutputs) throws IOException {

        tipOutputs.setTransitInjectionParametersFileName(String.format(
            "parameters-%02d", SKY_GROUP_ID));
    }

    protected void populateObjects() {

        createMockObjects();
        pipelineTask = createPipelineTask(PIPELINE_TASK_ID, SKY_GROUP_ID, 0,
            Integer.MAX_VALUE);

        tipInputsRetriever = new TipInputsRetriever(pipelineTask);
        setMockObjects(tipInputsRetriever);

        tipOutputsStorer = new TipOutputsStorer(pipelineTask);
        setMockObjects(tipOutputsStorer);
    }

    private void createMockObjects() {

        celestialObjectOperations = mock(CelestialObjectOperations.class);

        logCrud = mock(LogCrud.class);
        mjdToCadence = mock(MjdToCadence.class);
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        configMapOperations = mock(ConfigMapOperations.class);
        targetSelectionCrud = mock(TargetSelectionCrud.class);
        tpsCrud = mock(TpsCrud.class);
    }

    private void setMockObjects(TipInputsRetriever tipInputsRetriever) {

        tipInputsRetriever.setCelestialObjectOperations(celestialObjectOperations);
        tipInputsRetriever.setLogCrud(logCrud);
        tipInputsRetriever.setMjdToCadence(mjdToCadence);
        tipInputsRetriever.setRaDec2PixOperations(raDec2PixOperations);
        tipInputsRetriever.setConfigMapOperations(configMapOperations);
        tipInputsRetriever.setTargetSelectionCrud(targetSelectionCrud);
        tipInputsRetriever.setTpsCrud(tpsCrud);
    }

    private void setMockObjects(TipOutputsStorer tipOutputsStorer) {

    }

    protected void serializeInputs(final TipInputs tipInputs)
        throws IllegalAccessException {

        testSerialization(tipInputs, new TipInputs(), new File(
            Filenames.BUILD_TMP, getClass().getSimpleName() + "-inputs.bin"));
    }

    protected void serializeOutputs(final TipOutputs tipOutputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(tipOutputs, new TipOutputs(),
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

    private static void testSerialization(final TipInputs expected,
        final TipInputs actual, final File file) throws IllegalAccessException {

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

        ParameterSet parameterSet = new ParameterSet("cadencerange");
        CadenceRangeParameters cadenceRangeParameters = new CadenceRangeParameters(
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence());
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            cadenceRangeParameters));
        pipelineInstanceNode.putModuleParameterSet(
            CadenceRangeParameters.class, parameterSet);

        parameterSet = new ParameterSet("cadencetype");
        CadenceTypePipelineParameters cadenceTypePipelineParameters = new CadenceTypePipelineParameters(
            unitTestDescriptor.getCadenceType());
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            cadenceTypePipelineParameters));
        pipelineInstanceNode.putModuleParameterSet(
            CadenceTypePipelineParameters.class, parameterSet);

        parameterSet = new ParameterSet("targetlist");
        TargetListParameters targetListParameters = new TargetListParameters(0,
            new String[] { "targetListsName" }, new String[0]);
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            targetListParameters));
        pipelineInstanceNode.putModuleParameterSet(TargetListParameters.class,
            parameterSet);

        parameterSet = new ParameterSet("simulatedtransits");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new SimulatedTransitsModuleParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            SimulatedTransitsModuleParameters.class, parameterSet);

        parameterSet = new ParameterSet("tpspipelineinstance");
        TpsPipelineInstanceSelectionParameters tpsPipelineInstanceSelectionParameters = new TpsPipelineInstanceSelectionParameters();
        tpsPipelineInstanceSelectionParameters.setPipelineInstanceId(unitTestDescriptor.getTpsPipelineInstanceId());
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            tpsPipelineInstanceSelectionParameters));
        pipelineInstanceNode.putModuleParameterSet(
            TpsPipelineInstanceSelectionParameters.class, parameterSet);

        return pipelineInstanceNode;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Transit Injection Parameters");
        pipelineModuleDefinition.setExeTimeoutSecs(EXE_TIMEOUT_SECS);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            TipPipelineModule.class));
        pipelineModuleDefinition.setExeName("tip");

        return pipelineModuleDefinition;
    }

    private PipelineInstance createPipelineInstance(
        final CadenceType cadenceType) {

        PipelineInstance instance = new PipelineInstance();
        instance.setId(INSTANCE_ID);

        return instance;
    }

    private PipelineTask createPipelineTask(final long pipelineTaskId,
        final int skyGroupId, final int startKeplerId, final int endKeplerId) {

        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance(unitTestDescriptor.getCadenceType());
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            skyGroupId, startKeplerId, endKeplerId)));
        task.setPipelineDefinitionNode(definitionNode);

        return task;
    }

    private static UnitOfWorkTask createUowTask(final int skyGroupId,
        final int startKeplerId, final int endKeplerId) {
        TargetListChunkUowTask uowTask = new TargetListChunkUowTask(skyGroupId,
            startKeplerId, endKeplerId);

        return uowTask;
    }

    private List<Integer> mockKeplerIdsForTargetList(JMockTest jMockTest,
        TargetSelectionCrud targetSelectionCrud, List<String> targetListNames,
        int skyGroupId, int startKeplerId, int endKeplerId) {

        List<Integer> keplerIds = new ArrayList<Integer>();
        if (!targetListNames.isEmpty()) {
            keplerIds.add(KEPLER_ID);
        }

        if (jMockTest != null && targetSelectionCrud != null) {
            jMockTest.allowing(targetSelectionCrud)
                .retrieveKeplerIdsForTargetListName(targetListNames,
                    skyGroupId, startKeplerId, endKeplerId);
            jMockTest.will(returnValue(keplerIds));
        }
        return keplerIds;
    }

    private List<TpsDbResult> mockTpsResultsForPipelineInstance(
        JMockTest jMockTest, TpsCrud tpsCrud, List<Integer> keplerIds,
        long instanceId, int startCadence, int endCadence) {

        List<TpsDbResult> results = createTpsResults(keplerIds, startCadence,
            endCadence);

        if (jMockTest != null && tpsCrud != null) {
            jMockTest.allowing(tpsCrud)
                .retrieveTpsResultByKeplerIdsPipelineInstanceId(keplerIds,
                    instanceId);
            jMockTest.will(returnValue(results));
        }
        return results;
    }

    private List<TpsDbResult> createTpsResults(List<Integer> keplerIds,
        int startCadence, int endCadence) {

        List<TpsDbResult> results = new ArrayList<TpsDbResult>();
        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                continue;
            }
            results.add(new TpsDbResult(keplerId, TRIAL_TRANSIT_PULSE_DURATION,
                null, RMS_CDPP, startCadence, endCadence, FluxType.SAP,
                pipelineTask, 1.0, false, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null));
        }

        return results;
    }
}
