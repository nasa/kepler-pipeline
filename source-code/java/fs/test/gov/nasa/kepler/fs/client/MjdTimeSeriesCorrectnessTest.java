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


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.server.xfiles.MjdTimeSeriesTestData;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.*;
import java.util.concurrent.atomic.AtomicReference;

import static java.util.Collections.singleton;
import static java.util.Collections.singletonList;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;


public class MjdTimeSeriesCorrectnessTest {

    private FileStoreClient fsClient;
    private final double[] mjd = new double[630];
    private final float[] values = new float[mjd.length];
    private final long[] originators = new long[mjd.length];
    
    @Before
    public void setUp() throws Exception {
        fsClient = FileStoreClientFactory.getInstance();
        fsClient.rollbackLocalFsTransactionIfActive();
        for (int i=0; i < mjd.length; i++) {
            mjd[i] = (i+1) * Math.PI;
        }
        for (int i=0; i < mjd.length; i++) {
            values[i] = ((float) Math.E) * (i+1);
        }
        for (int i=0; i < originators.length; i++) {
            originators[i] = Integer.MAX_VALUE + i;
        }
        
    }

    protected FileStoreClient createFileStoreClient() throws Exception {
        return FileStoreClientFactory.getInstance();
    }
    
    @After
    public void tearDown() throws Exception {
        ((FileStoreTestInterface)fsClient).cleanFileStore();
    }

    @Test
    public void readNonExistantMjdTimeSeries() throws Exception {
        FsId notExist = new FsId("/cosmic-ray/test/not-exist");
    
        FloatMjdTimeSeries[] series_a = 
            fsClient.readMjdTimeSeries(new FsId[] { notExist }, -Double.MIN_VALUE, Double.MAX_VALUE);
        assertEquals(1, series_a.length);
        assertEquals(false, series_a[0].exists());
        assertEquals(0, series_a[0].values().length);
        assertEquals(Double.MAX_VALUE, series_a[0].endMjd(), 0);
        assertEquals(-Double.MIN_VALUE, series_a[0].startMjd(), 0);
        assertEquals(notExist, series_a[0].id());
        assertEquals(0, series_a[0].mjd().length);
        assertEquals(0, series_a[0].originators().length);
        
    }
    
