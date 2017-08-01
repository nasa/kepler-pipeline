/* f_euler.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__14 = 14;
static logical c_false = FALSE_;
static doublereal c_b16 = 1e-14;
static logical c_true = TRUE_;
static integer c__4 = 4;
static integer c__3 = 3;
static doublereal c_b49 = 2e-12;
static integer c__9 = 9;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__2 = 2;
static doublereal c_b171 = 1.;

/* $Procedure F_EULER ( Test the SPICELIB Euler angle routines ) */
/* Subroutine */ int f_euler__(logical *ok)
{
    /* Initialized data */

    static integer next[4] = { 2,3,1,2 };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double cos(doublereal);
    integer s_rnge(char *, integer, char *, integer);
    double sin(doublereal);

    /* Local variables */
    integer case__, seed;
    extern /* Subroutine */ int eul2m_(doublereal *, doublereal *, doublereal 
	    *, integer *, integer *, integer *, doublereal *);
    integer axis1, axis2, axis3;
    extern /* Subroutine */ int m2eul_(doublereal *, integer *, integer *, 
	    integer *, doublereal *, doublereal *, doublereal *);
    doublereal q[4], r__[9]	/* was [3][3] */, angle[3];
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *);
    logical rhand;
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmd_(char *, char *,
	     doublereal *, integer *, char *, ftnlen, ftnlen, ftnlen), repmi_(
	    char *, char *, integer *, char *, ftnlen, ftnlen, ftnlen);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal qtemp[4];
    extern logical isrot_(doublereal *, doublereal *, doublereal *);
    doublereal q1[4], q2[4], q3[4];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal lb, ub;
    extern doublereal pi_(void);
    extern /* Subroutine */ int cleard_(integer *, doublereal *);
    logical is;
    extern doublereal halfpi_(void);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    doublereal xr[9]	/* was [3][3] */, xangle[3];
    extern /* Subroutine */ int q2m_(doublereal *, doublereal *);
    logical abc;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    extern /* Subroutine */ int qxq_(doublereal *, doublereal *, doublereal *)
	    ;

/* $ Abstract */

/*     Exercise the SPICELIB routines that convert between */
/*     Euler angles and rotations. */

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

/*     This routine tests the SPICELIB Euler angle conversion routines */

/*        EUL2M */
/*        M2EUL */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     Rotation Required Reading. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 09-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     NUMCAS is the number of random Euler angle sequence test */
/*     cases per axis sequence.  Since there are 27 axis sequences */
/*     for the EUL2M tests and 12 sequences for the M2EUL tests, */
/*     and since we use a random selection of angles for each, we */
/*     actually have 8100 random cases for EUL2M and 3600 for M2EUL. */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     The principal test approach is as follows: we'll construct */
/*     rotation matrices from sets of Euler angles using EUL2M.  We'll */
/*     use an alternate, computationally independent approach to */
/*     construct the expected matrices and compare the output of EUL2M */
/*     against the expected results. */

/*     Having in hand rotations with known Euler angle factorizations, */
/*     we'll use M2EUL to recover the original angles. */

/*     The EUL2M tests will be performed using every possible Euler axis */
/*     sequence. */

/*     The M2EUL tests will be restricted to Euler axis sequences of the */
/*     forms */

/*        a-b-a */
/*        a-b-c */

/*     since M2EUL doesn't allow axis sequences where the middle axis is */
/*     equal to one of the others. */


/*     Open the test family. */

    topen_("F_EULER", (ftnlen)7);
    seed = -1;

