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

import static org.junit.Assert.*;

import java.io.File;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesTestUtil;
import gov.nasa.kepler.fs.server.AcquiredPermits;
import gov.nasa.kepler.fs.server.FixedAcquiredPermits;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.TimeSeriesCarrier;
import gov.nasa.kepler.fs.server.TransactionalBackend;
import gov.nasa.kepler.fs.server.UnboundedThrottle;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocationFactory;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.Filenames;

import static gov.nasa.kepler.fs.FileStoreConstants.*;

/**
 * Test that the reads are scheduled correctly.
 * 
 * @author Sean McCauliff
 *
 */
public class ScheduledReadTest {
    
    private TransactionalBackend transactionalBackend;
    private final File  dataDir = 
        new File(Filenames.BUILD_TEST, "ScheduledReadTest");
    private final static String FS_ID_PREFIX = "/ScheduledReadTest/";
    private final ThrottleInterface throttle = UnboundedThrottle.newInstance();
    
    @Before
    public void setup() {
        Configuration config = ConfigurationOverrideHandler.wrappedConfiguration(
            ImmutableMap.of(FS_DATA_DIR_PROPERTY, dataDir.getAbsolutePath()));
        FileTransactionManager.Factory ftmFactory = new FileTransactionManager.Factory();
        transactionalBackend = new TransactionalBackend.Factory().instance(config, ftmFactory);
    }
    
    @After
    public void cleanUp() throws Exception {
        transactionalBackend.cleanFileStore();
    }
    
    @Test
    public void testScheduleForReadTimeSeries() throws Exception {
        
        final int nSeries = 128;
        writeTimeSeries(nSeries);
        
        Xid xid = 
            transactionalBackend.fileTransactionManager().beginLocalTransaction(InetAddress.getLocalHost(), throttle);
        
        FsIdLocationFactory locationFactory = 
        transactionalBackend.fileTransactionManager().locationFactory(xid, false);
        
        
        List<FsIdOrder> fsIdOrder = new ArrayList<FsIdOrder>();
        for (int i=0; i < nSeries; i++) {
            final int finali = i;
            final FsId finalId = new FsId(FS_ID_PREFIX, Integer.toString(finali));
            fsIdOrder.add(new FsIdOrder() {
                
                @Override
                public int originalOrder() {
                    return finali;
                }
                
                @Override
                public FsId id() {
                    return finalId;
                }
            });
            
        }
        
        List<FsIdLocation> idLocations =locationFactory.locationFor(fsIdOrder);
        for (FsIdLocation idLoc : idLocations) {
            assertTrue(idLoc.exists());
            assertTrue(idLoc.fileLocation() >= 0);
            //System.out.println(idLoc);
        }
        
        
    }
    
    private void writeTimeSeries(int nSeries) throws Exception {
        int[] idata = new int[1440];
        List<SimpleInterval> valid = 
            Collections.singletonList(new SimpleInterval(0, idata.length -1 ));
        List<TaggedInterval> origin = 
            Collections.singletonList(new TaggedInterval(0, idata.length - 1, 893249838L));
        Arrays.fill(idata, 55);
        List<TimeSeriesCarrier> ts = new ArrayList<TimeSeriesCarrier>();
        for (int i=0; i < nSeries; i++) {
            IntTimeSeries its = new IntTimeSeries(new FsId( "/ScheduledReadTest/"+ i),
                idata, 0, idata.length - 1, valid, origin);
            TimeSeriesCarrier carrier = TimeSeriesTestUtil.toTimeSeriesCarrier(its);
            ts.add(carrier);
        }

        Xid xid = 
            transactionalBackend.fileTransactionManager().beginLocalTransaction(InetAddress.getLocalHost(), throttle);
        AcquiredPermits permits = new FixedAcquiredPermits(3);
        transactionalBackend.writeTimeSeries(ts, true, xid, permits);
        transactionalBackend.fileTransactionManager().prepareLocal(xid, throttle);
        
        transactionalBackend.fileTransactionManager().commitLocal(xid, throttle);

    }
}
