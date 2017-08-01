/* f_dyn07.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__2 = 2;
static doublereal c_b50 = 1e6;

/* $Procedure F_DYN07 ( Dynamic Frame Test Family 07 ) */
/* Subroutine */ int f_dyn07__(logical *ok)
{
    /* System generated locals */
    address a__1[2];
    integer i__1, i__2, i__3[2], i__4;
    char ch__1[114], ch__2[128], ch__3[124], ch__4[120], ch__5[134], ch__6[
	    130];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), i_indx(char *, char *, 
	    ftnlen, ftnlen);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    integer i__, j;
    doublereal r__[9]	/* was [3][3] */;
    extern /* Subroutine */ int tcase_(char *, ftnlen), movec_(char *, 
	    integer *, char *, ftnlen, ftnlen), topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int t_success__(logical *);
    char deftx2[80*50];
    integer handle, dx;
    extern /* Subroutine */ int delfil_(char *, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), t_pck08__(char *, logical *, logical *
	    , ftnlen), spkuef_(integer *);
    char errmsg[1840], gsetxt[80*50], gsmtxt[80*50], keywrd[80], martxt[80*50]
	    , mcqtxt[80*50], mqqtxt[80*50];
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen), lmpool_(char *, integer *, ftnlen), dvpool_(
	    char *, ftnlen);
    char tqqtxt[80*50];
    extern /* Subroutine */ int sxform_(char *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen), pxform_(char *, char *, doublereal 
	    *, doublereal *, ftnlen, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code used to handle */
/*     frame kernel errors. */

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


/*     Include File:  SPICELIB Error Handling Parameters */

/*        errhnd.inc  Version 2    18-JUN-1997 (WLT) */

/*           The size of the long error message was */
/*           reduced from 25*80 to 23*80 so that it */
/*           will be accepted by the Microsoft Power Station */
/*           FORTRAN compiler which has an upper bound */
/*           of 1900 for the length of a character string. */

/*        errhnd.inc  Version 1    29-JUL-1997 (NJB) */



/*     Maximum length of the long error message: */


/*     Maximum length of the short error message: */


/*     End Include File:  SPICELIB Error Handling Parameters */

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

/*     None. */

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


/*     Parameters controlling frame definitions: */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Open the test family. */

    topen_("F_DYN07", (ftnlen)7);
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     TWO-VECTOR CASES */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("Create and load kernels.", (ftnlen)24);

/*     Create and load kernels. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("test_dyn.bsp", &c_true, &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_pck08__("test_dyn.tpc", &c_true, &c_false, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define the GSE frame. */

    s_copy(gsetxt, "FRAME_GSE                        =  2399001", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(gsetxt + 80, "FRAME_2399001_NAME               = 'GSE'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(gsetxt + 160, "FRAME_2399001_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(gsetxt + 240, "FRAME_2399001_CLASS_ID           =  2399001", (
	    ftnlen)80, (ftnlen)43);
    s_copy(gsetxt + 320, "FRAME_2399001_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(gsetxt + 400, "FRAME_2399001_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsetxt + 480, "FRAME_2399001_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsetxt + 560, "FRAME_2399001_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsetxt + 640, "FRAME_2399001_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(gsetxt + 720, "FRAME_2399001_PRI_VECTOR_DEF       = 'OBSERVER_TAR"
	    "GET_POSITION'", (ftnlen)80, (ftnlen)63);
    s_copy(gsetxt + 800, "FRAME_2399001_PRI_OBSERVER       = 'EARTH'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsetxt + 880, "FRAME_2399001_PRI_TARGET         = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(gsetxt + 960, "FRAME_2399001_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(gsetxt + 1040, "FRAME_2399001_SEC_AXIS       = '-Y'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(gsetxt + 1120, "FRAME_2399001_SEC_VECTOR_DEF       =  'OBSERVER_T"
	    "ARGET_VELOCITY'", (ftnlen)80, (ftnlen)64);
    s_copy(gsetxt + 1200, "FRAME_2399001_SEC_OBSERVER       = 'SUN'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(gsetxt + 1280, "FRAME_2399001_SEC_TARGET       = 'EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(gsetxt + 1360, "FRAME_2399001_SEC_ABCORR         = 'NONE'", (
	    ftnlen)80, (ftnlen)41);
    s_copy(gsetxt + 1440, "FRAME_2399001_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsetxt + 1520, "FRAME_2399001_ANGLE_SEP_TOL       =  1.E-04", (
	    ftnlen)80, (ftnlen)43);
    s_copy(gsetxt + 1600, "FRAME_2399001_ROTATION_STATE       =  'ROTATING'", 
	    (ftnlen)80, (ftnlen)48);
    dx = 21;

/* --- Case: ------------------------------------------------------ */

    tcase_("Check handling of missing keywords in GSE (two-vector) frame def"
	    "inition.", (ftnlen)72);

/*     First set of tests:  delete required variables from the GSE */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the GSE frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the GSE definition. */

	movec_(gsetxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)276)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)277)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified GSE frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "GSE SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try an SXFORM call. */

	sxform_("GSE", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	if (i__ < dx && i__ != 20) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION STATE keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "GSE PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try a PXFORM call. */

	pxform_("GSE", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	if (i__ < dx && i__ != 20) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION STATE keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     GSE definition.  Make sure we get the expected error messages */
/*     when we refer to the GSE frame in an SXFORM or PXFORM call. We */
/*     currently restrict the testing to the keywords applicable to */
/*     dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the GSE definition. */

	movec_(gsetxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)353)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)355)) * 80, (
		ftnlen)80, j - 1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 48, a__1[0] = "GSE SXFORM case: Changing RHS value for key"
		"word ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__2, a__1, i__3, &c__2, (ftnlen)128);
	tcase_(ch__2, (ftnlen)128);
	i__4 = j;
	s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : s_rnge(
		"deftx2", i__2, "f_dyn07__", (ftnlen)364)) * 80 + i__4), 
		"'ABC'", 80 - i__4, (ftnlen)5);

