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

package gov.nasa.kepler.mc.dr;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.DoubleIntervalSet;
import gov.nasa.kepler.common.intervals.SimpleDoubleInterval;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.PixelLogCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.commons.lang.ArrayUtils;

/**
 * Converts from mjd->cadence and cadence->mjd using the mjd mid point time of
 * the cadence log.
 * 
 * This uses the the PixelLog objects which are generated from headers of FITS
 * files received from the DMC. If those logs do not exist then cadence gaps
 * will appear in all the responses from this class.
 * 
 * @author Sean McCauliff
 * 
 */
public class MjdToCadence {
    private static final int LC_PREFETCH_CADENCES = 1000;
    private static final int SC_PREFETCH_CADENCES = 60 * 24 * 10;
    private static final double PREFETCH_DAYS = 10.0;
    private static final double SHORT_DELTA = 1.0 / (24.0 * 60.0) * 1.5;
    private static final double LONG_DELTA = 1.0 / (2.0 * 24.0) * 1.5;

    private final SortedMap<Double, PixelLog> mjdToCadence = new TreeMap<Double, PixelLog>();
    private final SortedMap<Integer, PixelLog> cadenceToMjd = new TreeMap<Integer, PixelLog>();
    private final Set<Integer> gappedCadences = new HashSet<Integer>();
    private final DoubleIntervalSet<SimpleDoubleInterval> authoritativeMjds;

    private final PixelLogCrud pixelLogCrud;
    private final DataAnomalyOperations dataAnomalyOperations;
    private final CadenceType cadenceType;

    public MjdToCadence(CadenceType cadenceType,
        ModelMetadataRetriever modelMetadataRetriever) {
        this(new LogCrud(), new DataAnomalyOperations(modelMetadataRetriever),
            cadenceType);
    }

    public MjdToCadence(PixelLogCrud pixelLogCrud,
        DataAnomalyOperations dataAnomalyOperations, CadenceType cadenceType) {
        this.pixelLogCrud = pixelLogCrud;
        this.dataAnomalyOperations = dataAnomalyOperations;
        this.cadenceType = cadenceType;
        switch (cadenceType) {
            case LONG:
                authoritativeMjds = new DoubleIntervalSet<SimpleDoubleInterval>(
                    LONG_DELTA);
                break;
            case SHORT:
                authoritativeMjds = new DoubleIntervalSet<SimpleDoubleInterval>(
                    SHORT_DELTA);
                break;
            default:
                throw new IllegalStateException("Unhandled case " + cadenceType);
        }
    }

    public CadenceType cadenceType() {
        return cadenceType;
    }

    /**
     * Fill internal cache with values.
     * 
     * @param cadenceStart inclusive
     * @param cadenceEnd inclusive
     */
    public void cacheInterval(int startCadence, int endCadence,
        boolean existsError) {
        if (startCadence > endCadence) {
            throw new IllegalArgumentException("startCadence " + startCadence
                + " comes after endCadence " + endCadence);
        }
        List<PixelLog> pixelLogs = pixelLogCrud.retrievePixelLog(
            cadenceType.intValue(), DataSetType.Target, startCadence,
            endCadence);
        if (!(pixelLogs.size() == 0 && !existsError)) {
            if (pixelLogs.isEmpty()) {
                throw new IllegalArgumentException(
                    "At least one pixelLog must exist for the input cadence range.\n  cadenceType: "
                        + cadenceType
                        + "\n  startCadence: "
                        + startCadence
                        + "\n  endCadence: " + endCadence);
            }

            cacheInterval(pixelLogs);
        }

        /*
         * If any of the requested cadences do not exist in cadenceToMjd at this
         * point, it means they do not exist in DR_PIXEL_LOG and should be
         * treated as gaps rather than cache misses
         */
        for (int cadence = startCadence; cadence >= startCadence
            && cadence <= endCadence; cadence++) {
            if (!cadenceToMjd.containsKey(cadence)) {
                gappedCadences.add(cadence);
            }
        }
    }

    public void cacheInterval(int startCadence, int endCadence) {
        cacheInterval(startCadence, endCadence, true);
    }

