/* f_dyn08.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static logical c_false = FALSE_;
static integer c__5 = 5;
static integer c__3 = 3;
static integer c__0 = 0;
static doublereal c_b18 = 1.;
static doublereal c_b19 = 2.;
static doublereal c_b20 = 3.;
static doublereal c_b23 = 0.;
static integer c__1 = 1;
static doublereal c_b34 = 4.;
static integer c__4 = 4;
static doublereal c_b68 = 9.;
static logical c_true = TRUE_;
static integer c__9 = 9;
static integer c__199 = 199;
static integer c__999 = 999;

/* $Procedure F_DYN08 ( Dynamic Frame Test Family 08 ) */
/* Subroutine */ int f_dyn08__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int zzdynbid_(char *, integer *, char *, integer *
	    , ftnlen, ftnlen), zzdynoad_(char *, integer *, char *, integer *,
	     integer *, doublereal *, logical *, ftnlen, ftnlen), zzdynoac_(
	    char *, integer *, char *, integer *, integer *, char *, logical *
	    , ftnlen, ftnlen, ftnlen), zzdynfid_(char *, integer *, char *, 
	    integer *, ftnlen, ftnlen), zzdynvac_(char *, integer *, char *, 
	    integer *, integer *, char *, ftnlen, ftnlen, ftnlen), zzdynvad_(
	    char *, integer *, char *, integer *, integer *, doublereal *, 
	    ftnlen, ftnlen), zzdynvai_(char *, integer *, char *, integer *, 
	    integer *, integer *, ftnlen, ftnlen);
    integer i__, n;
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), chckai_(char *, integer 
	    *, char *, integer *, integer *, logical *, ftnlen, ftnlen), 
	    chcksc_(char *, char *, char *, char *, logical *, ftnlen, ftnlen,
	     ftnlen, ftnlen);
    integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    char chvals[80*5], framnm[32];
    doublereal dpvals[5];
    char deftxt[80*50], expchv[80*5];
    doublereal expdpv[5];
    integer expinv[5], invals[5];
    extern /* Subroutine */ int clpool_(void), lmpool_(char *, integer *, 
	    ftnlen), intstr_(integer *, char *, ftnlen), namfrm_(char *, 
	    integer *, ftnlen);

/* $ Abstract */

/*     Test family to exercise the frame subsystem kernel pool */
/*     fetch utilities. */

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

/*     This routine tests */

/*        ZZDYNFID {fetch frame ID code} */
/*        ZZDYNBID {fetch body ID code} */
/*        ZZDYNOAC {fetch optional array, character} */
/*        ZZDYNOAD {fetch optional array, d.p.} */
/*        ZZDYNVAC {fetch array, character} */
/*        ZZDYNVAD {fetch array, d.p.} */
/*        ZZDYNVAI {fetch array, integer} */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 18-DEC-2004 (NJB) */


/* -& */

/*     SPICELIB functions */

/*     Local Parameters */


/*     Tolerance levels for various tests. */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Open the test family. */

    topen_("F_DYN08", (ftnlen)7);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNVAD tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_2 = 4", (ftnlen)80, (
	    ftnlen)32);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_1_DP_ARRAY_1  = ( 5, 6, 7, 8 )", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_1_DP_ARRAY_2  = 9", (ftnlen)80, (
	    ftnlen)32);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expdpv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expdpv", 
		i__1, "f_dyn08__", (ftnlen)279)] = (doublereal) (i__ + 4);
    }

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b68, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_1_DP_ARRAY_012345  = ( 5, 6, 7, 8 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_1_DP_ARRAY_123456  = 9", (ftnlen)80, 
	    (ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expdpv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expdpv", 
		i__1, "f_dyn08__", (ftnlen)407)] = (doublereal) (i__ + 4);
    }

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_123456", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b68, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_01234 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)46);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_12345 = 4", (ftnlen)80, (
	    ftnlen)36);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_01234", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_12345", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_123456", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_01234", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_012345  = ( 5, 6, 7, 8"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_123455  = 9", (ftnlen)
	    80, (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_3", &c__5, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array having excessive s"
	    "ize.", (ftnlen)68);
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_1", &c__1, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAD, exception case:  try to fetch array having wrong data "
	    "type.", (ftnlen)69);
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynvad_(framnm, &frcode, "DP_ARRAY_1", &c__3, &n, dpvals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNVAI tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_2 = 4", (ftnlen)80, (
	    ftnlen)32);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {
	expinv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expinv", 
		i__1, "f_dyn08__", (ftnlen)762)] = i__;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_2", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckai_("INVALS (2)", invals, "=", &c__4, &c__1, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_1  = ( 5, 6, 7, 8 )", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_2  = 9", (ftnlen)80, (
	    ftnlen)32);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expinv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expinv", 
		i__1, "f_dyn08__", (ftnlen)825)] = i__ + 4;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_2", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckai_("INVALS (2)", invals, "=", &c__9, &c__1, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {
	expinv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expinv", 
		i__1, "f_dyn08__", (ftnlen)884)] = i__;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_2", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckai_("INVALS (2)", invals, "=", &c__4, &c__1, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_012345  = ( 5, 6, 7, 8 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_123456  = 9", (ftnlen)80, 
	    (ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_012345", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expinv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expinv", 
		i__1, "f_dyn08__", (ftnlen)955)] = i__ + 4;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_123456", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckai_("INVALS (2)", invals, "=", &c__9, &c__1, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_01234 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)46);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_12345 = 4", (ftnlen)80, (
	    ftnlen)36);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_01234", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {
	expinv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expinv", 
		i__1, "f_dyn08__", (ftnlen)1028)] = i__;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_12345", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckai_("INVALS (2)", invals, "=", &c__4, &c__1, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_012345", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/*     Repeat with a second variable. */


