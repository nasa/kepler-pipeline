/* q2m.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      Q2M ( Quaternion to matrix ) */
/* Subroutine */ int q2m_(doublereal *q, doublereal *r__)
{
    doublereal l2, q01, q02, q03, q12, q13, q23, sharpn, q1s, q2s, q3s;

/* $ Abstract */

/*     Find the rotation matrix corresponding to a specified unit */
/*     quaternion. */

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
/*     MATRIX */
/*     ROTATION */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     Q          I   A unit quaternion. */
/*     R          O   A rotation matrix corresponding to Q. */

/* $ Detailed_Input */

/*     Q              is a unit quaternion representing a rotation.  Q */
/*                    is a 4-dimensional vector.  Q has the property that */

/*                       || Q ||  =  1. */

/* $ Detailed_Output */

/*     R              is a 3 by 3 rotation matrix representing the same */
/*                    rotation as does Q.  If Q represents a rotation by */
/*                    r radians about some axis vector A, then for any */
/*                    vector V, R*V yields V, rotated by r radians */
/*                    about A. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) If Q is not a unit quaternion, the output matrix M is */
/*        the rotation matrix that is the result of converting */
/*        normalized Q to a rotation matrix. */

/*     2) If Q is the zero quaternion, the output matrix M is */
/*        the identity matrix. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     If a 4-dimensional vector Q satisfies the equality */

/*        || Q ||   =  1 */

/*     or equivalently */

/*            2          2          2          2 */
/*        Q(0)   +   Q(1)   +   Q(2)   +   Q(3)   =  1, */

/*     then we can always find a unit vector A and a scalar r such that */

/*        Q = ( cos(r/2), sin(r/2)A(1), sin(r/2)A(2), sin(r/2)A(3) ). */

/*     We can interpret A and r as the axis and rotation angle of a */
/*     rotation in 3-space.  If we restrict r to the range [0, pi], */
/*     then r and A are uniquely determined, except if r = pi.  In this */
/*     special case, A and -A are both valid rotation axes. */

/*     Every rotation is represented by a unique orthogonal matrix; this */
/*     routine returns that unique rotation matrix corresponding to Q. */

/*     The SPICELIB routine M2Q is a one-sided inverse of this routine: */
/*     given any rotation matrix R, the calls */

/*        CALL M2Q ( R, Q ) */
/*        CALL Q2M ( Q, R ) */

/*     leave R unchanged, except for round-off error.  However, the */
/*     calls */

/*        CALL Q2M ( Q, R ) */
/*        CALL M2Q ( R, Q ) */

/*     might preserve Q or convert Q to -Q. */

/* $ Examples */

/*     1)  A case amenable to checking by hand calculation: */

/*            To convert the quaternion */

/*               Q = ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ) */

/*            to a rotation matrix, we can use the code fragment */

/*               Q(0) =  DSQRT(2)/2.D0 */
/*               Q(1) =  0.D0 */
/*               Q(2) =  0.D0 */
/*               Q(3) = -DSQRT(2)/2.D0 */

/*               CALL Q2M ( Q, R ) */

/*            The matrix R will be set equal to */

/*               +-              -+ */
/*               |  0     1    0  | */
/*               |                | */
/*               | -1     0    0  |. */
/*               |                | */
/*               |  0     0    1  | */
/*               +-              -+ */

/*            Why?  Well, Q represents a rotation by some angle r about */
/*            some axis vector A, where r and A satisfy */

/*               Q = */

/*               ( cos(r/2), sin(r/2)A(1), sin(r/2)A(2), sin(r/2)A(3) ). */

/*            In this example, */

/*               Q = ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ), */

/*            so */

/*               cos(r/2) = sqrt(2)/2. */

/*            Assuming that r is in the interval [0, pi], we must have */

/*               r = pi/2, */

/*            so */

/*               sin(r/2) = sqrt(2)/2. */

/*            Since the second through fourth components of Q represent */

/*               sin(r/2) * A, */

/*            it follows that */

/*               A = ( 0, 0, -1 ). */

/*            So Q represents a transformation that rotates vectors by */
/*            pi/2 about the negative z-axis.  This is equivalent to a */
/*            coordinate system rotation of pi/2 about the positive */
/*            z-axis; and we recognize R as the matrix */

/*               [ pi/2 ] . */
/*                       3 */


/*     2)  Finding a set of Euler angles that represent a rotation */
/*         specified by a quaternion: */

/*            Suppose our rotation R is represented by the quaternion */
/*            Q.  To find angles TAU, ALPHA, DELTA such that */


/*               R  =  [ TAU ]  [ pi/2 - DELTA ]  [ ALPHA ] , */
/*                            3                 2          3 */

/*            we can use the code fragment */


/*               CALL Q2M    ( Q, R ) */

/*               CALL M2EUL  ( R,   3,      2,       3, */
/*              .                   TAU,    DELTA,   ALPHA  ) */

/*               DELTA = HALFPI() - DELTA */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     [1]    NAIF document 179.0, "Rotations and their Habits", by */
/*            W. L. Taber. */

/* $ Author_and_Institution */

/*     N.J. Bachman   (JPL) */
/*     W.L. Taber     (JPL) */
/*     F.S. Turner    (JPL) */

/* $ Version */

/* -    SPICELIB Version 1.1.1, 13-JUN-2002 (FST) */

/*        Updated the Exceptions section to clarify exceptions that */
/*        are the result of changes made in the previous version of */
/*        the routine. */

/* -    SPICELIB Version 1.1.0, 04-MAR-1999 (WLT) */

/*        Added code to handle the case in which the input quaternion */
/*        is not of length 1. */

/* -    SPICELIB Version 1.0.1, 10-MAR-1992 (WLT) */

/*        Comment section for permuted index source lines was added */
/*        following the header. */

/* -    SPICELIB Version 1.0.0, 30-AUG-1990 (NJB) */

/* -& */
/* $ Index_Entries */

/*     quaternion to matrix */

/* -& */

/*     Local variables */


/*     If a matrix R represents a rotation of r radians about the unit */
/*     vector n, we know that R can be represented as */

/*                                           2 */
/*        I  +  sin(r) N  +  [ 1 - cos(r) ] N , */

/*     where N is the matrix that satisfies */

/*        Nv = n x v */

/*     for all vectors v, namely */

/*             +-                -+ */
/*             |  0    -n     n   | */
/*             |         3     2  | */
/*             |                  | */
/*        N =  |  n     0    -n   |. */
/*             |   3           1  | */
/*             |                  | */
/*             | -n     n     0   | */
/*             |   2     1        | */
/*             +-                -+ */


/*      Define S as */

/*         sin(r/2) N, */

/*      and let our input quaternion Q be */

/*         ( q ,  q ,  q ,  q ). */
/*            0    1    2    3 */

/*      Using the facts that */

/*                             2 */
/*         1 - cos(r)  =  2 sin (r/2) */

/*      and */

/*         sin(r)      =  2 cos(r/2) sin(r/2), */


/*      we can express R as */

/*                                      2 */
/*         I  +  2 cos(r/2) S    +   2 S, */

/*      or */
/*                                2 */
/*         I  +  2 q  S    +   2 S. */
/*                  0 */

/*      Since S is just */

/*         +-                -+ */
/*         |  0    -q     q   | */
/*         |         3     2  | */
/*         |                  | */
/*         |  q     0    -q   |, */
/*         |   3           1  | */
/*         |                  | */
/*         | -q     q     0   | */
/*         |   2     1        | */
/*         +-                -+ */

/*      our expression for R comes out to */

/*         +-                                                         -+ */
/*         |          2   2                                            | */
/*         | 1 - 2 ( q + q  )    2( q q  -  q q )     2 ( q q  + q q ) | */
/*         |          2   3          1 2     0 3           1 3    0 2  | */
/*         |                                                           | */
/*         |                              2   2                        | */
/*         | 2( q q  +  q q )    1 - 2 ( q + q  )     2 ( q q  - q q ) |. */
/*         |     1 2     0 3              1   3            2 3    0 1  | */
/*         |                                                           | */
/*         |                                                   2   2   | */
/*         | 2( q q  -  q q )    2 ( q q  + q q )     1 - 2 ( q + q  ) | */
/*         |     1 3     0 2          2 3    0 1               1   2   | */
/*         +-                                                         -+ */


/*      For efficiency, we avoid duplicating calculations where possible. */

    q01 = q[0] * q[1];
    q02 = q[0] * q[2];
    q03 = q[0] * q[3];
    q12 = q[1] * q[2];
    q13 = q[1] * q[3];
    q23 = q[2] * q[3];
    q1s = q[1] * q[1];
    q2s = q[2] * q[2];
    q3s = q[3] * q[3];

/*     We sharpen the computation by effectively converting Q to */
/*     a unit quaternion if it isn't one already. */

    l2 = q[0] * q[0] + q1s + q2s + q3s;
    if (l2 != 1. && l2 != 0.) {
	sharpn = 1. / l2;
	q01 *= sharpn;
	q02 *= sharpn;
	q03 *= sharpn;
	q12 *= sharpn;
	q13 *= sharpn;
	q23 *= sharpn;
	q1s *= sharpn;
	q2s *= sharpn;
	q3s *= sharpn;
    }
    r__[0] = 1. - (q2s + q3s) * 2.;
    r__[1] = (q12 + q03) * 2.;
    r__[2] = (q13 - q02) * 2.;
    r__[3] = (q12 - q03) * 2.;
    r__[4] = 1. - (q1s + q3s) * 2.;
    r__[5] = (q23 + q01) * 2.;
    r__[6] = (q13 + q02) * 2.;
    r__[7] = (q23 - q01) * 2.;
    r__[8] = 1. - (q1s + q2s) * 2.;
    return 0;
} /* q2m_ */