/*        Load the modified GSE frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Handle body name errors. */

	if (i_indx(keywrd, "TARGET", (ftnlen)80, (ftnlen)6) > 0 || i_indx(
		keywrd, "OBSERVER", (ftnlen)80, (ftnlen)8) > 0) {
	    s_copy(errmsg, "SPICE(NOTRANSLATION)", (ftnlen)1840, (ftnlen)20);
	}

/*        Handle aberration correction errors. */

	if (i_indx(keywrd, "ABCORR", (ftnlen)80, (ftnlen)6) > 0) {
	    s_copy(errmsg, "SPICE(SPKINVALIDOPTION)", (ftnlen)1840, (ftnlen)
		    23);
	}

/*        Handle axis name errors. */

	if (i_indx(keywrd, "AXIS", (ftnlen)80, (ftnlen)4) > 0) {
	    s_copy(errmsg, "SPICE(INVALIDAXIS)", (ftnlen)1840, (ftnlen)18);
	}

/*        Handle velocity frame name errors.  (Careful, the */
/*        substring 'FRAME' is at the start of each keyword.) */

	if (i_indx(keywrd, "_FRAME", (ftnlen)80, (ftnlen)6) > 0) {
	    s_copy(errmsg, "SPICE(NOTRANSLATION)", (ftnlen)1840, (ftnlen)20);
	}

