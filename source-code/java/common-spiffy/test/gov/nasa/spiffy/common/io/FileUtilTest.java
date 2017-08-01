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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link FileUtil} class.
 * 
 * @author Bill Wohler
 */
public class FileUtilTest {

    protected File testDir;
    protected File archiveDir;

    @Before
    public void createTarRootDirectory() throws IOException {
        testDir = new File(Filenames.BUILD_TEST);
        testDir.mkdir();
        archiveDir = new File(Filenames.BUILD_TEST, "testTar");
        FileUtils.deleteDirectory(archiveDir);
        archiveDir.mkdir();
    }

    @Test
    public void testTar() throws IOException {
        List<String> filenames = Arrays.asList("foo", "bar", "baz");
        testTarIntern(filenames);
    }

    @Test
    public void testTarWithLongFilenames() throws IOException {
        List<String> filenames = Arrays.asList("a-very-long-filename-with-more-than-100-characters-"
            + "012345678901234567890123456789012345678901234567890123456789");
        testTarIntern(filenames);
    }

    @Test
    public void testTarWithLongDirectoryNames() throws IOException {
        List<String> filenames = Arrays.asList("a/very/long/path/with/more/than/100/characters/"
            + "012345678901234567890123456789012345678901234567890123456789");
        testTarIntern(filenames);
    }

    private void testTarIntern(List<String> filenames)
        throws FileNotFoundException, IOException {

        List<PermissionFile> files = new ArrayList<PermissionFile>(
            filenames.size());
        for (String filename : filenames) {
            files.add(new PermissionFile(filename, -1));
        }
        testTarWithoutCompression(files);
        testTarWithCompression(files);
    }

    @Test
    public void testTarPermissions() throws FileNotFoundException, IOException {
        // Can't tar files we can't read!
        // Also, for now, tar can't handle modes like 644 or 755. These get
        // mapped to 666 and 777, so don't test them (yet).
        ArrayList<PermissionFile> files = newArrayList(new PermissionFile(
            "file-444", 0444), new PermissionFile("file-666", 0666),
            new PermissionFile("file-555", 0555), new PermissionFile(
                "file-777", 0777));
        testTarWithoutCompression(files);
        testTarWithCompression(files);
    }

    private void testTarWithoutCompression(List<PermissionFile> files)
        throws IOException, FileNotFoundException {

        FileUtils.deleteDirectory(archiveDir);
        createHierarchy(files);
        File archive = FileUtil.createArchive(archiveDir);
        FileUtils.deleteDirectory(archiveDir);
        FileUtil.extractArchive(testDir, archive);
        checkHierarchy(files);
    }

    private void testTarWithCompression(List<PermissionFile> files)
        throws IOException, FileNotFoundException {

        FileUtils.deleteDirectory(archiveDir);
        createHierarchy(files);
        File archive = FileUtil.createCompressedArchive(archiveDir);
        FileUtils.deleteDirectory(archiveDir);
        FileUtil.extractCompressedArchive(testDir, archive);
        checkHierarchy(files);
    }

    private void createHierarchy(List<PermissionFile> files) throws IOException {
        for (PermissionFile permissionFile : files) {
            File file = new File(archiveDir, permissionFile.getFilename());
            File directory = file.getParentFile();
            if (directory != null && !directory.exists()) {
                FileUtil.mkdirs(directory);
            }
            Writer w = new FileWriter(file);
            w.write(permissionFile.getFilename());
            w.close();
            if (permissionFile.getMode() != -1) {
                FileUtil.setMode(file, permissionFile.getMode());
            }
        }
    }

    private void checkHierarchy(List<PermissionFile> files)
        throws FileNotFoundException, IOException {
        char[] buffer = new char[1024];
        for (PermissionFile permissionFile : files) {
            File file = new File(archiveDir, permissionFile.getFilename());
            Reader r = new FileReader(file);
            int length = r.read(buffer);
            r.close();
            assertEquals(permissionFile.getFilename(),
                new String(buffer).substring(0, length));
            if (permissionFile.getMode() != -1) {
                assertEquals(permissionFile.getMode(), FileUtil.getMode(file));
            }
        }
    }

    @Test(expected = FileNotFoundException.class)
    public void testNullOutputDir() throws IOException {
        FileUtil.extractCompressedArchive(null, new File("foo"));
    }

