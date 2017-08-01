/* f_kpsolv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static doublereal c_b10 = 1e-15;

/* $Procedure      F_KPSOLV (Family of tests for KPSOLV ) */
/* Subroutine */ int f_kpsolv__(logical *ok)
{
    /* Builtin functions */
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    doublereal evec[2], h__;
    integer i__, j;
    doublereal k, r__, x;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal theta;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    doublereal fx;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    extern doublereal kpsolv_(doublereal *);
    extern /* Subroutine */ int tstmsf_(doublereal *), tstmsg_(char *, char *,
	     ftnlen, ftnlen);

/* $ Abstract */

/*     This routine loops over a large set of points in the */
/*     unit circle to test the accuracy of the computations */
/*     carried out by KPSOLV. */

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

    topen_("F_KPSOLV", (ftnlen)8);
    tcase_("Determine how well the solution fits h,k whose polar coordinates"
	    " are r = {0, .05, .1, ... .9} and theta = { 0, .1 ... pi*2 } ", (
	    ftnlen)125);
    r__ = 0.;
    for (i__ = 1; i__ <= 20; ++i__) {
	theta = 0.;
	for (j = 1; j <= 63; ++j) {
	    tstmsg_("#", "Failure for R = # and THETA = #", (ftnlen)1, (
		    ftnlen)31);
	    tstmsf_(&r__);
	    tstmsf_(&theta);
	    h__ = r__ * cos(theta);
	    k = r__ * sin(theta);
	    evec[0] = h__;
	    evec[1] = k;
	    x = kpsolv_(evec);
	    fx = h__ * cos(x) + k * sin(x);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksd_("FX", &fx, "~", &x, &c_b10, ok, (ftnlen)2, (ftnlen)1);
	    theta += .1;
	}
	r__ += .05;
    }
    t_success__(ok);
    return 0;
} /* f_kpsolv__ */

