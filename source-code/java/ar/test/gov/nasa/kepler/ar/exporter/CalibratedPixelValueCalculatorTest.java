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

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.exporter.FluxPixelValueCalculator;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.Maps;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CalibratedPixelValueCalculatorTest {

    private final float floatE = (float) Math.E;
    private final float floatPI = (float) Math.PI;
    
    private Mockery mockery;
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    /**
     * Three cadence long data.  The middle cadence is gapped.  The last cadence
     * has a cosmic ray.
     */
    @Test
    public void calculateCalibratedPixelValues() {
        FluxPixelValueCalculator calc = new FluxPixelValueCalculator();
        final Map<FsId,TimeSeries> fsIdToTimeSeries = new HashMap<FsId, TimeSeries>();
        @SuppressWarnings("unchecked")
        final Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries = mockery.mock(Map.class, "mjd");
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
      
        final int startCadence = 7;
        final int endCadence = 9;
        final int originator = 89;
        
        final float COSMIC_RAY_VALUE = .000001f;
        float[] origPixel = new float[] { 3.14f, 6.28f, 9.42f};
        double[] origPixelDouble = new double[] { origPixel[0], origPixel[1], origPixel[2]};
        float[] ummPixel = new float[3];
        Arrays.fill(ummPixel, floatPI);
        boolean[] gaps = new boolean[] { false, true, false};
        double[] backgroundPixel = new double[] { 7, 1.4, 2.1};
        double[] backgroundUmmPixel = new double[3];
        Arrays.fill(backgroundUmmPixel, floatE);
        double[] expected = new double[3];
        expected[0] = origPixelDouble[0] - backgroundPixel[0];
        expected[1] = Double.NaN;
        expected[2] = origPixelDouble[2] - backgroundPixel[2] - (double) COSMIC_RAY_VALUE;
        double[] expectedUmm = new double[3];
        expectedUmm[0] = Math.sqrt((double)ummPixel[0] * (double) ummPixel[0] + 
            backgroundUmmPixel[0] * backgroundUmmPixel[0]);
        expectedUmm[1] = Float.NaN;
        expectedUmm[2] = expectedUmm[0];
        
        final FloatMjdTimeSeries cosmicRaySeries = 
            new FloatMjdTimeSeries(new FsId("/a/b"), 0.0, 2.0, 
                    new double[] { 2.0 }, new float[] { COSMIC_RAY_VALUE}, 1);
        final Pixel pixel = new Pixel(0, 0);
        final Map<Pixel, FloatMjdTimeSeries> cosmicRayMap = Maps.newHashMap();
        cosmicRayMap.put(pixel, cosmicRaySeries);
        
        final Map<Pixel, TimeSeries> calibratedPixelMap = Maps.newHashMap();
        final FloatTimeSeries calibratedPixelTimeSeries = 
            new FloatTimeSeries(new FsId("/a/b/cal"), 
                origPixel, startCadence, endCadence, gaps, originator);
        calibratedPixelMap.put(pixel, calibratedPixelTimeSeries);
       
        final Map<Pixel, BackgroundPixelValue> backgroundMap = Maps.newHashMap();
        BackgroundPixelValue backgroundPixelValue = 
            new BackgroundPixelValue(2, 1, backgroundPixel, gaps, backgroundUmmPixel, gaps);
        backgroundMap.put(pixel, backgroundPixelValue);
        
        final FloatTimeSeries ummTimeSeries = 
            new FloatTimeSeries(new FsId("/umm/a"), ummPixel, startCadence,
                endCadence, gaps, originator);
        final Map<Pixel, TimeSeries> ummPixelMap = Maps.newHashMap();
        ummPixelMap.put(pixel, ummTimeSeries);
        
        mockery.checking(new Expectations() {{
            for (int c=startCadence; c <= endCadence; c++) {
                allowing(mjdToCadence).mjdToCadence((double) (c - startCadence));
                will(returnValue(c));
            }
        }});
        
        calc.modifyCalibratedPixels(calibratedPixelMap, cosmicRayMap, ummPixelMap,
            backgroundMap, fsIdToTimeSeries, fsIdToMjdTimeSeries, mjdToCadence, Float.NaN);
            
        
        assertTrue(Arrays.equals(expected, 
            ((DoubleTimeSeries)fsIdToTimeSeries.get(calibratedPixelTimeSeries.id())).dseries()));
        assertTrue(Arrays.equals(expectedUmm,
            ((DoubleTimeSeries)fsIdToTimeSeries.get(ummTimeSeries.id())).dseries()));
        
        //Don't subtract background multiple times.
        calc.modifyCalibratedPixels(calibratedPixelMap, cosmicRayMap, ummPixelMap, 
            backgroundMap, fsIdToTimeSeries,
            fsIdToMjdTimeSeries, mjdToCadence, Float.NaN);
        
        assertTrue(Arrays.equals(expected, 
            ((DoubleTimeSeries)fsIdToTimeSeries.get(calibratedPixelTimeSeries.id())).dseries()));
        assertTrue(Arrays.equals(expectedUmm,
            ((DoubleTimeSeries)fsIdToTimeSeries.get(ummTimeSeries.id())).dseries()));

    }
}
