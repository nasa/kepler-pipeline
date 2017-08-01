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

import java.util.Date;

/**
 * @author Sean McCauliff
 *
 */
public interface ApertureMaskSource {

    int keplerId();

    double raDegrees();
    
    double decDegrees();
    
    /**
     * The number of columns in the image. The value if NAXIS1.
     * @return  Must be non-negative.
     */
    int nColumns();
    
    /**
     * The number of rows in the image.  The value of NAXIS2.
     * @return Must be non-negative.
     */
    int nRows();
    
    /**
     * The index of the first array dimension is the row number.  The index of the
     * second dimension is the column number.
     * @return This must be non-null.
     */
    int[][] apertureMaskImage();

    int referenceCcdRow();

    int referenceCcdColumn();
    
    /**
     * This is the value of the CHECKSUM keyword.
     * @return
     */
    String checksumString();
   
    
    /**
     * This is used in the file creation date and the CHECKSUM and DATASUM 
     * keyword comments.  This should return the same value if called multiple
     * times.
     * @return
     */
    Date generatedAt();
    
    /**
     * Number of pixels in the optimal aperture.
     */
    int nPixelsInOptimalAperture();
    
    /**
     * There where pixels identified by TAD that where not collected by the
     * spacecraft.
     * @return
     */
    int nPixelsMissingInOptimalAperture();

    
    /**
     * Flux fraction in optimal aperture.  This is the amount of flux due to the
     * target in the optimal aperture.
     */
    double fluxFractionInOptimalApertuire();

    boolean isK2();
}
