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

import static gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType.*;
import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.tpixel.DataQualityFlagsSource;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.kepler.ar.exporter.RollingBandFlags;
import gov.nasa.kepler.ar.exporter.RollingBandFlags.RollingBandKey;

import java.util.*;

import org.apache.commons.lang.ArrayUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableMap;

import static gov.nasa.kepler.ar.exporter.RollingBandFlagSecretDecoderRing.*;

@RunWith(JMock.class)
public class QualityFieldCalculatorTest {

    private Mockery mockery;
    
    private final int startCadence = 128;
    private final int endCadence = 255;
    private final int cadenceLength = endCadence - startCadence + 1;
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    
    /**
     * If there where no anomalous conditions then this should just return
     * an array of zero.
     */
    @Test
    public void testNoProblems() {
        


        final IntTimeSeries discontinuityTimeSeries = 
            mockery.mock(IntTimeSeries.class);
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        final FloatMjdTimeSeries pdcOutliers = 
            mockery.mock(FloatMjdTimeSeries.class);
        final IntTimeSeries paArgabrightening = mockery.mock(IntTimeSeries.class, "pa agabrightening");
        final IntTimeSeries zeroCrossings = mockery.mock(IntTimeSeries.class, "0 crossings");
        final IntTimeSeries thrusterFiring = mockery.mock(IntTimeSeries.class, "thruster");
        final IntTimeSeries possibleFiring = mockery.mock(IntTimeSeries.class, "possible thruster");
        boolean[] nothingFlagged = new boolean[cadenceLength];
        boolean[] everythingFlagged = new boolean[cadenceLength];
        Arrays.fill(everythingFlagged, true);

        int[] cadenceNumbers = new int[cadenceLength];
        Arrays.fill(cadenceNumbers, startCadence);
        
        final TimestampSeries timestampSeries =
            new TimestampSeries(null, null, null, nothingFlagged,
                    everythingFlagged, cadenceNumbers,
                    nothingFlagged, nothingFlagged, nothingFlagged,
                    everythingFlagged, nothingFlagged, nothingFlagged,
                    nothingFlagged);
        final byte[] noRollingBands = new byte[everythingFlagged.length];
        
        final RollingBandFlags rbFlags = mockery.mock(RollingBandFlags.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(rbFlags).flags();
            will(returnValue(ImmutableMap.of(new RollingBandKey(0, 0, 0, 0), noRollingBands)));
        }});
        QualityFieldCalculator qualityCalc = new QualityFieldCalculator();
        final DataQualityFlagsSource source = mockery.mock(DataQualityFlagsSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).anomalies();
            will(returnValue(Collections.EMPTY_LIST));
            atLeast(1).of(source).cosmicRays();
            will(returnValue(Collections.EMPTY_LIST));
            atLeast(1).of(source).discontinuityTimeSeries();
            will(returnValue(discontinuityTimeSeries));
            atLeast(0).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            atLeast(1).of(source).pdcOutliers();
            will(returnValue(pdcOutliers));
            
            atLeast(1).of(source).paArgabrighteningTimeSeries();
            will(returnValue(paArgabrightening));
            
            atLeast(1).of(source).reactionWheelZeroCrossings();
            will(returnValue(zeroCrossings));
            
            atLeast(1).of(source).thrusterFire();
            will(returnValue(thrusterFiring));
            
            atLeast(1).of(source).possibleThusterFire();
            will(returnValue(possibleFiring));
            
            atLeast(1).of(source).collateralCosmicRays();
            will(returnValue(Collections.EMPTY_LIST));
            
            atLeast(1).of(discontinuityTimeSeries).validCadences();
            will(returnValue(Collections.EMPTY_LIST));
            atLeast(1).of(discontinuityTimeSeries).iseries();
            will(returnValue(new int[cadenceLength]));
            
            atLeast(1).of(pdcOutliers).mjd();
            will(returnValue(ArrayUtils.EMPTY_DOUBLE_ARRAY));
            
            atLeast(1).of(paArgabrightening).validCadences();
            will(returnValue(Collections.EMPTY_LIST));
            
            atLeast(1).of(zeroCrossings).validCadences();
            will(returnValue(Collections.EMPTY_LIST));
       
            atLeast(1).of(thrusterFiring).validCadences();
            will(returnValue(Collections.EMPTY_LIST));
            
            atLeast(1).of(possibleFiring).validCadences();
            will(returnValue(Collections.EMPTY_LIST));
            
            atLeast(1).of(source).timestampSeries();
            will(returnValue(timestampSeries));
            
            atLeast(1).of(source).lcTimestampSeries();
            will(returnValue(null));
            
            atLeast(1).of(source).rollingBandFlags();
            will(returnValue(rbFlags));
            
            atLeast(1).of(source).isLcForShortCadence();
            will(returnValue(false));
            
            atLeast(1).of(source).optimalApertureRollingBandFlags();
            will(returnValue(null));
        }});
        
        int[] hopefullyZeroFlags =  qualityCalc.calculateQualityFlags(source);
        assertEquals(endCadence - startCadence +1, hopefullyZeroFlags.length);
        for (int flag : hopefullyZeroFlags) {
            assertEquals(0, flag);
        }
    }
    
    /**
     * Discontinuities every third cadence.
     * Cosmic rays every fourth cadence.
     * PDC outliers every fifth cadence
     * Momentum dumps every sixth cadence
     * attitude tweaks every seventh cadence
     * safe modes every eighth cadence
     * coarse point every ninth cadence
     * earth point every tenth cadence
     * argabrightening every eleventh cadence
     * manual exclude every twelveth cadence
     * pa argabrightening every 13th cadence
     * collateral cosmic ray every 14th cadence
     * reaction wheel zero crossings every 15th cadence
     * detector electronics anomaly every 16th cadence
     * fine point every 4th cadence
     * rolling band every 5th cadence
     */
    @Test
    public void testQualityFlagCalculator() {
        
        final int[] expectedFlags = new int[cadenceLength];
        boolean[] gaps = new boolean[cadenceLength];
        Arrays.fill(gaps, true);
        Arrays.fill(expectedFlags, QualityFieldCalculator.DATA_GAP);
        int[] values = new int[gaps.length];
        for (int c=startCadence; c <=endCadence; c+=3) {
            gaps[c - startCadence] = false;
            values[c - startCadence] = 1;
            expectedFlags[c - startCadence] |= QualityFieldCalculator.DISCONTINUITY;
            expectedFlags[c - startCadence] &= ~QualityFieldCalculator.DATA_GAP;
        }
        final IntTimeSeries discontinuityTimeSeries = 
            new IntTimeSeries(new FsId("/c/a"), 
                values, startCadence, endCadence, gaps, 0L);
        
        final double[] mjds = new double[endCadence - startCadence + 1];
        final int[] cadences = new int[mjds.length];
        for (int i=0; i < mjds.length; i++) {
            mjds[i] = i + 55555.0;
            cadences[i] = i + startCadence;
        }
        
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {{
            for (int i=0; i < mjds.length; i++) {
                atLeast(0).of(mjdToCadence).mjdToCadence(mjds[i]);
                will(returnValue(cadences[i]));
            }
        }});
        
        final double[] cosmicRayMjds = new double[(mjds.length + 4 - 1) / 4];
        for (int i=0; i < mjds.length; i +=4) {
            cosmicRayMjds[i/4] = mjds[i];
            expectedFlags[i] |= QualityFieldCalculator.COSMIC_RAY;
        }
        final FloatMjdTimeSeries cosmicRaySeries = 
            mockery.mock(FloatMjdTimeSeries.class, "cosmicrays");
        
        final List<FloatMjdTimeSeries> cosmicRays = 
            Collections.singletonList(cosmicRaySeries);
        mockery.checking(new Expectations() {{
            atLeast(1).of(cosmicRaySeries).mjd();
            will(returnValue(cosmicRayMjds));
        }});
        
        final double[] pdcOutlierMjds = new double[(mjds.length + 5 - 1)/5];
        for (int i=0; i < mjds.length; i+=5) {
            pdcOutlierMjds[i/5] = mjds[i];
            expectedFlags[i] |= QualityFieldCalculator.OUTLIER;
        }
        
        final FloatMjdTimeSeries pdcOutliers = 
            mockery.mock(FloatMjdTimeSeries.class, "outliers");
        mockery.checking(new Expectations() {{
            atLeast(1).of(pdcOutliers).mjd();
            will(returnValue(pdcOutlierMjds));
        }});
        
        final boolean[] momentumDump = new boolean[mjds.length];
        for (int i=0; i < momentumDump.length; i+=6) {
            momentumDump[i] = true;
            expectedFlags[i] |= QualityFieldCalculator.DESAT;
        }
        
        boolean[] isLdeOos = new boolean[cadenceLength];
        boolean[] isLdeParEr = new boolean[cadenceLength];
        boolean[] isScrcErr = new boolean[cadenceLength];
        boolean[] isSefiAcc = new boolean[cadenceLength];
        boolean[] isSefiCad = new boolean[cadenceLength];
        for (int i=0,type=0; i < cadenceLength; i += 16) {
            expectedFlags[i] |= QualityFieldCalculator.DETECTOR_ELECTRONICS_ANOMALY;
            switch (type) {
            case 0: isLdeOos[i] = true; break;
            case 1: isLdeParEr[i] = true; break;
            case 2: isScrcErr[i] = true; break;
            case 3: isSefiAcc[i] = true; break;
            case 4: isSefiCad[i] = true; break;
            default: throw new IllegalStateException("detector anomaly type");
            }
            type = (type + 1) % 5;
        }
        
        boolean[] isFinePt = new boolean[cadenceLength];
        Arrays.fill(isFinePt, true);
        for (int i=0; i < cadenceLength; i += 4) {
            isFinePt[i] = false;
            expectedFlags[i] |= QualityFieldCalculator.NOT_FINE_POINT;
        }
        
        final TimestampSeries timestampSeries =
            new TimestampSeries(null, null, null, gaps, null, cadences, isSefiAcc,
                    isSefiCad, isLdeOos, isFinePt, momentumDump, isLdeParEr,
                    isScrcErr);
        
        final IntTimeSeries paArgabrightening = 
            generateFlagTimeSeries(expectedFlags, startCadence, endCadence,
                13, QualityFieldCalculator.PA_ARGABRIGHTENING);
        
        final IntTimeSeries zeroCrossings = 
            generateFlagTimeSeries(expectedFlags, startCadence, endCadence,
                15, QualityFieldCalculator.REACTION_WHEEL_0_CROSSING);
        
        final List<DataAnomaly> anomalies = new ArrayList<DataAnomaly>();
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 7, ATTITUDE_TWEAK, QualityFieldCalculator.ATTITUDE_TWEAK);
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 8, SAFE_MODE, QualityFieldCalculator.SAFE_MODE);
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 9, COARSE_POINT, QualityFieldCalculator.COARSE_POINT);
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 10, EARTH_POINT, QualityFieldCalculator.EARTH_POINT);
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 11, ARGABRIGHTENING, QualityFieldCalculator.ARGABRIGHTENING);
        generateDataAnomaly(anomalies, expectedFlags, startCadence, endCadence, 12, EXCLUDE, QualityFieldCalculator.MANUAL_EXCLUDE);
        
        double[] collateralCosmicRayMjd = new double[(mjds.length +14 -1 )/14];
        for (int i=0; i < mjds.length; i+=14) {
            collateralCosmicRayMjd[i/14] = mjds[i];
            expectedFlags[i] |= QualityFieldCalculator.COLLATERAL_COSMIC_RAY;
        }
        
        final FloatMjdTimeSeries collateralCosmicRaySeries = 
            new FloatMjdTimeSeries(new FsId("/cal/collateral/cr"), 0, Double.MAX_VALUE, collateralCosmicRayMjd, 
                new float[collateralCosmicRayMjd.length], 14);
        
        final byte[] rollingBandFlags = new byte[gaps.length];
        final byte[] optimalApertureRollingBandFlags = new byte[gaps.length];
        final RollingBandFlags rbFlags = mockery.mock(RollingBandFlags.class, "all rbflags");
        final RollingBandFlags optimalApertureRbFlags = mockery.mock(RollingBandFlags.class, "opt ap rbflags");
        mockery.checking(new Expectations() {{
            for (int c=startCadence; c <= endCadence; c+= 5) {
                int cadenceIndex = c - startCadence;
                rollingBandFlags[cadenceIndex] = ROLLING_BAND_MASK;
                expectedFlags[cadenceIndex] |= QualityFieldCalculator.ROLLING_BAND_ON_APERTURE_ROW;
                if ( (c % 10) == 0) {
                    optimalApertureRollingBandFlags[cadenceIndex] = ROLLING_BAND_MASK;
                    rollingBandFlags[cadenceIndex] |= QualityFieldCalculator.ROLLING_BAND_ON_OPTIMAL_APERTURE_ROW;
                }
            }
            atLeast(1).of(rbFlags).flags();
            will(returnValue(ImmutableMap.of(new RollingBandKey(0, 0, 0, 0), rollingBandFlags)));
            atLeast(1).of(optimalApertureRbFlags).flags();
            will(returnValue(ImmutableMap.of(new RollingBandKey(0, 0, 0, 0), optimalApertureRollingBandFlags)));
        }});
        
        final IntTimeSeries thruster = 
            generateFlagTimeSeries(expectedFlags, startCadence, endCadence, 17, QualityFieldCalculator.THRUSTER_FIRE);
        
        final IntTimeSeries possibleThruster =
            generateFlagTimeSeries(expectedFlags, startCadence, endCadence, 18, QualityFieldCalculator.POSSIBLE_THRUSTER_FIRE);
        
        final DataQualityFlagsSource source = 
            mockery.mock(DataQualityFlagsSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).anomalies();
            will(returnValue(anomalies));
            atLeast(1).of(source).cosmicRays();
            will(returnValue(cosmicRays));
            atLeast(1).of(source).discontinuityTimeSeries();
            will(returnValue(discontinuityTimeSeries));
            atLeast(0).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            atLeast(1).of(source).pdcOutliers();
            will(returnValue(pdcOutliers));
            atLeast(1).of(source).paArgabrighteningTimeSeries();
            will(returnValue(paArgabrightening));
            atLeast(1).of(source).collateralCosmicRays();
            will(returnValue(Collections.singleton(collateralCosmicRaySeries)));
            atLeast(1).of(source).reactionWheelZeroCrossings();
            will(returnValue(zeroCrossings));
            atLeast(1).of(source).timestampSeries();
            will(returnValue(timestampSeries));
            atLeast(1).of(source).lcTimestampSeries();
            will(returnValue(null));
            atLeast(1).of(source).rollingBandFlags();
            will(returnValue(rbFlags));
            atLeast(1).of(source).thrusterFire();
            will(returnValue(thruster));
            atLeast(1).of(source).possibleThusterFire();
            will(returnValue(possibleThruster));
            atLeast(1).of(source).isLcForShortCadence();
            will(returnValue(false));
            atLeast(1).of(source).optimalApertureRollingBandFlags();
            will(returnValue(optimalApertureRbFlags));
        }});
        
        QualityFieldCalculator qualityCalc = new QualityFieldCalculator();
        int[] actualFlags = qualityCalc.calculateQualityFlags(source);
        assertArrayEquals(expectedFlags, actualFlags);
    
    }
    
    private static IntTimeSeries generateFlagTimeSeries(
        int[] expectedFlags, int startCadence,
        int endCadence, int step, int flag) {
        
        boolean[] gaps = new boolean[endCadence - startCadence +1];
        Arrays.fill(gaps, true);
        int[] flagData = new int[gaps.length];
        for (int c=startCadence; c <= endCadence; c+= step) {
            int index = c - startCadence;
                expectedFlags[index] |= flag;
            flagData[index] = 1;
            gaps[index] = false;
        }
        
        FsId fakeId = new FsId("/fake/id");
        return new IntTimeSeries(fakeId, flagData, startCadence, endCadence, gaps, 877);
    }

    private static void generateDataAnomaly(List<DataAnomaly> anomalies,
        int[] expectedFlags,
        int startCadence, int endCadence, int step, DataAnomalyType type,
        int flag) {

        for (int c=startCadence; c <=endCadence; c+= step) {
            expectedFlags[c - startCadence] |= flag;
            DataAnomaly dataAnomaly = new DataAnomaly(type, Cadence.CADENCE_LONG, c, c);
            anomalies.add(dataAnomaly);
        }
        
    }

}
