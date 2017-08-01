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

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;
import gov.nasa.kepler.mc.KeplerException;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * Extract keywords in common to image headers and primary ffi
 * headers.  Some keywords are present in the old FFI images, others are
 * present only in the new images.
 * 
 * @author Sean McCauliff
 *
 */
class CommonKeywordsExtractor {

    //These variables are not final because the compiler is not able to prove
    //they are only assigned to one time; either there was an exception that
    //assigned it or else it was assinged in the catch block.
    private Boolean finePoint;
    private Boolean momentiumDump;
    private Double startMjd;
    private Double endMjd;
    private Integer longCadence;
    
    /**
     * 
     * @param header  this can be a primary header or an image header.
     * @throws KeplerException
     */
    CommonKeywordsExtractor(Header header)  {
        try {
            finePoint = getHeaderBooleanValueChecked(header, FINE_PNT_KW);
        } catch (FitsException e) {
            finePoint = null;
        }
        
        try {
            momentiumDump = getHeaderBooleanValueChecked(header, MMNTMDMP_KW);
        } catch (FitsException e) {
            momentiumDump = null;
        }
        try {
            longCadence = getHeaderIntValueChecked(header, LC_INTER_KW);
        } catch (FitsException e) {
            longCadence = null;
        }
        
        startMjd = currentOrLegacyValue(header, MJDSTART_KW, STARTIME_KW);
        endMjd = currentOrLegacyValue(header, MJDEND_KW, END_TIME_KW);
        
    }
    
    public Double startMjd() {
        return startMjd;
    }
    
    public Double endMjd() {
        return endMjd;
    }
    
    
    public Boolean finePoint() {
        return finePoint;
    }
    
    public Boolean momentiumDump() {
        return momentiumDump;
    }
    
    public Integer longCadence() {
        return longCadence;
    }
    
}
