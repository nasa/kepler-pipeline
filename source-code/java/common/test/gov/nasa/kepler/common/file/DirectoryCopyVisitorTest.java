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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.CopyOp;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileCopyVisitor;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.FileVisitor;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.io.RegexFileFilter;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.io.filefilter.PrefixFileFilter;
import org.apache.commons.io.filefilter.SuffixFileFilter;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Forrest Girouard
 * @author Sean McCauliff
 * 
 */
public class DirectoryCopyVisitorTest {

    private static final Log log = LogFactory.getLog(DirectoryCopyVisitorTest.class);

    private static final int CHILDREN = 1;
    private static final int SIBLINGS = 2;
    private static final int DEPTH = 3;
    private static final String PREFIX_RE = "(.*/|)2-0.*";
    private static final String SUFFIX_RE = ".*2-1($|/.*)";

    private File testRoot = new File(Filenames.BUILD_TEST,
        "DirectoryCopyVisitorTest.test");
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
        if (testRoot.exists()) {
            FileUtil.removeAll(testRoot);
        }
        FileUtil.mkdirs(testRoot);
        FileUtil.mkdirs(srcDir);
        fileInRoot.createNewFile();
        FileUtil.mkdirs(emptyDir);
        FileUtil.mkdirs(firstLevelDir);
        FileUtil.mkdirs(secondLevelDir);
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
    public void filterDirectoryCopyEmpty() throws Exception {
        DirectoryWalker dwalker = new DirectoryWalker(srcDir);
        IOFileFilter ffilter = new SuffixFileFilter("-dir");
        DirectoryCopyVisitor fcpy = new DirectoryCopyVisitor(srcDir, destDir,
            ffilter);
        dwalker.traverse(fcpy);

        checkCopy(new File[] { srcDir, emptyDir });
    }

    @Test
    public void filterDirectoryCopy1() throws Exception {
        DirectoryWalker dwalker = new DirectoryWalker(srcDir);
        IOFileFilter ffilter = new PrefixFileFilter("1");
        DirectoryCopyVisitor fcpy = new DirectoryCopyVisitor(srcDir, destDir,
            ffilter);
        dwalker.traverse(fcpy);

        checkCopy(new File[] { srcDir, firstLevelDir, secondLevelDir,
            fileOneInSecondLevelDir, fileTwoInSecondLevelDir });
    }
    
    @Test 
    public void filterFileCopy() throws Exception {

        if (srcDir.exists()) {
            FileUtil.removeAll(srcDir);
        }
        srcDir.mkdirs();
        log.info("Create directories: children=" + CHILDREN + ", siblings="
            + SIBLINGS + ", depth=" + DEPTH);
        int filesCreated = createDirectories(srcDir, CHILDREN, SIBLINGS, DEPTH);
        log.info("Files created: " + filesCreated);

        FileFilter fileCopyFindFilter = new RegexFileFilter(new String[] {
            PREFIX_RE, SUFFIX_RE }, FileFilterUtils.directoryFileFilter());
        int expectedFileCopyFileCount = FileUtil.find(fileCopyFindFilter,
            srcDir)
            .size();
        log.info("Expected file copy count: " + expectedFileCopyFileCount);
        assertTrue(expectedFileCopyFileCount > 0);

        if (destDir.exists()) {
            FileUtil.removeAll(destDir);
        }
        destDir.mkdirs();

        log.info("FileCopyVisitor ...");
        IOFileFilter fileCopyFilter = new RegexFileFilter(new String[] {
            PREFIX_RE, SUFFIX_RE }, FileFilterUtils.directoryFileFilter());
        FileCopyVisitor fileCopy = new FileCopyVisitor(srcDir, destDir,
            CopyOp.COPY, fileCopyFilter);
        DirectoryWalker walker = new DirectoryWalker(srcDir);
        IntervalMetric fileCopyMetric = filterCopy(walker, fileCopy);
        int fileCopyCount = FileUtil.find(fileCopyFindFilter, destDir)
            .size();
        log.info("FileCopyVisitor: filesCopied=" + fileCopy.filesCopies() + ": "
            + fileCopyMetric.getLogString());
        log.info("Actual file copy count: " + fileCopyCount);

        assertEquals(expectedFileCopyFileCount, fileCopyCount);
    }

