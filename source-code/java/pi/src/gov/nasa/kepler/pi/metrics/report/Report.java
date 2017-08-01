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

import gov.nasa.kepler.pi.common.DisplayModel;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.labels.StandardCategoryItemLabelGenerator;
import org.jfree.chart.labels.StandardCategoryToolTipGenerator;
import org.jfree.chart.labels.StandardPieSectionLabelGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.category.StackedBarRenderer;
import org.jfree.chart.renderer.xy.StandardXYBarPainter;
import org.jfree.chart.renderer.xy.XYBarRenderer;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.general.PieDataset;
import org.jfree.data.statistics.HistogramDataset;
import org.jfree.data.statistics.HistogramType;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Element;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

/**
 * Base class for top-level elements of the performance report
 * 
 * @author tklaus
 */
public abstract class Report {
    private static final Log log = LogFactory.getLog(Report.class);

    // full width, short
    protected static final int CHART1_HEIGHT = 320;
    protected static final int CHART1_WIDTH = 700;

    // full width, tall height
    protected static final int CHART2_HEIGHT = 500;
    protected static final int CHART2_WIDTH = 700;

    // full width, normal height
    protected static final int CHART3_HEIGHT = 400;
    protected static final int CHART3_WIDTH = 700;

    protected PdfRenderer pdfRenderer;

    public Report(PdfRenderer pdfRenderer) {
        this.pdfRenderer = pdfRenderer;
    }

    protected void addCell(PdfPTable table, String s){
        addCell(table, s, false, 1);
    }
    
    protected void addCell(PdfPTable table, String s, boolean bold){
        addCell(table, s, bold, 1);
    }

    protected void addCell(PdfPTable table, String s, int columnSpan){
        addCell(table, s, false, columnSpan);
    }

    protected void addCell(PdfPTable table, String s, boolean bold, int columnSpan){
        PdfPCell cell = null;
        
        if(bold){
            cell = new PdfPCell(new Phrase(s, PdfRenderer.bodyBoldFont));
        }else{
            cell = new PdfPCell(new Phrase(s, PdfRenderer.bodyFont));
        }

        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setColspan(columnSpan);
        cell.setBorder(Rectangle.NO_BORDER);

        if(table.getLastCompletedRowIndex() % 2 == 0){
            cell.setBackgroundColor(new BaseColor(240,240,240));
        }
        
        table.addCell(cell);    
    }
    
    protected Pair<String, List<Double>> millisToHumanReadable(DescriptiveStatistics stats) {

        double mean = stats.getMean();
        
        long MINUTE = 60000; // 60,000    = 1m
        long HOUR = 3600000; // 3,600,000 = 1h
        
        String units = "s"; 
        long divisor = 1000;
        
        if(mean > HOUR){
            units = "h";
            divisor = HOUR;
        }else if(mean > MINUTE){
            units = "m";
            divisor = MINUTE;
        }
        
        return toHumanReadable(stats, units, divisor);
    }

    protected Pair<String, List<Double>> toHumanReadable(DescriptiveStatistics stats, String units, double divisor) {
        double[] values = stats.getValues();
        
        List<Double> list = new ArrayList<Double>((int) stats.getN());
        for (double v : values) {
            double convertedValue = v / divisor;
            list.add(convertedValue);
        }
        
        return Pair.of(units, list);
    }

    protected void dumpTopTen(PdfPTable pdfTable, TopNList topTenList, Format f) throws Exception{
        List<TopNListElement> list = topTenList.getList();
        
        PdfPTable topTenTable = new PdfPTable(2);

        addCell(topTenTable, "Top 10", true, 2);

        int[] indexOrder = new int[]{0,5,1,6,2,7,3,8,4,9};
        
        for (int index = 0; index < indexOrder.length; index++) {
            int elementIndex = indexOrder[index];
            int displayIndex = elementIndex + 1;
            
            if(elementIndex < list.size()){
                TopNListElement element = list.get(elementIndex);
                
                String value = f.format(element.getValue()); 
                
                addCell(topTenTable, displayIndex + " - " + element.getLabel() + ": " + value);
            }else{
                addCell(topTenTable, " ");
            }
        }

        PdfPCell cell = new PdfPCell(topTenTable);
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setBackgroundColor(new BaseColor(240,240,240));
        
        pdfTable.addCell(cell);
    }

    protected String formatTime(long timeMillis){
        return DurationFormatUtils.formatDuration(timeMillis, "HH:mm:ss");
    }

