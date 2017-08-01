/* f_dyn05.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__6 = 6;
static integer c__20 = 20;
static integer c__24 = 24;
static integer c__10 = 10;
static integer c__11 = 11;
static integer c__15 = 15;
static integer c__0 = 0;
static integer c__5 = 5;
static integer c__1 = 1;
static integer c__401 = 401;
static integer c__36 = 36;
static doublereal c_b308 = 1e-13;
static integer c__3 = 3;
static integer c__499 = 499;
static integer c__399 = 399;
static doublereal c_b802 = 0.;
static integer c__9 = 9;
static integer c__2 = 2;
static integer c__500 = 500;
static integer c__600 = 600;
static integer c__700 = 700;
static integer c_b1032 = -10001;
static integer c_n9900 = -9900;

/* $Procedure F_DYN05 ( Dynamic Frame Test Family 05 ) */
/* Subroutine */ int f_dyn05__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int ckgp_(integer *, doublereal *, doublereal *, 
	    char *, doublereal *, doublereal *, logical *, ftnlen), mxmg_(
	    doublereal *, doublereal *, integer *, integer *, integer *, 
	    doublereal *), mxvg_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *), mxmt_(doublereal *, doublereal *, 
	    doublereal *), zzspkzp1_(integer *, doublereal *, char *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen, ftnlen), sce2c_(
	    integer *, doublereal *, doublereal *);
    doublereal cmat0[9]	/* was [3][3] */, cmat1[9]	/* was [3][3] */, 
	    cmat2[9]	/* was [3][3] */;
    extern /* Subroutine */ int zzcorepc_(char *, doublereal *, doublereal *, 
	    doublereal *, ftnlen);
    doublereal r__[9]	/* was [3][3] */;
    extern /* Subroutine */ int dafgs_(doublereal *);
    integer clkid;
    extern /* Subroutine */ int dafps_(integer *, integer *, doublereal *, 
	    integer *, doublereal *), tcase_(char *, ftnlen), dafrs_(
	    doublereal *), cklpf_(char *, integer *, ftnlen), dafus_(
	    doublereal *, integer *, integer *, doublereal *, integer *);
    char ident[40];
    integer class__;
    extern /* Subroutine */ int ckupf_(integer *);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int spkez_(integer *, doublereal *, char *, char *
	    , integer *, doublereal *, doublereal *, ftnlen, ftnlen);
    integer rc2cde;
    extern /* Subroutine */ int spkpv_(integer *, doublereal *, doublereal *, 
	    char *, doublereal *, integer *, ftnlen), t_success__(logical *);
    doublereal state0[6], state1[6], state2[6], dc[2];
    extern /* Subroutine */ int rav2xf_(doublereal *, doublereal *, 
	    doublereal *), xf2rav_(doublereal *, doublereal *, doublereal *), 
	    tstck3_(char *, char *, logical *, logical *, logical *, integer *
	    , ftnlen, ftnlen);
    integer ic[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     daffna_(logical *), str2et_(char *, doublereal *, ftnlen), 
	    dafbfs_(integer *);
    doublereal et;
    integer handle[4];
    extern /* Subroutine */ int dafcls_(integer *), chcksc_(char *, char *, 
	    char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int delfil_(char *, ftnlen);
    integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    char frname[32];
    extern /* Subroutine */ int t_pck08__(char *, logical *, logical *, 
	    ftnlen);
    doublereal sclkdp;
    integer center;
    char deftxt[80*50];
    doublereal av0[3], av1[3], av2[3], clkout, etcorr, xf2[36]	/* was [6][6] 
	    */, xf3[36]	/* was [6][6] */, xf4[36]	/* was [6][6] */;
    integer clssid, instid;
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen), lmpool_(char *, integer *, ftnlen), namfrm_(
	    char *, integer *, ftnlen), frmnam_(integer *, char *, ftnlen), 
	    frinfo_(integer *, integer *, integer *, integer *, logical *), 
	    pcpool_(char *, integer *, char *, ftnlen, ftnlen), cidfrm_(
	    integer *, integer *, char *, logical *, ftnlen), cnmfrm_(char *, 
	    integer *, char *, logical *, ftnlen, ftnlen), dvpool_(char *, 
	    ftnlen), sxform_(char *, char *, doublereal *, doublereal *, 
	    ftnlen, ftnlen), spkezr_(char *, doublereal *, char *, char *, 
	    char *, doublereal *, doublereal *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), pxform_(char *, char *, doublereal *, doublereal *, 
	    ftnlen, ftnlen), spkpos_(char *, doublereal *, char *, char *, 
	    char *, doublereal *, doublereal *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), spkezp_(integer *, doublereal *, char *, char *, integer 
	    *, doublereal *, doublereal *, ftnlen, ftnlen), spkgeo_(integer *,
	     doublereal *, char *, integer *, doublereal *, doublereal *, 
	    ftnlen);
    integer han;
    extern /* Subroutine */ int spkgps_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen), spkssb_(integer *,
	     doublereal *, char *, doublereal *, ftnlen), spkapp_(integer *, 
	    doublereal *, char *, doublereal *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen), spkapo_(integer *, doublereal *, 
	    char *, doublereal *, char *, doublereal *, doublereal *, ftnlen, 
	    ftnlen), spksfs_(integer *, doublereal *, integer *, doublereal *,
	     char *, logical *, ftnlen), ckgpav_(integer *, doublereal *, 
	    doublereal *, char *, doublereal *, doublereal *, doublereal *, 
	    logical *, ftnlen), tisbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), tipbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), dafopw_(char *, integer *, ftnlen), 
	    spklef_(char *, integer *, ftnlen), spkuef_(integer *), mxm_(
	    doublereal *, doublereal *, doublereal *);
    doublereal sum[5];
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal pos0[3], pos1[3], pos2[3];

/* $ Abstract */

/*     Test family to exercise SPICELIB interfaces that indirectly */
/*     exercise dynamic frame code. */

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

/* $ Abstract */

/*     The parameters below form an enumerated list of the recognized */
/*     frame types.  They are: INERTL, PCK, CK, TK, DYN.  The meanings */
/*     are outlined below. */

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

/*     INERTL      an inertial frame that is listed in the routine */
/*                 CHGIRF and that requires no external file to */
/*                 compute the transformation from or to any other */
/*                 inertial frame. */

/*     PCK         is a frame that is specified relative to some */
/*                 INERTL frame and that has an IAU model that */
/*                 may be retrieved from the PCK system via a call */
/*                 to the routine TISBOD. */

/*     CK          is a frame defined by a C-kernel. */

/*     TK          is a "text kernel" frame.  These frames are offset */
/*                 from their associated "relative" frames by a */
/*                 constant rotation. */