    @Test(expected = NullPointerException.class)
    public void testNullTar() throws IOException {
        FileUtil.extractCompressedArchive(new File("."), (File) null);
    }

    @Test(expected = IOException.class)
    public void testInvalidTarFile() throws IOException {
        FileUtil.extractCompressedArchive(new File("."), new File("foo"));
    }

    @Test(expected = IOException.class)
    public void testInvalidOutputDir() throws IOException {
        File file = new File(Filenames.BUILD_TEST, "testFile");
        file.getParentFile()
            .mkdir();

        Writer w = new FileWriter(file);
        w.write(file.getName());
        w.close();

        FileUtil.extractCompressedArchive(file, new File("foo"));
    }

    @Test
    public void testGetMode() throws IOException {
        File file = new File(Filenames.BUILD_TEST, "testFile");
        FileUtils.touch(file);

        FileUtil.setMode(file, 0000);
        assertEquals(0000, FileUtil.getMode(file));
        FileUtil.setMode(file, 0111);
        assertEquals(0111, FileUtil.getMode(file));
        FileUtil.setMode(file, 0222);
        assertEquals(0222, FileUtil.getMode(file));
        FileUtil.setMode(file, 0444);
        assertEquals(0444, FileUtil.getMode(file));

        FileUtil.setMode(file, 0100);
        assertEquals(0111, FileUtil.getMode(file));
        FileUtil.setMode(file, 0200);
        assertEquals(0222, FileUtil.getMode(file));
        FileUtil.setMode(file, 0400);
        assertEquals(0444, FileUtil.getMode(file));

        FileUtil.setMode(file, 0110);
        assertEquals(0111, FileUtil.getMode(file));
        FileUtil.setMode(file, 0220);
        assertEquals(0222, FileUtil.getMode(file));
        FileUtil.setMode(file, 0440);
        assertEquals(0444, FileUtil.getMode(file));

        FileUtil.setMode(file, 0644);
        assertEquals(0666, FileUtil.getMode(file));
        FileUtil.setMode(file, 0664);
        assertEquals(0666, FileUtil.getMode(file));
        FileUtil.setMode(file, 0755);
        assertEquals(0777, FileUtil.getMode(file));
        FileUtil.setMode(file, 0775);
        assertEquals(0777, FileUtil.getMode(file));

        FileUtil.setMode(file, 0777);
        assertEquals(0777, FileUtil.getMode(file));
    }

    @Test
    public void testSetMode() throws IOException {
        File file = new File(Filenames.BUILD_TEST, "testFile");
        FileUtils.touch(file);

        FileUtil.setMode(file, 0000);
        testMode(file, false, false, false);
        FileUtil.setMode(file, 0111);
        testMode(file, false, false, true);
        FileUtil.setMode(file, 0222);
        testMode(file, false, true, false);
        FileUtil.setMode(file, 0444);
        testMode(file, true, false, false);

        FileUtil.setMode(file, 0100);
        testMode(file, false, false, true);
        FileUtil.setMode(file, 0200);
        testMode(file, false, true, false);
        FileUtil.setMode(file, 0400);
        testMode(file, true, false, false);

        FileUtil.setMode(file, 0110);
        testMode(file, false, false, true);
        FileUtil.setMode(file, 0220);
        testMode(file, false, true, false);
        FileUtil.setMode(file, 0440);
        testMode(file, true, false, false);

        FileUtil.setMode(file, 0644);
        testMode(file, true, true, false);
        FileUtil.setMode(file, 0664);
        testMode(file, true, true, false);
        FileUtil.setMode(file, 0755);
        testMode(file, true, true, true);
        FileUtil.setMode(file, 0775);
        testMode(file, true, true, true);

        FileUtil.setMode(file, 0777);
        testMode(file, true, true, true);
    }

    private void testMode(File file, boolean canRead, boolean canWrite,
        boolean canExecute) {
        assertEquals("canRead", canRead, file.canRead());
        assertEquals("canWrite", canWrite, file.canWrite());
        assertEquals("canExecute", canExecute, file.canExecute());
    }

    protected static class PermissionFile {
        private String filename;
        private int mode;

        public PermissionFile(String filename, int mode) {
            this.filename = filename;
            this.mode = mode;
        }

        public String getFilename() {
            return filename;
        }

        public int getMode() {
            return mode;
        }
    }
}
