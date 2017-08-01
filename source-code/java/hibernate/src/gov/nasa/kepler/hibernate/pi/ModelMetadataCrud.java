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
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * CRUD methods for accessing and updating the model metadata registry
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class ModelMetadataCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(ModelMetadataCrud.class);

    public ModelMetadataCrud() {
    }

    public ModelMetadataCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public ModelRegistry retrieveLatestRegistry() {
        Session session = getSession();
        Query q = session.createQuery("from ModelRegistry r order by version desc");
        q.setMaxResults(1);
        ModelRegistry registry = uniqueResult(q);

        if (registry == null) {
            log.warn("No ModelRegistry found");
            return null;
        }
        return registry;
    }

    public ModelMetadata retrieveLatestModelRevision(String modelType) {
        ModelRegistry registry = retrieveLatestRegistry();

        if (registry == null) {
            log.debug("No ModelRegistry found");
            return null;
        }

        ModelMetadata modelMetadata = registry.getModels()
            .get(new ModelType(modelType));

        if (modelMetadata == null) {
            log.debug("No ModelMetadata found for type = " + modelType);
            return null;
        }
        return modelMetadata;
    }

    /**
     * This method is used by model importers/updaters to notify the pipeline
     * infrastructure that a model has been updated or created.
     * 
     * @param modelType Name/type of the model
     * @param modelDescription Operator-supplied description of the model or
     * reason for update
     * @param importTime Timestamp when the model was created/updated
     * @param modelRevision String that describes this revision of the model
     * (SVN url, etc.)
     */
    public ModelMetadata updateModelMetaData(String modelType,
        String modelDescription, Date importTime, String modelRevision) {
        ModelType type = retrieveModelType(modelType);

        ModelRegistry registry = retrieveLatestRegistry();
        if (registry == null) {
            registry = new ModelRegistry();
            getSession().save(registry);
        } else if (registry.isLocked()) {
            registry = registry.newVersion();
            getSession().save(registry);
        }

        ModelMetadata model = registry.getModels()
            .get(type);

        if (model == null || model.isLocked()) {
            model = new ModelMetadata(type, modelDescription, modelRevision,
                importTime);
        } else {
            // update the existing, unlocked instance
            model.setModelDescription(modelDescription);
            model.setImportTime(importTime);
            model.setModelRevision(modelRevision);
        }
        // update the current (unlocked) version of the registry with the new
        // revision of the model
        registry.getModels()
            .put(type, model);

        return model;
    }

    /**
     * Return the most recent version of the {@link ModelRegistry}, locking it
     * if necessary. Used to associate a {@link PipelineInstance} with an
     * immutable registry version for data accountability purposes.
     * 
     * @return
     */
    public ModelRegistry lockCurrentRegistry() {
        ModelRegistry registry = retrieveLatestRegistry();

        if (registry == null) {
            registry = new ModelRegistry();
            getSession().save(registry);
        }

        if (!registry.isLocked()) {
            Map<ModelType, ModelMetadata> models = registry.getModels();
            for (ModelMetadata model : models.values()) {
                model.lock();
            }
            registry.lock();
        }
        return registry;
    }

    /**
     * Import a new data model registry. This method should only be used to seed
     * a database that contains no existing model registry.
     * 
     * @param newRegistry
     */
    public void importNewModelRegistry(ModelRegistry newRegistry) {
        if (retrieveLatestRegistry() != null) {
            throw new PipelineException(
                "Import FAILED: database already contains"
                    + " a model registry.");
        }

        // persist model types
        Set<ModelType> modelTypes = newRegistry.getModels()
            .keySet();
        for (ModelType modelType : modelTypes) {
            getSession().save(modelType);
        }

        // persist registry
        getSession().save(newRegistry);
    }

    // Used only by tests and internally
    ModelType retrieveModelType(String type) {

        Session session = getSession();
        Query q = session.createQuery("from ModelType mt where mt.type = :type");
        q.setString("type", type);
        q.setMaxResults(1);
        ModelType modelType = uniqueResult(q);

        if (modelType == null) {
            modelType = new ModelType(type);
            createModelType(modelType);
        }
        return modelType;
    }

    // Used only by tests and internally
    List<ModelMetadata> retrieveAllModelRevisions(String modelType) {

        Session session = getSession();
        Query q = session.createQuery("from ModelMetadata m where m.modelType.type = :type"
            + " order by importTime desc");
        q.setString("type", modelType);

        List<ModelMetadata> models = list(q);

        if (models == null) {
            log.debug("No ModelMetadata found for type = " + modelType);
            return null;
        }

        return models;
    }

    // Used only by tests and internally
    List<ModelRegistry> retrieveAllRegistryRevisions() {

        Session session = getSession();
        Query q = session.createQuery("from ModelRegistry r order by version desc");

        List<ModelRegistry> models = list(q);

        if (models == null) {
            log.debug("No ModelRegistries found");
            return null;
        }

        return models;
    }

    // Used only by tests and internally
    void createModelType(ModelType modelType) {
        getSession().save(modelType);
    }

    // Used only by tests and internally
    List<ModelType> retrieveAllModelTypes() {

        Session session = getSession();
        Query q = session.createQuery("from ModelType mt");

        List<ModelType> result = list(q);

        return result;
    }
}
