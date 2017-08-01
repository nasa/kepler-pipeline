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

package gov.nasa.kepler.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Test the KicIngester class.
 * 
 * @author Bill Wohler
 */
public class KicIngesterTest {

    private static final String SCP_DATA_DIR = "sample_data_files/";
    private static final String SCP_FILENAME_PATTERN = "d[0-9]+.mrg";
    private static final String TMP_DIR_BASE = Filenames.BUILD_TMP
        + "/IngestKicTest";
    private static final String RANDOM_NON_SCP_DIRECTORY = "/etc/";

    private static DatabaseService dbService;
    private KicCrud kicCrud;

    /**
     * Gets the DatabaseService singleton.
     */
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
    }

    /**
     * Removes the temporary directory that we create in createEmptyDirectory.
     */
    @AfterClass
    public static void cleanup() throws IOException {
        File directory = new File(TMP_DIR_BASE);
        File dirname = directory.getParentFile();
        final String basename = directory.getName() + "[0-9]+";
        File[] files = dirname.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.matches(basename);
            }
        });
        for (File file : files) {
            if (file.delete() == false) {
                throw new IOException("Can't delete " + file);
            }
        }
    }

    /**
     * Creates a database for use by the tests.
     */
    @Before
    public void createDatabase() {
        dbService.getDdlInitializer()
            .initDB();
        kicCrud = new KicCrud();
    }

    /**
     * Destroy the database entirely. This ensures that our database state is
     * identical at the start of each test.
     */
    @After
    public void destroyDatabase() {
        dbService.closeCurrentSession();
        dbService.getDdlInitializer()
            .cleanDB();
    }

    /**
     * Test our ability to handle directories that do not exist.
     */
    @Test(expected = PipelineException.class)
    public void testNonExistentDirectory() throws FileNotFoundException {

        KicIngester.ingestScpFiles(KicIngester.getScpFiles(
            findNonExistentDirectory(), SCP_FILENAME_PATTERN));
    }

    /**
     * Test our ability to handle empty directories.
     */
    @Test(expected = PipelineException.class)
    public void testEmptyDirectory() throws IOException {
        KicIngester.ingestScpFiles(KicIngester.getScpFiles(
            createEmptyDirectory(), SCP_FILENAME_PATTERN));
    }

    /**
     * Test our ability to recover from data files that have been overwritten by
     * text.
     */
    @Test
    public void testEtcMotd() {
        try {
            KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), "etc-motd"));
            fail("Expected IngestScpException");
        } catch (IngestScpException e) {
            assertEquals("Errors", 8, e.getErrorCount());
            assertEquals("Files", 1, e.getFileCount());
            assertEquals("Encountered 8 errors in 1 file", e.getMessage());
        } catch (Exception e) {
            fail("Expected IngestScpException");
        }
    }

    /**
     * Test our ability to recover from random files.
     */
    @Test
    public void testLineNoise() {
        try {
            KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), "line-noise"));
            fail("Expected IngestScpException");
        } catch (IngestScpException e) {
            assertEquals("Errors", 10, e.getErrorCount());
            assertEquals("Files", 1, e.getFileCount());
            assertEquals("Encountered 10 errors in 1 file", e.getMessage());
        } catch (Exception e) {
            fail("Expected IngestScpException");
        }
    }

    /**
     * Test our ability to handle fields that violate database constraints.
     */
    @Test
    public void testBadScpData() {
        try {
            KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), "bad-data"));
            fail("Expected IngestScpException");
        } catch (IngestScpException e) {
            assertEquals("Errors", 7, e.getErrorCount());
            assertEquals("Files", 1, e.getFileCount());
            assertEquals("Encountered 7 errors in 1 file", e.getMessage());
        } catch (Exception e) {
            fail("Expected IngestScpException");
        }
    }

    /**
     * Test our ability to handle duplicate Kepler IDs.
     */
    @Test
    public void testDupKeplerId() {
        try {
            KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), "dup-kepler-id"));
            fail("Expected IngestScpException");
        } catch (IngestScpException e) {
            assertEquals("Errors", 1, e.getErrorCount());
            assertEquals("Files", 1, e.getFileCount());
            assertEquals("Encountered 1 error in 1 file", e.getMessage());
        } catch (Exception e) {
            fail("Expected IngestScpException");
        }
    }

    /**
     * Tests our ability to handle a directory that contains files other than
     * the ones we're looking for.
     */
    @Test(expected = PipelineException.class)
    public void testPopulatedDirectoryWithoutKicData() {
        KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
            RANDOM_NON_SCP_DIRECTORY), SCP_FILENAME_PATTERN));
    }

    /**
     * Tests our ability to read legitimate data files.
     */
    @Test
    public void testIngestKic() {
        Timer timer = new Timer();
        IngestScpState state = new IngestScpState();
        TimerTask timerTask = new KicIngester.IngestScpStateDisplayer(state);
        timer.scheduleAtFixedRate(timerTask, 100, 100);
        KicIngester.ingestScpFiles(KicIngester.getScpFiles(new File(
            SCP_DATA_DIR), SCP_FILENAME_PATTERN), state);
        timerTask.cancel();

        int data[][] = { { 94, 293451669, 2236424 },
            { 130, 1006572828, 2236433 }, { 148, 1006572873, 2236434 },
            { 153, 1122448811, 2238057 }, { 160, 1122448622, 2238050 },
            { 170, 1122431002, 2238041 } };
        final int KEPLER_ID = 0;
        final int TMID = 1;
        final int SCP_KEY = 2;

        for (int[] element : data) {
            Kic kic = kicCrud.retrieveKic(element[KEPLER_ID]);
            assertEquals(element[KEPLER_ID], kic.getKeplerId());
            assertEquals(element[TMID], (int) kic.getTwoMassId());
            assertEquals(element[SCP_KEY], (int) kic.getScpId());
        }
    }

    /**
     * Tests the manifest validation.
     */
    @Test
    public void testValidateManifest() {
        KicIngester.validateManifest(new File(SCP_DATA_DIR), "Manifest",
            KicIngester.getScpFiles(new File(SCP_DATA_DIR),
                SCP_FILENAME_PATTERN));
    }

    /**
     * Tests the manifest validation if the manifest contains files that don't
     * exist in the directory.
     */
    @Test(expected = PipelineException.class)
    public void testValidateManifestWithMissingFiles() {
        KicIngester.validateManifest(new File(SCP_DATA_DIR),
            "Manifest.missing-files", KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), SCP_FILENAME_PATTERN));
    }

    /**
     * Tests the manifest validation if the directory contains files that aren't
     * in the manifest.
     */
    @Test(expected = PipelineException.class)
    public void testValidateManifestWithMissingEntries() {
        KicIngester.validateManifest(new File(SCP_DATA_DIR),
            "Manifest.missing-entries", KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), SCP_FILENAME_PATTERN));
    }

    /**
     * Tests the manifest validation if one or more files are munged.
     */
    @Test(expected = PipelineException.class)
    public void testValidateManifestWithMungedFiles() {
        KicIngester.validateManifest(new File(SCP_DATA_DIR),
            "Manifest.munged-files", KicIngester.getScpFiles(new File(
                SCP_DATA_DIR), SCP_FILENAME_PATTERN));
    }

    /**
     * Find the name of a directory that does not exist.
     * 
     * @return a directory name
     * @throws FileNotFoundException if TMP_DIR_BASE contains a directory that
     * does not exist
     */
    private File findNonExistentDirectory() throws FileNotFoundException {
        final int MAX_TRIES = 10000;
        for (int i = 0; i < MAX_TRIES; i++) {
            File dir = new File(TMP_DIR_BASE + i);
            if (!dir.exists()) {
                return dir;
            }
        }

        throw new FileNotFoundException("Directories from " + TMP_DIR_BASE
            + "/0 to " + TMP_DIR_BASE + "/" + MAX_TRIES + " already exist");
    }

    /**
     * Creates an empty directory.
     * 
     * @return a file object for the new directory
     * @throws IOException if TMP_DIR_BASE contains a directory that does not
     * exist, or if the directory cannot be created
     */
    private File createEmptyDirectory() throws IOException {
        File emptyDirectory = findNonExistentDirectory();
        if (emptyDirectory.mkdir() == false) {
            throw new IOException("Can't create " + emptyDirectory);
        }

        return emptyDirectory;
    }
}
