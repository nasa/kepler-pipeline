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

package gov.nasa.kepler.fs.server.nc;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class MetaSpaceTest {

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
    }
    
    /**
     * Tests that all the boundry conditions are met when metadata is the
     * reserved address space.
     *
     */
    @Test
    public void testMetaUsed() {
        MetaSpace space = new MetaSpace(2, true);
        
        assertTrue("isUsed", space.isUsed(0));
        assertTrue("isUsed", space.isUsed(MetaSpace.BLOCK_SIZE-1));
        assertTrue("isUsed", !space.isUsed(MetaSpace.BLOCK_SIZE));
        assertTrue("isUsed", space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE));
        assertTrue("isUsed", space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2-1));
        assertTrue("isUsed", !space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2));
        
        assertEquals(MetaSpace.BLOCK_SIZE, space.nextUnusedAddress(0));
        assertEquals(MetaSpace.BLOCK_SIZE, space.nextUnusedAddress(MetaSpace.BLOCK_SIZE-1));
        assertEquals(MetaSpace.BLOCK_SIZE+MetaSpace.BLOCK_SPACING-1, 
            space.nextUnusedAddress(MetaSpace.BLOCK_SIZE));
        assertEquals(MetaSpace.BLOCK_SIZE+MetaSpace.BLOCK_SPACING-1, 
            space.nextUnusedAddress(MetaSpace.BLOCK_SIZE+MetaSpace.BLOCK_SPACING-1));
        
        assertEquals(MetaSpace.BLOCK_SIZE*2 + MetaSpace.BLOCK_SPACING,
                     space.nextUnusedAddress(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE));
        
        assertEquals(MetaSpace.BLOCK_SIZE*2 + MetaSpace.BLOCK_SPACING,
            space.nextUnusedAddress(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2 - 1));
        
        assertEquals(2*(MetaSpace.BLOCK_SIZE+ MetaSpace.BLOCK_SPACING)-1,
            space.nextUnusedAddress(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2));
        
        assertEquals(MetaSpace.BLOCK_SIZE, space.xlateAddress(0));
        assertEquals(MetaSpace.USED_PLUS_UNUSED -1, 
                     space.xlateAddress(MetaSpace.BLOCK_SPACING-1));
        assertEquals(MetaSpace.USED_PLUS_UNUSED+MetaSpace.BLOCK_SIZE,
                     space.xlateAddress(MetaSpace.BLOCK_SPACING));
        
    }
    
    /**
     * Tests that all the boundry conditions are met when normal data is the
     * reserved address space.
     */
    @Test
    public void testMetaNotUsed() {
        MetaSpace space = new MetaSpace(2, false);
        
        assertTrue("isUsed", space.isUsed(0));
        assertTrue("isUsed", !space.isUsed(2));
        assertTrue("isUsed", !space.isUsed(MetaSpace.BLOCK_SIZE-1));
        assertTrue("isUsed", space.isUsed(MetaSpace.BLOCK_SIZE));
        assertTrue("isUsed", !space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE));
        assertTrue("isUsed", !space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2-1));
        assertTrue("isUsed", space.isUsed(MetaSpace.BLOCK_SPACING + MetaSpace.BLOCK_SIZE*2));
        
        assertEquals(2L, space.nextUnusedAddress(0));
        assertEquals(MetaSpace.BLOCK_SIZE-1, space.nextUnusedAddress(2));
        assertEquals(MetaSpace.BLOCK_SIZE+MetaSpace.BLOCK_SPACING, 
            space.nextUnusedAddress(MetaSpace.BLOCK_SIZE));
        
        assertEquals(MetaSpace.BLOCK_SIZE*2+MetaSpace.BLOCK_SPACING-1, 
            space.nextUnusedAddress(MetaSpace.BLOCK_SIZE+MetaSpace.BLOCK_SPACING));
        
        assertEquals(2L, space.xlateAddress(0L));
        assertEquals(MetaSpace.USED_PLUS_UNUSED+2L, 
                     space.xlateAddress(MetaSpace.BLOCK_SIZE));
        assertEquals(MetaSpace.USED_PLUS_UNUSED,
                     space.xlateAddress(MetaSpace.BLOCK_SIZE-2L));

    }

}
