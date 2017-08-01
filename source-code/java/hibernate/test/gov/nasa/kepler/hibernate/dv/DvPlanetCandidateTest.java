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
import static gov.nasa.kepler.hibernate.dv.DvBootstrapHistogramTest.FINAL_SKIP_COUNT;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.CHI_SQUARE_1;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.CHI_SQUARE_2;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.CHI_SQUARE_DOF_1;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.CHI_SQUARE_DOF_2;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.EPOCH_MJD;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.KEPLER_ID;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.MAX_MULTIPLE_EVENT_SIGMA;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.MAX_SES_IN_MES;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.MAX_SINGLE_EVENT_SIGMA;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.ORBITAL_PERIOD;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.PIPELINE_TASK;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.ROBUST_STATISTIC;
import static gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest.TRIAL_TRANSIT_PULSE_DURATION;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvPlanetCandidate} class.
 * 
 * @author Bill Wohler
 */
public class DvPlanetCandidateTest {

    private static final Log log = LogFactory.getLog(DvPlanetCandidateTest.class);

    private static final long ID = 7;
    private static final int PLANET_NUMBER = 7;
    private static final int EXPECTED_TRANSIT_COUNT = 77;
    private static final int OBSERVED_TRANSIT_COUNT = 777;
    private static final boolean SUSPECTED_ECLIPSING_BINARY = false;
    private static final float SIGNIFICANCE = 7.1F;
    private static final DvBootstrapHistogram BOOTSTRAP_HISTOGRAM = createBootstrapHistogram(1F);
    private static final float BOOTSTRAP_MES_MEAN = 123.456f;
    private static final float BOOTSTRAP_MES_STD = 456.789f;
    private static final float BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA = 9.3F;
    private static final boolean STATISTIC_RATIO_BELOW_THRESHOLD = false;
    private static final float MODEL_CHI_SQUARE_2 = 7.2F;
    private static final int MODEL_CHI_SQUARE_DOF_2 = 8;
    private static final float MODEL_CHI_SQUARE_GOF = 9.1F;
    private static final int MODEL_CHI_SQUARE_GOF_DOF = 10;

    private DvPlanetCandidate planetCandidate;

    private static DvBootstrapHistogram createBootstrapHistogram(float seed) {
        List<Float> statistics = Arrays.asList(seed + .1F, seed + .2F,
            seed + .3F);
        List<Float> probabilities = Arrays.asList(seed + 1.1F, seed + 1.2F,
            seed + 1.3F);

        return new DvBootstrapHistogram(statistics, probabilities,
            FINAL_SKIP_COUNT);
    }