/*        Handle minimum anglular separation errors. */

	if (i_indx(keywrd, "ANGLE_SEP_TOL", (ftnlen)80, (ftnlen)13) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Try an SXFORM call. */

	sxform_("GSE", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 44, a__1[0] = "GSE PXFORM case: changing value for keyword "
		;
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__3, a__1, i__3, &c__2, (ftnlen)124);
	tcase_(ch__3, (ftnlen)124);

/*        Try a PXFORM call. */

	pxform_("GSE", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     TWO-VECTOR CASE:  GSM */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/*     Define the GSM frame. */

    s_copy(gsmtxt, "FRAME_GSM                        =  2399002", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(gsmtxt + 80, "FRAME_2399002_NAME               = 'GSM'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(gsmtxt + 160, "FRAME_2399002_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(gsmtxt + 240, "FRAME_2399002_CLASS_ID           =  2399002", (
	    ftnlen)80, (ftnlen)43);
    s_copy(gsmtxt + 320, "FRAME_2399002_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(gsmtxt + 400, "FRAME_2399002_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsmtxt + 480, "FRAME_2399002_DEF_STYLE       = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsmtxt + 560, "FRAME_2399002_FAMILY             = 'TWO-VECTOR'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsmtxt + 640, "FRAME_2399002_PRI_AXIS       = 'X'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(gsmtxt + 720, "FRAME_2399002_PRI_VECTOR_DEF       =  'OBSERVER_TA"
	    "RGET_POSITION'", (ftnlen)80, (ftnlen)64);
    s_copy(gsmtxt + 800, "FRAME_2399002_PRI_OBSERVER       = 'EARTH'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsmtxt + 880, "FRAME_2399002_PRI_TARGET       = 'SUN'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(gsmtxt + 960, "FRAME_2399002_PRI_ABCORR         = 'NONE'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(gsmtxt + 1040, "FRAME_2399002_SEC_AXIS       = 'Z'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(gsmtxt + 1120, "FRAME_2399002_SEC_VECTOR_DEF       = 'CONSTANT'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsmtxt + 1200, "FRAME_2399002_SEC_SPEC         = 'LATITUDINAL'", (
	    ftnlen)80, (ftnlen)46);
    s_copy(gsmtxt + 1280, "FRAME_2399002_SEC_UNITS         = 'DEGREES'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(gsmtxt + 1360, "FRAME_2399002_SEC_LONGITUDE          =   288.43", (
	    ftnlen)80, (ftnlen)47);
    s_copy(gsmtxt + 1440, "FRAME_2399002_SEC_LATITUDE          =    79.54", (
	    ftnlen)80, (ftnlen)46);
    s_copy(gsmtxt + 1520, "FRAME_2399002_SEC_FRAME          = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(gsmtxt + 1600, "FRAME_2399002_ANGLE_SEP_TOL       =  1.E-4", (
	    ftnlen)80, (ftnlen)42);
    dx = 21;

/* --- Case: ------------------------------------------------------ */

    tcase_("Check handling of missing keywords in GSM (two-vector) frame def"
	    "inition.", (ftnlen)72);

/*     First set of tests:  delete required variables from the GSM */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the GSM frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the GSM definition. */

	movec_(gsmtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)526)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)527)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified GSM frame definition.  We don't */
/*        want to clear the kernel pool here because we'd have */
/*        to keep re-loading the PCK. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "GSM SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try an SXFORM call. */

	sxform_("GSM", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	if (i__ < dx && i__ != 21) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The MIN_ANG_SEP keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "GSM PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try a PXFORM call. */

	pxform_("GSM", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	if (i__ < dx && i__ != 21) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The MIN_ANG_SEP keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     GSM definition.  Make sure we get the expected error messages */
/*     when we refer to the GSM frame in an SXFORM or PXFORM call. We */
/*     currently restrict the testing to the keywords applicable to */
/*     dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the GSM definition. */

	movec_(gsmtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)606)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)608)) * 80, (
		ftnlen)80, j - 1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 48, a__1[0] = "GSM SXFORM case: Changing RHS value for key"
		"word ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__2, a__1, i__3, &c__2, (ftnlen)128);
	tcase_(ch__2, (ftnlen)128);
	i__4 = j;
	s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : s_rnge(
		"deftx2", i__2, "f_dyn07__", (ftnlen)615)) * 80 + i__4), 
		"'ABC'", 80 - i__4, (ftnlen)5);

/*        Load the modified GSM frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Handle body name errors. */

	if (i_indx(keywrd, "TARGET", (ftnlen)80, (ftnlen)6) > 0 || i_indx(
		keywrd, "OBSERVER", (ftnlen)80, (ftnlen)8) > 0) {
	    s_copy(errmsg, "SPICE(NOTRANSLATION)", (ftnlen)1840, (ftnlen)20);
	}

