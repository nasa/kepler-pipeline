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

import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.hibernate.pi.ModelRegistry;
import gov.nasa.kepler.hibernate.pi.ModelType;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.pi.modelRegistry.DataModelRegistryDocument;
import gov.nasa.kepler.pi.modelRegistry.ModelMetadataXB;
import gov.nasa.kepler.pi.modelRegistry.ModelRegistryXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Operations class for the model metadata registry. This registry maintains
 * metadata about models in the system for data accountability purposes.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class ModelMetadataOperations {
    private static final Logger log = Logger.getLogger(ModelMetadataOperations.class);

    public ModelMetadataOperations() {
    }

    /**
     * Returns a String containing a textual report of the latest version of the
     * metadata for all models in the registry.
     * 
     * @return The report
     */
    public String report() {
        ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
        ModelRegistry registry = modelMetadataCrud.retrieveLatestRegistry();

        if (registry != null) {
            return report(registry);
        } else {
            return "No Model Registry found";
        }
    }

    /**
     * Returns a String containing a textual report of the model registry
     * associated with the specified pipeline instance.
     * 
     * @param pipelineInstance
     * @return
     */
    public String report(PipelineInstance pipelineInstance) {
        ModelRegistry registry = pipelineInstance.getModelRegistry();

        if (registry != null) {
            return report(registry);
        } else {
            return "No Model Registry found for this pipeline instance.";
        }
    }

    /**
     * Produce a report for the specified ModelRegistry
     * 
     * @param registry
     * @return
     */
    private String report(ModelRegistry registry) {
        StringBuilder sb = new StringBuilder();

        Map<ModelType, ModelMetadata> models = registry.getModels();
        List<ModelType> latestModelTypes = new LinkedList<ModelType>(models.keySet());
        Collections.sort(latestModelTypes);

        sb.append("version=" + registry.getVersion() + ", locked=" + registry.isLocked() + ", lockTimestamp="
            + registry.getLockTime() + "\n");

        if (latestModelTypes.isEmpty()) {
            sb.append("  <No models in registry>\n");
        } else {
            for (ModelType type : latestModelTypes) {
                ModelMetadata model = models.get(type);

                sb.append("  type=" + type + "\n");
                sb.append("    importTime=" + model.getImportTime() + "\n");
                sb.append("    revision=" + model.getModelRevision() + "\n");
                sb.append("    description=" + model.getModelDescription() + "\n");
                sb.append("    locked=" + model.isLocked() + "\n");
                sb.append("    lockTime=" + model.getLockTime() + "\n");
                sb.append("\n");
            }
        }
        return sb.toString();
    }

    /**
     * Export the current contents of the Data Model Registry to an XML file.
     * 
     * @param destinationPath
     * @throws IOException
     */
    public void exportModelRegistry(String destinationPath) throws IOException {

        File destinationFile = new File(destinationPath);
        if (destinationFile.exists() && destinationFile.isDirectory()) {
            throw new IllegalArgumentException("destinationPath exists and is a directory: " + destinationFile);
        }

        DataModelRegistryDocument modelRegistryDocument = DataModelRegistryDocument.Factory.newInstance();
        ModelRegistryXB modelRegistryXmlBean = modelRegistryDocument.addNewDataModelRegistry();

        ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
        ModelRegistry registry = modelMetadataCrud.retrieveLatestRegistry();

        if (registry != null) {
            Calendar calendar;
            
            Map<ModelType, ModelMetadata> models = registry.getModels();
            log.info("Exporting " + models.size() + " models to: " + destinationFile);

            List<ModelType> latestModelTypes = new LinkedList<ModelType>(models.keySet());
            Collections.sort(latestModelTypes);

            for (ModelType type : latestModelTypes) {
                ModelMetadata model = models.get(type);

                ModelMetadataXB modelXmlBean = modelRegistryXmlBean.addNewModelMetadata();
                modelXmlBean.setType(model.getModelType()
                    .toString());
                modelXmlBean.setRevision(model.getModelRevision());
                calendar = Calendar.getInstance();
                calendar.setTime(model.getImportTime());
                modelXmlBean.setImportTime(calendar);
                modelXmlBean.setDescription(model.getModelDescription());
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!modelRegistryDocument.validate(xmlOptions)) {
            throw new PipelineException("Export of ModelRegistry failed: XML validation errors: " + errors);
        }

        modelRegistryDocument.save(destinationFile, xmlOptions);
    }
    
    /**
     * Import a new model registry from the specified XML file.
     * Importing from an XML file is only allowed if the database
     * does not contain any ModelRegistry objects (use for seeding ONLY).
     * 
     * @param sourcePath
     * @throws Exception
     */
    public void importModelRegistry(String sourcePath) throws Exception{
        File sourceFile = new File(sourcePath);

        ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
        
        DataModelRegistryDocument modelRegistryDocument = DataModelRegistryDocument.Factory.parse(sourceFile);
        ModelRegistryXB modelRegistryXmlBean = modelRegistryDocument.getDataModelRegistry();
        
        ModelRegistry newRegistry = new ModelRegistry();
        Map<ModelType, ModelMetadata> models = newRegistry.getModels();
        
        ModelMetadataXB[] xmlModels = modelRegistryXmlBean.getModelMetadataArray();
        
        for (ModelMetadataXB xmlModel : xmlModels) {
            ModelMetadata model = new ModelMetadata();
            ModelType modelType = new ModelType(xmlModel.getType());
            model.setModelType(modelType);
            model.setModelRevision(xmlModel.getRevision());
            model.setImportTime(xmlModel.getImportTime().getTime());
            model.setModelDescription(xmlModel.getDescription());
            
            models.put(modelType, model);
        }
        modelMetadataCrud.importNewModelRegistry(newRegistry);
    }
}
