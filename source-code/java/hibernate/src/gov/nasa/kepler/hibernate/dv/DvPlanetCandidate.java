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

package gov.nasa.kepler.hibernate.dv;

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A planet candidate detected by DV.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "DV_PLANET_CANDIDATE")
@XmlType
public class DvPlanetCandidate extends DvThresholdCrossingEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_PLANET_CANDIDATE_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private int planetNumber;

    @XmlAttribute
    private int expectedTransitCount;

    @XmlAttribute
    private int observedTransitCount;

    @XmlAttribute
    private boolean suspectedEclipsingBinary;

    @XmlAttribute
    private double significance; // DV (Bootstrap)

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "statistics", column = @Column(name = "BOOTSTRAP_HISTOGRAM_STATS")),
        @AttributeOverride(name = "probabilities", column = @Column(name = "BOOTSTRAP_HISTOGRAM_PROB")) })
    @XmlElement
    private DvBootstrapHistogram bootstrapHistogram; // DV (Bootstrap)

    @Column(name = "BTSTRP_THRSHLD_FOR_DSRD_PFA")
    @XmlAttribute
    private float bootstrapThresholdForDesiredPfa;

    @XmlAttribute
    @Column(name = "STAT_RATIO_BELOW_THRESHOLD")
    private boolean statisticRatioBelowThreshold;

    @XmlAttribute
    private float modelChiSquare2;

    @XmlAttribute
    private int modelChiSquareDof2;

    @XmlAttribute
    private float modelChiSquareGof;

    @XmlAttribute
    private int modelChiSquareGofDof;
    
    @XmlAttribute
    private float bootstrapMesMean;
    
    @XmlAttribute
    private float bootstrapMesStd;

    /**
     * Creates an {@link DvPlanetCandidate}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvPlanetCandidate() {
    }

    private DvPlanetCandidate(Builder builder) {
        super(builder);
        id = builder.id;
        bootstrapHistogram = builder.bootstrapHistogram;
        bootstrapThresholdForDesiredPfa = builder.bootstrapThresholdForDesiredPfa;
        expectedTransitCount = builder.expectedTransitCount;
        modelChiSquare2 = builder.modelChiSquare2;
        modelChiSquareDof2 = builder.modelChiSquareDof2;
        modelChiSquareGof = builder.modelChiSquareGof;
        modelChiSquareGofDof = builder.modelChiSquareGofDof;
        observedTransitCount = builder.observedTransitCount;
        planetNumber = builder.planetNumber;
        significance = builder.significance;
        statisticRatioBelowThreshold = builder.statisticRatioBelowThreshold;
        suspectedEclipsingBinary = builder.suspectedEclipsingBinary;
        bootstrapMesMean = builder.bootstrapMesMean;
        bootstrapMesStd = builder.bootstrapMesStd;
    }

    public long getId() {
        return id;
    }

    public DvBootstrapHistogram getBootstrapHistogram() {
        return bootstrapHistogram;
    }

    public float getBootstrapThresholdForDesiredPfa() {
        return bootstrapThresholdForDesiredPfa;
    }

    public int getExpectedTransitCount() {
        return expectedTransitCount;
    }

    public float getModelChiSquare2() {
        return modelChiSquare2;
    }

    public int getModelChiSquareDof2() {
        return modelChiSquareDof2;
    }

    public float getModelChiSquareGof() {
        return modelChiSquareGof;
    }

    public int getModelChiSquareGofDof() {
        return modelChiSquareGofDof;
    }

    public int getObservedTransitCount() {
        return observedTransitCount;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public double getSignificance() {
        return significance;
    }

    public boolean isStatisticRatioBelowThreshold() {
        return statisticRatioBelowThreshold;
    }

    public boolean isSuspectedEclipsingBinary() {
        return suspectedEclipsingBinary;
    }
    
    public float getBootstrapMesMean() {
        return bootstrapMesMean;
    }
    
    public float getBootstrapMesStd() {
        return bootstrapMesStd;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result
            + (bootstrapHistogram == null ? 0 : bootstrapHistogram.hashCode());
        result = prime * result + Float.floatToIntBits(bootstrapMesMean);
        result = prime * result + Float.floatToIntBits(bootstrapMesStd);
        result = prime * result
            + Float.floatToIntBits(bootstrapThresholdForDesiredPfa);
        result = prime * result + expectedTransitCount;
        result = prime * result + Float.floatToIntBits(modelChiSquare2);
        result = prime * result + modelChiSquareDof2;
        result = prime * result + Float.floatToIntBits(modelChiSquareGof);
        result = prime * result + modelChiSquareGofDof;
        result = prime * result + observedTransitCount;
        result = prime * result + planetNumber;
        long temp;
        temp = Double.doubleToLongBits(significance);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + (statisticRatioBelowThreshold ? 1231 : 1237);
        result = prime * result + (suspectedEclipsingBinary ? 1231 : 1237);
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
        if (!(obj instanceof DvPlanetCandidate)) {
            return false;
        }
        DvPlanetCandidate other = (DvPlanetCandidate) obj;
        if (bootstrapHistogram == null) {
            if (other.bootstrapHistogram != null) {
                return false;
            }
        } else if (!bootstrapHistogram.equals(other.bootstrapHistogram)) {
            return false;
        }
        if (Float.floatToIntBits(bootstrapMesMean) != Float.floatToIntBits(other.bootstrapMesMean)) {
            return false;
        }
        if (Float.floatToIntBits(bootstrapMesStd) != Float.floatToIntBits(other.bootstrapMesStd)) {
            return false;
        }
        if (Float.floatToIntBits(bootstrapThresholdForDesiredPfa) != Float.floatToIntBits(other.bootstrapThresholdForDesiredPfa)) {
            return false;
        }
        if (expectedTransitCount != other.expectedTransitCount) {
            return false;
        }
        if (Float.floatToIntBits(modelChiSquare2) != Float.floatToIntBits(other.modelChiSquare2)) {
            return false;
        }
        if (modelChiSquareDof2 != other.modelChiSquareDof2) {
            return false;
        }
        if (Float.floatToIntBits(modelChiSquareGof) != Float.floatToIntBits(other.modelChiSquareGof)) {
            return false;
        }
        if (modelChiSquareGofDof != other.modelChiSquareGofDof) {
            return false;
        }
        if (observedTransitCount != other.observedTransitCount) {
            return false;
        }
        if (planetNumber != other.planetNumber) {
            return false;
        }
        if (Double.doubleToLongBits(significance) != Double.doubleToLongBits(other.significance)) {
            return false;
        }
        if (statisticRatioBelowThreshold != other.statisticRatioBelowThreshold) {
            return false;
        }
        if (suspectedEclipsingBinary != other.suspectedEclipsingBinary) {
            return false;
        }
        return true;
    }
    
    @Override
    public String toString() {
        return new ToStringBuilder(this).append(id)
            .appendSuper("DvThresholdCrossingEvent")
            .append("bootstrapHistogram", bootstrapHistogram)
            .append("boostrapThresholdForDesiredPfa",
                bootstrapThresholdForDesiredPfa)
            .append("expectedTransitCount", expectedTransitCount)
            .append("modelChiSquare2", modelChiSquare2)
            .append("modelChiSquareDof2", modelChiSquareDof2)
            .append("modelChiSquareGof", modelChiSquareGof)
            .append("modelChiSquareGofDof", modelChiSquareGofDof)
            .append("observedTransitCount", observedTransitCount)
            .append("planetNumber", planetNumber)
            .append("significance", significance)
            .append("statisticRatioBelowThreshold",
                isStatisticRatioBelowThreshold())
            .append("suspectedEclipsingBinary", suspectedEclipsingBinary)
            .append("bootstrapMesMean", bootstrapMesMean)
            .append("bootstrapMesStd", bootstrapMesStd)
            .toString();
    }

    /**
     * Used to construct a {@link DvPlanetCandidate} object. To use this class,
     * a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPlanetCandidate} object is created using the
     * build method. For example:
     * 
     * <pre>
     * DvPlanetCandidate planetCandidate = new DvPlanetCandidate.Builder(pipelineTask).keplerId(
     *     12345678)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    @XmlTransient
    public static class Builder extends DvThresholdCrossingEvent.Builder {
        private long id;
        private DvBootstrapHistogram bootstrapHistogram;
        private float bootstrapThresholdForDesiredPfa;
        private int expectedTransitCount;
        private float modelChiSquare2;
        private int modelChiSquareDof2;
        private float modelChiSquareGof;
        private int modelChiSquareGofDof;
        private int observedTransitCount;
        private int planetNumber;
        private double significance;
        private boolean statisticRatioBelowThreshold;
        private boolean suspectedEclipsingBinary;
        private float bootstrapMesMean;
        private float bootstrapMesStd;

        /**
         * Creates a {@link Builder} object with the given required parameter.
         * 
         * @param keplerId the Kepler ID
         * @param pipelineTask the pipeline task
         * @throws NullPointerException if {@code pipelineTask} is {@code null}
         */
        public Builder(int keplerId, PipelineTask pipelineTask) {
            super(keplerId, pipelineTask);
        }

        @Override
        public Builder chiSquare1(float chiSquare1) {
            super.chiSquare1(chiSquare1);
            return this;
        }

        @Override
        public Builder chiSquare2(float chiSquare2) {
            super.chiSquare2(chiSquare2);
            return this;
        }

        @Override
        public Builder chiSquareDof1(int chiSquareDof1) {
            super.chiSquareDof1(chiSquareDof1);
            return this;
        }

        @Override
        public Builder chiSquareDof2(float chiSquareDof2) {
            super.chiSquareDof2(chiSquareDof2);
            return this;
        }

        @Override
        public Builder chiSquareGof(float chiSquareGof) {
            super.chiSquareGof(chiSquareGof);
            return this;
        }

        @Override
        public Builder chiSquareGofDof(int chiSquareGofDof) {
            super.chiSquareGofDof(chiSquareGofDof);
            return this;
        }

        @Override
        public Builder epochMjd(double epochMjd) {
            super.epochMjd(epochMjd);
            return this;
        }

        @Override
        public Builder maxMultipleEventSigma(float maxMultipleEventSigma) {
            super.maxMultipleEventSigma(maxMultipleEventSigma);
            return this;
        }

        @Override
        public Builder maxSesInMes(float maxSesInMes) {
            super.maxSesInMes(maxSesInMes);
            return this;
        }

        @Override
        public Builder maxSingleEventSigma(float maxSingleEventSigma) {
            super.maxSingleEventSigma(maxSingleEventSigma);
            return this;
        }

        @Override
        public Builder orbitalPeriod(double orbitalPeriod) {
            super.orbitalPeriod(orbitalPeriod);
            return this;
        }

        @Override
        public Builder robustStatistic(float robustStatistic) {
            super.robustStatistic(robustStatistic);
            return this;
        }

        @Override
        public Builder thresholdForDesiredPfa(float thresholdForDesiredPfa) {
            super.thresholdForDesiredPfa(thresholdForDesiredPfa);
            return this;
        }

        @Override
        public Builder trialTransitPulseDuration(float trialTransitPulseDuration) {
            super.trialTransitPulseDuration(trialTransitPulseDuration);
            return this;
        }

        @Override
        public Builder weakSecondary(DvWeakSecondary weakSecondary) {
            super.weakSecondary(weakSecondary);
            return this;
        }

        /**
         * For use by tests only.
         */
        Builder id(long id) {
            this.id = id;
            return this;
        }

        public Builder bootstrapHistogram(
            DvBootstrapHistogram bootstrapHistogram) {
            this.bootstrapHistogram = bootstrapHistogram;
            return this;
        }

        public Builder bootstrapThresholdForDesiredPfa(
            float bootstrapThresholdForDesiredPfa) {
            this.bootstrapThresholdForDesiredPfa = bootstrapThresholdForDesiredPfa;
            return this;
        }

        public Builder expectedTransitCount(int expectedTransitCount) {
            this.expectedTransitCount = expectedTransitCount;
            return this;
        }

        public Builder modelChiSquare2(float modelChiSquare2) {
            this.modelChiSquare2 = modelChiSquare2;
            return this;
        }

        public Builder modelChiSquareDof2(int modelChiSquareDof2) {
            this.modelChiSquareDof2 = modelChiSquareDof2;
            return this;
        }

        public Builder modelChiSquareGof(float modelChiSquareGof) {
            this.modelChiSquareGof = modelChiSquareGof;
            return this;
        }

        public Builder modelChiSquareGofDof(int modelChiSquareGofDof) {
            this.modelChiSquareGofDof = modelChiSquareGofDof;
            return this;
        }

        public Builder observedTransitCount(int observedTransitCount) {
            this.observedTransitCount = observedTransitCount;
            return this;
        }

        public Builder planetNumber(int planetNumber) {
            this.planetNumber = planetNumber;
            return this;
        }

        public Builder significance(double significance) {
            this.significance = significance;
            return this;
        }

        public Builder statisticRatioBelowThreshold(
            boolean statisticRatioBelowThreshold) {
            this.statisticRatioBelowThreshold = statisticRatioBelowThreshold;
            return this;
        }

        public Builder suspectedEclipsingBinary(boolean suspectedEclipsingBinary) {
            this.suspectedEclipsingBinary = suspectedEclipsingBinary;
            return this;
        }
        
        public Builder bootstrapMesMean(float bootstrapMesMean) {
            this.bootstrapMesMean = bootstrapMesMean;
            return this;
        }
        
        public Builder bootstrapMesStd(float bootstrapMesStd) {
            this.bootstrapMesStd = bootstrapMesStd;
            return this;
        }

        @Override
        public DvPlanetCandidate build() {
            return new DvPlanetCandidate(this);
        }
    }
}
