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

package gov.nasa.kepler.dr.ukirt;

import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.UkirtImageBlobMetadata;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import java.io.File;
import java.util.Date;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This dispatcher handles ingest of UKIRT target images.
 * 
 * @author Forrest Girouard
 */
public class UkirtImageDispatcher implements Dispatcher {

    private static final Log log = LogFactory.getLog(UkirtImageDispatcher.class);

    private DvCrud dvCrud = new DvCrud();

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {

        log.info("file count = " + filenames.size());

        long createTime = new Date().getTime();

        for (String filename : filenames) {
            File imageFile = new File(sourceDirectory, filename);

            if (!imageFile.exists()) {
                throw new DispatchException(String.format(
                    "Image file %s must exist", filename));
            } else if (!imageFile.isFile()) {
                throw new DispatchException(String.format(
                    "Image file %s must be a regular file", filename));
            }

            int dotIndex = filename.lastIndexOf('.');
            if (dotIndex == -1 || dotIndex >= filename.length() - 1) {
                throw new DispatchException(String.format(
                    "Image file %s must have a file extension", filename));
            }
            String fileExtension = filename.substring(dotIndex + 1);

            int hyphenIndex = filename.indexOf('-');
            if (hyphenIndex == -1 || hyphenIndex == dotIndex - 1) {
                throw new DispatchException(String.format(
                    "Image file %s must contain keplerId", filename));
            }

            int underscoreIndex = filename.indexOf('_', hyphenIndex);
            if (underscoreIndex == -1 || underscoreIndex == hyphenIndex + 1) {
                throw new DispatchException(String.format(
                    "Image file %s must contain keplerId", filename));
            }

            String keplerIdString = filename.substring(hyphenIndex + 1,
                underscoreIndex);
            int keplerId = Integer.valueOf(keplerIdString);

            FsId fsId = DrFsIdFactory.getUkirtImageBlobFsId(keplerId,
                fileExtension, createTime);
            log.info(String.format("Storing file %s as blob %s ",
                imageFile.getName(), fsId));
            FileStoreClientFactory.getInstance()
                .writeBlob(fsId, DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID,
                    imageFile);

            UkirtImageBlobMetadata ukirtImageBlobMetadata = new UkirtImageBlobMetadata(
                createTime, keplerId, fileExtension);
            dvCrud.createUkirtImageBlobMetadata(ukirtImageBlobMetadata);
        }
    }
}
