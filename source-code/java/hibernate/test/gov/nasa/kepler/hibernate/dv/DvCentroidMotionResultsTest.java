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

import static gov.nasa.kepler.hibernate.dv.DvStatisticTest.SIGNIFICANCE;
import static gov.nasa.kepler.hibernate.dv.DvStatisticTest.VALUE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvCentroidMotionResults} class.
 * 
 * @author Bill Wohler
 */
public class DvCentroidMotionResultsTest {

    private static final Log log = LogFactory.getLog(DvCentroidMotionResultsTest.class);

    private static final int UNCERTAINTY_DIVISOR = 10;
    private static final double SOURCE_RA_HOURS = 3.1;
    private static final double SOURCE_DEC_DEGREES = 3.2;
    private static final double OOT_CENTROID_RA_HOURS = 3.21;
    private static final double OOT_CENTROID_DEC_DEGREES = 3.22;
    private static final float SOURCE_ROW_OFFSET = 3.3F;
    private static final float SOURCE_COLUMN_OFFSET = 3.4F;
    private static final float SOURCE_OFFSET_ARCSEC = 3.45F;
    private static final float PEAK_ROW_OFFSET = 3.5F;
    private static final float PEAK_COLUMN_OFFSET = 3.6F;
    private static final float PEAK_OFFSET_ARCSEC = 3.65F;

    private DvCentroidMotionResults centroidResults;

