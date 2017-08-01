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

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;

import gov.nasa.kepler.ar.exporter.RollingBandFlags.RollingBandKey;
import gov.nasa.kepler.ar.exporter.tpixel.DataQualityFlagsSource;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import static gov.nasa.kepler.ar.exporter.RollingBandFlagSecretDecoderRing.*;

/**
 * Creates the QUALITY column from a variety of data sources for one
 * quarter's worth of data.
 * 
 * @author Sean McCauliff
 *
 */
public class QualityFieldCalculator {

    public static final int ATTITUDE_TWEAK =     1; //1
    public static final int SAFE_MODE =          2; //2
    public static final int COARSE_POINT =       4; //3
    public static final int EARTH_POINT =        8; //4
    public static final int REACTION_WHEEL_0_CROSSING = 16; //5
    public static final int DESAT =              32; //6
    public static final int ARGABRIGHTENING =    64; //7 global argabrightening
    public static final int COSMIC_RAY =         128; //8 Get from cosmic ray image
    public static final int MANUAL_EXCLUDE =     256; //9
    //static final int reserved          512;  //10  This is reserved for eventual usage by bad pixel flags
    public static final int DISCONTINUITY =      1024; // 11 Get from PDC flags
    public static final int OUTLIER =            2048; // 12 Get from PDC outliers
    public static final int PA_ARGABRIGHTENING = 4096; // 13
    public static final int COLLATERAL_COSMIC_RAY = 8192; // 14 
    public static final int DETECTOR_ELECTRONICS_ANOMALY = 16384; //15
    public static final int NOT_FINE_POINT =     32768; //16
    public static final int DATA_GAP =           65536; //17
    public static final int ROLLING_BAND_ON_OPTIMAL_APERTURE_ROW = 131072; //18
    public static final int ROLLING_BAND_ON_APERTURE_ROW = 262144; //19
    public static final int POSSIBLE_THRUSTER_FIRE = 524288; //20
    public static final int THRUSTER_FIRE = 1048576; //21
    
