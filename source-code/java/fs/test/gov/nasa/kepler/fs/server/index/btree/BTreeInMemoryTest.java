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



import gov.nasa.kepler.fs.server.index.MemoryNodeIO;

import org.junit.Before;
import org.junit.Test;

/**
 * Test btree free of any disk IO.
 * 
 * @author Sean McCauliff
 *
 */
public class BTreeInMemoryTest extends BTreeTest {

    private MemoryNodeIO<String, Integer,BtreeNode<String,Integer>> memIo; 
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        memIo = new MemoryNodeIO<String, Integer,BtreeNode<String,Integer>>();
    }
    
    @Test
    public void deleteRight() throws Exception {
        deleteRight(memIo);
    }
    @Test
    public void deleteDeeper() throws Exception {
        deleteDeeper(memIo);
    }
    
    @Test
    public void emptyFindTest() throws Exception {
        emptyFind(memIo);
    }
    
    @Test
    public void fillRootNodeOnlyTest() throws Exception {
        fillRootNodeOnly(memIo);
    }
    
    @Test
    public void rootOverflowTest() throws Exception {
        rootOverflow(memIo);
    }
    
    @Test
    public void deleteFromNothingTest() throws Exception {
        deleteFromNothing(memIo);
    }
    
    @Test
    public void deleteNotInTreeTest() throws Exception {
        deleteNotInTree(memIo);
    }
    
    @Test
    public void simpleDeleteMakeRootEmptyTest() throws Exception {
        simpleDeleteMakeRootEmpty(memIo);
    }
    
    @Test
    public void bookInsertTest() throws Exception {
        bookInsert(memIo, true);
    }
    
    @Test
    public void bookDeleteTest() throws Exception {
        bookDelete(memIo);
    }
    
    @Test
    public void symmetricCase3abTest() throws Exception {
        symmetricCase3ab(memIo);
    }
    
    @Test
    public void case3aWithChildrenTest() throws Exception {
        case3aWithChildren(memIo);
    }
    
    @Test
    public void symmetic3aWithChildren() throws Exception {
        symmetic3aWithChildren(memIo);
    }
    
    @Test
    public void updateValueTest() throws Exception {
        updateValue(memIo);
    }

}
