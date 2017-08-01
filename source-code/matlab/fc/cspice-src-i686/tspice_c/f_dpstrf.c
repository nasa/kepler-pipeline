/* f_dpstrf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;

/* $Procedure      F_DPSTRF (Family of tests for dpstrf ) */
/* Subroutine */ int f_dpstrf__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal x;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    , t_success__(logical *), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    integer sigdig;
    char estrng[80];
    extern /* Subroutine */ int dpstrf_(doublereal *, integer *, char *, char 
	    *, ftnlen, ftnlen);
    char string[80];

/* $ Abstract */

/*     This routine performs a sequence of tests on the SPICELIB */
/*     routine dpstrf. */

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

    topen_("F_DPSTRF", (ftnlen)8);
    tcase_("Test Rounding X =  1.28372D+8, SIGDIG = 2", (ftnlen)41);
    x = 1.28372e8;
    sigdig = 2;
    s_copy(estrng, " 130000000.", (ftnlen)80, (ftnlen)11);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test Rounding X = -1.28372D+8, SIGDIG = 2", (ftnlen)41);
    x = -1.28372e8;
    sigdig = 2;
    s_copy(estrng, "-130000000.", (ftnlen)80, (ftnlen)11);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test Rounding X =  9.9995 , SIGDIG = 4", (ftnlen)38);
    x = 9.9995;
    sigdig = 4;
    s_copy(estrng, " 10.00", (ftnlen)80, (ftnlen)6);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test Rounding X =  9.9995 , SIGDIG = 5", (ftnlen)38);
    x = 9.9995;
    sigdig = 5;
    s_copy(estrng, " 9.9995", (ftnlen)80, (ftnlen)7);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test small values X = 1.2829D-21, SIGDIG = 5", (ftnlen)44);
    x = 1.2829e-21;
    sigdig = 5;
    s_copy(estrng, " 0.0000000000000000000012829", (ftnlen)80, (ftnlen)28);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test large values X = 9.92829D+35 SIGDIG = 3", (ftnlen)44);
    x = 9.92829e35;
    sigdig = 3;
    s_copy(estrng, " 993000000000000000000000000000000000.", (ftnlen)80, (
	    ftnlen)38);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Test large values X = 9.96829D+35 SIGDIG = 2", (ftnlen)44);
    x = 9.96829e35;
    sigdig = 2;
    s_copy(estrng, " 1000000000000000000000000000000000000.", (ftnlen)80, (
	    ftnlen)39);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Intermediate value of X with non-zero integer and fractional par"
	    "ts.  X = 123.18272 SIGDIG = 14 ", (ftnlen)95);
    x = 123.18272;
    sigdig = 14;
    s_copy(estrng, " 123.18272000000", (ftnlen)80, (ftnlen)16);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Intermediate value of X with non-zero integer and fractional par"
	    "ts.  X = -123.18272 SIGDIG = 14 ", (ftnlen)96);
    x = -123.18272;
    sigdig = 14;
    s_copy(estrng, "-123.18272000000", (ftnlen)80, (ftnlen)16);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Zero case X = 0, SIGDIG = 7 ", (ftnlen)28);
    x = 0.;
    sigdig = 7;
    s_copy(estrng, " 0.0000000", (ftnlen)80, (ftnlen)10);
    dpstrf_(&x, &sigdig, "F", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    t_success__(ok);
    return 0;
} /* f_dpstrf__ */

