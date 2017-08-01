/* f_xfneul.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__36 = 36;
static integer c__3 = 3;
static integer c__6 = 6;
static logical c_false = FALSE_;
static doublereal c_b43 = 2e-14;
static logical c_true = TRUE_;

/* $Procedure      F_XFNEUL ( State transformations and Euler angles) */
/* Subroutine */ int f_xfneul__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal diag[27]	/* was [3][3][3] */, axis[27]	/* was [3][3][3] */;
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *);
    integer a[3], i__, j, k, m;
    doublereal omega[27]	/* was [3][3][3] */;
    extern /* Subroutine */ int tcase_(char *, ftnlen), moved_(doublereal *, 
	    integer *, doublereal *);
    doublereal euler[6], xpect[36]	/* was [6][6] */;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */, xtemp[36]	/* was [6][6] 
	    */;
    extern /* Subroutine */ int t_success__(logical *), eul2xf_(doublereal *, 
	    integer *, integer *, integer *, doublereal *), xf2eul_(
	    doublereal *, integer *, integer *, integer *, doublereal *, 
	    logical *), rav2xf_(doublereal *, doublereal *, doublereal *), 
	    chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen);
    doublereal av[3];
    extern /* Subroutine */ int cleard_(integer *, doublereal *);
    doublereal xf[108]	/* was [6][6][3] */;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    doublereal ceuler[6];
    extern /* Subroutine */ int rotate_(doublereal *, integer *, doublereal *)
	    ;
    doublereal xeuler[6];
    logical unique;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/* -    TSPICE Version 2.0.0, 31-OCT-2005 (NJB) */

/*        Updated to test EUL2XF for all axis sequences, including those */
/*        for which the second axis matches the first or third. */
/*        Simplified the algorithm for constructing the expected */
/*        rotation. */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in MXM and VSCLG calls. */

/*     This routine tests the routines XF2EUL and EUL2XF */
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

    topen_("F_XFNEUL", (ftnlen)8);
