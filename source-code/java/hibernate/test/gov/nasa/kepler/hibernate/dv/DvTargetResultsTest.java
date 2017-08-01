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
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

public class DvTargetResultsTest {

    private static final Log log = LogFactory.getLog(DvTargetResultsTest.class);

    private static final int START_CADENCE = 9999;
    private static final int END_CADENCE = 99999;
    private static final int KEPLER_ID = 9;
    private static final long PIPELINE_TASK_ID = 999L;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final int PLANET_CANDIDATE_COUNT = 2;
    private static final String QUARTERS_OBSERVED = "O";
    private static final String PROVENANCE = "provenance";
    private static final DvQuantityWithProvenance RADIUS = createDvQuantityWithProvenance(
        1.0F, PROVENANCE);
    private static final DvQuantityWithProvenance EFFECTIVE_TEMP = createDvQuantityWithProvenance(
        2.0F, PROVENANCE);
    private static final DvQuantityWithProvenance LOG10_SURFACE_GRAVITY = createDvQuantityWithProvenance(
        3.0F, PROVENANCE);
    private static final DvQuantityWithProvenance LOG10_METALLICITY = createDvQuantityWithProvenance(
        4.0F, PROVENANCE);
    private static final DvDoubleQuantityWithProvenance DEC_DEGREES = createDvDoubleQuantityWithProvenance(
        5.0F, PROVENANCE);
    private static final DvQuantityWithProvenance KEPLER_MAG = createDvQuantityWithProvenance(
        6.0F, PROVENANCE);
    private static final DvDoubleQuantityWithProvenance RA_HOURS = createDvDoubleQuantityWithProvenance(
        7.0F, PROVENANCE);
    private static final String KOI_ID = "K00001.01";
    private static final String KEPLER_NAME = "Kepler-1 b";
    private static final List<String> MATCHED_KOI_IDS = new ArrayList<String>();
    private static final List<String> UNMATCHED_KOI_IDS = Arrays.asList(KOI_ID);
    private static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);

    private DvTargetResults targetResults;

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    @Before
    public void createExpectedTargetResults() {
        targetResults = createTargetResults(START_CADENCE, END_CADENCE,
            KEPLER_ID, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
    }

    private static DvTargetResults createTargetResults(int startCadence,
        int endCadence, int keplerId, PipelineTask pipelineTask,
        FluxType fluxType, int planetCandidateCount, String quartersObserved) {
        return createTargetResults(startCadence, endCadence, keplerId,
            pipelineTask, fluxType, planetCandidateCount, quartersObserved,
            RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY, LOG10_METALLICITY,
            DEC_DEGREES, KEPLER_MAG, RA_HOURS);
    }

    private static DvTargetResults createTargetResults(int startCadence,
        int endCadence, int keplerId, PipelineTask pipelineTask,
        FluxType fluxType, int planetCandidateCount, String quartersObserved,
        DvQuantityWithProvenance radius,
        DvQuantityWithProvenance effectiveTemp,
        DvQuantityWithProvenance log10SurfaceGravity,
        DvQuantityWithProvenance log10Metallicity,
        DvDoubleQuantityWithProvenance decDegrees,
        DvQuantityWithProvenance keplerMag,
        DvDoubleQuantityWithProvenance raHours) {
        return createTargetResults(startCadence, endCadence, keplerId,
            pipelineTask, fluxType, planetCandidateCount, quartersObserved,
            radius, effectiveTemp, log10SurfaceGravity, log10Metallicity,
            decDegrees, keplerMag, raHours, KOI_ID, KEPLER_NAME,
            MATCHED_KOI_IDS, UNMATCHED_KOI_IDS);
    }

    private static DvTargetResults createTargetResults(int startCadence,
        int endCadence, int keplerId, PipelineTask pipelineTask,
        FluxType fluxType, int planetCandidateCount, String quartersObserved,
        DvQuantityWithProvenance radius,
        DvQuantityWithProvenance effectiveTemp,
        DvQuantityWithProvenance log10SurfaceGravity,
        DvQuantityWithProvenance log10Metallicity,
        DvDoubleQuantityWithProvenance decDegrees,
        DvQuantityWithProvenance keplerMag,
        DvDoubleQuantityWithProvenance raHours, String koiId,
        String keplerName, List<String> matchedKoiIds,
        List<String> unmatchedKoiIds) {
        return new DvTargetResults.Builder(fluxType, startCadence, endCadence,
            keplerId, pipelineTask).planetCandidateCount(planetCandidateCount)
            .quartersObserved(quartersObserved)
            .radius(radius)
            .effectiveTemp(effectiveTemp)
            .log10SurfaceGravity(log10SurfaceGravity)
            .log10Metallicity(log10Metallicity)
            .decDegrees(decDegrees)
            .keplerMag(keplerMag)
            .raHours(raHours)
            .koiId(koiId)
            .keplerName(keplerName)
            .matchedKoiIds(matchedKoiIds)
            .unmatchedKoiIds(unmatchedKoiIds)
            .build();
    }

    private static DvQuantityWithProvenance createDvQuantityWithProvenance(
        float seed, String origin) {
        return new DvQuantityWithProvenance(seed, seed / 100, origin);
    }

    private static DvDoubleQuantityWithProvenance createDvDoubleQuantityWithProvenance(
        float seed, String origin) {
        return new DvDoubleQuantityWithProvenance(seed, seed / 100, origin);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvTargetResults();

        testTargetResults(targetResults);
    }

    private void testTargetResults(DvTargetResults targetResults) {

        assertEquals(KEPLER_ID, targetResults.getKeplerId());
        assertEquals(FLUX_TYPE, targetResults.getFluxType());
        assertEquals(START_CADENCE, targetResults.getStartCadence());
        assertEquals(END_CADENCE, targetResults.getEndCadence());
        assertEquals(PLANET_CANDIDATE_COUNT,
            targetResults.getPlanetCandidateCount());
        assertEquals(QUARTERS_OBSERVED, targetResults.getQuartersObserved());
        assertEquals(PIPELINE_TASK, targetResults.getPipelineTask());
        assertEquals(RADIUS, targetResults.getRadius());
        assertEquals(EFFECTIVE_TEMP, targetResults.getEffectiveTemp());
        assertEquals(LOG10_SURFACE_GRAVITY,
            targetResults.getLog10SurfaceGravity());
        assertEquals(LOG10_METALLICITY, targetResults.getLog10Metallicity());
        assertEquals(KOI_ID, targetResults.getKoiId());
        assertEquals(KEPLER_NAME, targetResults.getKeplerName());
        assertEquals(MATCHED_KOI_IDS, targetResults.getMatchedKoiIds());
        assertEquals(UNMATCHED_KOI_IDS, targetResults.getUnmatchedKoiIds());
    }

    @Test
    public void testEquals() {
        DvTargetResults results = createTargetResults(START_CADENCE,
            END_CADENCE, KEPLER_ID, PIPELINE_TASK, FLUX_TYPE,
            PLANET_CANDIDATE_COUNT, QUARTERS_OBSERVED);
        assertEquals(targetResults, results);

        results = createTargetResults(START_CADENCE + 1, END_CADENCE,
            KEPLER_ID, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE + 1,
            KEPLER_ID, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE,
            KEPLER_ID + 1, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            createPipelineTask(PIPELINE_TASK_ID + 1), FLUX_TYPE,
            PLANET_CANDIDATE_COUNT, QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FluxType.OAP, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT + 1,
            QUARTERS_OBSERVED);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT, "-O");
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, createDvQuantityWithProvenance(10F, PROVENANCE),
            EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY, LOG10_METALLICITY,
            DEC_DEGREES, KEPLER_MAG, RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS,
            createDvQuantityWithProvenance(10F, PROVENANCE),
            LOG10_SURFACE_GRAVITY, LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG,
            RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP,
            createDvQuantityWithProvenance(10F, PROVENANCE), LOG10_METALLICITY,
            DEC_DEGREES, KEPLER_MAG, RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            createDvQuantityWithProvenance(10F, PROVENANCE), DEC_DEGREES,
            KEPLER_MAG, RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY,
            createDvDoubleQuantityWithProvenance(10F, PROVENANCE), KEPLER_MAG,
            RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES,
            createDvQuantityWithProvenance(10F, PROVENANCE), RA_HOURS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG,
            createDvDoubleQuantityWithProvenance(10F, PROVENANCE));
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, "K00002.01",
            KEPLER_NAME, MATCHED_KOI_IDS, UNMATCHED_KOI_IDS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            "Kepler2 b", MATCHED_KOI_IDS, UNMATCHED_KOI_IDS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            KEPLER_NAME, Arrays.asList(KOI_ID), UNMATCHED_KOI_IDS);
        assertFalse("equals", targetResults.equals(results));

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            KEPLER_NAME, MATCHED_KOI_IDS, new ArrayList<String>());
        assertFalse("equals", targetResults.equals(results));
    }

    @Test
    public void testHashCode() {
        DvTargetResults results = createTargetResults(START_CADENCE,
            END_CADENCE, KEPLER_ID, PIPELINE_TASK, FLUX_TYPE,
            PLANET_CANDIDATE_COUNT, QUARTERS_OBSERVED);
        assertEquals(targetResults.hashCode(), results.hashCode());

        results = createTargetResults(START_CADENCE + 1, END_CADENCE,
            KEPLER_ID, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE + 1,
            KEPLER_ID, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE,
            KEPLER_ID + 1, PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            createPipelineTask(PIPELINE_TASK_ID + 1), FLUX_TYPE,
            PLANET_CANDIDATE_COUNT, QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FluxType.OAP, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT + 1,
            QUARTERS_OBSERVED);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT, "-O");
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, createDvQuantityWithProvenance(10F, PROVENANCE),
            EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY, LOG10_METALLICITY,
            DEC_DEGREES, KEPLER_MAG, RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS,
            createDvQuantityWithProvenance(10F, PROVENANCE),
            LOG10_SURFACE_GRAVITY, LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG,
            RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP,
            createDvQuantityWithProvenance(10F, PROVENANCE), LOG10_METALLICITY,
            DEC_DEGREES, KEPLER_MAG, RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            createDvQuantityWithProvenance(10F, PROVENANCE), DEC_DEGREES,
            KEPLER_MAG, RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY,
            createDvDoubleQuantityWithProvenance(10F, PROVENANCE), KEPLER_MAG,
            RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES,
            createDvQuantityWithProvenance(10F, PROVENANCE), RA_HOURS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG,
            createDvDoubleQuantityWithProvenance(10F, PROVENANCE));
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, "K00002.01",
            KEPLER_NAME, MATCHED_KOI_IDS, UNMATCHED_KOI_IDS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            "Kepler2 b", MATCHED_KOI_IDS, UNMATCHED_KOI_IDS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            KEPLER_NAME, Arrays.asList(KOI_ID), UNMATCHED_KOI_IDS);
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());

        results = createTargetResults(START_CADENCE, END_CADENCE, KEPLER_ID,
            PIPELINE_TASK, FLUX_TYPE, PLANET_CANDIDATE_COUNT,
            QUARTERS_OBSERVED, RADIUS, EFFECTIVE_TEMP, LOG10_SURFACE_GRAVITY,
            LOG10_METALLICITY, DEC_DEGREES, KEPLER_MAG, RA_HOURS, KOI_ID,
            KEPLER_NAME, MATCHED_KOI_IDS, new ArrayList<String>());
        assertFalse("hashCode", targetResults.hashCode() == results.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(targetResults.toString());
    }

}
