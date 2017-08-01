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

package gov.nasa.kepler.ar.exporter.dv;

import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getBarycentricCorrectedTimestampsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getResidualTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getSingleEventStatisticsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType.CORRELATION;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType.NORMALIZATION;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType.FLUX;
import static gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType.FILLED_INDICES;
import static gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX;
import static gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType.OUTLIERS;
import static gov.nasa.kepler.fs.api.TimeSeriesDataType.*;
import static com.google.common.base.Preconditions.checkNotNull;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSortedSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import gov.nasa.kepler.ar.exporter.AbstractTargetMetadata;
import gov.nasa.kepler.ar.exporter.AbstractTargetExporter.TargetTime;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.RollingBandFlags;
import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.ar.exporter.RmsCdpp;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayWriter;
import gov.nasa.kepler.ar.exporter.flux2.Accessor;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.spiffy.common.collect.Pair;


/**
 * Data pertaining to a single target star that is to be exported with the
 * Data Validation archive. These data appear in the primary header (the
 * header of the initial HDU) and the final "statistics" HDU of a Data
 * Validation FITS file, since each such file applies to a single target.
 * This class has fields for only those cards the values for which are not
 * obtainable from superclasses.
 * This is intended to be part of the Model in the Model-View-Controller
 * pattern. As such, it should not be aware of FITS and its requirements.
 *
 * @author Lee Brownston
 * @author Sean McCauliff
 */
