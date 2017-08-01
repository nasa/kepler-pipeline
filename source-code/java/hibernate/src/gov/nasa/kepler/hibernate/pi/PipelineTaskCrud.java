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
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.LockMode;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD methods for {@link PipelineTask}
 * 
 * @author tklaus
 */
public class PipelineTaskCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(PipelineTaskCrud.class);
    
    public PipelineTaskCrud() {
    }

    public PipelineTaskCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(PipelineTask task) {
        getSession().save(task);
    }

    public PipelineTask retrieve(long id) {
        Query query = getSession().createQuery("from PipelineTask where id = :id");
        query.setLong("id", id);
        PipelineTask task = uniqueResult(query);
        return task;
    }

    /**
     * Retrieve all {@link PipelineTask}s for the specified
     * {@link PipelineInstance}
     * 
     * @param instance
     * @return
     */
    public List<PipelineTask> retrieveAll(PipelineInstance instance) {

        Session session = getSession();
        Query q = session.createQuery("from PipelineTask pt"
            + " where pt.pipelineInstance = :pipelineInstance order by id asc");
        q.setEntity("pipelineInstance", instance);
        q.setLockMode("pt", LockMode.READ); // bypass caches

        List<PipelineTask> result = list(q);

        return result;
    }

    /**
     * Retrieve all {@link PipelineTask}s for the specified
     * {@link PipelineInstanceNode}
     * 
     * @param instance
     * @return
     */
    public List<PipelineTask> retrieveAll(PipelineInstanceNode pipelineInstanceNode) {

        Session session = getSession();
        Query q = session.createQuery("from PipelineTask pt"
            + " where pt.pipelineInstanceNode = :pipelineInstanceNode order by id asc");
        q.setEntity("pipelineInstanceNode", pipelineInstanceNode);
        q.setLockMode("pt", LockMode.READ); // bypass caches

        List<PipelineTask> result = list(q);

        return result;
    }

    /**
     * Retrieve all {@link PipelineTask}s for the specified
     * {@link PipelineInstance} and the specified {@link PipelineTask.State}
     * 
     * @param instance
     * @return
     */
    public List<PipelineTask> retrieveAll(PipelineInstance instance, PipelineTask.State state) {

        Session session = getSession();

        Query q = session.createQuery("from PipelineTask pt where " + "pt.pipelineInstance = :pipelineInstance "
            + "and pt.state = :state " + "order by id asc");

        q.setEntity("pipelineInstance", instance);
        q.setParameter("state", state);
        q.setLockMode("pt", LockMode.READ); // bypass caches

        List<PipelineTask> result = list(q);

        return result;
    }

    /**
     * Retrieve all {@link PipelineTask}s for the specified {@link Collection}
     * of pipelineTaskIds.
     * 
     * @param pipelineTaskIds {@link Collection} of pipelineTaskIds.
     * @return {@link List} of {@link PipelineTask}s.
     */
    public List<PipelineTask> retrieveAll(Collection<Long> pipelineTaskIds) {
        List<PipelineTask> pipelineTasks = new ArrayList<PipelineTask>();
        if (!pipelineTaskIds.isEmpty()) {
            Query query = getSession().createQuery(
                "from PipelineTask where id in (:pipelineTaskIds) " + "order by id asc");
            query.setParameterList("pipelineTaskIds", pipelineTaskIds);

            pipelineTasks = list(query);
        }

        return pipelineTasks;
    }

    /**
     * Retrieve the list of distinct softwareRevisions for the specified node.
     * Used for reporting
     * 
     * @param node
     * @return
     */
    public List<String> distinctSoftwareRevisions(PipelineInstanceNode node) {
        Session session = getSession();

        Query q = session.createQuery("select distinct softwareRevision"
            + " from PipelineTask pt where pt.pipelineInstanceNode"
            + " = :pipelineInstanceNode order by softwareRevision asc");

        q.setEntity("pipelineInstanceNode", node);

        List<String> result = list(q);

        return result;
    }

    /**
     * Retrieve the list of distinct softwareRevisions for the specified
     * pipeline instance. Used for reporting
     * 
     * @param node
     * @return
     */
    public List<String> distinctSoftwareRevisions(PipelineInstance instance) {
        Session session = getSession();

        Query q = session.createQuery("select distinct softwareRevision from PipelineTask pt "
            + "where pt.pipelineInstance = :pipelineInstance order by softwareRevision asc");

        q.setEntity("pipelineInstance", instance);

        List<String> result = list(q);

        return result;
    }

    public class ClearStaleStateResults {
        public int totalUpdatedTaskCount = 0;
        public Set<Integer> uniqueInstanceIds = new HashSet<Integer>();
    }

    /**
     * Change the state from PROCESSING to ERROR for any tasks with the
     * specified workerHost.
     * 
     * This is typically called by a worker during startup to clear the stale
     * state of any tasks that were processing when the worker exited abnormally
     * (without a chance to set the state to ERROR)
     * 
     * @param workerHost
     * @return
     */
    public ClearStaleStateResults clearStaleState(String workerHost) {
        ClearStaleStateResults results = new ClearStaleStateResults();

        Session session = getSession();
        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();

        Query q1 = session.createSQLQuery("select PI_PIPELINE_INSTANCE_ID, PI_PIPELINE_INST_NODE_ID,"
            + " count(*) from PI_PIPELINE_TASK " + "where WORKER_HOST = :workerHost and STATE = :processingState"
            + " group by PI_PIPELINE_INSTANCE_ID, PI_PIPELINE_INST_NODE_ID");
        q1.setString("workerHost", workerHost);
        q1.setParameter("processingState", PipelineTask.State.PROCESSING.ordinal());

        List<Object[]> staleTasks = list(q1);

        for (Object[] row : staleTasks) {
            Number instanceId = (Number) row[0];
            Number instanceNodeId = (Number) row[1];
            Number processingCount = (Number) row[2];

            log.info("instanceId = " + instanceId);
            log.info("instanceNodeId = " + instanceNodeId);
            log.info("processingCount = " + processingCount);

            results.uniqueInstanceIds.add(instanceId.intValue());

            pipelineInstanceNodeCrud.updateFailedTaskCount(instanceNodeId.longValue(), processingCount.intValue());

            Query q2 = session.createQuery("update PipelineTask set state = :errorState, endProcessingTime = :now where "
                + "pipelineInstanceNode = :instanceNode and " + "workerHost = :workerHost and state = :processingState");

            q2.setParameter("errorState", PipelineTask.State.ERROR);
            q2.setParameter("now", new Date());
            q2.setEntity("instanceNode", session.get(PipelineInstanceNode.class, instanceNodeId.longValue()));
            q2.setString("workerHost", workerHost);
            q2.setParameter("processingState", PipelineTask.State.PROCESSING);

            int updatedRows = q2.executeUpdate();

            session.flush(); // push out the update

            if (updatedRows == 0) {
                log.info("found NO rows for instanceNode = " + instanceNodeId
                    + " for this worker with stale state (PROCESSING)");
            } else {
                log.info("found " + updatedRows + " rows for instanceNode = " + instanceNodeId
                    + " for this worker with stale state (PROCESSING), these rows were reset to ERROR");
            }

            results.totalUpdatedTaskCount += processingCount.intValue();
        }

        log.info("totalUpdatedTaskCount = " + results.totalUpdatedTaskCount);

        return results;
    }

    /**
     * Change the state from PROCESSING or SUBMITTED to ERROR for any tasks with the
     * specified instance ID.
     *
     * Typically invoked by the operator to reset the state to ERROR for tasks that did
     * not complete normally (left in the PROCESSING or SUBMITTED states). This allows
     * the operator to re-run these tasks.
     * 
     */
    public void resetTaskStates(long pipelineInstanceId, boolean allStalledTasks, String taskIds) {

        Session session = getSession();
        Query select = null;
        
        if(allStalledTasks){
            select = session.createSQLQuery("select PI_PIPELINE_INST_NODE_ID,"
                + " count(*) from PI_PIPELINE_TASK" 
                + " where STATE = :submittedState or STATE = :processingState"
                + " and PI_PIPELINE_INSTANCE_ID = :instanceId"
                + " group by PI_PIPELINE_INST_NODE_ID");
            select.setParameter("submittedState", PipelineTask.State.SUBMITTED.ordinal());
            select.setParameter("processingState", PipelineTask.State.PROCESSING.ordinal());
            select.setParameter("instanceId", pipelineInstanceId);
        }else{
            select = session.createSQLQuery("select PI_PIPELINE_INST_NODE_ID,"
                + " count(*) from PI_PIPELINE_TASK" 
                + " where STATE = :submittedState"
                + " and PI_PIPELINE_INSTANCE_ID = :instanceId"
                + " group by PI_PIPELINE_INST_NODE_ID");
            select.setParameter("submittedState", PipelineTask.State.SUBMITTED.ordinal());
            select.setParameter("instanceId", pipelineInstanceId);
        }

        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();

        log.info("Select query: " + select);
        
        List<Object[]> staleTasks = list(select);

        for (Object[] row : staleTasks) {
            Number instanceNodeId = (Number) row[0];
            Number staleCount = (Number) row[1];

            log.info("instanceNodeId = " + instanceNodeId);
            log.info("staleCount = " + staleCount);

            pipelineInstanceNodeCrud.updateFailedTaskCount(instanceNodeId.longValue(), staleCount.intValue());

            Query update = generateResetQuery(instanceNodeId.longValue(), allStalledTasks, taskIds);
            
            log.info("Update query: " + update);
            
            int updatedRows = update.executeUpdate();

            session.flush(); // push out the update

            if (updatedRows == 0) {
                log.info("found NO rows for instanceNode = " + instanceNodeId
                    + " for this worker with stale state");
            } else {
                log.info("found " + updatedRows + " rows for instanceNode = " + instanceNodeId
                    + " for this worker with stale state, these rows were reset to ERROR");
            }
        }
    }

    private Query generateResetQuery(long instanceNodeId, boolean allStalledTasks, String taskIds){
        Session session = getSession();
        String stateConstraint = "";
        String taskIdsConstraint = "";
        
        State error = PipelineTask.State.ERROR;
        State processing = PipelineTask.State.PROCESSING;
        State submitted = PipelineTask.State.SUBMITTED;

        if(allStalledTasks){
            stateConstraint = "and state = :submitted or state = :processing "; 
        }else{
            stateConstraint = "and state = :submitted "; 
        }
        
        if(taskIds != null){
            taskIdsConstraint = "and id in (" + taskIds + ") ";
        }

        Query q = session.createQuery("update PipelineTask set " +
        		"state = :error, " +
        		"endProcessingTime = :now " +
        		"where " +
        		"pipelineInstanceNode = :instanceNode " +
        		stateConstraint + taskIdsConstraint);

        q.setParameter("error", error);
        q.setParameter("now", new Date());
        q.setEntity("instanceNode", session.get(PipelineInstanceNode.class, instanceNodeId));
        q.setParameter("submitted", submitted);

        if(allStalledTasks){
            q.setParameter("processing", processing);
        }

//        if(taskIds != null){
//            q.setParameter("taskIds", taskIds);
//        }
//        
        return q;
    }
    
    /**
     * Gets the number of {@link PipelineTask}s associated with the given
     * {@link PipelineInstance}.
     * 
     * @param the non-{@code null} {@link PipelineInstance}.
     * @return the number of {@link PipelineTask}s.
     * @throws HibernateException if there were problems retrieving the count of
     * {@link PipelineTask} objects.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    public int taskCount(PipelineInstance pipelineInstance) {
        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        Query query = getSession().createQuery(
            "select count(id) from PipelineTask t " + "where t.pipelineInstance = :pipelineInstance");
        query.setParameter("pipelineInstance", pipelineInstance);
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Gets a map containing the number of {@link PipelineTask}s associated with
     * the given {@link PipelineInstance} for each state {@link State}. All
     * known states are guaranteed to be found in the map, even if the count is
     * 0.
     * 
     * @param the non-{@code null} {@link PipelineInstance}.
     * @return the number of {@link PipelineTask}s.
     * @throws HibernateException if there were problems retrieving the count of
     * {@link PipelineTask} objects.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    public Map<State, Integer> taskCountByState(PipelineInstance pipelineInstance) {

        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        Query query = getSession().createQuery(
            "select state, count(*) from PipelineTask t " + "where t.pipelineInstance = :pipelineInstance "
                + "group by state");
        query.setParameter("pipelineInstance", pipelineInstance);

        List<Object[]> list = list(query);
        Map<State, Integer> taskCounts = new HashMap<State, Integer>();
        for (Object[] row : list) {
            taskCounts.put((State) row[0], ((Long) row[1]).intValue());
        }

        // Ensure that all states are covered.
        for (State state : State.values()) {
            if (taskCounts.get(state) == null) {
                taskCounts.put(state, 0);
            }
        }

        return taskCounts;
    }
}
