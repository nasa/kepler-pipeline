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

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithExpectedSize;
import static com.google.common.collect.Maps.newHashMapWithExpectedSize;
import static com.google.common.collect.Maps.newTreeMap;
import static com.google.common.collect.Sets.newHashSetWithExpectedSize;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.pa.BackgroundBlobMetadata;
import gov.nasa.kepler.hibernate.pa.CentroidPixel;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.pa.UncertaintyBlobMetadata;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.CosmicRayEraser;
import gov.nasa.kepler.mc.CosmicRaySeriesData;
import gov.nasa.kepler.mc.MatlabCallState;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType;
import gov.nasa.kepler.mc.pa.PaCosmicRayMetrics;
import gov.nasa.kepler.mc.tad.CoaCommon;
import gov.nasa.kepler.mc.tad.TargetTableModOut;
import gov.nasa.kepler.pa.PaPipelineModule.ProcessingState;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Stores {@link PaOutputs}
 * 
 * @author Forrest Girouard
 * @author Miles Cote
 * 
 */
public class PaOutputsStorer extends PaIoProcessor {

    private static final ConcurrentMap<TargetTableModOut, List<ObservedTarget>> targetTableModOutToRetrievedObservedTargets = 
        new ConcurrentHashMap<TargetTableModOut, List<ObservedTarget>>();
    public static List<ObservedTarget> getRetrievedObservedTargets(TargetTable targetTable, int ccdModule, int ccdOutput, TargetCrud targetCrud) {
        TargetTableModOut targetTableModOut = new TargetTableModOut(targetTable.getId(), ccdModule, ccdOutput);
        if (targetTableModOutToRetrievedObservedTargets.get(targetTableModOut) == null) {
            synchronized (targetTableModOutToRetrievedObservedTargets) {
                if (targetTableModOutToRetrievedObservedTargets.get(targetTableModOut) == null) {
                    log.info("Retrieving observed targets...");
                    List<ObservedTarget> retrievedObservedTargets = targetCrud.retrieveObservedTargetsPlusRejected(
                        targetTable, ccdModule, ccdOutput,
                        CoaCommon.INCLUDE_NULL_APERTURES);
                    log.info("retrievedObservedTargets.size(); " + retrievedObservedTargets.size());
                    
                    targetTableModOutToRetrievedObservedTargets.put(targetTableModOut, retrievedObservedTargets);
                }
            }
        }

        return targetTableModOutToRetrievedObservedTargets.get(targetTableModOut);
    }
    
    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(PaOutputsStorer.class);

    private PaCrud paCrud = new PaCrud();

    private MatlabCallState matlabCallState;

    private File matlabWorkingDir;

