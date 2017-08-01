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

package gov.nasa.kepler.common;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Saturation parameters used by PDC and DV.
 * 
 * @author Forrest Girouard
 *
 */
public class SaturationSegmentModuleParameters implements Persistable, Parameters {
    
    // order of Savitzky-Golay filter to detect saturated segments
    private int sgPolyOrder;

    // length of Savitzky-Golay frame
    private int sgFrameSize;

    // threshold for identifying saturated segments
    private float satSegThreshold;

    // zone for excluding secondary peaks
    private int satSegExclusionZone;
    
    private float maxSaturationMagnitude;

    public SaturationSegmentModuleParameters() {
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(maxSaturationMagnitude);
        result = prime * result + satSegExclusionZone;
        result = prime * result + Float.floatToIntBits(satSegThreshold);
        result = prime * result + sgFrameSize;
        result = prime * result + sgPolyOrder;
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
        final SaturationSegmentModuleParameters other = (SaturationSegmentModuleParameters) obj;
        if (Float.floatToIntBits(maxSaturationMagnitude) != Float.floatToIntBits(other.maxSaturationMagnitude))
            return false;
        if (satSegExclusionZone != other.satSegExclusionZone)
            return false;
        if (Float.floatToIntBits(satSegThreshold) != Float.floatToIntBits(other.satSegThreshold))
            return false;
        if (sgFrameSize != other.sgFrameSize)
            return false;
        if (sgPolyOrder != other.sgPolyOrder)
            return false;
        return true;
    }

    public int getSgPolyOrder() {
        return sgPolyOrder;
    }

    public void setSgPolyOrder(int sgPolyOrder) {
        this.sgPolyOrder = sgPolyOrder;
    }

    public int getSgFrameSize() {
        return sgFrameSize;
    }

    public void setSgFrameSize(int sgFrameSize) {
        this.sgFrameSize = sgFrameSize;
    }

    public float getSatSegThreshold() {
        return satSegThreshold;
    }

    public void setSatSegThreshold(float satSegThreshold) {
        this.satSegThreshold = satSegThreshold;
    }

    public int getSatSegExclusionZone() {
        return satSegExclusionZone;
    }

    public void setSatSegExclusionZone(int satSegExclusionZone) {
        this.satSegExclusionZone = satSegExclusionZone;
    }

    public float getMaxSaturationMagnitude() {
        return maxSaturationMagnitude;
    }

    public void setMaxSaturationMagnitude(float maxSaturationMagnitude) {
        this.maxSaturationMagnitude = maxSaturationMagnitude;
    }
    
}
