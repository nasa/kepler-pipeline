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
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.lang.StringUtils;

import javax.persistence.Entity;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Hibernate class for the table that contains the PDQ focal plane metric
 * reports.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "PDQ_FOCAL_PLANE_REPORT")
public class FocalPlaneMetricReport extends MetricReport {

    public static enum MetricType {
        DELTA_ATTITUDE_DEC,
        DELTA_ATTITUDE_RA,
        DELTA_ATTITUDE_ROLL,
        MAX_ATTITUDE_RESIDUAL_IN_PIXELS;

        private final String name;

        private MetricType() {
            this.name = StringUtils.constantToCamel(this.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    private MetricType type;

    FocalPlaneMetricReport() {
    }

    public FocalPlaneMetricReport(Builder builder) {
        super(builder);
        type = builder.type;
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
        if (!(obj instanceof FocalPlaneMetricReport)) {
            return false;
        }
        final FocalPlaneMetricReport other = (FocalPlaneMetricReport) obj;
        if (type == null) {
            if (other.type != null) {
                return false;
            }
        } else if (!type.equals(other.type)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public MetricType getType() {
        return type;
    }

    public void setType(MetricType type) {
        this.type = type;
    }

    /**
     * Used to construct an {@link ModuleOutputMetricReport} object. To use this
     * class, a {@link Builder} object is created with the required parameters
     * (pipelineTask, targetTable, ccdModule, ccdOutput, startCadence, and
     * endCadence). Then non-null fields are set using the available builder
     * methods. Finally, a {@link ModuleOutputMetricReport} object is returned
     * by using the build method. For example:
     * 
     * <pre>
     * ModuleOutputMetricReport metricReport = new ModuleOutputMetricReport.Builder(
     *     pipelineTask, targetTable).time(1.234)
     *     .value(5.678F)
     *     .uncertainty(0.00014F)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href="http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf">
     * Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     * @author Forrest Girouard
     */
    public static class Builder extends MetricReport.Builder {
        MetricType type;

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
        public Builder(PipelineTask pipelineTask, TargetTable targetTable) {

            super(pipelineTask, targetTable);
        }

        @Override
        public Builder time(double time) {
            super.time(time);
            return this;
        }

        @Override
        public Builder value(float value) {
            super.value(value);
            return this;
        }

        @Override
        public Builder uncertainty(float uncertainty) {
            super.uncertainty(uncertainty);
            return this;
        }

        @Override
        public Builder adaptiveBoundsReport(BoundsReport adaptiveBoundsReport) {
            super.adaptiveBoundsReport(adaptiveBoundsReport);
            return this;
        }

        @Override
        public Builder fixedBoundsReport(BoundsReport fixedBoundsReport) {
            super.fixedBoundsReport(fixedBoundsReport);
            return this;
        }

        public Builder type(MetricType type) {
            this.type = type;
            return this;
        }

        public FocalPlaneMetricReport build() {
            return new FocalPlaneMetricReport(this);
        }
    }
}
