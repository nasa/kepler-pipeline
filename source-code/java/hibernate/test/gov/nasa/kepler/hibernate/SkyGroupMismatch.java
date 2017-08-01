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

package gov.nasa.kepler.hibernate;

import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.Session;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

public class SkyGroupMismatch {

    private static final Log log = LogFactory.getLog(SkyGroupMismatch.class);

    /**
     * @param args
     */
    public static void main(String[] argv) {

        DatabaseService dbService = DatabaseServiceFactory.getInstance(false);

        Session session = dbService.getSession();

        try {
            dbService.beginTransaction();
            String queryStr = "select kic.keplerId, kic.skyGroupId "
                + "from Kic kic where kic.skyGroupId != 0";
            Query query = session.createQuery(queryStr);
            @SuppressWarnings("unchecked")
            List<Object[]> keplerIdsWithSkyGroups = query.list();
            log.debug("keplerIdsWithSkyGroups.size "
                + keplerIdsWithSkyGroups.size());

            query = session.createQuery("from SkyGroup");
            @SuppressWarnings("unchecked")
            List<SkyGroup> skyGroups = query.list();
            Map<Integer, Set<Pair<Integer, Integer>>> skyGroupIdToModOut = Maps.newHashMap();
            for (SkyGroup skyGroup : skyGroups) {

                Set<Pair<Integer, Integer>> modOuts = skyGroupIdToModOut.get(skyGroup.getSkyGroupId());
                if (modOuts == null) {
                    modOuts = Sets.newHashSet();
                    skyGroupIdToModOut.put(skyGroup.getSkyGroupId(), modOuts);
                }
                modOuts.add(Pair.of(skyGroup.getCcdModule(),
                    skyGroup.getCcdOutput()));
            }

            log.debug("skyGroupIdToModOut.size " + skyGroupIdToModOut.size());

            query = session.createQuery("from TargetDefinition tdef where tdef.keplerId in (:keplerIdsParam)");
            ListChunkIterator<Object[]> it = new ListChunkIterator<Object[]>(
                keplerIdsWithSkyGroups.iterator(), 512);
            int chunkN = 0;
            for (List<Object[]> chunk : it) {
                log.debug("Checking chunk " + chunkN++);
                checkChunk(query, chunk, skyGroupIdToModOut);
            }
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    private static void checkChunk(Query tdefQuery,
        List<Object[]> keplerIdsSkyGroupIds,
        Map<Integer, Set<Pair<Integer, Integer>>> skyGroupIdToModOut) {
        Map<Integer, Integer> keplerIdToSkyGroupId = Maps.newHashMap();
        for (Object[] keplerIdSkyGroupId : keplerIdsSkyGroupIds) {
            int keplerId = (Integer) keplerIdSkyGroupId[0];
            int skyGroupId = (Integer) keplerIdSkyGroupId[1];
            keplerIdToSkyGroupId.put(keplerId, skyGroupId);
        }
        List<Integer> distinctKeplerIds = Lists.newArrayList(keplerIdToSkyGroupId.keySet());
        tdefQuery.setParameterList("keplerIdsParam", distinctKeplerIds);
        @SuppressWarnings("unchecked")
        List<TargetDefinition> targetDefinitions = tdefQuery.list();

        for (TargetDefinition tdef : targetDefinitions) {
            int keplerId = tdef.getKeplerId();
            Pair<Integer, Integer> tdefModOut = Pair.of(tdef.getCcdModule(),
                tdef.getCcdOutput());
            Integer skyGroupId = keplerIdToSkyGroupId.get(keplerId);
            if (skyGroupId == null) {
                log.debug("Couldn't find skyGroupId for keplerId : " + keplerId);
                continue;
            }
            Set<Pair<Integer, Integer>> modOutsForSkyGroup = skyGroupIdToModOut.get(skyGroupId);
            if (modOutsForSkyGroup == null) {
                log.debug("Couldn't find modOutsForSkyGroup/keplerId "
                    + skyGroupId + "/" + keplerId);
                continue;
            }
            if (!modOutsForSkyGroup.contains(tdefModOut)) {
                log.debug("target "
                    + keplerId
                    + " is assigned to skyGroupId "
                    + skyGroupId
                    + " but it's target defintiion says it is on module/output "
                    + tdef.getCcdModule() + "/" + tdef.getCcdOutput()
                    + " not in that sky group.");
            }
        }
    }

}
