/* f_qderiv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b3 = .33333333333333331;
static logical c_false = FALSE_;
static doublereal c_b9 = 1e-11;
static doublereal c_b17 = 2.;
static integer c__2 = 2;
static doublereal c_b32 = 1e-8;
static doublereal c_b34 = 0.;
static logical c_true = TRUE_;

/* $Procedure F_QDERIV ( QDERIV tests ) */
/* Subroutine */ int f_qderiv__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *), sin(doublereal), cos(
	    doublereal);

    /* Local variables */
    doublereal dfdt[2];
    integer n;
    doublereal scale, delta;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    doublereal f0[2], f2[2], x0;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    doublereal xd[2];
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), qderiv_(integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *);
    doublereal epslon;

/* $ Abstract */

/*     Test family to exercise the SPICELIB routine QDERIV. */

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

/* -    TSPICE Version 1.0.0, 24-NOV-2004 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Tolerance levels for various tests. */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_QDERIV", (ftnlen)8);

/*     Compute machine epsilon and the horizontal scale */
/*     factor required for determining an appropriate value */
/*     of DELTA. */

    epslon = 1.1102230246251565e-16f;
    scale = pow_dd(&epslon, &c_b3);

/* --- Case: ------------------------------------------------------ */

    tcase_("Estimate the derivative of sin(x) at x = 0.", (ftnlen)43);
    n = 1;
    delta = 1e-6;
    f0[0] = sin(-delta);
    f2[0] = sin(delta);
    qderiv_(&n, f0, f2, &delta, dfdt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xd[0] = 1.;
    chcksd_("d(sin(x))/dt at x=0", dfdt, "~", xd, &c_b9, ok, (ftnlen)19, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Estimate the derivative of sin(x) at x = pi/4.", (ftnlen)46);
    n = 1;
    x0 = pi_() / 4;
    delta = x0 * scale;
    f0[0] = sin(x0 - delta);
    f2[0] = sin(x0 + delta);
    qderiv_(&n, f0, f2, &delta, dfdt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xd[0] = cos(x0);
    chcksd_("d(sin(x))/dt at x=0", dfdt, "~", xd, &c_b9, ok, (ftnlen)19, (
	    ftnlen)1);
    tcase_("Estimate the derivative of x2 at x = 2.", (ftnlen)39);
    n = 1;
    delta = .001;
    d__1 = 2. - delta;
    f0[0] = pow_dd(&d__1, &c_b17);
    d__1 = delta + 2.;
    f2[0] = pow_dd(&d__1, &c_b17);
    qderiv_(&n, f0, f2, &delta, dfdt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xd[0] = 4.;
    chcksd_("d(x**2)/dt at x=2", dfdt, "~", xd, &c_b9, ok, (ftnlen)17, (
	    ftnlen)1);
    tcase_("Vector case: combine the previous cases.", (ftnlen)40);
    n = 2;
    delta = 1e-6;
    f0[0] = sin(-delta);
    f2[0] = sin(delta);
    d__1 = 2. - delta;
    f0[1] = pow_dd(&d__1, &c_b17);
    d__1 = delta + 2.;
    f2[1] = pow_dd(&d__1, &c_b17);
    qderiv_(&n, f0, f2, &delta, dfdt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xd[0] = 1.;
    xd[1] = 4.;
    chckad_("d(x**2)/dt at x=2", dfdt, "~", xd, &c__2, &c_b32, ok, (ftnlen)17,
	     (ftnlen)1);
    tcase_("DELTA == 0", (ftnlen)10);
    qderiv_(&n, f0, f2, &c_b34, dfdt);
    chckxc_(&c_true, "SPICE(DIVIDEBYZERO)", ok, (ftnlen)19);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_qderiv__ */

