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

package gov.nasa.kepler.hibernate.pdc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

public class PdcProcessingCharacteristicsTest {

    private static final Log log = LogFactory.getLog(PdcProcessingCharacteristicsTest.class);

    static final long ID = 8;
    private static final int KEPLER_ID = 8;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;
    private static final int START_CADENCE = 42;
    private static final int END_CADENCE = START_CADENCE + 50;
    private static final String REGULAR_METHOD = "regularMap";
    private static final String MULTISCALE_METHOD = "multiscaleMap";
    private static final int NUM_DISCONTINUITIES_DETECTED = 3;
    private static final int NUM_DISCONTINUITIES_REMOVED = 2;
    private static final boolean HARMONICS_FITTED = true;
    private static final boolean HARMONICS_RESTORED = false;
    private static final float TARGET_VARIABILITY = 4.0F;
    private static final String PRIOR_FIT_TYPE = "prior";
    private static final String ROBUST_FIT_TYPE = "robust";
    private static final float PRIOR_WEIGHT = 5.0F;
    private static final float PRIOR_GOODNESS = 6.0F;
    private static final PdcBand PDC_BAND = createPdcBand();
    private static final List<PdcBand> BANDS = Arrays.asList(PDC_BAND);

    static final long PIPELINE_TASK_ID = 44;
    static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);

    private PdcProcessingCharacteristics pdcProcessingCharacteristics;

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    private static PdcBand createPdcBand() {
        return new PdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
    }

    @Before
    public void createExpectedPdcProcessingCharacteristics() {
        pdcProcessingCharacteristics = new PdcProcessingCharacteristics.Builder(
            PIPELINE_TASK_ID, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID).startCadence(
            START_CADENCE)
            .endCadence(END_CADENCE)
            .pdcMethod(REGULAR_METHOD)
            .numDiscontinuitiesDetected(NUM_DISCONTINUITIES_DETECTED)
            .numDiscontinuitiesRemoved(NUM_DISCONTINUITIES_REMOVED)
            .harmonicsFitted(HARMONICS_FITTED)
            .harmonicsRestored(HARMONICS_RESTORED)
            .targetVariability(TARGET_VARIABILITY)
            .bands(BANDS)
            .build();
    }

    private static PdcProcessingCharacteristics createPdcProcessingCharacteristics(
        PipelineTask pipelineTask, FluxType fluxType, CadenceType cadenceType,
        int keplerId, int startCadence, int endCadence, String pdcMethod,
        int numDiscontinuitiesDetected, int numDiscontinuitiesRemoved,
        boolean harmonicsFitted, boolean harmonicsRestored,
        float targetVariability, List<PdcBand> bands) {

        return new PdcProcessingCharacteristics.Builder(pipelineTask.getId(),
            fluxType, cadenceType, keplerId).startCadence(startCadence)
            .endCadence(endCadence)
            .pdcMethod(pdcMethod)
            .numDiscontinuitiesDetected(numDiscontinuitiesDetected)
            .numDiscontinuitiesRemoved(numDiscontinuitiesRemoved)
            .harmonicsFitted(harmonicsFitted)
            .harmonicsRestored(harmonicsRestored)
            .targetVariability(targetVariability)
            .bands(bands)
            .build();
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new PdcProcessingCharacteristics();

        testPdcProcessingCharacteristics(pdcProcessingCharacteristics);
    }

    static void testPdcProcessingCharacteristics(
        PdcProcessingCharacteristics ppc) {

        assertEquals(PIPELINE_TASK_ID, ppc.getPipelineTaskId());
        assertEquals(FLUX_TYPE, ppc.getFluxType());
        assertEquals(CADENCE_TYPE, ppc.getCadenceType());
        assertEquals(KEPLER_ID, ppc.getKeplerId());
        assertEquals(START_CADENCE, ppc.getStartCadence());
        assertEquals(END_CADENCE, ppc.getEndCadence());
        assertEquals(REGULAR_METHOD, ppc.getPdcMethod());
        assertEquals(NUM_DISCONTINUITIES_DETECTED,
            ppc.getNumDiscontinuitiesDetected());
        assertEquals(HARMONICS_FITTED, ppc.isHarmonicsFitted());
        assertEquals(HARMONICS_RESTORED, ppc.isHarmonicsRestored());
        assertEquals(TARGET_VARIABILITY, ppc.getTargetVariability(),
            0.000000001);
        assertEquals(BANDS, ppc.getBands());
    }

    @Test
    public void testEquals() {
        PdcProcessingCharacteristics ppc = createPdcProcessingCharacteristics(
            PIPELINE_TASK, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE,
            END_CADENCE, REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertEquals(pdcProcessingCharacteristics, ppc);

        ppc = createPdcProcessingCharacteristics(
            createPipelineTask(PIPELINE_TASK_ID + 1), FLUX_TYPE, CADENCE_TYPE,
            KEPLER_ID, START_CADENCE, END_CADENCE, REGULAR_METHOD,
            NUM_DISCONTINUITIES_DETECTED, NUM_DISCONTINUITIES_REMOVED,
            HARMONICS_FITTED, HARMONICS_RESTORED, TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FluxType.DIA,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CadenceType.SHORT, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID + 1, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE + 1, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE + 1,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            MULTISCALE_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED + 1,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, false, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, true,
            TARGET_VARIABILITY, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY + 1.0F, BANDS);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));

        PdcBand pdcBand = new PdcBand(ROBUST_FIT_TYPE, PRIOR_WEIGHT,
            PRIOR_GOODNESS);
        List<PdcBand> bands = Arrays.asList(pdcBand);

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, bands);
        assertFalse("equals", pdcProcessingCharacteristics.equals(ppc));
    }

    @Test
    public void testHashCode() {
        PdcProcessingCharacteristics ppc = createPdcProcessingCharacteristics(
            PIPELINE_TASK, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE,
            END_CADENCE, REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertEquals(pdcProcessingCharacteristics.hashCode(), ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(
            createPipelineTask(PIPELINE_TASK_ID + 1), FLUX_TYPE, CADENCE_TYPE,
            KEPLER_ID, START_CADENCE, END_CADENCE, REGULAR_METHOD,
            NUM_DISCONTINUITIES_DETECTED, NUM_DISCONTINUITIES_REMOVED,
            HARMONICS_FITTED, HARMONICS_RESTORED, TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FluxType.DIA,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CadenceType.SHORT, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID + 1, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE + 1, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE + 1,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            MULTISCALE_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED + 1,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, false, HARMONICS_RESTORED,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, true,
            TARGET_VARIABILITY, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY + 1.0F, BANDS);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());

        PdcBand pdcBand = new PdcBand(ROBUST_FIT_TYPE, PRIOR_WEIGHT,
            PRIOR_GOODNESS);
        List<PdcBand> bands = Arrays.asList(pdcBand);

        ppc = createPdcProcessingCharacteristics(PIPELINE_TASK, FLUX_TYPE,
            CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE,
            REGULAR_METHOD, NUM_DISCONTINUITIES_DETECTED,
            NUM_DISCONTINUITIES_REMOVED, HARMONICS_FITTED, HARMONICS_RESTORED,
            TARGET_VARIABILITY, bands);
        assertFalse("hashCode",
            pdcProcessingCharacteristics.hashCode() == ppc.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(pdcProcessingCharacteristics.toString());
    }
}
