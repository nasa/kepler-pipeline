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

package gov.nasa.kepler.ui;

import gov.nasa.kepler.common.KeplerSocVersion;

import java.awt.BorderLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * About dialog for the PIG
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
@SuppressWarnings("serial")
public class AboutPigDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(AboutPigDialog.class);

    private JPanel dataPanel;
    private JLabel projectLabel;
    private JLabel revisionLabel;
    private JLabel pigLabel;
    private JLabel buildDateLabel;
    private JLabel svnUrlLabel;
    private JLabel releaseLabel;
    private JLabel keplerImageLabel;
    private JButton closeButton;
    private JPanel buttonPanel;

    public AboutPigDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }
    
    private void initGUI() {
        try {
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            getContentPane().add(getKeplerImageLabel(), BorderLayout.WEST);
            getContentPane().add(getPigLabel(), BorderLayout.EAST);
            this.setSize(646, 185);
            this.setTitle("Kepler SOC PIpeline Gui");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7};
            dataPanelLayout.columnWeights = new double[] {0.1};
            dataPanelLayout.columnWidths = new int[] {7};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getProjectLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getReleaseLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getSvnUrlLabel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getRevisionLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getBuildDateLabel(), new GridBagConstraints(0, 4, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            buttonPanel.add(getCloseButton());
        }
        return buttonPanel;
    }
    
    private JButton getCloseButton() {
        if(closeButton == null) {
            closeButton = new JButton();
            closeButton.setText("close");
            closeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    closeButtonActionPerformed(evt);
                }
            });
        }
        return closeButton;
    }
    
    private void closeButtonActionPerformed(ActionEvent evt) {
        log.debug("closeButton.actionPerformed, event="+evt);
        setVisible(false);
        this.setTitle("Kepler Science Pipeline Console");
    }
    
    private JLabel getKeplerImageLabel() {
        if(keplerImageLabel == null) {
            keplerImageLabel = new JLabel();
            keplerImageLabel.setIcon(new ImageIcon(getClass().getClassLoader().getResource("images/kepler-logo-sm.png")));
            keplerImageLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        }
        return keplerImageLabel;
    }
    
    
    private JLabel getPigLabel() {
        if(pigLabel == null) {
            pigLabel = new JLabel();
            pigLabel.setIcon(new ImageIcon(getClass().getClassLoader().getResource("images/pig.jpg")));
            pigLabel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        }
        return pigLabel;
    }

    private JLabel getProjectLabel() {
        if(projectLabel == null) {
            projectLabel = new JLabel();
            projectLabel.setText("Project: " + KeplerSocVersion.getProject());
            projectLabel.setFont(new java.awt.Font("Dialog",1,12));
        }
        return projectLabel;
    }
    
    private JLabel getReleaseLabel() {
        if(releaseLabel == null) {
            releaseLabel = new JLabel();
            releaseLabel.setText("Release: " + KeplerSocVersion.getRelease());
            releaseLabel.setFont(new java.awt.Font("Dialog",1,12));
        }
        return releaseLabel;
    }
    
    private JLabel getSvnUrlLabel() {
        if(svnUrlLabel == null) {
            svnUrlLabel = new JLabel();
            svnUrlLabel.setText("Subversion URL: " + KeplerSocVersion.getUrl());
            svnUrlLabel.setFont(new java.awt.Font("Dialog",1,12));
        }
        return svnUrlLabel;
    }
    
    private JLabel getRevisionLabel() {
        if(revisionLabel == null) {
            revisionLabel = new JLabel();
            revisionLabel.setText("Subversion Revision: " + KeplerSocVersion.getRevision());
            revisionLabel.setFont(new java.awt.Font("Dialog",1,12));
        }
        return revisionLabel;
    }
    
    private JLabel getBuildDateLabel() {
        if(buildDateLabel == null) {
            buildDateLabel = new JLabel();
            buildDateLabel.setText("Built: " + KeplerSocVersion.getBuildDate());
            buildDateLabel.setFont(new java.awt.Font("Dialog",1,12));
        }
        return buildDateLabel;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 AboutPigDialog inst = new AboutPigDialog(frame);
                 inst.setVisible(true);
             }
         });
     }
}
