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

package gov.nasa.kepler.ar.exporter.collateral;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;
import static gov.nasa.kepler.common.FitsUtils.addDateObsKeywords;
import gov.nasa.kepler.ar.exporter.binarytable.AbstractBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;


abstract class CollateralPixelBinaryTableHeaderFormatter 
    extends AbstractBinaryTableHeaderFormatter {
    
    protected final static Float64Column mjdTimeColumn = 
            new Float64Column(MJD_TIME_TCOLUMN, MJD_TIME_TCOLUMN_COMMENT, MJD_TIME_TCOLUMN_DISPLAY_HINT, MJD_TIME_TCOLUMN_UNIT, MJD_TIME_TCOLUMN_UNIT_COMMENT);
    
    public Header formatHeader(CollateralPixelBinaryTableHeaderSource source, String checksum, ArrayDimensions arrayDimensions) throws HeaderCardException {

        Header h = super.basicBinaryTableHeader(source, null, arrayDimensions);
        addCommonTimeKeywords(source, h);
        addReadoutKeywords(source, h);
        addFixedOffsetKeywords(source, h);

        addDateObsKeywords(h, source.observationStartUTC(), source.observationEndUTC());

        
        if (source.printVirtualSmearCoordinates()) {
            h.addValue(VSMRSROW_KW, source.virtualSmearRowStart(), VSMRSROW_COMMENT);
            h.addValue(VSMREROW_KW, source.virtualSmearRowEnd(), VSMREROW_COMMENT);
            h.addValue(NROWVSMR_KW, source.nVirtualSmearRowBins(), NROWVSMR_COMMENT);
            h.addValue(VSMRSCOL_KW, source.virtualSmearColumnStart(), VSMRSCOL_COMMENT);
            h.addValue(VSMRECOL_KW, source.virtualSmearColumnEnd(), VSMRECOL_COMMENT);
            h.addValue(NCOLVSMR_KW, source.nVirtualSmearColumns(), NCOLVSMR_COMMENT);
        }
        if (source.printMaskedSmearCoordinates()) {
            h.addValue(MASKSROW_KW, source.maskedSmearRowStart(), MASKSROW_COMMENT);
            h.addValue(MASKEROW_KW, source.maskedSmearRowEnd(), MASKEROW_COMMENT);
            h.addValue(NROWMASK_KW, source.nMaskedSmearRowBins(), NROWMASK_COMMENT);
            h.addValue(MASKSCOL_KW, source.maskedSmearColumnStart(), MASKSCOL_COMMENT);
            h.addValue(MASKECOL_KW, source.maskedSmearColumnEnd(), MASKECOL_COMMENT);
            h.addValue(NCOLMASK_KW, source.nMaskedSmearColumns(), NCOLMASK_COMMENT);
        }
        if (source.printBlackCollateralCoordinates()) {
            h.addValue(BLCKSROW_KW, source.blackRowStart(), BLCKSROW_COMMENT);
            h.addValue(BLCKEROW_KW, source.blackRowEnd(), BLCKECOL_COMMENT);
            h.addValue(NROWBLCK_KW, source.nBlackRows(), NROWBLCK_COMMENT);
            h.addValue(BLCKSCOL_KW, source.blackColumnStart(), BLCKSCOL_COMMENT);
            h.addValue(BLCKECOL_KW, source.blackColumnEnd(), BLCKECOL_COMMENT);
            h.addValue(NCOLBLK_KW, source.nBlackColumnBins(), NCOLBLK_COMMENT);
        }
        
        addChecksum(h, checksum, source.generatedAt());
        
        return h;
    }
    
    abstract String extensionName();
    
    abstract String pixelListExtensionName();
    
    abstract String pixelListColumnType();
    
    abstract String pixelListColumnTypeComment();
    
}
