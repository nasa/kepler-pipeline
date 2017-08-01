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

package gov.nasa.kepler.fs.server.xfiles;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static gov.nasa.kepler.fs.FileStoreConstants.*;

import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesTestUtil;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.server.AcquiredPermits;
import gov.nasa.kepler.fs.server.FileTransactionManagerInterface;
import gov.nasa.kepler.fs.server.FixedAcquiredPermits;
import gov.nasa.kepler.fs.server.SingleAcquiredPermit;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.TimeSeriesCarrier;
import gov.nasa.kepler.fs.server.TransactionalBackend;
import gov.nasa.kepler.fs.server.UnboundedThrottle;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;

/**
 * @author Sean McCauliff
 * 
 */
public class OfflineExtractorTest {

    private final File dataDir = 
        new File(Filenames.BUILD_TEST, "OfflineExtractorTest.test");
    
    private final FsId intId = new FsId("/off-line-test/1");
    private final FsId floatId = new FsId("/off-line-test/2");
    private final FsId blobId = new FsId("/off-line-test/3");
    private final FsId cosmicRayId = new FsId("/cosmic/thing");
    
    private final int[] intData = new int[1024 * 16];
    private final float[] floatData = new float[intData.length];
    private final byte[] blobData = new byte[1024 * 1024];
    private final long blobOrigin = 5555555555L;
    
    private IntTimeSeries its;
    private FloatTimeSeries fts;
    private FloatMjdTimeSeries crs;
    
    private TransactionalBackend backend;
    private final ThrottleInterface throttle = UnboundedThrottle.newInstance();

    /**
     * Populates a file store file system with a time series of each kind, a
     * cosmic ray series and a blob.
     * 
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        dataDir.mkdirs();

        for (int i = 0; i < intData.length; i++) {
            intData[i] = i + 1;
        }

        for (int i = 0; i < floatData.length; i++) {
            floatData[i] = (float) ((i + 1) * Math.PI);
        }

        for (int i = 0; i < blobData.length; i++) {
            blobData[i] = (byte) i;
            if (blobData[i] == 0) {
                blobData[i] = (byte) 42;
            }
        }
        
        Configuration config = 
            ConfigurationOverrideHandler
        		.wrappedConfiguration(ImmutableMap.of(FS_DATA_DIR_PROPERTY, dataDir.getAbsolutePath()));

        backend = new TransactionalBackend.Factory().instance(config, new FileTransactionManager.Factory());
        
        SimpleInterval valid = new SimpleInterval(7, 7 + intData.length - 1);
        TaggedInterval origin = new TaggedInterval(7, valid.end(),
            Long.MAX_VALUE);
        its = new IntTimeSeries(intId, intData, (int) valid.start(),
            (int) valid.end(), Collections.singletonList(valid),
            Collections.singletonList(origin), true);

        fts = new FloatTimeSeries(floatId, floatData, (int) valid.start(),
            (int) valid.end(), Collections.singletonList(valid),
            Collections.singletonList(origin), true);

        double[] mjd = new double[]{7.0, 8.0};
        float[] values = new float[] {888.0f, 999.0f};
        long[] originators = new long[] {666L, 668L};
        
        crs = new FloatMjdTimeSeries(this.cosmicRayId, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
        
        FileTransactionManagerInterface ftm = backend.fileTransactionManager();
        PersistableXid xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(), throttle);
        AcquiredPermits permits = new FixedAcquiredPermits(3);
        
        TimeSeriesCarrier itsCarrier = TimeSeriesTestUtil.toTimeSeriesCarrier(its);
        TimeSeriesCarrier ftsCarrier = TimeSeriesTestUtil.toTimeSeriesCarrier(fts);
        backend.writeTimeSeries(Arrays.asList( new TimeSeriesCarrier[] {itsCarrier, ftsCarrier }), true, xid, permits);
        backend.writeMjdTimeSeries(Collections.singletonList(crs), true, xid, permits);
        WritableBlob writableBlob = backend.writeBlob(blobId, xid, blobOrigin);
        writableBlob.fileChannel.write(ByteBuffer.wrap(blobData));
        writableBlob.close();
        ftm.prepareLocal(xid, throttle);
        ftm.commitLocal(xid, throttle);

    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        backend.cleanFileStore();
    }

    @Test
    public void offlineExtractTimeSeries() throws Exception {
        OfflineExtractor extractor = new OfflineExtractor(dataDir);
        TimeSeries readSeries = extractor.readTimeSeries(intId);
        assertEquals(its, readSeries);

        readSeries = extractor.readTimeSeries(floatId);
        assertEquals(fts, readSeries);
    }

    @Test
    public void offlineExtractBlob() throws Exception {
        OfflineExtractor extractor = new OfflineExtractor(dataDir);
        StreamedBlobResult sBlob = extractor.readBlob(blobId);
        assertEquals(blobOrigin, sBlob.originator());
        DataInputStream din = new DataInputStream(sBlob.stream());
        byte[] readData = new byte[blobData.length];
        din.readFully(readData);
        assertEquals(-1, din.read());
        assertTrue(Arrays.equals(blobData, readData));
        din.close();

    }
    
    @Test
    public void offlineExtractCosmicRay() throws Exception {
        OfflineExtractor extractor = new OfflineExtractor(dataDir);
        FloatMjdTimeSeries extractedSeries = 
            extractor.readCosmicRaySeries(cosmicRayId);
        
        FloatMjdTimeSeries expected = 
            new FloatMjdTimeSeries(crs.id(), -Double.MAX_VALUE, Double.MAX_VALUE, 
                crs.mjd(), crs.values(), crs.originators(), true);
        assertEquals(expected, extractedSeries);
    }

    @Test
    public void offlineLs() throws Exception {
        OfflineExtractor extractor = new OfflineExtractor(dataDir);
        Set<FsId> allIds = extractor.ls(dataDir);
        Set<FsId> correct = new HashSet<FsId>();
        correct.add(floatId);
        correct.add(intId);
        correct.add(blobId);
        correct.add(cosmicRayId);
        assertEquals(correct, allIds);
    }

}