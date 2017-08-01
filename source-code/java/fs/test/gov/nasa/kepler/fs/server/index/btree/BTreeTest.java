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


import static org.junit.Assert.*;
import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


abstract class BTreeTest {

	private static final Comparator<String> comp =
		new Comparator<String>() {

			public int compare(String o1, String o2) {
				return o1.compareTo(o2);
			}
		
	};
	

	protected void emptyFind(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
		BTree<String, Integer> btree = 
            new BTree<String, Integer>(nodeIo, 4, comp);
		
		assertEquals(null, btree.find(""));
		
		assertEquals(0, btree.maxDepth());	
	}
	
	
	protected void fillRootNodeOnly(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
		BTree<String, Integer> btree =
            new BTree<String, Integer>(nodeIo, 4, comp);
		
		btree.insert("D", 1);
		btree.insert("F", 2);
		btree.insert("H", 3);
		btree.insert("L", 4);
		btree.insert("N", 5);
		btree.insert("P", 6);
		btree.insert("A", 0);
		nodeIo.flushPendingModifications();
		
		assertFindStuff(btree, new String[] { "D", "F", "H", "L", "N", "P", "X"},
				new Integer[] { 1, 2, 3, 4, 5, 6, null});
		assertEquals(1, btree.maxDepth());
		
	}

	private void assertFindStuff(BTree<String, Integer> btree, 
						   String[] keys, Integer[] values) throws Exception {
		for (int i=0; i < keys.length; i++) {
			String key = keys[i];
			Integer value = values[i];
			assertEquals(key+"->"+value, value, btree.find(key));
		}
	}
	
    /**
     * This should be the resulting tree.
     * digraph G {
      * node1[shape=record,label="<f0>|<f1>H|<f4>"];
      *  node0[shape=record,label="<f0>A|<f1>D|<f2>F"];
      *  node2[shape=record,label="<f0>K|<f1>L|<f2>N|<f3>P"];
      *  "node1":f0->node0;
      *  "node1":f2->node2;
      *}
      */
	
	protected void rootOverflow(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
		BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, 4, comp);
		
		//btree.insert("A", 0);
		btree.insert("D", 1);
		btree.insert("F", 2);
		btree.insert("H", 3);
		btree.insert("L", 4);
		btree.insert("N", 5);
		btree.insert("P", 6);
		btree.insert("A", 0);
		btree.insert("K", 7);
        nodeIo.flushPendingModifications();
        
		assertEquals(2, btree.maxDepth());
		