final class DvTargetMetadata 
    extends AbstractTargetMetadata
    implements DvTargetPrimaryHeaderSource {
    
    private static final Log log = LogFactory.getLog(DvTargetMetadata.class);
    
    /** This is the FluxType of all exported light curves. */
    public static final FluxType FLUX_TYPE = FluxType.SAP;
    
    private final FileNameFormatter fnameFormatter = new FileNameFormatter();
    
    
    private final long dvPipelineInstanceId;
    
    private final DvTargetResults targetResults;
    private final DvExporterSource exporterSource;
    
    private final List<DvTceMetadata> tceMetadataList;

    private final Map<Integer, SortedSet<Pixel>> ttableIdToAperturePixels;

    private final Map<Integer, RollingBandFlags> ttableIdtoRollingBandFlags = Maps.newHashMap();
    
    private final Map<Integer, RollingBandFlags> ttableIdtoOptimalApertureRollingBandFlags = Maps.newHashMap();
    
    /** Every FsId used. */
    private final FsIdPojo fsIdPojo;

    private final Date startOfDvRun;
    
    private final TpsDbResult initialTce;
   
    ////// The following data members can not be known at construction time
    ///// which is why they are not declared final.
    private ExposureCalculator exposureCalculator;
    
    private TargetTime targetTime;
    
    /**
     * Since this class's fields are private, there are no setters and this is
     * the only constructor, the only way to set the fields is via this
     * constructor.
     */
    DvTargetMetadata(
        CelestialObject celestialObject,
        DvExporterSource exporterSource,
        RmsCdpp rmsCdpp,
        Map<Integer, Set<Pixel>> aperturePixels,
        Map<Integer, Pair<Integer, Integer>> ttableIdToCcdModOut,
        Map<Integer, RollingBandUtils> ttableIdToRbPulseDurations,
        DvTargetResults targetResults,
        List<DvPlanetResults> planetResultsList,
        TpsDbResult initialTce) {
        
        super(celestialObject, CadenceType.LONG, rmsCdpp);

        PipelineTask pipelineTask = targetResults.getPipelineTask();
        PipelineInstance pipelineInstance = pipelineTask.getPipelineInstance();
        this.startOfDvRun  = pipelineInstance.getStartProcessingTime();
        checkNotNull(this.startOfDvRun, "startOfDvRun");
        
        // The DV-specific fields, which are final
        this.exporterSource = exporterSource;

        this.targetResults = targetResults;
        this.initialTce = initialTce;
        this.dvPipelineInstanceId = exporterSource.dvPipelineInstanceId();
        
        ImmutableList.Builder<DvTceMetadata> tceBldr = listBuilder();
        for (DvPlanetResults planetResults : planetResultsList) {
            tceBldr.add(new DvTceMetadata(planetResults, dvPipelineInstanceId));
        }
        this.tceMetadataList = tceBldr.build();
       
        ImmutableMap.Builder<Integer, SortedSet<Pixel>> ttableIdToAperturePixelsBldr =
            mapBuilder();
        
        for (Map.Entry<Integer, Set<Pixel>> pixelsForTtable : aperturePixels.entrySet()) {

            Integer ttableId = pixelsForTtable.getKey();
            Set<Pixel> pixelsForQuarter = pixelsForTtable.getValue();
            if (pixelsForQuarter == null) {
                log.info("Target " + keplerId() + " not observed during target table " + ttableId + ".");
                continue;
            }
            SortedSet<Pixel> sortedPixels = ImmutableSortedSet.copyOf(pixelsForQuarter);
            ttableIdToAperturePixelsBldr.put(ttableId, sortedPixels);
        }
        ttableIdToAperturePixels = ttableIdToAperturePixelsBldr.build();
        
        long tpsPipelineInstanceId = initialTce.getOriginator().getPipelineInstance().getId();
        this.fsIdPojo = new FsIdPojo(dvPipelineInstanceId, 
            exporterSource.tpsTrialTransitPulseDurationsHours(),
            ttableIdToCcdModOut, ttableIdToRbPulseDurations,
            tpsPipelineInstanceId);
        
    }
    
    public TargetTime targetTime() {
        checkNotNull(targetTime, "targetTime was not set");
        return targetTime;
    }
    
    public void setTargetTime(TargetTime targetTime) {
        checkNotNull(targetTime, "targetTime");
        this.targetTime = targetTime;
    }
    
    public ExposureCalculator exposureCalculator() {
        checkNotNull(exposureCalculator, "exposure calculator was not set");
        return exposureCalculator;
    }
    
    public void setExposureCalculator(ExposureCalculator exposureCalculator) {
        checkNotNull(exposureCalculator, "exposure calculator");
        this.exposureCalculator = exposureCalculator;
    }
    
    @Override
    public int hduCount() {
        return 1 + //primary
                1 + //statistics
                + tceMetadataList.size();
    }
    
    /** @return a file name String based on a Kepler ID and a time stamp */
    public String fileName() {
        return fnameFormatter.dataValidationTimeSeriesName(keplerId(), startOfDvRun);
    }
    
    /** @return the SubVersion revision number String for the Data Validation module */
    @Override
    public String dvSoftwareRevisionNumber() {
        return targetResults.getPipelineTask().getSoftwareRevision();
    }
    
    /**
     * @return a 17-character String, each element of which is either '0' or '1',
     * indicating whether quarter n, 0 <= n < 17, was used in the analysis
     */
    @Override
    public String quarters() {
        return targetResults.getQuartersObserved();
    }
    
    @Override
    public int tceCount() {
        return tceMetadataList.size();
    }
    
    
    public List<DvTceMetadata> tceMetadataList() {
        return this.tceMetadataList;
    }
    
    /** Where these data come from, e.g., a class. */
    @Override
    public String programName() {
        return exporterSource.programName();
    }

    /** The ID of the Pipeline Task that performed the export operation. */
    @Override
    public long pipelineTaskId() {
        return exporterSource.pipelineTaskId();
    }

    @Override
    public int dataReleaseNumber() {
        return exporterSource.dataReleaseNumber();
    }

    @Override
    public Date generatedAt() {
        return exporterSource.generatedAt();
    }
    
    @Override
    public String dvXmlFileName() {
        return fnameFormatter.dataValidationName(startOfDvRun);
    }

    /**
     * @return a Map from Pixel to the FloatMjdTimeSeries, where the Pixels
     * come from the cosmic ray Map and the FloatMjdTimeSeries comes from the
     * Map argument.
     */
    @Override
    public SortedMap<Pixel, FloatMjdTimeSeries> optimalApertureCosmicRays(
        Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId) {

        SortedMap<Pixel, FloatMjdTimeSeries> rv = 
            new TreeMap<Pixel, FloatMjdTimeSeries>(PixelByRowColumn.INSTANCE);
        SortedMap<Pixel, FsId> cosmicRaysForTtable = 
            fsIdPojo.ttableIdToCosmicRayId.get(externalTtableId);
        if (cosmicRaysForTtable == null) {
            return Maps.newTreeMap();
        }
        for (Map.Entry<Pixel, FsId> entry : cosmicRaysForTtable.entrySet()) {
            Pixel pixel = entry.getKey();
            FsId fsId = entry.getValue();
            rv.put(pixel, allSeries.get(fsId));
        }
        return rv;
    }

    /**
     * @return true if we have at least one time series to do.
     */
    @Override
    public boolean hasData(Map<FsId, TimeSeries> allSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries) {
        
        if (tceMetadataList.isEmpty()) {
            return false;
        }
        
        return !allSeries.get(fsIdPojo.timeBkjdFsId).isEmpty();
    }

    @Override
    public void addToMjdTimeSeriesIds(Set<FsId> totalSet) {
        fsIdPojo.addMjdTimeSeriesIdsTo(totalSet);
    }

    /**
     * Add entries to the Map argument, some of which are common to all
     * subclasses of AbstractTargetMetadata and some which are specific to Data
     * Validation.
     * @param totalSet must not be null
     */
    @Override
    public void addToTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet) {
        totalSet.putAll(fsIdPojo.fsIdToType);
        for (DvTceMetadata tce : tceMetadataList) {
            tce.addTimeSeriesIdsTo(totalSet);
        }
    }

    @Override
    protected Set<FsId> allTimeSeriesIds() {
        Set<FsId> allIds = new HashSet<FsId>(256);
        for (DvTceMetadata dvTceMetadata : tceMetadataList) {
            allIds.addAll(dvTceMetadata.allTimeSeriesIds()); 
        }
        allIds.addAll(fsIdPojo.fsIdToType.keySet());
        return allIds;
    }

    //////  These methods: quarter, season, ccdModule, ccdOutput, ccdChannel, targetTableId
    ////// don't work well with multi quarter stuff, but we need them
    ////// in order to satisfy some interface requirements.
    @Override
    public int quarter() {
        return -1;
    }

    @Override
    public int season() {
        return -1;
    }

    @Override
    public int ccdModule() {
        return -1;
    }

    @Override
    public int ccdOutput() {
        return -1;
    }

    @Override
    public int ccdChannel() {
        return -1;
    }
    
    @Override
    public int targetTableId() {
        return -1;
    }

    @Override
    public ObservingMode observingMode() {
        return ObservingMode.LONG_CADENCE;
    }

    /**
     * @return always -1
     */
    @Override
    public int k2Campaign() {
        return -1;
    }

    /**
     * @return always false
     */
    @Override
    public boolean isK2Target() {
        return false;
    }
