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

package gov.nasa.kepler.ar.exporter.flux2;

import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.correctedUnfilledFlux;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.uniqueValue;
import static gov.nasa.kepler.fs.api.TimeSeriesDataType.DoubleType;
import static gov.nasa.kepler.fs.api.TimeSeriesDataType.FloatType;
import static gov.nasa.kepler.fs.api.TimeSeriesDataType.IntType;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.exporter.AbstractTargetSingleQuarterMetadata;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.SingleQuarterExporterSource;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.RmsCdpp;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayWriter;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessComponentType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessMetricType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.spiffy.common.collect.Pair; 

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.ImmutableSortedSet;

/**
 * Per-target information needed to export light curves.
 * 
 * @author Sean McCauliff
 * 
 */
final class FluxTargetMetadata extends AbstractTargetSingleQuarterMetadata {

    private final SingleQuarterExporterSource source;
    private final SortedSet<Pixel> aperturePixels;
    private final SortedMap<Pixel, FsId> cosmicRayIds;
    private final FsId prfCentroidRowId;
    private final FsId prfCentroidRowUmmId;
    private final FsId prfCentroidColumnId;
    private final FsId prfCentroidColumnUmmId;
    private final FsId fluxCentroidRowUmmId;
    private final FsId fluxCentroidColumnUmmId;
    private final FsId paFluxId;
    private final FsId paFluxUmmId;
    private final FsId paBackgroundId;
    private final FsId paBackgroundUmmId;
    private final FsId paCrowdingMetricId;
    private final FsId paFluxFractionInApertureId;
    private final FsId paSignalToNoiseRatioId;
    private final FsId paSkyCrowdingMetricId;
    private final FsId pdcFluxId;
    private final FsId pdcFluxUmmId;
    private final FsId pdcOutlierId;
    private final FsId pdcOutlierUmmId;
    private final FsId pdcFilledIndicesId;

    private final FsId pdcMapCorrelationGoodnessId;
    private final FsId pdcMapCorrelationGoodnessPctId;
    private final FsId pdcMapVariabilityGoodnessId;
    private final FsId pdcMapVariabilityGoodnessPctId;
    private final FsId pdcMapNoiseGoodnessId;
    private final FsId pdcMapNoiseGoodnessPctId;
    private final FsId pdcMapTotalGoodnessId;
    private final FsId pdcMapTotalGoodnessPctId;
    private final FsId pdcMapEarthPointGoodnessId;
    private final FsId pdcMapEarthPointGoodnessPct;

    private final Map<FsId, TimeSeriesDataType> allDataFsIds;
    /**
     * If at least one fsid in this set is non-empty then we can say we have
     * data for this target.
     */
    private final Set<FsId> hasDataFsIds;

    private final TimestampSeries longCadenceTimestampSeries;

    private final PdcProcessingCharacteristics pdcCharacteristics;

