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

package gov.nasa.kepler.hibernate.mc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.pdq.PdqSeed;

import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the PDQ adaptive bounds report class.
 * 
 * @author Forrest Girouard
 * 
 */
public class BoundsReportTest {

    private static final float UPPER_BOUND = 10.0F;
    private static final float LOWER_BOUND = 2.0F;

    private BoundsReport abr;

    @Before
    public void createAdaptiveBoundsReport() {
        abr = PdqSeed.createBoundsReport(LOWER_BOUND, UPPER_BOUND);
    }

    @Test
    public void testConstructor() {

        assertEquals(LOWER_BOUND, abr.getLowerBound(), 0);
        assertEquals(UPPER_BOUND, abr.getUpperBound(), 0);
        assertTrue(abr.isOutOfUpperBound());
        assertEquals(1, abr.getOutOfUpperBoundsCount());

        assertNotNull(abr.getOutOfUpperBoundsTimes());
        assertEquals(1, abr.getOutOfUpperBoundsTimes()
            .size());
        assertEquals((double) LOWER_BOUND * UPPER_BOUND,
            abr.getOutOfUpperBoundsTimes()
                .get(0), 0);

        assertNotNull(abr.getOutOfUpperBoundsValues());
        assertEquals(1, abr.getOutOfUpperBoundsValues()
            .size());
        assertEquals(UPPER_BOUND + 1.0F, abr.getOutOfUpperBoundsValues()
            .get(0), 0);

        assertNotNull(abr.getUpperBoundsCrossingXFactors());
        assertEquals(1, abr.getUpperBoundsCrossingXFactors()
            .size());
        assertEquals(UPPER_BOUND / LOWER_BOUND,
            abr.getUpperBoundsCrossingXFactors()
                .get(0), 0);
    }

    @Test
    public void testEqualsObject() {

        BoundsReport abr1 = PdqSeed.createBoundsReport(LOWER_BOUND, UPPER_BOUND);
        assertTrue(abr.equals(abr1));

        BoundsReport abr2 = PdqSeed.createBoundsReport(LOWER_BOUND - 1.0F,
            UPPER_BOUND);
        assertFalse(abr1.equals(abr2));
    }

    @Test
    public void testHashCode() {

        BoundsReport abr1 = PdqSeed.createBoundsReport(LOWER_BOUND, UPPER_BOUND);
        assertEquals(abr.hashCode(), abr1.hashCode());

        BoundsReport abr2 = PdqSeed.createBoundsReport(LOWER_BOUND - 1.0F,
            UPPER_BOUND);

        assertTrue(abr.hashCode() != abr2.hashCode());
    }

}
