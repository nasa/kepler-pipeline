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
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.io.DataInputStream;


import static gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.ConcurrentModificationException;

import junit.framework.AssertionFailedError;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class BlobCorrectnessTest {

    protected static Configuration config = null;
    private FileStoreClient fsClient;
    private  final File testDataDir = new File(Filenames.BUILD_TEST, "/BlobCorrectnessTest.test");

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

    protected FileStoreClient constructGenericFileClient()
        {
        return FileStoreClientFactory.getInstance(config);
    }

    @Before
    public void setUp() throws Exception {
        fsClient = constructGenericFileClient();
        if (testDataDir.exists()) {
        	FileUtil.removeAll(testDataDir);
        }
        if (!testDataDir.mkdirs()) {
            throw new IllegalStateException("Failed to make directory \"" + testDataDir + "\".");
        }
    }

    @After
    public void tearDown() throws Exception {
        if (fsClient != null) {
            ((FileStoreTestInterface) fsClient).cleanFileStore();
        }
        FileUtil.removeAll(testDataDir);
    }

    @Test
    public void writeFile() throws Exception {
        final int DATA_SIZE = 1024 * 1024 * 1;

        FsId id = new FsId("/file-transfer/1");
        long origin = Integer.MAX_VALUE * 10L;

        File file = new File(testDataDir, "testFile");
        BufferedOutputStream bout = new BufferedOutputStream(
            new FileOutputStream(file));
        for (int i = 0; i < DATA_SIZE; i++) {
            bout.write(i + 1);
        }
        bout.close();

        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, origin, file);
        fsClient.commitLocalFsTransaction();

        File destFile = new File(testDataDir, "dest");
        long readOrigin = fsClient.readBlob(id, destFile);
        assertEquals(origin, readOrigin);
        assertEquals(file.length(), destFile.length());
        BufferedInputStream bin = new BufferedInputStream(new FileInputStream(
            destFile));
        try {
            for (int i = 0; i < DATA_SIZE; i++) {
                byte actual = (byte) bin.read();
                byte test = (byte) ((i + 1) & 0xff);
                if (actual != test) {
                    throw new AssertionFailedError("bytes in file differ");
                }
            }
        } finally {
            bin.close();
        }
    }

    @Test
    public void writeStream() throws Exception {
        FsId id = new FsId("/streamed/1");
        long origin = Integer.MAX_VALUE + 668L;
        fsClient.beginLocalFsTransaction();
        OutputStream out = fsClient.writeBlob(id, origin);
        byte[] data = new byte[1024 * 8];
        for (int i = 0; i < data.length; i++) {
            data[i] = (byte) (i + 1);
        }

        final long DATA_MULTIPLIER = 1024;
        for (int i=0; i < DATA_MULTIPLIER; i++) {
            out.write(data);
        }
        out.close();
        fsClient.commitLocalFsTransaction();

        StreamedBlobResult blobResult = fsClient.readBlobAsStream(id);
        assertEquals(origin, blobResult.originator());
        assertEquals(data.length * DATA_MULTIPLIER, blobResult.size());
        byte[] readIn = new byte[(int) (data.length * DATA_MULTIPLIER)];
        DataInputStream din = new DataInputStream(blobResult.stream());
        try {
            din.readFully(readIn);
            assertEquals(-1, din.read());
        } finally {
            blobResult.stream().close();
            din.close();
        }

        for (int i=0; i < DATA_MULTIPLIER; i++) {
            assertTrue("Data arrays must be equals.", 
                ArrayUtils.arrayEquals(data, 0, readIn, i * data.length, data.length));
        }
        
    }

    @Test
    public void writeZeroLengthStream() throws Exception {
        FsId id = new FsId("/streamed/1");
        fsClient.beginLocalFsTransaction();
        OutputStream out = fsClient.writeBlob(id, 668);
        out.close();
        fsClient.commitLocalFsTransaction();
        StreamedBlobResult blobResult = fsClient.readBlobAsStream(id);
        assertEquals(668L, blobResult.originator());
        assertEquals(-1, blobResult.stream().read());
        blobResult.stream().close();

    }
    
    @Test
    public void readNonExistantStream() throws Exception {
        FsId id = new FsId("/streamed/not/exist");
        StreamedBlobResult blobResult = null;
        boolean ok = false;
        try {
            blobResult = fsClient.readBlobAsStream(id);
        } catch (FileStoreIdNotFoundException kjsdkfj) {
            ok = true;
        } finally {
            if (blobResult != null) {
                blobResult.stream().close();
            }
        }
        assertTrue(ok);
    }
    
    /**
     * If this tests fails it may just cause errors elsewhere instead of
     * failing itself.
     * @throws Exception
     */
    @Test
    public void readIncompleteStream() throws Exception {
        FsId id = new FsId("/streamed/1");
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 8889, new byte[1024*1024*2]);
        fsClient.commitLocalFsTransaction();
       
        StreamedBlobResult blobResult = 
            fsClient.readBlobAsStream(id);
        assertEquals(8889L, blobResult.originator());
        assertEquals(0, blobResult.stream().read());
        blobResult.stream().close();
        fsClient.ping();
    }

    /**
     * Writes multiple blobs in the same transaction.
     * 
     * @throws Exception
     */
    @Test
    public void multiWrite() throws Exception {
        final int niter = 50;

        fsClient.beginLocalFsTransaction();
        byte[] buf = new byte[8 * 1024];
        for (int i = 0; i < niter; i++) {
            Arrays.fill(buf, (byte) i);
            fsClient.writeBlob(new FsId("/test/" + i), i, buf);
        }
        fsClient.commitLocalFsTransaction();

        for (int i = 0; i < niter; i++) {
            Arrays.fill(buf, (byte) i);
            BlobResult result = fsClient.readBlob(new FsId("/test/" + i));
            assertTrue("Arrays must be equals.", Arrays.equals(buf,
                result.data()));
        }

        fsClient.beginLocalFsTransaction();
        // Overwrite
        for (int i = 0; i < niter; i++) {
            Arrays.fill(buf, (byte) (i + niter));
            fsClient.writeBlob(new FsId("/test/" + i), i, buf);
        }
        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();
        for (int i = 0; i < niter; i++) {
            Arrays.fill(buf, (byte) (i + niter));
            BlobResult result = fsClient.readBlob(new FsId("/test/" + i));
            assertTrue("Arrays must be equals.", Arrays.equals(buf,
                result.data()));
        }
        fsClient.rollbackLocalFsTransaction();

    }

    @Test
    public void zeroLengthFile() throws Exception {
        fsClient.beginLocalFsTransaction();
        FsId id = new FsId("/test/blob0");
        fsClient.writeBlob(id, 23, new byte[0]);
        fsClient.commitLocalFsTransaction();

        assertTrue("file does not exist", fsClient.blobExists(id));
        BlobResult br = fsClient.readBlob(id);
        assertEquals(0, br.data().length);
        assertEquals(23L, br.originator());
    }

    @Test
    public void smallBlob() throws Exception {
        fsClient.beginLocalFsTransaction();
        FsId id = new FsId("/test/blob1");
        byte[] small = new byte[1];
        small[0] = 42;
        fsClient.writeBlob(id, 23, small);
        fsClient.commitLocalFsTransaction();
        assertTrue("file does not exist", fsClient.blobExists(id));
        BlobResult br = fsClient.readBlob(id);
        assertEquals(1, br.data().length);
        assertEquals(23L, br.originator());
        assertEquals((byte) 42, br.data()[0]);

    }

    /**
     * Tests that uncommitted data can be read back.
     * 
     * @throws Exception
     */
    @Test
    public void readSmallBlobUncommitted() throws Exception {
        fsClient.beginLocalFsTransaction();
        FsId id = new FsId("/test/blob2");
        byte[] small = new byte[1];
        small[0] = 42;
        fsClient.writeBlob(id, 23, small);
        assertTrue("file does not exist", fsClient.blobExists(id));
        BlobResult br = fsClient.readBlob(id);
        assertEquals(1, br.data().length);
        assertEquals(23L, br.originator());
        assertEquals((byte) 42, br.data()[0]);
        fsClient.commitLocalFsTransaction();
    }

    @Test
    public void readNonExistant() throws Exception {
        try {
            fsClient.readBlob(new FsId("/totally/b0gus"));
            assertTrue("read should have thrown exception", false);
        } catch (FileStoreIdNotFoundException x) {
            // Good
        }
    }

    @Test
    public void writeWithOutTransaction() throws Exception {
        try {
            fsClient.writeBlob(new FsId("/not/there"), 333, new byte[34]);
            assertTrue("Write without transaction should not be permitted.",
                false);
        } catch (FileStoreException ok) {
            // Good
        }
    }

    @Test
    public void deleteBlob() throws Exception {
        FsId id = new FsId("/b/1");
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 7, new byte[] { (byte) 77});
        fsClient.commitLocalFsTransaction();
       
        try {
            fsClient.deleteBlob(id);
            assertTrue("should not have reached here.",  false);
        } catch (FileStoreException fse) {
            //good
        }
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteBlob(id);
        fsClient.rollbackLocalFsTransaction();
        
        assertTrue(fsClient.blobExists(id));
        
        fsClient.beginLocalFsTransaction();
        fsClient.deleteBlob(id);
        fsClient.commitLocalFsTransaction();
        
        assertFalse(fsClient.blobExists(id));
    }
    
    /**
     * Attempt to read a blob that was not yet committed.
     * @throws Exception
     */
    @Test
    public void testReadUnCommittedBlob() throws Exception {
        FsId id = new FsId("/kajsdf/df");
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 88, new byte[] { (byte) 88});
        
        TestCantReadBlob otherClient = new TestCantReadBlob(id);
         
        Thread t = new Thread(otherClient);
        t.start();
        t.join();
        assertFalse(otherClient.found);
        assertFalse(otherClient.error);
        fsClient.rollbackLocalFsTransaction();
    }
    
    /**
     * Test that the old data can be read before a transaction has completed
     * on another thread.
     * @throws Exception
     */
    @Test
    public void testReadOldBlob() throws Exception {
        FsId id = new FsId("/kajsdf/df");
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 88, new byte[] { (byte) 88});
        fsClient.commitLocalFsTransaction();
        
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 10000, new byte[] { (byte) 99, (byte) 127});
        
        TestReadOldData otherClient = new TestReadOldData(id, new byte[] {(byte) 88}, 88);
        Thread t = new Thread(otherClient);
        t.start();
        t.join();
        
        assertTrue(otherClient.ok);
        
        fsClient.rollbackLocalFsTransaction();
    }
    
    @Test
    public void testWriteBlobExclusively() throws Exception {
        FsId id = new FsId("/kljsdfkjsdflk/sdff");
        fsClient.beginLocalFsTransaction();
        OutputStream ostream = fsClient.writeBlob(id, 3324344);
        try {
            fsClient.ping();
            assertTrue("Should not have reached here.", false);
        } catch (ConcurrentModificationException x) {
            //OK
        }
        ostream.close();
        fsClient.ping();
    }
    
    @Test
    public void writeMultipleTimesToSameBlob() throws Exception {
        FsId id = new FsId("/multiple/blob");
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(id, 2L, new byte[1024*16]);
        fsClient.writeBlob(id, 2L, new byte[1024*4]);
        fsClient.commitLocalFsTransaction();
        
        BlobResult blobResult = fsClient.readBlob(id);
        assertEquals(1024*4, blobResult.data().length);
        assertEquals(2L, blobResult.originator());
    }
    
    
    /**
     * Validate that uncommitted data can be read.
     * @author Sean McCauliff
     *
     */
    private class TestCantReadBlob implements Runnable {

        private boolean error = false;
        private boolean found = true;
        private final FsId id;
        
        TestCantReadBlob(FsId id) {
            this.id = id;
        }
        
        public void run() {
            try {
                fsClient.disassociateThread();
                @SuppressWarnings("unused")
                BlobResult blob = fsClient.readBlob(id);
            } catch (FileStoreIdNotFoundException fsidnfe) {
                found = false;
                //ok
            } catch (Exception e) {
                error = true;
            }
        }

    }
    
    /**
     * Read old data before new data was committed.
     */
    private class TestReadOldData implements Runnable {
        @SuppressWarnings("unused")
        boolean error = false;
        private boolean ok = false;
        private final FsId id;
        private final byte[] expectedData;
        private final long originator;
        
        TestReadOldData(FsId id, byte[] expectedData, long originator) {
            this.id = id;
            this.expectedData = expectedData;
            this.originator = originator;
        }
        
        public void run() {
            try {
                fsClient.disassociateThread();
                BlobResult blob = fsClient.readBlob(id);
                ok = blob.originator() == originator && Arrays.equals(expectedData, blob.data());
            } catch (Exception e) {
                error = true;
            }
        }
    }
}
