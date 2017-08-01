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

package gov.nasa.kepler.fs.perf;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Periodically dumps stack traces to a file.
 * 
 * @author Sean McCauliff
 *
 */
public class StackDumperPoller implements Runnable {

    private static final Log log = LogFactory.getLog(StackDumperPoller.class);
    
    private static final String THREAD_NAME = "Stack Dumper Poller";
    private static final String[] ignoreTheseMethods = 
    { "parseMethodName", "java.util.concurrent.DelayQueue.take", 
        "java.util.concurrent.ThreadPoolExecutor.getTask",
        "sun.nio.ch.ServerSocketChannelImpl.accept"
    };
    
    private static final long MAX_FILE_SIZE_BYTES = 1024 * 1024 * 256;
    
    private final List<Pattern> threadFilterPatterns;
    private final List<Pattern> methodFilterPatterns;
    private final StackTraceDumper dumper = new StackTraceDumper();
    private boolean isRunning = false;
    private final File outputFile;
    private final File oldOutputFile;
    private final long pollInterval;
    
    /**
     * 
     * @param outputDir Where to place the stack dump files.
     * @param pollInterval in milliseconds.
     * @throws IOException
     */
    public StackDumperPoller(File outputDir, long pollInterval) throws IOException {
        threadFilterPatterns = 
            Collections.singletonList(Pattern.compile(THREAD_NAME + "|BTree Metrics Poller"));
        
        
        methodFilterPatterns =
            Collections.singletonList(Pattern.compile("("+StringUtils.join(ignoreTheseMethods, '|')+")"));
        this.pollInterval = pollInterval;
        
        outputFile = new File(outputDir, "stack.dump.csv");
        oldOutputFile = new File(outputDir, "stack.dump.old.csv");
        if (outputFile.exists()) {
            oldOutputFile.delete();
            outputFile.renameTo(oldOutputFile);
        }
        outputFile.createNewFile();
        
    }
    
    @Override
    public void run() {
        try {
            while (true) {
                try {
                    poll();
                } catch (IOException e) {
                    log.error("Stack trace dumper error.", e);
                }
                Thread.sleep(pollInterval);
            }
        } catch (InterruptedException ie) {
            log.info("StackDumperExiting on interrupted exception.");
        }
    }

    /**
     * Creates a new thread and runs the poller.
     */
    public synchronized void start() {
        if (isRunning) {
            return;
        }
        Thread t = new Thread(this, THREAD_NAME);
        t.start();
        isRunning = true;
    }
    
    private void poll() throws IOException {
        if (outputFile.length() >= MAX_FILE_SIZE_BYTES ) {
            oldOutputFile.delete();
            outputFile.renameTo(oldOutputFile);
            outputFile.createNewFile();
        }
        FileWriter fileWriter = new FileWriter(outputFile, true);
        try {
            dumper.dumpStack(fileWriter, methodFilterPatterns, threadFilterPatterns);
        } finally {
            fileWriter.close();
        }
    }
}
