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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newLinkedHashMap;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hamcrest.core.IsAnything;
import org.hamcrest.core.IsEqual;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;

public class SbtCsciOperationsTest extends JMockTest {

    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Test
    public void testRetrieve() throws IllegalAccessException {
        final int keplerId = 1;
        final List<Integer> keplerIds = newArrayList();
        keplerIds.add(keplerId);

        final CadenceType cadenceType = CadenceType.LONG;
        final int startCadence = 2;
        final int endCadence = 3;

        final FluxType fluxType = FluxType.SAP;

        final long instanceId = 4;
        final Date instanceStartProcessingTime = new Date(5000);
        final Date instanceEndProcessingTime = new Date(6000);

        final long taskId = 7;
        final Set<Long> taskIds = newHashSet();
        taskIds.add(taskId);

        final Date taskStartProcessingTime = new Date(8000);
        final Date taskEndProcessingTime = new Date(9000);

        final int processId = 10;
        final Date timestamp = new Date(11000);

        final PipelineProduct csci = PipelineProduct.CAL;
        final List<PipelineProduct> cscis = newArrayList();
        cscis.add(csci);
        cscis.add(PipelineProduct.ANCILLARY);

        final FsId fsId = new FsId(csci.getFsIdPath(), "namePart");

        final TimeSeries timeSeries = mockery.mock(TimeSeries.class);

        final Map<FsId, TimeSeries> fsIdToTimeSeries = newLinkedHashMap();
        fsIdToTimeSeries.put(fsId, timeSeries);

        final String instanceName = "instanceName";
        final State instanceState = State.COMPLETED;

        final PipelineInstance pipelineInstance = mockery.mock(PipelineInstance.class);

        final gov.nasa.kepler.hibernate.pi.PipelineTask.State taskState = gov.nasa.kepler.hibernate.pi.PipelineTask.State.COMPLETED;
        final String softwareRevision = "softwareRevision";
        final ModOutCadenceUowTask uowTaskInstance = new ModOutCadenceUowTask(2, 1, 3, 4);
        final String uowString = uowTaskInstance.getClass()
            .getSimpleName() + ":" + uowTaskInstance.briefState();

        final String sourceComponent = "sourceComponent";
        final String processName = "processName";
        final String processHost = "processHost";
        final String severity = "severity";
        final String message = "message";

        final Parameters moduleParameters = new FluxTypeParameters(
            fluxType.toString());
        final String moduleParameterGroupName = moduleParameters.getClass()
            .getSimpleName();

        final ClassWrapper<Parameters> moduleClassWrapper = new ClassWrapper<Parameters>(
            moduleParameters.getClass());

        final BeanWrapper<Parameters> moduleBeanWrapper = new BeanWrapper<Parameters>(
            moduleParameters);

        final ParameterSet moduleParameterSet = new ParameterSet();
        moduleParameterSet.setParameters(moduleBeanWrapper);

        final Map<ClassWrapper<Parameters>, ParameterSet> moduleClassWrapperToParameterSet = newLinkedHashMap();
        moduleClassWrapperToParameterSet.put(moduleClassWrapper,
            moduleParameterSet);

        final PipelineInstanceNode pipelineInstanceNode = mockery.mock(PipelineInstanceNode.class);

        final PipelineTask pipelineTask = mockery.mock(PipelineTask.class);
        final List<PipelineTask> pipelineTasks = newArrayList();
        pipelineTasks.add(pipelineTask);

        final Parameters parameters = new CadenceTypePipelineParameters(
            cadenceType);
        final String parameterGroupName = parameters.getClass()
            .getSimpleName();

        final ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            parameters.getClass());

        final BeanWrapper<Parameters> beanWrapper = new BeanWrapper<Parameters>(
            parameters);

        final ParameterSet parameterSet = new ParameterSet();
        parameterSet.setParameters(beanWrapper);

