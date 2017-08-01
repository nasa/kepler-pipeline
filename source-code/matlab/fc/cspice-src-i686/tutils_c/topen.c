/* topen.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__2 = 2;

/* $Procedure      TOPEN (Open a family of tests) */
/* Subroutine */ int topen_0_(int n__, char *name__, ftnlen name_len)
{
    /* Initialized data */

    static integer tfamc = 1;
    static integer ntest = 0;
    static char oldnam[32] = "                                ";
    static logical first = TRUE_;

    /* System generated locals */
    address a__1[2];
    integer i__1, i__2[2];

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    static char good[120];
    extern /* Subroutine */ int t_fcount__(integer *);
    static integer i__, r__, nfail, ncase;
    extern logical isoff_(char *, ftnlen);
    extern /* Subroutine */ int reset_(void);
    static logical dummy;
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int t_success__(logical *);
    static logical ok;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    static char ctrace[1200];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     t_name__(char *, ftnlen);
    static char otrace[1200], messge[160];
    extern /* Subroutine */ int t_cnum__(integer *);
    extern logical setoff_(char *, ftnlen);
    static char tnames[32*1000];
    extern /* Subroutine */ int qcktrc_(char *, ftnlen), errdev_(char *, char 
	    *, ftnlen, ftnlen), repmct_(char *, char *, integer *, char *, 
	    char *, ftnlen, ftnlen, ftnlen, ftnlen), tstcbl_(void), cstart_(
	    void), suffix_(char *, integer *, char *, ftnlen, ftnlen), 
	    tstmof_(void), tstlog_(char *, logical *, ftnlen), tstlip_(void), 
	    tstlgs_(char *, char *, ftnlen, ftnlen), tstrul_(void);
    static char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen), 
	    t_begin__(char *, ftnlen), t_trace__(char *, char *, ftnlen, 
	    ftnlen);

/* $ Abstract */

/*     Open a collection of tests */

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
/*      NAME       I   The name of a family of tests */

/* $ Detailed_Input */

/*     NAME        is the name of some collection of tests that are */
/*                 to be performed.  Often this is simply the name */
/*                 of a subroutine that is to be tested. */

/*                 NAME should be no more than 32 characters in length. */

/*                 Longer names will be truncacted to 32 characters by */
/*                 the testing utilities. */

/* $ Detailed_Output */

/*      None. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */


/* $ Particulars */

/*     This routine establishes a new test family.   It acts by */
/*     side effect setting up the various test utilities that need */
/*     to be initialized before beginning a series of tests and logs */
/*     that this task has been accomplished. */

/* $ Examples */

/*     Test functions */

/*     LOGICAL               T_MYROUTINE */
/*     LOGICAL               T_ROUTINE2 */

/*     LOGICAL               RESULT */

/*     Enable the testing software. */

/*     CALL TSETUP ('test{0-9}{0-9}{0-9}{0-9}.log', '1.0.0' ) */

/*     Open the first test case. */

/*     CALL TOPEN  ('MYROUTINE' ) */
/*     RESULT = T_MYROUTINE () */

/*     CALL TOPEN  ('ROUTINE2'  ) */
/*     RESULT = RESULT .AND. T_ROUTINE2() */

/*     CALL TCLOSE */
/*     END */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities 4.0.0, 20-JUN-2001 (WLT) */

/*        Added code to remove any messages left lying around from a */
/*        previous test case or family that were created with TSTMSG. */

/* -    Testing Utilities 3.0.0, 27-JUL-1999 (WLT) */

/*        Added code so that if Error Handling status was not */
/*        checked in the previous test case, it will be done */
/*        here.  In addition the Test Program is reset to a */
/*        "clean" SPICE status.  All files are unloaded and */
/*        test files are deleted. */

/* -    Testing Utilities 2.0.0, 20-JUN-1997 (WLT) */

/*        Added the tests to make sure that the current SPICE */
/*        trace is the same at the end of a test case as it was */
/*        at the beginning of a test case.  This identifies routines */
/*        that checkin but don't check out. */

/* -    Testing Utilities Version 1.0.0, 3-NOV-1994 (WLT) */


/* -& */

/*     Spicelib Functions */


