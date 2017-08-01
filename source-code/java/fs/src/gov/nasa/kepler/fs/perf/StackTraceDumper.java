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

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;


/**
 * Dumps the stack traces of all the currently running threads. The format for
 * the output is timestamp|thread name|element no|class name|method name. 
 * This forms a database table suitable for importing into HSQLDB or spreadsheet
 * import.
 * 
 * @author Sean McCauliff
 *
 */
public class StackTraceDumper {

    private final ThreadMXBean threadMxBean;
    
    public StackTraceDumper() {
        threadMxBean = ManagementFactory.getThreadMXBean();
    }
    
    
    /**
     * Dump all the stacks to the specified writer ignoring the thread running
     * the stack dumper.
     * @param ignoreMethodNames These patterns will be tested against the names
     * of the methods, including the class name.  If a method name matches 
     *  then that stack trace will not be written.
     * @param ignoreThreads If the name of a thread matches these patterns then
     * the stack trace will not be written.
     * @throws IOException 
     */
    public void dumpStack(Appendable writer, List<Pattern> ignoreMethodNames, 
        List<Pattern> ignoreThreads) throws IOException {
        
        List<Pattern> useIgnoreThreads = theUsualSuspects(ignoreThreads);
        
        final String timestamp = Long.toString(System.currentTimeMillis());
        //TODO:  Hey we can get monitor waiting information.
        ThreadInfo[] threadInfos = threadMxBean.dumpAllThreads(false, false);
        for (ThreadInfo threadInfo : threadInfos) {
            String threadName = threadInfo.getThreadName();
            if (matchAny(useIgnoreThreads, threadName)) {
                continue;
            }
    
            StackTraceElement[] stackFrames = threadInfo.getStackTrace();
            boolean ignoreThread = false;
            for (StackTraceElement frame : stackFrames) {
                if (matchAny(ignoreMethodNames, frame.toString())) {
                    ignoreThread = true;
                    break;
                }
            }
            if (ignoreThread) {
                continue;
            }
            writeEntry(writer, timestamp, threadName, stackFrames);
        }
        
    }

    /**
     * Filter out some uninteresting threads.
     * @param ignoreThreads  The user supplied ignored thread patterns.
     * @return The complete list of ignored thread patterns.
     */
    private List<Pattern> theUsualSuspects(List<Pattern> ignoreThreads) {
        String ourThreadName = Thread.currentThread().getName();
        ourThreadName.replace("\\", "\\\\");
        ourThreadName.replace(".", "\\.");
        ourThreadName.replace("[", "\\[");
        ourThreadName.replace("]", "\\]");
        
        StringBuilder bldr = new StringBuilder();
        bldr.append('(').append(ourThreadName)
        .append('|').append("Finalizer|Reference Handler|CompilerThread|Signal Dispatcher|GC task)");
        
        
        List<Pattern> useIgnoreThreads = new ArrayList<Pattern>(ignoreThreads);
        useIgnoreThreads.add(Pattern.compile(bldr.toString()));
        return useIgnoreThreads;
    }
    
    private void writeEntry(Appendable writer, String timestamp, String threadName,
        StackTraceElement[] stackFrames) throws IOException {

        for (int i = 0; i < stackFrames.length; i++) {
            StackTraceElement stackTraceElement = stackFrames[i];
            writer.append(timestamp).append('|')
                .append(threadName).append('|')
                .append(Integer.toString(i)).append('|')
                .append(stackTraceElement.getClassName()).append('|')
                .append(stackTraceElement.getMethodName())
                .append('\n');
        }
    }


    private boolean matchAny(List<Pattern> patterns, String s) {
        for (Pattern pat : patterns) {
            if (pat.matcher(s).find()) {
                return true;
            }
        }
        return false;
    }
}
