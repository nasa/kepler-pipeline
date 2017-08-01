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


import gov.nasa.kepler.ar.exporter.CollateralParameterSource;
import gov.nasa.kepler.common.FfiType;

import java.util.Date;


/**
 * Source information for generating the primary FFI header.
 * 
 * @author Sean McCauliff
 *
 */
interface FfiPrimaryHeaderFormatterSource extends CollateralParameterSource {

    Date generatedAt();

    long pipelineTaskId();

    String programName();

    String subversionUrl();

    String subversionRevision();
    
    /**
     * Get this from the config map for this FFI.
     * @return
     */
    String datasetName();

    /**
     * Get this from the config map for this FFI.
     * @return
     */
    String dataCollectionTime();

    FfiType imageType();

    int quarter();

    int season();

    /**
     * Get this from the DMC's raw FFI.
     * @return
     */
    boolean isFinePoint();

    /**
     * Get this from the DMC's raw FFI.
     * @return
     */
    boolean isMomemtumDump();

    /**
     * Get this from the DMC's raw FFI.
     * @return
     */
    int configMapId();

    /**
     * Get this from the DMC's raw FFI.
     * @return
     */
    boolean isReverseClocked();

    /**
     * Get this from the DMC's raw FFI.
     * @return
     */
    double operatingTemp();

    /**
     * Parameter for spacecraft pointing.  Get this from the DMC's raw FFI.
     * @return
     */
    double[] focusingPosition();

    /**
     * Parameter for spacecraft pointing.  Get this from the DMC's raw FFI.
     * @return
     */
    double boresightRaDeg();

    /**
     * Parameter for spacecraft pointing.  Get this from the DMC's raw FFI.
     * @return
     */
    double boresightDecDeg();

    /**
     * Parameter for spacecraft pointing.  Get this from the DMC's raw FFI.
     * @return
     */
    double boresightRollDeg();

    /**
     * This is the formatted CHECKSUM keyword value as specified by the FITS checksum
     * proposal.
     * @return non-null
     */
    String checksumString();
    
    int dataReleaseNumber();
    
    boolean isK2();
    
    int k2Campaign();
    
}
