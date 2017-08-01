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

package gov.nasa.kepler.cal;

import static org.junit.Assert.*;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.Pixel;

import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * @author Sean McCauliff
 *
 */
public class PixelRowIteratorTest {

    @Test
    public void iterateWithPixelIterator() {
        Pixel pixel0 = new Pixel(0, 0, new FsId("/pixel/0"));
        Pixel pixel1 = new Pixel(0, 1, new FsId("/pixel/1"));
        Pixel pixel2 = new Pixel(1, 0, new FsId("/pixel/2"));
        Pixel pixel3 = new Pixel(2, 0, new FsId("/pixel/3"));
        
        Set<Pixel> pixels = ImmutableSet.of(pixel0, pixel1, pixel2, pixel3);
        
        PixelRowIterator rowIt = new PixelRowIterator(pixels, 1);
        assertTrue(rowIt.hasNext());
        assertEquals(2,rowIt.nchunks());
        
        List<FsId> firstChunk = ImmutableList.of(pixel0.getFsId(), pixel1.getFsId());
        List<FsId> secondChunk = ImmutableList.of(pixel2.getFsId(), pixel3.getFsId());
        
        assertEquals(firstChunk, rowIt.next());
        assertTrue(rowIt.hasNext());
        assertEquals(secondChunk, rowIt.next());
        assertFalse(rowIt.hasNext());
        
    }
    
    @Test
    public void iterateWithEmptyPixeIterator() {
        @SuppressWarnings("unchecked")
        PixelRowIterator pixelIt = new PixelRowIterator(Collections.EMPTY_SET, 1024*2);
        assertFalse(pixelIt.hasNext());
    }
}
