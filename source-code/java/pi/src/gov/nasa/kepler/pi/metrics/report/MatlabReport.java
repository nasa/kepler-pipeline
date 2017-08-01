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

import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.FileFilter;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.jfree.chart.JFreeChart;
import org.jfree.data.general.DefaultPieDataset;

public class MatlabReport extends Report {
    private static final Log log = LogFactory.getLog(MatlabReport.class);
    private String moduleName;
    private File taskFilesDir;
    
    public MatlabReport(PdfRenderer pdfRenderer, File taskFilesDir, String moduleName) {
        super(pdfRenderer);
        this.moduleName = moduleName;
        this.taskFilesDir = taskFilesDir;
    }

    /**
     * Generate stacked bar chart
     * 
     * Generate descriptive statistics and a histogram of the peak memory usage
     * for all matlab processes for all tasks for the specified module.
     * 
     * @param moduleName
     * @throws Exception
     */
    public void generateReport() throws Exception {
        generateExecTimeReport();
        generateMemoryReport();
    }

    private void generateExecTimeReport() throws Exception{
        MatlabMetrics matlabMetrics = new MatlabMetrics(taskFilesDir, moduleName);
        matlabMetrics.parseFiles();
        
        DescriptiveStatistics matlabStats = matlabMetrics.getTotalTimeStats();

        Map<String, DescriptiveStatistics> matlabFunctionStats = matlabMetrics.getFunctionStats();
        
        double totalTime = matlabStats.getSum();
        double otherTime = totalTime;

        DefaultPieDataset functionBreakdownDataset = new DefaultPieDataset();

        log.info("breakdown report");
        
        for (String metricName : matlabFunctionStats.keySet()) {
            String label = shortMetricName(metricName);

            log.info("processing metric: " + label);

            DescriptiveStatistics functionStats = matlabFunctionStats.get(metricName);
            double functionTime = functionStats.getSum();
            double fraction = functionTime / totalTime;
            
            if(fraction > 0.01){
                functionBreakdownDataset.setValue(label, fraction);
            }
            otherTime -= functionTime;
        }
        
        double otherFraction = otherTime / totalTime;
        functionBreakdownDataset.setValue("Other", otherFraction);

        JFreeChart pie = generatePieChart("MATLAB Algorithm Breakdown", functionBreakdownDataset);

        pdfRenderer.printChart(pie, CHART2_WIDTH, CHART2_HEIGHT);            
        
        pdfRenderer.newPage();
        
        Pair<String, List<Double>> values = millisToHumanReadable(matlabStats);
        JFreeChart execHistogram = generateHistogram("MATLAB Controller Run Time", "Time (" + values.left + ")", "Sub-Tasks", 
            values.right, 100);

        if(execHistogram != null){
            pdfRenderer.printChart(execHistogram, CHART3_WIDTH, CHART3_HEIGHT);            
        }else{
            pdfRenderer.printText("Histogram: No data points available");
        }

        pdfRenderer.printText(" ");

        generateSummaryTable("MATLAB Controller", matlabStats, matlabMetrics.getTopTen(), new TimeMillisFormat());

        pdfRenderer.newPage();
    }
    
    private void generateMemoryReport() throws Exception{
        File[] taskDirs = taskFilesDir.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().contains(moduleName + "-matlab-") && f.isDirectory());
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
        
        JFreeChart memHistogram = generateHistogram("Peak Memory Usage", "Memory Usage (MB)", "Tasks", 
            arrayToList(memoryStats.getValues(), 1.0/(1024*1024)), 100);

        if(memHistogram != null){
            pdfRenderer.printChart(memHistogram, CHART3_WIDTH, CHART3_HEIGHT);            
        }else{
            pdfRenderer.printText("Histogram: No data points available");
        }

        generateSummaryTable("MATLAB Memory Usage", memoryStats, topTen, new BytesFormat());
    }
        
    private String shortMetricName(String metricName) {
        String[] elements = metricName.split("\\.");
        String longest = "";
        for (String element : elements) {
            if(element.length() > longest.length()){
                longest = element;
            }
        }
        return longest;
    }
}
