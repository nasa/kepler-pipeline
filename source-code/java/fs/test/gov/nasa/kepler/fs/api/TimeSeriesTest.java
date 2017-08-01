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

package gov.nasa.kepler.fs.api;
import gov.nasa.kepler.fs.server.TimeSeriesCarrier;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import org.apache.commons.lang.ArrayUtils;
import org.junit.Before;
import org.junit.Test;

public class TimeSeriesTest {

    private int[] idata;
    private float[] fdata;
    
    @Before
    public void setUp() {
        idata = new int[10];
        for (int i=0; i < idata.length; i++) {
            idata[i] = i + 1;
        }
        
        fdata = new float[10];
        for (int i=0; i < fdata.length; i++) {
            fdata[i] = ((float) Math.PI) * (i + 1);
        }
    }
    
    @Test
    public void simpleOriginatorByCadenceTest() {
        FsId id = new FsId("/kgjkf/ksdjks");
        
        IntTimeSeries its = new IntTimeSeries(id, new int[128], 1, 128, 
            Collections.singletonList(new SimpleInterval(1,128)),
            Collections.singletonList(new TaggedInterval(1,128,2342)));

        assertEquals(-1, its.originatorByCadence(0));
        assertEquals(-1, its.originatorByCadence(129));
        assertEquals(2342L, its.originators().get(its.originatorByCadence(12)).tag());
        
    }
    
    @Test
    public void complexOriginatorByCadenceTest() {
        FsId id = new FsId("/kgjkf/ksdjks");
        
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        valid.add(new SimpleInterval(1,1));
        valid.add(new SimpleInterval(3,128));
        List<TaggedInterval> originators = new ArrayList<TaggedInterval>();
        
        originators.add(new TaggedInterval(1,1, 2342));
        originators.add(new TaggedInterval(3,10, 666));
        originators.add(new TaggedInterval(11,128, 777));
        
        IntTimeSeries its = new IntTimeSeries(id, new int[128], 1, 128, 
            valid, originators);

        assertEquals(-1, its.originatorByCadence(0));

        assertEquals(-1, its.originatorByCadence(2));
      
        
        assertEquals(2342L, its.originators().get(its.originatorByCadence(1)).tag());
        assertEquals(666L,  its.originators().get(its.originatorByCadence(3)).tag());
        assertEquals(777L,  its.originators().get(its.originatorByCadence(77)).tag());
        assertEquals(777L,  its.originators().get(its.originatorByCadence(11)).tag());
        assertEquals(777L,  its.originators().get(its.originatorByCadence(128)).tag());
        
    }
    
    @Test
    public void pipeDelimitedTest() {
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        valid.add(new SimpleInterval(10,12));
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(new TaggedInterval(10,12,3));
        FsId id = new FsId("/gak/series1");
        IntTimeSeries its = 
            new IntTimeSeries(id ,new int[] {1, 2, 3}, 10, 12, valid, origin);
        String pipeString = its.toPipeString();
        IntTimeSeries iunpiped = 
            (IntTimeSeries) TimeSeries.fromPipeString(pipeString);
        
        assertEquals(its, iunpiped);
        
        FloatTimeSeries fts 
            = new FloatTimeSeries(id,  new float[]{1.0f,2.0f,3.0f}, 
                                                  10, 12, valid, origin);
        FloatTimeSeries funpiped = 
            (FloatTimeSeries) TimeSeries.fromPipeString(fts.toPipeString());
        assertEquals(fts, funpiped);
    }
    
    @Test
    public void testFillDoNothing() {
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        SimpleInterval v1 = new SimpleInterval(1, idata.length);
        valid.add(v1);
        TaggedInterval o1 = new TaggedInterval(1, idata.length, 123);
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(o1);
        IntTimeSeries ts = new IntTimeSeries( new FsId("/dr/id0"),  
                                         Arrays.copyOf(idata,idata.length), 
                                         1, 10, valid, origin);
        ts.fillGaps(42);
        assertTrue(Arrays.equals(idata, ts.iseries()));
        
        FloatTimeSeries fts = new FloatTimeSeries(new FsId("/test/id0"),
                                                  Arrays.copyOf(fdata, fdata.length),
                                                  1, 10, valid, origin);
        fts.fillGaps(42f);
        assertTrue(Arrays.equals(fdata, fts.fseries()));
    }
    
