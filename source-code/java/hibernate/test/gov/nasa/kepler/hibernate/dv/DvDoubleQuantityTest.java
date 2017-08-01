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
 * Tests the {@link DvDoubleQuantity} class.
 * 
 * @author Forrest Girouard
 */
public class DvDoubleQuantityTest {

    private static final Log log = LogFactory.getLog(DvDoubleQuantityTest.class);

    static final double VALUE = 14.1;
    static final float UNCERTAINTY = 14.2F;

    private DvDoubleQuantity quantity;

    @Before
    public void createExpectedQuantity() {
        quantity = createQuantity(VALUE, UNCERTAINTY);
    }

    static DvDoubleQuantity createQuantity(double value, float uncertainty) {
        return new DvDoubleQuantity(value, uncertainty);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvDoubleQuantity();

        testQuantity(quantity);
    }

    static void testQuantity(DvDoubleQuantity quantity) {
        assertEquals(VALUE, quantity.getValue(), 0);
        assertEquals(UNCERTAINTY, quantity.getUncertainty(), 0);
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvDoubleQuantity mp = createQuantity(VALUE, UNCERTAINTY);
        assertEquals(quantity, mp);

        mp = createQuantity(VALUE + 1, UNCERTAINTY);
        assertFalse("equals", quantity.equals(mp));

        mp = createQuantity(VALUE, UNCERTAINTY + 1);
        assertFalse("equals", quantity.equals(mp));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvDoubleQuantity mp = createQuantity(VALUE, UNCERTAINTY);
        assertEquals(quantity.hashCode(), mp.hashCode());

        mp = createQuantity(VALUE + 1, UNCERTAINTY);
        assertFalse("hashCode", quantity.hashCode() == mp.hashCode());

        mp = createQuantity(VALUE, UNCERTAINTY + 1);
        assertFalse("hashCode", quantity.hashCode() == mp.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(quantity.toString());
    }
}
