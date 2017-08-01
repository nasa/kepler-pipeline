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

package gov.nasa.kepler.ar.exporter.ffi;


import java.util.Date;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.fs.api.FileStoreClient;
import nom.tam.fits.BasicHDU;
import nom.tam.fits.ImageHDU;

/**
 * Information needed to generate a single mod/out FFI fragment.
 * 
 * @author Sean McCauliff
 *
 */
public interface FfiFragmentGeneratorSource {

    /**
     * @return the value of this unit of work
     */
    int ccdModule();
    
    /**
     * 
     * @return the value of this unit of work
     */
    int ccdOutput();
    
    /**
     * The type of FFI returned by calibratedFfiImageHdu()
     * @return
     */
    FfiType ffiType();
    
    /**
     * This should be the HDU prefixed to the channel image by cal ffi.
     * @return a non-null primary HDU, no image.
     */
    BasicHDU primaryHdu();
    
    /**
     * This should return the same image every call.
     * @return a non-null image HDU
     */
    ImageHDU calibratedFfiImageHdu();

    ConfigMap configMap(double startMjd, double endMjd);
   
    /**
     * 
     * @param startMjd
     * @param endMjd
     * @param imageWidth
     * @param imageHeight
     * @return  this may return null if a barycentric correction could not be
     * computed.
     */
    ModOutBarycentricCorrection ffiBarycentricCorrection(
        double startMjd, double endMjd,
        int longReferenceCadence,
        int imageWidth, int imageHeight);

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return read noise in units of electrons
     */
    double readNoiseE(double startMjd, double endMjd);
    
    FileStoreClient fsClient();
    
    /**
     * 
     * @return
     */
    long piplineTaskId();

    /**
     * The timestamp of the FFI being processed.
     */
    String fileTimestamp();
    
    int skyGroupId(double startMjd, double endMjd);
    
    /**
     * Supply some fixed time so that tests will all use the same timestamp.
     * @return should always return the same non-null value.
     */
    Date generatedAt();
    
    /**
     * The per mod/out mean black.
     * @return in units of counts
     */
    double meanBlackCounts(double startMjd, double endMjd);
    
    SipWcsCoordinates sipWcs( double startMjd, double endMjd,
        int longReferenceCadence,
        int imageWidth, int imageHeight);
    
}
