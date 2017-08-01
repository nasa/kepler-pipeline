/* f_dyn04.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__20 = 20;
static integer c__7 = 7;
static integer c__2 = 2;
static integer c__5 = 5;
static integer c__4 = 4;
static integer c__9 = 9;
static doublereal c_b192 = 1e-12;
static doublereal c_b207 = 0.;
static integer c__6 = 6;
static doublereal c_b232 = 1e-19;

/* $Procedure F_DYN04 ( Dynamic Frame Test Family 04 ) */
/* Subroutine */ int f_dyn04__(logical *ok)
{
    /* Initialized data */

    static integer axeseq[6]	/* was [3][2] */ = { 3,1,3,2,3,1 };
    static char basefr[32*3] = "J2000                           " "IAU_MARS "
	    "                       " "GSE                             ";
    static char cofstr[80*3*3] = "( 1           2E-8        3E-13 )         "
	    "                                      " "( 10          2E-7     "
	    "   3E-12 )                                               " "( 10"
	    "0         2E-6        3E-11 )                                   "
	    "            " "( 2                             )                "
	    "                               " "( 4           5E-7            "
	    "  )                                               " "( 6        "
	    "   7E-7        8E-12 )                                          "
	    "     " "(  -47.68143  0.33621061170684714E-10 )                 "
	    "                        " "(  -37.1135  -0.19298045478743630E-10"
	    " )                                         " "( -176.630   -0.40"
	    "612497946759260E-02 )                                         ";
    static integer ctrcde[2] = { 399,499 };
    static char epcstr[80*2] = "@2000-JAN-1/12:00                           "
	    "                                    " "@2001-JAN-1/12:00        "
	    "                                                       ";
    static char units[80*2] = "'DEGREES'                                    "
	    "                                   " "'RADIANS'                 "
	    "                                                      ";
    static char rstate[80*3] = "ROTATING                                    "
	    "                                    " "INERTIAL                 "
	    "                                                       " "FROZEN"
	    "                                                                "
	    "          ";
    static integer dims__[7] = { 3,2,2,2,3,2,3 };
    static doublereal zr[9]	/* was [3][3] */ = { 0.,0.,0.,0.,0.,0.,0.,0.,
	    0. };

    /* System generated locals */
    address a__1[2], a__2[5], a__3[4];
    integer i__1, i__2, i__3, i__4[2], i__5[5], i__6[4], i__7;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    doublereal dmag;
    integer case__, axes[3];
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *);
    doublereal tipm[9]	/* was [3][3] */, xfb2j[36]	/* was [6][6] */, 
	    xff2j[36]	/* was [6][6] */;
    integer i__, j, n;
    doublereal p, r__[9]	/* was [3][3] */, t, delta;
    char epoch[80];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    integer ncart;
    extern doublereal jyear_(void);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), prsdp_(char *, 
	    doublereal *, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    doublereal tsipm[36]	/* was [6][6] */, r2[9]	/* was [3][3] */, 
	    rplus[9]	/* was [3][3] */, t0;
    extern /* Subroutine */ int bodc2n_(integer *, char *, logical *, ftnlen),
	     t_success__(logical *), eul2xf_(doublereal *, integer *, integer 
	    *, integer *, doublereal *), chckad_(char *, doublereal *, char *,
	     doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen)
	    , str2et_(char *, doublereal *, ftnlen);
    doublereal dp;
    logical go;
    doublereal et;
    integer handle;
    char bframe[32], angcof[80*3];
    doublereal drdiff[9]	/* was [3][3] */;
    integer dx;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal coeffs[6], refepc;
    char frname[32];
    integer frcode;
    extern integer prodai_(integer *, integer *);
    extern doublereal vnormg_(doublereal *, integer *);
    char axestr[80], casmsg[240], ctrnam[32], deftxt[80*50], frzepc[50], 
	    inunit__[80], keywrd[80], rststr[32], timstr[80], tokens[80*7], 
	    untstr[80], frstem[18];
    doublereal deterr, drlerr, drvblk[9]	/* was [3][3] */, drverr, 
	    eulang[6], nrmerr, rminus[9]	/* was [3][3] */, xf2[36]	
	    /* was [6][6] */;
    integer coords[7], center;
    logical ismars;
    extern /* Subroutine */ int tstlsk_(void), chckxc_(logical *, char *, 
	    logical *, ftnlen);
    doublereal tol;
    extern /* Subroutine */ int tstspk_(char *, logical *, integer *, ftnlen),
	     t_pck08__(char *, logical *, logical *, ftnlen), cmprss_(char *, 
	    integer *, char *, char *, ftnlen, ftnlen, ftnlen), replch_(char *
	    , char *, char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    suffix_(char *, integer *, char *, ftnlen, ftnlen), lmpool_(char *
	    , integer *, ftnlen), multix_(integer *, integer *, integer *, 
	    integer *, integer *), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen), sxform_(char *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen), pxform_(char *, char *, doublereal 
	    *, doublereal *, ftnlen, ftnlen), lparsm_(char *, char *, integer 
	    *, integer *, char *, ftnlen, ftnlen, ftnlen), convrt_(doublereal 
	    *, char *, char *, doublereal *, ftnlen, ftnlen), dvpool_(char *, 
	    ftnlen), spkuef_(integer *), delfil_(char *, ftnlen), t_xform__(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal drv2[9]	/* was [3][3] */;

/* $ Abstract */

/*     Test family to exercise the logic and code in the fourth */
/*     subset of dynamic frame routines.  Only Euler frames */
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

/*     This test family uses the following kernels: */

/*        LSK generated by tstlsk */
/*        PCK generated by t_pck08 */
/*        SPK generated by tstspk */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     As the set of Euler frame features grows, this routine should */
/*     be updated to exercise each supported feature. */

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


/*     Tests are done using a variety of frame definitions.  Each */
/*     combination of base frame and rotation state is used, where */
/*     the types of base frames include: */

/*        - inertial */
/*        - rotating non-dynamic */
/*        - dynamic */


/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.2.0, 05-AUG-2005 (NJB) */

/*        Frame centers are now specified by name in the main loop. */
/*        This is a quick way of exercising new logic in FRAMEX. */

/*        Parameters KWX, KWY, KWZ were renamed to KVX, KVY, KVZ. */

/* -    TSPICE Version 1.0.0, 10-JAN-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Tolerance levels for various tests. */


/*     Parameters controlling frame definitions: */


/*     The dimensions of the test parameter space are: */

/*         1) Coefficient set */
/*         2) Axis sequence */
/*         3) Units */
/*         4) Epoch */
/*         5) Base frame */
/*         6) Center */
/*         7) Rotation state */

/*     Number of dimensions of the test parameter space: */


/*     Number of coefficient sets: */


/*     The constant COFIDX refers to the ordinal position of the */
/*     dimension corresponding to the coefficient set in the parameter */
/*     space. */


/*     Index of coefficient set for Mars test case: */


/*     Number of axis sequences: */


/*     Index of axis sequence for Mars test case: */


/*     Number of unit selections: */


/*     Number of epoch selections: */


/*     Number of base frame cases: */


/*     The constant BFRIDX refers to the ordinal position of the */
/*     dimension corresponding to base frame in the parameter */
/*     space. */


/*     Number of frame center cases: */


/*     Number of rotation states: */


/*     The constant RSTIDX refers to the ordinal position of the */
/*     dimension corresponding to the rotation state in the parameter */
/*     space. */


/*     Local Variables */


/*     We'll use the kernel variable name "stem" */

/*        FRAME_<ID code>_ */

/*     The length declared below (18) is the length of such a string */
/*     where the ID code contains 11 digits. */


/*     Saved variables */


/*     Initial values */


/*     Euler angle axis sequences: */


/*     We use both inertial, PCK-based, and dynamic base frames. */


/*     Polynomial coefficient sets: */

/*     The last set is based on the coefficient for Mars from */
/*     pck00008.tpc.  That PCK contains the assignments */

/*        BODY499_POLE_RA          = (  317.68143   -0.1061      0.  ) */
/*        BODY499_POLE_DEC         = (   52.88650   -0.0609      0.  ) */
/*        BODY499_PM               = (  176.630    350.89198226  0.  ) */

/*     The angles shown here are obtained from those angles via */
/*     the transformations */

/*        Angle 1 is -Pi/2 - RA, mapped into the range [0, 360). */
/*        Angle 2 is -Pi/2 + Dec. */
/*        Angle 3 is -PM. */

/*     Units have been changed as well: */

/*        RA/Dec terms in the PCK are in degrees and degrees/century; */
/*        the rates here have been converted to degrees/sec. Prime */
/*        meridian terms in the PCK are in degrees and degrees/day; the */
/*        rate here has been converted to degrees/sec. */



/*     ID codes of frame centers: */


/*     Reference epochs for polynomial definitions: */


/*     Angular units: */


/*     Rotation states: */


/*     DIMS defines the dimensions of the cartesian product of the */
/*     input parameters.  The cardinality of the set comprising the */
/*     Nth "factor" of the cartesian product is DIMS(N).  The cardinality */
/*     of the product itself is the product of the elements of DIMS. */


/*     Initial values */


/*     Open the test family. */

    topen_("F_DYN04", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Create test inputs for comprehensive Euler frame test.", (ftnlen)
	    54);

/*     Create and load kernels. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("test_dyn.bsp", &c_true, &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_pck08__("test_dyn.tpc", &c_true, &c_false, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Parse the constant string used for the freeze epoch. */
/*     First remove the '@' and '/' characters from the string. */
/*     Add TDB token. */

    cmprss_("@", &c__0, "@2010-JAN-1/00:00:00", frzepc, (ftnlen)1, (ftnlen)20,
	     (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    replch_(frzepc, "/", " ", frzepc, (ftnlen)50, (ftnlen)1, (ftnlen)1, (
	    ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    suffix_("TDB", &c__1, frzepc, (ftnlen)3, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    str2et_(frzepc, &t0, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the GSE frame. */

    s_copy(deftxt, "FRAME_GSE                        =  2399001", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2399001_NAME               = 'GSE'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 160, "FRAME_2399001_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399001_CLASS_ID           =  2399001", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399001_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399001_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399001_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2399001_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2399001_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2399001_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(deftxt + 800, "FRAME_2399001_PRI_OBSERVER       = 'EARTH'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 880, "FRAME_2399001_PRI_TARGET         = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 960, "FRAME_2399001_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 1040, "FRAME_2399001_SEC_AXIS       = '-Y'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1120, "FRAME_2399001_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1200, "FRAME_2399001_SEC_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1280, "FRAME_2399001_SEC_TARGET       = 'EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1360, "FRAME_2399001_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1440, "FRAME_2399001_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 1520, "FRAME_2399001_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the GSE frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We use MULTIX and the array DIMS to define a mapping that allows */
/*     us to map a test case number to a set of input parameters. */

/*     Compute the number of test cases in the input cartesian product */
/*     space. */

    ncart = prodai_(dims__, &c__7);
    i__1 = ncart;
    for (case__ = 1; case__ <= i__1; ++case__) {

/*        Find the multi-dimensional coordinates of the current */
/*        case in the cartesian product of the test input sets. */

	multix_(&c__1, &c__7, dims__, &case__, coords);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set frame definition parameters defined by COORDS. */
/*        Start out with the coefficient sets. */

	for (i__ = 1; i__ <= 3; ++i__) {
	    s_copy(angcof + ((i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : 
		    s_rnge("angcof", i__2, "f_dyn04__", (ftnlen)651)) * 80, 
		    cofstr + ((i__3 = i__ + coords[0] * 3 - 4) < 9 && 0 <= 
		    i__3 ? i__3 : s_rnge("cofstr", i__3, "f_dyn04__", (ftnlen)
		    651)) * 80, (ftnlen)80, (ftnlen)80);
	}

/*        Set the axis sequence. */

	for (i__ = 1; i__ <= 3; ++i__) {
	    axes[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("axes", 
		    i__2, "f_dyn04__", (ftnlen)658)] = axeseq[(i__3 = i__ + 
		    coords[1] * 3 - 4) < 6 && 0 <= i__3 ? i__3 : s_rnge("axe"
		    "seq", i__3, "f_dyn04__", (ftnlen)658)];
	}

/*        Set the angular units. */

	s_copy(untstr, units + ((i__2 = coords[2] - 1) < 2 && 0 <= i__2 ? 
		i__2 : s_rnge("units", i__2, "f_dyn04__", (ftnlen)664)) * 80, 
		(ftnlen)80, (ftnlen)80);

/*        Set the epoch. */

	s_copy(epoch, epcstr + ((i__2 = coords[3] - 1) < 2 && 0 <= i__2 ? 
		i__2 : s_rnge("epcstr", i__2, "f_dyn04__", (ftnlen)669)) * 80,
		 (ftnlen)80, (ftnlen)80);

/*        Set the base frame. */

	s_copy(bframe, basefr + (((i__2 = coords[4] - 1) < 3 && 0 <= i__2 ? 
		i__2 : s_rnge("basefr", i__2, "f_dyn04__", (ftnlen)674)) << 5)
		, (ftnlen)32, (ftnlen)32);

/*        Set the frame center.  Obtain the center as a name. */

	center = ctrcde[(i__2 = coords[5] - 1) < 2 && 0 <= i__2 ? i__2 : 
		s_rnge("ctrcde", i__2, "f_dyn04__", (ftnlen)679)];
	bodc2n_(&center, ctrnam, &found, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Set the rotation state. */

	s_copy(rststr, rstate + ((i__2 = coords[6] - 1) < 3 && 0 <= i__2 ? 
		i__2 : s_rnge("rstate", i__2, "f_dyn04__", (ftnlen)689)) * 80,
		 (ftnlen)32, (ftnlen)80);

/*        Decide whether the current test case is the special case */
/*        for Mars. */

	ismars = center == 499 && s_cmp(bframe, "J2000", (ftnlen)32, (ftnlen)
		5) == 0 && s_cmp(epoch, "@2000-JAN-1/12:00", (ftnlen)80, (
		ftnlen)17) == 0 && s_cmp(untstr, "'DEGREES'", (ftnlen)80, (
		ftnlen)9) == 0 && coords[1] == 1 && coords[0] == 3;

/*        For this test family, there are no cases that must be */
/*        rejected, so the "GO" flag is always .TRUE.  We keep */
/*        this currently unused flag to simplify maintenance of */
/*        this code. */

	go = TRUE_;
	if (go) {

/*           We're ready to create a frame definition. */


/*           Create a text buffer containing a frame definition that */
/*           uses the current frame definition */


/*           First comes the frame name-to-frame code assignment. */

	    s_copy(frname, "EULER_DYN_FRAME", (ftnlen)32, (ftnlen)15);
	    frcode = -2000000000;
	    s_copy(deftxt, "FRAME_#           = #", (ftnlen)80, (ftnlen)21);
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
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 22, a__1[1] = "NAME             = '#'";
	    s_cat(deftxt + 80, a__1, i__4, &c__2, (ftnlen)80);
	    repmc_(deftxt + 80, "#", frname, deftxt + 80, (ftnlen)80, (ftnlen)
		    1, (ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Frame class and class ID come next. */

/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 20, a__1[1] = "CLASS            = 5";
	    s_cat(deftxt + 160, a__1, i__4, &c__2, (ftnlen)80);
/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 20, a__1[1] = "CLASS_ID         = #";
	    s_cat(deftxt + 240, a__1, i__4, &c__2, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt + 240, "#", &frcode, deftxt + 240, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           The frame center is specified via a name. */

/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 22, a__1[1] = "CENTER           = '#'";
	    s_cat(deftxt + 320, a__1, i__4, &c__2, (ftnlen)80);
	    repmc_(deftxt + 320, "#", ctrnam, deftxt + 320, (ftnlen)80, (
		    ftnlen)1, (ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the base frame. */

/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 22, a__1[1] = "RELATIVE         = '#'";
	    s_cat(deftxt + 400, a__1, i__4, &c__2, (ftnlen)80);
	    repmc_(deftxt + 400, "#", bframe, deftxt + 400, (ftnlen)80, (
		    ftnlen)1, (ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the frame definition style and family. */

/* Writing concatenation */
	    i__5[0] = 18, a__2[0] = frstem;
	    i__5[1] = 9, a__2[1] = "DEF_STYLE";
	    i__5[2] = 7, a__2[2] = "    = '";
	    i__5[3] = 13, a__2[3] = "PARAMETERIZED";
	    i__5[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 480, a__2, i__5, &c__5, (ftnlen)80);
	    repmi_(deftxt + 480, "#", &frcode, deftxt + 480, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* Writing concatenation */
	    i__5[0] = 18, a__2[0] = frstem;
	    i__5[1] = 6, a__2[1] = "FAMILY";
	    i__5[2] = 14, a__2[2] = "           = '";
	    i__5[3] = 5, a__2[3] = "EULER";
	    i__5[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 560, a__2, i__5, &c__5, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt + 560, "#", &frcode, deftxt + 560, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the epoch for the polynomials. */

/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 5, a__3[1] = "EPOCH";
	    i__6[2] = 14, a__3[2] = "            = ";
	    i__6[3] = 80, a__3[3] = epoch;
	    s_cat(deftxt + 640, a__3, i__6, &c__4, (ftnlen)80);

/*           Set the units for the polynomial coefficients. */

/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 5, a__3[1] = "UNITS";
	    i__6[2] = 14, a__3[2] = "            = ";
	    i__6[3] = 80, a__3[3] = untstr;
	    s_cat(deftxt + 720, a__3, i__6, &c__4, (ftnlen)80);

/*           Set the axis sequence. */

	    s_copy(axestr, "( # # # )", (ftnlen)80, (ftnlen)9);
	    for (i__ = 1; i__ <= 3; ++i__) {
		repmi_(axestr, "#", &axes[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? 
			i__2 : s_rnge("axes", i__2, "f_dyn04__", (ftnlen)804)]
			, axestr, (ftnlen)80, (ftnlen)1, (ftnlen)80);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
	    }
/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 4, a__3[1] = "AXES";
	    i__6[2] = 15, a__3[2] = "             = ";
	    i__6[3] = 80, a__3[3] = axestr;
	    s_cat(deftxt + 800, a__3, i__6, &c__4, (ftnlen)80);

/*           Set the coefficients. */

/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 14, a__3[1] = "ANGLE_1_COEFFS";
	    i__6[2] = 5, a__3[2] = "   = ";
	    i__6[3] = 80, a__3[3] = angcof;
	    s_cat(deftxt + 880, a__3, i__6, &c__4, (ftnlen)80);
/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 14, a__3[1] = "ANGLE_2_COEFFS";
	    i__6[2] = 5, a__3[2] = "   = ";
	    i__6[3] = 80, a__3[3] = angcof + 80;
	    s_cat(deftxt + 960, a__3, i__6, &c__4, (ftnlen)80);
/* Writing concatenation */
	    i__6[0] = 18, a__3[0] = frstem;
	    i__6[1] = 14, a__3[1] = "ANGLE_3_COEFFS";
	    i__6[2] = 5, a__3[2] = "   = ";
	    i__6[3] = 80, a__3[3] = angcof + 160;
	    s_cat(deftxt + 1040, a__3, i__6, &c__4, (ftnlen)80);

/*           Set the frame's rotation state or freeze epoch. */

	    if (s_cmp(rststr, "FROZEN", (ftnlen)32, (ftnlen)6) == 0) {
/* Writing concatenation */
		i__6[0] = 18, a__3[0] = frstem;
		i__6[1] = 12, a__3[1] = "FREEZE_EPOCH";
		i__6[2] = 7, a__3[2] = "     = ";
		i__6[3] = 20, a__3[3] = "@2010-JAN-1/00:00:00";
		s_cat(deftxt + 1120, a__3, i__6, &c__4, (ftnlen)80);
	    } else {
/* Writing concatenation */
		i__5[0] = 18, a__2[0] = frstem;
		i__5[1] = 14, a__2[1] = "ROTATION_STATE";
		i__5[2] = 8, a__2[2] = "     = '";
		i__5[3] = rtrim_(rststr, (ftnlen)32), a__2[3] = rststr;
		i__5[4] = 1, a__2[4] = "'";
		s_cat(deftxt + 1120, a__2, i__5, &c__5, (ftnlen)80);
	    }
	    dx = 15;

/*           Enter the frame definition into the kernel pool. */

	    lmpool_(deftxt, &dx, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Here's where the testing begins. */


/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM/PXFORM test number #A.  Test results against thos"
		    "e from PXFORM.", "#", &case__, casmsg, (ftnlen)70, (
		    ftnlen)1, (ftnlen)240);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)240);

/*           Pick a time value. */

	    et = (case__ - 100) * 1e3;
	    sxform_(frname, bframe, &et, xform, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    pxform_(frname, bframe, &et, r__, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Extract the derivative block from XFORM into DRVBLK. */
/*           We'll use this block later; we're extracting it here */
/*           to keep this code close to the associated SXFORM call. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    drvblk[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("drvblk", i__2, "f_dyn04__", (ftnlen)870)] 
			    = xform[(i__3 = j + 3 + i__ * 6 - 7) < 36 && 0 <= 
			    i__3 ? i__3 : s_rnge("xform", i__3, "f_dyn04__", (
			    ftnlen)870)];
		}
	    }
	    dmag = vnormg_(drvblk, &c__9);

/*           Extract the rotation block from XFORM into R2. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    r2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("r2", i__2, "f_dyn04__", (ftnlen)881)] = 
			    xform[(i__3 = j + i__ * 6 - 7) < 36 && 0 <= i__3 ?
			     i__3 : s_rnge("xform", i__3, "f_dyn04__", (
			    ftnlen)881)];
		}
	    }
	    chckad_("SXFORM vs PXFORM", r2, "~", r__, &c__9, &c_b192, ok, (
		    ftnlen)16, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM test number #B.  Test derivative block.", "#", &
		    case__, casmsg, (ftnlen)46, (ftnlen)1, (ftnlen)240);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)240);

/*           Pick a time value. */

	    et = (case__ - 100) * 1e3;
	    sxform_(frname, bframe, &et, xform, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Perform "sanity checks" on the returned matrix. */
/*           Make sure the diagonal blocks are identical rotations, */
/*           compute a discrete derivative and compare to the */
/*           lower left block, and make sure the upper right */
/*           block is a zero matrix. */

/*           The value of DELTA (1/16) was determined by experimentation. */

	    delta = .0625;
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
	    chcksd_("DETERR", &deterr, "~", &c_b207, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           Check norms of rows and columns in the rotation */
/*           blocks. */

	    chcksd_("NRMERR", &nrmerr, "~", &c_b207, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           If the frame is considered to be rotating, compare the */
/*           discrete derivative to the lower left block. */

	    if (eqstr_(rststr, "ROTATING", (ftnlen)32, (ftnlen)8)) {

/*              Check the derivative absolute error. */

		tol = 1e-6;
		chcksd_("DRVERR", &drverr, "~", &c_b207, &tol, ok, (ftnlen)6, 
			(ftnlen)1);

/*              Check the derivative relative error. */

		tol = 1e-4;
		chcksd_("DRLERR", &drlerr, "~", &c_b207, &tol, ok, (ftnlen)6, 
			(ftnlen)1);
	    } else if (eqstr_(rststr, "INERTIAL", (ftnlen)32, (ftnlen)8)) {

/*              The frame is supposed to be inertial, so the */
/*              state transformation mapping from this frame to */
/*              J2000 ideally should have a zero derivative block. */
/*              See whether the derivative block of the latter */
/*              transformation is close to zero. */

		sxform_(bframe, "J2000", &et, xfb2j, (ftnlen)32, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxmg_(xfb2j, xform, &c__6, &c__6, &c__6, xff2j);
		for (i__ = 1; i__ <= 3; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			drv2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 
				: s_rnge("drv2", i__2, "f_dyn04__", (ftnlen)
				972)] = xff2j[(i__3 = j + 3 + i__ * 6 - 7) < 
				36 && 0 <= i__3 ? i__3 : s_rnge("xff2j", i__3,
				 "f_dyn04__", (ftnlen)972)];
		    }
		}
		chckad_("Derivative block", drv2, "~", zr, &c__9, &c_b232, ok,
			 (ftnlen)16, (ftnlen)1);
	    } else {

/*              The frozen case is quite simple:  the derivative */
/*              with respect to the base frame is zero. */

		chckad_("Derivative block", drvblk, "=", zr, &c__9, &c_b207, 
			ok, (ftnlen)16, (ftnlen)1);
	    }

/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM test number #C. Construct state transformation lo"
		    "cally; compare to XFORM output.", "#", &case__, casmsg, (
		    ftnlen)87, (ftnlen)1, (ftnlen)240);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)240);

/*           Parse the reference epoch; compute the evaluation epoch. If */
/*           the rotation state is frozen, use the "freeze" value. */

	    cmprss_("@", &c__0, epoch, timstr, (ftnlen)1, (ftnlen)80, (ftnlen)
		    80);
	    suffix_("TDB", &c__1, timstr, (ftnlen)3, (ftnlen)80);
	    str2et_(timstr, &refepc, (ftnlen)80);
	    if (eqstr_(rststr, "FROZEN", (ftnlen)32, (ftnlen)6)) {
		t = t0 - refepc;
	    } else {
		t = et - refepc;
	    }

/*           Compute the Euler angles and their derivatives; */
/*           scale to radians and radians/sec. */

	    for (i__ = 1; i__ <= 3; ++i__) {

/*              Parse the string '( <coeff 0> <coeff 1> ... <coeff n> )' */

		lparsm_(angcof + ((i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : 
			s_rnge("angcof", i__2, "f_dyn04__", (ftnlen)1025)) * 
			80, " ()", &c__7, &n, tokens, (ftnlen)80, (ftnlen)3, (
			ftnlen)80);

/*              The first token will be the null token preceeding */
/*              the first parenthesis.  The next 1-3 tokens are */
/*              numbers.  The last token is also null. */

		i__2 = n - 1;
		for (j = 2; j <= i__2; ++j) {
		    prsdp_(tokens + ((i__3 = j - 1) < 7 && 0 <= i__3 ? i__3 : 
			    s_rnge("tokens", i__3, "f_dyn04__", (ftnlen)1033))
			     * 80, &coeffs[(i__7 = j - 2) < 6 && 0 <= i__7 ? 
			    i__7 : s_rnge("coeffs", i__7, "f_dyn04__", (
			    ftnlen)1033)], (ftnlen)80);
		}
/*               WRITE (*,*) '-------------------------------------' */
/*               WRITE (*,*) ( COEFFS(J), J = 0, N-3 ) */
/*               WRITE (*,*) '-------------------------------------' */

/*              Evaluate the polynomial P representing the angle */
/*              and its time derivative DP at T. */

		p = 0.;
		for (j = n - 3; j >= 0; --j) {
		    p = coeffs[(i__2 = j) < 6 && 0 <= i__2 ? i__2 : s_rnge(
			    "coeffs", i__2, "f_dyn04__", (ftnlen)1048)] + t * 
			    p;
		}
		dp = 0.;
		for (j = n - 3; j >= 1; --j) {
		    dp = j * (coeffs[(i__2 = j) < 6 && 0 <= i__2 ? i__2 : 
			    s_rnge("coeffs", i__2, "f_dyn04__", (ftnlen)1056)]
			     + t * dp);
		}

/*              Convert angular units to radians. */

		cmprss_("'", &c__0, untstr, inunit__, (ftnlen)1, (ftnlen)80, (
			ftnlen)80);
		convrt_(&p, inunit__, "RADIANS", &eulang[(i__2 = i__ - 1) < 6 
			&& 0 <= i__2 ? i__2 : s_rnge("eulang", i__2, "f_dyn0"
			"4__", (ftnlen)1065)], (ftnlen)80, (ftnlen)7);
		convrt_(&dp, inunit__, "RADIANS", &eulang[(i__2 = i__ + 2) < 
			6 && 0 <= i__2 ? i__2 : s_rnge("eulang", i__2, "f_dy"
			"n04__", (ftnlen)1066)], (ftnlen)80, (ftnlen)7);
	    }

/*           Compute the state transformation matrix. */

	    eul2xf_(eulang, axes, &axes[1], &axes[2], xf2);

/*           Now compare XF2 to XFORM. */

/*           Extract the derivative block from XF2. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    drv2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("drv2", i__2, "f_dyn04__", (ftnlen)1082)] =
			     xf2[(i__3 = j + 3 + i__ * 6 - 7) < 36 && 0 <= 
			    i__3 ? i__3 : s_rnge("xf2", i__3, "f_dyn04__", (
			    ftnlen)1082)];
		}
	    }

/*           Extract the rotation block and compare to */
/*           that for our dynamic frame. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    r2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("r2", i__2, "f_dyn04__", (ftnlen)1092)] = 
			    xf2[(i__3 = j + i__ * 6 - 7) < 36 && 0 <= i__3 ? 
			    i__3 : s_rnge("xf2", i__3, "f_dyn04__", (ftnlen)
			    1092)];
		}
	    }

/*           Compare to the rotation from the Euler frame to */
/*           the base frame returned by PXFORM. */

	    pxform_(frname, bframe, &et, r__, (ftnlen)32, (ftnlen)32);
	    tol = 1e-14;
	    chckad_("R2", r2, "~", r__, &c__9, &tol, ok, (ftnlen)2, (ftnlen)1)
		    ;

/*           Check the derivative block of the state transformation */
/*           matrix. */

	    sxform_(frname, bframe, &et, xform, (ftnlen)32, (ftnlen)32);
	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    drvblk[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("drvblk", i__2, "f_dyn04__", (ftnlen)1114)]
			     = xform[(i__3 = j + 3 + i__ * 6 - 7) < 36 && 0 <=
			     i__3 ? i__3 : s_rnge("xform", i__3, "f_dyn04__", 
			    (ftnlen)1114)];
		}
	    }

/*           Our locally derivative is relevant only if the frame's */
/*           rotation state is KVROTG. */

	    if (s_cmp(rststr, "ROTATING", (ftnlen)32, (ftnlen)8) == 0) {
		tol = 1e-14;
		chckad_("d(R2)/dt", drv2, "~", drvblk, &c__9, &tol, ok, (
			ftnlen)8, (ftnlen)1);
	    }

/* --- Case: ------------------------------------------------------ */


/*           We've finished the generic tests.  If our frame is */
/*           the pseudo IAU_MARS frame, compare the frame to that */
/*           defined by our PCK. */

	    if (ismars && s_cmp(rststr, "ROTATING", (ftnlen)32, (ftnlen)8) == 
		    0) {
		tcase_("IAU_MARS test case", (ftnlen)18);

/*              Get the PCK-defined state transformation matrix. */
/*              Set the epoch to ~2030; this will allow velocity */
/*              errors to accumulate. */

		et = jyear_() * 30;
		sxform_("J2000", "IAU_MARS", &et, tsipm, (ftnlen)5, (ftnlen)8)
			;

/*              Extract the derivative block. */

		for (i__ = 1; i__ <= 3; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			drv2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 
				: s_rnge("drv2", i__2, "f_dyn04__", (ftnlen)
				1154)] = tsipm[(i__3 = j + 3 + i__ * 6 - 7) < 
				36 && 0 <= i__3 ? i__3 : s_rnge("tsipm", i__3,
				 "f_dyn04__", (ftnlen)1154)];
		    }
		}

/*              Extract the rotation block and compare to */
/*              that for our dynamic frame. */

		for (i__ = 1; i__ <= 3; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			tipm[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 
				: s_rnge("tipm", i__2, "f_dyn04__", (ftnlen)
				1164)] = tsipm[(i__3 = j + i__ * 6 - 7) < 36 
				&& 0 <= i__3 ? i__3 : s_rnge("tsipm", i__3, 
				"f_dyn04__", (ftnlen)1164)];
		    }
		}
		pxform_("J2000", frname, &et, r__, (ftnlen)5, (ftnlen)32);
		tol = 1e-11;
		chckad_("Mars TIPM", r__, "~", tipm, &c__9, &tol, ok, (ftnlen)
			9, (ftnlen)1);

/*              Check the derivative block of the state transformation */
/*              matrix. */

		sxform_("J2000", frname, &et, xform, (ftnlen)5, (ftnlen)32);
		for (i__ = 1; i__ <= 3; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			drvblk[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? 
				i__2 : s_rnge("drvblk", i__2, "f_dyn04__", (
				ftnlen)1181)] = xform[(i__3 = j + 3 + i__ * 6 
				- 7) < 36 && 0 <= i__3 ? i__3 : s_rnge("xform"
				, i__3, "f_dyn04__", (ftnlen)1181)];
		    }
		}
		chckad_("Mars d(TIPM)/dt", drvblk, "~", drv2, &c__9, &tol, ok,
			 (ftnlen)15, (ftnlen)1);
	    }
	}

/*        Expunge the optional keywords from the kernel pool. */

	if (s_cmp(rststr, "FROZEN", (ftnlen)32, (ftnlen)6) == 0) {
/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 12, a__1[1] = "FREEZE_EPOCH";
	    s_cat(keywrd, a__1, i__4, &c__2, (ftnlen)80);
	} else {
/* Writing concatenation */
	    i__4[0] = 18, a__1[0] = frstem;
	    i__4[1] = 14, a__1[1] = "ROTATION_STATE";
	    s_cat(keywrd, a__1, i__4, &c__2, (ftnlen)80);
	}
	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Clean up the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test_dyn.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dyn04__ */

