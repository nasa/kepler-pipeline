/* t_xform.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static integer c__9 = 9;

/* $Procedure T_XFORM ( Test state transformation ) */
/* Subroutine */ int t_xform__(doublereal *xform, doublereal *rminus, 
	doublereal *rplus, doublereal *delta, doublereal *nrmerr, doublereal *
	deterr, doublereal *drverr, doublereal *drlerr, doublereal *drdiff)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2, d__3;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal blerr;
    extern /* Subroutine */ int dvhat_(doublereal *, doublereal *), moved_(
	    doublereal *, integer *, doublereal *), errdp_(char *, doublereal 
	    *, ftnlen);
    extern doublereal vrelg_(doublereal *, doublereal *, integer *);
    extern /* Subroutine */ int vsubg_(doublereal *, doublereal *, integer *, 
	    doublereal *), xpose_(doublereal *, doublereal *);
    extern doublereal vnorm_(doublereal *);
    extern logical failed_(void);
    doublereal drblck[9]	/* was [3][3] */, lrblck[9]	/* was [3][3] 
	    */, ulblck[9]	/* was [3][3] */, dsharp[6], urblck[9]	/* 
	    was [3][3] */, xpblck[9]	/* was [3][3] */, dscret[9]	/* 
	    was [3][3] */;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), qderiv_(integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *), chkout_(
	    char *, ftnlen);
    extern doublereal vdistg_(doublereal *, doublereal *, integer *);
    doublereal dscrtr[9]	/* was [3][3] */, rstate[6];
    extern /* Subroutine */ int setmsg_(char *, ftnlen);
    extern logical return_(void);
    extern doublereal det_(doublereal *);
    doublereal xpd[9]	/* was [3][3] */;

/* $ Abstract */

/*     Perform basic tests on a state transformation matrix:  verify */
/*     that the diagonal blocks contain matching rotations; check */
/*     the derivative block against a discrete derivative obtained */
/*     from input rotations. */

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

/*     MATH */
/*     UTILITY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  ------------------------------------------------- */
/*     XFORM      I   State transformation matrix. */
/*     RMINUS     I   Left side rotation for discrete derivative. */
/*     RPLUS      I   Right side rotation for discrete derivative. */
/*     DELTA      I   Abscissa separation for discrete derivative. */
/*     NRMERR     O   Maximum row and column norm error. */
/*     DETERR     O   Determinant error. */
/*     DRVERR     O   Derivative L2 (RMS) error. */
/*     DRLERR     O   Derivative relative error. */
/*     DRDIFF     O   Derivative difference. */

/* $ Detailed_Input */

/*     XFORM          is a time-dependent state transformation matrix to */
/*                    be tested. For the purposes of discussing the */
/*                    discrete derivative used in tests done by this */
/*                    routine, we'll consider XFORM to correspond to the */
/*                    epoch T0 second past J2000 TDB. */

/*     RMINUS         is a rotation matrix representing the value of */
/*                    XFORM's rotation blocks at time T0-DELTA. */

/*     RPLUS          is a rotation matrix representing the value of */
/*                    XFORM's rotation blocks at time T0+DELTA. */

/*     DELTA          is an interval separating abscissa values used */
/*                    for discrete differentiation.  DELTA is expressed */
/*                    in TDB seconds. */

/* $ Detailed_Output */

/*     NRMERR         is the maximum error of the norm of any row or */
/*                    column of the rotation blocks of XFORM.  Each */
/*                    such norm should be 1. */

/*     DETERR         is the error of the determinant of the upper */
/*                    left block of XFORM.  The determinant should be 1. */

/*     DRVERR         is the error of the derivative block of XFORM. */
/*                    This error is the L2 norm (RMS error) of the */
/*                    difference between the derivative block of XFORM */
/*                    and a discrete derivative computed from RPLUS, */
/*                    RMINUS, and DELTA. */

/*                    The discrete derivative is computed as follows: */

/*                       1) The derivative each component of the */
/*                          upper left block of XFORM is computed */
/*                          using QDERIV. */

/*                       2) Each row of the discrete derivative is */
/*                          "sharpened" by removing its radial component */
/*                          relative to the corresponding row of XFORM. */
/*                          This is done by making each of row the upper */
/*                          left block and its corresponding discrete */
/*                          derivative into a state vector and passing */
/*                          this state through DVHAT.  The velocity */
/*                          portion of the state returned by DVHAT */
/*                          becomes a row of the sharpened discrete */
/*                          derivative. */

/*     DRLERR         is the relative error between the derivative */
/*                    block of XFORM and the discrete derivative. */
/*                    This is computed using VRELG. */

/*     DRDIFF         is the matrix difference between the derivative */
/*                    block of XFORM and the discrete derivative. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*    1) If the rotation (main diagonal) blocks of XFORM don't match */
/*       exactly, the error SPICE(INVALIDMATRIX) is signaled. */

/*    2) If a routine called by this routine signals an error, */
/*       this routine simply returns. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine is used to perform sanity checks on state */
/*     transformations. */

