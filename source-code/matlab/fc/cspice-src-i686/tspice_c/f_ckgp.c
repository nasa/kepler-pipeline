/* f_ckgp.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_b6 = -10000;
static doublereal c_b10 = 0.;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__9 = 9;
static doublereal c_b41 = 1e-13;

/* $Procedure      F_CKGP (Family of tests for CKGP) */
/* Subroutine */ int f_ckgp__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal cmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int ckgp_(integer *, doublereal *, doublereal *, 
	    char *, doublereal *, doublereal *, logical *, ftnlen);
    char cknm[80];
    integer sclk;
    doublereal tmat[9]	/* was [3][3] */, eout, tout;
    extern /* Subroutine */ int sce2t_(integer *, doublereal *, doublereal *),
	     sct2e_(integer *, doublereal *, doublereal *);
    integer i__, j;
    doublereal ecmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char pcknm[80];
    extern /* Subroutine */ int ckupf_(integer *);
    logical found;
    doublereal ticks;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    doublereal xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int t_success__(logical *);
    integer id;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal et;
    integer handle;
    logical loadck;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    logical loadpc;
    extern /* Subroutine */ int ckgp_o__(integer *, doublereal *, doublereal *
	    , char *, doublereal *, doublereal *, logical *, ftnlen), ckmeta_(
	    integer *, char *, integer *, ftnlen);
    logical loadsc;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    logical keeppc;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    logical keepsc;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    doublereal angvel[3];
    logical efound;
    char sclknm[80];
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), tstatd_(doublereal *, doublereal *, doublereal *), 
	    tstckn_(char *, char *, logical *, logical *, logical *, integer *
	    , ftnlen, ftnlen), tstpck_(char *, logical *, logical *, ftnlen), 
	    sxform_(char *, char *, doublereal *, doublereal *, ftnlen, 
	    ftnlen);
    doublereal tol;
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine performs checks on the routine CKGP to ensure */
/*     that the upgrade to use non-inertial frames has not broken */
/*     anything. */

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

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_CKGP", (ftnlen)6);
    s_copy(cknm, "phoenix.bc", (ftnlen)80, (ftnlen)10);
    s_copy(pcknm, "phoenix.pck", (ftnlen)80, (ftnlen)11);
    s_copy(sclknm, "phoenix.sclk", (ftnlen)80, (ftnlen)12);
    loadck = TRUE_;
    loadsc = TRUE_;
    keepsc = TRUE_;
    loadpc = TRUE_;
    keeppc = FALSE_;
    kilfil_(cknm, (ftnlen)80);
    kilfil_(pcknm, (ftnlen)80);
    kilfil_(sclknm, (ftnlen)80);
    tstckn_(cknm, sclknm, &loadck, &loadsc, &keepsc, &handle, (ftnlen)80, (
	    ftnlen)80);
    tstpck_(pcknm, &loadpc, &keeppc, (ftnlen)80);
    ckmeta_(&c_b6, "SCLK", &sclk, (ftnlen)4);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    sce2t_(&sclk, &et, &ticks);
    tcase_("Check that the old version of CKGP and the new version yield the"
	    " same result when the frame requested is an inertial frame. ", (
	    ftnlen)124);
    id = -10000;
    ckgp_(&id, &ticks, &c_b10, "J2000", cmat, &tout, &found, (ftnlen)5);
    ckgp_o__(&id, &ticks, &c_b10, "J2000", ecmat, &eout, &efound, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chckad_("CMAT", cmat, "=", ecmat, &c__9, &c_b10, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksd_("TOUT", &tout, "=", &ticks, &c_b10, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Perform an independent computation of the attitude of object -99"
	    "99 and compare this with the value returned by CKGP. ", (ftnlen)
	    117);
    id = -9999;
    tol = 0.;
    ckmeta_(&id, "SCLK", &sclk, (ftnlen)4);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    sce2t_(&sclk, &et, &ticks);

/*        Now convert TICKS back to ET so that ET and TIKS point to */
/*        the same epoch (remember TICKS get pushed to an integer value */
/*        by SCE2T). */

    sct2e_(&sclk, &ticks, &et);
    ckgp_(&id, &ticks, &tol, "IAU_EARTH", cmat, &tout, &found, (ftnlen)9);

/*        CMAT now contains the transformation from IAU_EARTH to the */
/*        spacecraft frame (or it's supposed to anyway). */

    tstatd_(&et, tmat, angvel);

/*        TMAT gives the orientation of object -9999 relative to the */
/*        GALACTIC reference frame.  (TMAT is the transformation from */
/*        galactic to S.C. frame.) */

    sxform_("IAU_EARTH", "GALACTIC", &et, xform, (ftnlen)9, (ftnlen)8);
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    rot[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "rot", i__1, "f_ckgp__", (ftnlen)169)] = xform[(i__2 = 
		    i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("xform"
		    , i__2, "f_ckgp__", (ftnlen)169)];
	}
    }

/*        ROT      : IAU_EARTH ---> Galactic. */
/*        TMAT     : Galactic  ---> S.C. frame */
/*        TMAT*ROT : IAU_EARTH ---> S.C. frame */

    mxm_(tmat, rot, ecmat);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &efound, ok, (ftnlen)5);
    chckad_("CMAT", cmat, "~/", ecmat, &c__9, &c_b41, ok, (ftnlen)4, (ftnlen)
	    2);
    chcksd_("TOUT", &tout, "=", &ticks, &c_b10, ok, (ftnlen)4, (ftnlen)1);
    ckupf_(&handle);
    kilfil_(cknm, (ftnlen)80);
    kilfil_(pcknm, (ftnlen)80);
    kilfil_(sclknm, (ftnlen)80);
    t_success__(ok);
    return 0;
} /* f_ckgp__ */