    /**
     * 
     * @param cadenceType
     * @param mjdStart inclusive
     * @param mjdEnd inclusive
     */
    public void cacheInterval(double startMjd, double endMjd) {
        List<PixelLog> pixelLogs = pixelLogCrud.retrievePixelLog(
            cadenceType.intValue(), DataSetType.Target, startMjd, endMjd);

        cacheInterval(pixelLogs);
    }

    private void cacheInterval(List<PixelLog> pixelLogs) {
        for (PixelLog plog : pixelLogs) {
            cadenceToMjd.put(plog.getCadenceNumber(), plog);
            mjdToCadence.put(plog.getMjdMidTime(), plog);
        }

        try {
            validateCadenceTimes(cadenceToMjd.values());
        } catch (IllegalStateException x) {
            cadenceToMjd.clear();
            gappedCadences.clear();
            mjdToCadence.clear();
            throw x;
        }

        double startMjd = pixelLogs.get(0)
            .getMjdMidTime();
        double endMjd = pixelLogs.get(pixelLogs.size() - 1)
            .getMjdMidTime();
        authoritativeMjds.mergeInterval(new SimpleDoubleInterval(startMjd,
            endMjd));
    }

    private void cacheMiss(int missedCadence) {
        cacheMiss(missedCadence, true);
    }

    private void cacheMiss(int missedCadence, boolean checkError) {
        int prefetch = cadenceType == CadenceType.LONG ? LC_PREFETCH_CADENCES
            : SC_PREFETCH_CADENCES;

        int startCadence = Math.max(0, missedCadence - prefetch);
        int endCadence = (int) Math.min((long) Integer.MAX_VALUE, missedCadence
            + prefetch);
        cacheInterval(startCadence, endCadence, checkError);
        if (checkError && !cadenceToMjd.containsKey(missedCadence)) {
            throw new NoSuchElementException("Cadence " + missedCadence
                + " does not exist.");
        }
    }

    private void cacheMiss(double missedMjd) {
        if (!authoritativeMjds.inIntervalSet(new SimpleDoubleInterval(
            missedMjd, missedMjd))) {
            double startMjd = Math.max(0, missedMjd - PREFETCH_DAYS);
            double endMjd = Math.min(Double.MAX_VALUE, missedMjd
                + PREFETCH_DAYS);
            cacheInterval(startMjd, endMjd);
        }

        if (!mjdToCadence.containsKey(missedMjd)) {
            throw new NoSuchElementException("Mjd mid point " + missedMjd
                + " does not exist.");
        }
    }

    /**
     * 
     * @param cadence
     * @return the mjd of the mid point of the cadence.
     */
    public double cadenceToMjd(int cadence) {

        if (cadenceToMjd.containsKey(cadence)) {
            return cadenceToMjd.get(cadence)
                .getMjdMidTime();
        }

        if (!gappedCadences.contains(cadence)) {
            cacheMiss(cadence);

            return cadenceToMjd.get(cadence)
                .getMjdMidTime();
        } else {
            throw new NoSuchElementException("cadence: " + cadence
                + " does not exist");
        }
    }

    /**
     * 
     * @param mjd The MJD of the mid point of the cadence.
     * @return
     */
    public int mjdToCadence(double mjd) {

        if (mjdToCadence.containsKey(mjd)) {
            return mjdToCadence.get(mjd)
                .getCadenceNumber();
        }

        cacheMiss(mjd);

        return mjdToCadence.get(mjd)
            .getCadenceNumber();
    }

    /**
     * Gets the cached PixelLog for the specified cadence.
     * 
     * @param cadence
     * @return This may return null.
     */
    public PixelLog pixelLogForCadence(int cadence) {
        return cadenceToMjd.get(cadence);
    }

    /**
     * 
     * @param cadence
     * @return returns true if the specified cadence exists else returns false.
     */
    public boolean hasCadence(int cadence) {
        if (cadenceToMjd.containsKey(cadence)) {
            return true;
        }

        if (!gappedCadences.contains(cadence)) {
            cacheMiss(cadence, false);
        }

        if (cadenceToMjd.containsKey(cadence)) {
            return true;
        }
        return false;
    }

    /**
     * @return true if requant was enabled for this cadence else false
     */
    public boolean isRequantEnabled(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isDataRequantizedForDownlink();
    }

    public boolean isSefiAcc(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isSefiAcc();
    }

