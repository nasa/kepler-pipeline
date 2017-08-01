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

package gov.nasa.kepler.dv;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * Utility functions for the DV pipeline module.
 * 
 * @author Forrest Girouard
 */
public class DvUtils {

    public static void addAllFsIds(List<FsIdSet> fsIdSets,
        Map<Pair<Integer, Integer>, Set<FsId>> fsIdsByCadenceRange) {

        for (FsIdSet fsIdSet : fsIdSets) {
            Pair<Integer, Integer> cadenceRange = Pair.of(
                fsIdSet.startCadence(), fsIdSet.endCadence());
            Set<FsId> fsIds = fsIdsByCadenceRange.get(cadenceRange);
            if (fsIds == null) {
                fsIds = new TreeSet<FsId>();
                fsIdsByCadenceRange.put(cadenceRange, fsIds);
            }
            fsIds.addAll(fsIdSet.ids());
        }
    }

    public static void addAllMjdFsIds(List<MjdFsIdSet> mjdFsIdSets,
        Map<Pair<Double, Double>, Set<FsId>> mjdFsIdsByTimeRange) {

        for (MjdFsIdSet mjdFsIdSet : mjdFsIdSets) {
            Pair<Double, Double> timeRange = Pair.of(mjdFsIdSet.startMjd(),
                mjdFsIdSet.endMjd());
            Set<FsId> fsIds = mjdFsIdsByTimeRange.get(timeRange);
            if (fsIds == null) {
                fsIds = new TreeSet<FsId>();
                mjdFsIdsByTimeRange.put(timeRange, fsIds);
            }
            fsIds.addAll(mjdFsIdSet.ids());
        }
    }

    public static List<FsIdSet> createFsIdSets(
        Map<Pair<Integer, Integer>, Set<FsId>> fsIdsByCadenceRange) {

        List<FsIdSet> fsIdSets = new ArrayList<FsIdSet>();

        for (Map.Entry<Pair<Integer, Integer>, Set<FsId>> fsIdSetByCadenceRange : fsIdsByCadenceRange.entrySet()) {
            fsIdSets.add(new FsIdSet(fsIdSetByCadenceRange.getKey().left,
                fsIdSetByCadenceRange.getKey().right,
                fsIdSetByCadenceRange.getValue()));
        }

        return fsIdSets;
    }

    public static List<MjdFsIdSet> createMjdFsIdSets(
        Map<Pair<Double, Double>, Set<FsId>> mjdFsIdsByTimeRange) {

        List<MjdFsIdSet> mjdFsIdSets = new ArrayList<MjdFsIdSet>();

        for (Map.Entry<Pair<Double, Double>, Set<FsId>> fsIdSetByTimeRange : mjdFsIdsByTimeRange.entrySet()) {
            mjdFsIdSets.add(new MjdFsIdSet(fsIdSetByTimeRange.getKey().left,
                fsIdSetByTimeRange.getKey().right,
                fsIdSetByTimeRange.getValue()));
        }

        return mjdFsIdSets;
    }

}