/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_123456", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_01234", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)14);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_012345  = ( 5, 6, 7, 8"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_123455  = 9", (ftnlen)
	    80, (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_012345", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_012345", &c__5, &n, invals, (ftnlen)
	    32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_3", &c__5, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array having excessive s"
	    "ize.", (ftnlen)68);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__1, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array having wrong data "
	    "type.", (ftnlen)69);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__3, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, exception case:  try to fetch array having a value tha"
	    "t causes integer overflow.", (ftnlen)90);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 1.D30 )", (ftnlen)80, 
	    (ftnlen)43);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__3, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_true, "SPICE(INTOUTOFRANGE)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAI, *non-error* exception case:  fetch array having a valu"
	    "e that must be rounded.", (ftnlen)87);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 2.4 )", (ftnlen)80, (
	    ftnlen)41);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the integer fetch routine for required arguments. */

    zzdynvai_(framnm, &frcode, "IN_ARRAY_1", &c__3, &n, invals, (ftnlen)32, (
	    ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	expinv[(i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : s_rnge("expinv", 
		i__2, "f_dyn08__", (ftnlen)1318)] = i__;
    }

/*     Check the contents of the returned array. */

    chckai_("INVALS (1)", invals, "=", expinv, &n, ok, (ftnlen)10, (ftnlen)1);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNVAC tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_2 = '4'", (ftnlen)80, (
	    ftnlen)34);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)1376)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)1383)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)1383)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_1_CH_ARRAY_1  = ( '5', '6', '7', '8"
	    "' )", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_1_CH_ARRAY_2  = '9'", (ftnlen)80, (
	    ftnlen)34);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__3 = i__ + 4;
	intstr_(&i__3, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)1440)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)1447)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)1447)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "9", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)1501)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)1508)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)1508)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_1_CH_ARRAY_012345  = ( '5', '6', '7"
	    "', '8' )", (ftnlen)80, (ftnlen)58);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_1_CH_ARRAY_123456  = '9'", (ftnlen)
	    80, (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__3 = i__ + 4;
	intstr_(&i__3, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)1575)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)1582)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)1582)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_123456", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "9", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_01234 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_12345 = '4'", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_01234  = ( '5', '6', '"
	    "7', '8' )", (ftnlen)80, (ftnlen)59);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_12345  = '9'", (ftnlen)
	    80, (ftnlen)40);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_01234", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)1652)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)1659)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)1659)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_12345", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_123456", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_01234  = ( '5', '6', '"
	    "7', '8' )", (ftnlen)80, (ftnlen)59);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_12345  = '9'", (ftnlen)
	    80, (ftnlen)40);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_01234", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_012345  = ( '5', '6', "
	    "'7', '8' )", (ftnlen)80, (ftnlen)60);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_123455  = '9'", (ftnlen)
	    80, (ftnlen)41);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, (ftnlen)
	    32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_3", &c__5, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array having excessive s"
	    "ize.", (ftnlen)68);
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_1", &c__1, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNVAC, exception case:  try to fetch array having wrong data "
	    "type.", (ftnlen)69);
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynvac_(framnm, &frcode, "CH_ARRAY_1", &c__3, &n, chvals, (ftnlen)32, (
	    ftnlen)10, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNOAD tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_2 = 4", (ftnlen)80, (
	    ftnlen)32);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_1_DP_ARRAY_1  = ( 5, 6, 7, 8 )", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_1_DP_ARRAY_2  = 9", (ftnlen)80, (
	    ftnlen)32);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expdpv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expdpv", 
		i__1, "f_dyn08__", (ftnlen)2019)] = (doublereal) (i__ + 4);
    }

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b68, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_1", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_2", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_1_DP_ARRAY_012345  = ( 5, 6, 7, 8 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_1_DP_ARRAY_123456  = 9", (ftnlen)80, 
	    (ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    for (i__ = 1; i__ <= 4; ++i__) {
	expdpv[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge("expdpv", 
		i__1, "f_dyn08__", (ftnlen)2167)] = (doublereal) (i__ + 4);
    }

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_123456", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b68, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_01234 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)46);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_12345 = 4", (ftnlen)80, (
	    ftnlen)36);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_01234", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    vpack_(&c_b18, &c_b19, &c_b20, expdpv);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (1)", dpvals, "=", expdpv, &n, &c_b23, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_12345", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chckad_("DPVALS (2)", dpvals, "=", &c_b34, &c__1, &c_b23, ok, (ftnlen)10, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Repeat with a second variable. */


/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_123456", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_01234  = ( 5, 6, 7, 8 )"
	    , (ftnlen)80, (ftnlen)51);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_12345  = 9", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_01234", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_012345 = ( 1, 2, 3 )", (ftnlen)
	    80, (ftnlen)47);
    s_copy(deftxt + 80, "FRAME_-1000000000_DP_ARRAY_123456 = 4", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 160, "FRAME_FRAME_DP_123_DP_ARRAY_012345  = ( 5, 6, 7, 8"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 240, "FRAME_FRAME_DP_123_DP_ARRAY_123455  = 9", (ftnlen)
	    80, (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_DP_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_012345", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_3", &c__5, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array having excessive s"
	    "ize.", (ftnlen)68);
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_1", &c__1, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAD, exception case:  try to fetch array having wrong data "
	    "type.", (ftnlen)69);
    s_copy(framnm, "FRAME_DP_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_DP_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the d.p. fetch routine for required arguments. */

    zzdynoad_(framnm, &frcode, "DP_ARRAY_1", &c__3, &n, dpvals, &found, (
	    ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNOAC tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_2 = '4'", (ftnlen)80, (
	    ftnlen)34);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)2559)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)2566)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)2566)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_1_CH_ARRAY_1  = ( '5', '6', '7', '8"
	    "' )", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_1_CH_ARRAY_2  = '9'", (ftnlen)80, (
	    ftnlen)34);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__3 = i__ + 4;
	intstr_(&i__3, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)2633)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)2640)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)2640)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "9", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_1", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)2704)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)2711)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)2711)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_2", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_1_CH_ARRAY_012345  = ( '5', '6', '7"
	    "', '8' )", (ftnlen)80, (ftnlen)58);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_1_CH_ARRAY_123456  = '9'", (ftnlen)
	    80, (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__3 = i__ + 4;
	intstr_(&i__3, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)2788)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)2795)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)2795)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_123456", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "9", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_01234 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_12345 = '4'", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_01234  = ( '5', '6', '"
	    "7', '8' )", (ftnlen)80, (ftnlen)59);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_12345  = '9'", (ftnlen)
	    80, (ftnlen)40);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_01234", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, expchv + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		s_rnge("expchv", i__2, "f_dyn08__", (ftnlen)2875)) * 80, (
		ftnlen)80);
    }

