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

package gov.nasa.kepler.ar.exporter.tpixel;

import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.exporter.AbstractTargetSingleQuarterMetadata;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.RollingBandFlags.RollingBandKey;
import gov.nasa.kepler.ar.exporter.RmsCdpp;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

import com.google.common.collect.ImmutableSortedMap;
import com.google.common.collect.Ordering;

/**
 * Information about a single target that will have its pixels exported.
 * 
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
class TargetPixelMetadata extends AbstractTargetSingleQuarterMetadata {

    private final TargetPixelMetadataSource tPixelExporterSource;

    private SortedMap<Pixel, BackgroundPixelValue> backgroundPixels;
    
    private final TimestampSeries longCadenceTimes;
    
    private final TargetPixels targetPixelIds;
    
    private final SortedMap<RollingBandKey, FsId> rollingBandVariationFsId;
    
    private final int nRollingBandPulseDurations;
    
    /**
     * 
     * @param celestialObject non-null
     * @param cadenceType non-null
     * @param aperturePixels non-null and non-empty
     * @param tPixelExporterSource non-null
     * @param crowdingMetric this may be null
     * @param fluxFractionInOptimalAperture this may be null
     * @param cdpp this may be null
     * @param targetAperture non-null
     * @param longCadenceTimes long cadence timestamps, this must be non-null.
     */
    TargetPixelMetadata(CelestialObject celestialObject,
        CadenceType cadenceType, 
        Set<Pixel> aperturePixels, int ccdModule, int ccdOutput,
        TargetPixelMetadataSource tPixelExporterSource,
        Double crowdingMetric, Double fluxFractionInOptimalAperture,
        boolean droppedBySupplementalTad,
        int nPixelsMissingInOptimalAperture,
        RmsCdpp cdpp, TargetAperture targetAperture,
        TimestampSeries longCadenceTimes,
        int k2Campaign, int targetTableId, 
        boolean isK2, int[] rollingBandPulseDurationsLc) {

        super(celestialObject, cadenceType, ccdModule, ccdOutput, crowdingMetric,
            fluxFractionInOptimalAperture, droppedBySupplementalTad,
            nPixelsMissingInOptimalAperture, cdpp, targetAperture,
            k2Campaign, targetTableId, isK2, aperturePixels,
            rollingBandPulseDurationsLc);

        
        this.tPixelExporterSource = tPixelExporterSource;
        TargetType targetType = TargetType.valueOf(cadenceType);
        this.targetPixelIds = new TargetPixels(aperturePixels, 
            ccdModule, ccdOutput, targetType, droppedBySupplementalTad);
        this.longCadenceTimes = longCadenceTimes;
        
        this.nRollingBandPulseDurations = rollingBandPulseDurationsLc.length;

        Pair<Integer, Integer> startEndRows = startEndRows(aperturePixels);
        
        ImmutableSortedMap.Builder<RollingBandKey, FsId>  rbVariationBldr = 
            new ImmutableSortedMap.Builder<RollingBandKey, FsId>(Ordering.natural());
        for (int row=startEndRows.left; row <= startEndRows.right; row++) {
            for (int duration : rollingBandPulseDurationsLc) {
                RollingBandKey key = new RollingBandKey(duration, row, ccdModule, ccdOutput);
                rbVariationBldr.put(key, key.id());
            }
        }
        
        this.rollingBandVariationFsId = rbVariationBldr.build();
    }
    
    private static final Pair<Integer, Integer> startEndRows(Collection<Pixel> aperturePixels) {
        int minValue = Integer.MAX_VALUE;
        int maxValue = Integer.MIN_VALUE;
        
        for (Pixel px : aperturePixels) {
            if (minValue > px.getRow()) {
                minValue = px.getRow();
            }
            if (maxValue < px.getRow()) {
                maxValue = px.getRow();
            }
        }
        
        return Pair.of(minValue, maxValue);
    }
    
    final void setBackground(Map<Pixel,BackgroundPixelValue> allBackground) {
        this.backgroundPixels = 
            new TreeMap<Pixel, BackgroundPixelValue>(PixelByRowColumn.INSTANCE);
        for (Pixel pixel : aperturePixels()) {
            this.backgroundPixels.put(pixel, allBackground.get(pixel));
        }
    }
    
    final SortedMap<Pixel, BackgroundPixelValue> background() {
        return this.backgroundPixels;
    }
    
    final boolean compressFile() {
        return imageDimensions().sizeInPixels >= this.tPixelExporterSource.compressionThresholdInPixels();
    }
   
    /**
     * The number of rows by number of durations.
     * @return non-null
     */
    final Integer[] rollingBandVariationDimensions() {
        return new Integer[] { nRollingBandPulseDurations, super.imageDimensions().nRows};
    }
    
    final SortedMap<RollingBandKey, DoubleTimeSeries> rollingBandVariation(Map<FsId, TimeSeries> allSeries) {
        ImmutableSortedMap.Builder<RollingBandKey, DoubleTimeSeries> bldr =
            new  ImmutableSortedMap.Builder<RollingBandKey, DoubleTimeSeries>(Ordering.natural());
        for (Map.Entry<RollingBandKey, FsId> rbEntry : rollingBandVariationFsId.entrySet()) {
            bldr.put(rbEntry.getKey(), allSeries.get(rbEntry.getValue()).asDoubleTimeSeries());
        }
        return bldr.build();
    }
    
    @Override
    public final void addToLongCadenceFsIds(Map<FsId, TimeSeriesDataType> lcSet) {
        if (cadenceType == CadenceType.SHORT) {
            super.addToLongCadenceFsIds(lcSet);
            for (FsId rbVariationId : this.rollingBandVariationFsId.values()) {
                lcSet.put(rbVariationId, TimeSeriesDataType.FloatType);
            }
        }
    }
    
    @Override
    public final void addToTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet) {
        this.targetPixelIds.addTimeSeriesIds(totalSet);
        super.addCommonTimeSeriesIds(totalSet);
        
        if (cadenceType == CadenceType.LONG) {
            for (FsId rbVariationId : this.rollingBandVariationFsId.values()) {
                totalSet.put(rbVariationId, TimeSeriesDataType.DoubleType);
            }
        }
    }
    
    @Override
    public final void addToMjdTimeSeriesIds(Set<FsId> totalSet) {
        this.targetPixelIds.addMjdTimeSeriesIds(totalSet);
        super.addCommonMjdTimeSeriesIds(totalSet);
    }
    
    @Override
    public final SortedSet<Pixel> aperturePixels() {
        return targetPixelIds.aperturePixels();
    }
    
    final SortedMap<Pixel,TimeSeries> rawPixels(Map<FsId,TimeSeries> allSeries) {
        return targetPixelIds.rawPixels(allSeries);
    }

    final SortedMap<Pixel,TimeSeries> calibratedPixels(Map<FsId,TimeSeries> allSeries) {
        return targetPixelIds.calibratedPixels(allSeries);
        
    }
    
    final SortedMap<Pixel,TimeSeries> ummPixels(Map<FsId,TimeSeries> allSeries) {
        return targetPixelIds.ummPixels(allSeries);
    }
    
    final SortedMap<Pixel,FloatMjdTimeSeries> cosmicRays(Map<FsId,FloatMjdTimeSeries> allSeries) {
       return targetPixelIds.cosmicRays(allSeries);
    }
    
    /**
     * @param externalTtableId this parameter is ignored
     */
    @Override
    public final SortedMap<Pixel,FloatMjdTimeSeries> optimalApertureCosmicRays(Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId) {
        return targetPixelIds.optimalApertureCosmicRays(allSeries);
    }
    
    @Override
    public final boolean hasData(Map<FsId,TimeSeries> allSeries, Map<FsId,FloatMjdTimeSeries> allMjdTimeSeries) {
        return targetPixelIds.hasData(allSeries, allMjdTimeSeries);
    }
    
    
    @Override
    public final Set<FsId> allTimeSeriesIds() {
        Map<FsId, TimeSeriesDataType> all = new HashMap<FsId, TimeSeriesDataType>(1024);
        addCommonTimeSeriesIds(all);
        targetPixelIds.addTimeSeriesIds(all);
        for (FsId rbId : rollingBandVariationFsId.values()) {
            all.put(rbId, TimeSeriesDataType.FloatType);
        }
        return all.keySet();
    }
    
    @Override
    public final int dataReleaseNumber() {
        return tPixelExporterSource.dataReleaseNumber();
    }

    @Override
    public final long pipelineTaskId() {
        return tPixelExporterSource.pipelineTaskId();
    }

    @Override
    public final String programName() {
        return tPixelExporterSource.programName();
    }

    @Override
    public final int quarter() {
        return tPixelExporterSource.quarter();
    }

    @Override
    public final int season() {
        return tPixelExporterSource.season();
    }
    
    @Override
    public final Date generatedAt() {
        return tPixelExporterSource.generatedAt();
    }
    
    @Override
    protected final int cadenceToLongCadence(int nativeCadence) {
        return tPixelExporterSource.cadenceToLongCadence(nativeCadence);
    }

    @Override
    protected final TimestampSeries cadenceTimes() {
        return tPixelExporterSource.cadenceTimes();
    }

    @Override
    protected final TimestampSeries longCadenceTimes() {
        return longCadenceTimes;
    }


    @Override
    public int extensionHduCount() {
        return 2;
    }

}
