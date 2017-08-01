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

import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.Metric;

import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.StandardXYBarPainter;
import org.jfree.chart.renderer.xy.XYBarRenderer;
import org.jfree.data.statistics.BoxAndWhiskerCalculator;
import org.jfree.data.statistics.DefaultBoxAndWhiskerCategoryDataset;
import org.jfree.data.statistics.HistogramDataset;
import org.jfree.data.statistics.HistogramType;

/**
 * This class walks a task file directory tree looking for metrics-0.ser files, 
 * reads them, and generates a summary report of their contents.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class InstanceMetricsReport {
    private static final Log log = LogFactory.getLog(InstanceMetricsReport.class);
    
    private static final int CHART_HEIGHT = 500;
    private static final int CHART_WIDTH = 700;
    private static final int NUM_BINS = 100;
    private static final int TOP_N_INSTANCE = 20;
    private static final int TOP_N_TASKS = 10;

    private static final String METRICS_FILE_NAME = "metrics-0.ser";
    
    /** Top-level directory that contains the task files. Assumes that this
     * directory contains all of the task directories, which in turn contain
     * all of the sub-task directories 
     */
    private File rootDirectory = null;
    
    /** Name of the metric that represents the total time used by the controller.
     * Default is pipeline.module.executeAlgorithm.matlab.controller.execTime,
     * the metric added by the MATLAB code generator. This metric is used for the
     * "Top 10" list and the pie chart breakdown
     */
    private String totalTimeMetricName = "pipeline.module.executeAlgorithm.matlab.controller.execTime";
    
    // Map<metricName,rollupMetric>
    private Map<String, Metric> instanceMetrics = new HashMap<String, Metric>();
    
    // Map<taskFileDirname,Map<metricName,rollupMetric>
    private Map<String,Map<String, Metric>> taskMetricsMap = new HashMap<String, Map<String,Metric>>();
    
    private TopNList instanceTopNList = new TopNList(TOP_N_INSTANCE);

    // Map<taskDirName,List<execTime>> - Complete list of exec times, by sky group
    private Map<String,List<Double>> subTaskExecTimesByTask = new HashMap<String,List<Double>>();
    
    private List<Double> subTaskExecTimes = new ArrayList<Double>(200000);

    private int maxTasks = -1;

    private PdfRenderer instancePdfRenderer;
    private PdfRenderer taskPdfRenderer;
        
    public InstanceMetricsReport(File rootDirectory) {
        if(rootDirectory == null || !rootDirectory.isDirectory()){
            throw new IllegalArgumentException("rootDirectory does not exist or is not a directory: " + rootDirectory);
        }
        this.rootDirectory = rootDirectory;
    }

    public void generateReport() throws Exception{
        instancePdfRenderer = new PdfRenderer(new File(rootDirectory, "metrics-" + rootDirectory.getName() + "-instance-rpt.pdf"));
        taskPdfRenderer = new PdfRenderer(new File(rootDirectory, "metrics-" + rootDirectory.getName() + "-task-rpt.pdf"));
        
        instancePdfRenderer.printText("Metrics Report for " + rootDirectory.getName(), PdfRenderer.titleFont);
        taskPdfRenderer.printText("Metrics Report for " + rootDirectory.getName(), PdfRenderer.titleFont);
        
        parseFiles();
        
        log.info("Instance Metrics");
        dump(instanceMetrics);

        dumpTopTen(instancePdfRenderer, "Top " + TOP_N_INSTANCE + " for instance: ", instanceTopNList);
        
        JFreeChart histogram = generateHistogram("instance", subTaskExecTimes);

        if(histogram != null){
            chart2Png(histogram, new File(rootDirectory,"exec-time-hist-" + rootDirectory.getName() + ".png"));
            instancePdfRenderer.printChart(histogram, CHART_WIDTH, CHART_HEIGHT);
        }else{
            instancePdfRenderer.printText("No data points available");
        }
        
        JFreeChart boxNWhiskers = generateBoxAndWhiskers();
        chart2Png(boxNWhiskers, new File(rootDirectory,"exec-time-bnw-instance.png"));
        
        instancePdfRenderer.printChart(boxNWhiskers, CHART_WIDTH, CHART_HEIGHT);
        
        instancePdfRenderer.close();
        taskPdfRenderer.close();
        }

    @SuppressWarnings("unused")
    private void chart2Png(JFreeChart chart, File outputPngFile) throws Exception{
//        FileOutputStream fos = new FileOutputStream(outputPngFile);
//        BufferedOutputStream bos = new BufferedOutputStream(fos);
//        ChartUtilities.writeChartAsPNG(bos, chart, 800, 600);
//        bos.close();
//        fos.close();
    }
    
    private void parseFiles() throws Exception{
        File[] taskDirs = rootDirectory.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().contains("-matlab-") && f.isDirectory());
            }
        });
        
        int tasksProcessed = 0;
        
        for (File taskDir : taskDirs) {
            if(maxTasks > 0 && tasksProcessed >= maxTasks){
                continue;
            }
            
            log.info("Processing: " + taskDir);
            
            tasksProcessed++;
            
            String taskDirName = taskDir.getName();
            Map<String, Metric> taskMetrics = taskMetricsMap.get(taskDirName);
            TopNList taskTopNList = new TopNList(TOP_N_TASKS);

            if(taskMetrics == null){
                taskMetrics = new HashMap<String,Metric>();
                taskMetricsMap.put(taskDirName, taskMetrics);
            }
            
            File[] subTaskDirs = taskDir.listFiles(new FileFilter(){
                @Override
                public boolean accept(File pathname) {
                    return pathname.getName().startsWith("st-") && pathname.isDirectory();
                }
            });
            
            if(subTaskDirs != null){
                log.info("Found " + subTaskDirs.length + " sub-task directories");
            }else{
                log.info("No sub-task directories found");               
            }
            
            for (File subTaskDir : subTaskDirs) {
                File subTaskMetricsFile = new File(subTaskDir, METRICS_FILE_NAME);
                
                if(subTaskMetricsFile.exists()){
                    Map<String, Metric> subTaskMetrics = Metric.loadMetricsFromSerializedFile(subTaskMetricsFile);
                    
                    for (Metric metric : subTaskMetrics.values()) {
                        // merge this metric into the instance metrics
                        merge(metric, instanceMetrics);
                        // merge this metric into the task metrics
                        merge(metric, taskMetrics);
                        
                        if(metric.getName().equals(totalTimeMetricName)){
                            IntervalMetric totalTimeMetric = (IntervalMetric)metric; 
                            int execTime = (int)totalTimeMetric.getAverage();
                            instanceTopNList.add(execTime, taskDirName + "/" + subTaskDir.getName());
                            taskTopNList.add(execTime, taskDirName + "/" + subTaskDir.getName());                            
                            addExecTime(taskDirName, totalTimeMetric.getAverage());
                        }
                    }
                }else{
                    log.warn("No metrics file found in: " + subTaskDir);
                }
            }
            
            log.info("Metrics for: " + taskDirName);
            dumpTopTen(taskPdfRenderer, "Top " + TOP_N_TASKS + " for task: " + taskDirName, taskTopNList);
            
            List<Double> taskExecTimes = subTaskExecTimesByTask.get(taskDirName);            
            JFreeChart histogram = generateHistogram(taskDirName, taskExecTimes);
            
            if(histogram != null){
                chart2Png(histogram, new File(rootDirectory,"exec-time-hist-" + taskDirName + ".png"));
                taskPdfRenderer.printChart(histogram, CHART_WIDTH, CHART_HEIGHT);            
                taskPdfRenderer.newPage();
            }else{
                taskPdfRenderer.printText("No data points available");
            }

        }
    }
    
    
    private void addExecTime(String taskDirName, double execTime){
        List<Double> timesForTask = subTaskExecTimesByTask.get(taskDirName);
        if(timesForTask == null){
            timesForTask = new ArrayList<Double>(5000);
            subTaskExecTimesByTask.put(taskDirName, timesForTask);
        }
        
        double timeHours = execTime / 1000.0 /3600.0; // convert to hours
        timesForTask.add(timeHours);
        subTaskExecTimes.add(timeHours);
    }
    
    private double[] listToArray(List<Double> list){
        if(list == null || list.size() == 0){
            return new double[0];
        }
        
        double[] array = new double[list.size()];
        int index = 0;
        
        for (Double value : list) {
            array[index++] = value;
        }
        
        return array;
    }
    
    private JFreeChart generateHistogram(String label, List<Double> execTimes) throws Exception {
        if(execTimes == null || execTimes.size() == 0){
            return null;
        }
        
        double[] values = listToArray(execTimes);

        HistogramDataset dataset = new HistogramDataset();
        dataset.setType(HistogramType.RELATIVE_FREQUENCY);
        dataset.addSeries("execTime", values, NUM_BINS);
        
        JFreeChart chart = ChartFactory.createHistogram(
            "Algorithm Run-time (" + label + ")",
            "execTime (hours)",
            "Number of Sub-tasks",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false);
        XYPlot plot = (XYPlot) chart.getPlot();
        plot.setDomainPannable(true);
        plot.setRangePannable(true);
        plot.setForegroundAlpha(0.85f);
        NumberAxis yAxis = (NumberAxis) plot.getRangeAxis();
        yAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        XYBarRenderer renderer = (XYBarRenderer) plot.getRenderer();
        renderer.setDrawBarOutline(false);
        // flat bars look best...
        renderer.setBarPainter(new StandardXYBarPainter());
        renderer.setShadowVisible(false);
        
        return chart;
    }
    
    private JFreeChart generateBoxAndWhiskers() throws Exception{
        DefaultBoxAndWhiskerCategoryDataset dataset = new DefaultBoxAndWhiskerCategoryDataset();
        
        Set<String> taskNames = subTaskExecTimesByTask.keySet();
        for (String taskName : taskNames) {
            log.info("taskDirName = " + taskName);
            List<Double> execTimesForTask = subTaskExecTimesByTask.get(taskName);
            dataset.add(BoxAndWhiskerCalculator.calculateBoxAndWhiskerStatistics(execTimesForTask),
                taskName, taskName);            
        }
        
        JFreeChart chart = ChartFactory.createBoxAndWhiskerChart("Run Time Distribution by Sky Group", "Sky Group", "Run Time (hours)",
            dataset, false);
        
        CategoryPlot plot = (CategoryPlot) chart.getPlot();
        plot.setDomainGridlinesVisible(true);
        
        return chart;
    }

    private void merge(Metric metricToMerge, Map<String,Metric> mergeDestination){
        String metricName = metricToMerge.getName();
        Metric existingMetric = mergeDestination.get(metricName);
        if(existingMetric == null){
            // first time seeing this metric
            mergeDestination.put(metricName, metricToMerge.makeCopy());
        }else{
            existingMetric.merge(metricToMerge);
        }
    }
    
    private void dump(Map<String,Metric> metrics){
        for (Metric metric : metrics.values()) {
            log.info(metric.getName() + ": " + metric.toString());
        }
    }
    
    private void dumpTopTen(PdfRenderer pdfRenderer, String title, TopNList topTenList) throws Exception{
        List<TopNListElement> list = topTenList.getList();
        
        pdfRenderer.printText("Top Stragglers", PdfRenderer.h1Font);
        pdfRenderer.printText(title);

        int index = 1;
        for (TopNListElement element : list) {
            String duration = DurationFormatUtils.formatDuration(element.getValue(), "HH:mm:ss");
            pdfRenderer.printText(index + " - " + element.getLabel() + ": " + duration);
            index++;
        }
    }
    
    public static void main(String[] args) throws Exception {
        InstanceMetricsReport report = new InstanceMetricsReport(new File("/path/to/tps-5461/partial"));
        //InstanceMetricsReport report = new InstanceMetricsReport(new File("/path/to/tps-5461/full"));
        report.generateReport();
    }
}
