/* chckod.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__14 = 14;

/* $Procedure      CHCKOD ( Check order of an d.p. array ) */

/* Subroutine */ int chckod_(char *name__, doublereal *array, char *order, 
	integer *size, logical *ok, ftnlen name_len, ftnlen order_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    integer i__, j;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmd_(char *, char *, doublereal *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    integer r1, r2;
    char messge[240];
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);


/* $ Abstract */

/*     Check the ordering of values in a d.p. array. */

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

/*      None. */

/* $ Keywords */

/*       TESTING */

/* $ Declarations */


/* $ Brief_I/O */

/*      VARIABLE  I/O  DESCRIPTION */
/*      --------  ---  -------------------------------------------------- */
/*      NAME       I   the name of the array to be examined. */
/*      ARRAY      I   the actual array */
/*      ORDER      I   the kind of order check to perform. */
/*      SIZE       I   the size of the input array */
/*      OK         O   TRUE if the test passes, FALSE otherwise.. */

/* $ Detailed_Input */

/*     NAME        is the string used to give the name of an array. */

/*     ARRAY       is the actual d.p. array to be examined */

/*     ORDER       a string giving the kind of comparison to perform. */
/*                 Roughly speaking test that for I = 1, SIZE-1 */
/*                 verify that the relation ARRAY(I) ORDER ARRAY(I+1) */
/*                 holds.  Allowed ORDER operators are: */

/*                 =   --- check that all values of the array are */
/*                         the same. */

/*                 <   --- check that the values in the array are */
/*                         strictly increasing. */

/*                 >   --- check that the values in the array are */
/*                         strictly decreasing. */

/*                 =>  --- check that the values in the array are */
/*                         non-increasing (values can be duplicated */
/*                         but can't get bigger.) */

/*                 <=  --- check that the values in the array are */
/*                         non-decreasing (values can be duplicated */
/*                         but can't get smaller.) */

/*     SIZE        is the number of elements in the array. */

/* $ Detailed_Output */

/*     OK          if the check of the input array is successful then */
/*                 OK is given the value TRUE.  Otherwise OK is given the */
/*                 value FALSE and a diagnostic message is sent to the */
/*                 test logger. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */


/* $ Particulars */

/*     This routine checks that the items in an array satisfy an */
/*     order relationship. */

/* $ Examples */

/*     Suppose that you have a routine that orders the items in */
/*     an array so that they are increasing.  To test this routine */
/*     you could make the following calls: */

/*        CALL ORDER ( ARRAY, SIZE ) */
/*        CALL ORDER ( 'ARRAY', ARRAY, '<', SIZE, OK ) */


/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities 1.0.0, 18-NOV-1994 (WLT) */


/* -& */

/* $ Index_Entries */

/*     Check the order of elements of a d.p. array. */

/* -& */

/*     SPICELIB Functions */


/*     Test Utility Functions */


/*     Local Variables */


/*     So far the test case has not failed. */

    fail = FALSE_;
    j = *size + 1;
    if (s_cmp(order, "=", order_len, (ftnlen)1) == 0) {
	i__1 = *size - 1;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = fail || ! (array[i__ - 1] == array[i__]);
	}
	if (fail) {
	    j = min(j,i__);
	}
    } else if (s_cmp(order, "<", order_len, (ftnlen)1) == 0) {
	i__1 = *size - 1;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = fail || ! (array[i__ - 1] < array[i__]);
	}
	if (fail) {
	    j = min(j,i__);
	}
    } else if (s_cmp(order, "<=", order_len, (ftnlen)2) == 0) {
	i__1 = *size - 1;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = fail || ! (array[i__ - 1] <= array[i__]);
	}
	if (fail) {
	    j = min(j,i__);
	}
    } else if (s_cmp(order, ">", order_len, (ftnlen)1) == 0) {
	i__1 = *size - 1;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = fail || ! (array[i__ - 1] > array[i__]);
	}
	if (fail) {
	    j = min(j,i__);
	}
    } else if (s_cmp(order, "=>", order_len, (ftnlen)2) == 0) {
	i__1 = *size - 1;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = fail || ! (array[i__ - 1] >= array[i__]);
	}
	if (fail) {
	    j = min(j,i__);
	}
    }
    r1 = rtrim_(name__, name_len);
    r2 = rtrim_(order, order_len);
    tststy_(good, bad, (ftnlen)120, (ftnlen)120);
    tstlgs_("LEFT 3 RIGHT 75 NEWLINE /cr ", "LEFT 3 RIGHT 75 NEWLINE /cr FLA"
	    "G --- LEADER ---", (ftnlen)28, (ftnlen)47);
    if (fail) {
	s_copy(messge, "The input array # is does not satisfy the condition"
		" \"#(@) ? #($)\".  The two offending values are:/cr/cr(3:) #"
		"(@) = % /cr #($) = &. ", (ftnlen)240, (ftnlen)131);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "?", order, messge, (ftnlen)240, (ftnlen)1, r2, (
		ftnlen)240);
	repmi_(messge, "@", &j, messge, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	repmi_(messge, "@", &j, messge, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	i__1 = j + 1;
	repmi_(messge, "$", &i__1, messge, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	i__1 = j + 1;
	repmi_(messge, "$", &i__1, messge, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	repmd_(messge, "%", &array[j - 1], &c__14, messge, (ftnlen)240, (
		ftnlen)1, (ftnlen)240);
	repmd_(messge, "&", &array[j], &c__14, messge, (ftnlen)240, (ftnlen)1,
		 (ftnlen)240);
	tstlog_(" ", &fail, (ftnlen)1);
	tstlog_(messge, &fail, (ftnlen)240);
    } else if (verbos_()) {
	s_copy(messge, "The relationship #(I) ? #(I+1) is true for all eleme"
		"nts of the input array # ", (ftnlen)240, (ftnlen)77);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "#", name__, messge, (ftnlen)240, (ftnlen)1, r1, (
		ftnlen)240);
	repmc_(messge, "?", order, messge, (ftnlen)240, (ftnlen)1, r2, (
		ftnlen)240);
	tstlog_(" ", &fail, (ftnlen)1);
	tstlog_(messge, &fail, (ftnlen)240);
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    *ok = ! fail;
    return 0;
} /* chckod_ */

