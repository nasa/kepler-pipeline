/* f_zzrxr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b13 = 0.;

/* $Procedure      F_ZZRXR ( Check the routine zzRXR ) */
/* Subroutine */ int f_zzrxr__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal temp[9]	/* was [3][3] */;
    integer i__, j, n;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    , t_success__(logical *), zzrxr_(doublereal *, integer *, 
	    doublereal *), chckad_(char *, doublereal *, char *, doublereal *,
	     integer *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal expect[9]	/* was [3][3] */, sxform[45]	/* was [3][3][
	    5] */, output[9]	/* was [3][3] */;
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal rot1[9]	/* was [3][3] */, rot2[9]	/* was [3][3] */;

/* $ Abstract */

/*     This tests the private rouine ZZRXR.  Note that we put */
/*     something that can't be the correct answer in OUTPUT in */
/*     each test case to make sure that the OUTPUT is completely */
/*     filled by ZZRXR */
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

    topen_("F_ZZRXR", (ftnlen)7);
    tcase_("Test out the case when N = 0. We should get the 3x3 identity mat"
	    "rix in this case.", (ftnlen)81);
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    expect[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "expect", i__1, "f_zzrxr__", (ftnlen)80)] = (doublereal) (
		    -((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 = i__ - j, 
		    abs(i__3)) + 1));
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)81)] = -1.;
	}
    }
    n = 0;
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Test the case when N = 1.  For this case the output should be a "
	    "copy of the input.", (ftnlen)82);
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)96)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 3) * 3 - 13) < 45 && 0 <= i__1 ? i__1 : 
		    s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)103)] = (
		    doublereal) (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / ((
		    i__3 = i__ - j, abs(i__3)) + 1)));
	    expect[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "expect", i__1, "f_zzrxr__", (ftnlen)105)] = (doublereal) 
		    (j * (-((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 = i__ - 
		    j, abs(i__3)) + 1)));
	}
    }
    n = 1;
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("N = 2, Actual product computed.", (ftnlen)31);
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)123)] = -1.;
	}
    }
    rot1[0] = 1.;
    rot1[1] = 2.;
    rot1[2] = 3.;
    rot1[3] = 4.;
    rot1[4] = 5.;
    rot1[5] = 6.;
    rot1[6] = 7.;
    rot1[7] = 8.;
    rot1[8] = 9.;
    rot2[0] = 1.;
    rot2[1] = 2.;
    rot2[2] = 3.;
    rot2[3] = 2.;
    rot2[4] = 3.;
    rot2[5] = 1.;
    rot2[6] = 3.;
    rot2[7] = 1.;
    rot2[8] = 2.;
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 3) * 3 - 13) < 45 && 0 <= i__1 ? i__1 : 
		    s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)157)] = rot1[(
		    i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot1", i__2, "f_zzrxr__", (ftnlen)157)];
	    sxform[(i__1 = i__ + (j + 6) * 3 - 13) < 45 && 0 <= i__1 ? i__1 : 
		    s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)158)] = rot2[(
		    i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot2", i__2, "f_zzrxr__", (ftnlen)158)];
	}
    }
    n = 2;
    mxm_(&sxform[9], sxform, expect);
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Three matrices multiplied together", (ftnlen)34);
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)175)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 9) * 3 - 13) < 45 && 0 <= i__1 ? i__1 : 
		    s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)182)] = rot1[(
		    i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot1", i__2, "f_zzrxr__", (ftnlen)182)];
	}
    }
    n = 3;
    mxm_(&sxform[18], &sxform[9], temp);
    mxm_(temp, sxform, expect);
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Four matrices multiplied together", (ftnlen)33);
    n = 4;
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)202)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 12) * 3 - 13) < 45 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)209)] = rot2[
		    (i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot2", i__2, "f_zzrxr__", (ftnlen)209)];
	}
    }
    mxm_(&sxform[27], &sxform[18], expect);
    mxm_(expect, &sxform[9], temp);
    mxm_(temp, sxform, expect);
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Five matrices multiplied together", (ftnlen)33);
    n = 5;
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    output[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "output", i__1, "f_zzrxr__", (ftnlen)230)] = -1.;
	}
    }
    for (j = 1; j <= 3; ++j) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    sxform[(i__1 = i__ + (j + 15) * 3 - 13) < 45 && 0 <= i__1 ? i__1 :
		     s_rnge("sxform", i__1, "f_zzrxr__", (ftnlen)236)] = rot1[
		    (i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot1", i__2, "f_zzrxr__", (ftnlen)236)];
	}
    }
    mxm_(&sxform[36], &sxform[27], temp);
    mxm_(temp, &sxform[18], expect);
    mxm_(expect, &sxform[9], temp);
    mxm_(temp, sxform, expect);
    zzrxr_(sxform, &n, output);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("OUTPUT", output, "=", expect, &c__9, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_zzrxr__ */

