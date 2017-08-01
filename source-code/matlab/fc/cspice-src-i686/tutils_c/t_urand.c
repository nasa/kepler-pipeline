/* t_urand.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      T_URAND ( Random double precision number ) */
doublereal t_urand__(integer *seed)
{
    /* Initialized data */

    static integer idum2 = 123456789;
    static integer iv[32] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	    0,0,0,0,0,0,0,0 };
    static integer iy = 0;

    /* System generated locals */
    integer i__1;
    doublereal ret_val, d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer idum, j, k;

/* $ Abstract */

/*     Return a uniform random deviate in the range 0:1. */

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
/*     NUMBERS */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     SEED      I-O  Seed for random number generation. */

/*     The function returns values that are uniformly distributed over */
/*     the open interval (0,1). */

/* $ Detailed_Input */

/*     SEED           is a seed for the random number generator. On the */
/*                    first call to T_URAND, SEED should be set equal to */
/*                    a negative number.  After the first call, SEED */
/*                    should not be modified by the caller, except to */
/*                    start a new sequence of random numbers. */

/* $ Detailed_Output */

/*     SEED           is the seed value to be used as input on the next */
/*                    call to T_URAND to produce the next random number */
/*                    in the sequence. */

/*     The function returns values that are approximately uniformly */
/*     distributed over the open interval (0, 1). */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine implements a long-period (> 2 * 10**18) random */
/*     number generator of L'Ecuyer with Bays-Durham shuffle and added */
/*     safeguards.  Returns a uniform random deviate between 0.0 and 1.0 */
/*     (exclusive of the endpoint values).  Call with SEED a negative */
/*     integer to initialize; thereafter, do not alter SEED between */
/*     successive deviates in a sequence. */

/*     Each call to the routine produces a new random number.  The */
/*     sequence of numbers returned depends on the initial value of */
/*     SEED.  To obtain different sequences on different program runs, */
/*     different initial values of SEED must be supplied. */

/*     The set of random number routines includes: */

/*        T_URAND ( Uniform random deviate in range 0:1 ) */
/*        T_RANDD ( Random double-precision number ) */
/*        T_RANID ( Random integer ) */

/* $ Examples */

/*     1)  Print a series of 100 random numbers in the interval */
/*         (0.0, 1.0): */

/*            SEED = -1 */

/*            DO I = 1, 100 */
/*               WRITE ( *, '(1X,F25.16)' ), T_URAND ( SEED ) */
/*            END DO */


/*     2)  This time generate two different sequences: */

/*            SEED1 = -999 */
/*            SEED2 = -9999 */

/*            DO I = 1, 100 */
/*               WRITE ( *, '(1X,F25.16)' ), T_URAND ( SEED1 ) */
/*            END DO */

/*            DO I = 1, 100 */
/*               WRITE ( *, '(1X,F25.16)' ), T_URAND ( SEED2 ) */
/*            END DO */

/* $ Restrictions */

/*     1) Users must verify that the pseudo-random number sequences */
/*        generated by this routine are suitable for their applications. */

/* $ Literature_References */

/*     [1]  "Numerical Recipes---The Art of Scientific Computing" by */
/*           William H. Press, Brian P. Flannery, Saul A. Teukolsky, */
/*           William T. Vetterling (pp 272-273). */

/* $ Author_and_Institution */

/*     N.J. Bachman   (JPL) */

/* $ Version */

/* -    Testutil Version 1.0.0, 21-SEP-2005 (NJB) */

/* -& */

/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Copy SEED to local variable IDUM; we do this to maintain */
/*     consistency between local variable names here and in the */
/*     reference [1]. */

    idum = *seed;

/*     The following algorithm is from [1]. */

    if (idum <= 0) {

/*        Initialize. */

/*        Be sure to prevent IDUM = 0. */

/* Computing MAX */
	i__1 = -idum;
	idum = max(i__1,1);
	idum2 = idum;
	for (j = 40; j >= 1; --j) {

/*           Load the shuffle table (after 8 warm-ups). */

	    k = idum / 53668;

/*           Compute IDUM = MOD ( IA1*IDUM, IM1 ) without overflows */
/*           by Schrage's method. */

	    idum = (idum - k * 53668) * 40014 - k * 12211;
	    if (idum < 0) {
		idum += 2147483563;
	    }
	    if (j <= 32) {
		iv[(i__1 = j - 1) < 32 && 0 <= i__1 ? i__1 : s_rnge("iv", 
			i__1, "t_urand__", (ftnlen)260)] = idum;
	    }
	}
	iy = iv[0];
    }

/*     Start here when not initializing. */

    k = idum / 53668;

/*     Compute IDUM = MOD ( IA1*IDUM, IM1 ) without overflows */
/*     by Schrage's method. */

    idum = (idum - k * 53668) * 40014 - k * 12211;
    if (idum < 0) {
	idum += 2147483563;
    }

/*     Compute IDUM2 = MOD ( IA2*IDUM2, IM2 ) likewise. */

    idum2 = (idum2 - k * 52774) * 40692 - k * 3791;
    if (idum2 < 0) {
	idum2 += 2147483399;
    }

/*     Compute table index J (in the range 1:NTAB). */

    j = iy / 67108862 + 1;

/*     Here IDUM is shuffled, IDUM and IDUM2 are combined */
/*     to generate output. */

    iy = iv[(i__1 = j - 1) < 32 && 0 <= i__1 ? i__1 : s_rnge("iv", i__1, 
	    "t_urand__", (ftnlen)302)] - idum2;
    iv[(i__1 = j - 1) < 32 && 0 <= i__1 ? i__1 : s_rnge("iv", i__1, "t_urand"
	    "__", (ftnlen)303)] = idum;
    if (iy < 1) {
	iy += 2147483562;
    }

/*     Adjust the output to exclude endpoint values. */

/* Computing MIN */
    d__1 = iy * 4.6566130573917691e-10;
    ret_val = min(d__1,.999999999999999);

/*     Update the seed. */

    *seed = idum;
    return ret_val;
} /* t_urand__ */

