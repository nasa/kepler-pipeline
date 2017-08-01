/* f_hrmite.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static doublereal c_b5 = -5.;
static logical c_false = FALSE_;
static doublereal c_b10 = 1.;
static doublereal c_b11 = 1e-14;
static doublereal c_b14 = 0.;
static doublereal c_b17 = -1.;
static doublereal c_b53 = 5.;
static doublereal c_b127 = -6.;
static doublereal c_b147 = 6.;
static doublereal c_b152 = 168.;
static doublereal c_b156 = 29.;
static integer c__4 = 4;
static doublereal c_b169 = 3.;
static doublereal c_b184 = 2.;
static doublereal c_b189 = 141.;
static doublereal c_b193 = 456.;
static doublereal c_b201 = 2210.;
static doublereal c_b205 = 5115.;
static doublereal c_b213 = 78180.;
static doublereal c_b217 = 109395.;
static doublereal c_b221 = -15.;
static doublereal c_b226 = -170858920.;
static doublereal c_b230 = 79734315.;
static doublereal c_b233 = 100.;
static doublereal c_b238 = 100000000020005.;
static doublereal c_b242 = 7000000000400.;
static doublereal c_b245 = -1e3;
static doublereal c_b250 = -9.99999999999998e20;
static doublereal c_b254 = 6.999999999999996e18;
static doublereal c_b257 = 2e3;
static doublereal c_b262 = 1.28e23;
static doublereal c_b266 = 4.48e20;
static doublereal c_b269 = .001;
static doublereal c_b274 = 5.00000200000000028;
static doublereal c_b275 = 1e-12;
static doublereal c_b278 = .00400000000000000702;
static logical c_true = TRUE_;
static doublereal c_b292 = 1e-11;
static doublereal c_b524 = 8.;
static doublereal c_b528 = 11.;

/* $Procedure      F_HRMITE ( Hermite interpolation ) */
/* Subroutine */ int f_hrmite__(logical *ok)
{
    doublereal step, work[60]	/* was [30][2] */, f;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    doublereal start, xvals[15], yvals[30];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal df;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), hrmesp_(integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *), hrmint_(integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *);

/* $ Abstract */

/*     This routine tests the routines HRMINT and HRMESP. */
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

/* -    SPICELIB Version 3.0.0, 09-NOV-2005 (NJB) */

/*        Changed comparison type from relative to absolute for the */
/*        quantity y'(0) in the HRMINT test case using abscissa points */
/*        -1000, 0, 1, 1.000001.  (Yes, the same case for which the */
/*        previous update was made.) */

/* -    SPICELIB Version 2.2.0, 27-FEB-2003 (NJB) */

/*        Changed tolerance from TIGHT to LOOSE for HRMINT test */
/*        case using abscissa points -1000, 0, 1, 1.000001. */

/* -    SPICELIB Version 2.0.0, 04-SEP-2002 (NJB) */

/*        Test cases for handling of non-standard adjustable */
/*        array dimension 0 were removed; these tests cause the */
/*        calling program to crash on VAX environments. */

