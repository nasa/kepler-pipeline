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

package gov.nasa.kepler.ar.exporter.cbv;

import java.io.*;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.BufferedDataOutputStream;
import nom.tam.util.BufferedFile;

import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;

/**
 * Assembles all the cotrending basis vector mod/out files into one cotrending
 * basis vector FITS file.
 * 
 * @author Sean McCauliff
 *
 */
class CbvAssembler {

    private static final Log log = LogFactory.getLog(CbvAssembler.class);
    
    void assemble(CbvAssemblerSource source) throws FitsException, IOException {
        log.info("Creating primary header.");
        CbvPrimaryHeaderSource primaryHeaderSource = primaryHeaderSource(source);
                
        CbvPrimaryHeaderFormatter headerFormatter = new CbvPrimaryHeaderFormatter();
        Header primaryHeader = 
            headerFormatter.formatHeader(primaryHeaderSource, FitsConstants.CHECKSUM_DEFAULT);
       
        FitsChecksumOutputStream checkOut = new FitsChecksumOutputStream();
        BufferedDataOutputStream checkOutBuffered = 
            new BufferedDataOutputStream(checkOut);
        primaryHeader.write(checkOutBuffered);
        checkOutBuffered.flush();
        
        primaryHeader = headerFormatter.formatHeader(primaryHeaderSource, checkOut.checksumString());
        
        BufferedFile fileOutput = createOutputFile(source);
        primaryHeader.write(fileOutput);
        FileStoreClient fsClient = source.fileStoreClient();
        log.info("Writing out mod/out HDUs.");
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                FsId modOutBlobId = 
                    ArFsIdFactory.getSingleChannelCbvFile(ccdModule, ccdOutput, source.cadenceType(), source.quarter());
                if (!fsClient.blobExists(modOutBlobId)) {
                    log.warn("mod/out " + ccdModule + "/" + ccdOutput + " does not exist.");
                    continue; //need to do this in order to skip 
                }
                log.info("Reading mod/out blob \"" + modOutBlobId + "\".");
                byte[] cbvModOut = fsClient.readBlob(modOutBlobId).data();
                fileOutput.write(cbvModOut);
            }
        }
        fileOutput.close();
        log.info("CBV export complete.");
    }
    
    /**
     * This retries since we often export over NFS and NFS is flaky.
     * @param source
     * @return
     * @throws IOException 
     */
    private BufferedFile createOutputFile(CbvAssemblerSource source) throws IOException {
        final int MAX_TRYS = 2;
        int nTrys = 0;
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String cbvFitsFileName;
        if (source.isK2()) {
            cbvFitsFileName = fnameFormatter.k2CbvName(source.k2Campaign(), 
                source.dataRelease(), source.cadenceType());
        } else {
            cbvFitsFileName = fnameFormatter.cbvName(source.exportTimestamp(),
                source.quarter(), source.dataRelease(), source.cadenceType());
        }
        IOException cachedException = null;
        do {
            try {
                File exportFile = new File(source.exportDirectory(), cbvFitsFileName);
                BufferedFile bufferedFile = new BufferedFile(exportFile, "rw");
                log.info("Created file \"" + exportFile + "\".");
                return bufferedFile;
            } catch (IOException ioe) {
                cachedException = ioe;
                nTrys++;
            }
        } while (nTrys <= MAX_TRYS);
        throw cachedException;
    }
    
    private CbvPrimaryHeaderSource primaryHeaderSource(
        final CbvAssemblerSource assemblerSource) {
        CbvPrimaryHeaderSource source = new CbvPrimaryHeaderSource() {

            @Override
            public Date generatedAt() {
                return assemblerSource.generatedAt();
            }

            @Override
            public long pipelineTaskId() {
                return assemblerSource.pipelineTaskId();
            }

            @Override
            public String subversionUrl() {
                return KeplerSocVersion.getUrl();
            }

            @Override
            public String programName() {
                return assemblerSource.programName();
            }

            @Override
            public String subversionRevision() {
                return KeplerSocVersion.getRevision();
            }

            @Override
            public int quarter() {
                return assemblerSource.quarter();
            }

            @Override
            public int season() {
                return assemblerSource.season();
            }

            @Override
            public int dataReleaseNumber() {
                return assemblerSource.dataRelease();
            }

            @Override
            public ObservingMode observingMode() {
                return ObservingMode.valueOf(assemblerSource.cadenceType());
            }
            
            @Override
            public boolean isK2() {
                return assemblerSource.isK2();
            }
            
            @Override
            public int k2Campaign() {
                return assemblerSource.k2Campaign();
            }
            
        };
        return source;
    }
}
