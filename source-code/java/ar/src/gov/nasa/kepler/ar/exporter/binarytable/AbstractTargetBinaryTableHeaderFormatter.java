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

package gov.nasa.kepler.ar.exporter.binarytable;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;

import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;

import java.io.IOException;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

public abstract class AbstractTargetBinaryTableHeaderFormatter 
    extends AbstractBinaryTableHeaderFormatter {

    /**
     * 
     * @param h
     * @param source
     * @param celestialWcs  This may be null if there none of the columns are
     * in image format.
     * @throws FitsException
     * @throws IOException
     */
    protected Header formatHeader(BaseTargetBinaryTableHeaderSource source,
        CelestialWcsKeywordValueSource celestialWcs, ArrayDimensions arrayDims) 
        throws HeaderCardException {
        
        Header h = super.basicBinaryTableHeader(source, celestialWcs, arrayDims);
        h.addValue(TELESCOP_KW, TELESCOP_VALUE, TELESCOP_COMMENT);
        h.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        addObjectKeyword(h, source.keplerId(), source.isK2());
        h.addValue(KEPLERID_KW, source.keplerId(), KEPLERID_COMMENT);
        h.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        addRaObj(h, source.raDegrees());
        addDecObj(h, source.decDegrees());
        addEquinoxKeyword(h);
        addBarycentricTimeKeywords(source, h);
        addReadoutKeywords(source, h);
        addFixedOffsetKeywords(source, h);
        safeAdd(h, CDPP3_0_KW, source.cdpp3Hr(), CDPP3_0_COMMENT);
        safeAdd(h, CDPP6_0_KW, source.cdpp6Hr(), CDPP6_0_COMMENT);
        safeAdd(h, CDPP12_0_KW, source.cdpp12Hr(), CDPP12_0_COMMENT);
        if (source.isSingleQuarter()) {
            safeAdd(h, CROWDSAP_KW, source.crowding(), CROWDSAP_COMMENT, CROWDSAP_FORMAT);
            safeAdd(h, FLFRCSAP_KW, source.fluxFractionInOptimalAperture(), FLFRCSAP_COMMENT, FLFRCSAP_FORMAT);
        }
        
        
        return h;
    }

    
}
