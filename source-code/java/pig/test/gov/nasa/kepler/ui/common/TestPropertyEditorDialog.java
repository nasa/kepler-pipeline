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

package gov.nasa.kepler.ui.common;
import gov.nasa.kepler.common.ui.PropertySheetHelper;
import gov.nasa.kepler.common.ui.TestBean;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.l2fprod.common.propertysheet.PropertySheetPanel;

@SuppressWarnings("serial")
public class TestPropertyEditorDialog extends javax.swing.JDialog {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TestPropertyEditorDialog.class);
    
    private JPanel dataPanel;
    private PropertySheetPanel propertySheetPanel;
    private JButton exitButton;
    private JPanel actionPanel;
    private TestBean currentParams = new TestBean();
    
    public TestPropertyEditorDialog(JFrame frame) {
        super(frame);
        initGUI();
    }
    
    private void initGUI() {
        try {
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            setSize(400, 300);

            populateParamsPropertySheet();
        
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void populateParamsPropertySheet() {

        if (currentParams != null) {
            try {
                PropertySheetHelper.populatePropertySheet(currentParams, propertySheetPanel);
            } catch (Exception e) {
                throw new PipelineException("Failed to introspect Parameters bean", e);
            }
        }
    }

    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getPropertySheetPanel(), BorderLayout.CENTER);
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            actionPanel.add(getExitButton());
        }
        return actionPanel;
    }
    
    private JButton getExitButton() {
        if(exitButton == null) {
            exitButton = new JButton();
            exitButton.setText("Vamoose!");
            exitButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exitButtonActionPerformed(evt);
                }
            });
        }
        return exitButton;
    }
    
    private void exitButtonActionPerformed(ActionEvent evt) {
        System.out.println("exitButton.actionPerformed, event="+evt);
        System.exit(1);
    }
    
    private PropertySheetPanel getPropertySheetPanel() {
        if(propertySheetPanel == null) {
            propertySheetPanel = new PropertySheetPanel();
        }
        return propertySheetPanel;
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                TestPropertyEditorDialog inst = new TestPropertyEditorDialog(frame);
                inst.setVisible(true);
            }
        });
    }
}