/*        Handle aberration correction errors. */

	if (i_indx(keywrd, "ABCORR", (ftnlen)80, (ftnlen)6) > 0) {
	    s_copy(errmsg, "SPICE(SPKINVALIDOPTION)", (ftnlen)1840, (ftnlen)
		    23);
	}

/*        Handle axis name errors. */

	if (i_indx(keywrd, "AXIS", (ftnlen)80, (ftnlen)4) > 0) {
	    s_copy(errmsg, "SPICE(INVALIDAXIS)", (ftnlen)1840, (ftnlen)18);
	}

/*        Handle constant frame name errors. */

	if (i_indx(keywrd, "_FRAME", (ftnlen)80, (ftnlen)6) > 0) {
	    s_copy(errmsg, "SPICE(NOTRANSLATION)", (ftnlen)1840, (ftnlen)20);
	}

/*        Handle minimum anglular separation errors. */

	if (i_indx(keywrd, "ANGLE_SEP_TOL", (ftnlen)80, (ftnlen)13) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Handle latitude and longitude errors. */

	if (i_indx(keywrd, "LATITUDE", (ftnlen)80, (ftnlen)8) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}
	if (i_indx(keywrd, "LONGITUDE", (ftnlen)80, (ftnlen)9) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Handle unit errors. */

	if (i_indx(keywrd, "UNITS", (ftnlen)80, (ftnlen)5) > 0) {
	    s_copy(errmsg, "SPICE(UNITSNOTREC)", (ftnlen)1840, (ftnlen)18);
	}

/*        Try an SXFORM call. */

	sxform_("GSM", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 44, a__1[0] = "GSM PXFORM case: changing value for keyword "
		;
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__3, a__1, i__3, &c__2, (ftnlen)124);
	tcase_(ch__3, (ftnlen)124);

/*        Try a PXFORM call. */

	pxform_("GSM", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     MEAN EQUATOR AND EQUINOX OF DATE CASES */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/*     First set of tests:  delete required variables from the MQQ */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the MQQ frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    s_copy(mqqtxt, "FRAME_MQQ                        =  2399003", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(mqqtxt + 80, "FRAME_2399003_NAME               = 'MQQ'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(mqqtxt + 160, "FRAME_2399003_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(mqqtxt + 240, "FRAME_2399003_CLASS_ID           =  2399003", (
	    ftnlen)80, (ftnlen)43);
    s_copy(mqqtxt + 320, "FRAME_2399003_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(mqqtxt + 400, "FRAME_2399003_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(mqqtxt + 480, "FRAME_2399003_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(mqqtxt + 560, "FRAME_2399003_FAMILY             = 'MEAN_EQUATOR_A"
	    "ND_EQUINOX_OF_DATE'", (ftnlen)80, (ftnlen)69);
    s_copy(mqqtxt + 640, "FRAME_2399003_PREC_MODEL   = 'EARTH_IAU_1976'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(mqqtxt + 720, "FRAME_2399003_ROTATION_STATE    = 'ROTATING'", (
	    ftnlen)80, (ftnlen)44);
    dx = 10;
    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the MQQ definition. */

	movec_(mqqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)766)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)767)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified MQQ frame definition.  We don't */
/*        want to clear the kernel pool here because we'd have */
/*        to keep re-loading the PCK. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "MQQ SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try an SXFORM call. */

	sxform_("MQQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword or the FREEZE_EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "MQQ PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try a PXFORM call. */

	pxform_("MQQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword or the FREEZE_EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     MQQ definition.  Make sure we get the expected error messages */
/*     when we refer to the MQQ frame in an SXFORM or PXFORM call. We */
/*     currently restrict the testing to the keywords applicable to */
/*     dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the MQQ definition. */

	movec_(mqqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)848)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)850)) * 80, (
		ftnlen)80, j - 1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 48, a__1[0] = "MQQ SXFORM case: Changing RHS value for key"
		"word ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__2, a__1, i__3, &c__2, (ftnlen)128);
	tcase_(ch__2, (ftnlen)128);
	i__4 = j;
	s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : s_rnge(
		"deftx2", i__2, "f_dyn07__", (ftnlen)857)) * 80 + i__4), 
		"'ABC'", 80 - i__4, (ftnlen)5);

