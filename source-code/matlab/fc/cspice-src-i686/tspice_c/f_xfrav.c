/* f_xfrav.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b11 = 1e-14;
static integer c__3 = 3;
static doublereal c_b16 = -1.;
static integer c__6 = 6;

/* $Procedure      F_XFRAV ( Frame conversion to angular velocity) */
/* Subroutine */ int f_xfrav__(logical *ok)
{
    doublereal dmag;
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal dlat, long__;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    ), mxvg_(doublereal *, doublereal *, integer *, integer *, 
	    doublereal *);
    integer i__, j;
    doublereal r__, x[3];
    extern /* Subroutine */ int frame_(doublereal *, doublereal *, doublereal 
	    *), tcase_(char *, ftnlen);
    doublereal dlong;
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal vtemp[3], xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int xpose_(doublereal *, doublereal *), vcrss_(
	    doublereal *, doublereal *, doublereal *);
    doublereal v1[3], v2[3];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal state1[6], state2[6];
    extern /* Subroutine */ int rav2xf_(doublereal *, doublereal *, 
	    doublereal *), xf2rav_(doublereal *, doublereal *, doublereal *);
    doublereal xform1[36]	/* was [6][6] */, xform2[36]	/* was [6][6] 
	    */;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern doublereal pi_(void), halfpi_(void);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     latrec_(doublereal *, doublereal *, doublereal *, doublereal *), 
	    vsclip_(doublereal *, doublereal *);
    doublereal av1[3], av2[3];
    extern /* Subroutine */ int invstm_(doublereal *, doublereal *), tstmsg_(
	    char *, char *, ftnlen, ftnlen), vminus_(doublereal *, doublereal 
	    *), tstmsi_(integer *);
    doublereal mag, lat;
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal rot1[9]	/* was [3][3] */, rot2[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the "macro" routines XF2RAV and RAV2XF. */
/*     The tests performed check */

/*     1)  That the routines are nearly inverses of one another. */

/*     2)  That they produce equivalent objects for converting */
/*         states from one frame to another. */

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
/*        in VMINUS call. */

/* -    TSPICE Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Functions. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_XFRAV", (ftnlen)7);
    tcase_("This case tests that converting from a rotation and angular velo"
	    "city to a state transformation and then back to rotation and ang"
	    "ular velocity is very nearly the identity. 200 different sub-cas"
	    "es are examined.", (ftnlen)208);
    r__ = 1.;
    lat = -halfpi_();
    long__ = 0.;
    mag = .1;
    dlat = pi_() / 11.;
    dlong = pi_() / 10.;
    dmag = .1f;
    for (i__ = 1; i__ <= 10; ++i__) {
	lat += dlat;
	long__ = 0.;
	for (j = 1; j <= 20; ++j) {
	    tstmsg_("#", "The values of I and J are # and # respectively. ", (
		    ftnlen)1, (ftnlen)48);
	    tstmsi_(&i__);
	    tstmsi_(&j);
	    latrec_(&r__, &long__, &lat, rot1);
	    frame_(rot1, &rot1[3], &rot1[6]);
	    latrec_(&r__, &lat, &long__, x);
	    vscl_(&mag, x, av1);
	    rav2xf_(rot1, av1, xform);
	    xf2rav_(xform, rot2, av2);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("ROT2", rot2, "~", rot1, &c__9, &c_b11, ok, (ftnlen)4, (
		    ftnlen)1);
	    chckad_("AV2", av2, "~", av1, &c__3, &c_b11, ok, (ftnlen)3, (
		    ftnlen)1);
	    xpose_(rot1, rot2);
	    mxv_(rot1, av1, av2);
	    vsclip_(&c_b16, av2);
	    rav2xf_(rot2, av2, xform2);
	    invstm_(xform, xform1);
	    chckad_("XFORM1", xform1, "~", xform2, &c__9, &c_b11, ok, (ftnlen)
		    6, (ftnlen)1);
	    long__ += dlong;
	    mag += dmag;
	}
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("In this case we construct a rotation, angular velocity and state"
	    " transformation matrix.  We use these to compute velocities in t"
	    "wo different ways and compare the results. 200 sub-cases are exa"
	    "mined.", (ftnlen)198);
    r__ = 1.;
    lat = -halfpi_();
    long__ = 0.;
    mag = .1;
    dlat = pi_() / 11.;
    dlong = pi_() / 10.;
    dmag = .1f;
    state[0] = 6.;
    state[1] = 5.;
    state[2] = 4.;
    state[3] = 3.;
    state[4] = 2.;
    state[5] = 1.;
    for (i__ = 1; i__ <= 10; ++i__) {
	lat += dlat;
	long__ = 0.;
	for (j = 1; j <= 20; ++j) {
	    tstmsg_("#", "The values of I and J are # and # respectively. ", (
		    ftnlen)1, (ftnlen)48);
	    tstmsi_(&i__);
	    tstmsi_(&j);
	    latrec_(&r__, &long__, &lat, rot1);
	    frame_(rot1, &rot1[3], &rot1[6]);
	    latrec_(&r__, &lat, &long__, x);
	    vscl_(&mag, x, av1);
	    rav2xf_(rot1, av1, xform);

/*              First transform states using the state transformation */
/*              matrix. */

	    mxvg_(xform, state, &c__6, &c__6, state1);

/*              Now transform states using the rotation and angular */
/*              velocity.  Recall that the angular velocity of */
/*              FRAME1 with respect to FRAME2 is the opposite of */
/*              the angular velocity of FRAME2 with respect to FRAME1. */

	    vminus_(av1, av2);

/*              A part of the position and velocity is obtained by */
/*              simply rotating the original position and velocity. */

	    mxv_(rot1, state, state2);
	    mxv_(rot1, &state[3], v1);

/*              The rest of the velocity is obtained by crossing */
/*              the angular velocity with the current position */
/*              in  FRAME2. */

	    vcrss_(av2, state, vtemp);
	    mxv_(rot1, vtemp, v2);

/*              Add the results together to get the the full velocity. */

	    vadd_(v1, v2, &state2[3]);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("POSITION", state1, "~~/", state2, &c__3, &c_b11, ok, (
		    ftnlen)8, (ftnlen)3);
	    chckad_("VELOCITY", &state1[3], "~~/", &state2[3], &c__3, &c_b11, 
		    ok, (ftnlen)8, (ftnlen)3);
	    moved_(state2, &c__6, state);
	    long__ += dlong;
	    mag += dmag;
	}
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_xfrav__ */

