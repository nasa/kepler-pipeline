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

package gov.nasa.kepler.fs.client;

import static gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.*;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TimeSeriesCorrectnessTest {
    
    protected static Configuration config = null;
    private FileStoreClient fsClient;
    private static final int[] tsIntData = new int[128];
    private static final float[] tsFloatData = new float[128];
    private static final double[] tsDoubleData = new double[128];
    private static final float[] bigSeries = new float[1024];
    private static final long[] smallIntervals = new long[3];
    private static final long[] bigIntervals = new long[3];
    private static final FsId id1 = new FsId("/test/id1");
    private static final FsId id2 = new FsId("/test/id2");
    
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        
        System.setProperty(CONFIG_SERVICE_PROPERTIES_PATH_PROP,
                                        "etc/kepler.properties");
        
        try {
            config = ConfigurationServiceFactory.getInstance();
        } catch (PipelineException e) {
            e.printStackTrace();
        }
        
  
    }
   
    protected FileStoreClient constructTimeSeriesClient()
        throws Exception {
        FileStoreClientFactory.setInstance(null);
        return FileStoreClientFactory.getInstance(config);      
    }
    
    /**
     * @return When true the transactions tests should be run.
     */
    protected boolean runTransactionTests() {
        return true;
    }
    
    @Before
    public void setUp() throws Exception {
        fsClient = constructTimeSeriesClient();
        
        for (int i=0; i < tsIntData.length; i++) {
            tsIntData[i] = i + 10;
        }
        for (int i=0; i < tsFloatData.length; i++ ) {
            tsFloatData[i] = (float) Math.PI * (i + 1);
        }
        

        for (int i=0; i < bigSeries.length; i++) {
            bigSeries[i] = (float) Math.E * (i + 1);
        }
        
        for (int i=0; i < tsDoubleData.length; i++) {
            tsDoubleData[i] = Math.log10(Math.E * (i+1));
        }
        
        smallIntervals[0] =0;
        smallIntervals[1] = tsIntData.length - 1;
        smallIntervals[2] = 23;
        bigIntervals[0] = 0;
        bigIntervals[1] = bigSeries.length - 1;
        bigIntervals[2] = 23;
        
        
        
    }

    @After
    public void tearDown() throws Exception {
        ((FileStoreTestInterface)fsClient).cleanFileStore();
    }

    private List<TaggedInterval> originList(long[] a, long offset) {
        List<TaggedInterval> rv = new ArrayList<TaggedInterval>();
        if (a.length % 3 != 0) {
            throw new IllegalArgumentException("Invalid size.");
        }
        for (int i=0; i < a.length; i += 3) {
            rv.add(new TaggedInterval(a[i] + offset,a[i+1] + offset, a[i+2]));
        }
        return rv;
    }
    
    private List<SimpleInterval> validList(long[] a, long offset) {
        List<SimpleInterval> rv = new ArrayList<SimpleInterval>();
        if (a.length % 3 != 0) {
            throw new IllegalArgumentException("Invalid size.");
        }
        for (int i=0; i < a.length; i += 3) {
            rv.add(new SimpleInterval(a[i] + offset, a[i+1] + offset));
        }
        return rv;
    }
    

    @Test
    public void emptyParameters() {
        FloatTimeSeries[] fts = fsClient.readTimeSeriesAsFloat(new FsId[0], 0, 1000);
        assertEquals(0, fts.length);
    }
    
    @Test
    public void readNonExistant() {
        FloatTimeSeries[] ts = null;

        ts = fsClient.readTimeSeriesAsFloat(new FsId[]{id1},0, 1, false);
                                       
        assertEmptyTimeSeries(ts);
        assertEquals(2, ts[0].fseries().length);

        
        ts = fsClient.readAllTimeSeriesAsFloat(new FsId[]{id1}, false);
        
        assertEmptyTimeSeries(ts);
        assertEquals(0, ts[0].fseries().length);
        
        try {
            ts = fsClient.readTimeSeriesAsFloat(new FsId[] {id1}, 0, 1);
            assertTrue("Should have thrown exception.", false);
        } catch (FileStoreIdNotFoundException fsidnfe) {
            //ok
        }
        
        try {
            ts = fsClient.readAllTimeSeriesAsFloat(new FsId[] { id1});
            assertTrue("Should have thrown exception.", false);
        } catch (FileStoreIdNotFoundException fsidnf) {
            //ok
        }
        
        IntTimeSeries[] its = null;

        its = fsClient.readTimeSeriesAsInt(new FsId[]{id1},0, 1, false);
        assertEmptyTimeSeries(its);
        assertEquals(2, its[0].iseries().length);
        
        its = fsClient.readAllTimeSeriesAsInt(new FsId[]{id1}, false);
        assertEmptyTimeSeries(its);
        assertEquals(0, its[0].iseries().length);
        
        try {
            its = fsClient.readTimeSeriesAsInt(new FsId[] {id1}, 0, 1);
            assertTrue("Should have thrown exception.", false);
        } catch (FileStoreIdNotFoundException fsidnfe) {
            //ok
        }
        
        try {
            its = fsClient.readAllTimeSeriesAsInt(new FsId[] { id1});
            assertTrue("Should have thrown exception.", false);
        } catch (FileStoreIdNotFoundException fsidnf) {
            //ok
        }
    }
    
    private void assertEmptyTimeSeries(TimeSeries[] empty) {
        assertEquals(1, empty.length);
        assertEquals(id1, empty[0].id());
        assertFalse("exists() should return false", empty[0].exists());
       // assertEquals(0, empty[0].fseries().length);
        assertEquals(0, empty[0].originators().size());
        assertEquals(0, empty[0].validCadences().size());
    }
    
    
    @Test
    public void simpleTimeSeriesBatchTest() throws Exception {
        TimeSeries ts = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        FsIdSet fsIdSet = new FsIdSet(0, tsIntData.length - 1, Collections.singleton(id1));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts });
        fsClient.commitLocalFsTransaction();
        
        List<TimeSeriesBatch> batches = 
            fsClient.readTimeSeriesBatch(Collections.singletonList(fsIdSet), true);
        assertEquals(1, batches.size());
        TimeSeriesBatch batch = batches.get(0);
        assertEquals(0, batch.startCadence());
        assertEquals(tsIntData.length - 1, batch.endCadence());
        assertEquals(1, batch.timeSeries().size());
        IntTimeSeries its = (IntTimeSeries) batch.timeSeries().get(id1);
        assertEquals(ts, its);
        
    }
    
    /**
     * Read a float and int and a non-existent series.
     * 
     * @throws Exception
     */
    @Test
    public void readMixedTimeSeriesBatchTest() throws Exception {
        TimeSeries its = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        TimeSeries fts =
            new FloatTimeSeries(id2, tsFloatData,
                0, tsFloatData.length - 1, validList(smallIntervals,0),
                originList(smallIntervals,0));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its, fts} );
        fsClient.commitLocalFsTransaction();
        
        FsId notExistId = new FsId("/this/does/not/exist");
        Set<FsId> idSet = new HashSet<FsId>();
        idSet.add(id1);
        idSet.add(id2);
        idSet.add(notExistId);
        
        FsIdSet fsIdSet = new FsIdSet(0, tsFloatData.length-1, idSet);
        List<TimeSeriesBatch> batchList =
            fsClient.readTimeSeriesBatch(Collections.singletonList(fsIdSet), false);
        assertEquals(1, batchList.size());
        TimeSeriesBatch batch = batchList.get(0);
        assertEquals(3, batch.timeSeries().size());
        TimeSeries id1Series = batch.timeSeries().get(id1);
        assertEquals(its, id1Series);
        TimeSeries id2Series = batch.timeSeries().get(id2);
        assertEquals(fts, id2Series);
        TimeSeries notExistSeries = batch.timeSeries().get(notExistId);
        assertEquals(false, notExistSeries.exists());
        assertTrue(notExistSeries instanceof FloatTimeSeries);
    }
    
    @Test
    public void readMultiBatchTest() throws Exception {
        final int nSets = 4;
        final int idsPerSet = 16;
        final int nData = 1024;
        TimeSeries[] writeSeries = new TimeSeries[nSets * idsPerSet];
        
        List<FsIdSet> fsIdSetList = new ArrayList<FsIdSet>();
        for (int i=0; i < nSets; i++) {
            final int startCadence = i;
            final int endCadence = i + nData -1;
            Set<FsId> ids = new HashSet<FsId>();
            for (int j=0; j < idsPerSet; j++) {
                int[] data = new int[nData];
                final int fillValue = i * idsPerSet + j + 1;
                Arrays.fill(data, fillValue);
                FsId id = new FsId("/set/" + i + "/series/" + j);
                IntTimeSeries its = 
                    new IntTimeSeries(id, data, startCadence, 
                        endCadence, new boolean[data.length], fillValue);
                writeSeries[i * idsPerSet + j] = its;
                ids.add(id);
            }
            FsIdSet fsIdSet = new FsIdSet(startCadence, endCadence, ids);
            fsIdSetList.add(fsIdSet);
        }
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(writeSeries);
        fsClient.commitLocalFsTransaction();
        
        //Check the explicit transactions on read works as well.
        fsClient.beginLocalFsTransaction();
        List<TimeSeriesBatch> batchList = 
            fsClient.readTimeSeriesBatch(fsIdSetList, true);
        fsClient.rollbackLocalFsTransaction();
       
        assertEquals(nSets, batchList.size());
        int resultIndex = 0;
        for (FsIdSet idSet : fsIdSetList) {
            TimeSeriesBatch batch = batchList.get(resultIndex);
            assertEquals(idSet.ids().size(), batch.timeSeries().size());
            assertEquals(idSet.startCadence(), batch.startCadence());
            assertEquals(idSet.endCadence(), batch.endCadence());
            for (int j=0; j < idsPerSet; j++) {
                int index = resultIndex * idsPerSet + j;
                assertEquals(writeSeries[index], batch.timeSeries().get(writeSeries[index].id()));
            }
            resultIndex++;
        }
    }
    
    @Test
    public void testReadTimeSeriesAsInt()  {
        TimeSeries ts = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts});
        fsClient.writeTimeSeries(new TimeSeries[]{ts});
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries[] tsa =  
            fsClient.readTimeSeriesAsInt(new FsId[] {id1},  0, tsIntData.length -1 );
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        TaggedInterval origin = tsa[0].originators().get(0);
        assertTrue("exists() should return true", tsa[0].exists());
        assertEquals(0L, origin.start());
        assertEquals((long)(tsIntData.length - 1), origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        SimpleInterval valid = tsa[0].validCadences().get(0);
        assertEquals(0, (int) valid.start());
        assertEquals(tsIntData.length -1 , (int) valid.end());
        assertTrue("Data must be equal.", Arrays.equals(tsIntData, tsa[0].iseries()));
        tsa =  
            fsClient.readTimeSeriesAsInt(new FsId[] {id1},  10, 10);
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        origin = tsa[0].originators().get(0);     
        assertEquals(10, (int) origin.start());
        assertEquals(10, (int)origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        valid = tsa[0].validCadences().get(0);
        assertEquals(10, (int) valid.start());
        assertEquals(10 , (int) valid.end());
        assertEquals(tsIntData[10], tsa[0].iseries()[0]);

    }

    @Test
    public void testReadTimeSeriesAsFloat()  {
        FloatTimeSeries ts = 
            new FloatTimeSeries(id1, tsFloatData,
                           0, tsFloatData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts});
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] tsa =  
            fsClient.readTimeSeriesAsFloat(new FsId[] {id1},  0, tsFloatData.length -1 );
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        assertTrue("exists() should return true", tsa[0].exists());
        TaggedInterval origin = tsa[0].originators().get(0);
        assertEquals(0L, origin.start());
        assertEquals((long)(tsFloatData.length - 1), origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        SimpleInterval valid = tsa[0].validCadences().get(0);
        assertEquals(0, (int) valid.start());
        assertEquals(tsFloatData.length -1 , (int) valid.end());
        assertTrue("Data must be equal.", 
            Arrays.equals(tsFloatData, tsa[0].fseries()));
        tsa =  
            fsClient.readTimeSeriesAsFloat(new FsId[] {id1},  10, 10);
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        origin = tsa[0].originators().get(0);     
        assertEquals(10, (int) origin.start());
        assertEquals(10, (int)origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        valid = tsa[0].validCadences().get(0);
        assertEquals(10, (int) valid.start());
        assertEquals(10 , (int) valid.end());
        assertEquals(tsFloatData[10], tsa[0].fseries()[0], 0);

    }
    
    @Test
    public void testReadTimeSeriesAsFloatMulti()  {
        TimeSeries ts1 = 
            new FloatTimeSeries(id1, tsFloatData, 
                           0, tsFloatData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        TimeSeries ts2 = 
            new FloatTimeSeries(id2, tsFloatData,
                            0, tsFloatData.length - 1, validList(smallIntervals,0),
                            originList(smallIntervals,0));
        
        FsId[] ids = new FsId[] {id1, id2};
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts1, ts2});
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] tsa =  
            fsClient.readTimeSeriesAsFloat(ids,  0, tsFloatData.length -1 );
        assertEquals(2, tsa.length);
        for (int i=0; i < 2; i++) {
            assertEquals(ids[i], tsa[i].id());
            assertTrue("exists() should return true", tsa[i].exists());
            assertEquals(1, tsa[i].originators().size());
            TaggedInterval origin = tsa[i].originators().get(0);
            assertEquals(0L, origin.start());
            assertEquals((long)(tsFloatData.length - 1), origin.end());
            assertEquals(smallIntervals[2], origin.tag());
            assertEquals(1,tsa[i].validCadences().size());
            SimpleInterval valid = tsa[i].validCadences().get(0);
            assertEquals(0, (int) valid.start());
            assertEquals(tsFloatData.length -1 , (int) valid.end());
            assertTrue("Data must be equal.",
                Arrays.equals(tsFloatData, tsa[i].fseries()));
        }
        tsa =  
            fsClient.readTimeSeriesAsFloat(ids,  10, 10);
        assertEquals(2, tsa.length);
        for (int i=0; i <2; i++) {
            assertEquals(ids[i], tsa[i].id());          
            assertEquals(1, tsa[i].originators().size());
            TaggedInterval origin = tsa[i].originators().get(0);   
            assertTrue("exists() should return true", tsa[i].exists());
            assertEquals(10, (int) origin.start());
            assertEquals(10, (int)origin.end());
            assertEquals(smallIntervals[2], origin.tag());
            assertEquals(1,tsa[i].validCadences().size());
            SimpleInterval valid = tsa[i].validCadences().get(0);
            assertEquals(10, (int) valid.start());
            assertEquals(10 , (int) valid.end());
            assertEquals(tsFloatData[10], tsa[i].fseries()[0], 0);
        }

    }
    
    @Test
    public void testReadTimeSeriesAsIntMulti()  {
        TimeSeries ts1 = 
            new IntTimeSeries(id1,tsIntData, 
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        TimeSeries ts2 = 
            new IntTimeSeries(id2,  tsIntData, 
                            0, tsIntData.length - 1, validList(smallIntervals,0),
                            originList(smallIntervals,0));
        
        FsId[] ids = new FsId[] { id1, id2 };
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts1, ts2});
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries[] tsa =  
            fsClient.readTimeSeriesAsInt(ids, 0, tsIntData.length -1 );
        assertEquals(2, tsa.length);
        for (int i=0; i < 2; i++) {
            assertEquals(ids[i], tsa[i].id());
            assertTrue("exists() should return true", tsa[i].exists());
            assertEquals(1, tsa[i].originators().size());
            TaggedInterval origin = tsa[i].originators().get(0);
            assertEquals(0L, origin.start());
            assertEquals((long)(tsIntData.length - 1), origin.end());
            assertEquals(smallIntervals[2], origin.tag());
            assertEquals(1,tsa[i].validCadences().size());
            SimpleInterval valid = tsa[i].validCadences().get(0);
            assertEquals(0, (int) valid.start());
            assertEquals(tsIntData.length -1 , (int) valid.end());
            assertTrue("Data must be equal.", Arrays.equals(tsIntData, tsa[i].iseries()));
        }
        tsa =  
            fsClient.readTimeSeriesAsInt(ids , 10, 10);
        assertEquals(2, tsa.length);
        for (int i=0; i <2; i++) {
            assertEquals(ids[i], tsa[i].id());
            assertTrue("exists() should return true", tsa[i].exists());
            assertEquals(1, tsa[i].originators().size());
            TaggedInterval origin = tsa[i].originators().get(0);     
            assertEquals(10, (int) origin.start());
            assertEquals(10, (int)origin.end());
            assertEquals(smallIntervals[2], origin.tag());
            assertEquals(1,tsa[i].validCadences().size());
            SimpleInterval valid = tsa[i].validCadences().get(0);
            assertEquals(10, (int) valid.start());
            assertEquals(10 , (int) valid.end());
            assertEquals(tsIntData[10], tsa[i].iseries()[0]);
        }

    }
    
    @Test
    public void testGetIdsForSeries() {
        TimeSeries ts1 = 
            new IntTimeSeries(id1, tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        TimeSeries ts2 = 
            new IntTimeSeries(id2, tsIntData, 
                            tsIntData.length, (2*tsIntData.length) - 1, 
                            validList(smallIntervals,tsIntData.length),
                            originList(smallIntervals,tsIntData.length));
        TimeSeries ts3 =
            new IntTimeSeries(id1,  tsIntData,
                0, tsIntData.length - 1, validList(smallIntervals,0),
                originList(smallIntervals,0));
        
        TimeSeries[] tsa = new TimeSeries[]{ts1, ts2, ts3};
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(tsa);
        fsClient.commitLocalFsTransaction();
        
        Set<FsId> readIds = fsClient.getIdsForSeries(id1);
        assertEquals(2, readIds.size());
        for (TimeSeries ts : tsa) {
            assertTrue(ts.id() +" not listed in available ids for time series", 
                readIds.contains(ts.id()));
        }
      
        Set<FsId> empty = fsClient.getIdsForSeries(new FsId("/empty/_"));
        assertTrue(" should be empty", empty.isEmpty());
    }
    
    @Test
    public void testgetIntervalsForId() {

        TimeSeries ts1 = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        TimeSeries ts2 = 
            new IntTimeSeries(id2,  tsIntData,
                            0, tsIntData.length - 1, validList(smallIntervals,0),
                            originList(smallIntervals,0));
        TimeSeries ts3 =
            new IntTimeSeries(id2,  tsIntData,
                2*tsIntData.length, (3*tsIntData.length) - 1, 
                validList(smallIntervals,2*tsIntData.length),
                originList(smallIntervals,2*tsIntData.length));
        
        TimeSeries[] tsa = new TimeSeries[]{ts1, ts2, ts3};
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(tsa);
        fsClient.commitLocalFsTransaction();
        
        List<Interval>[] ranges = 
                fsClient.getCadenceIntervalsForId(new FsId[]{ id1, id2, new FsId(id1.path(), "nothing")});
        
       assertEquals(3, ranges.length);
       assertEquals(1, ranges[0].size());
       assertEquals(2, ranges[1].size());
       assertEquals(0, ranges[2].size());
       assertEquals(0L, ranges[0].get(0).start());
       assertEquals((long)(tsFloatData.length - 1), ranges[0].get(0).end());
       assertEquals(0L, ranges[1].get(0).start());
       assertEquals((long)(tsFloatData.length - 1), ranges[1].get(0).end());
       assertEquals((long)(tsFloatData.length * 2), ranges[1].get(1).start());
       assertEquals((long) (tsFloatData.length *3) - 1, ranges[1].get(1).end());
       
       List<Interval>[] emptyRange =
           fsClient.getCadenceIntervalsForId(new FsId[] { new FsId("/nowforsomethingcompletelydifferent/blah")});
       assertEquals(1, emptyRange.length);
       assertEquals(0, emptyRange[0].size());
    }
    
    /**
     * <pre>
     *         n
     *         |
     *         V
     *    000000000000000dddddddddddddddddddddddddddddd
     *    
     * </pre>
     */
    @Test
    public void testRangeNotStartAtZer0() {
        TimeSeries ts1 = 
            new FloatTimeSeries(id1, tsFloatData,
                           100, 100+tsFloatData.length - 1, validList(smallIntervals,100),
                           originList(smallIntervals,100));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts1});
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] noData = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1}, 0, 99);
        assertEquals(1, noData.length);
        assertEquals(100, noData[0].fseries().length);
        assertEquals(0, noData[0].validCadences().size());
        assertEquals(0, noData[0].originators().size());
        
        //Read one float before the time series data actually starts.
        FloatTimeSeries[] actualData = 
            fsClient.readTimeSeriesAsFloat(new FsId[] {id1},
                99, tsFloatData.length + 99);
        assertEquals(tsFloatData.length + 1, actualData[0].fseries().length);
        assertTrue("data must be equal " + Arrays.toString(tsFloatData) + "\n" 
            + Arrays.toString(actualData[0].fseries()),
                   arrayEquals(tsFloatData, actualData[0].fseries(), 1));
        assertEquals(1,actualData[0].validCadences().size());
        assertEquals(100L,actualData[0].validCadences().get(0).start());
        assertEquals(tsFloatData.length + 99, 
                     (int) actualData[0].validCadences().get(0).end());
        assertEquals(99, actualData[0].startCadence());
        assertEquals(tsFloatData.length + 99, actualData[0].endCadence());
        
        TimeSeries eSeries = 
            new FloatTimeSeries(id1,  new float[] {(float)Math.E},
                10,10,
                Collections.singletonList(new SimpleInterval(10,10)),
                Collections.singletonList(new TaggedInterval(10,10, 42)));

       fsClient.beginLocalFsTransaction();
       fsClient.writeTimeSeries(new TimeSeries[] {eSeries});
       fsClient.commitLocalFsTransaction();
       
       FloatTimeSeries[] newSeries = 
           fsClient.readTimeSeriesAsFloat(new FsId[] {id1}, 10, 10);
        assertEquals(1, newSeries.length);
        assertEquals((float)Math.E, newSeries[0].fseries()[0], 0);
        assertEquals(42L, newSeries[0].originators().get(0).tag());

        
        newSeries = fsClient.readTimeSeriesAsFloat(new FsId[]{id1},
             10, tsFloatData.length + 99);
        assertEquals(tsFloatData.length + (100 - 10 ), newSeries[0].fseries().length);
        assertTrue("data must be equal",
                   arrayEquals(tsFloatData, newSeries[0].fseries(), 90));
        assertEquals(2,newSeries[0].validCadences().size());
        assertEquals(100L,newSeries[0].validCadences().get(1).start());
        assertEquals(tsFloatData.length + 99, 
                     (int) newSeries[0].validCadences().get(1).end());
        assertEquals(10L,newSeries[0].validCadences().get(0).start());
        assertEquals(10L, 
                     newSeries[0].validCadences().get(0).end());
        assertEquals((float)Math.E, newSeries[0].fseries()[0], 0);
        assertEquals(42L, newSeries[0].originators().get(0).tag());
        assertEquals(23L, newSeries[0].originators().get(1).tag());
        
        List<Interval>[] ranges = 
            fsClient.getCadenceIntervalsForId(new FsId[] {id1});
        assertEquals(10L, ranges[0].get(0).start());
        assertEquals(10L, ranges[0].get(0).end());
        assertEquals(100L, ranges[0].get(1).start());
        assertEquals((long)(99 + tsFloatData.length), ranges[0].get(1).end());
        
    }

    /**
     * <pre>
     *           nnnnn
     *             |
     *             V
     * 0000000dddddddddd
     * </pre>
     */
    @Test
    public void testWriteInMiddle() {
        TimeSeries ts1 = 
            new FloatTimeSeries(id1, tsFloatData,
                100, 100+tsFloatData.length - 1, validList(smallIntervals,100),
                originList(smallIntervals,100));

        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{ts1});


        TimeSeries eSeries = 
            new FloatTimeSeries(id1,  new float[] {(float)Math.E},
                110,110,
                Collections.singletonList(new SimpleInterval(110,110)),
                Collections.singletonList(new TaggedInterval(110,110, 42)));


        fsClient.writeTimeSeries(new TimeSeries[] {eSeries});
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] newSeries = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1},
            100, tsFloatData.length + 99);

        assertEquals(tsFloatData.length, newSeries[0].fseries().length);

        tsFloatData[10] = (float) Math.E;
        assertTrue("array data must be equal.",
            Arrays.equals(tsFloatData, newSeries[0].fseries()));
        assertEquals(100L, newSeries[0].originators().get(0).start());
        assertEquals(109L, newSeries[0].originators().get(0).end());
        assertEquals(110L, newSeries[0].originators().get(1).start());
        assertEquals(110L, newSeries[0].originators().get(1).end());
        assertEquals(111L, newSeries[0].originators().get(2).start());
        assertEquals(tsFloatData.length + 99, (int)newSeries[0].originators().get(2).end());
        assertEquals(1, newSeries[0].validCadences().size());
    }
   
    /**
     * <pre>
     *               nnnnnn
     *                 |
     *                 V
     *   00000000ddddXXXXX
     * </pre>
     */
    @Test
    public void testWriteAtEnd() {
        TimeSeries ts1 = 
            new FloatTimeSeries(id1, tsFloatData,
                100, 100+tsFloatData.length - 1, validList(smallIntervals,100),
                originList(smallIntervals,100));


        TimeSeries eSeries = 
            new FloatTimeSeries(id1,  new float[] {(float)Math.E ,(float) (2 * Math.E)},
                1000,1001,
                Collections.singletonList(new SimpleInterval(1000,1001)),
                Collections.singletonList(new TaggedInterval(1000,1001, 42)));


        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] {ts1, eSeries});
        fsClient.commitLocalFsTransaction();

        FloatTimeSeries[] newData =
            fsClient.readTimeSeriesAsFloat(new FsId[] {id1}, 
                   0, 1001);
        assertEquals(1002, newData[0].fseries().length);
        assertTrue("Array data must match.", 
            arrayEquals(tsFloatData, newData[0].fseries(), 100));
        assertEquals((float)Math.E, newData[0].fseries()[1000], 0);
        assertEquals((float)Math.E * 2, newData[0].fseries()[1001], 0);
        assertEquals(100L, newData[0].validCadences().get(0).start());
        assertEquals(tsFloatData.length + 99,
                     (int) newData[0].validCadences().get(0).end());
        assertEquals(1000L, newData[0].validCadences().get(1).start());
        assertEquals(1001L,
                      newData[0].originators().get(1).end());
        assertEquals(100L, newData[0].originators().get(0).start());
        assertEquals(tsFloatData.length + 99,
                     (int) newData[0].originators().get(0).end());
        assertEquals(1000L, newData[0].originators().get(1).start());
        assertEquals(1001L,
                      newData[0].originators().get(1).end());
        assertEquals(42L, newData[0].originators().get(1).tag());
    }  
    
    /**
     * <pre>
     *               nnnnnnnnnnnnn
     *                     |
     *                     V
     *   0000dddddd00000000000000000ddddddd
     * </pre>
     */
    @Test
    public void testWriteIntoHole() {
        int[] offsets = new int[]{100, 2000, 1000};
        TimeSeries[] tsa = new TimeSeries[offsets.length];
        for (int i=0; i < tsa.length; i++) {
            tsa[i] =new FloatTimeSeries(id1, tsFloatData, 
                offsets[i], offsets[i]+tsFloatData.length - 1, 
                validList(smallIntervals,offsets[i]),
                originList(smallIntervals,offsets[i]));
        }

        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(tsa);
        fsClient.commitLocalFsTransaction();

        Arrays.sort(offsets);
        FloatTimeSeries[] newData = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1}, 
                    0, 
                offsets[offsets.length - 1] + tsFloatData.length - 1);

        assertEquals(offsets.length, newData[0].validCadences().size());
        
        for (int i=0; i < offsets.length; i++ ) {
            assertTrue("Array must be equals for array" + i,
                arrayEquals(tsFloatData, newData[0].fseries(), offsets[i], offsets[i] + tsFloatData.length));

            assertEquals(offsets[i], (int)newData[0].validCadences().get(i).start());
            assertEquals(offsets[i] + tsFloatData.length - 1, 
                (int)newData[0].validCadences().get(i).end());
        }

    }
    
    /**
     *  <pre>
     *         nnnnnnnnnnnnnnnnnnnnn
     *                   |
     *                   V
     *    ddddddd000000000000000dddddddddd
     *  </pre>
     */
    @Test
    public void testMergeRanges() {
        int[] offsets = 
            new int[]{100, 100 + tsFloatData.length + tsFloatData.length/2,  
                          100 + tsFloatData.length/2};
        
        fsClient.beginLocalFsTransaction();
        for (int i=0; i <offsets.length; i++) {
            
            //Change originators
            for (int smi=2; smi < smallIntervals.length; smi+=3) {
                smallIntervals[smi] = i;
            }
            
            FloatTimeSeries fts= new FloatTimeSeries(id1, tsFloatData, 
                offsets[i], offsets[i]+tsFloatData.length - 1, 
                validList(smallIntervals,offsets[i]),
                originList(smallIntervals,offsets[i]));
            
            fsClient.writeTimeSeries(new TimeSeries[] { fts} );
        }

        fsClient.commitLocalFsTransaction();

        Arrays.sort(offsets);
        FloatTimeSeries[] newData = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1},  0, 
                offsets[offsets.length - 1] + tsFloatData.length - 1);
        
        assertTrue("Array must be equals",
            arrayEquals(tsFloatData, newData[0].fseries(),offsets[0], offsets[1] - 1));
        assertTrue("Array must be equals.",
            arrayEquals(tsFloatData, newData[0].fseries(), offsets[1], 
                         tsFloatData.length - 1));
        assertTrue("Array must be equals.",
            arrayEquals(tsFloatData, newData[0].fseries(), 
                        offsets[1] + tsFloatData.length));
        
        assertEquals(offsets[0], (int)newData[0].validCadences().get(0).start());
        assertEquals(offsets[offsets.length - 1] + tsFloatData.length - 1, 
            (int)newData[0].validCadences().get(0).end());
        
        List<TaggedInterval> expectedOriginators = new ArrayList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(100, 100+tsFloatData.length/2-1, 0));
        expectedOriginators.add(new TaggedInterval(100+tsFloatData.length/2, 100+tsFloatData.length/2+tsFloatData.length-1, 2));
        expectedOriginators.add(new TaggedInterval(100+tsFloatData.length/2+tsFloatData.length, 100+tsFloatData.length/2+tsFloatData.length*2-1, 1));
        
        assertEquals(expectedOriginators, newData[0].originators());
    }
    
    /**
     * <per>
     *    1111111111111111111111111111111111
     *        |
     *        V
     * 0: 000000000000000000000000000000000
     * 
     * 
     * 1:  222222222222222222222222222222222
     *        |
     *        V
     *    1111111111111111111111111111111111
     * 
     * N:
     *    ................NNNNNNNNNNNNNNNNNN
     *       |
     *       V
     *    1234567............
     * </pre>
     * @throws FileStoreException
     */
    @Test
    public void testMergeMany() {
        fsClient.beginLocalFsTransaction();
        
        for (int i=0; i < tsFloatData.length; i++)  {
            
            int endCadence = tsFloatData.length + i - 1;
            
            //Change originators.
            for (int smi=2; smi < smallIntervals.length; smi += 3) {
                smallIntervals[smi] = i;
            }
            
           TimeSeries t =  new FloatTimeSeries(id1, tsFloatData,
                    i, endCadence, 
                    validList(smallIntervals,i),
                    originList(smallIntervals,i));
           fsClient.writeTimeSeries(new TimeSeries[]{t});
        }
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] tsa = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1},  
                                           0, (tsFloatData.length * 2) -1);
        
        float[] piArray = new float[tsFloatData.length];
        Arrays.fill(piArray, (float) Math.PI);
        assertTrue("Arrays must be equal.", 
            arrayEquals(piArray, tsa[0].fseries(), 0, tsFloatData.length-1));
        assertTrue("Arrays must be equal.",
                   arrayEquals(tsFloatData, tsa[0].fseries(), tsFloatData.length-1));
        
        List<TaggedInterval> expectedOriginators =
            new ArrayList<TaggedInterval>();
        
        for (int i=0; i < tsFloatData.length-1; i++) {
            expectedOriginators.add(new TaggedInterval(i,i,i));
        }
        expectedOriginators.add(new TaggedInterval(tsFloatData.length-1, 2*tsFloatData.length -2, tsFloatData.length-1));
        assertEquals(expectedOriginators, tsa[0].originators());
    }
    
    /**
     * Single time series with gaps, instead of writing multiple times to generate
     * the gaps.
     * <pre>
     *    1111111ddddddd11111111111111
     *                    |
     *                    v
     *    ddddddddddddddddddddddddd
     * </pre>
     * @throws FileStoreException
     */
    @Test
    public void writeDataWithAbysses() {
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        valid.add(new SimpleInterval(0, tsFloatData.length - 1));
        valid.add(new SimpleInterval(tsFloatData.length * 2, (3*tsFloatData.length) -1));
        origin.add(new TaggedInterval(0, tsFloatData.length - 1, 1));
        origin.add(new TaggedInterval(tsFloatData.length * 2, (3*tsFloatData.length) -1, 1));
        
        float[] data = new float[tsFloatData.length * 3];
        System.arraycopy(tsFloatData, 0, data, 0, tsFloatData.length);
        System.arraycopy(tsFloatData, 0, data, tsFloatData.length*2, tsFloatData.length);
        TimeSeries t 
           =new FloatTimeSeries(id1, data,
            0,  (3*tsFloatData.length) -1, 
            valid, origin);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[]{t});
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] tsa = 
            fsClient.readTimeSeriesAsFloat(new FsId[]{id1}, 
                                           0, tsFloatData.length * 3 - 1);
        
        assertEquals(1, tsa.length);
        assertEquals(tsFloatData.length * 3, tsa[0].fseries().length);
        assertTrue("Arrays must be equals.", 
            arrayEquals(tsFloatData, tsa[0].fseries(), 0, tsFloatData.length - 1));
        assertTrue("Arrays must be equals.", 
            arrayEquals(tsFloatData, tsa[0].fseries(), 
                tsFloatData.length *2 , 3* tsFloatData.length - 1));
        assertTrue("Valid intervals must be equal.", 
                valid.equals(tsa[0].validCadences()));
        assertTrue("Origin intervals must be equal.", 
               origin.equals(tsa[0].originators()));
    }
    
    /**
     * Overwrite = false so [start,end] cadence is not removed before
     * writing.
     * 
     * <pre>
     * 222x222xxx2222222xxxxxx2
     *    |
     *    v
     * xxxx11111xxxx11111xxxxxx
     * </pre>
     */
    @Test
    public void overwriteIsFalse() {
        List<SimpleInterval> valid1 = new ArrayList<SimpleInterval>();
        List<TaggedInterval> origin1 = new ArrayList<TaggedInterval>();
        
        valid1.add(new SimpleInterval(2,4));
        valid1.add(new SimpleInterval(50,51));
        origin1.add(new TaggedInterval(2,4,1));
        origin1.add(new TaggedInterval(50,51,1));
        
        IntTimeSeries its1 = 
            new IntTimeSeries(id1, tsIntData, 0, tsIntData.length - 1, valid1, origin1);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its1}, false);
        fsClient.commitLocalFsTransaction();
        
        List<SimpleInterval> valid2 = new ArrayList<SimpleInterval>();
        List<TaggedInterval> origin2 = new ArrayList<TaggedInterval>();
        
        valid2.add(new SimpleInterval(0,0));
        valid2.add(new SimpleInterval(2,3));
        valid2.add(new SimpleInterval(49,50));
        valid2.add(new SimpleInterval(tsIntData.length - 1, tsIntData.length - 1));
        origin2.add(new TaggedInterval(0,0,2));
        origin2.add(new TaggedInterval(2,3,2));
        origin2.add(new TaggedInterval(49,50,2));
        origin2.add(new TaggedInterval(tsIntData.length - 1, tsIntData.length -1, 2));
        
        int[] data2 = new int[tsIntData.length];
        for (int i=0; i < tsIntData.length; i++) {
            data2[i] = tsIntData[i] + 1000;
        }
        IntTimeSeries its2 = 
            new IntTimeSeries(id1, data2, 0, data2.length - 1, valid2, origin2);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its2}, false);
        IntTimeSeries[] uncommitted = 
            fsClient.readTimeSeriesAsInt(new FsId[] { id1} , 0, tsIntData.length - 1);
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries[] committed = 
            fsClient.readTimeSeriesAsInt(new FsId[] { id1} , 0, tsIntData.length - 1);
        
        
        assertEquals(committed[0], uncommitted[0]);
        
        List<SimpleInterval> validC = new ArrayList<SimpleInterval>();
        List<TaggedInterval> originC = new ArrayList<TaggedInterval>();
        validC.add(new SimpleInterval(0,0));
        validC.add(new SimpleInterval(2,4));
        validC.add(new SimpleInterval(49,51));
        validC.add(new SimpleInterval(tsIntData.length -1, tsIntData.length - 1));
        
        originC.add(new TaggedInterval(0,0,2));
        originC.add(new TaggedInterval(2,3,2));
        originC.add(new TaggedInterval(4,4,1));
        originC.add(new TaggedInterval(49,50,2));
        originC.add(new TaggedInterval(51,51,1));
        originC.add(new TaggedInterval(tsIntData.length -1, tsIntData.length - 1, 2));
        
        assertEquals(committed[0].validCadences(), validC);
        assertEquals(committed[0].originators(), originC);
        
        int[] dataC = new int[tsIntData.length];
        for (TaggedInterval o : originC) {
            int[] src =  (o.tag() == 1) ? tsIntData : data2;
                
            System.arraycopy(src, (int)o.start(), dataC, 
                        (int)o.start(), (int) (o.end() - o.start() + 1));
        }
        
        assertTrue("data arrays differ", Arrays.equals(dataC, committed[0].iseries()));
    }
    
    /**
     * Writes and reads lots of different time series in one call.
     */
    @Test
    public void testWriteReadManySeries() throws Exception {
        FsId[] ids = new FsId[99];
        TimeSeries[] initial = new TimeSeries[ids.length];
        for (int i=0; i < ids.length; i++) {
            ids[i] = new FsId("/test/id" + i);
            initial[i] = new FloatTimeSeries(ids[i], tsFloatData,  0, 
                tsFloatData.length-1, validList(smallIntervals,0), originList(smallIntervals,0));
        }
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(initial);
        fsClient.commitLocalFsTransaction();
        
        TimeSeries[] read = fsClient.readTimeSeriesAsFloat(ids, 0, tsFloatData.length - 1);
        assertEquals(initial.length, read.length);
        for (int i=0; i < read.length; i++) {
            assertEquals("ts i="+i+"\n initial:"+initial[i] + "\n"+read[i], initial[i], read[i]);
        }
        
    }
    
    /**
     * Test that uncomitted data can be read back from the same transaction.
     */
    @Test
    public void testReadUnComitted() throws Exception {
        if (!runTransactionTests()) {
            return;
        }
        
        int[] maxIntData = new int[tsIntData.length * 2];
        Arrays.fill(maxIntData, Integer.MAX_VALUE);
        
        TimeSeries maxIntSeries =
            new IntTimeSeries(id1, maxIntData, 0, maxIntData.length - 1,
                                           Collections.singletonList(new SimpleInterval(0, maxIntData.length - 1)),
                                           Collections.singletonList(new TaggedInterval(0, maxIntData.length -1, Integer.MIN_VALUE)));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { maxIntSeries} );
        
        
        TestCantReadUncommittedData cantRead = 
            new TestCantReadUncommittedData(id1);
        Thread t = new Thread(cantRead);
        t.setDaemon(true);
        t.start();
        Thread.yield();
        t.join();
        
        assertFalse(cantRead.error);
        assertFalse(cantRead.idFound);
        
        fsClient.commitLocalFsTransaction();
        
        TimeSeries ts = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        fsClient.beginLocalFsTransaction();
        //Write twice to check if the read non-transactioned parts can combine
        //multiple outstanding writes.
        fsClient.writeTimeSeries(new TimeSeries[]{ts});
        fsClient.writeTimeSeries(new TimeSeries[]{ts});

        TestReadOldDataOnly readOld = new TestReadOldDataOnly(id1, maxIntData);
        t = new Thread(readOld);
        t.setDaemon(true);
        t.start();
        Thread.yield();
        t.join();
        
        assertFalse(readOld.isError);
        assertTrue(readOld.asExpected);
        
        IntTimeSeries[] tsa =  
            fsClient.readTimeSeriesAsInt(new FsId[] {id1},  0, tsIntData.length -1 );
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        TaggedInterval origin = tsa[0].originators().get(0);
        assertEquals(0L, origin.start());
        assertEquals((long)(tsIntData.length - 1), origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        SimpleInterval valid = tsa[0].validCadences().get(0);
        assertEquals(0, (int) valid.start());
        assertEquals(tsIntData.length -1 , (int) valid.end());
        assertTrue("Data must be equal.", Arrays.equals(tsIntData, tsa[0].iseries()));
        
        tsa =  
            fsClient.readTimeSeriesAsInt(new FsId[] {id1},  10, 10);
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].originators().size());
        origin = tsa[0].originators().get(0);     
        assertEquals(10, (int) origin.start());
        assertEquals(10, (int)origin.end());
        assertEquals(smallIntervals[2], origin.tag());
        assertEquals(1,tsa[0].validCadences().size());
        valid = tsa[0].validCadences().get(0);
        assertEquals(10, (int) valid.start());
        assertEquals(10 , (int) valid.end());
        assertEquals(tsIntData[10], tsa[0].iseries()[0]);
        
        
        //Check that we can read the original  max int data at the end.
        tsa =
            fsClient.readTimeSeriesAsInt(new FsId[] { id1}, 0, maxIntData.length-1);
        assertEquals(1, tsa.length);
        assertEquals(1, tsa[0].validCadences().size());
        assertEquals(0L, tsa[0].validCadences().get(0).start());
        assertEquals((long)maxIntData.length-1, tsa[0].validCadences().get(0).end());
        assertEquals(0, tsa[0].startCadence());
        assertEquals(maxIntData.length-1, tsa[0].endCadence());
        
        List<TaggedInterval> originators = tsa[0].originators();
        assertEquals(2, originators.size());
        assertEquals(0L, originators.get(0).start());
        assertEquals((long) (tsIntData.length -1), originators.get(0).end());
        assertEquals(23L, originators.get(0).tag());
        assertEquals((long) tsIntData.length, originators.get(1).start());
        assertEquals((long) (maxIntData.length - 1), originators.get(1).end());
        assertEquals((long) Integer.MIN_VALUE, originators.get(1).tag());
        
        assertTrue("Data must be equal.", 
            ArrayUtils.arrayEquals(tsIntData, 0, tsa[0].iseries(), 0, tsIntData.length ));
        assertTrue("Data must be equal.", 
            ArrayUtils.arrayEquals(maxIntData, 0, tsa[0].iseries(),tsIntData.length, tsIntData.length ));
        fsClient.commitLocalFsTransaction();
    }
    
    /**
     * 
     * @throws Exception
     */
    @Test
    public void writeWithoutTransaction() throws Exception {
        try {
            TimeSeries ts = 
                new IntTimeSeries(id1,  tsIntData,
                               0, tsIntData.length - 1, validList(smallIntervals,0),
                               originList(smallIntervals,0));
            fsClient.writeTimeSeries(new TimeSeries[] {ts});
            assertTrue("Write without transaction should not be permitted.", false);
        } catch (FileStoreException ok) {
            
        }
    }
    
    /**
     * Test that reading the wrong type throws an exception.
     */
    @Test
    public void readWrongType() throws Exception {
        try {
            IntTimeSeries ts = new IntTimeSeries(id1, tsIntData,
                                           0, tsIntData.length - 1, validList(smallIntervals, 0),
                                           originList(smallIntervals, 0));
            fsClient.beginLocalFsTransaction();
            fsClient.writeTimeSeries(new TimeSeries[] { ts });
            fsClient.commitLocalFsTransaction();
            fsClient.readTimeSeriesAsFloat(new FsId[] { id1} , 0, 0);
            assertTrue("Should have thrown mixed type exception.", false);
        } catch (MixedTypeException x) {
            //OK.
        }
    }
    
    /**
     * Read all int time series.
     */
    @Test
    public void readAllIntTimeSeries() throws Exception {
        IntTimeSeries ts = new IntTimeSeries(id1, tsIntData,
                                             1, tsIntData.length, validList(smallIntervals, 1),
                                             originList(smallIntervals, 1));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts });
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries[] its = fsClient.readAllTimeSeriesAsInt(new FsId[] { id1 });
        assertEquals(1, its.length);
        assertTrue("exists() should return true", its[0].exists());
        assertEquals(1L, its[0].validCadences().get(0).start());
        assertEquals(tsIntData.length, (int) its[0].validCadences().get(0).end());
        assertTrue("Arrays must be equals.",
            Arrays.equals(tsIntData, its[0].iseries()) );
    }
    
    
    /**
     * Read all float time series.
     */
    @Test
    public void readAllFloatTimeSeries() throws Exception {
        FloatTimeSeries ts = new FloatTimeSeries(id1, tsFloatData,
                                             1, tsFloatData.length, validList(smallIntervals, 1),
                                             originList(smallIntervals, 1));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts });
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] its = fsClient.readAllTimeSeriesAsFloat(new FsId[] { id1 });
        assertEquals(1, its.length);
        assertTrue("exists() should return true", its[0].exists());
        assertEquals(its[0].validCadences().get(0).start(),1L);
        assertEquals(tsFloatData.length, (int) its[0].validCadences().get(0).end());
        assertTrue("Arrays must be equals.",
            Arrays.equals(tsFloatData, its[0].fseries()) );
    }

    @Test
    public void testValidCadencesFromGaps() {
        FloatTimeSeries fts1 = new FloatTimeSeries(id1, tsFloatData, 1,
            tsFloatData.length, validList(smallIntervals, 1), originList(
                smallIntervals, 1));
        FloatTimeSeries fts2 = new FloatTimeSeries(id1, tsFloatData, 1,
            tsFloatData.length, fts1.getGapIndicators(), 23);
        FloatTimeSeries fts3 = new FloatTimeSeries(id1, tsFloatData, 1,
            tsFloatData.length, fts1.getGapIndices(), 23);

        assertEquals("valid cadences from gap indicators",
            fts1.validCadences(), fts2.validCadences());
        assertEquals("valid cadences from gap indices", fts1.validCadences(),
            fts3.validCadences());

        assertTrue("gap indicators", Arrays.equals(fts1.getGapIndicators(),
            fts2.getGapIndicators()));
        assertTrue("gap indicators", Arrays.equals(fts1.getGapIndicators(),
            fts3.getGapIndicators()));

        assertTrue("gap indices", Arrays.equals(fts1.getGapIndices(),
            fts2.getGapIndices()));
        assertTrue("gap indices", Arrays.equals(fts1.getGapIndices(),
            fts3.getGapIndices()));

        assertEquals("time series", fts1, fts2);
        assertEquals("time series", fts1, fts3);

        long[] intervals = new long[] { 1, tsFloatData.length - 2, 23 };
        fts1 = new FloatTimeSeries(id1, tsFloatData, 1, tsFloatData.length,
            validList(intervals, 1), originList(intervals, 1));
        fts2 = new FloatTimeSeries(id1, tsFloatData, 1, tsFloatData.length,
            fts1.getGapIndicators(), 23);
        fts3 = new FloatTimeSeries(id1, tsFloatData, 1, tsFloatData.length,
            fts1.getGapIndices(), 23);

        assertEquals("valid cadences from gap indicators",
            fts1.validCadences(), fts2.validCadences());
        assertEquals("valid cadences from gap indices", fts1.validCadences(),
            fts3.validCadences());

        assertTrue("gap indicators", Arrays.equals(fts1.getGapIndicators(),
            fts2.getGapIndicators()));
        assertTrue("gap indicators", Arrays.equals(fts1.getGapIndicators(),
            fts3.getGapIndicators()));

        assertTrue("gap indices", Arrays.equals(fts1.getGapIndices(),
            fts2.getGapIndices()));
        assertTrue("gap indices", Arrays.equals(fts1.getGapIndices(),
            fts3.getGapIndices()));

        assertEquals("time series", fts1, fts2);
        assertEquals("time series", fts1, fts3);

        intervals = new long[] { 1, tsIntData.length / 2, 23,
            (tsIntData.length / 2) + 2, tsIntData.length - 1, 23 };
        IntTimeSeries its1 = new IntTimeSeries(id1, tsIntData, 1, tsIntData.length,
            validList(intervals, 1), originList(intervals, 1));
        IntTimeSeries its2 = new IntTimeSeries(id1, tsIntData, 1, tsIntData.length,
            its1.getGapIndicators(), 23);
        IntTimeSeries its3 = new IntTimeSeries(id1, tsIntData, 1, tsIntData.length,
            its1.getGapIndices(), 23);

        assertEquals("valid cadences from gap indicators",
            its1.validCadences(), its2.validCadences());
        assertEquals("valid cadences from gap indices", its1.validCadences(),
            its3.validCadences());

        assertTrue("gap indicators", Arrays.equals(its1.getGapIndicators(),
            its2.getGapIndicators()));
        assertTrue("gap indicators", Arrays.equals(its1.getGapIndicators(),
            its3.getGapIndicators()));

        assertTrue("gap indices", Arrays.equals(its1.getGapIndices(),
            its2.getGapIndices()));
        assertTrue("gap indices", Arrays.equals(its1.getGapIndices(),
            its3.getGapIndices()));

        assertEquals("time series", its1, its2);
        assertEquals("time series", its1, its3);
    }
    
    /**
     * <pre>
     *     start  |--------------------------| end
     *        ddddddddddddddddddddd
     *  </pre>
     */
    @SuppressWarnings("unchecked")
    @Test
    public void deleteDataInterval() throws Exception {
        TimeSeries ts = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts} );
        fsClient.commitLocalFsTransaction();
        
        TimeSeries deleteSeries = 
            new IntTimeSeries(id1, new int[tsIntData.length - 2], 1, tsIntData.length -2,
                                          Collections.EMPTY_LIST, Collections.EMPTY_LIST);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { deleteSeries });
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries[] tsa = fsClient.readAllTimeSeriesAsInt(new FsId[] { id1} );
        
        assertEquals(1, tsa.length);
        assertEquals(0, tsa[0].startCadence());
        assertEquals(tsIntData.length - 1, tsa[0].endCadence());
        List<TaggedInterval> originators = tsa[0].originators();
        assertEquals(2, originators.size());
        assertEquals(0L, originators.get(0).start());
        assertEquals(0L, originators.get(0).end());
        assertEquals(23L, originators.get(0).tag());
        assertEquals((long) tsIntData.length - 1, originators.get(1).start());
        assertEquals((long) tsIntData.length -1, originators.get(1).end());
        assertEquals(23L, originators.get(1).tag());
        
        List<SimpleInterval> valid = tsa[0].validCadences();
        assertEquals(2, valid.size());
        assertEquals(0L, valid.get(0).start());
        assertEquals(0L, valid.get(0).end());
        assertEquals((long) tsIntData.length - 1, valid.get(1).start());
        assertEquals((long) tsIntData.length - 1, valid.get(1).end());
    }
    
    @Test
    public void testReadAllTimeSeriesWithEmptyTimeSeries() throws Exception {
        boolean[] gaps = new boolean[1024];
        Arrays.fill(gaps, true);
        
        FloatTimeSeries fts = new FloatTimeSeries(id1, new float[1024], 0,1023, gaps, 666 );
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { fts });
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] readTimeSeries = fsClient.readAllTimeSeriesAsFloat(new FsId[] {id1});
        assertEquals(1, readTimeSeries.length);
        assertEquals(id1, readTimeSeries[0].id());
        assertEquals(0, readTimeSeries[0].validCadences().size());
        
    }
    
    @Test
    public void pdqWriteWithGapsTest() throws Exception {
        boolean[] gaps = { true, false, true, false};
        float[] pdqData = new float[] { -1.0f, 10.0f, -1.0f, 11.0f};
        FloatTimeSeries fts = new FloatTimeSeries(id1, pdqData, 0,3,gaps,5);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { fts} );
        fsClient.commitLocalFsTransaction();
        
        FloatTimeSeries[] readSeries = 
            fsClient.readAllTimeSeriesAsFloat(new FsId[] { id1} );
        assertEquals(1, readSeries.length);
        assertEquals(3, readSeries[0].cadenceLength());
        assertTrue(Arrays.equals(new boolean[] {false, true, false}, readSeries[0].getGapIndicators()));
    }
    
    @Test
    public void testLargeCadenceNumbers() throws Exception {
        final int billion = 1000000000;
        FsId id = new FsId("/large-cadence-numbers/billion");
        IntTimeSeries its = new IntTimeSeries(id, new int[] { 666} , billion, billion, new boolean[1], billion * 6);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its }, true);
        fsClient.commitLocalFsTransaction();
        
        IntTimeSeries readTimeSeries =
            fsClient.readTimeSeriesAsInt(new FsId[] { id}, billion, billion)[0];
        ReflectionEquals refelectionEquals = new ReflectionEquals();
        refelectionEquals.assertEquals(its, readTimeSeries);
    }
    
    /**
     * Explicitly deletes a TimeSeries.  Check that a transaction is required.
     * Check that rollback will not remove an existing time series.  Then 
     * actually remove it.
     * 
     * @throws Exception
     */
    @Test
    public void explicitDelete() throws Exception {
        try {
            fsClient.deleteTimeSeries(new FsId[] { id1 });
            assertTrue("Should not have reached here." , false);
        } catch (FileStoreException fex) {
            //ok
        }
        
        TimeSeries its = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its });
        fsClient.commitLocalFsTransaction();
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteTimeSeries(new FsId[] { id1 });
        fsClient.rollbackLocalFsTransaction();
        
        Set<FsId> existingIds = 
            fsClient.queryIds2(QueryEvaluator.DataType.TimeSeries + "@" + id1.toString());
        assertTrue(existingIds.contains(id1));
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteTimeSeries(new FsId[] { id1 });
        fsClient.commitLocalFsTransaction();
        
        existingIds = 
            fsClient.queryIds2(QueryEvaluator.DataType.TimeSeries + "@" + id1.toString());
        assertFalse(existingIds.contains(id1));
    }
    
    /**
     * Write and then read a DoubleTimeSeries.
     * 
     * @throws Exception
     */
    
    @Test
    public void readNonExistentDoubleTimeSeries() throws Exception {
        DoubleTimeSeries[] dts_a = fsClient.readAllTimeSeriesAsDouble(new FsId[] { id1} , false);
        assertEquals(1, dts_a.length);
        assertEquals(false, dts_a[0].exists());
        assertEquals(TimeSeries.NOT_EXIST_CADENCE, dts_a[0].startCadence());
        assertEquals(TimeSeries.NOT_EXIST_CADENCE, dts_a[0].endCadence());
    }
    
    @Test
    public void simpleDoubleTimeSeries() throws Exception {
        DoubleTimeSeries doubleTheFun = 
            new DoubleTimeSeries(id1,tsDoubleData, 0, tsDoubleData.length -1, 
                validList(smallIntervals, 0), originList(smallIntervals, 0));
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { doubleTheFun });
        fsClient.commitLocalFsTransaction();
        
        DoubleTimeSeries[] dts_a = 
            fsClient.readTimeSeriesAsDouble(new FsId[] { id1}, 0, tsDoubleData.length -1, true);
        assertEquals(1, dts_a.length);
        assertEquals(doubleTheFun, dts_a[0]);
        
        FsIdSet idSet = new FsIdSet(0, tsDoubleData.length -1, Collections.singleton(id1));
        List<TimeSeriesBatch> tsBatch = 
            fsClient.readTimeSeriesBatch(Collections.singletonList(idSet), true);
        assertEquals(1, tsBatch.size());
        
        Map<FsId, TimeSeries> returnedTimeSeries = tsBatch.get(0).timeSeries();
        assertEquals(1, returnedTimeSeries.size());
        assertEquals(doubleTheFun, returnedTimeSeries.get(id1));
        
    }
    
    /**
     * <pre>
     *  nnnnnXXXXXXXXnnnnnnnnnnnnnnnnn
     *  nnDnnnnnnnnnnnnnnnnnnnnnnnDnnn
     *  </pre>
     */
    @Test
    public void doubleTimeSeriesWithHoles() throws Exception {
        double[] data = new double[10*1024];
        data[1] = Math.E;
        data[data.length - 10] = Math.PI;
        boolean[] gaps = new boolean[data.length];
        Arrays.fill(gaps, true);
        gaps[1] = false;
        gaps[data.length - 10] = false;
        
        DoubleTimeSeries dts = new DoubleTimeSeries(id1, data, 0, data.length - 1, gaps, 99L);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { dts }, true);
        fsClient.commitLocalFsTransaction();
        
        DoubleTimeSeries[] dts_a = 
            fsClient.readTimeSeriesAsDouble(new FsId[] {id1}, 0, data.length -1, true);
        assertEquals(1, dts_a.length);
        assertEquals(dts, dts_a[0]);
        
        //read all
        dts_a = fsClient.readAllTimeSeriesAsDouble(new FsId[] { id1}, true);
        assertEquals(1, dts_a[0].startCadence());
        assertEquals(data.length - 10, dts_a[0].endCadence());
        assertTrue(ArrayUtils.arrayEquals(data, 1, dts_a[0].dseries(), 0, data.length - 1 -10));
        
        //Do write with overwrite=false
        double[] newData = new double[data.length];
        newData[4000] = Math.tanh(Math.PI);
        boolean[] newGaps = new boolean[newData.length];
        Arrays.fill(newGaps, true);
        newGaps[4000] = false;
        
        DoubleTimeSeries newSeries = new DoubleTimeSeries(id1, newData, 0, data.length - 1, newGaps, 103L);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { newSeries}, false);
        fsClient.commitLocalFsTransaction();
        
        dts_a = fsClient.readTimeSeriesAsDouble(new FsId[] {id1}, 0, data.length -1, true);
        assertEquals(0.0, Math.E, dts_a[0].dseries()[1]);
        assertEquals(0.0, newData[4000], dts_a[0].dseries()[4000]);
        assertEquals(0.0, Math.PI, dts_a[0].dseries()[data.length - 10]);
        
        assertEquals(new TaggedInterval(1,1,99L), dts_a[0].originators().get(0));
        assertEquals(new TaggedInterval(4000,4000, 103L), dts_a[0].originators().get(1));
        assertEquals(new TaggedInterval(data.length - 10, data.length -10, 99L), dts_a[0].originators().get(2));
        
    }
    
    /**
     * Tests the readTimeSeries
     * @throws Exception
     */
    @Test
    public void readTimeSeries() throws Exception {
        TimeSeries ts = 
            new IntTimeSeries(id1,  tsIntData,
                           0, tsIntData.length - 1, validList(smallIntervals,0),
                           originList(smallIntervals,0));

        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts });
        fsClient.commitLocalFsTransaction();
        
        Map<FsId, TimeSeries> idToTimeSeries = 
            fsClient.readTimeSeries(Collections.singleton(id1), 0, tsIntData.length -1, false);
        assertEquals(ts, idToTimeSeries.get(id1));
    }
    

    /**
     * 
     * @param src
     * @param unknown
     * @param unknown_start 
     * @return
     */
    public static boolean arrayEquals(float[] src, float[] unknown, int unknown_start) {
        
        return arrayEquals(src, unknown, unknown_start, Math.max(0,unknown.length - 1));
    }
    
    /**
     * 
     * @param src
     * @param unknown
     * @param unknown_start
     * @param unknown_end inclusive
     * @return
     */
    public static boolean arrayEquals(float[] src, float[] unknown, int unknown_start, int unknown_end) {
        
        int ui = unknown_start;
        for (int si=0; si < src.length && ui <= unknown_end; si++, ui++) {
            if (src[si] != unknown[ui]) return false;
        }
        return true;
    }
    
    /**
     * Checks that a time series does not exist.
     * @author Sean McCauliff
     *
     */
    private class TestCantReadUncommittedData implements Runnable {
        private final FsId id;
        private boolean idFound = true;
        private boolean error = false;
        
        public TestCantReadUncommittedData(FsId id) {
            this.id = id;
        }
        
        public void run() {
            try {
                FileStoreClient fsClient = constructTimeSeriesClient();
                fsClient.disassociateThread();
                IntTimeSeries[] its = fsClient.readAllTimeSeriesAsInt(new FsId[] { id }, false);
                idFound = its[0].exists();
            } catch (Exception e) {
                error = true;
            }
        }
        
        public boolean wasIdFound() {
            return idFound;
        }
        
        public boolean isErrored() {
            return error;
        }
    }
    
    private class TestReadOldDataOnly implements Runnable {
        private final FsId id;
        private final int[] expectedData;
        private boolean asExpected = false;
        private boolean isError = false;
        
        public TestReadOldDataOnly(FsId id, int[] expectedData) {
            this.id = id;
            this.expectedData = expectedData;
        }
        
        public void run() {
            try {
                FileStoreClient fsClient = constructTimeSeriesClient();
                fsClient.disassociateThread();
                IntTimeSeries[] its = fsClient.readAllTimeSeriesAsInt(new FsId[] { id });
                asExpected = Arrays.equals(expectedData, its[0].iseries());
            } catch (Exception e) {
                isError = true;
            }
        }
    }
    
}