    public int[] calculateQualityFlags(DataQualityFlagsSource source) {
        
        final int startCadence = source.startCadence();
        final int endCadence = source.endCadence();
        
        final int[] qualityFlags = new int[endCadence - startCadence + 1];
        for (DataAnomaly anomaly : source.anomalies()) {
            int startIndex = anomaly.getStartCadence() - startCadence;
            if (startIndex < 0) {
                continue;
            }
            int endIndex = Math.min(anomaly.getEndCadence() - startCadence, endCadence - startCadence);
            int flag = dataAnomalyTypeToFlagType(anomaly);
            for (int i=startIndex; i <= endIndex; i++) {
                qualityFlags[i] |=  flag;
            }
        }
        
        addFlagsFromMjdTimeSeries(qualityFlags, source.cosmicRays(), COSMIC_RAY, 
            source.mjdToCadence(), startCadence);
        
        addFlagsFromMjdTimeSeries(qualityFlags, source.collateralCosmicRays(),
            COLLATERAL_COSMIC_RAY, source.mjdToCadence(), startCadence);
        
        TimestampSeries timestampSeries = source.timestampSeries();
        if (source.isLcForShortCadence()) {
            timestampSeries = source.lcTimestampSeries();
        }
        int[] momentiumDumpAbsoluteCadences = timestampSeries.cadenceNumbers;
        boolean[] isMomentiumDump = timestampSeries.isMmntmDmp;
        boolean[] gapIndicators = timestampSeries.gapIndicators;
        boolean[] isFinePoint = timestampSeries.isFinePnt;
        boolean[] isLdeOos = timestampSeries.isLdeOos;
        boolean[] isLdeParEr = timestampSeries.isLdeParEr;
        boolean[] isScrcErr = timestampSeries.isScrcErr;
        boolean[] isSefiAcc = timestampSeries.isSefiAcc;
        boolean[] isSefiCad = timestampSeries.isSefiCad;
        int startIndex = Arrays.binarySearch(momentiumDumpAbsoluteCadences, startCadence);
        if (startIndex < 0) {
            throw new IllegalStateException("Missing start cadence(" + startCadence + ") ," +
                "first cadence is " + momentiumDumpAbsoluteCadences[0] + ".");
        }
        for (int i=startIndex; i < momentiumDumpAbsoluteCadences.length; i++) {

            int qualityFlagsIndex = momentiumDumpAbsoluteCadences[i] - startCadence;
            if (qualityFlagsIndex >= qualityFlags.length) {
                break;
            }
            if (qualityFlagsIndex < 0) {
                continue;
            }
            if (isMomentiumDump[i]) {
                qualityFlags[qualityFlagsIndex] |= DESAT;
            }
            if (gapIndicators[i]) {
                qualityFlags[qualityFlagsIndex] |= DATA_GAP;
            }
            if (!isFinePoint[i]) {
                qualityFlags[qualityFlagsIndex] |= NOT_FINE_POINT;
            }
            if (isLdeOos[i] || isLdeParEr[i] ||isScrcErr[i] || isSefiAcc[i] || isSefiCad[i]) {
                qualityFlags[qualityFlagsIndex] |= DETECTOR_ELECTRONICS_ANOMALY;
            }
        }

        addFlagsFromMjdTimeSeries(qualityFlags, 
            Collections.singleton(source.pdcOutliers()), OUTLIER,
            source.mjdToCadence(), startCadence);
        
        addFlagsFromFlagTimeSeries(source.discontinuityTimeSeries(),
            startCadence, qualityFlags, DISCONTINUITY);
        
        if (source.discontinuityTimeSeries() != null) {
            int[] discontinutyPerCadence = source.discontinuityTimeSeries().iseries();
            for (SimpleInterval valid : source.discontinuityTimeSeries().validCadences()) {
                for (int c= (int)valid.start(); c <= (int) valid.end(); c++) {
                    int index = c - startCadence;
                    if (index < 0) {
                        continue;
                    }
                    if (index >= qualityFlags.length) {
                        break;
                    }
                    if (discontinutyPerCadence[index] > 0) {
                        qualityFlags[index] |= DISCONTINUITY;
                    }
                }
            }
        }
        
        addFlagsFromFlagTimeSeries(source.paArgabrighteningTimeSeries(),
            startCadence, qualityFlags, PA_ARGABRIGHTENING);
        
        addFlagsFromFlagTimeSeries(source.reactionWheelZeroCrossings(),
            startCadence, qualityFlags, REACTION_WHEEL_0_CROSSING);
        
        addFlagsFromFlagTimeSeries(source.thrusterFire(),
            startCadence, qualityFlags, THRUSTER_FIRE);
        
        addFlagsFromFlagTimeSeries(source.possibleThusterFire(),
            startCadence, qualityFlags, POSSIBLE_THRUSTER_FIRE);
        
        if (source.rollingBandFlags() != null) {
            addRollingBandFlags(source.rollingBandFlags(), qualityFlags, 
                source.lcTimestampSeries(), source.timestampSeries(),
                ROLLING_BAND_ON_APERTURE_ROW);
        }
        if (source.optimalApertureRollingBandFlags() != null) {
            addRollingBandFlags(source.optimalApertureRollingBandFlags(), qualityFlags,
                source.lcTimestampSeries(), source.timestampSeries(),
                ROLLING_BAND_ON_OPTIMAL_APERTURE_ROW);
        }
        return qualityFlags;
    }

