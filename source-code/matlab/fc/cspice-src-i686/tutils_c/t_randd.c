/* t_randd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      T_RANDD ( Random double precision number ) */
doublereal t_randd__(doublereal *lower, doublereal *upper, integer *seed)
{
    /* System generated locals */
    doublereal ret_val;

    /* Local variables */
    extern /* Subroutine */ int chkin_(char *, ftnlen), errdp_(char *, 
	    doublereal *, ftnlen), sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen);
    extern logical return_(void);
    extern doublereal t_urand__(integer *);

/* $ Abstract */

/*     Return a random double precision number. */

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
/*     LOWER, */
/*     UPPER      I   Bounds of range of RAND. */
/*     SEED      I-O  Seed for random number generation. */

/*     The function returns values that are uniformly distributed over */
/*     the closed interval [ LOWER, UPPER ]. */

/* $ Detailed_Input */

/*     LOWER, */
/*     UPPER          are bounds for the closed interval in which the */
/*                    values of RAND lie. */

/*     SEED           is a seed for the random number generator.  SEED */
/*                    is a `work space' argument. On the first call to */
/*                    T_RANDD, SEED should be set equal to a negative */
/*                    number.  After the first call, SEED should not be */
/*                    modified by the caller except to start a new */
/*                    sequence of random numbers. */

/* $ Detailed_Output */

/*     SEED           is the seed value to be used as input on the next */
/*                    call to RAND to produce the next random number in */
/*                    the sequence. */

/*     The function returns values that are approximately uniformly */
/*     distributed over the closed interval [ LOWER, UPPER ]. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)  If the bounds are out of order, the error SPICE(INVALIDBOUNDS) */
/*         is signaled. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine returns random numbers in the specified interval. */
/*     Each call to the routine produces a new random number.  The */
/*     sequence of numbers returned depends on the initial value of */
/*     SEED.   To obtain multiple sequences of random numbers within a */
/*     single program run, different seed variables can be used, each */
/*     seed variable corresponding to a random sequence. */

/*     This routine can be used for testing routines that take double */
/*     precision variables as inputs. */

/*     For some testing applications, it may be appropriate to use this */
/*     routine to generate the logarithms of the input numbers. */
/*     Otherwise, numbers close to zero may be under-represented in the */
/*     set of test cases. */

/*     The set of random number routines includes: */

/*        T_URAND ( Uniform random deviate in range 0:1 ) */
/*        T_RANDD ( Random double-precision number ) */
/*        T_RANID ( Random integer ) */

/* $ Examples */

/*     1)  Print a series of 100 random numbers in the interval */
/*        [-2.D0, 5.D0]: */

/*            SEED = -100001 */

/*            DO I = 1, 100 */
/*               PRINT *, T_RANDD ( -2.D0, 5.D0, SEED ) */
/*            END DO */


/*     2)  This time generate two different sequences: */

/*            SEED1 = -999 */
/*            SEED2 = -9999 */

/*            DO I = 1, 100 */
/*               WRITE( *, '(1X,F25.16)' ), T_RANDD( -2.D0, 5.D0, SEED1 ) */
/*            END DO */

/*            DO I = 1, 100 */
/*               WRITE( *, '(1X,F25.16)' ), T_RANDD( -2.D0, 5.D0, SEED2 ) */
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

/* -    Testutil Version 1.0.0, 09-NOV-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Give the function an initial value. */

    ret_val = *lower;

/*     Standard SPICE error handling. */

    if (return_()) {
	return ret_val;
    } else {
	chkin_("T_RANDD", (ftnlen)7);
    }

/*     Check bounds. */

    if (*lower > *upper) {
	setmsg_("Lower, upper bounds are:  #  #. ", (ftnlen)32);
	errdp_("#", lower, (ftnlen)1);
	errdp_("#", upper, (ftnlen)1);
	sigerr_("SPICE(INVALIDBOUNDS)", (ftnlen)20);
	chkout_("T_RANDD", (ftnlen)7);
	return ret_val;
    }

/*     Get a random number in the range [LOWER, UPPER].  The */
/*     T_URAND function returns numbers in the range [0, 1]. */

    ret_val = *lower + (*upper - *lower) * t_urand__(seed);
    chkout_("T_RANDD", (ftnlen)7);
    return ret_val;
} /* t_randd__ */

