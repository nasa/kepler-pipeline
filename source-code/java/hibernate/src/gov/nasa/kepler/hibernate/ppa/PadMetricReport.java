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
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * Hibernate class for the table that contains the PPA attitude reports.
 * 
 * @author Jay Gunter
 * @author Bill Wohler
 */
@Entity
@Table(name = "PPA_PAD_METRIC_REPORT")
public class PadMetricReport extends MetricReport {

    public static enum ReportType {
        DELTA_RA, DELTA_DEC, DELTA_ROLL
    }

    /**
     * The type of attitude solution.
     */
    private ReportType type;

    /**
     * Creates an {@link PadMetricReport}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    PadMetricReport() {
    }

    /**
     * Creates a new {@link PadMetricReport} from the given builder.
     */
    private PadMetricReport(Builder builder) {
        super(builder);
        type = builder.type;
    }

    public ReportType getType() {
        return type;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + (type == null ? 0 : type.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (!(obj instanceof PadMetricReport)) {
            return false;
        }
        final PadMetricReport other = (PadMetricReport) obj;
        if (type == null) {
            if (other.type != null) {
                return false;
            }
        } else if (!type.equals(other.type)) {
            return false;
        }
        return true;
    }

    /**
     * Used to construct an {@link PadMetricReport} object. To use this class, a
     * {@link Builder} object is created with the required parameters
     * (pipelineTask, targetTable, startCadence, and endCadence). Then non-null
     * fields are set using the available builder methods. Finally, a
     * {@link PadMetricReport} object is returned by using the build method. For
     * example:
     * 
     * <pre>
     * PadMetricReport metricReport = new PadMetricReport.Builder(pipelineTask,
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
    public static class Builder extends MetricReport.Builder {
        private ReportType type;

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

            super(pipelineTask, targetTable, startCadence, endCadence);
        }

        @Override
        public Builder adaptiveBoundsReport(BoundsReport adaptiveBoundsReport) {
            super.adaptiveBoundsReport(adaptiveBoundsReport);
            return this;
        }

        @Override
        public Builder adaptiveBoundsXFactor(float adaptiveBoundsXFactor) {
            super.adaptiveBoundsXFactor(adaptiveBoundsXFactor);
            return this;
        }

        @Override
        public Builder fixedBoundsReport(BoundsReport fixedBoundsReport) {
            super.fixedBoundsReport(fixedBoundsReport);
            return this;
        }

        @Override
        public Builder meanValue(float meanValue) {
            super.meanValue(meanValue);
            return this;
        }

        @Override
        public Builder time(double time) {
            super.time(time);
            return this;
        }

        @Override
        public Builder trendReport(TrendReport trendReport) {
            super.trendReport(trendReport);
            return this;
        }

        @Override
        public Builder trackAlertLevel(int trackAlertLevel) {
            super.trackAlertLevel(trackAlertLevel);
            return this;
        }

        @Override
        public Builder trendAlertLevel(int trendAlertLevel) {
            super.trendAlertLevel(trendAlertLevel);
            return this;
        }

        @Override
        public Builder uncertainty(float uncertainty) {
            super.uncertainty(uncertainty);
            return this;
        }

        @Override
        public Builder value(float value) {
            super.value(value);
            return this;
        }

        public Builder type(ReportType type) {
            this.type = type;
            return this;
        }

        public PadMetricReport build() {
            return new PadMetricReport(this);
        }
    }
}
