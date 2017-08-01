/* f_dyn02.f -- translated by f2c (version 19980913).
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
static integer c__3 = 3;
static integer c__2 = 2;
static integer c__5 = 5;
static integer c__4 = 4;
static integer c__9 = 9;
static doublereal c_b152 = 1e-12;
static doublereal c_b165 = 0.;
static integer c__6 = 6;
static doublereal c_b190 = 1e-19;

/* $Procedure F_DYN02 ( Dynamic Frame Test Family 02 ) */
/* Subroutine */ int f_dyn02__(logical *ok)
{
    /* Initialized data */

    static doublereal zr[9]	/* was [3][3] */ = { 0.,0.,0.,0.,0.,0.,0.,0.,
	    0. };
    static char rstate[80*3] = "ROTATING                                    "
	    "                                    " "INERTIAL                 "
	    "                                                       " "FROZEN"
	    "                                                                "
	    "          ";
    static char basefr[32*3] = "J2000                           " "IAU_MARS "
	    "                       " "GSE                             ";
    static integer ctrcde[1] = { 399 };
    static integer dims__[3] = { 3,3,1 };

    /* System generated locals */
    address a__1[2], a__2[5], a__3[4];
    integer i__1, i__2, i__3[2], i__4[5], i__5[4], i__6;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal dmag;
    integer case__;
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *), mxmt_(doublereal *, 
	    doublereal *, doublereal *);
    doublereal xfb2j[36]	/* was [6][6] */, xff2j[36]	/* was [6][6] 
	    */;
    extern /* Subroutine */ int zzeprcss_(doublereal *, doublereal *);
    integer i__, j;
    doublereal r__[9]	/* was [3][3] */, t, delta;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal precm[9]	/* was [3][3] */;
    integer ncart;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *, char *
	    , ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    doublereal r2[9]	/* was [3][3] */, rplus[9]	/* was [3][3] */, t0;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), str2et_(char *, doublereal *, ftnlen);
    logical go;
    doublereal et;
    integer handle;
    char bframe[32];
    integer dx;
    doublereal drdiff[9]	/* was [3][3] */;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     delfil_(char *, ftnlen);
    char frname[32];
    extern /* Subroutine */ int t_pck08__(char *, logical *, logical *, 
	    ftnlen);
    extern integer prodai_(integer *, integer *);
    extern doublereal vnormg_(doublereal *, integer *);
    char casmsg[240], deftxt[80*50], frzepc[50], keywrd[80], rststr[80], 
	    frstem[18];
    doublereal deterr, drlerr, drvblk[9]	/* was [3][3] */, drverr, 
	    nrmerr, rminus[9]	/* was [3][3] */;
    integer coords[3], center;
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen), cmprss_(char *, integer *, char *, char *, 
	    ftnlen, ftnlen, ftnlen), replch_(char *, char *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen), suffix_(char *, integer *, char *
	    , ftnlen, ftnlen), lmpool_(char *, integer *, ftnlen), multix_(
	    integer *, integer *, integer *, integer *, integer *), sxform_(
	    char *, char *, doublereal *, doublereal *, ftnlen, ftnlen), 
	    pxform_(char *, char *, doublereal *, doublereal *, ftnlen, 
	    ftnlen), dvpool_(char *, ftnlen), spkuef_(integer *);
    doublereal tol;
    extern /* Subroutine */ int t_xform__(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal rj2b[9]	/* was [3][3] */, drv2[9]	/* was [3][3] */;

/* $ Abstract */

/*     Test family to exercise the logic and code in the second */
/*     subset of dynamic frame routines.  Only mean equator and */
/*     equinox of date frames are used in these tests. */

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

/*     As the set of mean-of-date frames grows, this routine should */
/*     be updated to exercise each supported frame model. */

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

/* -    TSPICE Version 1.1.0, 12-JAN-2005 (NJB) */

/*        Parameters KWX, KWY, KWZ were renamed to KVX, KVY, KVZ. */

/* -    TSPICE Version 1.0.0, 10-JAN-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Tolerance levels for various tests. */


/*     Parameters controlling frame definitions: */


/*     The dimensions of the test parameter space are: */

/*         1) Rotation state */
/*         2) Base frame */
/*         3) Frame center */

/*     Number of dimensions of the test parameter space: */


/*     Number of rotation states: */


/*     The constant RSTIDX refers to the ordinal position of the */
/*     dimension corresponding to the rotation state in the parameter */
/*     space. */


/*     Number of base frame cases: */


/*     The constant BFRIDX refers to the ordinal position of the */
/*     dimension corresponding to base frame in the parameter */
/*     space. */


/*     Number of frame center cases: */


/*     Local Variables */


/*     We'll use the kernel variable name "stem" */

/*        FRAME_<ID code>_ */

/*     The length declared below (18) is the length of such a string */
/*     where the ID code contains 11 digits. */


/*     This variable is used for debugging. */


/*     Saved variables */


/*     Initial values */


/*     Rotation states: */


/*     We use both inertial, PCK-based, and dynamic base frames. */


/*     ID codes of frame centers: */


/*     DIMS defines the dimensions of the cartesian product of the */
/*     input parameters.  The cardinality of the set comprising the */
/*     Nth "factor" of the cartesian product is DIMS(N).  The cardinality */
/*     of the product itself is the product of the elements of DIMS. */


/*     Open the test family. */

    topen_("F_DYN02", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Create test inputs for comprehensive mean-of-date test.", (ftnlen)
	    55);

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

/*     We use MULTIX and the array DIMS to define a mapping that allows */
/*     us to map a test case number to a set of input parameters. */

/*     Compute the number of test cases in the input cartesian product */
/*     space. */

    ncart = prodai_(dims__, &c__3);
    i__1 = ncart;
    for (case__ = 1; case__ <= i__1; ++case__) {

/*        Find the multi-dimensional coordinates of the current */
/*        case in the cartesian product of the test input sets. */

	multix_(&c__1, &c__3, dims__, &case__, coords);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the rotation state. */

	s_copy(rststr, rstate + ((i__2 = coords[0] - 1) < 3 && 0 <= i__2 ? 
		i__2 : s_rnge("rstate", i__2, "f_dyn02__", (ftnlen)485)) * 80,
		 (ftnlen)80, (ftnlen)80);

/*        Set the base frame. */

	s_copy(bframe, basefr + (((i__2 = coords[1] - 1) < 3 && 0 <= i__2 ? 
		i__2 : s_rnge("basefr", i__2, "f_dyn02__", (ftnlen)490)) << 5)
		, (ftnlen)32, (ftnlen)32);

/*        Set the frame center. */

	center = ctrcde[(i__2 = coords[2] - 1) < 1 && 0 <= i__2 ? i__2 : 
		s_rnge("ctrcde", i__2, "f_dyn02__", (ftnlen)495)];

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

	    s_copy(frname, "MEAN_OF_DATE_DYN_FRAME", (ftnlen)32, (ftnlen)22);
	    frcode = -2000000000;
	    s_copy(deftxt, "FRAME_#    = #", (ftnlen)80, (ftnlen)14);
	    repmc_(deftxt, "#", frname, deftxt, (ftnlen)80, (ftnlen)1, (
		    ftnlen)32, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt, "#", &frcode, deftxt, (ftnlen)80, (ftnlen)1, (
		    ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           We'll use the kernel variable name "stem" */

/*              FRAME_<ID code>_ */

/*           repeatedly, so instead of making many REPMI */
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

/*           The frame center must be specified via a code. */

/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 20, a__1[1] = "CENTER           = #";
	    s_cat(deftxt + 320, a__1, i__3, &c__2, (ftnlen)80);
	    repmi_(deftxt + 320, "#", &center, deftxt + 320, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
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
	    i__4[2] = 7, a__2[2] = "    = '";
	    i__4[3] = 13, a__2[3] = "PARAMETERIZED";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 480, a__2, i__4, &c__5, (ftnlen)80);
	    repmi_(deftxt + 480, "#", &frcode, deftxt + 480, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* Writing concatenation */
	    i__4[0] = 18, a__2[0] = frstem;
	    i__4[1] = 6, a__2[1] = "FAMILY";
	    i__4[2] = 14, a__2[2] = "           = '";
	    i__4[3] = 32, a__2[3] = "MEAN_EQUATOR_AND_EQUINOX_OF_DATE";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 560, a__2, i__4, &c__5, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    repmi_(deftxt + 560, "#", &frcode, deftxt + 560, (ftnlen)80, (
		    ftnlen)1, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Set the frame's precession model. */

/* Writing concatenation */
	    i__4[0] = 18, a__2[0] = frstem;
	    i__4[1] = 10, a__2[1] = "PREC_MODEL";
	    i__4[2] = 4, a__2[2] = " = '";
	    i__4[3] = 14, a__2[3] = "EARTH_IAU_1976";
	    i__4[4] = 1, a__2[4] = "'";
	    s_cat(deftxt + 640, a__2, i__4, &c__5, (ftnlen)80);

/*           Set the frame's rotation state or freeze epoch. */

	    if (s_cmp(rststr, "FROZEN", (ftnlen)80, (ftnlen)6) == 0) {
/* Writing concatenation */
		i__5[0] = 18, a__3[0] = frstem;
		i__5[1] = 12, a__3[1] = "FREEZE_EPOCH";
		i__5[2] = 7, a__3[2] = "     = ";
		i__5[3] = 20, a__3[3] = "@2010-JAN-1/00:00:00";
		s_cat(deftxt + 720, a__3, i__5, &c__4, (ftnlen)80);
	    } else {
/* Writing concatenation */
		i__4[0] = 18, a__2[0] = frstem;
		i__4[1] = 14, a__2[1] = "ROTATION_STATE";
		i__4[2] = 8, a__2[2] = "     = '";
		i__4[3] = rtrim_(rststr, (ftnlen)80), a__2[3] = rststr;
		i__4[4] = 1, a__2[4] = "'";
		s_cat(deftxt + 720, a__2, i__4, &c__5, (ftnlen)80);
	    }
	    dx = 10;

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

/*           Look up the state and position transformations from */
/*           the defined frame to the base frame at ET. */

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
			    s_rnge("drvblk", i__2, "f_dyn02__", (ftnlen)645)] 
			    = xform[(i__6 = j + 3 + i__ * 6 - 7) < 36 && 0 <= 
			    i__6 ? i__6 : s_rnge("xform", i__6, "f_dyn02__", (
			    ftnlen)645)];
		}
	    }
	    dmag = vnormg_(drvblk, &c__9);

/*           Extract the rotation block from XFORM into R2. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 1; j <= 3; ++j) {
		    r2[(i__2 = j + i__ * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("r2", i__2, "f_dyn02__", (ftnlen)656)] = 
			    xform[(i__6 = j + i__ * 6 - 7) < 36 && 0 <= i__6 ?
			     i__6 : s_rnge("xform", i__6, "f_dyn02__", (
			    ftnlen)656)];
		}
	    }
	    chckad_("SXFORM vs PXFORM", r2, "~", r__, &c__9, &c_b152, ok, (
		    ftnlen)16, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

	    repmi_("SXFORM test number #B.  Test derivative block.", "#", &
		    case__, casmsg, (ftnlen)46, (ftnlen)1, (ftnlen)240);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)240);

/*           Perform "sanity checks" on the returned matrix. Make sure */
/*           the diagonal blocks are identical rotations. Make sure the */
/*           upper right block is a zero matrix. */

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
	    chcksd_("DETERR", &deterr, "~", &c_b165, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           Check norms of rows and columns in the rotation */
/*           blocks. */

	    chcksd_("NRMERR", &nrmerr, "~", &c_b165, &tol, ok, (ftnlen)6, (
		    ftnlen)1);

/*           If the frame is considered to be rotating, compute a */
/*           discrete derivative and compare to the lower left block. */

	    if (eqstr_(rststr, "ROTATING", (ftnlen)80, (ftnlen)8)) {

/*              Check the derivative absolute error. */

		tol = 1e-12;
		chcksd_("DRVERR", &drverr, "~", &c_b165, &tol, ok, (ftnlen)6, 
			(ftnlen)1);

/*              Check the derivative relative error. */

		tol = 1e-5;
		chcksd_("DRLERR", &drlerr, "~", &c_b165, &tol, ok, (ftnlen)6, 
			(ftnlen)1);
/*               IF ( .NOT. OK ) THEN */
/*                  WRITE (*,*) 'DRVERR = ', DRVERR */
/*                  WRITE (*,*) 'DRLERR = ', DRLERR */
/*               END IF */
	    } else if (eqstr_(rststr, "INERTIAL", (ftnlen)80, (ftnlen)8)) {

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
				: s_rnge("drv2", i__2, "f_dyn02__", (ftnlen)
				739)] = xff2j[(i__6 = j + 3 + i__ * 6 - 7) < 
				36 && 0 <= i__6 ? i__6 : s_rnge("xff2j", i__6,
				 "f_dyn02__", (ftnlen)739)];
		    }
		}
		chckad_("Derivative block", drv2, "~", zr, &c__9, &c_b190, ok,
			 (ftnlen)16, (ftnlen)1);
	    } else {

/*              The frozen case is quite simple:  the derivative */
/*              with respect to the base frame is zero. */

		chckad_("Derivative block", drvblk, "=", zr, &c__9, &c_b165, 
			ok, (ftnlen)16, (ftnlen)1);
	    }

/* --- Case: ------------------------------------------------------ */

	    repmi_("PXFORM test number #C. Construct position transformation"
		    " locally; compare to PXFORM output.", "#", &case__, 
		    casmsg, (ftnlen)91, (ftnlen)1, (ftnlen)240);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tcase_(casmsg, (ftnlen)240);

/*           Pick a time value.  If the rotation state is */
/*           frozen, use the "freeze" value. */

	    if (eqstr_(rststr, "FROZEN", (ftnlen)80, (ftnlen)6)) {
		t = t0;
	    } else {
		t = et;
	    }

/*           Get precession matrix. */

	    zzeprcss_(&t, precm);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Now form the transformation from the mean-of-date */
/*           frame to the base frame. */

	    pxform_("J2000", bframe, &t, rj2b, (ftnlen)5, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    mxmt_(rj2b, precm, r2);

/*           Compare to the rotation from the mean-of-date frame to */
/*           the base frame returned by PXFORM. */

	    pxform_(frname, bframe, &et, r__, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    tol = 1e-14;
	    chckad_("R2", r2, "~", r__, &c__9, &tol, ok, (ftnlen)2, (ftnlen)1)
		    ;
	}

/*        Expunge the optional keywords from the kernel pool. */

	if (s_cmp(rststr, "FROZEN", (ftnlen)80, (ftnlen)6) == 0) {
/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 12, a__1[1] = "FREEZE_EPOCH";
	    s_cat(keywrd, a__1, i__3, &c__2, (ftnlen)80);
	} else {
/* Writing concatenation */
	    i__3[0] = 18, a__1[0] = frstem;
	    i__3[1] = 14, a__1[1] = "ROTATION_STATE";
	    s_cat(keywrd, a__1, i__3, &c__2, (ftnlen)80);
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
} /* f_dyn02__ */

