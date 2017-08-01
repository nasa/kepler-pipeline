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

package gov.nasa.kepler.dr.histogram;

import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.HistogramLog;
import gov.nasa.kepler.hibernate.dr.HistogramLogCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Set;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;

/**
 * This dispatcher processes and stores the Compression Histogram files sent by
 * the DMC.
 * 
 * @author Miles Cote
 */
public class HistogramDispatcher implements Dispatcher {

    private HistogramLogCrud histogramLogCrud;

    public HistogramDispatcher() {
        try {
            histogramLogCrud = new HistogramLogCrud(
                DatabaseServiceFactory.getInstance());
        } catch (PipelineException e) {
            throw new DispatchException("Initilialization failure", e);
        }
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        for (String filename : filenames) {
            try {
                FileLog fileLog = dispatcherWrapper.storeFile(filename);

                Fits fits = new Fits(sourceDirectory + File.separator
                    + filename);
                fits.read();

                // Read FITS header fields.
                fits.getHDU(0);

                BinaryTableHDU binaryHdu = (BinaryTableHDU) fits.getHDU(1);

                int cadenceStart = FitsUtils.getHeaderIntValueChecked(
                    binaryHdu.getHeader(),
                    HistogramLog.HDR_CADENCE_START_KEYWORD);
                int cadenceEnd = FitsUtils.getHeaderIntValueChecked(
                    binaryHdu.getHeader(), HistogramLog.HDR_CADENCE_END_KEYWORD);

                // Store metadata.
                histogramLogCrud.createHistogram(new HistogramLog(fileLog,
                    cadenceStart, cadenceEnd));

            } catch (Exception e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }
        }
    }

}