    /**
     * Creates a list of {@link FloatMjdTimeSeries} instances that collectively
     * represent all the given cosmic ray events.
     * 
     * @param ccdModule the module.
     * @param ccdOutput the output.
     * @param originator the pipeline task id of the caller.
     * @param crsFsIdsByCalCosmicRay map from a cosmic ray event to it's
     * corresponding {@code FsId}.
     * @param calCosmicRays list of cosmic ray events in background or target
     * data. This may not be in mjd order so this method will sort them into mjd
     * order.
     * @return a list of {@link FloatMjdTimeSeries}.
     */
    public static List<FloatMjdTimeSeries> createCosmicRaySeries(
        final int ccdModule, final int ccdOutput, final long originator,
        final TimestampSeries cadenceTimes,
        final Map<PaPixelCosmicRay, FsId> crsFsIdsByPaCosmicRay,
        final List<PaPixelCosmicRay> paCosmicRays) {

        List<FloatMjdTimeSeries> cosmicRaySeries = newArrayListWithExpectedSize(paCosmicRays.size());

        Map<FsId, CosmicRaySeriesData> cosmicRaySeriesDataByFsId = newHashMapWithExpectedSize(paCosmicRays.size());

        Collections.sort(paCosmicRays, new Comparator<PaPixelCosmicRay>() {

            @Override
            public int compare(final PaPixelCosmicRay o1,
                final PaPixelCosmicRay o2) {
                return Double.compare(o1.getMjd(), o2.getMjd());
            }

        });

        Set<PaPixelCosmicRay> processedCosmicRays = newHashSetWithExpectedSize(paCosmicRays.size());
        for (PaPixelCosmicRay paCosmicRay : paCosmicRays) {
            if (processedCosmicRays.contains(paCosmicRay)) {
                log.warn("ignoring duplicate cosmic ray event: " + paCosmicRay);
            } else {
                processedCosmicRays.add(paCosmicRay);

                FsId fsId = crsFsIdsByPaCosmicRay.get(paCosmicRay);
                CosmicRaySeriesData cosmicRaySeriesData = cosmicRaySeriesDataByFsId.get(fsId);
                if (cosmicRaySeriesData == null) {
                    cosmicRaySeriesData = new CosmicRaySeriesData(fsId);
                    cosmicRaySeriesDataByFsId.put(
                        cosmicRaySeriesData.getFsId(), cosmicRaySeriesData);
                }

                cosmicRaySeriesData.add(paCosmicRay.getMjd(),
                    paCosmicRay.getDelta());
            }
        }

        for (CosmicRaySeriesData data : cosmicRaySeriesDataByFsId.values()) {
            cosmicRaySeries.add(new FloatMjdTimeSeries(data.getFsId(),
                cadenceTimes.startMjd(), cadenceTimes.endMjd(),
                data.getTimes(), data.getValues(), originator));
        }
        return cosmicRaySeries;
    }

    public PaOutputsStorer(PipelineTask pipelineTask, int ccdModule,
        int ccdOutput) {
        super(pipelineTask, ccdModule, ccdOutput);
    }

