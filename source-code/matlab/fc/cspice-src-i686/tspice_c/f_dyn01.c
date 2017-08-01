/* f_dyn01.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static doublereal c_b15 = 35.06;
static doublereal c_b16 = 100.;
static doublereal c_b17 = 0.;
static integer c__3 = 3;
static integer c__20 = 20;
static integer c__9 = 9;
static doublereal c_b162 = 1e-14;
static integer c__6 = 6;
static doublereal c_b177 = 1e-16;
static integer c__21 = 21;
static integer c__36 = 36;
static integer c__5 = 5;
static integer c__1 = 1;
static integer c__11 = 11;
static integer c__2 = 2;
static integer c__4 = 4;
static integer c__7 = 7;
static integer c__0 = 0;
static doublereal c_b643 = 1.;
static doublereal c_b668 = 1e-12;
static doublereal c_b933 = 10.;

/* $Procedure F_DYN01 ( Dynamic Frame Test Family 01 ) */
/* Subroutine */ int f_dyn01__(logical *ok)
{
    /* Initialized data */

    static char abcorr[15*11] = "NONE           " "LT             " "LT+S   "
	    "        " "XLT            " "XLT+S          " "CN             " 
	    "CN+S           " "XCN            " "XCN+S          " "S        "
	    "      " "XS             ";
    static char vecfrm[80*5] = "J2000                                       "
	    "                                    " "GSE                      "
	    "                                                       " "PHOBOS"
	    "_RADIAL                                                         "
	    "          " "TARGET_FRAME                                       "
	    "                             " "OBSERVER_FRAME                  "
	    "                                                ";
    static char vecstr[80*3] = "( 1,  0,  1 )                               "
	    "                                    " "( 1,  1,  0 )            "
	    "                                                       " "( 0,  "
	    "1,  1 )                                                         "
	    "          ";
    static char angstr[80*2*2] = "-69.761                                   "
	    "                                      " " 78.565                "
	    "                                                         " "-1  "
	    "                                                                "
	    "            " " 1                                               "
	    "                               ";
    static char units[80*2] = "'DEGREES'                                    "
	    "                                   " "'RADIANS'                 "
	    "                                                      ";
    static integer dims__[5] = { 5,2,5,12,12 };
    static doublereal zr[9]	/* was [3][3] */ = { 0.,0.,0.,0.,0.,0.,0.,0.,
	    0. };
    static integer abpair[10]	/* was [2][5] */ = { 1,1,1,5,3,1,5,3,4,4 };
    static char axdef[80*2*6] = "Z                                          "
	    "                                     " "X                       "
	    "                                                        " "-x   "
	    "                                                                "
	    "           " " Y                                                "
	    "                              " " Y                             "
	    "                                                 " "-z          "
	    "                                                                "
	    "    " " -  y                                                    "
	    "                       " "  X                                   "
	    "                                          " " z                 "
	    "                                                             " 
	    " - x                                                           "
	    "                 " "- Z                                         "
	    "                                    " " - y                     "
	    "                                                       ";
    static char basefr[32*2] = "J2000                           " "GSE      "
	    "                       ";
    static char bodies[32*5] = "PHOBOS                          " "MARS     "
	    "                       " "EARTH                           " "MOO"
	    "N                            " "SUN                             ";
    static char corsys[80*3] = "'RECTANGULAR'                               "
	    "                                    " "'LATITUDINAL'            "
	    "                                                       " "'RA/DE"
	    "C'                                                              "
	    "          ";
    static doublereal e[9]	/* was [3][3] */ = { 1.,0.,0.,0.,1.,0.,0.,0.,
	    1. };
    static integer otpair[20]	/* was [4][5] */ = { 1,2,1,2,1,2,1,3,1,2,3,4,
	    3,4,3,4,3,5,3,4 };
    static char vecdef[80*4] = "OBSERVER_TARGET_POSITION                    "
	    "                                    " "TARGET_NEAR_POINT        "
	    "                                                       " "OBSERV"
	    "ER_TARGET_VELOCITY                                              "
	    "          " "CONSTANT                                           "
	    "                             ";

    /* System generated locals */
    address a__1[2], a__2[5], a__3[3], a__4[4];
    integer i__1, i__2, i__3[2], i__4[5], i__5[3], i__6, i__7, i__8[4];
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);
    integer i_indx(char *, char *, ftnlen, ftnlen);
    double d_lg10(doublereal *), pow_dd(doublereal *, doublereal *);

    /* Local variables */
    extern /* Subroutine */ int setmsg_(char *, ftnlen), errint_(char *, 
	    integer *, ftnlen), sigerr_(char *, ftnlen), cnmfrm_(char *, 
	    integer *, char *, logical *, ftnlen, ftnlen), suffix_(char *, 
	    integer *, char *, ftnlen, ftnlen), lparsm_(char *, char *, 
	    integer *, integer *, char *, ftnlen, ftnlen, ftnlen), cmprss_(
	    char *, integer *, char *, char *, ftnlen, ftnlen, ftnlen);
    doublereal dmag;
    extern /* Subroutine */ int convrt_(doublereal *, char *, char *, 
	    doublereal *, ftnlen, ftnlen), latrec_(doublereal *, doublereal *,
	     doublereal *, doublereal *);
    integer case__;
    extern /* Subroutine */ int spkpos_(char *, doublereal *, char *, char *, 
	    char *, doublereal *, doublereal *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), mxv_(doublereal *, doublereal *, doublereal *), chcksl_(
	    char *, logical *, logical *, logical *, ftnlen);
    doublereal xf2000[36]	/* was [6][6] */;
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    ), spkezr_(char *, doublereal *, char *, char *, char *, 
	    doublereal *, doublereal *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    namfrm_(char *, integer *, ftnlen), frinfo_(integer *, integer *, 
	    integer *, integer *, logical *), mxm_(doublereal *, doublereal *,
	     doublereal *), spkssb_(integer *, doublereal *, char *, 
	    doublereal *, ftnlen), stlabx_(doublereal *, doublereal *, 
	    doublereal *), stelab_(doublereal *, doublereal *, doublereal *);
    integer cent;
    char targ[32];
    integer ncor, nogo;
    extern /* Subroutine */ int vhat_(doublereal *, doublereal *);
    integer prij;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    ), mxmg_(doublereal *, doublereal *, integer *, integer *, 
	    integer *, doublereal *), vequ_(doublereal *, doublereal *);
    doublereal xfb2j[36]	/* was [6][6] */;
    extern /* Subroutine */ int zzcorepc_(char *, doublereal *, doublereal *, 
	    doublereal *, ftnlen);
    integer i__, j, k, l;
    extern /* Subroutine */ int zzprscor_(char *, logical *, ftnlen);
    integer n;
    doublereal r__[9]	/* was [3][3] */, v[3], delta;
    extern /* Subroutine */ int tcase_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen), vpack_(doublereal *, doublereal *, doublereal *,
	     doublereal *);
    char secvf[32];
    integer class__, ncart;
    logical found, iscon[2];
    extern /* Subroutine */ int movec_(char *, integer *, char *, ftnlen, 
	    ftnlen);
    doublereal state[6];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    logical isvel[2];
    integer nskip;
    char privf[32];
    extern /* Subroutine */ int topen_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen), prsdp_(char *, 
	    doublereal *, ftnlen);
    doublereal stobs[6], vtemp[3];
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int subpt_(char *, char *, doublereal *, char *, 
	    char *, doublereal *, doublereal *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), vperp_(doublereal *, doublereal *, doublereal *);
    doublereal r2[9]	/* was [3][3] */, r3[9]	/* was [3][3] */, r4[9]	/* 
	    was [3][3] */, rplus[9]	/* was [3][3] */;
    extern /* Subroutine */ int bodn2c_(char *, integer *, logical *, ftnlen),
	     bodc2n_(integer *, char *, logical *, ftnlen), t_success__(
	    logical *);
    char deftx2[80*50];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    logical go;
    doublereal et;
    char bframe[32];
    doublereal drdiff[9]	/* was [3][3] */, lt;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen), 
	    prodai_(integer *, integer *);
    extern doublereal vnormg_(doublereal *, integer *);
    char axname[80], casmsg[80], center[32], deftxt[80*50], frname[32], 
	    pricor[15], prifrm[32], priobs[32], pritrg[32], cor[15], obs[32], 
	    ord[4], privdf[80], seccor[15], secfrm[32], secobs[32], sectrg[32]
	    , secvdf[80], tmpstr[80], tokens[80*7], trgfrm[32], vdf[80], vfr[
	    80], vframe[32], frstem[18];
    doublereal alt, axsign, clt, convec[3], cstate[6], deterr, drlerr, drvblk[
	    9]	/* was [3][3] */, drverr, etcorr, lat, lon, maxder, nrmerr, 
	    pos[3], privec[3], rminus[9]	/* was [3][3] */, secvec[3], 
	    spoint[3], tol, xf2[36]	/* was [6][6] */, lat0;
    integer axindx, axpair, clssid, coords[5], coridx, dx;
    doublereal lon0;
    integer frcode, handle, sysidx, vfcode, npr;
    logical bigerr, priblk[15], tstdrv, secblk[15];
    extern /* Subroutine */ int tstlsk_(void), chckxc_(logical *, char *, 
	    logical *, ftnlen), tstspk_(char *, logical *, integer *, ftnlen),
	     tstpck_(char *, logical *, logical *, ftnlen), pdpool_(char *, 
	    integer *, doublereal *, ftnlen), lmpool_(char *, integer *, 
	    ftnlen), sxform_(char *, char *, doublereal *, doublereal *, 
	    ftnlen, ftnlen), pxform_(char *, char *, doublereal *, doublereal 
	    *, ftnlen, ftnlen), t_xform__(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), dvpool_(char *, ftnlen), cleard_(integer *, 
	    doublereal *), multix_(integer *, integer *, integer *, integer *,
	     integer *);

/* $ Abstract */

/*     Test family to exercise the logic and code in the first */
/*     subset of dynamic frame routines.  Only two-vector frames */
/*     are used in these tests. */

/* $ Disclaimer */

/*     THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE */
/*     CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S. */
/*     GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE */
/*     ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE */
/*     PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS" */
/*     TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY */
/*     WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A */
/*     PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC */
/*     SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE */
/*     SOFTWARE AND RELATED MATERIALS, HOWEVER USED. */

/*     IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA */
/*     BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT */
/*     LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND, */
/*     INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS, */
/*     REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE */
/*     REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY. */

/*     RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF */
/*     THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY */
/*     CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE */
/*     ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE. */

/* $ Required_Reading */

/*     None. */

/* $ Keywords */

/*     TEST FAMILY */

/* $ Declarations */
/* $ Abstract */

/*     Include file zzabcorr.inc */

/*     SPICE private file intended solely for the support of SPICE */
/*     routines.  Users should not include this file directly due */
/*     to the volatile nature of this file */

/*     The parameters below define the structure of an aberration */
/*     correction attribute block. */

/* $ Disclaimer */

/*     THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE */
/*     CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S. */
/*     GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE */
/*     ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE */
/*     PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS" */
/*     TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY */
/*     WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A */
/*     PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC */
/*     SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE */
/*     SOFTWARE AND RELATED MATERIALS, HOWEVER USED. */

/*     IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA */
/*     BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT */
/*     LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND, */
/*     INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS, */
/*     REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE */
/*     REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY. */

/*     RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF */
/*     THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY */
/*     CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE */
/*     ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE. */

/* $ Parameters */

/*     An aberration correction attribute block is an array of logical */
/*     flags indicating the attributes of the aberration correction */
/*     specified by an aberration correction string.  The attributes */
/*     are: */

/*        - Is the correction "geometric"? */

/*        - Is light time correction indicated? */

/*        - Is stellar aberration correction indicated? */

/*        - Is the light time correction of the "converged */
/*          Newtonian" variety? */

/*        - Is the correction for the transmission case? */

/*        - Is the correction relativistic? */

/*    The parameters defining the structure of the block are as */
/*    follows: */

/*       NABCOR    Number of aberration correction choices. */

/*       ABATSZ    Number of elements in the aberration correction */
/*                 block. */

/*       GEOIDX    Index in block of geometric correction flag. */

/*       LTIDX     Index of light time flag. */

/*       STLIDX    Index of stellar aberration flag. */

/*       CNVIDX    Index of converged Newtonian flag. */

/*       XMTIDX    Index of transmission flag. */

/*       RELIDX    Index of relativistic flag. */

/*    The following parameter is not required to define the block */
/*    structure, but it is convenient to include it here: */

/*       CORLEN    The maximum string length required by any aberration */
/*                 correction string */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 18-DEC-2004 (NJB) */

/* -& */
/*     Number of aberration correction choices: */


/*     Aberration correction attribute block size */
/*     (number of aberration correction attributes): */


/*     Indices of attributes within an aberration correction */
/*     attribute block: */


/*     Maximum length of an aberration correction string: */


/*     End of include file zzabcorr.inc */

/* $ Abstract */

/*     Include file zzdyn.inc */

/*     SPICE private file intended solely for the support of SPICE */
/*     routines.  Users should not include this file directly due */
/*     to the volatile nature of this file */

/*     The parameters defined below are used by the SPICELIB dynamic */
/*     frame subsystem. */

/* $ Disclaimer */

/*     THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE */
/*     CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S. */
/*     GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE */
/*     ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE */
/*     PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS" */
/*     TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY */
/*     WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A */
/*     PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC */
/*     SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE */
/*     SOFTWARE AND RELATED MATERIALS, HOWEVER USED. */

/*     IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA */
/*     BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT */
/*     LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND, */
/*     INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS, */
/*     REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE */
/*     REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY. */

/*     RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF */
/*     THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY */
/*     CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE */
/*     ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE. */

/* $ Parameters */

/*     This file declares parameters required by the dynamic */
/*     frame routines of the SPICELIB frame subsystem. */

/* $ Restrictions */

/*     The parameter BDNMLN is this routine must be kept */
/*     consistent with the parameter MAXL defined in */

/*        zzbodtrn.inc */


/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.1.0, 12-JAN-2005 (NJB) */

/*        Parameters KWX, KWY, KWZ renamed to KVX, KVY, KVZ. */

/* -    SPICELIB Version 1.0.0, 22-DEC-2004 (NJB) */

/* -& */

/*     String length parameters */
/*     ======================== */


/*     Kernel variable name length.  This parameter must be */
/*     kept consistent with the parameter MAXLEN used in the */
/*     POOL umbrella routine. */


/*     Length of a character kernel pool datum. This parameter must be */
/*     kept consistent with the parameter MAXCHR used in the POOL */
/*     umbrella routine. */


/*     Reference frame name length.  This parameter must be */
/*     kept consistent with the parameter WDSIZE used in the */
/*     FRAMEX umbrella routine. */


/*     Body name length.  This parameter is used to provide a level */
/*     of indirection so the dynamic frame source code doesn't */
/*     have to change if the name of this SPICELIB-scope parameter */
/*     is changed.  The value MAXL used here is defined in the */
/*     INCLUDE file */