    /**
     * Tests that gaps at the start and end are propery filled.
     * 
     */
    @Test
    public void testFillStartEnd() {
        idata[0] = 0;
        idata[9] = 0;
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        SimpleInterval v1 = new SimpleInterval(2,9);
        valid.add(v1);
        TaggedInterval o1 = new TaggedInterval(2, 9, 123);
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(o1);
        IntTimeSeries its = new IntTimeSeries(new FsId("/dr/id0"),
                                         Arrays.copyOf(idata, idata.length), 
                                         1, 10, valid, origin);
        its.fillGaps(42);
        idata[0] = 42;
        idata[9] = 42;
        assertTrue(Arrays.equals(idata,its.iseries()));
        
        fdata[0] = 0f;
        fdata[9] = 0f;
        FloatTimeSeries fts = new FloatTimeSeries(new FsId("/dr/id0"), 
                             Arrays.copyOf(fdata, fdata.length), 
                             1, 10, valid, origin);
        fts.fillGaps(42.0f);
        fdata[0] = 42f;
        fdata[9] = 42f;
        assertTrue(Arrays.equals(fdata, fts.fseries()));
    }
    
    
    /**
     * Tests that gaps in the middle are filled.
     */
    @Test
    public void testFillMiddleGaps() {
        idata[3] = 0;
        idata[6] = 0;
        
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        SimpleInterval v1 = new SimpleInterval(1,3);
        SimpleInterval v2 = new SimpleInterval(5,6);
        SimpleInterval v3 = new SimpleInterval(8,10);
        valid.add(v1);
        valid.add(v2);
        valid.add(v3);
        TaggedInterval o1 = new TaggedInterval(1, 3, 123);
        TaggedInterval o2 = new TaggedInterval(5, 6, 456);
        TaggedInterval o3 = new TaggedInterval(8, 10, 789);
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(o1);
        origin.add(o2);
        origin.add(o3);
        IntTimeSeries its = new IntTimeSeries(new FsId("/dr/id0"),
                                         Arrays.copyOf(idata, idata.length), 
                                         1, 10, valid, origin);
        
        its.fillGaps(42);
        idata[3] = 42;
        idata[6] = 42;
        assertTrue(Arrays.equals(idata, its.iseries()));
        
        
        fdata[3] = 0f;
        fdata[6] = 0f;
        FloatTimeSeries fts = new FloatTimeSeries(new FsId("/dr/id0"),
                                      Arrays.copyOf(fdata, fdata.length),
                                      1, 10, valid, origin);
        fts.fillGaps(42.0f);
        fdata[3] = 42f;
        fdata[6] = 42f;
        assertTrue(Arrays.equals(fdata, fts.fseries()));
    }
    
    /**
     * Test that different (by reference) time series are identical.
     * Test that the super class equals is called by changing one of the
     * time series fields in TimeSeries.
     * Test that data fields are correctly checked.
     *
     */
    @Test
    public void timeSeriesHashCodeAndEquals() {
        List<SimpleInterval> valid = 
            Collections.singletonList(new SimpleInterval(0,9));
        List<TaggedInterval> origin =
            Collections.singletonList(new TaggedInterval(0,9, 23));
        FsId id = new FsId("/fjfjf/jfjfj");
        IntTimeSeries its1 = new IntTimeSeries(id, idata, 0,9, valid, origin);
        IntTimeSeries its2 = 
            new IntTimeSeries(id, Arrays.copyOf(idata, idata.length),
                0, 9, valid, origin);
        
        assertEquals(its1, its2);
        assertEquals(its1.hashCode(), its2.hashCode());
        
        FloatTimeSeries fts1 = new FloatTimeSeries(id, fdata, 0,9, valid, origin);
        FloatTimeSeries fts2 = 
            new FloatTimeSeries(id, Arrays.copyOf(fdata, fdata.length),
                0, 9, valid, origin);
        
        assertEquals(fts1, fts2);
        assertEquals(fts1.hashCode(), fts2.hashCode());
        

        List<TaggedInterval> origin2 = 
            Collections.singletonList(new TaggedInterval(0,9,42));
        its2 = new IntTimeSeries(id, Arrays.copyOf(idata, idata.length),
            0, 9, valid, origin2);
       
       assertFalse("Time series should differ.",  its1.equals(its2));
       assertFalse("Time series hashCode should differ.", 
                           its1.hashCode() == its2.hashCode());
       
       fts2 =  new FloatTimeSeries(id, Arrays.copyOf(fdata, fdata.length),
           0, 9, valid, origin2);
       assertFalse("Time series should differ.",  fts1.equals(fts2));
       assertFalse("Time series hashCode should differ.", 
                           fts1.hashCode() == fts2.hashCode());
       
       
       int[] idata2 =  Arrays.copyOf(idata, idata.length);
       idata2[3]++;
       its2 = new IntTimeSeries(id, idata2, 0, 9, valid, origin);
       
       assertFalse("Time series should differ.",  its1.equals(its2));
       assertFalse("Time series hashCode should differ.", 
                           its1.hashCode() == its2.hashCode());
       
       
       float[] fdata2 =  Arrays.copyOf(fdata, fdata.length);
       fdata2[3]++;
       fts2 = new FloatTimeSeries(id, fdata2, 0, 9, valid, origin);
       
       assertFalse("Time series should differ.",  fts1.equals(fts2));
       assertFalse("Time series hashCode should differ.", 
                           fts1.hashCode() == fts2.hashCode());
       
       
    }
    