/*     Local Variables and Parameters */

    switch(n__) {
	case 1: goto L_tbegf;
	case 2: goto L_tfname;
	}

    if (first) {
	first = FALSE_;
	for (i__ = 1; i__ <= 1000; ++i__) {
	    s_copy(tnames + (((i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : 
		    s_rnge("tnames", i__1, "topen_", (ftnlen)210)) << 5), 
		    " ", (ftnlen)32, (ftnlen)1);
	}
    } else {

/*        See if exceptions were examined in the last test case. */

	if (isoff_("CHCKXC", (ftnlen)6)) {
	    chckxc_(&c_false, " ", &ok, (ftnlen)1);
	    dummy = setoff_("CHCKXC", (ftnlen)6);
	}
    }

/*     Turn off any messages that may have been left lying around from */
/*     the last call to TSTMSG. */

    tstmof_();

/*     Append this name to the list of names we maintain for */
/*     summary purposes. */

    if (ntest < 1000) {
	++ntest;
	s_copy(tnames + (((i__1 = ntest - 1) < 1000 && 0 <= i__1 ? i__1 : 
		s_rnge("tnames", i__1, "topen_", (ftnlen)235)) << 5), name__, 
		(ftnlen)32, name_len);
    }

/*     Get the current value of the trace. */

    s_copy(ctrace, " ", (ftnlen)1200, (ftnlen)1);
    qcktrc_(ctrace, (ftnlen)1200);

/*     Get the last stored value of the trace. */

    t_trace__("GET", otrace, (ftnlen)3, (ftnlen)1200);

/*     Reset the error handling */

    reset_();
    errdev_("SET", "NULL", (ftnlen)3, (ftnlen)4);

/*     Reset the kernel managers to a "clean" state. */

    cstart_();

/*     Log the last test case if it passed. */

    if (ntest > 1) {

/*        First we check the current trace and make sure it is the */
/*        same as the old trace. */

	chcksc_("Current Trace", ctrace, "=", otrace, &ok, (ftnlen)13, (
		ftnlen)1200, (ftnlen)1, (ftnlen)1200);
	tstlip_();
	tstrul_();
	tstrul_();
	tstcbl_();
    }

/*     Set the "old" trace value. */

    t_trace__("SET", ctrace, (ftnlen)3, (ftnlen)1200);
    t_name__(oldnam, (ftnlen)32);
    if (s_cmp(oldnam, " ", (ftnlen)32, (ftnlen)1) != 0) {

/*        We need to close out the old case */

	t_fcount__(&nfail);
	t_cnum__(&ncase);
	t_success__(&ok);
	tststy_(good, bad, (ftnlen)120, (ftnlen)120);
	if (ok) {
	    s_copy(messge, "Passed  --- Test Family: ", (ftnlen)160, (ftnlen)
		    25);
	    suffix_(oldnam, &c__1, messge, (ftnlen)32, (ftnlen)160);
	    tstlog_(messge, &c_false, (ftnlen)160);
	    tstlgs_("LEFT 9 RIGHT 78 FLAG --- NEWLINE /cr", "LEFT 9 RIGHT 78"
		    " FLAG --- NEWLINE /cr", (ftnlen)36, (ftnlen)36);
	    s_copy(messge, "Successful tests for # of # test cases. ", (
		    ftnlen)160, (ftnlen)40);
	    repmct_(messge, "#", &ncase, "L", messge, (ftnlen)160, (ftnlen)1, 
		    (ftnlen)1, (ftnlen)160);
	    repmct_(messge, "#", &ncase, "L", messge, (ftnlen)160, (ftnlen)1, 
		    (ftnlen)1, (ftnlen)160);
	    tstlog_(messge, &c_false, (ftnlen)160);
	} else {
	    s_copy(messge, "FAILURE for Test Family: ", (ftnlen)160, (ftnlen)
		    25);
	    suffix_(oldnam, &c__1, messge, (ftnlen)32, (ftnlen)160);
	    tstlog_(messge, &c_false, (ftnlen)160);
	    tstlgs_("LEFT 24 RIGHT 78 FLAG : NEWLINE /cr", "LEFT 24 RIGHT 78"
		    " FLAG : NEWLINE /cr", (ftnlen)35, (ftnlen)35);
	    s_copy(messge, "# of # test cases failed. ", (ftnlen)160, (ftnlen)
		    26);
	    repmct_(messge, "#", &nfail, "C", messge, (ftnlen)160, (ftnlen)1, 
		    (ftnlen)1, (ftnlen)160);
	    repmct_(messge, "#", &ncase, "L", messge, (ftnlen)160, (ftnlen)1, 
		    (ftnlen)1, (ftnlen)160);
	    tstlog_(messge, &c_false, (ftnlen)160);
	}
	tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
	tstlog_(" ", &c_false, (ftnlen)1);
    }
    t_begin__(name__, name_len);
/* Writing concatenation */
    i__2[0] = 25, a__1[0] = "Testing --- Test Family: ";
    i__2[1] = name_len, a__1[1] = name__;
    s_cat(messge, a__1, i__2, &c__2, (ftnlen)160);
    r__ = rtrim_(messge, (ftnlen)160);
    tstlog_(" ", &c_false, (ftnlen)1);
    tstlog_(messge, &c_false, r__);
    tstlog_(" ", &c_false, (ftnlen)1);
    return 0;

/*     The following two entry points are provided so that a program */
/*     can fetch in order all tests that were begun with a call to TOPEN. */

/*     The entry TBEGF sets the test family counter to 1.  The entry */
/*     TFNAME fetches the next name from the list of test families and */
/*     increments the test family counter.  When the the family counter */
/*     passes the number of calls to TOPEN, the name returned is set to */
/*     a blank. */


L_tbegf:
    tfamc = 1;
    return 0;

L_tfname:
    if (tfamc <= ntest) {
	s_copy(name__, tnames + (((i__1 = tfamc - 1) < 1000 && 0 <= i__1 ? 
		i__1 : s_rnge("tnames", i__1, "topen_", (ftnlen)361)) << 5), 
		name_len, (ftnlen)32);
	++tfamc;
    } else {
	s_copy(name__, " ", name_len, (ftnlen)1);
    }
    return 0;
} /* topen_ */

/* Subroutine */ int topen_(char *name__, ftnlen name_len)
{
    return topen_0_(0, name__, name_len);
    }

/* Subroutine */ int tbegf_(void)
{
    return topen_0_(1, (char *)0, (ftnint)0);
    }

/* Subroutine */ int tfname_(char *name__, ftnlen name_len)
{
    return topen_0_(2, name__, name_len);
    }

