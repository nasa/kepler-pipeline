/* f_oscelt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b8 = 100.;
static doublereal c_b9 = 0.;
static logical c_true = TRUE_;
static doublereal c_b16 = 1e10;
static doublereal c_b39 = 1.;
static doublereal c_b40 = 1e-10;
static integer c__14 = 14;
static logical c_false = FALSE_;
static doublereal c_b70 = 1e-13;
static integer c__3 = 3;

/* $Procedure      F_OSCELT ( OSCELT routine tests ) */
/* Subroutine */ int f_oscelt__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sin(doublereal);

    /* Local variables */
    integer iecc;
    doublereal xecc[6];
    integer iinc;
    doublereal xinc[7], elts[8];
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer iargp;
    extern doublereal exact_(doublereal *, doublereal *, doublereal *);
    extern /* Subroutine */ int repmd_(char *, char *, doublereal *, integer *
	    , char *, ftnlen, ftnlen, ftnlen);
    extern doublereal dpmax_(void);
    doublereal state[6], xargp[8];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal xelts[8];
    extern doublereal twopi_(void);
    extern /* Subroutine */ int t_success__(logical *);
    doublereal state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    doublereal et;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal mu;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    integer ilnode;
    extern /* Subroutine */ int conics_(doublereal *, doublereal *, 
	    doublereal *);
    logical succes;
    doublereal xlnode[4];
    extern /* Subroutine */ int oscelt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal inelts[8];
    char tstdsc[400];
    integer im0;
    doublereal xm0[8], tol, xrp[1];

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        OSCELT */

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

/* -    SPICELIB Version 1.0.0, 23-JAN-2003 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     The value of CLOSE must match that used in OSCELT. */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_OSCELT", (ftnlen)8);