    public void storeOutputs(File matlabWorkingDir, PaOutputs paOutputs) {
        this.matlabWorkingDir = matlabWorkingDir;

        state = ProcessingState.valueOf(paOutputs.getProcessingState());
        log.info("[" + getModuleName() + "]Processing state: " + state);

        if (cadenceType == null) {
            cadenceType = CadenceType.valueOf(pipelineTask.getParameters(
                CadenceTypePipelineParameters.class)
                .getCadenceType());
        }

        if (paParameters == null) {
            retrieveParameters();
        }

        if (paParameters.isPaCoaEnabled() && state == ProcessingState.TARGETS) {

            if (targetListSet == null) {
                initializeTargetListSet();
            }

            if (targetTable == null) {
                initializeTargetTableFromSet();
            }
        } else if (targetTable == null) {
            initializeTargetTable();
        }

        log.info("paParameters.isPaCoaEnabled(): "
            + paParameters.isPaCoaEnabled());

        if (paParameters.isPaCoaEnabled() && state == ProcessingState.TARGETS) {

            validate();

            if (observedTargets == null) {
                initializeObservedTargets();

                List<Integer> keplerIds = new ArrayList<Integer>();
                for (PaFluxTarget fluxTarget : paOutputs.getFluxTargets()) {
                    // For short cadence, we always want to process all of the
                    // fluxTargets output by matlab.
                    if (cadenceType == CadenceType.SHORT
                        || fluxTarget.getOptimalAperture() != null) {
                        keplerIds.add(fluxTarget.getOptimalAperture()
                            .getKeplerId());
                    }
                }

                List<ObservedTarget> retrievedObservedTargets = getRetrievedObservedTargets(
                    targetTable, ccdModule, ccdOutput, targetCrud);

                observedTargets = new ArrayList<ObservedTarget>();
                for (ObservedTarget observedTarget : retrievedObservedTargets) {
                    if (keplerIds.contains(observedTarget.getKeplerId())) {
                        observedTargets.add(observedTarget);
                    }
                }
            }
        }

        cadenceTimes = localData.getTimestampSeriesStream()
            .read(matlabWorkingDir);
        matlabCallState = localData.getMatlabCallStateStream()
            .read(matlabWorkingDir);

        if (state == PaPipelineModule.ProcessingState.BACKGROUND) {
            localData.setAllBackgroundCosmicRayFsIds(localData.getFsIdsStream()
                .read(DataSetType.Background, matlabWorkingDir));
        }
        if (matlabCallState.isLastCall()
            && !paParameters.isOnlyProcessPpaTargetsEnabled()) {
            localData.setAllTargetCosmicRayFsIds(localData.getFsIdsStream()
                .read(DataSetType.Target, matlabWorkingDir));
        }

        ModuleOutputListsParameters moduleOutputLists = pipelineTask.getParameters(ModuleOutputListsParameters.class);
        int channelForStoringNonChannelSpecificData = moduleOutputLists.getChannelForStoringNonChannelSpecificData();
        int channelNumber = FcConstants.getChannelNumber(ccdModule, ccdOutput);

        if (matlabCallState.isFirstCall()
            && !paParameters.isSimulatedTransitsEnabled()) {
            // if channelForStoringNonChannelSpecificData is invalid, then just store these for all mod/outs.
            if (isInvalidChannel(channelForStoringNonChannelSpecificData) || 
                channelNumber == channelForStoringNonChannelSpecificData) {
                log.info("[" + getModuleName()
                    + "]persisting reaction wheel zero-crossing events because the channel is " + channelForStoringNonChannelSpecificData);
                storeIndicesAsIntTimeseries(
                    PaFsIdFactory.getZeroCrossingFsId(cadenceType),
                    paOutputs.getReactionWheelZeroCrossingIndices());
            } else {
                log.info("[" + getModuleName()
                    + "]not persisting reaction wheel zero-crossing events because the channel is not " + channelForStoringNonChannelSpecificData + 
                    "\n  channel: " + channelForStoringNonChannelSpecificData);
            }
        }

        if (matlabCallState.isFirstCall() && cadenceType == CadenceType.LONG
            && !paParameters.isSimulatedTransitsEnabled()) {

            log.info("[" + getModuleName() + "]persist background blob.");
            log.debug("[" + getModuleName() + "]background blob filename: "
                + paOutputs.getBackgroundBlobFileName());
            if (paOutputs.getBackgroundBlobFileName() == null
                || paOutputs.getBackgroundBlobFileName()
                    .length() == 0) {
                throw new IllegalStateException(
                    "Expected background blob file name but none given.");
            }
            storeBackgroundBlob(paOutputs.getBackgroundBlobFileName());

            log.info("[" + getModuleName()
                + "]persist background cosmic ray series.");
            storeCosmicRays(TargetType.BACKGROUND,
                paOutputs.getBackgroundCosmicRayEvents(),
                localData.getAllBackgroundCosmicRayFsIds());

            if (paOutputs.getBackgroundCosmicRayMetrics()
                .isEmpty()) {
                log.error("[" + getModuleName()
                    + "]background cosmic ray metrics is empty.");
            } else {
                log.info("[" + getModuleName()
                    + "]persist background cosmic ray metrics.");
                storeCosmicRayMetrics(TargetType.BACKGROUND,
                    paOutputs.getBackgroundCosmicRayMetrics());
            }
        } else if (!matlabCallState.isFirstCall()) {
            if (!paOutputs.getFluxTargets()
                .isEmpty()) {
                List<PaFluxTarget> fluxTargets = paOutputs.getFluxTargets();
                log.info("[" + getModuleName()
                    + "]persist products for targets.");
                storeTargetTimeSeries(paParameters.isOapEnabled(),
                    paParameters.isPaCoaEnabled()
                        && state == ProcessingState.TARGETS
                        && cadenceType == CadenceType.LONG, fluxTargets);
                storeAperturePixels(fluxTargets);
                if (paParameters.isPaCoaEnabled()
                    && state == ProcessingState.TARGETS) {
                    storeOptimalApertures(fluxTargets);
                }
            }
        }

        if (matlabCallState.isLastCall()
            && !paParameters.isSimulatedTransitsEnabled()) {

            if (pouParameters.isPouEnabled()
                && paOutputs.getUncertaintyBlobFileName()
                    .length() > 0) {
                log.info("[" + getModuleName() + "]persist PA uncertainties.");
                storeUncertaintyBlob(paOutputs.getUncertaintyBlobFileName());
            }

            if (!paParameters.isOnlyProcessPpaTargetsEnabled()) {
                log.info("[" + getModuleName()
                    + "]persist target cosmic ray series.");
                storeCosmicRays(TargetType.valueOf(cadenceType),
                    paOutputs.getTargetStarCosmicRayEvents(),
                    localData.getAllTargetCosmicRayFsIds());

                if (paOutputs.getTargetCosmicRayMetrics()
                    .isEmpty()) {
                    log.error("[" + getModuleName()
                        + "]target cosmic ray metrics is empty.");
                } else {
                    log.info("[" + getModuleName()
                        + "]persist target cosmic ray metrics.");
                    storeCosmicRayMetrics(TargetType.valueOf(cadenceType),
                        paOutputs.getTargetCosmicRayMetrics());
                }
            }

            if (cadenceType == CadenceType.LONG) {
                if (!paParameters.isOnlyProcessPpaTargetsEnabled()) {
                    log.info("[" + getModuleName()
                        + "]persist metric timeseries.");
                    storeMetricTimeSeries(paOutputs.getBrightnessMetrics(),
                        paOutputs.getEncircledEnergyMetrics());
                }

                if (!paParameters.isSimulatedTransitsEnabled()
                    && !paParameters.isMotionBlobsInputEnabled()) {
                    log.info("[" + getModuleName() + "]persist motion blob.");
                    log.debug("[" + getModuleName() + "]motion blob filename: "
                        + paOutputs.getMotionBlobFileName());
                    if (paOutputs.getMotionBlobFileName() == null
                        || paOutputs.getMotionBlobFileName()
                            .length() == 0) {
                        throw new IllegalStateException(
                            "Expected motion blob file name but none given.");
                    }
                    storeMotionBlob(paOutputs.getMotionBlobFileName());
                }
            }

            if (!paParameters.isOnlyProcessPpaTargetsEnabled()) {
                log.info("[" + getModuleName()
                    + "]persist argabrightening events.");
                storeIndicesAsIntTimeseries(
                    PaFsIdFactory.getArgabrighteningFsId(cadenceType,
                        targetTable.getExternalId(), ccdModule, ccdOutput),
                    paOutputs.getArgabrighteningIndices());
            }
        }

        if (matlabCallState.isFirstCall()) {
            if (ArrayUtils.isEmpty(paOutputs.getDefiniteThrusterActivityIndicators())) {
                log.info("[" + getModuleName()
                    + "]definite thruster activity indicators array is empty.");
            } else {
                // if channelForStoringNonChannelSpecificData is invalid, then just store these for all mod/outs.
                if (isInvalidChannel(channelForStoringNonChannelSpecificData) || 
                    channelNumber == channelForStoringNonChannelSpecificData) {
                    log.info("[" + getModuleName()
                      + "]persisting definite thruster firing indicators because the channel is " + channelForStoringNonChannelSpecificData);
                    storeBooleanArrayAsIntTimeSeries(
                        PaFsIdFactory.getThrusterActivityFsId(cadenceType,
                        ThrusterActivityType.DEFINITE_THRUSTER_ACTIVITY),
                        paOutputs.getDefiniteThrusterActivityIndicators());
              } else {
                  log.info("[" + getModuleName()
                      + "]not persisting definite thruster firing indicators because the channel is not " + channelForStoringNonChannelSpecificData + 
                      "\n  channel: " + channelForStoringNonChannelSpecificData);
              }
            }
            if (ArrayUtils.isEmpty(paOutputs.getPossibleThrusterActivityIndicators())) {
                log.info("[" + getModuleName()
                    + "]possible thruster activity indicators array is empty.");
            } else {
                // if channelForStoringNonChannelSpecificData is invalid, then just store these for all mod/outs.
                if (isInvalidChannel(channelForStoringNonChannelSpecificData) || 
                    channelNumber == channelForStoringNonChannelSpecificData) {
                    log.info("[" + getModuleName()
                      + "]persisting possible thruster firing indicators because the channel is " + channelForStoringNonChannelSpecificData);
                    storeBooleanArrayAsIntTimeSeries(
                        PaFsIdFactory.getThrusterActivityFsId(cadenceType,
                        ThrusterActivityType.POSSIBLE_THRUSTER_ACTIVITY),
                        paOutputs.getPossibleThrusterActivityIndicators());
              } else {
                  log.info("[" + getModuleName()
                      + "]not persisting possible thruster firing indicators because the channel is not " + channelForStoringNonChannelSpecificData + 
                      "\n  channel: " + channelForStoringNonChannelSpecificData);
              }
            }
        }
        
        if (paOutputs.getAlerts()
            .size() > 0) {
            for (ModuleAlert alert : paOutputs.getAlerts()) {
                AlertServiceFactory.getInstance()
                    .generateAlert(MODULE_NAME, pipelineTask.getId(),
                        Severity.valueOf(alert.getSeverity()),
                        alert.getMessage() + ": time=" + alert.getTime());
            }
        }
    }
    