/*        zzbodtrn.inc */

/*     Current value of MAXL = 36 */


/*     Numeric parameters */
/*     =================================== */

/*     The parameter MAXCOF is the maximum number of polynomial */
/*     coefficients that may be used to define an Euler angle */
/*     in an "Euler frame" definition */


/*     The parameter LBSEP is the default angular separation limit for */
/*     the vectors defining a two-vector frame.  The angular separation */
/*     of the vectors must differ from Pi and 0 by at least this amount. */


/*     The parameter QEXP is used to determine the width of */
/*     the interval DELTA used for the discrete differentiation */
/*     of velocity in the routines ZZDYNFRM, ZZDYNROT, and their */
/*     recursive analogs.  This parameter is appropriate for */
/*     64-bit IEEE double precision numbers; when SPICELIB */
/*     is hosted on platforms where longer mantissas are supported, */
/*     this parameter (and hence this INCLUDE file) will become */
/*     platform-dependent. */

/*     The choice of QEXP is based on heuristics.  It's believed to */
/*     be a reasonable choice obtainable without expensive computation. */

/*     QEXP is the largest power of 2 such that */

/*        1.D0 + 2**QEXP  =  1.D0 */

/*     Given an epoch T0 at which a discrete derivative is to be */
/*     computed, this choice provides a value of DELTA that usually */
/*     contributes no round-off error in the computation of the function */
/*     evaluation epochs */

/*        T0 +/- DELTA */

/*     while providing the largest value of DELTA having this form that */
/*     causes the order of the error term O(DELTA**2) in the quadratric */
/*     function approximation to round to zero.  Note that the error */
/*     itself will normally be small but doesn't necessarily round to */
/*     zero.  Note also that the small function approximation error */
/*     is not a measurement of the error in the discrete derivative */
/*     itself. */

/*     For ET values T0 > 2**27 seconds past J2000, the value of */
/*     DELTA will be set to */

/*        T0 * 2**QEXP */

/*     For smaller values of T0, DELTA should be set to 1.D0. */


/*     Frame kernel parameters */
/*     ======================= */

/*     Parameters relating to kernel variable names (keywords) start */
/*     with the letters */

/*        KW */

/*     Parameters relating to kernel variable values start with the */
/*     letters */

/*        KV */


/*     Generic parameters */
/*     --------------------------------- */

/*     Token used to build the base frame keyword: */


/*     Frame definition style parameters */
/*     --------------------------------- */

/*     Token used to build the frame definition style keyword: */


/*     Token indicating parameterized dynamic frame. */


/*     Freeze epoch parameters */
/*     --------------------------------- */

/*     Token used to build the freeze epoch keyword: */


/*     Rotation state parameters */
/*     --------------------------------- */

/*     Token used to build the rotation state keyword: */


/*     Token indicating rotating rotation state: */


/*     Token indicating inertial rotation state: */


/*     Frame family parameters */
/*     --------------------------------- */

/*     Token used to build the frame family keyword: */


/*     Token indicating mean equator and equinox of date frame. */


/*     Token indicating mean ecliptic and equinox of date frame. */


/*     Token indicating true equator and equinox of date frame. */


/*     Token indicating two-vector frame. */


/*     Token indicating Euler frame. */


/*     "Of date" frame family parameters */
/*     --------------------------------- */

/*     Token used to build the precession model keyword: */


/*     Token used to build the nutation model keyword: */


/*     Token used to build the obliquity model keyword: */


/*     Mathematical models used to define "of date" frames will */
/*     likely accrue over time.  We will simply assign them */
/*     numbers. */


/*     Token indicating the Lieske earth precession model: */


/*     Token indicating the IAU 1980 earth nutation model: */


/*     Token indicating the IAU 1980 earth mean obliqity of */
/*     date model.  Note the name matches that of the preceding */
/*     nutation model---this is intentional.  The keyword */
/*     used in the kernel variable definition indicates what */
/*     kind of model is being defined. */


/*     Two-vector frame family parameters */
/*     --------------------------------- */

/*     Token used to build the vector axis keyword: */


/*     Tokens indicating axis values: */


/*     Prefixes used for primary and secondary vector definition */
/*     keywords: */


/*     Token used to build the vector definition keyword: */


/*     Token indicating observer-target position vector: */


/*     Token indicating observer-target velocity vector: */


/*     Token indicating observer-target near point vector: */


/*     Token indicating constant vector: */


/*     Token used to build the vector observer keyword: */


/*     Token used to build the vector target keyword: */


/*     Token used to build the vector frame keyword: */


/*     Token used to build the vector aberration correction keyword: */


/*     Token used to build the constant vector specification keyword: */


/*     Token indicating rectangular coordinates used to */
/*     specify constant vector: */


/*     Token indicating latitudinal coordinates used to */
/*     specify constant vector: */


/*     Token indicating RA/DEC coordinates used to */
/*     specify constant vector: */


/*     Token used to build the cartesian vector literal keyword: */


/*     Token used to build the constant vector latitude keyword: */


/*     Token used to build the constant vector longitude keyword: */


/*     Token used to build the constant vector right ascension keyword: */


/*     Token used to build the constant vector declination keyword: */


/*     Token used to build the angular separation tolerance keyword: */


/*     See the section "Physical unit parameters" below for additional */
/*     parameters applicable to two-vector frames. */


/*     Euler frame family parameters */
/*     --------------------------------- */

/*     Token used to build the epoch keyword: */


/*     Token used to build the Euler axis sequence keyword: */


/*     Tokens used to build the Euler angle coefficients keywords: */


/*     See the section "Physical unit parameters" below for additional */
/*     parameters applicable to Euler frames. */


/*     Physical unit parameters */
/*     --------------------------------- */

/*     Token used to build the units keyword: */


/*     Token indicating radians: */


/*     Token indicating degrees: */


/*     End of include file zzdyn.inc */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */


/*     Tests done here include, but are not necessarily limited to: */

/*        - Test state transformation from SXFORM: */

/*            o Make sure upper left and lower right blocks match. */
/*            o Test determinant of rotation blocks */
/*            o Test norms of rows and columns */

/*        - Compare SXFORM and PXFORM results. */

/*        - Compare SXFORM derivative to discrete derivative */
/*          computed using PXFORM.  Check absolute and relative */
/*          derivative errors. */

/*        - Compute state transformation via a local computation. */
/*          Compare rotation portion of transformation matrix */
/*          from SXFORM to locally computed result. */

/*        - Make sure that when rotation state is inertial, when a */
/*          matrix mapping from base frame to an inertial frame is */
/*          right-multiplied by matrix produced by SXFORM, resulting */
/*          matrix has zero derivative. */

/*        - Make sure that when rotation state is frozen, when a */
/*          matrix produced by SXFORM has zero derivative. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 09-NOV-2005 (NJB) */

/*        Parameters KWX, KWY, KWZ were renamed to KVX, KVY, KVZ. */
/*        Tolerance was increase for GSE-to-J2000 test from 5.D-8 to */
/*        6.D-8. */

/* -    TSPICE Version 1.0.0, 10-JAN-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Tolerance levels for various tests. */


/*     Parameters controlling frame definitions: */


/*     Number of dimensions of the test parameter space: */


/*     Number of aberration correction settings: */


/*     Number of aberration correction settings used for the */
/*     full cartesian product test: */

/*      PARAMETER           ( NABPRS = 1 ) */

/*     The constant ABCIDX refers to the ordinal position of the */
/*     dimension corresponding to aberration correction in the parameter */
/*     space. */


/*     Number of axis definition cases: */


/*     Number of base frame cases: */


/*     The constant BFRIDX refers to the ordinal position of the */
/*     dimension corresponding to base frame in the parameter */
/*     space. */


/*     Number of bodies: */


/*     Number of observer-target body pairs: */


/*     Number of vector definitions: */


/*     Number of vector frames: */


/*     Number of extended vector definitions.  These definitions */
/*     include every combination of frame-dependent definition type */
/*     and frame (for example, velocity and observer frame, constant */
/*     and J2000 frame, etc.) */


/*     Other parameters */

/*     Number of coordinate systems used to represent constant vectors: */


/*     Local Variables */


/*     We'll use the kernel variable name "stem" */

/*        FRAME_<ID code>_ */

/*     The length declared below (18) is the length of such a string */
/*     where the ID code contains 11 digits. */


/*     This variable is used for debugging. */


/*     OTPAIR is used to store observer-target pairs used to define */
/*     all vector types other than constant vectors.  The first */
/*     element of the ith column indicates the observer (the value */
/*     is an index into the BODIES array) for the primary vector; */
/*     the second element indicates the target for the primary vector. */
/*     The third and fourth elements play the same role for the */
/*     secondary vector. */


/*     Saved variables */


/*     Initial values */


/*     The elements of ABPAIR are indices into the ABCORR array. ABPAIR */
/*     has dimensions 2 x NABPRS. Each column of ABPAIR indicates the */
/*     corrections to be used for the primary and secondary vectors. */

/*     For the special case of constant vectors, the correction */
/*     'LT+S' is replaced with the correction 'LT', the correction */
/*     'XLT' is replaced with the correction 'S', and the correction */
/*     'XLT+S' is replaced with the correction 'XS'.  These replacements */
/*     are done in-line. */


/*     When defining axes, we vary the spacing and case to test the */
/*     algorithm used to parse axis specifications. */


/*     We use both inertial and dynamic base frames. */


/*     PHOBOS_RADIAL is an alternative, or additional, dynamic base */
/*     frame.  At least one dynamic base frame must be used. */


/*     .                      'PHOBOS_RADIAL'                          / */

/*     Bodies acting as observers and targets. */


/*     Coordinate systems used to represent constant vectors: */


/*     Euclidean basis vectors. */


/*     The primary vector is always defined using Phobos as the */
/*     observer and Mars as the target.  The secondary vector */
/*     may have the same observer and target (used when the second */
/*     vector is a velocity vector), the same observer and a different */
/*     target, or different observer and target. */


/*     VECDEF contains the possible vector definitions. */


/*     VECFRM contains frames associated with vectors.  Only velocity */
/*     and constant vectors actually use frame definitions. */


/*     When constant vectors are used and the coordinate system */
/*     is rectangular, the vectors are picked from this set. */


/*     These strings are used for latitudinal coordinates. */


/*     DIMS defines the dimensions of the cartesian product of the */
/*     input parameters.  The cardinality of the set comprising the */
/*     Nth "factor" of the cartesian product is DIMS(N).  The cardinality */
/*     of the product itself is the product of the elements of DIMS. */


/*     Open the test family. */

    topen_("F_DYN01", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Create test inputs for comprehensive two-vector test.", (ftnlen)
	    53);

