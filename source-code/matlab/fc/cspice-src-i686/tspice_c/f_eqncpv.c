/* f_eqncpv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b9 = 5e-12;
static integer c__6 = 6;

/* $Procedure      F_EQNCPV (Family of tests for EQNCPV) */
/* Subroutine */ int f_eqncpv__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    double sqrt(doublereal), sin(doublereal), cos(doublereal), tan(doublereal)
	    ;
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal node, eqel[9], argp, temp[36]	/* was [6][6] */, elts[8];
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *), mxvg_(doublereal *, 
	    doublereal *, integer *, integer *, doublereal *);
    doublereal a;
    integer i__, j;
    doublereal k[3], n, p, x[3], y[3], z__[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal theta;
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *);
    doublereal rapol, state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */, m0;
    extern /* Subroutine */ int ucrss_(doublereal *, doublereal *, doublereal 
	    *);
    doublereal t0, rotto[36]	/* was [6][6] */;
    extern /* Subroutine */ int t_success__(logical *);
    doublereal state1[6], state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal gm, et;
    extern doublereal halfpi_(void);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    doublereal decpol, fivdpd, tendpd;
    extern /* Subroutine */ int conics_(doublereal *, doublereal *, 
	    doublereal *), eqncpv_(doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *), xposeg_(doublereal *, 
	    integer *, integer *, doublereal *);
    doublereal tmpsta[6], rotfrm[36]	/* was [6][6] */, toinrt[9]	/* 
	    was [3][3] */, ecc, inc;
    extern doublereal rpd_(void);
    doublereal rot[9]	/* was [3][3] */;
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;

/* $ Abstract */

/*     This routine performs a basic comparison of EQNCPV when */
/*     the pole of the reference frame is aligned with the */
/*     z-axis of the inertial frame and the rate of change of */
/*     the longitude of the node and argument of periapse is */
/*     zero. */

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

/* -    TSPICE Version 1.1.0, 27-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in MXV calls. */

/* -    Version 2.0.0  14-JAN-1998  (WLT) */

/*     The relative error tests were relaxed from 1.0D-12 to 5.0D-12 */
/*     so that comparisons will pass on the PC which for some reason */
/*     isn't able to achieve the same performance as the UNIX machines. */



/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_EQNCPV", (ftnlen)8);
    tcase_("This compares EQNCPV with CONICS for the case when the rates of "
	    "node and argument of periapse are zero and the pole of the centr"
	    "al frame is aligned with the pole of an inertial frame. ", (
	    ftnlen)184);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    elts[0] = p;
    elts[1] = ecc;
    elts[2] = inc;
    elts[3] = node;
    elts[4] = argp;
    elts[5] = m0;
    elts[6] = t0;
    elts[7] = gm;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = 0.;
    eqel[7] = n;
    eqel[8] = 0.;
    rapol = -halfpi_();
    decpol = halfpi_();
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	conics_(elts, &et, state1);
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("POSITION", state2, "~/", state1, &c__3, &c_b9, ok, (ftnlen)8,
		 (ftnlen)2);
	chckad_("VELOCITY", &state2[3], "~/", &state1[3], &c__3, &c_b9, ok, (
		ftnlen)8, (ftnlen)2);
    }
    tcase_("Test to make sure we can accurately compute the state of an obje"
	    "ct that has non-zero rates for the longitude of the ascending no"
	    "de. ", (ftnlen)132);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    elts[0] = p;
    elts[1] = ecc;
    elts[2] = inc;
    elts[3] = node;
    elts[4] = argp;
    elts[5] = m0;
    elts[6] = t0;
    elts[7] = gm;

/*        We want a rate for the node of 10 degrees/day. */

    tendpd = rpd_() * 1.1574074074074075e-4;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = tendpd;
    eqel[7] = n + tendpd;
    eqel[8] = tendpd;
    rapol = -halfpi_();
    decpol = halfpi_();
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	theta = (et - t0) * tendpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * tendpd;
	xform[4] = cos(theta) * tendpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * tendpd;
	xform[10] = -sin(theta) * tendpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	conics_(elts, &et, state);
	mxvg_(xform, state, &c__6, &c__6, state1);
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("POSITION", state2, "~/", state1, &c__3, &c_b9, ok, (ftnlen)8,
		 (ftnlen)2);
	chckad_("VELOCITY", &state2[3], "~/", &state1[3], &c__3, &c_b9, ok, (
		ftnlen)8, (ftnlen)2);
    }
    tcase_("Test to make sure that we can accurately compute the state of an"
	    " object that has a non-zero rate for the argument of periapse. ", 
	    (ftnlen)127);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    elts[0] = p;
    elts[1] = ecc;
    elts[2] = inc;
    elts[3] = node;
    elts[4] = argp;
    elts[5] = m0;
    elts[6] = t0;
    elts[7] = gm;

