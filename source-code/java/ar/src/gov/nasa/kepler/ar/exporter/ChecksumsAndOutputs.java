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

package gov.nasa.kepler.ar.exporter;

import java.io.Closeable;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;
import static gov.nasa.kepler.common.FitsConstants.*;
/**
 * Checksums and output buffers to use with the per target exporter.
 * Usually you want two instances of these one that computes the
 * checksums and the other that actually writes the files given
 * the the first instance has computed the checksums.
 * 
 * @author Sean McCauliff
 *
 */
public final class ChecksumsAndOutputs implements Closeable {

    private final static Log log = LogFactory.getLog(ChecksumsAndOutputs.class);
    
    private final List<String> checksums;

    private final List<ArrayDataOutput> outputs;

    private final List<FitsChecksumOutputStream> checksumOutputStreams;

    /**
     * Create a new instance with default checksums.
     * @param nHdus
     * @return non-null
     */
    public static ChecksumsAndOutputs newInstanceWithDefaults(int nHdus) {
        List<FitsChecksumOutputStream> checksumOutputStreams = new ArrayList<FitsChecksumOutputStream>(nHdus);
        for (int i=0; i < nHdus; i++) {
            checksumOutputStreams.add(new FitsChecksumOutputStream());
        }

        List<ArrayDataOutput> outputStreams = new ArrayList<ArrayDataOutput>(nHdus);
        for (int i=0; i < nHdus; i++) {
            outputStreams.add(new BufferedDataOutputStream(checksumOutputStreams.get(i)));
        }

        List<String> checksums = new ArrayList<String>(nHdus);
        for (int i=0; i < nHdus; i++) {
            checksums.add(CHECKSUM_DEFAULT);
        }

        return new ChecksumsAndOutputs(checksums, outputStreams, checksumOutputStreams);
    }

    public static ChecksumsAndOutputs newInstance(int nHdus, ArrayDataOutput bufOut,
        ChecksumsAndOutputs calculatedChecksums) {

        List<String> checksums = new ArrayList<String>(nHdus);
        for (int i=0; i < nHdus; i++) {
            checksums.add(calculatedChecksums.checksumOutputStreams.get(i).checksumString());
        }

        List<ArrayDataOutput> outputStreams = new ArrayList<ArrayDataOutput>(nHdus);
        for (int i=0; i < nHdus; i++) {
            outputStreams.add(bufOut);
        }
        return new ChecksumsAndOutputs(checksums, outputStreams, null);
    }

    private ChecksumsAndOutputs(List<String> checksums, List<ArrayDataOutput> outputs,
        List<FitsChecksumOutputStream> checksumOutputStreams) {

        this.checksums = checksums;
        this.outputs = outputs;
        this.checksumOutputStreams = checksumOutputStreams;
    }

    public List<String> checksums() {
        return checksums;
    }

    public List<ArrayDataOutput> outputs() {
        return outputs;
    }

    @Override
    public void close() {
        if (checksumOutputStreams != null) {
            for (ArrayDataOutput out : outputs) {
                try {
                    out.close();
                } catch (IOException ioe) {
                    throw new IllegalStateException(ioe);
                }
            }
        } else {
            ArrayDataOutput out = outputs.get(0);
            try {
                out.close();
            } catch (IOException ioe) {
                log.warn("Failed to close output to FITS file.", ioe);
            }
        }
    }

}