/* -    SPICELIB Version 1.0.0, 01-MAR-2000 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_HRMITE", (ftnlen)8);
    tcase_("HRMINT test:  interpolate the constant function y == 1.  The fun"
	    "ction satisfies y(0) = 1, y'(0) = 0, y(1) = 1, y'(1) = 0.  Evalu"
	    "ate the function at x = -5, x = -1, x = 0, x = 1, x = 5.", (
	    ftnlen)184);
    xvals[0] = 0.;
    xvals[1] = 1.;
    yvals[0] = 1.;
    yvals[1] = 0.;
    yvals[2] = 1.;
    yvals[3] = 0.;
    hrmint_(&c__2, xvals, yvals, &c_b5, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-5)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-5)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)6, (ftnlen)1);
    hrmint_(&c__2, xvals, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)6, (ftnlen)1);
    hrmint_(&c__2, xvals, yvals, &c_b14, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(0)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmint_(&c__2, xvals, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmint_(&c__2, xvals, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    tcase_("HRMINT test:  interpolate the linear function y == 1.  The funct"
	    "ion satisfies y(0) = 0, y'(0) = 1, y(1) = 1, y'(1) = 1.  Evaluat"
	    "e the function at x = -5, x = -1, x = 0, x = 1, x = 5.", (ftnlen)
	    182);
    xvals[0] = 0.;
    xvals[1] = 1.;
    yvals[0] = 0.;
    yvals[1] = 1.;
    yvals[2] = 1.;
    yvals[3] = 1.;
    hrmint_(&c__2, xvals, yvals, &c_b5, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-5)", &f, "~/", &c_b5, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-5)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b17, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b14, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~", &c_b14, &c_b11, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("y'(0)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b53, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    tcase_("HRMINT test:  interpolate the 3rd degree polynomial y == -x**3 +"
	    " 12*x**2 -7*x -6. The function y and its derivative take the val"
	    "ues y(-6) = 684, y'(-6) = -259, values y(-1) = 14,  y'(-1) = -34."
	    , (ftnlen)193);
    xvals[0] = -6.;
    xvals[1] = -1.;
    yvals[0] = 684.;
    yvals[1] = -259.;
    yvals[2] = 14.;
    yvals[3] = -34.;
    hrmint_(&c__2, xvals, yvals, &c_b127, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-6)", &f, "~/", yvals, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-6)", &df, "~/", &yvals[1], &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &yvals[2], &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &yvals[3], &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmint_(&c__2, xvals, yvals, &c_b147, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(6)", &f, "~/", &c_b152, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(6)", &df, "~/", &c_b156, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    tcase_("HRMINT test:  interpolate the 7th degree polynomial y == x**7 + "
	    "2*x**2 +5.  The function y(-1) = 6, y'(-1) = 3, y(0) = 5, y'(0) "
	    "= 0, y(3) = 2210, y'(3) = 5115, y(5) = 78180, y'(5) = 109395.", (
	    ftnlen)189);
    xvals[0] = -1.;
    xvals[1] = 0.;
    xvals[2] = 3.;
    xvals[3] = 5.;
    yvals[0] = 6.;
    yvals[1] = 3.;
    yvals[2] = 5.;
    yvals[3] = 0.;
    yvals[4] = 2210.;
    yvals[5] = 5115.;
    yvals[6] = 78180.;
    yvals[7] = 109395.;
    hrmint_(&c__4, xvals, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b147, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &c_b169, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b14, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~/", &c_b53, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(0)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmint_(&c__4, xvals, yvals, &c_b184, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2)", &f, "~/", &c_b189, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &df, "~/", &c_b193, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b169, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(3)", &f, "~/", &c_b201, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(3)", &df, "~/", &c_b205, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b213, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~/", &c_b217, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    tcase_("HRMINT test:  interpolate the 7th degree polynomial y == x**7 + "
	    "2*x**2 +5 at a variety of abscissa values.", (ftnlen)106);
    hrmint_(&c__4, xvals, yvals, &c_b221, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-15)", &f, "~/", &c_b226, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    chcksd_("y'(-15)", &df, "~/", &c_b230, &c_b11, ok, (ftnlen)7, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b233, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(100)", &f, "~/", &c_b238, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    chcksd_("y'(100)", &df, "~/", &c_b242, &c_b11, ok, (ftnlen)7, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b245, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1000)", &f, "~/", &c_b250, &c_b11, ok, (ftnlen)8, (ftnlen)2);
    chcksd_("y'(-1000)", &df, "~/", &c_b254, &c_b11, ok, (ftnlen)9, (ftnlen)2)
	    ;
    hrmint_(&c__4, xvals, yvals, &c_b257, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2000)", &f, "~/", &c_b262, &c_b11, ok, (ftnlen)7, (ftnlen)2);
    chcksd_("y'(2000)", &df, "~/", &c_b266, &c_b11, ok, (ftnlen)8, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b269, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1.D-3)", &f, "~/", &c_b274, &c_b275, ok, (ftnlen)8, (ftnlen)2);
    chcksd_("y'(1.D-3)", &df, "~/", &c_b278, &c_b275, ok, (ftnlen)9, (ftnlen)
	    2);

/*     Now for the HRMINT error cases. */

    tcase_("HRMINT error case:  equal abscissa values.", (ftnlen)42);
    xvals[1] = -1.;
    hrmint_(&c__4, xvals, yvals, &c_b169, work, &f, &df);
    chckxc_(&c_true, "SPICE(DIVIDEBYZERO)", ok, (ftnlen)19);
    tcase_("HRMINT error case:  window size = 0.", (ftnlen)36);
    xvals[1] = 0.;

/*     Further HRMINT non-error tests: */

/*     Using the same polynomial as above */

