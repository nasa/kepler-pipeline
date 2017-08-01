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

import static gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType.DEFINITE_THRUSTER_ACTIVITY;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType.POSSIBLE_THRUSTER_ACTIVITY;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.ar.exporter.tpixel.DataQualityFlagsSource;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;

/**
 * Stuff we need to know in order to generate data quality flags.
 * Some information is contained in each target and not in this class.
 * 
 * This is only valid for a single target table.  If your light curves are
 * multiquarter then you will need to instantiate more than one of these
 * objects.
 * 
 * @author Sean McCauliff
 *
 */
public class DataQualityMetadata<M extends AbstractTargetMetadata> implements DataQualityFlagsSource {

    
    private final FsId paArgabrighteningFsId;
    private final FsId thrusterFiringId;
    private final FsId possibleThrusterFiringId;
    private final FsId zeroCrossingFsId;
     
    private final CadenceType cadenceType;
    private final int startCadence;
    private final int endCadence;
    private final List<DataAnomaly> dataAnomalies;
    private final MjdToCadence mjdToCadence;
    private final TimestampSeries timestampSeries;
    private final TimestampSeries lcTimestampSeries;
    private final boolean lcForShortCadence;
    private final int ttableExternalId;
    private final int lcTtableExternalId;
    
    private final QualityFieldCalculator qualityFieldCalculator
        = new QualityFieldCalculator();
    
    /**
     * This gets set later, perhaps multiple times.
     */
    private M targetMetadata;
    
    /** This gets set later. */
    private Map<FsId, TimeSeries> allTimeSeries;
   
    /** This gets set later. */
    private Map<FsId, FloatMjdTimeSeries> mjdTimeSeries;
    
    /**
     * 
     * @param targetTableExternalId
     * @param lcExternalTargetTableId
     * @param cadenceType
     * @param isShortCadence  This is important.  As this can be a long cadence
     * data quality metadata instance, but the actual time series we are
     * exporting is short cadence.  
     * @param ccdModule
     * @param ccdOutput
     * @param startCadence
     * @param endCadence
     * @param dataAnomalies
     * @param rollingBandFlags null ok.
     * @param lcTimestampSeries null ok.
     */
    public DataQualityMetadata(int targetTableExternalId, 
        int lcExternalTargetTableId, CadenceType cadenceType,
        boolean isShortCadence,
        int ccdModule, int ccdOutput,
        int startCadence, int endCadence,
        List<DataAnomaly> dataAnomalies,
        MjdToCadence mjdToCadence,
        TimestampSeries timestampSeries,
        TimestampSeries lcTimestampSeries
        ) {

        checkNotNull(dataAnomalies, "dataAnomalies");
        checkNotNull(mjdToCadence, "mjdToCadence");
        checkNotNull(timestampSeries, "timestampSeries");
        
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.dataAnomalies = dataAnomalies;
        this.timestampSeries = timestampSeries;
        this.lcTimestampSeries = lcTimestampSeries;
        this.mjdToCadence = mjdToCadence;
        this.cadenceType = cadenceType;
        this.lcTtableExternalId = lcExternalTargetTableId;
        this.ttableExternalId = targetTableExternalId;
        
        /** This is the metadata for the covering long cadences. */
        this.lcForShortCadence = cadenceType == CadenceType.LONG && isShortCadence;
        
        paArgabrighteningFsId = PaFsIdFactory.getArgabrighteningFsId(
            cadenceType, targetTableExternalId,
            ccdModule, ccdOutput);
        
        thrusterFiringId = PaFsIdFactory.getThrusterActivityFsId(cadenceType, DEFINITE_THRUSTER_ACTIVITY);
        possibleThrusterFiringId = PaFsIdFactory.getThrusterActivityFsId(cadenceType, POSSIBLE_THRUSTER_ACTIVITY);  
        zeroCrossingFsId = PaFsIdFactory.getZeroCrossingFsId(cadenceType);
    }
    
    
    public void addTimeSeriesTo(Map<FsId, TimeSeriesDataType> fsIdToType) {
        fsIdToType.put(thrusterFiringId, TimeSeriesDataType.IntType);
        fsIdToType.put(possibleThrusterFiringId, TimeSeriesDataType.IntType);
        fsIdToType.put(zeroCrossingFsId, TimeSeriesDataType.IntType);
        fsIdToType.put(paArgabrighteningFsId, TimeSeriesDataType.IntType);
    }