        final Map<ClassWrapper<Parameters>, ParameterSet> pipelineClassWrapperToParameterSet = newLinkedHashMap();
        pipelineClassWrapperToParameterSet.put(classWrapper, parameterSet);

        final TaggedInterval taskInterval = new TaggedInterval(startCadence,
            endCadence, taskId);
        final List<TaggedInterval> taskIntervals = newArrayList();
        taskIntervals.add(taskInterval);

        final SbtAncillaryEngineeringGroup sbtAncillaryEngineeringGroup = mockery.mock(SbtAncillaryEngineeringGroup.class);

        final List<SbtAncillaryEngineeringGroup> sbtAncillaryEngineeringGroups = newArrayList();
        sbtAncillaryEngineeringGroups.add(sbtAncillaryEngineeringGroup);

        final SbtAncillaryPipelineGroup sbtAncillaryPipelineGroup = mockery.mock(SbtAncillaryPipelineGroup.class);

        final List<SbtAncillaryPipelineGroup> sbtAncillaryPipelineGroups = newArrayList();
        sbtAncillaryPipelineGroups.add(sbtAncillaryPipelineGroup);

        final Alert alertData = new Alert(timestamp, sourceComponent, taskId,
            processName, processHost, processId, message);
        alertData.setSeverity(severity);

        final AlertLog alertLog = new AlertLog(alertData);

        final List<AlertLog> alertLogs = newArrayList();
        alertLogs.add(alertLog);

        final PipelineTaskCrud pipelineTaskCrud = mockery.mock(PipelineTaskCrud.class);
        final SbtCadenceRangeDataMerger sbtCadenceRangeDataMerger = mockery.mock(SbtCadenceRangeDataMerger.class);
        final SbtAncillaryOperations sbtAncillaryOperations = mockery.mock(SbtAncillaryOperations.class);
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        final AlertLogCrud alertLogCrud = mockery.mock(AlertLogCrud.class);

        mockery.checking(new Expectations() {
            {
                allowing(timeSeries).id();
                will(returnValue(fsId));

                allowing(timeSeries).originators();
                will(returnValue(taskIntervals));

                allowing(pipelineTaskCrud).retrieveAll(taskIds);
                will(returnValue(pipelineTasks));

                allowing(pipelineTask).getId();
                will(returnValue(taskId));

                allowing(pipelineTask).getPipelineInstance();
                will(returnValue(pipelineInstance));

                allowing(pipelineInstance).getId();
                will(returnValue(instanceId));

                allowing(pipelineTask).uowTaskInstance();
                will(returnValue(uowTaskInstance));

                allowing(pipelineTask).getStartProcessingTime();
                will(returnValue(taskStartProcessingTime));

                allowing(pipelineTask).getEndProcessingTime();
                will(returnValue(taskEndProcessingTime));

                allowing(pipelineTask).getState();
                will(returnValue(taskState));

                allowing(pipelineTask).getSoftwareRevision();
                will(returnValue(softwareRevision));

                allowing(pipelineInstance).getName();
                will(returnValue(instanceName));

                allowing(pipelineInstance).getStartProcessingTime();
                will(returnValue(instanceStartProcessingTime));

                allowing(pipelineInstance).getEndProcessingTime();
                will(returnValue(instanceEndProcessingTime));

                allowing(pipelineInstance).getState();
                will(returnValue(instanceState));

                allowing(pipelineInstance).getPipelineParameterSets();
                will(returnValue(pipelineClassWrapperToParameterSet));

                allowing(pipelineTask).getPipelineInstanceNode();
                will(returnValue(pipelineInstanceNode));

                allowing(pipelineInstanceNode).getModuleParameterSets();
                will(returnValue(moduleClassWrapperToParameterSet));

                allowing(sbtCadenceRangeDataMerger).merge(
                    with(new IsAnything<List<SbtParameterMap>>()));

                allowing(sbtAncillaryOperations).retrieveSbtAncillaryEngineeringGroups(
                    with(new IsAnything<List<SbtParameterGroup>>()),
                    with(new IsEqual<MjdToCadence>(mjdToCadence)));
                will(returnValue(sbtAncillaryEngineeringGroups));

                allowing(sbtAncillaryOperations).retrieveSbtAncillaryPipelineGroups(
                    with(new IsAnything<List<SbtParameterGroup>>()),
                    with(new IsEqual<MjdToCadence>(mjdToCadence)));
                will(returnValue(sbtAncillaryPipelineGroups));

                allowing(alertLogCrud).retrieveByPipelineTaskIds(taskIds);
                will(returnValue(alertLogs));
            }
        });

