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

package gov.nasa.kepler.fs.server.index;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Arrays;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class PersistentBitSetTest {

    private final File testRoot = new File(Filenames.BUILD_TEST
        + "/PersistableBitSetTest.test");

    @Before
    public void setUp() throws Exception {
        testRoot.mkdirs();

    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    @Test
    public void emptySet() throws Exception {
        File pbsetFile = new File(testRoot, "bpsetFile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetFile);
        pbset.close();
        PersistentBitSet pbset2 = new PersistentBitSet(pbsetFile);
        assertEquals(pbset, pbset2);
    }

    @Test
    public void updateSet() throws Exception {
        File pbsetFile = new File(testRoot, "bpsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetFile);
        pbset.set(0, true);
        pbset.set(80000, true);
        pbset.set(80001, false);
        assertTrue(pbset.get(80000));
        assertFalse(pbset.get(80001));
        assertTrue(pbset.get(0));
        pbset.close();

        PersistentBitSet pbset2 = new PersistentBitSet(pbsetFile);
        assertEquals(pbset, pbset2);
        assertTrue(pbset.get(80000));
        assertFalse(pbset.get(80001));
        assertTrue(pbset.get(0));
        pbset2.close();

    }

    @Test
    public void truncateSetToSizeZero() throws Exception {
        File pbsetfile = new File(testRoot, "bpsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);
        pbset.set(90000, true);
        pbset.truncate(0);
        pbset.set(900001, true);
        assertTrue(pbset.get(900001));
        assertFalse(pbset.get(90000));
        pbset.close();

        PersistentBitSet pbset2 = new PersistentBitSet(pbsetfile);
        assertEquals(pbset, pbset2);
    }

    @Test
    public void truncateSet() throws Exception {
        File pbsetfile = new File(testRoot, "bpsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);

        for (int truncateSize = 9; truncateSize <= 16; truncateSize++) {
            for (int i = 8; i < 16; i++) {
                pbset.set(i, true);
            }
            pbset.truncate(truncateSize);
            for (int i = 8; i < 16; i++) {
                if (i < truncateSize) {
                    assertTrue(" i: " + i + " truncateSize: " + truncateSize,
                        pbset.get(i));
                } else {
                    assertFalse(pbset.get(i));
                }
            }
        }

    }

    @Test
    public void findTrueFalseInSet() throws Exception {
        File pbsetfile = new File(testRoot, "bpsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);
        pbset.set(90000, true);
        pbset.set(1, true);
        List<Integer> trueIndices = pbset.allIndex(true);
        assertEquals(1, (int) trueIndices.get(0));
        assertEquals(90000, (int) trueIndices.get(1));

        List<Integer> falseIndices = pbset.allIndex(false);
        assertTrue(falseIndices.size() > 90000 - 1);
        int indexValue = 0;
        for (int falseIndex : falseIndices) {
            if (indexValue == 1 || indexValue == 90000) {
                indexValue++;
            }
            assertEquals(indexValue, falseIndex);
            indexValue++;
        }
        pbset.close();
    }

    @Test
    public void update() throws Exception {
        File pbsetfile = new File(testRoot, "bpsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);
        pbset.set(6, true);
        pbset.set(7, true);
        pbset.set(8, true);

        File pbsetfile2 = new File(testRoot, "secondfile");
        PersistentBitSet pbset2 = new PersistentBitSet(pbsetfile2);
        pbset2.set(6, false);
        pbset2.set(7, false);
        pbset2.set(8, false);

        pbset2.update(Arrays.asList(new Integer[] { 6, 7, 8 }), true);

        assertEquals(pbset, pbset2);
    }
    
    @Test
    public void findFalse() throws Exception {
        File pbsetfile = new File(testRoot, "pbsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);
        assertEquals(0, pbset.findNextFalse(0));
        pbset.set(7, true);
        assertEquals(0, pbset.findNextFalse(0));
        pbset.set(0, true);
        assertEquals(1, pbset.findNextFalse(0));
        for (int i=0; i < 8; i++) {
            pbset.set(i, true);
        }
        
        assertEquals(8, pbset.findNextFalse(0));
        pbset.set(8, true);
        assertEquals(9, pbset.findNextFalse(0));
        assertEquals(9, pbset.findNextFalse(8));

    }
    
    @Test
    public void truncateEnd() throws Exception {
        File pbsetfile = new File(testRoot, "pbsetfile");
        PersistentBitSet pbset = new PersistentBitSet(pbsetfile);
        pbset.truncateEndIfEmpty();
        assertEquals(0, pbset.capacityInBytes());
        pbset.set(0, true);
        pbset.truncateEndIfEmpty();
        assertEquals(1, pbset.capacityInBytes());
        pbset.set(1023, true);
        pbset.truncateEndIfEmpty();
        assertEquals(1024/8, pbset.capacityInBytes());
    }
}
