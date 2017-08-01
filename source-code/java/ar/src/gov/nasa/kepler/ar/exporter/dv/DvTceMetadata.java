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

import static gov.nasa.kepler.mc.fs.DvFsIdFactory.*;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.*;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType.*;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.*;
import static gov.nasa.kepler.fs.api.TimeSeriesDataType.*;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayWriter;
import gov.nasa.kepler.ar.exporter.flux2.Accessor;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.dv.DvModelParameter;
import gov.nasa.kepler.hibernate.dv.DvPlanetCandidate;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.util.*;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * Data pertaining to a single Threshold Crossing Event that is to be exported
 * with the Data Validation archive. These data appear in the header of a TCE
 * HDU in a Data Validation FITS file.
 * This is intended to be part of the Model in the Model-View-Controller
 * pattern. As such, it should not be aware of FITS and its requirements.
 * @author lbrownst
 * @author Sean McCauliff
 */
class DvTceMetadata  {
    /** This is the FluxType of all exported light curves. */
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    
    /** To convert cadences to hours. */
    private static final float HOURS_PER_CADENCE = 0.49f;
    
    private final int keplerId;
    
    /** The order in which the TCE was discovered, 1-based. */
    private final int    planetNumber;

    /** Transit period in days. */
    private final double  period;

    private final double  epoch;
    /** Fitted depth in PPM. */
    private final Double  transitDepth;
    /** Transit signal-to-noise ratio. */
    private final Float   transitSignalToNoiseRatio;
    /** Transit duration in hours. */
    private final Double  transitDurationHours;
    /** Ingress duration in hours. */
    private final Double  ingressDurationHours;
    /** Impact parameter. */
    private final Double  impact;
    /** Inclination in degrees. */
    private final Double  inclinationDegrees;
    /** Planet distance over star radius. */
    private final Double  planetDistanceStarRadiusRatio;
    /** Planet star radius ratio. */
    private final Double  planetRadiusStarRadiusRatio;
    /** Planet radius in earth radii. */
    private final Double  planetRadiusWrtEarth;
    /** Maximum multi-event statistic. */
    private final float   maxMes;
    /** Maximum single-event statistic. */
    private final float   maxSes;
    /** Number of transits for this TCE. */
    private final int     transitCount;
    /** Convergence. */
    private final Boolean convergence;
    /** Length of the median detrender in hours. */
    private final Float   medianDetrendWindowHours;

    private final FsId phaseFsId;
    /** LC_INIT */
    private final FsId quarterStitchedInitialLightCurveFsId;
    /** LC_INIT_ERR */
    private final FsId quarterStitchedInitialLightCurveErrorFsId;
    /** filled indices for LC_INIT AND LC_INIT_ERR. */
    private final FsId quarterStitchedInitialLightCurveFillFsId;
    
    /** LC_WHITE */
    private final FsId initialWhitenedLightCurveFsId;
    /** LC_DETREND */
    private final FsId initialMedianDetrendedLightCurveFsId;
    /** Fill for LC_DETREND */
    private final FsId initialMedianDetrendedLightCurveFillFsId;
    /** MODEL_INIT */
    private final FsId initialModelLightCurveFsId;
    /** MODEL_WHITE */
    private final FsId whitenedModelLightCurveFsId;
    
    private final Map<FsId, TimeSeriesDataType> fsIdsToType;
    