    private boolean isInvalidChannel(int channel) {
        return channel < 1 || channel > 84;
    }

    private void storeIndicesAsIntTimeseries(FsId fsId, int[] indices) {

        int length = task.getEndCadence() - task.getStartCadence() + 1;
        boolean[] gapIndicators = new boolean[length];
        int[] iseries = new int[length];
        Arrays.fill(gapIndicators, true);

        for (int index : indices) {
            gapIndicators[index] = false;
            iseries[index] = 1;
        }

        IntTimeSeries timeSeries = new IntTimeSeries(fsId, iseries,
            task.getStartCadence(), task.getEndCadence(), gapIndicators,
            pipelineTask.getId());
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(new TimeSeries[] { timeSeries });
    }

    private void storeBackgroundBlob(final String blobFileName) {

        BackgroundBlobMetadata backgroundBlobMetadata = new BackgroundBlobMetadata(
            pipelineTask.getId(), ccdModule, ccdOutput, task.getStartCadence(),
            task.getEndCadence(), FilenameUtils.getExtension(blobFileName));
        paCrud.createBackgroundBlobMetadata(backgroundBlobMetadata);

        FileStoreClientFactory.getInstance()
            .writeBlob(BlobOperations.getFsId(backgroundBlobMetadata),
                pipelineTask.getId(), new File(matlabWorkingDir, blobFileName));
    }

