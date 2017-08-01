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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeries;
import gov.nasa.kepler.hibernate.pdq.PdqDoubleTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A persistable time series with double precision values and uncertainties.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqDoubleTimeSeries implements Persistable {

    /**
     * Time series values.
     */
    private double[] values = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    /**
     * Uncertainty in values.
     */
    private double[] uncertainties = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    /**
     * True values represent gaps in the time series. The values and
     * uncertainties for gaps are unspecified.
     */
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    public PdqDoubleTimeSeries() {
    }

    public PdqDoubleTimeSeries(double[] values, double[] uncertainties,
        boolean[] gapIndicators) {

        if (values == null) {
            throw new NullPointerException("values can't be null");
        }
        if (uncertainties == null) {
            throw new NullPointerException("uncertainties can't be null");
        }
        if (gapIndicators == null) {
            throw new NullPointerException("gapIndicators can't be null");
        }
        if (values.length != uncertainties.length) {
            throw new IllegalArgumentException(
                "uncertainties length must match values length");
        }
        if (values.length != gapIndicators.length) {
            throw new IllegalArgumentException(
                "gapIndicators length must match values length");
        }
        this.values = values;
        this.uncertainties = uncertainties;
        this.gapIndicators = gapIndicators;
    }
    
    public int size() {
        return values.length;
    }

    public PdqDbTimeSeries toDbTimeSeries(
        PdqDoubleTimeSeriesType timeSeriesType, int targetTableId,
        int startCadence, int endCadence, long originator) {

        double[] values = this.values;
        double[] uncertainties = this.uncertainties;
        boolean[] gapIndicators = this.gapIndicators;
        if (endCadence > size() - 1) {
            int newLength = endCadence + 1;
            values = Arrays.copyOf(values, newLength);
            uncertainties = Arrays.copyOf(uncertainties, newLength);
            gapIndicators = Arrays.copyOf(gapIndicators, newLength);
            Arrays.fill(gapIndicators, size(), endCadence, false);
        }
        PdqDbTimeSeries timeSeries = new PdqDbTimeSeries(
            timeSeriesType, targetTableId, startCadence, endCadence, values,
            uncertainties, gapIndicators, originator);
        return timeSeries;
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

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(gapIndicators);
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
        PdqDoubleTimeSeries other = (PdqDoubleTimeSeries) obj;
        if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
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
        return new ToStringBuilder(this).append("values.length", values.length)
            .toString();
    }
}