    @Test
    public void simpleMjdBatchTest() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        MjdFsIdSet idSet = new MjdFsIdSet(series.startMjd(), series.endMjd(), singleton(id1));
        List<MjdTimeSeriesBatch> batchList = 
            fsClient.readMjdTimeSeriesBatch(singletonList(idSet));
        assertEquals(1, batchList.size());
        MjdTimeSeriesBatch batch = batchList.get(0);
        assertEquals(idSet.startMjd(), batch.startMjd(), 0.0);
        assertEquals(idSet.endMjd(), batch.endMjd(), 0.0);
        assertEquals(1, batch.timeSeries().size());
        assertEquals(series, batch.timeSeries().get(series.id()));
    }
    
    @Test
    public void multiMjdBatchTest() throws Exception {
        final int nSets = 10;
        final int setSize = 20;
        final int nPoints = 512;
        
        FloatMjdTimeSeries[] timeSeries = new FloatMjdTimeSeries[nSets * setSize];
        List<MjdFsIdSet> mjdFsIdSetList = new ArrayList<MjdFsIdSet>(nSets);
        for (int seti=0; seti < nSets; seti++) {
            final double startMjd = 1.0 + seti;
            final double endMjd = 500000.0;
            Set<FsId> ids = new HashSet<FsId>(setSize);
            for (int seriesi=0; seriesi < setSize; seriesi++) {
                double[] mjd = new double[nPoints];
                float[] values = new float[nPoints];
                Arrays.fill(values, seriesi);
                for (int pointi=0; pointi < nPoints; pointi++) {
                    mjd[pointi] = startMjd + (seti * setSize) +  seriesi + pointi;
                }
                FsId id = new FsId("/set/" + seti + "/series/" + seriesi);
                FloatMjdTimeSeries series = new FloatMjdTimeSeries(id, startMjd, endMjd, mjd, values, seti);
                timeSeries[seti * setSize + seriesi] = series;
                ids.add(id);
            }
            mjdFsIdSetList.add(new MjdFsIdSet(startMjd, endMjd, ids));
        }
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(timeSeries);
        fsClient.commitLocalFsTransaction();
        
        //check that explicit transactions work.
        fsClient.beginLocalFsTransaction();
        List<MjdTimeSeriesBatch> batchList = 
                fsClient.readMjdTimeSeriesBatch(mjdFsIdSetList);
        fsClient.rollbackLocalFsTransaction();
        
        assertEquals(nSets, batchList.size());
        
        int timeSeriesIndex = 0;
        int setIndex=0;
        for (MjdTimeSeriesBatch batch : batchList) {
            MjdFsIdSet idSet = mjdFsIdSetList.get(setIndex++);
            assertEquals(idSet.startMjd(), batch.startMjd(), 0.0);
            assertEquals(idSet.endMjd(), batch.endMjd(), 0.0);
            assertEquals(idSet.ids().size(), batch.timeSeries().size());
            for (int i=0; i < idSet.ids().size(); i++) {
                assertEquals(timeSeries[timeSeriesIndex], 
                             batch.timeSeries().get(timeSeries[timeSeriesIndex].id()));
                timeSeriesIndex++;
            }
        }

    }
    
    @Test
    public void testSimpleMjdTimeSeries() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries[] readSeries = fsClient.readMjdTimeSeries(new FsId[] { id1}, mjd[0], mjd[mjd.length - 1]);
        
        assertEquals(1, readSeries.length);
        assertEquals(series, readSeries[0]);
        
        readSeries = fsClient.readMjdTimeSeries(new FsId[] { id1}, mjd[0], (mjd[1] + mjd[0])/2.0);
        assertEquals(mjd[0],readSeries[0].startMjd(), 0);
        assertEquals(1, readSeries[0].mjd().length);
        assertEquals((mjd[0] + mjd[1]) /2.0, readSeries[0].endMjd(), 0);
   
        readSeries = fsClient.readMjdTimeSeries(new FsId[] {id1},(mjd[0] + mjd[1])/2.0, mjd[1]);
        assertEquals(1, readSeries[0].mjd().length);
        assertEquals(mjd[1], readSeries[0].mjd()[0], 0);
    }
   
    @Test
    public void truncateMjdTimeSeries() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        float[] bigData = new float[1024*32];
        double[] bigMjd = new double[bigData.length];
        long[] bigOriginators = new long[bigData.length];
        for (int i=0; i < bigMjd.length; i++) {
            bigMjd[i] = 1 + i;
        }
        
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id1, bigMjd[0], bigMjd[bigMjd.length - 1], bigMjd, bigData, bigOriginators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries truncateSeries = 
            new FloatMjdTimeSeries(id1, bigMjd[0], bigMjd[bigMjd.length - 1],
                new double[0], new float[0], new long[0], true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { truncateSeries });
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries[] readMts = 
            fsClient.readAllMjdTimeSeries(new FsId[] { id1 });
        assertEquals(0, readMts[0].mjd().length);
        assertEquals(true, readMts[0].exists());
    }
    
    @Test
    public void readMjdTimeSeriesBeforeCommit() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        
        FloatMjdTimeSeries[] readSeries = fsClient.readMjdTimeSeries(new FsId[] {id1}, mjd[0], mjd[mjd.length -1 ]);
        assertEquals(1, readSeries.length);
        assertEquals(series, readSeries[0]);
        
        fsClient.rollbackLocalFsTransaction();
        
        readSeries = fsClient.readMjdTimeSeries(new FsId[] { id1}, -Double.MIN_VALUE, Double.MAX_VALUE);
        assertEquals(1, readSeries.length);
        assertFalse(readSeries[0].exists());
        
    }
    
    @Test
    public void rollbackMjdTimeSeriesTest() throws Exception {
        FsId id1 = new FsId("/anc/blah-blah");
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series});
        fsClient.commitLocalFsTransaction();
        
        float[] newValues = new float[values.length];
        Arrays.fill(newValues, 7.3f);
        long[] newOriginators = new long[originators.length];
        Arrays.fill(newOriginators, 8899L);
        FloatMjdTimeSeries intermediateSeries =
            new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, newValues, newOriginators, true);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { intermediateSeries});
        fsClient.rollbackLocalFsTransaction();
        
        FloatMjdTimeSeries[] readMts = 
            fsClient.readMjdTimeSeries(new FsId[] {id1}, mjd[0], mjd[mjd.length - 1]);
        assertEquals(series, readMts[0]);
    }
    
    /**
     *    nnnnnnnnnnnnnn
     *              |
     *              v
     *    oooooooooooooo
     * @throws Exception
     */
    @Test
    public void overwriteMjdTimeSeries() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        fsClient.beginLocalFsTransaction();
        double[] overwriteMjd = new double[] { mjd[0] -.05 };
        double overwriteStart = mjd[0] - .1;
        double overwriteEnd = mjd[mjd.length - 1] + .1;
        FloatMjdTimeSeries overwriteSeries = 
            new FloatMjdTimeSeries(id1, overwriteStart, overwriteEnd, overwriteMjd, new float[] { 2.4F}, new long[] { 333344L }, true);
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] {overwriteSeries});
        fsClient.commitLocalFsTransaction();
        
        
        FloatMjdTimeSeries[] readSeries= fsClient.readMjdTimeSeries(new FsId[] {id1} , overwriteStart, overwriteEnd);
        assertEquals(overwriteSeries, readSeries[0]);
    }
    
    /**
     *          nnnnnnnnnnnnn
     *  ooo                               ooo
     * @throws Exception
     */
    @Test
    public void insertIntoMjdTimeSeries() throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        double insertStart = mjd[mjd.length / 2] + .001;
        double insertEnd = mjd[ (mjd.length / 2) + 1] - .001;
        double[] insertMjd = new double[mjd.length];
        float[] insertCorrections = new float[mjd.length];
        for (int i=0; i < insertMjd.length; i++) {
            insertMjd[i] = insertStart + .00000001 * i;
            insertCorrections[i] = 2.81333f + .000000002f * i;
        }
        long insertOrigin = 555555L;
        FloatMjdTimeSeries insertSeries = 
            new FloatMjdTimeSeries(id1, insertStart, insertEnd, insertMjd, insertCorrections, insertOrigin);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { insertSeries });
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries[] readSeries = fsClient.readMjdTimeSeries(new FsId[] { id1} , mjd[0], mjd[mjd.length - 1]);
        assertEquals(1, readSeries.length);
        FloatMjdTimeSeries s = readSeries[0];
        assertTrue( s.exists());

        double[] combinedMjd = new double[mjd.length * 2];
        float[] combinedValues = new float[mjd.length * 2 ];
        long[] combinedOriginators = new long[mjd.length * 2];
        int combinedIndex = 0;
        int originalIndex = 0;
        for (; combinedIndex < (mjd.length / 2 + 1); combinedIndex++, originalIndex++) {
            combinedMjd[combinedIndex] = mjd[originalIndex];
            combinedValues[combinedIndex] = values[originalIndex];
            combinedOriginators[combinedIndex] = originators[originalIndex];
        }
        
        for (int i=0; i < mjd.length; i++,combinedIndex++) {
            combinedMjd[combinedIndex] = insertMjd[i];
            combinedOriginators[combinedIndex] = insertOrigin;
            combinedValues[combinedIndex] = insertCorrections[i];
        }
        
        for (; originalIndex < mjd.length; originalIndex++, combinedIndex++) {
            combinedMjd[combinedIndex] = mjd[originalIndex];
            combinedValues[combinedIndex] = values[originalIndex];
            combinedOriginators[combinedIndex] = originators[originalIndex];
        }
        
        FloatMjdTimeSeries combinedSeries = 
            new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], combinedMjd, combinedValues, combinedOriginators, true);
        
        assertEquals(combinedSeries, s);
    }
    
    /**          
     *                          nnnnnnnnnnnnnnnnnnn
     * oooooooooooo
     * @throws Exception
     */
    @Test
    public void appendToMjdTimeSeries() throws Exception {
        prefixOrAppend(true);
    }
    
    /**
     *   nnnnnnnnn
     *                      ooooooooooooo
     * @throws Exception
     */
    @Test
    public void prefixMjdTimeSeries() throws Exception {
        prefixOrAppend(false);
    }
    
    private void prefixOrAppend(boolean append) throws Exception {
        FsId id1 = new FsId("/cosmic-ray/test/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id1, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        
        double mjdStart = 
            (append) ? mjd[mjd.length - 1] + 1.0 : mjd[0] - 10000.0;
        double[] appendMjd = new double[mjd.length];
        for (int i=0; i < mjd.length; i++) {
            appendMjd[i] = mjd[i] + mjdStart;
        }
        float[] appendValues = new float[values.length];
        for (int i=0; i < values.length; i++) {
            appendValues[i] = values[i] + 1.0f;
        }
        
        FloatMjdTimeSeries endSeries = 
            new FloatMjdTimeSeries(id1, appendMjd[0], appendMjd[appendMjd.length - 1], appendMjd, appendValues, 777L);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { endSeries });
        fsClient.commitLocalFsTransaction();
        
        double[] combinedMjd = new double[mjd.length * 2];
        double[] firstMjd = (append) ? mjd : appendMjd;
        double[] secondMjd = (append) ? appendMjd : mjd;
        System.arraycopy(firstMjd, 0, combinedMjd, 0, mjd.length);
        System.arraycopy(secondMjd, 0, combinedMjd, mjd.length, mjd.length);
        
        float[] combinedValues = new float[mjd.length * 2];
        float[] firstValues = (append) ? values : appendValues;
        float[] secondValues=  (append) ? appendValues : values;
        System.arraycopy(firstValues, 0, combinedValues, 0, values.length);
        System.arraycopy(secondValues, 0, combinedValues, values.length, values.length);
        
        long[] combinedOriginators = new long[originators.length * 2];
        if (append) {
            System.arraycopy(originators, 0, combinedOriginators, 0, originators.length);
            Arrays.fill(combinedOriginators, originators.length, combinedOriginators.length, 777L);
        } else {
            Arrays.fill(combinedOriginators, 0, originators.length, 777L);
            System.arraycopy(originators, 0, combinedOriginators, originators.length, originators.length);
        }
        
        
        FloatMjdTimeSeries combinedSeries = 
            new FloatMjdTimeSeries(id1, combinedMjd[0], combinedMjd[ combinedMjd.length - 1], combinedMjd, combinedValues, combinedOriginators, true);
        FloatMjdTimeSeries[] readSeries_a =  fsClient.readMjdTimeSeries(new FsId[] { id1 }, combinedMjd[0],  combinedMjd[combinedMjd.length - 1]);
        assertEquals(combinedSeries, readSeries_a[0]);
    }
     
    @Test
    public void testListMjdTimeSeries() throws Exception {
        FsId id1 = new FsId("/root-1/1");
        FsId id2 = new FsId("/root-1/2");
        FsId id3 = new FsId("/root-1/root-1-1/1");
        
        FsId[] ids = new FsId[] { id1, id2, id3 };
        FloatMjdTimeSeries[] series_a = new FloatMjdTimeSeries[ids.length];
        for (int i=0; i < series_a.length; i++) {
            series_a[i] = new FloatMjdTimeSeries(ids[i], -Double.MIN_VALUE, Double.MAX_VALUE, mjd, values, originators, true);
        }
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(series_a);
        fsClient.commitLocalFsTransaction();
        
        Set<FsId> twoIds = fsClient.listMjdTimeSeries(new FsId("/root-1/_"));
        assertTrue(twoIds.contains(id1));
        assertTrue(twoIds.contains(id2));
        assertEquals(2, twoIds.size());
        
        Set<FsId> oneId = fsClient.listMjdTimeSeries(new FsId("/root-1/root-1-1/_"));
        assertTrue(oneId.contains(id3));
        assertEquals(1, oneId.size());
        
        Set<FsId> emptySet = fsClient.listMjdTimeSeries(new FsId("/test-1/test-1-2/_"));
        assertTrue(emptySet.isEmpty());
    }
    
    @Test
    public void testReadAllMjdTimeSeries() throws Exception  {
        FsId id1 = new FsId("/root-1/1");
        FsId id2 = new FsId("/root-1/2");
        FsId id3 = new FsId("/root-1/root-1-1/1");
        
        FsId[] ids = new FsId[] { id1, id2, id3 };
        FloatMjdTimeSeries[] series_a = new FloatMjdTimeSeries[ids.length];
        for (int i=0; i < series_a.length; i++) {
            double[] differentMjd = Arrays.copyOf(mjd, mjd.length);
            for (int mi=0; mi < differentMjd.length; mi++) {
                differentMjd[mi] += i;
            }
            series_a[i] = 
                new FloatMjdTimeSeries(ids[i], differentMjd[0], differentMjd[differentMjd.length - 1],
                    differentMjd, values, originators, true);
        }
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(series_a);
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries[] readSeries = fsClient.readAllMjdTimeSeries(ids);
        assertEquals(series_a.length, readSeries.length);
        for (int i=0; i < series_a.length; i++) {
            assertEquals(series_a[i].id(), readSeries[i].id());
            assertEquals(series_a[i], readSeries[i]);
        }
    }
    
    @Test
    public void multipleWritesInSingleTransaction() throws Exception {
        FsId id1 = new FsId("/series/id1");
        double[] mjd1 = new double[] { -1.0, 1.0, 2.0};
        float[] values1 = new float[] {-1.0f, 1.0f, 2.0f};
        FloatMjdTimeSeries mts1 = 
            new FloatMjdTimeSeries(id1, -2.0, 5.0, mjd1, values1, 42L);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { mts1});
        
        double[] mjd2 = new double[] { 2.0, 3.0, 4.0};
        float[] values2 = new float[] { 2.0f, 3.0f, 4.0f};
        FloatMjdTimeSeries mts2 = 
            new FloatMjdTimeSeries(id1, 1.0, 5.0, mjd2, values2, Long.MAX_VALUE);
        
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { mts2} );
        
        double[] expectedMjd = new double[] { -1.0, 2.0, 3.0, 4.0};
        float[] expectedValues = new float[] { -1.0f, 2.0f, 3.0f, 4.0f};
        long[] expectedOriginators  = new long[] {42L, Long.MAX_VALUE, Long.MAX_VALUE, Long.MAX_VALUE};
        FloatMjdTimeSeries expectedSeries = 
            new FloatMjdTimeSeries(id1, -1.0, 5.0, 
                expectedMjd, expectedValues ,expectedOriginators, true);
        FloatMjdTimeSeries readSeries = 
            fsClient.readMjdTimeSeries(new FsId[] { id1 }, -1.0, 5.0)[0];
        assertEquals(expectedSeries, readSeries);
        
        fsClient.commitLocalFsTransaction();
        
        readSeries = fsClient.readMjdTimeSeries(new FsId[] { id1 }, -1.0, 5.0)[0];
        
        assertEquals(expectedSeries, readSeries);
    }
    
    @Test
    public void writeLongMjdTimeSeries() throws Exception {
        Random rand = new Random(4223555L);
        double[] mjd = new double[438];
        for (int i=0; i < mjd.length; i++) {
            mjd[i] = Math.PI * ( i + 1);
        }
        float[] values = new float[mjd.length];
        for (int i=0; i < values.length; i++) {
            values[i] = rand.nextFloat();
        }
        
        FsId id = new FsId("/big-one/1");
        FloatMjdTimeSeries series = new FloatMjdTimeSeries(id, mjd[0], mjd[mjd.length - 1], mjd, values, 55L);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series});
        fsClient.commitLocalFsTransaction();
        
        FloatMjdTimeSeries readSeries = 
            fsClient.readMjdTimeSeries(new FsId[] { id} , mjd[0], mjd[mjd.length - 1])[0];
        assertEquals(series, readSeries);
        
        fsClient.beginLocalFsTransaction();
        double[] mjd2 = new double[1];
        mjd2[0] = mjd[mjd.length / 2];
        float[] values2 = new float[] { 42.0f };
        FloatMjdTimeSeries series2 = 
            new FloatMjdTimeSeries(id, mjd2[0], mjd2[0], mjd2, values2, 666L);
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series2 });
        
        
        long[] expectedOriginators = new long[mjd.length];
        Arrays.fill(expectedOriginators, 55L);
        expectedOriginators[mjd.length / 2] = 666L;
        values[mjd.length / 2] = 42.0f;
        
        readSeries = fsClient.readMjdTimeSeries(new FsId[] { id} , mjd[0], mjd[mjd.length - 1])[0];
        
        assertTrue(Arrays.equals(mjd, readSeries.mjd()));
        assertTrue(Arrays.equals(values, readSeries.values()));
        assertTrue(Arrays.equals(expectedOriginators, readSeries.originators()));      
        
        fsClient.commitLocalFsTransaction();

        readSeries = fsClient.readMjdTimeSeries(new FsId[] { id} , mjd[0], mjd[mjd.length - 1])[0];
        
        assertTrue(Arrays.equals(mjd, readSeries.mjd()));
        assertTrue(Arrays.equals(values, readSeries.values()));
        assertTrue(Arrays.equals(expectedOriginators, readSeries.originators()));
        
        
    }
    
    /**
     *      2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
     *               |
     *               v
     *     P P P P P P P P P P P P P P P
     */
    @Test
    public void interleavedWhenOverwriteIsFalse() throws Exception {
    	FsId id = new FsId("/test/overwrite-is-false/id1");
    	MjdTimeSeriesTestData testData = new MjdTimeSeriesTestData(id);
    	
    	fsClient.beginLocalFsTransaction();
    	fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { testData.series }, false);
    	fsClient.commitLocalFsTransaction();
    	
    	fsClient.beginLocalFsTransaction();
    	fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] {testData.middle}, false);
    	fsClient.commitLocalFsTransaction();
    	
    	FloatMjdTimeSeries[] mts = 
    		fsClient.readMjdTimeSeries(new FsId[] { id }, testData.combinedSeries.startMjd(), testData.combinedSeries.endMjd());
    	ReflectionEquals reflectionEquals = new ReflectionEquals();
    	reflectionEquals.assertEquals(testData.combinedSeries, mts[0]);
	}
    
    @Test
    public void concurrentWrite() throws Exception {
        for (int i=0; i < 2; i++) {
            concurrentWrite(i);
        }
    }
    
    private void concurrentWrite(int i) throws Exception {
        FsId id = new FsId("/concurrent-write/id" + i);
        final MjdTimeSeriesTestData testData = new MjdTimeSeriesTestData(id);
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { testData.series }, false);
        
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        
        Runnable r = new Runnable() {
            public void run() {
                try {
                    fsClient.disassociateThread();
                    fsClient.beginLocalFsTransaction();
                    fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { testData.middle }, false);
                    fsClient.commitLocalFsTransaction();
                } catch (Exception e) {
                    error.set(e);
                }
            }
        };
        
        Thread t = new Thread(r);
        t.start();
        t.join();
        assertEquals(null, error.get());
        
        FloatMjdTimeSeries[] mts = 
            fsClient.readMjdTimeSeries(new FsId[] { id }, testData.combinedSeries.startMjd(), testData.combinedSeries.endMjd());
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(testData.combinedSeries, mts[0]);
        
        fsClient.commitLocalFsTransaction();
        mts = 
            fsClient.readMjdTimeSeries(new FsId[] { id }, testData.combinedSeries.startMjd(), testData.combinedSeries.endMjd());
        reflectionEquals.assertEquals(testData.combinedSeries, mts[0]);
    }
    
    
    /**
     * Explicitly delete a time series.
     * 
     * @throws Exception
     */
    @Test
    public void explictDelete() throws Exception {
        FsId id = new FsId("/delete-test/1");
        
        try {
            fsClient.deleteMjdTimeSeries(new FsId[] { id});
            assertTrue(false); //should not reach here/
        } catch (FileStoreException fsx) {
            //ok
        }
        
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteMjdTimeSeries(new FsId[] { id} );
        fsClient.rollbackLocalFsTransaction();
        
        Set<FsId> existingIds = 
            fsClient.queryIds2(QueryEvaluator.DataType.MjdTimeSeries + "@" + id.toString());
        assertTrue(existingIds.contains(id));
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteMjdTimeSeries(new FsId[] { id });
        fsClient.commitLocalFsTransaction();
        
        existingIds = 
            fsClient.queryIds2(QueryEvaluator.DataType.MjdTimeSeries + "@" + id.toString());
        assertFalse(existingIds.contains(id));
    }
    
    /**
     * Tests the simple method to read mjd time series.
     * 
     * @throws Exception
     */
    @Test
    public void simpleReadMjdTimeSeries() throws Exception {
        FsId id = new FsId("/simple/mjd");
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series } );
        fsClient.commitLocalFsTransaction();
        
        Map<FsId, FloatMjdTimeSeries> rv = 
            fsClient.readMjdTimeSeries(singleton(id), mjd[0], mjd[mjd.length - 1]);
        assertEquals(1, rv.size());
        assertEquals(series, rv.get(id));
        
    }

}
