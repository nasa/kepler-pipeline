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

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SipWcsCoordinates;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;

/**
 * Generate the header part of a single FFI image.
 * @author Sean McCauliff
 *
 */
public class FfiImageHeaderFormatter {

    /**
     * 
     * @param source
     * @param sipWcs  this may be null in which case the WCS keywords will not
     * be generated
     * @return A non-null header populated with the correct keywords and values.
     * @throws HeaderCardException
     */
    public Header formatImageHeader(FfiImageHeaderSource source, SipWcsCoordinates sipWcs) throws HeaderCardException {
        
        
        Header h = new Header();
        h.addValue(XTENSION_KW, XTENSION_IMAGE_VALUE, XTENSION_COMMENT);
        h.addValue(BITPIX_KW, BITPIX_SINGLE_PRECISION_IMAGE, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 2, NAXIS_KW);
        h.addValue(NAXIS1_KW, source.imageWidth(), NAXIS1_COMMENT);
        h.addValue(NAXIS2_KW, source.imageHeight(), NAXIS2_COMMENT);
        h.addValue(PCOUNT_KW, PCOUNT_VALUE, PCOUNT_COMMENT);
        h.addValue(GCOUNT_KW, GCOUNT_VALUE, GCOUNT_COMMENT);
        h.addValue(INHERT_KW, INHERIT_VALUE, INHERIT_COMMENT);
        h.addValue(EXTNAME_KW, "MOD.OUT " + source.ccdModule() + "." + source.ccdOutput(), EXTNAME_COMMENT);
        h.addValue(EXTVER_KW, 1, EXTVER_COMMENT);
        h.addValue(TELESCOP_KW, TELESCOP_VALUE, TELESCOP_COMMENT);
        h.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        h.addValue(CHANNEL_KW, source.ccdChannel(), CHANNEL_COMMENT);
        if (!source.isK2()) {
            h.addValue(SKYGROUP_KW, source.skyGroup(), SKYGROUP_COMMENT);
        }
        h.addValue(MODULE_KW, source.ccdModule(), MODULE_COMMENT);
        h.addValue(OUTPUT_KW, source.ccdOutput(), OUTPUT_COMMENT);
        h.addValue(TIMEREF_KW, TIMEREF_VALUE, TIMEREF_COMMENT);
        h.addValue(TASSIGN_KW, TASSIGN_VALUE, TASSIGN_COMMENT);
        h.addValue(TIMESYS_KW, TIMESYS_VALUE, TIMESYS_COMMENT);
        h.addValue(MJDSTART_KW,source.startMjd(), MJDSTART_COMMENT);
        h.addValue(MJDEND_KW, source.endMjd(), MJDEND_COMMENT);
        h.addValue(BJDREFI_KW, ModifiedJulianDate.kjdReferenceIntegerPart(), BJDREFI_COMMENT);
        safeAdd(h, BJDREFF_KW, ModifiedJulianDate.kjdReferenceFractionalPart(), BJDREFF_COMMENT, BJDREFF_FORMAT);
        h.addValue(TIMEUNIT_KW, TIMEUNIT_VALUE, TIMEUNIT_COMMENT);
        safeAdd(h, TSTART_KW, source.barycentricStart(), TSTART_COMMENT, TSTART_FORMAT);
        safeAdd(h, TSTOP_KW, source.barycentricEnd(), TSTOP_COMMENT, TSTOP_FORMAT);
        safeAdd(h, TELAPSE_KW, source.elaspedTimeDays(), TELAPSE_COMMENT, TELAPSE_FORMAT);
        safeAdd(h, EXPOSURE_KW, source.exposureDays(), EXPOSURE_COMMENT, EXPOSURE_FORMAT);
        safeAdd(h, LIVETIME_KW, source.livetimeDays(), LIVETIME_COMMENT, LIVETIME_FORMAT);
        safeAdd(h, DEADC_KW, source.deadC(), DEADC_COMMENT, DEADC_FORMAT);
        safeAdd(h, TIMEPIXR_KW, TIMEPIXR_VALUE, TIMEPIXR_COMMENT);
        safeAdd(h, TIERRELA_KW, TIERRELA_VALUE, TIERRELA_COMMENT, TIERRELA_FORMAT);
        safeAdd(h, INT_TIME_KW, source.integrationTimeSec(), INT_TIME_COMMENT, INT_TIME_FORMAT);
        safeAdd(h, READTIME_KW, source.readTimeMilliSec(), READTIME_COMMENT, READTIME_FORMAT);
        safeAdd(h, FRAMETIM_KW, source.frameTimeSec(), FRAMETIM_COMMENT);
        safeAdd(h, NUM_FRM_KW, source.nIntegrationsCoaddedPerFfiImage(), NUM_FRM_COMMENT);
        safeAdd(h, FGSFRPER_KW, source.fgsFrameTimeMilliS(), FGSFRPER_COMMENT);
        safeAdd(h, NUMFGSFP_KW, source.nFgsFramesPerIntegration(), NUMFGSFP_COMMENT);
        safeAdd(h, TIMEDEL_KW, source.timeResolutionOfDataDays(), TIMEDEL_COMMENT, TIMEDEL_FORMAT);
        addDateObsKeywords(h, source.observationStartUT(), source.observationEndUT());
        safeAdd(h, BTC_PIX1_KW, source.barycentricCorrectionReferenceColumn(), BTC_PIX1_COMMENT);
        safeAdd(h, BTC_PIX2_KW, source.barycentricCorrectionReferenceRow(), BTC_PIX2_COMMENT);        
        safeAdd(h, BUNIT_KW, BUNIT_VALUE, BUNIT_COMMENT);
        safeAdd(h, BARYCORR_KW, source.barycentricCorrection(), BARYCORR_COMMENT, BARYCORR_FORMAT);
        h.addValue(BACKAPP_KW, false, BACKAPP_COMMENT);
        h.addValue(DEADAPP_KW, DEADAPP_VALUE, DEADAPP_COMMENT);
        h.addValue(VIGNAPP_KW, VIGNAPP_VALUE, VIGNAPP_COMMENT);
        safeAdd(h,READNOIS_KW, source.readNoiseE(), READNOIS_COMMENT, READNOIS_FORMAT);
        h.addValue(NREADOUT_KW, source.readsPerImage(), NREADOUT_COMMENT);
        h.addValue(TIMSLICE_KW, source.timeSlice(), TIMSLICE_COMMENT);
        h.addValue(MEANBLCK_KW, source.meanBlackCounts(), MEANBLCK_COMMENT);
        h.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        addEquinoxKeyword(h);
        
        if (sipWcs != null && sipWcs.isValid()) {
            addSipWcs(sipWcs, h);
        }
        
        addPhysicalWcs(h, 0, 0);
        
        addChecksum(h, source.checksumString(), source.generatedAt());
        
        return h;
    }

}
