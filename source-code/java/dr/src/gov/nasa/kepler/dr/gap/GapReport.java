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

package gov.nasa.kepler.dr.gap;

import gov.nasa.kepler.hibernate.dr.GapCadence;
import gov.nasa.kepler.hibernate.dr.GapChannel;
import gov.nasa.kepler.hibernate.dr.GapCollateralPixel;
import gov.nasa.kepler.hibernate.dr.GapPixel;
import gov.nasa.kepler.hibernate.dr.GapTarget;

import java.util.List;

/**
 * Contains a gap report.
 * 
 * @author Miles Cote
 * 
 */
public final class GapReport {

    private final List<GapCadence> gapCadences;
    private final List<GapChannel> gapChannels;
    private final List<GapTarget> gapTargets;
    private final List<GapPixel> gapPixels;
    private final List<GapCollateralPixel> gapCollateralPixels;

    public GapReport(List<GapCadence> gapCadences,
        List<GapChannel> gapChannels, List<GapTarget> gapTargets,
        List<GapPixel> gapPixels, List<GapCollateralPixel> gapCollateralPixels) {
        this.gapCadences = gapCadences;
        this.gapChannels = gapChannels;
        this.gapTargets = gapTargets;
        this.gapPixels = gapPixels;
        this.gapCollateralPixels = gapCollateralPixels;
    }

    public List<GapCadence> getGapCadences() {
        return gapCadences;
    }

    public List<GapChannel> getGapChannels() {
        return gapChannels;
    }

    public List<GapTarget> getGapTargets() {
        return gapTargets;
    }

    public List<GapPixel> getGapPixels() {
        return gapPixels;
    }

    public List<GapCollateralPixel> getGapCollateralPixels() {
        return gapCollateralPixels;
    }

    @Override
    public String toString() {
        return "GapReport [gapCadences=" + gapCadences + ", gapChannels="
            + gapChannels + ", gapTargets=" + gapTargets + ", gapPixels="
            + gapPixels + ", gapCollateralPixels=" + gapCollateralPixels + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((gapCadences == null) ? 0 : gapCadences.hashCode());
        result = prime * result
            + ((gapChannels == null) ? 0 : gapChannels.hashCode());
        result = prime
            * result
            + ((gapCollateralPixels == null) ? 0
                : gapCollateralPixels.hashCode());
        result = prime * result
            + ((gapPixels == null) ? 0 : gapPixels.hashCode());
        result = prime * result
            + ((gapTargets == null) ? 0 : gapTargets.hashCode());
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
        GapReport other = (GapReport) obj;
        if (gapCadences == null) {
            if (other.gapCadences != null)
                return false;
        } else if (!gapCadences.equals(other.gapCadences))
            return false;
        if (gapChannels == null) {
            if (other.gapChannels != null)
                return false;
        } else if (!gapChannels.equals(other.gapChannels))
            return false;
        if (gapCollateralPixels == null) {
            if (other.gapCollateralPixels != null)
                return false;
        } else if (!gapCollateralPixels.equals(other.gapCollateralPixels))
            return false;
        if (gapPixels == null) {
            if (other.gapPixels != null)
                return false;
        } else if (!gapPixels.equals(other.gapPixels))
            return false;
        if (gapTargets == null) {
            if (other.gapTargets != null)
                return false;
        } else if (!gapTargets.equals(other.gapTargets))
            return false;
        return true;
    }

}