/*     DYN         is a "dynamic" frame.  These currently are */
/*                 parameterized, built-in frames where the full frame */
/*                 definition depends on parameters supplied via a */
/*                 frame kernel. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 3.0.0, 28-MAY-2004 (NJB) */

/*       The parameter DYN was added to support the dynamic frame class. */

/* -    SPICELIB Version 2.0.0, 12-DEC-1996 (WLT) */

/*        Various unused frames types were removed and the */
/*        frame time TK was added. */

/* -    SPICELIB Version 1.0.0, 10-DEC-1995 (WLT) */

/* -& */
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

/*        CKs generated by tstck3:  one default, one modified */
/*        by changing descriptor via DAFRS. */

/*        LSK generated by tstlsk */

/*        PCK generated by t_pck08 */

/*        SPKs generated by tstspk: one default, one modified */
/*        by changing descriptor via DAFRS. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     Test family F_DYN05 exercises SPICELIB interfaces that use */
/*     dynamic frames. */

/*     Most tests done here check interfaces by means of consistency */
/*     checks:  computations are done in alternate ways and the results */
/*     are compared.  The test rely heavily on the routines SXFORM */
/*     and PXFORM; the other test families are expected to prove these */
/*     two routines correct. */

/*     This routine attempts to exercise the main computational paths of */
/*     the underlying frame transformation code; for this reason, */
/*     examples of each frame family are used in at least one test. The */
/*     tests of the frame transformation code are meant first of all to */
/*     simply verify that the integrated dynamic frame capability works, */
/*     but also to probe for possible recursion violations.  However */
/*     these tests are not exhaustive; the frame-family-specific test */
/*     families are expected to cover all logic paths in the low-level */
/*     frame transformation code. */

/*     In some cases, the tests simply verify that improper uses */
/*     of dynamic frames are diagnosed. */

/*     Here kernel readers are considered to be part of the API:  this */
/*     test family checks the ability of the SPK and CK readers, */
/*     respectively, to properly handle SPK and CK segments having */
/*     dynamic base frames.  Note that PCKs are not allowed to have */
/*     non-inertial base frames. */


/*     Covered API routines are: */

/*        Frame subsystem */
/*        =============== */

/*           Transformation routines */
/*           ----------------------- */
/*           PXFORM */
/*           SXFORM */


/*           FRAMEX ("frame expert") routines */
/*           -------------------------------- */
/*           CIDFRM */
/*           CNMFRM */
/*           FRINFO */
/*           FRMNAM */
/*           NAMFRM */

/*        SPK subsystem */
/*        =============== */

/*           Principal readers */
/*           ----------------- */
/*           SPKEZR */
/*           SPKPOS */
/*           SPKEZ */
/*           SPKEZP */

/*           Geometric state API */
/*           ------------------- */
/*           SPKGEO */
/*           SPKGPS */

/*           Apparent state routines */
/*           ----------------------- */
/*           SPKAPO */
/*           SPKAPP */

/*           Barycentric state API */
/*           --------------------- */
/*           SPKSSB */

/*           Miscellaneous (deprecated) */
/*           -------------------------- */
/*           SPKPV */


/*        CK subsystem */
/*        =============== */
/*        CKGP */
/*        CPGPAV */

/*        PCK subsystem */
/*        =============== */
/*        TIPBOD */
/*        TISBOD */


/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.1.0, 20-OCT-2005 (NJB) */

/*        Parameters KWX, KWY, KWZ were renamed to KVX, KVY, KVZ. */

/* -    TSPICE Version 1.0.0, 10-JAN-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Note:  the name CKNM was picked because the more consistent */
/*     name "CK" is taken---it's the name of a frame class. */


/*     Tolerance levels for various tests. */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Open the test family. */

    topen_("F_DYN05", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Create test inputs for comprehensive mean-of-date test.", (ftnlen)
	    55);

/*     Create and load kernels. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("test_dyn.bsp", &c_true, handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_pck08__("test_dyn.tpc", &c_true, &c_false, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstck3_("test_ck3.bc", "test_ck3.tsc", &c_true, &c_true, &c_false, &
	    handle[1], (ftnlen)11, (ftnlen)12);

/*     Define a CK frame associated with instrument -10001; the pointing */
/*     for this instrument is given by the CK created by the test */
/*     utility TSTCK3. */

    s_copy(deftxt, "FRAME_CK_-10001                  =  -10001", (ftnlen)80, (
	    ftnlen)42);
    s_copy(deftxt + 80, "FRAME_-10001_NAME                = 'CK_-10001'", (
	    ftnlen)80, (ftnlen)46);
    s_copy(deftxt + 160, "FRAME_-10001_CLASS               =  3", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_-10001_CLASS_ID            =  -10001", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 320, "FRAME_-10001_CENTER              =  -9", (ftnlen)80,
	     (ftnlen)38);
    s_copy(deftxt + 400, "FRAME_-10001_RELATIVE            = 'J2000'", (
	    ftnlen)80, (ftnlen)42);