/*        Load the modified MQQ frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Try an SXFORM call. */

	sxform_("MQQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 44, a__1[0] = "MQQ PXFORM case: changing value for keyword "
		;
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__3, a__1, i__3, &c__2, (ftnlen)124);
	tcase_(ch__3, (ftnlen)124);

/*        Try a PXFORM call. */

	pxform_("MQQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     TRUE EQUATOR AND EQUINOX OF DATE CASES */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/*     First set of tests:  delete required variables from the TQQ */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the TQQ frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    s_copy(tqqtxt, "FRAME_TQQ                        =  2399004", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(tqqtxt + 80, "FRAME_2399004_NAME               = 'TQQ'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(tqqtxt + 160, "FRAME_2399004_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(tqqtxt + 240, "FRAME_2399004_CLASS_ID           =  2399004", (
	    ftnlen)80, (ftnlen)43);
    s_copy(tqqtxt + 320, "FRAME_2399004_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(tqqtxt + 400, "FRAME_2399004_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(tqqtxt + 480, "FRAME_2399004_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(tqqtxt + 560, "FRAME_2399004_FAMILY             = 'TRUE_EQUATOR_A"
	    "ND_EQUINOX_OF_DATE'", (ftnlen)80, (ftnlen)69);
    s_copy(tqqtxt + 640, "FRAME_2399004_PREC_MODEL   = 'EARTH_IAU_1976'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(tqqtxt + 720, "FRAME_2399004_NUT_MODEL   = 'EARTH_IAU_1980'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(tqqtxt + 800, "FRAME_2399004_ROTATION_STATE    = 'INERTIAL'", (
	    ftnlen)80, (ftnlen)44);
    dx = 11;
    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the TQQ definition. */

	movec_(tqqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)948)) * 80, "=", (
		ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)949)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified TQQ frame definition.  We don't */
/*        want to clear the kernel pool here because we'd have */
/*        to keep re-loading the PCK. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "TQQ SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try an SXFORM call. */

	sxform_("TQQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION STATE keyword or the FREEZE EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "TQQ PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try a PXFORM call. */

	pxform_("TQQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword or the FREEZE_EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     TQQ definition.  Make sure we get the expected error messages */
/*     when we refer to the TQQ frame in an SXFORM or PXFORM call. We */
/*     currently restrict the testing to the keywords applicable to */
/*     dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the TQQ definition. */

	movec_(tqqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1030)) * 80, 
		"=", (ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1032)) * 80, (
		ftnlen)80, j - 1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 48, a__1[0] = "TQQ SXFORM case: Changing RHS value for key"
		"word ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__2, a__1, i__3, &c__2, (ftnlen)128);
	tcase_(ch__2, (ftnlen)128);
	i__4 = j;
	s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : s_rnge(
		"deftx2", i__2, "f_dyn07__", (ftnlen)1039)) * 80 + i__4), 
		"'ABC'", 80 - i__4, (ftnlen)5);

/*        Load the modified TQQ frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Try an SXFORM call. */

	sxform_("TQQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 44, a__1[0] = "TQQ PXFORM case: changing value for keyword "
		;
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__3, a__1, i__3, &c__2, (ftnlen)124);
	tcase_(ch__3, (ftnlen)124);

