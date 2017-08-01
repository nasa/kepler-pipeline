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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.dv.DvPipelineModule;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * Counts {@link TpsDbResult}s that would be passed to {@link DvPipelineModule}.
 * 
 * @author Miles Cote
 * @author Todd Klaus
 * 
 */
public class TpsDbResultCounter {

    public static void main(String[] args) {
        String bySkyGroupId = "by-sky-group-id";
        String includeKeplerIds = "include-kepler-ids";
        
        if (args.length != 0
            && (args.length != 1 
                || (!args[0].equals(bySkyGroupId) && !args[0].equals(includeKeplerIds)))) {
            throw new IllegalArgumentException("USAGE: count-tps-results ["
                + bySkyGroupId + "|" + includeKeplerIds + "]");
        }

        boolean outputPerSkyGroupId = args.length == 1
        && args[0].equals(bySkyGroupId);

        boolean outputKeplerIds = args.length == 1
        && args[0].equals(includeKeplerIds);

        TpsCrud tpsCrud = new TpsCrud();
        List<TpsDbResult> tpsResults = tpsCrud.retrieveLatestTpsResults(null);

        if (outputPerSkyGroupId || outputKeplerIds) {
            printCountsPerSkyGroupId(tpsResults, outputKeplerIds);
        } else {
            System.out.println("tpsResultCount: " + tpsResults.size());
        }

        DatabaseServiceFactory.getInstance()
            .rollbackTransactionIfActive();

        System.exit(0);
    }

    private static void printCountsPerSkyGroupId(List<TpsDbResult> tpsResults, boolean outputKeplerIds) {
        Map<Integer, TreeSet<Integer>> skyGroupIdToTpsResults = new LinkedHashMap<Integer, TreeSet<Integer>>();
        for (int skyGroupId = 1; skyGroupId <= FcConstants.nModules
            * FcConstants.nOutputsPerModule; skyGroupId++) {
            skyGroupIdToTpsResults.put(skyGroupId, new TreeSet<Integer>());
        }

        List<Integer> keplerIds = new ArrayList<Integer>();
        for (TpsDbResult tpsDbResult : tpsResults) {
            keplerIds.add(tpsDbResult.getKeplerId());
        }

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            new ModelMetadataRetrieverLatest(), false);
        Map<Integer, Integer> keplerIdToSkyGroupId = celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        for (TpsDbResult tpsDbResult : tpsResults) {
            Integer skyGroupId = keplerIdToSkyGroupId.get(tpsDbResult.getKeplerId());
            Set<Integer> tpsResultsForSkyGroup = skyGroupIdToTpsResults.get(skyGroupId);
            tpsResultsForSkyGroup.add(tpsDbResult.getKeplerId());
        }

        for (int skyGroupId = 1; skyGroupId <= FcConstants.nModules
            * FcConstants.nOutputsPerModule; skyGroupId++) {
            Set<Integer> resultsForSkyGroup = skyGroupIdToTpsResults.get(skyGroupId);
            System.out.println("skyGroup" + skyGroupId + "Count: "
                + resultsForSkyGroup.size());
            
            if(outputKeplerIds){
                for (Integer keplerId : resultsForSkyGroup) {
                    System.out.println("KepId: " + keplerId);
                }
            }
        }
    }

}
