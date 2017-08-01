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

import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.*;
import static org.junit.Assert.*;
import gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.pdc.FilledCadencesUtil;

import java.util.Arrays;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class FluxTimeSeriesProcessingTest {

    private Mockery mockery;

    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }

    @Test
    public void testfilledMjdTimeSeriesPreifxGapped() {
        boolean t = true;
        boolean f = false;
        //These are crazy, unrealistic values.
        double[] orig = new double[]   { 0, 0, 0,    1.0, 1.5, 1.7, 1.9,     0,    2.1 };
        boolean[] gaps = new boolean[] {t, t, t,      f,   f,   f,   f,      t,     f};
        double[] expected = {0.1, 0.4, 0.7, 1.0, 1.5, 1.7, 1.9, 2.2, 2.1};
        
        double[] filled = filledMjdTimeSeries(orig, gaps);
        
        for (int i=0; i < gaps.length; i++) {
            assertEquals(expected[i], filled[i], 0.000000000001);
        }
    }
    
    @Test
    public void testfilledMjdTimeSeriesNoPrefixFill() {
        boolean t = true;
        boolean f = false;
        //These are crazy, unrealistic values.
        double[] orig = new double[]   { 0.3, 0, 0,    1.0, 1.5, 1.7, 1.9,     0,    2.1 };
        boolean[] gaps = new boolean[] {f, t, t,      f,   f,   f,   f,      t,     f};
        double[] expected = {0.3, 0.6, 0.9, 1.0, 1.5, 1.7, 1.9, 2.2, 2.1};
        double[] filled = filledMjdTimeSeries(orig, gaps);
        
        for (int i=0; i < gaps.length; i++) {
            assertEquals(expected[i], filled[i], 0.000000000001);
        }
    }
    
    @Test
    public void testCorrectedUnfilledFlux() {
        final int FILL_MJD_INDEX = 7;
        final int OUTLIER_MJD_INDEX = 3;
        final float OUTLIER_ORIG = 2.3f;

        final double[] mjds = new double[16];
        for (int i = 0; i < mjds.length; i++) {
            mjds[i] = 1.0 + 1.0 / mjds.length * i;
        }
        FsId id = new FsId("/pdc/fill");
        IntTimeSeries filled = FilledCadencesUtil.indicesToIndicators(id, 0, 7,
            new int[] { OUTLIER_MJD_INDEX, FILL_MJD_INDEX }, 89L);

        FloatMjdTimeSeries outlier = new FloatMjdTimeSeries(id, 1.0, 2.0,
            new double[] { mjds[OUTLIER_MJD_INDEX] },
            new float[] { OUTLIER_ORIG }, 1L);

        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {
            {
                exactly(1).of(mjdToCadence)
                    .mjdToCadence(mjds[OUTLIER_MJD_INDEX]);
                will(returnValue(OUTLIER_MJD_INDEX));
            }
        });

        float[] originalValues = new float[mjds.length];
        for (int i = 0; i < mjds.length; i++) {
            originalValues[i] = (float) (i * Math.PI);
        }
        FloatTimeSeries pdcTimeSeries = new FloatTimeSeries(id, originalValues,
            0, mjds.length - 1, new boolean[mjds.length], 1L);

        float[] unfill = correctedUnfilledFlux(mjdToCadence, filled, outlier,
            pdcTimeSeries, Float.NEGATIVE_INFINITY);

        float[] expected = Arrays.copyOf(originalValues, originalValues.length);
        expected[FILL_MJD_INDEX] = Float.NEGATIVE_INFINITY;
        expected[OUTLIER_MJD_INDEX] = OUTLIER_ORIG;

        assertTrue(Arrays.equals(expected, unfill));

    }
    
    @Test
    public void timeCorrrection() throws Exception {
        FsId id = new FsId("/test/1");
        float[] correctionInDays = new float[100];
        for (int i=0; i < correctionInDays.length; i++) {
            correctionInDays[i] = .001f * i;
        }
        boolean[] gaps = new boolean[100];
        gaps[50] = true;
        
        FloatTimeSeries timeCorrectionSeries = 
            new FloatTimeSeries(id, correctionInDays, 0, 99, gaps, 1L);
        float[] correctionInSeconds = 
            FluxTimeSeriesProcessing.timeCorrectionSeries(timeCorrectionSeries, -1000.0f);
        float[] expected = new float[correctionInDays.length];
        for (int i=0; i < expected.length; i++) {
            expected[i] = (float) (.001f * i * 60.0 * 60.0 * 24.0);
        }
        expected[50] = -1000.0f;
        assertEquals(expected.length, correctionInSeconds.length);
        for (int i=0; i < expected.length; i++) {
            assertEquals(expected[i], correctionInSeconds[i], 0.0);
        }
        
    }
    @Test
    public void hoursToDegrees() throws Exception {
        assertEquals(180.0, decimalHoursToDecimalDegrees(12.0),0.0);
    }
    
    @Test(expected=java.lang.IllegalArgumentException.class)
    public void hoursToDegreesFail() throws Exception {
        decimalHoursToDecimalDegrees(24.0);
    }
    
    @Test
    public void resizeSeriesUnTouched() {
        float[]  fseries = new float[1024];
        Arrays.fill(fseries, 5);
        float[] resized = resizeSeries(0, 1023, fseries, 0, 1023, (float) Math.PI);
        assertEquals(fseries, resized);
    }
    
    @Test
    public void resizeSeriesTruncateStart() {
        float[] fseries = generateTestSeries(1024);
        
        float[] resized = resizeSeries(5, 1023, fseries, 0, 1023, -1);
        assertEquals(1019, resized.length);
        assertEquals((float) (Math.PI * 5), resized[0], 0);
        assertEquals((float) (Math.PI * 1023), resized[resized.length - 1], 0);
    }
    
    @Test
    public void resizeSeriesTruncateEnd() {
        float[] fseries = generateTestSeries(1024);
        float[] resized = resizeSeries(0, 1018, fseries, 0, 1023, -1);
        assertEquals(1019, resized.length);
        assertEquals((float)0, resized[0], 0);
        assertEquals((float) (Math.PI * 1018), resized[resized.length - 1], 0);
    }
    
    @Test
    public void resizeSeriesPadStart() {
        float[] fseries = generateTestSeries(1024);
        float[] resized = resizeSeries(0, 1033, fseries, 10, 1033, -1);
        assertEquals(1034, resized.length);
        assertEquals((float) -1, resized[0], 0);
        assertEquals((float) -1, resized[9], 0);
        assertEquals((float) 0, resized[10], 0);
        assertEquals(fseries[1023], resized[1033], 0);
    }
    
    @Test
    public void resizeSeriesPadEnd() {
        float[] fseries =  generateTestSeries(1024);
        float[] resized = resizeSeries(0, 1033, fseries, 0, 1023, -1);
        assertEquals(1034, resized.length);
        assertEquals((float) 0, resized[0], 0);
        assertEquals(fseries[fseries.length - 1], resized[fseries.length - 1], 0);
        assertEquals((float) -1, resized[fseries.length], 0);
        assertEquals((float) -1, resized[1033], 0);
    }
    

    ////// Double precision resize tests. ////
    @Test
    public void resizeSeriesUnTouchedDouble() {
        double[] dseries = new double[1024];
        Arrays.fill(dseries, 5);
        double[] resized = resizeSeries(0, 1023, dseries, 0, 1023,  Math.PI);
        assertEquals(dseries, resized);
    }
    
    @Test
    public void resizeSeriesTruncateStartDouble() {
        double[] dseries = generateDoubleTestSeries(1024);
        
        double[] resized = resizeSeries(5, 1023, dseries, 0, 1023, -1);
        assertEquals(1019, resized.length);
        assertEquals( (Math.PI * 5), resized[0], 0);
        assertEquals( (Math.PI * 1023), resized[resized.length - 1], 0);
    }
    
    @Test
    public void resizeSeriesTruncateEndDouble() {
        double[] dseries = generateDoubleTestSeries(1024);
        double[] resized = resizeSeries(0, 1018, dseries, 0, 1023, -1);
        assertEquals(1019, resized.length);
        assertEquals(0.0, resized[0], 0);
        assertEquals( (Math.PI * 1018), resized[resized.length - 1], 0);
    }
    
    @Test
    public void resizeSeriesPadStartDouble() {
        double[] dseries = generateDoubleTestSeries(1024);
        double[] resized = resizeSeries(0, 1033, dseries, 10, 1033, -1);
        assertEquals(1034, resized.length);
        assertEquals( -1.0, resized[0], 0);
        assertEquals( -1.0, resized[9], 0);
        assertEquals( 0.0, resized[10], 0);
        assertEquals(dseries[1023], resized[1033], 0);
    }
    
    @Test
    public void resizeSeriesPadEndDouble() {
        double[] dseries =  generateDoubleTestSeries(1024);
        double[] resized = resizeSeries(0, 1033, dseries, 0, 1023, -1);
        assertEquals(1034, resized.length);
        assertEquals( 0.0, resized[0], 0);
        assertEquals(dseries[dseries.length - 1], resized[dseries.length - 1], 0);
        assertEquals( -1.0, resized[dseries.length], 0);
        assertEquals( -1.0, resized[1033], 0);
    }
    
    private static double[] generateDoubleTestSeries(final int size) {
        double[] dseries = new double[size];
        for (int i=0; i < dseries.length; i++) {
            dseries[i] = i * Math.PI;
        }
        return dseries;
    }
    
    private static float[] generateTestSeries(final int size) {
        final float[] rv = new float[size];
        for (int i=0; i < size; i++) {
            rv[i] =  (float) (i * Math.PI);
        }
        return rv;
    }
    
    @Test
    public void barycentricCorrectionStartOfFirstCadenceTest() {
        float[] midPointBarycentricCorrections = new float[] { 1.5f, 2.5f, 3.51f};
        boolean[] gaps1 = new boolean[] { false, false, false};
        FloatTimeSeries correctionSeries = 
            new FloatTimeSeries(new FsId("/barycentric/mid-cadence/corrections"),
                midPointBarycentricCorrections, 0, 2, gaps1, 0, true);
        
        
        float startCorrection = 
            barycentricCorrectionStartOfFirstCadence(correctionSeries, 0, 2);
        assertEquals(1.0, startCorrection,0.0);
     
        startCorrection =
            barycentricCorrectionStartOfFirstCadence(correctionSeries, 1, 2);
        assertEquals(2.5f - (3.51f - 2.5f)/2.0, startCorrection, 0.0000001);
        
    }
    
    
    @Test(expected=IllegalArgumentException.class)
    public void failBarycentricCorrectionStartOfFirstCadenceTest() {
        FloatTimeSeries correctionSeries = 
            new FloatTimeSeries(new FsId("/barycentric/mid-cadence/corrections"),
                new float[3], 0, 2, new boolean[] { true, false, false}, 0, true);
        barycentricCorrectionStartOfFirstCadence(correctionSeries,0, 2);
    }
    
    @Test
    public void barycentricCorrectionEndOfLastCadenceTest() {
        
        float[] midPointBarycentricCorrections = new float[] { 1.5f, 2.5f, 3.51f};
        boolean[] gaps1 = new boolean[] { false, false, false};
        FloatTimeSeries correctionSeries = 
            new FloatTimeSeries(new FsId("/barycentric/mid-cadence/corrections"),
                midPointBarycentricCorrections, 0, 2, gaps1, 0, true);
        float endCorrection =
            barycentricCorrectionEndOfLastCadence(correctionSeries, 0, 2);
        assertEquals(3.51+((3.51-2.5)/2.0), endCorrection,.000001);
        
        endCorrection =
            barycentricCorrectionEndOfLastCadence(correctionSeries, 0,1);
        assertEquals(3.0, endCorrection,.0000001);
    }
    
    @Test(expected=IllegalArgumentException.class)
    public void failBarycentricCorrectionEndOfLastCadenceTest() {
        FloatTimeSeries correctionSeries = 
            new FloatTimeSeries(new FsId("/barycentric/mid-cadence/corrections"),
                new float[3], 0, 2, new boolean[] { false, false, true}, 0, true);
        barycentricCorrectionEndOfLastCadence(correctionSeries, 0, 2);
    }
    
    @Test
    public void uniqueTimeSeriesValueTest() {
        assertEquals(null, uniqueValue(null));
        
        FloatTimeSeries empty = new FloatTimeSeries(new FsId("/bogus/blah"),new float[] { 1f }, 0, 0, new boolean[] { true }, 999);
        assertEquals(null, uniqueValue(empty));
        
        FloatTimeSeries something = new FloatTimeSeries(new FsId("/bigus/blah"), new float[] { 1f, 1f}, 0, 1, new boolean[2], 999);
        assertEquals(1.0f, uniqueValue(something), 0.0f);
        
        FloatTimeSeries nans = new FloatTimeSeries(new FsId("/bigus/nanme"), new float[] { Float.NaN, Float.NaN} ,0, 1, new boolean[2], 999);
        assertEquals(null, uniqueValue(nans));
    }
    
    @Test(expected=IllegalArgumentException.class)
    public void uniqueTimeSeriesTestFail() {
        FloatTimeSeries mismatch = new FloatTimeSeries(new FsId("/non/unique"), new float[] { Float.NaN, 2.0f}, 0, 1, new boolean[2], 999);
        uniqueValue(mismatch);
    }
}
