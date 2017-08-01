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

package gov.nasa.kepler.mc.file;

import java.io.File;
import java.io.IOException;

import junit.framework.AssertionFailedError;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Unit tests for the {@code FileAssert} class.
 * 
 * @author Forrest Girouard
 * 
 */
public class FileAssertTest {

    private static final String OUTPUT_DIRECTORY = "build/test/FileAssert";
    private static final String TEST_STRING = "testing ... one, two, three";

    private File outputDirectory;

    @BeforeClass
    public static void initialize() {
    }

    @Before
    public void setUp() throws IOException {

        outputDirectory = new File(OUTPUT_DIRECTORY);
        FileUtils.deleteDirectory(outputDirectory);
        FileUtils.forceMkdir(outputDirectory);
    }

    @After
    public void tearDown() throws IOException {

        FileUtils.deleteDirectory(outputDirectory);
    }

    @Test(expected = NullPointerException.class)
    public void expectedFileNull() {

        FileAssert.assertEquals(null, outputDirectory);
    }

    @Test(expected = NullPointerException.class)
    public void actualFileNull() {

        FileAssert.assertEquals(outputDirectory, null);
    }

    @Test(expected = AssertionFailedError.class)
    public void mixedFileTypes() throws IOException {

        File file = new File(outputDirectory, "test.txt");
        file.createNewFile();
        FileAssert.assertEquals(outputDirectory, file);
    }

    @Test(expected = AssertionFailedError.class)
    public void mixedFileTypes2() throws IOException {

        File file = new File(outputDirectory, "test.txt");
        file.createNewFile();
        FileAssert.assertEquals(file, outputDirectory);
    }

    @Test(expected = AssertionFailedError.class)
    public void expectedNotDirectory() throws IOException {

        File file = new File(outputDirectory, "test.txt");
        file.createNewFile();
        FileAssert.assertDirectoryEquals(file, outputDirectory);
    }

    @Test(expected = AssertionFailedError.class)
    public void actualNotDirectory() throws IOException {

        File file = new File(outputDirectory, "test.txt");
        file.createNewFile();
        FileAssert.assertDirectoryEquals(outputDirectory, file);
    }

    @Test
    public void filesEquals() throws IOException {

        File file1 = new File(outputDirectory, "test1.txt");
        File file2 = new File(outputDirectory, "test2.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        FileAssert.assertEquals(file1, file2);
    }

    @Test(expected = AssertionFailedError.class)
    public void filesEqualsFalse() throws IOException {

        File file1 = new File(outputDirectory, "test1.txt");
        File file2 = new File(outputDirectory, "test2.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING + "\n" + TEST_STRING);
        FileAssert.assertEquals(file1, file2);
    }

    @Test(expected = AssertionFailedError.class)
    public void actualEmptyEqualsFalse() throws IOException {
        File file1 = new File(outputDirectory, "test1.txt");
        File file2 = new File(outputDirectory, "test2.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileAssert.assertEquals(file1, file2);
    }

    @Test(expected = AssertionFailedError.class)
    public void expectedEmptyEqualsFalse() throws IOException {
        File file1 = new File(outputDirectory, "test1.txt");
        File file2 = new File(outputDirectory, "test2.txt");
        FileUtils.writeStringToFile(file2, TEST_STRING);
        FileAssert.assertEquals(file1, file2);
    }

    @Test
    public void directoryEquals() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = AssertionFailedError.class)
    public void directoryEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING + "\n" + TEST_STRING);
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test
    public void subdirEquals() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        file1 = new File(dir1, "test");
        file2 = new File(dir2, "test");
        file1.mkdir();
        file2.mkdir();
        file1 = new File(file1, "test.txt");
        file2 = new File(file2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = AssertionFailedError.class)
    public void subdirEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        file1 = new File(dir1, "test");
        file2 = new File(dir2, "test");
        file1.mkdir();
        file2.mkdir();
        file1 = new File(file1, "test.txt");
        file2 = new File(file2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING + "\n" + TEST_STRING);
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = AssertionFailedError.class)
    public void subdirSubdirEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        file1 = new File(dir1, "test");
        file2 = new File(dir2, "test");
        file1.mkdir();
        file2.mkdir();
        file1 = new File(file1, "test.txt");
        file2 = new File(file2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        file1 = new File(dir1, "test1");
        file2 = new File(dir2, "test2");
        file1.mkdir();
        file2.mkdir();
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = AssertionFailedError.class)
    public void missingSubdirEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        File subdir1 = new File(dir1, "test");
        File subdir2 = new File(dir2, "test");
        subdir1.mkdir();
        subdir2.mkdir();
        file1 = new File(subdir1, "test.txt");
        file2 = new File(subdir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        new File(subdir1, "test1").mkdir();
        new File(subdir2, "test1").mkdir();
        new File(subdir1, "missing").mkdir();
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = AssertionFailedError.class)
    public void unexpectedSubdirEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        File subdir1 = new File(dir1, "test");
        File subdir2 = new File(dir2, "test");
        subdir1.mkdir();
        subdir2.mkdir();
        new File(subdir2, "unexpected").mkdir();
        file1 = new File(subdir1, "test.txt");
        file2 = new File(subdir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        FileUtils.writeStringToFile(file2, TEST_STRING);
        FileAssert.assertDirectoryEquals(dir1, dir2);
    }

    @Test(expected = NullPointerException.class)
    public void nullRegexs() {

        FileAssert.assertEquals(new File(outputDirectory, "test1"), new File(
            outputDirectory, "test2"), (String[]) null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void emptyRegexs() {

        FileAssert.assertEquals(new File(outputDirectory, "test1"), new File(
            outputDirectory, "test2"), new String[0]);
    }

    @Test
    public void regexEquals() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        String testString = TEST_STRING.replaceFirst("one,", "ten,");
        FileUtils.writeStringToFile(file2, testString);
        FileAssert.assertEquals(dir1, dir2,
            new String[] { "^(.*)(?:\\.\\.\\. [onet]{3},)(.*)$" });
    }

    @Test
    public void regexsEquals() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        String testString = TEST_STRING.replaceFirst("one,", "ten,");
        testString.replaceFirst("three", "tree");
        FileUtils.writeStringToFile(file2, testString);
        FileAssert.assertEquals(dir1, dir2,
            new String[] { "^(.*)(?:\\.\\.\\. [onet]{3},)(.*)$",
                "^(.*)(?: [th]{1,2}ree)(.*)$" });
    }

    @Test(expected = AssertionFailedError.class)
    public void regexsEqualsFalse() throws IOException {

        File dir1 = new File(outputDirectory, "test1");
        File dir2 = new File(outputDirectory, "test2");
        dir1.mkdir();
        dir2.mkdir();
        File file1 = new File(dir1, "test.txt");
        File file2 = new File(dir2, "test.txt");
        FileUtils.writeStringToFile(file1, TEST_STRING);
        String testString = TEST_STRING.replaceFirst("one,", "ten,");
        testString = testString.replaceFirst("three", "trek");
        FileUtils.writeStringToFile(file2, testString);
        FileAssert.assertEquals(dir1, dir2,
            new String[] { "^(.*)(?:\\.\\.\\. [onet]{3},)(.*)$",
                "^(.*)(?: [th]{1,2}ree)(.*)$" });
    }
}
