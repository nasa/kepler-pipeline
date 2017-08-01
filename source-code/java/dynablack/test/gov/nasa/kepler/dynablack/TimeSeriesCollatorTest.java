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

package gov.nasa.kepler.dynablack;


import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMock.class)
public class TimeSeriesCollatorTest {

    private PixelTimeSeriesReader timeSeriesReader;
    private Mockery mockery;
    private final int startCadence = 0;
    private final int endCadence = 1;
    
    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        timeSeriesReader = mockery.mock(PixelTimeSeriesReader.class);
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void removeDuplicates() throws Exception {

        final List<Pixel> pixels = generatePixels(1024* 10, 512);
        pixels.addAll(new ArrayList<Pixel>(pixels));

        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] returnTimeSeries = makePixelTimeSeries(ids);
        assertEquals(1024*10*2, returnTimeSeries.length);
        final IntTimeSeries[] deduplicated = new IntTimeSeries[returnTimeSeries.length/2];
        int i=0;
        Set<FsId> seen = new HashSet<FsId>();
        final FsId[] deduplicatedIds = new FsId[ids.length / 2];
        for (IntTimeSeries orig : returnTimeSeries) {
            if (seen.contains(orig.id())) continue;

            seen.add(orig.id());
            deduplicated[i] = orig;
            deduplicatedIds[i++] = orig.id();
        }
        
        mockery.checking(new Expectations() {{
            one(timeSeriesReader).readTimeSeriesAsInt(deduplicatedIds, startCadence, endCadence);
            will(returnValue(deduplicated));
        }});