    /**
     * The only constructor sets all fields, obtaining them from a
     * DvPlanetResults object.
     * @param keplerId2 
     */
    DvTceMetadata(DvPlanetResults dvPlanetResults, long dvPipelineInstanceId) {
        DvPlanetCandidate dvPlanetCandidate =
            dvPlanetResults.getPlanetCandidate();
        
        planetNumber         = dvPlanetCandidate.getPlanetNumber();
        maxMes               = dvPlanetCandidate.getMaxMultipleEventSigma();
        maxSes               = dvPlanetCandidate.getMaxSingleEventSigma();
        transitCount         = dvPlanetCandidate.getObservedTransitCount();
        
        keplerId = dvPlanetResults.getKeplerId();
        
        DvPlanetModelFit allTransitsModelFit =
            dvPlanetResults.getAllTransitsFit();
        
        if (allTransitsModelFit == null) {
            //Joe says this should never happen.
            transitDepth = null;
            transitSignalToNoiseRatio = null;
            transitDurationHours = (double) dvPlanetCandidate.getTrialTransitPulseDuration();
            ingressDurationHours = null;
            impact = null;
            inclinationDegrees = null;
            planetDistanceStarRadiusRatio = null;
            planetRadiusStarRadiusRatio = null;
            planetRadiusWrtEarth = null;
            convergence = null;
            //Use TPS results if the FIT failed.
            period = dvPlanetCandidate.getOrbitalPeriod();
            epoch = ModifiedJulianDate.mjdToKjd(dvPlanetCandidate.getEpochMjd());
        } else if (allTransitsModelFit.getModelChiSquare() == -1 ) {
            //Fit failed, but some of the TPS results will still be in there.
            List<DvModelParameter> allTransitFitModelParameters =
                allTransitsModelFit.getModelParameters();
            
            Map<String, DvModelParameter> modelParameterToValue =
                new HashMap<String, DvModelParameter>();
            
            for (DvModelParameter parameter : allTransitFitModelParameters) {
                String parameterName = parameter.getName();
                modelParameterToValue.put(parameterName, parameter);
            }
            
            epoch = lookup("transitEpochBkjd", modelParameterToValue);
            period = lookup("orbitalPeriodDays", modelParameterToValue);
            transitDurationHours = lookup("transitDurationHours", modelParameterToValue);
            transitDepth = null;
            transitSignalToNoiseRatio = null;
            ingressDurationHours = null;
            impact = null;
            inclinationDegrees = null;
            planetDistanceStarRadiusRatio = null;
            planetRadiusStarRadiusRatio = null;
            planetRadiusWrtEarth = null;
            convergence = null;
        } else {
            List<DvModelParameter> allTransitFitModelParameters =
                allTransitsModelFit.getModelParameters();
            
            Map<String, DvModelParameter> modelParameterToValue =
                new HashMap<String, DvModelParameter>();
            
            for (DvModelParameter parameter : allTransitFitModelParameters) {
                String parameterName = parameter.getName();
                modelParameterToValue.put(parameterName, parameter);
            }
            
            transitDepth = lookup("transitDepthPpm", modelParameterToValue);
            transitSignalToNoiseRatio = allTransitsModelFit.getModelFitSnr();
            transitDurationHours = lookup("transitDurationHours", modelParameterToValue);
            ingressDurationHours = lookup("transitIngressTimeHours", modelParameterToValue);
            impact = lookup("minImpactParameter", modelParameterToValue);
            inclinationDegrees = lookup("inclinationDegrees", modelParameterToValue);
            planetDistanceStarRadiusRatio = lookup("ratioSemiMajorAxisToStarRadius", modelParameterToValue);
            planetRadiusStarRadiusRatio = lookup("ratioPlanetRadiusToStarRadius", modelParameterToValue);
            planetRadiusWrtEarth = lookup("planetRadiusEarthRadii", modelParameterToValue);
            convergence = allTransitsModelFit.isFullConvergence();
            epoch = lookup("transitEpochBkjd", modelParameterToValue);
            period = lookup("orbitalPeriodDays", modelParameterToValue);
        } 
        
        if (dvPlanetResults.getDetrendFilterLength() == 0) {
            medianDetrendWindowHours = defaultMedianDetrendWindowLengthHr(transitDurationHours);
        } else {
            medianDetrendWindowHours = dvPlanetResults.getDetrendFilterLength() * HOURS_PER_CADENCE;
        }
        
        phaseFsId =
            getFoldedPhaseTimeSeriesFsId(FLUX_TYPE, dvPipelineInstanceId,
                keplerId, planetNumber);
        
        quarterStitchedInitialLightCurveFsId = 
            getCorrectedFluxTimeSeriesFsId(FLUX_TYPE, INITIAL,
                FLUX, dvPipelineInstanceId, keplerId, planetNumber);
        quarterStitchedInitialLightCurveErrorFsId = 
            getCorrectedFluxTimeSeriesFsId(FLUX_TYPE, INITIAL,
                UNCERTAINTIES, dvPipelineInstanceId, keplerId, planetNumber);
        quarterStitchedInitialLightCurveFillFsId = 
            getCorrectedFluxTimeSeriesFsId(FLUX_TYPE, INITIAL,
                FILLED_INDICES, dvPipelineInstanceId, keplerId, planetNumber);
        
        //Not sure why this string is needed, but it seems like DV
        //itself does this.  This being the last release I would 
        //rather not merge any changes into DV in order to fix this.
        final String WHITENED_FLUX = "WhitenedFlux";
        initialWhitenedLightCurveFsId =
            getFluxTimeSeriesFsId(FLUX_TYPE, WHITENED_FLUX,
                dvPipelineInstanceId, keplerId, planetNumber);

        initialMedianDetrendedLightCurveFsId = 
            getCorrectedFluxTimeSeriesFsId(FLUX_TYPE, DETRENDED, FLUX, 
                dvPipelineInstanceId, keplerId, planetNumber);
        
        initialMedianDetrendedLightCurveFillFsId = 
            getCorrectedFluxTimeSeriesFsId(FLUX_TYPE, DETRENDED, FILLED_INDICES, 
                dvPipelineInstanceId, keplerId, planetNumber);

        initialModelLightCurveFsId = getLightCurveTimeSeriesFsId(FLUX_TYPE,
            MODEL_LIGHT_CURVE, dvPipelineInstanceId, keplerId, planetNumber);
        
        whitenedModelLightCurveFsId = getLightCurveTimeSeriesFsId(FLUX_TYPE,
            WHITENED_MODEL_LIGHT_CURVE, dvPipelineInstanceId, keplerId, planetNumber);

        ImmutableMap.Builder<FsId, TimeSeriesDataType> bldr = 
            new ImmutableMap.Builder<FsId, TimeSeriesDataType>();
        bldr.put(phaseFsId, FloatType)
            .put(quarterStitchedInitialLightCurveFsId, FloatType)
            .put(quarterStitchedInitialLightCurveErrorFsId, FloatType)
            .put(quarterStitchedInitialLightCurveFillFsId, IntType)
            .put(initialWhitenedLightCurveFsId, FloatType)
            .put(initialMedianDetrendedLightCurveFsId, FloatType)
            .put(initialMedianDetrendedLightCurveFillFsId, IntType)
            .put(initialModelLightCurveFsId, FloatType)
            .put(whitenedModelLightCurveFsId, FloatType);
        fsIdsToType = bldr.build();
    }
    
