/* inelpl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static doublereal c_b8 = 1.;

/* $Procedure      INELPL ( Intersection of ellipse and plane ) */
/* Subroutine */ int inelpl_(doublereal *ellips, doublereal *plane, integer *
	nxpts, doublereal *xpt1, doublereal *xpt2)
{
    /* System generated locals */
    doublereal d__1, d__2;

    /* Builtin functions */
    double acos(doublereal), atan2(doublereal, doublereal), cos(doublereal), 
	    sin(doublereal);

    /* Local variables */
    doublereal beta;
    extern doublereal vdot_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    doublereal alpha, v[2];
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal const__, trans[4], point[3], angle1, angle2;
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), vlcom3_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *), pl2nvc_(doublereal *, doublereal *, doublereal *), 
	    pl2nvp_(doublereal *, doublereal *, doublereal *), nvp2pl_(
	    doublereal *, doublereal *, doublereal *);
    doublereal center[3], normal[3], smajor[3];
    extern /* Subroutine */ int chkout_(char *, ftnlen);
    doublereal tmpvec[3], sminor[3];
    extern doublereal vnormg_(doublereal *, integer *);
    extern logical vzerog_(doublereal *, integer *), return_(void);

/* $ Abstract */

/*     Find the intersection of an ellipse and a plane. */

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

/*     ELLIPSES */
/*     PLANES */

/* $ Keywords */

/*     ELLIPSE */
/*     GEOMETRY */
/*     MATH */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     ELLIPS     I   A SPICELIB ellipse. */
/*     PLANE      I   A SPICELIB plane. */
/*     NXPTS      O   Number of intersection points of plane and ellipse. */
/*     XPT1, */
/*     XPT2       O   Intersection points. */

/* $ Detailed_Input */

/*     ELLIPS         is a SPICELIB ellipse. */

/*     PLANE          is a SPICELIB plane. */

/* $ Detailed_Output */

/*     NXPTS          is the number of points of intersection of the */
/*                    geometric plane and ellipse represented by PLANE */
/*                    and ELLIPS. NXPTS may take the values 0, 1, 2 or */
/*                    -1.  The value -1 indicates that the ellipse lies */
/*                    in the plane, so the number of intersection points */
/*                    is infinite. */

/*     XPT1, */
/*     XPT2           are the points of intersection of the input plane */
/*                    and ellipse.  If there is only one intersection */
/*                    point, both XPT1 and XPT2 contain that point.  If */
/*                    the number of intersection points is zero or */
/*                    infinite, the contents of XPT1 and XPT2 are */
/*                    undefined. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)  If the input ellipse is invalid, the error will be diagnosed */
/*         by routines called by this routine. */

/*     2)  If the input plane is invalid, the error will be diagnosed by */
/*         routines called by this routine. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     A plane may intersect an ellipse in 0, 1, 2, or infinitely many */
/*     points.  To get lots of intersection points, the ellipse must */
/*     lie in the plane. */

/* $ Examples */

/*     1)  If we want to find the angle of some ray above the limb of an */
/*         ellipsoid, where the angle is measured in a plane containing */
/*         the ray and a `down' vector, we can follow the procedure */
/*         given below.  We assume the ray does not intersect the */
/*         ellipsoid.  The result we seek is called ANGLE, imaginatively */
/*         enough. */

/*         We assume that all vectors are given in body-fixed */
/*         coordinates. */

/*            C */
/*            C     Find the limb of the ellipsoid as seen from the */
/*            C     point OBSERV.  Here A, B, and C are the lengths of */
/*            C     the semi-axes of the ellipsoid. */
/*            C */
/*                  CALL EDLIMB ( A, B, C, OBSERV, LIMB ) */

/*            C */
/*            C     The ray direction vector is RAYDIR, so the ray is the */
/*            C     set of points */
/*            C */
/*            C        OBSERV  +  t * RAYDIR */
/*            C */
/*            C     where t is any non-negative real number. */
/*            C */
/*            C     The `down' vector is just -OBSERV.  The vectors */
/*            C     OBSERV and RAYDIR are spanning vectors for the plane */
/*            C     we're interested in.  We can use PSV2PL to represent */
/*            C     this plane by a SPICELIB plane. */
/*            C */
/*                  CALL PSV2PL ( OBSERV, OBSERV, RAYDIR, PLANE ) */

/*            C */
/*            C     Find the intersection of the plane defined by OBSERV */
/*            C     and RAYDIR with the limb. */
/*            C */
/*                  CALL INELPL ( LIMB, PLANE, NXPTS, XPT1, XPT2 ) */

/*            C */
/*            C     We always expect two intersection points, if DOWN */
/*            C     is valid. */
/*            C */
/*                  IF ( NXPTS .LT. 2 ) THEN */

/*                     [ do something about the error ] */

/*                  ENDIF */

/*            C */
/*            C     Form the vectors from OBSERV to the intersection */
/*            C     points.  Find the angular separation between the */
/*            C     boresight ray and each vector from OBSERV to the */
/*            C     intersection points. */
/*            C */
/*                  CALL VSUB   ( XPT1, OBSERV, VEC1 ) */
/*                  CALL VSUB   ( XPT2, OBSERV, VEC2 ) */

/*                  SEP1 = VSEP ( VEC1, RAYDIR ) */
/*                  SEP2 = VSEP ( VEC2, RAYDIR ) */

/*            C */
/*            C     The angular separation we're after is the minimum of */
/*            C     the two separations we've computed. */
/*            C */
/*                  ANGLE = MIN ( SEP1, SEP2 ) */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman   (JPL) */

