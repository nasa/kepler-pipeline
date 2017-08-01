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

package gov.nasa.kepler.pa;

import static com.google.common.base.Preconditions.checkState;
import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newTreeSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.FsIdsStream;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MatlabCallStateStream;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.PseudoTargetListParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.TimestampSeriesStream;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperationsFactory;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.tad.CoaCommon;
import gov.nasa.kepler.mc.tad.CoaObservedTargetRejecter;
import gov.nasa.kepler.mc.tad.DistanceFromEdgeCalculator;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.tad.TargetTableModOut;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pa.PaPipelineModule.ProcessingState;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class PaIoProcessor {
    
    private static final ConcurrentMap<Integer, Map<Integer, KicEntryData>> channelToKeplerIdToKicEntryData = 
        new ConcurrentHashMap<Integer, Map<Integer,KicEntryData>>();
    public static Map<Integer, KicEntryData> getKeplerIdToKicEntryData(int channel, PaIoProcessor paIoProcessor) {
        if (channelToKeplerIdToKicEntryData.get(channel) == null) {
            synchronized (channelToKeplerIdToKicEntryData) {
                if (channelToKeplerIdToKicEntryData.get(channel) == null) {
                        List<KicEntryData> kicEntryDataList = paIoProcessor.retrieveKicEntryData();
                        log.info("kicEntryDataList.size(); " + kicEntryDataList.size());
                        
                        Map<Integer, KicEntryData> keplerIdToKicEntryData = new HashMap<Integer, KicEntryData>();
                        for (KicEntryData kicEntryData : kicEntryDataList) {
                            keplerIdToKicEntryData.put(kicEntryData.getKeplerId(), kicEntryData);
                        }

                        channelToKeplerIdToKicEntryData.put(channel, keplerIdToKicEntryData);
                }
            }
        }

        return channelToKeplerIdToKicEntryData.get(channel);
    }
    
    private static final ConcurrentMap<TargetTableModOut, List<ObservedTarget>> targetTableModOutToRetrievedObservedTargets = 
        new ConcurrentHashMap<TargetTableModOut, List<ObservedTarget>>();
    public static List<ObservedTarget> getRetrievedObservedTargets(TargetTable targetTable, int ccdModule, int ccdOutput, TargetCrud targetCrud) {
        TargetTableModOut targetTableModOut = new TargetTableModOut(targetTable.getId(), ccdModule, ccdOutput);
        if (targetTableModOutToRetrievedObservedTargets.get(targetTableModOut) == null) {
            synchronized (targetTableModOutToRetrievedObservedTargets) {
                if (targetTableModOutToRetrievedObservedTargets.get(targetTableModOut) == null) {
                    List<ObservedTarget> retrievedObservedTargets = targetCrud.retrieveObservedTargetsPlusRejected(
                        targetTable, ccdModule, ccdOutput,
                        INCLUDE_NULL_APERTURES);
                    log.info("retrievedObservedTargets.size(); " + retrievedObservedTargets.size());
                        
                    targetTableModOutToRetrievedObservedTargets.put(targetTableModOut, retrievedObservedTargets);
                }
            }
        }

        return targetTableModOutToRetrievedObservedTargets.get(targetTableModOut);
    }
    
    public static class PaLocalData {
        private Set<FsId> allBackgroundCosmicRayFsIds = newTreeSet();
        private Set<FsId> allTargetCosmicRayFsIds = newTreeSet();
        private FsIdsStream fsIdsStream;
        private TimestampSeriesStream timestampSeriesStream;
        private MatlabCallStateStream matlabCallStateStream;
        private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();

        public PaLocalData(Set<FsId> allBackgroundCosmicRayFsIds,
            Set<FsId> allTargetCosmicRayFsIds, FsIdsStream fsIdsStream,
            TimestampSeriesStream timestampSeriesStream,
            MatlabCallStateStream matlabCallStateStream,
            ProducerTaskIdsStream producerTaskIdsStream) {
            this.allBackgroundCosmicRayFsIds = allBackgroundCosmicRayFsIds;
            this.allTargetCosmicRayFsIds = allTargetCosmicRayFsIds;
            this.fsIdsStream = fsIdsStream;
            this.timestampSeriesStream = timestampSeriesStream;
            this.matlabCallStateStream = matlabCallStateStream;
            this.producerTaskIdsStream = producerTaskIdsStream;
        }

        public Set<FsId> getAllBackgroundCosmicRayFsIds() {
            return allBackgroundCosmicRayFsIds;
        }

        public void setAllBackgroundCosmicRayFsIds(
            Set<FsId> allBackgroundCosmicRayFsIds) {
            this.allBackgroundCosmicRayFsIds = allBackgroundCosmicRayFsIds;
        }

        public Set<FsId> getAllTargetCosmicRayFsIds() {
            return allTargetCosmicRayFsIds;
        }

        public void setAllTargetCosmicRayFsIds(Set<FsId> allTargetCosmicRayFsIds) {
            this.allTargetCosmicRayFsIds = allTargetCosmicRayFsIds;
        }

        public FsIdsStream getFsIdsStream() {
            return fsIdsStream;
        }

        public void setFsIdsStream(FsIdsStream fsIdsStream) {
            this.fsIdsStream = fsIdsStream;
        }

        public TimestampSeriesStream getTimestampSeriesStream() {
            return timestampSeriesStream;
        }

        public void setTimestampSeriesStream(
            TimestampSeriesStream timestampSeriesStream) {
            this.timestampSeriesStream = timestampSeriesStream;
        }

        public MatlabCallStateStream getMatlabCallStateStream() {
            return matlabCallStateStream;
        }

        public void setMatlabCallStateStream(
            MatlabCallStateStream matlabCallStateStream) {
            this.matlabCallStateStream = matlabCallStateStream;
        }

        public ProducerTaskIdsStream getProducerTaskIdsStream() {
            return producerTaskIdsStream;
        }

        public void setProducerTaskIdsStream(
            ProducerTaskIdsStream producerTaskIdsStream) {
            this.producerTaskIdsStream = producerTaskIdsStream;
        }
    }

    /**
     * Logger for this class
     */
    static final Log log = LogFactory.getLog(PaIoProcessor.class);

    public static final String MODULE_NAME = "pa";
    static final boolean INCLUDE_NULL_APERTURES = true;
    protected static final float DEFAULT_FLUX_FRACTION_IN_APERTURE = 1.0F;
    protected static final float DEFAULT_CROWDING_METRIC = 2.0F;
    protected static final float DEFAULT_SKY_CROWDING_METRIC = 3.0F;
    protected static final float DEFAULT_SIGNAL_TO_NOISE_RATIO = 4.0F;

    protected PipelineTask pipelineTask;
    protected PipelineInstance pipelineInstance;
    protected ModOutCadenceUowTask task;
    protected int ccdModule;
    protected int ccdOutput;
    protected ProcessingState state;

    protected TargetCrud targetCrud = new TargetCrud();
    protected TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

    protected CadenceType cadenceType;
    protected double durationDays;
    protected String startTime;
    protected TimestampSeries cadenceTimes;

    protected MjdToCadence mjdToLongCadence;

    protected PaModuleParameters paParameters;
    protected AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters;
    protected AncillaryPipelineParameters ancillaryPipelineParameters;
    protected ApertureModelParameters apertureModelParameters;
    protected ArgabrighteningModuleParameters argabrighteningParameters;
    protected BackgroundModuleParameters backgroundParameters;
    protected PaCoaModuleParameters paCoaModuleParameters;
    protected PaCosmicRayParameters paCosmicRayParameters;
    protected RollingBandArtifactParameters rollingBandArtifactParameters;
    protected EncircledEnergyModuleParameters encircledEnergyParameters;
    protected GapFillModuleParameters gapFillParameters;
    protected ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance;
    protected MotionModuleParameters motionModuleParameters;
    protected OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters;
    protected PaHarmonicsIdentificationParameters paHarmonicsIdentificationParameters;
    protected PouModuleParameters pouParameters;
    protected PseudoTargetListParameters pseudoTargetListParameters;
    protected ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters;
    protected SaturationSegmentModuleParameters saturationSegmentModuleParameters;
    protected TadParameters tadParameters;
    protected ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters;

    private final DistanceFromEdgeCalculator distanceFromEdgeCalculator;
    private final CoaObservedTargetRejecter coaObservedTargetRejecter;

    protected TargetTable targetTable;
    protected TargetTable backgroundTable;
    protected TargetListSet targetListSet;
    protected TargetListSet associatedLcTargetListSet;
    protected List<ObservedTarget> observedTargets;
    protected List<ObservedTarget> observedTargetsCustom;
    protected List<ObservedTarget> observedTargetsRejected;

    protected Map<Integer, KicEntryData> keplerIdToKicEntryData = newHashMap();

    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private BlobOperations blobOperations = new BlobOperations();
    private CharacteristicCrud characteristicCrud = new CharacteristicCrud();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private DataAnomalyOperations dataAnomalyOperations;
    private CelestialObjectOperations celestialObjectOperations;
    private CelestialObjectOperationsFactory celestialObjectOperationsFactory;
    private KicCrud kicCrud = new KicCrud();
    private LogCrud logCrud = new LogCrud();
    private PersistableFactory persistableFactory;
    private PrfOperations prfOperations = new PrfOperations();
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private ReadNoiseOperations readNoiseOperations = new ReadNoiseOperations();
    private GainOperations gainOperations = new GainOperations();
    private LinearityOperations linearityOperations = new LinearityOperations();
    private RollTimeOperations rollTimeOperations = new RollTimeOperations();
    private TpsCrud tpsCrud = new TpsCrud();
    
    private QuarterToParameterValueMap tadParameterValues;

    protected PaLocalData localData = new PaLocalData(new TreeSet<FsId>(),
        new TreeSet<FsId>(), new FsIdsStream(), new TimestampSeriesStream(),
        new MatlabCallStateStream(), new ProducerTaskIdsStream());

    private MjdToCadence mjdToCadence;

    private final Set<Long> producerTaskIds = newHashSet();

    private int quarter;
    private String targetListSetName;
    private String associatedLcTargetListSetName;
    private String supplementalForTlsName;

    public PaIoProcessor(PipelineTask pipelineTask, int ccdModule, int ccdOutput) {
        this(pipelineTask, ccdModule, ccdOutput,
            new DistanceFromEdgeCalculator(), new CoaObservedTargetRejecter(),
            new CelestialObjectOperationsFactory(), new PersistableFactory());
    }

    public PaIoProcessor(PipelineTask pipelineTask, int ccdModule,
        int ccdOutput, DistanceFromEdgeCalculator distanceFromEdgeCalculator,
        CoaObservedTargetRejecter coaObservedTargetRejecter,
        CelestialObjectOperationsFactory celestialObjectOperationsFactory,
        PersistableFactory persistableFactory) {
        this.pipelineTask = pipelineTask;
        pipelineInstance = pipelineTask.getPipelineInstance();
        task = pipelineTask.uowTaskInstance();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.distanceFromEdgeCalculator = distanceFromEdgeCalculator;
        this.coaObservedTargetRejecter = coaObservedTargetRejecter;
        this.celestialObjectOperationsFactory = celestialObjectOperationsFactory;
        this.persistableFactory = persistableFactory;
    }

    protected String getModuleName() {
        return MODULE_NAME;
    }

    protected void retrieveParameters() {
    
        log.info("[" + getModuleName() + "]retrieve module parameters.");
    
        ancillaryDesignMatrixParameters = pipelineTask.getParameters(AncillaryDesignMatrixParameters.class);
        ancillaryPipelineParameters = PaCommonInputsRetriever.retrieveAncillaryPipelineParameters(pipelineTask);
        apertureModelParameters = pipelineTask.getParameters(ApertureModelParameters.class);
        argabrighteningParameters = pipelineTask.getParameters(ArgabrighteningModuleParameters.class);
        backgroundParameters = pipelineTask.getParameters(BackgroundModuleParameters.class);
        paCoaModuleParameters = pipelineTask.getParameters(PaCoaModuleParameters.class);
        paCosmicRayParameters = pipelineTask.getParameters(PaCosmicRayParameters.class);
        rollingBandArtifactParameters = pipelineTask.getParameters(RollingBandArtifactParameters.class);
        encircledEnergyParameters = pipelineTask.getParameters(EncircledEnergyModuleParameters.class);
        gapFillParameters = pipelineTask.getParameters(GapFillModuleParameters.class);
        motionModuleParameters = pipelineTask.getParameters(MotionModuleParameters.class);
        oapAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveOapAncillaryEngineeringParameters(pipelineTask);
        paHarmonicsIdentificationParameters = pipelineTask.getParameters(PaHarmonicsIdentificationParameters.class);
        paParameters = pipelineTask.getParameters(PaModuleParameters.class);
        pouParameters = pipelineTask.getParameters(PouModuleParameters.class);
        pseudoTargetListParameters = retrievePseudoTargetListParameters();
        reactionWheelAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveReactionWheelAncillaryEngineeringParameters(pipelineTask);
        saturationSegmentModuleParameters = pipelineTask.getParameters(SaturationSegmentModuleParameters.class);
        tadParameters = pipelineTask.getParameters(TadParameters.class);
        thrusterDataAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveThrusterDataAncillaryEngineeringParameters(pipelineTask);
        
        // If fail we must, fail early
        validatePaModuleParameters();
        
        int startCadence = task.getStartCadence();
        int endCadence = task.getEndCadence();
        
        List<String> quartersList = Arrays.asList(tadParameters.getQuarters().split(","));
        List<String> targetListSetNames = Arrays.asList(tadParameters.getTargetListSetName().split(","));
        List<String> associatedLcTargetListSetNames = Arrays.asList(tadParameters.getAssociatedLcTargetListSetName().split(","));
        List<String> supplementalFors = Arrays.asList(tadParameters.getSupplementalFor().split(","));
        
        tadParameterValues = getTadParameterValues();
        quarter = tadParameterValues.getQuarter(quartersList, quartersList, cadenceType, startCadence, endCadence);
        targetListSetName = tadParameterValues.getValue(quartersList, targetListSetNames, cadenceType, startCadence, endCadence).trim();
        associatedLcTargetListSetName = tadParameterValues.getValue(quartersList, associatedLcTargetListSetNames, cadenceType, startCadence, endCadence).trim();
        supplementalForTlsName = tadParameterValues.getValue(quartersList, supplementalFors, cadenceType, startCadence, endCadence).trim();
    }
    
    /**
     * Fail early if PaModuleParameters contains values known now to be invalid.
     */
    private void validatePaModuleParameters() {
        final int[] paTestPulseDurations = paParameters.getTestPulseDurations();
        final int[] rbaTestPulseDurations =
            pipelineTask.getParameters(RollingBandArtifactParameters.class).getTestPulseDurations();
            
        // Forbid duplicates
        // There must be a more elegant way to build the Set<Integer>
        Set<Integer> paTestPulseDurationSet = new HashSet<Integer>();
        for (int i : paTestPulseDurations) {
            paTestPulseDurationSet.add(i);
        }
        checkState((paTestPulseDurations.length == paTestPulseDurationSet.size()),
            "testPulseDurations has duplicates");
        
        // The elements must all be members of the set of possible pulse durations
        Set<Integer> rbaTestPulseDurationSet = new HashSet<Integer>();
        for (int i : rbaTestPulseDurations) {
            rbaTestPulseDurationSet.add(i);
        }
        checkState(rbaTestPulseDurationSet.containsAll(paTestPulseDurationSet),
            "PA's testPulseDurations is not a subset of RBA's testPulseDurations");
    }

    protected void initializeTargetListSet() {
        logTadParameters(tadParameters);
        
        if (targetListSetName.trim().length() < 1) {
            throw new IllegalArgumentException(
                "The targetListSetName field of TadParameter must have "
                    + "a non-zero length value when the paCoaEnabled parameter "
                    + "of PaModuleParameters is true.");
        }

        targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
        if (associatedLcTargetListSetName != null) {
            associatedLcTargetListSet = targetSelectionCrud.retrieveTargetListSet(associatedLcTargetListSetName);
        }

        log.info(TargetListSetOperations.getTlsInfo(targetListSet,
            associatedLcTargetListSet));

        startTime = MatlabDateFormatter.dateFormatter()
            .format(targetListSet.getStart());
        log.info("startTime = " + startTime);

        long durationMilliseconds = targetListSet.getEnd()
            .getTime() - targetListSet.getStart()
            .getTime();
        durationDays = (double) durationMilliseconds
            / (double) (1000 * 60 * 60 * 24);
        log.info("duration = " + durationDays);
    }
    
    protected void initializeTargetTable() {
    
        if (cadenceType == CadenceType.LONG) {
            targetTable = PaCommonInputsRetriever.getLongCadenceTargetTable(
                getModuleName(), targetCrud, task.getStartCadence(),
                task.getEndCadence());
            backgroundTable = PaCommonInputsRetriever.getBackgroundTargetTable(
                targetCrud, task.getStartCadence(), task.getEndCadence());
        } else {
            targetTable = PaCommonInputsRetriever.getShortCadenceTargetTable(
                targetCrud, task.getStartCadence(), task.getEndCadence());
        }
    }

    protected void initializeTargetTableFromSet() {

        targetTable = targetListSet.getTargetTable();
        if (cadenceType == CadenceType.LONG) {
            backgroundTable = targetListSet.getBackgroundTable();
        }
    }

    protected void initializeObservedTargets() {

        log.info("Retrieving observed targets...");
        List<ObservedTarget> retrievedObservedTargets = getRetrievedObservedTargets(
            targetListSet.getTargetTable(), ccdModule, ccdOutput, targetCrud);

        log.info("From: ");
        log.info(TargetListSetOperations.getTlsInfo(targetListSet));
        log.info(String.format(
            "targetListSet.getTargetTable().getExternalId() = %d\n",
            targetListSet.getTargetTable()
                .getExternalId()));
        log.info(String.format("targetListSet.getTargetTable().getId() = %d\n",
            targetListSet.getTargetTable()
                .getId()));
        log.info(String.format("Retrieved %d ObservedTargets.",
            retrievedObservedTargets.size()));

        log.info("Setting distanceFromEdge for custom targets.");
        for (ObservedTarget observedTarget : retrievedObservedTargets) {
            if (TargetManagementConstants.isCustomTarget(observedTarget.getKeplerId())) {
                observedTarget.setDistanceFromEdge(distanceFromEdgeCalculator.getDistanceFromEdge(observedTarget.getAperture()));
            }
        }

        observedTargets = newArrayList();
        observedTargetsCustom = newArrayList();
        observedTargetsRejected = newArrayList();
        for (ObservedTarget observedTarget : retrievedObservedTargets) {
            if (!TargetManagementConstants.isCustomTarget(observedTarget.getKeplerId())) {
                if (!observedTarget.isRejected()) {
                    observedTargets.add(observedTarget);
                } else {
                    observedTargetsRejected.add(observedTarget);
                }
            } else {
                observedTargetsCustom.add(observedTarget);
            }
        }

        log.info(String.format("observedTargets: %d\n", observedTargets.size()));
        log.info(String.format("observedTargetsCustom: %d\n",
            observedTargetsCustom.size()));
        log.info(String.format("observedTargetsRejected: %d\n",
            observedTargetsRejected.size()));
    }

    protected void storeOptimalApertures(List<PaFluxTarget> fluxTargets) {
        if (cadenceType == CadenceType.LONG) {
            int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
            keplerIdToKicEntryData = getKeplerIdToKicEntryData(channel, this);

            log.info("Storing optimal apertures...");
            CoaCommon.storeOptimalApertures(pipelineTask,
                PaPipelineModule.class, targetCrud, targetSelectionCrud,
                ccdModule, ccdOutput, targetListSet, coaObservedTargetRejecter,
                observedTargets, observedTargetsCustom,
                extractOptimalApertures(fluxTargets), supplementalForTlsName, keplerIdToKicEntryData);
        } else {
            log.info("Running on short cadence, so copying the long cadence optimal apertures.");
            CoaCommon.copyLcApertures(targetCrud, targetListSet, associatedLcTargetListSet,
                ccdModule, ccdOutput, observedTargets, tadParameters.isLcTargetRequiredForScCopy());
        }
    }

    /**
     * Only used for testing.
     */
    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    protected void setPipelineInstance(final PipelineInstance pipelineInstance) {

        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    /**
     * Only used for testing.
     */
    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    /**
     * Sets this module's target CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param targetCrud the target CRUD.
     */
    protected void setTargetCrud(final TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    protected void validate() {
            CoaCommon.validate(targetSelectionCrud, supplementalForTlsName, targetListSet);
    }

    public Set<Long> getProducerTaskIds() {
        return producerTaskIds;
    }

    private static List<OptimalAperture> extractOptimalApertures(
        List<PaFluxTarget> fluxTargets) {
    
        List<OptimalAperture> optimalApertures = newArrayList();
        for (PaFluxTarget fluxTarget : fluxTargets) {
            // Assume nothing is rejected and reject after assigning Apertures.
            OptimalAperture optimalAperture = fluxTarget.getOptimalAperture();
            optimalApertures.add(optimalAperture);
        }
    
        return optimalApertures;
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

    private static final void logTadParameters(TadParameters tadParameters) {
        log.info(String.format("tadParameters.targetListSetName=%s",
            tadParameters.getTargetListSetName()));
        log.info(String.format(
            "tadParameters.associatedLcTargetListSetName=%s",
            tadParameters.getAssociatedLcTargetListSetName()));
        log.info(String.format("tadParameters.supplementalFor=%s",
            tadParameters.getSupplementalFor()));
    }

    /**
     * Sets this module's target selection CRUD. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param targetSelectionCrud the target selection CRUD.
     */
    protected void setTargetSelectionCrud(
        final TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    public AncillaryOperations getAncillaryOperations() {
        return ancillaryOperations;
    }

    /**
     * Sets this module's ancillary operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param ancillaryOperations the ancillary operations.
     */
    protected void setAncillaryOperations(
        final AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    public BlobOperations getBlobOperations() {
        return blobOperations;
    }

    /**
     * Sets this module's blob operations. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param blobOperations the blob operations.
     */
    protected void setBlobOperations(final BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    public ConfigMapOperations getConfigMapOperations() {
        return configMapOperations;
    }

    /**
     * Sets this module's config map operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param configMapOperations the config map operations.
     */
    protected void setConfigMapOperations(
        final ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    protected CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return celestialObjectOperations;
    }
    
    protected QuarterToParameterValueMap getTadParameterValues() {
        if (tadParameterValues == null) {
            ModelOperations<ObservingLogModel> modelOperations = ModelOperationsFactory.getObservingLogInstance(
                new ModelMetadataRetrieverPipelineInstance(pipelineTask.getPipelineInstance()));
            ObservingLogModel observingLogModel = modelOperations.retrieveModel();
            tadParameterValues = new QuarterToParameterValueMap(observingLogModel);
        }
        
        return tadParameterValues;
    }

    protected void setTadParameterValues(QuarterToParameterValueMap tadParameterValues) {
        this.tadParameterValues = tadParameterValues;
    }

    protected DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }

        return dataAnomalyOperations;
    }

    /**
     * Sets this module's target selection operations. This method isn't used by
     * the module interface, but by tests.
     * 
     * @param celestialObjectOperations the target selection operations.
     */
    protected void setCelestialObjectOperations(
        final CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    public KicCrud getKicCrud() {
        return kicCrud;
    }

    /**
     * Sets this module's KIC CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param kicCrud the KIC CRUD.
     */
    protected void setKicCrud(final KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

    public LogCrud getLogCrud() {
        return logCrud;
    }

    /**
     * Sets this module's log CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param logCrud the log CRUD.
     */
    protected void setLogCrud(final LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    public PrfOperations getPrfOperations() {
        return prfOperations;
    }

    /**
     * Sets this module's PRF operations. This method isn't used by the module
     * interface, only tests.
     * 
     * @param prfOperations
     */
    protected void setPrfOperations(final PrfOperations prfOperations) {
        this.prfOperations = prfOperations;
    }

    public RaDec2PixOperations getRaDec2PixOperations() {
        return raDec2PixOperations;
    }

    /**
     * Sets this module's RaDec2Pix operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param raDec2PixOperations
     */
    protected void setRaDec2PixOperations(
        final RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    public ReadNoiseOperations getReadNoiseOperations() {
        return readNoiseOperations;
    }

    /**
     * Sets this module's ReadNoise operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param readNoiseOperations
     */
    protected void setReadNoiseOperations(
        final ReadNoiseOperations readNoiseOperations) {
        this.readNoiseOperations = readNoiseOperations;
    }

    public GainOperations getGainOperations() {
        return gainOperations;
    }

    /**
     * Sets this module's Gain operations. This method isn't used by the module
     * interface, only tests.
     * 
     * @param gainOperations
     */
    protected void setGainOperations(final GainOperations gainOperations) {
        this.gainOperations = gainOperations;
    }

    public LinearityOperations getLinearityOperations() {
        return linearityOperations;
    }

    /**
     * Sets this module's Linearity operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param linearityOperations
     */
    protected void setLinearityOperations(
        final LinearityOperations linearityOperations) {
        this.linearityOperations = linearityOperations;
    }

    public RollTimeOperations getRollTimeOperations() {
        return rollTimeOperations;
    }

    /**
     * Sets this module's RollTime operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param rollTimeOperations
     */
    protected void setRollTimeOperations(
        final RollTimeOperations rollTimeOperations) {
        this.rollTimeOperations = rollTimeOperations;
    }

    protected void setDataAnomalyOperations(
        DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    protected ModelMetadataRetrieverPipelineInstance getModelMetadataRetrieverPipelineInstance() {
        if (modelMetadataRetrieverPipelineInstance == null) {
            modelMetadataRetrieverPipelineInstance = new ModelMetadataRetrieverPipelineInstance(
                pipelineInstance);
        }
        return modelMetadataRetrieverPipelineInstance;
    }

    protected void setModelMetadataRetrieverPipelineInstance(
        ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance) {
        this.modelMetadataRetrieverPipelineInstance = modelMetadataRetrieverPipelineInstance;
    }

    public TpsCrud getTpsCrud() {
        return tpsCrud;
    }

    protected void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }

    /**
     * Returns {@link KicEntryData}s for a {@link UOWTask} (ccdModule,
     * ccdOutput, season).
     */
    protected List<KicEntryData> retrieveKicEntryData() {

        return CoaCommon.retrieveKicEntryData(pipelineInstance, kicCrud,
            characteristicCrud, ccdModule, ccdOutput,
            celestialObjectOperationsFactory, persistableFactory,
            targetListSet, quarter);
    }

    protected MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), cadenceType);
        }

        return mjdToCadence;
    }

    protected void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    protected MjdToCadence getMjdToLongCadence() {
        if (mjdToLongCadence == null) {
            mjdToLongCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), CadenceType.LONG);
        }

        return mjdToLongCadence;
    }

    public void setMjdToLongCadence(MjdToCadence mjdToLongCadence) {
        this.mjdToLongCadence = mjdToLongCadence;
    }

    public void serializeProducerTaskIds(File workingDir) {
        Set<Long> existingProducerTaskIds = localData.getProducerTaskIdsStream()
            .read(workingDir);
        log.info("[" + getModuleName() + "]Count of existing producerTaskIds: "
            + existingProducerTaskIds.size());
        producerTaskIds.addAll(existingProducerTaskIds);
        log.info("[" + getModuleName() + "]Total count of producerTaskIds: "
            + producerTaskIds.size());
        log.info("[" + getModuleName() + "]Serializing producerTaskIds...");
        localData.getProducerTaskIdsStream()
            .write(workingDir, producerTaskIds);
    }

    protected Set<Integer> getAllDurations() {
        return PaIoProcessor.getAllDurations(rollingBandArtifactParameters.getTestPulseDurations());
    }

    public static Set<Integer> getAllDurations(int[] testPulseDurations) {
        Set<Integer> durations = newHashSet();

        if (testPulseDurations != null) {
            for (int duration : testPulseDurations) {
                durations.add(duration);
            }
        }

        return durations;
    }
}