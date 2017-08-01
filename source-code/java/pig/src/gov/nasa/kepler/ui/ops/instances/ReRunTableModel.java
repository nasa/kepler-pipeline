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

package gov.nasa.kepler.ui.ops.instances;

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ReRunTableModel extends AbstractTableModel {
    private static final Log log = LogFactory.getLog(ReRunTableModel.class);

    private List<ReRunAttributes> moduleList;
    private Map<String, ReRunAttributes> moduleMap;
    
    public ReRunTableModel(List<PipelineTask> failedTasks, Map<Long,PipelineTaskAttributes> taskAttrMap) {
        moduleMap = new HashMap<String,ReRunAttributes>();
        
        for (PipelineTask task : failedTasks) {
            String moduleName = task.getModuleName();
            String pState = ProcessingState.INITIALIZING.toString();
            
            PipelineTaskAttributes taskAttrs = taskAttrMap.get(task.getId());
            if(taskAttrs != null){
                pState = taskAttrs.getProcessingState().shortName();
            }

            String key = ReRunAttributes.key(moduleName, pState);

            ReRunAttributes module = moduleMap.get(key);
            
            if(module == null){
                String[] supportedModes = task.getModuleImplementation().supportedRestartModes();
                String selectedMode = supportedModes.length > 0 ? supportedModes[0] : "-";
                
                module = new ReRunAttributes(moduleName, pState, 1, supportedModes, selectedMode);
                
                moduleMap.put(key, module);
            }else{
                module.incrementCount();
            }
        }
        
        moduleList = new LinkedList<ReRunAttributes>(moduleMap.values());
        
        log.debug("moduleList.size() = " + moduleList.size());
    }

    @Override
    public int getRowCount() {
        return moduleList.size();
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        
        log.debug("getValueAt(r=" + rowIndex + ", c=" + columnIndex + ")");
        
        ReRunAttributes reRunGroup = moduleList.get(rowIndex);
        
        switch (columnIndex) {
            case 0:
                return reRunGroup.getModuleName();
            case 1:
                return reRunGroup.getProcessingState();
            case 2:
                return reRunGroup.getCount();
            case 3:
                return reRunGroup.getSelectedRestartMode();
        }
        return "huh?";
    }

    @Override
    public int getColumnCount() {
        return 4;
    }

    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Module";
            case 1:
                return "P-state";
            case 2:
                return "Count";
            case 3:
                return "Restart Mode";
        }
        return "huh?";
    }

    @Override
    public boolean isCellEditable(int rowIndex, int columnIndex) {
        if(columnIndex == 3){
            return true;
        }else{
            return super.isCellEditable(rowIndex, columnIndex);
        }
    }

    @Override
    public void setValueAt(Object value, int rowIndex, int columnIndex) {

        log.debug("setValueAt(r=" + rowIndex + ", c=" + columnIndex + ", value-=" + value + ")");
        
        if(columnIndex == 3){
            ReRunAttributes module = moduleList.get(rowIndex);
            module.setSelectedRestartMode((String) value);
        }else{
            throw new IllegalArgumentException("read-only columnIndex = " + columnIndex);
        }
    }

    public List<ReRunAttributes> getModuleList() {
        return moduleList;
    }

    public Map<String, ReRunAttributes> getModuleMap() {
        return moduleMap;
    }
}
