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
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * This class retrieves metadata for pipeline processing for a csci.
 * 
 * @author Miles Cote
 * 
 */
public class SbtCsciOperations {

    private final PipelineTaskCrud pipelineTaskCrud;
    private final SbtCadenceRangeDataMerger sbtCadenceRangeDataMerger;
    private final SbtAncillaryOperations sbtAncillaryOperations;
    private final AlertLogCrud alertLogCrud;

    public SbtCsciOperations(PipelineTaskCrud pipelineTaskCrud,
        SbtCadenceRangeDataMerger sbtCadenceRangeDataMerger,
        SbtAncillaryOperations sbtAncillaryOperations, AlertLogCrud alertLogCrud) {
        this.pipelineTaskCrud = pipelineTaskCrud;
        this.sbtCadenceRangeDataMerger = sbtCadenceRangeDataMerger;
        this.sbtAncillaryOperations = sbtAncillaryOperations;
        this.alertLogCrud = alertLogCrud;
    }

    public Pair<List<SbtCsci>, List<SbtAncillaryData>> retrieveSbtCscis(
        List<PipelineProduct> pipelineProducts, List<Integer> keplerIds,
        Map<FsId, TimeSeries> fsIdToTimeSeries, MjdToCadence mjdToCadence) {
        List<SbtCsci> sbtCscis = newArrayList();
        List<SbtAncillaryData> sbtAncillaryDataList = newArrayList();
        for (PipelineProduct pipelineProduct : pipelineProducts) {
            if (pipelineProduct.isPipelineModule()) {
                TicToc.tic("Creating taskIntervals and taskIds", 2);
                Set<TaggedInterval> taskIntervals = newHashSet();
                Set<Long> taskIds = newHashSet();
                for (TimeSeries timeSeries : fsIdToTimeSeries.values()) {
                    if (timeSeries.id()
                        .path()
                        .startsWith(pipelineProduct.getFsIdPath())) {
                        for (TaggedInterval taggedInterval : timeSeries.originators()) {
                            taskIntervals.add(taggedInterval);
                            taskIds.add(taggedInterval.tag());
                        }
                    }
                }
                TicToc.toc();

                TicToc.tic("Calling pipelineTaskCrud.retrieveAll()", 1);
                List<PipelineTask> pipelineTasks = pipelineTaskCrud.retrieveAll(taskIds);
                TicToc.toc();

                TicToc.tic(
                    "Creating taskIdToTask map and taskIdToAlertLogs map", 2);
                Map<Long, PipelineTask> taskIdToTask = newLinkedHashMap();
                Map<Long, List<AlertLog>> taskIdToAlertLogs = newLinkedHashMap();
                for (PipelineTask pipelineTask : pipelineTasks) {
                    taskIdToTask.put(pipelineTask.getId(), pipelineTask);
                    ArrayList<AlertLog> alertLogs = newArrayList();
                    taskIdToAlertLogs.put(pipelineTask.getId(), alertLogs);
                }
                TicToc.toc();

                TicToc.tic("Calling alertLogCrud.retrieveByPipelineTaskIds()",
                    1);
                List<AlertLog> alertLogs = alertLogCrud.retrieveByPipelineTaskIds(taskIds);
                TicToc.toc();

                TicToc.tic("Adding alertLogs", 2);
                for (AlertLog alertLog : alertLogs) {
                    long taskId = alertLog.getAlertData()
                        .getSourceTaskId();
                    List<AlertLog> taskAlertLogs = taskIdToAlertLogs.get(taskId);
                    taskAlertLogs.add(alertLog);
                }
                TicToc.toc();

                TicToc.tic("Creating instanceIdToInstanceInterval map", 2);
                Map<Long, SbtPipelineInstanceInterval> instanceIdToInstanceInterval = newLinkedHashMap();
                for (TaggedInterval taskInterval : taskIntervals) {
                    long taskId = taskInterval.tag();
                    int startCadenceTask = (int) taskInterval.start();
                    int endCadenceTask = (int) taskInterval.end();

                    PipelineTask pipelineTask = taskIdToTask.get(taskId);
                    if (pipelineTask == null) {
                        throw new IllegalStateException(
                            "Originators must exist in the database.\n  originator: "
                                + taskId);
                    }

                    PipelineInstance pipelineInstance = pipelineTask.getPipelineInstance();
                    long instanceId = pipelineInstance.getId();
                    SbtPipelineInstanceInterval instanceInterval = instanceIdToInstanceInterval.get(instanceId);
                    if (instanceInterval == null) {
                        instanceInterval = new SbtPipelineInstanceInterval(
                            startCadenceTask, endCadenceTask, pipelineInstance);
                        instanceIdToInstanceInterval.put(instanceId,
                            instanceInterval);
                    }

                    List<PipelineTask> instanceIntervalTasks = instanceInterval.getPipelineTasks();
                    if (!instanceIntervalTasks.contains(pipelineTask)) {
                        instanceIntervalTasks.add(pipelineTask);
                    }

                    if (startCadenceTask < instanceInterval.getStartCadence()) {
                        instanceInterval.setStartCadence(startCadenceTask);
                    }
                    if (endCadenceTask > instanceInterval.getEndCadence()) {
                        instanceInterval.setEndCadence(endCadenceTask);
                    }
                }
                TicToc.toc();

                TicToc.tic("Creating instanceIntervals", 2);
                List<SbtPipelineInstanceInterval> instanceIntervals = newArrayList();
                for (SbtPipelineInstanceInterval instanceInterval : instanceIdToInstanceInterval.values()) {
                    instanceIntervals.add(instanceInterval);
                }
                Collections.sort(instanceIntervals);
                TicToc.toc();

                TicToc.tic("Creating sbtPipelineInstances", 2);
                List<SbtPipelineInstance> sbtPipelineInstances = newArrayList();
                for (SbtPipelineInstanceInterval instanceInterval : instanceIntervals) {
                    PipelineInstance pipelineInstance = instanceInterval.getPipelineInstance();

                    List<SbtPipelineTask> sbtPipelineTasks = newArrayList();
                    for (PipelineTask pipelineTask : instanceInterval.getPipelineTasks()) {
                        UnitOfWorkTask uowTask = pipelineTask.uowTaskInstance();
                        String uowString = uowTask.getClass()
                            .getSimpleName() + ":" + uowTask.briefState();

                        List<SbtAlert> sbtAlerts = newArrayList();
                        for (AlertLog alertLog : taskIdToAlertLogs.get(pipelineTask.getId())) {
                            Alert alertData = alertLog.getAlertData();
                            sbtAlerts.add(new SbtAlert(alertData.getTimestamp()
                                .toString(), alertData.getSourceComponent(),
                                alertData.getProcessName(),
                                alertData.getProcessHost(),
                                alertData.getProcessId(),
                                alertData.getSeverity(), alertData.getMessage()));
                        }

                        sbtPipelineTasks.add(new SbtPipelineTask(
                            pipelineTask.getId(),
                            pipelineTask.getStartProcessingTime()
                                .toString(),
                            pipelineTask.getEndProcessingTime()
                                .toString(), pipelineTask.getState()
                                .toString(),
                            pipelineTask.getSoftwareRevision(), uowString,
                            sbtAlerts));
                    }

                    sbtPipelineInstances.add(new SbtPipelineInstance(
                        instanceInterval.getStartCadence(),
                        instanceInterval.getEndCadence(),
                        pipelineInstance.getId(), pipelineInstance.getName(),
                        pipelineInstance.getStartProcessingTime()
                            .toString(),
                        pipelineInstance.getEndProcessingTime()
                            .toString(), pipelineInstance.getState()
                            .toString(), sbtPipelineTasks));
                }
                TicToc.toc();

                TicToc.tic(
                    "Creating parametersClassNameToSbtParameterMaps map", 2);
                Map<String, List<SbtParameterMap>> parametersClassNameToSbtParameterMaps = newLinkedHashMap();
                for (SbtPipelineInstanceInterval instanceInterval : instanceIntervals) {
                    Map<ClassWrapper<Parameters>, ParameterSet> classWrapperToParameterSet = newLinkedHashMap();

                    PipelineInstance pipelineInstance = instanceInterval.getPipelineInstance();
                    classWrapperToParameterSet.putAll(pipelineInstance.getPipelineParameterSets());

                    List<PipelineTask> instanceIntervalTasks = instanceInterval.getPipelineTasks();
                    if (instanceIntervalTasks.isEmpty()) {
                        throw new IllegalStateException(
                            "instanceIntervalTasks must not be empty.\n  instanceId: "
                                + pipelineInstance.getId());
                    }

                    PipelineTask pipelineTask = instanceIntervalTasks.get(0);
                    classWrapperToParameterSet.putAll(pipelineTask.getPipelineInstanceNode()
                        .getModuleParameterSets());

                    for (ClassWrapper<Parameters> classWrapper : classWrapperToParameterSet.keySet()) {
                        String classWrapperClassName = classWrapper.getClassName();
                        String[] stringArray = classWrapperClassName.split("\\.");
                        String className = stringArray[stringArray.length - 1];

                        List<SbtParameterMap> sbtParameterMaps = parametersClassNameToSbtParameterMaps.get(className);
                        if (sbtParameterMaps == null) {
                            sbtParameterMaps = newArrayList();
                            parametersClassNameToSbtParameterMaps.put(
                                className, sbtParameterMaps);
                        }

                        List<SbtParameterMapEntry> sbtParameterMapEntries = newArrayList();
                        for (Entry<String, String> parameterEntry : classWrapperToParameterSet.get(
                            classWrapper)
                            .getParameters()
                            .getProps()
                            .entrySet()) {
                            sbtParameterMapEntries.add(new SbtParameterMapEntry(
                                parameterEntry.getKey(),
                                parameterEntry.getValue()));
                        }
                        Collections.sort(sbtParameterMapEntries);

                        sbtParameterMaps.add(new SbtParameterMap(
                            instanceInterval.getStartCadence(),
                            instanceInterval.getEndCadence(),
                            sbtParameterMapEntries));
                    }
                }
                TicToc.toc();

                TicToc.tic("Merging sbtParameterMaps", 2);
                for (List<SbtParameterMap> sbtParameterMaps : parametersClassNameToSbtParameterMaps.values()) {
                    sbtCadenceRangeDataMerger.merge(sbtParameterMaps);
                }
                TicToc.toc();

                TicToc.tic("Creating sbtParameterGroups", 2);
                List<SbtParameterGroup> sbtParameterGroups = newArrayList();
                for (Entry<String, List<SbtParameterMap>> mapEntry : parametersClassNameToSbtParameterMaps.entrySet()) {
                    sbtParameterGroups.add(new SbtParameterGroup(
                        mapEntry.getKey(), mapEntry.getValue()));
                }
                Collections.sort(sbtParameterGroups);
                TicToc.toc();

                TicToc.tic(
                    "Creating sbtAncillaryEngineeringGroups and sbtAncillaryPipelineGroups",
                    2);
                List<SbtAncillaryEngineeringGroup> sbtAncillaryEngineeringGroups = newArrayList();
                List<SbtAncillaryPipelineGroup> sbtAncillaryPipelineGroups = newArrayList();
                if (pipelineProducts.contains(PipelineProduct.ANCILLARY)) {
                    TicToc.tic(
                        "Calling sbtAncillaryOperations.retrieveSbtAncillaryEngineeringGroups()",
                        1);
                    sbtAncillaryEngineeringGroups = sbtAncillaryOperations.retrieveSbtAncillaryEngineeringGroups(
                        sbtParameterGroups, mjdToCadence);
                    TicToc.toc();

                    TicToc.tic(
                        "Calling sbtAncillaryOperations.retrieveSbtAncillaryPipelineGroups()",
                        1);
                    sbtAncillaryPipelineGroups = sbtAncillaryOperations.retrieveSbtAncillaryPipelineGroups(
                        sbtParameterGroups, mjdToCadence);
                    TicToc.toc();
                }
                TicToc.toc();

                TicToc.tic("Adding sbtCscis and sbtAncillaryData", 2);
                sbtCscis.add(new SbtCsci(
                    trimSlashes(pipelineProduct.getFsIdPath()),
                    sbtPipelineInstances, sbtParameterGroups));
                sbtAncillaryDataList.add(new SbtAncillaryData(
                    trimSlashes(pipelineProduct.getFsIdPath()),
                    sbtAncillaryEngineeringGroups, sbtAncillaryPipelineGroups));
                TicToc.toc();
            }
        }

        return Pair.of(sbtCscis, sbtAncillaryDataList);
    }

