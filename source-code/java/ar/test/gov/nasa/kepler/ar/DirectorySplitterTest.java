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

package gov.nasa.kepler.ar;

import static org.junit.Assert.*;
import gov.nasa.kepler.ar.cli.DirectorySplitterCli;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.filefilter.DirectoryFileFilter;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class DirectorySplitterTest {

    private File testRoot;
    private File srcRoot;
    private File destRoot;
    
    @Before
    public void setup() throws Exception {
        testRoot = new File(Filenames.BUILD_TEST, "DirectorySplitterTest");
        FileUtil.mkdirs(testRoot);
        srcRoot = new File(testRoot, "src");
        FileUtil.mkdirs(srcRoot);
        destRoot = new File(testRoot, "dest");
        FileUtil.mkdirs(destRoot);
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(testRoot);
    }
    
    @Test
    public void directorySplitTest() throws Exception {
        Set<String> expectedFnames = initDirectorySplitTest();
        
        DirectorySplitter splitter = new DirectorySplitter();
        splitter.split(5, srcRoot, destRoot);
        
        assertNumberOfFiles(expectedFnames);
    }
    
    @Test
    public void directorySplitTestCli() throws Exception {
        Set<String> expectedFnames = initDirectorySplitTest();
        
        TestSystemProvider system = new TestSystemProvider(testRoot);
        DirectorySplitterCli cli = new DirectorySplitterCli(system);
        
        String[] cmd = String.format("-s %s -d %s -x 5", srcRoot.toString(), destRoot.toString()).split("\\s+");
        cli.parseOptions(cmd);
        cli.execute();
        
        assertNumberOfFiles(expectedFnames);
        
    }

    private Set<String> initDirectorySplitTest() throws IOException {
        Set<String> expectedFnames = new HashSet<String>();
        for (int i=0; i < 1000; i++) {
            int suffix = i % 3;
            File testFile = new File(srcRoot, "kplr" + i + "_" + suffix + ".fits");
            assertTrue(testFile.createNewFile());
            expectedFnames.add(testFile.getName());
        }
        return expectedFnames;
    }

    private void assertNumberOfFiles(Set<String> expectedFnames)
        throws IOException {
        List<File> found = FileUtil.find(".*\\.fits", destRoot);
        assertEquals(1000, found.size());
        Set<String> actualFnames = new HashSet<String>();
        for (File f : found) {
            actualFnames.add(f.getName());
        }
        assertEquals(expectedFnames, actualFnames);
    }
    
    @Test
    public void directorySplitTestKeepPrefixesTogether() throws Exception {
        Set<String> expectedFnames = new HashSet<String>();
        for (int i=0; i < 1000; i++) {
            int prefix = i % 4;
            File testFile = new File(srcRoot, "kplr" + prefix + "_" + i + ".fits");
            assertTrue(testFile.createNewFile());
            expectedFnames.add(testFile.getName());
        }
        
        DirectorySplitter splitter = new DirectorySplitter();
        splitter.split(5, srcRoot, destRoot);

        assertNumberOfFiles(expectedFnames);
        
        assertEquals(5, countDirectories());
    }
    
    private int countDirectories() throws Exception {
        List<File> directories = FileUtil.find(DirectoryFileFilter.INSTANCE, destRoot);
        return directories.size();
    }
    
    /**
     * Make sure existing directories get remapped into destination directory.
     * 
     * @throws Exception
     */
    @Test
    public void remapSubDirectoies() throws Exception {
        Set<File> expectedFiles = new HashSet<File>();
        expectedFiles.add(destRoot);
        
        for (int i=0; i < 10; i++) {
            File subDir = new File(srcRoot, "subdir-" + i);
            FileUtil.mkdirs(subDir);
            int subdirIndex = (i < 5) ? 0 : 5;
            File newRoot = new File(destRoot, "subdir-" + Integer.toString(subdirIndex));
            File destSubDir = new File(newRoot, subDir.getName());
            expectedFiles.add(newRoot);
            expectedFiles.add(destSubDir);
         }  
         
        DirectorySplitter splitter = new DirectorySplitter();
        splitter.split(5, srcRoot, destRoot);
        List<File> foundFiles = FileUtil.find(".*", destRoot);
        for (File f : foundFiles) {
            assertTrue("expectedFiles does not contain file \"" + f + "\".", 
                expectedFiles.contains(f));
            assertTrue(f.isDirectory());
            expectedFiles.remove(f);
        }
        assertEquals(0, expectedFiles.size());
    }
}
