/* f_spke15.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__6 = 6;
static doublereal c_b116 = 1e-12;
static doublereal c_b131 = 1e-13;
static doublereal c_b147 = 1e-11;
static doublereal c_b150 = 1e-10;
static integer c__3 = 3;
static doublereal c_b177 = 1e-4;

/* $Procedure      F_SPKE15  (  Test routine SPKE15  ) */
/* Subroutine */ int f_spke15__(logical *pass)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    double cos(doublereal), sin(doublereal), sqrt(doublereal);

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal dmdt;
    integer item[22]	/* was [11][2] */;
    doublereal mygm, elts0[8], elts1[8];
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal myecc;
    extern /* Subroutine */ int spke15_(doublereal *, doublereal *, 
	    doublereal *), spke53_(doublereal *, doublereal *, doublereal *);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen), vcrss_(doublereal *, 
	    doublereal *, doublereal *);
    extern doublereal twopi_(void);
    extern /* Subroutine */ int t_success__(logical *);
    doublereal angmo1[3], angmo2[3], state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    doublereal adnode, et;
    logical ok;
    doublereal ednode;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal adperi, edperi, record[34]	/* was [17][2] */, period, 
	    radius;
    extern /* Subroutine */ int oscelt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal sma, pos[3], myp, myj2;

/* $ Abstract */

/*     This test family checks the behavior of the SPICE routine */
/*     SPKE15 --- the evaluator for type 15 SPK segments. */

/*     It firsts exercises all of the listed exceptions for SPKE15. */

/*     Next it compares the results of the type 15 evaluator against */
/*     a modified type 53 evaluator provided by MASL. */

/*     Finally a few simple consistency checks are performed to check */
/*     that precession of the lines of nodes and apsides move at the */
/*     correct rate,  Angular momentum is constant and that discrete */
/*     integration of the intitial state approximately yields the */
/*     state one second later. */

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

/* -    SPICELIB Version 1.1.1, 14-DEC-2001 (EDW) */

/*        Altered Hyperbolic Angular Momentum test case */
/*        to us a vector relative comparison between the */
/*        experimental and theoretical angular momentum vectors. */
/*        The previous version of the test performed relative */
/*        error comparision on the vector components. */

/* -    SPICELIB Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Functions. */

/* -& */


/*     Testing Utilities */


/*     Spicelib Functions */


/*     Check out the error handling first. */


/*     Open the family of tests for SPKE15. */

    topen_("F_SPKE15", (ftnlen)8);
    item[0] = 1;
    item[1] = 2;
    item[2] = 5;
    item[3] = 8;
    item[4] = 9;
    item[6] = 10;
    item[7] = 11;
    item[8] = 14;
    item[9] = 15;
    item[10] = 16;
    item[5] = 17;
    item[11] = 1;
    item[12] = 2;
    item[13] = 5;
    item[14] = 8;
    item[15] = 9;
    item[16] = 10;
    item[17] = 11;
    item[18] = 12;
    item[19] = 15;
    item[20] = 16;
    item[21] = 17;
    for (i__ = 1; i__ <= 17; ++i__) {
	record[(i__1 = i__ - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge("record", 
		i__1, "f_spke15__", (ftnlen)183)] = 0.;
	record[(i__1 = i__ + 16) < 34 && 0 <= i__1 ? i__1 : s_rnge("record", 
		i__1, "f_spke15__", (ftnlen)184)] = 0.;
    }
    et = 7200.;

/*     Here's the basic strategy for each test case. */

/*        We set up conditions in the input */
/*        records that should yield exceptions. */

/*        We check for the exception */

/*        Finally set the exceptional item to */
/*        something realistic so that future tests */
/*        won't be tripped up by this exceptional */
/*        value. */

/*     Note: we set the values for both the type 53 record and */
/*     type 15 record at the same time so that they always */
/*     represent the same orbit.  We do this even when the type 53 */
/*     record is not used. */


/*     The semi-latus rectum is supposed to be positive.  Start */
/*     out at zero and then set it to something reasonable. */

    tcase_("Semi-latus rectum exception", (ftnlen)27);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 8) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)218)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)218)] = 0.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADLATUSRECTUM)", &ok, (ftnlen)21);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 8) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)225)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)225)] = 2e4;
    }

/*     Negative eccentricities should produce exceptions.  After */
/*     checking that this is so set the eccentricity to something */
/*     yielding a periodic orbit. */

    tcase_("Eccentricity Exception", (ftnlen)22);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 7) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)237)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)237)] = -1.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADECCENTRICITY)", &ok, (ftnlen)22);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 7) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)244)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)244)] = .1;
    }