    /**
     * 
     * @param celestialObject
     * @param cadenceType
     * @param source
     * @param aperturePixels
     * @param crowdingMetric
     * @param fluxFractionInOptimalAperture
     * @param targetDroppedBySupplmentalTad
     * @param nPixelsMissingInOptimalAperture
     * @param cdpp This may be null.
     */
    public FluxTargetMetadata(CelestialObject celestialObject,
        CadenceType cadenceType, SingleQuarterExporterSource source,
        Set<Pixel> aperturePixels, double crowdingMetric,
        double fluxFractionInOptimalAperture,
        boolean targetDroppedBySupplmentalTad,
        int nPixelsMissingInOptimalAperture, RmsCdpp cdpp,
        TargetAperture targetAperture,
        TimestampSeries longCadenceTimestampSeries,
        PdcProcessingCharacteristics pdcCharacteristics, int k2Campaign,
        int targetTableId, boolean isK2, int[] rollingBandPulseDurationsLc) {
        
        super(celestialObject, cadenceType, source.ccdModule(),
            source.ccdOutput(),
            crowdingMetric, fluxFractionInOptimalAperture,
            targetDroppedBySupplmentalTad, nPixelsMissingInOptimalAperture,
            cdpp, targetAperture, k2Campaign, targetTableId,
            isK2, aperturePixels, rollingBandPulseDurationsLc);

        this.pdcCharacteristics = pdcCharacteristics;
        this.source = source;
        ImmutableSortedSet.Builder<Pixel> apBuilder = new ImmutableSortedSet.Builder<Pixel>(
            PixelByRowColumn.INSTANCE);
        if (!targetDroppedBySupplmentalTad) {
            apBuilder.addAll(aperturePixels);
        } else {
            for (Pixel originalPixel : aperturePixels) {
                apBuilder.add(new Pixel(originalPixel.getRow(),
                    originalPixel.getColumn(), false));
            }
        }
        this.aperturePixels = apBuilder.build();

        if (aperturePixels.isEmpty()) {
            throw new IllegalStateException("Target "
                + celestialObject.getKeplerId() + " lacks pixels.");
        }

        TargetType targetType = TargetType.valueOf(cadenceType);

        prfCentroidRowId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.PRF,
            CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId());
        prfCentroidRowUmmId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.PRF,
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId());
        prfCentroidColumnId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.PRF,
            CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId());
        prfCentroidColumnUmmId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.PRF,
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId());

        fluxCentroidRowUmmId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.FLUX_WEIGHTED,
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId());
        fluxCentroidColumnUmmId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            FluxType.SAP, CentroidType.FLUX_WEIGHTED,
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId());

        paFluxId = PaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.RAW_FLUX,
            FluxType.SAP, cadenceType, keplerId());
        paFluxUmmId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.RAW_FLUX_UNCERTAINTIES, FluxType.SAP, cadenceType,
            keplerId());

        paBackgroundId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_FLUX, FluxType.SAP, cadenceType,
            keplerId());
        paBackgroundUmmId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_FLUX_UNCERTAINTIES, FluxType.SAP,
            cadenceType, keplerId());

        paCrowdingMetricId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.CROWDING_METRIC, FluxType.SAP, cadenceType,
            keplerId());
        paFluxFractionInApertureId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.FLUX_FRACTION_IN_APERTURE, FluxType.SAP,
            cadenceType, keplerId());
        paSignalToNoiseRatioId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.SIGNAL_TO_NOISE_RATIO, FluxType.SAP, cadenceType,
            keplerId());
        paSkyCrowdingMetricId = PaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.SKY_CROWDING_METRIC, FluxType.SAP, cadenceType,
            keplerId());

        pdcFluxId = PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.CORRECTED_FLUX, FluxType.SAP, cadenceType,
            keplerId());
        pdcFluxUmmId = PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES, FluxType.SAP,
            cadenceType, keplerId());

        pdcOutlierId = PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.OUTLIERS, FluxType.SAP, cadenceType,
            keplerId());

        pdcOutlierUmmId = PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES, FluxType.SAP,
            cadenceType, keplerId());
        pdcFilledIndicesId = PdcFsIdFactory.getFilledIndicesFsId(
            PdcFilledIndicesTimeSeriesType.FILLED_INDICES, FluxType.SAP,
            cadenceType, keplerId());

        pdcMapCorrelationGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION, PdcGoodnessComponentType.VALUE,
            FluxType.SAP, cadenceType, keplerId());

        pdcMapCorrelationGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapVariabilityGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.VALUE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapVariabilityGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapNoiseGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.VALUE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapNoiseGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapTotalGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.VALUE,
            FluxType.SAP, cadenceType, keplerId());
        pdcMapTotalGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.PERCENTILE,
            FluxType.SAP, cadenceType, keplerId());
        pdcMapEarthPointGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.VALUE, FluxType.SAP, cadenceType,
            keplerId());
        pdcMapEarthPointGoodnessPct = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, cadenceType,
            keplerId());

        cosmicRayIds = 
            createOptimalApertureCosmicRays(source.ccdModule(), source.ccdOutput(), aperturePixels, targetType);

        ImmutableMap.Builder<FsId, TimeSeriesDataType> bldr = new ImmutableMap.Builder<FsId, TimeSeriesDataType>();

        bldr.put(fluxCentroidRowId, DoubleType);
        bldr.put(fluxCentroidRowUmmId, FloatType);
        bldr.put(fluxCentroidColumnId, DoubleType);
        bldr.put(fluxCentroidColumnUmmId, FloatType);
        bldr.put(prfCentroidRowId, DoubleType);
        bldr.put(prfCentroidRowUmmId, FloatType);
        bldr.put(prfCentroidColumnId, DoubleType);
        bldr.put(prfCentroidColumnUmmId, FloatType);
        bldr.put(paFluxId, FloatType);
        bldr.put(paFluxUmmId, FloatType);
        bldr.put(paBackgroundId, FloatType);
        bldr.put(paBackgroundUmmId, FloatType);
        bldr.put(paCrowdingMetricId, DoubleType);
        bldr.put(paFluxFractionInApertureId, DoubleType);
        bldr.put(paSignalToNoiseRatioId, DoubleType);
        bldr.put(paSkyCrowdingMetricId, DoubleType);
        bldr.put(pdcFluxId, FloatType);
        bldr.put(pdcFluxUmmId, FloatType);
        bldr.put(pdcFilledIndicesId, IntType);
        bldr.put(pdcMapCorrelationGoodnessId, FloatType);
        bldr.put(pdcMapCorrelationGoodnessPctId, FloatType);
        bldr.put(pdcMapVariabilityGoodnessId, FloatType);
        bldr.put(pdcMapVariabilityGoodnessPctId, FloatType);
        bldr.put(pdcMapNoiseGoodnessId, FloatType);
        bldr.put(pdcMapNoiseGoodnessPctId, FloatType);
        bldr.put(pdcMapTotalGoodnessId, FloatType);
        bldr.put(pdcMapTotalGoodnessPctId, FloatType);
        bldr.put(pdcMapEarthPointGoodnessId, FloatType);
        bldr.put(pdcMapEarthPointGoodnessPct, FloatType);

        allDataFsIds = bldr.build();

        hasDataFsIds = ImmutableSet.of(paFluxId);

        this.longCadenceTimestampSeries = longCadenceTimestampSeries;
    }

    @Override
    public String programName() {
        return source.programName();
    }

    @Override
    public long pipelineTaskId() {
        return source.pipelineTaskId();
    }

    @Override
    public int dataReleaseNumber() {
        return source.dataReleaseNumber();
    }

    @Override
    public int quarter() {
        return source.quarter();
    }

    @Override
    public int season() {
        return source.season();
    }

    @Override
    public SortedSet<Pixel> aperturePixels() {
        return aperturePixels;
    }

    /**
     * @param externalTtableId this parameter is ignored
     */
    @Override
    public SortedMap<Pixel, FloatMjdTimeSeries> optimalApertureCosmicRays(
        Map<FsId, FloatMjdTimeSeries> allSeries, 
        int externalTtableId) {

        SortedMap<Pixel, FloatMjdTimeSeries> rv = new TreeMap<Pixel, FloatMjdTimeSeries>(
            PixelByRowColumn.INSTANCE);
        for (Map.Entry<Pixel, FsId> entry : cosmicRayIds.entrySet()) {
            rv.put(entry.getKey(), allSeries.get(entry.getValue()));
        }
        return rv;
    }

    @Override
    public boolean hasData(Map<FsId, TimeSeries> allSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries) {

        for (FsId id : hasDataFsIds) {
            if (!allSeries.get(id).isEmpty()) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void addToMjdTimeSeriesIds(Set<FsId> totalSet) {
        super.addCommonMjdTimeSeriesIds(totalSet);
        totalSet.addAll(cosmicRayIds.values());
        totalSet.add(pdcOutlierId);
        totalSet.add(pdcOutlierUmmId);
    }

    @Override
    public void addToTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet) {
        super.addCommonTimeSeriesIds(totalSet);
        totalSet.putAll(allDataFsIds);
    }

    @Override
    protected Set<FsId> allTimeSeriesIds() {
        return allDataFsIds.keySet();
    }

    @Override
    protected int cadenceToLongCadence(int nativeCadence) {
        return source.cadenceToLongCadence(nativeCadence);
    }

    @Override
    protected TimestampSeries cadenceTimes() {
        return source.timestampSeries();
    }

    Map<FsId, TimeSeries> targetData(Map<FsId, TimeSeries> allSeries) {
        Map<FsId, TimeSeries> rv = new HashMap<FsId, TimeSeries>();
        for (FsId id : allDataFsIds.keySet()) {
            rv.put(id, allSeries.get(id));
        }
        return rv;
    }

    @Override
    public Date generatedAt() {
        return source.generatedAt();
    }

    /**
     * Organize data by FITS column.
     * 
     * @param allTimeSeries
     * @param allMjdTimeSeries
     * @param floatFill
     * @param intFill
     * @param exposureCalc
     * @param mjdToCadence
     * @return
     */
    List<ArrayWriter> organizeData(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries, float floatFill,
        int intFill, ExposureCalculator exposureCalc, MjdToCadence mjdToCadence) {

        TargetDva targetDva = dva();
        targetDva.fillGaps(floatFill);

        Pair<float[], float[]> unfilledPdcLightCurves = correctedUnFilledFlux(
            mjdToCadence, allMjdTimeSeries, allTimeSeries, floatFill);
        Accessor a = new Accessor(allTimeSeries, floatFill, intFill,
            exposureCalc);
        return ImmutableList.of(
            a.farray(paFluxId, true),
            a.farray(paFluxUmmId, true),
            a.farray(paBackgroundId, true),
            a.farray(paBackgroundUmmId, true),
            // a.farray(pdcFluxId, true), a.farray(pdcFluxUmmId, true),
            new FloatArrayWriter(unfilledPdcLightCurves.left, exposureCalc),
            new FloatArrayWriter(unfilledPdcLightCurves.right, exposureCalc),
            new IntArrayWriter(dataQualityFlags()),
            a.darray(prfCentroidColumnId),
            a.farray(prfCentroidColumnUmmId, false),
            a.darray(prfCentroidRowId), a.farray(prfCentroidRowUmmId, false),
            a.darray(fluxCentroidColumnId),
            a.farray(fluxCentroidColumnUmmId, false),
            a.darray(fluxCentroidRowId), a.farray(fluxCentroidRowUmmId, false),
            new FloatArrayWriter(targetDva.getColumnDva(), null),
            new FloatArrayWriter(targetDva.getRowDva(), null));
    }

    PdcMapResults pdcMapResults(final Map<FsId, TimeSeries> allTimeSeries) {
        return new PdcMapResults() {

            @Override
            public Float pdcVariabilityGoodnessPct() {
                return uniqueValue(allTimeSeries.get(pdcMapVariabilityGoodnessPctId));
            }

            @Override
            public Float pdcVariabilityGoodness() {
                return uniqueValue(allTimeSeries.get(pdcMapVariabilityGoodnessId));
            }

            @Override
            public Float pdcTotalGoodnessPct() {
                return uniqueValue(allTimeSeries.get(pdcMapTotalGoodnessPctId));
            }

            @Override
            public Float pdcTotalGoodness() {
                return uniqueValue(allTimeSeries.get(pdcMapTotalGoodnessId));
            }

            @Override
            public Float pdcNoiseGoodnessPct() {
                return uniqueValue(allTimeSeries.get(pdcMapNoiseGoodnessPctId));
            }

            @Override
            public Float pdcNoiseGoodness() {
                return uniqueValue(allTimeSeries.get(pdcMapNoiseGoodnessId));
            }

            @Override
            public Float pdcCorrelationGoodnessPct() {
                return uniqueValue(allTimeSeries.get(pdcMapCorrelationGoodnessPctId));
            }

            @Override
            public Float pdcCorrelationGoodness() {
                return uniqueValue(allTimeSeries.get(pdcMapCorrelationGoodnessId));
            }

            @Override
            public Float pdcEarthPointGoodness() {
                return uniqueValue(allTimeSeries.get(pdcMapEarthPointGoodnessId));
            }

            @Override
            public Float pdcEarthPointGoodnessPct() {
                return uniqueValue(allTimeSeries.get(pdcMapEarthPointGoodnessPct));
            }

            @Override
            public PdcProcessingCharacteristics processingCharacteristics() {
                return pdcCharacteristics;
            }
        };
    }

    /**
     * Regaps and restores outliers and their uncertainties to the pdc light
     * curve.
     * 
     * @return (data, umm)
     */
    private Pair<float[], float[]> correctedUnFilledFlux(
        MjdToCadence mjdToCadence,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        Map<FsId, TimeSeries> allTimeSeries, float missingDataValue) {

        FloatTimeSeries pdcLightCurve = allTimeSeries.get(pdcFluxId)
            .asFloatTimeSeries();
        FloatTimeSeries pdcLightCurveUmm = allTimeSeries.get(pdcFluxUmmId)
            .asFloatTimeSeries();

        IntTimeSeries filledCadences = allTimeSeries.get(pdcFilledIndicesId)
            .asIntTimeSeries();
        FloatMjdTimeSeries outliers = allMjdTimeSeries.get(pdcOutlierId);

        float[] unfillData = correctedUnfilledFlux(mjdToCadence,
            filledCadences, outliers, pdcLightCurve, missingDataValue);

        // Add gaps to uncert
        FloatMjdTimeSeries outliersUmm = allMjdTimeSeries.get(pdcOutlierUmmId);
        float[] unfillUmm = correctedUnfilledFlux(mjdToCadence, filledCadences,
            outliersUmm, pdcLightCurveUmm, missingDataValue);

        return Pair.of(unfillData, unfillUmm);
    }

    @Override
    protected TimestampSeries longCadenceTimes() {
        return longCadenceTimestampSeries;
    }

    @Override
    public int extensionHduCount() {
        return 2;
    }

    Collection<FloatTimeSeries> paFluxTimeSeries(Map<FsId,TimeSeries> allTimeSeries) {
        List<FloatTimeSeries> rv = new ArrayList<FloatTimeSeries>();
        for (FsId id : new FsId[] {paFluxId, paFluxUmmId, paBackgroundId, paBackgroundUmmId}) {
            FloatTimeSeries paTimeSeries = allTimeSeries.get(id).asFloatTimeSeries();
            if (paTimeSeries != null) {
                rv.add(paTimeSeries);
            }
        }
        return rv;
    }
}
