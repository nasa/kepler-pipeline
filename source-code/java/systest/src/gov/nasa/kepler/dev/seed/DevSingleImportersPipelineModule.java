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

package gov.nasa.kepler.dev.seed;

import gov.nasa.kepler.cm.CmSeedData;
import gov.nasa.kepler.fc.importer.ImporterGain;
import gov.nasa.kepler.fc.importer.ImporterGeometry;
import gov.nasa.kepler.fc.importer.ImporterLargeFlatField;
import gov.nasa.kepler.fc.importer.ImporterLinearity;
import gov.nasa.kepler.fc.importer.ImporterParentNonImage;
import gov.nasa.kepler.fc.importer.ImporterPointing;
import gov.nasa.kepler.fc.importer.ImporterReadNoise;
import gov.nasa.kepler.fc.importer.ImporterRollTime;
import gov.nasa.kepler.fc.importer.ImporterSaturation;
import gov.nasa.kepler.fc.importer.ImporterUndershoot;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.kepler.hibernate.mc.EbTransitParameterModel;
import gov.nasa.kepler.hibernate.mc.TransitNameModel;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.EbTransitParameterModelImporter;
import gov.nasa.kepler.mc.TransitNameModelImporter;
import gov.nasa.kepler.mc.TransitParameterModelImporter;
import gov.nasa.kepler.mc.cm.KicOverrideModelImporter;
import gov.nasa.kepler.mc.obslog.ObservingLogImporter;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.mr.MrSeedTestData;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.services.security.SecuritySeedData;
import gov.nasa.kepler.systest.IncomingFileCopierRequester;
import gov.nasa.kepler.tad.peer.chartable.TadProductCharTypeCreator;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Imports models that are not specific to a mod/out.
 * 
 * @author Miles Cote
 * 
 */
public class DevSingleImportersPipelineModule extends PipelineModule {

    private static final Log log = LogFactory.getLog(DevSingleImportersPipelineModule.class);

    public static final String MODULE_NAME = "dev-single-importers";

    private static final String DESCRIPTION = "Created by DevSingleImportersPM from: ";

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(DataRepoParameters.class);
        requiredParams.add(ModelImportParameters.class);
        requiredParams.add(SeedParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {
            DataRepoParameters dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);
            ModelImportParameters modelImportParameters = pipelineTask.getParameters(ModelImportParameters.class);
            SeedParameters seed = pipelineTask.getParameters(SeedParameters.class);

            String dataRepoRootPath = dataRepoParams.getDataRepoPath();

            if (seed.isSeedSpiceEnabled()) {
                seedSpice(modelImportParameters, dataRepoRootPath);
            }

            // FC models
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + "rootdir", dataRepoRootPath);