/*     We'll perform tests for each possible axis sequence. */

    for (axis1 = 1; axis1 <= 3; ++axis1) {
	for (axis2 = 1; axis2 <= 3; ++axis2) {
	    for (axis3 = 1; axis3 <= 3; ++axis3) {
		for (case__ = 1; case__ <= 300; ++case__) {

/* --- Case: ------------------------------------------------------ */


/*                 Test EUL2M.  Select random Euler angles; construct */
/*                 a rotation matrix. */

		    d__1 = -pi_();
		    d__2 = pi_();
		    xangle[0] = t_randd__(&d__1, &d__2, &seed);

/*                 The range of the middle angle depends on */
/*                 the type of axis sequence.  This is a matter */
/*                 of convention, not mathematics. */

		    if (axis1 == axis3) {
			lb = 0.;
			ub = pi_();
		    } else {
			lb = -halfpi_();
			ub = halfpi_();
		    }
		    xangle[1] = t_randd__(&lb, &ub, &seed);
		    d__1 = -pi_();
		    d__2 = pi_();
		    xangle[2] = t_randd__(&d__1, &d__2, &seed);
		    s_copy(title, "Test EUL2M: Create a rotation matrix from"
			    " a random sequence of Euler angles; case = #.  A"
			    "xis sequence = # # #. Angle sequence = # # #.", (
			    ftnlen)240, (ftnlen)134);
		    repmi_(title, "#", &case__, title, (ftnlen)240, (ftnlen)1,
			     (ftnlen)240);
		    repmi_(title, "#", &axis3, title, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)240);
		    repmi_(title, "#", &axis2, title, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)240);
		    repmi_(title, "#", &axis1, title, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)240);
		    repmd_(title, "#", &xangle[2], &c__14, title, (ftnlen)240,
			     (ftnlen)1, (ftnlen)240);
		    repmd_(title, "#", &xangle[1], &c__14, title, (ftnlen)240,
			     (ftnlen)1, (ftnlen)240);
		    repmd_(title, "#", xangle, &c__14, title, (ftnlen)240, (
			    ftnlen)1, (ftnlen)240);
		    tcase_(title, (ftnlen)240);

/*                 Build the rotation matrix R. */

		    eul2m_(&xangle[2], &xangle[1], xangle, &axis3, &axis2, &
			    axis1, r__);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Verify that EUL2M created a rotation matrix. */

		    is = isrot_(r__, &c_b16, &c_b16);
		    chcksl_("Is R a rotation?", &is, &c_true, ok, (ftnlen)16);

/*                 Validate the rotation by building the same */
/*                 matrix using quaternions.  Construct a */
/*                 quaternion corresponding to each factor rotation. */

		    cleard_(&c__4, q1);
		    q1[0] = cos(-xangle[0] / 2.);
		    q1[(i__1 = axis1) < 4 && 0 <= i__1 ? i__1 : s_rnge("q1", 
			    i__1, "f_euler__", (ftnlen)297)] = sin(-xangle[0] 
			    / 2.);
		    cleard_(&c__4, q2);
		    q2[0] = cos(-xangle[1] / 2.);
		    q2[(i__1 = axis2) < 4 && 0 <= i__1 ? i__1 : s_rnge("q2", 
			    i__1, "f_euler__", (ftnlen)302)] = sin(-xangle[1] 
			    / 2.);
		    cleard_(&c__4, q3);
		    q3[0] = cos(-xangle[2] / 2.);
		    q3[(i__1 = axis3) < 4 && 0 <= i__1 ? i__1 : s_rnge("q3", 
			    i__1, "f_euler__", (ftnlen)307)] = sin(-xangle[2] 
			    / 2.);

/*                 Compute the product quaternion */

/*                    Q = Q3*Q2*Q1 */

		    qxq_(q3, q2, qtemp);
		    qxq_(qtemp, q1, q);

/*                 Convert Q to a rotation matrix for comparison. */

		    q2m_(q, xr);

/*                 How close is R to XR? */

		    chckad_("R", r__, "~", xr, &c__3, &c_b16, ok, (ftnlen)1, (
			    ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*                 Test EUL2M.  Decompose the rotation matrix */
/*                 created using EUL2M. */

/*                 Skip the cases where AXIS2 == AXIS1 or AXIS3. */

		    if (axis2 != axis1 && axis2 != axis3) {
			s_copy(title, "Test M2EUL: Factor a rotation matrix "
				"from a random sequence of Euler angles; case"
				" = #.  Axis sequence = # # #. Angle sequence"
				" = # # #.", (ftnlen)240, (ftnlen)134);
			repmi_(title, "#", &case__, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis3, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis2, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis1, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmd_(title, "#", &xangle[2], &c__14, title, (ftnlen)
				240, (ftnlen)1, (ftnlen)240);
			repmd_(title, "#", &xangle[1], &c__14, title, (ftnlen)
				240, (ftnlen)1, (ftnlen)240);
			repmd_(title, "#", xangle, &c__14, title, (ftnlen)240,
				 (ftnlen)1, (ftnlen)240);
			tcase_(title, (ftnlen)240);

/*                    Decompose the matrix. */

			m2eul_(r__, &axis3, &axis2, &axis1, &angle[2], &angle[
				1], angle);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Test the recovered Euler angles. */

			chckad_("Euler angles", angle, "~", xangle, &c__3, &
				c_b49, ok, (ftnlen)12, (ftnlen)1);
		    }
		}
	    }
	}
    }