/* $ Version */

/* -    SPICELIB Version 1.2.0, 25-AUG-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VSUB call. */

/* -    SPICELIB Version 1.1.0, 24-MAR-1992 (NJB) (WLT) */

/*        Output arguments XPT1, XPT2 are now correctly declared */
/*        with length 3.  Comment section for permuted index source */
/*        lines was added following the header. */

/* -    SPICELIB Version 1.0.0, 02-NOV-1990 (NJB) */

/* -& */
/* $ Index_Entries */

/*     intersection of ellipse and plane */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 1.2.0, 25-AUG-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VSUB call. */

/* -    SPICELIB Version 1.1.0, 24-MAR-1992 (NJB) (WLT) */

/*        Output arguments XPT1, XPT2 are now correctly declared */
/*        with length 3.  They formerly were declared as scalars. */
/*        The correction will not affect the behavior of the routine */
/*        in programs that already declared the correponding arguments */
/*        correctly. */

/*        Comment section for permuted index source lines was added */
/*        following the header. */

/* -& */

/*     SPICELIB functions */


/*     Local variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("INELPL", (ftnlen)6);
    }

/*     The first thing we want to do is translate the plane and the */
/*     ellipse so as to center the ellipse at the origin.  To translate */
/*     the plane, just get a point and normal vector, and translate */
/*     the point.  Find the plane constant of the translated plane. */

    el2cgv_(ellips, center, smajor, sminor);
    pl2nvp_(plane, normal, tmpvec);
    vsub_(tmpvec, center, point);
    nvp2pl_(normal, point, trans);
    pl2nvc_(trans, normal, &const__);

/*        Ok, we can get to work.  The locus of the ellipse is */

/*           cos(theta) SMAJOR  +  sin(theta) SMINOR, */

/*        and any point X of the ellipse that intersects the input plane */
/*        satisfies */

/*           < X, NORMAL >  =  CONST. */

/*        Substituting our expression for points on the ellipse into the */
/*        second equation, we arrive at */

/*              cos(theta) < SMAJOR, NORMAL > */
/*           +  sin(theta) < SMINOR, NORMAL >   =  CONST.        (1) */

/*        This equation merits a little analysis.  First, if NORMAL */
/*        is orthogonal to SMAJOR and SMINOR, the plane and ellipse must */
/*        be parallel.  Also, the left side of the equation is zero in */
/*        this case.   If CONST is non-zero, there are no solutions: */
/*        the ellipse and plane are parallel but do not intersect.  If */
/*        CONST is zero, the ellipse lies in the plane:  all values of */
/*        theta are solutions.  Let's get this case out of the way */
/*        right now, shall we? */

    v[0] = vdot_(smajor, normal);
    v[1] = vdot_(sminor, normal);

/*     Test whether the plane and ellipse are parallel: */

    if (vzerog_(v, &c__2)) {

/*        The ellipse lies in the plane if and only if CONST is zero. */
/*        In any case, we don't modify XPT1 or XPT2. */

	if (const__ == 0.) {
	    *nxpts = -1;
	} else {
	    *nxpts = 0;
	}
	chkout_("INELPL", (ftnlen)6);
	return 0;
    }

/*        Now if NORMAL is not orthogonal to both SMAJOR and SMINOR, */
/*        the vector */

/*           V = (  < SMAJOR, NORMAL >,  < SMINOR, NORMAL >  ) */

/*        is non-zero.  We can re-write (1) as */

/*           < U, V >  =  CONST, */

/*        where */

/*           U = ( cos(theta), sin(theta) ). */

/*        If alpha is the angle between U and V, we have */

/*           < U, V >  =  || U ||  *  || V ||  *  cos(alpha), */

/*        so */

/*           || V ||  *  cos(alpha)  =  CONST.                   (2) */

/*        This equation has solutions if and only if */

/*           || V ||  >    CONST.                                (3) */
/*                    - */

/*        CONST is positive, since PL2NVC returns a the distance */
/*        of between its input plane and the origin as the output */
/*        plane constant. */

/*        Let's return right now if there are no solutions. */

    if (vnormg_(v, &c__2) < const__) {
	*nxpts = 0;
	chkout_("INELPL", (ftnlen)6);
	return 0;
    }

/*        Since (3) above is satisfied, the plane and ellipse intersect. */
/*        We can find alpha by the formula */

/*           alpha  =  +  arccos (  CONST  /  || V ||  ) */

/*        Since alpha is the angular separation between U and V, we */
/*        can find U once we have the angular position of V; let's */
/*        call that beta.  The angular position of U (which we called */
/*        theta earlier) will be */

/*           theta   =   beta  +  alpha. */
/*                             - */

/*        The values of theta are the angles we seek. */

    alpha = acos(const__ / vnormg_(v, &c__2));
    beta = atan2(v[1], v[0]);
    angle1 = beta - alpha;
    angle2 = beta + alpha;
    if (angle1 == angle2) {
	*nxpts = 1;
    } else {
	*nxpts = 2;
    }

/*     Compute the intersection points. */

    d__1 = cos(angle1);
    d__2 = sin(angle1);
    vlcom3_(&c_b8, center, &d__1, smajor, &d__2, sminor, xpt1);
    d__1 = cos(angle2);
    d__2 = sin(angle2);
    vlcom3_(&c_b8, center, &d__1, smajor, &d__2, sminor, xpt2);
    chkout_("INELPL", (ftnlen)6);
    return 0;
} /* inelpl_ */

