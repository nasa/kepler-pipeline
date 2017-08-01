/* t_stat.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      T_STAT (Test Status) */
/* Subroutine */ int t_stat__0_(int n__, char *act, char *name__, logical *ok,
	 integer *number, ftnlen act_len, ftnlen name_len)
{
    /* Initialized data */

    static logical anybad = FALSE_;
    static logical succes = TRUE_;
    static logical caseok = TRUE_;
    static integer caseno = 0;
    static integer nfail = 0;
    static char myname[520] = "                                             "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                           ";
    static char descr[500] = "                                              "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "                                                                "
	    "      ";
    static char rname[12] = "            ";

    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);

    /* Local variables */
    static logical incr;
    static integer d__[7], i__, j;
    static char trace[1200], digit[1*10*7];
    extern /* Subroutine */ int ucase_(char *, char *, ftnlen, ftnlen);
    static char myact[32];
    extern /* Subroutine */ int reset_(void), ljust_(char *, char *, ftnlen, 
	    ftnlen);

/* $ Abstract */

/*     This routine provides an umbrella for a number of entry points */
/*     used for setting and retrieving the status of a family of */
/*     related test cases. */

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
/*      NAME      I/O  is the name of a test family or test case. */
/*      OK         O   the success of a single case or family of cases. */
/*      NUMBER     O   the number of the current test case. */

/* $ Detailed_Input */

/*     See individual entry points for descriptions */

/* $ Detailed_Output */

/*     See individual entry points for descriptions */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/*     This routine has no calls to any external routines. */

/* $ Particulars */

/*     This routine maintains the status of a family of related test */
/*     routines (provided of course that users) make proper use */
/*     of the various entry points.  The entry points are: */

/*     T_BEGIN ( NAME )  --- set the NAME of the current family of */
/*                           tests. The family can have a name of up to */
/*                           12 characters */

/*     T_NAME  ( NAME )  --- return the name of the current family of */
/*                           tests */

/*     T_SUCCESS ( OK )  --- have all tests in this family passed to */
/*                           this point. */

/*     T_CASE  ( NAME )  --- gives a name (possibly blank) to the current */
/*                           test case. Set the current case success to */
/*                           .TRUE.  The name may be up to 60 characters. */

/*     T_CFAIL ( )       --- set the success of the current case to */
/*                          .FALSE. */

/*     T_CPASS ( OK )    --- return the success of the current test */
/*                           case. */

/*     T_CNUM  (NUMBER)  --- return the current test case number. */

/*     T_CNAME ( NAME )  --- return the full name of the current test */
/*                           case.  The full name returned may have up */
/*                           to 80 characters. */

/*     T_FCOUNT(NUMBER)  --- the number of test cases that failed. */

/*     T_TRACE ( ACT, NAME ) --- set or get the last stored value of */
/*                               the SPICELIB traceback. */


/*     Note that most of the routines are meant to be used in building */
/*     other somewhat higher test utilities. */

/* $ Examples */

/*     A sample test case program would be outlined as shown here: */

/*     First establish the test name. */

/*     CALL T_BEGIN ( 'MY_ROUTINE' ) */


/*        perform any test initializations. */


/*     CALL T_CASE ( 'Normal Inputs' ) */

/*     set up the inputs and expected outputs. */

/*     IF ( not success ) THEN */
/*        CALL T_CFAIL () */
/*     END IF */

/*     All the bookkeeping about the success or failure */
/*     is maintained in one place we can deal with a failure */
/*     (even though we may have several tests above) here. */

/*     CALL T_CPASS ( OK ) */

/*     IF ( .NOT. OK ) THEN */
/*        CALL T_CNAME ( NAME ) */

/*        WRITE (*,*) NAME */
/*        WRITE (*,*) 'Did not pass. ' */

/*     END IF */


/*     DO I = 1, NEXCEP */

/*        CALL T_CASE ( 'Exception' ) */


/*        set up this case */

/*        IF ( not success ) THEN */
/*           CALL T_CFAIL() */
/*        END IF */


/*        CALL T_CPASS ( OK ) */

/*        IF ( .NOT. OK ) THEN */
/*           CALL T_CNAME ( NAME ) */

/*           WRITE (*,*) NAME */
/*           WRITE (*,*) 'Did not pass. ' */

/*        END IF */

/*     END DO */


/*     CALL T_SUCCESS ( OK   ) */
/*     CALL T_NAME    ( NAME ) */

/*     IF ( .NOT. OK ) THEN */

/*        WRITE (*,*) 'The ', NAME, ' family of tests failed. ' */
/*        WRITE (*,*) */
/*     ELSE */
/*        WRITE (*,*) 'All tests of ', NAME, ' passed.' */
/*     END IF */



/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utilities 2.1.0, 18-JUN-1999 (WLT) */

/*        Added RETURN before first entry point. */

/* -    Testing Utilities 2.0.0, 20-JUN-1997 (WLT) */

