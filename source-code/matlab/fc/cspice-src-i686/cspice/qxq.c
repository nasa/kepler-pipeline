/* qxq.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b2 = 1.;

/* $Procedure QXQ (Quaternion times quaternion) */
/* Subroutine */ int qxq_(doublereal *q1, doublereal *q2, doublereal *qout)
{
    extern doublereal vdot_(doublereal *, doublereal *);
    doublereal cross[3];
    extern /* Subroutine */ int vcrss_(doublereal *, doublereal *, doublereal 
	    *), vlcom3_(doublereal *, doublereal *, doublereal *, doublereal *
	    , doublereal *, doublereal *, doublereal *);

/* $ Abstract */

/*     Multiply two quaternions. */

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

/*     ROTATION */

/* $ Keywords */

/*     MATH */
/*     POINTING */
/*     ROTATION */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     Q1         I   First SPICE quaternion factor. */
/*     Q2         I   Second SPICE quaternion factor. */
/*     QOUT       O   Product of Q1 and Q2. */

/* $ Detailed_Input */

/*     Q1             is a 4-vector representing a SPICE-style */
/*                    quaternion. */

/*                    Note that multiple styles of quaternions */
/*                    are in use.  This routine will not work properly */
/*                    if the input quaternions do not conform to */
/*                    the SPICE convention.  See the Particulars */
/*                    section for details. */

/*     Q2             is a second SPICE quaternion. */

/* $ Detailed_Output */

/*     QOUT           is 4-vector representing the quaternion product */

/*                       Q1 * Q2 */

/*                    Representing Q(i) as the sums of scalar (real) */
/*                    part s(i) and vector (imaginary) part v(i) */
/*                    respectively, */

/*                       Q1 = s1 + v1 */
/*                       Q2 = s2 + v2 */

/*                    QOUT has scalar part s3 defined by */

/*                       s3 = s1 * s2 - <v1, v2> */

/*                    and vector part v3 defined by */

/*                       v3 = s1 * v2  +  s2 * v1  +  v1 x v2 */

/*                    where the notation < , > denotes the inner */
/*                    product operator and x indicates the cross */
/*                    product operator. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     There are (at least) two popular "styles" of quaternions; these */
/*     differ in the layout of the quaternion elements, the definition */
/*     of the multiplication operation, and the mapping between the set */
/*     of unit quaternions and corresponding rotation matrices. */

/*     SPICE-style quaternions have the scalar part in the first */
/*     component and the vector part in the subsequent components. The */
/*     SPICE convention, along with the multiplication rules for SPICE */
/*     quaternions, are those used by William Rowan Hamilton, the */
/*     inventor of quaternions. */

/*     Another common quaternion style places the scalar component */
/*     last.  This style is often used in engineering applications. */

/*     The correspondence between SPICE quaternions and rotation */
/*     matrices is defined as follows:  Let R be a rotation matrix that */
/*     transforms vectors from a right-handed, orthogonal reference */
/*     frame F1 to a second right-handed, orthogonal reference frame F2. */
/*     If a vector V has components x, y, z in the frame F1, then V has */
/*     components x', y', z' in the frame F2, and R satisfies the */
/*     relation: */

/*        [ x' ]     [       ] [ x ] */
/*        | y' |  =  |   R   | | y | */
/*        [ z' ]     [       ] [ z ] */


/*     Letting Q = (q0, q1, q2, q3) be the SPICE unit quaternion */
/*     representing R, we have the relation */

/*             R  = */

/*        +-                                                          -+ */
/*        |           2    2                                           | */
/*        | 1 - 2 ( q2 + q3 )    2 (q1 q2 - q0 q3)   2 (q1 q3 + q0 q2) | */
/*        |                                                            | */
/*        |                                                            | */
/*        |                                2    2                      | */
/*        | 2 (q1 q2 + q0 q3)    1 - 2 ( q1 + q3 )   2 (q2 q3 - q0 q1) | */
/*        |                                                            | */
/*        |                                                            | */
/*        |                                                    2    2  | */
/*        | 2 (q1 q3 - q0 q2)    2 (q2 q3 + q0 q1)   1 - 2 ( q1 + q2 ) | */
/*        |                                                            | */
/*        +-                                                          -+ */


/*     To map the rotation matrix R to a unit quaternion, we start by */
/*     decomposing the rotation matrix as a sum of symmetric */
/*     and skew-symmetric parts: */

/*                                        2 */
/*        R = [ I  +  (1-cos(theta)) OMEGA  ] + [ sin(theta) OMEGA ] */

/*                     symmetric                   skew-symmetric */


/*     OMEGA is a skew-symmetric matrix of the form */

/*                   +-             -+ */
/*                   |  0   -n3   n2 | */
/*                   |               | */
/*         OMEGA  =  |  n3   0   -n1 | */
/*                   |               | */
/*                   | -n2   n1   0  | */
/*                   +-             -+ */

/*     The vector N of matrix entries (n1, n2, n3) is the rotation axis */
/*     of R and theta is R's rotation angle.  Note that N and theta */
/*     are not unique. */

/*     Let */

/*        C = cos(theta/2) */
/*        S = sin(theta/2) */

/*     Then the unit quaternions Q corresponding to R are */

/*        Q = +/- ( C, S*n1, S*n2, S*n3 ) */

/*     The mappings between quaternions and the corresponding rotations */
/*     are carried out by the SPICELIB routines */

/*        Q2M {quaternion to matrix} */
/*        M2Q {matrix to quaternion} */

/*     M2Q always returns a quaternion with scalar part greater than */
/*     or equal to zero. */

/* $ Examples */

/*     1)  Let QID, QI, QJ, QK be the "basis" quaternions */

/*            QID  =  ( 1, 0, 0, 0 ) */
/*            QI   =  ( 0, 1, 0, 0 ) */
/*            QJ   =  ( 0, 0, 1, 0 ) */
/*            QK   =  ( 0, 0, 0, 1 ) */

/*         respectively.  Then the calls */

/*            CALL QXQ ( QI, QJ, IXJ ) */
/*            CALL QXQ ( QJ, QK, JXK ) */
/*            CALL QXQ ( QK, QI, KXI ) */

/*         produce the results */

/*            IXJ = QK */
/*            JXK = QI */
/*            KXI = QJ */

/*         All of the calls */

/*            CALL QXQ ( QI, QI, QOUT ) */
/*            CALL QXQ ( QJ, QJ, QOUT ) */
/*            CALL QXQ ( QK, QK, QOUT ) */

/*         produce the result */

/*            QOUT  =  -QID */

/*         For any quaternion Q, the calls */

/*            CALL QXQ ( QID, Q,   QOUT ) */
/*            CALL QXQ ( Q,   QID, QOUT ) */

/*         produce the result */

/*            QOUT  =  Q */



/*     2)  Composition of rotations:  let CMAT1 and CMAT2 be two */
/*         C-matrices (which are rotation matrices).  Then the */
/*         following code fragment computes the product CMAT1 * CMAT2: */


/*            C */
/*            C     Convert the C-matrices to quaternions. */
/*            C */
/*                  CALL M2Q ( CMAT1, Q1 ) */
/*                  CALL M2Q ( CMAT2, Q2 ) */

/*            C */
/*            C     Find the product. */
/*            C */
/*                  CALL QXQ ( Q1, Q2, QOUT ) */

/*            C */
/*            C     Convert the result to a C-matrix. */
/*            C */
/*                  CALL Q2M ( QOUT, CMAT3 ) */

/*            C */
/*            C     Multiply CMAT1 and CMAT2 directly. */
/*            C */
/*                  CALL MXM ( CMAT1, CMAT2, CMAT4 ) */

/*            C */
/*            C     Compare the results.  The difference DIFF of */
/*            C     CMAT3 and CMAT4 should be close to the zero */
/*            C     matrix. */
/*            C */
/*                  CALL VSUBG ( 9, CMAT3, CMAT4, DIFF ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 18-AUG-2002 (NJB) */


/* -& */
/* $ Index_Entries */

/*     quaternion times quaternion */
/*     multiply quaternion by quaternion */
/* -& */

/*     SPICELIB functions */


/*     Local variables */


/*     Compute the scalar part of the product. */

    qout[0] = q1[0] * q2[0] - vdot_(&q1[1], &q2[1]);

/*     And now the vector part.  The SPICELIB routine VLCOM3 computes */
/*     a linear combination of three 3-vectors. */

    vcrss_(&q1[1], &q2[1], cross);
    vlcom3_(q1, &q2[1], q2, &q1[1], &c_b2, cross, &qout[1]);
    return 0;
} /* qxq_ */

