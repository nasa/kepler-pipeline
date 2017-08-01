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

package gov.nasa.kepler.ar.exporter.cdpp;

import java.io.File;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.*;

/**
 * THIS CLASS IS BROKEN DO NOT USE IT.  It is still here because it is complicated to remove it
 * from the automated tests.
 * 
 * @author Sean McCauliff
 *
 */
public class CdppExporter {

    private static final Log log = LogFactory.getLog(CdppExporter.class);
    private final FileStoreClient fsClient;
    private final FileNameFormatter fnameFormatter = new FileNameFormatter();
    private final MjdToCadence mjdToCadence;
    private final Map<Integer, float[]> missingSeries = new HashMap<Integer, float[]>();
    private final TpsCrud tpsCrud = new TpsCrud();
    
    public CdppExporter(FileStoreClient fsClient, MjdToCadence mjdToCadence) {
        this.fsClient = fsClient;
        this.mjdToCadence = mjdToCadence;
    }
    
    /**
     * 
     * @param tpsDbResults  This should only contain results for 3.0, 6.0
     * or 12.0 trial transit pulses.
     * @throws IOException 
     * @throws FitsException 
     */
    public void export(List<? extends AbstractTpsDbResult> tpsDbResults, File outputDir, TpsType tpsType) throws IOException, FitsException {
        if (outputDir.exists() && !outputDir.isDirectory()) {
            throw new IllegalArgumentException("Output directory \"" + outputDir 
                + "\" already exists, but is a file.");
        }
        if (!outputDir.exists()) {
            FileUtil.mkdirs(outputDir);
        }

        //TODO:  This probably won't work for TPS lite since the operator needs to specify the
        //pipeline instance associated with the targets in the target table being exported.
        long tpsPipelineInstanceId = tpsCrud.retrieveLatestTpsRun(tpsType).getId();
        
        //Group results by their cadence intervals so that we can call the file
        //store with number of the same ones in the same range.
        List<ResultsForTarget> collectedResults = new ArrayList<ResultsForTarget>(collectResults(tpsDbResults, tpsType, tpsPipelineInstanceId));
        SortedMap<Pair<Integer, Integer>, List<ResultsForTarget>> minMaxCadenceToResults 
            = new TreeMap<Pair<Integer, Integer>, List<ResultsForTarget>>(new MinMaxCadenceComparator());


        log.info("Found results for " + collectedResults.size() + " kepler ids.");
        for (ResultsForTarget resultsForTarget : collectedResults) {
            Pair<Integer, Integer> minMaxCadence = resultsForTarget.minMaxCadence();
            List<ResultsForTarget> resultsList = minMaxCadenceToResults.get(minMaxCadence);
            if (resultsList == null) {
                resultsList = new ArrayList<ResultsForTarget>();
                minMaxCadenceToResults.put(minMaxCadence, resultsList);
            }
            resultsList.add(resultsForTarget);
        }
        
        int minCadenceForAllTargets = minMaxCadenceToResults.firstKey().left;
        int maxCadenceForAllTargets = minMaxCadenceToResults.lastKey().right;
        
        List<FsIdSet> fsIdSetList = new ArrayList<FsIdSet>(minMaxCadenceToResults.size());
        for (Map.Entry<Pair<Integer, Integer>, List<ResultsForTarget>> entry : minMaxCadenceToResults.entrySet()) {
            Pair<Integer, Integer> minMaxCadence = entry.getKey();
            FsIdSet fsIdSet = new FsIdSet(minMaxCadence.left, minMaxCadence.right, new HashSet<FsId>());
            for (ResultsForTarget resultsForTarget : entry.getValue()) {
                resultsForTarget.addTo(fsIdSet.ids());
            }
            fsIdSetList.add(fsIdSet);
        }

        List<TimeSeriesBatch> batchList = 
            fsClient.readTimeSeriesBatch(fsIdSetList, false /* exists error*/);

        for (TimeSeriesBatch batch : batchList) {
            for (TimeSeries ts : batch.timeSeries().values()) {
                FloatTimeSeries fts = (FloatTimeSeries) ts;
                fts.fillGaps(Float.NaN);
            }
        }
        
        
        TimestampSeries cadenceTimes =
            mjdToCadence.cadenceTimes(minCadenceForAllTargets,
                                      maxCadenceForAllTargets);
        
        Iterator<TimeSeriesBatch> batchIt = batchList.iterator();
        for (List<ResultsForTarget> resultsList : minMaxCadenceToResults.values()) {
            TimeSeriesBatch batch = batchIt.next();

            for (ResultsForTarget resultsForTarget : resultsList) {
                exportCdpp(outputDir, resultsForTarget, batch, cadenceTimes);
            }
        }
    }
    
    
    private void exportCdpp(File outputDir, ResultsForTarget resultsForTarget, TimeSeriesBatch batch,
        TimestampSeries cadenceTimes)
        throws IOException, FitsException {
        
        double startMjd= mjdToCadence.cadenceToMjd(resultsForTarget.minCadence());
        double endMjd = mjdToCadence.cadenceToMjd(resultsForTarget.maxCadence());
        int[] cadenceNumbers = 
            FluxTimeSeriesProcessing.absoluteCadences(resultsForTarget.minCadence(),
                resultsForTarget.maxCadence(), cadenceTimes);
        
        double[] mjds = new double[resultsForTarget.cadenceLength()];
        boolean[] mjdGaps = new boolean[resultsForTarget.cadenceLength()];
        
        for (int i=0; i < mjds.length; i++) {
            int srcIndex = i + (resultsForTarget.minCadence() - cadenceTimes.cadenceNumbers[0]);
            mjds[i] = cadenceTimes.midTimestamps[srcIndex];
            mjdGaps[i] = cadenceTimes.gapIndicators[srcIndex];
        }
        
        FloatTimeSeries barycentricCorrection = 
            (FloatTimeSeries) batch.timeSeries().get(resultsForTarget.barycentricCorrectionId());
        double[] bkjd = 
            FluxTimeSeriesProcessing.bkjdTimestampSeries(mjds, mjdGaps, 
                barycentricCorrection, Double.NaN);
        
        Date endUtc = ModifiedJulianDate.mjdToDate(endMjd);
        String fname = fnameFormatter.cdppName(endUtc, resultsForTarget.keplerId);
       
        File outputFile = new File(outputDir, fname);
        log.info("Writing output file \"" + outputFile + "\".");
        
        FloatTimeSeries cdppThreeHrAp = 
            (FloatTimeSeries) batch.timeSeries().get(resultsForTarget.threeHrCdppAp());
        FloatTimeSeries cdppSixHrAp =
            (FloatTimeSeries) batch.timeSeries().get(resultsForTarget.sixHrCdppAp());
        FloatTimeSeries cdppTweleveHrAp =
            (FloatTimeSeries) batch.timeSeries().get(resultsForTarget.tweleveHrCdppAp());
        

        CdppFitsFile cdppFitsFile = new CdppFitsFile(resultsForTarget.keplerId,
            startMjd, endMjd,
            data(cdppThreeHrAp, resultsForTarget.cadenceLength()),
            data(cdppSixHrAp, resultsForTarget.cadenceLength()),
            data(cdppTweleveHrAp, resultsForTarget.cadenceLength()),
            bkjd, cadenceNumbers);
        
        cdppFitsFile.write(outputFile);
            
    }
    
