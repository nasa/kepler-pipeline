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

package gov.nasa.spiffy.common.metrics;

import static gov.nasa.spiffy.common.metrics.MetricsDumper.FileReuseMode.ReuseFile;
import static gov.nasa.spiffy.common.metrics.MetricsDumper.FileReuseMode.RotateFile;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import org.apache.commons.io.output.CountingOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link Runnable} that periodically dumps metrics to a file.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * @author Sean McCauliff
 * 
 */
public class MetricsDumper implements Runnable {
    private static final Log log = LogFactory.getLog(MetricsDumper.class);

    static enum FileReuseMode {
        ReuseFile, RotateFile;
    }
    
    private static int DUMP_INTERVAL_MILLIS = 30000;
    private static final int MAX_FILE_SIZE_BYTES = 1024*1024*1024*2;
    private static final int BUF_SIZE_BYTES = 1024*1024;
    
    private PrintWriter printWriter;
    private CountingOutputStream countOut;
    private final File metricsFile;
        
    public MetricsDumper(int pid) throws IOException {
        this(pid, new File("logs"));
    }
    
    public MetricsDumper(int pid, File metricDumpDir) throws IOException {
        FileUtil.mkdirs(metricDumpDir);
        metricsFile = new File(metricDumpDir, "metrics-dump-" + pid + ".txt");
        openFile(RotateFile);
        
    }
    
    /**
     * Close old stuff, rotate and create a new log file.
     * @param metricsFile
     * @throws IOException
     */
    private void openFile(FileReuseMode reuseMode) throws IOException {
        if (countOut != null && countOut.getCount() < MAX_FILE_SIZE_BYTES) {
            return;
        }
        if (printWriter != null) {
            printWriter.close();
        }
        if (metricsFile.exists() && (reuseMode == RotateFile ||
            (reuseMode == ReuseFile && metricsFile.length() >= MAX_FILE_SIZE_BYTES))) {
            File oldFile = new File(metricsFile.getParent(), metricsFile.getName() + ".old");
            if (oldFile.exists()) {
                if (!oldFile.delete()) {
                    throw new IOException("Failed to delete file \"" + oldFile + "\".");
                }
            }
            metricsFile.renameTo(oldFile);
        }
        FileOutputStream fout = new FileOutputStream(metricsFile, true /*append mode*/);
        BufferedOutputStream bout = new BufferedOutputStream(fout, BUF_SIZE_BYTES);
       
        countOut = new CountingOutputStream(bout);
        printWriter = new PrintWriter(new OutputStreamWriter(countOut));
    }
    
    

    @Override
    public void run() {
        while (true) {
            try {
                Thread.sleep(DUMP_INTERVAL_MILLIS);
                Metric.dump(printWriter);
                printWriter.flush();
                openFile(RotateFile);
            } catch (Exception e) {
                log.error("failed to dump metrics, caught e=" + e.getMessage(), e);
            }
        }
    }
}
