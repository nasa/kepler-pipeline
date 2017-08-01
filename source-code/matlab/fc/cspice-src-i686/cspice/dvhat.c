/* dvhat.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      DVHAT ( Derivative and unit vector "V-hat" of a state) */
/* Subroutine */ int dvhat_(doublereal *s1, doublereal *sout)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *), vperp_(
	    doublereal *, doublereal *, doublereal *), unorm_(doublereal *, 
	    doublereal *, doublereal *);
    doublereal length;
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);

/* $ Abstract */

/*     Find the unit vector corresponding to a state vector and the */
/*     derivative of the unit vector. */

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

/*     VECTOR */
/*     DERIVATIVE */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     S1        I     State to be normalized. */
/*     SOUT      O     Unit vector S1 / |S1|, and its time derivative. */

/* $ Detailed_Input */

/*     S1       This is any double precision state. If the position */
/*              component of the state is the zero vector, this routine */
/*              will detect it and will not attempt to divide by zero. */

/* $ Detailed_Output */

/*     SOUT     SOUT is a state containing the unit vector pointing in */
/*              the direction of position component of S1 and the */
/*              derivative of the unit vector with respect to time. */

/*              SOUT may overwrite S1. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/*     1) If S1 represents the zero vector, then the position */
/*        component of SOUT will also be the zero vector.  The */
/*        velocity component will be the velocity component */
/*        of S1. */

/* $ Particulars */

/*     Let S1 be a state vector with position and velocity components P */
/*     and V respectively.  From these components one can compute the */
/*     unit vector parallel to P, call it U and the derivative of U */
/*     with respect to time, DU.  This pair (U,DU) is the state returned */
/*     by this routine in SOUT. */

/* $ Examples */

/*     Suppose that STATE gives the apparent state of a body with */
/*     respect to an observer.  This routine can be used to compute the */
/*     instantaneous angular rate of the object across the sky as seen */
/*     from the observers vantage. */

/*        INTEGER               POS */
/*        PARAMETER           ( POS = 1 ) */

/*        INTEGER               VEL */
/*        PARAMETER           ( VEL = 4 ) */

/*        CALL DVHAT ( STATE, USTATE ) */

/*        ANGULAR_RATE = VNORM ( USTATE(VEL) ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.1.0, 02-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VPERP and VSCL calls. */

/* -    SPICELIB Version 1.0.0, 15-JUN-1995 (WLT) */

/* -& */
/* $ Index_Entries */

/*     State of a unit vector parallel to a state vector */

/* -& */

/* $ Revisions */

/* -    SPICELIB Version 1.1.0, 02-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VPERP and VSCL calls. */

/* -& */

/*     Get the position portion of the output state and the length of */
/*     the input position. */

    unorm_(s1, sout, &length);
    if (length == 0.) {

/*        If the length of the input position is zero, just copy */
/*        the input velocity to the output velocity. */

	vequ_(&s1[3], &sout[3]);
    } else {

/*        Otherwise the derivative of the unit vector is just the */
/*        component of the input velocity perpendicular to the input */
/*        position, scaled by the reciprocal of the length of the */
/*        input position. */

	vperp_(&s1[3], sout, &sout[3]);
	d__1 = 1. / length;
	vsclip_(&d__1, &sout[3]);
    }
    return 0;
} /* dvhat_ */