/*     The central mass must be positive.  Zero or less should */
/*     trigger an exception. Try zero and -1.  After that we */
/*     use the mass of the earth. */

    tcase_("Central Mass Exception --- mass 0", (ftnlen)33);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 3) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)256)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)256)] = 0.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(NONPOSITIVEMASS)", &ok, (ftnlen)22);
    tcase_("Central Mass Exception --- mass -1", (ftnlen)34);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 3) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)265)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)265)] = -1.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(NONPOSITIVEMASS)", &ok, (ftnlen)22);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 3) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)272)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)272)] = 398600.447703261138f;
    }

/*     Only a zero trajectory pole can produce a problem.  By */
/*     construction we already have one. */

    tcase_("Trajectory Pole Exception", (ftnlen)25);
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADVECTOR)", &ok, (ftnlen)16);

/*        Set the trajectory pole to 45 degree inclination */

    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 10) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)289)] + 1 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)289)] = cos(pi_() / 4.);
	record[(i__2 = item[(i__1 = i__ * 11 - 10) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)290)] + 2 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)290)] = sin(pi_() / 4.);
    }

/*     Only a zero periapsis vector yields an exception.  We */
/*     already have this by construction.  After testing make */
/*     a periapsis vector that is orthogonal to the trajectory */
/*     pole vector. */

    tcase_("Periapsis Vector Exception", (ftnlen)26);
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADVECTOR)", &ok, (ftnlen)16);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)306)] + 1 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)306)] = sin(pi_() / 4.);
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)307)] + 2 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)307)] = -cos(pi_() / 4.);
    }

/*     Only a zero central body pole vector can yield an exception. */
/*     We have such a situation by construction.  After checking */
/*     this, align the pole with the Z axis. */

    tcase_("Pole Vector Exception", (ftnlen)21);
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADVECTOR)", &ok, (ftnlen)16);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 4) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)322)] + 2 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)322)] = 1.;
    }

/*     Anything less than zero should trigger an exception.  After */
/*     checking, set the equatorial radius to that of the earth. */

    tcase_("Equatorial Radius Exception", (ftnlen)27);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 1) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)333)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)333)] = -1.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADRADIUS)", &ok, (ftnlen)16);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 1) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)340)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)340)] = 6378.184;
    }

/*     If the periapse is not nearly perpepndicular to the */
/*     trajectory pole, we should get an exception.  Create */
/*     a vector that isn't perpendicular to the trajectory pole */
/*     by messing up the sign on the z-component. */

    tcase_("Bad Initial Conditions", (ftnlen)22);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)354)] + 1 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)354)] = 1.;
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)355)] + 2 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)355)] = 0.;
    }
    spke15_(&et, record, state);
    chckxc_(&c_true, "SPICE(BADINITSTATE)", &ok, (ftnlen)19);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)363)] + 1 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)363)] = sin(pi_() / 4.);
	record[(i__2 = item[(i__1 = i__ * 11 - 9) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)364)] + 2 + i__ * 
		17 - 18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, 
		"f_spke15__", (ftnlen)364)] = -cos(pi_() / 4.);
    }

/*     That takes care of all the exception tests.  Next see if */
/*     we get the same results with the two different implementations. */

/*     Check to make sure that type 53 and type 15 agree */
/*     when J2 is zero. */

    tcase_("Elliptic Orbit, J2 = 0", (ftnlen)22);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 2) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)378)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)378)] = 0.;
    }
    spke53_(&et, &record[17], state2);
    spke15_(&et, record, state);
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b116, &ok, (ftnlen)5, (
	    ftnlen)2);

/*     Check to make sure that type 53 and type 15 agree for */
/*     J2 non-zero.  More specifically when J2 is that of the */
/*     earth. */

    tcase_("Eliptic Orbit, J2 of Earth", (ftnlen)26);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 2) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)396)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)396)] = .001082616;
	record[(i__2 = item[(i__1 = i__ * 11 - 5) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)397)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)397)] = 0.;
    }
    spke53_(&et, &record[17], state);
    spke15_(&et, record, state2);
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b131, &ok, (ftnlen)5, (
	    ftnlen)2);

