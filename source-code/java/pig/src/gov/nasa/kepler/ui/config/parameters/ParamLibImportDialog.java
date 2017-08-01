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

package gov.nasa.kepler.ui.config.parameters;

import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor;
import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor.State;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.ops.instances.TextualReportDialog;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This dialog is used to import a parameter library from disk
 * into the parameter library in the database.
 * It is initialized by running the parameter library importer
 * in "dry run" mode, which tells the user what actions will 
 * take effect when the import is run for real.  The user can also
 * choose to exclude some of the parameter sets from the import if
 * desired.
 *   
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ParamLibImportDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ParamLibImportDialog.class);

    private JPanel dataPanel;
    private JButton importButton;
    private JButton reportButton;
    private ETable paramImportTable;
    private JScrollPane scrollPane;
    private JButton cancelButton;
    private JPanel buttonPanel;
    private ParamLibImportTableModel paramImportTableModel;
    private boolean cancelled = false;
    private List<ParameterSetDescriptor> dryRunResults = null;
    
    public ParamLibImportDialog(JFrame frame, List<ParameterSetDescriptor> dryRunResults) {
        super(frame, true);
        
        this.dryRunResults = dryRunResults;
        
        initGUI();
    }
    
    public static List<String> selectParamSet(JFrame frame, List<ParameterSetDescriptor> dryRunResults){
        ParamLibImportDialog dialog = new ParamLibImportDialog(frame, dryRunResults);
        dialog.setVisible(true); // blocks until user presses a button
        
        if(!dialog.cancelled){
            return dialog.paramImportTableModel.getExcludeList();
        }
        return null;
    }
    
    private void importButtonActionPerformed(ActionEvent evt) {
        log.debug("importButton.actionPerformed, event="+evt);
        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        cancelled = true;
        setVisible(false);
    }
    
    
    private void reportButtonActionPerformed(ActionEvent evt) {
        log.debug("reportButton.actionPerformed, event="+evt);
        
        StringBuilder report = new StringBuilder();
        
        List<String> excludes = paramImportTableModel.getExcludeList();
        Map<ParameterSetDescriptor.State,List<ParameterSetDescriptor>> binnedByState = 
            new HashMap<ParameterSetDescriptor.State, List<ParameterSetDescriptor>>();
        
        for (ParameterSetDescriptor d : dryRunResults) {
            String name = d.getName();
            State descState = d.getState();
            
            if(excludes.contains(name)){
                // override state since the user de-selected this one for import
                descState = ParameterSetDescriptor.State.IGNORE;
            }
            
            List<ParameterSetDescriptor> list = binnedByState.get(descState);
            if(list == null){
                list = new LinkedList<ParameterSetDescriptor>();
                binnedByState.put(descState, list);
            }
            list.add(d);
        }
        
        report.append("Parameter Sets to be Created:\n\n");
        appendToReport(report, binnedByState.get(ParameterSetDescriptor.State.CREATE));
        report.append("Parameter Sets to be Updated:\n\n");
        appendToReport(report, binnedByState.get(ParameterSetDescriptor.State.UPDATE));
        report.append("Parameter Sets in the library, but not in the export:\n\n");
        appendToReport(report, binnedByState.get(ParameterSetDescriptor.State.LIBRARY_ONLY));
        report.append("Parameter Sets that are the same (no change needed):\n\n");
        appendToReport(report, binnedByState.get(ParameterSetDescriptor.State.SAME));
        report.append("Parameter Sets to be Ignored (on the exclude list):\n\n");
        appendToReport(report, binnedByState.get(ParameterSetDescriptor.State.IGNORE));
        
        TextualReportDialog.showReport(this, report.toString());
    }
    
    private void appendToReport(StringBuilder report, List<ParameterSetDescriptor> descs){
                
        if(descs == null || descs.isEmpty()){
            report.append("NONE\n");
        }else{
            int maxNameLength = 0;
            for (ParameterSetDescriptor desc : descs) {
                int nameLength = desc.getName().length();
                if(nameLength > maxNameLength){
                    maxNameLength = nameLength; 
                }
            }

            for (ParameterSetDescriptor desc : descs) {
                report.append(StringUtils.pad(desc.getName(),maxNameLength+5) + "[" + desc.shortClassName() + "]\n");
            }
        }
        report.append("\n\n");
    }
    
    private void tableMouseClicked(MouseEvent evt, ETable table) {
        log.debug("tableMouseClicked(MouseEvent) - start, evt=" + evt);

        if (evt.getClickCount() == 2) {
            log.debug("tableMouseClicked(MouseEvent) - [DOUBLE-CLICK] table.mouseClicked, event="
                + evt);
            int tableRow = table.rowAtPoint(evt.getPoint());
            int selectedModelRow = table.convertRowIndexToModel(tableRow);
            log.info("tableMouseClicked(MouseEvent) - [DC] table row ="
                + selectedModelRow);

            ParameterSetDescriptor desc = paramImportTableModel.getDescriptorAt(selectedModelRow);
            String report = "Library Version:\n\n" + desc.getLibraryProps() + "\n\nImport Version:\n\n" + desc.getFileProps();
            TextualReportDialog.showReport(this, report);
        }

        log.debug("tableMouseClicked(MouseEvent) - end");
    }

    private void initGUI() {
        try {
            {
                this.setTitle("Import Parameter Library");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            }
            this.setSize(740, 567);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getScrollPane(), BorderLayout.CENTER);
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(100);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getReportButton());
            buttonPanel.add(getImportButton());
            buttonPanel.add(getCancelButton());
        }
        return buttonPanel;
    }
    
    private JButton getImportButton() {
        if(importButton == null) {
            importButton = new JButton();
            importButton.setText("import");
            importButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    importButtonActionPerformed(evt);
                }
            });
        }
        return importButton;
    }
    
    private JButton getCancelButton() {
        if(cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }
    
    private JScrollPane getScrollPane() {
        if(scrollPane == null) {
            scrollPane = new JScrollPane();
            scrollPane.setViewportView(getParamImportTable());
        }
        return scrollPane;
    }
    
    private ETable getParamImportTable() {
        if(paramImportTable == null) {
            paramImportTableModel = new ParamLibImportTableModel(dryRunResults);
            
            paramImportTable = new EShadedTable();
            paramImportTable.getSelectionModel()
            .setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            paramImportTable.setModel(paramImportTableModel);

            paramImportTable.addMouseListener(new MouseAdapter() {
                public void mouseClicked(MouseEvent evt) {
                    tableMouseClicked(evt, paramImportTable);
                }
            });
        }
        return paramImportTable;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 ParamLibImportDialog inst = new ParamLibImportDialog(frame,null);
                 inst.setVisible(true);
             }
         });
     }
    
    private JButton getReportButton() {
        if(reportButton == null) {
            reportButton = new JButton();
            reportButton.setText("report");
            reportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    reportButtonActionPerformed(evt);
                }
            });
        }
        return reportButton;
    }
}
