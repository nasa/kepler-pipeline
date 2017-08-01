/* qdq2av.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static doublereal c_b3 = -2.;

/* $Procedure QDQ2AV (Quaternion and quaternion derivative to a.v.) */
/* Subroutine */ int qdq2av_(doublereal *q, doublereal *dq, doublereal *av)
{
    doublereal qhat[4];
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    ), vhatg_(doublereal *, integer *, doublereal *);
    doublereal qtemp[4], qstar[4];
    extern /* Subroutine */ int vminus_(doublereal *, doublereal *), qxq_(
	    doublereal *, doublereal *, doublereal *);

/* $ Abstract */

/*     Derive angular velocity from a unit quaternion and its derivative */
/*     with respect to time. */

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
/*     Q          I   Unit SPICE quaternion. */
/*     DQ         I   Derivative of Q with respect to time. */
/*     AV         O   Angular velocity defined by Q and DQ. */

/* $ Detailed_Input */

/*     Q              is a unit length 4-vector representing a */
/*                    SPICE-style quaternion. */

/*                    Note that multiple styles of quaternions */
/*                    are in use.  This routine will not work properly */
/*                    if the input quaternions do not conform to */
/*                    the SPICE convention.  See the Particulars */
/*                    section for details. */

/*     DQ             is a 4-vector representing the derivative of */
/*                    Q with respect to time. */

/* $ Detailed_Output */

/*     AV             is 3-vector representing the angular velocity */
/*                    defined by Q and DQ, that is, the angular velocity */
/*                    of the frame defined by the rotation matrix */
/*                    associated with Q.  This rotation matrix can be */
/*                    obtained via the SPICELIB routine Q2M; see the */
/*                    Particulars section for the explicit matrix */
/*                    entries. */

/*                    AV is the vector (imaginary) part of the */
/*                    quaternion product */

/*                             * */
/*                       -2 * Q  * DQ */

/*                    This angular velocity is the same vector that */
/*                    could be obtained (much less efficiently ) by */
/*                    mapping Q and DQ to the corresponding C-matrix R */
/*                    and its derivative DR, then calling the SPICELIB */
/*                    routine XF2RAV. */

/*                    AV has units of */

/*                       radians / T */

/*                    where */

/*                       1 / T */

/*                    is the unit associated with DQ. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) A unitized version of input quaternion is used in the */
/*        computation.  No attempt is made to diagnose an invalid */
/*        input quaternion. */

/* $ Particulars */


/*     About SPICE quaternions */
/*     ======================= */

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


/*     About this routine */
/*     ================== */

/*     Given a time-dependent SPICE quaternion representing the */
/*     attitude of an object, we can obtain the object's angular */
/*     velocity AV in terms of the quaternion Q and its derivative */
/*     with respect to time DQ: */

/*                          * */
/*        AV  =  Im ( -2 * Q  * DQ )                                  (1) */

/*     That is, AV is the vector (imaginary) part of the product */
/*     on the right hand side (RHS) of equation (1).  The scalar part */
/*     of the RHS is zero. */

/*     We'll now provide an explanation of formula (1). For any */
/*     time-dependent rotation, the associated angular velocity at a */
/*     given time is a function of the rotation and its derivative at */
/*     that time. This fact enables us to extend a proof for a limited */
/*     subset of rotations to *all* rotations:  if we find a formula */
/*     that, for any rotation in our subset, gives us the angular */
/*     velocity as a function of the rotation and its derivative, then */
/*     that formula must be true for all rotations. */

/*     We start out by considering the set of rotation matrices */

/*        R(t) = M(t)C                                                (2) */

/*     where C is a constant rotation matrix and M(t) represents a */
/*     matrix that "rotates" with constant, unit magnitude angular */
/*     velocity and that is equal to the identity matrix at t = 0. */

/*     For future reference, we'll consider C to represent a coordinate */
/*     transformation from frame F1 to frame F2.  We'll call F1 the */
/*     "base frame" of C.  We'll let AVF2 be the angular velocity of */
/*     M(t) relative to F2 and AVF1 be the same angular velocity */
/*     relative to F1. */

