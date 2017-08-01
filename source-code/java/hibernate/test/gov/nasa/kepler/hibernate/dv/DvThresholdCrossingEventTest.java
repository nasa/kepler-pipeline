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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvThresholdCrossingEvent} class.
 * 
 * @author Bill Wohler
 */
public class DvThresholdCrossingEventTest {

    private static final Log log = LogFactory.getLog(DvThresholdCrossingEventTest.class);

    static final int KEPLER_ID = 42;
    static final double EPOCH_MJD = 6.1;
    static final float ORBITAL_PERIOD = 6.2F;
    static final float TRIAL_TRANSIT_PULSE_DURATION = 6.3F;
    static final float MAX_MULTIPLE_EVENT_SIGMA = 6.4F;
    static final float MAX_SINGLE_EVENT_SIGMA = 6.5F;
    static final long PIPELINE_TASK_ID = 43;
    static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);
    static final float MAX_MES_PHASE_IN_DAYS = 6.6F;
    static final float MAX_MES = 6.7F;
    static final float MIN_MES_PHASE_IN_DAYS = 6.65F;
    static final float MIN_MES = 6.75F;
    static final float MES_MAD = 6.76F;
    static final float DEPTHPPM_VALUE = 6.77F;
    static final float DEPTHPPM_UNCERTAINTY = 6.78F;
    private static final float MEDIAN_MES = 6.79F;
    private static final int VALID_PHASE_COUNT = 6791;
    private static final float WEAK_SECONDARY_ROBUST_STATISTIC = 6.792F;
    static final DvWeakSecondary WEAK_SECONDARY = createWeakSecondary(
        MAX_MES_PHASE_IN_DAYS, MAX_MES, MIN_MES_PHASE_IN_DAYS, MIN_MES,
        MES_MAD, DEPTHPPM_VALUE, DEPTHPPM_UNCERTAINTY, MEDIAN_MES,
        VALID_PHASE_COUNT, WEAK_SECONDARY_ROBUST_STATISTIC);
    static final float CHI_SQUARE_1 = 6.8F;
    static final float CHI_SQUARE_2 = 6.9F;
    static final int CHI_SQUARE_DOF_1 = 7;
    static final int CHI_SQUARE_DOF_2 = 8;
    static final float ROBUST_STATISTIC = 8.1F;
    static final float MAX_SES_IN_MES = 9.0F;

    private DvThresholdCrossingEvent thresholdCrossingEvent;

    @Before
    public void createExpectedThresholdCrossingEvent() {
        thresholdCrossingEvent = createThresholdCrossingEvent(KEPLER_ID,
            EPOCH_MJD, ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
    }

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    private static DvWeakSecondary createWeakSecondary(float maxMesPhaseInDays,
        float maxMes, float minMesPhaseInDays, float minMes, float mesMad,
        float depthPpmValue, float depthPpmUncertainty, float medianMes,
        int validPhaseCount, float robustStatistic) {
        DvWeakSecondary weakSecondary = new DvWeakSecondary(maxMesPhaseInDays,
            maxMes, minMesPhaseInDays, minMes, mesMad, depthPpmValue,
            depthPpmUncertainty, medianMes, validPhaseCount, robustStatistic);

        return weakSecondary;
    }

    static DvThresholdCrossingEvent createThresholdCrossingEvent(int keplerId,
        double epochMjd, float orbitalPeriod, float trialTransitPulseDuration,
        float maxMultipleEventSigma, float maxSingleEventSigma,
        PipelineTask pipelineTask, DvWeakSecondary weakSecondary,
        float chiSquare1, float chiSquare2, int chiSquareDof1,
        float chiSquareDof2, float robustStatistic, float maxSesInMes) {

        return new ThresholdCrossingEvent(keplerId, epochMjd, orbitalPeriod,
            trialTransitPulseDuration, maxMultipleEventSigma,
            maxSingleEventSigma, pipelineTask, weakSecondary, chiSquare1,
            chiSquare2, chiSquareDof1, chiSquareDof2, robustStatistic,
            maxSesInMes);
    }

    @Test
    public void testConstructor() {
        testThresholdCrossingEvent(thresholdCrossingEvent);
    }

    static void testThresholdCrossingEvent(
        DvThresholdCrossingEvent thresholdCrossingEvent) {

        assertEquals(KEPLER_ID, thresholdCrossingEvent.getKeplerId());
        assertEquals(EPOCH_MJD, thresholdCrossingEvent.getEpochMjd(), 0);
        assertEquals(ORBITAL_PERIOD, thresholdCrossingEvent.getOrbitalPeriod(),
            0);
        assertEquals(TRIAL_TRANSIT_PULSE_DURATION,
            thresholdCrossingEvent.getTrialTransitPulseDuration(), 0);
        assertEquals(MAX_MULTIPLE_EVENT_SIGMA,
            thresholdCrossingEvent.getMaxMultipleEventSigma(), 0);
        assertEquals(MAX_SES_IN_MES, thresholdCrossingEvent.getMaxSesInMes(), 0);
        assertEquals(MAX_SINGLE_EVENT_SIGMA,
            thresholdCrossingEvent.getMaxSingleEventSigma(), 0);
        assertEquals(PIPELINE_TASK, thresholdCrossingEvent.getPipelineTask());
    }

    @Test
    public void testHashCodeEquals() {
        // Include all don't-care fields here.
        DvThresholdCrossingEvent tce = createThresholdCrossingEvent(KEPLER_ID,
            EPOCH_MJD, ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertEquals(thresholdCrossingEvent, tce);
        assertEquals(thresholdCrossingEvent.hashCode(), tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID + 1, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD + 1,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD + 1, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION + 1,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA + 1, MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK, WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA + 1,
            PIPELINE_TASK, WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA,
            createPipelineTask(PIPELINE_TASK_ID + 1), WEAK_SECONDARY,
            CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2,
            ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS + 1, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES + 1,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS + 1, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES + 1, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD + 1, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES + 1, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT + 1,
                WEAK_SECONDARY_ROBUST_STATISTIC), CHI_SQUARE_1, CHI_SQUARE_2,
            CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(
            KEPLER_ID,
            EPOCH_MJD,
            ORBITAL_PERIOD,
            TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA,
            MAX_SINGLE_EVENT_SIGMA,
            PIPELINE_TASK,
            createWeakSecondary(MAX_MES_PHASE_IN_DAYS, MAX_MES,
                MIN_MES_PHASE_IN_DAYS, MIN_MES, MES_MAD, DEPTHPPM_VALUE,
                DEPTHPPM_UNCERTAINTY, MEDIAN_MES, VALID_PHASE_COUNT,
                WEAK_SECONDARY_ROBUST_STATISTIC + 1), CHI_SQUARE_1,
            CHI_SQUARE_2, CHI_SQUARE_DOF_1, CHI_SQUARE_DOF_2, ROBUST_STATISTIC,
            MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1 + 1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2 + 1, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1 + 1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2 + 1, ROBUST_STATISTIC, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC + 1, MAX_SES_IN_MES);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());

        tce = createThresholdCrossingEvent(KEPLER_ID, EPOCH_MJD,
            ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            WEAK_SECONDARY, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES + 1);
        assertFalse("equals", thresholdCrossingEvent.equals(tce));
        assertFalse("hashCode",
            thresholdCrossingEvent.hashCode() == tce.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(thresholdCrossingEvent.toString());

        DvThresholdCrossingEvent tce = createThresholdCrossingEvent(KEPLER_ID,
            EPOCH_MJD, ORBITAL_PERIOD, TRIAL_TRANSIT_PULSE_DURATION,
            MAX_MULTIPLE_EVENT_SIGMA, MAX_SINGLE_EVENT_SIGMA, PIPELINE_TASK,
            null, CHI_SQUARE_1, CHI_SQUARE_2, CHI_SQUARE_DOF_1,
            CHI_SQUARE_DOF_2, ROBUST_STATISTIC, MAX_SES_IN_MES);
        log.info(tce.toString());
    }

    private static class ThresholdCrossingEvent extends
        DvThresholdCrossingEvent {

        public ThresholdCrossingEvent(int keplerId, double epochMjd,
            float orbitalPeriod, float trialTransitPulseDuration,
            float maxMultipleEventSigma, float maxSingleEventSigma,
            PipelineTask pipelineTask, DvWeakSecondary weakSecondary,
            float chiSquare1, float chiSquare2, int chiSquareDof1,
            float chiSquareDof2, float robustStatistic, float maxSesInMes) {

            super(new Builder(keplerId, pipelineTask).chiSquare1(chiSquare1)
                .chiSquare2(chiSquare2)
                .chiSquareDof1(chiSquareDof1)
                .chiSquareDof2(chiSquareDof2)
                .epochMjd(epochMjd)
                .orbitalPeriod(orbitalPeriod)
                .maxMultipleEventSigma(maxMultipleEventSigma)
                .maxSesInMes(maxSesInMes)
                .maxSingleEventSigma(maxSingleEventSigma)
                .robustStatistic(robustStatistic)
                .trialTransitPulseDuration(trialTransitPulseDuration)
                .weakSecondary(weakSecondary));
        }

        public static class Builder extends DvThresholdCrossingEvent.Builder {
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
            public Builder trialTransitPulseDuration(
                float trialTransitPulseDuration) {
                super.trialTransitPulseDuration(trialTransitPulseDuration);
                return this;
            }

            @Override
            public Builder weakSecondary(DvWeakSecondary weakSecondary) {
                super.weakSecondary(weakSecondary);
                return this;
            }
        }
    }
}
