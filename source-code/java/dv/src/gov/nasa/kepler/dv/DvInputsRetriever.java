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

package gov.nasa.kepler.dv;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.KeplerSocBranch;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.persistable.SdfPersistableOutputStream;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.io.AncillaryEngineeringDataContainer;
import gov.nasa.kepler.dv.io.CentroidTestParameters;
import gov.nasa.kepler.dv.io.DvInputs;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvTargetData;
import gov.nasa.kepler.dv.io.DvTransit;
import gov.nasa.kepler.dv.io.PixelCorrelationParameters;
import gov.nasa.kepler.dv.io.TrapezoidalFitParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.mc.TransitNameModel;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DifferenceImageParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PlanetFitModuleParameters;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobData;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.pi.NumberOfElementsPerSubTask;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pdc.PdcHarmonicsIdentificationParameters;
import gov.nasa.kepler.pdc.PdcModuleParameters;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.sggen.SkyGroupGenPipelineModule;
import gov.nasa.kepler.tip.TipImporter;
import gov.nasa.kepler.tps.TpsHarmonicsIdentificationParameters;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Retrieve DV pipeline module inputs.
 * 
 * @author Forrest Girouard
 */
public class DvInputsRetriever {

    public static final String PRF_MODEL_SDF_FILENAME = "prfModel-%02d%d.sdf";
    private static final String UKIRT_IMAGE_FILENAME = "target-%09d-ukirt%s";
    public static final String ANCILLARY_ENGINEERING_DATA_SDF_FILENAME = "ancillaryEngineeringData.sdf";

    private static final Log log = LogFactory.getLog(DvInputsRetriever.class);

    public static final String MODULE_NAME = "dv";

    private static final String NULL = "NULL";

    // Variables set by pipeline infrastructure.
    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    private int skyGroupId;
    private int startKeplerId;
    private int endKeplerId;
    private int startCadence;
    private int endCadence;
    private FluxType fluxType;
    private File matlabWorkingDir;
    private InputsHandler inputsHandler;
    private NumberOfElementsPerSubTask elementsPerSubTaskCalc;

    // CRUD.
    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private LogCrud logCrud = new LogCrud();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private BlobOperations blobOperations = new BlobOperations();
    private KicCrud kicCrud = new KicCrud();
    private CelestialObjectOperations celestialObjectOperations;
    private RollTimeOperations rollTimeOperations = new RollTimeOperations();
    private TargetCrud targetCrud = new TargetCrud();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
    private TpsOperations tpsOperations;
    private TpsCrud tpsCrud;
    private MjdToCadence mjdToCadence;
    private DataAnomalyOperations dataAnomalyOperations;
    private TargetTableOperations targetTableOperations;
    private PrfOperations prfOperations = new PrfOperations();
    private ModelOperations<ExternalTceModel> externalTceModelOperations;
    private ModelOperations<TransitNameModel> transitNameModelOperations;
    private ModelOperations<TransitParameterModel> transitParameterModelOperations;
    private ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance;
    private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();

    // Local variables.
    private boolean retrieveInputsCalled;
    private final Set<Long> producerTaskIds = new HashSet<Long>();

    public List<Persistable> retrieveInputs(PipelineTask pipelineTask,
        File workingDirectory, InputsHandler inputsHandler) throws Exception {

        return retrieveInputs(pipelineTask, workingDirectory, inputsHandler,
            new NumberOfElementsPerSubTask() {

                @Override
                public int numberOfElementsPerSubTask(int totalNumberOfElements) {
                    return totalNumberOfElements;
                }
            });
    }

    public List<Persistable> retrieveInputs(PipelineTask pipelineTask,
        File workingDirectory, InputsHandler inputsHandler,
        NumberOfElementsPerSubTask numberOfElementsPerSubTask) throws Exception {

        log.info("start");

        if (retrieveInputsCalled) {
            throw new PipelineException(
                "retrieveInputsCalled may only be called once per instance");
        }
        retrieveInputsCalled = true;

        initializeTask(pipelineTask, workingDirectory, inputsHandler,
            numberOfElementsPerSubTask);

        List<Persistable> inputsList = retrieveInputsInternal();

        producerTaskIdsStream.write(getMatlabWorkingDir(), producerTaskIds);

        return inputsList;
    }

