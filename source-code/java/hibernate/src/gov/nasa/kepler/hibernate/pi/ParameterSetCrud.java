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
 * Provides CRUD methods for {@link ParameterSet}
 * 
 * @author tklaus
 * 
 */
public class ParameterSetCrud extends AbstractCrud{
    private static final Log log = LogFactory.getLog(ParameterSetCrud.class);

    public ParameterSetCrud() {
    }

    public ParameterSetCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(ParameterSet parameterSet) {
        getSession().save(parameterSet);
    }

    public void delete(ParameterSet parameterSet) {
        getSession().delete(parameterSet);
    }

    public List<ParameterSet> retrieveAllVersionsForName(String name) {
        
        Session session = getSession();
        Query q = session.createQuery("from ParameterSetName p where p.name = :name");
        q.setString("name", name);
        q.setMaxResults(1);

        ParameterSetName parameterSetName = uniqueResult(q); 
            
        if(parameterSetName == null){
            return new ArrayList<ParameterSet>();
        }
        
        q = session.createQuery("from ParameterSet p where p.name = :name order by version asc");
        q.setEntity("name", parameterSetName);

        List<ParameterSet> result = list(q);

        return result;
    }

    public List<ParameterSet> retrieveAll() {
        Session session = getSession();
        Query q = session.createQuery("from ParameterSet p order by name asc");

        List<ParameterSet> result = list(q);

        return result;
    }

    public ParameterSet retrieveLatestVersionForName(String name) {

        Session session = getSession();
        Query q = session.createQuery("from ParameterSetName p where p.name = :name");
        q.setString("name", name);
        q.setMaxResults(1);
        ParameterSetName parameterSetName = uniqueResult(q);

        if(parameterSetName == null){
            log.info("No ParameterSetName found for name = " + name);
            return null;
        }
        
        ParameterSet result = retrieveLatestVersionForName(parameterSetName);

        return result;
    }

    public ParameterSet retrieve(long id) {

        Session session = getSession();
        Query q = session.createQuery("from ParameterSet p where p.id = :id");
        q.setLong("id", id);
        q.setMaxResults(1);
        
        ParameterSet result = uniqueResult(q);
        return result;
    }

    public ParameterSet retrieveLatestVersionForName(ParameterSetName name) {
        Session session = getSession();
        Query q = session.createQuery("from ParameterSet pmps where pmps.name = :name order by version desc");
        q.setEntity("name", name);
        q.setMaxResults(1);

        ParameterSet result = uniqueResult(q);

        return result;
    }

    public List<ParameterSet> retrieveLatestVersions() {
        Session session = getSession();
        Query q = session.createQuery("from ParameterSetName order by name");

        List<ParameterSetName> names = list(q);

        List<ParameterSet> results = new ArrayList<ParameterSet>();

        for (ParameterSetName name : names) {
            ParameterSet latestVersion = retrieveLatestVersionForName(name);
            
            if(latestVersion != null){
                results.add(latestVersion);
            }else{
                log.info("no versions found for name = " + name);
            }
        }

        return results;
    }

    public void rename(ParameterSet parameterSet, String newName){
        Session session = getSession();
        String oldName = parameterSet.getName().getName();

        // first, create the new name in PI_PS_NAME
        ParameterSetName newNameEntity = new ParameterSetName(newName);
        session.save(newNameEntity);

        // flush these changes so the updates below will see them
        session.flush();
        
        /* second, update all references to the old name
         * This includes:
         *  TriggerDefinition (via PI_TD_PSN)
         *  TriggerDefinitionNode (via PI_TDN_MPS)
         *  PipelineInstance (via PI_INSTANCE_PS)
         *  PipelineInstanceNode (via PI_PIN_PI_MPS)
         */
        Query updateQuery1 = session.createSQLQuery("update PI_PS set PI_PS_NAME_NAME = :newName where "
            + "PI_PS_NAME_NAME = :oldName");
        updateQuery1.setParameter("newName", newName);
        updateQuery1.setParameter("oldName", oldName);

        int updatedRows = updateQuery1.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_PS");
        
        Query updateQuery2 = session.createSQLQuery("update PI_TD_PSN set PI_PS_NAME_NAME = :newName where "
            + "PI_PS_NAME_NAME = :oldName");
        updateQuery2.setParameter("newName", newName);
        updateQuery2.setParameter("oldName", oldName);

        updatedRows = updateQuery2.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_TD_PSN");
        
        Query updateQuery3 = session.createSQLQuery("update PI_TDN_MPS set PI_PS_NAME_NAME = :newName where "
            + "PI_PS_NAME_NAME = :oldName");
        updateQuery3.setParameter("newName", newName);
        updateQuery3.setParameter("oldName", oldName);

        updatedRows = updateQuery3.executeUpdate();
        
        log.debug("Updated " + updatedRows + " rows in PI_TDN_MPS");        
        
        // flush these changes so the delete below will not fail due to a foreign key
        // constraint violation
        session.flush();

        Query deleteQuery = session.createSQLQuery("delete from PI_PS_NAME where NAME = :oldName");
        deleteQuery.setParameter("oldName", oldName);
        int deletedRows = deleteQuery.executeUpdate();
        log.debug("Deleted " + deletedRows + " rows in PI_PS_NAME");
    }
}