    /**
     * Tests that transferFrom/To methods.
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
    @Test
    public void transfer() throws Exception {
        FsId id = new FsId("/blah/stuff");
        int[] idata = new int[1024*1024*2];
        Arrays.fill(idata, 7832338);
        TimeSeries its = new IntTimeSeries(id, idata, 1, idata.length, 
            Collections.singletonList(new SimpleInterval(1, idata.length)),
            Collections.singletonList(new TaggedInterval(1, idata.length, 665)));
        
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        its.transferTo(dout);
        
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream(bin);
        
        IntTimeSeries readIts = (IntTimeSeries) TimeSeries.transferFrom(din);
        assertEquals(its, readIts);
        
        IntTimeSeries emptyInt = new IntTimeSeries(id, new int[0], -1,-1,
            Collections.EMPTY_LIST, Collections.EMPTY_LIST, false);
        
        bout = new ByteArrayOutputStream();
        dout = new DataOutputStream(bout);
        emptyInt.transferTo(dout);
        
        bin = new ByteArrayInputStream(bout.toByteArray());
        din = new DataInputStream(bin);
        readIts =  (IntTimeSeries) TimeSeries.transferFrom(din);
        assertEquals(emptyInt, readIts);
        assertEquals(0, bin.available());
        
        
        float[] fdata = new float[999];
        Arrays.fill(fdata, (float)Math.PI);
        
        FloatTimeSeries fts = new FloatTimeSeries(id, fdata, 1, fdata.length, 
                Collections.singletonList(new SimpleInterval(1, fdata.length)), 
                Collections.singletonList(new TaggedInterval(1, fdata.length, 123123)));
        
        bout = new ByteArrayOutputStream();
        dout = new DataOutputStream(bout);
        fts.transferTo(dout);
        
        bin = new ByteArrayInputStream(bout.toByteArray());
        din = new DataInputStream(bin);
        FloatTimeSeries readFts =  (FloatTimeSeries) TimeSeries.transferFrom(din);
        assertEquals(fts, readFts);
        
        
        FloatTimeSeries emptyFts = 
            new FloatTimeSeries(id, new float[0], -1, -1, Collections.EMPTY_LIST,
                Collections.EMPTY_LIST, false);
        bout = new ByteArrayOutputStream();
        dout = new DataOutputStream(bout);
        emptyFts.transferTo(dout);
        
        bin = new ByteArrayInputStream(bout.toByteArray());
        din = new DataInputStream(bin);
        readFts =  (FloatTimeSeries) TimeSeries.transferFrom(din);
        assertEquals(emptyFts, readFts);
    }
    
    @Test
    public void testConvertToIndicesAllGapped() throws Exception {
        FsId id = new FsId("/nothing/no/really/nothing");
        boolean[] gaps = new boolean[fdata.length];
        Arrays.fill(gaps, true);
        FloatTimeSeries fts = 
            new FloatTimeSeries(id, fdata, 0,fdata.length - 1, gaps, 7L);
        int[] gapIndices = fts.getGapIndices();
        assertEquals(fdata.length, gapIndices.length);
        
        int[] expectedGapIndices = new int[gaps.length];
        for (int i=0; i < fdata.length; i++) {
            expectedGapIndices[i] = i;
        }
        assertTrue("Arrays must be equal.", Arrays.equals(expectedGapIndices, fts.getGapIndices()));
     }

    @Test
    public void timeSeriesCarrierTest() throws Exception {
        Random rand = new Random(787878);
        float[] fdata = new float[331];
        for (int i = 0; i < fdata.length; i++) {
            fdata[i] = rand.nextFloat();
        }

        FsId id = new FsId("/carry/me");
        FloatTimeSeries fts = new FloatTimeSeries(id, fdata, 1, fdata.length,
            Collections.singletonList(new SimpleInterval(1, fdata.length)),
            Collections.singletonList(new TaggedInterval(1, fdata.length,
                123123)));
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        fts.transferTo(dout);
        
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream(bin);
        TimeSeriesCarrier carrier = TimeSeriesCarrier.transferFrom(din);
        
        bout.reset();
        
        carrier.transferTo(dout);
        
        bin = new ByteArrayInputStream(bout.toByteArray());
        din = new DataInputStream(bin);
        FloatTimeSeries roundTripFts = (FloatTimeSeries) TimeSeries.transferFrom(din);
        assertEquals(fts, roundTripFts);
        
    }
    
    @Test
    public void nonExistantTimeSeriesTest() throws Exception {
        FsId id = new FsId("/not/exist");
        IntTimeSeries nExist = 
            new IntTimeSeries(id, ArrayUtils.EMPTY_INT_ARRAY,
                TimeSeries.NOT_EXIST_CADENCE, TimeSeries.NOT_EXIST_CADENCE,
                Collections.EMPTY_LIST, Collections.EMPTY_LIST, false);
        TimeSeriesCarrier carrier = 
            TimeSeriesTestUtil.toTimeSeriesCarrier(nExist);
        IntTimeSeries roundTripSeries = 
            (IntTimeSeries) TimeSeriesTestUtil.fromTimeSeriesCarrier(carrier);
        assertEquals(nExist, roundTripSeries);
    }
  
}
