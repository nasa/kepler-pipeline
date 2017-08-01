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

package gov.nasa.kepler.dr.sclk;

import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.sclk.SclkFileReader.CoefficientsIterator;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.SclkCoefficients;
import gov.nasa.kepler.hibernate.dr.SclkCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This {@link Dispatcher} handles SCLK Spice files from the MOC. These files
 * contain information about the Vehicle Time Clock, or VTC. This information
 * allows VTC values to be converted to timestamps.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class SclkDispatcher implements Dispatcher {

    private static final Log log = LogFactory.getLog(SclkDispatcher.class);

    private SclkCrud sclkCrud;

    public SclkDispatcher() {
        try {
            sclkCrud = new SclkCrud(DatabaseServiceFactory.getInstance());
        } catch (PipelineException e) {
            throw new DispatchException("Initilialization failure", e);
        }
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        List<SclkCoefficients> existingSclkCoefficients;

        // Fetch the existing set of SclkCoefficients.
        try {
            existingSclkCoefficients = sclkCrud.retrieveAllSclkCoefficients();
        } catch (Exception e) {
            throw new DispatchException(
                "Failed to fetch existing SclkCoefficients", e);
        }

        for (String filename : filenames) {
            try {
                File sclkFile = new File(sourceDirectory, filename);

                log.info("parsing SCLK = " + sclkFile);

                SclkFileReader sclkFileReader = new SclkFileReader(sclkFile);
                sclkFileReader.parse();

                log.info(String.format("Persisting %s to file store.", filename));
                FileLog fileLog = dispatcherWrapper.storeFile(filename);

                for (CoefficientsIterator it = sclkFileReader.getCoefficientsIterator(); it.hasNext();) {
                    SclkCoefficients sclkCoefficients = it.next();

                    // Only add this set of coefficients to the table if it's
                    // not already there.
                    if (!inExistingSclkCoefficients(existingSclkCoefficients,
                        sclkCoefficients)) {
                        log.info("Adding new SclkCoefficients: "
                            + sclkCoefficients);
                        sclkCrud.createSclkCoefficients(sclkCoefficients);

                        // Set fs metadata.
                        sclkCoefficients.setFileLog(fileLog);
                    } else {
                        log.info("Ignoring SclkCoefficients: "
                            + sclkCoefficients
                            + " because it already exists in the db");
                    }
                }
            } catch (Exception e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }
        }
    }

    private boolean inExistingSclkCoefficients(
        List<SclkCoefficients> existingSclkCoefficients,
        SclkCoefficients newSclkCoefficients) {
        for (SclkCoefficients sclkCoefficients : existingSclkCoefficients) {
            if (sclkCoefficients.getVtcEventTime() == newSclkCoefficients.getVtcEventTime()) {
                return true;
            }
        }
        return false;
    }

}
