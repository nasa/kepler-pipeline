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

package gov.nasa.kepler.mc;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;

/**
 * Implements {@link PlanetaryCandidatesFilter}.
 * 
 * @author Miles Cote
 * 
 */
public class PlanetaryCandidatesFilterImpl implements PlanetaryCandidatesFilter {

    private final PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters;

    private Set<Integer> cachedIncludedKeplerIds;
    private Set<Integer> cachedExcludedKeplerIds;

    public PlanetaryCandidatesFilterImpl(
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters) {
        this.planetaryCandidatesFilterParameters = planetaryCandidatesFilterParameters;
    }

    @Override
    public boolean included(int keplerId) {
        if (cachedIncludedKeplerIds == null || cachedExcludedKeplerIds == null) {
            populateCache();
        }

        if ((!cachedIncludedKeplerIds.isEmpty() && !cachedIncludedKeplerIds.contains(keplerId))
            || (!cachedExcludedKeplerIds.isEmpty() && cachedExcludedKeplerIds.contains(keplerId))) {
            return false;
        }

        return true;
    }

    private void populateCache() {
        String[] includedKeplerIds = planetaryCandidatesFilterParameters.getIncludedTargetLists();
        String[] excludedKeplerIds = planetaryCandidatesFilterParameters.getExcludedTargetLists();

        if (includedKeplerIds != null && excludedKeplerIds != null) {
            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            List<Integer> keplerIdList = targetSelectionCrud.retrieveKeplerIdsForTargetListName(Arrays.asList(includedKeplerIds));
            cachedIncludedKeplerIds = new HashSet<Integer>(keplerIdList);
            keplerIdList = targetSelectionCrud.retrieveKeplerIdsForTargetListName(Arrays.asList(excludedKeplerIds));
            cachedExcludedKeplerIds = new HashSet<Integer>(keplerIdList);
        } else {
            cachedIncludedKeplerIds = Collections.emptySet();
            cachedExcludedKeplerIds = Collections.emptySet();
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + ((cachedExcludedKeplerIds == null) ? 0
                : cachedExcludedKeplerIds.hashCode());
        result = prime
            * result
            + ((cachedIncludedKeplerIds == null) ? 0
                : cachedIncludedKeplerIds.hashCode());
        result = prime
            * result
            + ((planetaryCandidatesFilterParameters == null) ? 0
                : planetaryCandidatesFilterParameters.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        PlanetaryCandidatesFilterImpl other = (PlanetaryCandidatesFilterImpl) obj;
        if (cachedExcludedKeplerIds == null) {
            if (other.cachedExcludedKeplerIds != null)
                return false;
        } else if (!cachedExcludedKeplerIds.equals(other.cachedExcludedKeplerIds))
            return false;
        if (cachedIncludedKeplerIds == null) {
            if (other.cachedIncludedKeplerIds != null)
                return false;
        } else if (!cachedIncludedKeplerIds.equals(other.cachedIncludedKeplerIds))
            return false;
        if (planetaryCandidatesFilterParameters == null) {
            if (other.planetaryCandidatesFilterParameters != null)
                return false;
        } else if (!planetaryCandidatesFilterParameters.equals(other.planetaryCandidatesFilterParameters))
            return false;
        return true;
    }

}
