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

import static com.google.common.base.Preconditions.checkNotNull;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.ImmutableSortedMap;
import com.google.common.collect.ImmutableSortedSet;
import com.google.common.collect.Ordering;

import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

/**
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AbstractTargetMetadata {
 
    protected final CelestialObject celestialObject;
    
    /** celestialObject has this, but I want this fixed for the purposes of hashCode() and equals(). */
    private final int keplerId;
    
    protected final CadenceType cadenceType;

    protected final FsId pdcDiscontinuityId;
    
    protected final FsId pdcOutlierId;
    
    private final RmsCdpp rmsCdpp;
    
    private int[] dataQualityFlags;
    
    private Pair<Integer, Integer> actualStartEndTimes;
    
    private BarycentricCorrection bcOverride;

    /**
     * 
     * @param celestialObject
     * @param cadenceType
     * @param rmsCdpp this may be null
     */
    protected AbstractTargetMetadata(CelestialObject celestialObject,
        CadenceType cadenceType, RmsCdpp rmsCdpp) {
        
        checkNotNull(celestialObject, "celestial object");
        checkNotNull(cadenceType, "cadenceType");
        this.keplerId = celestialObject.getKeplerId();
        this.celestialObject = celestialObject;
        this.cadenceType = cadenceType;
        this.rmsCdpp = rmsCdpp;
        
        this.pdcDiscontinuityId = PdcFsIdFactory.getDiscontinuityIndicesFsId(FluxType.SAP, cadenceType, celestialObject.getKeplerId());
        this.pdcOutlierId = PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.OUTLIERS, FluxType.SAP,
            cadenceType, celestialObject.getKeplerId());
    }
    
    /**
     * Fetches the barycentric correction time series out from the the map of
     * all time series data else this generates a time series from the 
     * computed barycentric corrections.
     * 
     * @param timeSeries
     * @param startCadence The start of the unit of work.
     * @param endCadence The end of the unit of work.
     * @return
     */
    public FloatTimeSeries barycentricCorrectionSeries(
        Map<FsId, TimeSeries> timeSeries, int startCadence, int endCadence) {

        if (bcOverride != null) {
            return new FloatTimeSeries(new FsId("/fake/", Integer.toString(keplerId())),
                bcOverride.getCorrectionSeries(), startCadence, endCadence,
                bcOverride.getGaps(), 0);
        }
        throw new NullPointerException("Missing barycentric correction for " + keplerId() + ".");
    }
  
    /**
     * Updates the content of allTimeSeries with the new barycentric correction
     * if the barycentric correction does not exist currently.
     * 
     * @param bc
     * @param allTimeSeries
     * @param startCadence The start of the unit of work.
     * @param endCadence The end of the unit of work.
     */
    public final void setBarycentricCorrection(BarycentricCorrection bc) {
        if (bcOverride != null) {
            throw new IllegalStateException("Already set barycentric correction.");
        }
        
        this.bcOverride = bc;
    }
    
    /**
     * 
     * @return non-null
     */
    public final int[] dataQualityFlags() {
        if (dataQualityFlags == null) {
            throw new NullPointerException("data quality flags have not been set");
        }
        return dataQualityFlags;
    }
    
    /**
     * 
     * @param qualityFlags Data quality flags are calculated for the unit of work's [start,end] cadences
     * not the target's [start,end] cadences.
     */
    public final void setDataQualityFlags(int[] dataQualityFlags) {
        checkNotNull(dataQualityFlags, "dataQualityFlags");
        this.dataQualityFlags = dataQualityFlags;
    }
 
    /**
     * The min and max time cadences for which data is available for this target.
     * @param allSeries
     * @return
     */
    public final Pair<Integer,Integer> actualStartAndEnd(Map<FsId,TimeSeries> allSeries) {
        
        if (actualStartEndTimes != null) {
            return actualStartEndTimes;
        }
        int start = Integer.MAX_VALUE;
        int end = Integer.MIN_VALUE;
        
        for (FsId id : allTimeSeriesIds()) {
            TimeSeries ts = allSeries.get(id);
            if (ts == null) {
                continue;
            }
            if (!ts.exists()) {
                continue;
            }
            List<SimpleInterval> validCadences = ts.validCadences();
            if (validCadences.size() == 0) {
                continue;
            }
            start = Math.min((int)validCadences.get(0).start(), start);
            end = Math.max((int)validCadences.get(validCadences.size() - 1).end(), end);
        }
        
        actualStartEndTimes = Pair.of(start, end);
        return actualStartEndTimes;
    }
    
    public final String subversionRevision() {
        return KeplerSocVersion.getRevision();
    }

    public final String subversionUrl() {
        return KeplerSocVersion.getUrl();
    }
    
    public final int keplerId() {
        return keplerId;
    }
    
    public final double raDegrees() {
        return FluxTimeSeriesProcessing.decimalHoursToDecimalDegrees(celestialObject().getRa());
    }
    
    public final Integer skyGroup() {
        if (celestialObject().getSkyGroupId() == 0) {
            return null;
        }
        return celestialObject().getSkyGroupId();
    }
    
    public IntTimeSeries pdcDiscontinuitySeries(Map<FsId,TimeSeries> allSeries) {
        return allSeries.get(pdcDiscontinuityId).asIntTimeSeries();
    }
    
    public final FloatMjdTimeSeries pdcOutliers(Map<FsId,FloatMjdTimeSeries> allMjdTimeSeries) {
        return allMjdTimeSeries.get(pdcOutlierId);
    }
    
    /**
     * 
     * @return non-null
     */
    public final CelestialObject celestialObject() {
        return celestialObject;
    }
    
    /**
     * 
     * @return This may return null.
     */
    public final Float cdpp3Hr() {
        if (rmsCdpp == null) {
            return null;
        }
        return rmsCdpp.cdpp3Hr();
    }
    
    /**
     * 
     * @return This may return null.
     */
    public final Float cdpp6Hr() {
        if (rmsCdpp == null) {
            return null;
        }
        return rmsCdpp.cdpp6Hr();
    }
    
    /**
     * 
     * @return This may return null.
     */
    public final Float cdpp12Hr() {
        if (rmsCdpp == null) {
            return null;
        }
        return rmsCdpp.cdpp12Hr();
    }
    
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((cadenceType == null) ? 0 : cadenceType.hashCode());
        result = prime * result + keplerId;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        AbstractTargetMetadata other = (AbstractTargetMetadata) obj;
        if (cadenceType != other.cadenceType)
            return false;
        if (keplerId != other.keplerId)
            return false;
        return true;
    }

    protected abstract Set<FsId> allTimeSeriesIds();
    
    public abstract void addToLongCadenceFsIds(Map<FsId, TimeSeriesDataType> lcSet);
    
    /**
     * Rollingband file store ids associated with a particular quarter/target table id.
     * @param externalTtableId
     * @return
     */
    public abstract Set<FsId> rollingBandFlagsFsId(int externalTtableId);
    
    public abstract Set<FsId> rollingBandFlagsOptimalApertureFsId(int externalTtableId);
    
    /**
     * Get the mjd time series that deal with the cosmic rays detected on the
     * optimal aperture pixels projected onto the collateral pixel regions.
     * 
     * @param allSeries where to get the time series from
     * @param externalTtableId the target table identifier that was in effect
     * for this cadence type when the pixels were collected.
     * @return null ok?
     */
    public abstract Set<FloatMjdTimeSeries> optimalApertureCollateralCosmicRays(Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId);
    
    /**
     * The cosmic ray detections for the optimal aperture pixels.
     * 
     * @param allSeries
     * @param externalTtableId the target table identifier that was in effect
     * for this cadence type when the pixels were collected.
     * @return non-null.  An empty sorted map if optimal aperture cosmic rays are not
     * available.
     */
    public abstract SortedMap<Pixel,FloatMjdTimeSeries> optimalApertureCosmicRays(Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId);

    /**
     * 
     * @return This may return null if rolling band flags are not available.
     */
    public abstract RollingBandFlags rollingBandFlags(int externalTargetTableId);
    
    public abstract RollingBandFlags optimalApertureRollingBandFlags(int externalTargetTableId);
    
    
    /**
     * 
     * @param rbFlags non-null
     * @param externalTtableId
     */
    public abstract void setRollingBandFlags(RollingBandFlags rbFlags, int externalTtableId);

    public abstract void setOptimalApertureRollingBandFlags(RollingBandFlags rbFlags, int externalTtableId);
    
    /**
     * 
     * @return a positive integer
     */
    public abstract int hduCount();

    /**
     * 
     * @param allSeries non-null, all the TimeSeries for all targets.
     * @param allMjdTimeSeries non-null, all the MjdTimeSeries for all targets.
     * @return true if the specified target metadata has sufficient data
     * to generate a valid export file.
     */
    public abstract boolean hasData(Map<FsId,TimeSeries> allSeries, Map<FsId,FloatMjdTimeSeries> allMjdTimeSeries);
    
    /**
     * Add mjd time series FsIds to the specified set.  If none are
     * required then this does nothing.
     * 
     * @param totalSet non-null, out parameter
     */
    public abstract void addToMjdTimeSeriesIds(Set<FsId> totalSet);
    
    /**
     * Add the time series fs ids and their types needed for export to the specified
     * parameter totalSet.  Something will read this out of the file store
     * at a later time.
     * 
     * @param totalSet non-null, out parameter
     */
    public abstract void addToTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet);
    

    /**
     * Generates the FsIds for the collateral pixels that are aperture
     * pixels projected into the collateral pixel regions.
     * These are stored as FloatMjdTimeSeries.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param aperturePixels
     * @return non-null
     */
    protected Set<FsId> collateralCosmicRayIds(int ccdModule, int ccdOutput,
        Set<Pixel> aperturePixels) {
        
        ImmutableSet.Builder<FsId> collateralCRBuilder = 
            new ImmutableSet.Builder<FsId>();
        for (Pixel pixel : aperturePixels) {
            if (!pixel.isInOptimalAperture()) {
                continue;
            }
            
            collateralCRBuilder.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_LEVEL,
                cadenceType, ccdModule, ccdOutput, pixel.getRow()));
            collateralCRBuilder.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.MASKED_SMEAR,
                cadenceType, ccdModule, ccdOutput, pixel.getColumn()));
            collateralCRBuilder.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.VIRTUAL_SMEAR,
                cadenceType, ccdModule, ccdOutput, pixel.getColumn()));
            
            if (cadenceType == CadenceType.SHORT) {
                collateralCRBuilder.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_MASKED, 
                    cadenceType, ccdModule, ccdOutput, pixel.getColumn()));
                collateralCRBuilder.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_VIRTUAL,
                    cadenceType, ccdModule, ccdOutput, pixel.getRow()));
            }
        }
        return collateralCRBuilder.build();
    }
    
    protected SortedMap<Pixel, FsId> createOptimalApertureCosmicRays(
        int ccdModule, int ccdOutput, Set<Pixel> aperturePixels,
        TargetType targetType) {
        
        ImmutableSortedMap.Builder<Pixel, FsId> crBuilder = new ImmutableSortedMap.Builder<Pixel, FsId>(
            PixelByRowColumn.INSTANCE);
        for (Pixel pixel : aperturePixels) {
            if (!pixel.isInOptimalAperture()) {
                continue;
            }
            FsId id = PaFsIdFactory.getCosmicRaySeriesFsId(targetType,
                ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn());
            crBuilder.put(pixel, id);
        }
        return crBuilder.build();
    }
    
    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param aperturePixels
     * @param rollingBandPulseDurationsLc
     * @return (all rb flags, optimal aperture rb flags)
     */
    protected static Pair<Set<FsId>, Set<FsId>> createRollingBandFsIds(
        int ccdModule, int ccdOutput, Set<Pixel> aperturePixels,
        int[] rollingBandPulseDurationsLc) {

        ImmutableSet.Builder<FsId> rollingBandFlagsFsIds = setBuilder();
        ImmutableSet.Builder<FsId> rollingBandFlagsOptimalApertureFsIds = setBuilder();
        for (int pulseDuration : rollingBandPulseDurationsLc) {
            for (Pixel pixel : aperturePixels) {
                FsId rbFlagFsId = DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(
                    ccdModule, ccdOutput, pixel.getRow(), pulseDuration);
                rollingBandFlagsFsIds.add(rbFlagFsId);
                if (pixel.isInOptimalAperture()) {
                    rollingBandFlagsOptimalApertureFsIds.add(rbFlagFsId);
                }
            }
        }

        Set<FsId> rbFlags = rollingBandFlagsFsIds.build();
        Set<FsId> rbFlagsOpt = rollingBandFlagsOptimalApertureFsIds.build();
        return Pair.of(rbFlags, rbFlagsOpt);
    }
    
    protected static <K,V> ImmutableMap.Builder<K,V> mapBuilder() {
        return new ImmutableMap.Builder<K,V>();
    }
    
    protected static <K extends Comparable<K>,V> ImmutableSortedMap.Builder<K, V> sortedMapBuilder() {
        return new ImmutableSortedMap.Builder<K, V>(Ordering.natural());
    }
    
    protected static <T> ImmutableList.Builder<T> listBuilder() {
        return new ImmutableList.Builder<T>();
    }
    
    protected static <K extends Comparable<K>> ImmutableSortedSet.Builder<K> sortedSetBuilder() {
        return new ImmutableSortedSet.Builder<K>(Ordering.natural());
    }
    
    protected static <K> ImmutableSet.Builder<K> setBuilder() {
        return new ImmutableSet.Builder<K>();
    }
    
}