/*     Check the contents of the returned array. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	chcksc_("CHVALS (1)", chvals + ((i__2 = i__ - 1) < 5 && 0 <= i__2 ? 
		i__2 : s_rnge("chvals", i__2, "f_dyn08__", (ftnlen)2882)) * 
		80, "=", expchv + ((i__3 = i__ - 1) < 5 && 0 <= i__3 ? i__3 : 
		s_rnge("expchv", i__3, "f_dyn08__", (ftnlen)2882)) * 80, ok, (
		ftnlen)10, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    }

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_12345", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Check the cardinality of the returned array. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the contents of the returned array. */

    chcksc_("CHVALS (2)", chvals, "=", "4", ok, (ftnlen)10, (ftnlen)80, (
	    ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Repeat with a second variable. */


/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_123456", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_01234  = ( '5', '6', '"
	    "7', '8' )", (ftnlen)80, (ftnlen)59);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_12345  = '9'", (ftnlen)
	    80, (ftnlen)40);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_01234", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)14, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_012345 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 80, "FRAME_-1000000000_CH_ARRAY_123456 = '4'", (ftnlen)80,
	     (ftnlen)39);
    s_copy(deftxt + 160, "FRAME_FRAME_CH_123_CH_ARRAY_012345  = ( '5', '6', "
	    "'7', '8' )", (ftnlen)80, (ftnlen)60);
    s_copy(deftxt + 240, "FRAME_FRAME_CH_123_CH_ARRAY_123455  = '9'", (ftnlen)
	    80, (ftnlen)41);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_CH_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_012345", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)15, (ftnlen)80);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_3", &c__5, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the found flag. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array having excessive s"
	    "ize.", (ftnlen)68);
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( '1', '2', '3' )", (
	    ftnlen)80, (ftnlen)48);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_1", &c__1, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNOAC, exception case:  try to fetch array having wrong data "
	    "type.", (ftnlen)69);
    s_copy(framnm, "FRAME_CH_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_CH_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the character fetch routine for required arguments. */

    zzdynoac_(framnm, &frcode, "CH_ARRAY_1", &c__3, &n, chvals, &found, (
	    ftnlen)32, (ftnlen)10, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNBID tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = 199", (ftnlen)80, (ftnlen)
	    34);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_2 = 'MARS BARYCENTER'", (
	    ftnlen)80, (ftnlen)48);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__199, &c__0, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (2)", invals, "=", &c__4, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_1  = '5'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_2  = 'Pluto'", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__5, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (2)", invals, "=", &c__999, &c__0, ok, (ftnlen)10, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = 199", (ftnlen)80, (ftnlen)
	    34);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_2 = 'MARS BARYCENTER'", (
	    ftnlen)80, (ftnlen)48);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_1  = '5'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_2  = 'Pluto'", (ftnlen)80,
	     (ftnlen)38);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__199, &c__0, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (2)", invals, "=", &c__4, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 199", (ftnlen)80, (
	    ftnlen)39);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'MARS BARYCENTE"
	    "R'", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_012345  = '5'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_123456  = 'Pluto'", (
	    ftnlen)80, (ftnlen)43);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__5, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_123456", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (2)", invals, "=", &c__999, &c__0, ok, (ftnlen)10, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_01234 = 199", (ftnlen)80, (
	    ftnlen)38);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_12345 = 'MARS BARYCENTER'"
	    , (ftnlen)80, (ftnlen)52);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = '5'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 'Pluto'", (
	    ftnlen)80, (ftnlen)44);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_01234", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__199, &c__0, ok, (ftnlen)10, (
	    ftnlen)1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_12345", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (2)", invals, "=", &c__4, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 199", (ftnlen)80, (
	    ftnlen)39);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'MARS BARYCENTE"
	    "R'", (ftnlen)80, (ftnlen)53);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_123456", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = '5'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 'Pluto'", (
	    ftnlen)80, (ftnlen)44);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_01234", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 199", (ftnlen)80, (
	    ftnlen)39);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'MARS BARYCENTE"
	    "R'", (ftnlen)80, (ftnlen)53);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_012345  = '5'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_123455  = 'Pluto'", (
	    ftnlen)80, (ftnlen)45);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_3", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch integer array having siz"
	    "e > 1.", (ftnlen)70);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch character array having s"
	    "ize > 1.", (ftnlen)72);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( '1', '2' )", (ftnlen)80, 
	    (ftnlen)43);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNBID, exception case:  try to fetch body name with no matchi"
	    "ng ID code.", (ftnlen)75);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 =  'PLANET X'", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynbid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(NOTRANSLATION)", ok, (ftnlen)20);
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/*     ZZDYNFID tests */

