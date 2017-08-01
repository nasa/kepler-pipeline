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

package gov.nasa.kepler.ar.exporter.tpixel;

import gov.nasa.kepler.ar.exporter.AbstractTargetExporter.ExportData;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.SingleQuarterExporterSource;
import gov.nasa.kepler.common.Cadence.CadenceType;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.GZIPOutputStream;

import nom.tam.util.BufferedDataOutputStream;

/**
 * We use this class to create output streams because sometimes we want
 * different types of output streams based on how large we expect the
 * output is going to be.  This wraps the output stream in a BufferedDataOutputStream
 * which is a creation of nom.tam.fits.
 * 
 * @author Sean McCauliff
 *
 */
class PixelOutputStreamFactory {

    private static final int OUTPUT_BUFFER_SIZE = 1024 * 256;

    
    public final BufferedDataOutputStream outputStream(TargetPixelMetadata targetMetadata,
        SingleQuarterExporterSource source,
        ExportData<? extends TargetPixelMetadata> exportData) throws IOException {
        
        targetMetadata.actualStartAndEnd(exportData.allTimeSeries);

        CadenceType cadenceType = source.mjdToCadence().cadenceType();

        boolean useGzip = targetMetadata.compressFile();
        String fname = fileName(targetMetadata, source.fileTimestamp(), cadenceType, useGzip);
        
        FileOutputStream fout =
            new FileOutputStream(new File(source.exportDirectory(), fname));
        try {
            if (!useGzip) {
                return new BufferedDataOutputStream(fout, OUTPUT_BUFFER_SIZE);
            } else {
                GZIPOutputStream gzipOut = new GZIPOutputStream(fout);
                return  new BufferedDataOutputStream(gzipOut, OUTPUT_BUFFER_SIZE);
            }
        } catch (IOException ioe) {
            fout.close();
            throw ioe;
        } catch (RuntimeException rte) {
            fout.close();
            throw rte;
        }

    }
    
    protected String fileName(TargetPixelMetadata targetMetadata, 
        String fileTimestamp, CadenceType cadenceType, boolean useGzip) {
        
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        if (targetMetadata.isK2Target()) {
            String fname = fnameFormatter.k2TargetPixelName(targetMetadata.keplerId(), 
                    targetMetadata.k2Campaign(), (cadenceType == CadenceType.SHORT), useGzip);
            return fname;
        } else {
            String fname = fnameFormatter.targetPixelName(
                    targetMetadata.keplerId(), fileTimestamp,
                    (cadenceType == CadenceType.SHORT), useGzip);
            return fname;
        }
        
    }

}
