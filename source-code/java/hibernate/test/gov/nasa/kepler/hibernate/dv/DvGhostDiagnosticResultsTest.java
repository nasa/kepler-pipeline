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
 * Tests the {@link DvGhostDiagnosticResults} class.
 * 
 * @author Bill Wohler
 */
public class DvGhostDiagnosticResultsTest {

    private static final Log log = LogFactory.getLog(DvGhostDiagnosticResultsTest.class);

    private static final int SIGNIFICANCE_DIVISOR = 10;
    private static final float CORE_APERTURE_CORRELATION_VALUE = 3.3F;
    private static final float HALO_APERTURE_CORRELATION_VALUE = 3.4F;

    private DvGhostDiagnosticResults ghostDiagnosticResults;
    private DvStatistic coreApertureCorrelationStatistic;
    private DvStatistic haloApertureCorrelationStatistic;

    @Before
    public void createExpectedGhostDiagnosticResults() {
        coreApertureCorrelationStatistic = DvStatisticTest.createStatistic(
            CORE_APERTURE_CORRELATION_VALUE, CORE_APERTURE_CORRELATION_VALUE
                / SIGNIFICANCE_DIVISOR);
        haloApertureCorrelationStatistic = DvStatisticTest.createStatistic(
            HALO_APERTURE_CORRELATION_VALUE, HALO_APERTURE_CORRELATION_VALUE
                / SIGNIFICANCE_DIVISOR);
        ghostDiagnosticResults = createGhostDiagnosticResults(
            coreApertureCorrelationStatistic.getValue(),
            coreApertureCorrelationStatistic.getSignificance(),
            haloApertureCorrelationStatistic.getValue(),
            haloApertureCorrelationStatistic.getSignificance());
    }

    private DvGhostDiagnosticResults createGhostDiagnosticResults(
        float coreApertureCorrelationValue,
        float coreApertureCorrelationSignificance,
        float haloApertureCorrelationValue,
        float haloApertureCorrelationSignificance) {

        return new DvGhostDiagnosticResults(new DvStatistic(
            coreApertureCorrelationValue, coreApertureCorrelationSignificance),
            new DvStatistic(haloApertureCorrelationValue,
                haloApertureCorrelationSignificance));
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvGhostDiagnosticResults();

        testGhostDiagnosticResults(ghostDiagnosticResults);
    }

    private void testGhostDiagnosticResults(
        DvGhostDiagnosticResults ghostDiagnosticResults) {

        DvStatisticTest.testStatistic(coreApertureCorrelationStatistic,
            ghostDiagnosticResults.getCoreApertureCorrelationStatistic());
        DvStatisticTest.testStatistic(haloApertureCorrelationStatistic,
            ghostDiagnosticResults.getHaloApertureCorrelationStatistic());
    }

    @Test
    public void testHashCodeEquals() {
        // Include all don't-care fields here.
        DvGhostDiagnosticResults c = createGhostDiagnosticResults(
            CORE_APERTURE_CORRELATION_VALUE, CORE_APERTURE_CORRELATION_VALUE
                / SIGNIFICANCE_DIVISOR, HALO_APERTURE_CORRELATION_VALUE,
            HALO_APERTURE_CORRELATION_VALUE / SIGNIFICANCE_DIVISOR);
        assertEquals(ghostDiagnosticResults.hashCode(), c.hashCode());
        assertEquals(ghostDiagnosticResults, c);

        c = createGhostDiagnosticResults(CORE_APERTURE_CORRELATION_VALUE + 1,
            CORE_APERTURE_CORRELATION_VALUE / SIGNIFICANCE_DIVISOR,
            HALO_APERTURE_CORRELATION_VALUE, HALO_APERTURE_CORRELATION_VALUE
                / SIGNIFICANCE_DIVISOR);
        assertFalse("hashCode",
            ghostDiagnosticResults.hashCode() == c.hashCode());
        assertFalse("equals", ghostDiagnosticResults.equals(c));

        c = createGhostDiagnosticResults(CORE_APERTURE_CORRELATION_VALUE,
            CORE_APERTURE_CORRELATION_VALUE + 1 / SIGNIFICANCE_DIVISOR,
            HALO_APERTURE_CORRELATION_VALUE, HALO_APERTURE_CORRELATION_VALUE
                / SIGNIFICANCE_DIVISOR);
        assertFalse("hashCode",
            ghostDiagnosticResults.hashCode() == c.hashCode());
        assertFalse("equals", ghostDiagnosticResults.equals(c));

        c = createGhostDiagnosticResults(CORE_APERTURE_CORRELATION_VALUE,
            CORE_APERTURE_CORRELATION_VALUE / SIGNIFICANCE_DIVISOR,
            HALO_APERTURE_CORRELATION_VALUE + 1,
            HALO_APERTURE_CORRELATION_VALUE / SIGNIFICANCE_DIVISOR);
        assertFalse("hashCode",
            ghostDiagnosticResults.hashCode() == c.hashCode());
        assertFalse("equals", ghostDiagnosticResults.equals(c));

        c = createGhostDiagnosticResults(CORE_APERTURE_CORRELATION_VALUE,
            CORE_APERTURE_CORRELATION_VALUE / SIGNIFICANCE_DIVISOR,
            HALO_APERTURE_CORRELATION_VALUE, HALO_APERTURE_CORRELATION_VALUE
                + 1 / SIGNIFICANCE_DIVISOR);
        assertFalse("hashCode",
            ghostDiagnosticResults.hashCode() == c.hashCode());
        assertFalse("equals", ghostDiagnosticResults.equals(c));
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(ghostDiagnosticResults.toString());
    }
}