/*        Try a PXFORM call. */

	pxform_("TQQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     MEAN ECLIPTIC AND EQUINOX OF DATE CASES */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/*     First set of tests:  delete required variables from the MCQ */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the MCQ frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    s_copy(mcqtxt, "FRAME_MCQ                        =  2399005", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(mcqtxt + 80, "FRAME_2399005_NAME               = 'MCQ'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(mcqtxt + 160, "FRAME_2399005_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(mcqtxt + 240, "FRAME_2399005_CLASS_ID           =  2399005", (
	    ftnlen)80, (ftnlen)43);
    s_copy(mcqtxt + 320, "FRAME_2399005_CENTER             =  399", (ftnlen)
	    80, (ftnlen)39);
    s_copy(mcqtxt + 400, "FRAME_2399005_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(mcqtxt + 480, "FRAME_2399005_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(mcqtxt + 560, "FRAME_2399005_FAMILY             = 'MEAN_ECLIPTIC_"
	    "AND_EQUINOX_OF_DATE'", (ftnlen)80, (ftnlen)70);
    s_copy(mcqtxt + 640, "FRAME_2399005_PREC_MODEL  = 'EARTH_IAU_1976'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(mcqtxt + 720, "FRAME_2399005_OBLIQ_MODEL    = 'EARTH_IAU_1980'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(mcqtxt + 800, "FRAME_2399005_FREEZE_EPOCH       = @2005-JAN-1/00:"
	    "00:00", (ftnlen)80, (ftnlen)55);
    dx = 11;
    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the MCQ definition. */

	movec_(mcqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1128)) * 80, 
		"=", (ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1129)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified MCQ frame definition.  We don't */
/*        want to clear the kernel pool here because we'd have */
/*        to keep re-loading the PCK. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "MCQ SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try an SXFORM call. */

	sxform_("MCQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword or the FREEZE_EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 34, a__1[0] = "MCQ PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)114);
	tcase_(ch__1, (ftnlen)114);

/*        Try a PXFORM call. */

	pxform_("MCQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION STATE keyword or the FREEZE EPOCH keyword */
/*           must be present. */

	    chckxc_(&c_true, "SPICE(FRAMEDEFERROR)", ok, (ftnlen)20);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     MCQ definition.  Make sure we get the expected error messages */
/*     when we refer to the MCQ frame in an SXFORM or PXFORM call. We */
/*     currently restrict the testing to the keywords applicable to */
/*     dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the MCQ definition. */

	movec_(mcqtxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1210)) * 80, 
		"=", (ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1212)) * 80, (
		ftnlen)80, j - 1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 48, a__1[0] = "MCQ SXFORM case: Changing RHS value for key"
		"word ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__2, a__1, i__3, &c__2, (ftnlen)128);
	tcase_(ch__2, (ftnlen)128);
	i__4 = j;
	s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : s_rnge(
		"deftx2", i__2, "f_dyn07__", (ftnlen)1219)) * 80 + i__4), 
		"'ABC'", 80 - i__4, (ftnlen)5);

