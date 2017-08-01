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

package gov.nasa.kepler.mc.fs;

import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class FcFsIdFactory {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(FcFsIdFactory.class);

    private static final String FC_PATH = "/fc";

    /**
     * private to prevent instantiation
     *
     */
    private FcFsIdFactory() {
    }
    
    /**
     * Get a 2D black data (the image) blob for the specified historyId and CCD mod/out.
     * 
     * @param historyId
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getTwoDBlackDataId(int historyId, int ccdModule, int ccdOutput) {
    	String fullPath = 
    		FC_PATH + 
    		"/TwoDBlack" + 
    		"/data"+ ":" +
    		historyId + ":" +
    		ccdModule +  ":" +
    		ccdOutput;
    	return new FsId(fullPath);
    }
    
    /**
     * Get a 2D black uncertainty (the uncertainty in the image) blob for the specified historyId and CCD mod/out.
     * 
     * @param historyId
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getTwoDBlackUncertaintyId(int historyId, int ccdModule, int ccdOutput) {
    	String fullPath = 
    		FC_PATH + 
    		"/TwoDBlack" + 
    		"/uncertainty" + ":" +
    		historyId + ":" +
    		ccdModule +  ":" +
    		ccdOutput;
    	return new FsId(fullPath);
    }
    
    /**
     * Get a small flat data (the image) blob for the specified historyId and CCD mod/out.
     * 
     * @param historyId
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getSmallFlatFieldDataId(int historyId, int ccdModule, int ccdOutput) {
    	String fullPath = 
    		FC_PATH + 
    		"/SmallFlatField" + 
    		"/data" + ":" +
    		historyId + ":" +
    		ccdModule + ":" +
    		ccdOutput;
    	return new FsId(fullPath);
    }
    
    /**
     * Get a small flat uncertainty (the uncertainty in the image) blob for the specified historyId and CCD mod/out.
     * 
     * @param historyId
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getSmallFlatFieldUncertaintyId(int historyId, int ccdModule, int ccdOutput) {
    	String fullPath = 
    		FC_PATH + 
    		"/SmallFlatField" + 
    		"/uncertainty" + ":" +
    		historyId + ":" +
    		ccdModule + ":" +
    		ccdOutput;
    	return new FsId(fullPath);
    }
    
    /**
     * Get a small flat uncertainty (the uncertainty in the image) blob for the specified historyId and CCD mod/out.
     * 
     * @param historyId
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getPrfId(int historyId, int ccdModule, int ccdOutput) {
    	String fullPath = 
    		FC_PATH + 
    		"/Prf" + 
    		"/data" + ":" +
    		historyId + ":" +
    		ccdModule + ":" +
    		ccdOutput;
    	return new FsId(fullPath);
    }

    
    public static void testRead() throws IOException, ClassNotFoundException {
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        FsId fsId = FcFsIdFactory.getSmallFlatFieldDataId(666, 24, 4);
        BlobResult blobResult = fsClient.readBlob(fsId);

        ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(blobResult.data()));
        @SuppressWarnings("unused")
        float[][] image = (float[][]) ois.readObject();
    }

    public static void testWrite() throws IOException, ClassNotFoundException {
        float[][] image = new float[1070][1132];
        for (int ii = 0; ii < 1070; ++ii) {
        	for (int jj = 0; jj < 1132; ++jj) {
        		image[ii][jj] = 3.14f;
        	}	
        }

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        FsId fsId = FcFsIdFactory.getSmallFlatFieldDataId(666, 24, 4);
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(baos);
        oos.writeObject(image);
        
        fsClient.writeBlob(fsId, 0, baos.toByteArray()); // origin = 0: same as 
    }

}