/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */
/* **************************************************************** */

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, normal case:  fetch array using ID form of name.", (
	    ftnlen)58);

/*     First load some variables into the kernel pool. */

    clpool_();
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = 1", (ftnlen)80, (ftnlen)32)
	    ;
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_2 = 'IAU_MARS'", (ftnlen)
	    80, (ftnlen)41);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__1, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    namfrm_("IAU_MARS", &i__, (ftnlen)8);
    chcksi_("INVALS (2)", invals, "=", &i__, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, normal case:  fetch array using character form of name."
	    , (ftnlen)65);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_1  = 'J2000'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_2  = 'B1950'", (ftnlen)80,
	     (ftnlen)38);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__1, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    namfrm_("B1950", &i__, (ftnlen)5);
    chcksi_("INVALS (2)", invals, "=", &i__, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, normal case:  fetch array when ID and character form o"
	    "f name are both present.", (ftnlen)88);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = 1", (ftnlen)80, (ftnlen)32)
	    ;
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_2 = 'IAU_MARS'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_1  = 'J2000'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_2  = 'B1950'", (ftnlen)80,
	     (ftnlen)38);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__1, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_2", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    namfrm_("IAU_MARS", &i__, (ftnlen)8);
    chcksi_("INVALS (2)", invals, "=", &i__, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, normal case:  try to fetch array when ID form of name "
	    "is too long, char form is ok.", (ftnlen)93);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 1", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'IAU_JUPITER'", (
	    ftnlen)80, (ftnlen)49);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_1_IN_ARRAY_012345  = 'J2000'", (
	    ftnlen)80, (ftnlen)43);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_1_IN_ARRAY_123456  = 'B1950'", (
	    ftnlen)80, (ftnlen)43);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__1, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_123456", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    namfrm_("B1950", &i__, (ftnlen)5);
    chcksi_("INVALS (2)", invals, "=", &i__, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, normal case:  try to fetch array when ID form of name "
	    "is ok, char form is present but is too long.", (ftnlen)108);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_01234 = 1", (ftnlen)80, (
	    ftnlen)36);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_12345 = 'IAU_JUPITER'", (
	    ftnlen)80, (ftnlen)48);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = 'J2000'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 'B1950'", (
	    ftnlen)80, (ftnlen)44);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_01234", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    chcksi_("INVALS (1)", invals, "=", &c__1, &c__0, ok, (ftnlen)10, (ftnlen)
	    1);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_12345", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the contents of the returned ID. */

    namfrm_("IAU_JUPITER", &i__, (ftnlen)11);
    chcksi_("INVALS (2)", invals, "=", &i__, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch array when ID form of na"
	    "me is too long, char form is absent.", (ftnlen)100);

