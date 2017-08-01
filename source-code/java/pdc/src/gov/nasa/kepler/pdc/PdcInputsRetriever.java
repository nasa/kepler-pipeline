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

package gov.nasa.kepler.pdc;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithCapacity;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Maps.newHashMapWithExpectedSize;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DiscontinuityParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.PseudoTargetListParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.TransitOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.tad.Offset;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.primitives.Booleans;

/**
 * This is the Pre-Search Data Conditioning pipeline module. It uses relative
 * flux time series to create corrected flux time series.
 * 
 * SOC 1065.PDC.1: SOC processing shall be able to process input data sets
 * received out of time order. This requirement is satisfied by DR.
 * 
 * @author jgunter
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class PdcInputsRetriever {

    private static final float DEFAULT_FLUX_FRACTION_IN_APERTURE = 1.0F;

    private static final float DEFAULT_CROWDING_METRIC = 1.0F;

    private static final Log log = LogFactory.getLog(PdcInputsRetriever.class);

    static final int MJD_GAP_FILL_VALUE = 0;

    private FluxType fluxType;
    private CadenceType cadenceType;
    private int cadenceStart;
    private int cadenceEnd;
    private int ccdModule;
    private int ccdOutput;

    private TargetTable targetTable;
    List<PdcTarget> inputTargets;

    private Set<Long> producerTaskIds = newHashSet();

    private BlobOperations blobOperations = new BlobOperations();
    private TargetCrud targetCrud = new TargetCrud();
    private KicCrud kicCrud = new KicCrud();
    private LogCrud logCrud = new LogCrud();
    private DataAnomalyOperations dataAnomalyOperations;
    private QuarterToParameterValueMap parameterValues;
    private CelestialObjectOperations celestialObjectOperations;
    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private ObservingLogModel observingLogModel;
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private RollTimeOperations rollTimeOperations = new RollTimeOperations();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
    private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();
    private TransitOperations transitOperations;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    private ModOutCadenceUowTask task;

    private MjdToCadence mjdToCadence;
    private MjdToCadence mjdToLongCadence;

    private PseudoTargetListParameters pseudoTargetListParameters;

    private File matlabWorkingDir;

    public PdcInputsRetriever() {
    }

    private String getModuleName() {
        return PdcPipelineModule.MODULE_NAME;
    }

    public PdcInputs retrieveInputs(PipelineTask pipelineTask,
        File matlabWorkingDir, int[] channels) throws Exception {

        PdcInputs pdcInputs = new PdcInputs();
        for (int channel : channels) {
            retrieveInputs(pipelineTask, pdcInputs, matlabWorkingDir, channel);
        }

        return pdcInputs;
    }

    public PdcInputs retrieveInputs(PipelineTask pipelineTask,
        PdcInputs inputs, File matlabWorkingDir, int channel) throws Exception {

        setMatlabWorkingDir(matlabWorkingDir);
        setPipelineInstance(pipelineTask.getPipelineInstance());
        setPipelineTask(pipelineTask);

        task = pipelineTask.uowTaskInstance();

        cadenceStart = task.getStartCadence();
        cadenceEnd = task.getEndCadence();
        ccdModule = FcConstants.getModuleOutput(channel).left;
        ccdOutput = FcConstants.getModuleOutput(channel).right;

        log.info("cadenceStart: " + cadenceStart);
        log.info("cadenceEnd: " + cadenceEnd);
        log.info("ccdModule: " + ccdModule);
        log.info("ccdOutput: " + ccdOutput);
        log.info("pipelineTask.getId(): " + pipelineTask.getId());

        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);
        fluxType = FluxType.valueOf(fluxTypeParameters.getFluxType());
        log.info("fluxType: " + fluxType);

        CadenceTypePipelineParameters pipelineParams = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        log.info("pipelineParams: " + pipelineParams);
        cadenceType = CadenceType.valueOf(pipelineParams.getCadenceType());
        log.info("cadenceType: " + cadenceType);

        pseudoTargetListParameters = retrievePseudoTargetListParameters();

        // Determine targetTableType.
        TargetTable.TargetType targetTableType = TargetTable.TargetType.valueOf(cadenceType);

        // A single TargetTableLog should be available for the supplied
        // cadence
        // range.
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            targetTableType, cadenceStart, cadenceEnd);
        if (targetTableLogs.size() == 0) {
            throw new ModuleFatalProcessingException(
                String.format(
                    "%s cadence target table missing for cadence interval [%d, %d].",
                    targetTableType, cadenceStart, cadenceEnd));
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(String.format(
                "Found %d %s target tables for [%d, %d] cadence interval.",
                targetTableLogs.size(), targetTableType, cadenceStart,
                cadenceEnd));
        }

        TargetTableLog targetTableLog = targetTableLogs.get(0);
        log.debug("targetTableLog.getCadenceStart(): "
            + targetTableLog.getCadenceStart());
        log.debug("targetTableLog.getCadenceEnd(): "
            + targetTableLog.getCadenceEnd());

        targetTable = targetTableLog.getTargetTable();

        log.info("retrieving module parameters...");
        retrieveModuleParameters(pipelineTask, inputs);

        log.info("retrieving inputs...");
        retrieveInputsInternal(inputs);

        return inputs;
    }

    public void serializeProducerTaskIds(File taskWorkingDir) {
        log.info("Serializing producerTaskIds...");
        producerTaskIdsStream.write(taskWorkingDir, producerTaskIds);
    }

    void retrieveModuleParameters(PipelineTask task, PdcInputs pdcInputs) {
        PdcModuleParameters pdcParameters = task.getParameters(PdcModuleParameters.class);
        QuarterToParameterValueMap bandSplittingEnabledValues = getParameterValues();
        List<String> quartersList = Arrays.asList(pdcParameters.getBandSplittingEnabledQuarters()
            .split(","));
        List<Boolean> values = Booleans.asList(pdcParameters.getBandSplittingEnabled());
        Boolean bandSplittingEnabledValue = bandSplittingEnabledValues.getValue(
            quartersList, values, cadenceType, cadenceStart, cadenceEnd);
        pdcParameters.setBandSplittingEnabled(new boolean[] { bandSplittingEnabledValue });

        AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters = task.getParameters(AncillaryDesignMatrixParameters.class);
        AncillaryEngineeringParameters ancillaryEngineeringParameters = retrieveAncillaryEngineeringParameters();
        ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters = retrieveThrusterDataAncillaryEngineeringParameters();
        AncillaryPipelineParameters ancillaryPipelineParameters = retrieveAncillaryPipelineParameters();

        GapFillModuleParameters gapFillModuleParameters = task.getParameters(GapFillModuleParameters.class);
        SaturationSegmentModuleParameters saturationSegmentConfigurationStruct = task.getParameters(SaturationSegmentModuleParameters.class);
        PdcHarmonicsIdentificationParameters pdcHarmonicsIdentificationParameters = task.getParameters(PdcHarmonicsIdentificationParameters.class);
        DiscontinuityParameters discontinuityParameters = task.getParameters(DiscontinuityParameters.class);
        PdcMapParameters pdcMapParameters = task.getParameters(PdcMapParameters.class);
        SpsdDetectionParameters spsdDetectionParameters = task.getParameters(SpsdDetectionParameters.class);
        SpsdDetectorParameters spsdDetectorParameters = task.getParameters(SpsdDetectorParameters.class);
        SpsdRemovalParameters spsdRemovalParameters = task.getParameters(SpsdRemovalParameters.class);
        PdcGoodnessMetricParameters pdcGoodnessMetricParameters = task.getParameters(PdcGoodnessMetricParameters.class);
        BandSplittingParameters bandSplittingParameters = task.getParameters(BandSplittingParameters.class);

        pdcInputs.setCadenceType(cadenceType.toString());

        pdcInputs.setPdcModuleParameters(pdcParameters);
        pdcInputs.setAncillaryDesignMatrixParameters(ancillaryDesignMatrixParameters);
        pdcInputs.setAncillaryEngineeringParameters(ancillaryEngineeringParameters);
        pdcInputs.setThrusterDataAncillaryEngineeringParameters(thrusterDataAncillaryEngineeringParameters);
        pdcInputs.setAncillaryPipelineParameters(ancillaryPipelineParameters);
        pdcInputs.setGapFillModuleParameters(gapFillModuleParameters);
        pdcInputs.setSaturationSegmentParameters(saturationSegmentConfigurationStruct);
        pdcInputs.setHarmonicsIdentificationParameters(pdcHarmonicsIdentificationParameters);
        pdcInputs.setDiscontinuityParameters(discontinuityParameters);
        pdcInputs.setPdcMapParameters(pdcMapParameters);
        pdcInputs.setSpsdDetectionParameters(spsdDetectionParameters);
        pdcInputs.setSpsdDetectorParameters(spsdDetectorParameters);
        pdcInputs.setSpsdRemovalParameters(spsdRemovalParameters);
        pdcInputs.setPdcGoodnessMetricParameters(pdcGoodnessMetricParameters);
        pdcInputs.setBandSplittingParameters(bandSplittingParameters);
    }

    private AncillaryEngineeringParameters retrieveAncillaryEngineeringParameters() {
        AncillaryEngineeringParameters ancillaryEngineeringParameters = pipelineTask.getParameters(AncillaryEngineeringParameters.class);
        if (ancillaryEngineeringParameters.getMnemonics() != null
            && ancillaryEngineeringParameters.getMnemonics().length == 1
            && ancillaryEngineeringParameters.getMnemonics()[0] == null) {
            ancillaryEngineeringParameters = new AncillaryEngineeringParameters();
        }
        return ancillaryEngineeringParameters;
    }

    private ThrusterDataAncillaryEngineeringParameters retrieveThrusterDataAncillaryEngineeringParameters() {
        ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters = pipelineTask.getParameters(ThrusterDataAncillaryEngineeringParameters.class);
        if (thrusterDataAncillaryEngineeringParameters.getMnemonics() != null
            && thrusterDataAncillaryEngineeringParameters.getMnemonics().length == 1
            && thrusterDataAncillaryEngineeringParameters.getMnemonics()[0] == null) {
            thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters();
        }

        return thrusterDataAncillaryEngineeringParameters;
    }

    private AncillaryPipelineParameters retrieveAncillaryPipelineParameters() {
        AncillaryPipelineParameters ancillaryPipelineParameters = pipelineTask.getParameters(AncillaryPipelineParameters.class);
        if (ancillaryPipelineParameters.getMnemonics() != null
            && ancillaryPipelineParameters.getMnemonics().length == 1
            && ancillaryPipelineParameters.getMnemonics()[0] == null) {
            ancillaryPipelineParameters = new AncillaryPipelineParameters();
        }
        return ancillaryPipelineParameters;
    }

    private PseudoTargetListParameters retrievePseudoTargetListParameters() {
        PseudoTargetListParameters pseudoTargetListParameters = pipelineTask.getParameters(PseudoTargetListParameters.class);
        if (pseudoTargetListParameters.getTargetListNames() != null
            && pseudoTargetListParameters.getTargetListNames().length == 1
            && pseudoTargetListParameters.getTargetListNames()[0] == null) {
            pseudoTargetListParameters = new PseudoTargetListParameters();
        }

        return pseudoTargetListParameters;
    }

    protected RaDec2PixModel retrieveRaDec2PixModel(double startMjd,
        double endMjd) {

        return raDec2PixOperations.retrieveRaDec2PixModel(startMjd, endMjd);
    }

    protected void retrieveInputsInternal(PdcInputs pdcInputs)
        throws PipelineException {

        PdcInputChannelData pdcChannelData = new PdcInputChannelData();
        pdcInputs.getChannelData()
            .add(pdcChannelData);

        pdcChannelData.setCcdModule(ccdModule);
        pdcChannelData.setCcdOutput(ccdOutput);
        pdcInputs.setStartCadence(cadenceStart);
        pdcInputs.setEndCadence(cadenceEnd);

        PdcTimestampSeries cadenceTimes = retrieveCadenceTimes();
        pdcInputs.setCadenceTimes(cadenceTimes);

        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        pdcInputs.setRaDec2PixModel(retrieveRaDec2PixModel(startMjd, endMjd));

        log.info("[" + getModuleName() + "]set blob operations directory: "
            + getMatlabWorkingDir());
        blobOperations.setOutputDir(getMatlabWorkingDir());

        PdcTimestampSeries longCadenceTimes = null;
        if (cadenceType == CadenceType.LONG) {

            longCadenceTimes = cadenceTimes;
            pdcInputs.setLongCadenceTimes(longCadenceTimes);

            log.info("[" + getModuleName() + "]retrieve motion blobs.");
            BlobSeries<String> motionBlobs = retrieveMotionBlobFileSeries(
                cadenceStart, cadenceEnd);
            pdcChannelData.setMotionBlobs(new BlobFileSeries(motionBlobs));
            
            boolean retrieveCbvBlobs = false;
            
            for (boolean useCbvBlobs : pdcInputs.getPdcMapParameters()
                .getUseBasisVectorsAndPriorsFromBlob()) {
                if (useCbvBlobs) {
                    retrieveCbvBlobs = true;
                    break;
                }
            }

            for (boolean useBasisVectorsFromBlob : pdcInputs.getPdcMapParameters()
                .getUseBasisVectorsFromBlob()) {
                if (useBasisVectorsFromBlob) {
                    retrieveCbvBlobs = true;
                    break;
                }
            }
            
            if (retrieveCbvBlobs) {
                log.info("[" + getModuleName() + "]retrieve cbv blobs.");
                BlobSeries<String> cbvBlobs = retrieveCbvBlobFileSeries(
                    CadenceType.LONG, cadenceStart, cadenceEnd);
                pdcChannelData.setCbvBlobs(new BlobFileSeries(cbvBlobs));
            }
        } else {
            Pair<Integer, Integer> longCadenceInterval = shortCadenceToLongCadence(
                cadenceStart, cadenceEnd);
            log.info("[" + getModuleName() + "]longCadenceStart: "
                + longCadenceInterval.left);
            log.info("[" + getModuleName() + "]longCadenceEnd: "
                + longCadenceInterval.right);

            log.info("[" + getModuleName() + "]retrieve long cadence times.");
            longCadenceTimes = retrieveLongCadenceTimes(
                longCadenceInterval.left, longCadenceInterval.right);
            pdcInputs.setLongCadenceTimes(longCadenceTimes);

            log.info("[" + getModuleName() + "]retrieve motion blobs.");
            BlobSeries<String> motionBlobs = retrieveMotionBlobFileSeries(
                longCadenceInterval.left, longCadenceInterval.right);
            if (motionBlobs != null && motionBlobs.blobFilenames().length > 0) {
                pdcChannelData.setMotionBlobs(new BlobFileSeries(motionBlobs));
            }

            log.info("[" + getModuleName() + "]retrieve pdc blobs.");
            BlobSeries<String> pdcBlobs = retrievePdcBlobFileSeries(
                CadenceType.LONG, longCadenceInterval.left,
                longCadenceInterval.right);
            if (pdcBlobs != null && pdcBlobs.blobFilenames().length > 0) {
                pdcChannelData.setPdcBlobs(new BlobFileSeries(pdcBlobs));
            }
        }

        pdcInputs.setSpacecraftConfigMap(retrieveConfigMaps(cadenceTimes));

        // Retrieve ancillary engineering data.
        pdcInputs.setAncillaryEngineeringData(ancillaryOperations.retrieveAncillaryEngineeringData(
            pdcInputs.getAncillaryEngineeringParameters()
                .getMnemonics(), cadenceTimes.startMjd(), cadenceTimes.endMjd()));

        // Add thruster ancillary engineering data.
        pdcInputs.getAncillaryEngineeringData()
            .addAll(
                ancillaryOperations.retrieveAncillaryEngineeringData(
                    pdcInputs.getThrusterDataAncillaryEngineeringParameters()
                        .getMnemonics(), cadenceTimes.startMjd(),
                    cadenceTimes.endMjd()));

        // Retrieve ancillary pipeline data.
        pdcChannelData.setAncillaryPipelineData(ancillaryOperations.retrieveAncillaryPipelineData(
            pdcInputs.getAncillaryPipelineParameters()
                .getMnemonics(), targetTable, ccdModule, ccdOutput,
            cadenceTimes));
        producerTaskIds.addAll(ancillaryOperations.producerTaskIds());

        inputTargets = retrieveTargetInputDataList();

        if (cadenceType == CadenceType.LONG
            && pseudoTargetListParameters.getTargetListNames() != null
            && pseudoTargetListParameters.getTargetListNames().length > 0) {

            log.info("[" + getModuleName() + "]determine pseudo PDC targets");
            int observingSeason = rollTimeOperations.mjdToSeason(cadenceTimes.startMjd());
            int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
                observingSeason);
            inputTargets.addAll(createPseudoTargets(
                pseudoTargetListParameters.getTargetListNames(), skyGroupId));
        }

        log.info("[" + getModuleName() + "]get transit parameters");
        List<Integer> targetKeplerIds = Lists.newArrayListWithCapacity(inputTargets.size());
        for (PdcTarget pdcTarget : inputTargets) {
            targetKeplerIds.add(pdcTarget.getKeplerId());
        }
        Map<Integer, List<Transit>> keplerIdToTransit = getTransitOperations().getTransits(
            targetKeplerIds);
        for (PdcTarget pdcTarget : inputTargets) {
            pdcTarget.setTransits(keplerIdToTransit.get(pdcTarget.getKeplerId()));
        }
        pdcChannelData.setTargetData(inputTargets);
    }

    /**
     * Used only in the short cadence case to retrieve the long cadence mjds.
     */
    private PdcTimestampSeries retrieveLongCadenceTimes(int startCadence,
        int endCadence) {

        return new PdcTimestampSeries(rollTimeOperations,
            getMjdToLongCadence(), getObservingLogModel(), CadenceType.LONG,
            startCadence, endCadence);

    }

    private PdcTimestampSeries retrieveCadenceTimes() {
        return new PdcTimestampSeries(rollTimeOperations, getMjdToCadence(),
            getObservingLogModel(), cadenceType, cadenceStart, cadenceEnd);
    }

    private Pair<Integer, Integer> shortCadenceToLongCadence(
        int startShortCadence, int endShortCadence) {

        // convert short cadence interval to long cadence
        Pair<Integer, Integer> longCadenceInterval = logCrud.shortCadenceToLongCadence(
            startShortCadence, endShortCadence);
        if (longCadenceInterval == null) {
            throw new IllegalStateException(
                String.format(
                    "no long cadence data for given short cadence interval: [%d,%d]",
                    startShortCadence, endShortCadence));
        }
        return longCadenceInterval;
    }

    private BlobSeries<String> retrieveCbvBlobFileSeries(
        CadenceType cadenceType, final int startLongCadence,
        final int endLongCadence) {

        // retrieve the BlobFileSeries for long cadence
        BlobSeries<String> cbvBlobs = blobOperations.retrieveCbvBlobFileSeries(
            ccdModule, ccdOutput, cadenceType, startLongCadence, endLongCadence);
        producerTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(cbvBlobs.blobOriginators())));

        return cbvBlobs;
    }

    private BlobSeries<String> retrieveMotionBlobFileSeries(
        final int startLongCadence, final int endLongCadence) {

        // retrieve the BlobFileSeries for long cadence
        BlobSeries<String> motionBlobs = blobOperations.retrieveMotionBlobFileSeries(
            ccdModule, ccdOutput, startLongCadence, endLongCadence);
        producerTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(motionBlobs.blobOriginators())));

        return motionBlobs;
    }

    private BlobSeries<String> retrievePdcBlobFileSeries(
        CadenceType cadenceType, final int startLongCadence,
        final int endLongCadence) {

        // retrieve the BlobFileSeries for long cadence
        BlobSeries<String> pdcBlobs = blobOperations.retrievePdcBlobFileSeries(
            ccdModule, ccdOutput, cadenceType, startLongCadence, endLongCadence);
        producerTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(pdcBlobs.blobOriginators())));

        return pdcBlobs;
    }

    private List<PdcTarget> retrieveTargetInputDataList() {
        // At this point, targetTableLog has been set from the database.

        List<PdcTarget> inputTargets = new LinkedList<PdcTarget>();

        log.info("targetTable=" + targetTable.toString());

        List<ObservedTarget> targets = targetCrud.retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput);
        if (targets.isEmpty()) {
            log.info("There are no targets on module " + ccdModule
                + ", output " + ccdOutput);
            return inputTargets;
        }

        List<Integer> keplerIds = newArrayListWithCapacity(targets.size());
        for (ObservedTarget target : targets) {
            keplerIds.add(target.getKeplerId());
        }

        Map<Integer, CelestialObjectParameters> celestialObjectParametersByKeplerId = retrieveCelestialObjectParameters(keplerIds);

        targets = filterObservedTargets(targets,
            celestialObjectParametersByKeplerId);

        List<FsId> floatFsIds = newArrayList();
        List<FsId> doubleFsIds = newArrayList();

        // Prepare to retrieve PA-generated RAW_FLUX and RAW_UNCERTAINTIES time
        // series data:
        // batch FsIds to minimize filestore calls.
        for (int keplerId : keplerIds) {
            floatFsIds.addAll(PdcTarget.getFluxFloatTimeSeriesFsIds(fluxType,
                cadenceType, keplerId));
        }

        Map<FsId, TimeSeries> timeSeriesByFsId = readTimeSeries(floatFsIds,
            doubleFsIds);

        for (ObservedTarget target : targets) {
            CelestialObjectParameters celestialObjectParameters = celestialObjectParametersByKeplerId.get(target.getKeplerId());
            if (celestialObjectParameters != null) {
                PdcTarget inputTarget = new PdcTarget();
                inputTarget.setKeplerId(target.getKeplerId());

                float keplerMag = (float) celestialObjectParameters.getKeplerMag()
                    .getValue();

                inputTarget.setKeplerMag(keplerMag);
                inputTarget.setFluxFractionInAperture((float) target.getFluxFractionInAperture());
                inputTarget.setCrowdingMetric((float) target.getCrowdingMetric());
                if (target.getLabels() != null && target.getLabels()
                    .size() > 0) {
                    inputTarget.setLabels(target.getLabels()
                        .toArray(new String[0]));
                } else {
                    inputTarget.setLabels(ArrayUtils.EMPTY_STRING_ARRAY);
                }

                inputTarget.setTimeSeries(fluxType, cadenceType, cadenceEnd
                    - cadenceStart + 1, timeSeriesByFsId);

                inputTarget.setKic(celestialObjectParameters);

                inputTarget.setOptimalAperture(getOptimalAperture(target));

                inputTargets.add(inputTarget);
            }
        }

        return inputTargets;
    }

    private List<PdcTarget> createPseudoTargets(String[] targetListNames,
        int skyGroupId) {

        if (skyGroupId < 1 || skyGroupId > 84) {
            throw new IllegalArgumentException(skyGroupId
                + ": invalid skyGroupId");
        }

        List<PdcTarget> targets = newArrayListWithCapacity(1024);
        List<FsId> floatFsIds = newArrayList();
        List<FsId> doubleFsIds = newArrayList();
        Map<Integer, PlannedTarget> plannedTargetByKeplerId = newHashMap();
        Map<Integer, CelestialObjectParameters> celestialObjectParametersByKeplerId = newHashMap();

        for (String targetListName : targetListNames) {
            if (targetListName == null) {
                throw new NullPointerException("targetListName can't be null");
            }
            TargetList targetList = targetSelectionCrud.retrieveTargetList(targetListName);
            if (targetList == null) {
                throw new IllegalArgumentException(targetListName
                    + ": invalid targetListName");
            }

            log.info("[" + getModuleName() + "]retrieve pseudo targets from "
                + targetList.getName());
            List<PlannedTarget> plannedTargets = targetSelectionCrud.retrievePlannedTargets(
                targetList, skyGroupId);
            List<Integer> keplerIds = newArrayList();
            for (PlannedTarget plannedTarget : plannedTargets) {
                keplerIds.add(plannedTarget.getKeplerId());
                plannedTargetByKeplerId.put(plannedTarget.getKeplerId(),
                    plannedTarget);
            }
            celestialObjectParametersByKeplerId.putAll(retrieveCelestialObjectParameters(keplerIds));

            for (Integer keplerId : keplerIds) {
                if (celestialObjectParametersByKeplerId.get(keplerId) == null) {
                    plannedTargetByKeplerId.remove(keplerId);
                    continue;
                }
                floatFsIds.addAll(PdcTarget.getFluxFloatTimeSeriesFsIds(
                    fluxType, cadenceType, keplerId));
            }
        }

        Map<FsId, TimeSeries> timeSeriesByFsId = readTimeSeries(floatFsIds,
            doubleFsIds);

        for (Integer keplerId : plannedTargetByKeplerId.keySet()) {
            targets.add(createPdcTarget(plannedTargetByKeplerId.get(keplerId),
                celestialObjectParametersByKeplerId.get(keplerId),
                timeSeriesByFsId));
        }

        return targets;
    }

    private PdcTarget createPdcTarget(PlannedTarget plannedTarget,
        CelestialObjectParameters celestialObjectParameters,
        Map<FsId, TimeSeries> timeSeriesByFsId) {

        PdcTarget target = new PdcTarget();
        target.setKeplerId(plannedTarget.getKeplerId());

        target.setCrowdingMetric(DEFAULT_CROWDING_METRIC);
        target.setFluxFractionInAperture(DEFAULT_FLUX_FRACTION_IN_APERTURE);

        float keplerMag = (float) celestialObjectParameters.getKeplerMag()
            .getValue();
        target.setKeplerMag(keplerMag);

        if (plannedTarget.getLabels() != null && plannedTarget.getLabels()
            .size() > 0) {
            target.setLabels(plannedTarget.getLabels()
                .toArray(new String[0]));
        } else {
            target.setLabels(ArrayUtils.EMPTY_STRING_ARRAY);
        }
        target.setLabels(plannedTarget.getLabels()
            .toArray(new String[0]));

        target.setTimeSeries(fluxType, cadenceType,
            task.getEndCadence() - task.getStartCadence() + 1, timeSeriesByFsId);

        target.setKic(celestialObjectParameters);

        return target;
    }

    private Map<FsId, TimeSeries> readTimeSeries(List<FsId> floatFsIds,
        List<FsId> doubleFsIds) {

        // Retrieve PA float data.
        FloatTimeSeries[] floatTimeSeriesArrays = FileStoreClientFactory.getInstance(
            ConfigurationServiceFactory.getInstance())
            .readTimeSeriesAsFloat(
                floatFsIds.toArray(new FsId[floatFsIds.size()]), cadenceStart,
                cadenceEnd, false);

        // Retrieve PA double data.
        DoubleTimeSeries[] doubleTimeSeriesArrays = new DoubleTimeSeries[0];
        if (doubleFsIds.size() > 0) {
            doubleTimeSeriesArrays = FileStoreClientFactory.getInstance(
                ConfigurationServiceFactory.getInstance())
                .readTimeSeriesAsDouble(
                    doubleFsIds.toArray(new FsId[doubleFsIds.size()]),
                    cadenceStart, cadenceEnd, false);
        }

        TimeSeriesOperations.addToDataAccountability(floatTimeSeriesArrays,
            producerTaskIds);
        TimeSeriesOperations.addToDataAccountability(doubleTimeSeriesArrays,
            producerTaskIds);

        Map<FsId, TimeSeries> timeSeriesByFsId = newHashMap();
        timeSeriesByFsId.putAll(TimeSeriesOperations.getTimeSeriesByFsId(floatTimeSeriesArrays));
        timeSeriesByFsId.putAll(TimeSeriesOperations.getTimeSeriesByFsId(doubleTimeSeriesArrays));

        return timeSeriesByFsId;
    }

    private List<ObservedTarget> filterObservedTargets(
        List<ObservedTarget> targets,
        Map<Integer, CelestialObjectParameters> celestialObjectParametersByKeplerId) {
        List<ObservedTarget> filteredTargets = newArrayList();
        for (ObservedTarget observedTarget : targets) {
            if (celestialObjectParametersByKeplerId.get(observedTarget.getKeplerId()) != null) {
                filteredTargets.add(observedTarget);
            }
        }

        return filteredTargets;
    }

    private Map<Integer, CelestialObjectParameters> retrieveCelestialObjectParameters(
        List<Integer> keplerIds) {

        List<CelestialObjectParameters> celestialObjectParametersList = getCelestialObjectOperations().retrieveCelestialObjectParameters(
            keplerIds);
        Map<Integer, CelestialObjectParameters> celestialObjectParametersByKeplerId = newHashMapWithExpectedSize(celestialObjectParametersList.size());
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            if (celestialObjectParameters != null) {
                celestialObjectParametersByKeplerId.put(
                    celestialObjectParameters.getKeplerId(),
                    celestialObjectParameters);
            }
        }

        return celestialObjectParametersByKeplerId;
    }

    private ApertureMask getOptimalAperture(ObservedTarget target) {

        return new ApertureMask(target.getAperture()
            .getReferenceRow(), target.getAperture()
            .getReferenceColumn(), transformOffsets(target.getAperture()
            .getOffsets()));
    }

    private List<Offset> transformOffsets(
        List<gov.nasa.kepler.hibernate.tad.Offset> hibernateOffsets) {

        List<Offset> offsets = newArrayList();
        for (gov.nasa.kepler.hibernate.tad.Offset hibernateOffset : hibernateOffsets) {
            offsets.add(new Offset(hibernateOffset.getRow(),
                hibernateOffset.getColumn()));
        }
        return offsets;
    }

    private List<ConfigMap> retrieveConfigMaps(TimestampSeries cadenceTimes) {

        List<ConfigMap> configMaps = configMapOperations.retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        if (configMaps == null || configMaps.size() == 0) {
            throw new ModuleFatalProcessingException(
                "Need at least one spacecraft config map, but found none.");
        }

        return configMaps;
    }

    MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), cadenceType);
        }

        return mjdToCadence;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    MjdToCadence getMjdToLongCadence() {
        if (mjdToLongCadence == null) {
            mjdToLongCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), CadenceType.LONG);
        }

        return mjdToLongCadence;
    }

    void setMjdToLongCadence(MjdToCadence mjdToLongCadence) {
        this.mjdToLongCadence = mjdToLongCadence;
    }

    File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    void setMatlabWorkingDir(File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }

    void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    void setConfigMapOperations(ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return celestialObjectOperations;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    private DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }

        return dataAnomalyOperations;
    }

    void setDataAnomalyOperations(DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    private QuarterToParameterValueMap getParameterValues() {
        if (parameterValues == null) {
            parameterValues = new QuarterToParameterValueMap(
                getObservingLogModel());
        }

        return parameterValues;
    }

    void setParameterValues(QuarterToParameterValueMap parameterValues) {
        this.parameterValues = parameterValues;
    }

    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    private ObservingLogModel getObservingLogModel() {
        if (observingLogModel == null) {
            ModelOperations<ObservingLogModel> modelOperations = ModelOperationsFactory.getObservingLogInstance(new ModelMetadataRetrieverPipelineInstance(
                pipelineTask.getPipelineInstance()));
            observingLogModel = modelOperations.retrieveModel();
        }

        return observingLogModel;
    }

    void setObservingLogModel(ObservingLogModel observingLogModel) {
        this.observingLogModel = observingLogModel;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    void setPipelineInstance(final PipelineInstance pipelineInstance) {

        checkNotNull(pipelineInstance, "pipelineInstance can't be null");

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    private TransitOperations getTransitOperations() {
        if (transitOperations == null) {
            transitOperations = new TransitOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }
        return transitOperations;
    }

    void setTransitOperations(TransitOperations transitOperations) {
        this.transitOperations = transitOperations;
    }

    void setRollTimeOperations(RollTimeOperations rollTimeOperations) {
        this.rollTimeOperations = rollTimeOperations;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

}