    private void initializeTask(PipelineTask pipelineTask,
        File workingDirectory, InputsHandler inputsHandler,
        NumberOfElementsPerSubTask numberOfElementsPerSubTask) {

        pipelineInstance = pipelineTask.getPipelineInstance();
        this.pipelineTask = pipelineTask;
        this.inputsHandler = inputsHandler;

        if (pipelineTask.getParameters(DvModuleParameters.class)
            .isSimulatedTransitsEnabled() && KeplerSocBranch.isRelease()) {
            throw new ModuleFatalProcessingException(
                "Can't enable simulated transits for released code.");
        }

        setMatlabWorkingDir(workingDirectory);

        PlanetaryCandidatesChunkUowTask task = pipelineTask.uowTaskInstance();
        log.debug("uow=" + task);

        skyGroupId = task.getSkyGroupId();
        startKeplerId = task.getStartKeplerId();
        endKeplerId = task.getEndKeplerId();
        elementsPerSubTaskCalc = numberOfElementsPerSubTask;

        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);
        startCadence = cadenceRangeParameters.getStartCadence();
        endCadence = cadenceRangeParameters.getEndCadence();
        if (startCadence == 0 || endCadence == 0) {
            Pair<Integer, Integer> firstAndLastCadences = logCrud.retrieveFirstAndLastCadences(Cadence.CADENCE_LONG);
            startCadence = startCadence > 0 ? startCadence
                : firstAndLastCadences.left;
            endCadence = endCadence > 0 ? endCadence
                : firstAndLastCadences.right;
        }

        blobOperations.setOutputDir(getMatlabWorkingDir());

        fluxType = FluxType.valueOf(retrieveFluxTypeParameters().getFluxType());
        AncillaryPipelineParameters ancillaryPipelineParameters = pipelineTask.getParameters(AncillaryPipelineParameters.class);
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters = pipelineTask.getParameters(PlanetaryCandidatesFilterParameters.class);
        DifferenceImageParameters differenceImageParameters = pipelineTask.getParameters(DifferenceImageParameters.class);

        targetTableOperations = new TargetTableOperations(getMjdToCadence(),
            fluxType, skyGroupId, startCadence, endCadence, startKeplerId,
            endKeplerId, differenceImageParameters.getBoundedBoxWidth(),
            planetaryCandidatesFilterParameters,
            ancillaryPipelineParameters.getMnemonics(),
            pipelineTask.getParameters(DvModuleParameters.class)
                .isExternalTcesEnabled());
        targetTableOperations.setAncillaryOperations(ancillaryOperations);
        targetTableOperations.setBlobOperations(blobOperations);
        targetTableOperations.setKicCrud(kicCrud);
        targetTableOperations.setCelestialObjectOperations(getCelestialObjectOperations());
        targetTableOperations.setRollTimeOperations(rollTimeOperations);
        targetTableOperations.setTargetSelectionCrud(targetSelectionCrud);
        targetTableOperations.setTargetCrud(targetCrud);
        targetTableOperations.setTpsOperations(getTpsOperations());
        targetTableOperations.setTpsCrud(getTpsCrud());
        if (pipelineTask.getParameters(DvModuleParameters.class)
            .isExternalTcesEnabled()) {
            targetTableOperations.setExternalTceModelOperations(getExternalTceModelOperations());
        }

