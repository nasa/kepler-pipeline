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
 * Hibernate class for the table that contains the PDQ module output specific
 * metric reports.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "PDQ_MOD_OUT_REPORT")
public class ModuleOutputMetricReport extends MetricReport {

    public static enum MetricType {
        BACKGROUND_LEVEL,
        BLACK_LEVEL,
        CENTROIDS_MEAN_COL,
        CENTROIDS_MEAN_ROW,
        DARK_CURRENT,
        DYNAMIC_RANGE,
        ENCIRCLED_ENERGY,
        MEAN_FLUX,
        PLATE_SCALE,
        SMEAR_LEVEL;

        private final String name;

        private MetricType() {
            this.name = StringUtils.constantToCamel(this.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    /**
     * The CCD module, or {@link #CCD_MOD_OUT_ALL} if this report represents the
     * entire focal plane
     */
    private int ccdModule;

    /**
     * The CCD output, or {@link #CCD_MOD_OUT_ALL} if this report represents the
     * entire focal plane
     */
    private int ccdOutput;

    private MetricType type;

    /**
     * Creates an {@link ModuleOutputMetricReport}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    ModuleOutputMetricReport() {
    }

    public ModuleOutputMetricReport(Builder builder) {
        super(builder);
        type = builder.type;
        ccdModule = builder.ccdModule;
        ccdOutput = builder.ccdOutput;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
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
        if (!(obj instanceof ModuleOutputMetricReport)) {
            return false;
        }
        final ModuleOutputMetricReport other = (ModuleOutputMetricReport) obj;
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
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

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
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
     * ModuleOutputMetricReport metricReport = new ModuleOutputMetricReport.Builder(pipelineTask,
     *     targetTable, ccdModule, ccdOutput, startCadence, endCadence).time(1.234)
     *     .value(5.678F)
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
    public static class Builder extends MetricReport.Builder {
        MetricType type;
        int ccdModule;
        int ccdOutput;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param pipelineTask the pipeline task
         * @param targetTable the target table
         * @param ccdModule the CCD module, or {@link CCD_MOD_OUT_ALL} if this
         * report represents the entire focal plane
         * @param ccdOutput the CCD output, or {@link CCD_MOD_OUT_ALL} if this
         * report represents the entire focal plane
         * @throws NullPointerException if either {@code pipelineTask} or
         * {@code targetTable} is {@code null}
         * @throws IllegalArgumentException if {@code startCadence} is not less
         * than or equal to {@code endCadence}
         */
        public Builder(PipelineTask pipelineTask, TargetTable targetTable,
            int ccdModule, int ccdOutput) {

            super(pipelineTask, targetTable);

            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
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

        public Builder type(MetricType type) {
            this.type = type;
            return this;
        }

        public ModuleOutputMetricReport build() {
            return new ModuleOutputMetricReport(this);
        }
    }

}
