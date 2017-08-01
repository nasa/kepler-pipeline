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
 * Extracts keywords from the primary header.
 * 
 * @author Sean McCauliff
 *
 */
class FfiPrimaryHeaderKeywordExtractor  {

    private final double boresightRollDeg;
    private final double boresightRaDeg;
    private final double boresightDecDeg;
    private final double[] focus = new double[3];
    private final boolean reverseClocked;
    private final int configMapId;
    
    private final CommonKeywordsExtractor common;
    //useless DMC keywords
    private final String datasetName;
    private final String dataCollectionTime;
    

    
    @SuppressWarnings("deprecation")
    FfiPrimaryHeaderKeywordExtractor(Header primaryHeader) throws KeplerException {
        try {
            boresightRollDeg = currentOrLegacyValue(primaryHeader, ROLL_NOM_KW, ROLLANGL_KW);
            boresightRaDeg = currentOrLegacyValue(primaryHeader, RA_NOM_KW, RA_XAXIS_KW);
            boresightDecDeg = currentOrLegacyValue(primaryHeader, DEC_NOM_KW, DEC_XAXS_KW);
            
            reverseClocked = getHeaderBooleanValueChecked(primaryHeader, REV_CLCK_KW);
            
            focus[0] = safeGetDoubleField(primaryHeader, FOCPOS1_KW);
            focus[1] = safeGetDoubleField(primaryHeader, FOCPOS2_KW);
            focus[2] = safeGetDoubleField(primaryHeader, FOCPOS3_KW);
            
            datasetName = getHeaderStringValueChecked(primaryHeader, DATSETNM_KW);
            dataCollectionTime = getHeaderStringValueChecked(primaryHeader, DCT_TIME_KW);
            
            configMapId = (int) currentOrLegacyValue(primaryHeader, SCCONFIG_KW, SCCONFID_KW).doubleValue();
            
            common = new CommonKeywordsExtractor(primaryHeader);
        } catch (FitsException e) {
            throw new KeplerException("Unable to create extractor.", e);
        }
    }
    
    public CommonKeywordsExtractor common() {
        return common;
    }
    
    public int configMapId() {
        return configMapId;
    }
    
    public double boresightRollDeg() {
        return boresightRollDeg;
    }
    
    public double boresightDecDeg() {
        return boresightDecDeg;
    }
    
    public double boresightRaDeg() {
        return boresightRaDeg;
    }
    
    public boolean reverseClocked() {
        return reverseClocked;
    }
    
    public double[] focuserPositions() {
        return focus;
    }
    
    public String datasetName() {
        return datasetName;
    }
    
    /**
     * Don't use this for any kind of computation that matters.
     * @return
     */
    public String dataCollectionTime() {
        return dataCollectionTime;
    }
    
    
}