/*     Create and load kernels. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("test_dyn.bsp", &c_true, &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstpck_("test_dyn.tpc", &c_true, &c_false, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Modify the prime meridian constants for Phobos to */
/*     make the rotation period deviate more from the orbital */
/*     period. */

    vpack_(&c_b15, &c_b16, &c_b17, v);
    pdpool_("BODY401_PM", &c__3, v, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We'll need to create two non-inertial frames:  one to */
/*     use as a base frame and one to use as a frame associated */
/*     with velocity and constant vectors.  We'll the the GSE */
/*     frame as one and a Mars radial frame as the other. */

    s_copy(deftxt, "FRAME_GSE                        =  2399000", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2399000_NAME               = 'GSE'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 160, "FRAME_2399000_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399000_CLASS_ID           =  2399000", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399000_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399000_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399000_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2399000_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2399000_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2399000_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(deftxt + 800, "FRAME_2399000_PRI_OBSERVER       = 'EARTH'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 880, "FRAME_2399000_PRI_TARGET         = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 960, "FRAME_2399000_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 1040, "FRAME_2399000_SEC_AXIS       = '-Y'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1120, "FRAME_2399000_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1200, "FRAME_2399000_SEC_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1280, "FRAME_2399000_SEC_TARGET       = 'EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1360, "FRAME_2399000_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1440, "FRAME_2399000_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 1520, "FRAME_2399000_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the GSE frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the PHOBOS_RADIAL frame. */

    s_copy(deftxt, "FRAME_PHOBOS_RADIAL              =  2401000", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2401000_NAME               = 'PHOBOS_RADIAL'", 
	    (ftnlen)80, (ftnlen)50);
    s_copy(deftxt + 160, "FRAME_2401000_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2401000_CLASS_ID           =  2401000", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2401000_CENTER             =  401", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2401000_RELATIVE           = 'IAU_MARS'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 480, "FRAME_2401000_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2401000_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2401000_PRI_AXIS       = 'Z'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2401000_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(deftxt + 800, "FRAME_2401000_PRI_OBSERVER       = 'PHOBOS'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 880, "FRAME_2401000_PRI_TARGET         = 'MARS'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 960, "FRAME_2401000_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 1040, "FRAME_2401000_SEC_AXIS       = '-X'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1120, "FRAME_2401000_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1200, "FRAME_2401000_SEC_OBSERVER       = 'PHOBOS'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 1280, "FRAME_2401000_SEC_TARGET       = 'MARS'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 1360, "FRAME_2401000_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1440, "FRAME_2401000_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 1520, "FRAME_2401000_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the PHOBOS_RADIAL frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     First test:  examine the GSE frame. */

    tcase_("Check GSE-to-J2000 frame transformation.", (ftnlen)40);
    et = 1e7;
    sxform_("GSE", "J2000", &et, xform, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Perform "sanity checks" on the returned matrix. Make sure the */
/*     diagonal blocks are identical rotations, compute a discrete */
/*     derivative and compare to the lower left block, and make sure the */
/*     upper right block is a zero matrix. */

    delta = 1.;
    d__1 = et - delta;
    pxform_("GSE", "J2000", &d__1, rminus, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = et + delta;
    pxform_("GSE", "J2000", &d__1, rplus, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_xform__(xform, rminus, rplus, &delta, &nrmerr, &deterr, &drverr, &
	    drlerr, drdiff);

/*     Check the error measurements we've made. First up is the */
/*     determinant error. */

    tol = 1e-14;
    chcksd_("DETERR", &deterr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check norms of rows and columns in the rotation blocks. */

    chcksd_("NRMERR", &nrmerr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check the absolute derivative error. */

    tol = 8e-14;
    chcksd_("DRVERR", &drverr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check the relative derivative error. */

    tol = 5.9999999999999995e-8;
    chcksd_("DRLERR", &drlerr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Second test:  examine the PHOBOS_RADIAL frame. */

    tcase_("Check PHOBOS_RADIAL-to-IAU_MARS frame transformation.", (ftnlen)
	    53);
    et = 1e7;
    sxform_("PHOBOS_RADIAL", "IAU_MARS", &et, xform, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Perform "sanity checks" on the returned matrix. Make sure the */
/*     diagonal blocks are identical rotations, compute a discrete */
/*     derivative and compare to the lower left block, and make sure the */
/*     upper right block is a zero matrix. */

    delta = 1.;
    d__1 = et - delta;
    pxform_("PHOBOS_RADIAL", "IAU_MARS", &d__1, rminus, (ftnlen)13, (ftnlen)8)
	    ;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = et + delta;
    pxform_("PHOBOS_RADIAL", "IAU_MARS", &d__1, rplus, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_xform__(xform, rminus, rplus, &delta, &nrmerr, &deterr, &drverr, &
	    drlerr, drdiff);

/*     Check the error measurements we've made. First up is the */
/*     determinant error. */

    tol = 1e-14;
    chcksd_("DETERR", &deterr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check norms of rows and columns in the rotation blocks. */

    chcksd_("NRMERR", &nrmerr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check the absolute derivative error. */

    tol = 1e-9;
    chcksd_("DRVERR", &drverr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/*     Check the relative derivative error. */

    tol = 4.9999999999999998e-7;
    chcksd_("DRLERR", &drlerr, "~", &c_b17, &tol, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Create an inertial version of the PHOBOS_RADIAL frame. */

    tcase_("Test INERTIAL version of PHOBOS_RADIAL frame.", (ftnlen)45);
    movec_(deftxt, &c__20, deftx2, (ftnlen)80, (ftnlen)80);
    repmc_(deftx2 + 1520, "ROTATING", "INERTIAL", deftx2 + 1520, (ftnlen)80, (
	    ftnlen)8, (ftnlen)8, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftx2, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("PHOBOS_RADIAL", "IAU_MARS", &et, xf2, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compare the PHOBOS_RADIAL to IAU_MARS transformation */
/*     defined using this frame to that using the standard */
/*     PHOBOS_RADIAL frame.  Just compare the rotation */
/*     blocks. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r__[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r", i__1, "f_dyn01__", (ftnlen)931)] = xform[(i__2 = i__ 
		    + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xform", 
		    i__2, "f_dyn01__", (ftnlen)931)];
	    r2[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r2", i__1, "f_dyn01__", (ftnlen)932)] = xf2[(i__2 = i__ 
		    + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xf2", 
		    i__2, "f_dyn01__", (ftnlen)932)];
	}
    }
    chckad_("Upper left block", r2, "~", r__, &c__9, &c_b17, ok, (ftnlen)16, (
	    ftnlen)1);
    for (i__ = 4; i__ <= 6; ++i__) {
	for (j = 4; j <= 6; ++j) {
	    r__[(i__1 = i__ - 3 + (j - 3) * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
		    s_rnge("r", i__1, "f_dyn01__", (ftnlen)940)] = xform[(
		    i__2 = i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge(
		    "xform", i__2, "f_dyn01__", (ftnlen)940)];
	    r2[(i__1 = i__ - 3 + (j - 3) * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
		    s_rnge("r2", i__1, "f_dyn01__", (ftnlen)941)] = xf2[(i__2 
		    = i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge(
		    "xf2", i__2, "f_dyn01__", (ftnlen)941)];
	}
    }
    chckad_("Lower right block", r2, "~", r__, &c__9, &c_b17, ok, (ftnlen)17, 
	    (ftnlen)1);

/*     Check results from PXFORM. */

    pxform_("PHOBOS_RADIAL", "IAU_MARS", &et, r3, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("PXFORM rotation", r3, "~", r2, &c__9, &c_b162, ok, (ftnlen)15, (
	    ftnlen)1);

/*     Check the derivative matrix:  when we compose the transformation */
/*     XF2 with the IAU_MARS-to-J2000 transformation, we should */
/*     get a result with derivative block zero. */

    sxform_("IAU_MARS", "J2000", &et, xf2000, (ftnlen)8, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxmg_(xf2000, xf2, &c__6, &c__6, &c__6, xfb2j);
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r__[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r", i__1, "f_dyn01__", (ftnlen)967)] = xfb2j[(i__2 = i__ 
		    + 3 + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xfb2j"
		    , i__2, "f_dyn01__", (ftnlen)967)];
	}
    }
    chckad_("Derivative block", r__, "~", zr, &c__9, &c_b177, ok, (ftnlen)16, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Create a frozen version of the PHOBOS_RADIAL frame. */

    tcase_("Test FROZEN version of PHOBOS_RADIAL frame.", (ftnlen)43);

/*     Expunge the optional ROTATN_STATE keyword from the kernel pool. */

    dvpool_("FRAME_2401000_ROTATION_STATE", (ftnlen)28);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Initialize the frame definition. */

    movec_(deftxt, &c__20, deftx2, (ftnlen)80, (ftnlen)80);

/*     Blank out the ROTATN_STATE assignment for this frame. */

    s_copy(deftx2 + 1520, " ", (ftnlen)80, (ftnlen)1);

/*     Set the freeze epoch equal to 1.E7 seconds past J2000 TDB. */

    s_copy(deftx2 + 1600, "FRAME_2401000_FREEZE_EPOCH       = @2000-117/05:4"
	    "6:40", (ftnlen)80, (ftnlen)53);
    lmpool_(deftx2, &c__21, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Although we look up XF2 at ET 0.D0, we should get the */
/*     same rotation we obtained from the standard PHOBOS_RADIAL */
/*     frame at ET 1.E7, except that the derivative block has */
/*     been zeroed out. */

    cleard_(&c__36, xf2);
    sxform_("PHOBOS_RADIAL", "IAU_MARS", &c_b17, xf2, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compare the PHOBOS_RADIAL to IAU_MARS transformation */
/*     defined using this frame to that using the standard */
/*     PHOBOS_RADIAL frame.  Just compare the rotation */
/*     blocks. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r__[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r", i__1, "f_dyn01__", (ftnlen)1024)] = xform[(i__2 = 
		    i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xform"
		    , i__2, "f_dyn01__", (ftnlen)1024)];
	    r2[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r2", i__1, "f_dyn01__", (ftnlen)1025)] = xf2[(i__2 = i__ 
		    + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xf2", 
		    i__2, "f_dyn01__", (ftnlen)1025)];
	}
    }
    chckad_("Upper left block", r2, "~", r__, &c__9, &c_b17, ok, (ftnlen)16, (
	    ftnlen)1);
    for (i__ = 4; i__ <= 6; ++i__) {
	for (j = 4; j <= 6; ++j) {
	    r__[(i__1 = i__ - 3 + (j - 3) * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
		    s_rnge("r", i__1, "f_dyn01__", (ftnlen)1033)] = xform[(
		    i__2 = i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge(
		    "xform", i__2, "f_dyn01__", (ftnlen)1033)];
	    r2[(i__1 = i__ - 3 + (j - 3) * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
		    s_rnge("r2", i__1, "f_dyn01__", (ftnlen)1034)] = xf2[(
		    i__2 = i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge(
		    "xf2", i__2, "f_dyn01__", (ftnlen)1034)];
	}
    }
    chckad_("Lower right block", r2, "~", r__, &c__9, &c_b17, ok, (ftnlen)17, 
	    (ftnlen)1);

/*     Check results from PXFORM. */

    pxform_("PHOBOS_RADIAL", "IAU_MARS", &et, r3, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("PXFORM rotation", r3, "~", r2, &c__9, &c_b162, ok, (ftnlen)15, (
	    ftnlen)1);

/*     Check the derivative matrix:  we should have derivative block */
/*     zero. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r__[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r", i__1, "f_dyn01__", (ftnlen)1054)] = xf2[(i__2 = i__ 
		    + 3 + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xf2", 
		    i__2, "f_dyn01__", (ftnlen)1054)];
	}
    }
    chckad_("Derivative block", r__, "~", zr, &c__9, &c_b177, ok, (ftnlen)16, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Create a new frozen frame that doesn't use a velocity */
/*     vector in its definition.  The secondary vector will be the */
/*     Mars-Sun vector. Start with the PHOBOS_RADIAL frame as a */
/*     template. */

    tcase_("Test FROZEN two-position vector frame.", (ftnlen)38);

/*     Initialize the frame definition. */

    movec_(deftxt, &c__20, deftx2, (ftnlen)80, (ftnlen)80);

/*     Blank out the ROTATN_STATE assignment for this frame. */

    s_copy(deftx2 + 1520, " ", (ftnlen)80, (ftnlen)1);
    repmc_(deftx2 + 1120, "OBSERVER_TARGET_VELOCITY", "OBSERVER_TARGET_POSIT"
	    "ION", deftx2 + 1120, (ftnlen)80, (ftnlen)24, (ftnlen)24, (ftnlen)
	    80);
    repmc_(deftx2 + 1280, "MARS", "SUN", deftx2 + 1280, (ftnlen)80, (ftnlen)4,
	     (ftnlen)3, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set the freeze epoch equal to 1.E7 seconds past J2000 TDB. */

    s_copy(deftx2 + 1600, "FRAME_2401000_FREEZE_EPOCH       = @2000-117/05:4"
	    "6:40", (ftnlen)80, (ftnlen)53);
    lmpool_(deftx2, &c__21, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Although we look up XF2 at ET 0.D0, we should get the */
/*     same rotation we obtained from the standard PHOBOS_RADIAL */
/*     frame at ET 1.E7, except that the derivative block has */
/*     been zeroed out. */

    cleard_(&c__36, xf2);
    sxform_("PHOBOS_RADIAL", "IAU_MARS", &c_b17, xf2, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the upper left rotation block from XF2. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r2[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r2", i__1, "f_dyn01__", (ftnlen)1109)] = xf2[(i__2 = i__ 
		    + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xf2", 
		    i__2, "f_dyn01__", (ftnlen)1109)];
	}
    }

/*     Check results from PXFORM. */

    pxform_("PHOBOS_RADIAL", "IAU_MARS", &et, r3, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("PXFORM rotation", r3, "~", r2, &c__9, &c_b162, ok, (ftnlen)15, (
	    ftnlen)1);

/*     Check the derivative matrix:  we should have derivative block */
/*     zero. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    r__[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "r", i__1, "f_dyn01__", (ftnlen)1127)] = xf2[(i__2 = i__ 
		    + 3 + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xf2", 
		    i__2, "f_dyn01__", (ftnlen)1127)];
	}
    }
    chckad_("Derivative block", r__, "~", zr, &c__9, &c_b177, ok, (ftnlen)16, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*     Create a new frozen frame with linearly dependent defining */
/*     vectors.  Both primary and secondary vectors will be the */
/*     Phobos-Mars position vector. Start with the PHOBOS_RADIAL frame */
/*     as a template. */

    tcase_("Test linearly dependent two-position vector frame.", (ftnlen)50);

/*     Initialize the frame definition. */

    movec_(deftxt, &c__20, deftx2, (ftnlen)80, (ftnlen)80);

/*     Blank out the ROTATN_STATE assignment for this frame. */

    s_copy(deftx2 + 1520, " ", (ftnlen)80, (ftnlen)1);
    repmc_(deftx2 + 1120, "OBSERVER_TARGET_VELOCITY", "OBSERVER_TARGET_POSIT"
	    "ION", deftx2 + 1120, (ftnlen)80, (ftnlen)24, (ftnlen)24, (ftnlen)
	    80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftx2, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure error is caught by both SXFORM and PXFORM. */

    sxform_("PHOBOS_RADIAL", "IAU_MARS", &c_b17, xf2, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);
    pxform_("PHOBOS_RADIAL", "IAU_MARS", &c_b17, r__, (ftnlen)13, (ftnlen)8);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Expunge the optional FREEZE_EPOCH keyword from the kernel pool. */

    dvpool_("FRAME_2401000_FREEZE_EPOCH", (ftnlen)26);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Restore the original PHOBOS_RADIAL frame definition. */

    s_copy(deftxt + 1600, " ", (ftnlen)80, (ftnlen)1);
    lmpool_(deftxt, &c__21, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Proceed to the general test cases. */


/*     Because there are so many options that may be used to define */
/*     a two-vector frame, we can't conveniently loop over every */
/*     set of possibilities using nested loops:  the loops would be */
/*     nested too deeply.  Instead, we define a mapping that allows */
/*     us to map a test case number to a set of input parameters. */

/*     First compute the number of test cases in the cartesian product */
/*     test. */

    ncart = prodai_(dims__, &c__5);

/*     All of the variables initialized here are used for debugging. */

    nogo = 0;
    npr = 0;
/*     NNORML = 0 */
    ncor = 0;
    nskip = 0;
    maxder = 0.;
    i__1 = ncart;
    for (case__ = 1; case__ <= i__1; ++case__) {

/*        Find the multi-dimensional coordinates of the current */
/*        case in the cartesian product of the test input sets. */

	multix_(&c__1, &c__5, dims__, &case__, coords);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set frame definition parameters defined by COORDS. */
/*        Start out with the base frame. */

	s_copy(bframe, basefr + (((i__2 = coords[1] - 1) < 2 && 0 <= i__2 ? 
		i__2 : s_rnge("basefr", i__2, "f_dyn01__", (ftnlen)1225)) << 
		5), (ftnlen)32, (ftnlen)32);

/*        The second dimension refers to the observer-target pairs */
/*        for the primary and secondary vectors.  (For constant */
/*        vectors, only the observer is used, and this is only if */
/*        aberration corrections are used.) */

	i__ = otpair[(i__2 = (coords[2] << 2) - 4) < 20 && 0 <= i__2 ? i__2 : 
		s_rnge("otpair", i__2, "f_dyn01__", (ftnlen)1233)];
	j = otpair[(i__2 = (coords[2] << 2) - 3) < 20 && 0 <= i__2 ? i__2 : 
		s_rnge("otpair", i__2, "f_dyn01__", (ftnlen)1234)];
	s_copy(priobs, bodies + (((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("bodies", i__2, "f_dyn01__", (ftnlen)1235)) << 5), (
		ftnlen)32, (ftnlen)32);
	s_copy(pritrg, bodies + (((i__2 = j - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("bodies", i__2, "f_dyn01__", (ftnlen)1236)) << 5), (
		ftnlen)32, (ftnlen)32);
	i__ = otpair[(i__2 = (coords[2] << 2) - 2) < 20 && 0 <= i__2 ? i__2 : 
		s_rnge("otpair", i__2, "f_dyn01__", (ftnlen)1238)];
	j = otpair[(i__2 = (coords[2] << 2) - 1) < 20 && 0 <= i__2 ? i__2 : 
		s_rnge("otpair", i__2, "f_dyn01__", (ftnlen)1239)];
	s_copy(secobs, bodies + (((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("bodies", i__2, "f_dyn01__", (ftnlen)1240)) << 5), (
		ftnlen)32, (ftnlen)32);
	s_copy(sectrg, bodies + (((i__2 = j - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("bodies", i__2, "f_dyn01__", (ftnlen)1241)) << 5), (
		ftnlen)32, (ftnlen)32);

/*        The third dimension refers to the extended vector */
/*        definition for the primary vector.  Extended definitions */
/*        include frame selections for velocity vectors and */
/*        constant vectors (those vectors requiring frames as */
/*        part of their definitions).  The ordering of extended */
/*        frame definitions is: */

/*            1           )  Observer-target position */
/*            2           )  Observer-near point position */
/*            3           )  Velocity vector, frame definition 1 */
/*                             ... */
/*            2 + NVECFR  )  Velocity vector, frame definition NVECFR */
/*            3 + NVECFR  )  Constant vector, frame definition 1 */
/*                             ... */
/*            2 + 2*NVECFR)  Constant vector, frame definition NVECFR */

/*        The fourth dimension provides the analogous information */
/*        for the secondary vector. */

/*        We'll process the definitions for both vectors in the loop */
/*        below. */

	for (i__ = 1; i__ <= 2; ++i__) {

/*           Indicate that we don't have a velocity vector or */
/*           constant vector until we know otherwise. */

	    isvel[(i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("isvel", 
		    i__2, "f_dyn01__", (ftnlen)1272)] = FALSE_;
	    iscon[(i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("iscon", 
		    i__2, "f_dyn01__", (ftnlen)1273)] = FALSE_;
	    if (i__ == 1) {
		coridx = 4;
	    } else {
		coridx = 5;
	    }
	    j = coords[(i__2 = coridx - 1) < 5 && 0 <= i__2 ? i__2 : s_rnge(
		    "coords", i__2, "f_dyn01__", (ftnlen)1281)];
	    if (i__ == 1) {
		prij = j;
	    }
	    if (j == 1) {

/*              The vector is an observer-target position. */

		s_copy(vdf, vecdef, (ftnlen)80, (ftnlen)80);
		s_copy(vfr, " ", (ftnlen)80, (ftnlen)1);
	    } else if (j == 2) {

/*              The vector is an observer-near point position. */

		s_copy(vdf, vecdef + 80, (ftnlen)80, (ftnlen)80);
		s_copy(vfr, " ", (ftnlen)80, (ftnlen)1);
	    } else if (j >= 3 && j <= 7) {

/*              The vector is an observer-target velocity. */
/*              The quantity J-2 is an index into the vector */
/*              frame array. */

		s_copy(vdf, vecdef + 160, (ftnlen)80, (ftnlen)80);
		s_copy(vfr, vecfrm + ((i__2 = j - 3) < 5 && 0 <= i__2 ? i__2 :
			 s_rnge("vecfrm", i__2, "f_dyn01__", (ftnlen)1310)) * 
			80, (ftnlen)80, (ftnlen)80);
		isvel[(i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("isv"
			"el", i__2, "f_dyn01__", (ftnlen)1311)] = TRUE_;
	    } else {

/*              The primary is constant in the specified frame. */
/*              The quantity J-2-NVECFR is an index into the vector */
/*              frame array. */

		s_copy(vdf, vecdef + 240, (ftnlen)80, (ftnlen)80);
		s_copy(vfr, vecfrm + ((i__2 = j - 8) < 5 && 0 <= i__2 ? i__2 :
			 s_rnge("vecfrm", i__2, "f_dyn01__", (ftnlen)1320)) * 
			80, (ftnlen)80, (ftnlen)80);
		iscon[(i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("isc"
			"on", i__2, "f_dyn01__", (ftnlen)1321)] = TRUE_;
	    }
	    if (i__ == 1) {
		s_copy(privdf, vdf, (ftnlen)80, (ftnlen)80);
		s_copy(prifrm, vfr, (ftnlen)32, (ftnlen)80);
	    } else {
		s_copy(secvdf, vdf, (ftnlen)80, (ftnlen)80);
		s_copy(secfrm, vfr, (ftnlen)32, (ftnlen)80);
	    }

/*           Set the aberration correction for the current vector. */

	    j = abpair[(i__2 = i__ + (coords[0] << 1) - 3) < 10 && 0 <= i__2 ?
		     i__2 : s_rnge("abpair", i__2, "f_dyn01__", (ftnlen)1336)]
		    ;

/*           If the current vector is constant, adjust the */
/*           aberration correction to make it valid for constant */
/*           vectors. */

/*           For the special case of constant vectors, the correction */
/*           'LT+S' is replaced with the correction 'LT', the correction */
/*           'XLT' is replaced with the correction 'S', and the */
/*           correction 'XLT+S' is replaced with the correction 'XS'. */

	    if (iscon[(i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("isc"
		    "on", i__2, "f_dyn01__", (ftnlen)1348)]) {
		if (s_cmp(abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? i__2 : 
			s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)1350)) * 
			15, "LT+S", (ftnlen)15, (ftnlen)4) == 0) {

/*                 Set the correction for this vector to 'LT' */

		    j = isrchc_("LT", &c__11, abcorr, (ftnlen)2, (ftnlen)15);
		} else if (s_cmp(abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)
			1356)) * 15, "XLT", (ftnlen)15, (ftnlen)3) == 0) {

/*                 Set the correction for this vector to 'S' */

		    j = isrchc_("S", &c__11, abcorr, (ftnlen)1, (ftnlen)15);
		} else if (s_cmp(abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)
			1363)) * 15, "XLT+S", (ftnlen)15, (ftnlen)5) == 0) {

/*                 Set the correction for this vector to 'XS' */

		    j = isrchc_("XS", &c__11, abcorr, (ftnlen)2, (ftnlen)15);
		} else if (s_cmp(abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)
			1369)) * 15, "NONE", (ftnlen)15, (ftnlen)4) == 0) {

/*                 Set the correction for this vector to 'NONE' */

		    j = isrchc_("NONE", &c__11, abcorr, (ftnlen)4, (ftnlen)15)
			    ;
		} else {
		    setmsg_("Unexpected aberration correction # was encounte"
			    "red when mapping correction for constant vector "
			    "#.Case is #.", (ftnlen)107);
		    errch_("#", abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			    i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (
			    ftnlen)1381)) * 15, (ftnlen)1, (ftnlen)15);
		    errint_("#", &i__, (ftnlen)1);
		    errint_("#", &case__, (ftnlen)1);
		    sigerr_("SPICE(BUG)", (ftnlen)10);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    return 0;
		}
	    }
	    if (i__ == 1) {
		s_copy(pricor, abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)
			1395)) * 15, (ftnlen)15, (ftnlen)15);
	    } else {
		s_copy(seccor, abcorr + ((i__2 = j - 1) < 11 && 0 <= i__2 ? 
			i__2 : s_rnge("abcorr", i__2, "f_dyn01__", (ftnlen)
			1397)) * 15, (ftnlen)15, (ftnlen)15);
	    }
	}

/*        Decide whether we need to execute the current case. */

/*        There are certain cases we can skip: */

/*           1) Neither vector is a velocity vector and both */
/*              vectors have the same observer/target sets. */
/*              Such vector pairs will be too close to linearly */
/*              dependent to work with. */

/*           2) Both vectors are velocity vectors. */

	go = TRUE_;

/*        Use this code to disable testing of frames defined by */
/*        a pair of velocity vectors. */

/*         IF ( ISVEL(1) .AND. ISVEL(2) ) THEN */
/*            GO = .FALSE. */
/*         END IF */
	j = coords[3];
	k = coords[4];
	if (isvel[0] && isvel[1] || j <= 2 && k <= 2) {

/*           The primary and secondary vectors are either both */

/*              - velocity vectors */

/*              - in the set */

/*                  { OBSERVER_TARGET_POSITION, TARGET_NEAR_POINT } */

/*           In this case we don't want both vectors to be defined */
/*           by the same pair of objects, because the vectors will */
/*           be linearly dependent or close to it. */

	    if ((s_cmp(priobs, secobs, (ftnlen)32, (ftnlen)32) == 0 || s_cmp(
		    priobs, sectrg, (ftnlen)32, (ftnlen)32) == 0) && (s_cmp(
		    pritrg, secobs, (ftnlen)32, (ftnlen)32) == 0 || s_cmp(
		    pritrg, sectrg, (ftnlen)32, (ftnlen)32) == 0)) {
		go = FALSE_;
	    }
	}

/*        Another linear dependency problem:  if the vector frame */
/*        is PHOBOS_RADIAL, then we don't want cases where the observer */
/*        and target are from the set { Phobos, Mars } for both */
/*        vectors. */

	if (s_cmp(prifrm, "PHOBOS_RADIAL", (ftnlen)32, (ftnlen)13) == 0 || 
		s_cmp(secfrm, "PHOBOS_RADIAL", (ftnlen)32, (ftnlen)13) == 0) {

/*           Note: this code must change if the observer-target pairs */
/*           are changed! */

	    if (coords[2] == 1) {
		go = FALSE_;
	    }
	}

/*        Similar problem for the earth and sun when the velocity */
/*        frame is GSE: */

	if (s_cmp(prifrm, "GSE", (ftnlen)32, (ftnlen)3) == 0 || s_cmp(secfrm, 
		"GSE", (ftnlen)32, (ftnlen)3) == 0) {

/*           Note: this code must change if the observer-target pairs */
/*           are changed! */

	    if (coords[2] == 4) {
		go = FALSE_;
	    }
	}

/*         Bits used for debugging */

	if (! go) {
	    ++nogo;
	}
	if (go) {

/*           Cycle over the vector-axis associations.  There's */
/*           no interaction between these parameters and the */
/*           other parameters, so we don't need to try every */
/*           possible combination of these values with the other */
/*           inputs.  We just need to use each association. */

	    axpair = case__ % 6 + 1;

/*           We're ready to create a frame definition. */


/*           Create a text buffer containing a frame definition that */
/*           uses the current frame definition */


/*           First comes the frame name-to-frame code assignment. */

	    s_copy(frname, "TWOVEC_DYN_FRAME", (ftnlen)32, (ftnlen)16);
	    frcode = -2000000000;
	    s_copy(deftxt, "FRAME_#          = #", (ftnlen)80, (ftnlen)20);
	    repmc_(deftxt, "#", frname, deftxt, (ftnlen)80, (ftnlen)1, (
		    ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt, "#", &frcode, deftxt, (ftnlen)80, (ftnlen)1, (
		    ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           We'll use the kernel variable name "stem" */

/*              FRAME_<ID code>_ */

/*           repeatedly, so instead of making thousands of REPMI */
/*           calls, we just create this stem here. */

	    repmi_("FRAME_#_", "#", &frcode, frstem, (ftnlen)8, (ftnlen)1, (
		    ftnlen)18);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 22, a__1[1] = "NAME             = '#'";
	    s_cat(deftxt + 80, a__1, i__3, &c__2, (ftnlen)80);
	    repmc_(deftxt + 80, "#", frname, deftxt + 80, (ftnlen)80, (ftnlen)
		    1, (ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Frame class and class ID come next. */

/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 20, a__1[1] = "CLASS            = 5";
	    s_cat(deftxt + 160, a__1, i__3, &c__2, (ftnlen)80);
/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 20, a__1[1] = "CLASS_ID         = #";
	    s_cat(deftxt + 240, a__1, i__3, &c__2, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt + 240, "#", &frcode, deftxt + 240, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           The frame center is always the primary vector's */
/*           observer, for now.  The center must be specified */
/*           via a code. */

/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 20, a__1[1] = "CENTER           = #";
	    s_cat(deftxt + 320, a__1, i__3, &c__2, (ftnlen)80);
	    bodn2c_(priobs, &j, &found, (ftnlen)32);
	    if (! found) {
		setmsg_("No ID code for #.", (ftnlen)17);
		errch_("#", priobs, (ftnlen)1, (ftnlen)32);
		sigerr_("SPICE(BUG)", (ftnlen)10);
	    }
	    repmi_(deftxt + 320, "#", &j, deftxt + 320, (ftnlen)80, (ftnlen)1,
		     (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the base frame. */

/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 22, a__1[1] = "RELATIVE         = '#'";
	    s_cat(deftxt + 400, a__1, i__3, &c__2, (ftnlen)80);
	    repmc_(deftxt + 400, "#", bframe, deftxt + 400, (ftnlen)80, (
		    ftnlen)1, (ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the frame definition style and family. */

/* Writing concatenation */
	    i__4[0] = 18, a__2[0] = frstem;
	    i__4[1] = 9, a__2[1] = "DEF_STYLE";
	    i__4[2] = 10, a__2[2] = "       = '";
	    i__4[3] = 13, a__2[3] = "PARAMETERIZED";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 480, a__2, i__4, &c__5, (ftnlen)80);
	    repmi_(deftxt + 480, "#", &frcode, deftxt + 480, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* Writing concatenation */
	    i__4[0] = 18, a__2[0] = frstem;
	    i__4[1] = 6, a__2[1] = "FAMILY";
	    i__4[2] = 16, a__2[2] = "             = '";
	    i__4[3] = 10, a__2[3] = "TWO-VECTOR";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 560, a__2, i__4, &c__5, (ftnlen)80);
	    repmi_(deftxt + 560, "#", &frcode, deftxt + 560, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* Writing concatenation */
	    i__4[0] = 18, a__2[0] = frstem;
	    i__4[1] = 14, a__2[1] = "ROTATION_STATE";
	    i__4[2] = 11, a__2[2] = "       =  '";
	    i__4[3] = 8, a__2[3] = "ROTATING";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 640, a__2, i__4, &c__5, (ftnlen)80);
	    repmi_(deftxt + 640, "#", &frcode, deftxt + 640, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Create definition assignments for the primary and secondary */
/*           axes. */

/*           At this point, we'll have to abandon hard-coded array */
/*           indices for the DEFTXT array and instead use the variable */
/*           DX to represent the current index. */

	    dx = 10;

/*           Blank out the variables containing associated frame names, */
/*           so we don't end up with residual values from other test */
/*           cases in these names. */

	    s_copy(privf, " ", (ftnlen)32, (ftnlen)1);
	    s_copy(secvf, " ", (ftnlen)32, (ftnlen)1);
	    s_copy(vframe, " ", (ftnlen)32, (ftnlen)1);
	    for (i__ = 1; i__ <= 2; ++i__) {
		if (i__ == 1) {

/*                 On the first pass, set up definitions for the */
/*                 primary vector. */

		    s_copy(ord, "PRI_", (ftnlen)4, (ftnlen)4);
		    s_copy(vdf, privdf, (ftnlen)80, (ftnlen)80);
		    s_copy(vfr, prifrm, (ftnlen)80, (ftnlen)32);
		    s_copy(cor, pricor, (ftnlen)15, (ftnlen)15);
		    s_copy(obs, priobs, (ftnlen)32, (ftnlen)32);
		    s_copy(targ, pritrg, (ftnlen)32, (ftnlen)32);
		} else {

/*                 On the second pass, set up definitions for the */
/*                 secondary vector. */

		    s_copy(ord, "SEC_", (ftnlen)4, (ftnlen)4);
		    s_copy(vdf, secvdf, (ftnlen)80, (ftnlen)80);
		    s_copy(vfr, secfrm, (ftnlen)80, (ftnlen)32);
		    s_copy(cor, seccor, (ftnlen)15, (ftnlen)15);
		    s_copy(obs, secobs, (ftnlen)32, (ftnlen)32);
		    s_copy(targ, sectrg, (ftnlen)32, (ftnlen)32);
		}

/*              Identify the axis { +/-X, +/-Y, +/-Z } associated */
/*              with the current vector. */

/* Writing concatenation */
		i__5[0] = 18, a__3[0] = frstem;
		i__5[1] = 4, a__3[1] = ord;
		i__5[2] = 18, a__3[2] = "AXIS         = '#'";
		s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1653)) * 
			80, a__3, i__5, &c__3, (ftnlen)80);
		repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1655)) * 
			80, "#", axdef + ((i__6 = i__ + (axpair << 1) - 3) < 
			12 && 0 <= i__6 ? i__6 : s_rnge("axdef", i__6, "f_dy"
			"n01__", (ftnlen)1655)) * 80, deftxt + ((i__7 = dx - 1)
			 < 50 && 0 <= i__7 ? i__7 : s_rnge("deftxt", i__7, 
			"f_dyn01__", (ftnlen)1655)) * 80, (ftnlen)80, (ftnlen)
			1, (ftnlen)80, (ftnlen)80);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		++dx;

/*              Set the current vector definition. */

/* Writing concatenation */
		i__8[0] = 18, a__4[0] = frstem;
		i__8[1] = 4, a__4[1] = ord;
		i__8[2] = 10, a__4[2] = "VECTOR_DEF";
		i__8[3] = 10, a__4[3] = "     = '#'";
		s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1665)) * 
			80, a__4, i__8, &c__4, (ftnlen)80);
		repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1666)) * 
			80, "#", vdf, deftxt + ((i__6 = dx - 1) < 50 && 0 <= 
			i__6 ? i__6 : s_rnge("deftxt", i__6, "f_dyn01__", (
			ftnlen)1666)) * 80, (ftnlen)80, (ftnlen)1, (ftnlen)80,
			 (ftnlen)80);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		++dx;

/*              Set the current vector observer. */

/* Writing concatenation */
		i__8[0] = 18, a__4[0] = frstem;
		i__8[1] = 4, a__4[1] = ord;
		i__8[2] = 8, a__4[2] = "OBSERVER";
		i__8[3] = 10, a__4[3] = "     = '#'";
		s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1673)) * 
			80, a__4, i__8, &c__4, (ftnlen)80);
		repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1674)) * 
			80, "#", obs, deftxt + ((i__6 = dx - 1) < 50 && 0 <= 
			i__6 ? i__6 : s_rnge("deftxt", i__6, "f_dyn01__", (
			ftnlen)1674)) * 80, (ftnlen)80, (ftnlen)1, (ftnlen)32,
			 (ftnlen)80);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		++dx;

/*              Set the current vector target.  Constant vectors */
/*              don't have targets. */

		if (s_cmp(vdf, "CONSTANT", (ftnlen)80, (ftnlen)8) != 0) {
/* Writing concatenation */
		    i__8[0] = 18, a__4[0] = frstem;
		    i__8[1] = 4, a__4[1] = ord;
		    i__8[2] = 6, a__4[2] = "TARGET";
		    i__8[3] = 10, a__4[3] = "     = '#'";
		    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 :
			     s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1684)
			    ) * 80, a__4, i__8, &c__4, (ftnlen)80);
		    repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 
			    : s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)
			    1685)) * 80, "#", targ, deftxt + ((i__6 = dx - 1) 
			    < 50 && 0 <= i__6 ? i__6 : s_rnge("deftxt", i__6, 
			    "f_dyn01__", (ftnlen)1685)) * 80, (ftnlen)80, (
			    ftnlen)1, (ftnlen)32, (ftnlen)80);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    ++dx;
		}

/*              Set the current vector's aberration correction. */

/* Writing concatenation */
		i__8[0] = 18, a__4[0] = frstem;
		i__8[1] = 4, a__4[1] = ord;
		i__8[2] = 6, a__4[2] = "ABCORR";
		i__8[3] = 10, a__4[3] = "     = '#'";
		s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1693)) * 
			80, a__4, i__8, &c__4, (ftnlen)80);
		repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 : 
			s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1695)) * 
			80, "#", cor, deftxt + ((i__6 = dx - 1) < 50 && 0 <= 
			i__6 ? i__6 : s_rnge("deftxt", i__6, "f_dyn01__", (
			ftnlen)1695)) * 80, (ftnlen)80, (ftnlen)1, (ftnlen)15,
			 (ftnlen)80);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		++dx;

