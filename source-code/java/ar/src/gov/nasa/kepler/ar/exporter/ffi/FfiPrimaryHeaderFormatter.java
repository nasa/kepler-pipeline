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

import gov.nasa.kepler.ar.exporter.FitsFileCreationTimeFormat;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import static gov.nasa.kepler.common.FitsUtils.*;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.spiffy.common.lang.StringUtils.truncate;

/**
 * Formats the primary header of the an FFI (full frame image).
 * @author Sean McCauliff
 *
 */
class FfiPrimaryHeaderFormatter {

    Header formatHeader(FfiPrimaryHeaderFormatterSource source) throws HeaderCardException {
        Header h = new Header();
        
        h.addValue(SIMPLE_KW, SIMPLE_VALUE, SIMPLE_COMMENT);
        h.addValue(BITPIX_KW, 8, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 0, NAXIS_COMMENT);
        h.addValue(EXTEND_KW, EXTEND_VALUE, EXTEND_COMMENT);
        h.addValue(NEXTEND_KW, 84, NEXTEND_COMMENT);
        h.addValue(EXTNAME_KW, "PRIMARY", EXTNAME_COMMENT);
        h.addValue(EXTVER_KW, 1, EXTVER_COMMENT);
        h.addValue(ORIGIN_KW, ORIGIN_VALUE, ORIGIN_COMMENT);
        
        FitsFileCreationTimeFormat creationTime = new FitsFileCreationTimeFormat();
        String creationTimeStr = creationTime.format(source.generatedAt());
        h.addValue(DATE_KW, creationTimeStr, DATE_COMMENT);
        String creatorStr = source.pipelineTaskId() + " " + source.programName();
        h.addValue(CREATOR_KW, truncate(creatorStr, CREATOR_LENGTH), CREATOR_COMMENT);
        String procVerStr = source.subversionUrl() + " r" + source.subversionRevision();
        h.addValue(PROCVER_KW, truncate(procVerStr,PROCVER_LENGTH), PROCVER_COMMENT);

        h.addValue(FILEVER_KW, "3.1", FILEVER_COMMENT);
        h.addValue(TIMVERSN_KW, "OGIP/93-003", TIMVERSN_COMMENT);
        h.addValue(TELESCOP_KW, TELESCOP_VALUE, TELESCOP_COMMENT);
        h.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        h.addValue(DATA_REL_KW, source.dataReleaseNumber(), DATA_REL_COMMENT);
        h.addValue(OBSMODE_KW, ObservingMode.FULL_FRAME_IMAGE.toFitsKeywordValue(), OBSMODE_COMMENT);
        if (source.isK2()) {
        	h.addValue(DATSETNM_KW, source.datasetName().replace("kplr", "ktwo"), DATSETNM_COMMENT);
        } else {
        	h.addValue(DATSETNM_KW, source.datasetName(), DATSETNM_COMMENT);
        }
        h.addValue(DCT_TIME_KW, source.dataCollectionTime(), DCT_TIME_COMMENT);
        h.addValue(DCT_TYPE_KW, DCT_TYPE_VALUE, DCT_TYPE_COMMENT);
        h.addValue(DCT_PURP_KW, DCT_PURP_VALUE, DCT_PURP_COMMENT);
        h.addValue(IMAGTYPE_KW, source.imageType().toFitsImageType(), IMAGTYPE_COMMENT);
        if (source.isK2()) {
            h.addValue(CAMPAIGN_KW, source.k2Campaign(), CAMPAIGN_COMMENT);
        } else {
            h.addValue(QUARTER_KW, source.quarter(), QUARTER_COMMENT);
        }
        if (!source.isK2()) {
            h.addValue(SEASON_KW, source.season(), SEASON_COMMENT);
        }
        h.addValue(FINE_PNT_KW, source.isFinePoint(), FINE_PNT_COMMENT);
        h.addValue(MMNTMDMP_KW, source.isMomemtumDump(), MMNTMDMP_COMMENT);
        h.addValue(SCCONFIG_KW, source.configMapId(), SCCONFIG_COMMENT);
        h.addValue(PIXELTYP_KW, PIXELTYPEnum.ALL.toFitsKeywordValue(), PIXELTYP_COMMENT);
        h.addValue(REV_CLCK_KW, source.isReverseClocked(), REV_CLCK_COMMENT);
        h.addValue(VSMRSROW_KW, source.virtualSmearRowStart(), VSMRSROW_COMMENT);
        h.addValue(VSMREROW_KW, source.virtualSmearRowEnd(), VSMREROW_COMMENT);
        h.addValue(NROWVSMR_KW, source.nVirtualSmearRowBins(), NROWVSMR_COMMENT);
        h.addValue(VSMRSCOL_KW, source.virtualSmearColumnStart(), VSMRSCOL_COMMENT);
        h.addValue(VSMRECOL_KW, source.virtualSmearColumnEnd(), VSMRECOL_COMMENT);
        h.addValue(NCOLVSMR_KW, source.nVirtualSmearColumns(), NCOLVSMR_COMMENT);
        h.addValue(MASKSROW_KW, source.maskedSmearRowStart(), MASKSROW_COMMENT);
        h.addValue(MASKEROW_KW, source.maskedSmearRowEnd(), MASKEROW_COMMENT);
        h.addValue(NROWMASK_KW, source.nMaskedSmearRowBins(), NROWMASK_COMMENT);
        h.addValue(MASKSCOL_KW, source.maskedSmearColumnStart(), MASKSCOL_COMMENT);
        h.addValue(MASKECOL_KW, source.maskedSmearColumnEnd(), MASKECOL_COMMENT);
        h.addValue(NCOLMASK_KW, source.nMaskedSmearColumns(), NCOLMASK_COMMENT);
        h.addValue(BLCKSROW_KW, source.blackRowStart(), BLCKSROW_COMMENT);
        h.addValue(BLCKEROW_KW, source.blackRowEnd(), BLCKECOL_COMMENT);
        h.addValue(NROWBLCK_KW, source.nBlackRows(), NROWBLCK_COMMENT);
        h.addValue(BLCKSCOL_KW, source.blackColumnStart(), BLCKSCOL_COMMENT);
        h.addValue(BLCKECOL_KW, source.blackColumnEnd(), BLCKECOL_COMMENT);
        h.addValue(NCOLBLK_KW, source.nBlackColumnBins(), NCOLBLK_COMMENT);
        h.addValue(OPERTEMP_KW, source.operatingTemp(), OPERTEMP_COMMENT);
        h.addValue(FOCPOS1_KW, source.focusingPosition()[0], FOCPOS1_COMMENT);
        h.addValue(FOCPOS2_KW, source.focusingPosition()[1], FOCPOS2_COMMENT);
        h.addValue(FOCPOS3_KW, source.focusingPosition()[2], FOCPOS3_COMMENT);
        h.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        addEquinoxKeyword(h);
        h.addValue(RA_NOM_KW, source.boresightRaDeg(), RA_NOM_COMMENT);
        h.addValue(DEC_NOM_KW, source.boresightDecDeg(), DEC_NOM_COMMENT);
        h.addValue(ROLL_NOM_KW, source.boresightRollDeg(), ROLL_NOM_COMMENT);
        if (source.isK2()) {
            h.addValue(MISSION_KW, MISSION_VALUE_K2, MISSION_COMMENT);
        } else {
            h.addValue(MISSION_KW, MISSION_VALUE_KEPLER, MISSION_COMMENT);
        }
        addChecksum(h, source.checksumString(), source.generatedAt());
        
        
        return h;
    }
}
