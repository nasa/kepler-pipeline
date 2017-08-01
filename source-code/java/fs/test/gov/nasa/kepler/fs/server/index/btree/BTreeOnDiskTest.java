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
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.xfiles.DefaultStorage;
import gov.nasa.kepler.fs.server.xfiles.MjdTimeSeriesBtreeIo;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Comparator;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class BTreeOnDiskTest extends BTreeTest {

    private final File testRoot = new File(Filenames.BUILD_TEST,
        "BTreeOnDisk.test");
    private final KeyValueIO<String, Integer> kvio = new StringIntKeyValueIO();
    private final int nodeSize = 1024;
    private int t;
    private final File btreeFile = new File(testRoot, "btree-ondisktest");
    private final Comparator<String> comp = new Comparator<String>() {

        public int compare(String o1, String o2) {
            return o1.compareTo(o2);
        }
    };
    
    private final BtreeNode.Factory<String, Integer> nodeFactory = BtreeNode.Factory.instance();

    private ConcurrentLruCache<CacheNodeKey, BtreeNode<String, Integer>> cache;

    @Before
    public void setUp() throws Exception {
        int tripletSize = kvio.keySize() + kvio.valueSize() + 8;
        int tripletsPerNode = nodeSize / tripletSize;
        if ((nodeSize % tripletsPerNode) < 8) {
            tripletsPerNode--;
        }
        t = tripletsPerNode / 2;
        // System.out.println("t="+t);

        if (!testRoot.mkdirs()) {
            throw new IOException("Can not make directory \"" + testRoot
                + "\".");
        }
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String, Integer>>(16); //TODO: revert back to 2
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    @Test
    public void deleteDeeper() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
                kvio, btreeFile, nodeSize,cache,nodeFactory);
        deleteDeeper(diskIo);
    }
    @Test
    public void deleteRight() throws Exception {
    	DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
                kvio, btreeFile, nodeSize,cache,nodeFactory);
        deleteRight(diskIo);
    }
    @Test
    public void emptyFindTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        emptyFind(diskIo);
    }

    @Test
    public void fillRootNodeOnlyTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        fillRootNodeOnly(diskIo);
    }

    @Test
    public void rootOverflowTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        rootOverflow(diskIo);
    }

    @Test
    public void deleteFromNothingTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        deleteFromNothing(diskIo);
    }

    @Test
    public void deleteNotInTreeTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        deleteNotInTree(diskIo);
    }

    @Test
    public void simpleDeleteMakeRootEmptyTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        simpleDeleteMakeRootEmpty(diskIo);
    }

    @Test
    public void bookInsertTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        bookInsert(diskIo, false);
    }

    @Test
    public void bookDeleteTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        bookDelete(diskIo);
    }

    @Test
    public void symmetricCase3abTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        symmetricCase3ab(diskIo);
    }

    @Test
    public void case3aWithChildrenTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        case3aWithChildren(diskIo);
    }

    @Test
    public void symmetic3aWithChildren() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        symmetic3aWithChildren(diskIo);
    }

    @Test
    public void updateValueTest() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        updateValue(diskIo);
    }

    @Test(expected = java.lang.IllegalArgumentException.class)
    public void invalidNodeSize() throws Exception {
        @SuppressWarnings("unused")
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, 16,cache,nodeFactory);
    }

    @Test
    public void bigTree() throws Exception {
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(
            kvio, btreeFile, nodeSize,cache,nodeFactory);
        BTree<String, Integer> btree = new BTree<String, Integer>(diskIo, t,
            comp);
        final int nElements = 1024 * 128;

        for (int i = 0; i < nElements; i++) {
            btree.insert("" + i, i);
            if ((i % 32) == 0) {
                diskIo.flushPendingModifications();
            }
        }
        diskIo.flushPendingModifications();
        cache.clear();

        for (int i = 0; i < nElements; i++) {
            assertEquals(i, (int) btree.find("" + i));
        }

        cache.clear();

        assertEquals(8, btree.maxDepth());

        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String, Integer>>(128);
        diskIo = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize,
            cache, nodeFactory);
        btree = new BTree<String, Integer>(diskIo, t, comp);
        for (int i = 0; i < nElements; i++) {
            assertEquals(i, (int) btree.find("" + i));
        }
    }

    @Test
    public void deleteMiddleOfMjdTimeSeriesLikeThing() throws Exception {
        final int testNodeSize = 1024 *4;
        final int testBtreeT = 71;
        final ConcurrentLruCache<CacheNodeKey, BtreeNode<Long,MjdTestValue>> tinyCache = 
            new ConcurrentLruCache<CacheNodeKey, BtreeNode<Long,MjdTestValue>>(2);

        RandomAccessStorage storage = 
            new DefaultStorage(btreeFile, new FsId("/blah/btree-test"), true, true);
        NodeIO<Long, MjdTestValue,BtreeNode<Long,MjdTestValue>> diskIo =
            new MjdTimeSeriesBtreeIo<Long, MjdTestValue>(new MjdLikeIo(), testNodeSize, tinyCache, storage);

        Comparator<Long> comp = new Comparator<Long>() {

            @Override
            public int compare(Long d1, Long d2) {
                if (d1 < d2) {
                    return -1;
                } else if (d1 > d2) {
                    return 1;
                } else {
                    return 0;
                }
            }
        };
        
        BTree<Long, MjdTestValue> btree = new BTree<Long, MjdTestValue>(diskIo, testBtreeT, comp);
        final int nItems = 438;
        final long originator =  0xEDCBA987L;
        for (int i=0; i < nItems; i++) {
            btree.insert(i+1L, new MjdTestValue(1.0f/3.0f * (i + 1),originator));
        }
        diskIo.flushPendingModifications();
        diskIo.close();
        
        String dot = btree.toDot();
        FileWriter dotWriter = new FileWriter("/tmp/mjdtree.dot");
        dotWriter.write(dot);
        dotWriter.close();
        
        int index=1;
        tinyCache.clear();
        for (Pair<Long,MjdTestValue> kv : btree) {
            assertEquals( index, kv.left.longValue());
            assertEquals( new MjdTestValue( (float) 1.0f/3.0f * index, originator), kv.right);
            index++;
        }
        
        final long deleteKey = nItems/2;
        btree.delete(deleteKey);
        diskIo.flushPendingModifications();
        diskIo.close();
        tinyCache.clear();
        index=1;
        for (Pair<Long, MjdTestValue> kv : btree) {
            long key = kv.left.longValue();
            if (index == deleteKey) {
                index++;
            }
            assertEquals(index, key);
            index++;
        }
    }

    private static final class MjdTestValue {
        public final float value;
        public final long originator;

        public MjdTestValue(float value, long originator) {
            this.value = value;
            this.originator = originator;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + (int) (originator ^ (originator >>> 32));
            result = prime * result + Float.floatToIntBits(value);
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            final MjdTestValue other = (MjdTestValue) obj;
            if (originator != other.originator)
                return false;
            if (Float.floatToIntBits(value) != Float.floatToIntBits(other.value))
                return false;
            return true;
        }
        
        @Override
        public String toString() {
            return String.format("%4.2f", value);
        }

    }

    private static final class MjdLikeIo implements
        KeyValueIO<Long, MjdTestValue> {

        @Override
        public int keySize() {
            return 8;
        }

        @Override
        public Long readKey(DataInput din) throws IOException {
            return din.readLong();
        }

        @Override
        public MjdTestValue readValue(DataInput din) throws IOException {
            return new MjdTestValue(din.readFloat(), din.readLong());
        }

        @Override
        public int valueSize() {
            return 12;
        }

        @Override
        public void writeKey(DataOutput dout, Long key) throws IOException {
            dout.writeLong(key.longValue());
        }

        @Override
        public void writeValue(DataOutput dout, MjdTestValue value)
            throws IOException {
            dout.writeFloat(value.value);
            dout.writeLong(value.originator);
        }

    }

}
