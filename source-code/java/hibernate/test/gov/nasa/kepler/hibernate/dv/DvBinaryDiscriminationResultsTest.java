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

import static gov.nasa.kepler.hibernate.dv.DvPlanetStatisticTest.PLANET_NUMBER;
import static gov.nasa.kepler.hibernate.dv.DvStatisticTest.SIGNIFICANCE;
import static gov.nasa.kepler.hibernate.dv.DvStatisticTest.VALUE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvBinaryDiscriminationResults} class.
 * 
 * @author Bill Wohler
 */
public class DvBinaryDiscriminationResultsTest {

    private static final Log log = LogFactory.getLog(DvBinaryDiscriminationResultsTest.class);

    private DvBinaryDiscriminationResults binaryDiscrimationResults;

    private enum ComparisonStatistic {
        NONE,
        SHORTER_PERIOD,
        LONGER_PERIOD,
        ODD_EVEN_TRANSIT_EPOCH,
        ODD_EVEN_TRANSIT_DEPTH,
        SINGLE_TRANSIT_DEPTH,
        SINGLE_TRANSIT_DURATION,
        SINGLE_TRANSIT_EPOCH,
    }

    @Before
    public void createExpectedBinaryDiscriminationResults() {
        binaryDiscrimationResults = createBinaryDiscriminationResults(
            PLANET_NUMBER, VALUE, SIGNIFICANCE, ComparisonStatistic.NONE);
    }

    private DvBinaryDiscriminationResults createBinaryDiscriminationResults(
        int planetNumber, float value, float significance,
        ComparisonStatistic variantField) {

        DvPlanetStatistic shorterPeriodComparisonStatistic = DvPlanetStatisticTest.createStatistic(
            planetNumber, value, significance);
        DvPlanetStatistic longerPeriodComparisonStatistic = DvPlanetStatisticTest.createStatistic(
            planetNumber, value, significance);
        DvStatistic oddEvenTransitEpochComparisonStatistic = DvStatisticTest.createStatistic(
            value, significance);
        DvStatistic oddEvenTransitDepthComparisonStatistic = DvStatisticTest.createStatistic(
            value, significance);
        DvStatistic singleTransitDepthComparisonStatistic = DvStatisticTest.createStatistic(
            value, significance);
        DvStatistic singleTransitDurationComparisonStatistic = DvStatisticTest.createStatistic(
            value, significance);
        DvStatistic singleTransitEpochComparisonStatistic = DvStatisticTest.createStatistic(
            value, significance);

        switch (variantField) {
            case SHORTER_PERIOD:
                shorterPeriodComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case LONGER_PERIOD:
                longerPeriodComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case ODD_EVEN_TRANSIT_DEPTH:
                oddEvenTransitDepthComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case ODD_EVEN_TRANSIT_EPOCH:
                oddEvenTransitEpochComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case SINGLE_TRANSIT_DEPTH:
                singleTransitDepthComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case SINGLE_TRANSIT_DURATION:
                singleTransitDurationComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case SINGLE_TRANSIT_EPOCH:
                singleTransitEpochComparisonStatistic = DvPlanetStatisticTest.createStatistic(
                    planetNumber + 1, value + 1, significance + 1);
            case NONE:
                break;
        }

        return new DvBinaryDiscriminationResults(
            shorterPeriodComparisonStatistic, longerPeriodComparisonStatistic,
            oddEvenTransitEpochComparisonStatistic,
            oddEvenTransitDepthComparisonStatistic,
            singleTransitDepthComparisonStatistic,
            singleTransitDurationComparisonStatistic,
            singleTransitEpochComparisonStatistic);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvBinaryDiscriminationResults();

        DvPlanetStatistic planetStatistic = binaryDiscrimationResults.getShorterPeriodComparisonStatistic();
        DvPlanetStatisticTest.testPlanetStatistic(planetStatistic);

        planetStatistic = binaryDiscrimationResults.getLongerPeriodComparisonStatistic();
        DvPlanetStatisticTest.testPlanetStatistic(planetStatistic);

        DvStatistic statistic = binaryDiscrimationResults.getOddEvenTransitEpochComparisonStatistic();
        DvStatisticTest.testStatistic(statistic);

        statistic = binaryDiscrimationResults.getOddEvenTransitDepthComparisonStatistic();
        DvStatisticTest.testStatistic(statistic);

        statistic = binaryDiscrimationResults.getSingleTransitDepthComparisonStatistic();
        DvStatisticTest.testStatistic(statistic);

        statistic = binaryDiscrimationResults.getSingleTransitDurationComparisonStatistic();
        DvStatisticTest.testStatistic(statistic);

        statistic = binaryDiscrimationResults.getSingleTransitEpochComparisonStatistic();
        DvStatisticTest.testStatistic(statistic);
    }

    @Test(expected = NullPointerException.class)
    public void testConstructorNullShort() {
        new DvBinaryDiscriminationResults(null,
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullLong() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), null, DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE), DvStatisticTest.createStatistic(VALUE,
                SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullEpoch() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvPlanetStatisticTest.createStatistic(
                PLANET_NUMBER, VALUE, SIGNIFICANCE), null,
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullDepth() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvPlanetStatisticTest.createStatistic(
                PLANET_NUMBER, VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE), null,
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullSingleDepth() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvPlanetStatisticTest.createStatistic(
                PLANET_NUMBER, VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE), null,
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullSingleDuration() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvPlanetStatisticTest.createStatistic(
                PLANET_NUMBER, VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE), null,
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE));
    }

    @Test(expected = NullPointerException.class)
    public void testBadConstructorNullSingleEpoch() {
        new DvBinaryDiscriminationResults(
            DvPlanetStatisticTest.createStatistic(PLANET_NUMBER, VALUE,
                SIGNIFICANCE), DvPlanetStatisticTest.createStatistic(
                PLANET_NUMBER, VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE),
            DvStatisticTest.createStatistic(VALUE, SIGNIFICANCE), null);
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvBinaryDiscriminationResults b = createBinaryDiscriminationResults(
            PLANET_NUMBER, VALUE, SIGNIFICANCE, ComparisonStatistic.NONE);
        assertEquals(binaryDiscrimationResults, b);

        for (ComparisonStatistic comparisonStatistic : ComparisonStatistic.values()) {
            if (comparisonStatistic == ComparisonStatistic.NONE) {
                continue;
            }
            b = createBinaryDiscriminationResults(PLANET_NUMBER, VALUE,
                SIGNIFICANCE, comparisonStatistic);
            assertFalse("equals", binaryDiscrimationResults.equals(b));
        }
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvBinaryDiscriminationResults b = createBinaryDiscriminationResults(
            PLANET_NUMBER, VALUE, SIGNIFICANCE, ComparisonStatistic.NONE);
        assertEquals(binaryDiscrimationResults.hashCode(), b.hashCode());

        for (ComparisonStatistic comparisonStatistic : ComparisonStatistic.values()) {
            if (comparisonStatistic == ComparisonStatistic.NONE) {
                continue;
            }
            b = createBinaryDiscriminationResults(PLANET_NUMBER, VALUE,
                SIGNIFICANCE, comparisonStatistic);
            assertFalse("hashCode",
                binaryDiscrimationResults.hashCode() == b.hashCode());
        }
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(binaryDiscrimationResults.toString());
    }
}
