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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.pi.common.TasksDisplayModel;
import gov.nasa.kepler.pi.common.TasksStates;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.models.AbstractDatabaseModel;
import gov.nasa.kepler.ui.proxy.PipelineTaskAttrOpsProxy;
import gov.nasa.kepler.ui.proxy.PipelineTaskCrudProxy;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class TasksTableModel extends AbstractDatabaseModel {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TasksTableModel.class);

    private PipelineInstance pipelineInstance;
    private List<PipelineTask> tasks = new LinkedList<PipelineTask>();
    private Map<Long, PipelineTaskAttributes> taskAttrs = new HashMap<Long,PipelineTaskAttributes>();
    private PipelineTaskCrudProxy pipelineTaskCrud;
    private PipelineTaskAttrOpsProxy attrOps;
 
    private TasksDisplayModel tasksDisplayModel = new TasksDisplayModel();
    
    public TasksTableModel() {
        pipelineTaskCrud = new PipelineTaskCrudProxy();
        attrOps = new PipelineTaskAttrOpsProxy();
    }

    public void loadFromDatabase() {
        
        try{
            if (tasks != null) {
                pipelineTaskCrud.evictAll(tasks); // clear the cache
            }

            if (pipelineInstance == null) {
                tasks = new LinkedList<PipelineTask>();
                taskAttrs = new HashMap<Long,PipelineTaskAttributes>();
            } else {
                tasks = pipelineTaskCrud.retrieveAll(pipelineInstance);
                taskAttrs = attrOps.retrieveByInstanceId(pipelineInstance.getId());
            }

            tasksDisplayModel.update(tasks, taskAttrs);
        }catch(PigSecurityException ignore){
        }
        
        fireTableDataChanged();
    }

    public PipelineTask getPipelineTaskForRow(int row) {
        validityCheck();
        return tasksDisplayModel.getPipelineTaskForRow(row);
    }

    public int getRowCount() {
        validityCheck();
        return tasksDisplayModel.getRowCount();
    }

    public int getColumnCount() {
        return tasksDisplayModel.getColumnCount();
    }

    public Object getValueAt(int rowIndex, int columnIndex) {
        validityCheck();
        return tasksDisplayModel.getValueAt(rowIndex, columnIndex);
    }

    /*
     * (non-Javadoc)
     * 
     * @see javax.swing.table.AbstractTableModel#getColumnName(int)
     */
    @Override
    public String getColumnName(int column) {
        return tasksDisplayModel.getColumnName(column);
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public void setPipelineInstance(PipelineInstance pipelineInstance) {
        this.pipelineInstance = pipelineInstance;
    }

    public TasksStates getTaskStates() {
        return tasksDisplayModel.getTaskStates();
    }
}
