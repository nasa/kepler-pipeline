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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvCentroidResults} class.
 * 
 * @author Bill Wohler
 */
public class DvCentroidResultsTest {

    private static final Log log = LogFactory.getLog(DvCentroidResultsTest.class);

    private static final DvCentroidMotionResults FLUX_WEIGHTED_MOTION_RESULTS = createCentroidMotionResults(10.1F);
    private static final DvCentroidMotionResults PRF_MOTION_RESULTS = createCentroidMotionResults(10.2F);
    private static final DvDifferenceImageMotionResults DIFFERENCE_IMAGE_MOTION_RESULTS = createDifferenceImageMotionResults(10.3F);
    private static final DvPixelCorrelationMotionResults PIXEL_CORRELATION_MOTION_RESULTS = createPixelCorrelationMotionResults(10.4F);

    private DvCentroidResults centroidResults;

    private static DvCentroidMotionResults createCentroidMotionResults(
        float seed) {

        return new DvCentroidMotionResults(new DvDoubleQuantity(seed + 0.02,
            seed + 0.03F), new DvDoubleQuantity(seed + 0.04, seed + 0.05F),
            new DvDoubleQuantity(seed + 0.051, seed + 0.052F),
            new DvDoubleQuantity(seed + 0.053, seed + 0.054F), new DvQuantity(
                seed + 0.06F, seed + 0.07F), new DvQuantity(seed + 0.08F,
                seed + 0.09F), new DvQuantity(seed + 0.10F, seed + 0.11F),
            new DvQuantity(seed + 0.001F, seed + 0.002F), new DvQuantity(
                seed + 0.003F, seed + 0.004F), new DvQuantity(seed + 0.12F,
                seed + 0.13F), new DvStatistic(seed, seed + 0.01F));
    }