    private void storeMotionBlob(final String blobFileName) {

        MotionBlobMetadata motionBlobMetadata = new MotionBlobMetadata(
            pipelineTask.getId(), ccdModule, ccdOutput, task.getStartCadence(),
            task.getEndCadence(), FilenameUtils.getExtension(blobFileName));
        paCrud.createMotionBlobMetadata(motionBlobMetadata);

        FileStoreClientFactory.getInstance()
            .writeBlob(BlobOperations.getFsId(motionBlobMetadata),
                pipelineTask.getId(), new File(matlabWorkingDir, blobFileName));
    }

    private void storeUncertaintyBlob(final String blobFileName) {

        UncertaintyBlobMetadata uncertaintyBlobMetadata = null;
        String fileExtension = null;
        int index = blobFileName.lastIndexOf('.');
        if (index == -1) {
            uncertaintyBlobMetadata = new UncertaintyBlobMetadata(
                pipelineTask.getId(), ccdModule, ccdOutput, cadenceType,
                task.getStartCadence(), task.getEndCadence());
        } else {
            fileExtension = blobFileName.substring(index);
            uncertaintyBlobMetadata = new UncertaintyBlobMetadata(
                pipelineTask.getId(), ccdModule, ccdOutput, cadenceType,
                task.getStartCadence(), task.getEndCadence(), fileExtension);
        }
        paCrud.createUncertaintyBlobMetadata(uncertaintyBlobMetadata);

        FileStoreClientFactory.getInstance()
            .writeBlob(BlobOperations.getFsId(uncertaintyBlobMetadata),
                pipelineTask.getId(), new File(matlabWorkingDir, blobFileName));
    }

