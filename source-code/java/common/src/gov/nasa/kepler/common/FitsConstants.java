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

package gov.nasa.kepler.common;

import gov.nasa.kepler.common.Cadence.CadenceType;

import java.util.*;

/**
 * These are FITS (Flexible Image Transport System) related constants.  Most of them are related to
 * keywords that appear in a HDU.  In this case the the keyword constant should end with _KW
 * the related comment should end with _COMMENT.  If a keyword has some constant value then the 
 * ending should be _VALUE.  Some keywords have values that must be formatted in a particular manner.
 * Formatting constants end with _FORMAT.  There are some deprecated keywords that do not follow
 * this naming convention.
 * @author Sean McCauliff
 *
 */
public abstract class FitsConstants {

    /** This is the maximum length of a FITS keyword value.
     */
    public static final int MAX_KEYWORD_VALUE_LENGTH = 71;
    
    /** The maximum length of a full line comment. */
    public static final int MAX_COMMENT_LENGTH = 72;
    
    public static final int MAX_KEYWORD_LENGTH = 8;
    
    public static final int HEADER_CARD_LENGTH = 80;
    
    public static final int HDU_BLOCK_SIZE = 2880;
    
    ///// These constants are sometimes useful for formatting values where type
    //// safety is needed, but we need a null.
    public static final Integer NULL_INT = null;
    public static final Float   NULL_FLOAT = null;
    public static final String  NULL_STRING = null;
    public static final Double  NULL_DOUBLE = null;
    
    //// These constants are used when formatting and parsing dates ///
    public static final String FILE_TIMESTAMP_FORMAT = "yyyyDDDHHmmss";
    
    ////////////  FITS keywords //////////
    public static final String  SIMPLE_KW = "SIMPLE";
    public static final boolean SIMPLE_VALUE = true;
    public static final String  SIMPLE_COMMENT = "conforms to FITS standards";
    
    public static final String BITPIX_KW = "BITPIX";
    public static final String BITPIX_COMMENT = "array data type";
    public static final int BITPIX_EMPTY_PRIMARY_VALUE = 8;
    public static final int BITPIX_BINTABLE_VALUE = 8;
    public static final int BITPIX_SINGLE_PRECISION_IMAGE = -32;
    
    public static final String XTENSION_KW = "XTENSION";
    public static final String XTENSION_BINTABLE_VALUE = "BINTABLE";
    public static final String XTENSION_IMAGE_VALUE  = "IMAGE";
    public static final String XTENSION_COMMENT = "marks the beginning of a new HDU";
    
    public static final String NAXIS_KW = "NAXIS";
    public static final String NAXIS_COMMENT = "number of array dimensions";
    public static final String NAXIS1_KW = "NAXIS1";
    public static final String NAXIS1_COMMENT = "length of first array dimension";
    public static final String NAXIS2_KW = "NAXIS2";
    public static final String NAXIS2_COMMENT = "length of second array dimension";
    public static final String PCOUNT_KW = "PCOUNT";
    public static final int PCOUNT_VALUE = 0;
    public static final String PCOUNT_COMMENT = "group parameter count (not used)";
    public static final String GCOUNT_KW = "GCOUNT";
    public static final int GCOUNT_VALUE = 1;
    public static final String GCOUNT_COMMENT = "group count (not used)";
    
    public static final String EXTNAME_KW = "EXTNAME";
    public static final String EXTNAME_COMMENT = "name of extension";
    public static final String EXTVER_KW = "EXTVER";
    public static final String EXTVER_COMMENT = "extension version number (not format version)";

    public static final String NEXTEND_KW = "NEXTEND";
    public static final String NEXTEND_COMMENT = "number of standard extensions";
    
    public static final String TELESCOP_KW = "TELESCOP";
    public static final String TELESCOP_VALUE = "Kepler";
    public static final String TELESCOP_COMMENT = "telescope";
    
    public static final String INSTRUME_KW = "INSTRUME";
    public static final String INSTRUME_VALUE = "Kepler Photometer";
    public static final String INSTRUME_COMMENT = "detector type";
    
    public static final String MISSION_KW = "MISSION";
    public static final String MISSION_VALUE_K2 = "K2";
    public static final String MISSION_VALUE_KEPLER = "Kepler";
    public static final String MISSION_COMMENT = "Mission name"; 
    
    public static final String CREATOR_KW = "CREATOR";
    public static final String CREATOR_COMMENT = "pipeline job and program used to produce this file";
    public static final int CREATOR_LENGTH = 64;
    
    public static final String PROCVER_KW = "PROCVER";
    public static final String PROCVER_COMMENT = "SW version";
    public static final int PROCVER_LENGTH = 64;
    
    public static final String FILEVER_KW = "FILEVER";
    public static final String FILEVER_COMMENT = "file format version";
    
    public static final String TIMVERSN_KW = "TIMVERSN";
    public static final String TIMVERSN_VALUE = "OGIP/93-003";
    public static final String TIMVERSN_COMMENT = "OGIP memo number for file format";
    
    public static final String OBJECT = "OBJECT";
    public static final String OBJECT_COMMENT = "string version of target id";
    
    public static final String KEPLERID_KW = "KEPLERID";
    public static final String KEPLERID_COMMENT = "unique Kepler target identifier";
    
    public static final String EXTEND_KW = "EXTEND";
    public static final boolean EXTEND_VALUE = true;
    public static final String EXTEND_COMMENT = "file contains extensions";
    
    public static final String ORIGIN_KW = "ORIGIN";
    public static final String ORIGIN_VALUE = "NASA/Ames";
    public static final String ORIGIN_COMMENT = "institution responsible for creating this file";
    
    public static final String DATE_KW = "DATE";
    public static final String DATE_COMMENT = "file creation date.";
    
    public static final String FILENAME_KW = "FILENAME";
    public static final String DATSETNM_KW = "DATSETNM";
    public static final String DATSETNM_COMMENT = "data set name";
    public static final String DATATYPE_KW = "DATATYPE";
    
    public static final String PIXELTYP_KW = "PIXELTYP";
    public static final String PIXELTYP_COMMENT = "pixel type: target, background, collateral, all";
    public static enum PIXELTYPEnum {
        ALL("all"),
        TARGET("target"),
        BACKGROUND("background"),
        COLLATERAL("collateral");
        