    private float[] data(FloatTimeSeries series, int length) {
        if (series != null) {
            return series.fseries();
        }
        
        float[] missing = missingSeries.get(length);
        if (missing == null) {
            missing = new float[length];
            Arrays.fill(missing, Float.NaN);
            missingSeries.put(length, missing);
        }
        return missing;
    }
    
    
    private static Collection<ResultsForTarget> collectResults(List<? extends AbstractTpsDbResult> tpsResults, TpsType tpsType, long tpsPipelineInstanceId) {
        Map<Integer, ResultsForTarget> collectedResults = 
            new HashMap<Integer, ResultsForTarget>();
        
        for (AbstractTpsDbResult result : tpsResults) {
            ResultsForTarget resultsForTarget = collectedResults.get(result.getKeplerId());
            if (resultsForTarget == null) {
                resultsForTarget = new ResultsForTarget(result.getKeplerId(), tpsType, tpsPipelineInstanceId);
                collectedResults.put(result.getKeplerId(), resultsForTarget);
            }
            
            resultsForTarget.addCdpp(result.getTrialTransitPulseInHours(), 
                result.getFluxType(), result.getStartCadence(), result.getEndCadence(), tpsType);
        }
        
        return collectedResults.values();
    }
    
    /**
     * Tracks the (min, max) cadence range and flux types for a particular
     * target.  Generates FsIds for that target.
     * 
     * TODO:  This is probably broken for TPS lite since the user needs to be ablet to specify the
     * TPS lite instance that was run.
     *
     */
    private static final class ResultsForTarget {
        private final int[] minCadence = new int[FluxType.values().length];
        private final int[] maxCadence = new int[FluxType.values().length];
        
        private final Map<Float, boolean[]> cdpp = new HashMap<Float,boolean[]>();
        private boolean seenOptimal = false;
        public final int keplerId;
        private final FsId barycentricCorrectionId;
        private final TpsType tpsType;
        private final long tpsPipelineInstanceId;
        
        ResultsForTarget(int keplerId, TpsType tpsType, long tpsPipelineInstanceId) {
            this.keplerId = keplerId;
            Arrays.fill(minCadence, Integer.MAX_VALUE);
            Arrays.fill(maxCadence, Integer.MIN_VALUE);
            this.barycentricCorrectionId = 
                PaFsIdFactory.getBarcentricTimeOffsetFsId(CadenceType.LONG, keplerId);
            this.tpsType = tpsType;
            this.tpsPipelineInstanceId = tpsPipelineInstanceId;
        }
        
