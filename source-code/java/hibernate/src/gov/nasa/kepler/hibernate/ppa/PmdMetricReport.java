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
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

/**
 * Hibernate class for the table that contains the PPA attitude reports.
 * 
 * @author Jay Gunter
 * @author Bill Wohler
 */
@Entity
@Table(name = "PPA_PMD_METRIC_REPORT")
public class PmdMetricReport extends MetricReport {

    /**
     * The value of the CCD module or column when the report spans the entire
     * focal plane.
     */
    public static final int CCD_MOD_OUT_ALL = -1;

    /**
     * The type of this report. Several values require subtypes. The cosmic ray
     * types require an {@link EnergyDistribution} subtype while the CDPP types
     * require both a {@link CdppMagnitude} and a {@link CdppDuration} subtype.
     * <p>
     * There aren't values for MASKED_BLACK_COSMIC_RAY and
     * VIRTUAL_BLACK_COSMIC_RAY because these metrics are created with short
     * cadence time series; recall that PPA only operates on long cadence
     * metrics.
     * 
     * @author Bill Wohler
     */
    public static enum ReportType {
        ACHIEVED_COMPRESSION_EFFICIENCY,
        BACKGROUND_LEVEL,
        BLACK_LEVEL,
        BRIGHTNESS,
        CENTROIDS_MEAN_COLUMN,
        CENTROIDS_MEAN_ROW,
        DARK_CURRENT,
        ENCIRCLED_ENERGY,
        LDE_UNDERSHOOT,
        PLATE_SCALE,
        SMEAR_LEVEL,
        THEORETICAL_COMPRESSION_EFFICIENCY,
        TWO_D_BLACK,

        BLACK_COSMIC_RAY,
        MASKED_SMEAR_COSMIC_RAY,
        VIRTUAL_SMEAR_COSMIC_RAY,
        BACKGROUND_COSMIC_RAY,
        TARGET_STAR_COSMIC_RAY,

        CDPP_EXPECTED,
        CDPP_MEASURED,
        CDPP_RATIO;

        public List<String> toList() {
            List<String> strings = new ArrayList<String>();
            strings.add(toString());
            return strings;
        }

        public static List<List<String>> allValues() {
            List<List<String>> values = new ArrayList<List<String>>();

            for (ReportType type : values()) {
                String s = type.toString();
                if (s.endsWith("_COSMIC_RAY")) {
                    for (EnergyDistribution energyDistribution : EnergyDistribution.values()) {
                        List<String> strings = new ArrayList<String>();
                        strings.add(s.toString());
                        strings.add(energyDistribution.toString());
                        values.add(strings);
                    }
                } else if (s.startsWith("CDPP_")) {
                    for (CdppMagnitude magnitude : CdppMagnitude.values()) {
                        for (CdppDuration duration : CdppDuration.values()) {
                            List<String> strings = new ArrayList<String>();
                            strings.add(s.toString());
                            strings.add(magnitude.toString());
                            strings.add(duration.toString());
                            values.add(strings);
                        }
                    }
                } else {
                    List<String> strings = new ArrayList<String>();
                    strings.add(s);
                    values.add(strings);
                }
            }

            return values;
        }
    }

    public static enum EnergyDistribution {
        HIT_RATE,
        MEAN_ENERGY,
        ENERGY_VARIANCE,
        ENERGY_SKEWNESS,
        ENERGY_KURTOSIS,
    }

    public static enum CdppMagnitude {
        MAG9(9),
        MAG10(10),
        MAG11(11),
        MAG12(12),
        MAG13(13),
        MAG14(14),
        MAG15(15);

        private final int value;

        private CdppMagnitude(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    public static enum CdppDuration {
        THREE_HOUR(3), SIX_HOUR(6), TWELVE_HOUR(12);

        private final int value;

        private CdppDuration(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    /**
     * The {@link PipelineInstance} that produced this report. This can be used
     * by pag to find reports that were written by pmd.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private PipelineInstance pipelineInstance;

    /**
     * The report type.
     */
    private ReportType type;

    /**
     * The report subtype.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @JoinTable(name = "PPA_PMD_MR_SUBTYPES", joinColumns = @JoinColumn(name = "PMD_METRIC_REPORT_ID"))
    @Cascade(CascadeType.ALL)
    private Set<String> subTypes;

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

    /**
     * Creates an {@link PmdMetricReport}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    PmdMetricReport() {
    }

    /**
     * Creates a new {@link PmdMetricReport} from the given builder.
     */
    private PmdMetricReport(Builder builder) {
        super(builder);
        pipelineInstance = getPipelineTask().getPipelineInstance();
        type = builder.type;
        subTypes = builder.subtypes;
        ccdModule = builder.ccdModule;
        ccdOutput = builder.ccdOutput;
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public ReportType getType() {
        return type;
    }

    public Set<String> getSubTypes() {
        return subTypes;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + (subTypes == null ? 0 : subTypes.hashCode());
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
        if (!(obj instanceof PmdMetricReport)) {
            return false;
        }
        final PmdMetricReport other = (PmdMetricReport) obj;
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (subTypes == null) {
            if (other.subTypes != null) {
                return false;
            }
        } else if (!subTypes.equals(other.subTypes)) {
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

    /**
     * Used to construct an {@link PmdMetricReport} object. To use this class, a
     * {@link Builder} object is created with the required parameters
     * (pipelineTask, targetTable, ccdModule, ccdOutput, startCadence, and
     * endCadence). Then non-null fields are set using the available builder
     * methods. Finally, a {@link PmdMetricReport} object is returned by using
     * the build method. For example:
     * 
     * <pre>
     * PmdMetricReport metricReport = new PmdMetricReport.Builder(pipelineTask,
     *     targetTable, ccdModule, ccdOutput, startCadence, endCadence).time(1.234)
     *     .value(5.678F)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    public static class Builder extends MetricReport.Builder {
        private ReportType type;
        private Set<String> subtypes = new LinkedHashSet<String>();
        private int ccdModule;
        private int ccdOutput;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param pipelineTask the pipeline task
         * @param targetTable the target table
         * @param ccdModule the CCD module, or {@link #CCD_MOD_OUT_ALL} if this
         * report represents the entire focal plane
         * @param ccdOutput the CCD output, or {@link #CCD_MOD_OUT_ALL} if this
         * report represents the entire focal plane
         * @param startCadence the start cadence
         * @param endCadence the end cadence
         * @throws NullPointerException if either {@code pipelineTask} or
         * {@code targetTable} is {@code null}
         * @throws IllegalArgumentException if {@code startCadence} is not less
         * than or equal to {@code endCadence}
         */
        public Builder(PipelineTask pipelineTask, TargetTable targetTable,
            int ccdModule, int ccdOutput, int startCadence, int endCadence) {

            super(pipelineTask, targetTable, startCadence, endCadence);

            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
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

        public Builder subtype(EnergyDistribution energyDistribution) {
            return subtype(energyDistribution.toString());
        }

        public Builder subtype(CdppMagnitude cdppMagnitude) {
            return subtype(cdppMagnitude.toString());
        }

        public Builder subtype(CdppDuration duration) {
            return subtype(duration.toString());
        }

        private Builder subtype(String subtype) {
            subtypes.add(subtype);
            return this;
        }

        public PmdMetricReport build() {
            return new PmdMetricReport(this);
        }
    }
}
