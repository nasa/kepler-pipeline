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

package gov.nasa.kepler.dr.dispatch;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class FileWatcherTest extends JMockTest {
    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(FileWatcherTest.class);

    private static final String BUILD_TEST_PATH = "build/test";
    private static final String FILE_WATCHER_PATH = BUILD_TEST_PATH
        + "/FileWatcher";
    private static final String INCOMING_DIR = FILE_WATCHER_PATH + "/incoming/";
    private static final String PROCESSING_DIR = FILE_WATCHER_PATH
        + "/processing/";

    @Before
    public void setUp() throws IOException {
        FileUtil.cleanDir(BUILD_TEST_PATH);
        FileUtil.cleanDir(FILE_WATCHER_PATH);
        FileUtil.cleanDir(INCOMING_DIR);
        FileUtil.cleanDir(PROCESSING_DIR);

        System.setProperty(FileWatcher.INCOMING_DIR_PROP, INCOMING_DIR);
        System.setProperty(FileWatcher.PROCESSING_ROOT_DIR_PROP, PROCESSING_DIR);
        System.setProperty(FileWatcher.SLEEP_TIME_PROP, "1");
    }

    @After
    public void tearDown() {
        FileStoreClientFactory.reset();
    }

    @Test
    public void testDetection() throws Exception {
        log.info("testDetection()");

        TestHandler testHandler = new TestHandler();

        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        fileWatcher.addHandler(".sdnm", testHandler);
        fileWatcher.start();

        log.info("filewatcher started, sleeping for 2...");
        Thread.sleep(2000);

        log.info("creating .tara file (should be ignored)");
        createFile("foo.tara");

        log.info("sleeping for 2...");
        Thread.sleep(2000);

        log.info("creating .sdnm file (should be detected)");
        createFile("foo.sdnm");

        log.info("sleeping for 2...");
        Thread.sleep(2000);

        fileWatcher.shutdown();

        log.info("sleeping for 2...");
        Thread.sleep(2000);

        assertFalse("filewatcher thread did not die as requested",
            fileWatcher.isAlive());

        LinkedList<String> expectedHandledFiles = new LinkedList<String>();
        expectedHandledFiles.add("foo.sdnm");

        assertEquals("list of detected files does not match expected",
            expectedHandledFiles, testHandler.handledFiles);
    }

    @Test
    public void testProcessingException() throws Exception {

        TestHandler testHandler = new TestHandler();
        testHandler.throwException = true;

        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        fileWatcher.addHandler(".sdnm", testHandler);
        fileWatcher.start();

        log.info("filewatcher started, sleeping for 2...");
        Thread.sleep(2000);

        log.info("creating .sdnm file (should be detected)");
        createFile("foo.sdnm");

        log.info("sleeping for 2...");
        Thread.sleep(2000);

        fileWatcher.shutdown();

        log.info("sleeping for 2...");
        Thread.sleep(2000);

        assertFalse("filewatcher thread did not die as requested",
            fileWatcher.isAlive());

        LinkedList<String> expectedHandledFiles = new LinkedList<String>();

        assertEquals("list of detected files does not match expected",
            expectedHandledFiles, testHandler.handledFiles);
    }

    @Test(expected = DispatchException.class)
    public void testNullMonitoredDir() throws Exception {
        System.getProperties()
            .remove(FileWatcher.INCOMING_DIR_PROP);
        new HighPriorityFileWatcher();
    }

    @Test(expected = DispatchException.class)
    public void testNonDir() throws Exception {
        System.setProperty(FileWatcher.INCOMING_DIR_PROP, "build.xml");
        new HighPriorityFileWatcher();
    }

    @Test
    public void testClearHandlers() throws Exception {
        System.setProperty(FileWatcher.INCOMING_DIR_PROP, INCOMING_DIR);
        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        TestHandler testHandler = new TestHandler();
        fileWatcher.addHandler(".sdnm", testHandler);
        fileWatcher.clearHandlers();

        assertEquals("handlers HashSet not empty", 0, fileWatcher.getHandlers()
            .size());
    }

    @Test
    public void testRemoveHandler() throws Exception {
        System.setProperty(FileWatcher.INCOMING_DIR_PROP, INCOMING_DIR);
        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        TestHandler testHandler = new TestHandler();
        fileWatcher.addHandler(".sdnm", testHandler);
        fileWatcher.removeHandler(".sdnm");

        assertEquals("handlers HashSet not empty", 0, fileWatcher.getHandlers()
            .size());
    }

    @Test
    public void testChangeMonitoredDir() throws Exception {
        File monitoredDirFile1 = new File(INCOMING_DIR + "dir1");
        File monitoredDirFile2 = new File(INCOMING_DIR + "dir2");
        FileUtils.forceMkdir(monitoredDirFile1);
        FileUtils.forceMkdir(monitoredDirFile2);

        System.setProperty(FileWatcher.INCOMING_DIR_PROP,
            monitoredDirFile1.getAbsolutePath());
        FileWatcher fileWatcher = new HighPriorityFileWatcher();

        assertEquals("monitoredDir does not match",
            monitoredDirFile1.getAbsoluteFile(),
            fileWatcher.getIncomingDirectory()
                .getAbsoluteFile());

        fileWatcher.setIncomingDirectory(monitoredDirFile2);

        assertEquals("monitoredDir does not match",
            monitoredDirFile2.getAbsoluteFile(),
            fileWatcher.getIncomingDirectory()
                .getAbsoluteFile());
    }

    @Test
    public void testChangeSleepTime() throws Exception {
        System.setProperty(FileWatcher.INCOMING_DIR_PROP, INCOMING_DIR);
        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        int sleepTime = 42;
        fileWatcher.setSleepTimeSecs(sleepTime);

        assertEquals("sleepTime does not match", sleepTime,
            fileWatcher.getSleepTimeSecs());
    }

    @Test(expected = IllegalStateException.class)
    public void testIllegalChangeMonitoredDir() throws Exception {
        File monitoredDirFile1 = new File(INCOMING_DIR + "dir1");
        File monitoredDirFile2 = new File(INCOMING_DIR + "dir2");
        FileUtils.forceMkdir(monitoredDirFile1);
        FileUtils.forceMkdir(monitoredDirFile2);

        System.setProperty(FileWatcher.INCOMING_DIR_PROP,
            monitoredDirFile1.getAbsolutePath());
        FileWatcher fileWatcher = new HighPriorityFileWatcher();

        fileWatcher.start();
        fileWatcher.setIncomingDirectory(monitoredDirFile2);
    }

    @Test(expected = IllegalStateException.class)
    public void testIllegalChangeSleepTime() throws Exception {
        System.setProperty(FileWatcher.INCOMING_DIR_PROP, INCOMING_DIR);
        FileWatcher fileWatcher = new HighPriorityFileWatcher();
        int sleepTime = 42;

        fileWatcher.start();
        fileWatcher.setSleepTimeSecs(sleepTime);
    }

    private void createFile(String name) throws Exception {
        String path = INCOMING_DIR + name;
        File newFile = new File(path);
        if (!newFile.createNewFile()) {
            throw new Exception("failed to create file: " + path);
        }
    }

    private static class TestHandler implements FileWatcherHandler {
        public LinkedList<String> handledFiles = new LinkedList<String>();
        public boolean throwException = false;

        public void handleFile(File incomingDirectory,
            File processingDirectory, File file) {
            if (throwException) {
                throw new DispatchException("failed!");
            }
            handledFiles.add(file.getName());
        }

    }
}
