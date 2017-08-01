/* tclose.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__1 = 1;

/* $Procedure      TCLOSE (Close testing.) */
/* Subroutine */ int tclose_(void)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char file[255], name__[32], good[120], time[80];
    extern /* Subroutine */ int t_anybad__(logical *), t_fcount__(integer *), 
	    tbegf_(void);
    integer nfail, ncase;
    extern logical isoff_(char *, ftnlen);
    extern /* Subroutine */ int reset_(void);
    logical dummy;
    char versn[80];
    extern /* Subroutine */ int t_success__(logical *);
    logical ok;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     t_name__(char *, ftnlen), tfname_(char *, ftnlen);
    char logfil[255];
    extern /* Subroutine */ int finish_(void);
    logical failur;
    char messge[256];
    extern /* Subroutine */ int t_cnum__(integer *);
    extern logical setoff_(char *, ftnlen);
    extern /* Subroutine */ int errdev_(char *, char *, ftnlen, ftnlen), 
	    repmct_(char *, char *, integer *, char *, char *, ftnlen, ftnlen,
	     ftnlen, ftnlen), tstcbl_(void), prefix_(char *, integer *, char *
	    , ftnlen, ftnlen), cstart_(void), tstglf_(char *, ftnlen), 
	    suffix_(char *, integer *, char *, ftnlen, ftnlen), tstfil_(char *
	    , char *, char *, ftnlen, ftnlen, ftnlen), tstioa_(char *, ftnlen)
	    , tstioc_(char *, ftnlen), tstget_(char *, char *, char *, ftnlen,
	     ftnlen, ftnlen), tstioh_(char *, ftnlen), tstlog_(char *, 
	    logical *, ftnlen), tstlip_(void), tstlgs_(char *, char *, ftnlen,
	     ftnlen), tstslf_(char *, ftnlen), tstwln_(char *, ftnlen), 
	    tstrul_(void);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);
    char env[80];

/* $ Abstract */

/*     Close out all  testing. */

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

/*      None. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine takes care of the problems of finishing a test */
/*     program.  It displays a summary of all testing, closes the */
/*     test log and failure log.  If no failures have occurred the */
/*     file 'passage.tst' is created and filled with a brief message */
/*     to indicate that all tests passed. */

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

/* -    Testing Utilities Version 3.0.0, 27-JUL-1999 (WLT) */

/*        Added code so that if Error Handling status was not */
/*        checked in the previous test case, it will be done */
/*        here.  Moreover, all test files that have not been */
/*        deleted are deleted (provided the test program is not */
/*        in DEBUGGING mode. */

/* -    Testing Utilities Version 2.0.0,  4-APR-1994 (WLT) */

/*        The wrong filename was being written into the pass file. */
/*        Now the logfile name is recovered and resaved after the */
/*        pass file is opened. */

/* -    Testing Utilities Version 1.0.0, 4-NOV-1994 (WLT) */


/* -& */

/*     Test Utility Functions */


/*     See if exceptions were examined in the last test case. */

    if (isoff_("CHCKXC", (ftnlen)6)) {
	chckxc_(&c_false, " ", &ok, (ftnlen)1);
	dummy = setoff_("CHCKXC", (ftnlen)6);
    }
    reset_();
    errdev_("SET", "NULL", (ftnlen)3, (ftnlen)4);
    tststy_(good, bad, (ftnlen)120, (ftnlen)120);

/*     Log the last test case if it passed. */

    tstlip_();

/*     Draw any rules that might be needed by verbose output. */

    tstrul_();
    tstrul_();

/*     Put a blank line between the cases and our output if we are in */
/*     case reporting or verbose mode. */

    tstcbl_();

