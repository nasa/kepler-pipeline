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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Cache for {@link TargetDefinition}s for {@link Etem2Fits} to reduce database
 * access.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TargetDefCache {

    private Map<Integer, List<TargetDefinition>> targetCache = new HashMap<Integer, List<TargetDefinition>>();
    private Map<Integer, List<TargetDefinition>> bkgrndCache = new HashMap<Integer, List<TargetDefinition>>();

    public TargetDefCache() {
    }

    /**
     * Get stellar target definitions for the specified mod/out from the cache
     * 
     * @param targetTable
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public synchronized List<TargetDefinition> getTargetDefs(TargetTable targetTable, int ccdModule,
        int ccdOutput) {
        int ccdChannel = FcConstants.getChannelNumber(ccdModule, ccdOutput);

        List<TargetDefinition> targetDefs = null;
        targetDefs = targetCache.get(ccdChannel);

        if (targetDefs == null) {
            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            TargetCrud targetCrud = new TargetCrud(dbService);

            targetDefs = targetCrud.retrieveTargetDefinitions(targetTable, ccdModule, ccdOutput);
            
            targetCache.put(ccdChannel, targetDefs);
        }

        return targetDefs;
    }

    /**
     * Get background target definitions for the specified mod/out from the cache
     * 
     * @param targetTable
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public synchronized List<TargetDefinition> getBackgroundDefs(TargetTable targetTable, int ccdModule,
        int ccdOutput) {
        int ccdChannel = FcConstants.getChannelNumber(ccdModule, ccdOutput);

        List<TargetDefinition> bkgrndDefs = null;
        bkgrndDefs = bkgrndCache.get(ccdChannel);

        if (bkgrndDefs == null) {
            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            TargetCrud targetCrud = new TargetCrud(dbService);

            bkgrndDefs = targetCrud.retrieveTargetDefinitions(targetTable, ccdModule, ccdOutput);
            
            bkgrndCache.put(ccdChannel, bkgrndDefs);
        }

        return bkgrndDefs;
    }

}
