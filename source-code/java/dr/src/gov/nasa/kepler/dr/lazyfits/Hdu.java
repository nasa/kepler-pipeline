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

package gov.nasa.kepler.dr.lazyfits;

import java.io.EOFException;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Represents a FITS HDU, which is made up of a Header and an optional Data
 * element
 * 
 * @author tklaus
 * 
 */
public class Hdu {

    private RandomAccessFile fileReader;

    private long headerFileOffset = 0;
    private long dataFileOffset = 0;

    private Header header = null;
    private Data data = null;

    /**
     * The non-reference case. Immediately read the header from the specified
     * RandomAccessFile. The file pointer is assumed to be set to the beginning
     * of this HDU.
     * 
     * @param fileReader
     * @throws LazyFitsException
     * @throws EOFException
     */
    public Hdu(RandomAccessFile fileReader) throws LazyFitsException,
        EOFException {
        this.fileReader = fileReader;

        read();
    }

    /**
     * The reference case. Empty Header and (possibly) Data instances are
     * created, but no data is read from the underlying file.
     * 
     * @param fileReader
     * @param referenceHdu
     */
    public Hdu(RandomAccessFile fileReader, Hdu referenceHdu) {
        header = new Header(fileReader, referenceHdu);
        headerFileOffset = referenceHdu.getHeaderFileOffset();
        if (referenceHdu.getHeader()
            .hasData()) {
            data = new Data(fileReader, referenceHdu);
            dataFileOffset = referenceHdu.getDataFileOffset();
        }
    }

    /**
     * Read the HDU contents. This method is only used in the non-reference
     * case.
     * 
     * @throws LazyFitsException
     * @throws EOFException
     */
    private void read() throws LazyFitsException, EOFException {
        try {
            headerFileOffset = fileReader.getFilePointer();
            header = new Header(fileReader);

            if (header.hasData()) {
                dataFileOffset = fileReader.getFilePointer();
                data = new Data(fileReader, header);
            }
        } catch (EOFException e) {
            throw e;
        } catch (IOException e) {
            throw new LazyFitsException("failed to read Hdu", e);
        }
    }

    public Header getHeader() {
        return header;
    }

    public Data getData() {
        return data;
    }

    public long getDataFileOffset() {
        return dataFileOffset;
    }

    public long getHeaderFileOffset() {
        return headerFileOffset;
    }
}
