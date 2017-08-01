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

package gov.nasa.kepler.fs.cli;

import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_DEFAULT;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_PROPERTY;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.File;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class CheckerTest {

    private final File testRoot = new File(Filenames.BUILD_TEST
        + "/CheckerTest.test");

    private TestSystemProvider testSystem;
    private String fsDataDir;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot.mkdirs();
        testSystem = new TestSystemProvider(testRoot);
        Configuration config = ConfigurationServiceFactory.getInstance();
        fsDataDir = config.getString(FS_DATA_DIR_PROPERTY, FS_DATA_DIR_DEFAULT);
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileStoreTestInterface fsTest = (FileStoreTestInterface) FileStoreClientFactory.getInstance();
        FileStoreClientFactory.setInstance(null);
        fsTest.cleanFileStore();
     

        FileUtil.removeAll(testRoot);
    }

    /**
     * Write some stuff into the file store, but do not commit. Recover from
     * this state with the command line tool. See if the file store starts up in
     * a consistent state. Run the directory checker to see if it removes the
     * empty directories.
     * 
     * @throws Exception
     */
    @Test
    public void testCheck() throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();

        FsId itsId = new FsId("/test/1");
        FsId blobId = new FsId("/blob/1");
        FsId crId = new FsId("/cosmic/1");
        
        fsClient.beginLocalFsTransaction();
        IntTimeSeries its = 
            new IntTimeSeries(itsId, new int[] { 999 }, 0, 0,
                                            new boolean[] { false }, 8);
        FloatMjdTimeSeries raySeries = 
            new FloatMjdTimeSeries(crId, 0.0, 1.0, new double[] { 0.5}, new float[] { 1.0f}, 8L);
        
        fsClient.writeTimeSeries(new TimeSeries[] { its });
        fsClient.writeBlob(blobId, 8, new byte[] {});
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { raySeries });
        // don't commit.

        Checker checker = new Checker(testSystem);
        checker.parse(new String[] { "-r", fsDataDir });
        checker.execute();

        assertEquals(0, testSystem.returnCode());

        //This makes the file store server forget about everything.
        File tmpDir = new File("/tmp/CheckerTest.tmp");
        FileUtil.mkdirs(tmpDir);
        FileUtil.copyFiles(fsDataDir, tmpDir.getAbsolutePath());
        ((FileStoreTestInterface)fsClient).cleanFileStore();
        FileUtil.copyFiles(tmpDir.getAbsolutePath(), fsDataDir);
        FileUtil.removeAll(tmpDir);

        //Check for erasure
        assertFalse(fsClient.blobExists(blobId));
        
        TimeSeries[] tsa = fsClient.readAllTimeSeriesAsInt(new FsId[] { itsId }, false);
        assertEquals(1, tsa.length);
        assertFalse(tsa[0].exists());
       
        FloatMjdTimeSeries[] ray_a = fsClient.readAllMjdTimeSeries(new FsId[] { crId});
        assertEquals(1, ray_a.length);
        assertFalse(ray_a[0].exists());
        

        // Fake cleaning of directories, this should only log potential changes.
        testSystem = new TestSystemProvider(this.testRoot);
        checker = new Checker(testSystem);
        checker.parse(new String[] { "-f", "-s", fsDataDir });
        checker.execute();

        assertEquals(0, testSystem.returnCode());

        File blobDir = new File(fsDataDir + File.separator
            + FileStoreConstants.BLOB_DIR_NAME + blobId.path());

        assertTrue(blobDir.exists());

        // for real clean up orphaned directories.
        testSystem = new TestSystemProvider(testRoot);
        checker = new Checker(testSystem);
        checker.parse(new String[] { "-s", fsDataDir });
        checker.execute();

        assertFalse(blobDir.exists());

    }

}
