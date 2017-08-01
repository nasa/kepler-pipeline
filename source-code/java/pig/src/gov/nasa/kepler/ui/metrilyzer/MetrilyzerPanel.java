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

import gov.nasa.kepler.services.metrics.MetricsFileParser;

import java.awt.BorderLayout;

/**
 * Contains the metrics selection panel and the chart panel.
 * @author tklaus
 * @author Sean McCauliff
 * 
 */
@SuppressWarnings("serial")
public class MetrilyzerPanel extends javax.swing.JPanel {

    private MetricsSelectorPanel selectorPanel = null;
    private MetricsChartPanel chartPanel = null;
    private final MetricTypeListModel availMetricsModel;
    private final MetricTypeListModel selectedMetricsModel;
    private final MetricsValueSource metricValueSource;

    /**
     * Use the database to get the metrics and their types.
     */
    public MetrilyzerPanel() {
        availMetricsModel = new DatabaseMetricsTypeListModel();
        selectedMetricsModel = new DatabaseMetricsTypeListModel();
        metricValueSource = new DatabaseMetricsValueSource();
        initGUI();
    }

    /**
     * Get metrics from a file.
     * @param metricsFileParser
     */
    public MetrilyzerPanel(MetricsFileParser metricsFileParser) {
        availMetricsModel = new FileSourceMetricsTypeListModel(metricsFileParser);
        selectedMetricsModel = new FileSourceMetricsTypeListModel(metricsFileParser);
        metricValueSource = new FileMetricsValueSource(metricsFileParser);
        initGUI();
    }
    
    private void initGUI() {
        try {
            BorderLayout thisLayout = new BorderLayout();
            this.setLayout(thisLayout);
            this.add(getChartPanel(), BorderLayout.CENTER);
            this.add(getSelectorPanel(), BorderLayout.NORTH);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private MetricsSelectorPanel getSelectorPanel() {
        if (selectorPanel == null) {
            selectorPanel = 
                new MetricsSelectorPanel(availMetricsModel, selectedMetricsModel, metricValueSource, chartPanel);
        }
        return selectorPanel;
    }

    private MetricsChartPanel getChartPanel() {
        if (chartPanel == null) {
            chartPanel = new MetricsChartPanel();
        }
        return chartPanel;
    }
}
