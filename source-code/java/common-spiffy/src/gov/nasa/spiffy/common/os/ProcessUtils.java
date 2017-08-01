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

package gov.nasa.spiffy.common.os;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Process-related functions. </p> Uses JNI and kill(2) to send a SIGKILL signal
 * to a process.
 * 
 * @author Forrest Girouard
 * @author Sean McCauliff
 * 
 */
public class ProcessUtils {

    private static final Log log = LogFactory.getLog(ProcessUtils.class);

    private static boolean killEnabled = false;

    static {
        try {
            System.loadLibrary("prockill");
            killEnabled = true;
            log.info("Using native prockill library");
        } catch (UnsatisfiedLinkError ule) {
            log.info("Failed to load prockill library.  killPid() functionality disabled");
        }
    }

    public static boolean isKillEnabled() {
        return killEnabled;
    }

    /**
     * Kill the specified pid with the kill() system call.
     * 
     * @param pid
     * @return the return value from kill()
     * @throws IOException
     */
    public static native int killPid(int pid);
    
    /**
     * Return the pid for the current process.
     * 
     * @return pid
     */
    public static native int getPidNative();
    
    /**
     * Gets the process id for the current process.
     */
    public static int getPid() {
        RuntimeMXBean rmx = ManagementFactory.getRuntimeMXBean();
        String nameStr = rmx.getName();
        String pidStr = nameStr.substring(0, nameStr.indexOf('@'));
        
        return Integer.parseInt(pidStr);
    }

    /**
     * Runs a Java process using the same environment as the calling Java
     * process. This assumes the command to run the virtual machine is just
     * "java".
     * 
     * @param mainClass The class containing the main() method.
     * @param mainArgs The parameters to pass to the class's main method.
     * @return a {@link Process} object.
     * @throws IOException if the process could not be started.
     */
    public static Process runJava(Class<?> mainClass, List<String> mainArgs)
        throws IOException {

        String className = mainClass.getCanonicalName();
        RuntimeMXBean rmx = ManagementFactory.getRuntimeMXBean();
        String classPath = rmx.getClassPath();
        List<String> javaCommandLineParameters = rmx.getInputArguments();
        String javaExe = System.getProperty("java.home") + File.separator
            + "bin" + File.separator + "java";

        List<String> commandList = new ArrayList<String>();
        StringBuilder cmd = new StringBuilder();
        cmd.append(javaExe).append(' ');
        commandList.add(javaExe);
        cmd.append("-cp ").append(classPath).append(' ');
        commandList.add("-cp");
        commandList.add(classPath);

        for (String javaArg : javaCommandLineParameters) {
            //don't run the java child with debugging parameters.
            if (javaArg.equals("-Xdebug") ||
                javaArg.startsWith("-Xrunjdwp") ||
                javaArg.startsWith("-agentlib:jdwp")) {
                continue;
            }
            cmd.append(javaArg).append(' ');
            commandList.add(javaArg);
        }

        cmd.append(className).append(' ');
        commandList.add(className);

        for (String arg : mainArgs) {
            cmd.append(arg).append(' ');
            commandList.add(arg);
        }

        String[] commandArray = new String[commandList.size()];
        commandList.toArray(commandArray);

        log.info("Executing java process with command line \"" + cmd + "\".");
        Process process = Runtime.getRuntime().exec(commandArray);
        BufferedReader errors = new BufferedReader(new InputStreamReader(
            process.getErrorStream()));

        // Report stderr if the process fails to launch. Unfortunately, if there
        // is a problem here, it seems you have to be stepping in the debugger
        // in order for errors.ready() to return true so that output can be
        // seen.
        while (errors.ready()) {
            log.error(errors.readLine());
        }

        return process;
    }
    
    /**
     * Correctly closes all the resources a process uses.  Likely you should 
     * use this in a finally block
     * @param process  This may be null.
     */
    public static void closeProcess(Process process) {
        if (process == null) {
            return;
        }
        
        FileUtil.close(process.getOutputStream());
        FileUtil.close(process.getInputStream());
        FileUtil.close(process.getErrorStream());
    }
    
    /**
     * Grab the output from executing a command.  Stderr appears at the end
     * of stdout.
     * 
     * @param cmd
     * @exception java.io.IOException For the usual reasons, and if execing
     * the process fails.
     * @return
     * @throws InterruptedException 
     */
    public static ProcessOutput grabOutput(String cmd) throws IOException, InterruptedException {
        Process process = null;
        try {
            process = Runtime.getRuntime().exec(cmd);
            return grabOutput(process, cmd);
        } finally {
            closeProcess(process);
        }
    }

    /**
     * This is like grabOutput(String) except that the caller needs to provide
     * the already constructed process and is responsible for closing the
     * process after this has been called.
     * 
     * @param process non-null.  The process to grab output from.
     * @param infoString This may be null.  This is included in thread names.
     * @return non-null
     * @throws InterruptedException
     */
    public static ProcessOutput grabOutput(Process process, String infoString)
        throws InterruptedException {
        InputStream in = process.getInputStream();
        ReadInput stdoutReader = new ReadInput(in);
        Thread stdoutReaderThread = new Thread(stdoutReader, "stdout reader : " + infoString);
        stdoutReaderThread.start();
        
        InputStream err = process.getErrorStream();
        ReadInput stderrReader = new ReadInput(err);
        Thread stderrReaderThread = new Thread(stderrReader, "stderr reader : " + infoString);
        stderrReaderThread.start();
        
        stdoutReaderThread.join();
        stderrReaderThread.join();
        
        if (stderrReader.err() != null) {
            throw new RuntimeException(stderrReader.err());
        }
        if (stdoutReader.err() != null) {
            throw new RuntimeException(stdoutReader.err());
        }
        
        int returnCode = process.waitFor();
        
        return new ProcessOutput(stdoutReader.output(), stderrReader.output(), returnCode);
    }
    
    public static final class ProcessOutput {
        private final String err;
        private final String output;
        private final int returnCode;
        
        public ProcessOutput(String output, String err, int returnCode) {
            super();
            this.output = output;
            this.returnCode = returnCode;
            this.err = err;
        }

        public int returnCode() {
            return returnCode;
        }
        
        public String err() {
            return err;
        }
        
        public String output() {
            return output;
        }
        
        public String all() {
            return output + err;
        }
        
        public List<String> allAsList() {
            BufferedReader stringReader = new BufferedReader(new StringReader(all()));
            List<String> rv = new ArrayList<String>();
            try {
                for (String line = stringReader.readLine(); line != null; line = stringReader.readLine()) {
                    rv.add(line);
                }
            } catch (IOException e) {
                log.error("This can never happen.", e);
            }
            
            return rv;
        }
    }
    
    public static class ReadInput implements Runnable {
        private final InputStream in;
        private volatile Throwable err;
        private final StringWriter out = new StringWriter();
        
        public ReadInput(InputStream in) {
            this.in = in;
        }
        
        public Throwable err() {
            return err;
        }
        
        public String output() {
            return out.toString();
        }
        
        @Override
        public void run() {
            try {
                synchronized (this) { //prevent reordering of writes into the string writer
                    IOUtils.copy(in, out);
                }
            } catch (Throwable t) {
                err = t;
            }
        }
    }
}
