/* clight.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure CLIGHT ( C, Speed of light in a vacuum ) */
doublereal clight_(void)
{
    /* System generated locals */
    doublereal ret_val;

/* $ Abstract */

/*     Return the speed of light in a vacuum (IAU official */
/*     value, in km/sec). */

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

/*     CONSTANTS */

/* $ Declarations */

/*     None. */

/* $ Brief_I/O */

/*     The function returns the speed of light in vacuo (km/sec). */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     The function returns the IAU official value for the speed of light */
/*     in vacuo: 299792.458 km/sec. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*      Error free. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     The function always returns the constant value shown above. */

/* $ Examples */

/*     The following example uses CLIGHT to determine the one-way */
/*     light-time (TAU) to an object whose position relative to an */
/*     observer is contained in POS. The light-time is then used */
/*     to antedate a request for data from the kernel pool: */

/*           DOUBLE PRECISION      CLIGHT */
/*           DOUBLE PRECISION      VNORM */

/*           DOUBLE PRECISION      POS     ( 3 ) */
/*           DOUBLE PRECISION      TAU */
/*           DOUBLE PRECISION      TRANS   ( 3,3 ) */

/*           INTEGER               BODY */
/*            . */
/*            . */

/*           TAU = VNORM ( POS ) / CLIGHT () */
/*           CALL BODMAT ( BODY, EPOCH - TAU, TRANS ) */

/*     Note that the SPK readers SPKEZ and SPKAPP return the one-way */
/*     light time as an output, */

/*           CALL SPKEZ  ( ..., TAU ) */
/*           CALL SPKAPP ( ..., TAU ) */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */
/*     I.M. Underwood  (JPL) */

/* $ Version */

/* -     SPICELIB Version 1.0.1, 10-MAR-1992 (WLT) */

/*         Comment section for permuted index source lines was added */
/*         following the header. */

/* -     SPICELIB Version 1.0.0, 31-JAN-1990 (WLT) (IMU) */

/* -& */
/* $ Index_Entries */

/*     c speed of light in a vacuum */

/* -& */

/*     Just like it says. */

    ret_val = 299792.458;
    return ret_val;
} /* clight_ */

