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

package gov.nasa.kepler.hibernate.mc;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * Hibernate class for the table that contains the bounds reports.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "MC_BOUNDS_REPORT")
public class BoundsReport {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_BOUNDS_REPORT_SEQ")
    private long id;

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
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOLB_TIMES")
    @IndexColumn(name = "IDXLT")
    private List<Double> outOfLowerBoundsTimes;

    /**
     * The metric values which have exceeded the lower bound.
     */
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOLB_VALUES")
    @IndexColumn(name = "IDXLV")
    private List<Float> outOfLowerBoundsValues;

    /**
     * The estimated number of standard deviations that the out of bounds metric
     * values deviate from the mean.
     */
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOLB_XFACTOR")
    @IndexColumn(name = "IDXLX")
    private List<Float> lowerBoundsCrossingXFactors;

    /**
     * The total number of samples for which the metric has exceeded the upper
     * bound for the current target table.
     */
    private int outOfUpperBoundsCount;

    /**
     * The sample times when the metric has exceeded the upper bound.
     */
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOUB_TIMES")
    @IndexColumn(name = "IDXUT")
    private List<Double> outOfUpperBoundsTimes;

    /**
     * The metric values which have exceeded the upper bound.
     */
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOUB_VALUES")
    @IndexColumn(name = "IDXUV")
    private List<Float> outOfUpperBoundsValues;

