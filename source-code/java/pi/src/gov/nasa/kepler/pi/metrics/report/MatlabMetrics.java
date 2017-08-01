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

import gov.nasa.kepler.pi.module.TaskDirectoryIterator;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.Metric;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

public class MatlabMetrics {
    private static final Log log = LogFactory.getLog(MatlabMetrics.class);

    private static final String MATLAB_METRICS_FILENAME = "metrics-0.ser";
    private static final String MATLAB_METRICS_CACHE_FILENAME = "metrics-cache.ser";
    private static final String MATLAB_CONTROLLER_EXEC_TIME_METRIC = "pipeline.module.executeAlgorithm.matlab.controller.execTime";
    
    private File taskFilesDir;
    private String moduleName;

    private boolean cacheResults = true;

    private boolean parsed = false;
    private DescriptiveStatistics totalTimeStats;
    private HashMap<String, DescriptiveStatistics> functionStats;
    private TopNList topTen;

    public MatlabMetrics(File taskFilesDir, String moduleName) {
        this.taskFilesDir = taskFilesDir;
        this.moduleName = moduleName;
    }
    
    private static final class CacheContents implements Serializable{
        private static final long serialVersionUID = -2905417458703562259L;
        public DescriptiveStatistics totalTime;
        public HashMap<String,DescriptiveStatistics> function;
        public TopNList topTen;
    }
    
    public void parseFiles() throws Exception{
        if(!parsed){
            totalTimeStats = new DescriptiveStatistics(); 
            functionStats = new HashMap<String,DescriptiveStatistics>(); 
            topTen = new TopNList(10);
            
            File cacheFile = new File(taskFilesDir, MATLAB_METRICS_CACHE_FILENAME);

            if(cacheFile.exists()){
                log.info("Found cache file");
                FileInputStream fis = new FileInputStream(cacheFile);
                BufferedInputStream bis = new BufferedInputStream(fis);
                ObjectInputStream ois = new ObjectInputStream(bis);
                CacheContents cacheContents = (CacheContents) ois.readObject();
                ois.close();
                
                totalTimeStats = cacheContents.totalTime;
                functionStats = cacheContents.function;
                topTen = cacheContents.topTen;
            }else{ // no cache
                log.info("No cache file found, parsing files");
                File[] taskDirs = taskFilesDir.listFiles(new FileFilter(){
                    @Override
                    public boolean accept(File f) {
                        return (f.getName().startsWith(moduleName + "-matlab-") && f.isDirectory());
                    }
                });
                
                for (File taskDir : taskDirs) {
                    log.info("Processing: " + taskDir);
                    
                    TaskDirectoryIterator directoryIterator = new TaskDirectoryIterator(taskDir);
                    
                    if(directoryIterator.hasNext()){
                        log.info("Found " + directoryIterator.numSubTasks() + " sub-task directories");
                    }else{
                        log.info("No sub-task directories found");               
                    }
                    
                    while(directoryIterator.hasNext()){
                        File subTaskDir = directoryIterator.next().right;
                        
                        log.debug("STM: " + subTaskDir);
                        
                        File subTaskMetricsFile = new File(subTaskDir, MATLAB_METRICS_FILENAME);
                        
                        if(subTaskMetricsFile.exists()){
                            try {
                                Map<String, Metric> subTaskMetrics = Metric.loadMetricsFromSerializedFile(subTaskMetricsFile);
                                
                                for (String metricName : subTaskMetrics.keySet()) {
                                    
                                    if(!metricName.equals(MATLAB_CONTROLLER_EXEC_TIME_METRIC)){
                                        Metric metric = subTaskMetrics.get(metricName);
                                        
                                        log.debug("STM: " + metricName + ": " + metric.toString());

                                        DescriptiveStatistics metricStats = functionStats.get(metricName);
                                        if(metricStats == null){
                                            metricStats = new DescriptiveStatistics();
                                            functionStats.put(metricName, metricStats);
                                        }
                                        
                                        IntervalMetric totalTimeMetric = (IntervalMetric)metric; 
                                        metricStats.addValue(totalTimeMetric.getAverage());
                                    }
                                }

                                Metric metric = subTaskMetrics.get(MATLAB_CONTROLLER_EXEC_TIME_METRIC);
                                if(metric != null){
                                    String subTaskName = subTaskDir.getParentFile().getName() + "/" + subTaskDir.getName();
                                    
                                    IntervalMetric totalTimeMetric = (IntervalMetric)metric; 
                                    double mean = totalTimeMetric.getAverage();
                                    totalTimeStats.addValue(mean);
                                    topTen.add((long) mean, subTaskName);
                                }else{
                                    log.warn("no metric found with name: " + MATLAB_CONTROLLER_EXEC_TIME_METRIC + " in:" + subTaskDir);
                                }
                            } catch (Exception e) {
                                log.warn("Metrics file is corrupt: " + subTaskDir + ", caught e:" + e);
                            }
                        }else{
                            log.warn("No metrics file found in: " + subTaskDir);
                        }
                    }
                }
                
                if(cacheResults){
                    FileOutputStream fos = new FileOutputStream(cacheFile);
                    BufferedOutputStream bos = new BufferedOutputStream(fos);
                    ObjectOutputStream oos = new ObjectOutputStream(bos);
                    
                    CacheContents cache = new CacheContents();
                    cache.totalTime = totalTimeStats;
                    cache.function = functionStats;
                    cache.topTen = topTen;
                    
                    oos.writeObject(cache);
                    oos.flush();
                    bos.close();
                }
            }
            parsed = true;
        }
    }
    
    public boolean isCacheResults() {
        return cacheResults;
    }

    public void setCacheResults(boolean cacheResults) {
        this.cacheResults = cacheResults;
    }

    public DescriptiveStatistics getTotalTimeStats() {
        return totalTimeStats;
    }

    public Map<String, DescriptiveStatistics> getFunctionStats() {
        return functionStats;
    }

    public TopNList getTopTen() {
        return topTen;
    }
}
