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

import static gov.nasa.kepler.fs.FileStoreConstants.BLOB_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.MJD_TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.TIME_SERIES_DIR_NAME;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.kepler.fs.server.journal.ModifiedFsIdJournal;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;

import javax.transaction.xa.Xid;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class XFilesCheckerTest {

    private static final File testDir = new File(Filenames.BUILD_TEST, "XFilesCheckerTest.test");
    private static final File tsDir = new File(testDir, TIME_SERIES_DIR_NAME);
    private static final File blobDir = new File(testDir, BLOB_DIR_NAME);
    private static final File crDir = new File(testDir, MJD_TIME_SERIES_DIR_NAME);
    
    private FsIdFileSystemLocator fileSystemLocator;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testDir.mkdirs();
        blobDir.mkdirs();
        tsDir.mkdirs();
        crDir.mkdirs();
        
        File fsConfig = new File(testDir, "fileSystemConfig.xml");
        fileSystemLocator = new UserConfigurableFsIdFileSystemLocator(fsConfig, testDir.getCanonicalPath());
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testDir);
    }

    /**
     * You must inspect the log of this test in order to be sure it worked
     * correctly. It should report an error about a missing directory.
     * 
     * @throws Exception
     */

    @Test
    public void checkBlobDirectoryHashStructure() throws Exception {
        checkDirectoryHashStructure(new DirectoryHashFactory(fileSystemLocator,blobDir, 1000, 10), blobDir);
    }

    private void checkDirectoryHashStructure(DirectoryHashFactory dirHashFactory, File typeDir)
        throws Exception {
        FsId id0 = new FsId("/test-level0/test-level1/0");
        FsId id1 = new FsId("/test-level0/1");
        FsId id2 = new FsId("/test-something/2");
        FsId deleteMe = new FsId("/test-level0/empty/3");

        dirHashFactory.findDirHash(id0,  true, true)
            .idToFile(id0.name())
            .createNewFile();
        dirHashFactory.findDirHash(id1,  true, true)
            .idToFile(id1.name())
            .createNewFile();
        dirHashFactory.findDirHash(id2,  true, true)
            .idToFile(id2.name())
            .createNewFile();
        dirHashFactory.findDirHash(deleteMe,  true, true);

        File corruptDir = new File(typeDir + "/test-level0/hd-0/hd-0");
        assertTrue(corruptDir.delete());
        XFilesChecker xchecker = new XFilesChecker(testDir);
        xchecker.checkDirectoryHashes(true);

        assertFalse(corruptDir.exists());

        xchecker.checkDirectoryHashes(false);

        dirHashFactory = new DirectoryHashFactory(fileSystemLocator,blobDir);
        assertTrue(corruptDir.exists());
        assertTrue(dirHashFactory.findDirHash(deleteMe) == null);
    }


    @Test
    public void checkStreamFiles() throws Exception {
        FsId id0 = new FsId("/blah/blah");

        DirectoryHashFactory dirHashFactory = new DirectoryHashFactory(fileSystemLocator,blobDir,
            1000, 10);

        DirectoryHash dirHash = dirHashFactory.findDirHash(id0,  true, true);
        File targetFile = dirHash.idToFile(id0.name());
        TransactionalStreamFile xfile = 
            TransactionalStreamFile.loadFile(targetFile,id0);
        Xid xid = new FakeXid(8989, 87788);
        xfile.beginTransaction(xid, 0, new TestModifiedFsIdJournal());
        WritableBlob writableBlob = xfile.writeBlob(xid, 89);
        writableBlob.fileChannel.write(ByteBuffer.allocateDirect(1024),
            writableBlob.fileStart);
        writableBlob.close();

        XFilesChecker xChecker = new XFilesChecker(testDir);
        xChecker.checkStreamFileConsistency(false);

        assertFalse(targetFile.exists());
    }
    
    private static class TestModifiedFsIdJournal implements ModifiedFsIdJournal {

        @Override
        public void fileModified(Xid xid, FsId id) throws IOException {
            //This does nothing.
        }
        
    }

}
