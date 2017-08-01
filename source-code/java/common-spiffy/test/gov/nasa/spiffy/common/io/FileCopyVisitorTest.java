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

package gov.nasa.spiffy.common.io;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.CopyOp;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileCopyVisitor;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.io.filefilter.NotFileFilter;
import org.apache.commons.io.filefilter.PrefixFileFilter;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class FileCopyVisitorTest {

    private File testRoot = new File(Filenames.BUILD_TEST, "FileCopyVisitorTest.test");
    private File srcDir = new File(testRoot, "src");
    private File destDir = new File(testRoot, "dest");
    private File fileInRoot = new File(srcDir, "file-in-root");
    private File emptyDir = new File(srcDir, "empty-dir");
    private File firstLevelDir = new File(srcDir, "1");
    private File secondLevelDir = new File(firstLevelDir, "2");
    private File fileOneInSecondLevelDir = new File(secondLevelDir, "one");
    private File fileTwoInSecondLevelDir = new File(secondLevelDir, "two");

    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot.mkdirs();
        srcDir.mkdirs();
        fileInRoot.createNewFile();
        emptyDir.mkdir();
        firstLevelDir.mkdir();
        secondLevelDir.mkdir();
        fileOneInSecondLevelDir.createNewFile();
        fileTwoInSecondLevelDir.createNewFile();
        
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test
    public void unfilteredCopy() throws Exception {
        unfilteredCopy(CopyOp.COPY);
    }
    
    @Test
    public void unfilteredHardShallowCopy() throws Exception {
        unfilteredCopy(CopyOp.HARD_SHALLOW);
    }
    
    @Test
    public void unfilteredSymbolicShallowCopy() throws Exception {
        unfilteredCopy(CopyOp.SYMBOLIC_SHALLOW);
    }

    @Test
    public void filterFileCopy() throws Exception {
        DirectoryWalker dwalker = new DirectoryWalker(srcDir);
        IOFileFilter ffilter = new NotFileFilter(new PrefixFileFilter("on"));
        FileCopyVisitor fcpy = new FileCopyVisitor(srcDir, destDir, CopyOp.COPY, ffilter);
        dwalker.traverse(fcpy);
        
        checkCopy(new File[] { srcDir, fileInRoot, emptyDir, firstLevelDir, secondLevelDir, fileTwoInSecondLevelDir});
    }
    
    @Test
    public void filterDirectoryCopy() throws Exception {
        DirectoryWalker dwalker = new DirectoryWalker(srcDir);
        IOFileFilter ffilter = new PrefixFileFilter(new String[] {"src", "file", "empty", "1"});
        FileCopyVisitor fcpy = new FileCopyVisitor(srcDir, destDir, CopyOp.COPY, ffilter);
        dwalker.traverse(fcpy);
        
        checkCopy(new File[] { srcDir, fileInRoot, emptyDir, firstLevelDir});
    }
    
    @Test
    public void simpleCpTest() throws Exception {
        int nCopied = FileUtil.copyFiles(srcDir, destDir);
        
        assertEquals(7, nCopied);
        checkCopy(new File[] { srcDir, fileInRoot, emptyDir, firstLevelDir, secondLevelDir, fileOneInSecondLevelDir, fileTwoInSecondLevelDir} );
    }
    
    @Test
    public void cpFilteredHardlinkTest() throws Exception {
        IOFileFilter ffilter = new PrefixFileFilter(new String[] {"src", "file", "empty", "1"});
        int nCopied = FileUtil.copyFiles(srcDir, destDir, CopyOp.HARD_SHALLOW, ffilter);
        assertEquals(4, nCopied);
        
        checkCopy(new File[] { srcDir, fileInRoot, emptyDir, firstLevelDir});
    }
    
    @Test
    public void cpFile() throws Exception {
        destDir.mkdir();
        int nCopied = FileUtil.copyFiles(this.fileOneInSecondLevelDir, destDir);
        assertEquals(1, nCopied);
        File newFile = new File(destDir, fileOneInSecondLevelDir.getName());
        assertTrue(newFile.exists());
    }
    
    private void unfilteredCopy(CopyOp copy) throws IOException {
        DirectoryWalker dwalker = new DirectoryWalker(srcDir);
        FileCopyVisitor fcpy = new FileCopyVisitor(srcDir, destDir,copy);
        dwalker.traverse(fcpy);
        
        checkCopy(new File[] { srcDir, fileInRoot, emptyDir, firstLevelDir, secondLevelDir, fileOneInSecondLevelDir, fileTwoInSecondLevelDir} );
    }
    
    private void checkCopy(File[] originalFiles) throws IOException {
        File[] expectedFiles = expectedFiles(originalFiles);
        List<File> found = FileUtil.find(".*", destDir);
        Set<File> foundSet = new HashSet<File>(found);
        
        for (File expected : expectedFiles) {
            assertTrue(foundSet.contains(expected));
            foundSet.remove(expected);
        }
        
        assertEquals(0, foundSet.size());
    }
    
    private File[] expectedFiles(File[] originalFiles) {
        File[] expectedFiles = new File[originalFiles.length];
        
        int srcDirLen = srcDir.getAbsolutePath().length();
        for (int i=0; i < originalFiles.length; i++) {
            expectedFiles[i] = new File(destDir + File.separator + originalFiles[i].getAbsolutePath().substring(srcDirLen));
        }
        
        return expectedFiles;
    }

}