    protected void generateSummaryTable(String label, DescriptiveStatistics stats, TopNList topTen, Format f) throws Exception{
        log.info("Generating report for: " + label);            

        PdfPTable layoutTable = new PdfPTable(2);        
        PdfPTable statsTable = new PdfPTable(2);
        
        addCell(statsTable, "Mean", true);
        addCell(statsTable, f.format(stats.getMean()));

        addCell(statsTable, "Median", true);
        addCell(statsTable, f.format(stats.getPercentile(50)));

        addCell(statsTable, "Min", true);
        addCell(statsTable, f.format(stats.getMin()));

        addCell(statsTable, "Max", true);
        addCell(statsTable, f.format(stats.getMax()));

        addCell(statsTable, "Sum", true);
        addCell(statsTable, f.format(stats.getSum()));

        addCell(statsTable, "StdDev", true);
        addCell(statsTable, f.format(stats.getStandardDeviation()));

        addCell(statsTable, "90%", true);
        addCell(statsTable, f.format(stats.getPercentile(90)));

        addCell(statsTable, "N", true);                
        addCell(statsTable, String.format("%d", stats.getN()));
                        
        PdfPCell cell = new PdfPCell(statsTable);
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setBackgroundColor(new BaseColor(240,240,240));
        
        layoutTable.addCell(cell);

        dumpTopTen(layoutTable, topTen, f);        

        pdfRenderer.add(layoutTable);        
    }

    protected JFreeChart generateHistogram(String title, String xCaption, String yCaption, List<Double> values, int numBins) throws Exception {
        if(values == null || values.size() == 0){
            return null;
        }
        
        double[] valuesArray = listToArray(values);

        HistogramDataset dataset = new HistogramDataset();
        dataset.setType(HistogramType.FREQUENCY);
        dataset.addSeries(yCaption, valuesArray, numBins);
        
        JFreeChart chart = ChartFactory.createHistogram(
            title,
            xCaption,
            yCaption,
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

    protected JFreeChart generateStackedBarChart(String title, String xCaption, String yCaption, CategoryDataset dataset) {

        JFreeChart chart = ChartFactory.createStackedBarChart(title, xCaption, yCaption, dataset, PlotOrientation.VERTICAL,
            true,                        // legend
            false,                       // tooltips
            false                        // urls
        );
        
        CategoryPlot plot = (CategoryPlot) chart.getPlot();
        StackedBarRenderer renderer = (StackedBarRenderer) plot.getRenderer(); //new StackedBarRenderer();
        renderer.setBaseItemLabelsVisible(true);
        renderer.setBaseItemLabelGenerator(
                new StandardCategoryItemLabelGenerator());
        renderer.setBaseToolTipGenerator(
                new StandardCategoryToolTipGenerator());
        plot.setRenderer(renderer);

        renderer.setDrawBarOutline(true);

        return chart;
    }

    protected JFreeChart generatePieChart(String title, PieDataset dataset) {

        JFreeChart chart = ChartFactory.createPieChart(title, dataset,
            true,                // include legend
            true,
            false);

        PiePlot plot = (PiePlot) chart.getPlot();
        StandardPieSectionLabelGenerator labelGenerator = new StandardPieSectionLabelGenerator("{2}");
        plot.setLabelGenerator(labelGenerator);
        plot.setLabelFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 12));
        plot.setNoDataMessage("No data available");
        plot.setCircular(false);
        plot.setLabelGap(0.02);
        return chart;

    }
    
    protected void printDisplayModel(String title, DisplayModel displayModel) throws Exception{
        printDisplayModel(title, displayModel, null);
    }
    
    protected void printDisplayModel(String title, DisplayModel displayModel, float[] colsWidth) throws Exception{
        pdfRenderer.printText(title, PdfRenderer.h1Font);
        pdfRenderer.println();
        
        PdfPTable table;
        
        if(colsWidth != null){
            table = new PdfPTable(colsWidth);
        }else{
            table = new PdfPTable(displayModel.getColumnCount());
        }
        
        table.setWidthPercentage(100);

        for (int i = 0; i < displayModel.getColumnCount(); i++) {
            addCell(table, displayModel.getColumnName(i), true);
        }

        for (int row = 0; row < displayModel.getRowCount(); row++) {
           for (int col = 0; col < displayModel.getColumnCount(); col++) {
               addCell(table,displayModel.getValueAt(row, col).toString(), false);
           }
        }
        
        pdfRenderer.add(table);
    }
    
    
    protected double[] listToArray(List<Double> list){
        if(list == null || list.size() == 0){
            return new double[0];
        }
        
        double[] array = new double[list.size()];
        int index = 0;
        
        for (double value : list) {
            array[index++] = value;
        }
        
        return array;
    }

    protected List<Double> arrayToList(double[] array){
        return arrayToList(array, 1.0);
    }

    protected List<Double> arrayToList(double[] array, double multiplier){
        if(array == null || array.length == 0){
            return new ArrayList<Double>(0);
        }
        
        ArrayList<Double> list = new ArrayList<Double>(array.length);
        
        for (int i = 0; i < array.length; i++) {
            list.add(array[i] * multiplier);
        }
        return list;
    }    
}