/*     There is also a set of special cases for M2EUL:  those for */
/*     which ANGLE3 and ANGLE1 are not uniquely determined.  For */
/*     these cases, we expect that ANGLE3 is set to zero and ANGLE1 */
/*     "absorbs" any contribution from ANGLE3. */

/*     We don't need to test the numeric performance of M2EUL here */
/*     (we just did that), so we won't run a large number of cases. */
/*     We do need to make sure we try every valid axis sequence. */

    for (axis1 = 1; axis1 <= 3; ++axis1) {
	for (axis2 = 1; axis2 <= 3; ++axis2) {
	    for (axis3 = 1; axis3 <= 3; ++axis3) {
		if (axis2 != axis1 && axis2 != axis3) {
		    for (case__ = 1; case__ <= 2; ++case__) {

/* --- Case: ------------------------------------------------------ */


/*                    If we have an a-b-a rotation, we need to */
/*                    test the cases where the middle angle is zero */
/*                    or pi.  For the a-b-c rotations, we need to */
/*                    test the cases where the middle angle is */
/*                    +/- pi/2. */

/*                    We'll use the same first and third angles for */
/*                    each case. */

			xangle[2] = pi_() / 6.;
			xangle[0] = pi_() / 3.;
			if (axis3 == axis1) {

/*                       This is the a-b-a case. */

			    abc = FALSE_;
			    if (case__ == 1) {
				xangle[1] = 0.;
			    } else {
				xangle[1] = pi_();
			    }
			} else {

/*                       This is the a-b-c case. */

			    abc = TRUE_;
			    if (case__ == 1) {
				xangle[1] = halfpi_();
			    } else {
				xangle[1] = -halfpi_();
			    }
			}
			s_copy(title, "Test M2EUL: Factor a rotation matrix "
				"from a sequence of Euler angles; special cas"
				"e = #.  Axis sequence = # # #. Angle sequenc"
				"e = # # #.", (ftnlen)240, (ftnlen)135);
			repmi_(title, "#", &case__, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis3, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis2, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(title, "#", &axis1, title, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmd_(title, "#", &xangle[2], &c__14, title, (ftnlen)
				240, (ftnlen)1, (ftnlen)240);
			repmd_(title, "#", &xangle[1], &c__14, title, (ftnlen)
				240, (ftnlen)1, (ftnlen)240);
			repmd_(title, "#", xangle, &c__14, title, (ftnlen)240,
				 (ftnlen)1, (ftnlen)240);
			tcase_(title, (ftnlen)240);

/*                    Create the rotation matrix. */

			eul2m_(&xangle[2], &xangle[1], xangle, &axis3, &axis2,
				 &axis1, xr);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Now decompose the matrix. */

			m2eul_(xr, &axis3, &axis2, &axis1, &angle[2], &angle[
				1], angle);
			chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                    Due to round-off error, we might not have */
/*                    succeeded in constructing a matrix that */
/*                    decomposes as we expect.  If the third angle */
/*                    is zero, perform the test for the special case. */
/*                    Otherwise, just confirm that the Euler angles */
/*                    we found generate the original matrix. */

			if (angle[2] == 0.) {

/*                       Test the recovered Euler angles.  We first */
/*                       adjust the expected first and third angles. */

			    if (abc) {

/*                          The way the first and third angles */
/*                          combine is a bit complicated:  it */
/*                          depends on whether the axis sequence */
/*                          is right-handed. */

				rhand = axis2 == next[(i__1 = axis1 - 1) < 4 
					&& 0 <= i__1 ? i__1 : s_rnge("next", 
					i__1, "f_euler__", (ftnlen)494)] && 
					axis3 == next[(i__2 = axis2 - 1) < 4 
					&& 0 <= i__2 ? i__2 : s_rnge("next", 
					i__2, "f_euler__", (ftnlen)494)];
				if (rhand) {
				    if (case__ == 1) {

/*                                The first and third angles combine */
/*                                additively. */

					xangle[0] += xangle[2];
				    } else {

/*                                The third angle acts as a negative */
/*                                rotation about the first axis. */

					xangle[0] -= xangle[2];
				    }
				} else {

/*                             For left-handed axis sequences, the */
/*                             combination pattern is reversed. */

				    if (case__ == 2) {

/*                                The first and third angles combine */
/*                                additively. */

					xangle[0] += xangle[2];
				    } else {

/*                                The third angle acts as a negative */
/*                                rotation about the first axis. */

					xangle[0] -= xangle[2];
				    }
				}
			    } else {
				if (case__ == 1) {

/*                             The first and third angles combine */
/*                             additively. */

				    xangle[0] += xangle[2];
				} else {

/*                             The third angle acts as a negative */
/*                             rotation about the first axis. */

				    xangle[0] -= xangle[2];
				}
			    }
			    xangle[2] = 0.;
			    chckad_("Euler angles", angle, "~", xangle, &c__3,
				     &c_b49, ok, (ftnlen)12, (ftnlen)1);
			}

/*                    Always test the angles produced by M2EUL to see */
/*                    whether we can recover XR from them.  This is */
/*                    the most basic test of validity of the angles: */
/*                    even when the geometry is degenerate, we should be */
/*                    able to find angles that correspond to the same */
/*                    composite rotation produced by the original angles. */

			eul2m_(&angle[2], &angle[1], angle, &axis3, &axis2, &
				axis1, r__);
			chckad_("Recovered matrix", r__, "~", xr, &c__9, &
				c_b16, ok, (ftnlen)16, (ftnlen)1);
		    }
		}
	    }
	}
    }

/*     Now for some error handling tests. */



/*     Error cases for EUL2M: */


/* --- Case: ------------------------------------------------------ */

    tcase_("EUL2M: axis numbers out of range.", (ftnlen)33);
    eul2m_(&angle[2], &angle[1], angle, &c__0, &c__1, &c__3, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    eul2m_(&angle[2], &angle[1], angle, &c__4, &c__1, &c__3, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    eul2m_(&angle[2], &angle[1], angle, &c__3, &c__0, &c__3, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    eul2m_(&angle[2], &angle[1], angle, &c__3, &c__4, &c__3, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    eul2m_(&angle[2], &angle[1], angle, &c__3, &c__1, &c__0, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    eul2m_(&angle[2], &angle[1], angle, &c__3, &c__1, &c__4, r__);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);

/*     Error cases for M2EUL: */


/* --- Case: ------------------------------------------------------ */

    tcase_("M2EUL: axis numbers out of range.", (ftnlen)33);
    m2eul_(r__, &c__0, &c__1, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__4, &c__1, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__3, &c__0, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__3, &c__4, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__3, &c__1, &c__0, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__3, &c__1, &c__4, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("M2EUL: middle axis matches first or third axis.", (ftnlen)47);
    m2eul_(r__, &c__3, &c__3, &c__1, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__1, &c__3, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__2, &c__2, &c__1, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__1, &c__2, &c__2, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__1, &c__1, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);
    m2eul_(r__, &c__3, &c__1, &c__1, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(BADAXISNUMBERS)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("M2EUL:  input matrix is not a rotation.", (ftnlen)39);
    filld_(&c_b171, &c__9, r__);
    m2eul_(r__, &c__3, &c__1, &c__3, &angle[2], &angle[1], angle);
    chckxc_(&c_true, "SPICE(NOTAROTATION)", ok, (ftnlen)19);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_euler__ */

