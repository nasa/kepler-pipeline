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

package gov.nasa.kepler.ar.exporter.cal;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMock.class)
public class CalibratedPixelExtractorTest {

	private Mockery mockery;
	
	@Before
	public void setUp() {
		mockery = new JUnit4Mockery() {
			{
				setImposteriser(ClassImposteriser.INSTANCE);
			}
		};
	}
	    
    @Test
    public void testEmptyExtraction() throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        Map<Double, Integer> timeMap = new HashMap<Double, Integer>();
        timeMap.put(100.0, 0);

        MjdToCadence mjdToCadence = new TestMjdToCadence(timeMap,
            CadenceType.LONG);

        final int module = 2;
        final int output = 3;
        
        CalibratedPixelExtractor extractor = new CalibratedPixelExtractor(
            fsClient, mjdToCadence, 0, 0, module, output);

        final PixelTypeInterface pDataType = mockery.mock(PixelTypeInterface.class);
        
        final OutputFileInfo info = mockery.mock(OutputFileInfo.class,"info1");
        mockery.checking(new Expectations() {
        	{
        		atLeast(1).of(info).pmrfName();
        		will(returnValue("pmrfName"));
        	}
        });
        
        mockery.checking(new Expectations() {
            {
            	one(pDataType).pixelIds(info, module, output, FsIdFactoryType.CALIBRATED);
            	will(returnValue(Collections.EMPTY_LIST));
            	
            	one(pDataType).pixelIds(info, module, output, FsIdFactoryType.CALIBRATED_UNCERT);
            	will(returnValue(Collections.EMPTY_LIST));
            	
            	one(pDataType).pixelIds(info, module, output, FsIdFactoryType.COSMIC_RAY);
            	will(returnValue(Collections.EMPTY_LIST));
            }
        });
        
        extractor.addPixels(info, pDataType);

        extractor.loadPixelsAndRays();

        assertEquals(0, extractor.calibratedPixels().size());
        
