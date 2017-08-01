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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newLinkedHashMap;
import static com.google.common.collect.Sets.newLinkedHashSet;
import static com.google.common.primitives.Ints.toArray;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.DETRENDED;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.INITIAL;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.TRAPEZOIDAL_MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.WHITENED_MODEL_LIGHT_CURVE;
import gov.nasa.kepler.cal.io.CalCompressionTimeSeries;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.EnumList;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.common.intervals.BlobFileSeriesFactory;
import gov.nasa.kepler.common.intervals.CadenceData;
import gov.nasa.kepler.common.intervals.CadenceDataCalculator;
import gov.nasa.kepler.common.intervals.CadenceDataFactory;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults;
import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;
import gov.nasa.kepler.hibernate.dv.DvPixelStatistic;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.CompoundIndicesTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SimpleIndicesTimeSeries;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.SingleEventParse;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.kepler.systest.sbt.data.EnumMapFactory.EnumPairType;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;

/**
 * This class retrieves all of the data available for a {@link List} of
 * keplerIds.
 * 
 * @author Miles Cote
 * 
 */
public class SbtDataOperations {

    private final MqTimestampSeriesFactory mqTimestampSeriesFactory;
    private final MjdToCadenceFactory mjdToCadenceFactory;
    private final RollTimeOperations rollTimeOperations;
    private final TargetCrud targetCrud;
    private final KicCrud kicCrud;
    private final PixelSetFactory pixelSetFactory;
    private final FsIdToTimeSeriesMapFactory fsIdToTimeSeriesMapFactory;
    private final PersistableTimeSeriesFactory persistableTimeSeriesFactory;
    private final SbtBlobSeriesOperations sbtBlobSeriesOperations;
    private final CelestialObjectOperations celestialObjectOperations;
    private final IndexingSchemeConverter indexingSchemeConverter;
    private final TpsOperations tpsOps;
    private final DvCrud dvCrud;
    private final FileStoreClient fileStoreClient;
    private final SbtTargetTypesFactory sbtTargetTypesFactory;
    private final PixelOperations pixelOperations;
    private final TypesFactory typesFactory;
    private final EnumMapFactory enumMapFactory;
    private final FsIdPipelineProductFilter fsIdPipelineProductFilter;
    private final ConfigMapOperations configMapOperations;
    private final CompressionCrud compressionCrud;
    private final CompressionTableFactory compressionTableFactory;
    private final PdcCrud pdcCrud;

    public SbtDataOperations() {
        this(new MqTimestampSeriesFactory(), new MjdToCadenceFactory(),
            new RollTimeOperations(), new TargetCrud(), new KicCrud(),
            new PixelSetFactory(), new FsIdToTimeSeriesMapFactory(
                FileStoreClientFactory.getInstance()),
            new PersistableTimeSeriesFactory(new DoubleDbTimeSeriesCrud()),
            new SbtBlobSeriesOperations(new BlobOperations(),
                new BlobFileSeriesFactory(), new LogCrud()),
            new CelestialObjectOperations(new ModelMetadataRetrieverLatest(),
                false), new IndexingSchemeConverterToOneBased(),
            new TpsOperations(new CelestialObjectOperations(
                new ModelMetadataRetrieverLatest(), false),
                FileStoreClientFactory.getInstance()), new DvCrud(),
            FileStoreClientFactory.getInstance(), new SbtTargetTypesFactory(),
            new PixelOperations(), new TypesFactory(), new EnumMapFactory(),
            new FsIdPipelineProductFilter(), new ConfigMapOperations(),
            new CompressionCrud(), new CompressionTableFactory(),
            new SbtCadenceRangeDataMerger(), new PdcCrud());
    }

    public SbtDataOperations(MqTimestampSeriesFactory mqTimestampSeriesFactory,
        MjdToCadenceFactory mjdToCadenceFactory,
        RollTimeOperations rollTimeOperations, TargetCrud targetCrud,
        KicCrud kicCrud, PixelSetFactory pixelSetFactory,
        FsIdToTimeSeriesMapFactory fsIdToTimeSeriesMapFactory,
        PersistableTimeSeriesFactory persistableTimeSeriesFactory,
        SbtBlobSeriesOperations sbtBlobSeriesOperations,
        CelestialObjectOperations celestialObjectOperations,
        IndexingSchemeConverter indexingSchemeConverter, TpsOperations tpsOps,
        DvCrud dvCrud, FileStoreClient fileStoreClient,
        SbtTargetTypesFactory sbtTargetTypesFactory,
        PixelOperations pixelOperations, TypesFactory typesFactory,
        EnumMapFactory enumMapFactory,
        FsIdPipelineProductFilter fsIdCsciFilter,
        ConfigMapOperations configMapOperations,
        CompressionCrud compressionCrud,
        CompressionTableFactory compressionTableFactory,
        SbtCadenceRangeDataMerger sbtCadenceRangeDataMerger, PdcCrud pdcCrud) {
        this.mqTimestampSeriesFactory = mqTimestampSeriesFactory;
        this.mjdToCadenceFactory = mjdToCadenceFactory;
        this.rollTimeOperations = rollTimeOperations;
        this.targetCrud = targetCrud;
        this.kicCrud = kicCrud;
        this.pixelSetFactory = pixelSetFactory;
        this.fsIdToTimeSeriesMapFactory = fsIdToTimeSeriesMapFactory;
        this.persistableTimeSeriesFactory = persistableTimeSeriesFactory;
        this.sbtBlobSeriesOperations = sbtBlobSeriesOperations;
        this.celestialObjectOperations = celestialObjectOperations;
        this.indexingSchemeConverter = indexingSchemeConverter;
        this.tpsOps = tpsOps;
        this.dvCrud = dvCrud;
        this.fileStoreClient = fileStoreClient;
        this.sbtTargetTypesFactory = sbtTargetTypesFactory;
        this.pixelOperations = pixelOperations;
        this.typesFactory = typesFactory;
        this.enumMapFactory = enumMapFactory;
        fsIdPipelineProductFilter = fsIdCsciFilter;
        this.configMapOperations = configMapOperations;
        this.compressionCrud = compressionCrud;
        this.compressionTableFactory = compressionTableFactory;
        this.pdcCrud = pdcCrud;
    }

    public SbtData retrieveSbtData(List<Integer> keplerIds,
        CadenceType cadenceType, int startCadence, int endCadence,
        PixelCoordinateSystemConverter pixelCoordinateSystemConverter,
        PipelineProductLists pipelineProductLists) {

        if (cadenceType == null) {
            throw new IllegalArgumentException("cadenceType must not be null.");
        }

        if (startCadence < 0) {
            throw new IllegalArgumentException(
                "startCadence must not be less than 0.\n  startCadence: "
                    + startCadence);
        }

        if (endCadence < startCadence) {
            throw new IllegalArgumentException(
                "endCadence must not be less than startCadence.\n  startCadence: "
                    + startCadence + "\n  endCadence: " + endCadence);
        }

        if (pixelCoordinateSystemConverter == null) {
            throw new IllegalArgumentException(
                "pixelCoordinateSystemConverter must not be null.");
        }

        if (pipelineProductLists == null) {
            throw new IllegalArgumentException(
                "pipelineProductLists must not be null.");
        }

        TicToc.tic("Creating pipelineProducts", 2);
        List<PipelineProduct> pipelineProducts = newArrayList();
        for (PipelineProduct pipelineProduct : typesFactory.getPipelineProducts()) {
            if (pipelineProductLists.included(pipelineProduct)) {
                pipelineProducts.add(pipelineProduct);
            }
        }
        TicToc.toc();

        TicToc.tic("Retrieving mqTimestampSeries");

        TicToc.tic("Calling mjdToCadenceFactory.getInstance()", 2);
        MjdToCadence mjdToCadence = mjdToCadenceFactory.create(cadenceType);
        TicToc.toc();

        TicToc.tic("Calling mqTimestampSeriesFactory.getInstance()", 1);
        MqTimestampSeries mqTimestampSeries = mqTimestampSeriesFactory.create(
            rollTimeOperations, mjdToCadence, startCadence, endCadence);
        TicToc.toc();

        /*
         * This validation of the start/end cadence should occur after the call
         * to mqTimestampSeriesFactory above since that call will cache all of
         * the PixelLogs in the mjdToCadence object. If the validation happens
         * first, we incur unnecessary DB queries
         */
        TicToc.tic("Calling mjdToCadence.hasCadence()", 1);
        if (!mjdToCadence.hasCadence(startCadence)) {
            throw new IllegalArgumentException(
                "startCadence must have a pixelLog.\n  startCadence: "
                    + startCadence);
        }
        TicToc.toc();

        TicToc.tic("Calling mjdToCadence.hasCadence()", 1);
        if (!mjdToCadence.hasCadence(endCadence)) {
            throw new IllegalArgumentException(
                "endCadence must have a pixelLog.\n  endCadence: " + endCadence);
        }
        TicToc.toc();

        TicToc.toc();

        TicToc.tic("Retrieving targetTableLogs");
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.valueOf(cadenceType), startCadence, endCadence);
        TicToc.toc();

        TicToc.tic("Retrieving KIC data");

        TicToc.tic("Calling retrieveKeplerIdToCelestialObjectMap()", 2);
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters = retrieveKeplerIdToCelestialObjectParameters(keplerIds);
        TicToc.toc();

        TicToc.tic("Calling retrieveSkyGroupIds()", 2);
        List<Integer> skyGroupIds = retrieveSkyGroupIds(keplerIdToCelestialObjectParameters);
        TicToc.toc();

        TicToc.toc();

        TicToc.tic("Retrieving TAD data (observedTargets)");
        Map<Pair<Integer, Integer>, ObservedTarget> targetTableIdKeplerIdToObservedTarget = retrieveTargetTableIdKeplerIdToObservedTarget(
            targetTableLogs, keplerIds);
        TicToc.toc();

        TicToc.tic("Retrieving badPixels");
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels = retrieveTargetTableIdSkyGroupIdToBadPixels(
            targetTableLogs, skyGroupIds, mjdToCadence);
        TicToc.toc();

        TicToc.tic("Validating keplerIds", 2);
        for (Integer keplerId : keplerIds) {
            CelestialObjectParameters celestialObjectParameters = keplerIdToCelestialObjectParameters.get(keplerId);
            if (celestialObjectParameters == null) {
                throw new IllegalArgumentException(
                    "keplerIds must exist in the kic or in the customTargetTable.\n  keplerId: "
                        + keplerId);
            }
        }
        TicToc.toc();

        TicToc.tic("Retrieving tps results");
        List<TpsDbResult> latestTpsResults = newArrayList();
        if (pipelineProducts.contains(PipelineProduct.TPS)) {
            TicToc.tic("Calling tpsOps.retrieveSbtResultsWithFileStoreData()", 1);
            latestTpsResults = tpsOps.retrieveSbtResultsWithFileStoreData(keplerIds);
            TicToc.toc();
        }
        TicToc.toc();

        TicToc.tic("Retrieving dv results.");

