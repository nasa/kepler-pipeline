/* tstlip.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;

/* $Procedure      TSTLIP ( Test log if passed ) */

/* Subroutine */ int tstlip_0_(int n__)
{
    /* Initialized data */

    static logical logifp = FALSE_;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static char fail[120], good[120], pass[120];
    static logical passed;
    static char messge[520];
    extern /* Subroutine */ int t_cnum__(integer *);
    static integer number;
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    static char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen), 
	    t_cname__(char *, ftnlen), t_cpass__(logical *);


/* $ Abstract */

/*     If the last registered test case passed and test case logging */
/*     is enabled, log the success of the last test case to SCREEN */
/*     and the log file. */

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

/*     If the last test case passed and individual test case logging */
/*     is enabled.  Log the success of that case. */

/* $ Examples */

/*     Later. */

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

/*     Log a succussful test case. */

/* -& */

/*     Test Utility Functions */


/*     Local Variables. */

    switch(n__) {
	case 1: goto L_tstcbl;
	case 2: goto L_tstlcy;
	case 3: goto L_tstlcn;
	}

    s_copy(pass, "LEFT 1 RIGHT 78 HARDSPACE $ FLAG Case$Passed:", (ftnlen)120,
	     (ftnlen)45);
    s_copy(fail, "LEFT 1 RIGHT 78 HARDSPACE $ FLAG CASE$FAILED!", (ftnlen)120,
	     (ftnlen)45);
    if (logifp || verbos_()) {
	s_copy(messge, " ", (ftnlen)520, (ftnlen)1);

/*        Copy the current logging style. */

	tststy_(good, bad, (ftnlen)120, (ftnlen)120);

/*        See whether or not this case passed and get its number. */

	t_cpass__(&passed);
	t_cnum__(&number);
	if (number > 0 && passed) {

/*           Print a blank line before the output message only */
/*           if we are in verbose mode. */

	    if (verbos_()) {
		tstlog_(" ", &c_false, (ftnlen)1);
	    }

/*           Set the logging style to PASS and print the case name. */

	    tstlgs_(pass, pass, (ftnlen)120, (ftnlen)120);
	    t_cname__(messge, (ftnlen)520);
	    tstlog_(messge, &c_false, (ftnlen)520);
	} else if (number > 0) {

/*           Always print a blank line before a case that failed. */

	    tstlog_(" ", &c_false, (ftnlen)1);

/*           Set the logging style to FAIL and print the case name. */

	    tstlgs_(fail, fail, (ftnlen)120, (ftnlen)120);
	    t_cname__(messge, (ftnlen)520);
	    tstlog_(messge, &c_false, (ftnlen)520);
	}
	tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    }
    return 0;

/*     Write a blank line if we are in case logging mode or verbose */
/*     mode. */


L_tstcbl:
    if (logifp || verbos_()) {
	tstlog_(" ", &c_false, (ftnlen)1);
    }
    return 0;

/*     To turn on the logging of individual test cases call TSTLCY */


L_tstlcy:
    logifp = TRUE_;
    return 0;

/*     To turn on the logging of individual test cases call TSTLCY */


L_tstlcn:
    logifp = FALSE_;
    return 0;
} /* tstlip_ */

/* Subroutine */ int tstlip_(void)
{
    return tstlip_0_(0);
    }

/* Subroutine */ int tstcbl_(void)
{
    return tstlip_0_(1);
    }

/* Subroutine */ int tstlcy_(void)
{
    return tstlip_0_(2);
    }

/* Subroutine */ int tstlcn_(void)
{
    return tstlip_0_(3);
    }