        SbtCsciOperations sbtCsciOperations = new SbtCsciOperations(
            pipelineTaskCrud, sbtCadenceRangeDataMerger,
            sbtAncillaryOperations, alertLogCrud);
        Pair<List<SbtCsci>, List<SbtAncillaryData>> actualSbtCsciAncillaryDataPair = sbtCsciOperations.retrieveSbtCscis(
            cscis, keplerIds, fsIdToTimeSeries, mjdToCadence);

        List<SbtAlert> expectedSbtAlerts = newArrayList();
        expectedSbtAlerts.add(new SbtAlert(timestamp.toString(),
            sourceComponent, processName, processHost, processId, severity,
            message));

        List<SbtPipelineTask> expectedPipelineTasks = newArrayList();
        expectedPipelineTasks.add(new SbtPipelineTask(taskId,
            taskStartProcessingTime.toString(),
            taskEndProcessingTime.toString(), taskState.toString(),
            softwareRevision, uowString, expectedSbtAlerts));

        List<SbtPipelineInstance> expectedPipelineInstances = newArrayList();
        expectedPipelineInstances.add(new SbtPipelineInstance(startCadence,
            endCadence, instanceId, instanceName,
            instanceStartProcessingTime.toString(),
            instanceEndProcessingTime.toString(), instanceState.toString(),
            expectedPipelineTasks));

        List<SbtParameterMapEntry> expectedModuleEntries = newArrayList();
        expectedModuleEntries.add(new SbtParameterMapEntry("fluxType",
            fluxType.toString()));

        List<SbtParameterMap> expectedModuleParameterMaps = newArrayList();
        expectedModuleParameterMaps.add(new SbtParameterMap(startCadence,
            endCadence, expectedModuleEntries));

        List<SbtParameterMapEntry> expectedEntries = newArrayList();
        expectedEntries.add(new SbtParameterMapEntry("cadenceType",
            cadenceType.toString()));

        List<SbtParameterMap> expectedParameterMaps = newArrayList();
        expectedParameterMaps.add(new SbtParameterMap(startCadence, endCadence,
            expectedEntries));

        List<SbtParameterGroup> expectedParameterGroups = newArrayList();

        expectedParameterGroups.add(new SbtParameterGroup(parameterGroupName,
            expectedParameterMaps));
        expectedParameterGroups.add(new SbtParameterGroup(
            moduleParameterGroupName, expectedModuleParameterMaps));

        List<SbtCsci> expectedSbtCscis = newArrayList();
        expectedSbtCscis.add(new SbtCsci(csci.toString()
            .toLowerCase(), expectedPipelineInstances, expectedParameterGroups));

        List<SbtAncillaryData> expectedSbtAncillaryDataList = newArrayList();
        expectedSbtAncillaryDataList.add(new SbtAncillaryData(csci.toString()
            .toLowerCase(), sbtAncillaryEngineeringGroups,
            sbtAncillaryPipelineGroups));

        Pair<List<SbtCsci>, List<SbtAncillaryData>> expectedPair = Pair.of(
            expectedSbtCscis, expectedSbtAncillaryDataList);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedPair,
            actualSbtCsciAncillaryDataPair);
    }
}