        TicToc.tic("Creating latestDvTargetResults", 2);
        List<DvTargetResults> latestDvTargetResults = newArrayList();
        if (pipelineProducts.contains(PipelineProduct.DV)) {
            TicToc.tic("Calling dvCrud.retrieveLatestTargetResults", 1);
            latestDvTargetResults = dvCrud.retrieveLatestTargetResults(keplerIds);
            TicToc.toc();
        }
        TicToc.toc();

        TicToc.tic("Creating latestDvPlanetResults", 2);
        List<DvPlanetResults> latestDvPlanetResults = newArrayList();
        if (pipelineProducts.contains(PipelineProduct.DV)) {
            TicToc.tic("Calling dvCrud.retrieveLatestPlanetResults", 1);
            latestDvPlanetResults = dvCrud.retrieveLatestPlanetResults(keplerIds);
            TicToc.toc();
        }
        TicToc.toc();

        TicToc.tic("Creating latestDvLimbDarkeningModels", 2);
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels = newArrayList();
        if (pipelineProducts.contains(PipelineProduct.DV)) {
            TicToc.tic("Calling dvCrud.retrieveLatestLimbDarkeningModels", 1);
            latestDvLimbDarkeningModels = dvCrud.retrieveLatestLimbDarkeningModels(keplerIds);
            TicToc.toc();
        }
        TicToc.toc();

        TicToc.tic("Creating dvPipelineInstanceIds", 2);
        Set<Long> dvPipelineInstanceIds = newLinkedHashSet();
        for (DvPlanetResults dvPlanetResults : latestDvPlanetResults) {
            dvPipelineInstanceIds.add(dvPlanetResults.getPipelineTask()
                .getPipelineInstance()
                .getId());
        }
        TicToc.toc();

        TicToc.tic("Creating singleEventFsIds", 2);
        Set<FsId> singleEventFsIds = newLinkedHashSet();
        if (pipelineProducts.contains(PipelineProduct.DV)) {
            if (!dvPipelineInstanceIds.isEmpty()) {
                for (FluxType fluxType : typesFactory.getFluxTypes()) {
                    TicToc.tic("Calling fileStoreClient.queryIds()", 1);
                    Set<FsId> singleEventFsIdsFluxType = fileStoreClient.queryIds2(DvFsIdFactory.createSingleEventStatisticsQuery(
                        fluxType, dvPipelineInstanceIds,
                        Collections.min(keplerIds), Collections.max(keplerIds)));
                    TicToc.toc();

                    singleEventFsIds.addAll(singleEventFsIdsFluxType);
                }
            }
        }
        TicToc.toc();

        TicToc.toc();

        TicToc.tic("Building FsId list");

        // Since no timeSeries have been retrieved, this call only retrieves
        // fsIds.
        TicToc.tic("Calling retrieveSbtFsIdGroup()", 2);
        SbtFsIdGroup sbtFsIdGroup = retrieveSbtFsIdGroup(true, keplerIds,
            cadenceType, startCadence, endCadence, targetTableLogs,
            skyGroupIds, mjdToCadence, new LinkedHashMap<FsId, TimeSeries>(),
            new LinkedHashMap<FsId, FloatMjdTimeSeries>(),
            targetTableIdKeplerIdToObservedTarget,
            keplerIdToCelestialObjectParameters, latestTpsResults,
            latestDvTargetResults, latestDvPlanetResults,
            latestDvLimbDarkeningModels, singleEventFsIds,
            targetTableIdSkyGroupIdToBadPixels, pipelineProducts);
        TicToc.toc();

        // Filter out fsIds that are not part of included pipelineProducts.
        TicToc.tic("Calling filter()", 2);
        filter(sbtFsIdGroup, pipelineProducts);
        TicToc.toc();

        TicToc.toc();

        // Create fsIdToTimeSeries maps.
        TicToc.tic(
            "Calling fsIdToTimeSeriesMapFactory.getInstance() and getInstanceMjd()",
            2);
        Map<FsId, TimeSeries> fsIdToTimeSeries = fsIdToTimeSeriesMapFactory.createForFsIds(sbtFsIdGroup.getFsIds());
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries = fsIdToTimeSeriesMapFactory.createForMjdFsIds(sbtFsIdGroup.getMjdFsIds());
        TicToc.toc();

        // Since timeSeries have been retrieved, this call returns populated
        // objects.
        TicToc.tic("Retrieving pipeline products from database");
        sbtFsIdGroup = retrieveSbtFsIdGroup(false, keplerIds, cadenceType,
            startCadence, endCadence, targetTableLogs, skyGroupIds,
            mjdToCadence, fsIdToTimeSeries, fsIdToMjdTimeSeries,
            targetTableIdKeplerIdToObservedTarget,
            keplerIdToCelestialObjectParameters, latestTpsResults,
            latestDvTargetResults, latestDvPlanetResults,
            latestDvLimbDarkeningModels, singleEventFsIds,
            targetTableIdSkyGroupIdToBadPixels, pipelineProducts);
        TicToc.toc();

        TicToc.tic("Retrieving pipeline metadata");

        TicToc.tic("Calling retrieveSbtSpacecraftMetadata()", 2);
        SbtSpacecraftMetadata sbtSpacecraftMetadata = retrieveSbtSpacecraftMetadata(mqTimestampSeries);
        TicToc.toc();

        TicToc.tic("Calling new SbtData()", 2);
        SbtData sbtData = new SbtData(cadenceType.toString(), startCadence,
            endCadence, pixelCoordinateSystemConverter.getBaseDescription(),
            EnumList.valueOf(pipelineProducts), mqTimestampSeries,
            sbtFsIdGroup.getSbtAttitudeSolution(),
            sbtFsIdGroup.getPagTimeSeriesList(),
            sbtFsIdGroup.getSbtTargetTables(), sbtFsIdGroup.getSbtTargets(),
            new ArrayList<SbtCsci>(), sbtSpacecraftMetadata,
            new ArrayList<SbtAncillaryData>());
        TicToc.toc();

        TicToc.tic("Calling indexingSchemeConverter.convert()", 2);
        indexingSchemeConverter.convert(sbtData);
        TicToc.toc();

        TicToc.tic("Calling pixelCoordinateSystemConverter.convert()", 2);
        pixelCoordinateSystemConverter.convert(sbtData);
        TicToc.toc();

        TicToc.toc();

