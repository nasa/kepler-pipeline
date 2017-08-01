/* f_dnearp.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__6 = 6;
static doublereal c_b11 = 1e-13;
static integer c__2 = 2;
static doublereal c_b17 = 1.;
static doublereal c_b18 = 1e-5;
static doublereal c_b20 = 1e5;
static doublereal c_b21 = -1e5;

/* $Procedure      F_DNEARP ( Family of DNEARP tests ) */
/* Subroutine */ int f_dnearp__(logical *ok)
{
    doublereal dalt[2], ealt[2];
    extern doublereal vdot_(doublereal *, doublereal *);
    doublereal a, b, c__, dnear[6];
    extern /* Subroutine */ int tcase_(char *, ftnlen), dvhat_(doublereal *, 
	    doublereal *), moved_(doublereal *, integer *, doublereal *);
    logical found;
    doublereal state[6];
    extern /* Subroutine */ int vlcom_(doublereal *, doublereal *, doublereal 
	    *, doublereal *, doublereal *), topen_(char *, ftnlen);
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal ednear[6];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen), 
	    dnearp_(doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, logical *), nearpt_(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal tmpsta[6], npoint1[3], npoint2[3], alt;

/* $ Abstract */

/*     This routine performs a set of rudimentary checks on the */
/*     routine DNEARP */

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

/* -    TSPICE Version 2.4.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    TSPICE Version 2.3.0, 27-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VLCOM call. */

/* -    Version 2.2.1 17-JUL-2002 (BVS) */

/*        Added MAC-OSX environments (only FORTRAN ones because */
/*        MAC-OSX C environment has the same problem with the */
/*        focal point test as the Linux and classic Mac C.) */

/* -    Version 2.2.0 02-JAN-2002 (NJB) (EDW) */

/*        Added PC-LINUX_C and MACPPC_C to the set of environments */
/*        for which the focal point test is omitted. */

/* -    Version 2.1.0 20-Oct-1999 (WLT) */

/*         Made the test environment specific because we can't get */
/*         a point on the focal set of the ellipsoid on our edition */
/*         of PC-LINUX or the MAC */

/* -& */

/*     Spicelib Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_DNEARP", (ftnlen)8);
    tcase_("Check the results of DNEARP when the body in question is the uni"
	    "t sphere. ", (ftnlen)74);
    a = 1.;
    b = 1.;
    c__ = 1.;
    state[0] = 10.;
    state[1] = 11.;
    state[2] = 12.;
    state[3] = 2.;
    state[4] = 3.;
    state[5] = -1.;

/*        When the body is the unit sphere, the near point is just */
/*        the unit vector that is parallel to the position component */
/*        of the state vector.  The velocity of the near point */
/*        is the derivative of this unit vector  DVHAT handles the */
/*        whole problem. */

    dvhat_(state, ednear);

/*        The latitude will be the distance from the origin minus 1. */
/*        The rate of change of */

    ealt[0] = vnorm_(state) - 1.;
    ealt[1] = vdot_(ednear, &state[3]);
    dnearp_(state, &a, &b, &c__, dnear, dalt, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chckad_("DNEAR", dnear, "~/", ednear, &c__6, &c_b11, ok, (ftnlen)5, (
	    ftnlen)2);
    chckad_("DALT", dalt, "~/", ealt, &c__2, &c_b11, ok, (ftnlen)4, (ftnlen)2)
	    ;
    tcase_("Check state of near point over a vertex of an ellipsoid. ", (
	    ftnlen)57);
    a = 4.;
    b = 4.;
    c__ = 9.;
    state[0] = 0.;
    state[1] = 0.;
    state[2] = 12.;
    state[3] = 1.;
    state[4] = 2.;
    state[5] = 5.;
    ednear[0] = 0.;
    ednear[1] = 0.;
    ednear[2] = 9.;
    ednear[3] = .75;
    ednear[4] = 1.5;
    ednear[5] = 0.;
    ealt[0] = 3.;
    ealt[1] = 5.;
    nearpt_(state, &a, &b, &c__, npoint1, &alt);
    vlcom_(&c_b17, state, &c_b18, &state[3], tmpsta);
    moved_(tmpsta, &c__6, state);
    nearpt_(state, &a, &b, &c__, npoint2, &alt);
    vlcom_(&c_b20, npoint2, &c_b21, npoint1, &ednear[3]);
    state[0] = 0.;
    state[1] = 0.;
    state[2] = 12.;
    state[3] = 1.;
    state[4] = 2.;
    state[5] = 5.;
    dnearp_(state, &a, &b, &c__, dnear, dalt, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chckad_("DNEAR", dnear, "~", ednear, &c__6, &c_b18, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("DALT", dalt, "~/", ealt, &c__2, &c_b11, ok, (ftnlen)4, (ftnlen)2)
	    ;
    t_success__(ok);
    return 0;
} /* f_dnearp__ */

