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
 * 
 * @author Forrest Girouard
 */
public class DvSecondaryEventResultsTest {

    private static final Log log = LogFactory.getLog(DvAbstractTargetTableDataTest.class);

    private DvSecondaryEventResults secondaryEventResults;
    private DvPlanetParameters planetParameters;
    private DvComparisonTests comparisonTests;

    @Before
    public void createSecondaryEventResults() {
        planetParameters = createPlanetParameters(1.0F);
        comparisonTests = createComparisonTests(2.0F);
        secondaryEventResults = createSecondaryEventResults(planetParameters,
            comparisonTests);
    }

    private static DvPlanetParameters createPlanetParameters(float seed) {
        DvQuantity geometricAlbedo = new DvQuantity(seed * 2, seed / 10.0F);
        DvQuantity planetEffectiveTemp = new DvQuantity(seed * 3, seed / 10.0F);
        return new DvPlanetParameters(geometricAlbedo, planetEffectiveTemp);
    }

    private static DvComparisonTests createComparisonTests(float seed) {
        DvStatistic albedoComparisonStatistic = new DvStatistic(seed * 2,
            seed / 10.0F);
        DvStatistic tempComparisonStatistic = new DvStatistic(seed * 3,
            seed / 10.0F);
        return new DvComparisonTests(albedoComparisonStatistic,
            tempComparisonStatistic);
    }

    private static DvSecondaryEventResults createSecondaryEventResults(
        DvPlanetParameters planetParameters, DvComparisonTests comparisonTests) {

        DvSecondaryEventResults secondaryEventResults = new DvSecondaryEventResults(
            planetParameters, comparisonTests);

        return secondaryEventResults;
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvSecondaryEventResults ser = createSecondaryEventResults(
            planetParameters, comparisonTests);
        assertEquals("equals", secondaryEventResults, ser);

        ser = createSecondaryEventResults(createPlanetParameters(2.0F),
            createComparisonTests(3.0F));
        assertFalse("equals", secondaryEventResults.equals(ser));

        ser = createSecondaryEventResults(createPlanetParameters(3.0F),
            createComparisonTests(2.0F));
        assertFalse("equals", secondaryEventResults.equals(ser));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvSecondaryEventResults ser = createSecondaryEventResults(
            planetParameters, comparisonTests);
        assertEquals("hashCode", secondaryEventResults.hashCode(),
            ser.hashCode());

        ser = createSecondaryEventResults(createPlanetParameters(2.0F),
            createComparisonTests(3.0F));
        assertEquals("hashCode", secondaryEventResults.hashCode(),
            ser.hashCode());

        ser = createSecondaryEventResults(createPlanetParameters(3.0F),
            createComparisonTests(2.0F));
        assertEquals("hashCode", secondaryEventResults.hashCode(),
            ser.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(secondaryEventResults.toString());
    }
}