/*     The ID form of the kernel variable name has length 33 */
/*     characters.  The name form is 32 characters long. */

    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 1", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'IAU_JUPITER'", (
	    ftnlen)80, (ftnlen)49);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/*     Repeat with a second variable. */


/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_123456", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch array when ID form of na"
	    "me is absent, char form too long.", (ftnlen)97);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_01234  = 'J2000'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_12345  = 'B1950'", (
	    ftnlen)80, (ftnlen)44);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt + 160, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_01234", invals, (ftnlen)32, (ftnlen)
	    14);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are pres"
	    "ent.", (ftnlen)132);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);

/*     The ID form of the kernel variable name has length 32 */
/*     characters.  The name form is 33 characters long. */

    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_012345 = 1", (ftnlen)80, (
	    ftnlen)37);
    s_copy(deftxt + 80, "FRAME_-1000000000_IN_ARRAY_123456 = 'IAU_JUPITER'", (
	    ftnlen)80, (ftnlen)49);
    s_copy(deftxt + 160, "FRAME_FRAME_IN_123_IN_ARRAY_012345  = 'J2000'", (
	    ftnlen)80, (ftnlen)45);
    s_copy(deftxt + 240, "FRAME_FRAME_IN_123_IN_ARRAY_123455  = 'B1950'", (
	    ftnlen)80, (ftnlen)45);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lmpool_(deftxt, &c__4, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch array when both ID and c"
	    "har forms of name are too long, both types of variables are abse"
	    "nt.", (ftnlen)131);
    s_copy(framnm, "FRAME_IN_123", (ftnlen)32, (ftnlen)12);
    clpool_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_012345", invals, (ftnlen)32, (ftnlen)
	    15);
    chckxc_(&c_true, "SPICE(VARNAMETOOLONG)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch array that is not presen"
	    "t.", (ftnlen)66);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_3", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch integer array having siz"
	    "e > 1.", (ftnlen)70);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( 1, 2, 3 )", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch character array having s"
	    "ize > 1.", (ftnlen)72);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 = ( '1', '2' )", (ftnlen)80, 
	    (ftnlen)43);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDYNFID, exception case:  try to fetch frame name with no match"
	    "ing ID code.", (ftnlen)76);
    s_copy(framnm, "FRAME_IN_1", (ftnlen)32, (ftnlen)10);
    frcode = -1000000000;
    s_copy(deftxt, "FRAME_-1000000000_IN_ARRAY_1 =  'PLANET X'", (ftnlen)80, (
	    ftnlen)42);
    clpool_();
    lmpool_(deftxt, &c__1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Call the body ID fetch routine for required arguments. */

    zzdynfid_(framnm, &frcode, "IN_ARRAY_1", invals, (ftnlen)32, (ftnlen)10);
    chckxc_(&c_true, "SPICE(NOTRANSLATION)", ok, (ftnlen)20);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dyn08__ */

