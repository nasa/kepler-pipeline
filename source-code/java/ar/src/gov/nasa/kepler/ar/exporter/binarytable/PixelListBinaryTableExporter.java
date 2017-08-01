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

package gov.nasa.kepler.ar.exporter.binarytable;

import gov.nasa.kepler.mc.Pixel;

import java.io.IOException;
import java.util.List;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.ArrayDataOutput;

import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.padBinaryTableData;

/**
 * Generates a pixel list binary table on output.
 * 
 * @author Sean McCauliff
 *
 */
public final class PixelListBinaryTableExporter {

    /**
     * 
     * @param out
     * @param headerSource
     * @param pixelCoordinates It's assume this is already in the correct
     * matching order.
     * @param extVersion This is the number that goes in the EXTVER keyword
     * value so that the user can distinguish between different headers with
     * the same EXTNAME value.
     * @throws IOException
     * @throws FitsException 
     */
    public void writePixelList(ArrayDataOutput out, 
        BaseBinaryTableHeaderSource headerSource,
        List<Pixel> pixelCoordinates,
        int extVersion, String checksum) throws IOException, FitsException {
        
        PixelListBinaryTableHeaderFormatter headerFormatter = new PixelListBinaryTableHeaderFormatter();
        Header h = headerFormatter.formatHeader(headerSource, extVersion, checksum);
        h.write(out);
        
        for (Pixel pixel : pixelCoordinates) {
            out.writeInt(pixel.getColumn());
            out.writeInt(pixel.getRow());
        }
        
        ArrayDimensions arrayDims = ArrayDimensions.newInstance(pixelCoordinates.size());
        long tableBytesWritten = headerFormatter.bytesPerTableRow(arrayDims);
        padBinaryTableData(tableBytesWritten, out);
    }
}
