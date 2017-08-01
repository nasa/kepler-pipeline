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

package gov.nasa.kepler.ar.archive;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

/**
 * The barycentric correction time series for a target.
 * 
 * @author Sean McCauliff
 *
 */
public class BarycentricCorrection implements Persistable {

    private int keplerId;
    private float[] barycentricTimeOffsets;
    private boolean[] barycentricGapIndicator;
    private double raDecimalHours;
    private double decDecimalDegrees;
    
    public BarycentricCorrection() {
        
    }

    public BarycentricCorrection(int keplerId, float[] correctionSeries,
        boolean[] gaps, double raDecimalHours, double decDecimalDegrees) {
        super();
        this.keplerId = keplerId;
        this.barycentricTimeOffsets = correctionSeries;
        this.barycentricGapIndicator = gaps;
        this.raDecimalHours = raDecimalHours;
        this.decDecimalDegrees = decDecimalDegrees;
    }
    
    public FloatTimeSeries toFloatTimeSeries(FsId id, int startCadence, int endCadence) {
        return new FloatTimeSeries(id, barycentricTimeOffsets, startCadence, endCadence, barycentricGapIndicator, 0L);
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public float[] getCorrectionSeries() {
        return barycentricTimeOffsets;
    }

    public void setCorrectionSeries(float[] correctionSeries) {
        this.barycentricTimeOffsets = correctionSeries;
    }

    public boolean[] getGaps() {
        return barycentricGapIndicator;
    }

    public void setGaps(boolean[] gaps) {
        this.barycentricGapIndicator = gaps;
    }

    public double getRaDecimalHours() {
        return raDecimalHours;
    }

    public void setRaDecimalHours(double raDecimalHours) {
        this.raDecimalHours = raDecimalHours;
    }

    public double getDecDecimalDegrees() {
        return decDecimalDegrees;
    }

    public void setDecDecimalDegrees(double decDecimalDegrees) {
        this.decDecimalDegrees = decDecimalDegrees;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(barycentricTimeOffsets);
        long temp;
        temp = Double.doubleToLongBits(decDecimalDegrees);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + Arrays.hashCode(barycentricGapIndicator);
        result = prime * result + keplerId;
        temp = Double.doubleToLongBits(raDecimalHours);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof BarycentricCorrection))
            return false;
        BarycentricCorrection other = (BarycentricCorrection) obj;
        if (!Arrays.equals(barycentricTimeOffsets, other.barycentricTimeOffsets))
            return false;
        if (Double.doubleToLongBits(decDecimalDegrees) != Double.doubleToLongBits(other.decDecimalDegrees))
            return false;
        if (!Arrays.equals(barycentricGapIndicator, other.barycentricGapIndicator))
            return false;
        if (keplerId != other.keplerId)
            return false;
        if (Double.doubleToLongBits(raDecimalHours) != Double.doubleToLongBits(other.raDecimalHours))
            return false;
        return true;
    }

    @Override
    public String toString() {
        final int maxLen = 10;
        StringBuilder builder = new StringBuilder();
        builder.append("BarycentricCorrection [keplerId=").append(keplerId).append(", barycentricTimeOffsets=").append(barycentricTimeOffsets != null ? Arrays.toString(Arrays.copyOf(barycentricTimeOffsets, Math.min(barycentricTimeOffsets.length, maxLen)))
            : null).append(", barycentricGapIndicator=").append(barycentricGapIndicator != null ? Arrays.toString(Arrays.copyOf(barycentricGapIndicator, Math.min(barycentricGapIndicator.length, maxLen)))
            : null).append(", raDecimalHours=").append(raDecimalHours).append(", decDecimalDegrees=").append(decDecimalDegrees).append("]");
        return builder.toString();
    }

}
