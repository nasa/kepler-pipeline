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

package gov.nasa.kepler.mc.uow;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * This class subdivides {@link KeplerIdChunkBinnable} tasks such that the
 * subdivided list of tasks have less than or equal to chunkSize keplerIds. If
 * chunkSize is 0, then no binning will be done.
 * 
 * @author Miles Cote
 * 
 */
public class KeplerIdChunkBinner {

    private final CelestialObjectOperations celestialObjectOperations;

    public KeplerIdChunkBinner() {
        this.celestialObjectOperations = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false);
    }

    public KeplerIdChunkBinner(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    public <T extends KeplerIdChunkBinnable> List<T> subdivide(List<T> tasks,
        int chunkSize, List<Integer> keplerIds) {

        Map<Integer, Integer> keplerIdToSkyGroupMap = celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        return subdivide(tasks, chunkSize, keplerIdToSkyGroupMap);
    }

    public <T extends KeplerIdChunkBinnable> List<T> subdivide(List<T> tasks,
        int chunkSize, Map<Integer, Integer> keplerIdToSkyGroupMap) {
        Map<Integer, List<Integer>> skyGroupIdToKeplerIdsMap = createSkyGroupIdToKeplerIdsMap(keplerIdToSkyGroupMap);

        List<T> subdividedTasks = newArrayList();

        // Assumes one task per skyGroupId.
        for (T task : tasks) {
            List<Integer> skyGroupKeplerIds = skyGroupIdToKeplerIdsMap.get(task.getSkyGroupId());
            if (skyGroupKeplerIds == null) {
                // no binning
                subdividedTasks.add(task);
            } else {
                Collections.sort(skyGroupKeplerIds);

                int uowSize = getUowSize(skyGroupKeplerIds.size(), chunkSize);

                List<Integer> uowKeplerIds = newArrayList();
                for (int i = 0; i < skyGroupKeplerIds.size(); i++) {
                    uowKeplerIds.add(skyGroupKeplerIds.get(i));

                    if (uowKeplerIds.size() == uowSize
                        || i == (skyGroupKeplerIds.size() - 1)) {
                        T subdividedTask = task.makeCopy(task);
                        subdividedTask.setStartKeplerId(uowKeplerIds.get(0));
                        subdividedTask.setEndKeplerId(uowKeplerIds.get(uowKeplerIds.size() - 1));
                        subdividedTasks.add(subdividedTask);

                        uowKeplerIds = newArrayList();
                    }
                }
            }
        }

        return subdividedTasks;
    }

    private Map<Integer, List<Integer>> createSkyGroupIdToKeplerIdsMap(
        Map<Integer, Integer> keplerIdToSkyGroupIdMap) {
        Map<Integer, List<Integer>> skyGroupIdToKeplerIdsMap = newHashMap();
        for (Integer keplerId : keplerIdToSkyGroupIdMap.keySet()) {
            Integer skyGroupId = keplerIdToSkyGroupIdMap.get(keplerId);

            List<Integer> keplerIds = skyGroupIdToKeplerIdsMap.get(skyGroupId);
            if (keplerIds == null) {
                keplerIds = newArrayList();
                skyGroupIdToKeplerIdsMap.put(skyGroupId, keplerIds);
            }

            keplerIds.add(keplerId);
        }

        return skyGroupIdToKeplerIdsMap;
    }

    private int getUowSize(int skyGroupKeplerIdCount, int chunkSize) {
        int uowSize;
        if (chunkSize == 0) {
            // no binning
            uowSize = skyGroupKeplerIdCount;
        } else {
            int taskCount = (skyGroupKeplerIdCount / chunkSize) + 1;

            // The reason for the "+1" in this statement is to ensure that every
            // task has less than chunkSize keplerIds. Without the "+1", there
            // are
            // cases where one task can end up with much more than chunkSize
            // keplerIds.
            uowSize = (skyGroupKeplerIdCount / taskCount) + 1;
        }

        return uowSize;
    }

}