/*     Check that the precession is what is predicted from the */
/*     equations.  We use oscelt to determine how far the node */
/*     moves in one orbit. */

    tcase_("Check Precession", (ftnlen)16);
    myp = record[(i__1 = item[3] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge("rec"
	    "ord", i__1, "f_spke15__", (ftnlen)415)];
    mygm = record[(i__1 = item[8] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge(
	    "record", i__1, "f_spke15__", (ftnlen)416)];
    myecc = record[(i__1 = item[4] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge(
	    "record", i__1, "f_spke15__", (ftnlen)417)];
    myj2 = record[(i__1 = item[9] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge(
	    "record", i__1, "f_spke15__", (ftnlen)418)];
    radius = record[(i__1 = item[10] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge(
	    "record", i__1, "f_spke15__", (ftnlen)419)];
/* Computing 2nd power */
    d__1 = myecc;
    sma = myp / (1 - d__1 * d__1);
/* Computing 3rd power */
    d__1 = sma;
    dmdt = sqrt(mygm / (d__1 * (d__1 * d__1)));
    period = twopi_() / dmdt;
    spke15_(&et, record, state);
    oscelt_(state, &et, &mygm, elts0);
    et += period;
    spke15_(&et, record, state2);
    oscelt_(state2, &et, &mygm, elts1);

/*        ELTS        are equivalent conic elements describing the orbit */
/*                    of the body around its primary. The elements are, */
/*                    in order: */

/*                          RP      Perifocal distance. */
/*                          ECC     Eccentricity. */
/*                          INC     Inclination. */
/*                          LNODE   Longitude of the ascending node. */
/*                          ARGP    Argument of periapsis. */
/*                          M0      Mean anomaly at epoch. */
/*                          T0      Epoch. */
/*                          MU      Gravitational parameter. */

/* Computing 2nd power */
    d__1 = radius / myp;
    ednode = -twopi_() * 1.5 * myj2 * cos(elts0[2]) * (d__1 * d__1);
    adnode = elts1[3] - elts0[3];
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chcksd_("DNODE", &adnode, "~/", &ednode, &c_b147, &ok, (ftnlen)5, (ftnlen)
	    2);

/*        Next Check to see that periapse has moved by the "right" */
/*        amount. */

/* Computing 2nd power */
    d__1 = cos(elts0[2]);
/* Computing 2nd power */
    d__2 = radius / myp;
    edperi = twopi_() * 1.5 * myj2 * (d__1 * d__1 * 2.5 - .5) * (d__2 * d__2);
    adperi = elts1[4] - elts0[4];
    chcksd_("DPERI", &adperi, "~/", &edperi, &c_b150, &ok, (ftnlen)5, (ftnlen)
	    2);

/*     See that we get the same results for the hyperbolic case. */

    tcase_("Hyperbolic Orbit", (ftnlen)16);
    for (i__ = 1; i__ <= 2; ++i__) {
	record[(i__2 = item[(i__1 = i__ * 11 - 7) < 22 && 0 <= i__1 ? i__1 : 
		s_rnge("item", i__1, "f_spke15__", (ftnlen)474)] + i__ * 17 - 
		18) < 34 && 0 <= i__2 ? i__2 : s_rnge("record", i__2, "f_spk"
		"e15__", (ftnlen)474)] = 2.;
    }
    et = 7200.;
    spke53_(&et, &record[17], state);
    spke15_(&et, record, state2);
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b116, &ok, (ftnlen)5, (
	    ftnlen)2);

/*     Make sure the angular momentum is constant. */

    tcase_("Hyperbolic Angular Momentum", (ftnlen)27);
    record[(i__1 = item[4] - 1) < 34 && 0 <= i__1 ? i__1 : s_rnge("record", 
	    i__1, "f_spke15__", (ftnlen)491)] = 2.;
    et = 0.;
    spke15_(&et, record, state);
    vcrss_(state, &state[3], angmo1);
    et += 7.2e4;
    spke15_(&et, record, state);
    vcrss_(state, &state[3], angmo2);
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chckad_("ANGMO", angmo1, "~~/", angmo2, &c__3, &c_b116, &ok, (ftnlen)5, (
	    ftnlen)3);

/*     In this case we simply check that adding the velocity times */
/*     a delta time gives approximately the position. */

    tcase_("Discrete Hyperbolic Integration", (ftnlen)31);
    et = 0.;
    spke15_(&et, record, state);
    d__1 = et + 1.;
    spke15_(&d__1, record, state2);
    vadd_(state, &state[3], pos);
    chckxc_(&c_false, " ", &ok, (ftnlen)1);
    chckad_("Position", pos, "~/", state2, &c__3, &c_b177, &ok, (ftnlen)8, (
	    ftnlen)2);
    t_success__(&ok);
    return 0;
} /* f_spke15__ */

