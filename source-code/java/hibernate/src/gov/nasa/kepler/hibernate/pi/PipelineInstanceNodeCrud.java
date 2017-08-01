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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.LockMode;
import org.hibernate.Query;

/**
 * Provides CRUD methods for {@link PipelineInstanceNode}
 * 
 * @author tklaus
 * 
 */
public class PipelineInstanceNodeCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(PipelineInstanceNodeCrud.class);

    public PipelineInstanceNodeCrud() {
    }

    public PipelineInstanceNodeCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(PipelineInstanceNode instanceNode) {
        getSession().save(instanceNode);
    }

    public List<PipelineInstanceNode> retrieveAll(
        PipelineInstance pipelineInstance) {
        Query query = getSession().createQuery(
            "from PipelineInstanceNode pin where pipelineInstance = :pipelineInstance order by pin.id");
        query.setEntity("pipelineInstance", pipelineInstance);

        List<PipelineInstanceNode> instanceNodes = list(query);

        return instanceNodes;
    }

    /**
     * Retrieve the PipelineInstanceNode for the specified id
     * using LockMode.READ (bypass caches)
     * 
     * @param id
     * @return
     */
    public PipelineInstanceNode retrieve(long id) {
        Query query = getSession().createQuery(
            "from PipelineInstanceNode where id = :id");
        query.setLong("id", id);
        query.setLockMode("pin", LockMode.READ);

        PipelineInstanceNode instanceNode = uniqueResult(query);
        return instanceNode;
    }

    /**
     * Retrieve the PipelineInstanceNode for the specified PipelineInstance
     * and PipelineDefinitionNode using LockMode.READ (bypass caches)
     * 
     * @param pipelineInstance
     * @param pipelineDefinitionNode
     * @return
     */
    public PipelineInstanceNode retrieve(PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode) {
        Query query = getSession().createQuery(
            "from PipelineInstanceNode pin where pipelineInstance = :pipelineInstance"
                + " and pipelineDefinitionNode = :pipelineDefinitionNode");

        query.setEntity("pipelineInstance", pipelineInstance);
        query.setEntity("pipelineDefinitionNode", pipelineDefinitionNode);
        query.setLockMode("pin", LockMode.READ);

        PipelineInstanceNode instanceNode = uniqueResult(query);
        return instanceNode;
    }

    private enum CountType{
        TOTAL("NUM_TASKS"),
        SUBMITTED("NUM_SUBMITTED_TASKS"),
        COMPLETED("NUM_COMPLETED_TASKS"),
        FAILED("NUM_FAILED_TASKS");
        
        private String columnName;

        private CountType(String columnName) {
            this.columnName = columnName;
        }

        public String getColumnName() {
            return columnName;
        }

        public String getColumnList() {
            return TOTAL.columnName + ","
            + SUBMITTED.columnName + ","
            + COMPLETED.columnName + ","
            + FAILED.columnName;
        }
    }
    
    /**
     * Common code to update task count columns atomically.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * 
     * @param pipelineInstanceNodeId
     * @param countType.toString()
     * @param taskCountDelta
     */
    private TaskCounts updateTaskCount(long pipelineInstanceNodeId, CountType countType, int taskCountDelta){
        
        // make sure dirty objects are flushed to the database
        getSession().flush();
    
        Query selectForUpdateQuery = getSession().createSQLQuery("select " + countType.getColumnList() 
            + " from PI_PIPELINE_INST_NODE pin where id = :pipelineInstanceNodeId for update");
    
        selectForUpdateQuery.setLong("pipelineInstanceNodeId", pipelineInstanceNodeId);
    
        log.debug("query = " + selectForUpdateQuery);
        
        Object[] results = uniqueResult(selectForUpdateQuery);

        // 4 columns returned, as defined in the query above
        Number numTasks = (Number) results[0];
        Number numSubmittedTasks = (Number) results[1];
        Number numCompletedTasks = (Number) results[2];
        Number numFailedTasks = (Number) results[3];

        TaskCounts newTaskCounts = new TaskCounts(numTasks.longValue(), numSubmittedTasks.longValue(), 
            numCompletedTasks.longValue(), numFailedTasks.longValue());
        
        int previousTaskCount;
        int newTaskCount;
        
        switch(countType){
            case TOTAL:
                previousTaskCount = numTasks.intValue();
                newTaskCount = previousTaskCount + taskCountDelta;
                newTaskCounts.setTotal(newTaskCount);
                break;
                
            case SUBMITTED:
                previousTaskCount = numSubmittedTasks.intValue();
                newTaskCount = previousTaskCount + taskCountDelta;
                newTaskCounts.setSubmitted(newTaskCount);
                break;
                
            case COMPLETED:
                previousTaskCount = numCompletedTasks.intValue();
                newTaskCount = previousTaskCount + taskCountDelta;
                newTaskCounts.setCompleted(newTaskCount);
                break;
                
            case FAILED:
                previousTaskCount = numFailedTasks.intValue();
                newTaskCount = previousTaskCount + taskCountDelta;
                newTaskCounts.setFailed(newTaskCount);
                break;
                
            default:
                throw new IllegalStateException("unknown CountType: " + countType);
        }


        // this update releases the lock obtained above
        Query updateQuery = getSession().createSQLQuery("update PI_PIPELINE_INST_NODE pin " +
                "set " + countType.getColumnName() + " = :newTaskCount where id = :pipelineInstanceNodeId");
    
        updateQuery.setLong("pipelineInstanceNodeId", pipelineInstanceNodeId);
        updateQuery.setLong("newTaskCount", newTaskCount);
    
        int rowsUpdated = updateQuery.executeUpdate();
        
        log.info("Changed PI_PIPELINE_INST_NODE("+pipelineInstanceNodeId+")." + countType.getColumnName() + " ("
            +previousTaskCount+"->"+newTaskCount+"), rowsUpdated = " + rowsUpdated);
        
        return newTaskCounts;
    }

    /**
     * Update numTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     * @param taskCountDelta
     */
    public TaskCounts updateTaskCount(long pipelineInstanceNodeId, int taskCountDelta) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.TOTAL, taskCountDelta);
     }

    /**
     * Increment numSubmittedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     */
    public TaskCounts incrementSubmittedTaskCount(long pipelineInstanceNodeId) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.SUBMITTED, 1);
     }

    /**
     * Update numSubmittedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     * @param taskCountDelta
     */
    public TaskCounts updateSubmittedTaskCount(long pipelineInstanceNodeId, int taskCountDelta) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.SUBMITTED, taskCountDelta);
     }

    /**
     * Increment numCompletedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     */
    public TaskCounts incrementCompletedTaskCount(long pipelineInstanceNodeId) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.COMPLETED, 1);
     }

    /**
     * Update numCompletedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     * @param taskCountDelta
     */
    public TaskCounts updateCompletedTaskCount(long pipelineInstanceNodeId, int taskCountDelta) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.COMPLETED, taskCountDelta);
     }

    /**
     * Increment numFailedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     */
    public TaskCounts incrementFailedTaskCount(long pipelineInstanceNodeId) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.FAILED, 1);
     }

    /**
     * Deccrement numFailedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     */
    public TaskCounts decrementFailedTaskCount(long pipelineInstanceNodeId) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.FAILED, -1);
     }

    /**
     * Increment numFailedTasks for the specified PipelineInstanceNode.
     * Uses 'select for update' semantics so that the count is
     * read and updated atomically.  
     * NOTE: Atomicity is not guaranteed on HSQLDB since it does
     * not support 'select for update'
     * 
     * @param pipelineInstanceNodeId
     * @param taskCountDelta
     */
    public TaskCounts updateFailedTaskCount(long pipelineInstanceNodeId, int taskCountDelta) {
        return updateTaskCount(pipelineInstanceNodeId, CountType.FAILED, taskCountDelta);
     }

    /**
     * True if PipelineInstanceNode.numCompletedTasks == numTasks
     * 
     * @param pipelineInstanceNodeId
     * @return
     */
//    private boolean isInstanceNodeComplete(long pipelineInstanceNodeId){
//        // Make sure dirty objects are flushed to the database.
//        // Then wash your hands.
//        getSession().flush();
//
//        Query query = getSession().createQuery("select numTasks, numCompletedTasks " +
//        		"from PipelineInstanceNode pin where id = :pipelineInstanceNodeId");
//
//        query.setLong("pipelineInstanceNodeId", pipelineInstanceNodeId);
//
//        Object[] results = (Object[]) query.uniqueResult();
//
//        // 2 columns, as defined in the query above
//        Number numTasks = (Number) results[0];
//        Number numCompletedTasks = (Number) results[1];
//        
//        log.info("PipelineInstanceNode("+pipelineInstanceNodeId+") numTasks/numCompletedTasks = "+numTasks+"/"+numCompletedTasks);
//        
//        return(numCompletedTasks.equals(numTasks));
//    }
    
    public void delete(PipelineInstanceNode instanceNode) {
        getSession().delete(instanceNode);
    }
}
