/* chckxc.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;

/* $Procedure      CHCKXC ( Check exceptions ) */
/* Subroutine */ int chckxc_(logical *except, char *short__, logical *ok, 
	ftnlen short_len)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120], lmsg[640], smsg[32];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), reset_(void);
    extern logical seton_(char *, ftnlen);
    logical dummy;
    extern integer rtrim_(char *, ftnlen);
    extern logical failed_(void);
    char ctrace[640], messge[640];
    extern /* Subroutine */ int getmsg_(char *, char *, ftnlen, ftnlen), 
	    qcktrc_(char *, ftnlen);
    extern logical verbos_(void);
    extern /* Subroutine */ int suffix_(char *, integer *, char *, ftnlen, 
	    ftnlen), tstlog_(char *, logical *, ftnlen), tstlgs_(char *, char 
	    *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     Check an string scalar value against some expected value. */

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
/*      EXCEPT     I   Logical indicating if an exception should exist */
/*      SHORT      I   The short error string associated with exception */

/* $ Detailed_Input */

/*     EXCEPT      is a logical that indicates whether or not an */
/*                 exception should have occurred.  If EXCEPT is */
/*                 TRUE an exception is expected. Otherwise no */
/*                 exception is expected. */

/*     SHORT       is the short error message that is associated */
/*                 with an exception.  SHORT will be used only if */
/*                 EXCEPT is TRUE.  Otherwise it is ignored as no */
/*                 exception is expected. */



/* $ Detailed_Output */

/*     OK         if the check exception condition is successful then */
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

/*     This routine checks that exceptions handling has the expected */
/*     status. */

/* $ Examples */

/*     Suppose that you have just made a call to a subroutine that */
/*     you wish to test (call the routine SPUD) and you would like */
/*     to test the handling of some exception.  Using */
/*     this routine you can automatically have the test result logged */
/*     in via the testing utitities. */

/*        CALL SPUD   (  INPUT,   OUTPUT ) */
/*        CALL CHCKXC (  EXPECT, 'SPICE(ERRORMESSAGE)', OK ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities 2.0.0, 27-JUL-1999 (WLT) */

/*        Added code so that the fact that a check of the */
/*        status of the error handling system will be communicated */
/*        to the rest of the test utility software. */

/* -    Testing Utilities Version 1.0.0, 10-Nov-1994 (WLT) */


/* -& */

/*     Test Utility functions */


/*     Spicelib functions */


/*     Local Variables */

    tststy_(good, bad, (ftnlen)120, (ftnlen)120);
    tstlgs_("LEFT 3 RIGHT 75 NEWLINE /cr ", "LEFT 3 RIGHT 75 NEWLINE /cr FLA"
	    "G --- LEADER ---", (ftnlen)28, (ftnlen)47);
    dummy = seton_("CHCKXC", (ftnlen)6);
    if (! (*except)) {
	fail = failed_();
	if (fail) {
	    getmsg_("SHORT", smsg, (ftnlen)5, (ftnlen)32);
	    getmsg_("LONG", lmsg, (ftnlen)4, (ftnlen)640);
	    qcktrc_(ctrace, (ftnlen)640);
	    reset_();
	    s_copy(messge, "No exception was expected however one exists.  T"
		    "he short error message was: '#'. ", (ftnlen)640, (ftnlen)
		    81);
	    repmc_(messge, "#", smsg, messge, (ftnlen)640, (ftnlen)1, rtrim_(
		    smsg, (ftnlen)32), (ftnlen)640);
	    tstlog_(messge, &fail, (ftnlen)640);
	    s_copy(messge, "The long error message follows:", (ftnlen)640, (
		    ftnlen)31);
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)640);
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(lmsg, &fail, (ftnlen)640);
	    s_copy(messge, "The current trace is: ", (ftnlen)640, (ftnlen)22);
	    suffix_(ctrace, &c__1, messge, (ftnlen)640, (ftnlen)640);
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)640);
	} else if (verbos_()) {
	    s_copy(messge, "No exception was detected.  This is the expected"
		    " behaviour. ", (ftnlen)640, (ftnlen)60);
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)640);
	}
    } else {
	if (failed_()) {
	    getmsg_("SHORT", smsg, (ftnlen)5, (ftnlen)32);
	    getmsg_("LONG", lmsg, (ftnlen)4, (ftnlen)640);
	    qcktrc_(ctrace, (ftnlen)640);
	    reset_();
	    fail = s_cmp(smsg, short__, (ftnlen)32, short_len) != 0;
	    if (fail) {
		s_copy(messge, "The expected short error message, '#' was no"
			"t found. Instead the short error message was '#'. ", (
			ftnlen)640, (ftnlen)94);
		repmc_(messge, "#", short__, messge, (ftnlen)640, (ftnlen)1, 
			rtrim_(short__, short_len), (ftnlen)640);
		repmc_(messge, "#", smsg, messge, (ftnlen)640, (ftnlen)1, 
			rtrim_(smsg, (ftnlen)32), (ftnlen)640);
		tstlog_(messge, &fail, (ftnlen)640);
		s_copy(messge, "The long error message follows:", (ftnlen)640,
			 (ftnlen)31);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)640);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(lmsg, &fail, (ftnlen)640);
		s_copy(messge, "The current trace is: ", (ftnlen)640, (ftnlen)
			22);
		suffix_(ctrace, &c__1, messge, (ftnlen)640, (ftnlen)640);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)640);
	    } else if (verbos_()) {
		s_copy(messge, "The short error message was '#' as expected. "
			, (ftnlen)640, (ftnlen)45);
		repmc_(messge, "#", smsg, messge, (ftnlen)640, (ftnlen)1, 
			rtrim_(smsg, (ftnlen)32), (ftnlen)640);
		tstlog_(messge, &fail, (ftnlen)640);
		s_copy(messge, "The long error message follows:", (ftnlen)640,
			 (ftnlen)31);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)640);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(lmsg, &fail, (ftnlen)640);
	    }
	} else {
	    fail = TRUE_;
	    s_copy(messge, "No exception was detected.  The expected short e"
		    "rror message was: '#'. ", (ftnlen)640, (ftnlen)71);
	    repmc_(messge, "#", short__, messge, (ftnlen)640, (ftnlen)1, 
		    rtrim_(short__, short_len), (ftnlen)640);
	    tstlog_(messge, &fail, (ftnlen)640);
	}
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    *ok = ! fail;
    return 0;
} /* chckxc_ */

