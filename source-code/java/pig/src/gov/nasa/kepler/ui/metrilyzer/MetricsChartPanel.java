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

package gov.nasa.kepler.ui.metrilyzer;
import gov.nasa.kepler.hibernate.metrics.MetricValue;

import java.awt.Color;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.time.TimeSeriesCollection;

/**
 * Contains the metrics chart and chart controls.
 * Supports:
 * - add metric to chart
 * - remove metric from chart
 * - set time window( end time, num samples)
 * 
 * @author tklaus
 */
@SuppressWarnings("serial")
public class MetricsChartPanel extends ChartPanel {
    private static Log log = LogFactory.getLog(MetricsChartPanel.class);

    private JFreeChart chart = null;
    private TimeSeriesCollection dataset = new TimeSeriesCollection();
    
    public MetricsChartPanel() {
        super(ChartFactory.createTimeSeriesChart(
                null,
                "Time", "Value",
                new TimeSeriesCollection(),
                true,
                true,
                false));
        
        chart = getChart();
        
        XYPlot plot = (XYPlot) chart.getPlot();
        dataset = (TimeSeriesCollection) plot.getDataset();
        XYItemRenderer r = plot.getRenderer();
        
        if (r instanceof XYLineAndShapeRenderer) {
            XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) r;
            renderer.setBaseShapesVisible(true);
            renderer.setBaseShapesFilled(true);
        }
        
        chart.setBackgroundPaint(getBackground());
        plot.setBackgroundPaint(Color.WHITE);
        plot.setDomainGridlinePaint(Color.GRAY);
        plot.setRangeGridlinePaint(Color.GRAY);
    }
    
    public void clearChart(){
        dataset.removeAllSeries();
    }
    
//    public void legendVisibility(boolean visible){
//        chart.
//    }

    /**
     * 
     * TODO add method comments...
     * 
     * @param name
     * @param dataset
     */
    public void addMetric( String name, Collection<MetricValue> metricList, int binSizeMillis ){
        if( metricList == null){
            log.error( "sampleList is null");
            return;
        }
        
        if( metricList.size() == 0 ){
            log.error( "sampleList is empty");
            return;
        }
        
        // partition by hostname
        HashMap< String,LinkedList<MetricValue> > byHost = new HashMap< String,LinkedList<MetricValue> >();
        for (MetricValue sample : metricList) {
            LinkedList<MetricValue> listForHost = byHost.get( sample.getSource() );
            if( listForHost == null ){
                listForHost = new LinkedList<MetricValue>();
                byHost.put( sample.getSource(), listForHost );
            }
            listForHost.add( sample );
        }
        
        SampleList samples = new SampleList();
        
        for (List<MetricValue> listForHost : byHost.values()) {
            samples.ingest( listForHost );
        }

        if( binSizeMillis > 0 ){
            samples.bin( binSizeMillis );
        }

        log.debug("adding series["+name+"] to dataset, #samples = " + samples.size());
        dataset.addSeries( samples.asTimeSeries( name ));
    }

}