        private final String fitsKeywordValue;
        
        
        private PIXELTYPEnum(String fitsKeywordValue) {
            this.fitsKeywordValue = fitsKeywordValue;
        }
        
        public String toFitsKeywordValue() {
            return fitsKeywordValue;
        }
    }
    
    public static final String CADENNUM_KW = "CADENNUM";
    
    public static final String CADENCNO_KW = "CADENCNO";
    public static final String CADENCNO_COMMENT = "number of long cadence interval";
    
    public static final String SEFI_ACC_KW = "SEFI_ACC";
    public static final String SEFI_ACC_COMMENT = "Single Event Funtional Interrupt in accum memor";

    public static final String SEFI_CAD_KW = "SEFI_CAD";
    public static final String SEFI_CAD_COMMENT = "Single Event Funtional Interrupt in cadence mem";
    
    public static final String LDE_OOS_KW = "LDE_OOS";
    public static final String LDE_OOS_COMMENT = "Local Detector Electronics OutOfSynch reported";
    
    public static final String FINE_PNT_KW = "FINE_PNT";
    public static final String FINE_PNT_COMMENT = "fine point pointing status during accumulation";
    
    public static final String MMNTMDMP_KW = "MMNTMDMP";
    public static final String MMNTMDMP_COMMENT = "momentum dump occurred during accumulation";
    
    public static final String LDEPARER_KW = "LDEPARER";
    public static final String LDEPARER_COMMENT = "Local Detector Electronics parity error occurre";
    
    public static final String SCRC_ERR_KW = "SCRC_ERR";
    public static final String SCRC_ERR_COMMENT = "SDRAM Controller memory pixel error occurred";
    
    public static final String SCCONFIG_KW = "SCCONFIG";
    public static final String SCCONFIG_COMMENT = "commanded S/C configuration ID";
    
    public static final String CONVRGE_KW = "CONVRGE";
    public static final String CONVRGE_COMMENT = "convergence yes/no flag";

    public static final String DRRATIO_KW = "DRRATIO";
    public static final String DRRATIO_COMMENT = "ratio of planet distance to star radius";

    public static final String DVVERSN_KW = "DVVERSN";
    public static final String DVVERSN_COMMENT = "DV Subversion revision number";

    public static final String TEPOCH_KW = "TEPOCH";
    public static final String TEPOCH_COMMENT = "transit epoch in bkjd [days]";


    public static final String FILENAME_COMMENT = "the name of this file";

    public static final String IMPACT_KW = "IMPACT";
    public static final String IMPACT_COMMENT = "impact parameter";

    public static final String INCLIN_KW = "INCLIN";
    public static final String INCLIN_COMMENT = "inclination [deg]";

    public static final String INDUR_KW = "INDUR";
    public static final String INDUR_COMMENT = "ingress duration [hr]";

    public static final String MAXMES_KW = "MAXMES";
    public static final String MAXMES_COMMENT = "maximum multi-event statistic";

    public static final String MAXSES_KW = "MAXSES";
    public static final String MAXSES_COMMENT = "maximum single-event statistic";

    public static final String MEDDETR_KW = "MEDDETR";
    public static final String MEDDETR_COMMENT = "length of the median detrender filter [hours]";

    public static final String NTRANS_KW = "NTRANS";
    public static final String NTRANS_COMMENT = "number of transits for this TCE";

    public static final String NUMTCES_KW = "NUMTCES";
    public static final String NUMTCES_COMMENT = "number of TCEs found";

    public static final String TPERIOD_KW = "TPERIOD";
    public static final String TPERIOD_COMMENT = "transit period [days]";

    public static final String PRADIUS_KW = "PRADIUS";
    public static final String PRADIUS_COMMENT = "planet radius in earth radii";

    public static final String QUARTERS_KW = "QUARTERS";
    public static final String QUARTERS_COMMENT = "bit-vector string of 17 0/1 chars";

    public static final String RADRATIO_KW = "RADRATIO";
    public static final String RADRATIO_COMMENT = "ratio of planet radius to star radius";

    public static final String STID_KW = "STID";
    public static final String STID_COMMENT = "ID of the Kepler SOC pipeline task that generated these data";

    public static final String TDEPTH_KW = "TDEPTH";
    public static final String TDEPTH_COMMENT = "fitted transit depth [ppm]";

    public static final String TDUR_KW = "TDUR";
    public static final String TDUR_COMMENT = "transit duration [hr]";

    public static final String TSNR_KW = "TSNR";
    public static final String TSNR_COMMENT = "transit signal-to-noise ratio";

    public static final String XMLSTR_KW = "XMLSTR";
    public static final String XMLSTR_COMMENT = "DV XML date string";
    
    // legacy
    public static final String SCCONFID_KW = "SCCONFID";
    
    public static final String SCCONFTM_KW = "SCCONFTM";
    public static final String SCCONFTM_COMMENT = "time of S/C config. command: yyyydddhhmmss";
    
    public static final String REV_CLCK_KW = "REV_CLCK";
    public static final String REV_CLCK_COMMENT = "reverse clocking in effect?";
    
    public static final String VSMRSROW_KW = "VSMRSROW";
    public static final String VSMRSROW_COMMENT = "collateral virtual smear region start row";
    
    public static final String VSMREROW_KW = "VSMREROW";
    public static final String VSMREROW_COMMENT ="collateral virtual smear region row end";
    
    public static final String NROWVSMR_KW = "NROWVSMR";
    public static final String NROWVSMR_COMMENT = "number of rows binned in virtual smear";
    
    public static final String VSMRSCOL_KW = "VSMRSCOL";
    public static final String VSMRSCOL_COMMENT = "collateral virtual smear region start column";
    
    public static final String VSMRECOL_KW = "VSMRECOL";
    public static final String VSMRECOL_COMMENT = "collateral virtual smear region end column";
    
    public static final String NCOLVSMR_KW = "NCOLVSMR";
    public static final String NCOLVSMR_COMMENT = "number of columns in virtual smear region";
    
    public static final String MASKSROW_KW = "MASKSROW";
    public static final String MASKSROW_COMMENT = "science collateral masked region start row";
    
    public static final String MASKEROW_KW = "MASKEROW";
    public static final String MASKEROW_COMMENT = "science collateral masked region end row";
    
    public static final String NROWMASK_KW = "NROWMASK";
    public static final String NROWMASK_COMMENT = "number of rows binned in masked region";
    
