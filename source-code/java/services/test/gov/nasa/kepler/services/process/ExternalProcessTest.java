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

package gov.nasa.kepler.services.process;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import gov.nasa.kepler.services.process.ExternalProcess;

import java.io.File;
import java.io.StringWriter;
import java.util.LinkedList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

public class ExternalProcessTest {
    private static final Log log = LogFactory.getLog(ExternalProcessTest.class);

    @Test
    public void testNormalSyncRun() throws Exception {
        log.info("testNormalSyncRun() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 10000);

        assertEquals("return code from external process,", 0, rc);

        log.info("testNormalSyncRun() - end");
    }

    @Test
    public void testNormalAsyncRun() throws Exception {
        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("2"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        log.info("starting async process");

        int rc = p.run(false, 5000);

        assertEquals("return code from run,", 0, rc);

        log.info("waiting for async process to finish");

        long start = System.currentTimeMillis();
        while (p.isProcessAlive()) {
            long elapsed = System.currentTimeMillis() - start;
            if (elapsed > 10000) {
                assertFalse("async process did not finish or timeout after 10 secs., bailing", true);
            }
        }

        log.info("DONE waiting for async process to finish");

        int asyncRetcode = p.getAsyncRetcode();
        assertEquals("return code from async process after finish,", 0, asyncRetcode);
    }

    @Test
    public void testTimeout() throws Exception {
        log.info("testTimeout() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("5"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 2000);

        assertEquals("rc", -1, rc);

        assertEquals("timeout flag,", true, p.timedOut());

        log.info("testTimeout() - end");
    }

    @Test
    public void testExeFail() throws Exception {
        log.info("testExeFail() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("1"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 10000);

        assertTrue("return code from external process not zero", rc != 0);

        log.info("testExeFail() - end");
    }

    @Test
    public void testExeFailWithOneRetry() throws Exception {
        log.info("testExeFailWithOneRetry() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("1"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);
        p.setRetryCount(1);
        p.setRetrySleepIntervalMillis(500);
        
        int rc = p.run(true, 10000);

        assertTrue("return code from external process not zero", rc != 0);
        assertEquals("retriesAttempted", 1, p.getRetriesAttempted());

        log.info("testExeFailWithOneRetry() - end");
    }

    @Test
    public void testExeFailWithThreeRetries() throws Exception {
        log.info("testExeFailWithThreeRetries() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("1"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);
        p.setRetryCount(3);
        p.setRetrySleepIntervalMillis(500);

        int rc = p.run(true, 10000);

        assertTrue("return code from external process not zero", rc != 0);
        assertEquals("retriesAttempted", 3, p.getRetriesAttempted());

        log.info("testExeFailWithThreeRetries() - end");
    }

    @Test
    public void testAbort() throws Exception {
        log.info("testAbort() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("5"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);
        p.setAbortCheck(new ExternalProcess.AbortCheck() {
            @Override
            public boolean abort() {
                log.info("abort() - start");

                log.info("abort() - end");
                return true;
            }
        });

        int rc = p.run(true, 10000);

        assertEquals("rc", -1, rc);

        assertEquals("aborted", p.aborted(), true);

        log.info("testAbort() - end");
    }

    @Test
    public void testBadExeName() throws Exception {
        log.info("testBadExeName() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog-bad");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 10000);

        assertEquals("return code from external process,", -1, rc);

        log.info("testBadExeName() - end");
    }

    @Test
    public void testDifferentWorkingDir() throws Exception {
        log.info("testDifferentWorkingDir() - start");

        File dir = new File("testdata/ExternalProcess/doesntexist");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 10000);

        assertEquals("return code from external process,", -1, rc);

        log.info("testDifferentWorkingDir() - end");
    }

    @Test
    public void testLogToMyWriter() throws Exception {
        log.info("testLogToMyWriter() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        StringWriter myWriter = new StringWriter();
        p.setUserDefinedStdOutWriter(myWriter);
        p.setUserDefinedStdErrWriter(myWriter);

        int rc = p.run(true, 10000);

        assertEquals("rc", 0, rc);

        String output = myWriter.toString();
        log.info("output len = " + output.length());

        assertTrue("output string not empty", output.length() != 0);

        log.info("testLogToMyWriter() - end");
    }

    @Test
    public void testLogToInternalStringWriter() throws Exception {
        log.info("testLogToInternalStringWriter() - start");

        File dir = new File("testdata/ExternalProcess");
        File exe = new File(dir.getPath() + "/testprog");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("0"); // retcode
        command.add("0"); // sleeptime
        command.add("0"); // crash flag

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(false);
        p.setLogStdErr(false);
        p.setWriteStdOut(true);
        p.setWriteStdErr(true);

        int rc = p.run(true, 10000);

        assertEquals("rc", 0, rc);

        String stdErr = p.getStderrString();
        log.info("stdErr len = " + stdErr.length());
        assertTrue("stdErr string not empty", stdErr.length() == 0);

        String stdOut = p.getStdoutString();
        log.info("stdOut len = " + stdOut.length());
        assertTrue("stdOut string not empty", stdOut.length() != 0);

        log.info("testLogToInternalStringWriter() - end");
    }
}
