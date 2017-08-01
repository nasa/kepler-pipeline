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

import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Bounds (either fixed or adaptive) report for a single metric time series.
 * 
 * @author forrestg
 */
public class BoundsReport implements Persistable {

    /**
     * True iff the metric is out of the upper bounds.
     */
    private boolean outOfUpperBound;

    /**
     * True iff the metric out of the lower bounds.
     */
    private boolean outOfLowerBound;

    /**
     * The total number of samples for which the metric has exceeded the lower
     * bound for the current target table.
     */
    private int outOfLowerBoundsCount;

    /**
     * The sample times when the metric has exceeded the lower bound.
     */
    private double[] outOfLowerBoundsTimes = new double[0];

    /**
     * The metric values which have exceeded the lower bound.
     */
    private float[] outOfLowerBoundsValues = new float[0];

    /**
     * The estimated number of standard deviations that the out of bounds metric
     * values deviate from the mean.
     */
    private float[] lowerBoundsCrossingXFactors = new float[0];

    /**
     * The total number of samples for which the metric has exceeded the upper
     * bound for the current target table.
     */
    private int outOfUpperBoundsCount;

    /**
     * The sample times when the metric has exceeded the upper bound.
     */
    private double[] outOfUpperBoundsTimes = new double[0];

    /**
     * The metric values which have exceeded the upper bound.
     */
    private float[] outOfUpperBoundsValues = new float[0];

    /**
     * The estimated number of standard deviations that the out of bounds metric
     * values deviate from the mean.
     */
    private float[] upperBoundsCrossingXFactors = new float[0];

    /**
     * The current upper bound.
     */
    private float upperBound;

    /**
     * The current lower bound.
     */
    private float lowerBound;

    /**
     * True iff a crossing of the upper bound is predicted.
     */
    private boolean upperBoundCrossingPredicted;

    /**
     * True iff a crossing of the lower bound is predicted.
     */
    private boolean lowerBoundCrossingPredicted;

    /**
     * The predicted absolute MJD for crossing the bound indicated.
     */
    @OracleDouble
    private double crossingTime;

    /**
     * Creates a {@link BoundsReport}.
     */
    public BoundsReport() {
    }

    /**
     * Creates a {@link BoundsReport} from the given Hibernate object.
     */
    public BoundsReport(gov.nasa.kepler.hibernate.mc.BoundsReport report) {
        setCrossingTime(report.getCrossingTime());
        setLowerBound(report.getLowerBound());
        setLowerBoundCrossingPredicted(report.isLowerBoundCrossingPredicted());
        setLowerBoundsCrossingXFactors(report.getLowerBoundsCrossingXFactors());
        setOutOfLowerBound(report.isOutOfLowerBound());
        setOutOfLowerBoundsCount(report.getOutOfLowerBoundsCount());
        setOutOfLowerBoundsTimes(report.getOutOfLowerBoundsTimes());
        setOutOfLowerBoundsValues(report.getOutOfLowerBoundsValues());
        setOutOfUpperBound(report.isOutOfUpperBound());
        setOutOfUpperBoundsCount(report.getOutOfUpperBoundsCount());
        setOutOfUpperBoundsTimes(report.getOutOfUpperBoundsTimes());
        setOutOfUpperBoundsValues(report.getOutOfUpperBoundsValues());
        setUpperBound(report.getUpperBound());
        setUpperBoundCrossingPredicted(report.isUpperBoundCrossingPredicted());
        setUpperBoundsCrossingXFactors(report.getUpperBoundsCrossingXFactors());
    }

    /**
     * Creates a Hibernate version of this {@link BoundsReport}.
     */
    public gov.nasa.kepler.hibernate.mc.BoundsReport createBoundsReport() {
        gov.nasa.kepler.hibernate.mc.BoundsReport report = new gov.nasa.kepler.hibernate.mc.BoundsReport();
        report.setCrossingTime(getCrossingTime());
        report.setLowerBound(getLowerBound());
        report.setLowerBoundCrossingPredicted(isLowerBoundCrossingPredicted());
        report.setLowerBoundsCrossingXFactors(getLowerBoundsCrossingXFactors());
        report.setOutOfLowerBound(isOutOfLowerBound());
        report.setOutOfLowerBoundsCount(getOutOfLowerBoundsCount());
        report.setOutOfLowerBoundsTimes(getOutOfLowerBoundsTimes());
        report.setOutOfLowerBoundsValues(getOutOfLowerBoundsValues());
        report.setOutOfUpperBound(isOutOfUpperBound());
        report.setOutOfUpperBoundsCount(getOutOfUpperBoundsCount());
        report.setOutOfUpperBoundsTimes(getOutOfUpperBoundsTimes());
        report.setOutOfUpperBoundsValues(getOutOfUpperBoundsValues());
        report.setUpperBound(getUpperBound());
        report.setUpperBoundCrossingPredicted(isUpperBoundCrossingPredicted());
        report.setUpperBoundsCrossingXFactors(getUpperBoundsCrossingXFactors());

        return report;
    }