/*              Set the current vector's frame, if necessary. */
/*              Velocity vectors and constant vectors have associated */
/*              frames. */

		if (s_cmp(vdf, "OBSERVER_TARGET_VELOCITY", (ftnlen)80, (
			ftnlen)24) == 0 || s_cmp(vdf, "CONSTANT", (ftnlen)80, 
			(ftnlen)8) == 0) {
		    if (s_cmp(vfr, "J2000", (ftnlen)80, (ftnlen)5) == 0 || 
			    s_cmp(vfr, "IAU_JUPITER", (ftnlen)80, (ftnlen)11) 
			    == 0 || s_cmp(vfr, "GSE", (ftnlen)80, (ftnlen)3) 
			    == 0 || s_cmp(vfr, "IAU_PHOBOS", (ftnlen)80, (
			    ftnlen)10) == 0 || s_cmp(vfr, "PHOBOS_RADIAL", (
			    ftnlen)80, (ftnlen)13) == 0) {
			s_copy(vframe, vfr, (ftnlen)32, (ftnlen)80);
		    } else if (s_cmp(vfr, "BASE_FRAME", (ftnlen)80, (ftnlen)
			    10) == 0) {
			s_copy(vframe, bframe, (ftnlen)32, (ftnlen)32);
		    } else if (s_cmp(vfr, "OBSERVER_FRAME", (ftnlen)80, (
			    ftnlen)14) == 0) {
			cnmfrm_(obs, &vfcode, vframe, &found, (ftnlen)32, (
				ftnlen)32);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			if (! found) {
			    setmsg_("No frame info for #.", (ftnlen)20);
			    errch_("#", obs, (ftnlen)1, (ftnlen)32);
			    sigerr_("SPICE(BUG)", (ftnlen)10);
			}
		    } else if (s_cmp(vfr, "TARGET_FRAME", (ftnlen)80, (ftnlen)
			    12) == 0) {
			cnmfrm_(targ, &vfcode, vframe, &found, (ftnlen)32, (
				ftnlen)32);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			if (! found) {
			    setmsg_("No frame info for #.", (ftnlen)20);
			    errch_("#", targ, (ftnlen)1, (ftnlen)32);
			    sigerr_("SPICE(BUG)", (ftnlen)10);
			}
		    } else {
			setmsg_("Unexpected velocity frame token: #", (ftnlen)
				34);
			errch_("#", vfr, (ftnlen)1, (ftnlen)80);
			sigerr_("SPICE(BUG)", (ftnlen)10);
		    }

/*                 Save the resolved frame names for later testing. */

		    if (i__ == 1) {
			s_copy(privf, vframe, (ftnlen)32, (ftnlen)32);
		    } else {
			s_copy(secvf, vframe, (ftnlen)32, (ftnlen)32);
		    }
/* Writing concatenation */
		    i__8[0] = 18, a__4[0] = frstem;
		    i__8[1] = 4, a__4[1] = ord;
		    i__8[2] = 5, a__4[2] = "FRAME";
		    i__8[3] = 13, a__4[3] = "        = '#'";
		    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 :
			     s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)1756)
			    ) * 80, a__4, i__8, &c__4, (ftnlen)80);
		    repmc_(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? i__2 
			    : s_rnge("deftxt", i__2, "f_dyn01__", (ftnlen)
			    1758)) * 80, "#", vframe, deftxt + ((i__6 = dx - 
			    1) < 50 && 0 <= i__6 ? i__6 : s_rnge("deftxt", 
			    i__6, "f_dyn01__", (ftnlen)1758)) * 80, (ftnlen)
			    80, (ftnlen)1, (ftnlen)32, (ftnlen)80);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    ++dx;
		}

