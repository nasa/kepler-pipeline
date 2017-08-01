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

import gov.nasa.spiffy.common.metrics.CounterMetric;

import java.io.EOFException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class implements a reader for FITS files. It employs a just-in-time
 * approach, only parsing the FITS logical records when data is requested from
 * them.
 * 
 * It also allows another LazyFits instance to be used as a map into a new
 * instance so that binary table contents can be read directly out without
 * parsing the metadata from the headers or parsing the preceeding HDU's. This
 * improves the performance for reading data from a large set of FITS files that
 * all have identical internal structure because the structure metadata need
 * only be read from one of the files.
 * 
 * @author tklaus
 * 
 */
public class LazyFits {
    private static final Log log = LogFactory.getLog(LazyFits.class);

    private RandomAccessFile fileReader;

    /**
     * The list of HDUs for this FITS object. May contain nulls in the reference
     * case where HDU's are skipped.
     */
    private ArrayList<Hdu> hduList = new ArrayList<Hdu>();

    /**
     * Reference to another LazyFits instance that is assumed to represent a
     * FITS file with the exact same internal structure as this one (same number
     * of HDU's, same number of rows in each table, etc.) If set, structure
     * metadata and file offsets will be used from the reference instead of
     * parsing them from this instance (for improved performance)
     */
    private LazyFits reference = null;

    /**
     * Read fits from the specified filename. All data and metadata will be read
     * from this file.
     * 
     * @param filename
     * @throws LazyFitsException
     */
    public LazyFits(String filename) throws LazyFitsException {
        log.debug("LazyFits(String filename=" + filename + ") - start");

        try {
            fileReader = new RandomAccessFile(filename, "r");
        } catch (FileNotFoundException e) {
            log.error("LazyFits(String filename=" + filename + ")", e);

            throw new LazyFitsException("failed to open " + filename, e);
        }
        CounterMetric.increment("dr.dispatch.pixel.lazyfits.non-reference.count");

        log.debug("LazyFits(String) - end");
    }

    /**
     * Read fits from the specified file. All data and metadata will be read
     * from this file.
     * 
     * @param file
     * @throws LazyFitsException
     */
    public LazyFits(File file) throws LazyFitsException {
        log.debug("LazyFits(File file=" + file + ") - start");

        try {
            fileReader = new RandomAccessFile(file, "r");
        } catch (FileNotFoundException e) {
            log.error("LazyFits(File file=" + file + ")", e);

            throw new LazyFitsException("failed to open " + file, e);
        }
        CounterMetric.increment("dr.dispatch.pixel.lazyfits.non-reference.count");

        log.debug("LazyFits(File) - end");
    }

    /**
     * Read fits from the specified file, using the specified reference LazyFits
     * as a map. File offsets from the reference will be used to seek into this
     * file before reading so that intervening HDU's don't need to be parsed.
     * 
     * @param filename
     * @param reference
     * @throws LazyFitsException
     */
    public LazyFits(String filename, LazyFits reference)
        throws LazyFitsException {
        this(filename);
        log.debug("LazyFits(String filename=" + filename
            + ", LazyFits reference=" + reference + ") - start");

        this.reference = reference;
        CounterMetric.increment("dr.dispatch.pixel.lazyfits.reference.count");

        log.debug("LazyFits(String, LazyFits) - end");
    }

    /**
     * Read fits from the specified file, using the specified reference LazyFits
     * as a map. File offsets from the reference will be used to seek into this
     * file before reading so that intervening HDU's don't need to be parsed.
     * 
     * @param file
     * @param reference
     * @throws LazyFitsException
     */
    public LazyFits(File file, LazyFits reference) throws LazyFitsException {
        this(file);
        log.debug("LazyFits(File file=" + file + ", LazyFits reference="
            + reference + ") - start");

        this.reference = reference;
        CounterMetric.increment("dr.dispatch.pixel.lazyfits.reference.count");

        log.debug("LazyFits(File, LazyFits) - end");
    }

    /**
     * In the non-reference case, the requested HDU is read fully, as are any
     * skipped HDU's.
     * 
     * In the reference case, the hduList is allowed to be sparse, with nulls
     * for skipped HDU's. These nulls will be replaced with real instances the
     * first time that HDU is requested.
     * 
     * @param index
     * @return
     * @throws LazyFitsException
     * @throws EOFException
     */
    public Hdu getHdu(int index) throws LazyFitsException, EOFException {

        if (reference != null) {
            // reference case
            growHduListIfNecessary(index);

            Hdu hdu = hduList.get(index);
            Hdu referenceHdu = reference.getHdu(index);

            if (hdu == null) {
                // not yet loaded
                hdu = new Hdu(fileReader, referenceHdu);
                hduList.set(index, hdu);
            }
            return hdu;
        } else {
            // non-reference case
            if (index >= hduList.size()) {

                int readCount = (index + 1) - hduList.size();
                for (int i = 0; i < readCount; i++) {
                    readNextHdu();
                }
            }
            return hduList.get(index);
        }
    }

    public Hdu readNextHdu() throws LazyFitsException, EOFException {

        Hdu hdu = new Hdu(fileReader);
        hduList.add(hdu);
        return hdu;
    }

    /**
     * Read all HDU's until EOF
     * 
     * @throws LazyFitsException
     */
    public void readAllHdus() throws LazyFitsException {
        try {
            while (true) {
                readNextHdu();
            }
        } catch (EOFException e) {
        }
    }

    public void close() throws IOException {
        fileReader.close();
    }

    /**
     * Make the hduList long enough to include index+1 elements. Intervening
     * elements are set to null
     * 
     * @param index
     */
    private final void growHduListIfNecessary(int index) {
        if (index < hduList.size()) {
            return;
        }

        hduList.ensureCapacity(index + 1);
        for (int i = hduList.size(); i <= index; i++) {
            hduList.add(null);
        }
    }
}
