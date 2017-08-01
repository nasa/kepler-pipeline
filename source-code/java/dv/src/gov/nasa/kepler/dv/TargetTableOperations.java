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
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvTargetTableData;
import gov.nasa.kepler.dv.io.DvThresholdCrossingEvent;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterImpl;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides targets with calibrated pixel time series and their
 * associated uncertainties across target tables as well as data per target
 * table.
 * 
 * @author Forrest Girouard
 */
public class TargetTableOperations {

    private static final Log log = LogFactory.getLog(TargetTableOperations.class);

    private static final int TARGETS_PER_CCD_MODULE_OUTPUT = 512;

    // CRUD
    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private BlobOperations blobOperations = new BlobOperations();
    private KicCrud kicCrud = new KicCrud();
    private CelestialObjectOperations celestialObjectOperations;
    private RollTimeOperations rollTimeOperations = new RollTimeOperations();
    private TargetCrud targetCrud = new TargetCrud();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
    private TpsOperations tpsOperations;
    private ModelOperations<ExternalTceModel> externalTceModelOperations;
    private TpsCrud tpsCrud = new TpsCrud();

    // Parameters
    private final MjdToCadence mjdToCadence;
    private final FluxType fluxType;
    private final int skyGroupId;
    private final int startCadence;
    private final int endCadence;
    private final int startKeplerId;
    private final int endKeplerId;
    private final float boundedBoxWidth;
    private PlanetaryCandidatesFilter planetaryCandidatesFilter;
    private PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters;
    private final String[] mnemonics;
    private boolean externalTcesEnabled;

    // Local variables
    private Map<Integer, DvTarget> dvTargetsByKeplerId = new HashMap<Integer, DvTarget>(
        TARGETS_PER_CCD_MODULE_OUTPUT);

    private List<DvTarget> allTargets = Collections.emptyList();
    private Map<Integer, List<CelestialObjectParameters>> celestialObjectParametersListByKeplerId;
    private List<DvTargetTableData> allTargetTableData = Collections.emptyList();
    private Set<Long> producerTaskIds = new HashSet<Long>();

    /**
     * Creates a {@link TargetTableOperations} object which can be used to
     * acquire the {@link DvTargetTableData} and {@link DvTarget}s associated
     * with the given parameters.
     */
    public TargetTableOperations(
        MjdToCadence mjdToCadence,
        FluxType fluxType,
        int skyGroupId,
        int startCadence,
        int endCadence,
        int startKeplerId,
        int endKeplerId,
        float boundedBoxWidth,
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters,
        String[] mnemonics, boolean externalTcesEnabled) {

        checkNotNull(mjdToCadence, "mjdToCadence can't be null");
        checkNotNull(fluxType, "fluxType can't be null");
        if (endCadence < startCadence) {
            throw new IllegalArgumentException(
                "endCadence must be greater than or equal to startCadence");
        }
        if (endKeplerId < startKeplerId) {
            throw new IllegalArgumentException(
                "endKeplerId must be greater than or equal to startKeplerId");
        }
        checkNotNull(planetaryCandidatesFilterParameters,
            "planetaryCandidatesFilterParameters can't be null");
        checkNotNull(mnemonics, "mnemonics can't be null");

        this.mjdToCadence = mjdToCadence;
        this.fluxType = fluxType;
        this.skyGroupId = skyGroupId;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
        this.boundedBoxWidth = boundedBoxWidth;
        this.planetaryCandidatesFilter = new PlanetaryCandidatesFilterImpl(
            planetaryCandidatesFilterParameters);
        this.planetaryCandidatesFilterParameters = planetaryCandidatesFilterParameters;
        this.mnemonics = mnemonics;
        this.externalTcesEnabled = externalTcesEnabled;
    }

