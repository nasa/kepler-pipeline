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

package gov.nasa.kepler.hibernate.ppa;

import javax.persistence.Embeddable;
import javax.persistence.Column;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * A trend report.
 * 
 * @author Bill Wohler
 */
@Embeddable
public class TrendReport {
    private boolean valid;
    private float fitTime;
    //Uncomment this if you need Postgres support @Column(name="TREND_REPORT_OFFSET")
    private float offset;
    private float slope;
    private float horizonTime;

    /**
     * Creates a {@link TrendReport} object. For use only by mock objects, and
     * Hibernate.
     */
    TrendReport() {
    }

    /**
     * Creates a {@link TrendReport}.
     * 
     * @param valid whether the data in this record has been set
     * @param fitTime the fit time
     * @param offset the offset
     * @param slope the slope
     * @param horizonTime the horizon
     */
    public TrendReport(boolean valid, float fitTime, float offset, float slope,
        float horizonTime) {

        this.valid = valid;
        this.fitTime = fitTime;
        this.offset = offset;
        this.slope = slope;
        this.horizonTime = horizonTime;
    }

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean flag) {
        valid = flag;
    }

    public float getFitTime() {
        return fitTime;
    }

    public void setFitTime(float fitTime) {
        this.fitTime = fitTime;
    }

    public float getOffset() {
        return offset;
    }

    public void setOffset(float offset) {
        this.offset = offset;
    }

    public float getSlope() {
        return slope;
    }

    public void setSlope(float slope) {
        this.slope = slope;
    }

    public float getHorizonTime() {
        return horizonTime;
    }

    public void setHorizonTime(float horizonTime) {
        this.horizonTime = horizonTime;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(fitTime);
        result = prime * result + Float.floatToIntBits(horizonTime);
        result = prime * result + Float.floatToIntBits(offset);
        result = prime * result + Float.floatToIntBits(slope);
        result = prime * result + (valid ? 1231 : 1237);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof TrendReport)) {
            return false;
        }
        final TrendReport other = (TrendReport) obj;
        if (Float.floatToIntBits(fitTime) != Float.floatToIntBits(other.fitTime)) {
            return false;
        }
        if (Float.floatToIntBits(horizonTime) != Float.floatToIntBits(other.horizonTime)) {
            return false;
        }
        if (Float.floatToIntBits(offset) != Float.floatToIntBits(other.offset)) {
            return false;
        }
        if (Float.floatToIntBits(slope) != Float.floatToIntBits(other.slope)) {
            return false;
        }
        if (valid != other.valid) {
            return false;
        }
        return true;
    }
    
    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
