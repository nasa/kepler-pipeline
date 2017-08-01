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

import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.config.AbstractClonableViewEditPanel;
import gov.nasa.kepler.ui.ops.instances.TextualReportDialog;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.ParameterSetCrudProxy;
import gov.nasa.kepler.ui.proxy.ParametersOperationsProxy;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ParameterSetsViewEditPanel extends AbstractClonableViewEditPanel {
    private static final Log log = LogFactory.getLog(ParameterSetsViewEditPanel.class);
    
    // do NOT init to null!
    // (see getTableModel)
    private ParameterSetsTableModel parameterSetsTableModel;

    private ParameterSetCrudProxy parameterSetCrud;

    private JButton reportButton;
    private JButton importButton;
    private JButton exportButton;
    
    private static String defaultParamLibImportExportPath = null;

    public ParameterSetsViewEditPanel() throws PipelineUIException {
        super(true,true);
        
        parameterSetCrud = new ParameterSetCrudProxy();

        initGUI();

        getButtonPanel().add(getReportButton());
        getButtonPanel().add(getImportButton());
        getButtonPanel().add(getExportButton());
    }

    private void reportButtonActionPerformed(ActionEvent evt) {
        log.debug("reportButton.actionPerformed, event=" + evt);

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_MONITOR);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        Object[] options = { "Formatted", "Colon-delimited" };
        int n = JOptionPane.showOptionDialog(PipelineConsole.instance,
            "Specify report type",
            "ReportType", JOptionPane.YES_NO_CANCEL_OPTION,
            JOptionPane.QUESTION_MESSAGE, null, options, options[0]);

        boolean csvMode = (n == 0 ? false : true);
        
        PipelineOperationsProxy ops = new PipelineOperationsProxy();
        String report = ops.generateParameterLibraryReport(csvMode);

        TextualReportDialog.showReport(PipelineConsole.instance, report);
    }

    private void importButtonActionPerformed(ActionEvent evt) {
        log.debug("importButton.actionPerformed, event="+evt);
        
        try {
            JFileChooser fc = new JFileChooser(defaultParamLibImportExportPath);
            
            fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
            fc.setDialogTitle("Select parameter library file to import");
            
            int returnVal = fc.showDialog(this,"Import");
    
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                defaultParamLibImportExportPath = file.getAbsolutePath();
                
                ParametersOperationsProxy paramsOps = new ParametersOperationsProxy();
                List<ParameterSetDescriptor> dryRunResults = paramsOps.importParameterLibrary(file.getAbsolutePath(), null, true);
                
                List<String> excludeList = ParamLibImportDialog.selectParamSet(PipelineConsole.instance, dryRunResults);
                
                if(excludeList != null){ // null means user cancelled
                    paramsOps.importParameterLibrary(file.getAbsolutePath(), excludeList, false);
                }
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private void exportButtonActionPerformed(ActionEvent evt) {
        log.debug("exportButton.actionPerformed, event="+evt);
        
        try {
            JFileChooser fc = new JFileChooser(defaultParamLibImportExportPath);
            fc.setDialogTitle("Select the destination file for the parameter library export");

            fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
            
            int returnVal = fc.showDialog(this, "Export");
    
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                defaultParamLibImportExportPath = file.getAbsolutePath();
                
                ParametersOperationsProxy paramsOps = new ParametersOperationsProxy();
                paramsOps.exportParameterLibrary(file.getAbsolutePath(), null, false); // excludes not supported ATM
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    @Override
    protected AbstractTableModel getTableModel() throws PipelineUIException {
        log.debug("getTableModel() - start");

        if (parameterSetsTableModel == null) {
            parameterSetsTableModel = new ParameterSetsTableModel();
            parameterSetsTableModel.register();
        }

        log.debug("getTableModel() - end");
        return parameterSetsTableModel;
    }

    @Override
    protected void doNew() {
        log.debug("doNew() - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        ParameterSet newParameterSet = ParameterSetNewDialog.createParameterSet();

        if (newParameterSet != null) {
            ParameterSetCrudProxy paramSetCrud = new ParameterSetCrudProxy();
            paramSetCrud.save(newParameterSet);
            parameterSetsTableModel.loadFromDatabase();
        } else {
            // user cancelled
            return;
        }

        log.debug("doNew() - end");
    }

    @Override
    protected void doClone(int row) {
        log.debug("doClone() - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        ParameterSet selectedParameterSet = parameterSetsTableModel.getParamSetAtRow(row);

        try {
            String newParameterSetName = (String) JOptionPane.showInputDialog(
                PipelineConsole.instance,
                "Enter the name for the new Parameter Set",
                "New Parameter Set", JOptionPane.PLAIN_MESSAGE);

            if (newParameterSetName == null
                || newParameterSetName.length() == 0) {
                JOptionPane.showMessageDialog(this,
                    "Please enter a Parameter Set name", "Error",
                    JOptionPane.ERROR_MESSAGE);
                return;
            }

            ParameterSet newParameterSet = new ParameterSet(
                selectedParameterSet);
            newParameterSet.rename(newParameterSetName);

            showEditDialog(newParameterSet, true);

            parameterSetsTableModel.loadFromDatabase();

        } catch (Exception e) {
            log.debug("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }

        log.debug("doClone() - end");
    }

    @Override
    protected void doRename(int row) {
        log.debug("doRename() - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        ParameterSet selectedParameterSet = parameterSetsTableModel.getParamSetAtRow(row);

        try {
            String newParameterSetName = (String) JOptionPane.showInputDialog(
                PipelineConsole.instance,
                "Enter the new name for this Parameter Set",
                "Rename Parameter Set", JOptionPane.PLAIN_MESSAGE);

            if (newParameterSetName == null
                || newParameterSetName.length() == 0) {
                JOptionPane.showMessageDialog(this,
                    "Please enter a Parameter Set name", "Error",
                    JOptionPane.ERROR_MESSAGE);
                return;
            }

            parameterSetCrud.rename(selectedParameterSet, newParameterSetName);
            parameterSetsTableModel.loadFromDatabase();

        } catch (Exception e) {
            log.debug("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }

        log.debug("doRename() - end");
    }

    @Override
    protected void doEdit(int row) {
        log.debug("doEdit(int) - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        ParameterSet parameterSet = parameterSetsTableModel.getParamSetAtRow(row);
        showEditDialog(parameterSet, false);

        log.debug("doEdit(int) - end");
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.ui.config.GenericViewEditPanel#doRefresh()
     */
    @Override
    protected void doRefresh() {
        try {
            parameterSetsTableModel.loadFromDatabase();
        } catch (Exception e) {
            log.error("showEditDialog(User)", e);

            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    @Override
    protected void doDelete(int row) {
        log.debug("doDelete(int) - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        ParameterSet parameterSet = parameterSetsTableModel.getParamSetAtRow(row);

        if (!parameterSet.isLocked()) {
            int choice = JOptionPane.showConfirmDialog(this,
                "Are you sure you want to delete Parameter Set '"
                    + parameterSet.getName() + "'?");

            if (choice == JOptionPane.YES_OPTION) {
                try {
                    parameterSetCrud.delete(parameterSet);
                    parameterSetsTableModel.loadFromDatabase();

                } catch (Throwable e) {
                    log.debug("caught e = ", e);
                    JOptionPane.showMessageDialog(this, e, "Error",
                        JOptionPane.ERROR_MESSAGE);
                }
            }
        } else {
            JOptionPane.showMessageDialog(
                this,
                "Can't delete a locked parameter set.  Parameter sets are locked when referenced by a pipeline instance",
                "Error", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("doDelete(int) - end");
    }

    @Override
    protected String getEditMenuText() {
        return "Edit selected Parameter Set...";
    }

    @Override
    protected String getNewMenuText() {
        return "Create new Parameter Set...";
    }

    @Override
    protected String getDeleteMenuText() {
        return "Delete selected Parameter Set...";
    }

    @Override
    protected String getCloneMenuText() {
        return "Clone selected Parameter Set";
    }

    @Override
    protected String getRenameMenuText() {
        return "Rename selected Parameter Set";
    }
    
    private void showEditDialog(ParameterSet module, boolean isNew) {
        log.debug("showEditDialog() - start");

        try {
            ParameterSetEditDialog inst = new ParameterSetEditDialog(
                PipelineConsole.instance, module, isNew);
            inst.setVisible(true);

            if(!inst.isCancelled()){
                parameterSetsTableModel.loadFromDatabase();
            }
        } catch (Exception e) {
            log.error("showEditDialog(User)", e);

            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }

        log.debug("showEditDialog() - end");
    }

    private JButton getReportButton() {
        if (reportButton == null) {
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

    private JButton getImportButton() {
        if (importButton == null) {
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

    private JButton getExportButton() {
        if (exportButton == null) {
            exportButton = new JButton();
            exportButton.setText("export");
            exportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exportButtonActionPerformed(evt);
                }
            });
        }

        return exportButton;
    }

    /**
     * This method should return an instance of this class which does NOT
     * initialize it's GUI elements. This method is ONLY required by Jigloo if
     * the superclass of this class is abstract or non-public. It is not needed
     * in any other situation.
     * 
     * @throws PipelineUIException
     */
    public static Object getGUIBuilderInstance() throws PipelineUIException {
        return new ParameterSetsViewEditPanel(Boolean.FALSE);
    }

    /**
     * This constructor is used by the getGUIBuilderInstance method to provide
     * an instance of this class which has not had it's GUI elements initialized
     * (ie, initGUI is not called in this constructor).
     * 
     * @throws PipelineUIException
     */
    public ParameterSetsViewEditPanel(Boolean initGUI)
        throws PipelineUIException {
        super(true,true);
    }
}