    /**
     * Returns all the {@link DvTarget} objects but without their time series
     * data (unpopulated).
     */
    public List<DvTarget> getAllTargets() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }
        return allTargets;
    }

    /**
     * Returns all the {@link DvTargetTableData} objects (populated).
     */
    public List<DvTargetTableData> getAllTargetTableData() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }
        return allTargetTableData;
    }

    /**
     * Returns a map of the {@link CelestialObjectParameters} objects by
     * keplerId.
     */
    public Map<Integer, List<CelestialObjectParameters>> getAllCelestialObjectParameters() {
        if (allTargets.isEmpty()) {
            getAllTargetsIntern();
        }

        return celestialObjectParametersListByKeplerId;
    }

    private void getAllTargetsIntern() {

        producerTaskIds.clear();

        Map<Integer, List<DvThresholdCrossingEvent>> tcesByKeplerId = new HashMap<Integer, List<DvThresholdCrossingEvent>>();

        if (externalTcesEnabled) {
            // Get the external TCEs.
            tcesByKeplerId.putAll(retrieveExternalTces());
        } else {
            // Get the TPS TCEs.
            tcesByKeplerId.putAll(retrieveTpsResults());
        }
        
        celestialObjectParametersListByKeplerId = celestialObjectOperations.retrieveCelestialObjectParameters(
            new ArrayList<Integer>(tcesByKeplerId.keySet()), boundedBoxWidth);
        
        Map<Integer, Set<String>> categoriesByKeplerId = retrieveCategories(tcesByKeplerId.keySet());

        // Create targets to be updated as target tables are processed.
        for (int keplerId : tcesByKeplerId.keySet()) {
            List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListByKeplerId.get(keplerId);

            if (celestialObjectParametersList == null) {
                log.warn(String.format(
                    "celestialObjectParametersList is null for keplerId %d",
                    keplerId));
                continue;
            }
            CelestialObjectParameters celestialObjectParameters = celestialObjectParametersList.get(0);
            if (celestialObjectParameters == null) {
                log.warn(String.format(
                    "celestialObjectParameters is null for keplerId %d",
                    keplerId));
                continue;
            }
            if (celestialObjectParameters.getSkyGroupId() != skyGroupId) {
                // Skip external TCEs not in the current sky group.
                continue;
            }
            CelestialObjectParameter keplerMag = celestialObjectParameters.getKeplerMag();
            CelestialObjectParameter ra = celestialObjectParameters.getRa();
            CelestialObjectParameter dec = celestialObjectParameters.getDec();
            CelestialObjectParameter effectiveTemp = celestialObjectParameters.getEffectiveTemp();
            CelestialObjectParameter log10SurfaceGravity = celestialObjectParameters.getLog10SurfaceGravity();
            CelestialObjectParameter log10Metallicity = celestialObjectParameters.getLog10Metallicity();
            CelestialObjectParameter radius = celestialObjectParameters.getRadius();

            Set<String> categorySet = categoriesByKeplerId.get(keplerId);
            String[] categories = ArrayUtils.EMPTY_STRING_ARRAY;
            if (categorySet != null && categorySet.size() > 0) {
                categories = categorySet.toArray(new String[categorySet.size()]);
            }

            DvTarget dvTarget = new DvTarget.Builder(keplerId, fluxType).keplerMag(
                keplerMag)
                .decDegrees(dec)
                .raHours(ra)
                .effectiveTemp(effectiveTemp)
                .log10Metallicity(log10Metallicity)
                .log10SurfaceGravity(log10SurfaceGravity)
                .radius(radius)
                .thresholdCrossingEvent(tcesByKeplerId.get(keplerId))
                .categories(categories)
                .build();
            dvTargetsByKeplerId.put(dvTarget.getKeplerId(), dvTarget);
        }

        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.LONG_CADENCE, startCadence, endCadence);

        pruneTargetsWithLabels(targetTableLogs);

        allTargets = new ArrayList<DvTarget>(dvTargetsByKeplerId.size());
        allTargets.addAll(dvTargetsByKeplerId.values());

        // Process each target table and update targets.
        allTargetTableData = new ArrayList<DvTargetTableData>(
            targetTableLogs.size());
        for (TargetTableLog targetTableLog : targetTableLogs) {
            allTargetTableData.add(processTargetTable(targetTableLog,
                mjdToCadence));
        }
    }

    private Map<Integer, List<DvThresholdCrossingEvent>> retrieveTpsResults() {

        log.info("Retrieving TPS results");
        PipelineInstance tpsPipelineInstance = tpsCrud.retrieveLatestTpsRun(TpsType.TPS_FULL);
        
        // Get the list of Kepler IDs in the specified range.
        List<TpsDbResult> tpsDbResults = tpsOperations.retrieveLatestTpsResultsWithFileStoreData(
            skyGroupId, startKeplerId, endKeplerId, planetaryCandidatesFilter);
        if (tpsDbResults == null || tpsDbResults.size() == 0) {
            throw new IllegalStateException(
                "No TPS results available for skyGroup=" + skyGroupId
                    + ",startKepId=" + startKeplerId + ",endKepId="
                    + endKeplerId);
        }

        Map<Integer, List<DvThresholdCrossingEvent>> tcesByKeplerId = new HashMap<Integer, List<DvThresholdCrossingEvent>>();
        for (TpsDbResult tpsDbResult : tpsDbResults) {
            producerTaskIds.add(tpsDbResult.getOriginator()
                .getId());
            tcesByKeplerId.put(
                tpsDbResult.getKeplerId(),
                Arrays.asList(DvThresholdCrossingEvent.getInstance(tpsDbResult)));
        }

        List<FsId> fsIds = new ArrayList<FsId>(tcesByKeplerId.size());
        for (Map.Entry<Integer, List<DvThresholdCrossingEvent>> tces : tcesByKeplerId.entrySet()) {
            for (DvThresholdCrossingEvent tce : tces.getValue()) {
                fsIds.add(TpsFsIdFactory.getDeemphasizedNormalizationTimeSeriesId(tpsPipelineInstance.getId(),
                    tces.getKey(), tce.getTrialTransitPulseDuration()));
            }
        }

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>(
            fsIds.size());
        FloatTimeSeries[] allTimeSeries = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsFloat(fsIds.toArray(new FsId[0]), startCadence,
                endCadence, false);
        for (FloatTimeSeries timeSeries : allTimeSeries) {
            if (timeSeries.exists()) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
                for (TaggedInterval interval : timeSeries.originators()) {
                    producerTaskIds.add(interval.tag());
                }
            }
        }

        for (Map.Entry<Integer, List<DvThresholdCrossingEvent>> tces : tcesByKeplerId.entrySet()) {
            for (DvThresholdCrossingEvent tce : tces.getValue()) {
                FloatTimeSeries timeSeries = timeSeriesByFsId.get(TpsFsIdFactory.getDeemphasizedNormalizationTimeSeriesId(
                    tpsPipelineInstance.getId(),tces.getKey(), tce.getTrialTransitPulseDuration()));
                if (timeSeries != null) {
                    tce.setDeemphasizedNormalizationTimeSeries(timeSeries.fseries());
                }
            }
        }

        return tcesByKeplerId;
    }

    private Map<Integer, List<DvThresholdCrossingEvent>> retrieveExternalTces() {

        log.info("Retrieving external TCEs");

        Map<Integer, List<DvThresholdCrossingEvent>> tcesByKeplerId = new HashMap<Integer, List<DvThresholdCrossingEvent>>();

        // Get all the TCEs in the model independent of sky group and specified
        // kepler id range.
        ExternalTceModel externalTceModel = externalTceModelOperations.retrieveModel();

        List<Integer> keplerIds = new ArrayList<Integer>();
        for (ExternalTce externalTce : externalTceModel.getExternalTces()) {
            if (!keplerIds.contains(externalTce.getKeplerId())) {
                keplerIds.add(externalTce.getKeplerId());
            }
        }
        Map<Integer, Integer> keplerIdToSkyGroupMap = celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        for (ExternalTce externalTce : externalTceModel.getExternalTces()) {
            int tceSkyGroupId = keplerIdToSkyGroupMap.get(externalTce.getKeplerId());
            if (externalTce.getKeplerId() < startKeplerId
                || externalTce.getKeplerId() > endKeplerId
                || tceSkyGroupId != skyGroupId
                || !planetaryCandidatesFilter.included(externalTce.getKeplerId())) {
                // Skip external TCEs that are outside of specified kepler id
                // range or explicitly excluded.
                continue;
            }
            List<DvThresholdCrossingEvent> tces = tcesByKeplerId.get(externalTce.getKeplerId());
            if (tces == null) {
                tces = new ArrayList<DvThresholdCrossingEvent>();
                tcesByKeplerId.put(externalTce.getKeplerId(), tces);
            }
            tces.add(DvThresholdCrossingEvent.getInstance(externalTce));
        }

        return tcesByKeplerId;
    }

    private Map<Integer, Set<String>> retrieveCategories(Set<Integer> keplerIds) {

        Map<Integer, Set<String>> categoriesByKeplerId = newHashMap();
        Map<Integer, List<PlannedTarget>> plannedTargetsByKeplerId = targetSelectionCrud.retrievePlannedTargets(keplerIds);
        for (Integer keplerId : plannedTargetsByKeplerId.keySet()) {
            Set<String> categories = newHashSet();
            List<PlannedTarget> plannedTargets = plannedTargetsByKeplerId.get(keplerId);
            for (PlannedTarget plannedTarget : plannedTargets) {
                categories.add(plannedTarget.getTargetList()
                    .getCategory());
            }
            categoriesByKeplerId.put(keplerId, categories);
            DatabaseServiceFactory.getInstance()
                .evictAll(plannedTargets);
        }

        return categoriesByKeplerId;
    }

    private void pruneTargetsWithLabels(List<TargetTableLog> targetTableLogs) {
        Set<String> labels = newHashSet(planetaryCandidatesFilterParameters.getExcludeTargetLabels());
        List<Integer> keplerIds = Arrays.asList(dvTargetsByKeplerId.keySet()
            .toArray(new Integer[0]));
        for (TargetTableLog targetTableLog : targetTableLogs) {
            List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
                targetTableLog.getTargetTable(), keplerIds);
            for (ObservedTarget observedTarget : observedTargets) {
                if (observedTarget == null) {
                    // This target does not exist in this target table.
                    continue;
                }

                if (observedTarget.getLabels() != null
                    && !Collections.disjoint(observedTarget.getLabels(), labels)) {
                    dvTargetsByKeplerId.remove(observedTarget.getKeplerId());
                }
            }
        }
    }

    private DvTargetTableData processTargetTable(TargetTableLog targetTableLog,
        MjdToCadence mjdToCadence) {

        int tableStartCadence = targetTableLog.getCadenceStart() < startCadence ? startCadence
            : targetTableLog.getCadenceStart();
        int tableEndCadence = targetTableLog.getCadenceEnd() > endCadence ? endCadence
            : targetTableLog.getCadenceEnd();
        TimestampSeries cadenceTimes = mjdToCadence.cadenceTimes(
            tableStartCadence, tableEndCadence, true, false);
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        int[] quarters = rollTimeOperations.mjdToQuarter(new double[] { startMjd });

        TargetTable targetTable = targetTableLog.getTargetTable();
        log.info("Retrieving sky group");
        SkyGroup skyGroup = kicCrud.retrieveSkyGroup(skyGroupId,
            targetTable.getObservingSeason());
        TargetOperations targetOperations = new TargetOperations(targetTable,
            skyGroup.getCcdModule(), skyGroup.getCcdOutput(),
            tableStartCadence, tableEndCadence, startMjd, endMjd, quarters[0],
            dvTargetsByKeplerId);
        targetOperations.setTargetCrud(targetCrud);
        targetOperations.updateAllTargets();

        log.info("Retrieving ancillary pipeline data");
        List<AncillaryPipelineData> ancillaryPipelineData = ancillaryOperations.retrieveAncillaryPipelineData(
            mnemonics, targetTable, skyGroup.getCcdModule(),
            skyGroup.getCcdOutput(), cadenceTimes);
        producerTaskIds.addAll(ancillaryOperations.producerTaskIds());

        log.info("Retrieving background blobs");
        BlobSeries<String> blobSeries = blobOperations.retrieveBackgroundBlobFileSeries(
            skyGroup.getCcdModule(), skyGroup.getCcdOutput(),
            tableStartCadence, tableEndCadence);
        producerTaskIds.addAll(blobSeries.blobOriginatorsSet());
        BlobFileSeries backgroundBlobs = new BlobFileSeries(blobSeries);

        log.info("Retrieving motion blobs");
        blobSeries = blobOperations.retrieveMotionBlobFileSeries(
            skyGroup.getCcdModule(), skyGroup.getCcdOutput(),
            tableStartCadence, tableEndCadence);
        producerTaskIds.addAll(blobSeries.blobOriginatorsSet());
        BlobFileSeries motionBlobs = new BlobFileSeries(blobSeries);

        log.info("Retrieving CBV blobs");
        blobSeries = blobOperations.retrieveCbvBlobFileSeries(
            skyGroup.getCcdModule(), skyGroup.getCcdOutput(), CadenceType.LONG,
            tableStartCadence, tableEndCadence);
        producerTaskIds.addAll(blobSeries.blobOriginatorsSet());
        BlobFileSeries cbvBlobs = new BlobFileSeries(blobSeries);

        log.info("Retrieving argabrightening indices");
        int[] argabrighteningIndices = retrieveArgabrighteningIndices(
            targetTableLog.getTargetTable(), tableStartCadence,
            tableEndCadence, skyGroup.getCcdModule(), skyGroup.getCcdOutput());

        DvTargetTableData targetTableData = new DvTargetTableData(
            targetTable.getExternalId(), skyGroup.getCcdModule(),
            skyGroup.getCcdOutput(), tableStartCadence, tableEndCadence,
            quarters[0], ancillaryPipelineData, argabrighteningIndices,
            backgroundBlobs, cbvBlobs, motionBlobs);

        return targetTableData;
    }

    private int[] retrieveArgabrighteningIndices(TargetTable targetTable,
        int startCadence, int endCadence, int ccdModule, int ccdOutput) {

        log.info("Retrieving argabrightening indices");
        FsId fsId = PaFsIdFactory.getArgabrighteningFsId(targetTable.getType()
            .toCadenceType(), targetTable.getExternalId(), ccdModule, ccdOutput);
        IntTimeSeries[] intTimeSeries = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsInt(new FsId[] { fsId }, startCadence, endCadence,
                false);

        TimeSeriesOperations.addToDataAccountability(intTimeSeries,
            producerTaskIds);

        List<Integer> indices = new ArrayList<Integer>();
        if (intTimeSeries[0].exists()) {
            boolean[] argabrighteningGaps = intTimeSeries[0].getGapIndicators();
            for (int i = 0; i < argabrighteningGaps.length; i++) {
                if (!argabrighteningGaps[i]) {
                    indices.add(i);
                }
            }
        }

        int[] argabrighteningIndices = new int[indices.size()];
        for (int i = 0; i < indices.size(); i++) {
            argabrighteningIndices[i] = indices.get(i);
        }

        return argabrighteningIndices;
    }

    public Set<Long> latestProducerTaskIds() {
        Set<Long> currentTaskIds = producerTaskIds;
        producerTaskIds = new HashSet<Long>();
        return currentTaskIds;
    }

    /**
     * This method is only needed for testing.
     */
    void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    /**
     * This method is only needed for testing.
     */
    void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    /**
     * This method is only needed for testing.
     */
    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

    /**
     * This method is only needed for testing.
     */
    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    /**
     * This method is only needed for testing.
     */
    void setRollTimeOperations(RollTimeOperations rollTimeOperations) {
        this.rollTimeOperations = rollTimeOperations;
    }

    /**
     * This method is only needed for testing.
     */
    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    /**
     * This method is only needed for testing.
     */
    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    /**
     * This method is only needed for testing.
     */
    void setTpsOperations(TpsOperations tpsOperations) {
        this.tpsOperations = tpsOperations;
    }
    
    /**
     * This method is only needed for testing.
     */
    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }

    /**
     * This method is only needed for testing.
     */
    void setExternalTceModelOperations(
        ModelOperations<ExternalTceModel> externalTceModelOperations) {
        this.externalTceModelOperations = externalTceModelOperations;
    }
}
