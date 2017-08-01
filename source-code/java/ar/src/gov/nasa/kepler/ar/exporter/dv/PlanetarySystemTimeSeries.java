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

import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getBarycentricCorrectedTimestampsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getCorrectedFluxTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getLightCurveTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getResidualTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getSingleEventStatisticsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.parseSingleEventStatisticsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.INITIAL;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType.CORRELATION;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType.NORMALIZATION;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType.FILLED_INDICES;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType.FLUX;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType.UNCERTAINTIES;
import gnu.trove.TFloatHashSet;
import gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dv.DvCrud.DvPlanetSummary;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.SingleEventParse;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Collect all the FsIds about a system.
 * 
 * @author Sean McCauliff
 *
 */
class PlanetarySystemTimeSeries {
    private final DvPlanetSummary system;
    
    private final FsId residualFluxFsId;
    private final FsId residualFluxUncertFsId;
    private final FsId residualFluxFilledIndicesFsId;
    
    private final FsId[/* planet number*/] initialFluxFsId;
    private final FsId[/* planet number*/] initialFluxUncertFsId;
    private final FsId[/* planet number*/] initialFluxFilledIndicesFsId;
    private final FsId[/* planet number */] modelLightCurveFsId;
    
    
    private final FsId[/* trial transit pulse*/] correlatedSingleEventFsId;
    private final FsId[/* trial transit pulse*/] normalizedSingleEventFsId;
    
    private final float[] trialTransitPulse;
    
    private final FsId dvBarycentricCorrectedTime;
    
