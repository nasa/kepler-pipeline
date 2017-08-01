/* tcase.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;

/* $Procedure      TCASE (Test Case) */
/* Subroutine */ int tcase_(char *title, ftnlen title_len)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char good[120], doing[120];
    extern logical isoff_(char *, ftnlen);
    extern /* Subroutine */ int reset_(void);
    static logical dummy, ok;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), t_case__(char *, 
	    ftnlen);
    static char ctrace[1200];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    static char otrace[1200], messge[100];
    extern logical setoff_(char *, ftnlen);
    extern /* Subroutine */ int qcktrc_(char *, ftnlen), errdev_(char *, char 
	    *, ftnlen, ftnlen);
    extern logical verbos_(void);
    extern /* Subroutine */ int tstmof_(void), tstlog_(char *, logical *, 
	    ftnlen), tstlip_(void), tstlgs_(char *, char *, ftnlen, ftnlen), 
	    tstrul_(void);
    static char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen), 
	    t_cname__(char *, ftnlen), t_trace__(char *, char *, ftnlen, 
	    ftnlen);

/* $ Abstract */

/*     Set the title for the next test case and log the success of */
/*     the last test case if it passed and logging of individual */
/*     test case success is enabled. */

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
/*      TITLE      I   The title of this test case. */

/* $ Detailed_Input */

/*     TITLE       is the title of a test case.  It should have no */
/*                 more than 32 characters.  If it does characters */
/*                 beyond the thirty second character are ignored. */


/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     If test case success logging is enabled, the previous test */
/*     case success is logged to SCREEN and the log file. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This is the user interface routine for initializing test cases. */

/* $ Examples */

/*     Later. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities 3.3.0, 19-JUN-2001 (WLT) */

/*        Added a call to TSTMOF to turn off the test message from the */
/*        last test case. */

/* -    Testing Utilities 3.2.0, 11-NOV-1999 (WLT) */

/*        Declared SETOFF to be a function and it is now called */
/*        as a function instead of as a subroutine. */

/* -    Testing Utilities 3.0.0, 27-JUL-1999 (WLT) */

/*        Added code so that if Error Handling status was not */
/*        checked in the previous test case, it will be done */
/*        here. */

/* -    Testing Utilities 2.0.0, 20-JUN-1997 (WLT) */

/*        Added the tests to make sure that the current SPICE */
/*        trace is the same at the end of a test case as it was */
/*        at the beginning of a test case.  This identifies routines */
/*        that checkin but don't check out. */

/* -    Testing Utilities 1.0.0, 18-NOV-1994 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Initializing a test case. */

/* -& */

/*     Take care of resetting the error handling and logging the */
/*     last test case if it passed. */


/*     Test Utility Functions */


/*     Local Variables */


/*     See if exceptions were examined in the last test case. */

    if (isoff_("CHCKXC", (ftnlen)6)) {
	chckxc_(&c_false, " ", &ok, (ftnlen)1);
	dummy = setoff_("CHCKXC", (ftnlen)6);
    }

/*     Any message created with TSTMSG is no longer relevent.  Disable */
/*     any such message. */

    tstmof_();

/*     Check the current traceback to make sure things that */
/*     checked in checked out in the last test case. */

    qcktrc_(ctrace, (ftnlen)1200);
    t_trace__("GET", otrace, (ftnlen)3, (ftnlen)1200);
    chcksc_("Current Trace", ctrace, "=", otrace, &ok, (ftnlen)13, (ftnlen)
	    1200, (ftnlen)1, (ftnlen)1200);
    tstlip_();
    t_case__(title, title_len);
    tstrul_();
    tstrul_();
    if (verbos_()) {

/*        Copy the current logging style. */

	tststy_(good, bad, (ftnlen)120, (ftnlen)120);
	s_copy(doing, "LEFT 1 RIGHT 78 HARDSPACE $ FLAG Performing$:", (
		ftnlen)120, (ftnlen)45);
	s_copy(messge, "  ", (ftnlen)100, (ftnlen)2);
	tstlgs_(doing, doing, (ftnlen)120, (ftnlen)120);
	t_cname__(messge, (ftnlen)100);
	tstlog_(messge, &c_false, (ftnlen)100);

/*        Reset the logging style back to what it was. */

	tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    }
    t_trace__("SET", ctrace, (ftnlen)3, (ftnlen)1200);
    reset_();
    errdev_("SET", "NULL", (ftnlen)3, (ftnlen)4);
    return 0;
} /* tcase_ */

