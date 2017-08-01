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


import static org.junit.Assert.*;

import java.util.Arrays;

import gov.nasa.kepler.fs.api.*;

import org.junit.After;
import org.junit.Test;

public class ComboTest {

    
    @After
    public void tearDown() {
        ((FileStoreTestInterface)FileStoreClientFactory.getInstance()).cleanFileStore();
    }

    /**
     * Write blobs, time series and mjd time series in the same transaction.
     * 
     */
    @Test
    public void comboMealTest() {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        for (int i=0; i < 10; i++) {
            byte[] blobData = generateBlob(i);
            fsClient.writeBlob(new FsId("/beware-of-the-blob/" + i), i, blobData);
        }
        for (int i=0; i < 10; i++) {
            IntTimeSeries itsIt = generateIntTimeSeries(i);
            fsClient.writeTimeSeries(new TimeSeries[] { itsIt} );
        }
        for (int i=0; i < 10; i++) {
            FloatMjdTimeSeries mts = generateFloatMjdTimeSeries(i);
            fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { mts });
        }
        
        fsClient.commitLocalFsTransaction();
        
        
        for (int i=0; i < 10; i++) {
            FsId id = new FsId("/beware-of-the-blob/" + i);
            BlobResult result = fsClient.readBlob(id);
            assertEquals((long)i, result.originator());
            byte[] blobData = generateBlob(i);
            assertTrue(Arrays.equals(blobData, result.data()));
        }
        
        for (int i=0; i < 10; i++) {
            IntTimeSeries expected = generateIntTimeSeries(i);
            IntTimeSeries[] itsIt = 
                fsClient.readTimeSeriesAsInt(new FsId[] { expected.id()}, expected.startCadence(), expected.endCadence());
            assertEquals(expected, itsIt[0]);
            
        }
        
        for (int i=0; i < 10; i++) {
            FloatMjdTimeSeries expected = generateFloatMjdTimeSeries(i);
            FloatMjdTimeSeries[] read = fsClient.readMjdTimeSeries(new FsId[] { expected.id()}, expected.startMjd(), expected.endMjd());
            assertEquals(expected, read[0]);
        }
    }

    /**
     * This simulates what happens with FFI to LC.
     */
    @Test
    public void ffiToLcCombo() {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        for (int i=0; i < 10; i++) {
            byte[] blobData = generateBlob(i);
            FsId blobId = new FsId("/b/" + i);
            fsClient.writeBlob(blobId, i, blobData);
        }
        
        for (int i=0; i < 10; i++) {
            FsId blobId = new FsId("/b/" + i);
            byte[] blobData = generateBlob(i);
            BlobResult result = fsClient.readBlob(blobId);
            assertTrue(Arrays.equals(blobData, result.data()));
        }
        fsClient.commitLocalFsTransaction();
        
        for (int i=0; i < 10; i++) {
            FsId blobId = new FsId("/b/" + i);
            byte[] blobData = generateBlob(i);
            BlobResult result = fsClient.readBlob(blobId);
            assertTrue(Arrays.equals(blobData, result.data()));
        }
    }
    
    
    
    private FloatMjdTimeSeries generateFloatMjdTimeSeries(int i) {
        double[] mjd = new double[1024*16];
        float[] values= new float[mjd.length];
        Arrays.fill(values, 3.14f * i);
        for (int m=0; m < mjd.length; m++) {
            mjd[m] = .1 * m;
        }
        FloatMjdTimeSeries mts = new FloatMjdTimeSeries(new FsId("/m/" + i), 0.0, 100000.0, mjd, values, i);
        return mts;
    }

    private IntTimeSeries generateIntTimeSeries(int i) {
        int[] idata = new int[16*1024];
        Arrays.fill(idata, i);
        IntTimeSeries itsIt = 
            new IntTimeSeries(new FsId("/itsit/"+i), idata, 0,idata.length -1, new boolean[idata.length], i);
        return itsIt;
    }

    private byte[] generateBlob(int i) {
        byte[] blobData = new byte[1024];
        Arrays.fill(blobData, (byte) i);
        return blobData;
    }

}
