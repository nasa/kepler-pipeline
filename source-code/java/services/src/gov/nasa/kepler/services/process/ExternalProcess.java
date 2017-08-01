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

import gov.nasa.spiffy.common.metrics.CounterMetric;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class manages an external process. It provides the following
 * functionality on top of java.lang.ProcessBuilder:
 * <ul>
 * <li>Spawns threads to collect stdout & stderr from the external process. It
 * can be configured to send this output to commons logging, or to a
 * user-supplied java.io.Writer, or to an internal java.io.Writer (user can
 * access it as a String after the process completes), or to logging and a
 * Writer.</li>
 * <li>Allows the external process to be run synchronously or asynchronously</li>
 * <li>Option for user-supplied AbortCheck (kill process if abort check returns
 * true)</li>
 * <li>Kill if user-supplied timeout expires</li>
 * </ul>
 *
 * @author tklaus
 *
 */
public class ExternalProcess {
    static final Log log = LogFactory.getLog(ExternalProcess.class);

    private static final int KILL_WAIT_MILLIS = 1000;
    private static final int SLEEP_INTERVAL_BETWEEN_RETRIES_DEFAULT_MILLIS = 10000;

    private String cmdLine = null;
    private ProcessBuilder processBuilder = null;
    private Process process;
    private boolean logStdOut = false;
    private boolean logStdErr = true;
    private boolean writeStdOut = false;
    private boolean writeStdErr = false;
    private Writer userDefinedStdOutWriter = null;
    private Writer userDefinedStdErrWriter = null;
    private StringWriter internalStdOutWriter = new StringWriter();
    private StringWriter internalStdErrWriter = new StringWriter();
    private OutputConsumerThread stdErrThread;
    private OutputConsumerThread stdOutThread;
    private boolean timedOut = false;
    private boolean killed = false;
    private boolean aborted = false;
    private boolean launchFailed = false;
    private AbortCheck abortCheck = null;
    private String lastErrMsg;
    private String progName = "?";
    private int asyncRetcode = -1;
    private String threadLabel = "";
    private boolean complete;
    private int retCode;
    private long startTime;
    private boolean started = false;
    private int retryCount = 0;
    private int retriesAttempted;
    private int retrySleepIntervalMillis = SLEEP_INTERVAL_BETWEEN_RETRIES_DEFAULT_MILLIS;
    private boolean verbose = true;

    private static Map<String, Process> currentlyRunningProcesses = new HashMap<String, Process>();

    /**
     * External hook for callers to easily terminate the process. If abortCheck
     * is set, the AbortCheck.abort() method will be called periodically by the
     * run() method while waiting for the process to complete. If abort()
     * returns true, the external process will be killed. This is useful for
     * aborting during a system shutdown, etc.
     *
     * @author Todd Klaus
     *
     */
    public interface AbortCheck {
        /**
         * If true, ExternalProcess will kill the process
         *
         * @return
         */
        public boolean abort();
    }

    /**
     *
     * @param command
     */
    public ExternalProcess(List<String> commandPlusArgs) {
        processBuilder = new ProcessBuilder(commandPlusArgs);
    }

    /**
     *
     * @param command
     */
    public ExternalProcess(String... command) {
        processBuilder = new ProcessBuilder(command);
    }

    /**
     *
     * @return
     */
    public File directory() {
        return processBuilder.directory();
    }

    /**
     *
     * @param directory
     */
    public void directory(File directory) {
        processBuilder.directory(directory);
    }

    /**
     *
     * @return
     */
    public Map<String, String> environment() {
        return processBuilder.environment();
    }

    /**
     * Execute the external process
     *
     * @param wait Whether to wait for the external process to complete. If
     * false, process runs asynchronously
     * @param timeoutMillis
     * @return Return code for the external process
     * @throws InterruptedException
     */
    public int run(boolean wait, int timeoutMillis) throws InterruptedException {

        if (started) {
            log.error("Process already started (run() may only be called once per instance of ExternalProcess)");
            return -1;
        }

        started = true;
        retriesAttempted = 0;

        while (true) {
            startProcess(wait, timeoutMillis);

            log.debug("retCode=" + retCode);

            if (timedOut || retCode == 0) {
                return retCode;
            }

            if (retriesAttempted < retryCount) {
                retriesAttempted++;
                log.info("retry " + retriesAttempted + "/" + retryCount
                    + ", sleeping for " + retrySleepIntervalMillis
                    + " before retry...");
                try {
                    Thread.sleep(retrySleepIntervalMillis);
                } catch (Exception e) {
                }
                log.info("retrying...");
            } else {
                if (retryCount > 0) {
                    log.error("Retries exhaused, giving up");
                    return retCode;
                }

                // no retries requested, just give up
                return retCode;
            }
        }
    }