    @Before
    public void createExpectedPlanetCandidate() {
        planetCandidate = createPlanetCandidate(PLANET_NUMBER,
            EXPECTED_TRANSIT_COUNT, OBSERVED_TRANSIT_COUNT,
            SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE, BOOTSTRAP_HISTOGRAM,
            BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
    }

    static DvPlanetCandidate createPlanetCandidate(float seed) {
        return createPlanetCandidate(PLANET_NUMBER + (int) seed,
            EXPECTED_TRANSIT_COUNT + (int) seed, OBSERVED_TRANSIT_COUNT
                + (int) seed, !SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE + seed,
            createBootstrapHistogram(seed), BOOTSTRAP_MES_MEAN,
            BOOTSTRAP_MES_STD, BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA
                + seed, !STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
    }

    /**
     * Creates a {@link DvPlanetCandidate} where all fields are set except for
     * don't-care fields that are not included in the {@code hashCode} and
     * {@code equals} methods ({@code id}).
     */
    private static DvPlanetCandidate createPlanetCandidate(int planetNumber,
        int expectedTransitCount, int observedTransitCount,
        boolean suspectedEclipsingBinary, float significance,
        DvBootstrapHistogram bootstrapHistogram,
        float bootstrapMesMean,
        float bootstrapMesStd,
        float bootstrapThresholdForDesiredPfa,
        boolean statisticRatioBelowThreshold, float modelChiSquare2,
        int modelChiSquareDof2, float modelChiSquareGof,
        int modelChiSquareGofDof) {

        return createPlanetCandidate(ID, planetNumber, expectedTransitCount,
            observedTransitCount, suspectedEclipsingBinary, significance,
            bootstrapHistogram, bootstrapMesMean, bootstrapMesStd,
            bootstrapThresholdForDesiredPfa,
            statisticRatioBelowThreshold, modelChiSquare2, modelChiSquareDof2,
            modelChiSquareGof, modelChiSquareGofDof);
    }

    /**
     * Creates a {@link DvPlanetCandidate} where all fields are set including
     * don't-care fields that are not included in the {@code hashCode} and
     * {@code equals} methods ({@code id}).
     */
    private static DvPlanetCandidate createPlanetCandidate(long id,
        int planetNumber, int expectedTransitCount, int observedTransitCount,
        boolean suspectedEclipsingBinary, float significance,
        DvBootstrapHistogram bootstrapHistogram,
        float bootstrapMesMean, float bootstrapMesStd,
        float bootstrapThresholdForDesiredPfa,
        boolean statisticRatioBelowThreshold, float modelChiSquare2,
        int modelChiSquareDof2, float modelChiSquareGof,
        int modelChiSquareGofDof) {

        return new DvPlanetCandidate.Builder(KEPLER_ID, PIPELINE_TASK).chiSquare1(
            CHI_SQUARE_1)
            .chiSquare2(CHI_SQUARE_2)
            .chiSquareDof1(CHI_SQUARE_DOF_1)
            .chiSquareDof2(CHI_SQUARE_DOF_2)
            .epochMjd(EPOCH_MJD)
            .orbitalPeriod(ORBITAL_PERIOD)
            .robustStatistic(ROBUST_STATISTIC)
            .trialTransitPulseDuration(TRIAL_TRANSIT_PULSE_DURATION)
            .maxMultipleEventSigma(MAX_MULTIPLE_EVENT_SIGMA)
            .maxSesInMes(MAX_SES_IN_MES)
            .maxSingleEventSigma(MAX_SINGLE_EVENT_SIGMA)
            .id(id)
            .bootstrapHistogram(bootstrapHistogram)
            .bootstrapMesMean(bootstrapMesMean)
            .bootstrapMesStd(bootstrapMesStd)
            .bootstrapThresholdForDesiredPfa(bootstrapThresholdForDesiredPfa)
            .expectedTransitCount(expectedTransitCount)
            .modelChiSquare2(modelChiSquare2)
            .modelChiSquareDof2(modelChiSquareDof2)
            .modelChiSquareGof(modelChiSquareGof)
            .modelChiSquareGofDof(modelChiSquareGofDof)
            .observedTransitCount(observedTransitCount)
            .planetNumber(planetNumber)
            .significance(significance)
            .statisticRatioBelowThreshold(statisticRatioBelowThreshold)
            .suspectedEclipsingBinary(suspectedEclipsingBinary)
            .build();
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvPlanetCandidate();

        testPlanetCandidate(planetCandidate);
    }

    static void testPlanetCandidate(DvPlanetCandidate planetCandidate) {

        checkNotNull(planetCandidate, "planetCandidate can't be null");

        DvThresholdCrossingEventTest.testThresholdCrossingEvent(planetCandidate);

        assertEquals(BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            planetCandidate.getBootstrapThresholdForDesiredPfa(), 0);
        assertEquals(BOOTSTRAP_HISTOGRAM,
            planetCandidate.getBootstrapHistogram());
        assertEquals(EXPECTED_TRANSIT_COUNT,
            planetCandidate.getExpectedTransitCount());
        assertEquals(ID, planetCandidate.getId());
        assertEquals(MODEL_CHI_SQUARE_2, planetCandidate.getModelChiSquare2(),
            0);
        assertEquals(MODEL_CHI_SQUARE_DOF_2,
            planetCandidate.getModelChiSquareDof2());
        assertEquals(MODEL_CHI_SQUARE_GOF,
            planetCandidate.getModelChiSquareGof(), 0);
        assertEquals(MODEL_CHI_SQUARE_GOF_DOF,
            planetCandidate.getModelChiSquareGofDof());
        assertEquals(OBSERVED_TRANSIT_COUNT,
            planetCandidate.getObservedTransitCount());
        assertEquals(PLANET_NUMBER, planetCandidate.getPlanetNumber());
        assertEquals(SIGNIFICANCE, planetCandidate.getSignificance(), 0);
        assertEquals(STATISTIC_RATIO_BELOW_THRESHOLD,
            planetCandidate.isStatisticRatioBelowThreshold());
        assertEquals(SUSPECTED_ECLIPSING_BINARY,
            planetCandidate.isSuspectedEclipsingBinary());
    }

    @Test
    public void testHashCodeEquals() {
        // Modify all don't-care fields here.
        DvPlanetCandidate pc = createPlanetCandidate(ID + 1, PLANET_NUMBER,
            EXPECTED_TRANSIT_COUNT, OBSERVED_TRANSIT_COUNT,
            SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE, BOOTSTRAP_HISTOGRAM,
            BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertEquals(planetCandidate, pc);
        assertEquals(planetCandidate.hashCode(), pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER + 1, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT + 1,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT + 1, SUSPECTED_ECLIPSING_BINARY,
            SIGNIFICANCE, BOOTSTRAP_HISTOGRAM,
            BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, !SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY,
            SIGNIFICANCE + 1, BOOTSTRAP_HISTOGRAM,
            BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            createBootstrapHistogram(2F), BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN + 0.001f, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD + 0.001f,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA + 1,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            !STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2 + 1,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2 + 1, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF + 1,
            MODEL_CHI_SQUARE_GOF_DOF);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());

        pc = createPlanetCandidate(PLANET_NUMBER, EXPECTED_TRANSIT_COUNT,
            OBSERVED_TRANSIT_COUNT, SUSPECTED_ECLIPSING_BINARY, SIGNIFICANCE,
            BOOTSTRAP_HISTOGRAM, BOOTSTRAP_MES_MEAN, BOOTSTRAP_MES_STD,
            BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA,
            STATISTIC_RATIO_BELOW_THRESHOLD, MODEL_CHI_SQUARE_2,
            MODEL_CHI_SQUARE_DOF_2, MODEL_CHI_SQUARE_GOF,
            MODEL_CHI_SQUARE_GOF_DOF + 1);
        assertFalse("equals", planetCandidate.equals(pc));
        assertFalse("hashCode", planetCandidate.hashCode() == pc.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(planetCandidate.toString());
    }
}
