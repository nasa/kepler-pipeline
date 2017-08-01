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

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD methods for {@link PipelineDefinition}
 * 
 * @author tklaus
 * 
 */
public class PipelineDefinitionCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(PipelineDefinitionCrud.class);

    public PipelineDefinitionCrud() {
    }

    public PipelineDefinitionCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * 
     * @param pipeline
     * @return @
     */
    public void create(PipelineDefinition pipeline) {
        getSession().save(pipeline);
    }

    /**
     * 
     * @return @
     */
    public List<PipelineDefinition> retrieveAll() {
        Query query = getSession().createQuery("from PipelineDefinition");

        List<PipelineDefinition> results = list(query);

        return results;
    }

    public List<PipelineDefinition> retrieveAllVersionsForName(String name) {
        
        Session session = getSession();
        Query q = session.createQuery("from PipelineDefinitionName m where m.name = :name");
        q.setString("name", name);
        q.setMaxResults(1);

        PipelineDefinitionName pipelineDefName = uniqueResult(q); 
            
        if(pipelineDefName == null){
            return new ArrayList<PipelineDefinition>();
        }
        
        q = session.createQuery("from PipelineDefinition pd where pd.name = :name order by version asc");
        q.setEntity("name", pipelineDefName);

        List<PipelineDefinition> result = list(q);

        return result;
    }

    public PipelineDefinition retrieveLatestVersionForName(String name) {

        Session session = getSession();
        Query q = session.createQuery("from PipelineDefinitionName where name = :name");
        q.setString("name", name);
        q.setMaxResults(1);
        PipelineDefinitionName pipelineDefName = uniqueResult(q);

        if(pipelineDefName == null){
            log.warn("No PipelineDefinitionName found for name = " + name);
            return null;
        }
        
        PipelineDefinition result = retrieveLatestVersionForName(pipelineDefName);

        return result;
    }

    public PipelineDefinition retrieveLatestVersionForName(PipelineDefinitionName name) {
        Session session = getSession();
        Query q = session.createQuery("from PipelineDefinition where name = :name order by version desc");
        q.setEntity("name", name);
        q.setMaxResults(1);

        PipelineDefinition result = uniqueResult(q);

        return result;
    }


    public List<PipelineDefinition> retrieveLatestVersions() {
        Session session = getSession();
        Query q = session.createQuery("from PipelineDefinitionName order by name");

        List<PipelineDefinitionName> names = list(q);

        List<PipelineDefinition> results = new ArrayList<PipelineDefinition>();

        for (PipelineDefinitionName name : names) {
            results.add(retrieveLatestVersionForName(name));
        }

        return results;
    }

    /**
     * Retrieves the unique list of names of all {@link PipelineDefinition}s.
     * 
     * @return a non-{@code null} list of {@link PipelineDefinition} names.
     * @throws HibernateException if there were problems accessing the database.
     */
    public List<String> retrievePipelineDefinitionNames() {
        Query query = getSession().createQuery(
            "select name from PipelineDefinitionName "
                + "order by name asc");

        List<String> results = list(query);

        return results;
    }

    /**
     * Retrieves the names of all {@link PipelineDefinition}s that are
     * associated with {@link PipelineInstance}s.
     * 
     * @return a non-{@code null} list of {@link PipelineDefinition} names.
     * @throws HibernateException if there were problems accessing the database.
     */
    public List<String> retrievePipelineDefinitionNamesInUse() {
        Query query = getSession().createQuery(
            "select distinct pdn.name from PipelineDefinitionName pdn, PipelineInstance pinst "
                + "where pdn.name = pinst.pipelineDefinition.name order by pdn.name asc");

        List<String> names = list(query);

        return names;
    }

    public void deleteAllVersionsForName(String name){
        List<PipelineDefinition> allVersions = retrieveAllVersionsForName(name);
        
        for (PipelineDefinition pipelineDefinition : allVersions) {
            log.info("deleting existing pipeline def: " + pipelineDefinition);
            deletePipeline(pipelineDefinition);
        }
    }
    
    /**
     * 
     * @param pipeline @
     */
    public void deletePipeline(PipelineDefinition pipeline) {
       
        /* Must delete the nodes before deleting the pipeline
         * because the cascade rules do not include delete
         * (having Cascade.ALL would cause errors in the PIG when
         * manually deleting individual nodes)
         */
        deleteNodes(pipeline.getRootNodes());
        
        getSession().delete(pipeline);
    }

    /**
     * Delete all of the nodes in a pipeline and clear the rootNodes List.
     * 
     * @param pipeline
     */
    public void deleteAllPipelineNodes(PipelineDefinition pipeline) {
        List<PipelineDefinitionNode> rootNodes = pipeline.getRootNodes();
        deleteNodes(rootNodes);
        rootNodes.clear();
    }
    
    /**
     * Recursively delete all of the nodes in a pipeline.
     * 
     * @param rootNodes
     */
    private void deleteNodes(List<PipelineDefinitionNode> nodes) {
        for (PipelineDefinitionNode node : nodes) {
            deleteNodes(node.getNextNodes());
            deletePipelineNode(node);
        }
    }

    /**
     * 
     * @param pipeline @
     */
    public void deletePipelineNode(PipelineDefinitionNode pipelineNode) {
        getSession().delete(pipelineNode);
    }

    public void rename(PipelineDefinition pipelineDef, String newName){
        Session session = getSession();
        String oldName = pipelineDef.getName().getName();
        
        // first, create the new name in PI_PD_NAME
        PipelineDefinitionName newNameEntity = new PipelineDefinitionName(newName);
        session.save(newNameEntity);
        
        // flush these changes so the updates below will see them
        session.flush();
        
        /* second, update all references to the old name
         * This includes:
         *   PipelineDefinition
         *   PipelineTriggerDefinition
         */
        Query updateQuery1 = session.createSQLQuery("update PI_PIPELINE_DEF set PI_PD_NAME_NAME = :newName where "
            + "PI_PD_NAME_NAME = :oldName");
        updateQuery1.setParameter("newName", newName);
        updateQuery1.setParameter("oldName", oldName);

        int updatedRows = updateQuery1.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_PIPELINE_DEF");

        Query updateQuery2 = session.createSQLQuery("update PI_TRIGGER_DEF set PI_PD_NAME_NAME = :newName where "
            + "PI_PD_NAME_NAME = :oldName");
        updateQuery2.setParameter("newName", newName);
        updateQuery2.setParameter("oldName", oldName);

        updatedRows = updateQuery2.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_TRIGGER_DEF");
        
        // flush these changes so the delete below will not fail due to a foreign key
        // constraint violation
        session.flush();

        Query deleteQuery = session.createSQLQuery("delete from PI_PD_NAME where NAME = :oldName");
        deleteQuery.setParameter("oldName", oldName);
        int deletedRows = deleteQuery.executeUpdate();
        log.debug("Deleted " + deletedRows + " rows in PI_PD_NAME");
    }

}
