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

import gov.nasa.kepler.hibernate.mc.BoundsReport;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import javax.persistence.Embedded;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MappedSuperclass;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;

import org.apache.commons.lang.builder.StandardToStringStyle;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * Hibernate class for the table that contains the PPA attitude reports.
 * 
 * @author Jay Gunter
 * @author Bill Wohler
 */
@MappedSuperclass
public class MetricReport {

    private static StandardToStringStyle toStringStyle = new StandardToStringStyle();
    static {
        toStringStyle.setUseShortClassName(true);
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PPA_METRIC_REPORT_SEQ")
    private long id; // required by Hibernate

    /**
     * The {@link PipelineTask} of the {@link PipelineModule} that produced this
     * report. Not included in the report.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    /**
     * The {@link TargetTable} that was in effect when this report was
     * generated.
     */
    @ManyToOne
    private TargetTable targetTable;

    /**
     * The starting cadence.
     */
    private int startCadence;

    /**
     * The ending cadence.
     */
    private int endCadence;

    /**
     * Time of the last sample (reference pixel file) used in determining the
     * summary value and uncertainty.
     */
    private double time;

    /**
     * Summary value for this metric.
     */
    private float value;

    /**
     * The estimated mean value of the metric at the specified time.
     */
    private float meanValue;

    /**
     * The estimated uncertainty of the metric at the specified time.
     */
    private float uncertainty;

    private float adaptiveBoundsXFactor;

    /**
     * The metric status indicator at the specified time.
     */
    private int trackAlertLevel;

    /**
     * The metric status indicator for the future.
     */
    private int trendAlertLevel;

    /**
     * Adaptive bounds report, if available, for this metric.
     */
    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "ADAPTIVE_BOUNDS_REPORT_ID")
    private BoundsReport adaptiveBoundsReport;

