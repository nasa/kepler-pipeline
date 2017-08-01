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
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Map;
import java.util.Set;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JPanel;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ParameterSetMapEditorDialog extends javax.swing.JDialog implements ParameterSetMapEditorListener{
    private JPanel dataPanel;
    private ParameterSetMapEditorPanel parameterSetMapEditorPanel;
    private JButton closeButton;
    private JPanel buttonPanel;

    private Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters = null;
    private Set<ClassWrapper<Parameters>> requiredParameters;
    private Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters;

    private ParameterSetMapEditorListener mapListener;

    public ParameterSetMapEditorDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }
    
    public ParameterSetMapEditorDialog(JFrame frame, Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters,
        Set<ClassWrapper<Parameters>> requiredParameters,
        Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters) {
        super(frame, true);
        
        this.currentParameters = currentParameters;
        this.requiredParameters = requiredParameters;
        this.currentPipelineParameters = currentPipelineParameters;

        initGUI();
    }
    
    public ParameterSetMapEditorDialog(JDialog dialog, Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters,
        Set<ClassWrapper<Parameters>> requiredParameters,
        Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters) {
        super(dialog, true);
        
        this.currentParameters = currentParameters;
        this.requiredParameters = requiredParameters;
        this.currentPipelineParameters = currentPipelineParameters;

        initGUI();
    }
    
    private void initGUI() {
        try {
            {
                dataPanel = new JPanel();
                BorderLayout dataPanelLayout = new BorderLayout();
                getContentPane().add(dataPanel, BorderLayout.CENTER);
                dataPanel.setLayout(dataPanelLayout);
                {
                    parameterSetMapEditorPanel = new ParameterSetMapEditorPanel(currentParameters, requiredParameters, currentPipelineParameters);
                    parameterSetMapEditorPanel.setMapListener(this);
                    dataPanel.add(parameterSetMapEditorPanel, BorderLayout.CENTER);
                    parameterSetMapEditorPanel.setBorder(BorderFactory.createTitledBorder("Parameter Sets"));
                }
            }
            {
                buttonPanel = new JPanel();
                getContentPane().add(buttonPanel, BorderLayout.SOUTH);
                {
                    closeButton = new JButton();
                    buttonPanel.add(closeButton);
                    closeButton.setText("Close");
                    closeButton.addActionListener(new ActionListener() {
                        public void actionPerformed(ActionEvent evt) {
                            closeButtonActionPerformed(evt);
                        }
                    });
                }
            }
            this.setSize(536, 405);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void closeButtonActionPerformed(ActionEvent evt) {
        setVisible(false);
    }

    public ParameterSetMapEditorListener getMapListener() {
        return mapListener;
    }

    public void setMapListener(ParameterSetMapEditorListener mapListener) {
        this.mapListener = mapListener;
    }

    public void notifyMapChanged(Object source) {
        if(mapListener != null){
            mapListener.notifyMapChanged(this);
        }
    }

    public Map<ClassWrapper<Parameters>, ParameterSetName> getParameterSetsMap() {
        return parameterSetMapEditorPanel.getParameterSetsMap();
    }

}
