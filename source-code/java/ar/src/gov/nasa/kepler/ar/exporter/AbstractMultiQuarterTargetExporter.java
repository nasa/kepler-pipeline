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

package gov.nasa.kepler.ar.exporter;

import gnu.trove.TLongHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.MapConstraints;
import com.google.common.collect.Maps;

/**
 * Like AbstractPerTargetExporter except that this deals with the case where you have more than
 * one quarters worth of data.  In this case some of the information provided by
 * the source no longer makes sense.  This doesn't do short cadence.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AbstractMultiQuarterTargetExporter<
    M extends AbstractTargetMetadata,
    S extends MultiQuarterTargetSource>
    extends AbstractTargetExporter<M, S> {
    
    private static final Log log = LogFactory.getLog(AbstractMultiQuarterTargetExporter.class);
    
    /**
     * Assembles the export data for all targets. There is a whole bunch of
     * logic to deal with custom targets and filling in missing data for some
     * targets.
     * 
     * @param source must not be null
     * @param observedTargetFilter when true retain the target, this is useful
     * to remove some targets which should not be exported.
     * @param metadataFactory create metadata for a specific data product.
     * @return
     */
    protected ExportData<M> exportData(S exporterSource) {

        log.info("Start assembling the export data.");
        log.info("Exporting target pixel files for " + exporterSource.cadenceType()
            + " cadences [" + exporterSource.startCadence() + "," + exporterSource.endCadence()
            + "] and "
            + " target tables " + Arrays.deepToString(exporterSource.targetTableExternalId()) + ".");

        if (exporterSource.cadenceType() == CadenceType.SHORT) {
            throw new IllegalArgumentException("I don't do short cadence.");
        }

        TLongHashSet sourceTaskIds = new TLongHashSet();
        SortedMap<Integer, M> keplerIdToTargetPixelMetadata = 
            mapTargetsToMetadata(
                exporterSource,
                exporterSource.targetTableExternalId(),
                exporterSource.celestialObjects(),
                exporterSource.observedTargets(),
                exporterSource.tpsResults(),
                exporterSource.sciOps(),
                exporterSource.ccdChannels(),
                sourceTaskIds,
                exporterSource.timestampSeries(),
                exporterSource.fsClient());

        if (keplerIdToTargetPixelMetadata.isEmpty()) {
            log.warn("All targets skipped.");
            ExportData<M> empty = ExportData.empty();
            return empty;
        }
        
        Map<FsId, TimeSeriesDataType> timeSeriesFsIds =
            new HashMap<FsId, TimeSeriesDataType>(1024 * 4);
        Set<FsId> mjdTimeSeriesFsIds = new HashSet<FsId>(1024 * 4);
        for (M targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            targetMetadata.addToTimeSeriesIds(timeSeriesFsIds);
            targetMetadata.addToMjdTimeSeriesIds(mjdTimeSeriesFsIds);
        }

        List<DataQualityMetadata<M>> perQuarterQualityMetadata = 
            Lists.newArrayList();
        
        for (int i=0; i < exporterSource.targetTableExternalId().length; i++) {
            Integer ttableId = exporterSource.targetTableExternalId()[i];
            if (ttableId == null) {
                perQuarterQualityMetadata.add(null);
                continue;
            }
            
            TargetTableLog ttableLog = exporterSource.targetTableLogs().get(i);
            Pair<Integer, Integer> ccdChannel = exporterSource.ccdChannels().get(ttableId);
            if (ccdChannel == null) {
                perQuarterQualityMetadata.add(null);
                continue;
            }
            
            DataQualityMetadata<M> dataQualityMetadata = 
            new DataQualityMetadata<M>(ttableId,
                ttableId,
                exporterSource.cadenceType(), 
                exporterSource.cadenceType() == CadenceType.SHORT,
                ccdChannel.left, ccdChannel.right,
                ttableLog.getCadenceStart(), ttableLog.getCadenceEnd(),
                exporterSource.anomalies(), exporterSource.mjdToCadence(),
                exporterSource.timestampSeries(),
                null);
     
            dataQualityMetadata.addTimeSeriesTo(timeSeriesFsIds);
            perQuarterQualityMetadata.add(dataQualityMetadata);
        }

        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries = 
            fetchFileStoreStuff(
            timeSeriesFsIds, mjdTimeSeriesFsIds, sourceTaskIds,
            exporterSource.startCadence(), exporterSource.endCadence(),
            exporterSource.cadenceType(),
            -1, -1, Collections.EMPTY_MAP,
            exporterSource.mjdToCadence(), exporterSource.fsClient());

        exporterSource.originatorsModelRegistryChecker().check(allTimeSeries);
        
        for (M metadata : keplerIdToTargetPixelMetadata.values()) {
            int[] multiQuarterDataQualityFlags = 
                new int[exporterSource.endCadence() - exporterSource.startCadence() + 1];
            for (DataQualityMetadata<M> dataQualityMetadata : perQuarterQualityMetadata) {
                dataQualityMetadata.setAllMjdTimeSeries(allTimeSeries.right);
                dataQualityMetadata.setAllTimeSeries(allTimeSeries.left);
                dataQualityMetadata.setTargetMetadata(metadata);
                int[] singleQuarterFlags = dataQualityMetadata.calculateDataQualityFlags();
                int multiQuarterOffset = dataQualityMetadata.startCadence() - exporterSource.startCadence();
                for (int i=0, mqIndex=multiQuarterOffset; 
                        i < singleQuarterFlags.length && mqIndex < multiQuarterDataQualityFlags.length;
                        i++, mqIndex++) {
                    multiQuarterDataQualityFlags[multiQuarterOffset + i] |= singleQuarterFlags[i];
                }
                metadata.setDataQualityFlags(multiQuarterDataQualityFlags);
            }
        }
        
        
        removeEmptyEntries(keplerIdToTargetPixelMetadata, allTimeSeries.left,
            allTimeSeries.right);
        

        skippedTargetsReport(exporterSource.keplerIds(), keplerIdToTargetPixelMetadata);

        log.info("End assembling the export data.");

        return new ExportData<M>(allTimeSeries.left, allTimeSeries.right,
            keplerIdToTargetPixelMetadata.values(), sourceTaskIds);
    }
    
    /**
     * @param source
     * @param metadataFactory
     * @param keplerIdToKic
     * @param keplerIdToObservedTarget
     * @param keplerIdToCdpp
     * @param sourceTaskIds
     * @return
     */
    protected SortedMap<Integer, M> mapTargetsToMetadata(
        S exporterSource,
        Integer[] targetTableIds,
        List<CelestialObject> celestialObjects,
        List<ObservedTarget> observedTargets,
        List<TpsDbResult> tpsDbResults,
        List<SciencePixelOperations> sciOps,
        Map<Integer, Pair<Integer, Integer>> ccdChannels,
        TLongHashSet sourceTaskIds,
        TimestampSeries cadenceTimes,
        FileStoreClient fsClient
        ) {

        Map<Integer, CelestialObject> keplerIdToKic = MapConstraints.constrainedMap(
            new HashMap<Integer, CelestialObject>(), MapConstraints.notNull());
        addCelestialObjectsToMap(keplerIdToKic, celestialObjects);

        Map<Integer, List<ObservedTarget>> keplerIdToObservedTarget = 
            observedTargetsByKeplerIdAndTargetTable(targetTableIds, observedTargets);
        
        Map<Integer, RmsCdpp> keplerIdToCdpp = toTpsDbResultMap(tpsDbResults);
        
        Map<Integer, TpsDbResult> initialTce = toInitialDbResultMap(tpsDbResults);
        
        SortedMap<Integer, M> keplerIdToTargetPixelMetadata =
            buildTargetMetadata(exporterSource,
                keplerIdToKic, keplerIdToObservedTarget, keplerIdToCdpp,
                initialTce, sourceTaskIds, ccdChannels, sciOps);

        for (Integer externalTtableId : targetTableIds) {
            if (externalTtableId == null) {
                continue;
            }
            fetchRollingBandFlags(
                externalTtableId,
                keplerIdToTargetPixelMetadata, 
                    cadenceTimes,
                    fsClient);
        }
        
        return keplerIdToTargetPixelMetadata;

    }

    private Map<Integer, TpsDbResult> toInitialDbResultMap(
        List<TpsDbResult> tpsDbResults) {

        Map<Integer, TpsDbResult> initialTces = Maps.newHashMap();
        for (TpsDbResult tpsDbResult : tpsDbResults) {
            if (!tpsDbResult.isPlanetACandidate()) {
                continue;
            }
            Integer keplerId = tpsDbResult.getKeplerId();
            if (initialTces.containsKey(keplerId)) {
                TpsDbResult preTce = initialTces.get(keplerId);
                if (preTce.getMaxMultipleEventStatistic() < tpsDbResult.getMaxMultipleEventStatistic()) {
                    initialTces.put(keplerId, tpsDbResult);
                }
            } else {
                initialTces.put(keplerId, tpsDbResult);
            }
        }
        return initialTces;
    }

    protected SortedMap<Integer, M> buildTargetMetadata(
        S exporterSource,
        Map<Integer, CelestialObject> keplerIdToCelestialObject,
        Map<Integer, List<ObservedTarget>> keplerIdToObservedTarget,
        Map<Integer, RmsCdpp> keplerIdToCdpp,
        Map<Integer, TpsDbResult> initialTces,
        TLongHashSet sourceTaskIds,
        Map<Integer, Pair<Integer, Integer>> ccdChannels,
        List<SciencePixelOperations> sciOps) {

        log.info("Starting to build target metadata.");
        SortedMap<Integer, M> perTargetMetadata = new TreeMap<Integer, M>();
        
        Integer[] ttableIds = exporterSource.targetTableExternalId();
        for (Integer keplerId : keplerIdToCelestialObject.keySet()) {
            List<Set<Pixel>> pixelsPerQuarter = Lists.newArrayListWithExpectedSize(ttableIds.length);
            CelestialObject celestialObject = keplerIdToCelestialObject.get(keplerId);

            List<ObservedTarget> observedTargetsForKeplerId = keplerIdToObservedTarget.get(keplerId);
            RmsCdpp rmsCdpp = keplerIdToCdpp.get(keplerId);
            
            for (int i=0; i < ttableIds.length; i++) {
                Integer ttableId = ttableIds[i];
                pixelsPerQuarter.add(null);
                if (ttableId == null) {
                    continue;
                }
                ObservedTarget observedTarget = observedTargetsForKeplerId.get(i);
                if (observedTarget == null) {
                    continue;
                }
                Pair<Integer, Integer> ccdChannel = ccdChannels.get(ttableId);
                sourceTaskIds.add(observedTarget.getPipelineTask().getId());
                Set<Pixel> targetPixels = 
                    sciOps.get(i).loadTargetPixels(observedTarget, ccdChannel.left, ccdChannel.right);
                pixelsPerQuarter.set(i, targetPixels);
            }
            
            TpsDbResult initialTce = initialTces.get(keplerId);
            sourceTaskIds.add(initialTce.getOriginator().getId());

            M multiQuarterTargetMetadata = 
                createMultiQuarterTargetMetadata(exporterSource,
                    celestialObject, observedTargetsForKeplerId, 
                    rmsCdpp, pixelsPerQuarter, initialTce);
            if (multiQuarterTargetMetadata == null) {
                continue;
            }
            
            perTargetMetadata.put(keplerId, multiQuarterTargetMetadata);

        }
        log.info("Building target metadata is complete.");
        return perTargetMetadata;
    }

    /**
     * Create a target metadata instance.
     * 
     * @param celestialObject
     * @param observedTargetForKeplerId
     * @param rmsCdpp
     * @param pixelsPerQuarter
     * @param initialTce
     * @return null if some dependent object does not exist.
     */
    protected abstract M createMultiQuarterTargetMetadata(
        S exporterSource,
        CelestialObject celestialObject,
        List<ObservedTarget> observedTargetForKeplerId, RmsCdpp rmsCdpp,
        List<Set<Pixel>> pixelsPerQuarter, TpsDbResult initialTce);

    
    /**
     * Collects all the observed targets by kepler id.
     * 
     * @param targetTableIds non-null, though it may contain nulls.
     * @param observedTargets non-null
     * @return non-null
     */
    private Map<Integer, List<ObservedTarget>> observedTargetsByKeplerIdAndTargetTable(
        Integer[] targetTableIds, List<ObservedTarget> observedTargets) {
        Map<Integer, Integer> ttableIdToIndex = Maps.newHashMap();
        for (int i=0; i < targetTableIds.length; i++) {
            Integer externalId = targetTableIds[i];
            if (externalId != null) {
                ttableIdToIndex.put(externalId, i);
            }
        }
        Map<Integer, List<ObservedTarget>> keplerIdToObservedTarget = Maps.newHashMap();
        for (ObservedTarget ot : observedTargets) {
            if (ot == null) {
                continue;
            }
            if (!keplerIdToObservedTarget.containsKey(ot.getKeplerId())) {
                //This puts nulls into the list.
                List<ObservedTarget> newList = Lists.newArrayList();
                for (int i=0; i < targetTableIds.length; i++) {
                    newList.add(null);
                }
                keplerIdToObservedTarget.put(ot.getKeplerId(), newList);
            }
            List<ObservedTarget> observedTargetsForKeplerId = keplerIdToObservedTarget.get(ot.getKeplerId());
            observedTargetsForKeplerId.set(ttableIdToIndex.get(ot.getTargetTable().getExternalId()), ot);
        }
        return keplerIdToObservedTarget;
    }

}
