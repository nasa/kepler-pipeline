/* f_lagrng.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static doublereal c_b10 = 1e-14;
static doublereal c_b17 = 2.;
static doublereal c_b22 = 1.;
static doublereal c_b26 = 16.;
static doublereal c_b34 = -17.;
static doublereal c_b38 = -5.;
static doublereal c_b46 = -2.;
static doublereal c_b50 = 0.;
static integer c__4 = 4;
static doublereal c_b54 = 3.;
static logical c_true = TRUE_;

/* $Procedure      F_LAGRNG ( Lagrange interpolation ) */
/* Subroutine */ int f_lagrng__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal work[30]	/* was [15][2] */;
    integer i__, n;
    doublereal p, x;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    doublereal xvals[15], yvals[15];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal dp;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), lgrind_(integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *);

/* $ Abstract */

/*     This routine tests the routine LGRIND. */
/*     The tests performed check */

/*     1)  That the routines correctly interpolate data sets plucked */
/*         from known polynomials. */

/*     2)  That both interpolators perform error handling as specified. */

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

/* -    SPICELIB Version 1.0.0, 28-AUG-2002 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Statement function for (a particular) polynomial derivative: */


/*     Begin every test family with an open call. */

    topen_("F_LAGRNG", (ftnlen)8);
    n = 4;
    xvals[0] = -1.;
    xvals[1] = 0.;
    xvals[2] = 1.;
    xvals[3] = 3.;
    yvals[0] = -2.;
    yvals[1] = -7.;
    yvals[2] = -8.;
    yvals[3] = 26.;

/*        The unique cubic polynomial that fits these points is */

/*                       3       2 */
/*           f(x)   =   x   +  2x  - 4x  - 7 */


/*        The derivative of f(x) is */

/*             '         2 */
/*           f (x)  =  3x   +  4x  - 4 */

    tcase_("LGRIND normal case #1: f(x) = x**3 + 2*x**2 -4*x - 7.  Evaluate "
	    "at input x values.", (ftnlen)82);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	x = xvals[(i__2 = i__ - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge("xvals", 
		i__2, "f_lagrng__", (ftnlen)128)];
	lgrind_(&n, xvals, yvals, work, &x, &p, &dp);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksd_("y(xvals(i))", &p, "~/", &yvals[(i__2 = i__ - 1) < 15 && 0 <= 
		i__2 ? i__2 : s_rnge("yvals", i__2, "f_lagrng__", (ftnlen)133)
		], &c_b10, ok, (ftnlen)11, (ftnlen)2);
/* Computing 2nd power */
	d__2 = x;
	d__1 = d__2 * d__2 * 3. + x * 4. - 4.;
	chcksd_("y'(xvals(i))", &dp, "~", &d__1, &c_b10, ok, (ftnlen)12, (
		ftnlen)1);
    }
    tcase_("LGRIND normal case #2: f(x) = x**3 + 2*x**2 -4*x - 7.  Evaluate "
	    "at x = 2.", (ftnlen)73);
    lgrind_(&n, xvals, yvals, work, &c_b17, &p, &dp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        The returned value of P should be 1.D0. */

/*        The returned value of DP should be 1.6D1. */

    chcksd_("y(2)", &p, "~/", &c_b22, &c_b10, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &dp, "~", &c_b26, &c_b10, ok, (ftnlen)5, (ftnlen)1);
    tcase_("LGRIND normal case #3: linear polynomial.", (ftnlen)41);
    n = 2;
    xvals[0] = -1.;
    xvals[1] = 0.;
    yvals[0] = -2.;
    yvals[1] = -7.;
    lgrind_(&n, xvals, yvals, work, &c_b17, &p, &dp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2)", &p, "~/", &c_b34, &c_b10, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &dp, "~", &c_b38, &c_b10, ok, (ftnlen)5, (ftnlen)1);
    tcase_("LGRIND normal case #4: constant polynomial.", (ftnlen)43);
    n = 1;
    xvals[0] = -1.;
    yvals[0] = -2.;
    lgrind_(&n, xvals, yvals, work, &c_b17, &p, &dp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2)", &p, "~/", &c_b46, &c_b10, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &dp, "~", &c_b50, &c_b10, ok, (ftnlen)5, (ftnlen)1);

/*     Now for the LGRIND error cases. */

    tcase_("LGRIND error case:  equal abscissa values.", (ftnlen)42);
    xvals[1] = -1.;
    lgrind_(&c__4, xvals, yvals, work, &c_b54, &p, &dp);
    chckxc_(&c_true, "SPICE(DIVIDEBYZERO)", ok, (ftnlen)19);
    t_success__(ok);
    return 0;
} /* f_lagrng__ */