/*        We want a rate for the node of 10 degrees/day. */

    fivdpd = rpd_() * 5.7870370370370373e-5;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd;
    eqel[7] = n + fivdpd;
    eqel[8] = 0.;
    rapol = -halfpi_();
    decpol = halfpi_();
    rot[0] = cos(node);
    rot[1] = sin(node);
    rot[2] = 0.;
    rot[3] = -cos(inc) * sin(node);
    rot[4] = cos(inc) * cos(node);
    rot[5] = sin(inc);
    rot[6] = sin(inc) * sin(node);
    rot[7] = -sin(inc) * cos(node);
    rot[8] = cos(inc);
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    rotto[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "rotto", i__1, "f_eqncpv__", (ftnlen)351)] = rot[(i__2 = 
		    i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge("rot", 
		    i__2, "f_eqncpv__", (ftnlen)351)];
	    rotto[(i__1 = i__ + 3 + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 
		    : s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)352)] = rot[
		    (i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot", i__2, "f_eqncpv__", (ftnlen)352)];
	    rotto[(i__1 = i__ + 3 + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)353)] = 0.;
	    rotto[(i__1 = i__ + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)354)] = 0.;
	}
    }
    xposeg_(rotto, &c__6, &c__6, rotfrm);
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	theta = (et - t0) * fivdpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * fivdpd;
	xform[4] = cos(theta) * fivdpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * fivdpd;
	xform[10] = -sin(theta) * fivdpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	mxmg_(xform, rotfrm, &c__6, &c__6, &c__6, temp);
	mxmg_(rotto, temp, &c__6, &c__6, &c__6, xform);
	conics_(elts, &et, state);
	mxvg_(xform, state, &c__6, &c__6, state1);
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("POSITION", state2, "~/", state1, &c__3, &c_b9, ok, (ftnlen)8,
		 (ftnlen)2);
	chckad_("VELOCITY", &state2[3], "~/", &state1[3], &c__3, &c_b9, ok, (
		ftnlen)8, (ftnlen)2);
    }
    tcase_("Test the equinoctial propagator when precession of both the node"
	    " and argument of periapse are non-zero. ", (ftnlen)104);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    elts[0] = p;
    elts[1] = ecc;
    elts[2] = inc;
    elts[3] = node;
    elts[4] = argp;
    elts[5] = m0;
    elts[6] = t0;
    elts[7] = gm;

/*        We want a rate for the node of 10 degrees/day. */

    fivdpd = rpd_() * 5.7870370370370373e-5;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd + tendpd;
    eqel[7] = n + fivdpd + tendpd;
    eqel[8] = tendpd;
    rapol = -halfpi_();
    decpol = halfpi_();
    rot[0] = cos(node);
    rot[1] = sin(node);
    rot[2] = 0.;
    rot[3] = -cos(inc) * sin(node);
    rot[4] = cos(inc) * cos(node);
    rot[5] = sin(inc);
    rot[6] = sin(inc) * sin(node);
    rot[7] = -sin(inc) * cos(node);
    rot[8] = cos(inc);
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    rotto[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "rotto", i__1, "f_eqncpv__", (ftnlen)485)] = rot[(i__2 = 
		    i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge("rot", 
		    i__2, "f_eqncpv__", (ftnlen)485)];
	    rotto[(i__1 = i__ + 3 + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 
		    : s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)486)] = rot[
		    (i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot", i__2, "f_eqncpv__", (ftnlen)486)];
	    rotto[(i__1 = i__ + 3 + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)487)] = 0.;
	    rotto[(i__1 = i__ + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)488)] = 0.;
	}
    }
    xposeg_(rotto, &c__6, &c__6, rotfrm);
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	theta = (et - t0) * fivdpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * fivdpd;
	xform[4] = cos(theta) * fivdpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * fivdpd;
	xform[10] = -sin(theta) * fivdpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	mxmg_(xform, rotfrm, &c__6, &c__6, &c__6, temp);
	mxmg_(rotto, temp, &c__6, &c__6, &c__6, xform);
	conics_(elts, &et, state1);
	mxvg_(xform, state1, &c__6, &c__6, state);
	theta = (et - t0) * tendpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * tendpd;
	xform[4] = cos(theta) * tendpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * tendpd;
	xform[10] = -sin(theta) * tendpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	mxvg_(xform, state, &c__6, &c__6, state1);
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("POSITION", state2, "~/", state1, &c__3, &c_b9, ok, (ftnlen)8,
		 (ftnlen)2);
	chckad_("VELOCITY", &state2[3], "~/", &state1[3], &c__3, &c_b9, ok, (
		ftnlen)8, (ftnlen)2);
    }
    tcase_("Apply the same test as the previous case with the RA and DEC of "
	    "the pole of the equatorial frame set so that the axes of the equ"
	    "atorial frame are not aligned with the inertial frame. ", (ftnlen)
	    183);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    elts[0] = p;
    elts[1] = ecc;
    elts[2] = inc;
    elts[3] = node;
    elts[4] = argp;
    elts[5] = m0;
    elts[6] = t0;
    elts[7] = gm;