    private void startProcess(boolean wait, int timeoutMillis)
        throws InterruptedException {
        // for debug purposes only
        StringBuffer cmdLineBuf = new StringBuffer();
        for (String cmd : processBuilder.command()) {
            cmdLineBuf.append(cmd);
            cmdLineBuf.append(" ");
        }
        cmdLine = cmdLineBuf.toString();

        retCode = 0;
        startTime = 0;
        launchFailed = false;
        complete = false;
        timedOut = false;
        progName = processBuilder.command()
            .get(0);

        try {
            if (verbose) {
                log.debug("starting process, cmdLine=" + cmdLineBuf);
            }
            process = processBuilder.start();

            if (wait) {
                registerProcess(progName, process);
            }
            startTime = System.currentTimeMillis();
        } catch (IOException e) {
            lastErrMsg = "process [" + cmdLineBuf
                + "] failed to start, caught e = " + e;
            log.warn(lastErrMsg);
            CounterMetric.increment("pipeline.module.exec.[" + progName
                + "].fail.count");
            launchFailed = true;
            retCode = -1;
            return;
        }

        if (process != null) {
            initConsumers();

            if (wait) {
                waitFor(timeoutMillis);
            } else {
                // not waiting, just make sure it started ok
                Thread.sleep(1000);

                try {
                    retCode = process.exitValue();
                    log.info("retcode for process [" + progName + "] = "
                        + retCode);
                } catch (IllegalThreadStateException e) {
                    // still running...
                }
            }
        } else {
            lastErrMsg = "process [" + progName + "] failed to start";
            log.warn(lastErrMsg);
            retCode = -1;
            launchFailed = true;
            CounterMetric.increment("exec.[" + progName + "].fail.count");
        }

        if (!aborted && wait && !complete) {
            lastErrMsg = "process [" + progName + "] timed out, killing";
            kill();
            log.warn(lastErrMsg);
            timedOut = true;
            retCode = -1;
            CounterMetric.increment("exec.[" + progName + "].timeout.count");
        }
    }

    private void initConsumers() {
        // where does stdout go?
        Writer outWriter = null;
        if (userDefinedStdOutWriter != null) {
            outWriter = userDefinedStdOutWriter;
        } else if (writeStdOut) {
            outWriter = internalStdOutWriter;
        }
        // where does stderr go?
        Writer errWriter = null;
        if (userDefinedStdErrWriter != null) {
            errWriter = userDefinedStdErrWriter;
        } else if (writeStdErr) {
            errWriter = internalStdErrWriter;
        }

        stdOutThread = new OutputConsumerThread(threadLabel + ":so",
            process.getInputStream(), outWriter, logStdOut);
        stdErrThread = new OutputConsumerThread(threadLabel + ":se",
            process.getErrorStream(), errWriter, logStdErr);

        stdErrThread.start();
        stdOutThread.start();
    }

    private void waitFor(int timeoutMillis) throws InterruptedException {
        if (timeoutMillis > 0) {
            log.debug("waiting for process to terminate or timeout");
            while (!complete
                && System.currentTimeMillis() - startTime < timeoutMillis) {
                try {
                    if (abortCheck != null && abortCheck.abort()) {
                        // caller requested abort
                        log.debug("caller requested abort, killing");
                        kill();
                        deRegisterProcess(progName);
                        killed = true;
                        aborted = true;
                        retCode = -1;
                        log.debug("kill complete, returning");
                        break;
                    }
                    retCode = process.exitValue();
                    // if we got here, process ended
                    deRegisterProcess(progName);
                    complete = true;
                    break;
                } catch (IllegalThreadStateException e) {
                    // process.exitValue() threw, so it's not done
                    // yet...
                    Thread.sleep(1000);
                }
            }
        } else {
            log.debug("waiting for process to terminate");
            // wait until complete
            retCode = process.waitFor();
            deRegisterProcess(progName);
            complete = true;
        }

        log.debug("complete = " + complete);
        if (complete) {
            try {
                stdOutThread.join();
                log.debug("stdout thread finished");
            } catch (Exception e) {
                log.error("caught exeception reading stdout thread, e = ", e);
            }
            try {
                stdErrThread.join();
                log.debug("stderr thread finished");
            } catch (Exception e) {
                log.error("caught exeception reading stderr thread, e = ", e);
            }
        }
    }

    private void registerProcess(String processName, Process currentProcess) {
        synchronized (currentlyRunningProcesses) {
            currentlyRunningProcesses.put(processName, currentProcess);
        }
    }

    private void deRegisterProcess(String processName) {
        synchronized (currentlyRunningProcesses) {
            currentlyRunningProcesses.remove(processName);
        }
    }

    public static void killAllRunningProcesses() throws InterruptedException {
        synchronized (currentlyRunningProcesses) {
            for (String processName : currentlyRunningProcesses.keySet()) {
                Process p = currentlyRunningProcesses.get(processName);
                kill(processName, p);
            }
        }
    }

    /**
     *
     * @return Indicates whether the process is still running
     */
    public boolean isProcessAlive() {
        Integer rc = processStatus(process);
        if (rc != null) {
            asyncRetcode = rc;
            return false;
        }

        return true;
    }