        mockery.assertIsSatisfied();
    }

    @Test
    public void testCalibratedPixelExtractor() throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();

        final int ccdModule = 2;
        final int ccdOutput = 3;
        
        Map<Double, Integer> timeMap = new HashMap<Double, Integer>();
        timeMap.put(100.0, 0);
        timeMap.put(101.0, 1);
        timeMap.put(102.0, 2);

        CadenceType cType = CadenceType.LONG;
        MjdToCadence mjdToCadence = new TestMjdToCadence(timeMap,cType);

        final FsId calVisibleId = CalFsIdFactory.getTimeSeriesFsId(PixelTimeSeriesType.SOC_CAL,
            TargetType.LONG_CADENCE, ccdModule,ccdOutput, 770, 771);
        final FsId uncertVisibleId = CalFsIdFactory.getTimeSeriesFsId(PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
            TargetType.LONG_CADENCE, ccdModule, ccdOutput, 770, 771) ;

        CollateralType collateralType = CollateralType.VIRTUAL_SMEAR;
        final FsId calCollateralId = CalFsIdFactory.getCalibratedCollateralFsId(collateralType,
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, CadenceType.LONG, ccdModule, ccdOutput, 1044);
        
        final FsId uncertCollateralId = CalFsIdFactory.getCalibratedCollateralFsId(collateralType, 
            PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, cType, 
            ccdModule, ccdOutput, 1044);
        
        
        float[] collateralValues = new float[3];
        Arrays.fill(collateralValues, 100.0f);
        float[] uncertCollateralValues = new float[collateralValues.length];
        Arrays.fill(uncertCollateralValues, 101.0f);
        float[] pixelValues = new float[3];
        Arrays.fill(pixelValues, 66.0f);
        float[] uncertPixelValues = new float[3];
        Arrays.fill(uncertPixelValues, 3.0f);

        boolean[] gaps = new boolean[3];
        FloatTimeSeries collateralPixels = new FloatTimeSeries(calCollateralId,
            collateralValues, 0, 2, gaps, 98);
        FloatTimeSeries uncertCollateralPixels = new FloatTimeSeries(uncertCollateralId,
            uncertCollateralValues, 0,2, gaps, 98);
    
        
        FloatTimeSeries calibratedPixels = new FloatTimeSeries(calVisibleId,
            pixelValues, 0, 2, gaps, 99);
        FloatTimeSeries uncertPixels = new FloatTimeSeries(uncertVisibleId,
            uncertPixelValues, 0, 2, gaps, 99);

        final FsId rayId = PaFsIdFactory.getCosmicRaySeriesFsId(
            TargetType.LONG_CADENCE,ccdModule, ccdOutput, 770, 771);
        final FsId collateralRayId = CalFsIdFactory.getCosmicRaySeriesFsId(
            CollateralType.VIRTUAL_SMEAR, CadenceType.LONG, 
            ccdModule, ccdOutput, 1044);

        FloatMjdTimeSeries rays = new FloatMjdTimeSeries(rayId, 100.0, 102.0,
            new double[] { 101.0 }, new float[] { 4.0f }, 999);
        FloatMjdTimeSeries collateralRays = new FloatMjdTimeSeries(
            collateralRayId, 100.0, 102.0, new double[] { 101.0 },
            new float[] { 6.0f }, 899);

        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { rays,
            collateralRays });
        fsClient.writeTimeSeries(new TimeSeries[] { calibratedPixels, uncertPixels,
            collateralPixels, uncertCollateralPixels });
        fsClient.commitLocalFsTransaction();

        CalibratedPixelExtractor extractor = new CalibratedPixelExtractor(
            fsClient, mjdToCadence, 0, 2, ccdModule, ccdOutput);

        final OutputFileInfo info1 = mockery.mock(OutputFileInfo.class,"info1");
        mockery.checking(new Expectations() {
        	{
        		atLeast(1).of(info1).pmrfName();
        		will(returnValue("info1"));
        	}
        });
        
        final PixelTypeInterface longCadenceTargetType =
        	mockery.mock(PixelTypeInterface.class, "visible");
        
        mockery.checking(new Expectations() {
        	{
        		one(longCadenceTargetType).pixelIds(info1, ccdModule, ccdOutput,
        				FsIdFactoryType.CALIBRATED);
        		will(returnValue(Collections.singletonList(calVisibleId)));
        		
        		one(longCadenceTargetType).pixelIds(info1, ccdModule, ccdOutput, 
        				FsIdFactoryType.CALIBRATED_UNCERT);
        		will(returnValue(Collections.singletonList(uncertVisibleId)));
        		
        		one(longCadenceTargetType).pixelIds(info1, ccdModule, ccdOutput,
        				FsIdFactoryType.COSMIC_RAY);
        		will(returnValue(Collections.singletonList(rayId)));
        	}
        });
        
        final PixelTypeInterface collateralPixelType =
        	mockery.mock(PixelTypeInterface.class, "collateral");
        
        final OutputFileInfo info2 = mockery.mock(OutputFileInfo.class,"info2");
        mockery.checking(new Expectations() {
        	{
        		atLeast(1).of(info2).pmrfName();
        		will(returnValue("info2"));
        	}
        });
        
        mockery.checking(new Expectations() {
        	{
        		one(collateralPixelType).pixelIds(info2, ccdModule, ccdOutput, FsIdFactoryType.CALIBRATED);
        		will(returnValue(Collections.singletonList(calCollateralId)));
        		
        		one(collateralPixelType).pixelIds(info2, ccdModule, ccdOutput, FsIdFactoryType.CALIBRATED_UNCERT);
        		will(returnValue(Collections.singletonList(uncertCollateralId)));
        		
        		one(collateralPixelType).pixelIds(info2, ccdModule, ccdOutput, FsIdFactoryType.COSMIC_RAY);
        		will(returnValue(Collections.singletonList(collateralRayId)));
        	}
        });
        
        extractor.addPixels(info1, longCadenceTargetType);
       
        extractor.addPixels(info2, collateralPixelType);

        extractor.loadPixelsAndRays();

        Map<FsId, FloatTimeSeries> extractedPixels = extractor.calibratedPixels();
        assertEquals(4, extractedPixels.size());

        FloatTimeSeries extractedSeries = extractedPixels.get(calVisibleId);
        pixelValues[1] -= 4.0;
        assertTrue(Arrays.equals(pixelValues, extractedSeries.fseries()));

        extractedSeries = extractedPixels.get(calCollateralId);
        //collateralValues[1] -= 6.0f;
        assertTrue(Arrays.equals(collateralValues, extractedSeries.fseries()));

        extractedSeries = extractedPixels.get(uncertCollateralId);
        assertTrue(Arrays.equals(uncertCollateralValues, extractedSeries.fseries()));
        
        extractedSeries = extractedPixels.get(uncertVisibleId);
        assertTrue(Arrays.equals(uncertPixelValues, extractedSeries.fseries()));
        
        Map<FsId, FloatMjdTimeSeries> extractedCosmicRays = extractor.cosmicRays();
        assertEquals(2, extractedCosmicRays.size());

        FloatMjdTimeSeries extractedRaySeries = extractedCosmicRays.get(rayId);
        assertTrue(Arrays.equals(new float[] { 4.0f },
            extractedRaySeries.values()));

        extractedRaySeries = extractedCosmicRays.get(collateralRayId);
        assertTrue(Arrays.equals(new float[] { 6.0f },
            extractedRaySeries.values()));
        
        Map<Double, Set<FloatMjdTimeSeries>> crByMjd = extractor.cosmicRaysByMjd();
        assertEquals(1, crByMjd.size());
        assertEquals(101.0, crByMjd.entrySet().iterator().next().getKey(), 0.0);
        assertEquals(2, crByMjd.entrySet().iterator().next().getValue().size());
        

    }

    private static class TestMjdToCadence extends MjdToCadence {

        private final Map<Double, Integer> testMjdToCadence;
        private final Map<Integer, Double> testCadenceToMjd = new HashMap<Integer, Double>();

        public TestMjdToCadence(Map<Double, Integer> mjdToCadenceMap,
            CadenceType cadenceType) {
            super(cadenceType, null);

            testMjdToCadence = mjdToCadenceMap;
            for (Map.Entry<Double, Integer> entry : mjdToCadenceMap.entrySet()) {
                testCadenceToMjd.put(entry.getValue(), entry.getKey());
            }
        }

        @Override
        public double cadenceToMjd(int cadence) {
            Double mjd = testCadenceToMjd.get(cadence);
            if (mjd == null) {
                throw new PipelineException("Missing cadence " + cadence);
            }
            return mjd;
        }

        @Override
        public int mjdToCadence(double mjd) {
            Integer cadence = testMjdToCadence.get(mjd);
            if (cadence == null) {
                throw new PipelineException("Missing mjd " + mjd);
            }

            return cadence;
        }

    }

}
