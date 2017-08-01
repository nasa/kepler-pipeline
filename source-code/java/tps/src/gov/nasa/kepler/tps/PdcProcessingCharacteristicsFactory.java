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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * Generate the PdcProcessingCharacteristics for the specified targets and time
 * intervals.
 * 
 * @author Sean McCauliff
 * 
 */
final class PdcProcessingCharacteristicsFactory {

    private final PdcCrud pdcCrud;
    private final List<TargetTableLog> quarterlyCadenceIntervals;
    private final Collection<Integer> keplerIds;
    
    /**
     * This is a map from (keplerId, quarter) -> PdcProcessingCharacteristics
     */
    private final Map<Pair<Integer,Integer>, PdcProcessingCharacteristics> cachedCharacteristics;
    
    
    public PdcProcessingCharacteristicsFactory(
        Collection<TargetTableLog> quarterlyCadenceIntervals, PdcCrud pdcCrud, Collection<Integer> keplerIds) {

        this.quarterlyCadenceIntervals = Lists.newArrayList(quarterlyCadenceIntervals);
        Collections.sort(this.quarterlyCadenceIntervals, new Comparator<TargetTableLog>() {

            @Override
            public int compare(TargetTableLog o1, TargetTableLog o2) {
                return o1.getCadenceStart() - o2.getCadenceStart();
            }
        });
        
        cachedCharacteristics = Maps.newHashMap();
        this.pdcCrud = pdcCrud;
        this.keplerIds = keplerIds;
    }


    /**
     * 
     * @return every array element has non-null element. The array is then same
     * as the number of quarterly cadence intervals passed into the constructor.
     */
    public PdcProcessingCharacteristics[] characteristicsForTarget(int keplerId) {

        if (cachedCharacteristics.isEmpty()) {
            populateCache();
        }
        
        PdcProcessingCharacteristics[] rv =
            new PdcProcessingCharacteristics[quarterlyCadenceIntervals.size()];
        for (int quarterIndex=0; quarterIndex < rv.length; quarterIndex++) {
            PdcProcessingCharacteristics ppc = cachedCharacteristics.get(Pair.of(keplerId, quarterIndex));
            if (ppc == null) {
                rv[quarterIndex] = new PdcProcessingCharacteristics();
            } else {
                rv[quarterIndex] = ppc;
            }
        }
        
        return rv;
    }
    
    private void populateCache() {
        
        for (int quarterIndex=0; quarterIndex < quarterlyCadenceIntervals.size(); quarterIndex++) {
            int startCadence = quarterlyCadenceIntervals.get(quarterIndex).getCadenceStart();
            int endCadence = quarterlyCadenceIntervals.get(quarterIndex).getCadenceEnd();
            List<gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics> dbChars =
                pdcCrud.retrievePdcProcessingCharacteristics(FluxType.SAP,
                    CadenceType.LONG, keplerIds, startCadence, endCadence);
            for (gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics dbChar : dbChars) {
                if (dbChar == null) {
                    continue;
                }
                PdcProcessingCharacteristics ppc = new PdcProcessingCharacteristics(dbChar);
                cachedCharacteristics.put(Pair.of(dbChar.getKeplerId(), quarterIndex), ppc);
            }
        }
    }

}