    public static final String MASKSCOL_KW = "MASKSCOL";
    public static final String MASKSCOL_COMMENT = "science collateral masked region start";
    
    public static final String MASKECOL_KW = "MASKECOL";
    public static final String MASKECOL_COMMENT = "science collateral masked region end";
    
    public static final String NCOLMASK_KW = "NCOLMASK";
    public static final String NCOLMASK_COMMENT = "number of columns in masked region";
    
    public static final String BLCKSROW_KW = "BLCKSROW";
    public static final String BLCKSROW_COMMENT = "science collateral black region start row";
    
    public static final String BLCKEROW_KW = "BLCKEROW";
    public static final String BLCKEROW_COMMENT = "science collateral black region end row";
    
    public static final String NROWBLCK_KW = "NROWBLCK";
    public static final String NROWBLCK_COMMENT = "number of rows in black region";
    
    public static final String BLCKSCOL_KW = "BLCKSCOL";
    public static final String BLCKSCOL_COMMENT = "science collateral black region start";
    
    public static final String BLCKECOL_KW = "BLCKECOL";
    public static final String BLCKECOL_COMMENT = "science collateral black region end column";
    
    public static final String NCOLBLK_KW = "NCOLBLK";
    public static final String NCOLBLK_COMMENT = "number of columns binned in black region";
    
    public static final String OPERTEMP_KW = "OPERTEMP";
    public static final String OPERTEMP_COMMENT = "[C] commanded FPA temperature set point";
    
    public static final String FOCPOS1_KW = "FOCPOS1";
    public static final String FOCPOS1_COMMENT = "[microns] mechanism 1 focus position";
    
    public static final String FOCPOS2_KW = "FOCPOS2";
    public static final String FOCPOS2_COMMENT = "[microns] mechanism 2 focus position";
    
    public static final String FOCPOS3_KW = "FOCPOS3";
    public static final String FOCPOS3_COMMENT = "[microns] mechanism 3 focus position";
    
    public static final String MODULE_KW = "MODULE";
    public static final String MODULE_COMMENT = "CCD module";
    public static final String OUTPUT_KW = "OUTPUT";
    public static final String OUTPUT_COMMENT = "CCD output";
    public static final String CHANNEL_KW = "CHANNEL";
    public static final String CHANNEL_COMMENT = "CCD channel";
    public static final String SKYGROUP_KW = "SKYGROUP";
    public static final String SKYGROUP_COMMENT = "roll-independent location of channel";
    
    /**
     * The external id of the target table that is associated with this HDU.
     */
    public static final String TTABLEID_KW = "TTABLEID";
    public static final String TTABLEID_COMMENT = "target table id";

    /** The version of this data release. */
    public static final String DATA_REL_KW = "DATA_REL";
    public static final String DATA_REL_COMMENT = "data release version number";
    
    /** This value will be replaced by another tool. */
    public static final String DATA_REL_VALUE = "REPLACEME";
    
    /** The name of the release quarter. */
    public static final String QUARTER_KW = "QUARTER";
    public static final String QUARTER_VALUE = "REPLACEME";
    public static final String QUARTER_COMMENT = "Observing quarter";
    
    public static final String SEASON_KW = "SEASON";
    public static final String SEASON_COMMENT = "mission season during which data was collected";
    
    public static final String CAMPAIGN_KW = "CAMPAIGN";
    public static final String CAMPAIGN_COMMENT = "Observing campaign number";
    
    public static final String OBSMODE_KW = "OBSMODE";
    public static final String OBSMODE_COMMENT = "observing mode";
    public static enum ObservingMode {
        FULL_FRAME_IMAGE, LONG_CADENCE, SHORT_CADENCE;
        
        public String toFitsKeywordValue() {
            return this.toString().toLowerCase().replace('_', ' ');
        }
        
        public static ObservingMode valueOf(CadenceType cadenceType) {
            switch (cadenceType) {
                case LONG: return LONG_CADENCE;
                case SHORT: return SHORT_CADENCE;
                default:
                    throw new IllegalArgumentException("bad cadence type: " + cadenceType);
            }
        }
    }
    
    /** See KSOC-373.  No this should not be RADECSYS */
    public static final String RADESYS_KW = "RADESYS";
    public static final String RADESYS_VALUE = "ICRS";
    public static final String RADESYS_COMMENT = "reference frame of celestial coordinates";
    
    /**
     * This is the right ascension of the object in the file in degrees, NOT hours.  Files
     * with targets likely want to use this keyword.
     */
    public static final String RA_OBJ_KW = "RA_OBJ";
    public static final String RA_OBJ_COMMENT = "[deg] right ascension";
    
    /**
     * This is the declination of the object in the file in degrees.  Files
     * with targets likely want to use this keyword.
     */
    public static final String DEC_OBJ_KW = "DEC_OBJ";
    public static final String DEC_OBJ_COMMENT = "[deg] declination";
    
    /**
     * This is an old keyword used by some of the older FITS data products that
     * Kepler exports.  Do not use this in any new file.
     */
    @Deprecated
    public static final String RA_TARG = "RA";
    
    /**
     * This is an old keyword used by some of the older FITS data products that
     * Kepler exports.  Do not use this in any new file.
     */
    @Deprecated
    public static final String DEC_TARG = "DEC";
    
    
    public static final String EQUINOX = "EQUINOX";
    public static final float EQUINOX_VALUE = 2000.0f;
    public static final String EQUINOX_FORMAT = "%.1f";
    public static final String EQUINOX_COMMENT = "equinox of celestial coordinate system";
    
    /**
     * This is the right ascension of the spacecraft boresight.  Files that 
     * describe the entire focal plane or large parts of it likely want to use
     * this keyword.  This is in degrees NOT hours.
     */
    public static final String RA_NOM_KW = "RA_NOM";
    public static final String RA_NOM_COMMENT = " [deg] RA of spacecraft boresight";
    
    /**
     * This is the old spacecraft boresight RA  keyword.
     */
    @Deprecated
    public static final String RA_XAXIS_KW = "RA-XAXIS";
    
    /**
     * This is the declination of the spacecraft boresight.  Files that 
     * describe the entire focal plane or large parts of it likely want to use
     * this keyword.
     */
    public static final String DEC_NOM_KW = "DEC_NOM";
    public static final String DEC_NOM_COMMENT = "[deg] declination of spacecraft boresight";
    