		assertFindStuff(btree, new String[] {"A", "D", "F", "H", "L", "N", "P", "X"},
				new Integer[] {0, 1, 2, 3, 4, 5, 6,  null});
	}
    
    
    protected void deleteFromNothing(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, 3, comp);
        btree.delete("X");
        nodeIo.flushPendingModifications();
        
        assertEquals(0, btree.maxDepth());
    }
    
    
    protected void deleteNotInTree(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, 3, comp);
        btree.insert("A", 0);
        btree.delete("X");
        nodeIo.flushPendingModifications();
        
        assertEquals(1, btree.maxDepth());
        assertEquals(0, (int) btree.find("A"));
    }
    
    
    protected void simpleDeleteMakeRootEmpty(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, 3, comp);
        btree.insert("A", 0);
        btree.insert("B", 1);
        btree.delete("A");
        btree.delete("B");
        nodeIo.flushPendingModifications();
        
        assertEquals(0, btree.maxDepth());
        assertEquals(null, btree.find("A"));
        assertEquals(null, btree.find("B"));
    }
    
    /**
     * This runs the example on pg. 396-397
     * @param compareTree check the output of toDot(), this is dependent
     * on node address assignment.
     * @throws Exception
     */
    
    protected void bookInsert(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo, boolean compareTree) throws Exception {
        String[] keys = "ABCDEFGJKLMNOPQRSTUVXYZ".split("");
        //Older versions of Java put a "" as the first element.
        if (keys[0].equals("")) {
            keys = Arrays.copyOfRange(keys, 1, keys.length);
        }
        int t=3;
        
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=0; i < keys.length; i++) {
            btree.insert(keys[i], i);
            //System.out.println(btree.toDot());
        }
        nodeIo.flushPendingModifications();
        
        assertEquals(3, btree.maxDepth());
        for (int i=0; i < keys.length; i++) {
            assertEquals("expected " + keys[i] + " -> " + i , i, (int) btree.find(keys[i]));
        }
        
        Pattern whitespacePattern = Pattern.compile("\\s+", Pattern.MULTILINE);
        
        String expectedGraph = "digraph BTree {"+
        "       node0[shape=record,label=\"<f0>|<f1>K|<f2>\"];"+
        "       node7[shape=record,label=\"<f0>|<f1>C|<f2>|<f3>F|<f4>\"];"+
        "       node1[shape=record,label=\"<f0>A|<f1>B\"];"+
        "       node2[shape=record,label=\"<f0>D|<f1>E\"];"+
        "       node3[shape=record,label=\"<f0>G|<f1>J\"];"+
        "       node8[shape=record,label=\"<f0>|<f1>N|<f2>|<f3>Q|<f4>|<f5>T|<f6>\"];"+
        "       node4[shape=record,label=\"<f0>L|<f1>M\"];"+
        "       node5[shape=record,label=\"<f0>O|<f1>P\"];"+
        "       node6[shape=record,label=\"<f0>R|<f1>S\"];"+
        "       node9[shape=record,label=\"<f0>U|<f1>V|<f2>X|<f3>Y|<f4>Z\"];"+
        "       \"node0\":f0->node7[label=\"7\"];"+
        "       \"node7\":f0->node1[label=\"1\"];"+
        "       \"node7\":f2->node2[label=\"2\"];"+
        "       \"node7\":f4->node3[label=\"3\"];"+
        "       \"node0\":f2->node8[label=\"8\"];"+
        "       \"node8\":f0->node4[label=\"4\"];"+
        "       \"node8\":f2->node5[label=\"5\"];"+
        "       \"node8\":f4->node6[label=\"6\"];"+
        "       \"node8\":f6->node9[label=\"9\"];"+
        "}";
        Matcher matcher = whitespacePattern.matcher(expectedGraph);
        expectedGraph = matcher.replaceAll("");
        
        String actualGraph = btree.toDot().replaceAll("[ \t\n]+", "");
        if (compareTree) {
            boolean ok = false;
            try {
                assertEquals(expectedGraph, actualGraph);
                ok = true;
            } finally {
                if (!ok) {
                    System.out.println("Exepcted graph.");
                    System.out.println(expectedGraph);
                    System.out.println("Actual graph.");
                    System.out.println(actualGraph);
                }
            }
        }

        int i=0;
        for (Pair<String,Integer> kv : btree) {
            assertEquals(keys[i], kv.left);
            assertEquals(i, (int) kv.right);
            i++;
        }
        
        //System.out.println("-------------");
        for (i=1; i < keys.length; i++) {
            Iterator<Pair<String,Integer>> it = btree.iterateFrom(keys[i]);
            int j=i;
            while (it.hasNext()) {
                Pair<String, Integer> kv = it.next();
                assertEquals(keys[j], kv.left);
                assertEquals(j, (int) kv.right);
                j++;
            }
            assertEquals(keys.length, j);
        }
        
        //Iterate from missing point
        Iterator<Pair<String, Integer>> fromMissing = btree.iterateFrom("JJ");
        i=8;
        while (fromMissing.hasNext()) {
            Pair<String, Integer> kv = fromMissing.next();
            assertEquals(keys[i], kv.left);
            assertEquals(i, (int) kv.right);
            i++;
        }
        assertEquals(keys.length, i);
        
        //Iterate from off the end
        Iterator<Pair<String, Integer>> fromEnd = btree.iterateFrom("ZZ");
        assertFalse(fromEnd.hasNext());
    }

    /**
     * This is here to test deleting the key from the root node and also to see
     * how delete() recursively finds the key to replace the deleted key.
     * @param nodeIo
     * @throws Exception
     */
    protected void deleteDeeper(NodeIO<String, Integer, BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
        btree.delete("K");
        
        btree.checkTree();
        valueMap.remove("K");
        checkValues(valueMap, btree);
    }
    
    
    /**
     * Delete the right most internal node key.
     * @param nodeIo
     * @throws Exception
     */
    protected void deleteRight(NodeIO<String, Integer, BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        
        checkValues(valueMap, btree);
        
        for (String s : new String[] {"V", "X", "Z"}) {
            btree.delete(s);
            valueMap.remove(s);
        }
        
        btree = new BTree<String, Integer>(nodeIo, t, comp);
        //System.out.println(btree.toDot());
        
        btree.checkTree();
        checkValues(valueMap, btree);
    }
    
    /**
     * This runs the example on pg. 396-397 with some modification.
     * @throws Exception
     */ 
    
    protected void bookDelete(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        
        checkValues(valueMap, btree);
      //  System.out.println(btree.toDot());
        
        //Case 1
        btree.delete("X");
        valueMap.remove("X");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
       // System.out.println(btree.toDot());
        //Case 2a
        btree.delete("U");
        valueMap.remove("U");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
       // System.out.println(btree.toDot());
        //Case 2b
        btree.delete("R");
        valueMap.remove("R");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
        //System.out.println(btree.toDot());
        //Case 2c
        btree.delete("N");
        valueMap.remove("N");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
        //System.out.println(btree.toDot());
        
        //Case 3b, this also deletes the root and moves the whole tree up.
        btree.delete("D");
        valueMap.remove("D");
        nodeIo.flushPendingModifications();
      //  System.out.println(btree.toDot());
        checkValues(valueMap, btree);
        

        btree.delete("B");
        valueMap.remove("B");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
       // System.out.println(btree.toDot());
    }
	
    /**
     * Uses the right sub tree.
     * @throws Exception
     */
    
    protected void symmetricCase3ab(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        
        //3b
        for (String deleteKey  : new String[] {"X", "U", "R", "N", "Q" }) {
            btree.delete(deleteKey);
            valueMap.remove(deleteKey);
        }
        nodeIo.flushPendingModifications();

        
        checkValues(valueMap, btree);
        
        //3a
        btree.delete("D");
        valueMap.remove("D");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
    }
    
    
    protected void case3aWithChildren(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        
        btree.delete("D");
        valueMap.remove("D");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
    }
    
    
    protected void symmetic3aWithChildren(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        //Note this start point is different.
        String[] keys = "YZABPQRSTUVXCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
      //  System.out.println(btree.toDot());
        checkValues(valueMap, btree);
        
        btree.delete("Z");
        valueMap.remove("Z");
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
        
    //    System.out.println(btree.toDot());
    }

    
    /**
     * Updates the value of an existing key.
     * @throws Exception
     */
    protected void updateValue(NodeIO<String,Integer,BtreeNode<String,Integer>> nodeIo) throws Exception {
        String[] keys = "PQRSTUVXYZABCDEFGJKLMNO".split("");
        int t=3;
        
        Map<String, Integer> valueMap = new HashMap<String, Integer>();
        BTree<String, Integer> btree = new BTree<String, Integer>(nodeIo, t, comp);
        for (int i=1; i < keys.length; i++) {
            btree.insert(keys[i], i);
            valueMap.put(keys[i], i);
        }
        nodeIo.flushPendingModifications();
        
        valueMap.put("Q", Integer.MAX_VALUE);
        btree.insert("Q", Integer.MAX_VALUE);
        nodeIo.flushPendingModifications();
        checkValues(valueMap, btree);
    }
    
    /**
     * 
     * @param valueMap
     * @param btree
     * @throws Exception
     */
    
    private void checkValues(Map<String, Integer> valueMap, BTree<String, Integer> btree) throws Exception  {
        for (Map.Entry<String, Integer> entry : valueMap.entrySet()) {
            assertEquals("key="+entry.getKey(), entry.getValue(), btree.find(entry.getKey()));
        }
    }
}