    @Before
    public void createExpectedCentroidResults() {
        centroidResults = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            PRF_MOTION_RESULTS, DIFFERENCE_IMAGE_MOTION_RESULTS,
            PIXEL_CORRELATION_MOTION_RESULTS);
    }

    private static DvMqCentroidOffsets createMqCentroidOffsets(float seed) {

        return new DvMqCentroidOffsets(new DvQuantity(seed + 0.01F,
            seed + 0.02F), new DvQuantity(seed + 0.03F, seed + 0.04F),
            new DvQuantity(seed + 0.05F, seed + 0.06F), new DvQuantity(
                seed + 0.07F, seed + 0.08F), new DvQuantity(seed + 0.09F,
                seed + 0.10F), new DvQuantity(seed + 0.11F, seed + 0.12F));
    }

    private static DvMqImageCentroid createMqImageCentroid(float seed) {

        return new DvMqImageCentroid(new DvDoubleQuantity(seed + 0.01,
            seed + 0.02F), new DvDoubleQuantity(seed + 0.03, seed + 0.04F));
    }

    private static DvSummaryQualityMetric createSummaryQualityMetric(float seed) {

        return new DvSummaryQualityMetric(seed, 3, 2, 3, seed);
    }

    private static DvSummaryOverlapMetric createSummaryOverlapMetric(float f) {

        return new DvSummaryOverlapMetric(10, 9, (float) 0.9);
    }

    static DvDifferenceImageMotionResults createDifferenceImageMotionResults(
        float seed) {

        DvMqCentroidOffsets mqControlCentroidOffsets = createMqCentroidOffsets(seed + 0.1F);
        DvMqCentroidOffsets mqKicCentroidOffsets = createMqCentroidOffsets(seed + 0.2F);
        DvMqImageCentroid mqControlImageCentroid = createMqImageCentroid(seed + 0.3F);
        DvMqImageCentroid mqDifferenceImageCentroid = createMqImageCentroid(seed + 0.4F);
        DvSummaryQualityMetric summaryQualityMetric = createSummaryQualityMetric(seed + 0.5F);
        DvSummaryOverlapMetric summaryOverlapMetric = createSummaryOverlapMetric(seed + 0.6F);

        return new DvDifferenceImageMotionResults(mqControlCentroidOffsets,
            mqKicCentroidOffsets, mqControlImageCentroid,
            mqDifferenceImageCentroid, summaryQualityMetric,
            summaryOverlapMetric);
    }

    static DvPixelCorrelationMotionResults createPixelCorrelationMotionResults(
        float seed) {

        DvMqCentroidOffsets mqControlCentroidOffsets = createMqCentroidOffsets(seed + 0.1F);
        DvMqCentroidOffsets mqKicCentroidOffsets = createMqCentroidOffsets(seed + 0.2F);
        DvMqImageCentroid mqControlImageCentroid = createMqImageCentroid(seed + 0.3F);
        DvMqImageCentroid mqCorrelationImageCentroid = createMqImageCentroid(seed + 0.4F);

        return new DvPixelCorrelationMotionResults(mqControlCentroidOffsets,
            mqKicCentroidOffsets, mqControlImageCentroid,
            mqCorrelationImageCentroid);
    }

    static DvCentroidResults createCentroidResults(float seed) {
        return createCentroidResults(createCentroidMotionResults(seed + 0.01F),
            createCentroidMotionResults(seed + 0.02F),
            createDifferenceImageMotionResults(seed + 0.03F),
            createPixelCorrelationMotionResults(seed + 0.04F));
    }

    private static DvCentroidResults createCentroidResults(
        DvCentroidMotionResults fluxWeightedMotionResults,
        DvCentroidMotionResults prfMotionResults,
        DvDifferenceImageMotionResults differenceImageMotionResults,
        DvPixelCorrelationMotionResults pixelCorrelationMotionResults) {

        return new DvCentroidResults(fluxWeightedMotionResults,
            prfMotionResults, differenceImageMotionResults,
            pixelCorrelationMotionResults);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvCentroidResults();

        testCentroidResults(centroidResults);
    }

    private static void testCentroidResults(DvCentroidResults centroidResults) {
        assertEquals(FLUX_WEIGHTED_MOTION_RESULTS,
            centroidResults.getFluxWeightedMotionResults());
        assertEquals(PRF_MOTION_RESULTS, centroidResults.getPrfMotionResults());
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvCentroidResults cr = createCentroidResults(
            FLUX_WEIGHTED_MOTION_RESULTS, PRF_MOTION_RESULTS,
            DIFFERENCE_IMAGE_MOTION_RESULTS, PIXEL_CORRELATION_MOTION_RESULTS);
        assertEquals(centroidResults, cr);

        cr = createCentroidResults(createCentroidMotionResults(42.0F),
            PRF_MOTION_RESULTS, DIFFERENCE_IMAGE_MOTION_RESULTS,
            PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("equals", centroidResults.equals(cr));

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            createCentroidMotionResults(42.0F),
            DIFFERENCE_IMAGE_MOTION_RESULTS, PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("equals", centroidResults.equals(cr));

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            PRF_MOTION_RESULTS, createDifferenceImageMotionResults(42.0F),
            PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("equals", centroidResults.equals(cr));

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            PRF_MOTION_RESULTS, DIFFERENCE_IMAGE_MOTION_RESULTS,
            createPixelCorrelationMotionResults(42.0F));
        assertFalse("equals", centroidResults.equals(cr));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvCentroidResults cr = createCentroidResults(
            FLUX_WEIGHTED_MOTION_RESULTS, PRF_MOTION_RESULTS,
            DIFFERENCE_IMAGE_MOTION_RESULTS, PIXEL_CORRELATION_MOTION_RESULTS);
        assertEquals(centroidResults.hashCode(), cr.hashCode());

        cr = createCentroidResults(createCentroidMotionResults(42.0F),
            PRF_MOTION_RESULTS, DIFFERENCE_IMAGE_MOTION_RESULTS,
            PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("hashCode", centroidResults.hashCode() == cr.hashCode());

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            createCentroidMotionResults(42.0F),
            DIFFERENCE_IMAGE_MOTION_RESULTS, PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("hashCode", centroidResults.hashCode() == cr.hashCode());

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            PRF_MOTION_RESULTS, createDifferenceImageMotionResults(42.0F),
            PIXEL_CORRELATION_MOTION_RESULTS);
        assertFalse("hashCode", centroidResults.hashCode() == cr.hashCode());

        cr = createCentroidResults(FLUX_WEIGHTED_MOTION_RESULTS,
            PRF_MOTION_RESULTS, DIFFERENCE_IMAGE_MOTION_RESULTS,
            createPixelCorrelationMotionResults(42.0F));
        assertFalse("hashCode", centroidResults.hashCode() == cr.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(centroidResults.toString());
    }
}