    public boolean isSefiCad(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isSefiCad();
    }

    public boolean isLdeOos(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isLdeOos();
    }

    public boolean isFinePnt(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isFinePnt();
    }

    public boolean isMmntmDmp(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isMmntmDmp();
    }

    public boolean isLdeParEr(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isLdeParEr();
    }

    public boolean isScrcErr(int cadence) {
        if (!hasCadence(cadence)) {
            return false;
        }

        return cadenceToMjd.get(cadence)
            .isScrcErr();
    }

    /**
     * 
     * @param sortedLogs Logs should be sorted in ascending cadence order.
     */
    private void validateCadenceTimes(Collection<PixelLog> sortedLogs) {
        if (sortedLogs.size() <= 1) {
            return;
        }

        Iterator<PixelLog> it = sortedLogs.iterator();

        PixelLog firstLog = it.next();
        double prevStartMjd = firstLog.getMjdStartTime();
        double prevMidMjd = firstLog.getMjdMidTime();
        double prevEndMjd = firstLog.getMjdEndTime();

        int prevCadence = firstLog.getCadenceNumber();

        while (it.hasNext()) {
            PixelLog log = it.next();
            if (prevCadence != log.getCadenceNumber()) {
                if (prevMidMjd >= log.getMjdMidTime()
                    || prevStartMjd >= log.getMjdStartTime()
                    || prevEndMjd >= log.getMjdEndTime()) {

                    String m = "Time goes backwards or does not change in pixel logs.\n";
                    m += "current/prev cadence " + log.getCadenceNumber() + " "
                        + prevCadence + "\n";
                    m += "current/prev mjd start time " + log.getMjdStartTime()
                        + " " + prevStartMjd + "\n ";
                    m += "current/prev mjd mid time  " + log.getMjdMidTime()
                        + " " + prevMidMjd + "\n";
                    m += "current/prev mjd end time " + log.getMjdEndTime()
                        + " " + prevEndMjd + "\n";

                    throw new IllegalStateException(m);
                }
            } else if (prevMidMjd != log.getMjdMidTime()) {
                throw new IllegalStateException("Mjd should be " + prevMidMjd
                    + " but found " + log.getMjdEndTime());
            }

            prevStartMjd = log.getMjdStartTime();
            prevMidMjd = log.getMjdMidTime();
            prevEndMjd = log.getMjdEndTime();
            prevCadence = log.getCadenceNumber();

        }
    }

    /**
     * Equivalent to cadenceTimes(startCadence, endCadence, true).
     */
    public TimestampSeries cadenceTimes(int startCadence, int endCadence) {
        return cadenceTimes(startCadence, endCadence, true, true);
    }

    /**
     * Equivalent to cadenceTimes(startCadence, endCadence, true).
     */
    public TimestampSeries cadenceTimes(int startCadence, int endCadence,
        boolean existsError) {
        return cadenceTimes(startCadence, endCadence, existsError, true);
    }

    /**
     * Assumes that the cache already contains the specified range
     */
    public TimestampSeries cachedCadenceTimes(int startCadence, int endCadence) {
        return cadenceTimes(startCadence, endCadence, true, false);
    }