/* $ Examples */

/*     See use in test family F_DYN01. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 21-DEC-2004 (NJB) */

/* -& */
/* $ Index_Entries */

/*       Compute multidimensional array index from offset */

/* -& */

/*     SPICELIB functions */


/*     Local variables */

    if (return_()) {
	return 0;
    }
    chkin_("T_XFORM", (ftnlen)7);

/*     Extract the 3x3 blocks of the input state */
/*     transformation matrix. */

    moved_(xform, &c__3, ulblck);
    moved_(&xform[6], &c__3, &ulblck[3]);
    moved_(&xform[12], &c__3, &ulblck[6]);
    moved_(&xform[18], &c__3, urblck);
    moved_(&xform[24], &c__3, &urblck[3]);
    moved_(&xform[30], &c__3, &urblck[6]);
    moved_(&xform[3], &c__3, drblck);
    moved_(&xform[9], &c__3, &drblck[3]);
    moved_(&xform[15], &c__3, &drblck[6]);
    moved_(&xform[21], &c__3, lrblck);
    moved_(&xform[27], &c__3, &lrblck[3]);
    moved_(&xform[33], &c__3, &lrblck[6]);

/*     The upper left and lower right blocks should be identical. */

    blerr = vdistg_(ulblck, lrblck, &c__9);
    if (blerr != 0.) {
	setmsg_("L2 distance between blocks on main diagonal is #; this dist"
		"ance must be zero.", (ftnlen)77);
	errdp_("#", &blerr, (ftnlen)1);
	sigerr_("SPICE(INVALIDMATRIX)", (ftnlen)20);
	chkout_("T_XFORM", (ftnlen)7);
	return 0;
    }

/*     Start out by finding the norms of rows and columns in */
/*     the upper left block. */

    *nrmerr = 0.;
    for (i__ = 1; i__ <= 3; ++i__) {
/* Computing MAX */
	d__2 = *nrmerr, d__3 = (d__1 = 1. - vnorm_(&ulblck[(i__1 = i__ * 3 - 
		3) < 9 && 0 <= i__1 ? i__1 : s_rnge("ulblck", i__1, "t_xform"
		"__", (ftnlen)259)]), abs(d__1));
	*nrmerr = max(d__2,d__3);
    }
    xpose_(ulblck, xpblck);
    for (i__ = 1; i__ <= 3; ++i__) {
/* Computing MAX */
	d__2 = *nrmerr, d__3 = (d__1 = 1. - vnorm_(&xpblck[(i__1 = i__ * 3 - 
		3) < 9 && 0 <= i__1 ? i__1 : s_rnge("xpblck", i__1, "t_xform"
		"__", (ftnlen)265)]), abs(d__1));
	*nrmerr = max(d__2,d__3);
    }

/*     Find the determinant error of the upper left block. */

    *deterr = (d__1 = 1. - det_(ulblck), abs(d__1));

/*     Compute a discrete derivative of the upper left block using */
/*     the matrices corresponding to time offsets of +/- DELTA. */

    qderiv_(&c__9, rminus, rplus, delta, dscret);
    if (failed_()) {
	chkout_("T_XFORM", (ftnlen)7);
	return 0;
    }

/*     "Sharpen" the discrete derivative:  we know the rows of the */
/*     discrete derivative matrix should be orthogonal to those of the */
/*     corresponding rows of the rotation ULBLCK.  We'll find it */
/*     easier to work with columns of matrices, so let XPD be the */
/*     transpose of the discrete derivative. */

    xpose_(dscret, xpd);
    for (i__ = 1; i__ <= 3; ++i__) {

/*        XPBLCK contains the transpose of XFORM's upper left rotation */
/*        block.  Make a state vector out of the Ith column of XPBLCK */
/*        and the corresponding discrete derivative.  Find the state of */
/*        corresponding unit vector; store the velocity of the unit */
/*        vector in the Ith column of DSCRTR. */

	vequ_(&xpblck[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		"xpblck", i__1, "t_xform__", (ftnlen)300)], rstate);
	vequ_(&xpd[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		"xpd", i__1, "t_xform__", (ftnlen)301)], &rstate[3]);
	dvhat_(rstate, dsharp);
	vequ_(&dsharp[3], &dscrtr[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? 
		i__1 : s_rnge("dscrtr", i__1, "t_xform__", (ftnlen)303)]);
    }

/*     Replace the discrete derivative with the sharpened version */
/*     we just computed. */

    xpose_(dscrtr, dscret);

/*     Find the L2 error between the discrete derivative and the */
/*     derivative block of XFORM.  Also find the relative error. */

    *drverr = vdistg_(dscret, drblck, &c__9);
    *drlerr = vrelg_(dscret, drblck, &c__9);

/*     Find the matrix difference of the derivatives. */

    vsubg_(dscret, drblck, &c__9, drdiff);
    chkout_("T_XFORM", (ftnlen)7);
    return 0;
} /* t_xform__ */