    /**
     *
     * @param p
     * @return return code. If null, process is still running
     */
    private static Integer processStatus(Process p) {
        Integer rc = null;
        try {
            if (p != null) {
                rc = p.exitValue();
            }
        } catch (IllegalThreadStateException e) {
            // still running...
        }
        return rc;
    }

    /**
     *
     * @return Indicates whether the stdout drain thread is still running
     */
    public boolean isStdoutThreadAlive() {
        if (stdOutThread != null) {
            return stdOutThread.isAlive();
        }

        return false;
    }

    /**
     *
     * @return Indicates whether the stderr drain thread is still running
     */
    public boolean isStderrThreadAlive() {
        if (stdErrThread != null) {
            return stdErrThread.isAlive();
        }

        return false;
    }

    /**
     *
     * Kill the external process
     *
     * @throws InterruptedException
     *
     */
    public void kill() throws InterruptedException {
        kill(progName, process);
    }

    private static void kill(String processName, Process p)
        throws InterruptedException {

        if (p == null) {
            log.warn("kill() called for null process!, doing nothing");
            return;
        }

        if (processStatus(p) == null) {
            log.info("killing process <" + processName + ">");
            p.destroy();

            Thread.sleep(KILL_WAIT_MILLIS);

            if (processStatus(p) == null) {
                log.warn("tried to kill process <" + processName
                    + ">, but it's still alive!  Trying one more time");
                p.destroy();

                Thread.sleep(KILL_WAIT_MILLIS);
                if (processStatus(p) == null) {
                    log.error("tried to kill process <"
                        + processName
                        + ">, but it's still alive after two assasination attempts!");
                }
            }
        } else {
            log.info("Request made to kill process <" + processName
                + ">, but it's not running");
        }
    }

    /**
     * @return
     */
    public String getStdoutString() {
        return internalStdOutWriter.toString();
    }

    /**
     * @return
     */
    public String getStderrString() {
        return internalStdErrWriter.toString();
    }

    /**
     * @return
     */
    public boolean isLogStdErr() {
        return logStdErr;
    }

    /**
     * @return
     */
    public boolean isLogStdOut() {
        return logStdOut;
    }

    /**
     * @param b
     */
    public void setLogStdErr(boolean b) {
        logStdErr = b;
    }

    /**
     * @param b
     */
    public void setLogStdOut(boolean b) {
        logStdOut = b;
    }

    /**
     * @param writer
     */
    public void setUserDefinedStdErrWriter(Writer writer) {
        userDefinedStdErrWriter = writer;
    }

    /**
     * @param writer
     */
    public void setUserDefinedStdOutWriter(Writer writer) {
        userDefinedStdOutWriter = writer;
    }

    /**
     * @return
     */
    public boolean timedOut() {
        return timedOut;
    }

    /**
     * @param check
     */
    public void setAbortCheck(AbortCheck check) {
        abortCheck = check;
    }

    /**
     * @return
     */
    public boolean killed() {
        return killed;
    }

    /**
     * @return
     */
    public String getCmdLine() {
        return cmdLine;
    }

    /**
     * @return Returns the lastErrMsg.
     */
    public String getLastErrMsg() {
        return lastErrMsg;
    }

    /**
     * @return
     */
    public Process getProcess() {
        return process;
    }

    /**
     *
     * @return
     */
    public boolean launchFailed() {
        return launchFailed;
    }

    /**
     *
     * @return
     */
    public boolean aborted() {
        return aborted;
    }

    /**
     *
     * @return
     */
    public int getAsyncRetcode() {
        return asyncRetcode;
    }

    /**
     *
     * @return
     */
    public boolean isWriteStdErr() {
        return writeStdErr;
    }

    /**
     *
     * @param writeStdErr
     */
    public void setWriteStdErr(boolean writeStdErr) {
        this.writeStdErr = writeStdErr;
    }

    /**
     *
     * @return
     */
    public boolean isWriteStdOut() {
        return writeStdOut;
    }

    /**
     *
     * @param writeStdOut
     */
    public void setWriteStdOut(boolean writeStdOut) {
        this.writeStdOut = writeStdOut;
    }

    /**
     * @return the threadLabel
     */
    public String getThreadLabel() {
        return threadLabel;
    }

    /**
     * @param threadLabel the threadLabel to set
     */
    public void setThreadLabel(String threadLabel) {
        this.threadLabel = threadLabel;
    }

    public int getRetryCount() {
        return retryCount;
    }

    public void setRetryCount(int retryCount) {
        this.retryCount = retryCount;
    }

    public int getRetriesAttempted() {
        return retriesAttempted;
    }

    public int getRetrySleepIntervalMillis() {
        return retrySleepIntervalMillis;
    }

    public void setRetrySleepIntervalMillis(int retrySleepInterval) {
        retrySleepIntervalMillis = retrySleepInterval;
    }

    public boolean isVerbose() {
        return verbose;
    }

    public void setVerbose(boolean verbose) {
        this.verbose = verbose;
    }
}
