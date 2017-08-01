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

import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderSource;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator.TargetImageDimensions;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.spiffy.common.collect.Pair;

/**
 * Metadata about a particular target for a single quarter.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AbstractTargetSingleQuarterMetadata
    extends AbstractTargetMetadata
    implements TargetPrimaryHeaderSource, DvaTargetSource {
   
    private static final Log log = LogFactory.getLog(AbstractTargetSingleQuarterMetadata.class);
    
    private static final TargetImageDimensionCalculator imageDimensionsCalculator 
    = new TargetImageDimensionCalculator();
    
    
    private static final ReferenceCadenceCalculator referenceCadenceCalculator 
        = new ReferenceCadenceCalculator();
    
    private static final CentroidCalculator centroidCalculator =
        new CentroidCalculator();
    
    protected final FsId fluxCentroidRowId;
    protected final FsId fluxCentroidColumnId;
    protected final FsId fluxCentroidLcRowId;
    protected final FsId fluxCentroidLcColumnId;
    
    
    private final Set<FsId> collateralCosmicRayIds;
    
    private int[] longCadenceQualityFlags;
    
    private TargetWcs targetWcs;
    private TargetDva targetDva;

    private TargetImageDimensions imageDimensions;
    private final Double crowdingMetric;
    private final Double fluxFractionInOptimalAperture;
    private final boolean targetDroppedBySupplmentalTad;
    private final int nPixelsMissingInOptimalAperture;

    /** This is not final because in some cases we need to find the
     * task that created the PA data for this target.
     */
    private TargetAperture targetAperture;
    
    /* Sorted by pulse duration and row. */
    private final Set<FsId> rollingBandFlagsFsIds;
    private final Set<FsId> rollingBandFlagsOptimalApertureFsIds;
    private final int ccdModule;
    private final int ccdOutput;
    private final int k2Campaign;
    private final int targetTableId;
    private final boolean isK2;
    private RollingBandFlags rollingBandFlags;
    private RollingBandFlags optimalApertureRollingBandFlags;
    
    /**
     * 
     * @param celestialObject non-null
     * @param cadenceType non-null
     * @param crowdingMetric This may be null
     * @param fluxFractionInOptimalAperture  this may be null
     * @param cdpp This may be null.
     * @param targetAperture may be null
     */
    protected AbstractTargetSingleQuarterMetadata(CelestialObject celestialObject,
        CadenceType cadenceType, int ccdModule, int ccdOutput,
        Double crowdingMetric, Double fluxFractionInOptimalAperture,
        boolean targetDroppedBySupplementalTad, 
        int nPixelsMissingInOptimalAperture, RmsCdpp rmsCdpp,
        TargetAperture targetAperture, int k2Campaign, int targetTableId,
        boolean isK2, Set<Pixel> aperturePixels, int[] rollingBandPulseDurationsLc) {

        super(celestialObject, cadenceType, rmsCdpp);
        
        if (nPixelsMissingInOptimalAperture < 0) {
            throw new IllegalArgumentException("Number of pixels missing in" +
                " optimal aperture must be greater than or equal to zero.");
        }
        
        if (k2Campaign < -1) {
            throw new IllegalArgumentException("k2Campaign must be greater"
                + " than or equal to negative one.  I got " + k2Campaign);
        }
        
        this.targetAperture = targetAperture;

        this.crowdingMetric = crowdingMetric;
        this.fluxFractionInOptimalAperture = fluxFractionInOptimalAperture;
        this.targetDroppedBySupplmentalTad = targetDroppedBySupplementalTad;
        this.nPixelsMissingInOptimalAperture = 
            targetDroppedBySupplementalTad ? 0 : nPixelsMissingInOptimalAperture;
        this.ccdOutput = ccdOutput;
        this.ccdModule = ccdModule;
        this.k2Campaign = k2Campaign;
        this.targetTableId = targetTableId;
        this.isK2 = isK2;
        
        fluxCentroidRowId = 
            PaFsIdFactory.getCentroidTimeSeriesFsId(FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                PaFsIdFactory.CentroidTimeSeriesType.CENTROID_ROWS,
                cadenceType, celestialObject.getKeplerId());
        fluxCentroidColumnId =
            PaFsIdFactory.getCentroidTimeSeriesFsId(FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                PaFsIdFactory.CentroidTimeSeriesType.CENTROID_COLS,
                cadenceType, celestialObject.getKeplerId());
        if (cadenceType == CadenceType.LONG) {
            fluxCentroidLcColumnId = fluxCentroidColumnId;
            fluxCentroidLcRowId = fluxCentroidRowId;
        } else {
            fluxCentroidLcColumnId = PaFsIdFactory.getCentroidTimeSeriesFsId(FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                PaFsIdFactory.CentroidTimeSeriesType.CENTROID_COLS,
                CadenceType.LONG, celestialObject.getKeplerId());
            fluxCentroidLcRowId = PaFsIdFactory.getCentroidTimeSeriesFsId(FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                PaFsIdFactory.CentroidTimeSeriesType.CENTROID_ROWS,
                CadenceType.LONG, celestialObject.getKeplerId());
        }
        
        Pair<Set<FsId>, Set<FsId>> rbFlagSets = 
            createRollingBandFsIds(ccdModule, ccdOutput, aperturePixels, rollingBandPulseDurationsLc);
        rollingBandFlagsFsIds = rbFlagSets.left;
        rollingBandFlagsOptimalApertureFsIds = rbFlagSets.right;
        
        collateralCosmicRayIds = collateralCosmicRayIds(ccdModule, ccdOutput, aperturePixels);
    }

    protected void addCommonTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet) {
        totalSet.put(pdcDiscontinuityId, TimeSeriesDataType.IntType);
        totalSet.put(fluxCentroidRowId, TimeSeriesDataType.DoubleType);
        totalSet.put(fluxCentroidColumnId, TimeSeriesDataType.DoubleType);
        if (cadenceType == CadenceType.LONG) {
            totalSet.put(fluxCentroidLcRowId, TimeSeriesDataType.DoubleType);
            totalSet.put(fluxCentroidLcColumnId, TimeSeriesDataType.DoubleType);
        }
    }
    
    /**
     * 
     * @param allTimeSeries non-null
     * @return returns a non-null list containing the centroid related time series
     * generated by PA.  This list may be empty.
     */
    public List<TimeSeries> fluxCentroidTimeSeries(Map<FsId,TimeSeries> allTimeSeries) {
    	List<TimeSeries> centroidTimeSeries = new ArrayList<TimeSeries>(2);
    	if (allTimeSeries.containsKey(fluxCentroidColumnId)) {
    		centroidTimeSeries.add(allTimeSeries.get(fluxCentroidColumnId));
    	}
    	if (allTimeSeries.containsKey(fluxCentroidRowId)) {
    		centroidTimeSeries.add(allTimeSeries.get(fluxCentroidRowId));
    	}
    	return centroidTimeSeries;
    }
    
    /**
     * 
     * @param externalTtableId this parameter is ignored
     * @return
     */
    @Override
    public final Set<FsId> rollingBandFlagsFsId(int externalTtableId) {
        return rollingBandFlagsFsIds;
    }
    
    /**
     * 
     * @param externalTtableId this parameter is ignored.
     * @return
     */
    @Override
    public final Set<FsId> rollingBandFlagsOptimalApertureFsId(int externalTtableId) {
        return rollingBandFlagsOptimalApertureFsIds;
    }
    
    /**
     * @param externalTargetTableId this parameter is ignored.
     * @return This may return null if rolling band flags are not available.
     */
    public final RollingBandFlags rollingBandFlags(int externalTargetTableId) {
        return rollingBandFlags;
    }
    
    /**
     * @param externalTargetTableId this parameter is ignored
     * @return This may return null if rolling band flags are not available.
     */
    public final RollingBandFlags optimalApertureRollingBandFlags(int externalTargetTableId) {
       return optimalApertureRollingBandFlags; 
    }
    
    /**
     * @param externalTargetTableId this parameter is ignored
     */
    @Override
    public final void setRollingBandFlags(RollingBandFlags rbFlags, int externalTargetTableId) {
        this.rollingBandFlags = rbFlags;
    }
    
    /**
     * @param externalTargetTableId this parameter is ignored
     */
    @Override
    public final void setOptimalApertureRollingBandFlags(RollingBandFlags rbFlags, int externalTargetTableId) {
        this.optimalApertureRollingBandFlags = rbFlags;
    }
    
    /**
     * The number of HDUs being exported.
     * @return a positive integer
     */
    public int hduCount() {
        return 3;
    }
    
    protected void addCommonMjdTimeSeriesIds(Set<FsId> totalSet) {
        totalSet.add(pdcOutlierId);
        
        totalSet.addAll(collateralCosmicRayIds);
    }
    
    /**
     * Use this to add time series that need to be fetched at long cadence.
     * This default implementation does nothing.
     * @param totalSet non-null
     */
    public void addToLongCadenceFsIds(Map<FsId, TimeSeriesDataType> lcSet) {
        if (cadenceType == CadenceType.SHORT) {
            lcSet.put(fluxCentroidLcRowId, TimeSeriesDataType.DoubleType);
            lcSet.put(fluxCentroidLcColumnId, TimeSeriesDataType.DoubleType);
        }
    }
    
    public final boolean isCustomTarget() {
        return TargetManagementConstants.isCustomTarget(keplerId());
    }
    
    /**
     * 
     * @return this may return null
     */
    public final TargetAperture targetAperture() {
        return targetAperture;
    }
    
    public void setTargetAperture(TargetAperture targetAperture) {
        if (targetAperture == null) {
            throw new NullPointerException("targetAperture");
        }
        if (this.targetAperture != null) {
            throw new IllegalStateException("this.targetAperture is not null");
        }
        this.targetAperture = targetAperture;
    }
    
    /**
     * The target was dropped in a supplemental TAD run, but we collected pixels
     * for this target.
     * @return
     */
    public final boolean targetDroppedBySupplementalTad() {
        return targetDroppedBySupplmentalTad;
    }
    
    /**
     * 
     * @return  This may return a null value.
     */
    public Double crowdingMetric() {
        return crowdingMetric;
    }
    
    /**
     * 
     * @return This may return null.
     */
    public Double fluxFractionInOptimalAperture() {
        return fluxFractionInOptimalAperture;
    }
    
    public final TargetImageDimensions imageDimensions() {
        if (imageDimensions == null) {
            imageDimensions =
                imageDimensionsCalculator.imageDimensions(aperturePixels());
        }
        return this.imageDimensions;
    }
    
    /**
     * When the supplemental tad run was performed some pixels in the new
     * optimal aperture may not have been collected.
     * @return
     */
    public final int nPixelsMissingInOptimalAperture() {
        return nPixelsMissingInOptimalAperture;
    }
    
    @Override
    public final int ccdChannel() {
        return FcConstants.getChannelNumber(ccdModule(), ccdOutput());
    }

    @Override
    public final ObservingMode observingMode() {
        return ObservingMode.valueOf(cadenceType);
    }
    
    /**
     * The long cadence data quality flags are used to calculate reference
     * cadences for the purpose of calculating RA/DEC, DVA, etc.  In the case
     * of long cadence this may be the same as the dataQualityFlags.  These 
     * flags should not be exported to a file.
     * @param longCadenceQualityFlags
     */
    public final void setLongCadenceDataQualityFlags(int[] longCadenceQualityFlags) {
        this.longCadenceQualityFlags = longCadenceQualityFlags;
    }
    
    @Override
    public final int longReferenceCadence(Map<FsId, TimeSeries> allTimeSeries, 
        boolean ignoreZeroCrosssingEvents) {
        if (cadenceType == CadenceType.SHORT && longCadenceQualityFlags == null) {
            throw new NullPointerException("need long cadence data quality flags in order to compute proper long reference cadence");
        }
        
        DoubleTimeSeries rowCentroidLcTs = allTimeSeries.get(fluxCentroidLcRowId).asDoubleTimeSeries();
        DoubleTimeSeries columnCentroidLcTs = allTimeSeries.get(fluxCentroidLcColumnId).asDoubleTimeSeries();
        
        int[] qualityFlags = (cadenceType == CadenceType.SHORT) ? 
            longCadenceQualityFlags : dataQualityFlags();
        
        Pair<Integer, Integer> nativeAcutals = actualStartAndEnd(allTimeSeries);
        int lcActualStart = cadenceToLongCadence(nativeAcutals.left);
        int lcActualEnd = cadenceToLongCadence(nativeAcutals.right);
        int qualityMask = ReferenceCadenceCalculator.BAD_QUALITY_FLAGS;
        if (ignoreZeroCrosssingEvents) {
            qualityMask &= ~QualityFieldCalculator.REACTION_WHEEL_0_CROSSING;
        }
        if (isK2) {
            qualityMask &= ~QualityFieldCalculator.DETECTOR_ELECTRONICS_ANOMALY;
        }

        int refCadence = -1000000;
        if (rowCentroidLcTs.isEmpty() || columnCentroidLcTs.isEmpty()) {
            log.warn("Target " + keplerId() + " is missing PA generated centroids.");
            refCadence = referenceCadenceCalculator.referenceCadence(longCadenceTimes().cadenceNumbers[0],
                    lcActualStart, lcActualEnd, longCadenceTimes(), qualityFlags, qualityMask);
        } else {
            refCadence = referenceCadenceCalculator.referenceCadence(longCadenceTimes().cadenceNumbers[0],
                    lcActualStart, lcActualEnd, longCadenceTimes(), qualityFlags, rowCentroidLcTs, columnCentroidLcTs, qualityMask);
        }
        
        return refCadence;
        
    }
    
    @Override
    public final Pair<Double, Double> rowColumnCentroid(Map<FsId,TimeSeries> allTimeSeries, boolean ignoreZeroCrossings) {
        DoubleTimeSeries rowCentroidLcTs = allTimeSeries.get(fluxCentroidLcRowId).asDoubleTimeSeries();
        DoubleTimeSeries columnCentroidLcTs = allTimeSeries.get(fluxCentroidLcColumnId).asDoubleTimeSeries();
        
        if (rowCentroidLcTs.isEmpty() || columnCentroidLcTs.isEmpty()) {
            return centroidCalculator.apertureCentroid(aperturePixels());
        }
        
        int refCadence =  longReferenceCadence(allTimeSeries, ignoreZeroCrossings);
        
        double row = rowCentroidLcTs.dseries()[refCadence - rowCentroidLcTs.startCadence()];
        double col = columnCentroidLcTs.dseries()[refCadence - columnCentroidLcTs.startCadence()];
        return Pair.of(row, col);
    }
    
    public final TargetDva dva() {
        return targetDva;
    }
    
    public final void setDva(TargetDva targetDva) {
        this.targetDva = targetDva;
    }
    
    public final TargetWcs wcs() {
        return targetWcs;
    }
    
    public final void setWcs(TargetWcs targetWcs) {
        this.targetWcs = targetWcs;
    }
    
    @Override
    public final Set<FloatMjdTimeSeries> optimalApertureCollateralCosmicRays(Map<FsId, FloatMjdTimeSeries> allSeries, int externalTtableId) {
        Set<FloatMjdTimeSeries> rv = new HashSet<FloatMjdTimeSeries>(collateralCosmicRayIds.size() * 2);
        for (FsId collateralFsId : this.collateralCosmicRayIds) {
            rv.add(allSeries.get(collateralFsId));
        }
        return rv;
    }
    
    /**
     * All of the time series FsIDs required to export a file.
     * @return non-null
     */
    protected abstract Set<FsId> allTimeSeriesIds();
    
    /**
     * 
     * @param nativeCadence a long cadence if this is long cadence a short
     * cadence if this is short cadence
     */
    protected abstract int cadenceToLongCadence(int nativeCadence);
    
    /**
     * 
     * @return the long cadence timestamp series for this unit of work else
     * the short cadence timestamp series for this unit of work if this is short
     * cadence.
     */
    protected abstract TimestampSeries cadenceTimes();
    
    protected abstract TimestampSeries longCadenceTimes();
    
    @Override
    public final double ra() {
        return celestialObject().getRa();
    }

    @Override
    public  final double dec() {
        return celestialObject().getDec();
    }
    
    @Override
    public final int ccdModule() {
        return ccdModule;
    }
    
    @Override
    public final int ccdOutput() {
        return ccdOutput;
    }

    @Override
    public final int k2Campaign() {
        return k2Campaign;
    }
    
    /**
     * 
     * @return true when exporting for K2, false otherwise.
     */
    public final boolean isK2Target() {
        return isK2;
    }
    
    @Override
    public final int targetTableId() {
        return targetTableId;
    }

}