    private String trimSlashes(String csciName) {
        if (csciName.startsWith("/")) {
            csciName = csciName.substring(1, csciName.length());
        }

        if (csciName.endsWith("/")) {
            csciName = csciName.substring(0, csciName.length() - 1);
        }

        return csciName;
    }

    private class SbtPipelineInstanceInterval implements
        Comparable<SbtPipelineInstanceInterval> {
        private int startCadence;
        private int endCadence;
        private PipelineInstance pipelineInstance;

        private List<PipelineTask> pipelineTasks = newArrayList();

        @Override
        public int compareTo(SbtPipelineInstanceInterval o) {
            return this.startCadence - o.startCadence;
        }

        public SbtPipelineInstanceInterval(int startCadence, int endCadence,
            PipelineInstance pipelineInstance) {
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.pipelineInstance = pipelineInstance;
        }

        public int getStartCadence() {
            return startCadence;
        }

        public void setStartCadence(int startCadence) {
            this.startCadence = startCadence;
        }

        public int getEndCadence() {
            return endCadence;
        }

        public void setEndCadence(int endCadence) {
            this.endCadence = endCadence;
        }

        public PipelineInstance getPipelineInstance() {
            return pipelineInstance;
        }

        public List<PipelineTask> getPipelineTasks() {
            return pipelineTasks;
        }
    }

}
