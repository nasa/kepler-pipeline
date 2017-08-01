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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JPanel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link JDialog} wrapper for the {@link ParameterSetSelectorPanel}
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ParameterSetSelectorDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ParameterSetSelectorDialog.class);

    private Class<? extends Parameters> filterClass;
    private JPanel dataPanel;
    private JButton cancelButton;
    private JButton selectButton;
    private JPanel actionPanel;
    private ParameterSetSelectorPanel parameterSetSelectorPanel;

    private boolean cancelled = false;

    public ParameterSetSelectorDialog(JFrame frame) {
        super(frame, true);
        this.filterClass = null;
        initGUI();
    }

    public ParameterSetSelectorDialog(JFrame frame, Class<? extends Parameters> filterClass) {
        super(frame, true);
        this.filterClass = filterClass;
        initGUI();
    }

    /**
     * Select a parameter set of the specified type from the parameter set library
     * 
     * @param filterClass
     * @return
     */
    public static ParameterSet selectParameterSet(Class<? extends Parameters> filterClass) {

        ParameterSetSelectorDialog dialog = new ParameterSetSelectorDialog(PipelineConsole.instance, filterClass);
        dialog.setVisible(true); // blocks until user presses a button

        if (!dialog.cancelled) {
            return dialog.parameterSetSelectorPanel.getSelected();
        } else {
            return null;
        }
    }

    /**
     * Select a parameter set from the parameter set library with no filtering
     * 
     * @return
     */
    public static ParameterSet selectParameterSet() {

        ParameterSetSelectorDialog dialog = new ParameterSetSelectorDialog(PipelineConsole.instance);
        dialog.setVisible(true); // blocks until user presses a button

        if (!dialog.cancelled) {
            return dialog.parameterSetSelectorPanel.getSelected();
        } else {
            return null;
        }
    }

    // private void initGUI() {
    // try {
    // {
    // this.setTitle("Select Parameter Set");
    // }
    // {
    // dataPanel = new JPanel();
    // BorderLayout dataPanelLayout = new BorderLayout();
    // getContentPane().add(dataPanel, BorderLayout.CENTER);
    // dataPanel.setLayout(dataPanelLayout);
    // {
    // parameterSetSelectorPanel = new ParameterSetSelectorPanel(filterClass);
    // dataPanel.add(parameterSetSelectorPanel, BorderLayout.CENTER);
    // }
    // }
    // {
    // actionPanel = new JPanel();
    // FlowLayout actionPanelLayout = new FlowLayout();
    // actionPanelLayout.setHgap(40);
    // actionPanel.setLayout(actionPanelLayout);
    // getContentPane().add(actionPanel, BorderLayout.SOUTH);
    // {
    // selectButton = new JButton();
    // actionPanel.add(selectButton);
    // selectButton.setText("Select");
    // selectButton.addActionListener(new ActionListener() {
    // public void actionPerformed(ActionEvent evt) {
    // selectButtonActionPerformed(evt);
    // }
    // });
    // }
    // {
    // cancelButton = new JButton();
    // actionPanel.add(cancelButton);
    // cancelButton.setText("Cancel");
    // cancelButton.addActionListener(new ActionListener() {
    // public void actionPerformed(ActionEvent evt) {
    // cancelButtonActionPerformed(evt);
    // }
    // });
    // }
    // }
    // this.setSize(281, 203);
    // } catch (Exception e) {
    // e.printStackTrace();
    // }
    // }
    private void initGUI() {
        try {
            {
                this.setTitle("Select Parameter Set");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            }
            this.setSize(300, 600);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void selectButtonActionPerformed(ActionEvent evt) {
        log.debug("selectButton.actionPerformed, event=" + evt);

        setVisible(false);
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event=" + evt);

        cancelled = true;
        setVisible(false);
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getParameterSetSelectorPanel(), BorderLayout.CENTER);
        }
        return dataPanel;
    }

    private ParameterSetSelectorPanel getParameterSetSelectorPanel() {
        if (parameterSetSelectorPanel == null) {
            parameterSetSelectorPanel = new ParameterSetSelectorPanel(filterClass);
        }
        return parameterSetSelectorPanel;
    }

    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(40);
            actionPanelLayout.setHgap(40);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getSelectButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }

    private JButton getSelectButton() {
        if (selectButton == null) {
            selectButton = new JButton();
            selectButton.setText("Select");
            selectButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    selectButtonActionPerformed(evt);
                }
            });
        }
        return selectButton;
    }

    private JButton getCancelButton() {
        if (cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }
}