        log.debug("skyGroupId: " + skyGroupId);
        log.debug("startKeplerId: " + startKeplerId);
        log.debug("endKeplerId: " + endKeplerId);
        log.debug("startCadence: " + startCadence);
        log.debug("endCadence: " + endCadence);
        log.debug("fluxType: " + fluxType);
        log.debug("pipelineInstance: " + pipelineInstance.getId());
        log.debug("pipelineTask: " + pipelineTask.getId());
    }

    private List<Persistable> retrieveInputsInternal() throws IOException {

        MqTimestampSeries cadenceTimes = retrieveCadenceTimes();
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();

        DvInputs inputs = new DvInputs();
        inputs.setAncillaryDesignMatrixParameters(pipelineTask.getParameters(AncillaryDesignMatrixParameters.class));
        inputs.setAncillaryEngineeringParameters(pipelineTask.getParameters(AncillaryEngineeringParameters.class));
        inputs.setAncillaryEngineeringDataFileName(retrieveAncillaryEngineeringData(
            startMjd, endMjd, inputs.getAncillaryEngineeringParameters()));
        inputs.setAncillaryPipelineParameters(pipelineTask.getParameters(AncillaryPipelineParameters.class));
        inputs.setCentroidTestParameters(pipelineTask.getParameters(CentroidTestParameters.class));
        inputs.setConfigMaps(retrieveConfigMaps(cadenceTimes));
        inputs.setDifferenceImageParameters(pipelineTask.getParameters(DifferenceImageParameters.class));
        inputs.setMqCadenceTimes(cadenceTimes);
        DvModuleParameters dvModuleParameters = pipelineTask.getParameters(DvModuleParameters.class);
        inputs.setDvModuleParameters(dvModuleParameters);
        inputs.setFluxTypeParameters(retrieveFluxTypeParameters());
        inputs.setGapFillModuleParameters(pipelineTask.getParameters(GapFillModuleParameters.class));
        inputs.setPdcHarmonicsIdentificationParameters(pipelineTask.getParameters(PdcHarmonicsIdentificationParameters.class));
        inputs.setPixelCorrelationParameters(pipelineTask.getParameters(PixelCorrelationParameters.class));
        inputs.setTpsHarmonicsIdentificationParameters(pipelineTask.getParameters(TpsHarmonicsIdentificationParameters.class));
        inputs.setPdcModuleParameters(pipelineTask.getParameters(PdcModuleParameters.class));
        inputs.setBootstrapModuleParameters(pipelineTask.getParameters(BootstrapModuleParameters.class));
        inputs.setPlanetFitModuleParameters(pipelineTask.getParameters(PlanetFitModuleParameters.class));
        inputs.setRaDec2PixModel(retrieveRaDec2PixModel(cadenceTimes));
        inputs.setSkyGroupId(skyGroupId);
        inputs.setSaturationSegmentModuleParameters(pipelineTask.getParameters(SaturationSegmentModuleParameters.class));
        inputs.setTargetTableData(targetTableOperations.getAllTargetTableData());
        inputs.setPrfModelFileNames(retrievePrfModels());
        inputs.setTpsModuleParameters(pipelineTask.getParameters(TpsModuleParameters.class));
        inputs.setTrapezoidalFitParameters(pipelineTask.getParameters(TrapezoidalFitParameters.class));
        inputs.setSoftwareRevision(pipelineTask.getSoftwareRevision());
        if (dvModuleParameters.isExternalTcesEnabled()) {
            log.debug("setExternalTceModelDescription: "
                + externalTceModelOperations.getModelDescription());
            inputs.setExternalTceModelDescription(extractFilename(externalTceModelOperations.getModelDescription()));
        }
        inputs.setTaskTimeoutSecs(pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition()
            .getExeTimeoutSecs());

        if (dvModuleParameters.isSimulatedTransitsEnabled()) {
            inputs.setTransitInjectionParametersFileName(retrieveTipFile());
        }

        producerTaskIds.addAll(targetTableOperations.latestProducerTaskIds());

        log.info(String.format("Processing %d targets",
            targetTableOperations.getAllTargets()
                .size()));
        
        if (dvModuleParameters.isKoiMatchingEnabled()) {
            retrieveTransits(inputs, targetTableOperations.getAllTargets());
        }
        inputs.setTargets(targetTableOperations.getAllTargets());
        inputs.setKicsByKeplerId(targetTableOperations.getAllCelestialObjectParameters());

        int targetsPerSubTask = elementsPerSubTaskCalc.numberOfElementsPerSubTask(targetTableOperations.getAllTargets()
            .size());
        List<Persistable> inputsList = split(inputs, targetsPerSubTask);
        log.info(String.format(
            "Calling DV MATLAB with %d targets (%d chunk%s, %d target%s per chunk)",
            inputs.getTargets()
                .size(), inputsList.size(), inputsList.size() > 1 ? "s" : "",
            targetsPerSubTask, targetsPerSubTask > 1 ? "s" : ""));

        for (Persistable persistable : inputsList) {
            DvInputs dvInputs = (DvInputs) persistable;
            populateTargets(startMjd, endMjd, dvInputs.getTargets());
            inputsHandler.addSubTaskInputs(dvInputs);
        }

        return inputsList;
    }

    private MqTimestampSeries retrieveCadenceTimes() {
        log.info("Retrieving cadence times");
        MqTimestampSeries cadenceTimes = new MqTimestampSeries(
            rollTimeOperations, getMjdToCadence(), startCadence, endCadence);

        return cadenceTimes;
    }

    private String retrieveAncillaryEngineeringData(double startMjd,
        double endMjd,
        AncillaryEngineeringParameters ancillaryEngineeringParameters) {

        checkNotNull(ancillaryEngineeringParameters,
            "ancillaryEngineeringParameters can't be null");
        log.info("Retrieving ancillary engineering data");

        List<AncillaryEngineeringData> ancillaryEngineeringData = ancillaryOperations.retrieveAncillaryEngineeringData(
            ancillaryEngineeringParameters.getMnemonics(), startMjd, endMjd);
        AncillaryEngineeringDataContainer ancillaryEngineeringDataContainer = new AncillaryEngineeringDataContainer(
            ancillaryEngineeringData);

        String fileName = null;
        try {
            fileName = writeSdfAncillaryEngineeringData(ancillaryEngineeringDataContainer);
        } catch (IOException e) {
            throw new PipelineException(
                "Failed to retrieve ancillary engineering data", e);
        }

        return fileName;
    }

    private String writeSdfAncillaryEngineeringData(
        AncillaryEngineeringDataContainer ancillaryEngineeringDataContainer)
        throws IOException {

        String filename = ANCILLARY_ENGINEERING_DATA_SDF_FILENAME;
        File file = new File(getMatlabWorkingDir(), filename);
        DataOutputStream dataOutputStream = null;
        try {
            dataOutputStream = new DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(file)));
            log.info(String.format(
                "Writing ancillary engineering data into sdf file %s", filename));
            new SdfPersistableOutputStream(dataOutputStream).save(ancillaryEngineeringDataContainer);
        } catch (Exception e) {
            throw new IOException(String.format(
                "Failed to write sdf file[%s], e = %s", file, e), e);
        } finally {
            FileUtil.close(dataOutputStream);
        }

        return filename;
    }

    private List<ConfigMap> retrieveConfigMaps(TimestampSeries cadenceTimes) {

        log.info("Retrieving configuration maps");
        List<ConfigMap> configMaps = configMapOperations.retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        if (configMaps == null || configMaps.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "Need at least one spacecraft config map, but found none");
        }

        return configMaps;
    }

    private FluxTypeParameters retrieveFluxTypeParameters() {
        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);

        return fluxTypeParameters;
    }

    private RaDec2PixModel retrieveRaDec2PixModel(TimestampSeries cadenceTimes) {

        log.info("Retrieving RaDec2PixModel");
        RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        return raDec2PixModel;
    }

    private String[] retrievePrfModels() {

        String[] prfModelFileNames = new String[SkyGroupGenPipelineModule.SEASON_COUNT];
        TimestampSeries cadenceTimes = mjdToCadence.cadenceTimes(startCadence,
            endCadence, true, false);
        double startMjd = cadenceTimes.startMjd();

        for (int season = 0; season < SkyGroupGenPipelineModule.SEASON_COUNT; season++) {
            SkyGroup skyGroup = kicCrud.retrieveSkyGroup(skyGroupId, season);

            log.info(String.format("Retrieving PRF model for mod/out %d/%d",
                skyGroup.getCcdModule(), skyGroup.getCcdOutput()));
            PrfModel prfModel = prfOperations.retrievePrfModel(startMjd,
                skyGroup.getCcdModule(), skyGroup.getCcdOutput());
            if (prfModel == null) {
                log.warn(String.format("PRF model missing for mod/out %d/%d",
                    skyGroup.getCcdModule(), skyGroup.getCcdOutput()));
                prfModelFileNames[season] = "";
                continue;
            }

            try {
                prfModelFileNames[season] = writeSdfPrfModel(prfModel);
            } catch (IOException e) {
                throw new PipelineException(String.format(
                    "Failed to retrieve PRF model %02d/%d",
                    skyGroup.getCcdModule(), skyGroup.getCcdOutput()), e);
            }
        }

        return prfModelFileNames;
    }

    private String writeSdfPrfModel(PrfModel prfModel) throws IOException {

        String filename = String.format(PRF_MODEL_SDF_FILENAME,
            prfModel.getCcdModule(), prfModel.getCcdOutput());
        File file = new File(getMatlabWorkingDir(), filename);
        DataOutputStream dataOutputStream = null;
        try {
            dataOutputStream = new DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(file)));
            log.info(String.format("Writing PRF model into sdf file %s",
                filename));
            new SdfPersistableOutputStream(dataOutputStream).save(prfModel);
        } catch (Exception e) {
            throw new IOException(String.format(
                "Failed to write sdf file[%s], e = %s", file, e), e);
        } finally {
            FileUtil.close(dataOutputStream);
        }

        return filename;
    }

    private String retrieveTipFile() {

        ModelMetadata modelMetadata = getModelMetadataRetrieverPipelineInstance().retrieve(
            TipImporter.MODEL_TYPE);
        if (modelMetadata == null) {
            throw new IllegalStateException("TIP model metadata does not exist");
        }

        BlobData<String> tipBlobData = blobOperations.retrieveTipBlobFile(
            skyGroupId, modelMetadata.getImportTime()
                .getTime());

        return tipBlobData.getBlobFileName();
    }

    /**
     * Splits the inputs into copies that each contain no more than
     * {@code elementsPerSubTask} targets.
     * 
     * @param dvInputs the inputs
     * @param elementsPerSubTask the maximum number of targets per copy
     * @return a non-{@code null} list of split inputs
     */
    private List<Persistable> split(DvInputs dvInputs, int elementsPerSubTask) {

        List<Persistable> inputsList = new ArrayList<Persistable>();

        // Extract list of Kepler IDs from the list of targets.
        List<Integer> keplerIds = new ArrayList<Integer>();
        for (DvTarget target : dvInputs.getTargets()) {
            keplerIds.add(target.getKeplerId());
        }

        // Create right-sized chunks of that list.
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), elementsPerSubTask);

        // Use those chunks to create copies of the inputs that have a subset of
        // the targets.
        while (keplerIdIterator.hasNext()) {
            inputsList.add(DvInputs.copy(dvInputs, keplerIdIterator.next()));
        }

        return inputsList;
    }

    /**
     * Populates the given list of {@code DvTarget}s with their time series.
     * 
     * @param startMjd start time in MJD for the unit-of-work
     * @param endMjd end time in MJD for the unit-of-work
     * @param targets the {@code DvTarget}s to be populated
     * @throws IOException
     */
    private void populateTargets(double startMjd, double endMjd,
        List<DvTarget> targets) throws IOException {

        // The array of pulse durations will be passed down to DvTarget
        final PaModuleParameters paModuleParameters =
            pipelineTask.getParameters(PaModuleParameters.class);
        final int[] pulseDurations =
            paModuleParameters.getTestPulseDurations();
        
        for (DvTarget target : targets) {
            Map<Pair<Integer, Integer>, Set<FsId>> readFsIdSets = new HashMap<Pair<Integer, Integer>, Set<FsId>>();
            Map<Pair<Double, Double>, Set<FsId>> readMjdFsIdSets = new HashMap<Pair<Double, Double>, Set<FsId>>();

            DvUtils.addAllFsIds(target.getFsIdSets(startCadence, endCadence,
                pulseDurations),
                readFsIdSets);
            DvUtils.addAllMjdFsIds(target.getMjdFsIdSets(startMjd, endMjd),
                readMjdFsIdSets);

            Map<Pair<Integer, Integer>, Map<FsId, TimeSeries>> timeSeriesByCadenceRange = readTimeSeries(readFsIdSets);
            Map<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>> mjdTimeSeriesByTimeRange = readMjdTimeSeries(readMjdFsIdSets);

            target.setTimeSeries(getMjdToCadence(), startCadence, endCadence,
                startMjd, endMjd, timeSeriesByCadenceRange,
                mjdTimeSeriesByTimeRange, pulseDurations);

            for (DvTargetData targetData : target.getTargetData()) {

                readFsIdSets.clear();
                readMjdFsIdSets.clear();

                DvUtils.addAllFsIds(Arrays.asList(new FsIdSet(
                    targetData.getStartCadence(), targetData.getEndCadence(),
                    Pixel.getAllFsIds(targetData.getPixels()))), readFsIdSets);
                DvUtils.addAllMjdFsIds(Arrays.asList(new MjdFsIdSet(
                    targetData.getStartMjd(), targetData.getEndMjd(),
                    Pixel.getAllMjdFsIds(targetData.getPixels()))),
                    readMjdFsIdSets);

                timeSeriesByCadenceRange = readTimeSeries(readFsIdSets);
                mjdTimeSeriesByTimeRange = readMjdTimeSeries(readMjdFsIdSets);

                targetData.setPixelTimeSeries(timeSeriesByCadenceRange,
                    mjdTimeSeriesByTimeRange);

                targetData.export(inputsHandler.subTaskDirectory(),
                    target.getKeplerId());
            }

            target.setUkirtImageFileName(retrieveUkirtImage(
                inputsHandler.subTaskDirectory(), target.getKeplerId()));
        }
    }

    private void retrieveTransits(DvInputs inputs, List<DvTarget> inputTargets) {

        ModelOperations<TransitParameterModel> transitParameterModelOperations = getTransitParameterModelOperations();
        TransitParameterModel transitParameterModel = transitParameterModelOperations.retrieveModel();
        Map<Integer, Map<String, Map<String, String>>> transitParameters = TransitParameterModel.parseModel(transitParameterModel);

        if (transitParameters.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "The TransitParameterModel must exist and can't be empty.");
        }
        inputs.setTransitParameterModelDescription(extractFilename(transitParameterModelOperations.getModelDescription()));

        ModelOperations<TransitNameModel> transitNameModelOperations = getTransitNameModelOperations();
        TransitNameModel transitNameModel = transitNameModelOperations.retrieveModel();
        Map<Integer, Map<String, Map<String, String>>> transitNames = TransitNameModel.parseModel(transitNameModel);

        if (transitNames.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "The TransitNameModel must exist and can't be empty.");
        }
        inputs.setTransitNameModelDescription(extractFilename(transitNameModelOperations.getModelDescription()));

        for (DvTarget inputTarget : inputTargets) {
            inputTarget.setTransits(getTransits(
                transitParameters.get(inputTarget.getKeplerId()),
                transitNames.get(inputTarget.getKeplerId())));
        }
    }

    private String extractFilename(String modelDescription) {
        int index = modelDescription.indexOf(':');
        if (index != -1) {
            return modelDescription.substring(0, index);
        }

        return modelDescription;
    }

    private List<DvTransit> getTransits(
        Map<String, Map<String, String>> transitParametersByKoiId,
        Map<String, Map<String, String>> transitNamesByKoiId) {

        List<DvTransit> transits = new ArrayList<DvTransit>();

        if (transitParametersByKoiId != null
            && !transitParametersByKoiId.isEmpty()) {
            for (String koiId : transitParametersByKoiId.keySet()) {
                Map<String, String> parameters = transitParametersByKoiId.get(koiId);
                Map<String, String> names = null;
                if (transitNamesByKoiId != null) {
                    names = transitNamesByKoiId.get(koiId);
                }

                double epoch = Double.NaN;
                if (parameters.get(TransitParameterModel.EPOCH_NAME) != null
                    && !parameters.get(TransitParameterModel.EPOCH_NAME)
                        .equals(NULL)) {
                    epoch = Double.valueOf(parameters.get(TransitParameterModel.EPOCH_NAME));
                }

                float period = Float.NaN;
                if (parameters.get(TransitParameterModel.PERIOD_NAME) != null
                    && !parameters.get(TransitParameterModel.PERIOD_NAME)
                        .equals(NULL)) {
                    period = Float.valueOf(parameters.get(TransitParameterModel.PERIOD_NAME));
                }

                float duration = Float.NaN;
                if (parameters.get(TransitParameterModel.DURATION_NAME) != null
                    && !parameters.get(TransitParameterModel.DURATION_NAME)
                        .equals(NULL)) {
                    duration = Float.valueOf(parameters.get(TransitParameterModel.DURATION_NAME));
                }

                String keplerName = "";
                if (names != null
                    && names.get(TransitNameModel.KEPLER_NAME_COLUMN) != null) {
                    keplerName = names.get(TransitNameModel.KEPLER_NAME_COLUMN);
                }

                transits.add(new DvTransit(koiId, keplerName, epoch, period,
                    duration));
            }
        }

        return transits;
    }

    private Map<Pair<Integer, Integer>, Map<FsId, TimeSeries>> readTimeSeries(
        Map<Pair<Integer, Integer>, Set<FsId>> readFsIdSets) {

        log.info("Reading " + timeSeriesCount(readFsIdSets) + " time series");
        List<FsIdSet> fsIdSetList = new ArrayList<FsIdSet>();
        for (Map.Entry<Pair<Integer, Integer>, Set<FsId>> fsIdSetByCadenceRange : readFsIdSets.entrySet()) {
            fsIdSetList.add(new FsIdSet(fsIdSetByCadenceRange.getKey().left,
                fsIdSetByCadenceRange.getKey().right,
                fsIdSetByCadenceRange.getValue()));
        }

        List<TimeSeriesBatch> timeSeriesBatchList = FileStoreClientFactory.getInstance()
            .readTimeSeriesBatch(fsIdSetList, false);

        Map<Pair<Integer, Integer>, Map<FsId, TimeSeries>> timeSeriesByCadenceRange = new HashMap<Pair<Integer, Integer>, Map<FsId, TimeSeries>>();
        for (TimeSeriesBatch timeSeriesBatch : timeSeriesBatchList) {
            Pair<Integer, Integer> cadenceRange = Pair.of(
                timeSeriesBatch.startCadence(), timeSeriesBatch.endCadence());
            Map<FsId, TimeSeries> timeSeriesByFsId = timeSeriesByCadenceRange.get(cadenceRange);
            if (timeSeriesByFsId == null) {
                timeSeriesByFsId = new HashMap<FsId, TimeSeries>();
                timeSeriesByCadenceRange.put(cadenceRange, timeSeriesByFsId);
            }
            for (TimeSeries timeSeries : timeSeriesBatch.timeSeries()
                .values()) {
                if (timeSeries.exists()) {
                    timeSeriesByFsId.put(timeSeries.id(), timeSeries);
                    TimeSeriesOperations.addToDataAccountability(timeSeries,
                        producerTaskIds);
                }
            }
        }

        return timeSeriesByCadenceRange;
    }

    private Map<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>> readMjdTimeSeries(
        Map<Pair<Double, Double>, Set<FsId>> readMjdFsIdSets) {

        log.info("Reading " + mjdTimeSeriesCount(readMjdFsIdSets)
            + " mjd time series");
        List<MjdFsIdSet> mjdFsIdSetList = new ArrayList<MjdFsIdSet>();
        for (Map.Entry<Pair<Double, Double>, Set<FsId>> mjdFsIdSetByTimeRange : readMjdFsIdSets.entrySet()) {
            mjdFsIdSetList.add(new MjdFsIdSet(
                mjdFsIdSetByTimeRange.getKey().left,
                mjdFsIdSetByTimeRange.getKey().right,
                mjdFsIdSetByTimeRange.getValue()));
        }

        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList = FileStoreClientFactory.getInstance()
            .readMjdTimeSeriesBatch(mjdFsIdSetList);

        Map<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>> mjdTimeSeriesByTimeRange = new HashMap<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>>();
        for (MjdTimeSeriesBatch mjdTimeSeriesBatch : mjdTimeSeriesBatchList) {
            Pair<Double, Double> timeRange = Pair.of(
                mjdTimeSeriesBatch.startMjd(), mjdTimeSeriesBatch.endMjd());
            Map<FsId, FloatMjdTimeSeries> mjdTimeSeriesByFsId = mjdTimeSeriesByTimeRange.get(timeRange);
            if (mjdTimeSeriesByFsId == null) {
                mjdTimeSeriesByFsId = new HashMap<FsId, FloatMjdTimeSeries>();
                mjdTimeSeriesByTimeRange.put(timeRange, mjdTimeSeriesByFsId);
            }
            for (FloatMjdTimeSeries floatMjdTimeSeries : mjdTimeSeriesBatch.timeSeries()
                .values()) {
                if (floatMjdTimeSeries.exists()) {
                    mjdTimeSeriesByFsId.put(floatMjdTimeSeries.id(),
                        floatMjdTimeSeries);
                    TimeSeriesOperations.addToDataAccountability(
                        floatMjdTimeSeries, producerTaskIds);
                }
            }
        }

        return mjdTimeSeriesByTimeRange;
    }

    private int timeSeriesCount(
        Map<Pair<Integer, Integer>, Set<FsId>> readFsIdSets) {

        int fsIdCount = 0;
        for (Set<FsId> fsIds : readFsIdSets.values()) {
            fsIdCount += fsIds.size();
        }

        return fsIdCount;
    }

    private int mjdTimeSeriesCount(
        Map<Pair<Double, Double>, Set<FsId>> readFsIdSets) {

        int fsIdCount = 0;
        for (Set<FsId> fsIds : readFsIdSets.values()) {
            fsIdCount += fsIds.size();
        }

        return fsIdCount;
    }

    private String retrieveUkirtImage(File matlabWorkingDir, int keplerId)
        throws IOException {

        BlobData<String> ukirtImageBlob = blobOperations.retrieveUkirtImageBlobFile(keplerId);
        String ukirtImageFileName = "";
        if (ukirtImageBlob != null && ukirtImageBlob.getBlobFileName()
            .length() > 0) {
            File blobFile = new File(getMatlabWorkingDir(),
                ukirtImageBlob.getBlobFileName());
            String fileExtension = getFileExtension(blobFile);
            ukirtImageFileName = String.format(UKIRT_IMAGE_FILENAME, keplerId,
                fileExtension);
            File imageFile = new File(matlabWorkingDir, ukirtImageFileName);
            FileUtil.mkdirs(imageFile.getParentFile());
            if (!blobFile.renameTo(imageFile)) {
                throw new IOException(String.format(
                    "rename from %s to %s failed.", blobFile.getPath(),
                    imageFile.getPath()));
            }
        }

        return ukirtImageFileName;
    }

    private String getFileExtension(File file) {

        String extension = "";
        int lastIndex = file.getName()
            .lastIndexOf('.');
        if (lastIndex != -1) {
            extension = file.getName()
                .substring(lastIndex);
        }

        return extension;
    }

    protected File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    /**
     * Only used for testing.
     */
    protected void setMatlabWorkingDir(File workingDir) {
        matlabWorkingDir = workingDir;
    }

    /**
     * Only used for testing.
     */
    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    private DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(
                getModelMetadataRetrieverPipelineInstance());
        }

        return dataAnomalyOperations;
    }

    /**
     * Only used for testing.
     */
    void setDataAnomalyOperations(DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    private MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), CadenceType.LONG);
        }

        return mjdToCadence;
    }

    /**
     * Only used for testing.
     */
    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    /**
     * Only used for testing.
     */
    void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    /**
     * Only used for testing.
     */
    void setConfigMapOperations(ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    /**
     * Only used for testing.
     */
    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    /**
     * Only used for testing.
     */
    void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    /**
     * Only used for testing.
     */
    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                getModelMetadataRetrieverPipelineInstance(),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return celestialObjectOperations;
    }

    /**
     * Only used for testing.
     */
    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    /**
     * Only used for testing.
     */
    void setRollTimeOperations(RollTimeOperations rollTimeOperations) {
        this.rollTimeOperations = rollTimeOperations;
    }

    /**
     * Only used for testing.
     */
    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    /**
     * Only used for testing.
     */
    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    private TpsOperations getTpsOperations() {
        if (tpsOperations == null) {
            tpsOperations = new TpsOperations(getCelestialObjectOperations(),
                FileStoreClientFactory.getInstance());
        }

        return tpsOperations;
    }

    /**
     * Only used for testing.
     */
    void setTpsOperations(TpsOperations tpsOperations) {
        this.tpsOperations = tpsOperations;
    }

    /**
     * Only used for testing.
     */
    void setPrfOperations(PrfOperations prfOperations) {
        this.prfOperations = prfOperations;
    }

    private ModelOperations<ExternalTceModel> getExternalTceModelOperations() {
        if (externalTceModelOperations == null) {
            externalTceModelOperations = ModelOperationsFactory.getExternalTceInstance(new ModelMetadataRetrieverLatest());
        }

        return externalTceModelOperations;
    }

    /**
     * Only used for testing.
     */
    void setExternalTceModelOperations(
        ModelOperations<ExternalTceModel> externalTceModelOperations) {
        this.externalTceModelOperations = externalTceModelOperations;
    }

    /**
     * Only used for testing.
     */
    public void setModelMetadataRetrieverPipelineInstance(
        ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance) {
        this.modelMetadataRetrieverPipelineInstance = modelMetadataRetrieverPipelineInstance;
    }

    ModelMetadataRetrieverPipelineInstance getModelMetadataRetrieverPipelineInstance() {
        if (modelMetadataRetrieverPipelineInstance == null) {
            modelMetadataRetrieverPipelineInstance = new ModelMetadataRetrieverPipelineInstance(
                pipelineInstance);
        }
        return modelMetadataRetrieverPipelineInstance;
    }

    private ModelOperations<TransitNameModel> getTransitNameModelOperations() {
        if (transitNameModelOperations == null) {
            transitNameModelOperations = ModelOperationsFactory.getTransitNameInstance(new ModelMetadataRetrieverPipelineInstance(
                pipelineInstance));
        }

        return transitNameModelOperations;
    }

    /**
     * Only used for testing.
     */
    void setTransitNameModelOperations(
        ModelOperations<TransitNameModel> transitNameModelOperations) {
        this.transitNameModelOperations = transitNameModelOperations;
    }

    private ModelOperations<TransitParameterModel> getTransitParameterModelOperations() {
        if (transitParameterModelOperations == null) {
            transitParameterModelOperations = ModelOperationsFactory.getTransitParameterInstance(new ModelMetadataRetrieverPipelineInstance(
                pipelineInstance));
        }

        return transitParameterModelOperations;
    }

    /**
     * Only used for testing.
     */
    void setTransitParameterModelOperations(
        ModelOperations<TransitParameterModel> transitParameterModelOperations) {
        this.transitParameterModelOperations = transitParameterModelOperations;
    }

    private TpsCrud getTpsCrud() {
        if (tpsCrud == null) {
            tpsCrud = new TpsCrud();
        }
        return tpsCrud;
    }

    /**
     * Only used for testing.
     */
    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }
}
