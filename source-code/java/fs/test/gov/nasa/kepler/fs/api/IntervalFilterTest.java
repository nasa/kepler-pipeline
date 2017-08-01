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

package gov.nasa.kepler.fs.api;

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;


/**
 * Tests the interval filter.
 * 
 * @author Sean McCauliff
 *
 */
public class IntervalFilterTest {

	
	/**
	 *   0000000100000
	 *   ddddddddddddd
	 *        
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void simpleIntervalFilterTest() {
		List<SimpleInterval> original = new ArrayList<SimpleInterval>();
		original.add(new SimpleInterval(100,110));
		
		boolean[] filter = new boolean[11];
		filter[5] = true;
		
		IntervalFilter ifilter = new IntervalFilter();
		List<SimpleInterval> results = (List<SimpleInterval>)
			ifilter.filter(original, 100, 100, filter);
		assertEquals(1, results.size());
		assertEquals(0L, results.get(0).start());
		assertEquals(9L, results.get(0).end());
	}
	
	/**
	 * 1111110000000
	 * xxxxddddddddd
	 */
	@SuppressWarnings("unchecked")
	@Test
	public void clipStartFilterTest() {
		List<SimpleInterval> original = new ArrayList<SimpleInterval>();
		original.add(new SimpleInterval(10,15));
		
		boolean[] filter = new boolean[14];
		for (int i=0; i < 11; i++) {
			filter[i] = true;
		}
		
		IntervalFilter ifilter = new IntervalFilter();
		List<SimpleInterval> results = (List<SimpleInterval>)
			ifilter.filter(original, 2, 1, filter);
		assertEquals(1, results.size());
		assertEquals(1L, results.get(0).start());
		assertEquals(3L, results.get(0).end());
	}
	
	/**
	 *   0101010101010
	 *   ddddddXdddddd
	 */
	@SuppressWarnings("unchecked")
    @Test
	public void interleavedFilter() throws Exception {
		List<SimpleInterval> original = new ArrayList<SimpleInterval>();
		original.add(new SimpleInterval(0,5));
		original.add(new SimpleInterval(7,10));
		
		boolean[] filter = new boolean[11];
		for (int i=0; i < filter.length; i++) {
			filter[i] = (i & 0x01) == 1;
		}
		
		IntervalFilter ifilter = new IntervalFilter();
		List<SimpleInterval> results = (List<SimpleInterval>)
			ifilter.filter(original, 0, 0, filter);
		assertEquals(2, results.size());
		assertEquals(0L, results.get(0).start());
		assertEquals(2L, results.get(0).end());
		assertEquals(4L, results.get(1).start());
		assertEquals(5L, results.get(1).end());
		
	}
	
	/**
	 *   1010101010101
	 *   ddddddXdddddd
	 */
	@SuppressWarnings("unchecked")
    @Test
	public void interleavedMergeFilter() throws Exception {
		List<SimpleInterval> original = new ArrayList<SimpleInterval>();
		original.add(new SimpleInterval(0,5));
		original.add(new SimpleInterval(7,10));
		
		boolean[] filter = new boolean[11];
		for (int i=0; i < filter.length; i++) {
			filter[i] = (i & 0x01) == 0;
		}
		
		IntervalFilter ifilter = new IntervalFilter();
		List<SimpleInterval> results = (List<SimpleInterval>)
			ifilter.filter(original, 0, 0, filter);
		assertEquals(1, results.size());
		assertEquals(0L, results.get(0).start());
		assertEquals(4L, results.get(0).end());
	}
	
}
