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

import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics.Units;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.jfree.chart.JFreeChart;
import org.jfree.data.category.DefaultCategoryDataset;

import com.itextpdf.text.pdf.PdfPTable;

public class NodeReport extends Report {
    private static final Log log = LogFactory.getLog(NodeReport.class);
    private List<String> orderedCategoryNames;
    private Map<String, DescriptiveStatistics> categoryStats;
    private Map<String, TopNList> categoryTopTen;
    private Map<String, Units> categoryUnits;
    
    public NodeReport(PdfRenderer pdfRenderer) {
        super(pdfRenderer);
    }

    public void generateReport(PipelineInstanceNode node, List<PipelineTask> tasks) throws Exception{
        String moduleName = node.getPipelineModuleDefinition().getName().getName();
        pdfRenderer.printText("Pipeline Module: " + moduleName, PdfRenderer.h1Font);

        categoryStats = new HashMap<String, DescriptiveStatistics>();
        categoryTopTen = new HashMap<String, TopNList>();
        
        Map<String, List<Pair<Long, Long>>> categoryMetrics = new HashMap<String,List<Pair<Long,Long>>>();
        categoryUnits = new HashMap<String, Units>();
        
        orderedCategoryNames = new LinkedList<String>();
        
        for (PipelineTask task : tasks) {
            List<PipelineTaskMetrics> taskMetrics = task.getSummaryMetrics();
            
            for (PipelineTaskMetrics taskMetric : taskMetrics) {

                String category = taskMetric.getCategory();

                categoryUnits.put(category, taskMetric.getUnits());
                
                long value = taskMetric.getValue();

                if(!orderedCategoryNames.contains(category)){
                    orderedCategoryNames.add(category);
                }

                DescriptiveStatistics stats = categoryStats.get(category);
                
                if(stats == null){
                    stats = new DescriptiveStatistics();
                    categoryStats.put(category, stats);
                }
                
                stats.addValue(value);
                
                TopNList topTen = categoryTopTen.get(category);
                
                if(topTen == null){
                    topTen = new TopNList(10);
                    categoryTopTen.put(category, topTen);
                }
                
                topTen.add(value, "ID: "+task.getId());
                
                List<Pair<Long, Long>> valueList = categoryMetrics.get(category);
                
                if(valueList == null){
                    valueList = new ArrayList<Pair<Long,Long>>(tasks.size());
                    categoryMetrics.put(category, valueList);
                }
                
                valueList.add(Pair.of(task.getId(), value));
                
            }
        }

        DefaultCategoryDataset categoryTaskDataset = new DefaultCategoryDataset();

        log.info("summary report");
        
        for (String category : orderedCategoryNames) {
            log.info("processing category: " + category);

            if(categoryIsTime(category)){
                List<Pair<Long, Long>> values = categoryMetrics.get(category);
                for (Pair<Long, Long> value : values) {
                    Long taskId = value.left;
                    Long valueMillis = value.right;
                    double valueMins = valueMillis / (1000.0 * 60); 
                    categoryTaskDataset.addValue(valueMins, category, taskId);
                }
            }
        }

        JFreeChart stackedBar = generateStackedBarChart("Wall Time Breakdown by Task and Category", "Tasks", "Time (mins)", categoryTaskDataset);

        pdfRenderer.printChart(stackedBar, CHART2_WIDTH, CHART2_HEIGHT);
        
        pdfRenderer.newPage();
        
        // task breakdown table
        pdfRenderer.printText("Wall Time Breakdown by Task and Category", PdfRenderer.h1Font);
        pdfRenderer.println();
        
        float[] colsWidth = {1.5f, 1f, 1f, 1f, 1f, 1f, 0.5f};
        PdfPTable breakdownTable = new PdfPTable(colsWidth);
        breakdownTable.setWidthPercentage(100);
        
        addCell(breakdownTable, "Category", true);
        addCell(breakdownTable, "Mean", true);
        addCell(breakdownTable, "Min", true);
        addCell(breakdownTable, "Max", true);
        addCell(breakdownTable, "StdDev", true);
        addCell(breakdownTable, "90%", true);
        addCell(breakdownTable, "N", true);

        for (String category : orderedCategoryNames) {
            if(categoryIsTime(category)){
                DescriptiveStatistics stats = categoryStats.get(category);
                
                addCell(breakdownTable, category);
                addCell(breakdownTable, formatValue(category, stats.getMean()));
                addCell(breakdownTable, formatValue(category, stats.getMin()));
                addCell(breakdownTable, formatValue(category, stats.getMax()));
                addCell(breakdownTable, formatValue(category, stats.getStandardDeviation()));
                addCell(breakdownTable, formatValue(category, stats.getPercentile(90)));
                addCell(breakdownTable, String.format("%d", stats.getN()));
            }
        }

        pdfRenderer.add(breakdownTable);        
    }

    protected String formatValue(String category, double value){
        if(categoryIsTime(category)){
            return formatTime((long) value);
        }else{
            return String.format("%.2f", value);
        }
    }    
    
    public boolean categoryIsTime(String category){
        Units units = categoryUnits.get(category);
        
        return (units != null && units == Units.TIME);
    }
    
    public List<String> getOrderedCategoryNames() {
        return orderedCategoryNames;
    }

    public Map<String, DescriptiveStatistics> getCategoryStats() {
        return categoryStats;
    }

    public Map<String, TopNList> getCategoryTopTen() {
        return categoryTopTen;
    }

    public Map<String, Units> getCategoryUnits() {
        return categoryUnits;
    }
}