/*     Validate the computation of state transformation from */
/*     Euler angles and derivatives. */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    for (k = 1; k <= 3; ++k) {
		omega[(i__1 = i__ + (j + k * 3) * 3 - 13) < 27 && 0 <= i__1 ? 
			i__1 : s_rnge("omega", i__1, "f_xfneul__", (ftnlen)
			100)] = 0.;
		axis[(i__1 = i__ + (j + k * 3) * 3 - 13) < 27 && 0 <= i__1 ? 
			i__1 : s_rnge("axis", i__1, "f_xfneul__", (ftnlen)101)
			] = 0.;
		diag[(i__1 = i__ + (j + k * 3) * 3 - 13) < 27 && 0 <= i__1 ? 
			i__1 : s_rnge("diag", i__1, "f_xfneul__", (ftnlen)102)
			] = 0.;
	    }
	}
    }
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    diag[(i__1 = j + (j + i__ * 3) * 3 - 13) < 27 && 0 <= i__1 ? i__1 
		    : s_rnge("diag", i__1, "f_xfneul__", (ftnlen)110)] = 1. - 
		    (doublereal) (i__4 = ((i__2 = i__ - j, abs(i__2)) - 1) / (
		    (i__3 = i__ - j, abs(i__3)) + 1), abs(i__4));
	    axis[(i__1 = j + (j + i__ * 3) * 3 - 13) < 27 && 0 <= i__1 ? i__1 
		    : s_rnge("axis", i__1, "f_xfneul__", (ftnlen)111)] = (
		    i__4 = ((i__2 = i__ - j, abs(i__2)) - 1) / ((i__3 = i__ - 
		    j, abs(i__3)) + 1), (doublereal) abs(i__4));
	}
    }
    omega[21] = 1.;
    omega[7] = 1.;
    omega[11] = 1.;
    omega[5] = -1.;
    omega[19] = -1.;
    omega[15] = -1.;
    tcase_("Validate the computation of state transformation from Euler angl"
	    "es and derivatives. Every possible combination of axes is tested"
	    ". ", (ftnlen)130);
    euler[0] = .33;
    euler[1] = -.2;
    euler[2] = .5;
    euler[3] = -.3;
    euler[4] = .1;
    euler[5] = .7;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    for (k = 1; k <= 3; ++k) {

/*                 We construct the state transformation matrix */
/*                 from scratch and compare that to the results */
/*                 returned by EUL2XF. */

		a[0] = i__;
		a[1] = j;
		a[2] = k;

/*                 Set the expected state transformation to the identity */
/*                 to begin with. */

		cleard_(&c__36, xpect);
		for (m = 1; m <= 6; ++m) {
		    xpect[(i__1 = m + m * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
			    s_rnge("xpect", i__1, "f_xfneul__", (ftnlen)159)] 
			    = 1.;
		}
		for (m = 1; m <= 3; ++m) {

/*                    Construct the state transformation for the Mth */
/*                    rotation in the sequence.  We start out with */
/*                    the rotation matrix and angular velocity vector. */

		    rotate_(&euler[(i__1 = m - 1) < 6 && 0 <= i__1 ? i__1 : 
			    s_rnge("euler", i__1, "f_xfneul__", (ftnlen)168)],
			     &a[(i__2 = m - 1) < 3 && 0 <= i__2 ? i__2 : 
			    s_rnge("a", i__2, "f_xfneul__", (ftnlen)168)], 
			    rot);

/*                    Set the angular velocity vector:  the component */
/*                    corresponding to axis M is the Mth rate; the other */
/*                    components are zero. */

		    cleard_(&c__3, av);
		    av[(i__2 = a[(i__1 = m - 1) < 3 && 0 <= i__1 ? i__1 : 
			    s_rnge("a", i__1, "f_xfneul__", (ftnlen)177)] - 1)
			     < 3 && 0 <= i__2 ? i__2 : s_rnge("av", i__2, 
			    "f_xfneul__", (ftnlen)177)] = euler[(i__3 = m + 2)
			     < 6 && 0 <= i__3 ? i__3 : s_rnge("euler", i__3, 
			    "f_xfneul__", (ftnlen)177)];
		    rav2xf_(rot, av, &xf[(i__1 = (m * 6 + 1) * 6 - 42) < 108 
			    && 0 <= i__1 ? i__1 : s_rnge("xf", i__1, "f_xfne"
			    "ul__", (ftnlen)179)]);
		    mxmg_(xpect, &xf[(i__1 = (m * 6 + 1) * 6 - 42) < 108 && 0 
			    <= i__1 ? i__1 : s_rnge("xf", i__1, "f_xfneul__", 
			    (ftnlen)181)], &c__6, &c__6, &c__6, xtemp);
		    moved_(xtemp, &c__36, xpect);
		}
		eul2xf_(euler, &i__, &j, &k, xform);
		tstmsg_("#", "Rotation is a #-#-# ", (ftnlen)1, (ftnlen)20);
		tstmsi_(&i__);
		tstmsi_(&j);
		tstmsi_(&k);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chckad_("XFORM", xform, "~", xpect, &c__36, &c_b43, ok, (
			ftnlen)5, (ftnlen)1);
	    }
	}
    }
    tcase_("Validate the computation of euler angles and derivatives from th"
	    "e state transformation matrix. Every combination of rotation axe"
	    "s is exercised. ", (ftnlen)144);
    euler[0] = .33;
    euler[1] = .2;
    euler[2] = .5;
    euler[3] = .3;
    euler[4] = .1;
    euler[5] = .7;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    if (i__ != j) {
		for (k = 1; k <= 3; ++k) {
		    if (k != j) {
			eul2xf_(euler, &i__, &j, &k, xform);
			xf2eul_(xform, &i__, &j, &k, ceuler, &unique);
			tstmsg_("#", "Rotation is a #-#-# ", (ftnlen)1, (
				ftnlen)20);
			tstmsi_(&i__);
			tstmsi_(&j);
			tstmsi_(&k);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			chcksl_("UNIQUE", &unique, &c_true, ok, (ftnlen)6);
			chckad_("XFORM", ceuler, "~", euler, &c__6, &c_b43, 
				ok, (ftnlen)5, (ftnlen)1);
		    }
		}
	    }
	}
    }
    tcase_("Exercise the degenerate cases where the second angle is nearly z"
	    "ero. ", (ftnlen)69);
    euler[0] = 0.;
    euler[1] = 1e-10;
    euler[2] = .5;
    euler[3] = 0.;
    euler[4] = .1;
    euler[5] = .7;
    xeuler[0] = 0.;
    xeuler[1] = 0.;
    xeuler[2] = .5;
    xeuler[3] = 0.;
    xeuler[4] = .1;
    xeuler[5] = .7;
    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    if (i__ != j) {
		for (k = 1; k <= 3; ++k) {
		    if (k == i__) {
			eul2xf_(euler, &i__, &j, &k, xform);
			xf2eul_(xform, &i__, &j, &k, ceuler, &unique);
			tstmsg_("#", "Rotation is a #-#-# ", (ftnlen)1, (
				ftnlen)20);
			tstmsi_(&i__);
			tstmsi_(&j);
			tstmsi_(&k);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			chcksl_("UNIQUE", &unique, &c_false, ok, (ftnlen)6);
			chckad_("XFORM", ceuler, "~", xeuler, &c__6, &c_b43, 
				ok, (ftnlen)5, (ftnlen)1);
		    }
		}
	    }
	}
    }
    t_success__(ok);
    return 0;
} /* f_xfneul__ */

