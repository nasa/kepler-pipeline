/* chckai.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      CHCKAI ( Check an array of integers ) */
/* Subroutine */ int chckai_(char *name__, integer *array, char *comp, 
	integer *exp__, integer *size, logical *ok, ftnlen name_len, ftnlen 
	comp_len)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    integer i__;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *, char *
	    , ftnlen, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    char messge[800];
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     Check the  values in two integer arrays.. */

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
/*      COMP       I   the kind of comparison to perform. */
/*      EXP        I   the comparison values for the array */
/*      SIZE       I   the size of the input array */
/*      OK         O   TRUE if the test passes, FALSE otherwise.. */

/* $ Detailed_Input */

/*     NAME        is the string used to give the name of an array. */

/*     ARRAY       is the actual d.p. array to be examined */

/*     COMP        a string giving the kind of comparison to perform: */

/*                    =    ---   check for strict equality */

/*     EXP         an expected values or bounds on the values in ARRAY. */


/* $ Detailed_Output */

/*     OK         if the check of the input array is successful then */
/*                OK is given the value TRUE.  Otherwise OK is given the */
/*                value FALSE and a diagnostic message is sent to the */
/*                test logger. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine handles a wide variety of comparisons between */
/*     double precision arrays. */

/* $ Examples */

/*     Suppose that you have just made a call to a subroutine that */
/*     you wish to test (call the routine SPUD) and you would like */
/*     to test an output d.p. against an expected value and verify that */
/*     the relative difference is less than some value.  Using */
/*     this routine you can automatically have the test result logged */
/*     in via the testing utitities. */

/*        CALL SPUD   (  INPUT,   OUTPUT ) */
/*        CALL CHCKAI ( 'OUTPUT', OUTPUT, '=', EXPECT, OK ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */
/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utility Version 1.1.0, 10-MAY-2001 (FST) */

/*        OK is now properly set before returning control to the */
/*        caller in all cases. */

/* -    Testing Utility Version 1.0.0, 7-NOV-1994 (WLT) */


/* -& */

/*     SPICELIB functions */


/*     Testing Utility Functions */


/*     Local Variables */

    tststy_(good, bad, (ftnlen)120, (ftnlen)120);
    tstlgs_("LEFT 3 RIGHT 75 NEWLINE /cr ", "LEFT 3 RIGHT 75 NEWLINE /cr FLA"
	    "G --- LEADER ---", (ftnlen)28, (ftnlen)47);
    fail = FALSE_;
    if (s_cmp(comp, "=", comp_len, (ftnlen)1) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = array[i__ - 1] != exp__[i__ - 1];
	    if (fail) {
		s_copy(messge, "Value # of array # was not the value expecte"
			"d. /cr(3:)/cr The value was:         # /crthe expect"
			"ed value was #./crThe difference between these is: #"
			" . ", (ftnlen)800, (ftnlen)151);
		repmi_(messge, "#", &i__, messge, (ftnlen)800, (ftnlen)1, (
			ftnlen)800);
		repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)800);
		repmi_(messge, "#", &array[i__ - 1], messge, (ftnlen)800, (
			ftnlen)1, (ftnlen)800);
		repmi_(messge, "#", &exp__[i__ - 1], messge, (ftnlen)800, (
			ftnlen)1, (ftnlen)800);
		i__2 = array[i__ - 1] - exp__[i__ - 1];
		repmi_(messge, "#", &i__2, messge, (ftnlen)800, (ftnlen)1, (
			ftnlen)800);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)800);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else {
	fail = TRUE_;
	s_copy(messge, "The comparison \"#\" is not recognized. ", (ftnlen)
		800, (ftnlen)38);
	repmc_(messge, "#", comp, messge, (ftnlen)800, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)800);
    }
    if (! fail) {
	s_copy(messge, "The comparison /cr/cr(3:)'# # EXPECTED' /cr/cr(-3:) "
		"was satisfied.", (ftnlen)800, (ftnlen)66);
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmc_(messge, "#", comp, messge, (ftnlen)800, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)800);
	if (verbos_()) {
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)800);
	}
    } else {
	tstlog_(" ", &fail, (ftnlen)1);
	tstlog_(messge, &fail, (ftnlen)800);
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    *ok = ! fail;
    return 0;
} /* chckai_ */