/*     Referring to the axis-and-angle decomposition of M(t) */

/*                                                2 */
/*        M(t) = I + sin(t)OMEGA + (1-cos(t))OMEGA                    (3) */

/*     (see the Rotation Required Reading for a derivation) we */
/*     have */

/*        d(M(t))| */
/*        -------|     = OMEGA                                        (4) */
/*          dt   |t=0 */

/*     Then the derivative of R(t) at t = 0 is given by */


/*        d(R(t))| */
/*        -------|     = OMEGA  * C                                   (5) */
/*          dt   |t=0 */


/*     The rotation axis A associated with OMEGA is defined by        (6) */

/*        A(1) =  - OMEGA(2,3) */
/*        A(2) =    OMEGA(1,3) */
/*        A(3) =  - OMEGA(1,2) */

/*     Since the coordinate system rotation M(t) rotates vectors about A */
/*     through angle t radians at time t, the angular velocity AVF2 of */
/*     M(t) is actually given by */

/*        AVF2  =  - A                                                (7) */

/*     This angular velocity is represented relative to the image */
/*     frame F2 associated with the coordinate transformation C. */

/*     Now, let's proceed to the angular velocity formula for */
/*     quaternions. */

/*     To avoid some verbiage, we'll freely use 3-vectors to represent */
/*     the corresponding pure imaginary quaternions. */

/*     Letting QR(t), QM(t), and QC be quaternions representing the */
/*     time-dependent matrices R(t), M(t) and C respectively, where */
/*     QM(t) is selected to be a differentiable function of t in a */
/*     neighborhood of t = 0, the quaternion representing R(t) is */

/*        QR(t) = QM(t) * QC                                          (8) */

/*     Differentiating with respect to t, then evaluating derivatives */
/*     at t = 0, we have */

/*        d(QR(t))|         d(QM(t))| */
/*        --------|     =   --------|     * QC                        (9) */
/*           dt   |t=0         dt   |t=0 */


/*     Since QM(t) represents a rotation having axis A and rotation */
/*     angle t, then (according to the relationship between SPICE */
/*     quaternions and rotations set out in the Rotation Required */
/*     Reading), we see QM(t) must be the quaternion (represented as the */
/*     sum of scalar and vector parts): */

/*        cos(t/2)  +  sin(t/2) * A                                  (10) */

/*     where A is the rotation axis corresponding to the matrix */
/*     OMEGA introduced in equation (3).  By inspection */

/*        d(QM(t))| */
/*        --------|     =   1/2 * A                                  (11) */
/*           dt   |t=0 */

/*     which is a quaternion with scalar part zero.  This allows us to */
/*     rewrite the quaternion derivative */

/*        d(QR(t))| */
/*        --------|     =   1/2  *  A  *  QC                         (12) */
/*           dt   |t=0 */

/*     or for short, */

/*        DQ = 1/2 * A * QC                                          (13) */

/*     Since from (7) we know the angular velocity AVF2 of the frame */
/*     associated with QM(t) is the negative of the rotation axis */
/*     defined by (3), we have */

/*        DQ = - 1/2 * AVF2 * QC                                     (14) */

/*     Since */

/*        AVF2 = C * AVF1                                            (15) */

/*     we can apply the quaternion transformation formula */
/*     (from the Rotation Required Reading) */

/*                                 * */
/*        AVF2 =  QC  *  AVF1  * QC                                  (16) */

/*     Now we re-write (15) as */

/*                                     * */
/*        DQ = - 1/2 * ( QC * AVF1 * QC ) * QC */

/*           = - 1/2 *   QC * AVF1                                   (17) */

/*     Then the angular velocity vector AVF1 is given by */

/*                       * */
/*        AVF1  = -2 * QC  * DQ                                      (18) */

/*     The relation (18) has now been demonstrated for quaternions */
/*     having constant, unit magnitude angular velocity.  But since */
/*     all time-dependent quaternions having value QC and derivative */
/*     DQ at a given time t have the same angular velocity at time t, */
/*     that angular velocity must be AVF1. */

