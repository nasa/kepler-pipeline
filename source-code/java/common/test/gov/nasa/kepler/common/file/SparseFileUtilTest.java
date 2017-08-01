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

package gov.nasa.kepler.common.file;

import static org.junit.Assert.*;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class SparseFileUtilTest {

    private final File testRoot =
        new File(Filenames.BUILD_TMP, "FileFindTest.test");
    
    @Before
    public void before() throws Exception {
        FileUtil.mkdirs(testRoot);
    }
    
    @After
    public void after() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test
    public void fileExtentMapTest() throws Exception {
        
        SparseFileUtil fileExtentMap = new SparseFileUtil();
        
        File testFile = new File(testRoot, "sparse-file");
        RandomAccessFile raf = new RandomAccessFile(testFile, "rw");
        raf.write(1);
        raf.seek(1024*1024-1);
        raf.write(1);
        raf.close();
        
        List<SimpleInterval> extents =  fileExtentMap.extents(testFile);
        System.out.println("Found extents " + extents.size());
        for (SimpleInterval e : extents) {
            System.out.println(e);
        }
        
        assertEquals(2, extents.size());
        //Assumes the file system block size is 4k
        assertEquals(new SimpleInterval(0,1024*4-1), extents.get(0));
        assertEquals(new SimpleInterval(1024*1024-(4*1024), 1024*1024-1), extents.get(1));
    }
    
    @Test
    public void zeroLengthFileTest() throws Exception {
        SparseFileUtil sparseFileUtil = new SparseFileUtil();
        
        File testFile = new File(testRoot, "zero-length-file");
        assertTrue(testFile.createNewFile());
      
        List<SimpleInterval> extents = sparseFileUtil.extents(testFile);
        assertEquals(0, extents.size());
        
    }
}