/*              If the vector is constant, define it.  The vector */
/*              definitions have no interaction with the other defining */
/*              parameters other than the vector order, so all we need */
/*              do is make sure all definitions are covered for the */
/*              primary and secondary vectors.  We'll use the following */
/*              definitions: */

/*                 ... SPEC      = 'RECTANGULAR' */
/*                 ... VECTOR    = ( <number1>, <number2>, <number3> ) */

/*                 ... SPEC      = 'RECTANGULAR' */
/*                 ... VECTOR    = ( <number4>, <number5>, <number6> ) */

/*                 ... SPEC      = 'RECTANGULAR' */
/*                 ... VECTOR    = ( <number7>, <number8>, <number9> ) */

/*                 ... SPEC      = 'LATITUDINAL' */
/*                 ... UNITS     = 'DEGREES' */
/*                 ... LONGITUDE = <number> */
/*                 ... LATITUDE  = <number> */

/*                 ... SPEC      = 'LATITUDINAL' */
/*                 ... UNITS     = 'RADIANS' */
/*                 ... LONGITUDE = <number> */
/*                 ... LATITUDE  = <number> */



		if (s_cmp(vdf, "CONSTANT", (ftnlen)80, (ftnlen)8) == 0) {
		    if (i__ == 1) {
			++ncor;
		    }

/*                 Make the vector selection depend on the case */
/*                 and whether the axis is primary or secondary. */

		    j = (ncor + i__) % 5 + 1;
		    if (j <= 3) {

/*                    This is the rectangular coordinate case. */

			sysidx = 1;
/* Writing concatenation */
			i__4[0] = 18, a__2[0] = frstem;
			i__4[1] = 4, a__2[1] = ord;
			i__4[2] = 4, a__2[2] = "SPEC";
			i__4[3] = 11, a__2[3] = "         = ";
			i__4[4] = 80, a__2[4] = corsys + ((i__6 = sysidx - 1) 
				< 3 && 0 <= i__6 ? i__6 : s_rnge("corsys", 
				i__6, "f_dyn01__", (ftnlen)1811)) * 80;
			s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? 
				i__2 : s_rnge("deftxt", i__2, "f_dyn01__", (
				ftnlen)1811)) * 80, a__2, i__4, &c__5, (
				ftnlen)80);
			++dx;
/* Writing concatenation */
			i__8[0] = 18, a__4[0] = frstem;
			i__8[1] = 4, a__4[1] = ord;
			i__8[2] = 6, a__4[2] = "VECTOR";
			i__8[3] = 9, a__4[3] = "       = ";
			s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? 
				i__2 : s_rnge("deftxt", i__2, "f_dyn01__", (
				ftnlen)1816)) * 80, a__4, i__8, &c__4, (
				ftnlen)80);
			suffix_(vecstr + ((i__2 = j - 1) < 3 && 0 <= i__2 ? 
				i__2 : s_rnge("vecstr", i__2, "f_dyn01__", (
				ftnlen)1819)) * 80, &c__1, deftxt + ((i__6 = 
				dx - 1) < 50 && 0 <= i__6 ? i__6 : s_rnge(
				"deftxt", i__6, "f_dyn01__", (ftnlen)1819)) * 
				80, (ftnlen)80, (ftnlen)80);
			++dx;

/*                    Produce the d.p. constant vector; we'll use this */
/*                    in later testing.  Start by parsing the string */
/*                    representing the vector.  The first token will */
/*                    be a blank (representing the null token to the */
/*                    left of the left parenthesis), so start with */
/*                    token #2. */

			lparsm_(vecstr + ((i__2 = j - 1) < 3 && 0 <= i__2 ? 
				i__2 : s_rnge("vecstr", i__2, "f_dyn01__", (
				ftnlen)1830)) * 80, "(),", &c__7, &n, tokens, 
				(ftnlen)80, (ftnlen)3, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			for (l = 2; l <= 4; ++l) {
			    prsdp_(tokens + ((i__2 = l - 1) < 7 && 0 <= i__2 ?
				     i__2 : s_rnge("tokens", i__2, "f_dyn01__"
				    , (ftnlen)1834)) * 80, &convec[(i__6 = l 
				    - 2) < 3 && 0 <= i__6 ? i__6 : s_rnge(
				    "convec", i__6, "f_dyn01__", (ftnlen)1834)
				    ], (ftnlen)80);
			    chckxc_(&c_false, " ", ok, (ftnlen)1);
			}
		    } else {

/*                    This is one of the latitudinal or RA/DEC */
/*                    coordinate cases. */

			if (j == 4) {

/*                       Use latitudinal coordinates. */

			    sysidx = 2;
			} else {

/*                       Use RA/DEC coordinates. */

			    sysidx = 3;
			}
/* Writing concatenation */
			i__4[0] = 18, a__2[0] = frstem;
			i__4[1] = 4, a__2[1] = ord;
			i__4[2] = 4, a__2[2] = "SPEC";
			i__4[3] = 11, a__2[3] = "         = ";
			i__4[4] = 80, a__2[4] = corsys + ((i__6 = sysidx - 1) 
				< 3 && 0 <= i__6 ? i__6 : s_rnge("corsys", 
				i__6, "f_dyn01__", (ftnlen)1855)) * 80;
			s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? 
				i__2 : s_rnge("deftxt", i__2, "f_dyn01__", (
				ftnlen)1855)) * 80, a__2, i__4, &c__5, (
				ftnlen)80);
			++dx;

/*                    Let K be the index of the units. */

			k = j - 3;