    /**
     * @return null if the map doesn't contain the key or the key is mapped to
     * a null {@link DvModelParameter}; otherwise the value of the
     * {@link DvModelParameter}
     * @throws NullPointerException if parameterMap is null
     */
    private static Double lookup(String parameterName,
        Map<String, DvModelParameter> parameterMap) {
  
        // Look up the DvModelParameter by name
        DvModelParameter dvModelParameter = parameterMap.get(parameterName);
        Double parameterValue = 
            (dvModelParameter == null)  ? null : dvModelParameter.getValue();
        return parameterValue;
    }
    
    int planetNumber() {
    	return planetNumber;
    }
    
    int    index()    { 
    	return planetNumber;
	}
    
    double period()   {
    	return period;
	}
    /**
     * Transit epoch in BKJD.
     * This has to be a double because it includes both integral numbers of
     * days and fractional days with centisecond precision.
     * 
     * If the fit fails then this is just in JKD.
     */
    double epoch()    { 
    	return epoch;
	}
    
    Double transitDepth() {
    	return transitDepth;
	}
    Float  transitSignalToNoiseRatio() { 
    	return transitSignalToNoiseRatio;
	}
    Double transitDurationHours() { 
    	return transitDurationHours;
	}
    Double ingressDurationHours() { 
    	return ingressDurationHours;
	}
    Double impact() { 
    	return impact; 
	}
    Double inclinationDegrees() {
    	return inclinationDegrees;
	}
    Double planetDistanceStarRadiusRatio() {
    	return planetDistanceStarRadiusRatio;
    }
    Double planetRadiusStarRadiusRatio() { 
    	return planetRadiusStarRadiusRatio;
	}
    Double planetRadiusWrtEarth() { 
    	return planetRadiusWrtEarth;
	}
    float maxMes() { 
    	return maxMes;
	}
    float maxSes() { 
    	return maxSes;
	}
    int   transitCount() { 
    	return transitCount;
	}
    Boolean convergence() { 
    	return convergence;
	}
    Float medianDetrendWindowHours() { 
    	return medianDetrendWindowHours;
    }
    