    /**
     * This is the old keyword used by the original FITS headers.
     */
    @Deprecated
    public static final String DEC_XAXS_KW = "DEC-XAXS";

    public static final String ROLL_NOM_KW = "ROLL_NOM";
    public static final String ROLL_NOM_COMMENT = "[deg] roll angle of spacecraft";
    
    /**
     * This is the old keyword used by the original FITS headers for spacecraft
     * boresight rollangle.
     */
    @Deprecated
    public static final String ROLLANGL_KW = "ROLLANGL";

    public static final String PMRA_KW = "PMRA";
    public static final String PMRA_COMMENT = "[arcsec/yr] RA proper motion ";
    public static final String PMDEC_KW = "PMDEC";
    public static final String PMDEC_COMMENT = "[arcsec/yr] Dec proper motion";
    public static final String PMTOTAL_KW = "PMTOTAL";
    public static final String PMTOTAL_COMMENT = "[arcsec/yr] total proper motion ";
    public static final String PARALLAX_KW = "PARALLAX";
    public static final String PARALLAX_COMMENT = "[arcsec] parallax ";
    public static final String GLON_KW = "GLON";
    public static final String GLON_COMMENT = "[deg] galactic longitude";
    public static final String GLAT_KW = "GLAT";
    public static final String GLAT_COMMENT = "[deg] galactic latitude ";
    public static final String GMAG_KW = "GMAG";
    public static final String GMAG_COMMENT = "[mag] SDSS g band magnitude";
    public static final String RMAG_KW = "RMAG";
    public static final String RMAG_COMMENT = "[mag] SDSS r band magnitude";
    public static final String IMAG_KW = "IMAG";
    public static final String IMAG_COMMENT = "[mag] SDSS i band magnitude";
    public static final String ZMAG_KW = "ZMAG";
    public static final String ZMAG_COMMENT = "[mag] SDSS z band magnitude";
    public static final String D51MAG_KW = "D51MAG";
    public static final String D51MAG_COMMENT = "[mag] D51 magnitude,";
    public static final String JMAG_KW = "JMAG";
    public static final String JMAG_COMMENT = "[mag] J band magnitude from 2MASS";
    public static final String HMAG_KW = "HMAG";
    public static final String HMAG_COMMENT = "[mag] H band magnitude from 2MASS";
    public static final String KMAG_KW = "KMAG";
    public static final String KMAG_COMMENT = "[mag] K band magnitude from 2MASS";
    public static final String KEPMAG_KW = "KEPMAG";
    public static final String KEPMAG_COMMENT = "[mag] Kepler magnitude (Kp)";
    public static final String GRCOLOR_KW = "GRCOLOR";
    public static final String GRCOLOR_COMMENT = "[mag] (g-r) color, SDSS bands";
    public static final String JKCOLOR_KW = "JKCOLOR";
    public static final String JKCOLOR_COMMENT = "[mag] (J-K) color, 2MASS bands";
    public static final String GKCOLOR_KW = "GKCOLOR";
    public static final String GKCOLOR_COMMENT = "[mag] (g-K) color, SDSS g - 2MASS K";
    public static final String TEFF_KW = "TEFF";
    public static final String TEFF_COMMENT = "[K] Effective temperature";
    public static final String LOGG_KW = "LOGG";
    public static final String LOGG_COMMENT = "[cm/s2] log10 surface gravity ";
    public static final String FEH_KW = "FEH";
    public static final String FEH_COMMENT = "[log10([Fe/H])]  metallicity ";
    public static final String EBMINUSV_KW = "EBMINUSV";
    public static final String EBMINUSV_COMMENT = "[mag] E(B-V) reddening";
    public static final String AV_KW = "AV";
    public static final String AV_COMMENT = "[mag] A_v extinction";
    public static final String RADIUS_KW = "RADIUS";
    public static final String RADIUS_COMMENT = "[solar radii] stellar radius";
    public static final String TMINDEX_KW = "TMINDEX";
    public static final String TMINDEX_COMMENT = "unique 2MASS catalog ID";
    public static final String SCPID_KW = "SCPID";
    public static final String SCPID_COMMENT = "unique SCP processing ID";

    public static final String INHERT_KW = "INHERIT";
    public static final boolean INHERIT_VALUE = true;
    public static final String INHERIT_COMMENT  = "inherit the primary header";
    
    public static final String TIMEREF_KW = "TIMEREF";
    public static final String TIMEREF_VALUE = "SOLARSYSTEM";
    public static final String TIMEREF_COMMENT = "barycentric correction applied to times";
    
    public static final String TASSIGN_KW = "TASSIGN";
    public static final String TASSIGN_VALUE = "SPACECRAFT";
    public static final String TASSIGN_COMMENT = "where time is assigned";
    
    public static final String TIMESYS_KW = "TIMESYS";
    public static final String TIMESYS_VALUE = "TDB";
    public static final String TIMESYS_COMMENT = "time system is barycentric JD";
    
    public static final String BJDREFI_KW = "BJDREFI";
    public static final String BJDREFI_COMMENT = "integer part of BJD reference date";
    
    public static final String BJDREFF_KW = "BJDREFF";
    public static final String BJDREFF_COMMENT = "fraction of the day in BJD reference date";
    public static final String BJDREFF_FORMAT = "%.8f";
    
    public static final String TIMEUNIT_KW = "TIMEUNIT";
    public static final String TIMEUNIT_VALUE = "d";
    public static final String TIMEUNIT_COMMENT = "time unit for TIME, TSTART and TSTOP";
    
    public static final String TSTART_KW = "TSTART";
    public static final String TSTART_COMMENT = "observation start time in BJD-BJDREF";
    public static final String TSTART_FORMAT = "%.8f";
    
    public static final String TSTOP_KW = "TSTOP";
    public static final String TSTOP_COMMENT = "observation stop time in BJD-BJDREF";
    public static final String TSTOP_FORMAT = "%.8f";
    
    public static final String LC_START_KW = "LC_START";
    public static final String LC_START_COMMENT = "mid point of first cadence in MJD";
    public static final String LC_START_FORMAT = "%.8f";
    
    public static final String LC_END_KW = "LC_END";
    public static final String LC_END_COMMENT = "mid point of last cadence in MJD";
    public static final String LC_END_FORMAT = "%.8f";
    