/* Writing concatenation */
			i__4[0] = 18, a__2[0] = frstem;
			i__4[1] = 4, a__2[1] = ord;
			i__4[2] = 5, a__2[2] = "UNITS";
			i__4[3] = 10, a__2[3] = "        = ";
			i__4[4] = 80, a__2[4] = units + ((i__6 = k - 1) < 2 &&
				 0 <= i__6 ? i__6 : s_rnge("units", i__6, 
				"f_dyn01__", (ftnlen)1864)) * 80;
			s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 ? 
				i__2 : s_rnge("deftxt", i__2, "f_dyn01__", (
				ftnlen)1864)) * 80, a__2, i__4, &c__5, (
				ftnlen)80);
			++dx;
			if (j == 4) {
/* Writing concatenation */
			    i__8[0] = 18, a__4[0] = frstem;
			    i__8[1] = 4, a__4[1] = ord;
			    i__8[2] = 9, a__4[2] = "LONGITUDE";
			    i__8[3] = 6, a__4[3] = "    = ";
			    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 
				    ? i__2 : s_rnge("deftxt", i__2, "f_dyn01"
				    "__", (ftnlen)1869)) * 80, a__4, i__8, &
				    c__4, (ftnlen)80);
			} else {
/* Writing concatenation */
			    i__8[0] = 18, a__4[0] = frstem;
			    i__8[1] = 4, a__4[1] = ord;
			    i__8[2] = 2, a__4[2] = "RA";
			    i__8[3] = 13, a__4[3] = "           = ";
			    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 
				    ? i__2 : s_rnge("deftxt", i__2, "f_dyn01"
				    "__", (ftnlen)1872)) * 80, a__4, i__8, &
				    c__4, (ftnlen)80);
			}
			suffix_(angstr + ((i__2 = (k << 1) - 2) < 4 && 0 <= 
				i__2 ? i__2 : s_rnge("angstr", i__2, "f_dyn0"
				"1__", (ftnlen)1876)) * 80, &c__1, deftxt + ((
				i__6 = dx - 1) < 50 && 0 <= i__6 ? i__6 : 
				s_rnge("deftxt", i__6, "f_dyn01__", (ftnlen)
				1876)) * 80, (ftnlen)80, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Save the longitude as a d.p. number. */

			prsdp_(angstr + ((i__2 = (k << 1) - 2) < 4 && 0 <= 
				i__2 ? i__2 : s_rnge("angstr", i__2, "f_dyn0"
				"1__", (ftnlen)1881)) * 80, &lon0, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			++dx;
			if (j == 4) {
/* Writing concatenation */
			    i__8[0] = 18, a__4[0] = frstem;
			    i__8[1] = 4, a__4[1] = ord;
			    i__8[2] = 8, a__4[2] = "LATITUDE";
			    i__8[3] = 7, a__4[3] = "     = ";
			    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 
				    ? i__2 : s_rnge("deftxt", i__2, "f_dyn01"
				    "__", (ftnlen)1886)) * 80, a__4, i__8, &
				    c__4, (ftnlen)80);
			} else {
/* Writing concatenation */
			    i__8[0] = 18, a__4[0] = frstem;
			    i__8[1] = 4, a__4[1] = ord;
			    i__8[2] = 3, a__4[2] = "DEC";
			    i__8[3] = 12, a__4[3] = "          = ";
			    s_cat(deftxt + ((i__2 = dx - 1) < 50 && 0 <= i__2 
				    ? i__2 : s_rnge("deftxt", i__2, "f_dyn01"
				    "__", (ftnlen)1889)) * 80, a__4, i__8, &
				    c__4, (ftnlen)80);
			}
			suffix_(angstr + ((i__2 = (k << 1) - 1) < 4 && 0 <= 
				i__2 ? i__2 : s_rnge("angstr", i__2, "f_dyn0"
				"1__", (ftnlen)1893)) * 80, &c__1, deftxt + ((
				i__6 = dx - 1) < 50 && 0 <= i__6 ? i__6 : 
				s_rnge("deftxt", i__6, "f_dyn01__", (ftnlen)
				1893)) * 80, (ftnlen)80, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			++dx;

/*                    Save the latitude as a d.p. number. */

			prsdp_(angstr + ((i__2 = (k << 1) - 1) < 4 && 0 <= 
				i__2 ? i__2 : s_rnge("angstr", i__2, "f_dyn0"
				"1__", (ftnlen)1899)) * 80, &lat0, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Convert the numeric lat/lon values to radians. */

			cmprss_("'", &c__0, units + ((i__2 = k - 1) < 2 && 0 
				<= i__2 ? i__2 : s_rnge("units", i__2, "f_dy"
				"n01__", (ftnlen)1905)) * 80, tmpstr, (ftnlen)
				1, (ftnlen)80, (ftnlen)80);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			convrt_(&lat0, tmpstr, "RADIANS", &lat, (ftnlen)80, (
				ftnlen)7);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			convrt_(&lon0, tmpstr, "RADIANS", &lon, (ftnlen)80, (
				ftnlen)7);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Produce a d.p. constant vector. */

			latrec_(&c_b643, &lon, &lat, convec);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    }

/*                 Save the constant vector as one of the defining */
/*                 vectors. */

		    if (i__ == 1) {
			vequ_(convec, privec);
		    } else {
			vequ_(convec, secvec);
		    }
		}
	    }

/*           Enter the frame definition into the kernel pool. */

	    i__2 = dx - 1;
	    lmpool_(deftxt, &i__2, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Here's where the testing begins. */


/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM test number #.  Test results against those from P"
		    "XFORM.", "#", &case__, casmsg, (ftnlen)62, (ftnlen)1, (
		    ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)80);

/*           Pick a time value. */

	    et = (case__ - 5000) * 1e3;