    /**
     * The estimated number of standard deviations that the out of bounds metric
     * values deviate from the mean.
     */
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "MC_OOUB_XFACTOR")
    @IndexColumn(name = "IDXUX")
    private List<Float> upperBoundsCrossingXFactors;

    /**
     * The current upper adaptive bound.
     */
    private float upperBound;

    /**
     * The current lower adaptive bound.
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
     * The predicted absolute MJD for crossing the previously indicated bounds.
     */
    private double crossingTime;

    public BoundsReport() {
    }

    public BoundsReport(float lowerBound, float upperBound) {
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
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
        result = prime
            * result
            + (lowerBoundsCrossingXFactors == null ? 0
                : lowerBoundsCrossingXFactors.hashCode());
        result = prime * result + (outOfLowerBound ? 1231 : 1237);
        result = prime * result + outOfLowerBoundsCount;
        result = prime
            * result
            + (outOfLowerBoundsTimes == null ? 0
                : outOfLowerBoundsTimes.hashCode());
        result = prime
            * result
            + (outOfLowerBoundsValues == null ? 0
                : outOfLowerBoundsValues.hashCode());
        result = prime * result + (outOfUpperBound ? 1231 : 1237);
        result = prime * result + outOfUpperBoundsCount;
        result = prime
            * result
            + (outOfUpperBoundsTimes == null ? 0
                : outOfUpperBoundsTimes.hashCode());
        result = prime
            * result
            + (outOfUpperBoundsValues == null ? 0
                : outOfUpperBoundsValues.hashCode());
        result = prime * result + Float.floatToIntBits(upperBound);
        result = prime * result + (upperBoundCrossingPredicted ? 1231 : 1237);
        result = prime
            * result
            + (upperBoundsCrossingXFactors == null ? 0
                : upperBoundsCrossingXFactors.hashCode());
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
        if (lowerBoundsCrossingXFactors == null) {
            if (other.lowerBoundsCrossingXFactors != null) {
                return false;
            }
        } else if (!lowerBoundsCrossingXFactors.equals(other.lowerBoundsCrossingXFactors)) {
            return false;
        }
        if (outOfLowerBound != other.outOfLowerBound) {
            return false;
        }
        if (outOfLowerBoundsCount != other.outOfLowerBoundsCount) {
            return false;
        }
        if (outOfLowerBoundsTimes == null) {
            if (other.outOfLowerBoundsTimes != null) {
                return false;
            }
        } else if (!outOfLowerBoundsTimes.equals(other.outOfLowerBoundsTimes)) {
            return false;
        }
        if (outOfLowerBoundsValues == null) {
            if (other.outOfLowerBoundsValues != null) {
                return false;
            }
        } else if (!outOfLowerBoundsValues.equals(other.outOfLowerBoundsValues)) {
            return false;
        }
        if (outOfUpperBound != other.outOfUpperBound) {
            return false;
        }
        if (outOfUpperBoundsCount != other.outOfUpperBoundsCount) {
            return false;
        }
        if (outOfUpperBoundsTimes == null) {
            if (other.outOfUpperBoundsTimes != null) {
                return false;
            }
        } else if (!outOfUpperBoundsTimes.equals(other.outOfUpperBoundsTimes)) {
            return false;
        }
        if (outOfUpperBoundsValues == null) {
            if (other.outOfUpperBoundsValues != null) {
                return false;
            }
        } else if (!outOfUpperBoundsValues.equals(other.outOfUpperBoundsValues)) {
            return false;
        }
        if (Float.floatToIntBits(upperBound) != Float.floatToIntBits(other.upperBound)) {
            return false;
        }
        if (upperBoundCrossingPredicted != other.upperBoundCrossingPredicted) {
            return false;
        }
        if (upperBoundsCrossingXFactors == null) {
            if (other.upperBoundsCrossingXFactors != null) {
                return false;
            }
        } else if (!upperBoundsCrossingXFactors.equals(other.upperBoundsCrossingXFactors)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public long getId() {
        return id;
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

    public List<Double> getOutOfLowerBoundsTimes() {
        return outOfLowerBoundsTimes;
    }

    public void setOutOfLowerBoundsTimes(List<Double> outOfLowerBoundsTimes) {
        this.outOfLowerBoundsTimes = outOfLowerBoundsTimes;
    }

    public void setOutOfLowerBoundsTimes(double[] outOfLowerBoundsTimes) {
        this.outOfLowerBoundsTimes = new ArrayList<Double>();
        for (double time : outOfLowerBoundsTimes) {
            this.outOfLowerBoundsTimes.add(time);
        }
    }

    public List<Float> getOutOfLowerBoundsValues() {
        return outOfLowerBoundsValues;
    }

    public void setOutOfLowerBoundsValues(List<Float> outOfLowerBoundsValues) {
        this.outOfLowerBoundsValues = outOfLowerBoundsValues;
    }

    public void setOutOfLowerBoundsValues(float[] outOfLowerBoundsValues) {
        this.outOfLowerBoundsValues = new ArrayList<Float>();
        for (float value : outOfLowerBoundsValues) {
            this.outOfLowerBoundsValues.add(value);
        }
    }

    public List<Float> getLowerBoundsCrossingXFactors() {
        return lowerBoundsCrossingXFactors;
    }

    public void setLowerBoundsCrossingXFactors(
        List<Float> lowerBoundsCrossingXFactors) {
        this.lowerBoundsCrossingXFactors = lowerBoundsCrossingXFactors;
    }

    public void setLowerBoundsCrossingXFactors(float[] lowerBoundsCrossingXFactors) {
        this.lowerBoundsCrossingXFactors = new ArrayList<Float>();
        for (float value : lowerBoundsCrossingXFactors) {
            this.lowerBoundsCrossingXFactors.add(value);
        }
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

    public List<Double> getOutOfUpperBoundsTimes() {
        return outOfUpperBoundsTimes;
    }

    public void setOutOfUpperBoundsTimes(List<Double> outOfUpperBoundsTimes) {
        this.outOfUpperBoundsTimes = outOfUpperBoundsTimes;
    }

    public void setOutOfUpperBoundsTimes(double[] outOfUpperBoundsTimes) {
        this.outOfUpperBoundsTimes = new ArrayList<Double>();
        for (double time : outOfUpperBoundsTimes) {
            this.outOfUpperBoundsTimes.add(time);
        }
    }

    public List<Float> getOutOfUpperBoundsValues() {
        return outOfUpperBoundsValues;
    }

    public void setOutOfUpperBoundsValues(List<Float> outOfUpperBoundsValues) {
        this.outOfUpperBoundsValues = outOfUpperBoundsValues;
    }

    public void setOutOfUpperBoundsValues(float[] outOfUpperBoundsValues) {
        this.outOfUpperBoundsValues = new ArrayList<Float>();
        for (float value : outOfUpperBoundsValues) {
            this.outOfUpperBoundsValues.add(value);
        }
    }

    public List<Float> getUpperBoundsCrossingXFactors() {
        return upperBoundsCrossingXFactors;
    }

    public void setUpperBoundsCrossingXFactors(
        List<Float> upperBoundsCrossingXFactors) {
        this.upperBoundsCrossingXFactors = upperBoundsCrossingXFactors;
    }

    public void setUpperBoundsCrossingXFactors(float[] upperBoundsCrossingXFactors) {
        this.upperBoundsCrossingXFactors = new ArrayList<Float>();
        for (float value : upperBoundsCrossingXFactors) {
            this.upperBoundsCrossingXFactors.add(value);
        }
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
