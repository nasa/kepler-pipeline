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

package gov.nasa.kepler.mc.tad;

import static com.google.common.collect.Maps.newLinkedHashMap;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;

import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Rejects {@link ObservedTarget}s based on criteria.
 * 
 * @author Miles Cote
 * 
 */
public class CoaObservedTargetRejecter {

    static final Log log = LogFactory.getLog(CoaObservedTargetRejecter.class);

    public void reject(List<ObservedTarget> origObservedTargets,
        List<ObservedTarget> suppObservedTargets) {
        if (origObservedTargets == null) {
            throw new IllegalArgumentException(
                "origObservedTargets must not be null.");
        }

        if (suppObservedTargets == null) {
            rejectForOrigTadRun(origObservedTargets);
        } else {
            rejectForSuppTadRun(origObservedTargets, suppObservedTargets);
        }
    }

    private void rejectForOrigTadRun(List<ObservedTarget> origObservedTargets) {
        for (ObservedTarget origObservedTarget : origObservedTargets) {
            if (origObservedTarget.getAperture() == null
                || origObservedTarget.getAperture()
                    .getOffsets()
                    .isEmpty()) {
                origObservedTarget.setRejected(true);
            }
        }
    }

    private void rejectForSuppTadRun(List<ObservedTarget> origObservedTargets,
        List<ObservedTarget> suppObservedTargets) {
        Map<Integer, ObservedTarget> keplerIdToOrigTarget = newLinkedHashMap();
        for (ObservedTarget origObservedTarget : origObservedTargets) {
            keplerIdToOrigTarget.put(origObservedTarget.getKeplerId(),
                origObservedTarget);
        }

        Map<Integer, ObservedTarget> keplerIdToSuppTarget = newLinkedHashMap();
        for (ObservedTarget suppObservedTarget : suppObservedTargets) {
            keplerIdToSuppTarget.put(suppObservedTarget.getKeplerId(),
                suppObservedTarget);
        }

        validateTargets(origObservedTargets, suppObservedTargets,
            keplerIdToOrigTarget, keplerIdToSuppTarget);

        for (ObservedTarget suppObservedTarget : suppObservedTargets) {
            ObservedTarget origObservedTarget = keplerIdToOrigTarget.get(suppObservedTarget.getKeplerId());
            Aperture origAperture = origObservedTarget.getAperture();
            Aperture suppAperture = suppObservedTarget.getAperture();

            if (suppAperture == null || origAperture != null
                && origAperture.getOffsets()
                    .isEmpty() && suppAperture != null
                && suppAperture.getOffsets()
                    .isEmpty()) {
                suppObservedTarget.setRejected(true);
            }

            if (origAperture != null && origAperture.getOffsets()
                .isEmpty() && suppAperture != null
                && !suppAperture.getOffsets()
                    .isEmpty()) {
                throw new IllegalArgumentException(
                    "If the origAperture is empty, then the suppAperture can't be non-empty.  "
                        + "This is probably caused by a target that was flagged as an artifact in the orig run, "
                        + "but not in the supp run.\n  keplerId: "
                        + suppObservedTarget.getKeplerId());
            }
        }
    }

    private void validateTargets(List<ObservedTarget> origObservedTargets,
        List<ObservedTarget> suppObservedTargets,
        Map<Integer, ObservedTarget> keplerIdToOrigTarget,
        Map<Integer, ObservedTarget> keplerIdToSuppTarget) {

        if (origObservedTargets.isEmpty()) {
            throw new IllegalArgumentException(
                "The list of original targets can't be empty.");
        }
        if (suppObservedTargets.isEmpty()) {
            throw new IllegalArgumentException(
                "The list of supplemental targets can't be empty.");
        }
        if (keplerIdToOrigTarget.isEmpty()) {
            throw new IllegalArgumentException(
                "The map of original targets can't be empty.");
        }
        if (keplerIdToSuppTarget.isEmpty()) {
            throw new IllegalArgumentException(
                "The map of supplemental targets can't be empty.");
        }

        int missingOriginals = 0;
        for (ObservedTarget origObservedTarget : origObservedTargets) {
            if (keplerIdToSuppTarget.get(origObservedTarget.getKeplerId()) == null) {
                missingOriginals++;
                log.error(String.format(
                    "Original ObservedTarget (%d) must appear on the "
                        + "supplemental list.",
                    origObservedTarget.getKeplerId()));
            }
        }
        if (missingOriginals > 0) {
            log.error(String.format(
                "ObservedTargets on the original list must appear on "
                    + "the supplemental list. There are %d original targets "
                    + "missing from the supplemental list (see log).",
                missingOriginals));
            throw new IllegalArgumentException();
        }

        int missingSupplementals = 0;
        for (ObservedTarget suppObservedTarget : suppObservedTargets) {
            if (keplerIdToOrigTarget.get(suppObservedTarget.getKeplerId()) == null) {
                missingSupplementals++;
                log.error(String.format(
                    "Supplemental ObservedTarget (%d) must appear on the "
                        + "original list.", suppObservedTarget.getKeplerId()));
            }
        }
        if (missingSupplementals > 0) {
            log.error(String.format(
                "ObservedTargets on the supplemental list must appear on "
                    + "the original list. There are %d supplemental targets "
                    + "missing from the original list (see log).",
                missingSupplementals));
        }
        
        if (missingOriginals > 0 || missingSupplementals > 0) {
            throw new IllegalArgumentException(
                "ObservedTargets mismatch between the original list and the supplemental list "
                    + "See the log for specific missing targets.");
        }
    }

}