/* $ Examples */

/*     The following test program creates a quaternion and quaternion */
/*     derivative from a known rotation matrix and angular velocity */
/*     vector.  The angular velocity is recovered from the quaternion */
/*     and quaternion derivative by calling QDQ2AV and by an */
/*     alternate method; the results are displayed for comparison. */

/*              PROGRAM TQDQ2AV */
/*              IMPLICIT NONE */
/*        C */
/*        C     Start with a known rotation and angular velocity.  Find */
/*        C     the quaternion and quaternion derivative.  The latter is */
/*        C     computed from */
/*        C */
/*        C                       * */
/*        C        AV  =   -2  * Q  * DQ */
/*        C */
/*        C        DQ  =  -1/2 * Q  * AV */
/*        C */
/*        C */
/*        C     SPICELIB Functions */
/*        C */
/*              DOUBLE PRECISION      RPD */

/*        C */
/*        C     Local variables */
/*        C */
/*              DOUBLE PRECISION      ANGLE  ( 3 ) */
/*              DOUBLE PRECISION      AV     ( 3 ) */
/*              DOUBLE PRECISION      AVX    ( 3 ) */
/*              DOUBLE PRECISION      DM     ( 3,  3 ) */
/*              DOUBLE PRECISION      DQ     ( 0 : 3 ) */
/*              DOUBLE PRECISION      EXPAV  ( 3 ) */
/*              DOUBLE PRECISION      M      ( 3,  3 ) */
/*              DOUBLE PRECISION      MOUT   ( 3,  3 ) */
/*              DOUBLE PRECISION      Q      ( 0 : 3 ) */
/*              DOUBLE PRECISION      QAV    ( 0 : 3 ) */
/*              DOUBLE PRECISION      XTRANS ( 6,  6 ) */

/*              INTEGER               I */
/*              INTEGER               J */

/*        C */
/*        C     Pick some Euler angles and form a rotation matrix. */
/*        C */
/*              ANGLE(1) = -20.0 * RPD() */
/*              ANGLE(2) =  50.0 * RPD() */
/*              ANGLE(3) = -60.0 * RPD() */

/*              CALL EUL2M ( ANGLE(3), ANGLE(2), ANGLE(1), 3, 1, 3, M ) */

/*              CALL M2Q   ( M, Q ) */

/*        C */
/*        C     Choose an angular velocity vector. */
/*        C */
/*              EXPAV(1) =  1.0D0 */
/*              EXPAV(2) =  2.0D0 */
/*              EXPAV(3) =  3.0D0 */

/*        C */
/*        C     Form the quaternion derivative. */
/*        C */
/*              QAV(0)    =  0.D0 */
/*              CALL VEQU ( EXPAV, QAV(1) ) */

/*              CALL QXQ ( Q, QAV, DQ ) */

/*              CALL VSCLG ( -0.5D0, DQ, 4, DQ ) */

/*        C */
/*        C     Recover angular velocity from Q and DQ using QDQ2AV. */
/*        C */
/*              CALL QDQ2AV ( Q, DQ, AV ) */

/*        C */
/*        C     Now we'll obtain the angular velocity from Q and */
/*        C     DQ by an alternate method. */
/*        C */
/*        C     Convert Q back to a rotation matrix. */
/*        C */
/*              CALL Q2M ( Q, M ) */

/*        C */
/*        C     Convert Q and DQ to a rotation derivative matrix.  This */
/*        C     somewhat messy procedure is based on differentiating the */
/*        C     formula for deriving a rotation from a quaternion, then */
/*        C     substituting components of Q and DQ into the derivative */
/*        C     formula. */
/*        C */

/*              DM(1,1)  =  -4.D0 * (   Q(2)*DQ(2)  +  Q(3)*DQ(3)  ) */

/*              DM(1,2)  =   2.D0 * (   Q(1)*DQ(2)  +  Q(2)*DQ(1) */
/*             .                      - Q(0)*DQ(3)  -  Q(3)*DQ(0)  ) */

