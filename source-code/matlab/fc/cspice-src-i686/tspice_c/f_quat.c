/* f_quat.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static doublereal c_b7 = 1e-14;
static integer c__3 = 3;
static integer c__1 = 1;
static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b57 = 1e-12;
static doublereal c_b62 = -.5;
static integer c__36 = 36;

/* $Procedure      F_QUAT ( Quaternion routine tests ) */
/* Subroutine */ int f_quat__(logical *ok)
{
    /* Initialized data */

    static doublereal qidneg[4] = { -1.,0.,0.,0. };
    static doublereal qid[4] = { 1.,0.,0.,0. };
    static doublereal qi[4] = { 0.,1.,0.,0. };
    static doublereal qj[4] = { 0.,0.,1.,0. };
    static doublereal qk[4] = { 0.,0.,0.,1. };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2, d__3;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal mexp[9]	/* was [3][3] */, qexp[4];
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    doublereal qtmp[4], mout[9]	/* was [3][3] */, qout[4];
    extern /* Subroutine */ int eul2m_(doublereal *, doublereal *, doublereal 
	    *, integer *, integer *, integer *, doublereal *);
    integer i__, j;
    doublereal q[4], angle[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), moved_(doublereal *, 
	    integer *, doublereal *), vsclg_(doublereal *, doublereal *, 
	    integer *, doublereal *);
    doublereal expav[3];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal m1[9]	/* was [3][3] */, m2[9]	/* was [3][3] */, q1[4], q2[4]
	    ;
    extern /* Subroutine */ int t_success__(logical *), qdq2av_(doublereal *, 
	    doublereal *, doublereal *), xf2rav_(doublereal *, doublereal *, 
	    doublereal *), chckad_(char *, doublereal *, char *, doublereal *,
	     integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal dm[9]	/* was [3][3] */, dq[4], av[3];
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal xtrans[36]	/* was [6][6] */;
    extern /* Subroutine */ int m2q_(doublereal *, doublereal *), q2m_(
	    doublereal *, doublereal *);
    extern doublereal rpd_(void);
    doublereal qav[4], avx[3];
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    , qxq_(doublereal *, doublereal *, doublereal *);

/* $ Abstract */

/*     This routine tests the SPICELIB quaternion routine */

/*        QXQ */

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
/*        in VSCLG call. */

/* -    TSPICE Version 1.0.0, 25-AUG-2002 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_QUAT", (ftnlen)6);

/*     QXQ tests follow: */

    tcase_("QXQ test:  Check compliance with  Hamilton's rules.  Test QI x Q"
	    "J.", (ftnlen)66);
    qxq_(qi, qj, qout);
    chckad_("i*j", qout, "~", qk, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Check compliance with Hamilton's rules.  Test QJ x QK.", (ftnlen)
	    54);
    qxq_(qj, qk, qout);
    chckad_("j*k", qout, "~", qi, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Check compliance with Hamilton's rules.  Test QK x QI.", (ftnlen)
	    54);
    qxq_(qk, qi, qout);
    chckad_("k*i", qout, "~", qj, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Check compliance with Hamilton's rules.  Test QI x QI.", (ftnlen)
	    54);
    qxq_(qi, qi, qout);
    chckad_("i*i", qout, "~", qidneg, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Check compliance with Hamilton's rules.  Test QJ x QJ.", (ftnlen)
	    54);
    qxq_(qj, qj, qout);
    chckad_("j*j", qout, "~", qidneg, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Check compliance with Hamilton's rules.  Test QK x QK.", (ftnlen)
	    54);
    qxq_(qk, qk, qout);
    chckad_("k*k", qout, "~", qidneg, &c__4, &c_b7, ok, (ftnlen)3, (ftnlen)1);
    qexp[0] = 1.;
    qexp[1] = 2.;
    qexp[2] = 3.;
    qexp[3] = 4.;
    tcase_("Check right-multiplication by the identity.", (ftnlen)43);
    qxq_(qexp, qid, qout);
    chckad_("QEXP * 1", qout, "~", qexp, &c__4, &c_b7, ok, (ftnlen)8, (ftnlen)
	    1);
    tcase_("Check left-multiplication by the identity.", (ftnlen)42);
    qxq_(qid, qexp, qout);
    chckad_("1 * QEXP", qout, "~", qexp, &c__4, &c_b7, ok, (ftnlen)8, (ftnlen)
	    1);

/*     Try a more complex case:  multiply two rotation matrices */
/*     via quaternion multiplication. */

    tcase_("Multiply two rotations via quaternion multiplication.", (ftnlen)
	    53);
    d__1 = rpd_() * 20.f;
    d__2 = rpd_() * 10.f;
    d__3 = rpd_() * 70.f;
    eul2m_(&d__1, &d__2, &d__3, &c__3, &c__1, &c__3, m1);
    d__1 = rpd_() * -20.f;
    d__2 = rpd_() * 30.f;
    d__3 = rpd_() * -10.f;
    eul2m_(&d__1, &d__2, &d__3, &c__3, &c__1, &c__3, m2);
    m2q_(m1, q1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    m2q_(m2, q2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    qxq_(q1, q2, qout);
    q2m_(qout, mout);
    mxm_(m1, m2, mexp);
    chckad_("MOUT", mout, "~", mexp, &c__9, &c_b57, ok, (ftnlen)4, (ftnlen)1);

/*     QDQ2AV tests follow: */

    tcase_("Produce quaternion and derivative from Euler angles and a.v.  Re"
	    "cover a.v. from QDQ2AV; compare to original a.v.", (ftnlen)112);

/*     Start with a known rotation and angular velocity.  Find */
/*     the quaternion and quaternion derivative.  The latter is */
/*     computed from */

/*                        * */
/*         AV  =   -2  * Q  * DQ */

/*         DQ  =  -1/2 * Q  * AV */

    angle[0] = rpd_() * -20.f;
    angle[1] = rpd_() * 50.f;
    angle[2] = rpd_() * -60.f;
    eul2m_(&angle[2], &angle[1], angle, &c__3, &c__1, &c__3, m1);
    m2q_(m1, q);
    expav[0] = 1.;
    expav[1] = 2.;
    expav[2] = 3.;

/*     Form the quaternion derivative. */

    qav[0] = 0.;
    vequ_(expav, &qav[1]);
    qxq_(q, qav, dq);
    vsclg_(&c_b62, dq, &c__4, qtmp);
    moved_(qtmp, &c__4, dq);

/*     Recover angular velocity from Q and DQ. */

    qdq2av_(q, dq, av);

/*     Do a consistency check against the orginal a.v.  This is */
/*     an intermediate check; it demonstrates invertability but */
/*     not corrrectness of our formulas. */

    chckad_("AV from Q and DQ", av, "~", expav, &c__3, &c_b57, ok, (ftnlen)16,
	     (ftnlen)1);

/*     Convert Q back to a rotation matrix. */

    q2m_(q, m1);
    tcase_("Map a quaternion and derivative to angular velocity via a transf"
	    "ormation matrix and xf2rav.  Compare to result from QDQ2AV.", (
	    ftnlen)123);

/*     Convert Q and DQ to a rotation derivative matrix.  This */
/*     somewhat messy procedure is based on differentiating the */
/*     formula for deriving a rotation from a quaternion, then */
/*     substituting components of Q and DQ into the derivative */
/*     formula. */

    dm[0] = (q[2] * dq[2] + q[3] * dq[3]) * -4.;
    dm[3] = (q[1] * dq[2] + q[2] * dq[1] - q[0] * dq[3] - q[3] * dq[0]) * 2.;
    dm[6] = (q[1] * dq[3] + q[3] * dq[1] + q[0] * dq[2] + q[2] * dq[0]) * 2.;
    dm[1] = (q[1] * dq[2] + q[2] * dq[1] + q[0] * dq[3] + q[3] * dq[0]) * 2.;
    dm[4] = (q[1] * dq[1] + q[3] * dq[3]) * -4.;
    dm[7] = (q[2] * dq[3] + q[3] * dq[2] - q[0] * dq[1] - q[1] * dq[0]) * 2.;
    dm[2] = (q[3] * dq[1] + q[1] * dq[3] - q[0] * dq[2] - q[2] * dq[0]) * 2.;
    dm[5] = (q[2] * dq[3] + q[3] * dq[2] + q[0] * dq[1] + q[1] * dq[0]) * 2.;
    dm[8] = (q[1] * dq[1] + q[2] * dq[2]) * -4.;

/*     Form the state transformation matrix corresponding to M1 */
/*     and DM. */

    cleard_(&c__36, xtrans);

/*     Upper left block: */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    xtrans[(i__1 = i__ + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : s_rnge(
		    "xtrans", i__1, "f_quat__", (ftnlen)326)] = m1[(i__2 = 
		    i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge("m1", 
		    i__2, "f_quat__", (ftnlen)326)];
	}
    }

/*     Lower right block: */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    xtrans[(i__1 = i__ + 3 + (j + 3) * 6 - 7) < 36 && 0 <= i__1 ? 
		    i__1 : s_rnge("xtrans", i__1, "f_quat__", (ftnlen)337)] = 
		    m1[(i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : 
		    s_rnge("m1", i__2, "f_quat__", (ftnlen)337)];
	}
    }

/*     Lower left block: */

    for (i__ = 1; i__ <= 3; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    xtrans[(i__1 = i__ + 3 + j * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("xtrans", i__1, "f_quat__", (ftnlen)348)] = dm[(
		    i__2 = i__ + j * 3 - 4) < 9 && 0 <= i__2 ? i__2 : s_rnge(
		    "dm", i__2, "f_quat__", (ftnlen)348)];
	}
    }
    xf2rav_(xtrans, mout, avx);

/*     Compare the angular velocity obtained from the state */
/*     transformation with that from QDQ2AV. */

    chckad_("AV from Q and DQ", av, "~", avx, &c__3, &c_b57, ok, (ftnlen)16, (
	    ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_quat__ */