    @Test
    public void filterDirectoryCopy() throws Exception {

        if (srcDir.exists()) {
            FileUtil.removeAll(srcDir);
        }
        srcDir.mkdirs();
        log.info("Create directories: children=" + CHILDREN + ", siblings="
            + SIBLINGS + ", depth=" + DEPTH);
        int filesCreated = createDirectories(srcDir, CHILDREN, SIBLINGS, DEPTH);
        log.info("Files created: " + filesCreated);
        
        FileFilter directoryCopyFindFilter = new RegexFileFilter(new String[] {
            PREFIX_RE, SUFFIX_RE });
        int expectedDirectoryCopyFileCount = FileUtil.find(
            directoryCopyFindFilter, srcDir)
            .size();
        log.info("Expected directory copy count: "
            + expectedDirectoryCopyFileCount);
        assertTrue(expectedDirectoryCopyFileCount > 0);

        if (destDir.exists()) {
            FileUtil.removeAll(destDir);
        }
        destDir.mkdirs();

        log.info("DirectoryCopyVisitor ...");
        IOFileFilter directoryCopyFilter = new RegexFileFilter(new String[] {
            PREFIX_RE, SUFFIX_RE });
        FileCopyVisitor directoryCopy = new DirectoryCopyVisitor(srcDir,
            destDir, directoryCopyFilter);
        DirectoryCopyWalker copyWalker = new DirectoryCopyWalker(srcDir);
        IntervalMetric directoryCopyMetric = filterCopy(copyWalker,
            directoryCopy);
        int directoryCopyCount = FileUtil.find(directoryCopyFindFilter, destDir)
            .size();
        log.info("DirectoryCopyVisitor: directoriesCopied="
            + directoryCopy.filesCopies() + ": "
            + directoryCopyMetric.getLogString());
        log.info("Actual directory copy count: " + directoryCopyCount);

        assertEquals(expectedDirectoryCopyFileCount, directoryCopyCount);
    }

    private IntervalMetric filterCopy(DirectoryWalker walker,
        FileVisitor visitor) throws IOException {
        IntervalMetric m = null;
        
        IntervalMetricKey metricKey = IntervalMetric.start();
        try {
            walker.traverse(visitor);
        } finally {
            m = IntervalMetric.stop("filterCopyPerformance: " + visitor, metricKey);
        }
        return m;
    }

    private void checkCopy(File[] originalFiles) throws IOException {
        File[] expectedFiles = expectedFiles(originalFiles);
        List<File> found = FileUtil.find(".*", destDir);
        Set<File> foundSet = new HashSet<File>(found);

        for (File expected : expectedFiles) {
            assertTrue(foundSet.contains(expected));
            foundSet.remove(expected);
        }

        String filesThatShouldNotBeThere = StringUtils.join(foundSet.iterator(), ',');
        assertEquals("Files that should not be there: " + filesThatShouldNotBeThere,
            0, foundSet.size());
    }

    private File[] expectedFiles(File[] originalFiles) {
        File[] expectedFiles = new File[originalFiles.length];

        int srcDirLen = srcDir.getAbsolutePath()
            .length();
        for (int i = 0; i < originalFiles.length; i++) {
            expectedFiles[i] = new File(destDir + File.separator
                + originalFiles[i].getAbsolutePath()
                    .substring(srcDirLen));
        }

        return expectedFiles;
    }

    private int createDirectories(File parent, int children, int siblings,
        int depth) throws IOException {

        int fileCount = 0;
        if (depth == 0) {
            fileCount = createFiles(parent, children * children * 10);
        } else {
            for (int i = 0; i < children; i++) {
                File child = new File(parent, depth + "-" + i);
                child.mkdir();
                fileCount += createDirectories(child, children * siblings,
                    siblings, depth - 1);
            }
        }
        return fileCount;
    }

    private int createFiles(File parent, int children) throws IOException {

        for (int i = 0; i < children; i++) {
            File.createTempFile("test", ".file", parent);
        }
        return children;
    }
}