    PlanetarySystemTimeSeries(DvPlanetSummary system, List<FsId> singleEventIds, FluxType fluxType) {
        this.system = system;

        residualFluxFsId = getResidualTimeSeriesFsId(fluxType, FLUX, 
            system.pipelineInstanceId, system.keplerId);

        residualFluxUncertFsId = getResidualTimeSeriesFsId(fluxType, UNCERTAINTIES, 
            system.pipelineInstanceId, system.keplerId);
        residualFluxFilledIndicesFsId = getResidualTimeSeriesFsId(fluxType, FILLED_INDICES, 
            system.pipelineInstanceId, system.keplerId);
        
        initialFluxFsId = new FsId[system.planetNumbers.length];
        initialFluxUncertFsId = new FsId[system.planetNumbers.length];
        initialFluxFilledIndicesFsId = new FsId[system.planetNumbers.length];
        modelLightCurveFsId = new FsId[system.planetNumbers.length];
        
        for (int planeti=0; planeti < system.planetNumbers.length; planeti++) {
            int planetNo = system.planetNumbers[planeti];
            initialFluxFsId[planeti] = getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL,
                FLUX, system.pipelineInstanceId, system.keplerId, planetNo);
            initialFluxUncertFsId[planeti] =  getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL,
                UNCERTAINTIES, system.pipelineInstanceId, system.keplerId, planetNo);
            initialFluxFilledIndicesFsId[planeti] =  getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL,
                FILLED_INDICES, system.pipelineInstanceId, system.keplerId, planetNo);
            modelLightCurveFsId[planeti] = getLightCurveTimeSeriesFsId(fluxType,
                MODEL_LIGHT_CURVE, system.pipelineInstanceId, system.keplerId, planetNo);
        }
        
        TFloatHashSet trialTransitPulseSet = new TFloatHashSet();
        for (FsId sevId : singleEventIds) {
            SingleEventParse parseResult = parseSingleEventStatisticsFsId(sevId);
            trialTransitPulseSet.add(parseResult.trialTransitPulseDuration);
        }
        
        trialTransitPulse = trialTransitPulseSet.toArray();
        Arrays.sort(trialTransitPulse);
        correlatedSingleEventFsId = new FsId[trialTransitPulse.length];
        normalizedSingleEventFsId = new FsId[trialTransitPulse.length];
        for (int i=0; i < trialTransitPulse.length; i++) {
            float trialTransitPulseDuration = trialTransitPulse[i];
            correlatedSingleEventFsId[i] = getSingleEventStatisticsFsId(fluxType,
                CORRELATION, system.pipelineInstanceId, system.keplerId, 
                trialTransitPulseDuration);

            normalizedSingleEventFsId[i] = getSingleEventStatisticsFsId(fluxType,
                NORMALIZATION, system.pipelineInstanceId, system.keplerId, 
                trialTransitPulseDuration);
        }
        
        dvBarycentricCorrectedTime =
            getBarycentricCorrectedTimestampsFsId(fluxType, 
                  system.pipelineInstanceId, system.keplerId);
    }
    
    void addIds(Set<FsId> ids) {
        ids.add(residualFluxFsId);
        ids.add(residualFluxFilledIndicesFsId);
        ids.add(residualFluxUncertFsId);
        ids.add(dvBarycentricCorrectedTime);
        
        addAll(ids, initialFluxFsId);
        addAll(ids, initialFluxUncertFsId);
        addAll(ids, initialFluxFilledIndicesFsId);
        addAll(ids, modelLightCurveFsId);
        
        addAll(ids, correlatedSingleEventFsId);
        addAll(ids, normalizedSingleEventFsId);
        
    }
    
    
    
    private static void addAll(Set<FsId> ids, FsId[] array) {
        for (FsId aid : array) {
            ids.add(aid);
        }
    }
    
    long pipelineInstanceId() {
        return system.pipelineInstanceId;
    }
    
    int keplerId() {
        return system.keplerId;
    }
    
    int startCadence() {
        return system.startCadence;
    }
    
    int endCadence() {
        return system.endCadence;
    }
    
    SimpleInterval cadenceInterval() {
        return new SimpleInterval(system.startCadence, system.endCadence);
    }
    
    FloatTimeSeries residualFlux(Map<FsId, TimeSeries> timeSeries) {
        return timeSeries.get(residualFluxFsId).asFloatTimeSeries();
    }
    
    FloatTimeSeries residualFluxUncert(Map<FsId, TimeSeries> timeSeries) {
        return timeSeries.get(residualFluxUncertFsId).asFloatTimeSeries();
    }
    
    IntTimeSeries residualFluxFilledIndices(Map<FsId, TimeSeries> timeSeries) {
        return timeSeries.get(residualFluxFilledIndicesFsId).asIntTimeSeries();
    }
    
    DoubleTimeSeries barcentricCorrectedTimeSeries(Map<FsId, TimeSeries> timeSeries) {
        return timeSeries.get(dvBarycentricCorrectedTime).asDoubleTimeSeries();
    }
    
    float[][] modelLightCurve(Map<FsId, TimeSeries> timeSeries, float gapFill) {
        float[][] modelLightCurves = new float[modelLightCurveFsId.length][];
        for (int planeti=0; planeti < modelLightCurves.length; planeti++) {
            FloatTimeSeries fts = 
                timeSeries.get(modelLightCurveFsId[planeti]).asFloatTimeSeries();
            fts.fillGaps(gapFill);
            modelLightCurves[planeti] = fts.fseries();
        }
        return modelLightCurves;
    }
    
    InitialTimeSeries initialFluxTimeSeries(Map<FsId, TimeSeries> timeSeries, float gapFill) {
        
        float[][] initial = new float[initialFluxFsId.length][];
        float[][] uncert = new float[initialFluxFsId.length][];
        
        for (int i=0; i < initialFluxFsId.length; i++) {
            
            IntTimeSeries fillIndices =
                timeSeries.get(initialFluxFilledIndicesFsId[i]).asIntTimeSeries();
            
            
            FloatTimeSeries initialFluxTimeSeries = 
                timeSeries.get(initialFluxFsId[i]).asFloatTimeSeries();
            initialFluxTimeSeries.fillGaps(gapFill);
            initial[i] = initialFluxTimeSeries.fseries();
            FluxTimeSeriesProcessing.unfill(initial[i], gapFill, fillIndices);
            
            FloatTimeSeries uncertTimeSeries =
                timeSeries.get(initialFluxUncertFsId[i]).asFloatTimeSeries();
            uncertTimeSeries.fillGaps(gapFill);
            uncert[i] = uncertTimeSeries.fseries();
            
            FluxTimeSeriesProcessing.unfill(uncert[i], gapFill, fillIndices);

        }
        return new InitialTimeSeries(initial, uncert);
    }
   
    
    SingleEventStatistics singleEventStatistics(Map<FsId, TimeSeries> timeSeries, float gapFill) {
        float[][] correlation = new float[trialTransitPulse.length][];
        float[][] normalized = new float[trialTransitPulse.length][];
        for (int i=0; i < trialTransitPulse.length; i++) {
            FloatTimeSeries corr = timeSeries.get(correlatedSingleEventFsId[i]).asFloatTimeSeries();
            corr.fillGaps(gapFill);
            correlation[i] = corr.fseries();
            
            FloatTimeSeries norm = timeSeries.get(normalizedSingleEventFsId[i]).asFloatTimeSeries();
            norm.fillGaps(gapFill);
            normalized[i] = norm.fseries();
        }
        return new SingleEventStatistics(correlation, normalized);
    }
    
    
    DvTimeSeriesFitsFile toFluxFitsFile(Map<FsId, TimeSeries> timeSeries, 
        TimestampSeries cadenceTimes, float gapFill) {
        
        DvTimeSeriesFitsFile fff = new DvTimeSeriesFitsFile();
        
        //Misc
        fff.setKeplerId(keplerId());
        fff.setPlanetNumbers(system.planetNumbers);
        fff.setPipelineTaskId(system.pipelineTaskId);
        fff.setTrialTransitPulse(trialTransitPulse);
        
        //Residual
        FloatTimeSeries residualTimeSeries = residualFlux(timeSeries);
        residualTimeSeries.fillGaps(gapFill);
        float[] unfilledResidualFlux = residualTimeSeries.fseries();
        FluxTimeSeriesProcessing.unfill(unfilledResidualFlux, gapFill, residualFluxFilledIndices(timeSeries));
        fff.setResidualTimeSeries(unfilledResidualFlux);
        FloatTimeSeries residualUncertTimeSeries = residualFluxUncert(timeSeries);
        residualUncertTimeSeries.fillGaps(gapFill);
        float[] unfilledResidualUncert = residualUncertTimeSeries.fseries();
        FluxTimeSeriesProcessing.unfill(unfilledResidualUncert, gapFill, 
            residualFluxFilledIndices(timeSeries));
        fff.setResidualTimeSeriesUncertaintiy(unfilledResidualUncert);
        
        
        //Initial time series
        InitialTimeSeries initial =  initialFluxTimeSeries(timeSeries, gapFill);
        fff.setInitialFlux(initial.initialFlux);
        fff.setInitialFluxUncertaintiy(initial.initialFluxUncert);
        
        //Single event statistics
        SingleEventStatistics sev = singleEventStatistics(timeSeries, gapFill);
        fff.setSingleEventCorrelated(sev.correlated);
        fff.setSingleEventNormalized(sev.normalized);
        
        //time
        fff.setCadences(cadenceTimes.cadenceNumbers);
        fff.setTime(this.barcentricCorrectedTimeSeries(timeSeries).dseries());
        fff.setMjdStart(cadenceTimes.midTimestamps[0]);
        fff.setMjdEnd(cadenceTimes.midTimestamps[cadenceTimes.midTimestamps.length - 1]);

        fff.setModelLightCurve(modelLightCurve(timeSeries, gapFill));
        
        return fff;

    }
    
    static class SingleEventStatistics {
        final float[/* trial transit pulse*/][] correlated;
        final float[/* trial transit pulse*/][] normalized;
        
        public SingleEventStatistics(
            float[/* trial transit pulse*/][] correlated, 
            float[/* trial transit pulse*/][] normalized) {

            this.correlated = correlated;
            this.normalized = normalized;
        }

    }
    
    static class InitialTimeSeries {
        final float[/* planet index*/][] initialFlux;
        final float[/* planet index*/][] initialFluxUncert;
        
        
        public InitialTimeSeries(float[/* planet no*/][] initialFlux,
            float[/* planet no*/][] initialFluxUncert) {

            this.initialFlux = initialFlux;
            this.initialFluxUncert = initialFluxUncert;
        }

    }
    
}