/*     We need to close out the old case */

    t_name__(name__, (ftnlen)32);
    t_fcount__(&nfail);
    t_cnum__(&ncase);
    t_success__(&ok);
    if (ok) {
	s_copy(messge, "Passed  --- Test Family: ", (ftnlen)256, (ftnlen)25);
	suffix_(name__, &c__1, messge, (ftnlen)32, (ftnlen)256);
	tstlog_(messge, &c_false, (ftnlen)256);
	tstlgs_("LEFT 9 RIGHT 78 FLAG --- NEWLINE /cr", "LEFT 9 RIGHT 78 FLA"
		"G --- NEWLINE /cr", (ftnlen)36, (ftnlen)36);
	s_copy(messge, "Successful tests for # of # test cases. ", (ftnlen)
		256, (ftnlen)40);
	repmct_(messge, "#", &ncase, "L", messge, (ftnlen)256, (ftnlen)1, (
		ftnlen)1, (ftnlen)256);
	repmct_(messge, "#", &ncase, "L", messge, (ftnlen)256, (ftnlen)1, (
		ftnlen)1, (ftnlen)256);
	tstlog_(messge, &c_false, (ftnlen)256);
    } else {
	s_copy(messge, "FAILURE for Test Family: ", (ftnlen)256, (ftnlen)25);
	suffix_(name__, &c__1, messge, (ftnlen)32, (ftnlen)256);
	tstlog_(messge, &c_false, (ftnlen)256);
	tstlgs_("LEFT 24 RIGHT 78 FLAG : NEWLINE /cr", "LEFT 24 RIGHT 78 FLA"
		"G : NEWLINE /cr", (ftnlen)35, (ftnlen)35);
	s_copy(messge, "# of # test cases failed. ", (ftnlen)256, (ftnlen)26);
	repmct_(messge, "#", &nfail, "C", messge, (ftnlen)256, (ftnlen)1, (
		ftnlen)1, (ftnlen)256);
	repmct_(messge, "#", &ncase, "L", messge, (ftnlen)256, (ftnlen)1, (
		ftnlen)1, (ftnlen)256);
	tstlog_(messge, &c_false, (ftnlen)256);
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);

/*     Now we check on the overall success of the testing. */

    t_anybad__(&failur);
    if (! failur) {
	tstglf_(logfil, (ftnlen)255);
	tstfil_("pass{0-9}{0-9}{0-9}{0-9}.log", "SAVE", file, (ftnlen)28, (
		ftnlen)4, (ftnlen)255);
	tstslf_(logfil, (ftnlen)255);
	tstget_(env, versn, time, (ftnlen)80, (ftnlen)80, (ftnlen)80);

/*        We temporarily turn off writing to the log file and screen */
/*        so that we can put the test stamp in the pass file. */

	tstioa_("SAVE", (ftnlen)4);
	tstioh_("LOG", (ftnlen)3);
	tstioh_("SCREEN", (ftnlen)6);
	tstwln_(env, (ftnlen)80);
	tstwln_(versn, (ftnlen)80);
	tstwln_(time, (ftnlen)80);

/*        Now reactivate the screen and log file. */

	tstioa_("LOG", (ftnlen)3);
	tstioa_("SCREEN", (ftnlen)6);

/*        Write out the testing summary. */

	tstwln_(" ", (ftnlen)1);
	tstwln_("All tests passed.  ", (ftnlen)19);
	tstioh_("SCREEN", (ftnlen)6);
	tstwln_("Tests performed were:", (ftnlen)21);
	tstwln_(" ", (ftnlen)1);
	tbegf_();
	tfname_(name__, (ftnlen)32);
	while(s_cmp(name__, " ", (ftnlen)32, (ftnlen)1) != 0) {
	    tstwln_(name__, (ftnlen)32);
	    tfname_(name__, (ftnlen)32);
	}

/*        Turn off writing to the log file,  the next message doesn't */
/*        belong in it. */

	tstglf_(messge, (ftnlen)256);
	prefix_("For details, see the test log:", &c__1, messge, (ftnlen)30, (
		ftnlen)256);
	tstioh_("LOG", (ftnlen)3);
	tstwln_(" ", (ftnlen)1);
	tstlog_(messge, &c_false, (ftnlen)256);
	tstwln_(" ", (ftnlen)1);

/*        Close the pass file. */

	tstioc_("SAVE", (ftnlen)4);

/*        Reactivate writing to the log file. */

	tstioa_("LOG", (ftnlen)3);
	tstioa_("SCREEN", (ftnlen)6);
    }

/*     Clean up any files that might be lying around from the */
/*     last test family. */

    cstart_();

/*     Finish up everything now. */
    tstlog_(" ", &c_false, (ftnlen)1);
    finish_();
    return 0;
} /* tclose_ */