/*     Error tests: */

    for (i__ = 1; i__ <= 3; ++i__) {
	state[(i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("state", i__1,
		 "f_oscelt__", (ftnlen)147)] = i__ * 1e3;
    }
    for (i__ = 4; i__ <= 6; ++i__) {
	state[(i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("state", i__1,
		 "f_oscelt__", (ftnlen)151)] = i__ * -10.;
    }
    tcase_("Invalid GM.", (ftnlen)11);
    oscelt_(state, &c_b8, &c_b9, elts);
    chckxc_(&c_true, "SPICE(NONPOSITIVEMASS)", ok, (ftnlen)22);
    tcase_("Specific angular momentum == 0", (ftnlen)30);
    for (i__ = 4; i__ <= 6; ++i__) {
	state[(i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("state", i__1,
		 "f_oscelt__", (ftnlen)166)] = 0.;
    }
    oscelt_(state, &c_b8, &c_b16, elts);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Normal cases: */


/*     Set up the expected element values. */


/*     Expected argument of periapse: */

    for (iargp = 1; iargp <= 8; ++iargp) {
	xargp[(i__1 = iargp - 1) < 8 && 0 <= i__1 ? i__1 : s_rnge("xargp", 
		i__1, "f_oscelt__", (ftnlen)184)] = (iargp - 1) * twopi_() / 
		8;
    }

/*     Expected eccentricity: */

    xecc[0] = 0.;
    xecc[1] = .5;
    xecc[2] = .999999;
    xecc[3] = 1.;
    xecc[4] = 1.000001;
    xecc[5] = 1.5;

/*     Expected inclination: */

    xinc[0] = 0.;
    xinc[1] = 5.0000000000000002e-11;
    xinc[2] = pi_() * .25;
    xinc[3] = pi_() * .5;
    xinc[4] = pi_() * .75;
    xinc[5] = pi_() - 5.0000000000000002e-11;
    xinc[6] = pi_();

/*     Expected longitude of the ascending node: */

    for (ilnode = 1; ilnode <= 4; ++ilnode) {
	xlnode[(i__1 = ilnode - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("xlnode", 
		i__1, "f_oscelt__", (ftnlen)212)] = (ilnode - 1) * twopi_() / 
		4;
    }

/*     Expected mean anomaly: */

    for (im0 = 1; im0 <= 8; ++im0) {
	xm0[(i__1 = im0 - 1) < 8 && 0 <= i__1 ? i__1 : s_rnge("xm0", i__1, 
		"f_oscelt__", (ftnlen)219)] = (im0 - 1) * twopi_() / 8;
    }

/*     Epoch: */

    et = 1e8;

/*     Expected perifocal distance: */

    xrp[0] = 262144.;

/*     GM of central body (we make this the cube of RP so we may */
/*     recover an eccentricity of zero when we have a circular orbit): */

    mu = 18014398509481984.;

/*     For a variety of element sets, we'll use CONICS to produce */
/*     the equivalent state vector.  We'll then try to recover */
/*     the elements from the state vector. */

    for (iargp = 1; iargp <= 8; ++iargp) {
	for (iecc = 1; iecc <= 6; ++iecc) {
	    for (iinc = 1; iinc <= 7; ++iinc) {
		for (ilnode = 1; ilnode <= 4; ++ilnode) {
		    for (im0 = 1; im0 <= 8; ++im0) {

/*                    Assign the input elements for this test case. */

			inelts[0] = xrp[0];
			inelts[1] = xecc[(i__1 = iecc - 1) < 6 && 0 <= i__1 ? 
				i__1 : s_rnge("xecc", i__1, "f_oscelt__", (
				ftnlen)256)];
			inelts[2] = xinc[(i__1 = iinc - 1) < 7 && 0 <= i__1 ? 
				i__1 : s_rnge("xinc", i__1, "f_oscelt__", (
				ftnlen)257)];
			inelts[3] = xlnode[(i__1 = ilnode - 1) < 4 && 0 <= 
				i__1 ? i__1 : s_rnge("xlnode", i__1, "f_osce"
				"lt__", (ftnlen)258)];
			inelts[4] = xargp[(i__1 = iargp - 1) < 8 && 0 <= i__1 
				? i__1 : s_rnge("xargp", i__1, "f_oscelt__", (
				ftnlen)259)];
			inelts[5] = xm0[(i__1 = im0 - 1) < 8 && 0 <= i__1 ? 
				i__1 : s_rnge("xm0", i__1, "f_oscelt__", (
				ftnlen)260)];
			inelts[6] = et;
			inelts[7] = mu;

/*                    Set the expected elements. */

			for (i__ = 1; i__ <= 8; ++i__) {
			    xelts[(i__1 = i__ - 1) < 8 && 0 <= i__1 ? i__1 : 
				    s_rnge("xelts", i__1, "f_oscelt__", (
				    ftnlen)269)] = inelts[(i__2 = i__ - 1) < 
				    8 && 0 <= i__2 ? i__2 : s_rnge("inelts", 
				    i__2, "f_oscelt__", (ftnlen)269)];
			}
/*                    In some cases, these are not the input */
/*                    elements, so adjust accordingly: */

/*                    If the input inclination is close to 0 or pi, */
/*                    the output inclination will be rounded.  The */
/*                    longitude of the ascending node becomes 0. */

			if ((d__1 = inelts[2] + 0., abs(d__1)) < 1e-10) {
			    xelts[2] = 0.;
			    xelts[3] = 0.;
			} else if ((d__1 = inelts[2] - pi_(), abs(d__1)) < 
				1e-10) {
			    xelts[2] = pi_();
			    xelts[3] = 0.;
			}

/*                    If the eccentricity is "close" to 1, make it 1. */

			xelts[1] = exact_(&xelts[1], &c_b39, &c_b40);

/*                    Set up the test description for the TCASE call. */

			s_copy(tstdsc, "RP = #; ECC = #; INC = #; LNODE = #;"
				" ARGP = #; M0 = #; ET = #;, MU = #", (ftnlen)
				400, (ftnlen)70);
			for (i__ = 1; i__ <= 8; ++i__) {
			    repmd_(tstdsc, "#", &inelts[(i__1 = i__ - 1) < 8 
				    && 0 <= i__1 ? i__1 : s_rnge("inelts", 
				    i__1, "f_oscelt__", (ftnlen)303)], &c__14,
				     tstdsc, (ftnlen)400, (ftnlen)1, (ftnlen)
				    400);
			}
			tcase_(tstdsc, (ftnlen)400);

/*                    Obtain the equivalent state vector, then call */
/*                    OSCELT. */

			conics_(inelts, &et, state);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			oscelt_(state, &et, &mu, elts);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
/*                     WRITE (*,*) 'ELTS(2) = ', ELTS(2) */
/*                     WRITE (*,*) 'ELTS(3) = ', ELTS(3) */
			succes = TRUE_;

/*                    See how well we did. */

/*                    Set the tolerance to use for RP; acknowledge */
/*                    that we can't recover RP for nearly */
/*                    parabolic orbits. */

			if (inelts[1] == 1.) {
			    tol = 1e-12;
			} else if ((d__1 = inelts[1] - 1., abs(d__1)) < 1e-10)
				 {
			    tol = .001;
			} else if ((d__1 = inelts[1] - 1., abs(d__1)) < 1e-4) 
				{
			    tol = 1e-8;
			} else {
			    tol = 1e-12;
			}
			chcksd_("RP", elts, "~/", xelts, &tol, ok, (ftnlen)2, 
				(ftnlen)2);
			succes = succes && *ok;

/*                    We use the same tolerances for eccentricity */
/*                    as for inclination. */

			chcksd_("ECC", &elts[1], "~", &xelts[1], &tol, ok, (
				ftnlen)3, (ftnlen)1);
			succes = succes && *ok;

/*                    We should always be able to recover inclination */
/*                    reasonably accurately. */

			tol = 1e-10;
			chcksd_("INC", &elts[2], "~", &xelts[2], &tol, ok, (
				ftnlen)3, (ftnlen)1);
			succes = succes && *ok;

/*                    When the inclination is not too close to 0 */
/*                    or pi, we should be able to recover it */
/*                    reasonably accurately. */

			if (sin(xelts[3]) > 1e-10) {
			    tol = 1e-10;
			} else {
			    tol = 1e-8;
			}
			if ((d__1 = elts[3] - xelts[3], abs(d__1)) <= pi_()) {
			    chcksd_("LNODE", &elts[3], "~", &xelts[3], &tol, 
				    ok, (ftnlen)5, (ftnlen)1);
			} else {
			    if (elts[3] > xelts[3]) {
				xelts[3] += twopi_();
			    } else {
				xelts[3] -= twopi_();
			    }
			    chcksd_("LNODE", &elts[3], "~", &xelts[3], &tol, 
				    ok, (ftnlen)5, (ftnlen)1);
			}
			succes = succes && *ok;

/*                    Check ARGP: */

/*                    When the eccentricity is not too close to */
/*                    zero and the inclination is not too close to */
/*                    zero or pi, we can use a reasonably tight tolerance */
/*                    for ARGP.  When the eccentricity is determined */
/*                    by OSCELT to be zero, we know exactly what */
/*                    ARGP is supposed to be.  When the eccentricity */
/*                    is very close to but not equal to zero, ARGP */
/*                    can be almost anything.  For these cases all */
/*                    we can do is check ARGP+M0. */

/*                    Note that our path is governed by the eccentricity */
/*                    found by OSCELT, since an input eccentricity of */
/*                    zero may not be recovered as such. */

			if (inelts[2] > 1e-10 && inelts[2] < pi_() - 1e-10) {

/*                       These are the normal inclination cases. */

			    if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-10) {
				tol = dpmax_();
			    } else if ((d__1 = inelts[1] - 1., abs(d__1)) <= 
				    1e-6) {
				tol = .001;
			    } else if ((d__1 = inelts[1] - 1., abs(d__1)) <= 
				    1e-4) {
				tol = 1e-10;
			    } else if (elts[1] > 1e-5) {
				tol = 1e-12;
			    } else if (elts[1] > 1e-6) {
				tol = 1e-10;
			    } else if (elts[1] == 0.) {
				tol = 1e-12;
			    } else {
				tol = dpmax_();
			    }
			} else if (inelts[2] == 0. || inelts[2] == pi_()) {

/*                       These are exceptional, but reasonably */
/*                       well-behaved inclination cases. */

			    if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-10) {
				tol = dpmax_();
			    } else if ((d__1 = inelts[1] - 1., abs(d__1)) <= 
				    1e-6) {
				tol = .001;
			    } else if ((d__1 = inelts[1] - 1., abs(d__1)) <= 
				    1e-5) {
				tol = 1e-8;
			    } else if ((d__1 = inelts[1] - 1., abs(d__1)) <= 
				    .001) {
				tol = 1e-10;
			    } else if (elts[1] > 1e-6) {
				tol = 1e-12;
			    } else if (elts[1] == 0.) {
				tol = 1e-12;
			    } else {
				tol = dpmax_();
			    }
			} else {
			    if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-10) {
				tol = dpmax_();
			    } else if (elts[1] > 1e-10 || elts[1] == 0.) {
				tol = 1e-10;
			    } else {
				tol = dpmax_();
			    }
			}

/*                    When the eccentricity is zero, the argument of */
/*                    periapse is absorbed into the mean anomaly.  This */
/*                    only happens if OSCELT is able to determine that */
/*                    the eccentricity is zero, so test ELTS(2). */

			if (elts[1] == 0.) {
			    xelts[5] = xelts[4] + xelts[5];
			    xelts[4] = 0.;
			}

/*                    Adjust our expected value of ARGP if */
/*                    LNODE has been set to zero and if the */
/*                    eccentricity is non-zero.  The sign of */
/*                    the adjustment depends on INC. */

			if (elts[3] == 0. && inelts[3] != 0. && elts[1] != 0. 
				&& elts[2] == 0.) {
			    xelts[4] += inelts[3] - elts[3];
			} else if (elts[3] == 0. && inelts[3] != 0. && elts[1]
				 != 0. && elts[2] == pi_()) {
			    xelts[4] += elts[3] - inelts[3];
			}
			if (xelts[4] >= twopi_()) {
			    xelts[4] -= twopi_();
			} else if (xelts[4] < 0.) {
			    xelts[4] += twopi_();
			}
			if ((d__1 = elts[4] - xelts[4], abs(d__1)) <= pi_()) {
			    chcksd_("ARGP", &elts[4], "~", &xelts[4], &tol, 
				    ok, (ftnlen)4, (ftnlen)1);
			} else {
			    if (elts[4] > xelts[4]) {
				xelts[4] += twopi_();
			    } else {
				xelts[4] -= twopi_();
			    }
			    chcksd_("ARGP", &elts[4], "~", &xelts[4], &tol, 
				    ok, (ftnlen)4, (ftnlen)1);
			}
			succes = succes && *ok;

/*                    Check M0: */

			if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-10) {
			    tol = dpmax_();
			} else if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-6) {
			    tol = .001;
			} else if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-5) {
			    tol = 1e-6;
			} else if ((d__1 = elts[1] - 1., abs(d__1)) <= 1e-4) {
			    tol = 1e-8;
			} else if (elts[1] > 1e-10) {
			    tol = 1e-12;
			} else if (elts[1] == 0.) {
			    tol = 1e-12;
			} else {
			    tol = dpmax_();
			}
			succes = succes && *ok;

/*                    If the eccentricity is zero and the inclination */
/*                    is zero or pi, the original */
/*                    longitude of the ascending node is absorbed into */
/*                    M0. */

			if (elts[1] == 0. && elts[2] == 0.) {

/*                       Eccentricity and inclination were both */
/*                       found to be zero by OSCELT.  The input */
/*                       value of the argument of periapse is going */
/*                       to be added onto the mean anomaly. */

			    xelts[5] += inelts[3];
			} else if (elts[1] == 0. && elts[2] == pi_()) {

/*                       Eccentricity was found to be zero and */
/*                       inclination was found to be pi by OSCELT. */
/*                       The input value of the argument of periapse */
/*                       is going to be subtracted from the mean anomaly. */

			    xelts[5] -= inelts[3];
			}
			if ((d__1 = elts[5] - xelts[5], abs(d__1)) <= pi_()) {
			    chcksd_("M0", &elts[5], "~", &xelts[5], &tol, ok, 
				    (ftnlen)2, (ftnlen)1);
			} else {
			    if (elts[5] > xelts[5]) {
				xelts[5] += twopi_();
			    } else {
				xelts[5] -= twopi_();
			    }
			    chcksd_("M0", &elts[5], "~", &xelts[5], &tol, ok, 
				    (ftnlen)2, (ftnlen)1);
			}
			succes = succes && *ok;
			chcksd_("MU", &elts[7], "=", &xelts[7], &c_b70, ok, (
				ftnlen)2, (ftnlen)1);

/*                    Now that we've obtained elements, see whether */
/*                    we can use them to obtain the state we got */
/*                    back from CONICS the first time. */

			conics_(elts, &et, state2);
			if ((d__1 = inelts[1] - 1., abs(d__1)) <= 1e-4) {
			    tol = .001;
			} else if ((d__1 = inelts[1] - 1., abs(d__1)) <= .001)
				 {
			    tol = 1e-6;
			} else if (inelts[2] == 0. || inelts[2] >= pi_()) {
			    tol = 1e-12;
			} else if (inelts[2] <= 1e-10 || inelts[2] >= pi_() - 
				1e-10) {
			    tol = 1e-10;
			} else {
			    tol = 1e-12;
			}
			chckad_("Position", state2, "~~/", state, &c__3, &tol,
				 ok, (ftnlen)8, (ftnlen)3);
			chckad_("Velocity", &state2[3], "~~/", &state[3], &
				c__3, &tol, ok, (ftnlen)8, (ftnlen)3);
			if (! succes) {
/*                        WRITE (*, *) 'ELTS: ' */
/*                        WRITE (*, '(8(1X,E25.16))') ELTS */
			    succes = TRUE_;
			}
		    }
		}
	    }
	}
    }
    t_success__(ok);
    return 0;
} /* f_oscelt__ */