    /**
     * Set this later, after the file store fetch has been done.
     *  
     * @param allTimeSeries non-null, this gets stored in this object.
     */
    public void setAllTimeSeries(Map<FsId, TimeSeries> allTimeSeries) {
        checkNotNull(allTimeSeries, "allTimeSeries");
        this.allTimeSeries = allTimeSeries;
    }
    
    public void setAllMjdTimeSeries(Map<FsId, FloatMjdTimeSeries> mjdTimeSeries) {
        checkNotNull(mjdTimeSeries, "mjdTimeSeries");
        this.mjdTimeSeries = mjdTimeSeries;
    }

    public void setTargetMetadata(M targetMetadata) {
        checkNotNull(targetMetadata, "targetMetadata");
        this.targetMetadata = targetMetadata;
    }
    
    @Override
    public boolean isLcForShortCadence() {
        return lcForShortCadence;
    }
    
    @Override
    public int startCadence() {
        return startCadence;
    }

    @Override
    public int endCadence() {
        return endCadence;
    }

    @Override
    public List<DataAnomaly> anomalies() {
        return this.dataAnomalies;
    }

    @Override
    public Collection<FloatMjdTimeSeries> cosmicRays() {
        if (lcForShortCadence) {
            return Collections.emptyList();
        } else {
            return targetMetadata.optimalApertureCosmicRays(mjdTimeSeries, ttableExternalId).values();
        }
    }

    @Override
    public Collection<FloatMjdTimeSeries> collateralCosmicRays() {
        if (lcForShortCadence) {
            return Collections.emptyList();
        } else {
            return targetMetadata.optimalApertureCollateralCosmicRays(mjdTimeSeries, ttableExternalId);
        }
    }

    @Override
    public RollingBandFlags rollingBandFlags() {
        if (this.lcForShortCadence) {
            return null;
        } else {
            return targetMetadata.rollingBandFlags(lcTtableExternalId);
        }
    }

    @Override
    public MjdToCadence mjdToCadence() {
        return mjdToCadence;
    }

    @Override
    public TimestampSeries timestampSeries() {
        return timestampSeries;
    }

    @Override
    public TimestampSeries lcTimestampSeries() {
        return lcTimestampSeries;
    }

    @Override
    public FloatMjdTimeSeries pdcOutliers() {
        if (this.lcForShortCadence) {
            return new FloatMjdTimeSeries(new FsId("/empty/0"), 0,
                Double.MAX_VALUE, ArrayUtils.EMPTY_DOUBLE_ARRAY,
                ArrayUtils.EMPTY_FLOAT_ARRAY, ArrayUtils.EMPTY_LONG_ARRAY,
                false);
        } else {
            return targetMetadata.pdcOutliers(mjdTimeSeries);
        }
    }

    @Override
    public IntTimeSeries discontinuityTimeSeries() {
        if (this.lcForShortCadence) {
            return null;
        } else {
            return targetMetadata.pdcDiscontinuitySeries(allTimeSeries);
        }
    }

    @Override
    public IntTimeSeries paArgabrighteningTimeSeries() {
        return allTimeSeries.get(paArgabrighteningFsId).asIntTimeSeries();
    }

    @Override
    public IntTimeSeries reactionWheelZeroCrossings() {
        return allTimeSeries.get(zeroCrossingFsId).asIntTimeSeries();
    }

    @Override
    public IntTimeSeries thrusterFire() {
        return allTimeSeries.get(thrusterFiringId).asIntTimeSeries();
    }

    @Override
    public IntTimeSeries possibleThusterFire() {
        return allTimeSeries.get(possibleThrusterFiringId).asIntTimeSeries();
    }

    public CadenceType cadenceType() {
        return cadenceType;
    }
    
    public int[] calculateDataQualityFlags() {
        return qualityFieldCalculator.calculateQualityFlags(this);
    }


    @Override
    public RollingBandFlags optimalApertureRollingBandFlags() {
        if (this.lcForShortCadence) {
            return null;
        } else {
            return targetMetadata.optimalApertureRollingBandFlags(this.lcTtableExternalId);
        }
    }
}
