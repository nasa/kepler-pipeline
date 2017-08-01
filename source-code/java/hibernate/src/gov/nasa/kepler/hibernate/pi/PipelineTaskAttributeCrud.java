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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD methods for {@link PipelineTaskAttribute}
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PipelineTaskAttributeCrud extends AbstractCrud{
    private static final Log log = LogFactory.getLog(PipelineTaskAttributeCrud.class);

    public PipelineTaskAttributeCrud() {
    }

    public PipelineTaskAttributeCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public PipelineTaskAttributes retrieveByTaskId(long pipelineTaskId){
        Session session = getSession();
        Query q = session.createQuery("from PipelineTaskAttribute pta"
            + " where pta.pipelineTaskId = :pipelineTaskId");
        q.setLong("pipelineTaskId", pipelineTaskId);

        List<PipelineTaskAttribute> results = list(q);

        Map<String,String> map = new HashMap<String,String>();
        
        for (PipelineTaskAttribute attr : results) {
            map.put(attr.getAttributeName(), attr.getAttributeValue());
        }
        
        PipelineTaskAttributes attrs = new PipelineTaskAttributes(map);

        getDatabaseService().evictAll(results);
        
        return attrs;
    }

    public Map<Long,PipelineTaskAttributes> retrieveByInstanceId(long pipelineInstanceId){
        Map<Long,PipelineTaskAttributes> attrsByTask = new HashMap<Long,PipelineTaskAttributes>();

        Session session = getSession();
        Query q = session.createQuery("from PipelineTaskAttribute pta"
            + " where pta.pipelineInstanceId = :pipelineInstanceId");
        q.setLong("pipelineInstanceId", pipelineInstanceId);

        List<PipelineTaskAttribute> results = list(q);
        
        for (PipelineTaskAttribute result : results) {
            
            long taskId = result.getPipelineTaskId();
            PipelineTaskAttributes attr = attrsByTask.get(taskId);
            
            if(attr == null){
                attr = new PipelineTaskAttributes();
                attrsByTask.put(taskId, attr);
            }
            
            Map<String,String> map = attr.getAttributeMap();
            map.put(result.getAttributeName(), result.getAttributeValue());
        }
        
        getDatabaseService().evictAll(results);
        
        return attrsByTask;
    }

    public void update(long pipelineTaskId, long pipelineInstanceId, Map<String,String> attributes){
        PipelineTaskAttributes oldAttrs = retrieveByTaskId(pipelineTaskId);
        Map<String, String> oldAttrsMap = oldAttrs.getAttributeMap();
        
        for (String attrName : attributes.keySet()) {
            if(oldAttrsMap.containsKey(attrName)){
                // update
                Query updateQuery = getSession().createSQLQuery(
                    "update PI_PIPELINE_TASK_ATTR " 
                        + "set ATTRIBUTE_VALUE = :value "
                    + "where PIPELINE_TASK_ID = :taskId and "
                    + "ATTRIBUTE_NAME = :name");

                updateQuery.setString("name", attrName);
                updateQuery.setString("value", attributes.get(attrName));
                updateQuery.setLong("taskId", pipelineTaskId);

                log.info("updateQuery: " + updateQuery);
                
                int rowsUpdated = updateQuery.executeUpdate();
                
                log.info("Updated " + rowsUpdated + " rows for name = " + attrName);
            }else{
                // insert
                Query updateQuery = getSession().createSQLQuery(
                    "insert into PI_PIPELINE_TASK_ATTR " 
                        + "(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID, ATTRIBUTE_NAME, ATTRIBUTE_VALUE) "
                        + "values "
                        + "(:taskId, :instanceId, :name, :value)");

                updateQuery.setLong("taskId", pipelineTaskId);
                updateQuery.setLong("instanceId", pipelineInstanceId);
                updateQuery.setString("name", attrName);
                updateQuery.setString("value", attributes.get(attrName));

                int rowsUpdated = updateQuery.executeUpdate();
                
                log.info("Inserted " + rowsUpdated + " rows for name = " + attrName);
            }
        }
    }
}
