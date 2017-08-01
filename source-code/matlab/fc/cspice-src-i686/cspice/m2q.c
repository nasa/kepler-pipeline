/* m2q.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b2 = .1;

/* $Procedure      M2Q ( Matrix to quaternion ) */
/* Subroutine */ int m2q_(doublereal *r__, doublereal *q)
{
    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    doublereal c__, s[3];
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal trace, l2;
    extern logical isrot_(doublereal *, doublereal *, doublereal *);
    doublereal mtrace, factor, cc4;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen);
    doublereal polish;
    extern /* Subroutine */ int setmsg_(char *, ftnlen);
    doublereal s114, s224, s334;

/* $ Abstract */

/*     Find a unit quaternion corresponding to a specified rotation */
/*     matrix. */

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
/*     R          I   A rotation matrix. */
/*     Q          O   A unit quaternion representing R. */

/* $ Detailed_Input */

/*     R              is a rotation matrix. */

/* $ Detailed_Output */

/*     Q              is a unit quaternion representing R.  Q is a */
/*                    4-dimensional vector.  If R rotates vectors by an */
/*                    angle of r radians about a unit vector A, where */
/*                    r is in [0, pi], then if h = r/2, */

/*                       Q = ( cos(h), sin(h)A ,  sin(h)A ,  sin(h)A ). */
/*                                            1          2          3 */

/*                    The restriction that r must be in the range [0, pi] */
/*                    determines the output quaternion Q uniquely */
/*                    except when r = pi; in this special case, both of */
/*                    the quaternions */

/*                       Q = ( 0,  A ,  A ,  A  ) */
/*                                  1    2    3 */
/*                    and */

/*                       Q = ( 0, -A , -A , -A  ) */
/*                                  1    2    3 */

/*                   are possible outputs, if A is a choice of rotation */
/*                   axis for R. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)   If R is not a rotation matrix, the error SPICE(NOTAROTATION) */
/*          is signalled. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     A unit quaternion is a 4-dimensional vector for which the sum of */
/*     the squares of the components is 1.  Unit quaternions can be used */
/*     to represent rotations in the following way:  Given a rotation */
/*     angle r in [0, pi] and a unit vector A that acts as a rotation */
/*     axis, we define the quaternion Q by */

/*        Q = ( cos(r/2), sin(r/2)A , sin(r/2)A , sin(r/2)A ). */
/*                                 1           2           3 */

/*     As mentioned in $Detailed_Output, our restriction on the range of */
/*     r determines Q uniquely, except when r = pi. */

/*     The SPICELIB routine Q2M is an one-sided inverse of this routine: */
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

/*            To convert the rotation matrix */

/*                     +-              -+ */
/*                     |  0     1    0  | */
/*                     |                | */
/*               R  =  | -1     0    0  | */
/*                     |                | */
/*                     |  0     0    1  | */
/*                     +-              -+ */

/*            also represented as */

/*               [ pi/2 ] */
/*                       3 */

/*            to a quaternion, we can use the code fragment */

/*               CALL ROTATE (  HALFPI(),  3,  R  ) */
/*               CALL M2Q    (  R,             Q  ) */

/*            M2Q will return Q as */

/*               ( sqrt(2)/2, 0, 0, -sqrt(2)/2 ). */

/*            Why?  Well, R is a coordinate transformation that */
/*            rotates vectors by -pi/2 radians about the axis vector */

/*               A  = ( 0, 0, 1 ), */

/*            so our definition of Q, */

/*               Q = */

/*               ( cos(r/2), sin(r/2)A , sin(r/2)A , sin(r/2)A  ), */
/*                                    1           2           3 */

/*            implies that in this case, */

/*               Q =  ( cos(pi/4),  0,  0,  sin(pi/4)  ) */

/*                 =  ( sqrt(2)/2,  0,  0, -sqrt(2)/2  ). */


/*     2)  Finding a quaternion that represents a rotation specified by */
/*         a set of Euler angles: */

/*            Suppose our original rotation R is the product */

/*               [ TAU ]  [ pi/2 - DELTA ]  [ ALPHA ] . */
/*                      3                 2          3 */

/*            The code fragment */

/*               CALL EUL2M  ( TAU,   HALFPI() - DELTA,   ALPHA, */
/*              .              3,     2,                  3,      R ) */

/*               CALL M2Q    ( R, Q ) */

/*            yields a quaternion Q that represents R. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman   (JPL) */

/* $ Version */

/* -    SPICELIB Version 2.0.0, 17-SEP-1999 (WLT) */

/*        The routine was re-implemented to sharpen the numerical */
/*        stability of the routine and eliminate calls to SIN */
/*        and COS functions. */

/* -    SPICELIB Version 1.0.1, 10-MAR-1992 (WLT) */

/*        Comment section for permuted index source lines was added */
/*        following the header. */

/* -    SPICELIB Version 1.0.0, 30-AUG-1990 (NJB) */

/* -& */
/* $ Index_Entries */

/*     matrix to quaternion */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     NTOL and DETOL are used to determine whether R is a rotation */
/*     matrix. */

/*     NTOL is the tolerance for the norms of the columns of R. */

/*     DTOL is the tolerance for the determinant of a matrix whose */
/*     columns are the unitized columns of R. */



/*     Local Variables */


/*     If R is not a rotation matrix, we can't proceed. */

    if (! isrot_(r__, &c_b2, &c_b2)) {
	chkin_("M2Q", (ftnlen)3);
	setmsg_("Input matrix was not a rotation.", (ftnlen)32);
	sigerr_("SPICE(NOTAROTATION)", (ftnlen)19);
	chkout_("M2Q", (ftnlen)3);
	return 0;
    }