    // These custom accessors are here instead of below so to make it easier to
    // clobber all of the accessors if they need to be regenerated.
    public void setLowerBoundsCrossingXFactors(
        List<Float> lowerBoundsCrossingXFactors) {
        this.lowerBoundsCrossingXFactors = toFloatArray(lowerBoundsCrossingXFactors);
    }

    public void setOutOfLowerBoundsTimes(List<Double> outOfLowerBoundsTimes) {
        this.outOfLowerBoundsTimes = toDoubleArray(outOfLowerBoundsTimes);
    }

    public void setOutOfLowerBoundsValues(List<Float> outOfLowerBoundsValues) {
        this.outOfLowerBoundsValues = toFloatArray(outOfLowerBoundsValues);
    }

    public void setOutOfUpperBoundsTimes(List<Double> outOfUpperBoundsTimes) {
        this.outOfUpperBoundsTimes = toDoubleArray(outOfUpperBoundsTimes);
    }

    public void setOutOfUpperBoundsValues(List<Float> outOfUpperBoundsValues) {
        this.outOfUpperBoundsValues = toFloatArray(outOfUpperBoundsValues);
    }

    public void setUpperBoundsCrossingXFactors(
        List<Float> upperBoundsCrossingXFactors) {
        this.upperBoundsCrossingXFactors = toFloatArray(upperBoundsCrossingXFactors);
    }

    private float[] toFloatArray(List<Float> floats) {
        float[] floatArray = new float[floats.size()];
        int i = 0;
        for (Float f : floats) {
            floatArray[i++] = f;
        }

        return floatArray;
    }

