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

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.MappedSuperclass;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

/**
 * A threshold crossing event detected by TPS.
 *
 * @author Bill Wohler
 */
@MappedSuperclass
@XmlType
public class DvThresholdCrossingEvent {

    @XmlAttribute
    private int keplerId; // CM

    @XmlAttribute
    private float chiSquare1;

    @XmlAttribute
    private float chiSquare2;

    @XmlAttribute
    private int chiSquareDof1;

    @XmlAttribute
    private float chiSquareDof2;

    @XmlAttribute
    private float chiSquareGof;

    @XmlAttribute
    private int chiSquareGofDof;

    @XmlAttribute
    private float robustStatistic;

    @XmlAttribute
    private double epochMjd; // TPS, DV

    @XmlAttribute(name = "orbitalPeriodInDays")
    private double orbitalPeriod; // TPS, DV

    @XmlAttribute(name = "trialTransitPulseDurationInHours")
    private float trialTransitPulseDuration; // TPS, DV

    @XmlAttribute
    private float maxMultipleEventSigma; // TPS, DV

    @XmlAttribute
    private float maxSingleEventSigma; // TPS, DV

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    @Column(name = "THRSHLD_FOR_DSRD_PFA")
    @XmlAttribute
    private float thresholdForDesiredPfa;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "maxMesPhaseInDays", column = @Column(name = "WEAK_SECONDARY_MAX_MES_PHASE")),
        @AttributeOverride(name = "maxMes", column = @Column(name = "WEAK_SECONDARY_MAX_MES")),
        @AttributeOverride(name = "minMesPhaseInDays", column = @Column(name = "WEAK_SECONDARY_MIN_MES_PHASE")),
        @AttributeOverride(name = "minMes", column = @Column(name = "WEAK_SECONDARY_MIN_MES")),
        @AttributeOverride(name = "mesMad", column = @Column(name = "WEAK_SECONDARY_MES_MAD")),
        @AttributeOverride(name = "depthPpm.value", column = @Column(name = "WEAK_SECONDARY_DEPTHPPM_VALUE")),
        @AttributeOverride(name = "depthPpm.uncertainty", column = @Column(name = "WEAK_SECONDARY_DEPTHPPM_UNCERT")) })
    @XmlElement
    private DvWeakSecondary weakSecondary;

    @XmlAttribute
    private float maxSesInMes;

    /**
     * Creates a {@link DvThresholdCrossingEvent}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvThresholdCrossingEvent() {
    }

    protected DvThresholdCrossingEvent(Builder builder) {
        checkNotNull(builder, "builder can't be null");

        keplerId = builder.keplerId;
        chiSquare1 = builder.chiSquare1;
        chiSquare2 = builder.chiSquare2;
        chiSquareDof1 = builder.chiSquareDof1;
        chiSquareDof2 = builder.chiSquareDof2;
        chiSquareGof = builder.chiSquareGof;
        chiSquareGofDof = builder.chiSquareGofDof;
        robustStatistic = builder.robustStatistic;
        epochMjd = builder.epochMjd;
        orbitalPeriod = builder.orbitalPeriod;
        trialTransitPulseDuration = builder.trialTransitPulseDuration;
        maxMultipleEventSigma = builder.maxMultipleEventSigma;
        maxSingleEventSigma = builder.maxSingleEventSigma;
        pipelineTask = builder.pipelineTask;
        thresholdForDesiredPfa = builder.thresholdForDesiredPfa;
        weakSecondary = builder.weakSecondary;
        maxSesInMes = builder.maxSesInMes;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public float getChiSquare1() {
        return chiSquare1;
    }

    public float getChiSquare2() {
        return chiSquare2;
    }

    public int getChiSquareDof1() {
        return chiSquareDof1;
    }

    public float getChiSquareDof2() {
        return chiSquareDof2;
    }

    public float getChiSquareGof() {
        return chiSquareGof;
    }

    public int getChiSquareGofDof() {
        return chiSquareGofDof;
    }

    public float getRobustStatistic() {
        return robustStatistic;
    }

    public double getEpochMjd() {
        return epochMjd;
    }

    public double getOrbitalPeriod() {
        return orbitalPeriod;
    }

    public float getTrialTransitPulseDuration() {
        return trialTransitPulseDuration;
    }

    public float getMaxMultipleEventSigma() {
        return maxMultipleEventSigma;
    }

    public float getMaxSingleEventSigma() {
        return maxSingleEventSigma;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public float getThresholdForDesiredPfa() {
        return thresholdForDesiredPfa;
    }

    public DvWeakSecondary getWeakSecondary() {
        return weakSecondary;
    }

    public float getMaxSesInMes() {
        return maxSesInMes;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(chiSquare1);
        result = prime * result + Float.floatToIntBits(chiSquare2);
        result = prime * result + chiSquareDof1;
        result = prime * result + Float.floatToIntBits(chiSquareDof2);
        result = prime * result + Float.floatToIntBits(chiSquareGof);
        result = prime * result + chiSquareGofDof;
        long temp;
        temp = Double.doubleToLongBits(epochMjd);
        result = prime * result + (int) (temp ^ temp >>> 32);
        result = prime * result + keplerId;
        result = prime * result + Float.floatToIntBits(maxMultipleEventSigma);
        result = prime * result + Float.floatToIntBits(maxSesInMes);
        result = prime * result + Float.floatToIntBits(maxSingleEventSigma);
        temp = Double.doubleToLongBits(orbitalPeriod);
        result = prime * result + (int) (temp ^ temp >>> 32);
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        result = prime * result + Float.floatToIntBits(robustStatistic);
        result = prime * result + Float.floatToIntBits(thresholdForDesiredPfa);
        result = prime * result
            + Float.floatToIntBits(trialTransitPulseDuration);
        result = prime * result
            + (weakSecondary == null ? 0 : weakSecondary.hashCode());
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
        DvThresholdCrossingEvent other = (DvThresholdCrossingEvent) obj;
        if (Float.floatToIntBits(chiSquare1) != Float.floatToIntBits(other.chiSquare1)) {
            return false;
        }
        if (Float.floatToIntBits(chiSquare2) != Float.floatToIntBits(other.chiSquare2)) {
            return false;
        }
        if (chiSquareDof1 != other.chiSquareDof1) {
            return false;
        }
        if (chiSquareDof2 != other.chiSquareDof2) {
            return false;
        }
        if (Float.floatToIntBits(chiSquareGof) != Float.floatToIntBits(other.chiSquareGof)) {
            return false;
        }
        if (chiSquareGofDof != other.chiSquareGofDof) {
            return false;
        }
        if (Double.doubleToLongBits(epochMjd) != Double.doubleToLongBits(other.epochMjd)) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (Float.floatToIntBits(maxMultipleEventSigma) != Float.floatToIntBits(other.maxMultipleEventSigma)) {
            return false;
        }
        if (Float.floatToIntBits(maxSesInMes) != Float.floatToIntBits(other.maxSesInMes)) {
            return false;
        }
        if (Float.floatToIntBits(maxSingleEventSigma) != Float.floatToIntBits(other.maxSingleEventSigma)) {
            return false;
        }
        if (Double.doubleToLongBits(orbitalPeriod) != Double.doubleToLongBits(other.orbitalPeriod)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        if (Float.floatToIntBits(robustStatistic) != Float.floatToIntBits(other.robustStatistic)) {
            return false;
        }
        if (Float.floatToIntBits(thresholdForDesiredPfa) != Float.floatToIntBits(other.thresholdForDesiredPfa)) {
            return false;
        }
        if (Float.floatToIntBits(trialTransitPulseDuration) != Float.floatToIntBits(other.trialTransitPulseDuration)) {
            return false;
        }
        if (weakSecondary == null) {
            if (other.weakSecondary != null) {
                return false;
            }
        } else if (!weakSecondary.equals(other.weakSecondary)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        StringBuilder builder2 = new StringBuilder(128);
        builder2.append("DvThresholdCrossingEvent [keplerId=");
        builder2.append(keplerId);
        builder2.append(", chiSquare1=");
        builder2.append(chiSquare1);
        builder2.append(", chiSquare2=");
        builder2.append(chiSquare2);
        builder2.append(", chiSquareDof1=");
        builder2.append(chiSquareDof1);
        builder2.append(", chiSquareDof2=");
        builder2.append(chiSquareDof2);
        builder2.append(", chiSquareGof=");
        builder2.append(chiSquareGof);
        builder2.append(", chiSquareGofDof=");
        builder2.append(chiSquareGofDof);
        builder2.append(", robustStatistic=");
        builder2.append(robustStatistic);
        builder2.append(", epochMjd=");
        builder2.append(epochMjd);
        builder2.append(", orbitalPeriod=");
        builder2.append(orbitalPeriod);
        builder2.append(", trialTransitPulseDuration=");
        builder2.append(trialTransitPulseDuration);
        builder2.append(", maxMultipleEventSigma=");
        builder2.append(maxMultipleEventSigma);
        builder2.append(", maxSesInMes");
        builder2.append(maxSesInMes);
        builder2.append(", maxSingleEventSigma=");
        builder2.append(maxSingleEventSigma);
        builder2.append(", pipelineTask=");
        builder2.append(pipelineTask);
        builder2.append(", thresholdForDesiredPfa=");
        builder2.append(thresholdForDesiredPfa);
        builder2.append(", weakSecondary=");
        builder2.append(weakSecondary);
        builder2.append("]");
        return builder2.toString();
    }

    /**
     * Used to construct a {@link DvThresholdCrossingEvent} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvThresholdCrossingEvent} object is created
     * using the build method, implemented by sub-classes. For example:
     *
     * <pre>
     * DvSubClass subClassObject = new DvSubClass.Builder(pipelineTask).keplerId(
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
    public static class Builder {
        private int keplerId;
        private float chiSquare1;
        private float chiSquare2;
        private int chiSquareDof1;
        private float chiSquareDof2;
        private float chiSquareGof;
        private int chiSquareGofDof;
        private float robustStatistic;
        private double epochMjd;
        private double orbitalPeriod;
        private float trialTransitPulseDuration;
        private float maxMultipleEventSigma;
        private float maxSesInMes;
        private float maxSingleEventSigma;
        private PipelineTask pipelineTask;
        private float thresholdForDesiredPfa;
        private DvWeakSecondary weakSecondary;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         *
         * @param keplerId the Kepler ID
         * @param pipelineTask the pipeline task
         * @throws NullPointerException if {@code pipelineTask} is {@code null}
         */
        public Builder(int keplerId, PipelineTask pipelineTask) {

            this.keplerId = keplerId;
            this.pipelineTask = pipelineTask;
        }

        public Builder chiSquare1(float chiSquare1) {
            this.chiSquare1 = chiSquare1;
            return this;
        }

        public Builder chiSquare2(float chiSquare2) {
            this.chiSquare2 = chiSquare2;
            return this;
        }

        public Builder chiSquareDof1(int chiSquareDof1) {
            this.chiSquareDof1 = chiSquareDof1;
            return this;
        }

        public Builder chiSquareDof2(float chiSquareDof2) {
            this.chiSquareDof2 = chiSquareDof2;
            return this;
        }

        public Builder chiSquareGof(float chiSquareGof) {
            this.chiSquareGof = chiSquareGof;
            return this;
        }

        public Builder chiSquareGofDof(int chiSquareGofDof) {
            this.chiSquareGofDof = chiSquareGofDof;
            return this;
        }

        public Builder robustStatistic(float robustStatistic) {
            this.robustStatistic = robustStatistic;
            return this;
        }

        public Builder epochMjd(double epochMjd) {
            this.epochMjd = epochMjd;
            return this;
        }

        public Builder orbitalPeriod(double orbitalPeriod) {
            this.orbitalPeriod = orbitalPeriod;
            return this;
        }

        public Builder thresholdForDesiredPfa(float thresholdForDesiredPfa) {
            this.thresholdForDesiredPfa = thresholdForDesiredPfa;
            return this;
        }

        public Builder trialTransitPulseDuration(float trialTransitPulseDuration) {
            this.trialTransitPulseDuration = trialTransitPulseDuration;
            return this;
        }

        public Builder maxMultipleEventSigma(float maxMultipleEventSigma) {
            this.maxMultipleEventSigma = maxMultipleEventSigma;
            return this;
        }

        public Builder maxSingleEventSigma(float maxSingleEventSigma) {
            this.maxSingleEventSigma = maxSingleEventSigma;
            return this;
        }

        public Builder weakSecondary(DvWeakSecondary weakSecondary) {
            this.weakSecondary = weakSecondary;
            return this;
        }

        public Builder maxSesInMes(float maxSesInMes) {
            this.maxSesInMes = maxSesInMes;
            return this;
        }

        public DvThresholdCrossingEvent build() {
            return new DvThresholdCrossingEvent(this);
        }
    }
}