        public void addCdpp(float trialTransitPulseInHr, FluxType fluxType, 
                            int startCadence, int endCadence, TpsType tpsType) {
            
            if (startCadence > endCadence) {
                throw new IllegalArgumentException("Start cadence is greater than end cadence.");
            }
            
            boolean[] fluxTypeArray = cdpp.get(trialTransitPulseInHr);
            if (fluxTypeArray == null) {
                fluxTypeArray = new boolean[FluxType.values().length];
                cdpp.put(trialTransitPulseInHr, fluxTypeArray);
            }
            if (fluxType == FluxType.OAP) {
                seenOptimal = true;
            }
            fluxTypeArray[fluxType.ordinal()] = true;
            
            minCadence[fluxType.ordinal()] = Math.min(minCadence[fluxType.ordinal()], startCadence);
            maxCadence[fluxType.ordinal()] = Math.max(maxCadence[fluxType.ordinal()], endCadence);
        }
        
        
        public FluxType apFluxType() {
            if (seenOptimal) {
                return FluxType.OAP;
            }
            return FluxType.SAP;
        }
        
        public int minCadence() {
            int min = Integer.MAX_VALUE;
            if (seenOptimal) {
                min = minCadence[FluxType.OAP.ordinal()];
            } else {
                min = minCadence[FluxType.SAP.ordinal()];
            }
            
            min = Math.min(min, minCadence[FluxType.DIA.ordinal()]);
            return min;
        }
        
        public int maxCadence() {
            int max = Integer.MIN_VALUE;
            if (seenOptimal) {
                max = maxCadence[FluxType.OAP.ordinal()];
            } else {
                max = maxCadence[FluxType.SAP.ordinal()];
            }
            
            max = Math.max(max, maxCadence[FluxType.DIA.ordinal()]);
            return max;
        }
        
        public int cadenceLength() {
            return maxCadence() - minCadence() + 1;
        }
        
        public FsId barycentricCorrectionId() {
            return barycentricCorrectionId;
        }
        
        public FsId threeHrCdppAp() {
            return getCdppId(tpsPipelineInstanceId, keplerId, 3.0f, tpsType, apFluxType());
        }
        
        public FsId sixHrCdppAp() {
            return getCdppId(tpsPipelineInstanceId, keplerId, 6.0f, tpsType, apFluxType());
        }
        
        public FsId tweleveHrCdppAp() {
            return getCdppId(tpsPipelineInstanceId, keplerId, 12.0f, tpsType, apFluxType());
        }
        
        
        public Pair<Integer, Integer> minMaxCadence() {
            return Pair.of(minCadence(), maxCadence());
        }
        
        /**
         * If we see a result using OAP then use OAP results.
         * @param idList
         */
        public void addTo(Collection<FsId> idList) {
            for (Map.Entry<Float, boolean[]> entries : cdpp.entrySet()) {
                float trialTransitPulse = entries.getKey();
                if (trialTransitPulse != 3.0 && trialTransitPulse != 6.0 && 
                    trialTransitPulse != 12.0) {
                    log.warn("Ignoring CDPP for trial transit pulse of " + 
                        trialTransitPulse + " hours.");
                    continue;
                }
                boolean[] fluxTypeArray = entries.getValue();
                if (seenOptimal && fluxTypeArray[FluxType.OAP.ordinal()]) {
                    FsId id = getCdppId(tpsPipelineInstanceId, keplerId, trialTransitPulse, 
                        tpsType, FluxType.OAP);
                    idList.add(id);
                } else if (fluxTypeArray[FluxType.SAP.ordinal()]) {
                    FsId id = getCdppId(tpsPipelineInstanceId, keplerId, trialTransitPulse, 
                        tpsType, FluxType.SAP);
                    idList.add(id);
                }
                
                if (fluxTypeArray[FluxType.DIA.ordinal()]) {
                    FsId id = getCdppId(tpsPipelineInstanceId, keplerId, trialTransitPulse,
                        tpsType, FluxType.DIA);
                        
                    idList.add(id);
                }
                
            }
            idList.add(barycentricCorrectionId);
        }
        
        @Override
        public int hashCode() {
            return keplerId;
        }
        
        @Override
        public boolean equals(Object o) {
            if (!(o instanceof ResultsForTarget)) {
                return false;
            }
            ResultsForTarget other = (ResultsForTarget) o;
            return other.keplerId == this.keplerId;
        }
    }
    
    private static final class MinMaxCadenceComparator implements Comparator<Pair<Integer, Integer>> {
        
        @Override
        public int compare(Pair<Integer, Integer> o1,
            Pair<Integer, Integer> o2) {

            int diff = o1.left - o2.left;
            if (diff != 0) {
                return diff;
            }
            return o1.right - o2.right;
        }
    }
}
