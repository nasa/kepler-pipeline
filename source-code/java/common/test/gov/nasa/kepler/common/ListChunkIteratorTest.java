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

package gov.nasa.kepler.common;

import static org.junit.Assert.*;

import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class ListChunkIteratorTest {

    @Test
    public void emptyIteratorTest() {
        ListChunkIterator<Object> empty = 
            new ListChunkIterator<Object>(new ArrayList<Object>().iterator(), 1);
        assertFalse(empty.hasNext());
    }
    
    @Test
    public void getOneListTest() {
        final int nElements = 5555;
        List<Integer> src = new ArrayList<Integer>(nElements);
        for (int i=0; i < 5555; i++) {
            src.add(i + 1);
        }
        
        ListChunkIterator<Integer> it = 
            new ListChunkIterator<Integer>(src.iterator(), nElements);
        assertTrue(it.hasNext());
        List<Integer> next = it.next();
        assertEquals(nElements, next.size());
        int i=0;
        for (int n : next) {
            assertEquals(++i, n);
        }
        assertFalse(it.hasNext());
    }
    
    @Test
    public void multiChunkTest() {
        final int nElements = 5555;
        List<Integer> src = new ArrayList<Integer>(nElements);
        for (int i=0; i < 5555; i++) {
            src.add(i + 1);
        }
        
        ListChunkIterator<Integer> it = 
            new ListChunkIterator<Integer>(src.iterator(), nElements/2);
        assertTrue(it.hasNext());
        int[] size = new int[] { nElements /2, nElements/2, 1};
        int i = 0;
        for (List<Integer> chunk : it) {
            assertEquals(size[i++], chunk.size());
        }
    }
    
}
