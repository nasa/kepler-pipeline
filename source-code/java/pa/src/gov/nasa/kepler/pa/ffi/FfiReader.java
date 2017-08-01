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

package gov.nasa.kepler.pa.ffi;

import static gov.nasa.kepler.common.FitsConstants.END_TIME_KW;
import static gov.nasa.kepler.common.FitsConstants.LC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import static gov.nasa.kepler.common.FitsConstants.SCCONFID_KW;
import static gov.nasa.kepler.common.FitsConstants.STARTIME_KW;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.IOException;
import java.io.InputStream;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.ImageHDU;
import nom.tam.util.BufferedDataInputStream;

/**
 * This reads Ffi mod outs very inefficiently.
 * 
 * @author Forrest Girouard
 * 
 */
public class FfiReader {

    /**
     * Reads from an ffi file that contains a single mod out along with the
     * primary header.
     * 
     * @param ffiValuesModOutId
     * @param tmpDir
     * @return
     * @throws IOException
     * @throws FitsException
     */
    public FfiModOut readFfiModOut(FsId ffiModOutId) throws IOException, FitsException {

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        StreamedBlobResult blobResult = fsClient.readBlobAsStream(ffiModOutId);
        try {
            return parseFile(1, blobResult.originator(),
                blobResult.stream());
        } finally {
            FileUtil.close(blobResult.stream());
        }
    }

    private FfiModOut parseFile(int hdui, long originator,
        InputStream blobStream) throws IOException,
        FitsException {

        BufferedDataInputStream blobBufferedStream = new BufferedDataInputStream(
            blobStream);
        Fits fits = new Fits(blobBufferedStream);
        BasicHDU basicHeader = fits.readHDU();
        // TODO: This is UTC in mjd. ?
        double startMjd = basicHeader.getHeader()
            .getDoubleValue(STARTIME_KW);
        double endMjd = basicHeader.getHeader()
            .getDoubleValue(END_TIME_KW);
        double midMjd = (endMjd + startMjd) / 2.0;
        int longCadenceNumber = basicHeader.getHeader()
            .getIntValue(LC_INTER_KW);
        int scConfigId = basicHeader.getHeader()
            .getIntValue(SCCONFID_KW);
        ImageHDU dataImageHdu = (ImageHDU) fits.getHDU(hdui);
        int ccdModule = dataImageHdu.getHeader()
            .getIntValue(MODULE_KW);
        int ccdOutput = dataImageHdu.getHeader()
            .getIntValue(OUTPUT_KW);

        float[][] data = (float[][]) dataImageHdu.getData()
            .getData();
        boolean[][] gaps = new boolean[data.length][data[0].length];
        for (int row = 0; row < data.length; row++) {
            for (int column = 0; column < data[row].length; column++) {
                if (Float.isNaN(data[row][column])) {
                    gaps[row][column] = true;
                }
            }
        }
        return new FfiModOut(data, gaps, startMjd, midMjd, endMjd,
            originator, basicHeader, dataImageHdu.getHeader(),
            longCadenceNumber, scConfigId, ccdModule, ccdOutput);
    }
}
