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

package gov.nasa.kepler.fs.server.index.btree;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import gov.nasa.kepler.fs.server.index.MemoryNodeIO;

import java.util.Comparator;
import java.util.HashSet;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class NodeTest {

	private final Comparator<String> comp =
		new Comparator<String>() {

			public int compare(String o1, String o2) {
				return o1.compareTo(o2);
			}
		
	};
	
    private MemoryNodeIO<String, Integer,BtreeNode<String,Integer>> mio;
    
	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
         mio = new MemoryNodeIO<String, Integer,BtreeNode<String,Integer>>();
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}
	
	/**
	 * Example from p. 391 of _Algorithms_  by Corman,  Leiserson, Rivest
	 * @throws Exception
	 */
	@Test
	public void splitNode() throws Exception {
		
		int t=4;
		
		BtreeNode<String,Integer> y = 
			new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
		
		int value=0;
		long childCounter = Integer.MAX_VALUE + 1;
		
		y.add("A", value++, comp);
		y.add("D", value++, comp);
		y.add("F", value++, comp);
		y.add("H", value++, comp);
		y.add("L", value++, comp);
		y.add("N", value++, comp);
		y.add("P", value++, comp);
		
		for (int i=0; i < (t*2); i++) {
			y.childAddresses.add(childCounter++);
		}
		
		BtreeNode<String, Integer> s = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
		s.addChild(0, y.address());
		
		BtreeNode<String,Integer> newNode = y.split(t, s, 0);
		
		assertEquals(2, s.childAddresses.size());
		assertEquals(y.address(), (long) s.childAddresses.get(0));
		assertEquals(newNode.address(), (long) s.childAddresses.get(1));
		assertEquals(1, s.keys.size());
		assertEquals("H", s.keys.get(0));
		assertEquals(1, s.values.size());
		assertEquals(3, (int) s.values.get(0));
		
		assertEquals(3, y.keys.size());
		assertEquals("A", y.keys.get(0));
		assertEquals("D", y.keys.get(1));
		assertEquals("F", y.keys.get(2));
		assertEquals(3, y.values.size());
		assertEquals(0, (int) y.values.get(0));
		assertEquals(1, (int) y.values.get(1));
		assertEquals(2, (int) y.values.get(2));
		
		assertEquals(3, newNode.keys.size());
		assertEquals("L", newNode.keys.get(0));
		assertEquals("N", newNode.keys.get(1));
		assertEquals("P", newNode.keys.get(2));
		
		assertEquals(3, newNode.values.size());
		assertEquals(4, (int) newNode.values.get(0));
		assertEquals(5, (int) newNode.values.get(1));
		assertEquals(6, (int) newNode.values.get(2));
	}
    
    @Test
    public void mergeNodesWithoutChildren() throws Exception {
        @SuppressWarnings("unused")
        int t = 3;
        BtreeNode<String, Integer> x = 
            new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        
       x.add("A", 0, comp);
       x.add("B", 1, comp);
       
       
       BtreeNode<String, Integer> y =
           new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
       
       y.add("D", 3, comp);
       y.add("E", 4, comp);
       
       x.merge(y, "C", 2);
       
       
       int count=0;
       for (String key : new String[] { "A", "B", "C", "D", "E"} ) {
           assertEquals(key, x.keys.get(count));
           assertEquals(count, (int) x.values.get(count));
           count++;
       }
    }
    
    /**
     *                              key =G
     *       x=  [ D E]                            y=   [J K]
     * [CA CB] [DA DB] [EA EB]       [GA GB] [JA JB]  [KA KB]
     * 
     * @throws Exception
     */
    @Test
    public void mergeNodesWithChildren() throws Exception {
        @SuppressWarnings("unused")
        int t = 3;
        BtreeNode<String, Integer> x =
            new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        
        
        x.add("D", 2, comp);
        x.add("E", 5, comp);
        
        BtreeNode<String, Integer> xc1 = 
            new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        xc1.add("CA", 0, comp);
        xc1.add("CB", 1, comp);
        
        x.addChild(0, xc1.address());
        
        BtreeNode<String, Integer> xc2 = 
            new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        xc2.add("DA", 3, comp);
        xc2.add("DB", 4, comp);
        
        x.addChild(1, xc2.address());
        
        BtreeNode<String, Integer> xc3 = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        xc3.add("EA", 6, comp);
        xc3.add("EB", 7, comp);
        
        x.addChild(2, xc3.address());
        
        
        BtreeNode<String, Integer> y = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        y.add("J", 11, comp);
        y.add("K",14, comp);
        
        BtreeNode<String, Integer> yc1 = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        yc1.add("GA", 9, comp);
        yc1.add("GB", 10, comp);
        
        y.addChild(0, yc1.address());
        
        BtreeNode<String, Integer> yc2 = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        yc2.add("JA", 12, comp);
        yc2.add("JB", 13, comp);
        
        y.addChild(1, yc2.address());
        
        BtreeNode<String, Integer> yc3 = new BtreeNode<String, Integer>(mio.allocateAddress(), mio);
        yc3.add("KA", 15, comp);
        yc3.add("KB", 16, comp);
        
        y.addChild(2, yc3.address());
        
        @SuppressWarnings("unchecked")
        BtreeNode<String, Integer>[] allNodes = (BtreeNode<String, Integer>[])
            new BtreeNode[] {x, y, xc1, xc2, xc3, yc1, yc2, yc3};
     
        for (BtreeNode<String, Integer> saveMe : allNodes) {
            mio.writeNode(saveMe);
        }
        
        x.merge(y, "G", 8);
        
        Set<String> visitedKeys = validateNode(x);
        String[] allKeys =
            new String[] {"CA", "CB", "D",  "DA", "DB", "E", "EA", "EB", "G", "GA", "GB", "J", "JA", "JB", "K", "KA", "KB"};
        for (String key : allKeys) {
            assertTrue("visited keys does not contain key \"" + key + "\".", 
                              visitedKeys.contains(key));
        }
           
    }
    
    /**
     * Checks that keys are values are in order.
     * @param x
     * @return visited keys
     * @throws Exception
     */
    private  Set<String> validateNode(BtreeNode<String, Integer> x) throws Exception {
        Set<String> visitedKeys = new HashSet<String>();
        
        validateNodeRec(x, visitedKeys);
        
        return visitedKeys;
    }
    
    private void validateNodeRec(BtreeNode<String, Integer> x, Set<String> visitedKeys) throws Exception {
        if (!x.isLeaf()) {
            checkChildKeys(x.child(0), x.keys.get(0), true);
            validateNodeRec(x.child(0), visitedKeys);
            for (int i=0; i < x.keys.size(); i++) {
                checkChildKeys(x.child(i+1), x.keys.get(i), false);
                validateNodeRec(x.child(i+1), visitedKeys);
            }
        }
        
        
        visitedKeys.add(x.keys.get(0));
        String prev = x.keys.get(0);
        for (int i=1; i < x.keys.size(); i++) {
            visitedKeys.add(x.keys.get(i));
            assertTrue(comp.compare(prev, x.keys.get(i)) < 0);
            prev = x.keys.get(i);
        }
    }
    
    private void checkChildKeys(BtreeNode<String, Integer> child, String key, boolean less) throws Exception {
        for (String childKey : child.keys) {
            if (less) {
                assertTrue(comp.compare(childKey, key) < 0);
            } else {
                assertTrue("child key not in correct order " + childKey + " <= " +key, comp.compare(childKey, key) > 0);
            }
        }
    }
    
    
}
