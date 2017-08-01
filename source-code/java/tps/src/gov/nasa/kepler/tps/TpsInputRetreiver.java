/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.tps;

import static gov.nasa.kepler.mc.pdc.FilledCadencesUtil.indicatorsToIndices;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrowdingInfo;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.TransitOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.pi.NumberOfElementsPerSubTask;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

/**
 * Get the inputs for a TPS unit of work. This class is not MT-safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class TpsInputRetreiver {

    private static final Log log = LogFactory.getLog(TpsInputRetreiver.class);
    private static final FluxType fluxType = FluxType.SAP;

    private TLongHashSet originators;
    private int skippedKeplerIdCount;

    public List<TpsInputs> retrieveInputs(
        long pipelineTaskId,
        int startCadence,
        int endCadence,
        int startKeplerId,
        int endKeplerId,
        TargetCrud targetCrud,
        PdcCrud pdcCrud,
        TargetSelectionCrud targetSelectionCrud,
        MjdToCadence mjdToCadence,
        int skyGroupId,
        FileStoreClient fsClient,
        TransitOperations transitOps,
        RollTimeOperations rollTimeOps,
        CelestialObjectOperations celestialObjOps,
        TpsModuleParameters tpsModuleParameters,
        TpsHarmonicsIdentificationParameters tpsHarmonicsIdentificationParameters,
        GapFillModuleParameters gapFillParameters,
        BootstrapModuleParameters bootstrapParameters,
        List<String> targetListNames, List<String> excludeTargetListNames,
        NumberOfElementsPerSubTask numElementsCalc,
        int taskTimeoutSecs, double tasksPerCore) {

        skippedKeplerIdCount = 0;
        originators = new TLongHashSet();

        List<TargetTableLog> ttableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.LONG_CADENCE, startCadence, endCadence);

        MqTimestampSeries mqCadenceTimes = 
            new MqTimestampSeries(rollTimeOps, mjdToCadence, startCadence, endCadence);

        Set<Integer> allKeplerIds = ImmutableSet.copyOf(targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            targetListNames, skyGroupId, startKeplerId, endKeplerId));
        Set<Integer> excludeKeplerIds = Sets.newHashSet(targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            excludeTargetListNames, skyGroupId, startKeplerId, endKeplerId));

        log.info("Found " + excludeKeplerIds.size() + " excluded kepler ids.");
        
        List<CelestialObjectParameters> celestialObjectParametersList = 
                celestialObjOps.retrieveCelestialObjectParameters(allKeplerIds);

        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters = new LinkedHashMap<Integer, CelestialObjectParameters>();
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            if (celestialObjectParameters != null) {
                keplerIdToCelestialObjectParameters.put(
                    celestialObjectParameters.getKeplerId(),
                    celestialObjectParameters);
            }
        }
        
        Map<Integer, TargetCrowdingInfo> keplerIdToCrowdingMetrics =
            retrieveCrowdingMetrics(skyGroupId, ttableLogs, targetCrud);
        
        Set<Integer> filteredKeplerIds = filterKeplerIds(allKeplerIds,
                keplerIdToCelestialObjectParameters.keySet(), excludeKeplerIds, 
                keplerIdToCrowdingMetrics.keySet());
        
        RollTimeModel rtModel = rollTimeOps.retrieveRollTimeModelAll();

        log.info("Processing " + filteredKeplerIds.size()
            + " keplerIds for target list \""
            + StringUtils.join(targetListNames.toArray(), ", ") + "\".");

        Map<Integer, FsIdsForTarget> keplerIdToFsIds = 
            generateFsIdsForTarget(mjdToCadence.cadenceType(), filteredKeplerIds);
        Set<FsId> timeSeriesIds = Sets.newHashSetWithExpectedSize(filteredKeplerIds.size() * 4);
        Set<FsId> mjdTimeSeriesIds = Sets.newHashSetWithExpectedSize(filteredKeplerIds.size());
        for (FsIdsForTarget fsIdsForTarget : keplerIdToFsIds.values()) {
            fsIdsForTarget.addTimeSeriesIdsTo(timeSeriesIds);
            fsIdsForTarget.addMjdTimeSeriesTo(mjdTimeSeriesIds);
        }

        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries = fsClient.readMjdTimeSeries(
            mjdTimeSeriesIds, mqCadenceTimes.startMjd(), mqCadenceTimes.endMjd());

        // Some kepler ids may not exist because TAD rejected them or for some
        // other reasons. Do not throw an exception if that happens.

        Map<FsId, TimeSeries> allTimeSeries = fsClient.readTimeSeries(
            timeSeriesIds, startCadence, endCadence, false);

        for (TimeSeries ts : allTimeSeries.values()) {
            ts.uniqueOriginators(originators);
        }

        for (FloatMjdTimeSeries fts : allMjdTimeSeries.values()) {
            originators.addAll(fts.originators());
        }

        Map<Integer, PdcProcessingCharacteristics[]> pdcCharacteristics =
            loadPdcDataProcessingCharacteristics(pdcCrud, filteredKeplerIds, ttableLogs);

        Map<Integer, List<Transit>> transitEphemerisByKeplerId = 
            transitOps.getTransits(allKeplerIds);
        int nTargetsPerSubTask = numElementsCalc.numberOfElementsPerSubTask(filteredKeplerIds.size());
        ListChunkIterator<Integer> subTaskChunkIterator = new ListChunkIterator<Integer>(
            filteredKeplerIds.iterator(), nTargetsPerSubTask);
        List<TpsInputs> allTpsInputs = Lists.newArrayList();
        int numTargetsInAllSubTasks = 0;

        for (List<Integer> keplerIdsInThisSubtask : subTaskChunkIterator) {

            List<TpsTarget> tpsTargetsForSubTask = generateSubTaskInputs(
                keplerIdsInThisSubtask, startCadence, endCadence, mjdToCadence,
                keplerIdToFsIds, keplerIdToCrowdingMetrics, pdcCharacteristics,
                keplerIdToCelestialObjectParameters, transitEphemerisByKeplerId, 
                allTimeSeries, allMjdTimeSeries);

            if (tpsTargetsForSubTask.isEmpty()) {
                continue;
            }

            numTargetsInAllSubTasks += tpsTargetsForSubTask.size();

            TpsInputs tpsInputsForSubTask = new TpsInputs(skyGroupId,
                tpsModuleParameters, gapFillParameters,
                tpsHarmonicsIdentificationParameters, 
                bootstrapParameters, tpsTargetsForSubTask,
                rtModel, mqCadenceTimes, taskTimeoutSecs, tasksPerCore);
            allTpsInputs.add(tpsInputsForSubTask);
        }

        if (numTargetsInAllSubTasks == 0) {
            log.warn("Unit of work did not contain any targets that had data.");
            return Collections.emptyList();
        }

        log.info("Skipped " + skippedKeplerIdCount + " targets.");

        return allTpsInputs;
    }

    private Set<Integer> filterKeplerIds(Set<Integer> keplerIds,
        Set<Integer> goodSet, Set<Integer> excludeKeplerIds,
        Set<Integer> keplerIdsWithCrowdingInfo) {
        ImmutableSet.Builder<Integer> builder = ImmutableSet.builder();
        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                continue;
            }
            if (excludeKeplerIds.contains(keplerId)) {
                skippedKeplerIdCount++;
                continue;
            }
            if (!keplerIdsWithCrowdingInfo.contains(keplerId)) {
                log.warn("Target with kepler id " + keplerId + 
                    " does not have crowding info.  Skipping.");
                skippedKeplerIdCount++;
                continue;
            }
            if (!goodSet.contains(keplerId)) {
                log.warn("Target with kepler id " + keplerId
                    + " does not have a celestial object.");
            }
            builder.add(keplerId);
        }
        return builder.build();
    }

    private List<TpsTarget> generateSubTaskInputs(
        List<Integer> keplerIdsInThisSubTask,
        int startCadence,
        int endCadence,
        MjdToCadence mjdToCadence,
        Map<Integer, FsIdsForTarget> keplerIdToFsIds,
        Map<Integer, TargetCrowdingInfo> keplerIdToCrowdingMetrics,
        Map<Integer, PdcProcessingCharacteristics[]> pdcCharacteristics,
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters,
        Map<Integer, List<Transit>> transitEphemerisByKeplerId,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries) {

        List<TpsTarget> rv = Lists.newArrayListWithCapacity(keplerIdsInThisSubTask.size());
        
        for (Integer keplerId : keplerIdsInThisSubTask) {
            FsIdsForTarget fsIdsForTarget = keplerIdToFsIds.get(keplerId);
            FloatTimeSeries fluxTimeSeries = (FloatTimeSeries) allTimeSeries.get(fsIdsForTarget.fluxId);
            FloatTimeSeries fluxUmmTimeSeries = (FloatTimeSeries) allTimeSeries.get(fsIdsForTarget.fluxUmmId);

            // Skip
            if (!fluxTimeSeries.exists() || fluxTimeSeries.isEmpty()) {
                log.warn("Skipped target with kepler id "
                    + keplerId
                    + " since the PDC light curve does not exist or have any values"
                    + " for the cadence interval.");
                skippedKeplerIdCount++;
                continue;
            }

            int[] fillIndices = filledIndicesForKeplerId(keplerId,
                fsIdsForTarget.filledIndicesId, "filled", allTimeSeries);
            int[] discontinuityIndices = filledIndicesForKeplerId(keplerId,
                fsIdsForTarget.discontinuityId, "discontinuity", allTimeSeries);
            int[] outlierIndices = mjdTimeSeriesToIndices(keplerId,
                startCadence, fsIdsForTarget.outlierId, "outlier",
                allMjdTimeSeries, mjdToCadence);

            // Number of target tables this target appears on.
            int nTargetTables = keplerIdToCrowdingMetrics.values()
                .iterator()
                .next()
                .getCcdModule().length;

            TargetDiagnostics diagnostics = null;
            TargetCrowdingInfo targetCrowdingInfo = 
                keplerIdToCrowdingMetrics.get(keplerId);
            if (keplerIdToCelestialObjectParameters.get(keplerId) != null) {
                // For debugging bin files only; MATLAB doesn't actually use
                // this. I hope.

                float keplerMag = (float)
                    keplerIdToCelestialObjectParameters.get(keplerId)
                    .getKeplerMag()
                    .getValue();

                PdcProcessingCharacteristics[] pdcCharacteristicsPerQuarter = pdcCharacteristics.get(keplerId);
                diagnostics = new TargetDiagnostics(
                    targetCrowdingInfo, keplerMag,
                    keplerMag != Float.POSITIVE_INFINITY,
                    pdcCharacteristicsPerQuarter);
            } else {
                diagnostics = new TargetDiagnostics(nTargetTables);
            }
            
            TpsTarget tpsTarget = new TpsTarget(keplerId, diagnostics,
                fluxTimeSeries.fseries(), fluxUmmTimeSeries.fseries(),
                fluxTimeSeries.getGapIndices(), fillIndices, outlierIndices,
                discontinuityIndices, targetCrowdingInfo.getGapIndicators(),
                transitEphemerisByKeplerId.get(keplerId));
                
            rv.add(tpsTarget);
        }

        return rv;
    }

    private Map<Integer, PdcProcessingCharacteristics[]> loadPdcDataProcessingCharacteristics(
        PdcCrud pdcCrud, Collection<Integer> keplerIds,
        List<TargetTableLog> ttableLogs) {

        PdcProcessingCharacteristicsFactory factory =
            new PdcProcessingCharacteristicsFactory(ttableLogs, pdcCrud, keplerIds);

        Map<Integer, PdcProcessingCharacteristics[]> characteristics = Maps.newHashMap();

        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                continue;
            }
            PdcProcessingCharacteristics[] forTarget =
                factory.characteristicsForTarget(keplerId);
            characteristics.put(keplerId, forTarget);
        }

        return characteristics;
    }

    private int[] filledIndicesForKeplerId(Integer keplerId, FsId id,
        String errorInfo, Map<FsId, TimeSeries> allTimeSeries) {

        IntTimeSeries fillSeries = (IntTimeSeries) allTimeSeries.get(id);
        if (fillSeries == null || !fillSeries.exists()) {
            throw new ModuleFatalProcessingException("Can't find " + errorInfo
                + " time series for keplerId " + keplerId + ".");
        }

        int[] fillIndices = indicatorsToIndices(fillSeries);
        return fillIndices;
    }

    private int[] mjdTimeSeriesToIndices(Integer keplerId, int startCadence,
        FsId fsId, String errorInfo,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        MjdToCadence mjdToCadence) {

        FloatMjdTimeSeries mjdTimeSeries = allMjdTimeSeries.get(fsId);
        if (mjdTimeSeries == null || !mjdTimeSeries.exists()) {
            throw new ModuleFatalProcessingException("Can't find " + errorInfo
                + " series for keplerId " + keplerId + ".");
        }

        int[] indices = new int[mjdTimeSeries.mjd().length];
        int nextEmptySlot = 0;
        for (double fillMjd : mjdTimeSeries.mjd()) {
            indices[nextEmptySlot++] = 
                mjdToCadence.mjdToCadence(fillMjd) - startCadence;
        }
        return indices;
    }

    private Map<Integer, TargetCrowdingInfo> retrieveCrowdingMetrics(
        int skyGroupId, List<TargetTableLog> ttableLogs, TargetCrud targetCrud) {

        List<TargetTable> ttables = new ArrayList<TargetTable>();
        for (TargetTableLog ttableLog : ttableLogs) {
            ttables.add(ttableLog.getTargetTable());
        }

        return targetCrud.retrieveCrowdingMetricInfo(ttables, skyGroupId);
    }

    private Map<Integer, FsIdsForTarget> generateFsIdsForTarget(CadenceType cadenceType, Set<Integer> keplerIds) {
        ImmutableMap.Builder<Integer, FsIdsForTarget> bldr = ImmutableMap.builder();
        for (Integer keplerId : keplerIds) {
            bldr.put(keplerId, new FsIdsForTarget(keplerId, cadenceType));
        }
        return bldr.build();
    }

    Set<Long> originators() {
        Set<Long> juSet = Sets.newHashSetWithExpectedSize(originators.size());
        for (long o : originators.toArray()) {
            juSet.add(o);
        }
        return juSet;
    }

    private static final class FsIdsForTarget {
        private final FsId fluxId;
        private final FsId fluxUmmId;
        private final FsId filledIndicesId;
        private final FsId discontinuityId;
        private final FsId outlierId;

        FsIdsForTarget(int keplerId, CadenceType cadenceType) {
            fluxId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX, fluxType,
                CadenceType.LONG, keplerId);
            fluxUmmId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
                fluxType, CadenceType.LONG, keplerId);
            filledIndicesId = PdcFsIdFactory.getFilledIndicesFsId(
                PdcFilledIndicesTimeSeriesType.FILLED_INDICES, fluxType,
                CadenceType.LONG, keplerId);
            discontinuityId = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                fluxType, CadenceType.LONG, keplerId);
            outlierId = PdcFsIdFactory.getOutlierTimerSeriesId(
                PdcOutliersTimeSeriesType.OUTLIERS, fluxType, CadenceType.LONG,
                keplerId);
        }

        void addTimeSeriesIdsTo(Set<FsId> dest) {
            dest.add(fluxId);
            dest.add(fluxUmmId);
            dest.add(filledIndicesId);
            dest.add(discontinuityId);
        }

        void addMjdTimeSeriesTo(Set<FsId> dest) {
            dest.add(outlierId);
        }
    }

}
