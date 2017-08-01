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
import java.io.File;

import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UIManager.LookAndFeelInfo;
import javax.swing.WindowConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Frame and main() for running the Metrilyzer as a
 * standalone app.
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class MetrilyzerMainFrame extends javax.swing.JFrame {
    private static final Log log = LogFactory.getLog(MetrilyzerMainFrame.class);

    private MetrilyzerPanel metrilyzerPanel = null;
    private final MetricsFileParser metricsFileParser;
    
    /**
     * 
     * @param metricsFileParser  this may be null
     */
    public MetrilyzerMainFrame(MetricsFileParser metricsFileParser) {
        this.metricsFileParser = metricsFileParser;
        initGUI();
    }
    
    private void initGUI() {
        setTitle("Metrics Analysis Tool");
        BorderLayout thisLayout = new BorderLayout();
        this.getContentPane().setLayout(thisLayout);
        setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        this.getContentPane().add(getMetrilyzerPanel(), BorderLayout.CENTER);
        pack();
        setSize(1024, 768);
    }
    
    private MetrilyzerPanel getMetrilyzerPanel() {
        if (metrilyzerPanel == null) {
            if (metricsFileParser == null) {
                metrilyzerPanel = new MetrilyzerPanel();
            } else {
                metrilyzerPanel = new MetrilyzerPanel(metricsFileParser);
            }
        }
        return metrilyzerPanel;
    }
    
    /**
    *  Main method to display this JFrame.
    */
    public static void main(String[] args) {
        File metricsFile = null;
        if (args.length != 0) {
            metricsFile = new File(args[0]);
        }
        
        final MetricsFileParser metricsFileParser = 
            (metricsFile == null) ? null : new MetricsFileParser(metricsFile);
        
        try {
            SwingUtilities.invokeAndWait(new Runnable() {
            @Override
            public void run() {
                try {
//                    PlasticLookAndFeel.setMyCurrentTheme(new SkyBluer());
//                    javax.swing.UIManager.setLookAndFeel("com.jgoodies.looks.plastic.Plastic3DLookAndFeel");

                    for (LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
                        if ("Nimbus".equals(info.getName())) {
                            UIManager.setLookAndFeel(info.getClassName());
                            break;
                        }
                    }
                    MetrilyzerMainFrame mf = new MetrilyzerMainFrame(metricsFileParser);
                    mf.setVisible( true );
                    
                } catch (Exception e) {
                    log.error("main", e);
                }
            }});
        } catch (Throwable t) {
            log.error("This error is lame.", t);
        }
    }
    
}