/*        y = x**7 + 2*x**2 + 5 */

/*     define the polynomial on a set of abscissa values having */
/*     spacing of widely varying magnitudes. */


    tcase_("HRMINT test:  interpolate the 7th degree polynomial y = x**7 + 2"
	    "*x**2 +5.  Use  abscissa points -1000, 0, 1, 1.000001.", (ftnlen)
	    118);
    xvals[0] = -100.;
    xvals[1] = 0.;
    xvals[2] = 1.;
    xvals[3] = 1.1;
    yvals[0] = -99999999979995.;
    yvals[1] = 6999999999600.;
    yvals[2] = 5.;
    yvals[3] = 0.;
    yvals[4] = 8.;
    yvals[5] = 11.;
    yvals[6] = 9.36871710000000135;
    yvals[7] = 16.8009270000000086;

/*     Make sure we can recover the interpolated values. */

    hrmint_(&c__4, xvals, yvals, xvals, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-100)", &f, "~/", yvals, &c_b292, ok, (ftnlen)7, (ftnlen)2);
    chcksd_("y'(-100)", &df, "~/", &yvals[1], &c_b292, ok, (ftnlen)8, (ftnlen)
	    2);
    hrmint_(&c__4, xvals, yvals, &xvals[1], work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~/", &yvals[2], &c_b292, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(0)", &df, "~", &yvals[3], &c_b292, ok, (ftnlen)5, (ftnlen)1);
    hrmint_(&c__4, xvals, yvals, &xvals[2], work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &yvals[4], &c_b292, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~/", &yvals[5], &c_b292, ok, (ftnlen)5, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &xvals[3], work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1.1)", &f, "~/", &yvals[6], &c_b292, ok, (ftnlen)6, (ftnlen)2);
    chcksd_("y'(1.1)", &df, "~/", &yvals[7], &c_b292, ok, (ftnlen)7, (ftnlen)
	    2);