/*        Load the modified MCQ frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Handle freeze epoch errors. */

	if (i_indx(keywrd, "FREEZE_EPOCH", (ftnlen)80, (ftnlen)12) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Try an SXFORM call. */

	sxform_("MCQ", "J2000", &c_b50, xform, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 44, a__1[0] = "MCQ PXFORM case: changing value for keyword "
		;
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__3, a__1, i__3, &c__2, (ftnlen)124);
	tcase_(ch__3, (ftnlen)124);

/*        Try a PXFORM call. */

	pxform_("MCQ", "J2000", &c_b50, r__, (ftnlen)3, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */
/*     EULER FRAME CASES */
/* ************************************************************** */
/* ************************************************************** */
/* ************************************************************** */

/*     Define the pseudo IAU_MARS frame. */

    s_copy(martxt, "FRAME_IAU_MARS2                  =  2499000", (ftnlen)80, 
	    (ftnlen)43);
    s_copy(martxt + 80, "FRAME_2499000_NAME               = 'IAU_MARS2'", (
	    ftnlen)80, (ftnlen)46);
    s_copy(martxt + 160, "FRAME_2499000_CLASS              =  5", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(martxt + 240, "FRAME_2499000_CLASS_ID           =  2499000", (
	    ftnlen)80, (ftnlen)43);
    s_copy(martxt + 320, "FRAME_2499000_CENTER             =  499", (ftnlen)
	    80, (ftnlen)39);
    s_copy(martxt + 400, "FRAME_2499000_RELATIVE           = 'J2000'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(martxt + 480, "FRAME_2499000_DEF_STYLE   = 'PARAMETERIZED'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(martxt + 560, "FRAME_2499000_FAMILY             = 'EULER'", (
	    ftnlen)80, (ftnlen)42);
    s_copy(martxt + 640, "FRAME_2499000_EPOCH              =  @2000-JAN-1/12"
	    ":00", (ftnlen)80, (ftnlen)53);
    s_copy(martxt + 720, "FRAME_2499000_AXES               = ( 3  1  3 )", (
	    ftnlen)80, (ftnlen)46);
    s_copy(martxt + 800, "FRAME_2499000_ANGLE_1_COEFFS     = ( -47.68143 0.3"
	    "3621061170684714E-10 )", (ftnlen)80, (ftnlen)72);
    s_copy(martxt + 880, "FRAME_2499000_ANGLE_2_COEFFS     = ( -37.1135 -0.1"
	    "9298045478743630E-10 )", (ftnlen)80, (ftnlen)72);
    s_copy(martxt + 960, "FRAME_2499000_ANGLE_3_COEFFS     = (-176.630  -0.4"
	    "0612497946759260E-02 )", (ftnlen)80, (ftnlen)72);
    s_copy(martxt + 1040, "FRAME_2499000_UNITS              =  'DEGREES'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(martxt + 1120, "FRAME_2499000_ROTATION_STATE    = 'ROTATING'", (
	    ftnlen)80, (ftnlen)44);
    dx = 15;

/* --- Case: ------------------------------------------------------ */

    tcase_("Check handling of missing keywords in IAU_MARS2 (Euler) frame de"
	    "finition.", (ftnlen)73);

/*     First set of tests:  delete required variables from the GSE */
/*     definition.  Make sure we get the expected error messages */
/*     when we refer to the GSE frame in an SXFORM or PXFORM call. */
/*     We currently restrict the testing to the keywords applicable */
/*     to dynamic frames.  These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/*        Make a copy of the IAU_MARS2 definition. */

	movec_(martxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);

/*        Lose the Ith element of the definition. */

	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1333)) * 80, 
		"=", (ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1334)) * 80, (
		ftnlen)80, j - 1);


/*        Load the modified IAU_MARS2 frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Delete the Ith element of the frame definition from */
/*        the kernel pool. */

	dvpool_(keywrd, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 40, a__1[0] = "IAU_MARS2 SXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__4, a__1, i__3, &c__2, (ftnlen)120);
	tcase_(ch__4, (ftnlen)120);

/*        Try an SXFORM call. */

	sxform_("IAU_MARS2", "J2000", &c_b50, xform, (ftnlen)9, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 40, a__1[0] = "IAU_MARS2 PXFORM case: deleting keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__4, a__1, i__3, &c__2, (ftnlen)120);
	tcase_(ch__4, (ftnlen)120);

/*        Try a PXFORM call. */

	pxform_("IAU_MARS2", "J2000", &c_b50, r__, (ftnlen)9, (ftnlen)5);
	if (i__ < dx) {

/*           We've deleted a required keyword. */

	    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
	} else {

/*           The ROTATION_STATE keyword is optional. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }

/*     Second set of tests:  assign bogus values to variables from the */
/*     IAU_MARS2 definition. Make sure we get the expected error */
/*     messages when we refer to the IAU_MARS2 frame in an SXFORM or */
/*     PXFORM call. We currently restrict the testing to the keywords */
/*     applicable to dynamic frames. These are keywords 7 through DX. */

    i__1 = dx;
    for (i__ = 7; i__ <= i__1; ++i__) {

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 54, a__1[0] = "IAU_MARS2 SXFORM case: Changing RHS value f"
		"or keyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__5, a__1, i__3, &c__2, (ftnlen)134);
	tcase_(ch__5, (ftnlen)134);

/*        Make a copy of the IAU_MARS2 definition. */

	movec_(martxt, &dx, deftx2, (ftnlen)80, (ftnlen)80);
	j = i_indx(deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1418)) * 80, 
		"=", (ftnlen)80, (ftnlen)1);
	s_copy(keywrd, deftx2 + ((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1420)) * 80, (
		ftnlen)80, j - 1);
	if (eqstr_(keywrd, "FRAME_2499000_AXES", (ftnlen)80, (ftnlen)18)) {
	    i__4 = j;
	    s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		    s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1424)) * 80 + 
		    i__4), "( 1, 0, 1 )", 80 - i__4, (ftnlen)11);
	} else if (eqstr_(keywrd, "FRAME_2499000_EPOCH", (ftnlen)80, (ftnlen)
		19)) {
	    i__4 = j;
	    s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		    s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1428)) * 80 + 
		    i__4), "@2004-ABC/12:00:00", 80 - i__4, (ftnlen)18);
	} else {
	    i__4 = j;
	    s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		    s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1431)) * 80 + 
		    i__4), "'ABC'", 80 - i__4, (ftnlen)5);
	}