        return sbtData;
    }

    private void filter(SbtFsIdGroup sbtFsIdGroup,
        List<PipelineProduct> pipelineProducts) {
        for (FsIdSet fsIdSet : sbtFsIdGroup.getFsIds()) {
            fsIdPipelineProductFilter.filter(fsIdSet.ids(), pipelineProducts);
        }

        for (MjdFsIdSet mjdFsIdSet : sbtFsIdGroup.getMjdFsIds()) {
            fsIdPipelineProductFilter.filter(mjdFsIdSet.ids(), pipelineProducts);
        }
    }

    private SbtFsIdGroup retrieveSbtFsIdGroup(
        boolean retrieveMetadataOnly,
        List<Integer> keplerIds,
        CadenceType cadenceType,
        int startCadence,
        int endCadence,
        List<TargetTableLog> targetTableLogs,
        List<Integer> skyGroupIds,
        MjdToCadence mjdToCadence,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        Map<Pair<Integer, Integer>, ObservedTarget> targetTableIdKeplerIdToObservedTarget,
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters,
        List<TpsDbResult> latestTpsResults,
        List<DvTargetResults> latestDvTargetResults,
        List<DvPlanetResults> latestDvPlanetResults,
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels,
        Set<FsId> singleEventFsIds,
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels,
        List<PipelineProduct> pipelineProducts) {

        List<FsIdSet> fsIdSets = newArrayList();
        List<MjdFsIdSet> mjdFsIdSets = newArrayList();
        Set<FsId> fsIds = newLinkedHashSet();

        SbtAttitudeSolution sbtAttitudeSolution = new SbtAttitudeSolution();
        if (pipelineProducts.contains(PipelineProduct.PPA)) {
            sbtAttitudeSolution = retrieveSbtAttitudeSolution(
                retrieveMetadataOnly, cadenceType, startCadence, endCadence,
                fsIdSets, mjdFsIdSets, fsIdToTimeSeries, fsIdToMjdTimeSeries,
                fsIds);
        }

        List<SbtSimpleTimeSeries> sbtPagTimeSeriesList = newArrayList();
        for (TimeSeriesType valuesType : typesFactory.getPagTimeSeriesTypes()) {
            FsId pagValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(valuesType);
            fsIds.add(pagValuesFsId);
            SimpleFloatTimeSeries pagTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                pagValuesFsId, fsIdToTimeSeries);
            sbtPagTimeSeriesList.add(new SbtSimpleTimeSeries(
                valuesType.toString(), pagTimeSeries));
        }

        List<SbtTargetTable> sbtTargetTables = retrieveSbtTargetTables(
            retrieveMetadataOnly, keplerIds, mjdToCadence, startCadence,
            endCadence, targetTableLogs, skyGroupIds, fsIdSets, mjdFsIdSets,
            fsIdToTimeSeries, fsIdToMjdTimeSeries, pipelineProducts);

        List<SbtTarget> sbtTargets = retrieveSbtTargets(keplerIds, cadenceType,
            startCadence, endCadence, targetTableLogs, mjdToCadence, fsIdSets,
            mjdFsIdSets, keplerIdToCelestialObjectParameters, fsIdToTimeSeries,
            fsIdToMjdTimeSeries, targetTableIdKeplerIdToObservedTarget,
            latestTpsResults, latestDvTargetResults, latestDvPlanetResults,
            latestDvLimbDarkeningModels, singleEventFsIds,
            targetTableIdSkyGroupIdToBadPixels);

        fsIdSets.add(new FsIdSet(startCadence, endCadence, fsIds));

        return new SbtFsIdGroup(fsIdSets, mjdFsIdSets, sbtAttitudeSolution,
            sbtPagTimeSeriesList, sbtTargetTables, sbtTargets);
    }

    private SbtSpacecraftMetadata retrieveSbtSpacecraftMetadata(
        MqTimestampSeries mqTimestampSeries) {
        List<ConfigMap> configMaps = configMapOperations.retrieveConfigMapsUsingPixelLog(
            mqTimestampSeries.startMjd(), mqTimestampSeries.endMjd());

        List<RequantTable> requantTables = newArrayList();
        for (gov.nasa.kepler.hibernate.gar.RequantTable requantTableFromDatabase : compressionCrud.retrieveRequantTables(
            mqTimestampSeries.startMjd(), mqTimestampSeries.endMjd())) {
            Pair<Double, Double> startEndTimes = compressionCrud.retrieveStartEndTimes(requantTableFromDatabase.getExternalId());
            requantTables.add(compressionTableFactory.create(
                requantTableFromDatabase, startEndTimes.left));
        }

        List<HuffmanTable> huffmanTables = newArrayList();
        for (gov.nasa.kepler.hibernate.gar.HuffmanTable huffmanTableFromDatabase : compressionCrud.retrieveHuffmanTables(
            mqTimestampSeries.startMjd(), mqTimestampSeries.endMjd())) {
            Pair<Double, Double> startEndTimes = compressionCrud.retrieveStartEndTimes(huffmanTableFromDatabase.getExternalId());
            huffmanTables.add(compressionTableFactory.create(
                huffmanTableFromDatabase, startEndTimes.left));
        }

        return new SbtSpacecraftMetadata(configMaps, requantTables,
            huffmanTables);
    }

    private SbtAttitudeSolution retrieveSbtAttitudeSolution(
        boolean retrieveMetadataOnly, CadenceType cadenceType,
        int startCadence, int endCadence, List<FsIdSet> fsIdSets,
        List<MjdFsIdSet> mjdFsIdSets, Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries, Set<FsId> fsIds) {
        SbtAttitudeSolution sbtAttitudeSolution = new SbtAttitudeSolution();
        if (cadenceType.equals(CadenceType.LONG)) {
            List<SbtSimpleDoubleTimeSeries> sbtAttitudeSolutionDoubleTimeSeriesList = newArrayList();
            for (DoubleTimeSeriesType type : typesFactory.getAttitudeSolutionDoubleTypes()) {
                SimpleDoubleTimeSeries timeSeries = new SimpleDoubleTimeSeries();
                if (!retrieveMetadataOnly) {
                    TicToc.tic(
                        "Calling persistableTimeSeriesFactory.getSimpleDoubleTimeSeries() for type "
                            + type, 1);
                    timeSeries = persistableTimeSeriesFactory.getSimpleDoubleTimeSeriesFromDatabase(
                        type, startCadence, endCadence);
                    TicToc.toc();
                }
                sbtAttitudeSolutionDoubleTimeSeriesList.add(new SbtSimpleDoubleTimeSeries(
                    type.toString(), timeSeries));
            }

            List<SbtSimpleTimeSeries> sbtAttitudeSolutionFloatTimeSeriesList = newArrayList();
            for (TimeSeriesType type : typesFactory.getAttitudeSolutionFloatTypes()) {
                FsId valuesFsId = PpaFsIdFactory.getTimeSeriesFsId(type);
                fsIds.add(valuesFsId);
                SimpleFloatTimeSeries timeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                    valuesFsId, fsIdToTimeSeries);
                sbtAttitudeSolutionFloatTimeSeriesList.add(new SbtSimpleTimeSeries(
                    type.toString(), timeSeries));
            }

            sbtAttitudeSolution = new SbtAttitudeSolution(
                sbtAttitudeSolutionDoubleTimeSeriesList,
                sbtAttitudeSolutionFloatTimeSeriesList);
        }

        return sbtAttitudeSolution;
    }

    private List<SbtTargetTable> retrieveSbtTargetTables(
        boolean retrieveMetadataOnly, List<Integer> keplerIds,
        MjdToCadence mjdToCadence, int startCadence, int endCadence,
        List<TargetTableLog> targetTableLogs, List<Integer> skyGroupIds,
        List<FsIdSet> fsIdSets, List<MjdFsIdSet> mjdFsIdSets,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        List<PipelineProduct> pipelineProducts) {
        List<SbtTargetTable> sbtTargetTables = newArrayList();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            int targetTableId = targetTableLog.getTargetTable()
                .getExternalId();

            int quarter = retrieveQuarter(targetTableLog, mjdToCadence);

            List<SbtModOut> sbtModOuts = retrieveSbtModOuts(
                retrieveMetadataOnly, targetTableLog, keplerIds, mjdToCadence,
                skyGroupIds, startCadence, endCadence, fsIdSets, mjdFsIdSets,
                fsIdToTimeSeries, fsIdToMjdTimeSeries, pipelineProducts);

            Pair<Integer, Integer> targetTableCadenceRange = getCadenceRange(
                targetTableLog, startCadence, endCadence);
            int startCadenceTargetTable = targetTableCadenceRange.left;
            int endCadenceTargetTable = targetTableCadenceRange.right;

            TicToc.tic("Calling mjdToCadence.cachedCadenceTimes()", 1);
            TimestampSeries cadenceTimes = mjdToCadence.cachedCadenceTimes(
                startCadenceTargetTable, endCadenceTargetTable);
            TicToc.toc();

            sbtTargetTables.add(new SbtTargetTable(targetTableId, quarter,
                startCadenceTargetTable, endCadenceTargetTable, cadenceTimes,
                sbtModOuts));
        }

        return sbtTargetTables;
    }

    private int retrieveQuarter(TargetTableLog targetTableLog,
        MjdToCadence mjdToCadence) {
        TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
        double targetTableMjd = mjdToCadence.cadenceToMjd(targetTableLog.getCadenceStart());
        TicToc.toc();

        TicToc.tic("Calling rollTimeOperations.mjdToQuarter()", 1);
        int quarter = rollTimeOperations.mjdToQuarter(new double[] { targetTableMjd })[0];
        TicToc.toc();

        return quarter;
    }

    private List<SbtModOut> retrieveSbtModOuts(boolean retrieveMetadataOnly,
        TargetTableLog targetTableLog, List<Integer> keplerIds,
        MjdToCadence mjdToCadence, List<Integer> skyGroupIds, int startCadence,
        int endCadence, List<FsIdSet> fsIdSets, List<MjdFsIdSet> mjdFsIdSets,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        List<PipelineProduct> pipelineProducts) {
        Pair<Integer, Integer> targetTableCadenceRange = getCadenceRange(
            targetTableLog, startCadence, endCadence);
        int startCadenceTargetTable = targetTableCadenceRange.left;
        int endCadenceTargetTable = targetTableCadenceRange.right;

        Set<FsId> fsIdsTargetTable = newLinkedHashSet();
        Set<FsId> mjdFsIdsTargetTable = newLinkedHashSet();

        List<SbtModOut> sbtModOuts = newArrayList();
        for (Integer skyGroupId : skyGroupIds) {
            Pair<Integer, Integer> modOut = retrieveModOut(skyGroupId,
                targetTableLog, mjdToCadence);
            int ccdModule = modOut.left;
            int ccdOutput = modOut.right;

            TicToc.tic("Calling mjdToCadence.cadenceType()", 1);
            CadenceType cadenceType = mjdToCadence.cadenceType();
            TicToc.toc();

            List<SbtBlobSeries> blobGroups = newArrayList();
            if (cadenceType.equals(CadenceType.LONG)) {
                for (PipelineProduct pipelineProduct : pipelineProducts) {
                    BlobSeriesType blobSeriesType = pipelineProduct.getBlobSeriesType();
                    if (blobSeriesType != null) {
                        SbtBlobSeries sbtBlobSeries = new SbtBlobSeries();
                        if (!retrieveMetadataOnly) {
                            TicToc.tic(
                                "Calling sbtBlobSeriesOperations.retrieveSbtBlobSeries() for type "
                                    + blobSeriesType, 1);
                            sbtBlobSeries = sbtBlobSeriesOperations.retrieveSbtBlobSeries(
                                blobSeriesType, ccdModule, ccdOutput,
                                cadenceType, startCadenceTargetTable,
                                endCadenceTargetTable);
                            TicToc.toc();
                        }
                        blobGroups.add(sbtBlobSeries);
                    }
                }
            }

            FsId argabrighteningFsId = PaFsIdFactory.getArgabrighteningFsId(
                cadenceType, targetTableLog.getTargetTable()
                    .getExternalId(), ccdModule, ccdOutput);
            fsIdsTargetTable.add(argabrighteningFsId);
            SimpleIntTimeSeries argabrighteningTimeSeries = persistableTimeSeriesFactory.getSimpleIntTimeSeries(
                argabrighteningFsId, fsIdToTimeSeries);
            int[] argabrighteningIndices = getIndices(argabrighteningTimeSeries);

            List<SbtCalCompressionTimeSeries> sbtCalCompressionMetricTimeSeriesList = newArrayList();
            for (Entry<MetricsTimeSeriesType, MetricsTimeSeriesType> enumPair : enumMapFactory.create(
                typesFactory.getCalMetricsTimeSeriesTypes(),
                EnumPairType.COUNTS)
                .entrySet()) {
                MetricsTimeSeriesType valuesType = enumPair.getKey();
                FsId valuesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
                    cadenceType, valuesType, ccdModule, ccdOutput);
                MetricsTimeSeriesType countsType = enumPair.getValue();
                FsId countsFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
                    cadenceType, countsType, ccdModule, ccdOutput);
                fsIdsTargetTable.add(valuesFsId);
                fsIdsTargetTable.add(countsFsId);
                CalCompressionTimeSeries timeSeries = persistableTimeSeriesFactory.getCalCompressionTimeSeries(
                    valuesFsId, countsFsId, fsIdToTimeSeries);
                sbtCalCompressionMetricTimeSeriesList.add(new SbtCalCompressionTimeSeries(
                    valuesType.toString(), timeSeries));
            }

            List<SbtCompoundTimeSeries> sbtCalMetricTimeSeriesList = newArrayList();
            for (Entry<MetricsTimeSeriesType, MetricsTimeSeriesType> enumPair : enumMapFactory.create(
                typesFactory.getCalMetricsTimeSeriesTypes(),
                EnumPairType.UNCERTAINTIES)
                .entrySet()) {
                MetricsTimeSeriesType valuesType = enumPair.getKey();
                FsId calMetricValuesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
                    cadenceType, valuesType, ccdModule, ccdOutput);
                MetricsTimeSeriesType uncertaintiesType = enumPair.getValue();
                FsId calMetricUncertaintiesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
                    cadenceType, uncertaintiesType, ccdModule, ccdOutput);
                fsIdsTargetTable.add(calMetricValuesFsId);
                fsIdsTargetTable.add(calMetricUncertaintiesFsId);
                CompoundFloatTimeSeries calMetricTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                    calMetricValuesFsId, calMetricUncertaintiesFsId,
                    fsIdToTimeSeries);
                sbtCalMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
                    valuesType.toString(), calMetricTimeSeries));
            }

            List<SbtSimpleTimeSeriesList> sbtCalCosmicRayMetricGroups = newArrayList();
            for (CollateralType collateralType : typesFactory.getCollateralTypes()) {
                List<SbtSimpleTimeSeries> sbtCalCosmicRayMetricTimeSeriesList = newArrayList();
                for (gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType metricType : typesFactory.getCalCosmicRayMetricsTypes()) {
                    FsId calCosmicRayMetricValuesFsId = CalFsIdFactory.getCosmicRayMetricFsId(
                        cadenceType, collateralType, metricType, ccdModule,
                        ccdOutput);
                    fsIdsTargetTable.add(calCosmicRayMetricValuesFsId);
                    SimpleFloatTimeSeries calCosmicRayMetricTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        calCosmicRayMetricValuesFsId, fsIdToTimeSeries);
                    sbtCalCosmicRayMetricTimeSeriesList.add(new SbtSimpleTimeSeries(
                        metricType.toString(), calCosmicRayMetricTimeSeries));
                }
                sbtCalCosmicRayMetricGroups.add(new SbtSimpleTimeSeriesList(
                    collateralType.toString(),
                    sbtCalCosmicRayMetricTimeSeriesList));
            }

            List<SbtCompoundTimeSeries> sbtPaMetricTimeSeriesList = newArrayList();
            for (Entry<MetricTimeSeriesType, MetricTimeSeriesType> enumPair : enumMapFactory.create(
                typesFactory.getPaMetricTypes(), EnumPairType.UNCERTAINTIES)
                .entrySet()) {
                MetricTimeSeriesType valuesType = enumPair.getKey();
                FsId paMetricValuesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                    valuesType, ccdModule, ccdOutput);
                MetricTimeSeriesType uncertaintiesType = enumPair.getValue();
                FsId paMetricUncertaintiesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
                    uncertaintiesType, ccdModule, ccdOutput);
                fsIdsTargetTable.add(paMetricValuesFsId);
                fsIdsTargetTable.add(paMetricUncertaintiesFsId);
                CompoundFloatTimeSeries paMetricTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                    paMetricValuesFsId, paMetricUncertaintiesFsId,
                    fsIdToTimeSeries);
                sbtPaMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
                    valuesType.toString(), paMetricTimeSeries));
            }

            List<SbtSimpleTimeSeriesList> sbtPaCosmicRayMetricGroups = newArrayList();
            for (TargetType targetType : sbtTargetTypesFactory.create(cadenceType)) {
                List<SbtSimpleTimeSeries> sbtPaCosmicRayMetricTimeSeriesList = newArrayList();
                for (CosmicRayMetricType metricType : typesFactory.getPaCosmicRayMetricTypes()) {
                    FsId paCosmicRayMetricValuesFsId = PaFsIdFactory.getCosmicRayMetricFsId(
                        metricType, targetType, ccdModule, ccdOutput);
                    fsIdsTargetTable.add(paCosmicRayMetricValuesFsId);
                    SimpleFloatTimeSeries paCosmicRayMetricTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        paCosmicRayMetricValuesFsId, fsIdToTimeSeries);
                    sbtPaCosmicRayMetricTimeSeriesList.add(new SbtSimpleTimeSeries(
                        metricType.toString(), paCosmicRayMetricTimeSeries));
                }
                sbtPaCosmicRayMetricGroups.add(new SbtSimpleTimeSeriesList(
                    targetType.toString(), sbtPaCosmicRayMetricTimeSeriesList));
            }

            List<SbtCompoundTimeSeries> sbtPmdTimeSeriesList = newArrayList();
            for (Entry<TimeSeriesType, TimeSeriesType> enumPair : enumMapFactory.create(
                typesFactory.getPmdTimeSeriesTypes(),
                EnumPairType.UNCERTAINTIES)
                .entrySet()) {
                TimeSeriesType valuesType = enumPair.getKey();
                FsId pmdValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(
                    valuesType, ccdModule, ccdOutput);
                TimeSeriesType uncertaintiesType = enumPair.getValue();
                FsId pmdUncertaintiesFsId = PpaFsIdFactory.getTimeSeriesFsId(
                    uncertaintiesType, ccdModule, ccdOutput);
                fsIdsTargetTable.add(pmdValuesFsId);
                fsIdsTargetTable.add(pmdUncertaintiesFsId);
                CompoundFloatTimeSeries pmdTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                    pmdValuesFsId, pmdUncertaintiesFsId, fsIdToTimeSeries);
                sbtPmdTimeSeriesList.add(new SbtCompoundTimeSeries(
                    valuesType.toString(), pmdTimeSeries));
            }

            List<SbtCompoundTimeSeriesListList> sbtPmdCdppTimeSeriesLists = newArrayList();
            for (Entry<TimeSeriesType, TimeSeriesType> enumPair : enumMapFactory.create(
                typesFactory.getPmdCdppTimeSeriesTypes(),
                EnumPairType.UNCERTAINTIES)
                .entrySet()) {
                TimeSeriesType valuesType = enumPair.getKey();
                TimeSeriesType uncertaintiesType = enumPair.getValue();
                List<SbtCompoundTimeSeriesList> sbtCdppMagnitudeList = newArrayList();
                for (CdppMagnitude cdppMagnitude : typesFactory.getCdppMagnitudes()) {
                    List<SbtCompoundTimeSeries> sbtCdppDurationList = newArrayList();
                    for (CdppDuration cdppDuration : typesFactory.getCdppDurations()) {
                        FsId pmdValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(
                            valuesType, ccdModule, ccdOutput,
                            cdppMagnitude.getValue(), cdppDuration.getValue());
                        FsId pmdUncertaintiesFsId = PpaFsIdFactory.getTimeSeriesFsId(
                            uncertaintiesType, ccdModule, ccdOutput,
                            cdppMagnitude.getValue(), cdppDuration.getValue());
                        fsIdsTargetTable.add(pmdValuesFsId);
                        fsIdsTargetTable.add(pmdUncertaintiesFsId);
                        CompoundFloatTimeSeries pmdTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                            pmdValuesFsId, pmdUncertaintiesFsId,
                            fsIdToTimeSeries);
                        sbtCdppDurationList.add(new SbtCompoundTimeSeries(
                            cdppDuration.toString(), pmdTimeSeries));
                    }
                    sbtCdppMagnitudeList.add(new SbtCompoundTimeSeriesList(
                        cdppMagnitude.toString(), sbtCdppDurationList));
                }
                sbtPmdCdppTimeSeriesLists.add(new SbtCompoundTimeSeriesListList(
                    valuesType.toString(), sbtCdppMagnitudeList));
            }

            sbtModOuts.add(new SbtModOut(ccdModule, ccdOutput, blobGroups,
                argabrighteningIndices, sbtCalCompressionMetricTimeSeriesList,
                sbtCalMetricTimeSeriesList, sbtCalCosmicRayMetricGroups,
                sbtPaMetricTimeSeriesList, sbtPaCosmicRayMetricGroups,
                sbtPmdTimeSeriesList, sbtPmdCdppTimeSeriesLists));
        }

        fsIdSets.add(new FsIdSet(startCadenceTargetTable,
            endCadenceTargetTable, fsIdsTargetTable));

        TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
        mjdFsIdSets.add(new MjdFsIdSet(
            mjdToCadence.cadenceToMjd(startCadenceTargetTable),
            mjdToCadence.cadenceToMjd(endCadenceTargetTable),
            mjdFsIdsTargetTable));
        TicToc.toc();

        return sbtModOuts;
    }

    private int[] getIndices(SimpleIntTimeSeries timeSeries) {
        int[] intArray = ArrayUtils.EMPTY_INT_ARRAY;
        if (timeSeries != null) {
            boolean[] gapIndicators = timeSeries.getGapIndicators();

            List<Integer> list = newArrayList();
            for (int i = 0; i < gapIndicators.length; i++) {
                if (gapIndicators[i] == false) {
                    list.add(i);
                }
            }

            intArray = toArray(list);
        }

        return intArray;
    }

    private Pair<Integer, Integer> retrieveModOut(Integer skyGroupId,
        TargetTableLog targetTableLog, MjdToCadence mjdToCadence) {
        int targetTableStartCadence = targetTableLog.getCadenceStart();

        TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
        double targetTableMjd = mjdToCadence.cadenceToMjd(targetTableStartCadence);
        TicToc.toc();

        TicToc.tic("Calling rollTimeOperations.mjdToSeason()", 1);
        int season = rollTimeOperations.mjdToSeason(targetTableMjd);
        TicToc.toc();

        TicToc.tic("Calling kicCrud.retrieveSkyGroup()", 1);
        SkyGroup skyGroup = kicCrud.retrieveSkyGroup(skyGroupId, season);
        TicToc.toc();

        Pair<Integer, Integer> modOut = Pair.of(skyGroup.getCcdModule(),
            skyGroup.getCcdOutput());

        return modOut;
    }

    private List<Integer> retrieveSkyGroupIds(
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters) {
        List<Integer> skyGroupIds = newArrayList();
        for (Entry<Integer, CelestialObjectParameters> entry : keplerIdToCelestialObjectParameters.entrySet()) {
            int skyGroupId = entry.getValue()
                .getSkyGroupId();
            if (skyGroupId < 1) {
                throw new IllegalArgumentException(
                    "keplerIds must be on the field of view (FOV).\n  keplerId: "
                        + entry.getKey() + "\n  skyGroupId: " + skyGroupId);
            }

            if (!skyGroupIds.contains(skyGroupId)) {
                skyGroupIds.add(skyGroupId);
            }
        }

        Collections.sort(skyGroupIds);
        return skyGroupIds;
    }

    private Map<Integer, CelestialObjectParameters> retrieveKeplerIdToCelestialObjectParameters(
        List<Integer> keplerIds) {
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters = newLinkedHashMap();

        TicToc.tic(
            "Calling celestialObjectOperations.retrieveCelestialObjectParameters()",
            1);
        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectOperations.retrieveCelestialObjectParameters(keplerIds);
        TicToc.toc();

        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            if (celestialObjectParameters != null) {
                keplerIdToCelestialObjectParameters.put(
                    celestialObjectParameters.getKeplerId(),
                    celestialObjectParameters);
            }
        }

        return keplerIdToCelestialObjectParameters;
    }

    private Map<Pair<Integer, Integer>, ObservedTarget> retrieveTargetTableIdKeplerIdToObservedTarget(
        List<TargetTableLog> targetTableLogs, List<Integer> keplerIds) {
        Map<Pair<Integer, Integer>, ObservedTarget> targetTableIdKeplerIdToObservedTarget = newLinkedHashMap();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            TargetTable targetTable = targetTableLog.getTargetTable();

            TicToc.tic("Calling targetCrud.retrieveObservedTargets()", 1);
            List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
                targetTable, keplerIds);
            TicToc.toc();

            for (ObservedTarget observedTarget : observedTargets) {
                if (observedTarget != null) {
                    targetTableIdKeplerIdToObservedTarget.put(
                        Pair.of(targetTable.getExternalId(),
                            observedTarget.getKeplerId()), observedTarget);
                }
            }
        }

        return targetTableIdKeplerIdToObservedTarget;
    }

    private Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> retrieveTargetTableIdSkyGroupIdToBadPixels(
        List<TargetTableLog> targetTableLogs, List<Integer> skyGroupIds,
        MjdToCadence mjdToCadence) {
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels = newLinkedHashMap();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            for (int skyGroupId : skyGroupIds) {
                Pair<Integer, Integer> modOut = retrieveModOut(skyGroupId,
                    targetTableLog, mjdToCadence);
                int ccdModule = modOut.left;
                int ccdOutput = modOut.right;

                TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
                double startMjd = mjdToCadence.cadenceToMjd(targetTableLog.getCadenceStart());
                TicToc.toc();

                TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
                double endMjd = mjdToCadence.cadenceToMjd(targetTableLog.getCadenceEnd());
                TicToc.toc();

                TicToc.tic("Calling pixelOperations.retrievePixelRange()", 1);
                gov.nasa.kepler.hibernate.fc.Pixel[] pixels = pixelOperations.retrievePixelRange(
                    ccdModule, ccdOutput, startMjd, endMjd);
                TicToc.toc();

                int externalId = targetTableLog.getTargetTable()
                    .getExternalId();
                targetTableIdSkyGroupIdToBadPixels.put(
                    Pair.of(externalId, skyGroupId), Arrays.asList(pixels));
            }
        }

        return targetTableIdSkyGroupIdToBadPixels;
    }

    private List<SbtTarget> retrieveSbtTargets(
        List<Integer> keplerIds,
        CadenceType cadenceType,
        int startCadence,
        int endCadence,
        List<TargetTableLog> targetTableLogs,
        MjdToCadence mjdToCadence,
        List<FsIdSet> fsIdSets,
        List<MjdFsIdSet> mjdFsIdSets,
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        Map<Pair<Integer, Integer>, ObservedTarget> targetTableIdKeplerIdToObservedTarget,
        List<TpsDbResult> latestTpsResults,
        List<DvTargetResults> latestDvTargetResults,
        List<DvPlanetResults> latestDvPlanetResults,
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels,
        Set<FsId> singleEventFsIds,
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels) {
        Set<FsId> fsIdsMultiQuarter = newLinkedHashSet();
        Set<FsId> mjdFsIdsMultiQuarter = newLinkedHashSet();
        List<SbtTarget> sbtTargets = newArrayList();
        for (Integer keplerId : keplerIds) {
            CelestialObjectParameters celestialObjectParameters = keplerIdToCelestialObjectParameters.get(keplerId);

            FsId barycentricTimeOffsetsFsId = PaFsIdFactory.getBarcentricTimeOffsetFsId(
                cadenceType, keplerId);
            fsIdsMultiQuarter.add(barycentricTimeOffsetsFsId);
            SimpleFloatTimeSeries barycentricTimeOffsetsTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                barycentricTimeOffsetsFsId, fsIdToTimeSeries);

            List<SbtFluxGroup> sbtFluxGroups = retrieveSbtFluxGroups(
                cadenceType, startCadence, endCadence, fsIdToTimeSeries,
                fsIdToMjdTimeSeries, fsIdsMultiQuarter, mjdFsIdsMultiQuarter,
                keplerId, mjdToCadence, latestTpsResults,
                latestDvTargetResults, latestDvPlanetResults,
                latestDvLimbDarkeningModels, singleEventFsIds);

            List<SbtAperture> apertures = retrieveSbtApertures(cadenceType,
                startCadence, endCadence, targetTableLogs,
                keplerIdToCelestialObjectParameters, mjdToCadence,
                fsIdToTimeSeries, fsIdToMjdTimeSeries,
                targetTableIdKeplerIdToObservedTarget, fsIdSets, mjdFsIdSets,
                keplerId, targetTableIdSkyGroupIdToBadPixels,
                latestDvPlanetResults, latestDvLimbDarkeningModels);

            sbtTargets.add(new SbtTarget(keplerId, celestialObjectParameters,
                barycentricTimeOffsetsTimeSeries, sbtFluxGroups, apertures));
        }

        fsIdSets.add(new FsIdSet(startCadence, endCadence, fsIdsMultiQuarter));

        TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
        mjdFsIdSets.add(new MjdFsIdSet(mjdToCadence.cadenceToMjd(startCadence),
            mjdToCadence.cadenceToMjd(endCadence), mjdFsIdsMultiQuarter));
        TicToc.toc();

        return sbtTargets;
    }

    private List<SbtFluxGroup> retrieveSbtFluxGroups(CadenceType cadenceType,
        int startCadence, int endCadence,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        Set<FsId> fsIdsMultiQuarter, Set<FsId> mjdFsIdsMultiQuarter,
        Integer keplerId, MjdToCadence mjdToCadence,
        List<TpsDbResult> latestTpsResults,
        List<DvTargetResults> latestDvTargetResults,
        List<DvPlanetResults> latestDvPlanetResults,
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels,
        Set<FsId> singleEventFsIds) {
        List<SbtFluxGroup> sbtFluxGroups = newArrayList();
        for (FluxType fluxType : typesFactory.getFluxTypes()) {
            FsId discontinuityFsId = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                fluxType, cadenceType, keplerId);
            fsIdsMultiQuarter.add(discontinuityFsId);
            SimpleIntTimeSeries discontinuityTimeSeries = persistableTimeSeriesFactory.getSimpleIntTimeSeries(
                discontinuityFsId, fsIdToTimeSeries);
            int[] discontinuityIndices = getIndices(discontinuityTimeSeries);

            List<SbtPdcProcessingCharacteristics> pdcProcessingCharacteristics = retrievePdcProcessingCharacteristics(
                fluxType, cadenceType, keplerId, startCadence, endCadence);

            FsId rawFluxValuesFsId = PaFsIdFactory.getTimeSeriesFsId(
                PaFsIdFactory.TimeSeriesType.RAW_FLUX, fluxType,
                cadenceType, keplerId);
            FsId rawFluxUncertaintiesFsId = PaFsIdFactory.getTimeSeriesFsId(
                PaFsIdFactory.TimeSeriesType.RAW_FLUX_UNCERTAINTIES,
                fluxType, cadenceType, keplerId);
            fsIdsMultiQuarter.add(rawFluxValuesFsId);
            fsIdsMultiQuarter.add(rawFluxUncertaintiesFsId);
            CompoundFloatTimeSeries rawFluxTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                rawFluxValuesFsId, rawFluxUncertaintiesFsId, fsIdToTimeSeries);

            List<SbtCorrectedFluxAndOutliersTimeSeries> sbtCorrectedFluxTimeSeriesList = newArrayList();
            for (CorrectedFluxType correctedFluxType : typesFactory.getCorrectedFluxTypes()) {
                Map<PdcFluxTimeSeriesType, PdcFluxTimeSeriesType> pdcFluxTypeMap = enumMapFactory.create(
                    typesFactory.getPdcFluxTimeSeriesTypes(),
                    EnumPairType.UNCERTAINTIES);
                PdcFluxTimeSeriesType pdcFluxTimeSeriesType = correctedFluxType.getPdcFluxTimeSeriesType();
                PdcFluxTimeSeriesType pdcFluxTimeSeriesTypeUncertainties = pdcFluxTypeMap.get(pdcFluxTimeSeriesType);
                PdcFilledIndicesTimeSeriesType pdcFilledIndicesTimeSeriesType = correctedFluxType.getPdcFilledIndicesTimeSeriesType();
                FsId correctedFluxValuesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                    pdcFluxTimeSeriesType, fluxType, cadenceType, keplerId);
                FsId correctedFluxUncertaintiesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                    pdcFluxTimeSeriesTypeUncertainties, fluxType, cadenceType,
                    keplerId);
                FsId correctedFluxFilledIndicesFsId = PdcFsIdFactory.getFilledIndicesFsId(
                    pdcFilledIndicesTimeSeriesType, fluxType, cadenceType,
                    keplerId);
                fsIdsMultiQuarter.add(correctedFluxValuesFsId);
                fsIdsMultiQuarter.add(correctedFluxUncertaintiesFsId);
                fsIdsMultiQuarter.add(correctedFluxFilledIndicesFsId);
                CorrectedFluxTimeSeries correctedFluxTimeSeries = persistableTimeSeriesFactory.getCorrectedFluxTimeSeries(
                    correctedFluxValuesFsId, correctedFluxUncertaintiesFsId,
                    correctedFluxFilledIndicesFsId, fsIdToTimeSeries);

                Map<PdcOutliersTimeSeriesType, PdcOutliersTimeSeriesType> pdcOutliersTypeMap = enumMapFactory.create(
                    typesFactory.getPdcOutliersTimeSeriesTypes(),
                    EnumPairType.UNCERTAINTIES);
                PdcOutliersTimeSeriesType pdcOutliersTimeSeriesType = correctedFluxType.getPdcOutliersTimeSeriesType();
                PdcOutliersTimeSeriesType pdcOutliersTimeSeriesTypeUncertainties = pdcOutliersTypeMap.get(pdcOutliersTimeSeriesType);
                FsId outliersValuesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
                    pdcOutliersTimeSeriesType, fluxType, cadenceType, keplerId);
                FsId outliersUncertaintiesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
                    pdcOutliersTimeSeriesTypeUncertainties, fluxType,
                    cadenceType, keplerId);
                mjdFsIdsMultiQuarter.add(outliersValuesFsId);
                mjdFsIdsMultiQuarter.add(outliersUncertaintiesFsId);
                CompoundIndicesTimeSeries outliers = persistableTimeSeriesFactory.getCompoundIndicesTimeSeries(
                    outliersValuesFsId, outliersUncertaintiesFsId,
                    fsIdToMjdTimeSeries, mjdToCadence, startCadence, endCadence);

                sbtCorrectedFluxTimeSeriesList.add(new SbtCorrectedFluxAndOutliersTimeSeries(
                    correctedFluxType.toString(), correctedFluxTimeSeries,
                    outliers));
            }

            List<SbtCentroidTimeSeries> centroidGroups = newArrayList();
            for (CentroidType centroidType : typesFactory.getCentroidTypes()) {
                FsId centroidRowFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                    fluxType, centroidType,
                    CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId);
                FsId centroidRowUncertaintiesFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                    fluxType, centroidType,
                    CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES,
                    cadenceType, keplerId);
                FsId centroidColFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                    fluxType, centroidType,
                    CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId);
                FsId centroidColUncertaintiesFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                    fluxType, centroidType,
                    CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES,
                    cadenceType, keplerId);
                fsIdsMultiQuarter.add(centroidRowFsId);
                fsIdsMultiQuarter.add(centroidRowUncertaintiesFsId);
                fsIdsMultiQuarter.add(centroidColFsId);
                fsIdsMultiQuarter.add(centroidColUncertaintiesFsId);
                CentroidTimeSeries centroids = persistableTimeSeriesFactory.getCentroidTimeSeries(
                    centroidRowFsId, centroidRowUncertaintiesFsId,
                    centroidColFsId, centroidColUncertaintiesFsId,
                    fsIdToTimeSeries);
                centroidGroups.add(new SbtCentroidTimeSeries(
                    centroidType.toString(), centroids));
            }

            List<SbtTpsResult> sbtTpsResults = newArrayList();
            for (TpsDbResult tpsDbResult : latestTpsResults) {
                if (tpsDbResult.getKeplerId() == keplerId) {
                    float trialTransitPulseInHours = tpsDbResult.getTrialTransitPulseInHours();

                    FsId cdppFsId = TpsFsIdFactory.getCdppId(tpsDbResult.getOriginator().getPipelineInstance().getId(), keplerId,
                        trialTransitPulseInHours, TpsType.TPS_FULL, fluxType);
                    fsIdsMultiQuarter.add(cdppFsId);
                    SimpleFloatTimeSeries cdppTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        cdppFsId, fsIdToTimeSeries);

                    double detectedOrbitalPeriodInDays = tpsDbResult.getDetectedOrbitalPeriodInDays() == null ? 0.0
                        : tpsDbResult.getDetectedOrbitalPeriodInDays();
                    boolean isPlanetACandidate = tpsDbResult.isPlanetACandidate() == null ? false
                        : tpsDbResult.isPlanetACandidate();
                    float maxSingleEventStatistic = tpsDbResult.getMaxSingleEventStatistic() == null ? 0.0F
                        : tpsDbResult.getMaxSingleEventStatistic();
                    float maxMultipleEventStatistic = tpsDbResult.getMaxMultipleEventStatistic() == null ? 0.0F
                        : tpsDbResult.getMaxMultipleEventStatistic();
                    float timeToFirstTransitInDays = tpsDbResult.getTimeToFirstTransitInDays() == null ? 0.0F
                        : tpsDbResult.getTimeToFirstTransitInDays();
                    float rmsCdpp = tpsDbResult.getRmsCdpp() == null ? 0.0F
                        : tpsDbResult.getRmsCdpp();
                    double timeOfFirstTransitInMjd = tpsDbResult.timeOfFirstTransitInMjd() == null ? 0.0
                        : tpsDbResult.timeOfFirstTransitInMjd();
                    float minMultipleEventStatistic = tpsDbResult.getMinMultipleEventStatistic() == null ? 0.0F
                        : tpsDbResult.getMinMultipleEventStatistic();
                    float timeToFirstMicrolensInDays = tpsDbResult.getTimeToFirstMicrolensInDays() == null ? 0.0F
                        : tpsDbResult.getTimeToFirstMicrolensInDays();
                    double timeOfFirstMicrolensInMjd = tpsDbResult.getTimeOfFirstMicrolensInMjd() == null ? 0.0
                        : tpsDbResult.getTimeOfFirstMicrolensInMjd();
                    float detectedMicrolensOrbitalPeriodInDays = tpsDbResult.getDetectedMicrolensOrbitalPeriodInDays() == null ? 0.0F
                        : tpsDbResult.getDetectedMicrolensOrbitalPeriodInDays();

                    sbtTpsResults.add(new SbtTpsResult(
                        trialTransitPulseInHours, detectedOrbitalPeriodInDays,
                        isPlanetACandidate, maxSingleEventStatistic,
                        maxMultipleEventStatistic, timeToFirstTransitInDays,
                        rmsCdpp, timeOfFirstTransitInMjd, cdppTimeSeries,
                        minMultipleEventStatistic, timeToFirstMicrolensInDays,
                        timeOfFirstMicrolensInMjd,
                        detectedMicrolensOrbitalPeriodInDays));
                }
            }

            long maxPipelineInstanceId = 0;
            List<SbtPlanetResults> sbtPlanetResults = newArrayList();
            for (DvPlanetResults dvPlanetResults : latestDvPlanetResults) {
                if (dvPlanetResults.getKeplerId() == keplerId) {
                    PipelineInstance pipelineInstance = dvPlanetResults.getPipelineTask()
                        .getPipelineInstance();
                    int planetNumber = dvPlanetResults.getPlanetNumber();

                    if (pipelineInstance.getId() > maxPipelineInstanceId) {
                        maxPipelineInstanceId = pipelineInstance.getId();
                    }

                    FsId initialFluxValuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, INITIAL, DvTimeSeriesType.FLUX,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    FsId initialFluxUncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, INITIAL, DvTimeSeriesType.UNCERTAINTIES,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    FsId initialFluxFilledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, INITIAL, DvTimeSeriesType.FILLED_INDICES,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    fsIdsMultiQuarter.add(initialFluxValuesFsId);
                    fsIdsMultiQuarter.add(initialFluxUncertaintiesFsId);
                    fsIdsMultiQuarter.add(initialFluxFilledIndicesFsId);
                    CorrectedFluxTimeSeries initialFluxTimeSeries = persistableTimeSeriesFactory.getCorrectedFluxTimeSeries(
                        initialFluxValuesFsId, initialFluxUncertaintiesFsId,
                        initialFluxFilledIndicesFsId, fsIdToTimeSeries);

                    FsId modelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
                        fluxType, MODEL_LIGHT_CURVE, pipelineInstance.getId(),
                        keplerId, planetNumber);
                    fsIdsMultiQuarter.add(modelLightCurveFsId);
                    SimpleFloatTimeSeries modelLightCurveTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        modelLightCurveFsId, fsIdToTimeSeries);

                    FsId whitenedModelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
                        fluxType, WHITENED_MODEL_LIGHT_CURVE,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    fsIdsMultiQuarter.add(whitenedModelLightCurveFsId);
                    SimpleFloatTimeSeries whitenedModelLightCurveTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        whitenedModelLightCurveFsId, fsIdToTimeSeries);

                    FsId trapezoidalModelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
                        fluxType, TRAPEZOIDAL_MODEL_LIGHT_CURVE,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    fsIdsMultiQuarter.add(trapezoidalModelLightCurveFsId);
                    SimpleFloatTimeSeries trapezoidalModelLightCurveTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        trapezoidalModelLightCurveFsId, fsIdToTimeSeries);

                    FsId whitenedFluxTimeSeriesFsId = DvFsIdFactory.getFluxTimeSeriesFsId(
                        fluxType, "WhitenedFlux", pipelineInstance.getId(),
                        keplerId, planetNumber);
                    fsIdsMultiQuarter.add(whitenedFluxTimeSeriesFsId);
                    SimpleFloatTimeSeries whitenedFluxTimeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                        whitenedFluxTimeSeriesFsId, fsIdToTimeSeries);

                    FsId detrendedFluxValuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, DETRENDED, DvTimeSeriesType.FLUX,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    FsId detrendedFluxUncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, DETRENDED, DvTimeSeriesType.UNCERTAINTIES,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    FsId detrendedFluxFilledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                        fluxType, DETRENDED, DvTimeSeriesType.FILLED_INDICES,
                        pipelineInstance.getId(), keplerId, planetNumber);
                    fsIdsMultiQuarter.add(detrendedFluxValuesFsId);
                    fsIdsMultiQuarter.add(detrendedFluxUncertaintiesFsId);
                    fsIdsMultiQuarter.add(detrendedFluxFilledIndicesFsId);
                    CorrectedFluxTimeSeries detrendedFluxTimeSeries = persistableTimeSeriesFactory.getCorrectedFluxTimeSeries(
                        detrendedFluxValuesFsId,
                        detrendedFluxUncertaintiesFsId,
                        detrendedFluxFilledIndicesFsId, fsIdToTimeSeries);

                    sbtPlanetResults.add(new SbtPlanetResults(dvPlanetResults,
                        initialFluxTimeSeries, modelLightCurveTimeSeries,
                        whitenedModelLightCurveTimeSeries,
                        trapezoidalModelLightCurveTimeSeries,
                        whitenedFluxTimeSeries, detrendedFluxTimeSeries));
                }
            }

            FsId residualFluxValuesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
                fluxType, DvTimeSeriesType.FLUX, maxPipelineInstanceId,
                keplerId);
            FsId residualFluxUncertaintiesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
                fluxType, DvTimeSeriesType.UNCERTAINTIES,
                maxPipelineInstanceId, keplerId);
            FsId residualFluxFilledIndicesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
                fluxType, DvTimeSeriesType.FILLED_INDICES,
                maxPipelineInstanceId, keplerId);
            fsIdsMultiQuarter.add(residualFluxValuesFsId);
            fsIdsMultiQuarter.add(residualFluxUncertaintiesFsId);
            fsIdsMultiQuarter.add(residualFluxFilledIndicesFsId);
            CorrectedFluxTimeSeries residualFluxTimeSeries = persistableTimeSeriesFactory.getCorrectedFluxTimeSeries(
                residualFluxValuesFsId, residualFluxUncertaintiesFsId,
                residualFluxFilledIndicesFsId, fsIdToTimeSeries);
            SbtCorrectedFluxTimeSeries sbtResidualFluxTimeSeries = new SbtCorrectedFluxTimeSeries(
                residualFluxTimeSeries);

            List<SbtSingleEventStatistics> sbtSingleEventStatisticsList = newArrayList();
            for (FsId singleEventFsId : singleEventFsIds) {
                SingleEventParse singleEventParsed = DvFsIdFactory.parseSingleEventStatisticsFsId(singleEventFsId);
                FluxType fluxTypeParsed = singleEventParsed.fluxType;
                DvSingleEventStatisticsType singleEventStatisticsTypeParsed = singleEventParsed.singleEventStatisticsType;
                long pipelineInstanceIdParsed = singleEventParsed.pipelineInstanceId;
                int keplerIdParsed = singleEventParsed.keplerId;
                float trialTransitPulseDurationParsed = singleEventParsed.trialTransitPulseDuration;
                if (fluxType.equals(fluxTypeParsed)
                    && singleEventStatisticsTypeParsed.equals(DvSingleEventStatisticsType.CORRELATION)
                    && maxPipelineInstanceId == pipelineInstanceIdParsed
                    && keplerId == keplerIdParsed) {
                    List<SbtSimpleTimeSeries> sbtSingleEventStatisticsGroups = newArrayList();
                    for (DvSingleEventStatisticsType dvSingleEventStatisticsType : typesFactory.getDvSingleEventStatisticsTypes()) {
                        FsId fsId = DvFsIdFactory.getSingleEventStatisticsFsId(
                            fluxType, dvSingleEventStatisticsType,
                            maxPipelineInstanceId, keplerId,
                            trialTransitPulseDurationParsed);
                        fsIdsMultiQuarter.add(fsId);
                        SimpleFloatTimeSeries timeSeries = persistableTimeSeriesFactory.getSimpleTimeSeries(
                            fsId, fsIdToTimeSeries);
                        sbtSingleEventStatisticsGroups.add(new SbtSimpleTimeSeries(
                            dvSingleEventStatisticsType.toString(), timeSeries));
                    }

                    sbtSingleEventStatisticsList.add(new SbtSingleEventStatistics(
                        trialTransitPulseDurationParsed,
                        sbtSingleEventStatisticsGroups));
                }
            }

            FsId barycentricCorrectedTimestampsFsId = DvFsIdFactory.getBarycentricCorrectedTimestampsFsId(
                fluxType, maxPipelineInstanceId, keplerId);
            fsIdsMultiQuarter.add(barycentricCorrectedTimestampsFsId);
            SimpleDoubleTimeSeries barycentricCorrectedTimestampsTimeSeries = persistableTimeSeriesFactory.getSimpleDoubleTimeSeries(
                barycentricCorrectedTimestampsFsId, fsIdToTimeSeries);
            double[] barycentricCorrectedTimestamps = barycentricCorrectedTimestampsTimeSeries == null ? ArrayUtils.EMPTY_DOUBLE_ARRAY
                : barycentricCorrectedTimestampsTimeSeries.getValues();

            SbtQuantityWithProvenance effectiveTemp = new SbtQuantityWithProvenance();
            SbtQuantityWithProvenance log10Metallicity = new SbtQuantityWithProvenance();
            SbtQuantityWithProvenance log10SurfaceGravity = new SbtQuantityWithProvenance();
            SbtQuantityWithProvenance radius = new SbtQuantityWithProvenance();
            SbtDoubleQuantityWithProvenance decDegrees = new SbtDoubleQuantityWithProvenance();
            SbtQuantityWithProvenance keplerMag = new SbtQuantityWithProvenance();
            SbtDoubleQuantityWithProvenance raHours = new SbtDoubleQuantityWithProvenance();
            SbtString quartersObserved = new SbtString("");
            for (DvTargetResults dvTargetResults : latestDvTargetResults) {
                if (dvTargetResults.getKeplerId() == keplerId) {
                    effectiveTemp = dvTargetResults.getEffectiveTemp() == null ? new SbtQuantityWithProvenance()
                        : new SbtQuantityWithProvenance(
                            dvTargetResults.getEffectiveTemp());
                    log10Metallicity = dvTargetResults.getLog10Metallicity() == null ? new SbtQuantityWithProvenance()
                        : new SbtQuantityWithProvenance(
                            dvTargetResults.getLog10Metallicity());
                    log10SurfaceGravity = dvTargetResults.getLog10SurfaceGravity() == null ? new SbtQuantityWithProvenance()
                        : new SbtQuantityWithProvenance(
                            dvTargetResults.getLog10SurfaceGravity());
                    radius = dvTargetResults.getRadius() == null ? new SbtQuantityWithProvenance()
                        : new SbtQuantityWithProvenance(
                            dvTargetResults.getRadius());
                    decDegrees = dvTargetResults.getDecDegrees() == null ? new SbtDoubleQuantityWithProvenance()
                        : new SbtDoubleQuantityWithProvenance(
                            dvTargetResults.getDecDegrees());
                    keplerMag = dvTargetResults.getKeplerMag() == null ? new SbtQuantityWithProvenance()
                        : new SbtQuantityWithProvenance(
                            dvTargetResults.getKeplerMag());
                    raHours = dvTargetResults.getRaHours() == null ? new SbtDoubleQuantityWithProvenance()
                        : new SbtDoubleQuantityWithProvenance(
                            dvTargetResults.getRaHours());
                    quartersObserved = dvTargetResults.getQuartersObserved() == null ? new SbtString()
                        : new SbtString(dvTargetResults.getQuartersObserved());
                }
            }

            sbtFluxGroups.add(new SbtFluxGroup(fluxType.toString(),
                rawFluxTimeSeries, sbtCorrectedFluxTimeSeriesList,
                centroidGroups, discontinuityIndices,
                pdcProcessingCharacteristics, sbtTpsResults, new SbtDvResults(
                    sbtPlanetResults, sbtResidualFluxTimeSeries,
                    sbtSingleEventStatisticsList,
                    barycentricCorrectedTimestamps, effectiveTemp,
                    log10Metallicity, log10SurfaceGravity, radius, decDegrees,
                    keplerMag, raHours, quartersObserved)));
        }
        return sbtFluxGroups;
    }

    private List<SbtPdcProcessingCharacteristics> retrievePdcProcessingCharacteristics(
        FluxType fluxType, CadenceType cadenceType, int keplerId,
        int startCadence, int endCadence) {

        List<PdcProcessingCharacteristics> allData = pdcCrud.retrievePdcProcessingCharacteristics(
            fluxType, cadenceType, keplerId, startCadence, endCadence);

        if (allData == null || allData.isEmpty()) {
            return newArrayList();
        }

        CadenceDataFactory<PdcProcessingCharacteristics> dataFactory = new PdcProcessingCharacteristicsDataFactory();
        CadenceDataCalculator<PdcProcessingCharacteristics> dataCalc = new CadenceDataCalculator<PdcProcessingCharacteristics>(
            allData);
        CadenceData[] dataList = dataCalc.cadenceData();
        dataList = compressCadenceData(dataList, dataFactory, startCadence,
            endCadence);

        List<SbtPdcProcessingCharacteristics> sbtPdcProcessingCharacteristics = newArrayList();
        for (CadenceData cadenceData : dataList) {
            sbtPdcProcessingCharacteristics.add(new SbtPdcProcessingCharacteristics(
                keplerId, startCadence, endCadence,
                dataFactory.dataForCadenceData(cadenceData)));
        }

        return sbtPdcProcessingCharacteristics;
    }

    private static CadenceData[] compressCadenceData(CadenceData[] dataArray,
        CadenceDataFactory<PdcProcessingCharacteristics> dataFactory,
        int startCadence, int endCadence) {

        List<CadenceData> cadenceDataList = new ArrayList<CadenceData>();
        if (dataArray.length > 0) {
            CadenceData previousCadenceData = null;
            PdcProcessingCharacteristics currentCadenceData = null;
            for (int cadence = startCadence; cadence < endCadence + 1; cadence++) {
                int i = cadence - startCadence;
                CadenceData cadenceData = dataArray[i];

                if (previousCadenceData != null
                    && cadenceData.equals(previousCadenceData)) {
                    currentCadenceData.setEndCadence(cadence);
                } else {
                    if (previousCadenceData != null) {
                        cadenceDataList.add(currentCadenceData);
                    }
                    previousCadenceData = cadenceData;
                    currentCadenceData = dataFactory.duplicateCadenceData(cadenceData);
                    currentCadenceData.setStartCadence(cadence);
                    currentCadenceData.setEndCadence(cadence);
                }
            }
            cadenceDataList.add(currentCadenceData);
        }

        return cadenceDataList.toArray(new CadenceData[cadenceDataList.size()]);
    }

    private List<SbtAperture> retrieveSbtApertures(
        CadenceType cadenceType,
        int startCadence,
        int endCadence,
        List<TargetTableLog> targetTableLogs,
        Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters,
        MjdToCadence mjdToCadence,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        Map<Pair<Integer, Integer>, ObservedTarget> targetTableIdKeplerIdToObservedTarget,
        List<FsIdSet> fsIdSets,
        List<MjdFsIdSet> mjdFsIdSets,
        Integer keplerId,
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels,
        List<DvPlanetResults> latestDvPlanetResults,
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels) {
        List<SbtAperture> apertures = newArrayList();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            Pair<Integer, Integer> targetTableCadenceRange = getCadenceRange(
                targetTableLog, startCadence, endCadence);
            int startCadenceTargetTable = targetTableCadenceRange.left;
            int endCadenceTargetTable = targetTableCadenceRange.right;

            Set<FsId> fsIdsTargetTable = newLinkedHashSet();
            Set<FsId> mjdFsIdsTargetTable = newLinkedHashSet();

            int skyGroupId = keplerIdToCelestialObjectParameters.get(keplerId)
                .getSkyGroupId();

            Pair<Integer, Integer> modOut = retrieveModOut(skyGroupId,
                targetTableLog, mjdToCadence);
            int ccdModule = modOut.left;
            int ccdOutput = modOut.right;

            TargetTable targetTable = targetTableLog.getTargetTable();
            ObservedTarget observedTarget = targetTableIdKeplerIdToObservedTarget.get(Pair.of(
                targetTable.getExternalId(), keplerId));
            if (observedTarget != null) {
                Set<Pixel> pixels = pixelSetFactory.create(observedTarget,
                    null, ccdModule, ccdOutput);

                int targetTableId = targetTable.getExternalId();

                List<SbtPixel> sbtPixels = retrieveSbtPixels(cadenceType,
                    fsIdToTimeSeries, fsIdToMjdTimeSeries, fsIdsTargetTable,
                    mjdFsIdsTargetTable, ccdModule, ccdOutput, pixels,
                    mjdToCadence, startCadenceTargetTable,
                    endCadenceTargetTable, targetTableIdSkyGroupIdToBadPixels,
                    targetTableId, skyGroupId, latestDvPlanetResults,
                    latestDvLimbDarkeningModels, keplerId);

                int quarter = retrieveQuarter(targetTableLog, mjdToCadence);

                SbtTadData sbtTadData = new SbtTadData(
                    observedTarget.getLabels()
                        .toArray(new String[0]),
                    observedTarget.getSignalToNoiseRatio(),
                    observedTarget.getMagnitude(), observedTarget.getRa(),
                    observedTarget.getDec(), observedTarget.getEffectiveTemp(),
                    observedTarget.getBadPixelCount(),
                    observedTarget.getCrowdingMetric(),
                    observedTarget.getSkyCrowdingMetric(),
                    observedTarget.getFluxFractionInAperture(),
                    observedTarget.getDistanceFromEdge(),
                    observedTarget.getSaturatedRowCount());

                List<SbtCompoundTimeSeries> sbtCalTargetMetricTimeSeriesList = newArrayList();
                for (Entry<TargetMetricsTimeSeriesType, TargetMetricsTimeSeriesType> enumPair : enumMapFactory.create(
                    typesFactory.getCalTargetMetricsTimeSeriesTypes(),
                    EnumPairType.UNCERTAINTIES)
                    .entrySet()) {
                    TargetMetricsTimeSeriesType valuesType = enumPair.getKey();
                    FsId valuesFsId = CalFsIdFactory.getTargetMetricsTimeSeriesFsId(
                        cadenceType, valuesType, ccdModule, ccdOutput, keplerId);
                    TargetMetricsTimeSeriesType uncertaintiesType = enumPair.getValue();
                    FsId uncertaintiesFsId = CalFsIdFactory.getTargetMetricsTimeSeriesFsId(
                        cadenceType, uncertaintiesType, ccdModule, ccdOutput,
                        keplerId);
                    fsIdsTargetTable.add(valuesFsId);
                    fsIdsTargetTable.add(uncertaintiesFsId);
                    CompoundFloatTimeSeries compoundFloatTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                        valuesFsId, uncertaintiesFsId, fsIdToTimeSeries);
                    sbtCalTargetMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
                        valuesType.toString(), compoundFloatTimeSeries));
                }

                List<SbtAperturePlanetResults> planetResults = newArrayList();
                for (DvPlanetResults dvPlanetResults : latestDvPlanetResults) {
                    if (dvPlanetResults.getKeplerId() == keplerId) {
                        SbtPixelCorrelationResults pixelCorrelationResults = new SbtPixelCorrelationResults();
                        for (DvPixelCorrelationResults dvPixelCorrelationResults : dvPlanetResults.getPixelCorrelationResults()) {
                            if (dvPixelCorrelationResults.getTargetTableId() == targetTableId
                                && dvPixelCorrelationResults.getCcdModule() == ccdModule
                                && dvPixelCorrelationResults.getCcdOutput() == ccdOutput) {
                                pixelCorrelationResults = new SbtPixelCorrelationResults(
                                    dvPixelCorrelationResults);
                            }
                        }

                        SbtDifferenceImageResults differenceImageResults = new SbtDifferenceImageResults();
                        for (DvDifferenceImageResults dvDifferenceImageResults : dvPlanetResults.getDifferenceImageResults()) {
                            if (dvDifferenceImageResults.getTargetTableId() == targetTableId
                                && dvDifferenceImageResults.getCcdModule() == ccdModule
                                && dvDifferenceImageResults.getCcdOutput() == ccdOutput) {
                                differenceImageResults = new SbtDifferenceImageResults(
                                    dvDifferenceImageResults);
                            }
                        }

                        planetResults.add(new SbtAperturePlanetResults(
                            dvPlanetResults.getPlanetNumber(),
                            pixelCorrelationResults, differenceImageResults));
                    }
                }

                SbtLimbDarkeningModel limbDarkeningModel = new SbtLimbDarkeningModel();
                for (DvLimbDarkeningModel dvLimbDarkeningModel : latestDvLimbDarkeningModels) {
                    if (dvLimbDarkeningModel.getKeplerId() == keplerId
                        && dvLimbDarkeningModel.getTargetTableId() == targetTableId
                        && dvLimbDarkeningModel.getCcdModule() == ccdModule
                        && dvLimbDarkeningModel.getCcdOutput() == ccdOutput) {
                        limbDarkeningModel = new SbtLimbDarkeningModel(
                            dvLimbDarkeningModel);
                    }
                }

                apertures.add(new SbtAperture(targetTableId, quarter,
                    startCadenceTargetTable, endCadenceTargetTable, ccdModule,
                    ccdOutput, sbtTadData, sbtPixels,
                    sbtCalTargetMetricTimeSeriesList, planetResults,
                    limbDarkeningModel));
            }

            fsIdSets.add(new FsIdSet(startCadenceTargetTable,
                endCadenceTargetTable, fsIdsTargetTable));

            TicToc.tic("Calling mjdToCadence.cadenceToMjd()", 1);
            mjdFsIdSets.add(new MjdFsIdSet(
                mjdToCadence.cadenceToMjd(startCadenceTargetTable),
                mjdToCadence.cadenceToMjd(endCadenceTargetTable),
                mjdFsIdsTargetTable));
            TicToc.toc();
        }
        return apertures;
    }

    private List<SbtPixel> retrieveSbtPixels(
        CadenceType cadenceType,
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        Set<FsId> fsIdsTargetTable,
        Set<FsId> mjdFsIdsTargetTable,
        int ccdModule,
        int ccdOutput,
        Set<Pixel> pixels,
        MjdToCadence mjdToCadence,
        int startCadenceTargetTable,
        int endCadenceTargetTable,
        Map<Pair<Integer, Integer>, List<gov.nasa.kepler.hibernate.fc.Pixel>> targetTableIdSkyGroupIdToBadPixels,
        int targetTableId, int skyGroupId,
        List<DvPlanetResults> latestDvPlanetResults,
        List<DvLimbDarkeningModel> latestDvLimbDarkeningModels, Integer keplerId) {
        List<SbtPixel> sbtPixels = newArrayList();
        for (Pixel pixel : pixels) {
            TargetType targetType = TargetType.valueOf(cadenceType);
            int row = pixel.getRow();
            int column = pixel.getColumn();

            FsId rawPixelValuesFsId = DrFsIdFactory.getSciencePixelTimeSeries(
                DrFsIdFactory.TimeSeriesType.ORIG, targetType, ccdModule,
                ccdOutput, row, column);
            fsIdsTargetTable.add(rawPixelValuesFsId);
            SimpleIntTimeSeries rawPixelTimeSeries = persistableTimeSeriesFactory.getSimpleIntTimeSeries(
                rawPixelValuesFsId, fsIdToTimeSeries);

            FsId calPixelValuesFsId = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetType,
                ccdModule, ccdOutput, row, column);
            FsId calPixelUncertaintiesFsId = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                targetType, ccdModule, ccdOutput, row, column);
            fsIdsTargetTable.add(calPixelValuesFsId);
            fsIdsTargetTable.add(calPixelUncertaintiesFsId);
            CompoundFloatTimeSeries calPixelTimeSeries = persistableTimeSeriesFactory.getCompoundTimeSeries(
                calPixelValuesFsId, calPixelUncertaintiesFsId, fsIdToTimeSeries);

            FsId cosmicRayEventsValuesFsId = PaFsIdFactory.getCosmicRaySeriesFsId(
                targetType, ccdModule, ccdOutput, row, column);
            mjdFsIdsTargetTable.add(cosmicRayEventsValuesFsId);
            // Commented out because cosmicRayEvent mjds are no longer related
            // to PixelLog, so MjdToCadence cannot be used to convert the
            // cosmicRay mjd into a cadence number.
            // SimpleIndicesTimeSeries cosmicRayEventsTimeSeries =
            // persistableTimeSeriesFactory.getSimpleIndicesTimeSeries(
            // cosmicRayEventsValuesFsId, fsIdToMjdTimeSeries, mjdToCadence,
            // startCadenceTargetTable, endCadenceTargetTable);
            SimpleIndicesTimeSeries cosmicRayEventsTimeSeries = new SimpleIndicesTimeSeries();

            List<SbtBadPixelInterval> sbtBadPixelIntervals = newArrayList();
            List<gov.nasa.kepler.hibernate.fc.Pixel> badPixels = targetTableIdSkyGroupIdToBadPixels.get(Pair.of(
                targetTableId, skyGroupId));
            if (badPixels != null) {
                for (gov.nasa.kepler.hibernate.fc.Pixel badPixel : badPixels) {
                    if (badPixel.getCcdModule() == ccdModule
                        && badPixel.getCcdOutput() == ccdOutput
                        && badPixel.getCcdRow() == row
                        && badPixel.getCcdColumn() == column) {
                        sbtBadPixelIntervals.add(new SbtBadPixelInterval(
                            badPixel.getStartTime(), badPixel.getEndTime(),
                            badPixel.getType()
                                .toString(), badPixel.getPixelValue()));
                    }
                }
            }

            List<SbtPixelPlanetResults> planetResults = newArrayList();
            for (DvPlanetResults dvPlanetResults : latestDvPlanetResults) {
                if (dvPlanetResults.getKeplerId() == keplerId) {
                    SbtStatistic pixelCorrelationStatistic = new SbtStatistic();
                    for (DvPixelCorrelationResults pixelCorrelationResults : dvPlanetResults.getPixelCorrelationResults()) {
                        if (pixelCorrelationResults.getTargetTableId() == targetTableId
                            && pixelCorrelationResults.getCcdModule() == ccdModule
                            && pixelCorrelationResults.getCcdOutput() == ccdOutput) {
                            List<DvPixelStatistic> pixelCorrelationStatisticsList = pixelCorrelationResults.getPixelCorrelationStatistics();
                            for (DvPixelStatistic dvPixelStatistic : pixelCorrelationStatisticsList) {
                                if (dvPixelStatistic.getCcdRow() == row
                                    && dvPixelStatistic.getCcdColumn() == column) {
                                    pixelCorrelationStatistic = new SbtStatistic(
                                        dvPixelStatistic);
                                }
                            }
                        }
                    }

                    SbtDifferenceImagePixelData differenceImagePixel = new SbtDifferenceImagePixelData();
                    for (DvDifferenceImageResults dvDifferenceImageResults : dvPlanetResults.getDifferenceImageResults()) {
                        if (dvDifferenceImageResults.getTargetTableId() == targetTableId
                            && dvDifferenceImageResults.getCcdModule() == ccdModule
                            && dvDifferenceImageResults.getCcdOutput() == ccdOutput) {
                            for (DvDifferenceImagePixelData dvDifferenceImagePixelData : dvDifferenceImageResults.getDifferenceImagePixelData()) {
                                if (dvDifferenceImagePixelData.getCcdRow() == row
                                    && dvDifferenceImagePixelData.getCcdColumn() == column) {
                                    differenceImagePixel = new SbtDifferenceImagePixelData(
                                        dvDifferenceImagePixelData);
                                }
                            }
                        }
                    }

                    planetResults.add(new SbtPixelPlanetResults(
                        dvPlanetResults.getPlanetNumber(),
                        pixelCorrelationStatistic, differenceImagePixel));
                }
            }

            sbtPixels.add(new SbtPixel(row, column,
                pixel.isInOptimalAperture(), rawPixelTimeSeries,
                calPixelTimeSeries, cosmicRayEventsTimeSeries,
                sbtBadPixelIntervals, planetResults));
        }
        return sbtPixels;
    }

    private Pair<Integer, Integer> getCadenceRange(
        TargetTableLog targetTableLog, int startCadence, int endCadence) {
        int startCadenceTargetTable = startCadence < targetTableLog.getCadenceStart() ? targetTableLog.getCadenceStart()
            : startCadence;
        int endCadenceTargetTable = endCadence > targetTableLog.getCadenceEnd() ? targetTableLog.getCadenceEnd()
            : endCadence;

        return Pair.of(startCadenceTargetTable, endCadenceTargetTable);
    }

    private static class PdcProcessingCharacteristicsDataFactory implements
        CadenceDataFactory<PdcProcessingCharacteristics> {

        @Override
        public PdcProcessingCharacteristics dataForCadenceData(
            CadenceData cadenceData) {
            if (!(cadenceData instanceof PdcProcessingCharacteristics)) {
                throw new IllegalArgumentException(
                    "unexpected cadenceData of type "
                        + (cadenceData != null ? cadenceData.getClass()
                            .getSimpleName() : null));
            }
            return (PdcProcessingCharacteristics) cadenceData;
        }

        @Override
        public long originatorForCadenceData(CadenceData cadenceData) {
            if (!(cadenceData instanceof PdcProcessingCharacteristics)) {
                throw new IllegalArgumentException(
                    "unexpected cadenceData of type "
                        + (cadenceData != null ? cadenceData.getClass()
                            .getSimpleName() : null));
            }
            return ((PdcProcessingCharacteristics) cadenceData).getPipelineTaskId();
        }

        @Override
        public PdcProcessingCharacteristics duplicateCadenceData(
            CadenceData cadenceData) {
            if (!(cadenceData instanceof PdcProcessingCharacteristics)) {
                throw new IllegalArgumentException(
                    "unexpected cadenceData of type "
                        + (cadenceData != null ? cadenceData.getClass()
                            .getSimpleName() : null));
            }
            PdcProcessingCharacteristics ppc = (PdcProcessingCharacteristics) cadenceData;
            return new PdcProcessingCharacteristics.Builder(
                ppc.getPipelineTaskId(), ppc.getFluxType(),
                ppc.getCadenceType(), ppc.getKeplerId()).startCadence(
                ppc.getStartCadence())
                .endCadence(ppc.getEndCadence())
                .pdcMethod(ppc.getPdcMethod())
                .numDiscontinuitiesDetected(ppc.getNumDiscontinuitiesDetected())
                .numDiscontinuitiesRemoved(ppc.getNumDiscontinuitiesRemoved())
                .harmonicsFitted(ppc.isHarmonicsFitted())
                .harmonicsRestored(ppc.isHarmonicsRestored())
                .targetVariability(ppc.getTargetVariability())
                .bands(ppc.getBands())
                .build();
        }
    }
}