            // roll-time
            log.info("Importing roll-time model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterRollTime.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getRolltimePath());
            new ImporterRollTime().rewriteHistory(DESCRIPTION
                + modelImportParameters.getRolltimePath());

            // pointing
            log.info("Importing pointing model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterPointing.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getPointingPath());
            new ImporterPointing().rewriteHistory(DESCRIPTION
                + modelImportParameters.getPointingPath());

            // geometry
            log.info("Importing geometry model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterGeometry.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getGeometryPath());
            new ImporterGeometry().rewriteHistory(DESCRIPTION
                + modelImportParameters.getGeometryPath());

            // read-noise
            log.info("Importing read-noise model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterReadNoise.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getReadNoisePath());
            new ImporterReadNoise().rewriteHistory(DESCRIPTION
                + modelImportParameters.getReadNoisePath());

            // gain
            log.info("Importing gain model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterGain.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getGainPath());
            new ImporterGain().rewriteHistory(DESCRIPTION
                + modelImportParameters.getGainPath());

            // linearity
            log.info("Importing linearity model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterLinearity.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getLinearityPath());
            new ImporterLinearity().rewriteHistory(DESCRIPTION
                + modelImportParameters.getLinearityPath());

            // undershoot
            log.info("Importing undershoot model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterUndershoot.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getUndershootPath());
            new ImporterUndershoot().rewriteHistory(DESCRIPTION
                + modelImportParameters.getUndershootPath());

            // invalid-pixels
            // System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
            // + ImporterInvalidPixels.DATAFILE_DIRECTORY_NAME,
            // modelImport.getInvalidPixelsPath());
            // new ImporterInvalidPixels().rewriteHistory(reason +
            // modelImport.getInvalidPixelsPath());

            // large-flat
            log.info("Importing large-flat model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterLargeFlatField.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getLargeFlatPath());
            new ImporterLargeFlatField().rewriteHistory(DESCRIPTION
                + modelImportParameters.getLargeFlatPath());

            // saturation
            log.info("Importing saturation model ...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterSaturation.DATAFILE_DIRECTORY_NAME,
                modelImportParameters.getSaturationPath());
            new ImporterSaturation().rewriteHistory(DESCRIPTION
                + modelImportParameters.getSaturationPath());

            // kic-override-model
            log.info("Importing kic-override model ...");
            importKicOverrideModel(modelImportParameters, dataRepoRootPath);

            // observing log model
            log.info("Importing observing log model ...");
            importObservingLogModel(modelImportParameters, dataRepoRootPath);

            // KOI transit parameter model
            log.info("Importing koi transit parameter model ...");
            importTransitParameterModel(modelImportParameters, dataRepoRootPath);

            // EB transit parameter model
            log.info("Importing eb transit parameter model ...");
            importEbTransitParameterModel(modelImportParameters, dataRepoRootPath);

            // transit name model
            log.info("Importing transit name model ...");
            importTransitNameModel(modelImportParameters, dataRepoRootPath);

            // seed cm
            log.info("Loading CM seed data ...");
            new CmSeedData().loadSeedData();

            // seed security
            if (seed.isSeedSecurityEnabled()) {
                log.info("Loading security seed data ...");
                new SecuritySeedData().loadSeedData();
            }

            // seed mr
            log.info("Loading MR seed data ...");
            new MrSeedTestData().loadSeedData();

            // seed some char types
            log.info("Seeding some char types ...");
            new TadProductCharTypeCreator().run();
            
            log.info("Done.");

        } catch (Exception e) {
            throw new PipelineException("Unable to import data.", e);
        }
    }

    private void importKicOverrideModel(ModelImportParameters modelImport,
        String dataRepoRootPath) throws IOException {
        File komDir = new File(dataRepoRootPath + "/"
            + modelImport.getKicOverrideModelPath());

        File komFile = null;
        for (File file : komDir.listFiles()) {
            if (file.getName()
                .endsWith("txt")) {
                komFile = file;
            }
        }

        KicOverrideModelImporter kicOverrideModelImporter = new KicOverrideModelImporter();
        KicOverrideModel kicOverrideModel = kicOverrideModelImporter.importFile(komFile);

        ModelOperations<KicOverrideModel> modelOperations = ModelOperationsFactory.getKicOverrideInstance(new ModelMetadataRetrieverLatest());
        modelOperations.replaceExistingModel(kicOverrideModel, DESCRIPTION
            + komDir.getAbsolutePath());
    }

    private void importObservingLogModel(ModelImportParameters modelImport,
        String dataRepoRootPath) throws Exception {
        File modelDir = new File(dataRepoRootPath + "/"
            + modelImport.getObservingLogModelPath());

        File modelFile = null;
        for (File file : modelDir.listFiles()) {
            if (file.getName().equals("observing-log.xml")) {
                modelFile = file;
            }
        }

        ObservingLogImporter observingLogModelImporter = new ObservingLogImporter();
        observingLogModelImporter.importFile(modelFile, DESCRIPTION);
    }

    private void importTransitParameterModel(
        ModelImportParameters modelImportParameters, String dataRepoRootPath)
        throws IOException {
        File tpmDir = new File(dataRepoRootPath + "/"
            + modelImportParameters.getTransitParameterModelPath());

        File tpmFile = null;
        for (File file : tpmDir.listFiles()) {
            if (file.getName()
                .endsWith("csv") && file.getName()
                .startsWith("cumulative")) {
                tpmFile = file;
            }
        }

        TransitParameterModelImporter transitParameterModelImporter = new TransitParameterModelImporter();
        TransitParameterModel transitParameterModel = transitParameterModelImporter.importFile(tpmFile);

        ModelOperations<TransitParameterModel> modelOperations = ModelOperationsFactory.getTransitParameterInstance(new ModelMetadataRetrieverLatest());
        modelOperations.replaceExistingModel(transitParameterModel, DESCRIPTION
            + tpmDir.getAbsolutePath());
    }

    private void importEbTransitParameterModel(
        ModelImportParameters modelImportParameters, String dataRepoRootPath)
        throws IOException {
        File tpmDir = new File(dataRepoRootPath + "/"
            + modelImportParameters.getEbTransitParameterModelPath());

        File tpmFile = null;
        for (File file : tpmDir.listFiles()) {
            if (file.getName()
                .endsWith("txt")) {
                tpmFile = file;
            }
        }

        EbTransitParameterModelImporter ebTransitParameterModelImporter = new EbTransitParameterModelImporter();
        EbTransitParameterModel ebTransitParameterModel = ebTransitParameterModelImporter.importFile(tpmFile);

        ModelOperations<EbTransitParameterModel> modelOperations = ModelOperationsFactory.getEbTransitParameterInstance(new ModelMetadataRetrieverLatest());
        modelOperations.replaceExistingModel(ebTransitParameterModel, DESCRIPTION
            + tpmDir.getAbsolutePath());
    }

    private void importTransitNameModel(
        ModelImportParameters modelImportParameters, String dataRepoRootPath)
        throws IOException {
        File tpmDir = new File(dataRepoRootPath + "/"
            + modelImportParameters.getTransitNameModelPath());

        File tpmFile = null;
        for (File file : tpmDir.listFiles()) {
            if (file.getName()
                .endsWith("csv") && file.getName()
                .startsWith("keplernames")) {
                tpmFile = file;
            }
        }

        TransitNameModelImporter transitNameModelImporter = new TransitNameModelImporter();
        TransitNameModel transitNameModel = transitNameModelImporter.importFile(tpmFile);

        ModelOperations<TransitNameModel> modelOperations = ModelOperationsFactory.getTransitNameInstance(new ModelMetadataRetrieverLatest());
        modelOperations.replaceExistingModel(transitNameModel, DESCRIPTION
            + tpmDir.getAbsolutePath());
    }

    private void seedSpice(ModelImportParameters modelImport,
        String dataRepoRootPath) throws InterruptedException {

        IncomingFileCopierRequester requester = new IncomingFileCopierRequester();

        requester.requestCopyAndWaitForNmCompletion(dataRepoRootPath + "/"
            + modelImport.getSpacecraftEphemPath());
        requester.requestCopyAndWaitForNmCompletion(dataRepoRootPath + "/"
            + modelImport.getPlanetaryEphemPath());
        requester.requestCopyAndWaitForNmCompletion(dataRepoRootPath + "/"
            + modelImport.getLeapSecsPath());
        requester.requestCopyAndWaitForNmCompletion(dataRepoRootPath + "/"
            + modelImport.getSclkPath());
    }

}
