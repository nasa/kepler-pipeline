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

package gov.nasa.kepler.fs.server;

import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_PROPERTY;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.xfiles.FileTransactionManager;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.util.Arrays;

import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author smccauliff
 * 
 */
public class TimeSeriesBackendPackageTest {

    private File rootDir;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        rootDir = new File(Filenames.BUILD_TEST, "TimeSeriesBackendTest.test");
        if (!rootDir.mkdirs() && !rootDir.exists()) {
            throw new IllegalArgumentException("Failed to make test directory \"" + rootDir + "\".");
        }
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        
  //      FileUtil.removeAll(rootDir);
    }

    /**
     * Checks that a file store can be stopped and restarted and it can retain
     * all the data that was stored into it.
     * 
     */
    @Test
    public void recoverHashInfo() throws Exception {
        Configuration config = ConfigurationServiceFactory.getInstance();
        ThrottleInterface throttle = UnboundedThrottle.newInstance();
        config.setProperty(FS_DATA_DIR_PROPERTY, rootDir.getAbsolutePath());
        FileTransactionManager.Factory ftmFactory = new FileTransactionManager.Factory();
        TransactionalBackend backend = new TransactionalBackend(config, ftmFactory);
        Xid xid = backend.fileTransactionManager().beginLocalTransaction(
            InetAddress.getLocalHost(), throttle);
        FsId id = new FsId("/TimeSeriesBackendPackageTest/id1");
        byte[] data = new byte[1024];
        Arrays.fill(data, (byte) 42);
        WritableBlob blob = backend.writeBlob(id, xid, 444);
        blob.fileChannel.write(ByteBuffer.wrap(data));
        blob.close();
        backend.fileTransactionManager().prepareLocal(xid, throttle);
        backend.fileTransactionManager().commitLocal(xid, throttle);
        TransactionalBackend newBackend = new TransactionalBackend(config, new FileTransactionManager.Factory());
        xid = newBackend.fileTransactionManager().beginLocalTransaction(
            InetAddress.getLocalHost(), throttle);
        ReadableBlob rblob = newBackend.readBlob(id, xid);
        ByteBuffer readBuffer = ByteBuffer.allocate(data.length);
        rblob.fileChannel.read(readBuffer);
        rblob.close();
        readBuffer.position(0);
        newBackend.fileTransactionManager().rollback(xid, throttle);
        newBackend.cleanFileStore();
        assertTrue("blobs must be equal", Arrays.equals(data,
            readBuffer.array()));

    }

}