    /**
     * 
     * @param startCadence
     * @param endCadence inclusive
     * @param existsError if start or end cadences do not exist then throw a
     * NoSuchElementExcpetion.
     * @return Where mjd[i] is the mjd for cadence startCadence + 1. If the mjd
     * for mjd[i] is missing then gaps[i] will be true and the value of mjd[i]
     * and requantEnabled will be undefined.
     * @throws PipelineException
     * @throws NoSuchElementException If start or end are missing cadences.
     */
    public TimestampSeries cadenceTimes(int startCadence, int endCadence,
        boolean existsError, boolean reloadCache) {
        if (reloadCache) {
            cacheInterval(startCadence, endCadence, existsError);
        }

        double[] startTimestamps = new double[endCadence - startCadence + 1];
        double[] midTimestamps = new double[startTimestamps.length];
        double[] endTimestamps = new double[startTimestamps.length];
        boolean[] gapIndicators = new boolean[startTimestamps.length];
        boolean[] requantEnabled = new boolean[startTimestamps.length];
        boolean[] isSefiAcc = new boolean[startTimestamps.length];
        boolean[] isSefiCad = new boolean[startTimestamps.length];
        boolean[] isLdeOos = new boolean[startTimestamps.length];
        boolean[] isFinePnt = new boolean[startTimestamps.length];
        boolean[] isMmntmDmp = new boolean[startTimestamps.length];
        boolean[] isLdeParEr = new boolean[startTimestamps.length];
        boolean[] isScrcErr = new boolean[startTimestamps.length];
        int[] cadenceNumbers = new int[startTimestamps.length];

        for (int cadenceNo = startCadence; cadenceNo <= endCadence; cadenceNo++) {
            int index = cadenceNo - startCadence;
            if (hasCadence(cadenceNo)) {
                PixelLog plog = cadenceToMjd.get(cadenceNo);
                startTimestamps[index] = plog.getMjdStartTime();
                midTimestamps[index] = plog.getMjdMidTime();
                endTimestamps[index] = plog.getMjdEndTime();
                requantEnabled[index] = isRequantEnabled(cadenceNo);
                isSefiAcc[index] = isSefiAcc(cadenceNo);
                isSefiCad[index] = isSefiCad(cadenceNo);
                isLdeOos[index] = isLdeOos(cadenceNo);
                isFinePnt[index] = isFinePnt(cadenceNo);
                isMmntmDmp[index] = isMmntmDmp(cadenceNo);
                isLdeParEr[index] = isLdeParEr(cadenceNo);
                isScrcErr[index] = isScrcErr(cadenceNo);
                gapIndicators[index] = false;
            } else {
                gapIndicators[index] = true;
                requantEnabled[index] = false;
                isSefiAcc[index] = false;
                isSefiCad[index] = false;
                isLdeOos[index] = false;
                isFinePnt[index] = false;
                isMmntmDmp[index] = false;
                isLdeParEr[index] = false;
                isScrcErr[index] = false;
            }
            cadenceNumbers[index] = cadenceNo;
        }

        DataAnomalyFlags dataAnomalyFlags = dataAnomalyOperations.retrieveDataAnomalyFlags(
            cadenceType, startCadence, endCadence);

        return new TimestampSeries(startTimestamps, midTimestamps,
            endTimestamps, gapIndicators, requantEnabled, cadenceNumbers,
            isSefiAcc, isSefiCad, isLdeOos, isFinePnt, isMmntmDmp, isLdeParEr,
            isScrcErr, dataAnomalyFlags);
    }

    @ProxyIgnoreStatics
    public static class TimestampSeries implements Persistable, Serializable {

        private static final long serialVersionUID = -7344693057506009040L;

        /**
         * The beginning of a cadence in MJD. The length of this array
         * represents the number of cadences for this TimestampSeries.
         */
        public double[] startTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        /**
         * The mid point of the cadence in MJD. (start + end ) /2.0 This is the
         * same length as startTimestamps.
         */
        public double[] midTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        /**
         * The end point of the cadence in MJD. This is the same length as
         * startTimestamps.
         */
        public double[] endTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        /**
         * If gapIndicators[i] is true then the value of the other arrays at
         * index i is undefined. This is the same length as startTimestamps.
         */
        public boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * When requantEnabled is true then the requantization was enabled for
         * that cadence. This is the same length as startTimestamps.
         */
        public boolean[] requantEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * The absolute cadence number. This is the same length as
         * startTimestamps.
         */
        public int[] cadenceNumbers = ArrayUtils.EMPTY_INT_ARRAY;
        /**
         * Single Event Funtional Interrupt in accum memory when true. This is
         * the same length as startTimestamps.
         */
        public boolean[] isSefiAcc = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * Single Event Funtional Interrupt in cadence memory when true. This is
         * the same length as startTimestamps.
         */
        public boolean[] isSefiCad = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * Local Detector Electronics OutOfSynch reported when true. This is the
         * same length as startTimestamps.
         */
        public boolean[] isLdeOos = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /** Fine Point pointing status during accumulation when true. */
        public boolean[] isFinePnt = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * Momentum dump occurred during accumulation when true. This is the
         * same length as startTimestamps.
         */
        public boolean[] isMmntmDmp = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * Local Detector Electronics parity error occurred when true. This is
         * the same length as startTimestamps.
         */
        public boolean[] isLdeParEr = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * SDRAM Controller memory pixel error occurred when true. This is the
         * same length as startTimestamps.
         */
        public boolean[] isScrcErr = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        /**
         * Class for data anomaly indicators.
         */
        public DataAnomalyFlags dataAnomalyFlags = new DataAnomalyFlags();