/*        Load the modified IAU_MARS2 frame definition. */

	lmpool_(deftx2, &dx, (ftnlen)80);
	if (eqstr_(keywrd, "FRAME_2499000_EPOCH", (ftnlen)80, (ftnlen)19)) {

/*           LMPOOL catches malformed time tokens of the form @*. */

	    s_copy(errmsg, "SPICE(BADTIMESPEC)", (ftnlen)1840, (ftnlen)18);
	    chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/*           Re-set the time token to a string not recognized */
/*           as a time token. */

	    i__4 = j;
	    s_copy(deftx2 + (((i__2 = i__ - 1) < 50 && 0 <= i__2 ? i__2 : 
		    s_rnge("deftx2", i__2, "f_dyn07__", (ftnlen)1451)) * 80 + 
		    i__4), "'ABC'", 80 - i__4, (ftnlen)5);
	    lmpool_(deftx2, &dx, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	} else {
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/*        Set the expected error message resulting from an SXFORM */
/*        call relying on this frame definition. */

/*        Start with the most common error message. */

	s_copy(errmsg, "SPICE(NOTSUPPORTED)", (ftnlen)1840, (ftnlen)19);

/*        Handle epoch errors. */

	if (i_indx(keywrd, "EPOCH", (ftnlen)80, (ftnlen)5) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Handle units errors. */

	if (i_indx(keywrd, "UNITS", (ftnlen)80, (ftnlen)5) > 0) {
	    s_copy(errmsg, "SPICE(UNITSNOTREC)", (ftnlen)1840, (ftnlen)18);
	}

/*        Handle axis sequence errors. */

	if (i_indx(keywrd, "AXES", (ftnlen)80, (ftnlen)4) > 0) {
	    s_copy(errmsg, "SPICE(BADAXISNUMBERS)", (ftnlen)1840, (ftnlen)21);
	}

/*        Handle angle 1 coefficient errors. */

	if (i_indx(keywrd, "ANGLE_1_COEFFS", (ftnlen)80, (ftnlen)14) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Handle angle 2 coefficient errors. */

	if (i_indx(keywrd, "ANGLE_2_COEFFS", (ftnlen)80, (ftnlen)14) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Handle angle 3 coefficient errors. */

	if (i_indx(keywrd, "ANGLE_3_COEFFS", (ftnlen)80, (ftnlen)14) > 0) {
	    s_copy(errmsg, "SPICE(BADVARIABLETYPE)", (ftnlen)1840, (ftnlen)22)
		    ;
	}

/*        Try an SXFORM call. */

	sxform_("IAU_MARS2", "J2000", &c_b50, xform, (ftnlen)9, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);

/* --- Case: ------------------------------------------------------ */

/* Writing concatenation */
	i__3[0] = 50, a__1[0] = "IAU_MARS2 PXFORM case: changing value for k"
		"eyword ";
	i__3[1] = 80, a__1[1] = keywrd;
	s_cat(ch__6, a__1, i__3, &c__2, (ftnlen)130);
	tcase_(ch__6, (ftnlen)130);

/*        Try a PXFORM call. */

	pxform_("IAU_MARS2", "J2000", &c_b50, r__, (ftnlen)9, (ftnlen)5);
	chckxc_(&c_true, errmsg, ok, (ftnlen)1840);
    }

/*     Clean up the SPK file. */

    tcase_("File clean-up.", (ftnlen)14);
    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test_dyn.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dyn07__ */

