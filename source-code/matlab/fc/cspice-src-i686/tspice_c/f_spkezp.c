/* f_spkezp.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c_b12 = 401001;
static integer c_b15 = 301001;
static integer c__3 = 3;
static doublereal c_b24 = 1e-13;
static doublereal c_b27 = 1e-14;
static integer c_b32 = 399001;
static doublereal c_b43 = 0.;
static integer c__399 = 399;
static integer c__6 = 6;
static doublereal c_b126 = 1e-11;
static doublereal c_b129 = 1e-12;

/* $Procedure      F_SPKEZP (Family of tests for SPKEZP) */
/* Subroutine */ int f_spkezp__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    doublereal sobs[6];
    extern /* Subroutine */ int mxvg_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *), tcase_(char *, ftnlen);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    doublereal xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal et;
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     kilfil_(char *, ftnlen);
    doublereal estate[6];
    extern /* Subroutine */ int spkgeo_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen);
    doublereal istate[6];
    extern /* Subroutine */ int spkuef_(integer *), tparse_(char *, 
	    doublereal *, char *, ftnlen, ftnlen), spkapp_(integer *, 
	    doublereal *, char *, doublereal *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen);
    doublereal tstate[6];
    extern /* Subroutine */ int spkssb_(integer *, doublereal *, char *, 
	    doublereal *, ftnlen), tstpck_(char *, logical *, logical *, 
	    ftnlen), spkezp_(integer *, doublereal *, char *, char *, integer 
	    *, doublereal *, doublereal *, ftnlen, ftnlen), sxform_(char *, 
	    char *, doublereal *, doublereal *, ftnlen, ftnlen), tstspk_(char 
	    *, logical *, integer *, ftnlen);
    doublereal clt, elt;

/* $ Abstract */

/*     This routine performs a series of tests on the routine */
/*     SPKEZP to make sure that it behaves as expected. */

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

/* $ Version */

/*     TSPICE Version 2.0.1 11-JAN-2002 (EDW) */

/*        Reduced the vector tolerance for Cases 1 and 6 */
/*        by two orders of magnitude, to 10^12 and 10^-10 */
/*        respectively. Roundoff error resulted in */
/*        relative differences between test and exp vectors */
/*        to exceed the original tolerances on some */
/*        platforms. */

/*     TSPICE Version 2.0.0 18-DEC-2001 (NJB) */
/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPKEZP", (ftnlen)8);
    kilfil_("phoenix2.bsp", (ftnlen)12);
    kilfil_("phoenix2.ker", (ftnlen)12);
    tstspk_("phoenix2.bsp", &c_true, &handle, (ftnlen)12);
    tstpck_("phoenix2.ker", &c_true, &c_false, (ftnlen)12);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    tcase_("Make sure that SPKEZPand SPKGEO return the same information when"
	    " the correction requested is NONE. ", (ftnlen)99);
    spkezp_(&c_b12, &et, "IAU_EARTH", "NONE", &c_b15, state, &lt, (ftnlen)9, (
	    ftnlen)4);
    spkgeo_(&c_b12, &et, "IAU_EARTH", &c_b15, estate, &elt, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__3, &c_b24, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b27, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Make sure that SPKEZP returns the same thing as the combination "
	    "of SPKSSB and SPKAPP when an inertial frame is the requested out"
	    "put frame. Light time only correction.", (ftnlen)166);
    spkezp_(&c_b15, &et, "J2000", "LT", &c_b32, state, &lt, (ftnlen)5, (
	    ftnlen)2);
    spkssb_(&c_b32, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b15, &et, "J2000", sobs, "LT", estate, &elt, (ftnlen)5, (
	    ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", estate, &c__3, &c_b43, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksd_("LT", &lt, "=", &elt, &c_b43, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Repeat the previous test for the transmission case.", (ftnlen)51);
    spkezp_(&c_b15, &et, "J2000", "XLT", &c_b32, state, &lt, (ftnlen)5, (
	    ftnlen)3);
    spkssb_(&c_b32, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b15, &et, "J2000", sobs, "XLT", estate, &elt, (ftnlen)5, (
	    ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", estate, &c__3, &c_b43, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksd_("LT", &lt, "=", &elt, &c_b43, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Make sure that SPKEZP returns the same thing as the combination "
	    "of SPKSSB and SPKAPP when an inertial frame is the requested out"
	    "put frame. Converged Newtonian plus stellar aberation", (ftnlen)
	    181);
    spkezp_(&c_b15, &et, "J2000", "CN+S", &c_b32, state, &lt, (ftnlen)5, (
	    ftnlen)4);
    spkssb_(&c_b32, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b15, &et, "J2000", sobs, "CN+S", estate, &elt, (ftnlen)5, (
	    ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", estate, &c__3, &c_b43, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksd_("LT", &lt, "=", &elt, &c_b43, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Repeat the previous test for the transmission case.", (ftnlen)51);
    spkezp_(&c_b15, &et, "J2000", "XCN+S", &c_b32, state, &lt, (ftnlen)5, (
	    ftnlen)5);
    spkssb_(&c_b32, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b15, &et, "J2000", sobs, "XCN+S", estate, &elt, (ftnlen)5, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", estate, &c__3, &c_b43, ok, (ftnlen)5, (
	    ftnlen)1);
    chcksd_("LT", &lt, "=", &elt, &c_b43, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Perform an independent test to see if \"apparent\" positions in "
	    "non-inertial frames are properly computed. ", (ftnlen)105);
    spkezp_(&c_b12, &et, "IAU_EARTH", "CN+S", &c_b15, state, &lt, (ftnlen)9, (
	    ftnlen)4);
    spkssb_(&c_b15, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b12, &et, "J2000", sobs, "CN+S", istate, &elt, (ftnlen)5, (
	    ftnlen)4);
    spkapp_(&c__399, &et, "J2000", sobs, "CN+S", tstate, &clt, (ftnlen)5, (
	    ftnlen)4);
    d__1 = et - clt;
    sxform_("J2000", "IAU_EARTH", &d__1, xform, (ftnlen)5, (ftnlen)9);
    mxvg_(xform, istate, &c__6, &c__6, estate);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__3, &c_b126, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b129, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Repeat the previous test for the transmission case.", (ftnlen)51);
    spkezp_(&c_b12, &et, "IAU_EARTH", "XCN+S", &c_b15, state, &lt, (ftnlen)9, 
	    (ftnlen)5);
    spkssb_(&c_b15, &et, "J2000", sobs, (ftnlen)5);
    spkapp_(&c_b12, &et, "J2000", sobs, "XCN+S", istate, &elt, (ftnlen)5, (
	    ftnlen)5);
    spkapp_(&c__399, &et, "J2000", sobs, "XCN+S", tstate, &clt, (ftnlen)5, (
	    ftnlen)5);
    d__1 = et + clt;
    sxform_("J2000", "IAU_EARTH", &d__1, xform, (ftnlen)5, (ftnlen)9);
    mxvg_(xform, istate, &c__6, &c__6, estate);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", estate, &c__3, &c_b129, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &elt, &c_b129, ok, (ftnlen)2, (ftnlen)2);
    spkuef_(&handle);
    kilfil_("phoenix2.bsp", (ftnlen)12);
    t_success__(ok);
    return 0;
} /* f_spkezp__ */

