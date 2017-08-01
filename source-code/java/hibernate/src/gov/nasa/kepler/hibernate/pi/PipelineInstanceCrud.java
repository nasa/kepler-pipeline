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
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.LockMode;
import org.hibernate.Query;

/**
 * Provides CRUD methods for {@link PipelineInstance}.
 * 
 * @author tklaus
 * 
 */
public class PipelineInstanceCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(PipelineInstanceCrud.class);

    public PipelineInstanceCrud() {
    }

    public PipelineInstanceCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(PipelineInstance instance) {
        getSession().save(instance);
    }

    public PipelineInstance retrieve(long id) {
        Query query = getSession().createQuery("from PipelineInstance where id = :id");
        query.setLong("id", id);
        PipelineInstance instance = uniqueResult(query);
        return instance;
    }

    /**
     * Return all instances that match the specified filter.
     * 
     * @return
     */
    public List<PipelineInstance> retrieve(PipelineInstanceFilter filter) {

        Query q = filter.query(getSession());

        q.setLockMode("pi", LockMode.READ);

        List<PipelineInstance> result = list(q);

        return result;
    }

    /**
     * Return all pipeline instances started within the specified date range.
     * Sorted by priority (highest to lowest)
     * 
     * @return @
     */
    public List<PipelineInstance> retrieve(Date startDate, Date endDate) {

        Query q = getSession().createQuery(
            "from PipelineInstance pi " + "where pi.startProcessingTime >= :startDate "
                + "and pi.startProcessingTime <= :endDate " + "order by priority desc");
        q.setParameter("startDate", startDate);
        q.setParameter("endDate", endDate);
        List<PipelineInstance> result = list(q);

        return result;
    }

    /**
     * Retrieves all {@link PipelineInstance}s that began within the specified
     * date range that have the given states and types ordered by ID.
     * 
     * @param startDate the starting date.
     * @param endDate the ending date.
     * @param states an array of states
     * @param types an array of types (the name of the instance's pipeline
     * definition).
     * @return a non-{@code null} list of {@link PipelineInstance}s.
     * @throws HibernateException if there were problems accessing the database.
     */
    public List<PipelineInstance> retrieve(Date startDate, Date endDate, State[] states, String[] types) {

        // We found that a clean Criteria query would return a huge
        // n-dimensional Cartesian product. The following code trades a huge
        // number of joins with an n+1 select (but n is usually pretty small).

        // First, get all the instances within the date range.
        Query query = getSession().createQuery(
            "from PipelineInstance " + "where startProcessingTime >= :startDate "
                + "and startProcessingTime <= :endDate " + "order by id asc");
        query.setParameter("startDate", startDate);
        query.setParameter("endDate", endDate);
        List<PipelineInstance> result = list(query);

        // Now, choose those instances that match the additional criteria.
        List<PipelineInstance> filteredResult = new ArrayList<PipelineInstance>();
        for (PipelineInstance pipelineInstance : result) {
            boolean found = false;
            for (State state : states) {
                if (pipelineInstance.getState() == state) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                continue;
            }
            found = false;
            for (String type : types) {
                if (pipelineInstance.getPipelineDefinition()
                    .getName()
                    .toString()
                    .equals(type)) {
                    found = true;
                    break;
                }
            }
            if (found) {
                filteredResult.add(pipelineInstance);
            }
        }

        return filteredResult;
    }

    /**
     * 
     * @return @
     */
    public List<PipelineInstance> retrieveAll() {
        Query q = getSession().createQuery("from PipelineInstance pi order by pi.id asc");
        q.setLockMode("pi", LockMode.READ);

        List<PipelineInstance> result = list(q);

        return result;
    }

    /**
     * Return all active pipeline instances, sorted by priority (highest to
     * lowest)
     * 
     * @return @
     */
    public List<PipelineInstance> retrieveAllActive() {

        Query q = getSession().createQuery(
            "from PipelineInstance pi where pi.state = :processing " + "or pi.state = :errorsrunning "
                + "order by priority desc");
        q.setParameter("processing", PipelineInstance.State.PROCESSING);
        q.setParameter("errorsrunning", PipelineInstance.State.ERRORS_RUNNING);

        List<PipelineInstance> result = list(q);

        return result;
    }

    /**
     * Cancel all actibve pipeline instances. 
     * This method should only be called if there are no running instances. This is useful for reducing 
     * the number of queues monitored by the workers, thereby reducing the load on the JMS broker
     */
    public void cancelAllActive(){
    	List<PipelineInstance> activeInstances = retrieveAllActive();
    	
    	for (PipelineInstance instance : activeInstances) {
			instance.setState(PipelineInstance.State.STOPPED);
		}
    }
    
    /**
     * Retrieve all {@link PipelineInstance}s for the specified
     * {@link Collection} of pipelineInstanceIds.
     * 
     * @param pipelineInstanceIds {@link Collection} of pipelineInstanceIds.
     * @return {@link List} of {@link PipelineInstance}s.
     */
    public List<PipelineInstance> retrieveAll(
        Collection<Long> pipelineInstanceIds) {
        List<PipelineInstance> pipelineInstances = new ArrayList<PipelineInstance>();
        if (!pipelineInstanceIds.isEmpty()) {
            Query query = getSession().createQuery(
                "from PipelineInstance where id in (:pipelineInstanceIds) "
                    + "order by id asc");
            query.setParameterList("pipelineInstanceIds", pipelineInstanceIds);

            pipelineInstances = list(query);
        }

        return pipelineInstances;
    }

    /**
     * Update the name of a pipeline instance (normally by the operator in the PIG)
     * This is done with SQL update rather than via the Hibernate object because we
     * don't want to perturb the other fields which can be set by the worker processes.
     * 
     * @param id
     * @param newName
     */
    public void updateName(long id, String newName) {
        Query updateQuery = getSession().createSQLQuery(
            "update PI_PIPELINE_INSTANCE pi " + "set name = :newName where id = :id");

        updateQuery.setString("newName", newName);
        updateQuery.setLong("id", id);

        int rowsUpdated = updateQuery.executeUpdate();
        
        log.info("Updated instance name, rowsUpdated=" + rowsUpdated);
    }

    /**
     * Indicates whether all {@link PipelineTask}s for this
     * {@link PipelineInstance} are in the PipelineTask.State.COMPLETED state
     * 
     * @param instanceId
     * @return @
     */
    public PipelineInstanceAggregateState instanceState(PipelineInstance instance) {

        // flush changes so that the updateInstanceState query will see them.
        getSession().flush();

        Query q = getSession().createQuery(
            "select new gov.nasa.kepler.hibernate.pi.PipelineInstanceAggregateState(sum(instanceNode.numTasks), sum(instanceNode.numSubmittedTasks), sum(instanceNode.numCompletedTasks), "
                + "sum(instanceNode.numFailedTasks)) from PipelineInstanceNode instanceNode where pipelineInstance "
                + "= :instance");
        q.setEntity("instance", instance);

        PipelineInstanceAggregateState state = uniqueResult(q);

        log.debug(state);

        return state;
    }

    /**
     * Indicates whether all {@link PipelineTask}s for this
     * {@link PipelineInstance} are in the PipelineTask.State.COMPLETED state,
     * without considering the specified ignoredTask. This is used by the
     * transition logic to see if all tasks other than the one for which the
     * transition logic is acting on (which is about to become completed) have
     * completed.
     * 
     * @param instanceId
     * @return @
     */
    public boolean isInstanceComplete(PipelineInstance instance, PipelineTask ignoredTask) {

        Query q = getSession().createQuery(
            "select count(*) from PipelineTask pt where pipelineInstance "
                + "= :instance and state not in (:state1, :state2) and id <> :id");
        q.setEntity("instance", instance);
        q.setLong("id", ignoredTask.getId());
        q.setParameter("state1", PipelineTask.State.COMPLETED);
        q.setParameter("state2", PipelineTask.State.PARTIAL);
        Number count = uniqueResult(q);

        return (count.intValue() == 0);
    }

    public void delete(PipelineInstance instance) {
        getSession().delete(instance);
    }
}