    /** This is used for the FFIs */
    public static final String MJDSTART_KW = "MJDSTART";
    public static final String MJDSTART_COMMENT = "[d] start of observation in spacecraft MJD";
    
    /** This is used for the FFIs. */
    public static final String MJDEND_KW = "MJDEND";
    public static final String MJDEND_COMMENT = "[d] end of observation in spacecraft MJD";
    
    public static final String TELAPSE_KW = "TELAPSE";
    public static final String TELAPSE_COMMENT = "[d] TSTOP - TSTART";
    public static final String TELAPSE_FORMAT = "%.8f";
    
    public static final String LIVETIME_KW = "LIVETIME";
    public static final String LIVETIME_COMMENT = "[d] TELAPSE multiplied by DEADC";
    public static final String LIVETIME_FORMAT = "%.8f";
    
    public static final String EXPOSURE_KW = "EXPOSURE";
    public static final String EXPOSURE_COMMENT = "[d] time on source";
    public static final String EXPOSURE_FORMAT = "%.8f";
    
    public static final String FGSFRPER_KW = "FGSFRPER";
    public static final String FGSFRPER_COMMENT = " [ms] FGS frame period";
    
    public static final String NUMFGSFP_KW = "NUMFGSFP";
    /** Kepler seems to call this the number of FGS frames per integration. */
    public static final String NUMFGSFP_COMMENT = "number of FGS frame periods per exposure";
    
    public static final String DEADC_KW = "DEADC";
    public static final String DEADC_COMMENT = "deadtime correction";
    public static final String DEADC_FORMAT = "%.8f";
    
    public static final String TIMEPIXR_KW = "TIMEPIXR";
    public static final float TIMEPIXR_VALUE = 0.5f;
    public static final String TIMEPIXR_COMMENT = "bin time beginning=0 middle=0.5 end=1";
    
    public static final String TIERRELA_KW = "TIERRELA";
    public static final float TIERRELA_VALUE = 5.78E-7f;
    public static final String TIERRELA_COMMENT = "[d] relative time error";
    public static final String TIERRELA_FORMAT = "%.2E";
    
    public static final String TIERABSO_KW = "TIERABSO";
    public static final Float TIERABSO_VALUE = null;
    public static final String TIERABSO_COMMENT = "[d] absolute time error";
    
    public static final String INT_TIME_KW = "INT_TIME";
    public static final String INT_TIME_COMMENT = "[s] photon accumulation time per frame";
    public static final String INT_TIME_FORMAT = "%14.12f";
    
    public static final String READTIME_KW = "READTIME";
    public static final String READTIME_COMMENT = "[s] readout time per frame";
    public static final String READTIME_FORMAT = INT_TIME_FORMAT;
    
    public static final String FRAMETIM_KW = "FRAMETIM";
    public static final String FRAMETIM_COMMENT = "[s] frame time (INT_TIME + READTIME)";
    public static final String FRAMETIM_FORMAT = INT_TIME_FORMAT;
    
    public static final String NUM_FRM_KW = "NUM_FRM";
    public static final String NUM_FRM_COMMENT = "number of frames per time stamp";
    
    public static final String TIMEDEL_KW = "TIMEDEL";
    public static final String TIMEDEL_COMMENT = "[d] time resolution of data";
    public static final String TIMEDEL_FORMAT = "%.8f";
    
    public static final String DATE_OBS_KW = "DATE-OBS";
    public static final String DATE_OBS_COMMENT = "TSTART as UTC calendar date";

    public static final String DATE_END_KW = "DATE-END";
    public static final String DATE_END_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    public static final String DATE_END_COMMENT = "TSTOP as UTC calendar date";
    
    public static final String BACKAPP_KW = "BACKAPP";
    public static final String BACKAPP_COMMENT = "background is subtracted";
    public static final boolean BACKAPP_VALUE = true;
    
    public static final String DEADAPP_KW = "DEADAPP";
    public static final boolean DEADAPP_VALUE = true;
    public static final String DEADAPP_COMMENT = "deadtime applied";
    
    public static final String VIGNAPP_KW = "VIGNAPP";
    public static final boolean VIGNAPP_VALUE = true;
    public static final String VIGNAPP_COMMENT = "vignetting or collimator correction applied";
    
    public static final String GAIN_KW = "GAIN";
    public static final String GAIN_COMMENT = "[electrons/count] channel gain";
    
    public static final String READNOIS_KW = "READNOIS";
    public static final String READNOIS_COMMENT = "[electrons] read noise";
    public static final String READNOIS_FORMAT = "%.6f";
    
    public static final String NREADOUT_KW = "NREADOUT";
    public static final String NREADOUT_COMMENT = "number of read per cadence";
    
    public static final String TIMSLICE_KW = "TIMSLICE";
    public static final String TIMSLICE_COMMENT = "time-slice readout sequence section";
    
    public static final String MEANBLCK_KW = "MEANBLCK";
    public static final String MEANBLCK_COMMENT = "[count] FSW mean black level";

    public static final String LCFXDOFF_KW = "LCFXDOFF";
    public static final String LCFXDOFF_COMMENT = "long cadence fixed offset";
    public static final String LCFXDOFF_FORMAT = "%d";
    
    public static final String SCFXDOFF_KW = "SCFXDOFF";
    public static final String SCFXDOFF_COMMENT = "short cadence fixed offset";
    public static final String SCFXDOFF_FORMAT = "%d";
    
    public static final String BTC_PIX1_KW = "BTC_PIX1";
    public static final String BTC_PIX1_COMMENT = "reference col for barycentric time correction";
    
    public static final String BTC_PIX2_KW = "BTC_PIX2";
    public static final String BTC_PIX2_COMMENT = "reference row for barycentric time correction";
    
    public static final String BUNIT_KW = "BUNIT";
    public static final String BUNIT_VALUE = "electrons/s";
    public static final String BUNIT_COMMENT = "physical units of image data";
    
    public static final String BARYCORR_KW = "BARYCORR";
    public static final String BARYCORR_COMMENT = "[d] barycentric time correction";
    public static final String BARYCORR_FORMAT = "%.7E";
    
    public static final String CROWDSAP_KW = "CROWDSAP";
    public static final String CROWDSAP_COMMENT = "Ratio of target flux to total flux in op. ap.";
    public static final String CROWDSAP_FORMAT = "%.4f";
    