    /**
     * 
     * @param rbFlags non-null
     * @param qualityFlags  This may be modified.
     * @param lcTimestmapSeries  This may be null in which case this assumes we are processing
     * long cadence.  Else this assumes we are processing short cadence and want the
     * bit fields interpolated for long cadence.
     * @param mask the bit to set in the quality flags
     */
    private static void addRollingBandFlags(RollingBandFlags rbFlags, final int[] qualityFlags,
        TimestampSeries lcTimestampSeries, TimestampSeries scTimestampSeries,
        int mask) {
        
        int[] lcQualityFlags = qualityFlags;
        if (lcTimestampSeries != null) {
            lcQualityFlags = new int[lcTimestampSeries.cadenceNumbers.length];
        }
        
        for (Map.Entry<RollingBandKey, byte[]> entry : rbFlags.flags().entrySet()) {
            byte[] dynablackFlags = entry.getValue();
            for (int i=0; i < lcQualityFlags.length; i++) {
                if ((dynablackFlags[i] & ROLLING_BAND_MASK) != 0) {
                    lcQualityFlags[i] |= mask;
                }
            }
        }
        
        if (lcTimestampSeries == null) {
            return;
        }
        
        //Match Short cadence to Long cadence
        ShortToLongCadenceMap shortToLongCadenceMap = 
            new ShortToLongCadenceMap(lcTimestampSeries, scTimestampSeries);
        int[] shortCadences = scTimestampSeries.cadenceNumbers;
        boolean[] shortGaps = scTimestampSeries.gapIndicators;
        int lcStartCadence = lcTimestampSeries.cadenceNumbers[0];
        int rollingBandQualityMask = ROLLING_BAND_ON_APERTURE_ROW | ROLLING_BAND_ON_OPTIMAL_APERTURE_ROW;
        for (int i=0; i < shortCadences.length; i++) {
            if (shortGaps[i]) {
                continue;
            }
            int longCadence = shortToLongCadenceMap.coveringLongCadence(shortCadences[i]);
            if (longCadence == -1) {
                continue;
            }
            qualityFlags[i] |= 
                lcQualityFlags[longCadence - lcStartCadence] & rollingBandQualityMask;
        }
    }
   
    /**
     * 
     * @param intTimeSeries This time series should store things where a gap
     * indicates not detected and a non-gap indicates maybe detected. This may be
     * null.
     */
    private static void addFlagsFromFlagTimeSeries(IntTimeSeries intTimeSeries,
        int startCadence, int[] qualityFlags, int flag) {
        
        if (intTimeSeries == null) {
            return;
        }
        
        for (SimpleInterval detectedInterval : intTimeSeries.validCadences()) {
            int[] flagData = intTimeSeries.iseries();
            for (int c=(int)detectedInterval.start(); c <= (int) detectedInterval.end(); c++) {
                int index = c - startCadence;
                if (index < 0) {
                    continue;
                }
                if (index >= qualityFlags.length) {
                    break;
                }
                if (flagData[index] != 0) {
                    qualityFlags[index] |= flag;
                }
            }
        }
    }
    
    private static void addFlagsFromMjdTimeSeries( int[] qualityFlags,
        Collection<FloatMjdTimeSeries> mjdTimeSeries, final int flag,
        MjdToCadence mjdToCadence, final int startCadence) {

        if (mjdTimeSeries == null) {
            return;
        }
        
        for (FloatMjdTimeSeries singleTimeSeries : mjdTimeSeries) {
            if (singleTimeSeries == null) {
                continue;
            }
            
            for (double mjd : singleTimeSeries.mjd()) {
                int cadence = mjdToCadence.mjdToCadence(mjd);
                int qualityIndex = cadence - startCadence;
                if (qualityIndex < 0) {
                    continue;
                }
                if (qualityIndex >= qualityFlags.length) {
                    break;
                }
                qualityFlags[qualityIndex] |= flag;
            }
        }
    }
    
    private int dataAnomalyTypeToFlagType(DataAnomaly anomaly) {
        switch (anomaly.getDataAnomalyType()) {
            case ATTITUDE_TWEAK:
                return ATTITUDE_TWEAK;
            case SAFE_MODE:
                return SAFE_MODE;
            case COARSE_POINT:
                return COARSE_POINT;
            case ARGABRIGHTENING:
                return ARGABRIGHTENING;
            case EXCLUDE:
                return MANUAL_EXCLUDE;
            case EARTH_POINT:
                return EARTH_POINT;
            case PLANET_SEARCH_EXCLUDE:
                return 0;
            default:
               throw new IllegalStateException("Unhandled data anomaly type "
                    + anomaly.getDataAnomalyType());
        }
    }
}