        /**
         * No arg constructor required by persistable. This also happens to
         * initialize everything to an empty array.
         */
        public TimestampSeries() {
            startTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
            midTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
            endTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;
            gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            cadenceNumbers = ArrayUtils.EMPTY_INT_ARRAY;
            requantEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isSefiAcc = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isSefiCad = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isLdeOos = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isFinePnt = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isMmntmDmp = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isLdeParEr = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            isScrcErr = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
            dataAnomalyFlags = new DataAnomalyFlags();
        }

        public TimestampSeries(double[] startTimestamps,
            double[] midTimestamps, double[] endTimestamps,
            boolean[] gapIndicators, boolean[] requantEnabled,
            int[] cadenceNumbers, boolean[] isSefiAcc, boolean[] isSefiCad,
            boolean[] isLdeOos, boolean[] isFinePnt, boolean[] isMmntmDmp,
            boolean[] isLdeParEr, boolean[] isScrcErr) {

            this(startTimestamps, midTimestamps, endTimestamps, gapIndicators,
                requantEnabled, cadenceNumbers, isSefiAcc, isSefiCad, isLdeOos,
                isFinePnt, isMmntmDmp, isLdeParEr, isScrcErr,
                new DataAnomalyFlags());
        }

        public TimestampSeries(double[] startTimestamps,
            double[] midTimestamps, double[] endTimestamps,
            boolean[] gapIndicators, boolean[] requantEnabled,
            int[] cadenceNumbers, boolean[] isSefiAcc, boolean[] isSefiCad,
            boolean[] isLdeOos, boolean[] isFinePnt, boolean[] isMmntmDmp,
            boolean[] isLdeParEr, boolean[] isScrcErr,
            DataAnomalyFlags dataAnomalyFlags) {
            this.startTimestamps = startTimestamps;
            this.endTimestamps = endTimestamps;
            this.midTimestamps = midTimestamps;
            this.gapIndicators = gapIndicators;
            this.requantEnabled = requantEnabled;
            this.cadenceNumbers = cadenceNumbers;
            this.isSefiAcc = isSefiAcc;
            this.isSefiCad = isSefiCad;
            this.isLdeOos = isLdeOos;
            this.isFinePnt = isFinePnt;
            this.isMmntmDmp = isMmntmDmp;
            this.isLdeParEr = isLdeParEr;
            this.isScrcErr = isScrcErr;
            this.dataAnomalyFlags = dataAnomalyFlags;
        }

        /**
         * Returns the first start timestamp.
         */
        public double startMjd() {
            for (int i = 0; i < gapIndicators.length; i++) {
                if (!gapIndicators[i]) {
                    return startTimestamps[i];
                }
            }

            throw new PixelLogMissingException("Start mjd not found.", cadenceNumbers[0]);
        }

