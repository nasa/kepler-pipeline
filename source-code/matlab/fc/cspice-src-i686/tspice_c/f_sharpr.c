/* f_sharpr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__3 = 3;
static integer c__2 = 2;
static doublereal c_b12 = -.01;
static doublereal c_b13 = .01;
static integer c__9 = 9;
static doublereal c_b21 = 1e-14;
static logical c_true = TRUE_;
static doublereal c_b27 = 0.;
static doublereal c_b28 = .040000000000000001;

/* $Procedure F_SHARPR ( Test the SPICELIB routine SHARPR ) */
/* Subroutine */ int f_sharpr__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer case__, seed;
    doublereal axis[3];
    extern /* Subroutine */ int mtxm_(doublereal *, doublereal *, doublereal *
	    ), eul2m_(doublereal *, doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *);
    integer i__, j;
    doublereal q[9]	/* was [3][3] */, r__[9]	/* was [3][3] */;
    extern /* Subroutine */ int vaddg_(doublereal *, doublereal *, integer *, 
	    doublereal *);
    doublereal angle[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen);
    doublereal noise[9]	/* was [3][3] */;
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern logical isrot_(doublereal *, doublereal *, doublereal *);
    extern /* Subroutine */ int t_success__(logical *);
    extern doublereal pi_(void);
    extern /* Subroutine */ int cleard_(integer *, doublereal *);
    logical is;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal qangle;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), raxisa_(doublereal *, doublereal *, doublereal *);
    doublereal nearly[9]	/* was [3][3] */;
    extern /* Subroutine */ int sharpr_(doublereal *);
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);

/* $ Abstract */

/*     Exercise the SPICELIB routine SHARPR. */

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

/*     This routine tests the SPICELIB routine SHARPR.  SHARPR */
/*     "sharpens" a 3x3 matrix that is "nearly" a rotation matrix */
/*     by unitizing the columns and making the columns mutually */
/*     orthogonal. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 14-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_SHARPR", (ftnlen)8);
    seed = -1;
    for (case__ = 1; case__ <= 1000; ++case__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Perturb a rotation matrix; then sharpen; case #.", (
		ftnlen)240, (ftnlen)48);
	repmi_(title, "#", &case__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	tcase_(title, (ftnlen)240);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Construct a rotation matrix from three Euler angles. */

	d__1 = -pi_();
	d__2 = pi_();
	angle[0] = t_randd__(&d__1, &d__2, &seed);
	d__1 = -pi_() / 2.;
	d__2 = pi_() / 2.;
	angle[1] = t_randd__(&d__1, &d__2, &seed);
	d__1 = -pi_();
	d__2 = pi_();
	angle[2] = t_randd__(&d__1, &d__2, &seed);
	eul2m_(&angle[2], &angle[1], angle, &c__3, &c__2, &c__3, r__);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Construct a "noise" matrix with which to perturb the */
/*        rotation. */

	for (i__ = 1; i__ <= 3; ++i__) {
	    for (j = 1; j <= 3; ++j) {
		noise[(i__1 = i__ + j * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
			s_rnge("noise", i__1, "f_sharpr__", (ftnlen)206)] = 
			t_randd__(&c_b12, &c_b13, &seed);
	    }
	}

/*        NEARLY is "nearly" a rotation. */

	vaddg_(r__, noise, &c__9, nearly);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Now sharpen the rotation. */

	sharpr_(nearly);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the result is a rotation. */

	is = isrot_(nearly, &c_b21, &c_b21);
	chcksl_("Is result a rotation?", &is, &c_true, ok, (ftnlen)21);

/*        Make sure the result is not too different from R. */
/*        Express the quotient of R and NEARLY as a rotation; */
/*        measure the rotation angle. */

	mtxm_(nearly, r__, q);
	raxisa_(q, axis, &qangle);
	chcksd_("QANGLE", &qangle, "~", &c_b27, &c_b28, ok, (ftnlen)6, (
		ftnlen)1);
    }

/*     Now for some error handling tests. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SHARPR:  pass in a singular matrix.  All we expect is that the r"
	    "outine doesn't crash.", (ftnlen)85);
    cleard_(&c__9, r__);
    sharpr_(r__);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_sharpr__ */

