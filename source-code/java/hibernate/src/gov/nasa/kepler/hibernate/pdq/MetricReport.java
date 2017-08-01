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

import gov.nasa.kepler.hibernate.mc.BoundsReport;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MappedSuperclass;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * Hibernate class for the table that contains the PPA attitude reports.
 * 
 * @author Forrest Girouard
 */
@MappedSuperclass
public class MetricReport {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PDQ_METRIC_REPORT_SEQ")
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
     * Time of the last sample (reference pixel file) used in determining the
     * summary value and uncertainty.
     */
    private double time;

    /**
     * Summary value for this metric.
     */
    private float value;

    /**
     * Uncertainty for this metric value.
     */
    private float uncertainty;

    /**
     * Adaptive bounds report for this metric.
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
        time = builder.time;
        value = builder.value;
        uncertainty = builder.uncertainty;
        adaptiveBoundsReport = builder.adaptiveBoundsReport;
        fixedBoundsReport = builder.fixedBoundsReport;
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

    public double getTime() {
        return time;
    }

    public float getValue() {
        return value;
    }

    public float getUncertainty() {
        return uncertainty;
    }

    public BoundsReport getAdaptiveBoundsReport() {
        return adaptiveBoundsReport;
    }

    public BoundsReport getFixedBoundsReport() {
        return fixedBoundsReport;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (targetTable == null ? 0 : targetTable.hashCode());
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
        if (targetTable == null) {
            if (other.targetTable != null) {
                return false;
            }
        } else if (!targetTable.equals(other.targetTable)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    /**
     * Used to construct an {@link MetricReport} object. To use this class, a
     * {@link Builder} object is created with the required parameters
     * (pipelineTask, targetTable). Then non-null fields are set using the
     * available builder methods. Finally, an object which is a subclass of
     * {@link MetricReport} is returned by using the build method (which
     * subclasses must implement). For example:
     * 
     * <pre>
     * FooMetricReport metricReport = new FooMetricReport.Builder(pipelineTask,
     *     targetTable).time(1.234)
     *     .value(5.678F)
     *     .uncertainty(0.00014F)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a
     * href="http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf">
     * Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     * @author Forrest Girouard
     */
    public static abstract class Builder {
        PipelineTask pipelineTask;
        TargetTable targetTable;
        double time;
        float value;
        float uncertainty;
        BoundsReport adaptiveBoundsReport;
        BoundsReport fixedBoundsReport;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param pipelineTask the pipeline task
         * @param targetTable the target table
         * @throws NullPointerException if either {@code pipelineTask} or
         * {@code targetTable} is {@code null}
         * @throws IllegalArgumentException if {@code startCadence} is not less
         * than or equal to {@code endCadence}
         */
        public Builder(PipelineTask pipelineTask, TargetTable targetTable) {

            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }
            if (targetTable == null) {
                throw new NullPointerException("targetTable can't be null");
            }

            this.pipelineTask = pipelineTask;
            this.targetTable = targetTable;
        }

        public Builder time(double time) {
            this.time = time;
            return this;
        }

        public Builder value(float value) {
            this.value = value;
            return this;
        }

        public Builder uncertainty(float uncertainty) {
            this.uncertainty = uncertainty;
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
    }
}