        /**
         * Returns the last end timestamp.
         * 
         * @return
         */
        public double endMjd() {
            for (int i = gapIndicators.length - 1; i >= 0; i--) {
                if (!gapIndicators[i]) {
                    return endTimestamps[i];
                }
            }

            throw new PixelLogMissingException("End mjd not found.", cadenceNumbers[cadenceNumbers.length - 1]);
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + dataAnomalyFlags.hashCode();
            result = prime * result + Arrays.hashCode(endTimestamps);
            result = prime * result + Arrays.hashCode(gapIndicators);
            result = prime * result + Arrays.hashCode(isFinePnt);
            result = prime * result + Arrays.hashCode(isLdeOos);
            result = prime * result + Arrays.hashCode(isLdeParEr);
            result = prime * result + Arrays.hashCode(isMmntmDmp);
            result = prime * result + Arrays.hashCode(isScrcErr);
            result = prime * result + Arrays.hashCode(isSefiAcc);
            result = prime * result + Arrays.hashCode(isSefiCad);
            result = prime * result + Arrays.hashCode(midTimestamps);
            result = prime * result + Arrays.hashCode(requantEnabled);
            result = prime * result + Arrays.hashCode(startTimestamps);
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (!(obj instanceof TimestampSeries)) {
                return false;
            }
            final TimestampSeries other = (TimestampSeries) obj;
            if (!dataAnomalyFlags.equals(other.dataAnomalyFlags)) {
                return false;
            }
            if (!Arrays.equals(endTimestamps, other.endTimestamps)) {
                return false;
            }
            if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
                return false;
            }
            if (!Arrays.equals(isFinePnt, other.isFinePnt)) {
                return false;
            }
            if (!Arrays.equals(isLdeOos, other.isLdeOos)) {
                return false;
            }
            if (!Arrays.equals(isLdeParEr, other.isLdeParEr)) {
                return false;
            }
            if (!Arrays.equals(isMmntmDmp, other.isMmntmDmp)) {
                return false;
            }
            if (!Arrays.equals(isScrcErr, other.isScrcErr)) {
                return false;
            }
            if (!Arrays.equals(isSefiAcc, other.isSefiAcc)) {
                return false;
            }
            if (!Arrays.equals(isSefiCad, other.isSefiCad)) {
                return false;
            }
            if (!Arrays.equals(midTimestamps, other.midTimestamps)) {
                return false;
            }
            if (!Arrays.equals(requantEnabled, other.requantEnabled)) {
                return false;
            }
            if (!Arrays.equals(startTimestamps, other.startTimestamps)) {
                return false;
            }
            return true;
        }

        @Override
        public String toString() {
            return getClass().getSimpleName();

        }
    }

    @ProxyIgnoreStatics
    public static class DataAnomalyFlags implements Persistable, Serializable {

        private static final long serialVersionUID = 5885163580691105068L;

        public boolean[] attitudeTweakIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] safeModeIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] coarsePointIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] argabrighteningIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] excludeIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] earthPointIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        public boolean[] planetSearchExcludeIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

        public DataAnomalyFlags() {
        }

        public DataAnomalyFlags(boolean[] attitudeTweakIndicators,
            boolean[] safeModeIndicators, boolean[] coarsePointIndicators,
            boolean[] argabrighteningIndicators, boolean[] excludeIndicators,
            boolean[] earthPointIndicators,
            boolean[] planetSearchExcludeIndicators) {

            this.attitudeTweakIndicators = attitudeTweakIndicators;
            this.safeModeIndicators = safeModeIndicators;
            this.coarsePointIndicators = coarsePointIndicators;
            this.argabrighteningIndicators = argabrighteningIndicators;
            this.excludeIndicators = excludeIndicators;
            this.earthPointIndicators = earthPointIndicators;
            this.planetSearchExcludeIndicators = planetSearchExcludeIndicators;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result
                + Arrays.hashCode(argabrighteningIndicators);
            result = prime * result + Arrays.hashCode(attitudeTweakIndicators);
            result = prime * result + Arrays.hashCode(coarsePointIndicators);
            result = prime * result + Arrays.hashCode(earthPointIndicators);
            result = prime * result + Arrays.hashCode(excludeIndicators);
            result = prime * result + Arrays.hashCode(safeModeIndicators);
            result = prime * result
                + Arrays.hashCode(planetSearchExcludeIndicators);
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (!(obj instanceof DataAnomalyFlags)) {
                return false;
            }
            DataAnomalyFlags other = (DataAnomalyFlags) obj;
            if (!Arrays.equals(argabrighteningIndicators,
                other.argabrighteningIndicators)) {
                return false;
            }
            if (!Arrays.equals(attitudeTweakIndicators,
                other.attitudeTweakIndicators)) {
                return false;
            }
            if (!Arrays.equals(coarsePointIndicators,
                other.coarsePointIndicators)) {
                return false;
            }
            if (!Arrays.equals(earthPointIndicators, other.earthPointIndicators)) {
                return false;
            }
            if (!Arrays.equals(excludeIndicators, other.excludeIndicators)) {
                return false;
            }
            if (!Arrays.equals(safeModeIndicators, other.safeModeIndicators)) {
                return false;
            }
            if (!Arrays.equals(planetSearchExcludeIndicators,
                other.planetSearchExcludeIndicators)) {
                return false;
            }
            return true;
        }
    }

}
