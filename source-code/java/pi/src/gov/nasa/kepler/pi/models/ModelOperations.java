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

package gov.nasa.kepler.pi.models;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;

import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Contains operations related to {@link Model}s.
 * 
 * @author Miles Cote
 * 
 */
public class ModelOperations<T extends Model> {

    private static final Log log = LogFactory.getLog(ModelOperations.class);

    private final ModelMetadataCrud modelMetadataCrud;
    private final ModelCrud<T> modelCrud;
    private final Date created;
    private final ModelMetadataRetriever modelMetadataRetriever;

    public ModelOperations(ModelCrud<T> modelCrud,
        ModelMetadataRetriever modelMetadataRetriever) {
        this(new ModelMetadataCrud(), modelCrud, new Date(),
            modelMetadataRetriever);
    }

    ModelOperations(ModelMetadataCrud modelMetadataCrud,
        ModelCrud<T> modelCrud, Date created,
        ModelMetadataRetriever modelMetadataRetriever) {
        this.modelMetadataCrud = modelMetadataCrud;
        this.modelCrud = modelCrud;
        this.created = created;
        this.modelMetadataRetriever = modelMetadataRetriever;
    }

    public void replaceExistingModel(T model, String modelDescription) {
        ModelMetadata latestModelMetadata = modelMetadataCrud.retrieveLatestModelRevision(modelCrud.getType());

        int revision = getRevision(latestModelMetadata);

        log.info(String.format("Existing %s model %s is at revision %d\n",
            modelCrud.getType(), latestModelMetadata, revision));

        // If the latest metadata is unlocked, then delete it.
        if (latestModelMetadata != null && !latestModelMetadata.isLocked()) {
            T existingModel = retrieveModel();
            log.info(String.format("Existing model is %s\n", existingModel));
            if (existingModel != null) {
                if (existingModel.getRevision() != revision) {
                    throw new IllegalStateException(
                        "The revision to delete must be the latest revision.\n  revisionToDelete: "
                            + existingModel.getRevision()
                            + "\n  latestRevision: " + revision);
                }

                log.info(String.format("Delete existing model\n", existingModel));
                modelCrud.delete(existingModel);

                DatabaseServiceFactory.getInstance()
                    .getSession()
                    .flush();
            }
        }

        revision++;

        log.info(String.format(
            "Update %s model metadata using description \"%s\" at revision %d\n",
            modelCrud.getType(), modelDescription, revision));
        modelMetadataCrud.updateModelMetaData(modelCrud.getType(),
            modelDescription, created, String.valueOf(revision));

        model.setRevision(revision);

        modelCrud.create(model);
    }

    public T retrieveModel() {
        ModelMetadata modelMetadata = modelMetadataRetriever.retrieve(modelCrud.getType());
        if (modelMetadata == null) {
            return null;
        }

        int revision = getRevision(modelMetadata);

        T model = modelCrud.retrieve(revision);

        return model;
    }

    public String getModelDescription() {
        ModelMetadata modelMetadata = modelMetadataRetriever.retrieve(modelCrud.getType());
        if (modelMetadata == null) {
            return null;
        }

        return modelMetadata.getModelDescription();
    }

    public static final int getRevision(ModelMetadata modelMetadata) {
        int revision = Model.NULL_REVISION;
        if (modelMetadata != null) {
            revision = Integer.parseInt(modelMetadata.getModelRevision());
        }

        return revision;
    }
}
