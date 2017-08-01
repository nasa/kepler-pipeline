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

package gov.nasa.kepler.cal.ffi;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.ImageHDU;
import nom.tam.util.BufferedDataInputStream;

import static gov.nasa.kepler.common.FitsConstants.*;

/**
 * This reads Ffi mod outs very inefficiently.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiReader {

    /**
     * Read an entire FFI and get a single mod out from it.
     * @param ffiId
     * @param tmpDir
     * @param ccdModule
     * @param ccdOutput
     * @return
     * @throws IOException
     * @throws FitsException
     */
    public FfiModOut readFfi(FsId ffiId,int ccdModule, int ccdOutput)
        throws IOException, FitsException {
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        StreamedBlobResult blobResult = fsClient.readBlobAsStream(ffiId);
        
        int hdui = FcConstants.getChannelNumber(ccdModule, ccdOutput);
        try {
            return parseFile( hdui, blobResult.originator(), blobResult.stream());
        } finally {
            FileUtil.close(blobResult.stream());
        }
    }
    
    /**
     * Reads from an ffi file that contains a single mod out along with the
     * primary header.
     * 
     * @param ffiModOutId
     * @param tmpDir
     * @return
     * @throws IOException
     * @throws FitsException
     */
    public FfiModOut readFFiModOut(FsId ffiModOutId) 
        throws IOException, FitsException {
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        StreamedBlobResult blobResult = fsClient.readBlobAsStream(ffiModOutId);
        try {
            return parseFile( 1, blobResult.originator(), blobResult.stream());
        } finally {
            FileUtil.close(blobResult.stream());
        }
    }
    
    private FfiModOut parseFile( int hdui, long originator, InputStream in) 
        throws IOException, FitsException {
        
        BufferedDataInputStream bin = new BufferedDataInputStream(in);
        Fits fits = new Fits(bin);
        BasicHDU initial = fits.readHDU();
        //TODO:  This is UTC in mjd. ?
        double startMjd = initial.getHeader().getDoubleValue(STARTIME_KW);
        double endMjd = initial.getHeader().getDoubleValue(END_TIME_KW);
        double midMjd= (endMjd + startMjd)/2.0;
        int longCadenceNumber = initial.getHeader().getIntValue(LC_INTER_KW);
        int scConfigId = initial.getHeader().getIntValue(SCCONFID_KW);
        ImageHDU imageHdu = (ImageHDU) fits.getHDU(hdui);
        int ccdModule = imageHdu.getHeader().getIntValue(MODULE_KW);
        int ccdOutput = imageHdu.getHeader().getIntValue(OUTPUT_KW);
        String fileName = initial.getHeader().getStringValue(FILENAME_KW);
           
        int[][] pixels = (int[][]) imageHdu.getData().getData();
        boolean[][] gaps = new boolean[pixels.length][pixels[0].length];
        for (int i=0; i < pixels.length; i++) {
            for (int j=0; j < pixels[i].length; j++) {
                if (pixels[i][j] == MISSING_PIXEL_VALUE) {
                    gaps[i][j] = true;
                }
            }
        }
        return new FfiModOut(pixels,gaps, startMjd, midMjd, endMjd, 
            originator, initial, imageHdu.getHeader(), longCadenceNumber,
            scConfigId, ccdModule, ccdOutput, fileName);
    }
}
