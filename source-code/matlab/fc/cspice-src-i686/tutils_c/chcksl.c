/* chcksl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      CHCKSL ( Check Scalar logical ) */

/* Subroutine */ int chcksl_(char *name__, logical *val, logical *exp__, 
	logical *ok, ftnlen name_len)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    char messge[320];
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);


/* $ Abstract */

/*     Check a logical value against an expected value. */

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
/*      NAME       I   the name of the variable to be examined. */
/*      VAL        I   the actual variable */
/*      EXP        I   the comparison value for the variable */
/*      OK         O   TRUE if the test passes, FALSE otherwise.. */

/* $ Detailed_Input */

/*     NAME        is the string used to give the name of a variable */

/*     VAL         is the actual logical variable to be examined */

/*     EXP         an expected value or bound on the value VAL. */


/* $ Detailed_Output */

/*     OK         if the check of the input variable is successful then */
/*                OK is given the value TRUE.  Otherwise OK is given the */
/*                value FALSE and a diagnostic message is sent to the */
/*                test logger. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      The result of a failure is automatically logged in the testing */
/*      log file and failure file.  Success is logged only if verbose */
/*      testing has been enabled. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine handles a wide variety of comparisons between */
/*     scalar double precision values. */

/* $ Examples */

/*     Suppose that you have just made a call to a subroutine that */
/*     you wish to test (call the routine SPUD) and you would like */
/*     to test an output logical against an expected value and */
/*     verify that they are the same. Using */
/*     this routine you can automatically have the test result logged */
/*     in via the testing utitities. */

/*        CALL SPUD   (  INPUT,   OUTPUT ) */
/*        CALL CHCKSD ( 'OUTPUT', OUTPUT, EXPECT, OK ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utility Version 1.0.0, 7-NOV-1994 (WLT) */


/* -& */

/*     Test Utility functions */


/*     Spicelib functions */


/*     Local Variables */

    tststy_(good, bad, (ftnlen)120, (ftnlen)120);
    tstlgs_("LEFT 3 RIGHT 75 NEWLINE /cr ", "LEFT 3 RIGHT 75 NEWLINE /cr FLA"
	    "G --- LEADER ---", (ftnlen)28, (ftnlen)47);

/*     Just make sure that the values of VAL and EXP are the same. */

    if (*exp__) {
	*ok = *val;
	if (*ok) {
	    s_copy(messge, "The value of # was TRUE as expected. ", (ftnlen)
		    320, (ftnlen)37);
	} else {
	    s_copy(messge, "The expected value of # was TRUE.  The actual va"
		    "lue was FALSE", (ftnlen)320, (ftnlen)61);
	}
    } else {
	*ok = ! (*val);
	if (*ok) {
	    s_copy(messge, "The value of # was FALSE as expected. ", (ftnlen)
		    320, (ftnlen)38);
	} else {
	    s_copy(messge, "The expected value of # was FALSE.  The actual v"
		    "alue was TRUE", (ftnlen)320, (ftnlen)61);
	}
    }
    repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(name__,
	     name_len), (ftnlen)320);
    fail = ! (*ok);
    if (*ok) {
	if (verbos_()) {
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)320);
	}
    } else {
	tstlog_(" ", &fail, (ftnlen)1);
	tstlog_(messge, &fail, (ftnlen)320);
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    return 0;
} /* chcksl_ */

