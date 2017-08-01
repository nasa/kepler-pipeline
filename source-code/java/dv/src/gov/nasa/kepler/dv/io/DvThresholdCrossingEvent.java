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

package gov.nasa.kepler.dv.io;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.apache.commons.lang.ArrayUtils;

/**
 * A threshold crossing event.
 *
 * @author Forrest Girouard
 */
public class DvThresholdCrossingEvent implements Persistable {

    private float chiSquare1;
    private float chiSquare2;
    private int chiSquareDof1;
    private float chiSquareDof2;
    private float chiSquareGof;
    private int chiSquareGofDof;
    @OracleDouble
    private double epochMjd;
    private int keplerId;
    private float maxMultipleEventSigma;
    private float maxSesInMes;
    private float maxSingleEventSigma;
    @OracleDouble
    private double orbitalPeriod;
    private float robustStatistic;
    private float thresholdForDesiredPfa;
    private float trialTransitPulseDuration;
    private WeakSecondary weakSecondaryStruct = new WeakSecondary();
    private float[] deemphasizedNormalizationTimeSeries = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * For use only by mock objects and Hibernate.
     */
    public DvThresholdCrossingEvent() {
    }

    protected DvThresholdCrossingEvent(int keplerId, float chiSquare1,
        float chiSquare2, int chiSquareDof1, float chiSquareDof2,
        float chiSquareGof, int chiSquareGofDof, double epochMjd,
        float maxMultipleEventSigma, float maxSesInMes,
        float maxSingleEventSigma, double orbitalPeriod, float robustStatistic,
        float thresholdForDesiredPfa, float trialTransitPulseDuration,
        WeakSecondary weakSecondary) {

        this.keplerId = keplerId;
        this.chiSquare1 = chiSquare1;
        this.chiSquare2 = chiSquare2;
        this.chiSquareDof1 = chiSquareDof1;
        this.chiSquareDof2 = chiSquareDof2;
        this.chiSquareGof = chiSquareGof;
        this.chiSquareGofDof = chiSquareGofDof;
        this.epochMjd = epochMjd;
        this.maxMultipleEventSigma = maxMultipleEventSigma;
        this.maxSesInMes = maxSesInMes;
        this.maxSingleEventSigma = maxSingleEventSigma;
        this.orbitalPeriod = orbitalPeriod;
        this.robustStatistic = robustStatistic;
        this.thresholdForDesiredPfa = thresholdForDesiredPfa;
        this.trialTransitPulseDuration = trialTransitPulseDuration;
        weakSecondaryStruct = weakSecondary;
    }

    protected DvThresholdCrossingEvent(Builder builder) {
        this(builder.keplerId, builder.chiSquare1, builder.chiSquare2,
            builder.chiSquareDof1, builder.chiSquareDof2, builder.chiSquareGof,
            builder.chiSquareGofDof, builder.epochMjd,
            builder.maxMultipleEventSigma, builder.maxSesInMes,
            builder.maxSingleEventSigma, builder.orbitalPeriod,
            builder.robustStatistic, builder.thresholdForDesiredPfa,
            builder.trialTransitPulseDuration, builder.weakSecondary);
    }

    public static DvThresholdCrossingEvent getInstance(TpsDbResult tpsDbResult) {
        checkNotNull(tpsDbResult, "tpsDbResult can't be null");

        return new Builder(tpsDbResult.getKeplerId()).chiSquare1(
            tpsDbResult.getChiSquare1())
            .chiSquare2(tpsDbResult.getChiSquare2())
            .chiSquareDof1(tpsDbResult.getChiSquareDof1())
            .chiSquareDof2(tpsDbResult.getChiSquareDof2())
            .chiSquareGof(tpsDbResult.getChiSquareGof())
            .chiSquareGofDof(tpsDbResult.getChiSquareGofDof())
            .epochMjd(tpsDbResult.timeOfFirstTransitInMjd())
            .maxMultipleEventSigma(tpsDbResult.getMaxMultipleEventStatistic())
            .maxSesInMes(tpsDbResult.getMaxSesInMes())
            .maxSingleEventSigma(tpsDbResult.getMaxSingleEventStatistic())
            .orbitalPeriod(tpsDbResult.getDetectedOrbitalPeriodInDays())
            .robustStatistic(tpsDbResult.getRobustStatistic())
            .thresholdForDesiredPfa(tpsDbResult.getThresholdForDesiredPfa())
            .trialTransitPulseDuration(
                tpsDbResult.getTrialTransitPulseInHours())
            .weakSecondary(new WeakSecondary(tpsDbResult.getWeakSecondary()))
            .build();
    }