/*        Added the entry point that allows users to set or get */
/*        the current traceback. */

/* -    TESTLIB Version 1.0.0, 25-OCT-1994 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Keep track of testing status. */

/* -& */

/*     Local Variables */


/*     We enough digits to have unique text versions of case numbers */
/*     for 10**7 cases. */

    switch(n__) {
	case 1: goto L_t_begin;
	case 2: goto L_t_name;
	case 3: goto L_t_success;
	case 4: goto L_t_fcount;
	case 5: goto L_t_case;
	case 6: goto L_t_cfail;
	case 7: goto L_t_cpass;
	case 8: goto L_t_cnum;
	case 9: goto L_t_cname;
	case 10: goto L_t_anybad;
	case 11: goto L_t_trace;
	}

    return 0;

/*     The entry point T_BEGIN sets up all of the needed local */
/*     machinery for tracking the test cases for the current */
/*     set of tests. */


L_t_begin:

/*        Until something goes wrong.  All tests are assumed to pass. */
/*        Store the name and current case number. */

    succes = TRUE_;
    s_copy(rname, name__, (ftnlen)12, name_len);
    caseno = 0;
    nfail = 0;

/*        Set up the "odometer" for the case counter.  Note we put */
/*        blanks instead of zeros for every digit but the least */
/*        significant digit. */

/*        Here's the idea.  At each test case, we increment CASENO */
/*        and flip over one digit on the case odometer.  When we */
/*        reach the 10 on any digit, we flip back to zero and */
/*        cause the digit to the left to increment.  The actual */
/*        text version for the current case number will be: */

/*        DIGIT(D(1),1)//DIGIT(D(2),2)// ... //DIGIT(D(MAXPLC),MAXPLC). */

    for (i__ = 1; i__ <= 7; ++i__) {
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 10) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)315)] = ' ';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 9) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)316)] = '1';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 8) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)317)] = '2';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 7) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)318)] = '3';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 6) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)319)] = '4';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 5) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)320)] = '5';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 4) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)321)] = '6';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 3) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)322)] = '7';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 2) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)323)] = '8';
	*(unsigned char *)&digit[(i__1 = i__ * 10 - 1) < 70 && 0 <= i__1 ? 
		i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)324)] = '9';
	d__[(i__1 = i__ - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge("d", i__1, 
		"t_stat__", (ftnlen)325)] = 1;
    }
    *(unsigned char *)&digit[60] = '0';
    return 0;

/*     Return the name of the current family of tests. */


L_t_name:
    s_copy(name__, rname, name_len, (ftnlen)12);
    return 0;

/*     Return information about whether all test cases since set up */
/*     via T_BEGIN have passed. */


L_t_success:
    *ok = succes;
    return 0;

L_t_fcount:
    *number = nfail;
    return 0;

/*     Set up for the next test case. */


L_t_case:

/*        Store the name, set this case success value to .TRUE. and */
/*        increment the case number. */

    s_copy(descr, name__, (ftnlen)500, name_len);
    caseok = TRUE_;
    ++caseno;

/*        Reset the error handling. */

    reset_();

