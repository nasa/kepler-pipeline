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

/**
 * Data needed for creating a FFI image HDU header.  This assumes that all 
 * coordinates are given in a zero-based coordinate system unlike
 * the FITS image.
 * 
 * @author Sean McCauliff
 *
 */
interface FfiImageHeaderSource {

    int imageWidth();

    int imageHeight();

    int ccdModule();

    int ccdOutput();

    int ccdChannel();

    int skyGroup();

    /**
     * The start time of FFI data collection.
     * @return
     */
    double startMjd();
    
    /**
     * The end time of FFI data collection.
     * @return
     */
    double endMjd();

    Double barycentricStart();

    Double barycentricEnd();

    double elaspedTimeDays();

    double exposureDays();

    double deadC();

    double integrationTimeSec();

    double readTimeMilliSec();

    double frameTimeSec();

    double  timeResolutionOfDataDays();

    /**
     * The universal time of the start of the observation period for this image.
     * @return May not be null.
     */
    Date observationStartUT();

    /**
     * The universal time of the end of the observation period for this image.
     * @return May not be null.
     */
    Date observationEndUT();

    /**
     * The reference ccd column used to calculate the barycentric time correction.
     * @return
     */
    Double barycentricCorrectionReferenceColumn();

    /**
     * The reference ccd row used to calculate the barycentric time correction.
     * @return
     */
    Double barycentricCorrectionReferenceRow();

    /**
     * The barycentric time correction in days at the reference row and column.
     *   All of these are specified by other  keyword values.
     * @return
     */
    Float barycentricCorrection();

    /**
     * CCD read noise in e-
     * @return
     */
    double readNoiseE();

    /**
     * The number of coadds in this image.
     * @return
     */
    int readsPerImage();

    int timeSlice();

    double meanBlackCounts();

    /**
     * ASCII formatted checksum as described in the FITS checksum proposal.
     * @return  non-null
     */
    String checksumString();

    /**
     * The date to use in the checksum keyword comment.  This must always 
     * return the same value.
     * @return non-null
     */
    Date generatedAt();

    double livetimeDays();

    int nIntegrationsCoaddedPerFfiImage();

    double fgsFrameTimeMilliS();

    int nFgsFramesPerIntegration();
  
    boolean isK2();

}