    public static final String NPIXSAP_KW = "NPIXSAP";
    public static final String NPIXSAP_COMMENT = "Number of pixels in optimal aperture";
    
    public static final String FLFRCSAP_KW = "FLFRCSAP";
    public static final String FLFRCSAP_COMMENT = "Frac. of target flux w/in the op. aperture";
    public static final String FLFRCSAP_FORMAT = "%.4f";
    
    public static final String NPIXMISS_KW = "NPIXMISS";
    public static final String NPIXMISS_COMMENT = "Number of op. aperture pixels not collected";

    public static final String CDPP3_0_KW = "CDPP3_0";
    public static final String CDPP3_0_COMMENT = "[ppm] RMS CDPP on 3.0-hr time scales";
    
    public static final String CDPP6_0_KW = "CDPP6_0";
    public static final String CDPP6_0_COMMENT = "[ppm] RMS CDPP on 6.0-hr time scales";
    
    public static final String CDPP12_0_KW = "CDPP12_0";
    public static final String CDPP12_0_COMMENT = "[ppm] RMS CDPP on 12.0-hr time scales";
    
    public static final String PDC_EPT_KW = "PDC_EPT";
    public static final String PDC_EPT_COMMENT = "PDC earth point goodness metric for target";
    public static final String PDC_EPTP_KW = "PDC_EPTP";
    public static final String PDC_EPTP_COMMENT = "PDC_EPT percentile compared to mod/out";
    
    public static final String PDCMETHD_KW = "PDCMETHD";
    public static final String PDCMETHD_COMMENT = "PDC algorithm used for target";
    
    public static final String NSPSDDET_KW = "NSPSDDET";
    public static final String NSPSDDET_COMMENT = "Number of SPSDs detected";
    
    public static final String NSPSDCOR_KW = "NSPSDCOR";
    public static final String NSPSDCOR_COMMENT = "Number of SPSDs corrected";
    public static final String NUMBAND_KW = "NUMBAND";
    public static final String NUMBAND_COMMENT = "Number of scale bands";
    
    public static final String FITTYPE_KW = "FITTYPE";
    public static final String FITTYPE_COMMENT = "Fit type used for band %d";
    
    public static final String PR_GOOD_KW = "PR_GOOD";
    public static final String PR_GOOD_COMMENT = "Prior goodness for band %d";
    
    public static final String PR_WGHT_KW = "PR_WGHT";
    public static final String PR_WGHT_COMMENT = "Prior weight for band %d";
    
    public static final String PDCVAR_KW = "PDCVAR";
    public static final String PDCVAR_COMMENT = "Target variability";
    
    public static final String PDC_TOT_KW = "PDC_TOT";
    public static final String PDC_TOT_COMMENT = "PDC total goodness metric for target";
    
    public static final String PDC_TOTP_KW = "PDC_TOTP";
    public static final String PDC_TOTP_COMMENT = "PDC_TOT percentile compared to mod/out";
    
    public static final String PDC_COR_KW = "PDC_COR";
    public static final String PDC_COR_COMMENT = "PDC correlation goodness metric for target";
    
    public static final String PDC_CORP_KW = "PDC_CORP";
    public static final String PDC_CORP_COMMENT = "PDC_COR percentile compared to mod/out";
    
    public static final String PDC_VAR_KW = "PDC_VAR";
    public static final String PDC_VAR_COMMENT = "PDC variability goodness metric for target";
    
    public static final String PDC_VARP_KW = "PDC_VARP";
    public static final String PDC_VARP_COMMENT = "PDC_VAR percentile compared to mod/out";
    
    public static final String PDC_NOI_KW = "PDC_NOI";
    public static final String PDC_NOI_COMMENT = "PDC noise goodness metric for target";
    
    public static final String PDC_NOIP_KW = "PDC_NOIP";
    public static final String PDC_NOIP_COMMENT = "PDC_NOI percentile compared to mod/out";
    
    public static final String MAPORDER_KW = "MAPORDER";
    public static final String MAPORDER_COMMENT = "order used for MAP fit";
    
    public static final String BVVER_KW = "BVVER";
    public static final String BVVER_COMMENT = "basis vector software version";
    
    /**  The value of this keyword should be one of the enumerated values
     * in the BlackAlgorithm enumerated type.
     */
    public static final String BLKALGO_KW = "BLKALGO";
    public static final String BLKALGO_COMMENT = "black algorithm used";
    
    //////////// Background polynomial keywords /////////////////
    public static final String POFFSETX_KW = "POFFSETX";
    public static final String POFFSETX_COMMENT = "B. Polynomial column offset"; 
    public static final String PSCALEX_KW = "PSCALEX";
    public static final String PSCALEX_COMMENT = "B. Polynomial column scale size";
    public static final String PORIGINX_KW = "PORIGINX";
    public static final String PORIGINX_COMMENT = "B. Polynomial column origin"; 
    public static final String POFFSETY_KW = "POFFSETY";
    public static final String POFFSETY_COMMENT = "B. Polynomial row offset"; 
    public static final String PSCALEY_KW  = "PSCALEY";
    public static final String PSCALEY_COMMENT = "B. Polynomial row scale size"; 
    public static final String PORIGINY_KW = "PORIGINY";
    public static final String PORIGINY_COMMENT = "B. Polynomial row origin";
    
    //////////// WCS Related Constants ////////////////
    /* SIP WCS Related Keywords */
    /**
     * If this keyword is present it must come before all other WCS keywords in
     * the same header.
     */
    public static final String WCSAXES_KW = "WCSAXES";
    public static final String WCSAXES_COMMENT = "number of WCS axes";
    
    public static final String CTYPE1_KW = "CTYPE1";
    public static final String CTYPE1_RADEC_VALUE = "RA---TAN";
    public static final String CTYPE1_RADEC_COMMENT = "right ascension coordinate type";
    
    public static final String CTYPE1_SIP_VALUE = "RA---TAN-SIP";
    public static final String CTYPE1_SIP_COMMENT = "Gnomonic projection + SIP distortions ";
    
    public static final String CTYPE2_KW = "CTYPE2";
    public static final String CTYPE2_RADEC_VALUE = "DEC--TAN";
    public static final String CTYPE2_RADEC_COMMENT = "declination coordinate type";
    
