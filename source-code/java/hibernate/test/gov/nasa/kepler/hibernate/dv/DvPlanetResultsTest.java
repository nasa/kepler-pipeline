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

import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvPlanetResults} class.
 * 
 * @author Bill Wohler
 */
public class DvPlanetResultsTest {

    private static final Log log = LogFactory.getLog(DvPlanetResultsTest.class);

    private static final long ID = 9;
    private static final int START_CADENCE = 9999;
    private static final int END_CADENCE = 99999;
    private static final int KEPLER_ID = 9;
    private static final int PLANET_NUMBER = 99;
    private static final DvPlanetCandidate PLANET_CANDIDATE = createPlanetCandidate(9.0F);
    private static final DvCentroidResults CENTROID_RESULTS = createCentroidResults(9.1F);
    private static final DvBinaryDiscriminationResults BINARY_DISCRIMINATION_RESULTS = createBinaryDiscriminationResults(9.2F);
    private static final DvPlanetModelFit ALL_TRANSITS_FIT = createPlanetModelFit(9.2F);
    private static final DvPlanetModelFit EVEN_TRANSITS_FIT = createPlanetModelFit(9.3F);
    private static final DvPlanetModelFit ODD_TRANSITS_FIT = createPlanetModelFit(9.4F);
    private static final DvPlanetModelFit TRAPEZOIDAL_FIT = createPlanetModelFit(9.7F);
    private static final DvSecondaryEventResults SECONDARY_EVENT_RESULTS = createSecondaryEventResults(10.0F);
    private static final List<DvPlanetModelFit> SINGLE_TRANSIT_FITS = Arrays.asList(createPlanetModelFit(9.5F));
    private static final DvGhostDiagnosticResults GHOST_DIAGNOSTIC_RESULTS = createGhostDiagnosticResults(9.6F);
    private static final List<DvPixelCorrelationResults> PIXEL_CORRELATION_RESULTS = Arrays.asList(createPixelCorrelationResults());
    private static final List<DvDifferenceImageResults> DIFFERENCE_IMAGE_RESULTS = Arrays.asList(createDifferenceImageResults());
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final String KEPLER_NAME = "Kepler-1 b";
    private static final String KOI_ID = "K00001.01";
    private static final float KOI_CORRELATION = 1;
    private static final long PIPELINE_TASK_ID = 999;
    private static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);

    private DvPlanetResults planetResults;

    private static DvPlanetCandidate createPlanetCandidate(float seed) {
        return DvPlanetCandidateTest.createPlanetCandidate(seed);
    }

    private static DvCentroidResults createCentroidResults(float seed) {
        return DvCentroidResultsTest.createCentroidResults(seed);
    }

    private static DvBinaryDiscriminationResults createBinaryDiscriminationResults(
        float seed) {

        return new DvBinaryDiscriminationResults(new DvPlanetStatistic(
            (int) seed, seed + 0.04F, seed + 0.05F), new DvPlanetStatistic(
            (int) seed, seed + 0.06F, seed + 0.07F), new DvStatistic(
            seed + 0.08F, seed + 0.09F), new DvStatistic(seed + 0.091F,
            seed + 0.092F), new DvStatistic(seed + 0.093F, seed + 0.094F),
            new DvStatistic(seed + 0.095F, seed + 0.096F), new DvStatistic(
                seed + 0.097F, seed + 0.098F));
    }

    private static DvPlanetModelFit createPlanetModelFit(float seed) {
        return DvPlanetModelFitTest.createPlanetModelFit(seed);
    }

    private static DvSecondaryEventResults createSecondaryEventResults(
        float seed) {

        return new DvSecondaryEventResults(new DvPlanetParameters(
            new DvQuantity(seed * 2, seed / 2.0F), new DvQuantity(seed * 2,
                seed / 2.0F)), new DvComparisonTests(new DvStatistic(seed * 4,
            seed / 4.0F), new DvStatistic(seed * 5, seed / 5.0F)));
    }

    private static DvGhostDiagnosticResults createGhostDiagnosticResults(
        float seed) {
        return new DvGhostDiagnosticResults(new DvStatistic(seed * 2,
            seed / 2.0F), new DvStatistic(seed * 3, seed / 3.0F));
    }

    private static DvPixelCorrelationResults createPixelCorrelationResults() {
        return DvPixelCorrelationResultsTest.createPixelCorrelationResults();
    }

    private static DvDifferenceImageResults createDifferenceImageResults() {
        return DvDifferenceImageResultsTest.createDifferenceImageResults(Arrays.asList(new DvDifferenceImagePixelData()));
    }

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    @Before
    public void createExpectedPlanetResults() {
        planetResults = createPlanetResults(KEPLER_ID, PLANET_NUMBER,
            PLANET_CANDIDATE, CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS,
            ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
    }

    private static DvPlanetResults createPlanetResults(int keplerId,
        int planetNumber, DvPlanetCandidate planetCandidate,
        DvCentroidResults centroidResults,
        DvBinaryDiscriminationResults binaryDiscriminationResults,
        DvPlanetModelFit allTransitsFit, DvPlanetModelFit evenTransitsFit,
        DvPlanetModelFit oddTransitsFit, DvPlanetModelFit trapezoidalFit,
        DvSecondaryEventResults secondaryEventResults,
        List<DvPlanetModelFit> singleTransitFits,
        List<DvDifferenceImageResults> differenceImageResults,
        DvGhostDiagnosticResults ghostDiagnosticResults,
        List<DvPixelCorrelationResults> pixelCorrelationResults,
        FluxType fluxType, PipelineTask pipelineTask) {

        return createPlanetResults(ID, START_CADENCE, END_CADENCE, keplerId,
            planetNumber, planetCandidate, centroidResults,
            binaryDiscriminationResults, allTransitsFit, evenTransitsFit,
            oddTransitsFit, trapezoidalFit, secondaryEventResults,
            singleTransitFits, differenceImageResults, ghostDiagnosticResults,
            pixelCorrelationResults, fluxType, pipelineTask);
    }

    private static DvPlanetResults createPlanetResults(long id,
        int startCadence, int endCadence, int keplerId, int planetNumber,
        DvPlanetCandidate planetCandidate, DvCentroidResults centroidResults,
        DvBinaryDiscriminationResults binaryDiscriminationResults,
        DvPlanetModelFit allTransitsFit, DvPlanetModelFit evenTransitsFit,
        DvPlanetModelFit oddTransitsFit, DvPlanetModelFit trapezoidalFit,
        DvSecondaryEventResults secondaryEventResults,
        List<DvPlanetModelFit> singleTransitFits,
        List<DvDifferenceImageResults> differenceImageResults,
        DvGhostDiagnosticResults ghostDiagnosticResults,
        List<DvPixelCorrelationResults> pixelCorrelationResults,
        FluxType fluxType, PipelineTask pipelineTask) {

        return createPlanetResults(id, startCadence, endCadence, keplerId,
            planetNumber, planetCandidate, centroidResults,
            binaryDiscriminationResults, allTransitsFit, evenTransitsFit,
            oddTransitsFit, trapezoidalFit, secondaryEventResults,
            singleTransitFits, differenceImageResults, ghostDiagnosticResults,
            pixelCorrelationResults, fluxType, pipelineTask, KEPLER_NAME,
            KOI_ID, KOI_CORRELATION);
    }

    private static DvPlanetResults createPlanetResults(long id,
        int startCadence, int endCadence, int keplerId, int planetNumber,
        DvPlanetCandidate planetCandidate, DvCentroidResults centroidResults,
        DvBinaryDiscriminationResults binaryDiscriminationResults,
        DvPlanetModelFit allTransitsFit, DvPlanetModelFit evenTransitsFit,
        DvPlanetModelFit oddTransitsFit, DvPlanetModelFit trapezoidalFit,
        DvSecondaryEventResults secondaryEventResults,
        List<DvPlanetModelFit> singleTransitFits,
        List<DvDifferenceImageResults> differenceImageResults,
        DvGhostDiagnosticResults ghostDiagnosticResults,
        List<DvPixelCorrelationResults> pixelCorrelationResults,
        FluxType fluxType, PipelineTask pipelineTask, String keplerName,
        String koiId, float koiCorrelation) {

        return new DvPlanetResults.Builder(startCadence, endCadence, keplerId,
            planetNumber, pipelineTask).id(id)
            .planetCandidate(planetCandidate)
            .centroidResults(centroidResults)
            .binaryDiscriminationResults(binaryDiscriminationResults)
            .allTransitsFit(allTransitsFit)
            .evenTransitsFit(evenTransitsFit)
            .oddTransitsFit(oddTransitsFit)
            .trapezoidalFit(trapezoidalFit)
            .secondaryEventResults(secondaryEventResults)
            .singleTransitFits(singleTransitFits)
            .differenceImageResults(differenceImageResults)
            .ghostDiagnosticResults(ghostDiagnosticResults)
            .pixelCorrelationResults(pixelCorrelationResults)
            .fluxType(fluxType)
            .keplerName(keplerName)
            .koiCorrelation(koiCorrelation)
            .koiId(koiId)
            .build();
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvPlanetResultsTest();

        testPlanetResults(planetResults);
    }

    private void testPlanetResults(DvPlanetResults planetResults) {
        assertEquals(KEPLER_ID, planetResults.getKeplerId());
        assertEquals(PLANET_NUMBER, planetResults.getPlanetNumber());
        assertEquals(PLANET_CANDIDATE, planetResults.getPlanetCandidate());
        assertEquals(CENTROID_RESULTS, planetResults.getCentroidResults());
        assertEquals(BINARY_DISCRIMINATION_RESULTS,
            planetResults.getBinaryDiscriminationResults());
        assertEquals(ALL_TRANSITS_FIT, planetResults.getAllTransitsFit());
        assertEquals(EVEN_TRANSITS_FIT, planetResults.getEvenTransitsFit());
        assertEquals(ODD_TRANSITS_FIT, planetResults.getOddTransitsFit());
        assertEquals(TRAPEZOIDAL_FIT, planetResults.getTrapezoidalFit());
        assertEquals(SECONDARY_EVENT_RESULTS,
            planetResults.getSecondaryEventResults());
        assertEquals(SINGLE_TRANSIT_FITS, planetResults.getSingleTransitFits());
        assertEquals(DIFFERENCE_IMAGE_RESULTS,
            planetResults.getDifferenceImageResults());
        assertEquals(GHOST_DIAGNOSTIC_RESULTS,
            planetResults.getGhostDiagnosticResults());
        assertEquals(PIXEL_CORRELATION_RESULTS,
            planetResults.getPixelCorrelationResults());
        assertEquals(FLUX_TYPE, planetResults.getFluxType());
        assertEquals(PIPELINE_TASK, planetResults.getPipelineTask());
        assertEquals(KEPLER_NAME, planetResults.getKeplerName());
        assertEquals(KOI_ID, planetResults.getKoiId());
        assertEquals(KOI_CORRELATION, planetResults.getKoiCorrelation(),
            0.000001);
    }

    @Test
    public void testHashCodeEquals() {
        // Include all don't-care fields here.
        DvPlanetResults pr = createPlanetResults(ID + 1, START_CADENCE,
            END_CADENCE, KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertEquals(planetResults.hashCode(), pr.hashCode());
        assertEquals(planetResults, pr);

        pr = createPlanetResults(KEPLER_ID + 1, PLANET_NUMBER,
            PLANET_CANDIDATE, CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS,
            ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER + 1,
            PLANET_CANDIDATE, CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS,
            ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER,
            createPlanetCandidate(42.0F), CENTROID_RESULTS,
            BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT,
            ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS,
            SINGLE_TRANSIT_FITS, DIFFERENCE_IMAGE_RESULTS,
            GHOST_DIAGNOSTIC_RESULTS, PIXEL_CORRELATION_RESULTS, FLUX_TYPE,
            PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            createCentroidResults(42.0F), BINARY_DISCRIMINATION_RESULTS,
            ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, createBinaryDiscriminationResults(42.0F),
            ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS,
            createPlanetModelFit(42.0F), EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT,
            TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            createPlanetModelFit(42.0F), ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, createPlanetModelFit(42.0F), TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, createPlanetModelFit(42.0F),
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS,
            Arrays.asList(createPlanetModelFit(42.0F)),
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE,
            createPipelineTask(PIPELINE_TASK_ID + 1));
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, createGhostDiagnosticResults(42.0F),
            PIXEL_CORRELATION_RESULTS, FLUX_TYPE, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(KEPLER_ID, PLANET_NUMBER, PLANET_CANDIDATE,
            CENTROID_RESULTS, BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT,
            EVEN_TRANSITS_FIT, ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT,
            SECONDARY_EVENT_RESULTS, SINGLE_TRANSIT_FITS,
            DIFFERENCE_IMAGE_RESULTS, GHOST_DIAGNOSTIC_RESULTS,
            PIXEL_CORRELATION_RESULTS, FluxType.DIA, PIPELINE_TASK);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(ID, START_CADENCE, END_CADENCE, KEPLER_ID,
            PLANET_NUMBER, PLANET_CANDIDATE, CENTROID_RESULTS,
            BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT,
            ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS,
            SINGLE_TRANSIT_FITS, DIFFERENCE_IMAGE_RESULTS,
            GHOST_DIAGNOSTIC_RESULTS, PIXEL_CORRELATION_RESULTS, FLUX_TYPE,
            PIPELINE_TASK, "Kepler-2 b", KOI_ID, KOI_CORRELATION);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(ID, START_CADENCE, END_CADENCE, KEPLER_ID,
            PLANET_NUMBER, PLANET_CANDIDATE, CENTROID_RESULTS,
            BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT,
            ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS,
            SINGLE_TRANSIT_FITS, DIFFERENCE_IMAGE_RESULTS,
            GHOST_DIAGNOSTIC_RESULTS, PIXEL_CORRELATION_RESULTS, FLUX_TYPE,
            PIPELINE_TASK, KEPLER_NAME, "K00002.01", KOI_CORRELATION);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));

        pr = createPlanetResults(ID, START_CADENCE, END_CADENCE, KEPLER_ID,
            PLANET_NUMBER, PLANET_CANDIDATE, CENTROID_RESULTS,
            BINARY_DISCRIMINATION_RESULTS, ALL_TRANSITS_FIT, EVEN_TRANSITS_FIT,
            ODD_TRANSITS_FIT, TRAPEZOIDAL_FIT, SECONDARY_EVENT_RESULTS,
            SINGLE_TRANSIT_FITS, DIFFERENCE_IMAGE_RESULTS,
            GHOST_DIAGNOSTIC_RESULTS, PIXEL_CORRELATION_RESULTS, FLUX_TYPE,
            PIPELINE_TASK, KEPLER_NAME, KOI_ID, 0);
        assertFalse("hashCode", planetResults.hashCode() == pr.hashCode());
        assertFalse("equals", planetResults.equals(pr));
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(planetResults.toString());
    }
}
