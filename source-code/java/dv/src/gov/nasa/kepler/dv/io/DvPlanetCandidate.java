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

import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.spiffy.common.persistable.OracleDouble;

public class DvPlanetCandidate extends DvThresholdCrossingEvent {

    private DvBootstrapHistogram bootstrapHistogram = new DvBootstrapHistogram();
    private float bootstrapThresholdForDesiredPfa;
    private int expectedTransitCount;
    private CorrectedFluxTimeSeries initialFluxTimeSeries = new CorrectedFluxTimeSeries();
    private float modelChiSquare2;
    private int modelChiSquareDof2;
    private float modelChiSquareGof;
    private int modelChiSquareGofDof;
    private int observedTransitCount;
    private int planetNumber;
    @OracleDouble
    private double significance;
    private boolean statisticRatioBelowThreshold;
    private boolean suspectedEclipsingBinary;
    private float bootstrapMesMean;
    private float bootstrapMesStd;

    /**
     * Creates a {@link DvPlanetCandidate}. For use only by mock objects and
     * Hibernate.
     */
    public DvPlanetCandidate() {
    }

    /**
     * Creates a new {@link DvPlanetCandidate} from the given builder.
     */
    private DvPlanetCandidate(Builder builder) {
        super(builder);
        bootstrapHistogram = builder.bootstrapHistogram;
        bootstrapThresholdForDesiredPfa = builder.bootstrapThresholdForDesiredPfa;
        expectedTransitCount = builder.expectedTransitCount;
        initialFluxTimeSeries = builder.initialFluxTimeSeries;
        planetNumber = builder.planetNumber;
        modelChiSquare2 = builder.modelChiSquare2;
        modelChiSquareDof2 = builder.modelChiSquareDof2;
        modelChiSquareGof = builder.modelChiSquareGof;
        modelChiSquareGofDof = builder.modelChiSquareGofDof;
        observedTransitCount = builder.observedTransitCount;
        significance = builder.significance;
        statisticRatioBelowThreshold = builder.statisticRatioBelowThreshold;
        suspectedEclipsingBinary = builder.suspectedEclipsingBinary;
        bootstrapMesMean = builder.bootstrapMesMean;
        bootstrapMesStd = builder.bootstrapMesStd;
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

    public CorrectedFluxTimeSeries getInitialFluxTimeSeries() {
        return initialFluxTimeSeries;
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
    
    public float getBoostrapMesMean() {
        return bootstrapMesMean;
    }
    
    public float getBootstrapMesStd() {
        return bootstrapMesStd;
    }

    /**
     * Used to construct a {@link DvPlanetCandidate} object. To use this class,
     * a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPlanetCandidate} object is created using the
     * build method. For example:
     * 
     * <pre>
     * DvPlanetCandidate planetCandidate = new DvPlanetCandidate.Builder(keplerId).build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    public static class Builder extends DvThresholdCrossingEvent.Builder {

        private DvBootstrapHistogram bootstrapHistogram;
        private float bootstrapThresholdForDesiredPfa;
        private int expectedTransitCount;
        private CorrectedFluxTimeSeries initialFluxTimeSeries;
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

        public Builder(int keplerId) {
            super(keplerId);
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

        public Builder chiSquareGof(int chiSquareGof) {
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
        public Builder trialTransitPulseDuration(float trialTransitPulseDuration) {
            super.trialTransitPulseDuration(trialTransitPulseDuration);
            return this;
        }

        @Override
        public Builder weakSecondary(WeakSecondary weakSecondary) {
            super.weakSecondary(weakSecondary);
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

        public Builder initialFluxTimeSeries(
            CorrectedFluxTimeSeries initialFluxTimeSeries) {
            this.initialFluxTimeSeries = initialFluxTimeSeries;
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