    /**
     * Fixed bounds report for this metric.
     */
    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "FIXED_BOUNDS_REPORT_ID")
    private BoundsReport fixedBoundsReport;

    /**
     * Trend report for this metric.
     */
    @Embedded
    private TrendReport trendReport = new TrendReport();

    /**
     * Creates an {@link MetricReport}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    MetricReport() {
    }

    /**
     * Creates a new {@link Builder} from the given object.
     */
    protected MetricReport(Builder builder) {
        pipelineTask = builder.pipelineTask;
        targetTable = builder.targetTable;
        startCadence = builder.startCadence;
        endCadence = builder.endCadence;
        time = builder.time;
        value = builder.value;
        meanValue = builder.meanValue;
        uncertainty = builder.uncertainty;
        adaptiveBoundsXFactor = builder.adaptiveBoundsXFactor;
        trackAlertLevel = builder.trackAlertLevel;
        trendAlertLevel = builder.trendAlertLevel;
        adaptiveBoundsReport = builder.adaptiveBoundsReport;
        fixedBoundsReport = builder.fixedBoundsReport;
        trendReport = builder.trendReport;
    }

    public long getId() {
        return id;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public double getTime() {
        return time;
    }

    public float getValue() {
        return value;
    }

    public float getMeanValue() {
        return meanValue;
    }

    public float getUncertainty() {
        return uncertainty;
    }

    public float getAdaptiveBoundsXFactor() {
        return adaptiveBoundsXFactor;
    }

    public int getTrackAlertLevel() {
        return trackAlertLevel;
    }

    public int getTrendAlertLevel() {
        return trendAlertLevel;
    }

    public BoundsReport getAdaptiveBoundsReport() {
        return adaptiveBoundsReport;
    }

    public BoundsReport getFixedBoundsReport() {
        return fixedBoundsReport;
    }

    public TrendReport getTrendReport() {
        return trendReport;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (adaptiveBoundsReport == null ? 0
                : adaptiveBoundsReport.hashCode());
        result = prime * result + Float.floatToIntBits(adaptiveBoundsXFactor);
        result = prime * result + endCadence;
        result = prime * result
            + (fixedBoundsReport == null ? 0 : fixedBoundsReport.hashCode());
        result = prime * result + Float.floatToIntBits(meanValue);
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        result = prime * result + startCadence;
        result = prime * result
            + (targetTable == null ? 0 : targetTable.hashCode());
        long temp;
        temp = Double.doubleToLongBits(time);
        result = prime * result + (int) (temp ^ temp >>> 32);
        result = prime * result + trackAlertLevel;
        result = prime * result + trendAlertLevel;
        result = prime * result
            + (trendReport == null ? 0 : trendReport.hashCode());
        result = prime * result + Float.floatToIntBits(uncertainty);
        result = prime * result + Float.floatToIntBits(value);
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
        if (!(obj instanceof MetricReport)) {
            return false;
        }
        final MetricReport other = (MetricReport) obj;
        if (adaptiveBoundsReport == null) {
            if (other.adaptiveBoundsReport != null) {
                return false;
            }
        } else if (!adaptiveBoundsReport.equals(other.adaptiveBoundsReport)) {
            return false;
        }
        if (Float.floatToIntBits(adaptiveBoundsXFactor) != Float.floatToIntBits(other.adaptiveBoundsXFactor)) {
            return false;
        }
        if (endCadence != other.endCadence) {
            return false;
        }
        if (fixedBoundsReport == null) {
            if (other.fixedBoundsReport != null) {
                return false;
            }
        } else if (!fixedBoundsReport.equals(other.fixedBoundsReport)) {
            return false;
        }
        if (Float.floatToIntBits(meanValue) != Float.floatToIntBits(other.meanValue)) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (targetTable == null) {
            if (other.targetTable != null) {
                return false;
            }
        } else if (!targetTable.equals(other.targetTable)) {
            return false;
        }
        if (Double.doubleToLongBits(time) != Double.doubleToLongBits(other.time)) {
            return false;
        }
        if (trackAlertLevel != other.trackAlertLevel) {
            return false;
        }
        if (trendAlertLevel != other.trendAlertLevel) {
            return false;
        }
        if (trendReport == null) {
            if (other.trendReport != null) {
                return false;
            }
        } else if (!trendReport.equals(other.trendReport)) {
            return false;
        }
        if (Float.floatToIntBits(uncertainty) != Float.floatToIntBits(other.uncertainty)) {
            return false;
        }
        if (Float.floatToIntBits(value) != Float.floatToIntBits(other.value)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        // Don't even think of using ReflectionToStringBuilder--the output
        // for all reports across the focal plane is 30 MB! With this version,
        // it is "only" 600 kB.

        ToStringBuilder builder = new ToStringBuilder(this, toStringStyle).append(
            "id", id)
            .append("pt.id", pipelineTask.getId());

        if (pipelineTask.getPipelineInstance() != null) {
            builder.append("pi.id", pipelineTask.getPipelineInstance()
                .getId());
        }

        return builder.toString();
    }

    /**
     * Used to construct an {@link MetricReport} object. To use this class, a
     * {@link Builder} object is created with the required parameters
     * (pipelineTask, targetTable, startCadence, and endCadence). Then non-null
     * fields are set using the available builder methods. Finally, an object
     * which is a subclass of {@link MetricReport} is returned by using the
     * build method (which subclasses must implement). For example:
     * 
     * <pre>
     * FooMetricReport metricReport = new FooMetricReport.Builder(pipelineTask,
     *     targetTable, startCadence, endCadence).time(1.234)
     *     .value(5.678F)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a
     * href="http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf">
     * Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    public static abstract class Builder {
        private PipelineTask pipelineTask;
        private TargetTable targetTable;
        private int startCadence;
        private int endCadence;
        private double time;
        private float value;
        private float meanValue;
        private float uncertainty;
        private float adaptiveBoundsXFactor;
        private int trackAlertLevel;
        private int trendAlertLevel;
        private BoundsReport adaptiveBoundsReport;
        private BoundsReport fixedBoundsReport;
        private TrendReport trendReport = new TrendReport();

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param pipelineTask the pipeline task
         * @param targetTable the target table
         * @param startCadence the start cadence
         * @param endCadence the end cadence
         * @throws NullPointerException if either {@code pipelineTask} or
         * {@code targetTable} is {@code null}
         * @throws IllegalArgumentException if {@code startCadence} is not less
         * than or equal to {@code endCadence}
         */
        public Builder(PipelineTask pipelineTask, TargetTable targetTable,
            int startCadence, int endCadence) {

            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }
            if (targetTable == null) {
                throw new NullPointerException("targetTable can't be null");
            }
            if (startCadence > endCadence) {
                throw new IllegalArgumentException("startCadence ("
                    + startCadence
                    + ") must be less than or equal to endCadence ("
                    + endCadence + ")");
            }

            this.pipelineTask = pipelineTask;
            this.targetTable = targetTable;
            this.startCadence = startCadence;
            this.endCadence = endCadence;
        }

        public Builder time(double time) {
            this.time = time;
            return this;
        }

        public Builder value(float value) {
            this.value = value;
            return this;
        }

        public Builder meanValue(float meanValue) {
            this.meanValue = meanValue;
            return this;
        }

        public Builder uncertainty(float uncertainty) {
            this.uncertainty = uncertainty;
            return this;
        }

        public Builder adaptiveBoundsXFactor(float adaptiveBoundsXFactor) {
            this.adaptiveBoundsXFactor = adaptiveBoundsXFactor;
            return this;
        }

        public Builder trackAlertLevel(int trackAlertLevel) {
            this.trackAlertLevel = trackAlertLevel;
            return this;
        }

        public Builder trendAlertLevel(int trendAlertLevel) {
            this.trendAlertLevel = trendAlertLevel;
            return this;
        }

        public Builder adaptiveBoundsReport(BoundsReport adaptiveBoundsReport) {
            this.adaptiveBoundsReport = adaptiveBoundsReport;
            return this;
        }

        public Builder fixedBoundsReport(BoundsReport fixedBoundsReport) {
            this.fixedBoundsReport = fixedBoundsReport;
            return this;
        }

        public Builder trendReport(TrendReport trendReport) {
            this.trendReport = trendReport;
            return this;
        }
    }
}