/*              DM(1,3)  =   2.D0 * (   Q(1)*DQ(3)  +  Q(3)*DQ(1) */
/*             .                      + Q(0)*DQ(2)  +  Q(2)*DQ(0)  ) */

/*              DM(2,1)  =   2.D0 * (   Q(1)*DQ(2)  +  Q(2)*DQ(1) */
/*             .                      + Q(0)*DQ(3)  +  Q(3)*DQ(0)  ) */

/*              DM(2,2)  =  -4.D0 * (   Q(1)*DQ(1)  +  Q(3)*DQ(3)  ) */

/*              DM(2,3)  =   2.D0 * (   Q(2)*DQ(3)  +  Q(3)*DQ(2) */
/*             .                      - Q(0)*DQ(1)  -  Q(1)*DQ(0)  ) */

/*              DM(3,1)  =   2.D0 * (   Q(3)*DQ(1)  +  Q(1)*DQ(3) */
/*             .                      - Q(0)*DQ(2)  -  Q(2)*DQ(0)  ) */

/*              DM(3,2)  =   2.D0 * (   Q(2)*DQ(3)  +  Q(3)*DQ(2) */
/*             .                      + Q(0)*DQ(1)  +  Q(1)*DQ(0)  ) */

/*              DM(3,3)  =  -4.D0 * (   Q(1)*DQ(1)  +  Q(2)*DQ(2)  ) */

/*        C */
/*        C     Form the state transformation matrix corresponding to M */
/*        C     and DM. */

/*              CALL CLEARD ( 36, XTRANS ) */

/*        C */
/*        C     Upper left block: */
/*        C */
/*              DO I = 1, 3 */

/*                 DO J = 1, 3 */
/*                    XTRANS(I,J) = M(I,J) */
/*                 END DO */

/*              END DO */


/*        C */
/*        C     Lower right block: */
/*        C */
/*              DO I = 1, 3 */

/*                 DO J = 1, 3 */
/*                    XTRANS(3+I,3+J) = M(I,J) */
/*                 END DO */

/*              END DO */

/*        C */
/*        C     Lower left block: */
/*        C */
/*              DO I = 1, 3 */

/*                 DO J = 1, 3 */
/*                    XTRANS(3+I,J) = DM(I,J) */
/*                 END DO */

/*              END DO */

/*        C */
/*        C     Now use XF2RAV to produce the expected angular velocity. */
/*        C */
/*              CALL XF2RAV ( XTRANS, MOUT, AVX ) */

/*        C */
/*        C     The results should match to nearly full double */
/*        C     precision. */
/*        C */
/*              WRITE(*,*) 'Original angular velocity:  ', EXPAV */
/*              WRITE(*,*) 'QDQ2AV''s angular velocity:  ', AV */
/*              WRITE(*,*) 'XF2RAV''s angular velocity:  ', AVX */

/*              END */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.1.0, 31-AUG-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VSCL call. */

/* -    SPICELIB Version 1.0.1, 24-FEB-2004 (NJB) */

/*        Made minor edits to the Particulars header section. */

/* -    SPICELIB Version 1.0.0, 26-AUG-2002 (NJB) */


/* -& */
/* $ Index_Entries */

/*     angular velocity from  quaternion and derivative */
/* -& */
/* $ Revisions */

/* -    SPICELIB Version 1.1.0, 31-AUG-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VSCL call. */

/* -& */

/*     Local variables */


/*     Get a unitized copy of the input quaternion. */

    vhatg_(q, &c__4, qhat);

/*     Get the conjugate QSTAR of QHAT. */

    qstar[0] = qhat[0];
    vminus_(&qhat[1], &qstar[1]);

/*     Compute the angular velocity via the relationship */

/*                       * */
/*           AV  = -2 * Q  * DQ */

    qxq_(qstar, dq, qtemp);
    vscl_(&c_b3, &qtemp[1], av);
    return 0;
} /* qdq2av_ */