    public static final String CTYPE2_SIP_VALUE = "DEC--TAN-SIP";
    public static final String CTYPE2_SIP_COMMENT = "Gnomonic projection + SIP distortions ";
    
    public static final String CRVAL1_KW = "CRVAL1";
    public static final String CRVAL1_SIP_COMMENT = "RA at CRPIX1, CRPIX2";
    
    public static final String CRVAL2_KW = "CRVAL2";
    public static final String CRVAL2_SIP_COMMENT = "DEC at CRPIX1, CRPIX2";
    
    public static final String CRPIX1_KW = "CRPIX1";
    public static final String CRPIX1_SIP_COMMENT = "X reference pixel";
    
    public static final String CRPIX2_KW = "CRPIX2";
    public static final String CRPIX2_SIP_COMMENT = "Y reference pixel";
    
    public static final String CD1_1_KW = "CD1_1";
    public static final String CD1_1_COMMENT = "Transformation matrix";
    
    public static final String CD1_2_KW = "CD1_2";
    public static final String CD1_2_COMMENT = "Transformation matrix";

    public static final String CD2_1_KW = "CD2_1";
    public static final String CD2_1_COMMENT = "Transformation matrix";
    
    public static final String CD2_2_KW = "CD2_2";
    public static final String CD2_2_COMMENT = "Transformation matrix";
    
    public static final String A_ORDER_KW = "A_ORDER";
    public static final String A_ORDER_COMMENT = "Polynomial order, axis 1";
    
    public static final String B_ORDER_KW = "B_ORDER";
    public static final String B_ORDER_COMMENT = "Polynomial order, axis 2";
    
    public static final String AP_ORDER_KW = "AP_ORDER";
    public static final String AP_ORDER_COMMENT = "Inv polynomial order, axis 1";
    
    public static final String BP_ORDER_KW = "BP_ORDER";
    public static final String BP_ORDER_COMMENT = "Inv polynomial order, axis 2";
    
    public static final String A_DMAX_KW = "A_DMAX";
    public static final String A_DMAX_COMMENT = "maximum distortion, axis 1";
    
    public static final String B_DMAX_KW = "B_DMAX";
    public static final String B_DMAX_COMMENT = "maximum distortion, axis 2";

    public static final String WCS_PHYSICAL_CCD_ROW_TYPE = "RAWY";
    public static final String WCS_PHYSICAL_CCD_COL_TYPE = "RAWX";
    
    /**
     * LC_INTER tells you the long cadence number corresponding to the time the
     *  FFI was taken. This is the monotonic counter that increases every 30
     *  minutes whether the S/C is taking data or not. LC_INTER is what we use
     *  as the cadence number for LC data. LC_COUNT only increments when the
     *  S/C actually takes data and is less interesting because you can't
     *  convert it to a time stamp without knowing where all the gaps are.
     */
    public static final String LC_INTER_KW = "LC_INTER";
    public static final String SC_INTER_KW = "SC_INTER";
    
    public static final String INTEGRATIONS_PER_SC_KW = "NUMSHORT";
    public static final String SC_PER_LC_KW = "SHRTLONG";
    
    public static final String REQUANT_KW = "REQUANT";
    public static final String REQUANT_COMMENT = "data requantized for downlink (T/F)";

    public static final String HUFFMAN_KW = "HUFFMAN";
    public static final String HUFFMAN_COMMENT = "data entropic compressed for downlink (T/F)";
    
    public static final String BASELINE_KW = "BASELINE";
    public static final String BASELINE_COMMENT = "data originated as baseline image (T/F)";
    
    public static final String BASENAME_KW = "BASENAME";
    public static final String BASENAME_COMMENT = "rootname of baseline image";
    
    public static final String BASERCON_KW = "BASERCON";
    public static final String BASERCON_COMMENT = "baseline created from residual baseline image";
    
    public static final String RBASNAME_KW = "RBASNAME";
    public static final String RBASNAME_COMMENT = "rootname of residual baseline image";
    
    public static final String LCTRGDEF_KW = "LCTRGDEF"; //long cadence target definition identifier I2 N
    public static final String SCTRGDEF_KW = "SCTRGDEF"; //short cadence target definition identifier I2 N
    public static final String BKTRGDEF_KW = "BKTRGDEF"; //background definition identifier I2 N
    public static final String TARGAPER_KW = "TARGAPER"; //target aperture definition identifier I2 N
    public static final String BKG_APER_KW = "BKG_APER"; //background aperture definition identifier I2 N
    public static final String COMPTABL_KW = "COMPTABL"; //compression tables identifier I2 N
    
    ////// For Pixel Data Files ///
    /** 
     * long cadence target pixel mapping table C18 N */
    public static final String LONG_CADENCE_PMRF_KW = "LCTPMTAB"; 
    /** short cadence target pixel mapping table C18 N */
    public static final String SHORT_CADENCE_PMRF_KW = "SCTPMTAB";
    /**  background pixel mapping table C18 N*/
    public static final String BACKGROUND_PMRF_KW = "BKGPMTAB";
    /** long cadence collateral pixel mapping table C18 N */
    public static final String LONG_CADENCE_COLLATERAL_PMRF_KW = "LCCPMTAB";
    /** short cadence collateral pixel mapping table C18 N */
    public static final String SHORT_CADENCE_COLLATERAL_PMRF_KW = "SCCPMTAB";
    
    public static final String CHECKSUM_KW = "CHECKSUM";
    public static final String CHECKSUM_COMMENT_FORMAT = "HDU checksum updated %s";
    /** This is the value to use for the checksum when computing the checksum */
    public static final String CHECKSUM_DEFAULT = "0000000000000000";
    
    public static final String IMAGTYPE_KW = "IMAGTYPE";
    public static final String IMAGTYPE_COMMENT = "FFI image type: raw, SocCal, SocUnc";
    
    public static final String MNEMONIC_KW = "MNEMONIC";
    public static final String PAR_TYPE_KW = "PAR_TYPE";
    
    /**
     * This is only used in the FFIs
     */
    public static final String DCT_TIME_KW = "DCT_TIME";
    public static final String DCT_TIME_COMMENT = "data collection time: yyyydddhhss";
    
