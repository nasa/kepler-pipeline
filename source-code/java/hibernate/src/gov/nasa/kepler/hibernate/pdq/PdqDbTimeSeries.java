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

package gov.nasa.kepler.hibernate.pdq;

import java.util.Arrays;

import org.apache.commons.lang.builder.ToStringBuilder;

public class PdqDbTimeSeries {

    private double[] values;
    private double[] uncertainties;
    private boolean[] gapIndicators;
    private long[] originators;
    private PdqDoubleTimeSeriesType timeSeriesType;
    private int targetTableId;
    private int startCadence;
    private int endCadence;

    public PdqDbTimeSeries(PdqDoubleTimeSeriesType timeSeriesType,
        int targetTableId, int startCadence, int endCadence, double[] values,
        double[] uncertainties, boolean[] gapIndicators, long[] originators) {

        init(timeSeriesType, targetTableId, startCadence, endCadence, values,
            uncertainties, gapIndicators, originators);
    }

    private void init(PdqDoubleTimeSeriesType timeSeriesType,
        int targetTableId, int startCadence, int endCadence, double[] values,
        double[] uncertainties, boolean[] gapIndicators, long[] originators) {

        if (values.length != uncertainties.length) {
            throw new IllegalArgumentException("uncertainties must be the same"
                + " length as values.");
        }
        if (values.length != gapIndicators.length) {
            throw new IllegalArgumentException("gapIndicators must be the same"
                + " length as values.");
        }
        if (values.length != originators.length) {
            throw new IllegalArgumentException("originators must be the same"
                + " length as values.");
        }
        if (timeSeriesType == null) {
            throw new NullPointerException("timeSeriesType can't be null.");
        }
        if (endCadence < startCadence) {
            throw new IllegalArgumentException(
                "startCadence comes after endCadence.");
        }

        this.timeSeriesType = timeSeriesType;
        this.targetTableId = targetTableId;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.values = values;
        this.uncertainties = uncertainties;
        this.gapIndicators = gapIndicators;
        this.originators = originators;
    }

    public PdqDbTimeSeries(PdqDoubleTimeSeriesType timeSeriesType,
        int targetTableId, int startCadence, int endCadence, double[] values,
        double[] uncertainties, boolean[] gapIndicators, long originator) {

        long[] originators = new long[values.length];
        Arrays.fill(originators, originator);
        init(timeSeriesType, targetTableId, startCadence, endCadence, values,
            uncertainties, gapIndicators, originators);
    }

    public PdqDoubleTimeSeriesType getTimeSeriesType() {
        return timeSeriesType;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public double[] getValues() {
        return values;
    }

    public double[] getUncertainties() {
        return uncertainties;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public long[] getOriginators() {
        return originators;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + endCadence;
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result + Arrays.hashCode(originators);
        result = prime * result + startCadence;
        result = prime * result + targetTableId;
        result = prime * result
            + ((timeSeriesType == null) ? 0 : timeSeriesType.hashCode());
        result = prime * result + Arrays.hashCode(uncertainties);
        result = prime * result + Arrays.hashCode(values);
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
        if (getClass() != obj.getClass()) {
            return false;
        }
        PdqDbTimeSeries other = (PdqDbTimeSeries) obj;
        if (endCadence != other.endCadence) {
            return false;
        }
        if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
            return false;
        }
        if (!Arrays.equals(originators, other.originators)) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (targetTableId != other.targetTableId) {
            return false;
        }
        if (timeSeriesType == null) {
            if (other.timeSeriesType != null) {
                return false;
            }
        } else if (!timeSeriesType.equals(other.timeSeriesType)) {
            return false;
        }
        if (!Arrays.equals(uncertainties, other.uncertainties)) {
            return false;
        }
        if (!Arrays.equals(values, other.values)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("timeSeriesType",
            timeSeriesType.toString())
            .append("targetTableId", targetTableId)
            .append("values.length", values.length)
            .toString();
    }
}