/*     Try a variety of abscissa values. */

    hrmint_(&c__4, xvals, yvals, &c_b221, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-15)", &f, "~/", &c_b226, &c_b292, ok, (ftnlen)6, (ftnlen)2);
    chcksd_("y'(-15)", &df, "~/", &c_b230, &c_b292, ok, (ftnlen)7, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b233, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(100)", &f, "~/", &c_b238, &c_b292, ok, (ftnlen)6, (ftnlen)2);
    chcksd_("y'(100)", &df, "~/", &c_b242, &c_b292, ok, (ftnlen)7, (ftnlen)2);
    hrmint_(&c__4, xvals, yvals, &c_b245, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1000)", &f, "~/", &c_b250, &c_b292, ok, (ftnlen)8, (ftnlen)2);
    chcksd_("y'(-1000)", &df, "~/", &c_b254, &c_b292, ok, (ftnlen)9, (ftnlen)
	    2);
    hrmint_(&c__4, xvals, yvals, &c_b257, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2000)", &f, "~/", &c_b262, &c_b292, ok, (ftnlen)7, (ftnlen)2);
    chcksd_("y'(2000)", &df, "~/", &c_b266, &c_b292, ok, (ftnlen)8, (ftnlen)2)
	    ;
    hrmint_(&c__4, xvals, yvals, &c_b269, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1.D-3)", &f, "~/", &c_b274, &c_b292, ok, (ftnlen)8, (ftnlen)2);
    chcksd_("y'(1.D-3)", &df, "~/", &c_b278, &c_b292, ok, (ftnlen)9, (ftnlen)
	    2);

/*     Now for the HRMESP cases. */

    tcase_("HRMESP test:  interpolate the constant function y == 1.  The fun"
	    "ction satisfies y(0) = 1, y'(0) = 0, y(1) = 1, y'(1) = 0.  Evalu"
	    "ate the function at x = -5, x = -1, x = 0, x = 1, x = 5.", (
	    ftnlen)184);
    start = 0.;
    step = 1.;
    yvals[0] = 1.;
    yvals[1] = 0.;
    yvals[2] = 1.;
    yvals[3] = 0.;
    hrmesp_(&c__2, &start, &step, yvals, &c_b5, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-5)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-5)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)6, (ftnlen)1);
    hrmesp_(&c__2, &start, &step, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1-)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)6, (ftnlen)1);
    hrmesp_(&c__2, &start, &step, yvals, &c_b14, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(0)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmesp_(&c__2, &start, &step, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmesp_(&c__2, &start, &step, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~", &c_b14, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    tcase_("HRMESP test:  interpolate the linear function y == 1.  The funct"
	    "ion satisfies y(0) = 0, y'(0) = 1, y(1) = 1, y'(1) = 1.  Evaluat"
	    "e the function at x = -5, x = -1, x = 0, x = 1, x = 5.", (ftnlen)
	    182);
    start = 0.;
    step = 1.;
    yvals[0] = 0.;
    yvals[1] = 1.;
    yvals[2] = 1.;
    yvals[3] = 1.;
    hrmesp_(&c__2, &start, &step, yvals, &c_b5, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-5)", &f, "~/", &c_b5, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-5)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmesp_(&c__2, &start, &step, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b17, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmesp_(&c__2, &start, &step, yvals, &c_b14, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(0)", &f, "~", &c_b14, &c_b11, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("y'(0)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__2, &start, &step, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b10, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__2, &start, &step, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b53, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~/", &c_b10, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    tcase_("HRMESP test:  interpolate the 7th degree polynomial y == x**7 + "
	    "2*x**2 +5.  The function y(-1) = 6, y'(-1) = 3, y(1) = 8, y'(1) "
	    "= 11, y(3) = 2210, y'(3) = 5115, y(5) = 78180, y'(5) = 109395.", (
	    ftnlen)190);
    start = -1.;
    step = 2.;
    yvals[0] = 6.;
    yvals[1] = 3.;
    yvals[2] = 8.;
    yvals[3] = 11.;
    yvals[4] = 2210.;
    yvals[5] = 5115.;
    yvals[6] = 78180.;
    yvals[7] = 109395.;
    hrmesp_(&c__4, &start, &step, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b147, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &c_b169, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b524, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~", &c_b528, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmesp_(&c__4, &start, &step, yvals, &c_b184, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2)", &f, "~/", &c_b189, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &df, "~/", &c_b193, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b169, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(3)", &f, "~/", &c_b201, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(3)", &df, "~/", &c_b205, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b213, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~/", &c_b217, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    tcase_("HRMESP test:  interpolate the 7th degree polynomial y == x**7 + "
	    "2*x**2 +5.  The function y(-1) = 6, y'(-1) = 3, y(1) = 8, y'(1) "
	    "= 11, y(3) = 2210, y'(3) = 5115, y(5) = 78180, y'(5) = 109395.  "
	    "This time use a NEGATIVE step.", (ftnlen)222);
    start = 5.;
    step = -2.;
    yvals[6] = 6.;
    yvals[7] = 3.;
    yvals[4] = 8.;
    yvals[5] = 11.;
    yvals[2] = 2210.;
    yvals[3] = 5115.;
    yvals[0] = 78180.;
    yvals[1] = 109395.;
    hrmesp_(&c__4, &start, &step, yvals, &c_b17, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(-1)", &f, "~/", &c_b147, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("y'(-1)", &df, "~/", &c_b169, &c_b11, ok, (ftnlen)6, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b10, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(1)", &f, "~/", &c_b524, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(1)", &df, "~", &c_b528, &c_b11, ok, (ftnlen)5, (ftnlen)1);
    hrmesp_(&c__4, &start, &step, yvals, &c_b184, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(2)", &f, "~/", &c_b189, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(2)", &df, "~/", &c_b193, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b169, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(3)", &f, "~/", &c_b201, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(3)", &df, "~/", &c_b205, &c_b11, ok, (ftnlen)5, (ftnlen)2);
    hrmesp_(&c__4, &start, &step, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("y(5)", &f, "~/", &c_b213, &c_b11, ok, (ftnlen)4, (ftnlen)2);
    chcksd_("y'(5)", &df, "~/", &c_b217, &c_b11, ok, (ftnlen)5, (ftnlen)2);

/*     Now for the HRMESP error cases. */

    tcase_("HRMESP error case:  step size zero.", (ftnlen)35);
    start = -1.;
    step = 0.;
    hrmesp_(&c__4, &start, &step, yvals, &c_b53, work, &f, &df);
    chckxc_(&c_true, "SPICE(INVALIDSTEPSIZE)", ok, (ftnlen)22);
    tcase_("HRMESP error case:  window size = 0.", (ftnlen)36);
    start = -1.;
    step = 2.;
    t_success__(ok);
    return 0;
} /* f_hrmite__ */