    /**
     * You might think what do I need with yet another type keyword.  And you
     * would be correct.  As far as I can tell this is only used in the FFIs.
     */
    public static final String DCT_TYPE_KW = "DCT_TYPE";
    public static final String DCT_TYPE_COMMENT = "data type";
    public static final String DCT_TYPE_VALUE = "FFI";
    
    public static final String DCT_PURP_KW = "DCT_PURP";
    public static final String DCT_PURP_COMMENT = "purpose of data";
    public static final String DCT_PURP_VALUE = "Monthly FFI";
    public static final String DCT_PURP_REV_CLK_VALUE = "RevClk";

    public static final String TFIELDS_KW = "TFIELDS";
    public static final String TFIELDS_COMMENT = "number of table fields";
    
    public static final String TFORM_KW = "TFORM";
    
                  ////   binary table columns  /////
    public static final String TIME_TCOLUMN = "TIME";
    public static final String TIME_TCOLUMN_COMMENT = "data time stamps";
    public static final String TIME_TCOLUMN_UNIT = "BJD - 2454833";
    public static final String TIME_TCOLUMN_UNIT_COMMENT = "barycenter corrected JD";
    public static final String TIME_TCOLUMN_DISPLAY_HINT = "D14.7";
    
    public static final String CADENCENO_TCOLUMN = "CADENCENO";
    public static final String CADENCENO_TCOLUMN_COMMENT = "unique cadence number";
    public static final String CADENCENO_TCOLUMN_HINT = "I10";
    
    public static final String POSCORR1 = "POS_CORR1";
    public static final String POSCORR1_COMMENT = "column position correction";
    public static final String POSCORR2 = "POS_CORR2";
    public static final String POSCORR2_COMMENT = "row position correction";
    
    /** This is a display hint that can be used by most single precision columns. */
    public static final String SINGLE_PRECISION_HINT = "E14.7";
    
    public static final String MJD_TIME_TCOLUMN = "TIME_MJD";
    public static final String MJD_TIME_TCOLUMN_COMMENT = "data time stamps";
    public static final String MJD_TIME_TCOLUMN_UNIT = "MJD, days";
    public static final String MJD_TIME_TCOLUMN_UNIT_COMMENT = "Modified Julian Date";
    public static final String MJD_TIME_TCOLUMN_DISPLAY_HINT = "D17.7";
    
    public static final String RB_LEVEL_TCOLUMN = "RB_LEVEL";
    public static final String RB_LEVEL_TCOLUMN_COMMENT = "rolling band level";
    public static final String RB_LEVEL_TCOLUMN_UNIT = "sigma";
    public static final String RB_LEVEL_TCOLUMN_UNIT_COMMENT = "detection significance";
    
    public static final String RB_FLAG_TCOLUMN = "RB_FLAG";
    public static final String RB_FLAG_TCOLUMN_COMMENT = "rolling band flags";
    
    /*
     * DBCOLCO = <The value of TbMinpix> "Column cutoff used by Dynablack"
   (Correct me if I'm wrong, but FITS files are also one based, so no conversion required.)
     */
    public static final String DBCOLCO_KW = "DBCOLCO";
    public static final String DBCOLCO_COMMENT = "Column cutoff used by Dynablack";
    
    /**
     * <The value of scDPixThreshold / LC exposure time> "Flux threshold used by Dynablack, in e-/s"
    (It would be nice to convert the value of scDPixThreshold into e/s since those are the units used by the data files.) 
     */
    public static final String DBTHRES_KW = "DBTHRES";
    public static final String DBTHRES_COMMENT = "[e-/s] Flux threshold used by Dynablack";
    
    public static final String RBTDUR_KW_FORMAT = "RBTDUR%d";
    public static final String RBTDUR_COMMENT_FORMAT = "[cadences] transit duration for rolling band %2d";
    
    /** Value to use for missing integer pixel values. -1 */
    public static final int MISSING_PIXEL_VALUE = (int) (4294967296L - 1); // 2^32
    /** Value to use for missing floating point pixel values.*/
    @Deprecated
    public static final float MISSING_CAL_PIXEL_VALUE = Float.NEGATIVE_INFINITY;
    
    
    //// Deprecated constants used by older exporters. ///
    /// Some of these are in the KIC, but have been deemed uninteresting by the SO ///
    /**
     * This is the value some of the older files used for the cadence_number
     * binary table header column.
     */
    @Deprecated
    public static final String OLD_CADENCE_NUMBER = "cadence_number";

    /**
     * This is used to identify old keywords from the DMC relating to spacefraft
     * pointing.
     */
    @Deprecated
    public static final String[] POINTING_KEYWORD_ARRAY = 
    { RA_XAXIS_KW, DEC_XAXS_KW, ROLLANGL_KW, "LASTROLL", "DATAEND", "DATASTRT" };
    
    @Deprecated
    public static final Set<String> POINTING_KEYWORDS = 
        Collections.unmodifiableSet(new HashSet<String>(Arrays.asList(POINTING_KEYWORD_ARRAY)));
    
    
    @Deprecated
    public static final String UMAG = "UMAG";
    
    @Deprecated
    /**                 unique 2MASS catalog ID                           I4  N */
    public static final String _2MASSID = "TMID";
    
    /**                 alternate catalog ID                              I4  N */
    @Deprecated
    public static final String ALTCATID = "ALTID";
    
    /**                 identifier for alternate catalog                  C20 N */
    @Deprecated
    public static final String ALTCAT = "ALTSOURC";
    
    /**                 0  */
    @Deprecated
    public static final String GALAXY = "GALAXY";
    
    /**                 0  */
    @Deprecated
    public static final String BLEND = "BLEND";
    
    @Deprecated
    public static final String VARIABLE = "VARIABLE";
    
    /**                 source                         I4  N */
    @Deprecated
    public static final String CQ = "CQ";
    
    /**                 photometry quality indicator                      I4  N */
    @Deprecated
    public static final String PHOTQUAL = "PQ";
    
    /**                 astrophysics quality indicator                    I4  N */
    @Deprecated
    public static final String AST_QUAL = "AQ";
    
    /** key to CATALOG DB  I4 */
    @Deprecated
    public static final String CATKEY = "CATKEY";
    
    /**                 SAO Gred-band magnitude of target                 R4  N */
    @Deprecated
    public static final String GREDMAG = "GREDMAG";
    
    public static final String STARTIME_KW = "STARTIME";
    public static final String END_TIME_KW = "END_TIME";
    
}