/*        Next we increment the odometer.  We always increment the least */
/*        significant digit. */

    incr = TRUE_;
    for (i__ = 7; i__ >= 1; --i__) {
	if (incr) {

/*              If we incremented this digit, we will never want to use */
/*              a blank (while in this test case) for this digit again. */
/*              Set the first digit to zero "0". */

	    d__[(i__1 = i__ - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge("d", i__1, 
		    "t_stat__", (ftnlen)384)] = d__[(i__2 = i__ - 1) < 7 && 0 
		    <= i__2 ? i__2 : s_rnge("d", i__2, "t_stat__", (ftnlen)
		    384)] + 1;
	    *(unsigned char *)&digit[(i__1 = i__ * 10 - 10) < 70 && 0 <= i__1 
		    ? i__1 : s_rnge("digit", i__1, "t_stat__", (ftnlen)385)] =
		     '0';

/*              If the current digit is not greater than 10, we need */
/*              to set it back to 1 and cascade up to the next digit. */
/*              That is, make sure INCR stays .TRUE. */

	    if (d__[(i__1 = i__ - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge("d", 
		    i__1, "t_stat__", (ftnlen)391)] > 10) {
		d__[(i__1 = i__ - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge("d", 
			i__1, "t_stat__", (ftnlen)393)] = 1;
	    } else {

/*                 In this case we do not need to increment any digit */
/*                 that is more significant than the current digit. */

		incr = FALSE_;
	    }
	}
    }
    return 0;

/*     This entry point merely records that some aspect of this */
/*     test case has failed. */


L_t_cfail:
    if (caseok) {
	++nfail;
    }
    anybad = TRUE_;
    caseok = FALSE_;
    succes = FALSE_;
    return 0;

/*     Return information about whether or not the current test case */
/*     passed. */


L_t_cpass:
    *ok = caseok;
    return 0;

/*     Return the number of the current test case. */


L_t_cnum:
    *number = caseno;
    return 0;

/*     The entry point T_NAME gets the name of the current test case. */
/*     This has the form "Test Case #. <description> " where # is */
/*     the text decimal for the current case and <description> is the */
/*     description provided at the entry T_CASE. */


L_t_cname:
    s_copy(myname, "Test Case ", (ftnlen)520, (ftnlen)10);
    j = 10;

/*        Append each non-blank digit (starting with the most */
/*        significant) to the current value of MYNAME. */

    for (i__ = 1; i__ <= 7; ++i__) {
	if (*(unsigned char *)&digit[(i__2 = d__[(i__1 = i__ - 1) < 7 && 0 <= 
		i__1 ? i__1 : s_rnge("d", i__1, "t_stat__", (ftnlen)456)] + 
		i__ * 10 - 11) < 70 && 0 <= i__2 ? i__2 : s_rnge("digit", 
		i__2, "t_stat__", (ftnlen)456)] != ' ') {
	    ++j;
	    *(unsigned char *)&myname[j - 1] = *(unsigned char *)&digit[(i__2 
		    = d__[(i__1 = i__ - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge(
		    "d", i__1, "t_stat__", (ftnlen)458)] + i__ * 10 - 11) < 
		    70 && 0 <= i__2 ? i__2 : s_rnge("digit", i__2, "t_stat__",
		     (ftnlen)458)];
	}
    }

/*        Place a period after the case number. */

    ++j;
    *(unsigned char *)&myname[j - 1] = '.';

/*        Follow that up with the case description. */

    j += 2;
    s_copy(myname + (j - 1), descr, 520 - (j - 1), (ftnlen)500);
    s_copy(name__, myname, name_len, (ftnlen)520);
    return 0;

L_t_anybad:
    *ok = anybad;
    return 0;

L_t_trace:
    ljust_(act, myact, act_len, (ftnlen)32);
    ucase_(myact, myact, (ftnlen)32, (ftnlen)32);
    if (s_cmp(myact, "SET", (ftnlen)32, (ftnlen)3) == 0) {
	s_copy(trace, name__, (ftnlen)1200, name_len);
    } else if (s_cmp(myact, "GET", (ftnlen)32, (ftnlen)3) == 0) {
	s_copy(name__, trace, name_len, (ftnlen)1200);
    }
    return 0;
} /* t_stat__ */

/* Subroutine */ int t_stat__(char *act, char *name__, logical *ok, integer *
	number, ftnlen act_len, ftnlen name_len)
{
    return t_stat__0_(0, act, name__, ok, number, act_len, name_len);
    }

/* Subroutine */ int t_begin__(char *name__, ftnlen name_len)
{
    return t_stat__0_(1, (char *)0, name__, (logical *)0, (integer *)0, (
	    ftnint)0, name_len);
    }

/* Subroutine */ int t_name__(char *name__, ftnlen name_len)
{
    return t_stat__0_(2, (char *)0, name__, (logical *)0, (integer *)0, (
	    ftnint)0, name_len);
    }

/* Subroutine */ int t_success__(logical *ok)
{
    return t_stat__0_(3, (char *)0, (char *)0, ok, (integer *)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int t_fcount__(integer *number)
{
    return t_stat__0_(4, (char *)0, (char *)0, (logical *)0, number, (ftnint)
	    0, (ftnint)0);
    }

/* Subroutine */ int t_case__(char *name__, ftnlen name_len)
{
    return t_stat__0_(5, (char *)0, name__, (logical *)0, (integer *)0, (
	    ftnint)0, name_len);
    }

/* Subroutine */ int t_cfail__(void)
{
    return t_stat__0_(6, (char *)0, (char *)0, (logical *)0, (integer *)0, (
	    ftnint)0, (ftnint)0);
    }

/* Subroutine */ int t_cpass__(logical *ok)
{
    return t_stat__0_(7, (char *)0, (char *)0, ok, (integer *)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int t_cnum__(integer *number)
{
    return t_stat__0_(8, (char *)0, (char *)0, (logical *)0, number, (ftnint)
	    0, (ftnint)0);
    }

/* Subroutine */ int t_cname__(char *name__, ftnlen name_len)
{
    return t_stat__0_(9, (char *)0, name__, (logical *)0, (integer *)0, (
	    ftnint)0, name_len);
    }

/* Subroutine */ int t_anybad__(logical *ok)
{
    return t_stat__0_(10, (char *)0, (char *)0, ok, (integer *)0, (ftnint)0, (
	    ftnint)0);
    }

/* Subroutine */ int t_trace__(char *act, char *name__, ftnlen act_len, 
	ftnlen name_len)
{
    return t_stat__0_(11, act, name__, (logical *)0, (integer *)0, act_len, 
	    name_len);
    }

