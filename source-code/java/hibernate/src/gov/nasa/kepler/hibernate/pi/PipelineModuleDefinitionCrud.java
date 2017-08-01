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
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD methods for {@link PipelineModuleDefinition}
 * 
 * @author tklaus
 * 
 */
public class PipelineModuleDefinitionCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(PipelineModuleDefinitionCrud.class);

    public PipelineModuleDefinitionCrud() {
    }

    public PipelineModuleDefinitionCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * 
     * @return @
     */
    public List<PipelineModuleDefinition> retrieveAll() {
        List<PipelineModuleDefinition> results = list(getSession().createQuery("from PipelineModuleDefinition pmd order by pmd.name"));
        return results;
    }

    public List<PipelineModuleDefinition> retrieveAllVersionsForName(String name) {
        
        Session session = getSession();
        Query q = session.createQuery("from ModuleName m where m.name = :name");
        q.setString("name", name);
        q.setMaxResults(1);

        ModuleName moduleName = uniqueResult(q); 
            
        if(moduleName == null){
            return new ArrayList<PipelineModuleDefinition>();
        }
        
        q = session.createQuery("from PipelineModuleDefinition p where p.name = :name order by version asc");
        q.setEntity("name", moduleName);

        List<PipelineModuleDefinition> result = list(q);

        return result;
    }

    public PipelineModuleDefinition retrieveLatestVersionForName(String name) {

        Session session = getSession();
        Query q = session.createQuery("from ModuleName m where m.name = :name");
        q.setString("name", name);
        q.setMaxResults(1);
        ModuleName moduleName = uniqueResult(q);

        if(moduleName == null){
            log.info("No ModuleName found for name = " + name);
            return null;
        }
        
        PipelineModuleDefinition result = retrieveLatestVersionForName(moduleName);

        return result;
    }

    public PipelineModuleDefinition retrieveLatestVersionForName(ModuleName name) {
        Session session = getSession();
        Query q = session.createQuery("from PipelineModuleDefinition pmd where pmd.name = :name order by version desc");
        q.setEntity("name", name);
        q.setMaxResults(1);

        PipelineModuleDefinition result = uniqueResult(q);

        return result;
    }

    public List<PipelineModuleDefinition> retrieveLatestVersions() {
        Session session = getSession();
        Query q = session.createQuery("from ModuleName order by name");

        List<ModuleName> names = list(q);

        List<PipelineModuleDefinition> results = new ArrayList<PipelineModuleDefinition>();

        for (ModuleName name : names) {
            results.add(retrieveLatestVersionForName(name));
        }

        return results;
    }

    /**
     * 
     * @param module @
     */
    public void delete(PipelineModuleDefinition module) {
        getSession().delete(module);
    }

    /**
     * 
     * @param module
     * @return @
     */
    public void create(PipelineModuleDefinition module) {
        getSession().save(module);
    }
    
    public void rename(PipelineModuleDefinition moduleDef, String newName){
        Session session = getSession();
        String oldName = moduleDef.getName().getName();
        
        // first, create the new name in PI_MOD_NAME
        ModuleName newNameEntity = new ModuleName(newName);
        session.save(newNameEntity);
        
        // flush these changes so the updates below will see them
        session.flush();
        
        /* second, update all references to the old name
         * This includes:
         *   PipelineModuleDefinition
         *   PipelineDefinitionNode
         *   PipelineInstanceNode
         *   TriggerDefinitionNode
         *   MrReport          
         */
        Query updateQuery1 = session.createSQLQuery("update PI_MOD_DEF set PI_MOD_NAME_NAME = :newName where "
            + "PI_MOD_NAME_NAME = :oldName");
        updateQuery1.setParameter("newName", newName);
        updateQuery1.setParameter("oldName", oldName);

        int updatedRows = updateQuery1.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_MOD_DEF");

        Query updateQuery2 = session.createSQLQuery("update PI_PIPELINE_DEF_NODE set PI_MOD_NAME_NAME = :newName where "
            + "PI_MOD_NAME_NAME = :oldName");
        updateQuery2.setParameter("newName", newName);
        updateQuery2.setParameter("oldName", oldName);

        updatedRows = updateQuery2.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_PIPELINE_DEF_NODE");
        
        Query updateQuery3 = session.createSQLQuery("update PI_TRIGGER_DEF_NODE set PI_MOD_NAME_NAME = :newName where "
            + "PI_MOD_NAME_NAME = :oldName");
        updateQuery3.setParameter("newName", newName);
        updateQuery3.setParameter("oldName", oldName);

        updatedRows = updateQuery3.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_TRIGGER_DEF_NODE");
        
        Query updateQuery4 = session.createSQLQuery("update MR_REPORT set PI_MOD_NAME_NAME = :newName where "
            + "PI_MOD_NAME_NAME = :oldName");
        updateQuery4.setParameter("newName", newName);
        updateQuery4.setParameter("oldName", oldName);

        updatedRows = updateQuery4.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in MR_REPORT");
        
        // flush these changes so the delete below will not fail due to a foreign key
        // constraint violation
        session.flush();

        Query deleteQuery = session.createSQLQuery("delete from PI_MOD_NAME where NAME = :oldName");
        deleteQuery.setParameter("oldName", oldName);
        int deletedRows = deleteQuery.executeUpdate();
        log.debug("Deleted " + deletedRows + " rows in PI_MOD_NAME");
    }
}