    public static DvThresholdCrossingEvent getInstance(ExternalTce externalTce) {

        return new Builder(externalTce.getKeplerId()).epochMjd(
            externalTce.getEpochMjd())
            .maxMultipleEventSigma(externalTce.getMaxMultipleEventSigma())
            .maxSesInMes(externalTce.getMaxSingleEventSigma())
            .maxSingleEventSigma(externalTce.getMaxSingleEventSigma())
            .orbitalPeriod(externalTce.getOrbitalPeriodDays())
            .trialTransitPulseDuration(externalTce.getTransitDurationHours())
            .weakSecondary(new WeakSecondary())
            .build();
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

    public float[] getDeemphasizedNormalizationTimeSeries() {
        return deemphasizedNormalizationTimeSeries;
    }

    public void setDeemphasizedNormalizationTimeSeries(
        float[] deemphasizedNormalizationTimeSeries) {
        this.deemphasizedNormalizationTimeSeries = deemphasizedNormalizationTimeSeries;
    }

    public double getEpochMjd() {
        return epochMjd;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public float getMaxMultipleEventSigma() {
        return maxMultipleEventSigma;
    }

    public float getMaxSesInMes() {
        return maxSesInMes;
    }

    public float getMaxSingleEventSigma() {
        return maxSingleEventSigma;
    }

    public double getOrbitalPeriod() {
        return orbitalPeriod;
    }

    public float getRobustStatistic() {
        return robustStatistic;
    }

    public float getThresholdForDesiredPfa() {
        return thresholdForDesiredPfa;
    }

    public float getTrialTransitPulseDuration() {
        return trialTransitPulseDuration;
    }

    public WeakSecondary getWeakSecondary() {
        return weakSecondaryStruct;
    }

    public static class Builder {
        private float chiSquare1;
        private float chiSquare2;
        private int chiSquareDof1;
        private float chiSquareDof2;
        private float chiSquareGof;
        private int chiSquareGofDof;
        private double epochMjd;
        private int keplerId;
        private float maxMultipleEventSigma;
        private float maxSesInMes;
        private float maxSingleEventSigma;
        private double orbitalPeriod;
        private float robustStatistic;
        private float thresholdForDesiredPfa;
        private float trialTransitPulseDuration;
        private WeakSecondary weakSecondary = new WeakSecondary();

        public Builder(int keplerId) {
            this.keplerId = keplerId;
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

        public Builder epochMjd(double epochMjd) {
            this.epochMjd = epochMjd;
            return this;
        }

        public Builder maxMultipleEventSigma(float maxMultipleEventSigma) {
            this.maxMultipleEventSigma = maxMultipleEventSigma;
            return this;
        }

        public Builder maxSesInMes(float maxSesInMes) {
            this.maxSesInMes = maxSesInMes;
            return this;
        }

        public Builder maxSingleEventSigma(float maxSingleEventSigma) {
            this.maxSingleEventSigma = maxSingleEventSigma;
            return this;
        }

        public Builder orbitalPeriod(double orbitalPeriod) {
            this.orbitalPeriod = orbitalPeriod;
            return this;
        }

        public Builder robustStatistic(float robustStatistic) {
            this.robustStatistic = robustStatistic;
            return this;
        }

        public Builder trialTransitPulseDuration(float trialTransitPulseDuration) {
            this.trialTransitPulseDuration = trialTransitPulseDuration;
            return this;
        }

        public Builder weakSecondary(WeakSecondary weakSecondary) {
            this.weakSecondary = weakSecondary;
            return this;
        }

        public Builder thresholdForDesiredPfa(float thresholdForDesiredPfa) {
            this.thresholdForDesiredPfa = thresholdForDesiredPfa;
            return this;
        }

        public DvThresholdCrossingEvent build() {
            return new DvThresholdCrossingEvent(this);
        }
    }
}