/*     If our quaternion is C, S1, S2, S3 (the S's being the imaginary */
/*     part) and we let */

/*        CSi = C  * Si */
/*        Sij = Si * Sj */

/*     then the rotation matrix corresponding to our quaternion is: */

/*        R(1,1)      = 1.0D0 - 2*S22 - 2*S33 */
/*        R(2,1)      =         2*S12 + 2*CS3 */
/*        R(3,1)      =         2*S13 - 2*CS2 */

/*        R(1,2)      =         2*S12 - 2*CS3 */
/*        R(2,2)      = 1.0D0 - 2*S11 - 2*S33 */
/*        R(3,2)      =         2*S23 + 2*CS1 */

/*        R(1,3)      =         2*S13 + 2*CS2 */
/*        R(2,3)      =         2*S23 - 2*CS1 */
/*        R(3,3)      = 1.0D0 - 2*S11 - 2*S22 */

/*        From the above we can see that */

/*           TRACE = 3 - 4*(S11 + S22 + S33) */

/*        so that */


/*           1.0D0 + TRACE = 4 - 4*(S11 + S22 + S33) */
/*                         = 4*(CC + S11 + S22 + S33) */
/*                         - 4*(S11 + S22 + S33) */
/*                         = 4*CC */

/*        Thus up to sign */

/*          C = 0.5D0 * DSQRT( 1.0D0 + TRACE ) */

/*        But we also have */

/*          1.0D0 + TRACE - 2.0D0*R(i,i) = 4.0D0 - 4.0D0(Sii + Sjj + Skk) */
/*                                       - 2.0D0 + 4.0D0(Sjj + Skk ) */

/*                                       = 2.0D0 - 4.0D0*Sii */

/*        So that */

/*           1.0D0 - TRACE + 2.0D0*R(i,i) = 4.0D0*Sii */

/*        and so up to sign */

/*           Si = 0.5D0*DSQRT( 1.0D0 - TRACE + 2.0D0*R(i,i) ) */

/*        in addition to this observation, we note that all of the */
/*        product pairs can easily be computed */

/*         CS1 = (R(3,2) - R(2,3))/4.0D0 */
/*         CS2 = (R(1,3) - R(3,1))/4.0D0 */
/*         CS3 = (R(2,1) - R(1,2))/4.0D0 */
/*         S12 = (R(2,1) + R(1,2))/4.0D0 */
/*         S13 = (R(3,1) + R(1,3))/4.0D0 */
/*         S23 = (R(2,3) + R(3,2))/4.0D0 */

/*     But taking sums or differences of numbers that are nearly equal */
/*     or nearly opposite results in a loss of precision. As a result */
/*     we should take some care in which terms to select when computing */
/*     C, S1, S2, S3.  However, by simply starting with one of the */
/*     large quantities cc, S11, S22, or S33 we can make sure that we */
/*     use the best of the 6 quantities above when computing the */
/*     remaining components of the quaternion. */

    trace = r__[0] + r__[4] + r__[8];
    mtrace = 1. - trace;
    cc4 = trace + 1.;
    s114 = mtrace + r__[0] * 2.;
    s224 = mtrace + r__[4] * 2.;
    s334 = mtrace + r__[8] * 2.;

/*     Note that if you simply add CC4 + S114 + S224 + S334 */
/*     you get four. Thus at least one of the 4 terms is greater than 1. */

    if (1. <= cc4) {
	c__ = sqrt(cc4 * .25);
	factor = 1. / (c__ * 4.);
	s[0] = (r__[5] - r__[7]) * factor;
	s[1] = (r__[6] - r__[2]) * factor;
	s[2] = (r__[1] - r__[3]) * factor;
    } else if (1. <= s114) {
	s[0] = sqrt(s114 * .25);
	factor = 1. / (s[0] * 4.);
	c__ = (r__[5] - r__[7]) * factor;
	s[1] = (r__[3] + r__[1]) * factor;
	s[2] = (r__[6] + r__[2]) * factor;
    } else if (1. <= s224) {
	s[1] = sqrt(s224 * .25);
	factor = 1. / (s[1] * 4.);
	c__ = (r__[6] - r__[2]) * factor;
	s[0] = (r__[3] + r__[1]) * factor;
	s[2] = (r__[7] + r__[5]) * factor;
    } else {
	s[2] = sqrt(s334 * .25);
	factor = 1. / (s[2] * 4.);
	c__ = (r__[1] - r__[3]) * factor;
	s[0] = (r__[6] + r__[2]) * factor;
	s[1] = (r__[7] + r__[5]) * factor;
    }

/*     If the magnitude of this quaternion is not one, we polish it */
/*     up a bit. */

    l2 = c__ * c__ + s[0] * s[0] + s[1] * s[1] + s[2] * s[2];
    if (l2 != 1.) {
	polish = 1. / sqrt(l2);
	c__ *= polish;
	s[0] *= polish;
	s[1] *= polish;
	s[2] *= polish;
    }
    if (c__ > 0.) {
	q[0] = c__;
	q[1] = s[0];
	q[2] = s[1];
	q[3] = s[2];
    } else {
	q[0] = -c__;
	q[1] = -s[0];
	q[2] = -s[1];
	q[3] = -s[2];
    }
    return 0;
} /* m2q_ */