    private void storeCosmicRays(final TargetType targetType,
        final List<PaPixelCosmicRay> paCosmicRays, final Set<FsId> allFsIds) {

        Map<PaPixelCosmicRay, FsId> crsFsIdsByPaCosmicRay = newHashMapWithExpectedSize(paCosmicRays.size());
        for (PaPixelCosmicRay cosmicRay : paCosmicRays) {
            FsId fsId = PaFsIdFactory.getCosmicRaySeriesFsId(targetType,
                ccdModule, ccdOutput, cosmicRay.getCcdRow(),
                cosmicRay.getCcdColumn());
            crsFsIdsByPaCosmicRay.put(cosmicRay, fsId);
        }
        List<FloatMjdTimeSeries> cosmicRaySeries = createCosmicRaySeries(
            ccdModule, ccdOutput, pipelineTask.getId(), cadenceTimes,
            crsFsIdsByPaCosmicRay, paCosmicRays);
        CosmicRayEraser cosmicRayEraser = new CosmicRayEraser(cosmicRaySeries,
            allFsIds);
        cosmicRayEraser.storeAndErase(cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), pipelineTask.getId());
    }

    private void storeCosmicRayMetrics(final TargetType targetType,
        final PaCosmicRayMetrics cosmicRayMetrics) {

        List<FloatTimeSeries> floatTimeSeries = cosmicRayMetrics.toTimeSeries(
            targetType, ccdModule, ccdOutput, task.getStartCadence(),
            task.getEndCadence(), pipelineTask.getId());
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(
                floatTimeSeries.toArray(new FloatTimeSeries[floatTimeSeries.size()]));
    }

    private void storeTargetTimeSeries(final boolean oapEnabled,
        final boolean coaEnabled, final List<PaFluxTarget> paFluxTargets) {

        FluxType fluxType = oapEnabled ? FluxType.OAP : FluxType.SAP;

        List<TimeSeries> timeSeriesList = newArrayList();
        for (PaFluxTarget target : paFluxTargets) {
            timeSeriesList.addAll(target.toTimeSeries(coaEnabled && 
                target.getOptimalAperture().isApertureUpdatedWithPaCoa(), 
                fluxType,
                cadenceType, task.getStartCadence(), task.getEndCadence(),
                pipelineTask.getId()));
        }
        Map<FsId, TimeSeries> timeSeriesByFsId = newTreeMap();
        for (TimeSeries ts : timeSeriesList) {
            timeSeriesByFsId.put(ts.id(), ts);
        }
        timeSeriesList.clear();
        for (TimeSeries ts : timeSeriesByFsId.values()) {
            timeSeriesList.add(ts);
        }
        log.debug(String.format("timeSeries.size()=%d", timeSeriesList.size()));
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(
                timeSeriesList.toArray(new TimeSeries[timeSeriesList.size()]));
    }

    private void storeAperturePixels(List<PaFluxTarget> fluxTargets) {

        List<TargetAperture> newApertures = newArrayList();
        List<Integer> keplerIds = newArrayList();
        for (PaFluxTarget fluxTarget : fluxTargets) {
            keplerIds.add(fluxTarget.getKeplerId());
            TargetAperture targetAperture = new TargetAperture.Builder(
                pipelineTask, targetTable, fluxTarget.getKeplerId()).ccdModule(
                ccdModule)
                .ccdOutput(ccdOutput)
                .build();
            List<CentroidPixel> centroidPixels = newArrayListWithExpectedSize(fluxTarget.getPixelAperture()
                .size());
            for (PaCentroidPixel pixelFlags : fluxTarget.getPixelAperture()) {
                CentroidPixel centroidPixel = new CentroidPixel(
                    pixelFlags.getCcdRow(), pixelFlags.getCcdColumn(),
                    pixelFlags.isInFluxWeightedCentroidAperture(),
                    pixelFlags.isInPrfCentroidAperture());
                centroidPixels.add(centroidPixel);
            }
            targetAperture.setCentroidPixels(centroidPixels);
            newApertures.add(targetAperture);
        }

        List<TargetAperture> existingApertures = paCrud.retrieveTargetApertures(
            targetTable, ccdModule, ccdOutput, keplerIds);
        if (!existingApertures.isEmpty()) {
            paCrud.deleteTargetApertures(existingApertures);
        }

        if (!newApertures.isEmpty()) {
            paCrud.createTargetApertures(newApertures);
        }
        DatabaseServiceFactory.getInstance()
            .flush();
        DatabaseServiceFactory.getInstance()
            .evictAll(newApertures);
    }

    private void storeMetricTimeSeries(
        final CompoundFloatTimeSeries brightnessMetrics,
        final CompoundFloatTimeSeries encircledEnergyMetrics) {

        List<FloatTimeSeries> timeSeries = newArrayList();
        if (!brightnessMetrics.isEmpty()) {
            FsId valuesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                MetricTimeSeriesType.BRIGHTNESS, ccdModule, ccdOutput);
            FsId uncertaintiesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                MetricTimeSeriesType.BRIGHTNESS_UNCERTAINTIES, ccdModule,
                ccdOutput);
            timeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
                brightnessMetrics, valuesFsId, uncertaintiesFsId,
                task.getStartCadence(), task.getEndCadence(),
                pipelineTask.getId()));
        }
        if (!encircledEnergyMetrics.isEmpty()) {
            FsId valuesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                MetricTimeSeriesType.ENCIRCLED_ENERGY, ccdModule, ccdOutput);
            FsId uncertaintiesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                MetricTimeSeriesType.ENCIRCLED_ENERGY_UNCERTAINTIES, ccdModule,
                ccdOutput);
            timeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
                encircledEnergyMetrics, valuesFsId, uncertaintiesFsId,
                task.getStartCadence(), task.getEndCadence(),
                pipelineTask.getId()));
        }
        if (!timeSeries.isEmpty()) {
            FileStoreClientFactory.getInstance()
                .writeTimeSeries(
                    timeSeries.toArray(new FloatTimeSeries[timeSeries.size()]));
        }
    }

    private void storeBooleanArrayAsIntTimeSeries(FsId fsId,
        boolean[] booleanArray) {

        if (ArrayUtils.isEmpty(booleanArray)) {
            return;
        }

        PaSimpleBooleanTimeSeries paSimpleBooleanTimeSeries = new PaSimpleBooleanTimeSeries(
            booleanArray, new boolean[booleanArray.length]);
        IntTimeSeries timeSeries = paSimpleBooleanTimeSeries.toIntTimeSeries(
            fsId, task.getStartCadence(), task.getEndCadence(),
            pipelineTask.getId());
        if (!timeSeries.isEmpty()) {
            FileStoreClientFactory.getInstance()
                .writeTimeSeries(new IntTimeSeries[] { timeSeries });
        }
    }

    /**
     * Only used for testing.
     */
    protected void setMatlabWorkingDir(final File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }

    /**
     * Sets this module's PA CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param paCrud the PA CRUD.
     */
    protected void setPaCrud(final PaCrud paCrud) {
        this.paCrud = paCrud;
    }
}