    /** @return a Set of all FsIds for the TCE. */
    Set<FsId> allFsIds() {
        return fsIdsToType.keySet();
    }
    
    /**
     * Insert into the Map pairs of FsId and the data type of the time series
     * that the FsId specifies.
     * @param an out parameter to which pairs are added
     */
    void addTimeSeriesIdsTo(Map<FsId, TimeSeriesDataType> totalSet) {
        totalSet.putAll(fsIdsToType);
    }
    
    /**
     * This method has the same signature as
     * AbstractTargetMetadata.allTimeSeriesIds()
     * @return a set containing all FsIds needed to export time series for this
     * TCE.
     */
    Set<FsId> allTimeSeriesIds() {
        return fsIdsToType.keySet();
    }

    
    void unfill(Map<FsId, TimeSeries> allTimeSeries) {
        
        unfillTimeSeries(quarterStitchedInitialLightCurveFsId,
            quarterStitchedInitialLightCurveFillFsId,
            allTimeSeries);
        
        unfillTimeSeries(quarterStitchedInitialLightCurveErrorFsId,
            quarterStitchedInitialLightCurveFillFsId,
            allTimeSeries);
        
        unfillTimeSeries(initialWhitenedLightCurveFsId,
            initialMedianDetrendedLightCurveFillFsId,
            allTimeSeries);
        
        unfillTimeSeries(initialMedianDetrendedLightCurveFsId,
            initialMedianDetrendedLightCurveFillFsId,
            allTimeSeries);
        
    }
    
    static void unfillTimeSeries(FsId lightCurveId, FsId fillIndexId,
        Map<FsId, TimeSeries> allTimeSeries) {
        
        FloatTimeSeries lightCurve = allTimeSeries.get(lightCurveId).asFloatTimeSeries();
        IntTimeSeries fillIndices = allTimeSeries.get(fillIndexId).asIntTimeSeries();
        
        FluxTimeSeriesProcessing.unfill(lightCurve.fseries(), Float.NaN, fillIndices);
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
    public List<ArrayWriter> organizeData(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeries, float gapFill,
        int intGapFill, ExposureCalculator exposureCalculator,
        MjdToCadence mjdToCadence) {

        Accessor a = new Accessor(allTimeSeries, gapFill, intGapFill, exposureCalculator);
        
        return ImmutableList.of(
            a.farray(phaseFsId, false),
            a.farray(quarterStitchedInitialLightCurveFsId, false),
            a.farray(quarterStitchedInitialLightCurveErrorFsId, false),
            a.farray(initialWhitenedLightCurveFsId, false),
            a.farray(initialMedianDetrendedLightCurveFsId, false),
            a.farray(initialModelLightCurveFsId, false),
            a.farray(whitenedModelLightCurveFsId, false)
            );
    }
    
    /**
     * The default is based on the 9.2 default that is computed in DV.
     * This is the five times the transit duration in cadences, but we want
     * to round up the nearest whole, even number.  The specification for
     * the FITS file wants us to express this number in hours so we
     * convert it back to hours.
     * @param modelTransitDuration
     * @return a positive, non-nan, non-infnite value.
     */
    static float defaultMedianDetrendWindowLengthHr(double modelTransitDuration) {
        double windowLengthInCadences = 
            Math.ceil((modelTransitDuration / HOURS_PER_CADENCE * 5.0) / 2.0) * 2;
        float windowLengthInHours = 
            (float) (windowLengthInCadences * HOURS_PER_CADENCE);
        return windowLengthInHours;
    }
}