/*            WRITE (*,*) 'F_DYN01:  SXFORM CALL <<<<<<<<<<<<<<<<<<' */
	    sxform_(frname, bframe, &et, xform, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           IF ( .NOT. OK ) THEN */
/*              DO I = 1, DX-1 */
/*                 WRITE (*,*) DEFTXT(I) */
/*              END DO */

/*              WRITE (*,*) '=================================== ' */
/*           END IF */

/*            WRITE (*,*) 'F_DYN01:  DONE <<<<<<<<<<<<<<<<<<' */
	    pxform_(frname, bframe, &et, r__, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Extract the derivative block from XFORM into DRVBLK. */
/*           We'll use this block later; we're extracting it here */
/*           to keep this code close to the associated SXFORM call. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    drvblk[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("drvblk", i__2, "f_dyn01__", (ftnlen)1991)]
			     = xform[(i__6 = j + 3 + i__ * 6 - 7) < 36 && 0 <=
			     i__6 ? i__6 : s_rnge("xform", i__6, "f_dyn01__", 
			    (ftnlen)1991)];
		}
	    }
	    dmag = vnormg_(drvblk, &c__9);

/*           Extract the rotation block from XFORM into R2. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    r2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("r2", i__2, "f_dyn01__", (ftnlen)2002)] = 
			    xform[(i__6 = j + i__ * 6 - 7) < 36 && 0 <= i__6 ?
			     i__6 : s_rnge("xform", i__6, "f_dyn01__", (
			    ftnlen)2002)];
		}
	    }
	    chckad_("SXFORM vs PXFORM", r2, "~", r__, &c__9, &c_b668, ok, (
		    ftnlen)16, (ftnlen)1);

/*               These statements may be useful for debugging. */


/*               IF ( .NOT. OK ) THEN */

/*                  WRITE (*,*) '=================================== ' */
/*                  WRITE (*,*) 'CASE = ', CASE */
/*                  WRITE (*,*) COORDS */
/*                  WRITE (*,*) 'PRIFRM  = ', PRIFRM */
/*                  WRITE (*,*) 'PRIJ    = ', PRIJ */
/*                  WRITE (*,*) 'PRIVF   = ', PRIVF */
/*                  WRITE (*,*) 'VDF     = ', VDF */
/*                  WRITE (*,*) 'VFRAME  = ', VFRAME */
/*                  WRITE (*,*) 'DRVERR, DRLERR  = ', DRVERR, DRLERR */
/*                  WRITE (*,*) 'DMAG    = ', DMAG */
/*                  WRITE (*,*) 'DM16  /DMAG    = ', DM16  /DMAG */

/*                 DO I = 1, DX-1 */
/*                    WRITE (*,*) DEFTXT(I) */
/*                 END DO */

/*                 WRITE (*,*) '=================================== ' */

/*               END IF */


/* --- Case: ------------------------------------------------------ */

	    repmi_("PXFORM test number #.  Primary vector def = #.", "#", &
		    case__, casmsg, (ftnlen)46, (ftnlen)1, (ftnlen)80);
	    repmc_(casmsg, "#", privdf, casmsg, (ftnlen)80, (ftnlen)1, (
		    ftnlen)80, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)80);

/*           Find the primary axis name and sign. */

	    s_copy(axname, axdef + ((i__2 = (axpair << 1) - 2) < 12 && 0 <= 
		    i__2 ? i__2 : s_rnge("axdef", i__2, "f_dyn01__", (ftnlen)
		    2050)) * 80, (ftnlen)80, (ftnlen)80);
	    if (i_indx(axname, "-", (ftnlen)80, (ftnlen)1) > 0) {
		axsign = -1.;
	    } else {
		axsign = 1.;
	    }
	    cmprss_("-", &c__0, axname, axname, (ftnlen)1, (ftnlen)80, (
		    ftnlen)80);
	    if (eqstr_(axname, "X", (ftnlen)80, (ftnlen)1)) {
		axindx = 1;
	    } else if (eqstr_(axname, "Y", (ftnlen)80, (ftnlen)1)) {
		axindx = 2;
	    } else {
		axindx = 3;
	    }

/*           Create the primary vector, specified relative to the */
/*           base frame.  Map this vector to the current dynamic */
/*           frame.  The vector should match the current axis */
/*           specfication for the primary defining vector. */

	    if (s_cmp(privdf, "OBSERVER_TARGET_POSITION", (ftnlen)80, (ftnlen)
		    24) == 0) {
		spkpos_(pritrg, &et, "J2000", pricor, priobs, v, &lt, (ftnlen)
			32, (ftnlen)5, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		pxform_("J2000", frname, &et, r2, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, v, vtemp);
		vscl_(&axsign, vtemp, v);
		vhat_(v, privec);

/*              PRIVEC should match the axis indicated by AXINDX. */

		chckad_("PRIVEC", privec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2090)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(privdf, "TARGET_NEAR_POINT", (ftnlen)80, (ftnlen)
		    17) == 0) {

/*              Find the specified near point. */

		subpt_("NEAR POINT", pritrg, &et, pricor, priobs, spoint, &
			alt, (ftnlen)10, (ftnlen)32, (ftnlen)15, (ftnlen)32);

/*              We actually need to use the position transformation */
/*              from PRIVF to FRMNAM for this one.  NOTE:  the */
/*              epoch of this transformation is critical.  We must */
/*              use the same epoch as was used by SUBPT. */

/*              Get the light time LT from the observer to target */
/*              center. */

		spkpos_(pritrg, &et, "J2000", pricor, priobs, pos, &lt, (
			ftnlen)32, (ftnlen)5, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the epoch associated with the target by */
/*              adjusting ET by LT. */

		zzcorepc_(pricor, &et, &lt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the position transformation from the target */
/*              body-fixed frame at ETCORR to J2000.  Convert */
/*              the body-fixed sub-point position to the J2000 */
/*              frame. */

		cnmfrm_(pritrg, &j, trgfrm, &found, (ftnlen)32, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("TARGET FRAME FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		pxform_(trgfrm, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, spoint, v);

/*              Compute the observer-to-near point vector in the J2000 */
/*              frame. */

		vadd_(v, pos, vtemp);

/*              Find the position transformation J2000 the current frame */
/*              at ET.  Rotate the observer-near point vector into this */
/*              frame. */

		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r3, vtemp, v);

/*              Negate the vector if indicated, then unitize. */

		vscl_(&axsign, v, vtemp);
		vhat_(vtemp, privec);

/*              PRIVEC should match the axis indicated by AXINDX. */

		chckad_("PRIVEC", privec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2161)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(privdf, "OBSERVER_TARGET_VELOCITY", (ftnlen)80, (
		    ftnlen)24) == 0) {

/*              Look up the velocity vector in the specified frame. */
/*              Note this choice is critical:  any other frame, */
/*              unless related by a constant offset to the correct */
/*              frame, yields an invalid result. */

		spkezr_(pritrg, &et, privf, pricor, priobs, state, &lt, (
			ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              We actually need to use the position transformation */
/*              from PRIVF to FRMNAM for this one.  NOTE:  the */
/*              epoch of this transformation is critical.  We must */
/*              use the same epoch as was used by SPKEZR.  If */
/*              PRIVF is non-inertial, we need to adjust ET by */
/*              the light time from the observer to the center of PRIVF. */
/*              We can actually finesse the issue of whether the frame */
/*              is non-inertial, since performing the correction for */
/*              an inertial frame has no effect. */

		namfrm_(privf, &j, (ftnlen)32);
		frinfo_(&j, &cent, &class__, &clssid, &found);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("FRAME CENTER FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		bodc2n_(&cent, center, &found, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("CENTER NAME FOUND", &found, &c_true, ok, (ftnlen)17);

/*              Get the light time CLT from the observer to the center */
/*              of the frame in which we looked up the velocity. */

		spkezr_(center, &et, privf, pricor, priobs, cstate, &clt, (
			ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the epoch associated with the center of the */
/*              frame by adjusting ET by CLT. */

		zzcorepc_(pricor, &et, &clt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the position transformation from PRIVF at */
/*              ETCORR to the current frame at ET.  We must do */
/*              this in two steps, passing through J2000. */

		pxform_(privf, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxm_(r3, r2, r4);

/*              Extract the velocity vector.  Rotate to the current */
/*              frame, negate if indicated, then unitize. */

		mxv_(r4, &state[3], v);
		vscl_(&axsign, v, vtemp);
		vhat_(vtemp, privec);

/*              PRIVEC should match the axis indicated by AXINDX. */

		chckad_("PRIVEC", privec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2235)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(privdf, "CONSTANT", (ftnlen)80, (ftnlen)8) == 0) 
		    {

/*              The primary vector is a constant; the vector is */
/*              stored in PRIVEC. */

/*              We need to use the position transformation from PRIVF */
/*              to FRMNAM for this one.  NOTE:  the epoch of this */
/*              transformation is critical. If PRIVF is non-inertial, we */
/*              need to adjust ET by the light time from the observer to */
/*              the center of PRIVF. We can actually finesse the issue */
/*              of whether the frame is non-inertial, since performing */
/*              the correction for an inertial frame has no effect. */

		namfrm_(privf, &j, (ftnlen)32);
		frinfo_(&j, &cent, &class__, &clssid, &found);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("FRAME CENTER FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		bodc2n_(&cent, center, &found, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("CENTER NAME FOUND", &found, &c_true, ok, (ftnlen)17);

/*              Parse the aberration correction for the primary */
/*              vector.  Get the light time to the frame center if */
/*              light time corrections are used. */

		zzprscor_(pricor, priblk, (ftnlen)15);
		if (priblk[1]) {

/*                 Get the light time CLT from the observer to the */
/*                 center of the frame in which the constant vector is */
/*                 defined. */

		    spkezr_(center, &et, privf, pricor, priobs, cstate, &clt, 
			    (ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		} else {

/*                 The frame is not corrected for light time: */
/*                 the light time to the frame center is treated as */
/*                 zero. */

		    clt = 0.;
		}

/*              Find the epoch associated with the center of the */
/*              frame by adjusting ET by CLT. */

		zzcorepc_(pricor, &et, &clt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              We now want to express the constant vector in */
/*              the current dynamic frame at ET.  We must */
/*              transform the constant vector in two steps, */
/*              since the epoch associated with the frame in */
/*              which the constant vector is specified is ETCORR. */
/*              We first map the constant vector to the J2000 */
/*              frame, then to the current frame. */

/*              When the constant vector is expressed relative */
/*              to the J2000 frame, we apply the stellar aberration */
/*              correction if necessary. */

/*              Find the position transformation from PRIVF at */
/*              ETCORR to J2000.  Apply to PRIVEC. */

		pxform_(privf, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, privec, v);
		if (priblk[2]) {

/*                 Stellar aberration correction is required. */

/*                 Find the state of the observer relative to the */
/*                 solar system barycenter at ET, in the J2000 frame. */

		    bodn2c_(priobs, &j, &found, (ftnlen)32);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    spkssb_(&j, &et, "J2000", stobs, (ftnlen)5);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    if (priblk[4]) {

/*                    Apply transmission stellar aberration correction. */

			stlabx_(v, &stobs[3], vtemp);
		    } else {

/*                    Apply transmission stellar aberration correction. */

			stelab_(v, &stobs[3], vtemp);
		    }
		    vequ_(vtemp, v);
		}

/*              The vector V contains our corrected (if necessary) */
/*              constant vector relative to J2000. */

/*              Look up the rotation from J2000 to the current frame */
/*              at ET.  Apply to our constant vector. */

		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r3, v, privec);

/*              Negate the constant vector if indicated, then unitize. */

		vscl_(&axsign, privec, vtemp);
		vhat_(vtemp, privec);

/*              PRIVEC should match the axis indicated by AXINDX. */

		chckad_("PRIVEC", privec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2367)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else {

/*              We have an unrecognized vector definition. */

		setmsg_("F_DYN01 encountered vector definition #.", (ftnlen)
			40);
		errch_("#", privdf, (ftnlen)1, (ftnlen)80);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }


/*           We're now going to test the secondary vector.  We could */
/*           have combined this code in a loop toether with the tests */
/*           for the primary vector, but "unrolling" the loop makes */
/*           the test code a bit easier to look at. */


/* --- Case: ------------------------------------------------------ */

	    repmi_("PXFORM test number #.  Secondary vector def = #.", "#", &
		    case__, casmsg, (ftnlen)48, (ftnlen)1, (ftnlen)80);
	    repmc_(casmsg, "#", secvdf, casmsg, (ftnlen)80, (ftnlen)1, (
		    ftnlen)80, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)80);

/*           Find the secondary axis name and sign. */

	    s_copy(axname, axdef + ((i__2 = (axpair << 1) - 1) < 12 && 0 <= 
		    i__2 ? i__2 : s_rnge("axdef", i__2, "f_dyn01__", (ftnlen)
		    2408)) * 80, (ftnlen)80, (ftnlen)80);
	    if (i_indx(axname, "-", (ftnlen)80, (ftnlen)1) > 0) {
		axsign = -1.;
	    } else {
		axsign = 1.;
	    }
	    cmprss_("-", &c__0, axname, axname, (ftnlen)1, (ftnlen)80, (
		    ftnlen)80);
	    if (eqstr_(axname, "X", (ftnlen)80, (ftnlen)1)) {
		axindx = 1;
	    } else if (eqstr_(axname, "Y", (ftnlen)80, (ftnlen)1)) {
		axindx = 2;
	    } else {
		axindx = 3;
	    }

/*           Create the secondary vector, specified relative to the base */
/*           frame.  Map this vector to the current dynamic frame.  The */
/*           component of this vector orthogonal to the primary vector */
/*           should match the current axis specfication for the */
/*           secondary defining vector. */

	    if (s_cmp(secvdf, "OBSERVER_TARGET_POSITION", (ftnlen)80, (ftnlen)
		    24) == 0) {
		spkpos_(sectrg, &et, "J2000", seccor, secobs, v, &lt, (ftnlen)
			32, (ftnlen)5, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		pxform_("J2000", frname, &et, r2, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, v, vtemp);
		vscl_(&axsign, vtemp, v);

/*              PRIVEC is left over from the tests on the primary */
/*              axis.  Replace SECVEC with its component orthogonal */
/*              to PRIVEC.  Unitize this component. */

		vperp_(v, privec, vtemp);
		vhat_(vtemp, secvec);

/*              SECVEC should match the axis indicated by AXINDX. */

		chckad_("SECVEC", secvec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2456)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(secvdf, "TARGET_NEAR_POINT", (ftnlen)80, (ftnlen)
		    17) == 0) {

/*              Find the specified near point. */

		subpt_("NEAR POINT", sectrg, &et, seccor, secobs, spoint, &
			alt, (ftnlen)10, (ftnlen)32, (ftnlen)15, (ftnlen)32);

/*              We actually need to use the position transformation */
/*              from SECVF to FRMNAM for this one.  NOTE:  the */
/*              epoch of this transformation is critical.  We must */
/*              use the same epoch as was used by SUBPT. */

/*              Get the light time LT from the observer to target */
/*              center. */

		spkpos_(sectrg, &et, "J2000", seccor, secobs, pos, &lt, (
			ftnlen)32, (ftnlen)5, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the epoch associated with the target by */
/*              adjusting ET by LT. */

		zzcorepc_(seccor, &et, &lt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the position transformation from the target */
/*              body-fixed frame at ETCORR to J2000.  Convert */
/*              the body-fixed sub-point position to the J2000 */
/*              frame. */

		cnmfrm_(sectrg, &j, trgfrm, &found, (ftnlen)32, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("TARGET FRAME FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		pxform_(trgfrm, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, spoint, v);

/*              Compute the observer-to-near point vector in the J2000 */
/*              frame. */

		vadd_(v, pos, vtemp);

/*              Find the position transformation J2000 the current frame */
/*              at ET.  Rotate the observer-near point vector into this */
/*              frame. */

		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r3, vtemp, v);

/*              Negate the vector if indicated, then unitize. */

		vscl_(&axsign, v, vtemp);

/*              PRIVEC is left over from the tests on the primary */
/*              axis.  Replace SECVEC with its component orthogonal */
/*              to PRIVEC.  Unitize this component. */

		vperp_(vtemp, privec, v);
		vhat_(v, secvec);

/*              SECVEC should match the axis indicated by AXINDX. */

		chckad_("SECVEC", secvec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2534)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (ftnlen)80, (
		    ftnlen)24) == 0) {

/*              Look up the velocity vector in the specified frame. */
/*              Note this choice is critical:  any other frame, */
/*              unless related by a constant offset to the correct */
/*              frame, yields an invalid result. */

		spkezr_(sectrg, &et, secvf, seccor, secobs, state, &lt, (
			ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
/*               WRITE (*,*) 'F_DYN01:' */
/*               WRITE (*,*) 'STATE = ', STATE */
/*               WRITE (*,*) 'SECVF = ', SECVF */
/*               WRITE (*,*) 'ET    = ', ET */
/*               CALL VHAT (STATE(4), UVEL ) */
/*               WRITE (*, * ) 'UVEL = ' */
/*               WRITE (*,'(1X,3E25.17)' ) UVEL */

/*              We actually need to use the position transformation */
/*              from SECVF to FRMNAM for this one.  NOTE:  the */
/*              epoch of this transformation is critical.  We must */
/*              use the same epoch as was used by SPKEZR.  If */
/*              SECVF is non-inertial, we need to adjust ET by */
/*              the light time from the observer to the center of SECVF. */
/*              We can actually finesse the issue of whether the frame */
/*              is non-inertial, since performing the correction for */
/*              an inertial frame has no effect. */

		namfrm_(secvf, &j, (ftnlen)32);
		frinfo_(&j, &cent, &class__, &clssid, &found);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("FRAME CENTER FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		bodc2n_(&cent, center, &found, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("CENTER NAME FOUND", &found, &c_true, ok, (ftnlen)17);

/*              Get the light time CLT from the observer to the center */
/*              of the frame in which we looked up the velocity. */

		spkezr_(center, &et, secvf, seccor, secobs, cstate, &clt, (
			ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the epoch associated with the center of the */
/*              frame by adjusting ET by CLT. */

		zzcorepc_(seccor, &et, &clt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Find the position transformation from SECVF at */
/*              ETCORR to the current frame at ET.  We must do */
/*              this in two steps, passing through J2000. */

		pxform_(secvf, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxm_(r3, r2, r4);

/*              Extract the velocity vector.  Rotate to the current */
/*              frame, negate if indicated, then unitize. */

		mxv_(r4, &state[3], vtemp);
		vscl_(&axsign, vtemp, v);

/*              PRIVEC is left over from the tests on the primary */
/*              axis.  Replace SECVEC with its component orthogonal */
/*              to PRIVEC.  Unitize this component. */

		vperp_(v, privec, vtemp);
		vhat_(vtemp, secvec);

/*              PRIVEC is left over from the tests on the primary */
/*              axis.  Replace SECVEC with its component orthogonal */
/*              to PRIVEC. */

		vperp_(secvec, privec, vtemp);
		vequ_(vtemp, secvec);

/*              SECVEC should match the axis indicated by AXINDX. */

		chckad_("SECVEC", secvec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2635)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else if (s_cmp(secvdf, "CONSTANT", (ftnlen)80, (ftnlen)8) == 0) 
		    {

/*              The secondary vector is a constant; the vector is */
/*              stored in SECVEC. */

/*              We need to use the position transformation from SECVF */
/*              to FRMNAM for this one.  NOTE:  the epoch of this */
/*              transformation is critical. If SECVF is non-inertial, we */
/*              need to adjust ET by the light time from the observer to */
/*              the center of SECVF. We can actually finesse the issue */
/*              of whether the frame is non-inertial, since performing */
/*              the correction for an inertial frame has no effect. */

		namfrm_(secvf, &j, (ftnlen)32);
		frinfo_(&j, &cent, &class__, &clssid, &found);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("FRAME CENTER FOUND", &found, &c_true, ok, (ftnlen)18)
			;
		bodc2n_(&cent, center, &found, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksl_("CENTER NAME FOUND", &found, &c_true, ok, (ftnlen)17);

/*              Parse the aberration correction for the secondary */
/*              vector.  Get the light time to the frame center if */
/*              light time corrections are used. */

		zzprscor_(seccor, secblk, (ftnlen)15);
		if (secblk[1]) {

/*                 Get the light time CLT from the observer to the */
/*                 center of the frame in which the constant vector is */
/*                 defined. */

		    spkezr_(center, &et, secvf, seccor, secobs, cstate, &clt, 
			    (ftnlen)32, (ftnlen)32, (ftnlen)15, (ftnlen)32);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		} else {

/*                 The frame is not corrected for light time: */
/*                 the light time to the frame center is treated as */
/*                 zero. */

		    clt = 0.;
		}

/*              Find the epoch associated with the center of the */
/*              frame by adjusting ET by CLT. */

		zzcorepc_(seccor, &et, &clt, &etcorr, (ftnlen)15);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              We now want to express the constant vector in */
/*              the current dynamic frame at ET.  We must */
/*              transform the constant vector in two steps, */
/*              since the epoch associated with the frame in */
/*              which the constant vector is specified is ETCORR. */
/*              We first map the constant vector to the J2000 */
/*              frame, then to the current frame. */

/*              When the constant vector is expressed relative */
/*              to the J2000 frame, we apply the stellar aberration */
/*              correction if necessary. */

/*              Find the position transformation from SECVF at */
/*              ETCORR to J2000.  Apply to SECVEC. */

		pxform_(secvf, "J2000", &etcorr, r2, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r2, secvec, v);
		if (secblk[2]) {

/*                 Stellar aberration correction is required. */

/*                 Find the state of the observer relative to the */
/*                 solar system barycenter at ET, in the J2000 frame. */

		    bodn2c_(secobs, &j, &found, (ftnlen)32);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    spkssb_(&j, &et, "J2000", stobs, (ftnlen)5);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    if (secblk[4]) {

/*                    Apply transmission stellar aberration correction. */

			stlabx_(v, &stobs[3], vtemp);
		    } else {

/*                    Apply transmission stellar aberration correction. */

			stelab_(v, &stobs[3], vtemp);
		    }
		    vequ_(vtemp, v);
		}

/*              The vector V contains our (corrected if necessary) */
/*              constant vector relative to J2000. */

/*              Look up the rotation from J2000 to the current frame */
/*              at ET.  Apply to our constant vector. */

		pxform_("J2000", frname, &et, r3, (ftnlen)5, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxv_(r3, v, secvec);

/*              Negate the constant vector if indicated. */

		vscl_(&axsign, secvec, vtemp);

/*              PRIVEC is left over from the tests on the primary */
/*              axis.  Replace SECVEC with its component orthogonal */
/*              to PRIVEC.  Unitize this component. */

		vperp_(vtemp, privec, v);
		vhat_(v, secvec);

/*              SECVEC should match the axis indicated by AXINDX. */

		chckad_("SECVEC", secvec, "~", &e[(i__2 = axindx * 3 - 3) < 9 
			&& 0 <= i__2 ? i__2 : s_rnge("e", i__2, "f_dyn01__", (
			ftnlen)2775)], &c__3, &c_b668, ok, (ftnlen)6, (ftnlen)
			1);
	    } else {

/*              We have an unrecognized vector definition. */

		setmsg_("F_DYN01 encountered vector definition #.", (ftnlen)
			40);
		errch_("#", secvdf, (ftnlen)1, (ftnlen)80);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }

/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM test number #.  Test derivative block.", "#", &
		    case__, casmsg, (ftnlen)45, (ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)80);

/*           Perform "sanity checks" on the returned matrix. */
/*           Make sure the diagonal blocks are identical rotations, */
/*           compute a discrete derivative and compare to the */
/*           lower left block, and make sure the upper right */
/*           block is a zero matrix. */

	    delta = 1.;
	    d__1 = et - delta;
	    pxform_(frname, bframe, &d__1, rminus, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = et + delta;
	    pxform_(frname, bframe, &d__1, rplus, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    t_xform__(xform, rminus, rplus, &delta, &nrmerr, &deterr, &drverr,
		     &drlerr, drdiff);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check the error measurements we've made.  First */
/*           up is the determinant error. */

	    tol = 1e-14;
	    chcksd_("DETERR", &deterr, "~", &c_b17, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           Check norms of rows and columns in the rotation */
/*           blocks. */

	    chcksd_("NRMERR", &nrmerr, "~", &c_b17, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           Check the derivative error when measured against */
/*           the discrete derivative. */

	    maxder = max(maxder,drverr);
	    if (i_indx(pricor, "S", (ftnlen)15, (ftnlen)1) > 0 || i_indx(
		    seccor, "S", (ftnlen)15, (ftnlen)1) > 0) {
		tol = 1e-4;
/*               TOL = DM5 */
	    } else {
/*               TOL = DM5 */
		tol = 5e-7;
	    }
	    chcksd_("DRVERR", &drverr, "~", &c_b17, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*                 These statements may be useful for debugging. */

/*               IF ( .NOT. OK ) THEN */

/*                  WRITE (*,*) '=================================== ' */
/*                  WRITE (*,*) 'CASE = ', CASE */
/*                  WRITE (*,*) COORDS */
/*                  WRITE (*,*) 'PRIFRM  = ', PRIFRM */
/*                  WRITE (*,*) 'PRIJ    = ', PRIJ */
/*                  WRITE (*,*) 'PRIVF   = ', PRIVF */
/*                  WRITE (*,*) 'VDF     = ', VDF */
/*                  WRITE (*,*) 'SECVDF  = ', SECVDF */
/*                  WRITE (*,*) 'SECOBS  = ', SECOBS */
/*                  WRITE (*,*) 'SECTRG  = ', SECTRG */
/*                  WRITE (*,*) 'SECVF   = ', SECVF */
/*                  WRITE (*,*) 'VFRAME  = ', VFRAME */
/*                  WRITE (*,*) 'DRVERR  = ', DRVERR */
/*                  WRITE (*,*) 'PRIVEC  = ', PRIVEC */
/*                  WRITE (*,*) 'SECVEC  = ', SECVEC */
/*                  WRITE (*,*) 'DMAG    = ', DMAG */
/*                  WRITE (*,*) 'DM16  /DMAG    = ', DM16  /DMAG */

/*                  CALL M33 ( 'DRDIFF', DRDIFF ) */

/*                 DO I = 1, DX-1 */
/*                    WRITE (*,*) DEFTXT(I) */
/*                 END DO */

/*                 WRITE (*,*) '=================================== ' */

/*              END IF */

/*           Check the derivative relative error.  Perform this */
/*           test only if both aberration corrections are 'NONE' */
/*           and if the derivative error is not to close to */
/*           machine epsilon. */



/*           Decide whether we'll do a derivative test. */

	    tstdrv = TRUE_;
	    tol = 0.;
	    if (s_cmp(pricor, "NONE", (ftnlen)15, (ftnlen)4) == 0 && s_cmp(
		    seccor, "NONE", (ftnlen)15, (ftnlen)4) == 0) {

/*              No aberration corrections are used. */

/*              There are a few special cases where we must expect */
/*              quite inaccurate answers.  Set the tolerances for */
/*              these first. */

/*              The Phobos-earth and earth-sun velocity vectors in the */
/*              IAU_PHOBOS and PHOBOS_RADIAL frames are particularly */
/*              problematic. */

		if (drverr < 1e-15) {

/*                 The relative error is not meaningful; skip */
/*                 the test. */

		    ++nskip;
		    tstdrv = FALSE_;
		} else if (s_cmp(privf, "PHOBOS_RADIAL", (ftnlen)32, (ftnlen)
			13) == 0) {
/*                  TOL =  DM5 */
		    tol = 1e-4;
		} else if (s_cmp(priobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 
			0 && s_cmp(pritrg, "MARS", (ftnlen)32, (ftnlen)4) == 
			0 && s_cmp(privf, "IAU_PHOBOS", (ftnlen)32, (ftnlen)
			10) == 0 && s_cmp(privdf, "OBSERVER_TARGET_VELOCITY", 
			(ftnlen)80, (ftnlen)24) == 0) {
/*                  TOL =  DM4 */
		    tol = 1e-6;
		    ++npr;
/*                  WRITE (*,*) 'IAU_PHOBOS, NPR = ', NPR */
		}
		if (s_cmp(secobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 0 && 
			s_cmp(sectrg, "EARTH", (ftnlen)32, (ftnlen)5) == 0 && 
			s_cmp(secvf, "IAU_PHOBOS", (ftnlen)32, (ftnlen)10) == 
			0 && s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (
			ftnlen)80, (ftnlen)24) == 0) {
		    tol = max(tol,1e-4);
		} else if (s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)5) == 0 
			&& s_cmp(sectrg, "SUN", (ftnlen)32, (ftnlen)3) == 0 &&
			 s_cmp(secvf, "PHOBOS_RADIAL", (ftnlen)32, (ftnlen)13)
			 == 0 && s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (
			ftnlen)80, (ftnlen)24) == 0) {
		    tol = max(tol,.001);
		} else if (s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)5) == 0 
			&& s_cmp(sectrg, "SUN", (ftnlen)32, (ftnlen)3) == 0 &&
			 s_cmp(secvf, "IAU-EARTH", (ftnlen)32, (ftnlen)9) == 
			0 && s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (
			ftnlen)80, (ftnlen)24) == 0) {
		    tol = max(tol,.001);
		} else if (s_cmp(secobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 
			0 && s_cmp(sectrg, "EARTH", (ftnlen)32, (ftnlen)5) == 
			0 && s_cmp(secvf, "PHOBOS_RADIAL", (ftnlen)32, (
			ftnlen)13) == 0 && s_cmp(secvdf, "OBSERVER_TARGET_VE"
			"LOCITY", (ftnlen)80, (ftnlen)24) == 0) {
		    tol = max(tol,.01);
		}
		if (tol == 0.) {
		    if (dmag > 1e-15) {

/*                    This is the normal case. */

/*                    NNORML = NNORML + 1 */
/*                     TOL = MAX ( 10.D0**( -16 - LOG10(DMAG) ),  DM6 ) */
/* Computing MAX */
			d__2 = -16 - d_lg10(&dmag);
			d__1 = pow_dd(&c_b933, &d__2);
			tol = max(d__1,1e-5);
		    } else if (dmag == 0.) {

/*                    This should happen only for constant frames, */
/*                    in which case estimated and actual derivatives */
/*                     should---we think---be identically zero. */

			tol = 0.;
		    } else {

/*                    No point in testing the relative error---the */
/*                    derivative is too small for the discrete estimate */
/*                    to have any validity. */

			++nskip;
			tstdrv = FALSE_;
		    }
		}

/*              The tolerance has been set for the pure geometric */
/*              cases. */

	    } else if (i_indx(pricor, "LT", (ftnlen)15, (ftnlen)2) > 0 || 
		    i_indx(seccor, "LT", (ftnlen)15, (ftnlen)2) > 0 || i_indx(
		    pricor, "CN", (ftnlen)15, (ftnlen)2) > 0 || i_indx(seccor,
		     "CN", (ftnlen)15, (ftnlen)2) > 0 || i_indx(pricor, "S", (
		    ftnlen)15, (ftnlen)1) > 0 || i_indx(seccor, "S", (ftnlen)
		    15, (ftnlen)1) > 0) {

/*              We're using light time corrections possibly */
/*              stellar aberration corrections). */

/*              There are several special cases where we must expect */
/*              quite inaccurate answers.  Set the tolerances for */
/*              these first. */

/*              The phobos-earth velocity vector in the IAU_PHOBOS */
/*              frame is particularly problematic. */

		bigerr = FALSE_;
		if (s_cmp(secobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 0 && 
			s_cmp(sectrg, "EARTH", (ftnlen)32, (ftnlen)5) == 0 && 
			s_cmp(secvf, "IAU_PHOBOS", (ftnlen)32, (ftnlen)10) == 
			0 && s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (
			ftnlen)80, (ftnlen)24) == 0) {
		    bigerr = TRUE_;
		    tol = 1e-4;
		} else if (s_cmp(privdf, "CONSTANT", (ftnlen)80, (ftnlen)8) ==
			 0 && s_cmp(privf, "GSE", (ftnlen)32, (ftnlen)3) == 0 
			&& s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)5) == 0 
			&& s_cmp(sectrg, "SUN", (ftnlen)32, (ftnlen)3) == 0) {

/*                 The velocity is just noise for many of these */
/*                 cases, so the relative error is meaningless. */

		    bigerr = TRUE_;
		    tol = 0.;
		    tstdrv = FALSE_;
		} else if (s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)5) == 0 
			&& s_cmp(sectrg, "SUN", (ftnlen)32, (ftnlen)3) == 0 &&
			 s_cmp(secvf, "PHOBOS_RADIAL", (ftnlen)32, (ftnlen)13)
			 == 0 && s_cmp(secvdf, "OBSERVER_TARGET_VELOCITY", (
			ftnlen)80, (ftnlen)24) == 0) {
		    bigerr = TRUE_;
		    tol = .01;
		} else if (s_cmp(secobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 
			0 && s_cmp(sectrg, "EARTH", (ftnlen)32, (ftnlen)5) == 
			0 && s_cmp(secvf, "PHOBOS_RADIAL", (ftnlen)32, (
			ftnlen)13) == 0 && s_cmp(secvdf, "OBSERVER_TARGET_VE"
			"LOCITY", (ftnlen)80, (ftnlen)24) == 0) {
		    bigerr = TRUE_;
		    tol = .01;
		} else if (s_cmp(privdf, "CONSTANT", (ftnlen)80, (ftnlen)8) ==
			 0 && s_cmp(secvdf, "CONSTANT", (ftnlen)80, (ftnlen)8)
			 == 0) {

/*                 The velocity is just noise for many of these */
/*                 cases, so the relative error is meaningless. */

		    bigerr = TRUE_;
		    tol = 0.;
		    tstdrv = FALSE_;
		}

/*              Further tolerance adjustments may be needed if we're */
/*              using stellar aberration. */

		if (tstdrv) {
		    if (i_indx(pricor, "S", (ftnlen)15, (ftnlen)1) > 0) {
			if (s_cmp(priobs, "PHOBOS", (ftnlen)32, (ftnlen)6) == 
				0 && s_cmp(privf, "GSE", (ftnlen)32, (ftnlen)
				3) == 0) {
			    bigerr = TRUE_;
			    tol = .1;
			} else if (s_cmp(priobs, "PHOBOS", (ftnlen)32, (
				ftnlen)6) == 0 && s_cmp(privf, "PHOBOS_RADIAL"
				, (ftnlen)32, (ftnlen)13) == 0) {
			    bigerr = TRUE_;
			    tol = .001;
			} else if (s_cmp(priobs, "PHOBOS", (ftnlen)32, (
				ftnlen)6) == 0 && s_cmp(privdf, "OBSERVER_TA"
				"RGET_POSITION", (ftnlen)80, (ftnlen)24) == 0) 
				{
			    bigerr = TRUE_;
			    tol = .001;
			}
			if (s_cmp(priobs, "EARTH", (ftnlen)32, (ftnlen)5) == 
				0 && s_cmp(pritrg, "SUN", (ftnlen)32, (ftnlen)
				3) == 0 && s_cmp(privdf, "OBSERVER_TARGET_VE"
				"LOCITY", (ftnlen)80, (ftnlen)24) == 0) {
			    bigerr = TRUE_;
			    if (s_cmp(privf, "PHOBOS_RADIAL", (ftnlen)32, (
				    ftnlen)13) == 0) {

/*                          The derivative in this case suffers */
/*                          from total loss of precision. */

				tstdrv = FALSE_;
				tol = 0.;
			    } else {

/*                          We have about one digit of information here. */

				tol = .1;
			    }
			}
		    }
		    if (i_indx(seccor, "S", (ftnlen)15, (ftnlen)1) > 0) {
			if (s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)5) == 
				0 && s_cmp(sectrg, "SUN", (ftnlen)32, (ftnlen)
				3) == 0 && s_cmp(secvdf, "OBSERVER_TARGET_VE"
				"LOCITY", (ftnlen)80, (ftnlen)24) == 0) {
			    bigerr = TRUE_;
			    if (s_cmp(secvf, "PHOBOS_RADIAL", (ftnlen)32, (
				    ftnlen)13) == 0) {

/*                          The derivative in this case suffers */
/*                          from total loss of precision. */

				tstdrv = FALSE_;
				tol = 0.;
			    } else {

/*                          We have about one digit of information here. */

				tol = .1;
			    }
			} else if (s_cmp(secobs, "PHOBOS", (ftnlen)32, (
				ftnlen)6) == 0 && s_cmp(sectrg, "EARTH", (
				ftnlen)32, (ftnlen)5) == 0) {
			    bigerr = TRUE_;
			    tol = .1;
			} else if (s_cmp(secobs, "EARTH", (ftnlen)32, (ftnlen)
				5) == 0 && s_cmp(secvf, "PHOBOS_RADIAL", (
				ftnlen)32, (ftnlen)13) == 0) {
			    bigerr = TRUE_;
			    tol = max(tol,.001);
			}
		    }
		}

/*              Set the tolerance for the "normal" cases. */

		if (tstdrv && ! bigerr) {
		    if (dmag > 1e-10) {

/*                    The derivative magnitude is large enough to */
/*                    squeeze out about four digits of precision. */

			tol = 1e-4;
		    } else if (dmag > 1e-12) {

/*                    We may expect about two digits of agreement */
/*                    between the computed as estimated derivative. */

			tol = .01;
		    } else if (dmag == 0.) {

/*                    This should happen only for constant frames, */
/*                    in which case estimated and actual derivatives */
/*                    should---we think---be identically zero. */

			tol = 0.;
		    } else {

/*                    No point in testing the relative error---the */
/*                    derivative is too small for the discrete estimate */
/*                    to have any validity. */

			++nskip;
			tstdrv = FALSE_;
		    }
		}

/*              TOL has been set for the aberration correction cases. */

	    }

/*           TOL has been set. */

	    if (tstdrv) {
/* Computing MAX */
		d__1 = tol, d__2 = 1e-7 / dmag;
		tol = max(d__1,d__2);
/*               WRITE (*,*) 'USING TOL = ', TOL */
		chcksd_("DRLERR", &drlerr, "~", &c_b17, &tol, ok, (ftnlen)6, (
			ftnlen)1);

/*                   These statements may be useful for debugging. */

/*               IF ( .NOT. OK ) THEN */

/*                  WRITE (*,*) '=================================== ' */
/*                  WRITE (*,*) 'CASE = ', CASE */
/*                  WRITE (*,*) COORDS */
/*                  WRITE (*,*) 'PRIFRM  = ', PRIFRM */
/*                  WRITE (*,*) 'PRIJ    = ', PRIJ */
/*                  WRITE (*,*) 'PRIVDF  = ', PRIVDF */
/*                  WRITE (*,*) 'PRIOBS  = ', PRIOBS */
/*                  WRITE (*,*) 'PRITRG  = ', PRITRG */
/*                  WRITE (*,*) 'PRIVF   = ', PRIVF */
/*                  WRITE (*,*) 'VDF     = ', VDF */
/*                  WRITE (*,*) 'SECVDF  = ', SECVDF */
/*                  WRITE (*,*) 'SECOBS  = ', SECOBS */
/*                  WRITE (*,*) 'SECTRG  = ', SECTRG */
/*                  WRITE (*,*) 'SECVF   = ', SECVF */
/*                  WRITE (*,*) 'VFRAME  = ', VFRAME */
/*               IF ( ISVEL(1) .AND. ISVEL(2) ) THEN */
/*                  WRITE (*,*) 'DRVERR, DRLERR  = ', DRVERR, DRLERR */
/*               END IF */
/*                  WRITE (*,*) 'PRIVEC  = ', PRIVEC */
/*                  WRITE (*,*) 'SECVEC  = ', SECVEC */
/*                   WRITE (*,*) 'DMAG    = ', DMAG */
/*                   WRITE (*,*) '1.D-7/DMAG    = ', 1.D-7/DMAG */
/*                   WRITE (*,*) '1.D-8/DMAG    = ', 1.D-8/DMAG */
/*                  WRITE (*,*) 'DM16  /DMAG    = ', DM16  /DMAG */

/*                  CALL M33 ( 'DRDIFF', DRDIFF ) */
/*                  CALL M66 ( 'XFORM',  XFORM  ) */
/*                  CALL XF2RAV ( XFORM, R, V ) */
/*                  WRITE (*,*) 'Frame angular velocity: ', V */
/*                  WRITE (*,*) '||V|| = ', VNORM(V) */

/*                WRITE (*,*) 'F_DYN01:' */
/*                WRITE (*,*) 'STATE = ', STATE */
/*               WRITE (*,*) 'SECVF = ', SECVF */
/*               WRITE (*,*) 'ET    = ', ET */
/*               CALL VHAT (STATE(4), UVEL ) */
/*               WRITE (*, * ) 'UVEL = ' */
/*               WRITE (*,'(1X,3E25.17)' ) UVEL */
/*                 DO I = 1, DX-1 */
/*                    WRITE (*,*) DEFTXT(I) */
/*                 END DO */

/*                 WRITE (*,*) '=================================== ' */

/*              END IF */

	    }
	}
    }
/*      WRITE (*,*) 'Number of cases rejected: ', NOGO */
/*      WRITE (*,*) 'MAXDER = ', MAXDER */
/*      WRITE (*,*) 'NSKIP  = ', NSKIP */
/*      WRITE (*,*) 'NNORML = ', NNORML */

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dyn01__ */

