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

package gov.nasa.kepler.pi.metrics.report;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class MemdroneLog {
    private static final Log log = LogFactory.getLog(MemdroneLog.class);

    private InputStream input;
    private int lineCount = 0;
    private int skipCount = 0;
    // Map<ProcessId, DescriptiveStats>
    private Map<String, DescriptiveStatistics> logContents;
    
    public MemdroneLog(File memdroneLogFile) {
        if(!memdroneLogFile.exists()){
            throw new PipelineException("Specified memdrone file does not exist: " + memdroneLogFile);
        }

        if(!memdroneLogFile.isFile()){
            throw new PipelineException("Specified memdrone file is not a regular file: " + memdroneLogFile);
        }
        
        try {
            input = new FileInputStream(memdroneLogFile);
            parse();
        } catch (Exception e) {
            throw new PipelineException("failed to parse file, caught e = " + e, e );
        }
    }

    public MemdroneLog(InputStream input) {
        this.input = input;
        try {
            parse();
        } catch (Exception e) {
            throw new PipelineException("failed to parse file, caught e = " + e, e );
        }
    }

    private void parse() throws Exception {

        log.info("Parse started");
        
        logContents = new HashMap<String, DescriptiveStatistics>();
        
        BufferedReader br = new BufferedReader(new InputStreamReader(input));
        String line = null;
        
        while ((line = br.readLine()) != null) {
            lineCount++;
            MemdroneSample s = new MemdroneSample(line);
            if(s.isValid()){
                DescriptiveStatistics stats = logContents.get(s.getProcessId());
                if(stats == null){
                    stats = new DescriptiveStatistics();
                    logContents.put(s.getProcessId(), stats);
                }
                stats.addValue(s.getMemoryKilobytes()*1024.0);
            }else{
                skipCount ++;
            }
        }
        
        br.close();
        
        log.info("Parse complete");
        log.info("lineCount: " + lineCount);
        log.info("skipCount: " + skipCount);
    }

    public Map<String, DescriptiveStatistics> getLogContents() {
        return logContents;
    }
    
    private static void dumpMemoryReport(File taskFilesDir) throws Exception{
        File[] taskDirs = taskFilesDir.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().contains("-matlab-") && f.isDirectory());
            }
        });
        
        DescriptiveStatistics memoryStats = new DescriptiveStatistics();
        TopNList topTen = new TopNList(10);
        
        for (File taskDir : taskDirs) {
            log.info("Processing: " + taskDir);

            Memdrone memdrone = new Memdrone(taskDir);
            Map<String, DescriptiveStatistics> taskStats = memdrone.statsByPid();
            Map<String, String> pidMap = memdrone.subTasksByPid();
            
            Set<String> pids = taskStats.keySet();
            for (String pid : pids) {
                String subTaskName = pidMap.get(pid);
                if(subTaskName == null){
                    subTaskName = "?:" + pid;
                }
                
                double max = taskStats.get(pid).getMax();
                memoryStats.addValue(max);
                topTen.add((long) max, subTaskName);
            }
        }
        dumpTopTen(topTen);
    }
    
    private static void dumpTopTen(TopNList topTenList) throws Exception{
        Format f = new BytesFormat();
        List<TopNListElement> list = topTenList.getList();
        int index = 1;
        
        for (TopNListElement element : list) {
            String value = f.format(element.getValue());             
            System.out.println(index + " - " + element.getLabel() + ": " + value);
            index++;
        }
    }
    
    private static void usage() {
        System.out.println("memdrone TASK_DIR");
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            usage();
            System.exit(-1);
        }
        String taskDirName = args[0];
        File taskDir = new File(taskDirName);
        dumpMemoryReport(taskDir);
    }
}