    private double[] toDoubleArray(List<Double> doubles) {
        double[] doubleArray = new double[doubles.size()];
        int i = 0;
        for (Double d : doubles) {
            doubleArray[i++] = d;
        }

        return doubleArray;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(crossingTime);
        result = prime * result + (int) (temp ^ temp >>> 32);
        result = prime * result + Float.floatToIntBits(lowerBound);
        result = prime * result + (lowerBoundCrossingPredicted ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(lowerBoundsCrossingXFactors);
        result = prime * result + (outOfLowerBound ? 1231 : 1237);
        result = prime * result + outOfLowerBoundsCount;
        result = prime * result + Arrays.hashCode(outOfLowerBoundsTimes);
        result = prime * result + Arrays.hashCode(outOfLowerBoundsValues);
        result = prime * result + (outOfUpperBound ? 1231 : 1237);
        result = prime * result + outOfUpperBoundsCount;
        result = prime * result + Arrays.hashCode(outOfUpperBoundsTimes);
        result = prime * result + Arrays.hashCode(outOfUpperBoundsValues);
        result = prime * result + Float.floatToIntBits(upperBound);
        result = prime * result + (upperBoundCrossingPredicted ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(upperBoundsCrossingXFactors);
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
        if (!(obj instanceof BoundsReport)) {
            return false;
        }
        final BoundsReport other = (BoundsReport) obj;
        if (Double.doubleToLongBits(crossingTime) != Double.doubleToLongBits(other.crossingTime)) {
            return false;
        }
        if (Float.floatToIntBits(lowerBound) != Float.floatToIntBits(other.lowerBound)) {
            return false;
        }
        if (lowerBoundCrossingPredicted != other.lowerBoundCrossingPredicted) {
            return false;
        }
        if (!Arrays.equals(lowerBoundsCrossingXFactors,
            other.lowerBoundsCrossingXFactors)) {
            return false;
        }
        if (outOfLowerBound != other.outOfLowerBound) {
            return false;
        }
        if (outOfLowerBoundsCount != other.outOfLowerBoundsCount) {
            return false;
        }
        if (!Arrays.equals(outOfLowerBoundsTimes, other.outOfLowerBoundsTimes)) {
            return false;
        }
        if (!Arrays.equals(outOfLowerBoundsValues, other.outOfLowerBoundsValues)) {
            return false;
        }
        if (outOfUpperBound != other.outOfUpperBound) {
            return false;
        }
        if (outOfUpperBoundsCount != other.outOfUpperBoundsCount) {
            return false;
        }
        if (!Arrays.equals(outOfUpperBoundsTimes, other.outOfUpperBoundsTimes)) {
            return false;
        }
        if (!Arrays.equals(outOfUpperBoundsValues, other.outOfUpperBoundsValues)) {
            return false;
        }
        if (Float.floatToIntBits(upperBound) != Float.floatToIntBits(other.upperBound)) {
            return false;
        }
        if (upperBoundCrossingPredicted != other.upperBoundCrossingPredicted) {
            return false;
        }
        if (!Arrays.equals(upperBoundsCrossingXFactors,
            other.upperBoundsCrossingXFactors)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public double getCrossingTime() {
        return crossingTime;
    }

    public void setCrossingTime(double crossingTime) {
        this.crossingTime = crossingTime;
    }

    public float getLowerBound() {
        return lowerBound;
    }

    public void setLowerBound(float lowerBound) {
        this.lowerBound = lowerBound;
    }

    public boolean isLowerBoundCrossingPredicted() {
        return lowerBoundCrossingPredicted;
    }

    public void setLowerBoundCrossingPredicted(
        boolean lowerBoundCrossingPredicted) {
        this.lowerBoundCrossingPredicted = lowerBoundCrossingPredicted;
    }

    public boolean isOutOfLowerBound() {
        return outOfLowerBound;
    }

    public void setOutOfLowerBound(boolean outOfLowerBound) {
        this.outOfLowerBound = outOfLowerBound;
    }

    public int getOutOfLowerBoundsCount() {
        return outOfLowerBoundsCount;
    }

    public void setOutOfLowerBoundsCount(int outOfLowerBoundsCount) {
        this.outOfLowerBoundsCount = outOfLowerBoundsCount;
    }

    public double[] getOutOfLowerBoundsTimes() {
        return outOfLowerBoundsTimes;
    }

    public void setOutOfLowerBoundsTimes(double[] outOfLowerBoundsTimes) {
        this.outOfLowerBoundsTimes = outOfLowerBoundsTimes;
    }

    public float[] getOutOfLowerBoundsValues() {
        return outOfLowerBoundsValues;
    }

    public void setOutOfLowerBoundsValues(float[] outOfLowerBoundsValues) {
        this.outOfLowerBoundsValues = outOfLowerBoundsValues;
    }

    public float[] getLowerBoundsCrossingXFactors() {
        return lowerBoundsCrossingXFactors;
    }

    public void setLowerBoundsCrossingXFactors(
        float[] lowerBoundsCrossingXFactors) {
        this.lowerBoundsCrossingXFactors = lowerBoundsCrossingXFactors;
    }

    public boolean isOutOfUpperBound() {
        return outOfUpperBound;
    }

    public void setOutOfUpperBound(boolean outOfUpperBound) {
        this.outOfUpperBound = outOfUpperBound;
    }

    public int getOutOfUpperBoundsCount() {
        return outOfUpperBoundsCount;
    }

    public void setOutOfUpperBoundsCount(int outOfUpperBoundsCount) {
        this.outOfUpperBoundsCount = outOfUpperBoundsCount;
    }

    public double[] getOutOfUpperBoundsTimes() {
        return outOfUpperBoundsTimes;
    }

    public void setOutOfUpperBoundsTimes(double[] outOfUpperBoundsTimes) {
        this.outOfUpperBoundsTimes = outOfUpperBoundsTimes;
    }

    public float[] getOutOfUpperBoundsValues() {
        return outOfUpperBoundsValues;
    }

    public void setOutOfUpperBoundsValues(float[] outOfUpperBoundsValues) {
        this.outOfUpperBoundsValues = outOfUpperBoundsValues;
    }

    public float[] getUpperBoundsCrossingXFactors() {
        return upperBoundsCrossingXFactors;
    }

    public void setUpperBoundsCrossingXFactors(
        float[] upperBoundsCrossingXFactors) {
        this.upperBoundsCrossingXFactors = upperBoundsCrossingXFactors;
    }

    public float getUpperBound() {
        return upperBound;
    }

    public void setUpperBound(float upperBound) {
        this.upperBound = upperBound;
    }

    public boolean isUpperBoundCrossingPredicted() {
        return upperBoundCrossingPredicted;
    }

    public void setUpperBoundCrossingPredicted(
        boolean upperBoundCrossingPredicted) {
        this.upperBoundCrossingPredicted = upperBoundCrossingPredicted;
    }
}