/*     Load the CK_-10001 frame definition. */

    lmpool_(deftxt, &c__6, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define a CK frame associated with instrument -9901; the pointing */
/*     for this instrument is given by the CK created by the test */
/*     utility TSTCK3. */

    s_copy(deftxt, "FRAME_CK_-9901                   =  -9901", (ftnlen)80, (
	    ftnlen)41);
    s_copy(deftxt + 80, "FRAME_-9901_NAME                 = 'CK_-9901'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 160, "FRAME_-9901_CLASS                =  3", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_-9901_CLASS_ID             =  -9901", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 320, "FRAME_-9901_CENTER               =  -9", (ftnlen)80,
	     (ftnlen)38);
    s_copy(deftxt + 400, "FRAME_-9901_RELATIVE             = 'GALACTIC'", (
	    ftnlen)80, (ftnlen)45);

/*     Load the CK_-9901 frame definition. */

    lmpool_(deftxt, &c__6, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We'll need to several dynamic frames. Since the purpose of the */
/*     frames is to test the ability of the frame subsystem to handle */
/*     varying levels of recursive calls, we'll name the frames based on */
/*     the required recursion levels associated with transformations */
/*     between the frames and the J2000 frame. */

    s_copy(deftxt, "FRAME_RECUR_1                    =  2399001", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2399001_NAME               = 'RECUR_1'", (
	    ftnlen)80, (ftnlen)44);
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
    s_copy(deftxt + 720, "FRAME_2399001_PRI_VECTOR_DEF       = 'TARGET_NEAR_"
	    "POINT'", (ftnlen)80, (ftnlen)56);
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

/*     Load the RECUR_1 frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define a two-vector frame using a constant vector and */
/*     requiring one level of recursion for evaluation. */

    s_copy(deftxt, "FRAME_RECUR_1B                    =  2399002", (ftnlen)80,
	     (ftnlen)44);
    s_copy(deftxt + 80, "FRAME_2399002_NAME               = 'RECUR_1B'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 160, "FRAME_2399002_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399002_CLASS_ID           =  2399002", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399002_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399002_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399002_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2399002_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2399002_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2399002_PRI_VECTOR_DEF       = 'CONSTANT'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 800, "FRAME_2399002_PRI_FRAME          = 'IAU_SUN'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 880, "FRAME_2399002_PRI_OBSERVER       = 'EARTH'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 960, "FRAME_2399002_PRI_ABCORR         = 'LT'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 1040, "FRAME_2399002_PRI_SPEC         = 'LATITUDINAL'", (
	    ftnlen)80, (ftnlen)46);
    s_copy(deftxt + 1120, "FRAME_2399002_PRI_UNITS         = 'DEGREES'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 1200, "FRAME_2399002_PRI_LONGITUDE          =  60.0", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 1280, "FRAME_2399002_PRI_LATITUDE          = -30.0", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 1360, "FRAME_2399002_SEC_AXIS       = '-Y'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1440, "FRAME_2399002_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1520, "FRAME_2399002_SEC_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1600, "FRAME_2399002_SEC_TARGET       = 'EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1680, "FRAME_2399002_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1760, "FRAME_2399002_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 1840, "FRAME_2399002_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the RECUR_1B frame definition. */

    lmpool_(deftxt, &c__24, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the RECUR_2 frame. */

    s_copy(deftxt, "FRAME_RECUR_2                    =  2401000", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2401000_NAME               = 'RECUR_2'", (
	    ftnlen)80, (ftnlen)44);
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
    s_copy(deftxt + 1440, "FRAME_2401000_SEC_FRAME          = 'RECUR_1'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 1520, "FRAME_2401000_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the RECUR_2 frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define a two-vector frame using a constant vector and */
/*     requiring two levels of recursion for evaluation. */


    s_copy(deftxt, "FRAME_RECUR_2B                    =  2399003", (ftnlen)80,
	     (ftnlen)44);
    s_copy(deftxt + 80, "FRAME_2399003_NAME               = 'RECUR_2B'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 160, "FRAME_2399003_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399003_CLASS_ID           =  2399003", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399003_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399003_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399003_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2399003_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2399003_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2399003_PRI_VECTOR_DEF       = 'CONSTANT'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 800, "FRAME_2399003_PRI_FRAME          = 'RECUR_1B'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 880, "FRAME_2399003_PRI_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 960, "FRAME_2399003_PRI_ABCORR         = 'XS'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 1040, "FRAME_2399003_PRI_SPEC         = 'LATITUDINAL'", (
	    ftnlen)80, (ftnlen)46);
    s_copy(deftxt + 1120, "FRAME_2399003_PRI_UNITS         = 'DEGREES'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 1200, "FRAME_2399003_PRI_LONGITUDE          =  60.0", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 1280, "FRAME_2399003_PRI_LATITUDE          = -30.0", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 1360, "FRAME_2399003_SEC_AXIS       = '-Y'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1440, "FRAME_2399003_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1520, "FRAME_2399003_SEC_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1600, "FRAME_2399003_SEC_TARGET       = 'EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 1680, "FRAME_2399003_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1760, "FRAME_2399003_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 1840, "FRAME_2399003_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the RECUR_2B frame definition. */

    lmpool_(deftxt, &c__24, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the RECUR_3 frame.  This frame is used to test */
/*     error detection when excessive recursion depth is required */
/*     to evaluate a dynamic frame. */

    s_copy(deftxt, "FRAME_RECUR_3                    =  2499000", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2499000_NAME               = 'RECUR_3'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 160, "FRAME_2499000_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2499000_CLASS_ID           =  2499000", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2499000_CENTER             =  401", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2499000_RELATIVE           = 'IAU_MARS'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 480, "FRAME_2499000_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2499000_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2499000_PRI_AXIS       = 'Z'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2499000_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(deftxt + 800, "FRAME_2499000_PRI_OBSERVER       = 'MARS'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 880, "FRAME_2499000_PRI_TARGET         = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 960, "FRAME_2499000_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 1040, "FRAME_2499000_SEC_AXIS       = '-X'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1120, "FRAME_2499000_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1200, "FRAME_2499000_SEC_OBSERVER       = 'MARS'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1280, "FRAME_2499000_SEC_TARGET       = 'SUN'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(deftxt + 1360, "FRAME_2499000_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1440, "FRAME_2499000_SEC_FRAME          = 'RECUR_2'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 1520, "FRAME_2499000_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the RECUR_3 frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the RECUR_3B frame.  This frame is used to test */
/*     error detection when excessive recursion depth is required */
/*     to evaluate a dynamic frame. */

    s_copy(deftxt, "FRAME_RECUR_3B                   =  2499001", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2499001_NAME               = 'RECUR_3B'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 160, "FRAME_2499001_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2499001_CLASS_ID           =  2499001", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2499001_CENTER             =  401", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2499001_RELATIVE           = 'IAU_MARS'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 480, "FRAME_2499001_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 560, "FRAME_2499001_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 640, "FRAME_2499001_PRI_AXIS       = 'Z'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 720, "FRAME_2499001_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(deftxt + 800, "FRAME_2499001_PRI_OBSERVER       = 'MARS'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 880, "FRAME_2499001_PRI_TARGET         = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 960, "FRAME_2499001_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 1040, "FRAME_2499001_SEC_AXIS       = '-X'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(deftxt + 1120, "FRAME_2499001_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(deftxt + 1200, "FRAME_2499001_SEC_OBSERVER       = 'MARS'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1280, "FRAME_2499001_SEC_TARGET       = 'SUN'", (ftnlen)
	    80, (ftnlen)38);
    s_copy(deftxt + 1360, "FRAME_2499001_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(deftxt + 1440, "FRAME_2499001_SEC_FRAME          = 'RECUR_2B'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 1520, "FRAME_2499001_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);

/*     Load the RECUR_3B frame definition. */

    lmpool_(deftxt, &c__20, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the EARTH_MEAN_OF_DATE frame. */

    s_copy(deftxt, "FRAME_EARTH_MEAN_OF_DATE         =  2399004", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2399004_NAME               = 'EARTH_MEAN_OF_D"
	    "ATE'", (ftnlen)80, (ftnlen)55);
    s_copy(deftxt + 160, "FRAME_2399004_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399004_CLASS_ID           =  2399004", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399004_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399004_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399004_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 560, "FRAME_2399004_FAMILY             = 'MEAN_EQUATOR_A"
	    "ND_EQUINOX_OF_DATE'", (ftnlen)80, (ftnlen)69);
    s_copy(deftxt + 640, "FRAME_2399004_PREC_MODEL   = 'EARTH_IAU_1976'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 720, "FRAME_2399004_ROTATION_STATE    = 'ROTATING'", (
	    ftnlen)80, (ftnlen)44);

/*     Load the EARTH_MEAN_OF_DATE frame definition. */

    lmpool_(deftxt, &c__10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the EARTH_TRUE_OF_DATE frame. */

    s_copy(deftxt, "FRAME_EARTH_TRUE_OF_DATE         =  2399005", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2399005_NAME               = 'EARTH_TRUE_OF_D"
	    "ATE'", (ftnlen)80, (ftnlen)55);
    s_copy(deftxt + 160, "FRAME_2399005_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2399005_CLASS_ID           =  2399005", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2399005_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2399005_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2399005_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 560, "FRAME_2399005_FAMILY             = 'TRUE_EQUATOR_A"
	    "ND_EQUINOX_OF_DATE'", (ftnlen)80, (ftnlen)69);
    s_copy(deftxt + 640, "FRAME_2399005_PREC_MODEL   = 'EARTH_IAU_1976'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 720, "FRAME_2399005_NUT_MODEL   = 'EARTH_IAU_1980'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 800, "FRAME_2399005_ROTATION_STATE    = 'ROTATING'", (
	    ftnlen)80, (ftnlen)44);

/*     Load the EARTH_TRUE_OF_DATE frame definition. */

    lmpool_(deftxt, &c__11, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the MARS_EULER frame. */

    s_copy(deftxt, "FRAME_MARS_EULER                 =  2499002", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(deftxt + 80, "FRAME_2499002_NAME               = 'MARS_EULER'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(deftxt + 160, "FRAME_2499002_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(deftxt + 240, "FRAME_2499002_CLASS_ID           =  2499002", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 320, "FRAME_2499002_CENTER             =  499", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 400, "FRAME_2499002_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 480, "FRAME_2499002_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 560, "FRAME_2499002_FAMILY             = 'EULER'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(deftxt + 640, "FRAME_2499002_EPOCH              =  @2000-NOV-23/0"
	    "4:25:00", (ftnlen)80, (ftnlen)57);
    s_copy(deftxt + 720, "FRAME_2499002_UNITS              =  'DEGREES'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 800, "FRAME_2499002_AXES               = ( 1  3  2 )", (
	    ftnlen)80, (ftnlen)46);
    s_copy(deftxt + 880, "FRAME_2499002_ANGLE_1_COEFFS     = (  1      2.D-1"
	    "0 )", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 960, "FRAME_2499002_ANGLE_2_COEFFS     = (  3      4.D-1"
	    "0 )", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 1040, "FRAME_2499002_ANGLE_3_COEFFS     = (  5      6.D-"
	    "10 )", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 1120, "FRAME_2499002_ROTATION_STATE    = 'ROTATING'", (
	    ftnlen)80, (ftnlen)44);

/*     Load the MARS_EULER frame definition. */

    lmpool_(deftxt, &c__15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Start out by checking the FRAMEX interfaces.  These */
/*     tests are of a trivial nature; their purpose is to verify */
/*     that class 5 (dynamic) frames are handled properly. */

/* --- Case: ------------------------------------------------------ */

    tcase_("Map name RECUR_2 to an ID code, and back.", (ftnlen)41);
    rc2cde = 2401000;
    namfrm_("RECUR_2", &frcode, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("FRCODE", &frcode, "=", &rc2cde, &c__0, ok, (ftnlen)6, (ftnlen)1);
    frmnam_(&rc2cde, frname, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("FRNAME", frname, "=", "RECUR_2", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up frame info for RECUR_2", (ftnlen)30);
    frinfo_(&rc2cde, &center, &class__, &clssid, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     The frame class is "dynamic."  The parameter DYN is defined */
/*     in frmtyp.inc. */

    chcksi_("CLASS", &class__, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     The class ID is just the frame ID in this case. */

    chcksi_("CLASS ID", &clssid, "=", &rc2cde, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Get the center of frame RECUR_2", (ftnlen)31);

/*     This case is quite obscure:  we're making RECUR_2 the */
/*     default frame associated with Phobos, and we want to */
/*     make sure the FRAMEX API handles this.  Note that changing */
/*     the default frame associated with a planet or satellite */
/*     is a bad idea, unless the new frame is an improved body-fixed */
/*     frame for the object in question. */

    pcpool_("OBJECT_401_FRAME", &c__1, "RECUR_2", (ftnlen)16, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the center using CIDFRM first, then CNMFRM. */

    cidfrm_(&c__401, &frcode, frname, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("FRCODE", &frcode, "=", &rc2cde, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("FRNAME", frname, "=", "RECUR_2", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)7);
    cnmfrm_("PHOBOS", &frcode, frname, &found, (ftnlen)6, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("FRCODE", &frcode, "=", &rc2cde, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("FRNAME", frname, "=", "RECUR_2", ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)7);

/*     Delete the OBJECT_401_FRAME kernel variable. */

    dvpool_("OBJECT_401_FRAME", (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now we want to perform an SXFORM test:  transform between */
/*     two frames which both require two levels of recursion */
/*     for evaluation. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SXFORM test:  create and test transformation between RECUR_2 and"
	    " RECUR_2B.", (ftnlen)74);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create the transformation matrix. */

    sxform_("RECUR_2", "RECUR_2B", &et, xform, (ftnlen)7, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create transformations from RECUR_2 to J2000 and from */
/*     J2000 to RECUR_2B.  Compose and compare to XFORM. */

    sxform_("RECUR_2", "J2000", &et, xf2, (ftnlen)7, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "RECUR_2B", &et, xf3, (ftnlen)5, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxmg_(xf3, xf2, &c__6, &c__6, &c__6, xf4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compare results. */

    chckad_("XFORM", xform, "~/", xf4, &c__36, &c_b308, ok, (ftnlen)5, (
	    ftnlen)2);

/*     Now test the SPK interfaces. */

/*     We'll test the state and corresponding position-only routines */
/*     together, to the extent possible. */

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZR/SPKPOS using the frame RECUR_2.", (ftnlen)44);

/*     For each SPK API routine, we'll verify that the SPK routine */
/*     can do the same transformation that we can do explicitly */
/*     by looking up the state relative to the J2000 frame and */
/*     then using SXFORM or PXFORM to convert the state to the */
/*     dynamic frame. */

    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compute the light time from the center of the frame RECUR_2 */
/*     to the observer.  Determine the "aberration corrected epoch" */
/*     ETCORR.  The inertial to dynamic frame transformation XFORM will */
/*     be computed at this epoch. */

    spkezr_("PHOBOS", &et, "J2000", "LT+S", "MARS", state0, &lt, (ftnlen)6, (
	    ftnlen)5, (ftnlen)4, (ftnlen)4);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("LT+S", &et, &lt, &etcorr, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "RECUR_2", &etcorr, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "RECUR_2", &etcorr, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkezr_("EARTH", &et, "RECUR_2", "LT+S", "MARS", state0, &lt, (ftnlen)5, (
	    ftnlen)7, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "RECUR_2", "LT+S", "MARS", pos0, &lt, (ftnlen)5, (
	    ftnlen)7, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkezr_("EARTH", &et, "J2000", "LT+S", "MARS", state1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "J2000", "LT+S", "MARS", pos1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKPOS. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZR/SPKPOS using the frame RECUR_2B.", (ftnlen)45);

/*     This test is a repeat of the previous one, but we use a */
/*     frame whose constant vector is defined relative to a */
/*     dynamic frame. */

    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compute the light time from the center of the frame RECUR_2 */
/*     to the observer.  Determine the "aberration corrected epoch" */
/*     ETCORR.  The inertial to dynamic frame transformation XFORM will */
/*     be computed at this epoch. */

/*     RECUR_2B is centered at the earth. */

    spkezr_("EARTH", &et, "J2000", "XLT+S", "MARS", state0, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)5, (ftnlen)4);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("XLT+S", &et, &lt, &etcorr, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "RECUR_2B", &etcorr, xform, (ftnlen)5, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "RECUR_2B", &etcorr, r__, (ftnlen)5, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkezr_("EARTH", &et, "RECUR_2B", "XLT+S", "MARS", state0, &lt, (ftnlen)5,
	     (ftnlen)8, (ftnlen)5, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "RECUR_2B", "XLT+S", "MARS", pos0, &lt, (ftnlen)5, (
	    ftnlen)8, (ftnlen)5, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkezr_("EARTH", &et, "J2000", "XLT+S", "MARS", state1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)5, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "J2000", "XLT+S", "MARS", pos1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)5, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKPOS. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/*     Exercise the code for evaluting frames of the remaining */
/*     families. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZR/SPKPOS using the frame EARTH_MEAN_OF_DATE.", (ftnlen)
	    55);

/*     Compute the light time from the center of the frame */
/*     EARTH_MEAN_OF_DATE (namely the earth) to the observer.  Determine */
/*     the "aberration corrected epoch" ETCORR.  The inertial to dynamic */
/*     frame transformation XFORM will be computed at this epoch. */

    spkezr_("EARTH", &et, "J2000", "LT", "MARS", state0, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)2, (ftnlen)4);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("LT", &et, &lt, &etcorr, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "EARTH_MEAN_OF_DATE", &etcorr, xform, (ftnlen)5, (ftnlen)
	    18);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "EARTH_MEAN_OF_DATE", &etcorr, r__, (ftnlen)5, (ftnlen)
	    18);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkezr_("EARTH", &et, "EARTH_MEAN_OF_DATE", "LT", "MARS", state0, &lt, (
	    ftnlen)5, (ftnlen)18, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "EARTH_MEAN_OF_DATE", "LT", "MARS", pos0, &lt, (
	    ftnlen)5, (ftnlen)18, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkezr_("EARTH", &et, "J2000", "LT", "MARS", state1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "J2000", "LT", "MARS", pos1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKPOS. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZR/SPKPOS using the frame EARTH_TRUE_OF_DATE.", (ftnlen)
	    55);

/*     Compute the light time from the center of the frame */
/*     EARTH_TRUE_OF_DATE (namely the earth) to the observer.  Determine */
/*     the "aberration corrected epoch" ETCORR.  The inertial to dynamic */
/*     frame transformation XFORM will be computed at this epoch. */

    spkezr_("EARTH", &et, "J2000", "LT+S", "MARS", state0, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)4, (ftnlen)4);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("LT", &et, &lt, &etcorr, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "EARTH_TRUE_OF_DATE", &etcorr, xform, (ftnlen)5, (ftnlen)
	    18);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "EARTH_TRUE_OF_DATE", &etcorr, r__, (ftnlen)5, (ftnlen)
	    18);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkezr_("EARTH", &et, "EARTH_TRUE_OF_DATE", "LT", "MARS", state0, &lt, (
	    ftnlen)5, (ftnlen)18, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "EARTH_TRUE_OF_DATE", "LT", "MARS", pos0, &lt, (
	    ftnlen)5, (ftnlen)18, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkezr_("EARTH", &et, "J2000", "LT", "MARS", state1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("EARTH", &et, "J2000", "LT", "MARS", pos1, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)2, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKPOS. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZR/SPKPOS using the frame MARS_EULER.", (ftnlen)47);

/*     Compute the light time from the center of the frame MARS_EULER to */
/*     the observer.  Determine the "aberration corrected epoch" ETCORR. */
/*     The inertial to dynamic frame transformation XFORM will be */
/*     computed at this epoch. */

    spkezr_("MARS", &et, "J2000", "CN+S", "EARTH", state0, &lt, (ftnlen)4, (
	    ftnlen)5, (ftnlen)4, (ftnlen)5);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("CN+S", &et, &lt, &etcorr, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "MARS_EULER", &etcorr, xform, (ftnlen)5, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "MARS_EULER", &etcorr, r__, (ftnlen)5, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkezr_("MARS", &et, "MARS_EULER", "CN+S", "EARTH", state0, &lt, (ftnlen)
	    4, (ftnlen)10, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("MARS", &et, "MARS_EULER", "CN+S", "EARTH", pos0, &lt, (ftnlen)4, 
	    (ftnlen)10, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state in the inertial frame, then transform to */
/*     the dynamic frame. */

    spkezr_("MARS", &et, "J2000", "CN+S", "EARTH", state1, &lt, (ftnlen)4, (
	    ftnlen)5, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("MARS", &et, "J2000", "CN+S", "EARTH", pos1, &lt, (ftnlen)4, (
	    ftnlen)5, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKPOS. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/*     Suppose we do a lookup requiring three levels of recursion? */

/* --- Case: ------------------------------------------------------ */


/*     SPKEZR:  catch error when evaluating two-vector frame */
/*     defined using velocity vector. */

    tcase_("Check SPKEZR using the frame RECUR_3. In this test, the error sh"
	    "ould be caught in routine ZZSPKEZ1.", (ftnlen)99);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkezr_("PHOBOS", &et, "RECUR_3", "LT+S", "MARS", state0, &lt, (ftnlen)6, 
	    (ftnlen)7, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */


/*     SPKPOS:  catch error when evaluating two-vector frame defined */
/*     using velocity vector. Because the error will occur when */
/*     obtaining a state vector, the error will be trapped in ZZSPKEZ1 */
/*     rather than the position-only analog ZZSPKZP1. */

    tcase_("Check SPKEZR using the frame RECUR_3. In this test, the error sh"
	    "ould be caught in routine ZZSPKEZ1.", (ftnlen)99);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("PHOBOS", &et, "RECUR_3", "LT+S", "MARS", pos0, &lt, (ftnlen)6, (
	    ftnlen)7, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/*     Make sure ZZSPKZP1 can trap the recursion error.  Note: */
/*     this case should be excluded in Icy testing. */

    zzspkzp1_(&c__401, &et, "RECUR_1", "LT+S", &c__499, pos0, &lt, (ftnlen)7, 
	    (ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */


/*     SPKEZR:  catch error when evaluating two-vector frame */
/*     defined using constant vector. */

    tcase_("Check SPKEZR using the frame RECUR_3B. In this test, the error s"
	    "hould be caught in routine ZZFRMCH1.", (ftnlen)100);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkezr_("PHOBOS", &et, "RECUR_3B", "LT+S", "MARS", state0, &lt, (ftnlen)6,
	     (ftnlen)8, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/* --- Case: ------------------------------------------------------ */

/*     SPKPOS:  catch error when evaluating two-vector frame */
/*     defined using constant vector. */

    tcase_("Check SPKPOS using the frame RECUR_3B. In this test, the error s"
	    "hould be caught in routine ZZFRMCH1.", (ftnlen)100);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkpos_("PHOBOS", &et, "RECUR_3B", "LT+S", "MARS", pos0, &lt, (ftnlen)6, (
	    ftnlen)8, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/*     Now test the rest of the SPK API routines.  We'll use just */
/*     one dynamic frame for each case, since we've already exercised */
/*     the low-level code needed to evaluate each family of dynamic */
/*     frames.  (Note, however, that we haven't covered every */
/*     possible logic branch in the low-level code---the other */
/*     dynamic frame test families are responsible for that.) */


/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKEZ/SPKEZP using the frame RECUR_1.", (ftnlen)43);

/*     Compute the light time from the center of the frame RECUR_2 */
/*     to the observer.  Determine the "aberration corrected epoch" */
/*     ETCORR.  The inertial to dynamic frame transformation XFORM will */
/*     be computed at this epoch. */

    spkezr_("EARTH", &et, "J2000", "XLT+S", "MARS", state0, &lt, (ftnlen)5, (
	    ftnlen)5, (ftnlen)5, (ftnlen)4);

/*     Compute the transformation from J2000 to the dynamic frame at */
/*     the aberration corrected epoch. */

    zzcorepc_("XLT+S", &et, &lt, &etcorr, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "RECUR_1", &etcorr, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "RECUR_1", &etcorr, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkez_(&c__399, &et, "RECUR_1", "XLT+S", &c__499, state0, &lt, (ftnlen)7, 
	    (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkezp_(&c__399, &et, "RECUR_1", "XLT+S", &c__499, pos0, &lt, (ftnlen)7, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkez_(&c__399, &et, "J2000", "XLT+S", &c__499, state1, &lt, (ftnlen)5, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkezp_(&c__399, &et, "J2000", "XLT+S", &c__499, pos1, &lt, (ftnlen)5, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKEZP. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKGEO/SPKGPS using the frame RECUR_1.", (ftnlen)44);
    sxform_("J2000", "RECUR_1", &et, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "RECUR_1", &et, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the dynamic frame. */

    spkgeo_(&c__399, &et, "RECUR_1", &c__499, state0, &lt, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkgps_(&c__399, &et, "RECUR_1", &c__499, pos0, &lt, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state and position in the inertial frame, then */
/*     transform to the dynamic frame. */

    spkgeo_(&c__399, &et, "J2000", &c__499, state1, &lt, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkgps_(&c__399, &et, "J2000", &c__499, pos1, &lt, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    mxv_(r__, pos1, pos2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check position from SPKGPS. Measure error in relative terms. We */
/*     have a slightly larger relative error here (presumably due to */
/*     implementation differences between the two computation paths), so */
/*     use a slightly larger tolerance. */

    chckad_("POS0", pos0, "~/", pos2, &c__3, &c_b308, ok, (ftnlen)4, (ftnlen)
	    2);

/*     Check SPKSSB.  Note:  there's no position-only analog of SPKSSB. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKSSB using the frame RECUR_2.", (ftnlen)37);

/*     SPKSSB computes only geometric states, so the dynamic frame */
/*     is evaluated at ET. */

    sxform_("J2000", "RECUR_2", &et, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state in the dynamic frame. */

    spkssb_(&c__399, &et, "RECUR_2", state0, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state in the inertial frame, then transform to */
/*     the dynamic frame. */

    spkssb_(&c__399, &et, "J2000", state1, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKAPP/SPKAPO using the frame RECUR_2.", (ftnlen)44);

/*     SPKAPP supports only inertial frames.  However, we want to make */
/*     sure this routine rejects dynamic frames if they're provided as */
/*     inputs. */

    spkapp_(&c__499, &et, "RECUR_2", state0, "LT+S", state1, &lt, (ftnlen)7, (
	    ftnlen)4);
    chckxc_(&c_true, "SPICE(BADFRAME)", ok, (ftnlen)15);

/*     Ditto for SPKAPO. */

    spkapo_(&c__499, &et, "RECUR_2", state0, "LT+S", pos1, &lt, (ftnlen)7, (
	    ftnlen)4);
    chckxc_(&c_true, "SPICE(BADFRAME)", ok, (ftnlen)15);

/*     Check SPKPV.  Note:  this test need not be done for Icy. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Check SPKPV using the frame RECUR_2.", (ftnlen)36);

/*     SPKPV computes only geometric states, so the dynamic frame */
/*     is evaluated at ET. */

    sxform_("J2000", "RECUR_2", &et, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state in the dynamic frame. */

    spksfs_(&c__399, &et, &han, sum, ident, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    spkpv_(&han, sum, &et, "RECUR_2", state0, &center, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state in the inertial frame, then transform to */
/*     the dynamic frame. */

    spkpv_(&han, sum, &et, "J2000", state1, &center, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/*     Check the CK interfaces. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Look up attitude of object -10001 relative to frame RECUR_2 usin"
	    "g CKGP.", (ftnlen)71);
    instid = -10001;
    clkid = -9;
    str2et_("2005 JAN 1 12:00 TDB", &et, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sce2c_(&clkid, &et, &sclkdp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up pointing relative to frame RECUR_2. */

    ckgp_(&instid, &sclkdp, &c_b802, "RECUR_2", cmat0, &clkout, &found, (
	    ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Look up pointing relative to frame J2000; convert to */
/*     pointing relative to RECUR_2. */

    ckgp_(&instid, &sclkdp, &c_b802, "J2000", cmat1, &clkout, &found, (ftnlen)
	    5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    pxform_("J2000", "RECUR_2", &et, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxmt_(cmat1, r__, cmat2);

/*     Compare C-matrices. */

    chckad_("CMAT0", cmat0, "~", cmat2, &c__9, &c_b308, ok, (ftnlen)5, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up attitude of object -10001 relative to frame RECUR_2 usin"
	    "g CKGPAV.", (ftnlen)73);

/*     Look up pointing relative to frame RECUR_2. */

    ckgpav_(&instid, &sclkdp, &c_b802, "RECUR_2", cmat0, av0, &clkout, &found,
	     (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up pointing relative to frame J2000; convert to */
/*     pointing relative to RECUR_2. */

    ckgpav_(&instid, &sclkdp, &c_b802, "J2000", cmat1, av1, &clkout, &found, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("J2000", "RECUR_2", &et, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxmt_(cmat1, r__, cmat2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compare C-matrices. */

    chckad_("CMAT0", cmat0, "~", cmat2, &c__9, &c_b308, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Compare angular velocity vectors.  To do this, we first */
/*     must find the the angular velocity of frame CK_-10001 relative */
/*     to RECUR_2, given the angular velocity of frame CK_-10001 relative */
/*     to J2000.  We start by looking up the state transformation */
/*     from RECUR_2 to J2000. */

    sxform_("RECUR_2", "J2000", &et, xform, (ftnlen)7, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the state transformation from J2000 to CK_-10001. */

    rav2xf_(cmat1, av1, xf2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the state transformation from RECUR_2 to CK_-10001. */
/*     Extract the angular velocity from this transformation. */

    mxmg_(xf2, xform, &c__6, &c__6, &c__6, xf3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xf2rav_(xf3, cmat2, av2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check AV0. */

    chckad_("AV0", av0, "~", av2, &c__3, &c_b308, ok, (ftnlen)3, (ftnlen)1);

/*     Check the PCK interfaces. */


/* --- Case: ------------------------------------------------------ */


/*     TISBOD is supposed to support only inertial base frames. */
/*     Make sure that a dynamic base frame is rejected. */

    tcase_("Look up attitude of Mars relative to frame RECUR_1 using TISBOD.",
	     (ftnlen)64);
    tisbod_("RECUR_1", &c__499, &et, xform, (ftnlen)7);
    chckxc_(&c_true, "SPICE(IRFNOTREC)", ok, (ftnlen)16);

/*     Same deal for TIPBOD. */

    tcase_("Look up attitude of Mars relative to frame RECUR_1 using TIPBOD.",
	     (ftnlen)64);
    tipbod_("RECUR_1", &c__499, &et, r__, (ftnlen)7);
    chckxc_(&c_true, "SPICE(IRFNOTREC)", ok, (ftnlen)16);

/*     Now we're going to perform tests using SPK and CK files that use */
/*     dynamic frames as base frames.  First we'll create these kernels. */
/*     We'll use the existing test utilities to do most of our work, */
/*     then we'll change some segment descriptors to make selected */
/*     segments refer to new bodies and dynamic frames. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Create an SPK for tests using dynamic base frames.", (ftnlen)50);

/*     Start with the SPK file.  Create but don't load the file. */

    tstspk_("tst_dyn2.bsp", &c_false, &handle[2], (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Locate the segment for the Jupiter barycenter; change the */
/*     descriptor to make the base frame RECUR_2.  Make the base frame */
/*     for the Saturn barycenter RECUR_2B.  Change the ID codes of the */
/*     objects at the same time, so we can compare states from the new */
/*     segments with those from the old. */

/*     Change the frame for the Uranus barycenter to RECUR_3.  This */
/*     segment should become unusable; we'll check this later. */

    dafopw_("tst_dyn2.bsp", &handle[2], (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle[2]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    while(found) {
	dafgs_(sum);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dafus_(sum, &c__2, &c__6, dc, ic);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (ic[0] == 5) {

/*           Update the descriptor. */

	    namfrm_("RECUR_2", &ic[2], (ftnlen)7);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ic[0] *= 100;
	    dafps_(&c__2, &c__6, dc, ic, sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Write the new descriptor. */

	    dafrs_(sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	} else if (ic[0] == 6) {

/*           Update the descriptor. */

	    namfrm_("RECUR_2B", &ic[2], (ftnlen)8);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ic[0] *= 100;
	    dafps_(&c__2, &c__6, dc, ic, sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Write the new descriptor. */

	    dafrs_(sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	} else if (ic[0] == 7) {

/*           Update the descriptor. */

	    namfrm_("RECUR_3", &ic[2], (ftnlen)7);
	    ic[0] *= 100;
	    dafps_(&c__2, &c__6, dc, ic, sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Write the new descriptor. */

	    dafrs_(sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
	daffna_(&found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Close the modified SPK file. */

    dafcls_(&handle[2]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up state of body 500 relative to the sun, in frame RECUR_2."
	    " Compare to state of Jupiter barycenter in frame DE-96", (ftnlen)
	    118);

/*     Load our modified SPK file. */

    spklef_("tst_dyn2.bsp", &handle[2], (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    str2et_("2005 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the state of body 500 relative to the solar system */
/*     barycenter in the dynamic frame RECUR_2. The state should match */
/*     that of the Jupiter barycenter relative to the solar system */
/*     barycenter in frame DE-96. */

    spkez_(&c__500, &et, "RECUR_2", "NONE", &c__10, state0, &lt, (ftnlen)7, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The frame DE-96 is what's used for this segment by TSTSPK. */

    spkez_(&c__5, &et, "DE-96", "NONE", &c__10, state1, &lt, (ftnlen)5, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state1, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state1[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up state of body 500 relative to  body 600 in frame RECUR_1"
	    ". ", (ftnlen)66);

/*     Look up the state of body 600 relative to the solar system */
/*     barycenter in the dynamic frame RECUR_1. The state should match */
/*     that of the Jupiter barycenter relative to the solar system */
/*     barycenter in frame DE-102. */

    spkez_(&c__600, &et, "RECUR_1", "NONE", &c__500, state0, &lt, (ftnlen)7, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the same state using the J2000 frame.  Map to */
/*     RECUR_1 and compare. */

    spkez_(&c__600, &et, "J2000", "NONE", &c__500, state1, &lt, (ftnlen)5, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "RECUR_1", &et, xform, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxvg_(xform, state1, &c__6, &c__6, state2);

/*     Check position and velocity separately.  Measure error in */
/*     relative terms. */

    chckad_("STATE0 position", state0, "~/", state2, &c__3, &c_b308, ok, (
	    ftnlen)15, (ftnlen)2);
    chckad_("STATE0 velocity", &state0[3], "~/", &state2[3], &c__3, &c_b308, 
	    ok, (ftnlen)15, (ftnlen)2);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up state of the Uranus barycenter relative to the sun, in f"
	    "rame J2000. Our Uranus barycenter segment has a dynamic base fra"
	    "me requiring three levels of recursion for evaluation.", (ftnlen)
	    182);

/*     Look up the state of body 700 relative to the solar system */
/*     barycenter in the dynamic frame RECUR_3.  We expect an error */
/*     to be signaled. */

    spkez_(&c__700, &et, "J2000", "NONE", &c__10, state0, &lt, (ftnlen)5, (
	    ftnlen)4);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/*     Now create a CK containing a segment with dynamic base */
/*     frame. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Create a CK for tests using dynamic base frames.", (ftnlen)48);

/*     Start with the CK file.  Create but don't load the file. */

    tstck3_("tst_dyn2.bc", "test_ck3.tsc", &c_false, &c_false, &c_false, &
	    handle[3], (ftnlen)11, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Locate the segment for the instrument -9901; change the descriptor */
/*     to make the base frame RECUR_2. Change the ID code of the */
/*     instrument at the same time, so we can compare pointing from the */
/*     new segments with those from the old. */

/*     Change the frame for the instrument -10000 to RECUR_3.  This */
/*     segment should become unusable; we'll check this later. */

    dafopw_("tst_dyn2.bc", &handle[3], (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    while(found) {
	dafgs_(sum);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dafus_(sum, &c__2, &c__6, dc, ic);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (ic[0] == -10001) {

/*           Update the descriptor.  For CK descriptors, the frame */
/*           ID is in the second element of the integer component. */

	    namfrm_("RECUR_2", &ic[1], (ftnlen)7);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    ic[0] += 100;
	    dafps_(&c__2, &c__6, dc, ic, sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Write the new descriptor. */

	    dafrs_(sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	} else if (ic[0] == -10000) {

/*           Update the descriptor. */

	    namfrm_("RECUR_3", &ic[1], (ftnlen)7);
	    ic[0] += 100;
	    dafps_(&c__2, &c__6, dc, ic, sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Write the new descriptor. */

	    dafrs_(sum);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
	daffna_(&found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Close the modified CK file. */

    dafcls_(&handle[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up pointing of instrument -9901 in frame RECUR_2.", (ftnlen)
	    54);

/*     Load the CK containing data of interest. */

    cklpf_("tst_dyn2.bc", &handle[3], (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the pointing and angular velocity of instrument -9901 in */
/*     the dynamic frame RECUR_2. The data should match those of the */
/*     instrument -10001 in frame J2000. */

    instid = -9901;
    clkid = -9;
    str2et_("2005 JAN 1 12:00 TDB", &et, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sce2c_(&clkid, &et, &sclkdp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up pointing relative to frame RECUR_2. */

    ckgpav_(&instid, &sclkdp, &c_b802, "RECUR_2", cmat0, av0, &clkout, &found,
	     (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("-9901 FOUND", &found, &c_true, ok, (ftnlen)11);

/*     Look up the same data for instrument -10001 using the */
/*     J2000 frame (base frame for instrument -10001). */
/*     Compare. */

    ckgpav_(&c_b1032, &sclkdp, &c_b802, "J2000", cmat1, av1, &clkout, &found, 
	    (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("-10001 FOUND", &found, &c_true, ok, (ftnlen)12);

/*     Compare C-matrices. */

    chckad_("CMAT0", cmat0, "~", cmat1, &c__9, &c_b308, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Compare angular velocity vectors. */

    chckad_("AV0", av0, "~", av1, &c__3, &c_b308, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up pointing of instrument -9901 in frame J2000.  This force"
	    "s the CK subsystem to do a dynamic frame transformation.", (
	    ftnlen)120);

/*     Load the CK containing data of interest. */

    cklpf_("tst_dyn2.bc", &handle[3], (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up the pointing and angular velocity of instrument -9901 in */
/*     the dynamic frame J2000.  The data should match those of the */
/*     instrument -10001 after the RECUR_2 to J2000 state transformation */
/*     is applied. */

    instid = -9901;
    clkid = -9;
    str2et_("2005 JAN 1 12:00 TDB", &et, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sce2c_(&clkid, &et, &sclkdp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up pointing relative to frame J2000. */

    ckgpav_(&instid, &sclkdp, &c_b802, "J2000", cmat0, av0, &clkout, &found, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("-9901 FOUND", &found, &c_true, ok, (ftnlen)11);

/*     Look up the same data for instrument -10001 using the */
/*     J2000 frame (base frame for instrument -10001). */
/*     Compare. */

    ckgpav_(&c_b1032, &sclkdp, &c_b802, "J2000", cmat1, av1, &clkout, &found, 
	    (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("-10001 FOUND", &found, &c_true, ok, (ftnlen)12);

/*     Get the  J2000 to RECUR_2 position transformation matrix. */
/*     Right-multiply CMAT1 by this. */

    pxform_("J2000", "RECUR_2", &et, r__, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxm_(cmat1, r__, cmat2);

/*     Compare C-matrices. */

    chckad_("CMAT0", cmat0, "~", cmat2, &c__9, &c_b308, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Compare angular velocity vectors. To simplify the computations, */
/*     we'll work with state transformations. Construct the J2000 to */
/*     CK_-10001 state transformation XF2 from the corresponding */
/*     C-matrix and angular velocity vector. Right-multiply this by the */
/*     J2000 to RECUR_2 state transformation XF3. This should yield a */
/*     transformation XF4 equivalent to XFORM, since XFORM was */
/*     effectively created by the same right-multiplication of the state */
/*     transformation matrix mapping RECUR_2 to CK_-9901.  The angular */
/*     velocity vector AV2 extracted from XF4 can then be compared to */
/*     the original angular velocity vector AV0. */

    rav2xf_(cmat1, av1, xf2);
    sxform_("J2000", "RECUR_2", &et, xf3, (ftnlen)5, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxmg_(xf2, xf3, &c__6, &c__6, &c__6, xf4);

/*     Extract angular velocity from XF4. */

    xf2rav_(xf4, cmat2, av2);

/*     Check AV0. */

    chckad_("AV0", av0, "~", av2, &c__3, &c_b308, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Look up pointing of instrument -9900 in frame J2000.  The segmen"
	    "t for -9900 has a dynamic base frame requiring three levels of r"
	    "ecursion for evaluation.", (ftnlen)152);

/*     Look up the state of body 700 relative to the solar system */
/*     barycenter in the dynamic frame RECUR_3.  We expect an error */
/*     to be signaled. */

    ckgpav_(&c_n9900, &sclkdp, &c_b802, "J2000", cmat0, av0, &clkout, &found, 
	    (ftnlen)5);
    chckxc_(&c_true, "SPICE(RECURSIONTOODEEP)", ok, (ftnlen)23);

/*     End of test cases. */


/*     Clean up the SPK and CK files. */

    spkuef_(handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test_dyn.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckupf_(&handle[1]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test_ck3.bc", (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkuef_(&handle[2]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("tst_dyn2.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckupf_(&handle[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("tst_dyn2.bc", (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dyn05__ */

