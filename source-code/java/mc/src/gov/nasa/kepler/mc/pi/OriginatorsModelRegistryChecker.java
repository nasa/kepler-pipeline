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

package gov.nasa.kepler.mc.pi;

import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Maps.newLinkedHashMap;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newLinkedHashSet;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.ModelRegistry;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * Checks that all of the originators used the same {@link ModelRegistry}.
 * 
 * @author Miles Cote
 * 
 */
public class OriginatorsModelRegistryChecker {

    static final String ENABLED_PROP_NAME = "gov.nasa.kepler.pi.models.OriginatorsModelRegistryChecker.enabled";

    private final PipelineTaskCrud pipelineTaskCrud;
    private final AlertService alertService;

    public OriginatorsModelRegistryChecker() {
        this(new PipelineTaskCrud(), AlertServiceFactory.getInstance());
    }

    public OriginatorsModelRegistryChecker(PipelineTaskCrud pipelineTaskCrud,
        AlertService alertService) {
        this.pipelineTaskCrud = pipelineTaskCrud;
        this.alertService = alertService;
    }

    public void check(
        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> fsIdToTimeSeriesMapPair) {
        boolean enabled = ConfigurationServiceFactory.getInstance()
            .getBoolean(ENABLED_PROP_NAME, true);
        if (!enabled) {
            return;
        }

        Map<FsId, Set<Long>> fsIdToOriginators = getFsIdToOriginators(fsIdToTimeSeriesMapPair);

        Set<Long> pipelineTaskIds = getPipelineTaskIds(fsIdToOriginators);

        List<PipelineTask> pipelineTasks = pipelineTaskCrud.retrieveAll(pipelineTaskIds);

        Map<Long, PipelineTask> pipelineTaskIdToPipelineTask = getPipelineTaskIdToPipelineTask(pipelineTasks);

        Entry<FsId, Set<Long>> previousEntry = null;
        Long previousModelRegistryId = null;
        for (Entry<FsId, Set<Long>> entry : fsIdToOriginators.entrySet()) {
            for (Long originator : entry.getValue()) {
                PipelineTask pipelineTask = pipelineTaskIdToPipelineTask.get(originator);
                if (pipelineTask != null) {
                    ModelRegistry modelRegistry = pipelineTask.getPipelineInstance()
                        .getModelRegistry();
                    if (modelRegistry != null) {
                        long modelRegistryId = modelRegistry.getId();

                        if (previousModelRegistryId != null
                            && previousModelRegistryId != modelRegistryId) {
                            StringBuilder builder = new StringBuilder(
                                "timeSeries cannot have different modelRegistries.");
                            builder.append(getInfo(previousEntry,
                                previousModelRegistryId));
                            builder.append(getInfo(entry, modelRegistryId));

                            alertService.generateAlert(
                                getClass().getSimpleName(), builder.toString());
                        }

                        previousEntry = entry;
                        previousModelRegistryId = modelRegistryId;
                    }
                }
            }
        }
    }

    private Map<FsId, Set<Long>> getFsIdToOriginators(
        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> fsIdToTimeSeriesMapPair) {
        Map<FsId, Set<Long>> fsIdToOriginators = newLinkedHashMap();

        for (Entry<FsId, TimeSeries> entry : fsIdToTimeSeriesMapPair.left.entrySet()) {
            Set<Long> pipelineTaskIds = newLinkedHashSet();
            fsIdToOriginators.put(entry.getKey(), pipelineTaskIds);

            List<TaggedInterval> originators = entry.getValue()
                .originators();
            for (TaggedInterval taggedInterval : originators) {
                long pipelineTaskId = taggedInterval.tag();
                pipelineTaskIds.add(pipelineTaskId);
            }
        }

        for (Entry<FsId, FloatMjdTimeSeries> entry : fsIdToTimeSeriesMapPair.right.entrySet()) {
            Set<Long> pipelineTaskIds = newLinkedHashSet();
            fsIdToOriginators.put(entry.getKey(), pipelineTaskIds);

            long[] originators = entry.getValue()
                .originators();
            for (long originator : originators) {
                pipelineTaskIds.add(originator);
            }
        }

        return fsIdToOriginators;
    }

    private Set<Long> getPipelineTaskIds(Map<FsId, Set<Long>> fsIdToOriginators) {
        Set<Long> pipelineTaskIds = newHashSet();
        for (Set<Long> originators : fsIdToOriginators.values()) {
            pipelineTaskIds.addAll(originators);
        }

        return pipelineTaskIds;
    }

    private Map<Long, PipelineTask> getPipelineTaskIdToPipelineTask(
        List<PipelineTask> pipelineTasks) {
        Map<Long, PipelineTask> pipelineTaskIdToPipelineTask = newHashMap();
        for (PipelineTask pipelineTask : pipelineTasks) {
            pipelineTaskIdToPipelineTask.put(pipelineTask.getId(), pipelineTask);
        }

        return pipelineTaskIdToPipelineTask;
    }

    private String getInfo(Entry<FsId, Set<Long>> entry, Long modelRegistryId) {
        StringBuilder builder = new StringBuilder();
        builder.append("\n  ***************");
        builder.append("\n  fsId: ");
        builder.append(entry.getKey());
        builder.append("\n  pipelineTaskIds: ");
        builder.append(entry.getValue());
        builder.append("\n  modelRegistryId: ");
        builder.append(modelRegistryId);

        return builder.toString();
    }

}