    @Before
    public void createExpectedCentroidResults() {
        centroidResults = createCentroidResults(SOURCE_RA_HOURS,
            SOURCE_DEC_DEGREES, OOT_CENTROID_RA_HOURS,
            OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET, SOURCE_COLUMN_OFFSET,
            SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET,
            PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
    }

    static DvCentroidMotionResults createCentroidResults(double sourceRaHours,
        double sourceDecDegrees, double outOfTransitCentroidRaHours,
        double outOfTransitCentroidDecDegrees, float sourceRowOffset,
        float sourceColumnOffset, float sourceOffsetArcSec,
        float peakRowOffset, float peakColumnOffset, float peakOffsetArcSec,
        float value, float significance) {

        DvStatistic motionDetectionStatistic = DvStatisticTest.createStatistic(
            value, significance);

        return new DvCentroidMotionResults(
            new DvDoubleQuantity(sourceRaHours,
                (float) (sourceRaHours / UNCERTAINTY_DIVISOR)),
            new DvDoubleQuantity(sourceDecDegrees,
                (float) (sourceDecDegrees / UNCERTAINTY_DIVISOR)),
            new DvDoubleQuantity(outOfTransitCentroidRaHours,
                (float) (outOfTransitCentroidRaHours / UNCERTAINTY_DIVISOR)),
            new DvDoubleQuantity(outOfTransitCentroidDecDegrees,
                (float) (outOfTransitCentroidDecDegrees / UNCERTAINTY_DIVISOR)),
            new DvQuantity(sourceRowOffset, sourceRowOffset
                / UNCERTAINTY_DIVISOR), new DvQuantity(sourceColumnOffset,
                sourceColumnOffset / UNCERTAINTY_DIVISOR), new DvQuantity(
                sourceOffsetArcSec, sourceOffsetArcSec / UNCERTAINTY_DIVISOR),
            new DvQuantity(peakRowOffset, peakRowOffset / UNCERTAINTY_DIVISOR),
            new DvQuantity(peakColumnOffset, peakColumnOffset
                / UNCERTAINTY_DIVISOR), new DvQuantity(peakOffsetArcSec,
                peakOffsetArcSec / UNCERTAINTY_DIVISOR),
            motionDetectionStatistic);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvCentroidMotionResults();

        testCentroidResults(centroidResults);
    }

    static void testCentroidResults(
        DvCentroidMotionResults centroidMotionResults) {

        assertEquals(SOURCE_RA_HOURS, centroidMotionResults.getSourceRaHours()
            .getValue(), 0);
        assertEquals(SOURCE_RA_HOURS / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getSourceRaHours()
                .getUncertainty(), 0.00000001);
        assertEquals(SOURCE_DEC_DEGREES,
            centroidMotionResults.getSourceDecDegrees()
                .getValue(), 0);
        assertEquals(SOURCE_DEC_DEGREES / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getSourceDecDegrees()
                .getUncertainty(), 0.00000001);
        assertEquals(OOT_CENTROID_RA_HOURS,
            centroidMotionResults.getOutOfTransitCentroidRaHours()
                .getValue(), 0);
        assertEquals(OOT_CENTROID_RA_HOURS / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getOutOfTransitCentroidRaHours()
                .getUncertainty(), 0.00000001);
        assertEquals(OOT_CENTROID_DEC_DEGREES,
            centroidMotionResults.getOutOfTransitCentroidDecDegrees()
                .getValue(), 0);
        assertEquals(OOT_CENTROID_DEC_DEGREES / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getOutOfTransitCentroidDecDegrees()
                .getUncertainty(), 0.00000001);
        assertEquals(SOURCE_ROW_OFFSET,
            centroidMotionResults.getSourceRaOffset()
                .getValue(), 0);
        assertEquals(SOURCE_ROW_OFFSET / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getSourceRaOffset()
                .getUncertainty(), 0.00000001);
        assertEquals(SOURCE_COLUMN_OFFSET,
            centroidMotionResults.getSourceDecOffset()
                .getValue(), 0);
        assertEquals(SOURCE_COLUMN_OFFSET / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getSourceDecOffset()
                .getUncertainty(), 0.00000001);

        assertEquals(PEAK_ROW_OFFSET, centroidMotionResults.getPeakRaOffset()
            .getValue(), 0);
        assertEquals(PEAK_ROW_OFFSET / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getPeakRaOffset()
                .getUncertainty(), 0.00000001);
        assertEquals(PEAK_COLUMN_OFFSET,
            centroidMotionResults.getPeakDecOffset()
                .getValue(), 0);
        assertEquals(PEAK_COLUMN_OFFSET / UNCERTAINTY_DIVISOR,
            centroidMotionResults.getPeakDecOffset()
                .getUncertainty(), 0.00000001);

        DvStatistic statistic = centroidMotionResults.getMotionDetectionStatistic();
        DvStatisticTest.testStatistic(statistic);
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvCentroidMotionResults c = createCentroidResults(SOURCE_RA_HOURS,
            SOURCE_DEC_DEGREES, OOT_CENTROID_RA_HOURS,
            OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET, SOURCE_COLUMN_OFFSET,
            SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET,
            PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertEquals(centroidResults, c);

        c = createCentroidResults(SOURCE_RA_HOURS + 1, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES + 1,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES,
            SOURCE_ROW_OFFSET + 1, SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC,
            PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE,
            SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET + 1, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC + 1, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET + 1,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET + 1, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC + 1, VALUE, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE + 1, SIGNIFICANCE);
        assertFalse("equals", centroidResults.equals(c));

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE + 1);
        assertFalse("equals", centroidResults.equals(c));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvCentroidMotionResults c = createCentroidResults(SOURCE_RA_HOURS,
            SOURCE_DEC_DEGREES, OOT_CENTROID_RA_HOURS,
            OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET, SOURCE_COLUMN_OFFSET,
            SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET,
            PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertEquals(centroidResults.hashCode(), c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS + 1, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES + 1,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS + 1, OOT_CENTROID_DEC_DEGREES,
            SOURCE_ROW_OFFSET, SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC,
            PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE,
            SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES + 1,
            SOURCE_ROW_OFFSET, SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC,
            PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE,
            SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES,
            SOURCE_ROW_OFFSET + 1, SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC,
            PEAK_ROW_OFFSET, PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE,
            SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET + 1, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC + 1, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET + 1,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET + 1, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC + 1, VALUE, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE + 1, SIGNIFICANCE);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());

        c = createCentroidResults(SOURCE_RA_HOURS, SOURCE_DEC_DEGREES,
            OOT_CENTROID_RA_HOURS, OOT_CENTROID_DEC_DEGREES, SOURCE_ROW_OFFSET,
            SOURCE_COLUMN_OFFSET, SOURCE_OFFSET_ARCSEC, PEAK_ROW_OFFSET,
            PEAK_COLUMN_OFFSET, PEAK_OFFSET_ARCSEC, VALUE, SIGNIFICANCE + 1);
        assertFalse("hashCode", centroidResults.hashCode() == c.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(centroidResults.toString());
    }
}