//////////////////////////////////////////////////////////////
    @Override
    public Set<FsId> rollingBandFlagsFsId(int externalTtableId) {
        Set<FsId> rbIdSet = fsIdPojo.ttableIdToRollingBandIds.get(externalTtableId);
        if (rbIdSet == null) {
            return Collections.emptySet();
        }
        return rbIdSet;
    }

    @Override
    public Set<FsId> rollingBandFlagsOptimalApertureFsId(int externalTtableId) {
        Set<FsId> rbIdSet = fsIdPojo.ttableIdToOptimalApertureRollingBandIds.get(externalTtableId);
        if (rbIdSet == null) {
            return Collections.emptySet();
        }
        return rbIdSet;
    }

    @Override
    public Set<FloatMjdTimeSeries> optimalApertureCollateralCosmicRays(
        Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId) {
        
        return extractData(fsIdPojo.ttableIdToCollateralCosmicRayIds, allSeries, externalTtableId);
    }
    
    private static <T> Set<T>
        extractData(Map<Integer, Set<FsId>> tttableToListFsId, Map<FsId, T> allData, Integer externalTtableId) {

        if (!tttableToListFsId.containsKey(externalTtableId)) {
            return Collections.emptySet();
        }
        
        Set<T> rv = Sets.newHashSet();
        for (FsId collateralCrId : tttableToListFsId.get(externalTtableId)) {
            rv.add(allData.get(collateralCrId));
        }
        return rv;
    }

    @Override
    public RollingBandFlags rollingBandFlags(int externalTargetTableId) {
        return ttableIdtoRollingBandFlags.get(externalTargetTableId);
    }
    
    @Override
    public RollingBandFlags optimalApertureRollingBandFlags(int externalTargetTableId) {
        return ttableIdtoOptimalApertureRollingBandFlags.get(externalTargetTableId);
    }

    @Override
    public void setRollingBandFlags(RollingBandFlags rbFlags,
        int externalTtableId) {

        ttableIdtoRollingBandFlags.put(externalTtableId, rbFlags);
    }
    
    @Override
    public void setOptimalApertureRollingBandFlags(RollingBandFlags rbFlags,
        int externalTtableId) {

        ttableIdtoRollingBandFlags.put(externalTtableId, rbFlags);
    }

    /**
     * This does nothing.
     */
    @Override
    public void addToLongCadenceFsIds(Map<FsId, TimeSeriesDataType> lcSet) {
   
    }

    /**
     * 
     * @param floatMjdTimeSeries
     * @return non-null
     */
    public DoubleTimeSeries bcCorrectedTimestamps(
        Map<FsId, TimeSeries> allTimeSeries) {

        return allTimeSeries.get(fsIdPojo.timeBkjdFsId).asDoubleTimeSeries();
    }

    /**
     * 
     * @param floatMjdTimeSeries
     * @return non-null
     */
    public IntTimeSeries pdcFilledTimeSeries(Map<FsId, TimeSeries> allTimeSeries) {
        return allTimeSeries.get(fsIdPojo.pdcSapFilledIndicesFsId).asIntTimeSeries();
    }

    /**
     * 
     * @param floatMjdTimeSeries
     * @return non-null
     */
    public FloatMjdTimeSeries pdcOutlierTimeSeries(
        Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeries) {

        return floatMjdTimeSeries.get(fsIdPojo.pdcSapOutliersFsId);
    }
    
    public FloatTimeSeries pdcLightCurve(Map<FsId, TimeSeries> allTimeSeries) {
        return allTimeSeries.get(fsIdPojo.pdcSapLightCurveFsId).asFloatTimeSeries();
    }

    /**
     * 
     * @param allTimeSeries
     * @return non-null
     */
    public FloatTimeSeries pdcCorrectedTimeSeries(
        Map<FsId, TimeSeries> allTimeSeries) {

        return allTimeSeries.get(fsIdPojo.pdcSapFilledIndicesFsId).asFloatTimeSeries();
    }
    
    
    /**
     * 
     * @param allTimeSeries  the timeSeries map is updated with new corrected values
     * for this target.
     */
    public void unfillAndUnoutlie(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        MjdToCadence mjdToCadence) {
        
        derivePdcSapFlux(fsIdPojo.pdcSapLightCurveFsId,
            allTimeSeries, allMjdTimeSeries, mjdToCadence);
        
        derivePdcSapFlux(fsIdPojo.pdcSapLightCurveUmmFsId,
            allTimeSeries, allMjdTimeSeries, mjdToCadence);
        
        DvTceMetadata.unfillTimeSeries(fsIdPojo.residualLightCurveFsId, fsIdPojo.residualLightCurveFillIndicesFsId,
            allTimeSeries);
        
        for (DvTceMetadata tce : tceMetadataList) {
            tce.unfill(allTimeSeries);
        }
        
    }
    
    /**
     * 
     * @param allTimeSeries  the timeSeries map is updated with new corrected values
     * for this target.
     * @return This also returns the updated time series.
     * Warning:  The updated time series validCadences() and originators()
     * have not been modified.  Only the values of the underlying array.
     */
    private FloatTimeSeries derivePdcSapFlux(FsId pdcId,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        MjdToCadence mjdToCadence) {
        
       
        FloatTimeSeries pdcSapFlux = allTimeSeries.get(pdcId).asFloatTimeSeries();
        
        // Restore the outliers and unfill the gaps.
        float[] correctedUnfilledFluxTimeSeries =
            FluxTimeSeriesProcessing.correctedUnfilledFlux(
                mjdToCadence, pdcFilledTimeSeries(allTimeSeries),
                pdcOutlierTimeSeries(allMjdTimeSeries),
                pdcSapFlux, Float.NaN);
        
        FloatTimeSeries cleanedTimeSeries = 
            new FloatTimeSeries(pdcSapFlux.id(),correctedUnfilledFluxTimeSeries,
            pdcSapFlux.startCadence(), pdcSapFlux.endCadence(),
            pdcSapFlux.validCadences(), pdcSapFlux.originators());
        
        allTimeSeries.put(cleanedTimeSeries.id(), cleanedTimeSeries);
        return cleanedTimeSeries;
    }

    public List<ArrayWriter> organizeData(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeries, float gapFill,
        int intGapFill, ExposureCalculator exposureCalculator,
        MjdToCadence mjdToCadence) {

        Accessor a = new Accessor(allTimeSeries, gapFill, intGapFill, exposureCalculator);
        List<ArrayWriter> rv = Lists.newArrayList();
        rv.add(a.farray(fsIdPojo.pdcSapLightCurveFsId, true));
        rv.add(a.farray(fsIdPojo.pdcSapLightCurveUmmFsId, true));
        rv.add(a.farray(fsIdPojo.residualLightCurveFsId, true));
        rv.add(a.farray(fsIdPojo.initialDeemphasisWeightsFsId, false));
        rv.add(new IntArrayWriter(dataQualityFlags()));
        
        for (FsId sesCorrId : fsIdPojo.sesCorrelationPerPulseFsIds) {
            rv.add(a.farray(sesCorrId, false));
        }
        for (FsId sesNormId : fsIdPojo.sesNormalizationPerPulseFsIds) {
            rv.add(a.farray(sesNormId, false));
        }
        for (FsId sesNormId : fsIdPojo.sesNormalizationPerPulseFsIds) {
            rv.add(new CdppArrayWriter(allTimeSeries.get(sesNormId).asFloatTimeSeries().fseries()));
        }
        return rv;
        
    }
    
    /**
     * Aggregate and encapsulate per-target FsIds.
     * Each field corresponds to a column or set of related columns in the
     * table of the Statistics HDU.
     * This is non-static so it can see the the outer class's keplerId and cadenceType.
     */
    private class FsIdPojo {
        // The exported columns
        final FsId   timeBkjdFsId;
        
        final FsId   pdcSapLightCurveFsId;
        final FsId   pdcSapLightCurveUmmFsId;
        final FsId   pdcSapFilledIndicesFsId;
        final FsId   pdcSapOutliersFsId;   
        final FsId   pdcDiscontinuityIndicesFsId;
        
        final FsId   residualLightCurveFsId;
        final FsId   residualLightCurveFillIndicesFsId;
        final FsId[] sesCorrelationPerPulseFsIds;
        final FsId[] sesNormalizationPerPulseFsIds;
        final FsId   initialDeemphasisWeightsFsId;

        final Map<Integer, Set<FsId>> ttableIdToCollateralCosmicRayIds;
        final Map<Integer, SortedMap<Pixel, FsId>> ttableIdToCosmicRayId;
        final Map<Integer, Set<FsId>> ttableIdToRollingBandIds;
        final Map<Integer, Set<FsId>> ttableIdToOptimalApertureRollingBandIds;
        

        final Map<FsId, TimeSeriesDataType> fsIdToType;
        
        FsIdPojo(long dvPipelineInstanceId, float[] trialTransitPulseDurationsHours,
            Map<Integer, Pair<Integer, Integer>> ttableIdToCcdModOut,
            Map<Integer, RollingBandUtils> ttableIdToRbPulseDurations,
            long tpsPipeineInstanceId) {
            
            timeBkjdFsId = getBarycentricCorrectedTimestampsFsId(FLUX_TYPE, 
                dvPipelineInstanceId, keplerId());
        
            pdcSapLightCurveFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                CORRECTED_FLUX, FLUX_TYPE, CadenceType.LONG,
                keplerId());
            
            pdcSapLightCurveUmmFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                CORRECTED_FLUX_UNCERTAINTIES, FLUX_TYPE, CadenceType.LONG,
                keplerId());
            
            pdcSapFilledIndicesFsId = PdcFsIdFactory.getFilledIndicesFsId(
                FILLED_INDICES, FLUX_TYPE, cadenceType, keplerId());
            pdcSapOutliersFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
                OUTLIERS, FLUX_TYPE, cadenceType, keplerId());
            
            pdcDiscontinuityIndicesFsId =
                PdcFsIdFactory.getDiscontinuityIndicesFsId(FLUX_TYPE, cadenceType, keplerId());
        
            residualLightCurveFsId = getResidualTimeSeriesFsId(FLUX_TYPE, FLUX, 
                dvPipelineInstanceId, keplerId());
            
            residualLightCurveFillIndicesFsId = getResidualTimeSeriesFsId(FLUX_TYPE, DvTimeSeriesType.FILLED_INDICES, 
                dvPipelineInstanceId, keplerId());
            
            int pulseCount = trialTransitPulseDurationsHours.length;
            sesCorrelationPerPulseFsIds = new FsId[pulseCount];
            sesNormalizationPerPulseFsIds = new FsId[pulseCount];
            
            for (int i = 0; i < pulseCount; i++) {
                float trialTransitPulseDurationHours = trialTransitPulseDurationsHours[i];
                sesCorrelationPerPulseFsIds[i] = getSingleEventStatisticsFsId(FLUX_TYPE,
                    CORRELATION, dvPipelineInstanceId, keplerId(), 
                    trialTransitPulseDurationHours);
                sesNormalizationPerPulseFsIds[i] = getSingleEventStatisticsFsId(FLUX_TYPE,
                    NORMALIZATION, dvPipelineInstanceId, keplerId(), 
                    trialTransitPulseDurationHours);
            }
            
            float initialTcePulseDuration = initialTce.getTrialTransitPulseInHours();
            initialDeemphasisWeightsFsId =
                TpsFsIdFactory.getDeemphasisWeightsId(tpsPipeineInstanceId, keplerId(),
                    initialTcePulseDuration);

            ImmutableMap.Builder<FsId, TimeSeriesDataType> builder =
                mapBuilder();
            
            builder.put(timeBkjdFsId,            DoubleType);
            builder.put(pdcSapLightCurveFsId,    FloatType);
            builder.put(pdcSapLightCurveUmmFsId, FloatType);
            builder.put(residualLightCurveFsId,  FloatType);
            builder.put(residualLightCurveFillIndicesFsId, IntType);
            
            for (int i = 0; i < sesCorrelationPerPulseFsIds.length; i++) {
                builder.put(sesCorrelationPerPulseFsIds[i], FloatType);
            }
            for (int i = 0; i < sesNormalizationPerPulseFsIds.length; i++) {
                builder.put(sesNormalizationPerPulseFsIds[i], FloatType);
            }
            builder.put(initialDeemphasisWeightsFsId, FloatType);
            builder.put(pdcSapFilledIndicesFsId,      IntType);
            builder.put(pdcDiscontinuityIndicesFsId,  IntType);
               
            ImmutableMap.Builder<Integer, Set<FsId>> ttableIdToCollateralCosmicRayIdsBldr = 
                mapBuilder();
            
            ImmutableMap.Builder<Integer, SortedMap<Pixel, FsId>> ttableIdToCosmicRayIdBuilder = 
                mapBuilder();
            
            ImmutableMap.Builder<Integer, Set<FsId>> ttableIdToRollingBandIdsBuilder = 
                mapBuilder();
            
            ImmutableMap.Builder<Integer, Set<FsId>> ttableIdToOptimalApertureRollingBandIdsBuilder =
                mapBuilder();
            
            for (Map.Entry<Integer, SortedSet<Pixel>> pixelsForTtable : ttableIdToAperturePixels.entrySet()) {   
                Integer ttableId = pixelsForTtable.getKey();

                Pair<Integer, Integer> modOut = ttableIdToCcdModOut.get(ttableId);
                int ccdModule = modOut.left;
                int ccdOutput = modOut.right;
                
                ttableIdToCollateralCosmicRayIdsBldr.put(ttableId, 
                    collateralCosmicRayIds(ccdModule, ccdOutput, pixelsForTtable.getValue()));
                ttableIdToCosmicRayIdBuilder.put(ttableId,
                    createOptimalApertureCosmicRays(ccdModule, ccdOutput, pixelsForTtable.getValue(), TargetType.LONG_CADENCE));
                
                int[] rbPulseDurations = 
                    ttableIdToRbPulseDurations.get(ttableId)
                    .rollingBandPulseDurations();
                Pair<Set<FsId>, Set<FsId>> rbFlagSets = 
                    createRollingBandFsIds(ccdModule, ccdOutput, pixelsForTtable.getValue(), rbPulseDurations);
                ttableIdToRollingBandIdsBuilder.put(ttableId, rbFlagSets.left);
                ttableIdToOptimalApertureRollingBandIdsBuilder.put(ttableId, rbFlagSets.right);
            }

            ttableIdToCollateralCosmicRayIds = 
                ttableIdToCollateralCosmicRayIdsBldr.build();
            ttableIdToCosmicRayId = ttableIdToCosmicRayIdBuilder.build();

            ttableIdToRollingBandIds = ttableIdToRollingBandIdsBuilder.build();
            ttableIdToOptimalApertureRollingBandIds = 
                ttableIdToOptimalApertureRollingBandIdsBuilder.build();
            fsIdToType = builder.build();
        }

        public void addMjdTimeSeriesIdsTo(Set<FsId> totalSet) {
            totalSet.add(pdcSapOutliersFsId);
            for (Set<FsId> collateralCosmicRayIds : ttableIdToCollateralCosmicRayIds.values()) {
                totalSet.addAll(collateralCosmicRayIds);
            }
            for (SortedMap<Pixel, FsId> scienceCosmicRayIds : ttableIdToCosmicRayId.values()) {
                totalSet.addAll(scienceCosmicRayIds.values());
            }
        }
    }

    @Override
    public int extensionHduCount() {
        return hduCount();
    }


}