        TimeSeriesCollator collator = 
            new TimeSeriesCollator(pixels, timeSeriesReader, 1024*10, 1024*10, startCadence, endCadence);
        assertTrue(collator.hasNext());
        assertArrayEquals(deduplicated, collator.nextChunk());
        assertFalse(collator.hasNext());
    }
    
    
    @Test
    public void singleChunk() throws Exception {
        singleChunk(false);
    }
    
    @Test
    public void singleChunkPrefetch() throws Exception {
        singleChunk(true);
    }
    
    private void singleChunk(boolean prefetch) throws Exception {
        
        final List<Pixel> pixels = generatePixels(1024* 10, 512);
        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] returnTimeSeries = makePixelTimeSeries(ids);
        
        
        mockery.checking(new Expectations() {{
            one(timeSeriesReader).readTimeSeriesAsInt(ids, startCadence, endCadence);
            will(returnValue(returnTimeSeries));
        }});
        TimeSeriesCollator collator = 
            new TimeSeriesCollator(pixels, timeSeriesReader, 1024*10, 1024*10, 0, 1);
        if (prefetch) {
            collator.preFetch();
        }
        assertTrue(collator.hasNext());
        assertArrayEquals(returnTimeSeries, collator.nextChunk());
        assertFalse(collator.hasNext());
    }

    @Test
    public void threeChunksSingleFetch() throws Exception {
        threeChunksSingleFetch(false);
    }
    
    @Test
    public void threeChunksSingleFetchPrefetch() throws Exception {
        threeChunksSingleFetch(true);
    }
    
    private void threeChunksSingleFetch(boolean prefetch) throws Exception {
        final int rowSize = 500;
        List<Pixel> pixels = generatePixels(1024* 10,  rowSize );
        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] returnTimeSeries = makePixelTimeSeries(ids);
        
        
        final int chunkSize = 1024 * 5;
        
        int expectedNPixels = (chunkSize / rowSize) * rowSize;

        mockery.checking(new Expectations() {{
            one(timeSeriesReader).readTimeSeriesAsInt(ids, startCadence, endCadence);
            will(returnValue(returnTimeSeries));
        }});
        
        
        TimeSeriesCollator collator = 
            new TimeSeriesCollator(pixels, timeSeriesReader, chunkSize, 1024*10, startCadence, endCadence);
        if (prefetch) {
            collator.preFetch();
        }
        assertTrue(collator.hasNext());

        
        assertArrayEquals(collator.nextChunk(), Arrays.copyOfRange(returnTimeSeries, 0, expectedNPixels));
        if (prefetch) {
            collator.preFetch();
        }
        

        assertTrue(collator.hasNext());
        assertArrayEquals(collator.nextChunk(), Arrays.copyOfRange(returnTimeSeries, expectedNPixels, 2*expectedNPixels));
        if (prefetch) {
            collator.preFetch();
        }
        assertTrue(collator.hasNext());
        assertArrayEquals(collator.nextChunk(), Arrays.copyOfRange(returnTimeSeries, 2*expectedNPixels, returnTimeSeries.length));
        if (prefetch) {
            collator.preFetch();
        }
        assertFalse(collator.hasNext());
        
    }
    
    @Test
    public void oneChunkMultipleFetch() throws Exception {
        oneChunkMultipleFetch(false);
    }
    
    @Test
    public void oneChunkMultipleFetchPrefetch() throws Exception {
        oneChunkMultipleFetch(true);
    }
    
    
    private void oneChunkMultipleFetch(boolean prefetch) throws Exception {
        final int rowSize = 500;
        final List<Pixel> pixels = generatePixels(1024* 10, rowSize );
        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] returnTimeSeries = makePixelTimeSeries(ids);
        
        final int chunkSize = 1024 * 10;
        final int fetchSize = 1;
        mockery.checking(new Expectations() {{
            for (int i=0; i < ids.length; i++) {
                FsId[] singleId = new FsId[] { ids[i] };
                IntTimeSeries[] singleTimeSeries = new IntTimeSeries[] { returnTimeSeries[i] };
                one(timeSeriesReader).readTimeSeriesAsInt(singleId, startCadence, endCadence);
                will(returnValue(singleTimeSeries));
            }
        }});
        
        TimeSeriesCollator collator = 
            new TimeSeriesCollator(pixels, timeSeriesReader, chunkSize, fetchSize, startCadence, endCadence);
        if (prefetch) {
            collator.preFetch();
        }
        assertTrue(collator.hasNext());
        assertArrayEquals(returnTimeSeries, collator.nextChunk());
        if (prefetch) {
            collator.preFetch();
        }
        assertFalse(collator.hasNext());
    }
    
    /**
     * This tests the normal case where the cache size and the row/fetch
     * size do not match.  Some calls to collator will be partially cached, others
     * will be completely cached and at times none at all will be cached.
     * @throws Exception
     */
    @Test
    public void multiChunkMultiFetch() throws Exception {
        multiChunkMultiFetch(false);
    }
    
    
    @Test
    public void multiChunkMultiFetchPrefetch() throws Exception {
        multiChunkMultiFetch(true);
    }
    
    private void multiChunkMultiFetch(boolean prefetch) throws Exception {
        final int rowSize = 512;
        final List<Pixel> pixels = generatePixels(1024 * 10, rowSize );
        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] returnTimeSeries = makePixelTimeSeries(ids);
        
        final int chunkSize = 1024;
        final int fetchSize = 1024 + 512;
        mockery.checking(new Expectations() {{
            for (int i=0, nPixelsFetched=0;
                 i < Math.ceil(pixels.size() / (double) fetchSize);
                 i++, nPixelsFetched += fetchSize) {
                int endIndex = Math.min(nPixelsFetched + fetchSize, ids.length);
                FsId[] idChunk = Arrays.copyOfRange(ids, nPixelsFetched, endIndex);
                IntTimeSeries[] timeSeriesChunk = Arrays.copyOfRange(returnTimeSeries, nPixelsFetched, endIndex);
                one(timeSeriesReader).readTimeSeriesAsInt(idChunk, startCadence, endCadence);
                will(returnValue(timeSeriesChunk));
            }
        }});
        
        TimeSeriesCollator collator = 
            new TimeSeriesCollator(pixels, timeSeriesReader, chunkSize, fetchSize, startCadence, endCadence);
        
        for (int i=0; i < 10; i++) {
            if (prefetch) {
                collator.preFetch();
                //System.out.println("Cache size: " + collator.cacheSize());
            }
            assertTrue(collator.hasNext());
            assertArrayEquals(Arrays.copyOfRange(returnTimeSeries, i*chunkSize, (i+1)* chunkSize), collator.nextChunk());
            //Test # of cached time series
            if (i != 9) {
                switch ( i % 3) {
                    case 0: assertEquals(512, collator.cacheSize()); break;
                    case 1: assertEquals(1024, collator.cacheSize()); break;
                    case 2: assertEquals(0, collator.cacheSize()); break;
                }
            }
        }
        assertEquals(0, collator.cacheSize());
        assertFalse(collator.hasNext());
    }
    
    @Test
    public void nonExistentPixel() {
        final List<Pixel> pixels = generatePixels(1024 * 10, 512);
        final FsId[] ids = pixelsToFsIds(pixels);
        final IntTimeSeries[] timeSeries = makePixelTimeSeries(ids);

        // Update last time series so it does not exist.
        IntTimeSeries lastTimeSeries = timeSeries[timeSeries.length - 1];
        timeSeries[timeSeries.length - 1] = new IntTimeSeries(
            lastTimeSeries.id(), lastTimeSeries.iseries(),
            lastTimeSeries.startCadence(), lastTimeSeries.endCadence(),
            lastTimeSeries.validCadences(), lastTimeSeries.originators(), false);

        // The result should therefore not include it.
        final IntTimeSeries[] filteredTimeSeries = Arrays.copyOf(timeSeries,
            timeSeries.length - 1);

        mockery.checking(new Expectations() {
            {
                one(timeSeriesReader).readTimeSeriesAsInt(ids, startCadence,
                    endCadence);
                will(returnValue(timeSeries));
            }
        });
        TimeSeriesCollator collator = new TimeSeriesCollator(pixels,
            timeSeriesReader, 1024 * 10, 1024 * 10, 0, 1);

        assertTrue(collator.hasNext());
        assertArrayEquals(filteredTimeSeries, collator.nextChunk());
        assertFalse(collator.hasNext());
    }

    /**
     * 
     * @param maxPixels
     * @param pixelsPerRow
     * @return  These pixels are generated in the same sort order as the
     * time series collator so we can easily compare them with the chunks
     * returned by the collator.
     * @throws PipelineException
     */
    private List<Pixel> generatePixels(int maxPixels, int pixelsPerRow) {
        List<Pixel> pixels = new ArrayList<Pixel>(maxPixels);
        TargetType targetType  = TargetType.LONG_CADENCE;
        
        int row = 20;
        int col = 0;
        for (int i=0; i < maxPixels; i++) {
            if ( (i % pixelsPerRow) == 0) {
                row++;
                col=0;
            }
            
            FsId id = 
                DrFsIdFactory.getSciencePixelTimeSeries(TimeSeriesType.ORIG, targetType, 2, 2, row, col++);
            pixels.add(new Pixel(row, col, id));
        }
        
        return pixels;
    }
    
    private FsId[] pixelsToFsIds(List<Pixel> pixels)  {    
        FsId[] ids = new FsId[pixels.size()];
       
        int i=0;
        for (Pixel pixel : pixels) {
            ids[i++] = pixel.getFsId();
        }
        
        return ids;
    }
    
   private IntTimeSeries[] makePixelTimeSeries(FsId[] ids) {
       int[] iseries = new int[2];
       boolean[] gaps = new boolean[2];
       
       List<IntTimeSeries> rv = new ArrayList<IntTimeSeries>(ids.length);
       for (FsId id : ids) {
           IntTimeSeries its = new IntTimeSeries(id, iseries, startCadence, endCadence, gaps, 7);
           rv.add(its);
       }
       
       return rv.toArray(new IntTimeSeries[0]);
       
   }
}
