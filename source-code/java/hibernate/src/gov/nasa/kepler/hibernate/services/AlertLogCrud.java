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

package gov.nasa.kepler.hibernate.services;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.criterion.Disjunction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * This class provides CRUD methods for the AlertService
 * 
 * @author Bill Wohler
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class AlertLogCrud extends AbstractCrud {

    /**
     * Creates an {@link AlertLogCrud} object.
     */
    public AlertLogCrud() {
    }

    /**
     * Creates an {@link AlertLogCrud} object.
     * 
     * @param databaseService the database service
     */
    public AlertLogCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Stores a new {@link AlertLog} object.
     * 
     * @param alertLog the {@link AlertLog} object to store
     * @throws HibernateException if there were problems accessing the database
     */
    public void create(AlertLog alertLog) {
        getSession().save(alertLog);
    }

    /**
     * Retrieves the names of all components that have logged alerts to the
     * database.
     * 
     * @return a non-{@code null} list of matching components names
     * @throws NullPointerException if any of the arguments were {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<String> retrieveComponents() {
        Criteria query = getSession().createCriteria(AlertLog.class);
        query.setProjection((Projections.distinct(Projections.groupProperty("alertData.sourceComponent")
            .as("component"))));
        query.addOrder(Order.asc("component"));
        List<String> components = list(query);

        return components;
    }

    /**
     * Retrieves the names of all severities that have been logged in the
     * database.
     * 
     * @return a non-{@code null} list of matching severities
     * @throws NullPointerException if any of the arguments were {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<String> retrieveSeverities() {
        Criteria query = getSession().createCriteria(AlertLog.class);
        query.setProjection((Projections.distinct(Projections.groupProperty("alertData.severity")
            .as("severity"))));
        query.addOrder(Order.asc("severity"));
        List<String> severities = list(query);

        return severities;
    }

    /**
     * Retrieves all {@link AlertLog} objects during the given time range.
     * 
     * @param startDate the start date
     * @param endData the end date
     * @return a non-{@code null} list of matching {@link AlertLog} objects
     * @throws NullPointerException if any of the arguments were {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<AlertLog> retrieve(Date startDate, Date endDate) {
        return retrieve(startDate, endDate, new String[0], new String[0]);
    }

    /**
     * Retrieves all {@link AlertLog} objects associated with the given
     * {@code components} and {@code severities} during the given time range.
     * 
     * @param startDate the start date
     * @param endData the end date
     * @param components the components; if empty, all components are considered
     * @param severities severities; if empty, all severities are considered
     * @return a non-{@code null} list of matching {@link AlertLog} objects
     * @throws NullPointerException if any of the arguments were {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<AlertLog> retrieve(Date startDate, Date endDate, String[] components, String[] severities) {

        if (startDate == null) {
            throw new NullPointerException("startDate can't be null");
        }
        if (endDate == null) {
            throw new NullPointerException("endDate can't be null");
        }
        if (components == null) {
            throw new NullPointerException("components can't be null");
        }
        if (severities == null) {
            throw new NullPointerException("severities can't be null");
        }

        Criteria query = getSession().createCriteria(AlertLog.class);
        query.add(Restrictions.ge("alertData.timestamp", startDate));
        query.add(Restrictions.le("alertData.timestamp", endDate));

        if (components.length > 0) {
            Disjunction componentCriteria = Restrictions.disjunction();
            for (String component : components) {
                componentCriteria.add(Restrictions.eq("alertData.sourceComponent", component));
            }
            query.add(componentCriteria);
        }

        if (severities.length > 0) {
            Disjunction severityCriteria = Restrictions.disjunction();
            for (String severity : severities) {
                severityCriteria.add(Restrictions.eq("alertData.severity", severity));
            }
            query.add(severityCriteria);
        }

        query.addOrder(Order.asc("alertData.sourceComponent"));
        query.addOrder(Order.asc("alertData.severity"));
        query.addOrder(Order.asc("alertData.timestamp"));

        List<AlertLog> results = list(query);

        return results;
    }

    /**
     * Retrieve all alerts for the specified pipeline instance.
     * 
     * @param pipelineInstanceId
     * @return
     */
    public List<AlertLog> retrieveForPipelineInstance(long pipelineInstanceId) {

        SQLQuery query = getSession().createSQLQuery(
            "select * from PI_ALERT a, PI_PIPELINE_TASK t " +
            "where t.PI_PIPELINE_INSTANCE_ID = :pipelineInstanceId and t.ID = a.SOURCE_TASK_ID " +
            "order by a.SOURCE_TASK_ID");
        query.addEntity(AlertLog.class);
        query.setLong("pipelineInstanceId", pipelineInstanceId);
        

        List<AlertLog> results = list(query);

        return results;
    }
    
    /**
     * Retrieve all alerts for the specified list of pipeline task ids.
     */
    public List<AlertLog> retrieveByPipelineTaskIds(Collection<Long> taskIds) {
        List<AlertLog> rv = new ArrayList<AlertLog>();
        ListChunkIterator<Long> idIt = new ListChunkIterator<Long>(taskIds.iterator(), 50);
        for (List<Long> idChunk : idIt) {
            rv.addAll(retrieveChunk(idChunk));
        }
        return rv;
    }
    
    private List<AlertLog> retrieveChunk(List<Long> taskIds) {
        Criteria query = getSession().createCriteria(AlertLog.class);
        query.add(Restrictions.in("alertData.sourceTaskId",taskIds));
        
        List<AlertLog> rv = list(query);
        return rv;
    }

}