/*        We want a rate for the node of 10 degrees/day. */

    fivdpd = rpd_() * 5.7870370370370373e-5;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd + tendpd;
    eqel[7] = n + fivdpd + tendpd;
    eqel[8] = tendpd;
    rapol = rpd_() * 30.f;
    decpol = rpd_() * 60.f;
    rot[0] = cos(node);
    rot[1] = sin(node);
    rot[2] = 0.;
    rot[3] = -cos(inc) * sin(node);
    rot[4] = cos(inc) * cos(node);
    rot[5] = sin(inc);
    rot[6] = sin(inc) * sin(node);
    rot[7] = -sin(inc) * cos(node);
    rot[8] = cos(inc);
    z__[0] = cos(rapol) * cos(decpol);
    z__[1] = sin(rapol) * cos(decpol);
    z__[2] = sin(decpol);
    k[0] = 0.;
    k[1] = 0.;
    k[2] = 1.;
    ucrss_(k, z__, x);
    ucrss_(z__, x, y);
    toinrt[0] = x[0];
    toinrt[1] = x[1];
    toinrt[2] = x[2];
    toinrt[3] = y[0];
    toinrt[4] = y[1];
    toinrt[5] = y[2];
    toinrt[6] = z__[0];
    toinrt[7] = z__[1];
    toinrt[8] = z__[2];
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    rotto[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "rotto", i__1, "f_eqncpv__", (ftnlen)694)] = rot[(i__2 = 
		    i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge("rot", 
		    i__2, "f_eqncpv__", (ftnlen)694)];
	    rotto[(i__1 = i__ + 3 + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 
		    : s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)695)] = rot[
		    (i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "rot", i__2, "f_eqncpv__", (ftnlen)695)];
	    rotto[(i__1 = i__ + 3 + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)696)] = 0.;
	    rotto[(i__1 = i__ + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("rotto", i__1, "f_eqncpv__", (ftnlen)697)] = 0.;
	}
    }
    xposeg_(rotto, &c__6, &c__6, rotfrm);
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	theta = (et - t0) * fivdpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * fivdpd;
	xform[4] = cos(theta) * fivdpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * fivdpd;
	xform[10] = -sin(theta) * fivdpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	mxmg_(xform, rotfrm, &c__6, &c__6, &c__6, temp);
	mxmg_(rotto, temp, &c__6, &c__6, &c__6, xform);
	conics_(elts, &et, state1);
	mxvg_(xform, state1, &c__6, &c__6, state);
	theta = (et - t0) * tendpd;
	xform[0] = cos(theta);
	xform[1] = sin(theta);
	xform[2] = 0.;
	xform[3] = -sin(theta) * tendpd;
	xform[4] = cos(theta) * tendpd;
	xform[5] = 0.;
	xform[6] = -sin(theta);
	xform[7] = cos(theta);
	xform[8] = 0.;
	xform[9] = -cos(theta) * tendpd;
	xform[10] = -sin(theta) * tendpd;
	xform[11] = 0.;
	xform[12] = 0.;
	xform[13] = 0.;
	xform[14] = 1.;
	xform[15] = 0.;
	xform[16] = 0.;
	xform[17] = 0.;
	xform[18] = 0.;
	xform[19] = 0.;
	xform[20] = 0.;
	xform[21] = cos(theta);
	xform[22] = sin(theta);
	xform[23] = 0.;
	xform[24] = 0.;
	xform[25] = 0.;
	xform[26] = 0.;
	xform[27] = -sin(theta);
	xform[28] = cos(theta);
	xform[29] = 0.;
	xform[30] = 0.;
	xform[31] = 0.;
	xform[32] = 0.;
	xform[33] = 0.;
	xform[34] = 0.;
	xform[35] = 1.;
	mxvg_(xform, state, &c__6, &c__6, state1);
	mxv_(toinrt, state1, tmpsta);
	mxv_(toinrt, &state1[3], &tmpsta[3]);
	moved_(tmpsta, &c__6, state1);
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("POSITION", state2, "~/", state1, &c__3, &c_b9, ok, (ftnlen)8,
		 (ftnlen)2);
	chckad_("VELOCITY", &state2[3], "~/", &state1[3], &c__3, &c_b9, ok, (
		ftnlen)8, (ftnlen)2);
    }
    t_success__(ok);
    return 0;
} /* f_eqncpv__ */

