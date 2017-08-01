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

package gov.nasa.kepler.ar.exporter.primary;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addDecObj;
import static gov.nasa.kepler.common.FitsUtils.addEquinoxKeyword;
import static gov.nasa.kepler.common.FitsUtils.addObjectKeyword;
import static gov.nasa.kepler.common.FitsUtils.addRaObj;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.AV;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.D51MAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.EBMINUSV;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.FEH;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.GKCOLOR;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.GLAT;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.GLON;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.GMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.GRCOLOR;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.HMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.IMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.JKCOLOR;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.JMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.KEPMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.KMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.LOGG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.PARALLAX;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.PMDEC;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.PMRA;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.PMTOTAL;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.RADIUS;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.RMAG;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.SCPID;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.TEFF;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.TMID;
import static gov.nasa.kepler.hibernate.cm.Kic.Field.ZMAG;
import static gov.nasa.spiffy.common.lang.StringUtils.truncate;
import gov.nasa.kepler.ar.exporter.FitsFileCreationTimeFormat;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * The exciting primary HDU header for a collateral pixel file.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class PrimaryHeaderFormatter {

    public static final int NO_KEPLER_ID = -1;
    public static final int NO_TTABLE_ID = -1;
    
    /**
     * 
     * @param source a non-null source
     * @param checksumString a non-null checksum string
     * @return header with all the required keywords populated.
     * @throws HeaderCardException 
     */
    protected Header formatHeader(BasePrimaryHeaderSource source) throws HeaderCardException {
        Header h = new Header();
        
        h.addValue(SIMPLE_KW, SIMPLE_VALUE, SIMPLE_COMMENT);
        h.addValue(BITPIX_KW, 8, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 0, NAXIS_COMMENT);
        h.addValue(EXTEND_KW, EXTEND_VALUE, EXTEND_COMMENT);
        h.addValue(NEXTEND_KW, source.extensionHduCount(), NEXTEND_COMMENT);
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
        h.addValue(FILEVER_KW, fileVersion(), FILEVER_COMMENT);
        h.addValue(TIMVERSN_KW, TIMVERSN_VALUE, TIMVERSN_COMMENT);
        h.addValue(TELESCOP_KW, TELESCOP_VALUE, TELESCOP_COMMENT);
        h.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        if (source.keplerId() != NO_KEPLER_ID) {
            addObjectKeyword(h, source.keplerId(), source.isK2Target());
            h.addValue(KEPLERID_KW, source.keplerId(), KEPLERID_COMMENT);
        }
        
        //Should consolidate all these keywords into K2/Kepler single quarter
        //vs multi quarter.
        if (source.targetTableId() != NO_TTABLE_ID) {
            h.addValue(CHANNEL_KW, source.ccdChannel(), CHANNEL_COMMENT);
        }
        if (!source.isK2Target()) {
            safeAdd(h,SKYGROUP_KW, source.skyGroup(), SKYGROUP_COMMENT);
        }
        
        if (source.targetTableId() != NO_TTABLE_ID) {
            h.addValue(MODULE_KW, source.ccdModule(), MODULE_COMMENT);
            h.addValue(OUTPUT_KW, source.ccdOutput(), OUTPUT_COMMENT);
        }
        if (source.isK2Target()) {
            h.addValue(CAMPAIGN_KW, source.k2Campaign(), CAMPAIGN_COMMENT);
        } else if (source.targetTableId() != NO_TTABLE_ID){
            h.addValue(QUARTER_KW, source.quarter(), QUARTER_COMMENT);
        }
        if (!source.isK2Target() && source.targetTableId() != NO_KEPLER_ID) {
            h.addValue(SEASON_KW, source.season(), SEASON_COMMENT);
        }
        h.addValue(DATA_REL_KW, source.dataReleaseNumber(), DATA_REL_COMMENT);
        h.addValue(OBSMODE_KW, source.observingMode().toFitsKeywordValue(), OBSMODE_COMMENT);
        if (source.isK2Target()) {
            h.addValue(MISSION_KW, MISSION_VALUE_K2, MISSION_COMMENT);
        } else {
            h.addValue(MISSION_KW, MISSION_VALUE_KEPLER, MISSION_COMMENT);
        }
        if (source.targetTableId() != NO_TTABLE_ID) {
            h.addValue(TTABLEID_KW, source.targetTableId(), TTABLEID_COMMENT);
        }
        
        return h;
    }
    

    protected void addCelestialObjectKeyWords(Header h,
        CelestialObject kic, double raDegrees, boolean isK2Target) throws HeaderCardException {
        h.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        addRaObj(h, raDegrees);
        addDecObj(h, kic.getDec());
        addEquinoxKeyword(h);
        safeAdd(h, PMRA_KW, kic.getRaProperMotion(), PMRA_COMMENT, PMRA.getFormat());
        safeAdd(h, PMDEC_KW, kic.getDecProperMotion(), PMDEC_COMMENT, PMDEC.getFormat());
        safeAdd(h, PMTOTAL_KW, kic.getTotalProperMotion(), PMTOTAL_COMMENT, PMTOTAL.getFormat());
        safeAdd(h, PARALLAX_KW, kic.getParallax(), PARALLAX_COMMENT, PARALLAX.getFormat());
        safeAdd(h, GLON_KW, kic.getGalacticLongitude(), GLON_COMMENT, GLON.getFormat());
        safeAdd(h, GLAT_KW, kic.getGalacticLatitude(), GLAT_COMMENT, GLAT.getFormat());
        safeAdd(h, GMAG_KW, kic.getGMag(), GMAG_COMMENT, GMAG.getFormat());
        safeAdd(h, RMAG_KW, kic.getRMag(), RMAG_COMMENT, RMAG.getFormat());
        safeAdd(h, IMAG_KW, kic.getIMag(), IMAG_COMMENT, IMAG.getFormat());
        safeAdd(h, ZMAG_KW, kic.getZMag(), ZMAG_COMMENT, ZMAG.getFormat());
        if (!isK2Target) {
            safeAdd(h, D51MAG_KW, kic.getD51Mag(), D51MAG_COMMENT, D51MAG.getFormat());
        }
        safeAdd(h, JMAG_KW, kic.getTwoMassJMag(), JMAG_COMMENT, JMAG.getFormat());
        safeAdd(h, HMAG_KW, kic.getTwoMassHMag(), HMAG_COMMENT, HMAG.getFormat());
        safeAdd(h, KMAG_KW, kic.getTwoMassKMag(), KMAG_COMMENT, KMAG.getFormat());
        safeAdd(h, KEPMAG_KW, kic.getKeplerMag(), KEPMAG_COMMENT, KEPMAG.getFormat());
        safeAdd(h, GRCOLOR_KW, kic.getGrColor(), GRCOLOR_COMMENT, GRCOLOR.getFormat());
        safeAdd(h, JKCOLOR_KW, kic.getJkColor(), JKCOLOR_COMMENT, JKCOLOR.getFormat());
        safeAdd(h, GKCOLOR_KW, kic.getGkColor(), GKCOLOR_COMMENT, GKCOLOR.getFormat());
        safeAdd(h, TEFF_KW, kic.getEffectiveTemp(), TEFF_COMMENT, TEFF.getFormat());
        safeAdd(h, LOGG_KW, kic.getLog10SurfaceGravity(), LOGG_COMMENT, LOGG.getFormat());
        safeAdd(h, FEH_KW, kic.getLog10Metallicity(), FEH_COMMENT, FEH.getFormat());
        safeAdd(h, EBMINUSV_KW, kic.getEbMinusVRedding(), EBMINUSV_COMMENT, EBMINUSV.getFormat());
        safeAdd(h, AV_KW, kic.getAvExtinction(), AV_COMMENT, AV.getFormat());
        safeAdd(h, RADIUS_KW, kic.getRadius(), RADIUS_COMMENT, RADIUS.getFormat());
        safeAdd(h, TMINDEX_KW, kic.getTwoMassId(), TMINDEX_COMMENT, TMID.getFormat());
        if (!isK2Target) {
            safeAdd(h, SCPID_KW, kic.getScpId(), SCPID_COMMENT, SCPID.getFormat());
        }
    }

    protected abstract String fileVersion();
    
}
