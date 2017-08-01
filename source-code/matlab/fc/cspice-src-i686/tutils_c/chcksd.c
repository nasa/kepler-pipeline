/* chcksd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__14 = 14;

/* $Procedure      CHCKSD ( Check Scalar d.p. ) */

/* Subroutine */ int chcksd_(char *name__, doublereal *val, char *comp, 
	doublereal *exp__, doublereal *tol, logical *ok, ftnlen name_len, 
	ftnlen comp_len)
{
    /* System generated locals */
    doublereal d__1, d__2, d__3;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmd_(char *, char *, doublereal *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    char messge[320];
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);
    doublereal rel;


/* $ Abstract */

/*     Check an d.p. scalar value against some expected value. */

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
/*      COMP       I   the kind of comparison to perform. */
/*      EXP        I   the comparison value for the variable */
/*      TOL        I   the tolerance allowed in comparing. */
/*      OK         O   TRUE if the test passes, FALSE otherwise.. */

/* $ Detailed_Input */

/*     NAME        is the string used to give the name of a variable */

/*     VAL         is the actual d.p. variable to be examined */

/*     EXP         an expected value or bound on the value VAL. */

/*     COMP        a string giving the kind of comparison to perform: */

/*                    =    ---   check for strict equality */
/*                    >    ---   check for VAL >  EXP */
/*                    <    ---   check for VAL <  EXP */
/*                    >=   ---   check for VAL >= EXP ( VAL .GE. EXP ) */
/*                    <=   ---   check for VAL <= EXP ( VAL .LE. EXP ) */
/*                    !=   ---   check for VAL != EXP ( VAL .NE. EXP ) */
/*                    ~    ---   check for VAL ~  EXP ( VAL within TOL */
/*                               of EXP) */
/*                    ~/   ---   check for VAL ~/ EXP ( Relative */
/*                               difference between VAL and EXP .LE. TOL) */

/*     TOL        is a "tolerance" to use when checking for VAL to */
/*                be nearly the same as EXP. */

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
/*     to test an output d.p. against an expected value and verify that */
/*     the relative difference is less than some value.  Using */
/*     this routine you can automatically have the test result logged */
/*     in via the testing utitities. */

/*        CALL SPUD   (  INPUT,   OUTPUT ) */
/*        CALL CHCKSD ( 'OUTPUT', OUTPUT, '~/', EXPECT, 1.0D-12, OK ) */

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
    fail = FALSE_;
    if (s_cmp(comp, "=", comp_len, (ftnlen)1) == 0) {
	fail = *val != *exp__;
	s_copy(messge, "The value of # was not the value expected./cr The va"
		"lue was:         # /cr the expected value was #. /crThe diff"
		"erence between these is: # .", (ftnlen)320, (ftnlen)140);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *val - *exp__;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, "<", comp_len, (ftnlen)1) == 0) {
	fail = *val >= *exp__;
	s_copy(messge, "The value of # was not less than # as was expected. "
		"/cr The value was #. /cr This is greater than # by #. ", (
		ftnlen)320, (ftnlen)106);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *val - *exp__;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, ">", comp_len, (ftnlen)1) == 0) {
	fail = *val <= *exp__;
	s_copy(messge, "The value of # was not greater than # as was expecte"
		"d. /cr The value was #. /crThis is less than # by #. ", (
		ftnlen)320, (ftnlen)105);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *exp__ - *val;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, ">=", comp_len, (ftnlen)2) == 0) {
	fail = *val < *exp__;
	s_copy(messge, "The value of # was not greater than # as was expecte"
		"d. /cr The value was #./cr This is less than # by #. ", (
		ftnlen)320, (ftnlen)105);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *exp__ - *val;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, "<=", comp_len, (ftnlen)2) == 0) {
	fail = *val > *exp__;
	s_copy(messge, "The value of # was not less than # as was expected. "
		"/cr The value was #./cr This is greater than # by #. ", (
		ftnlen)320, (ftnlen)105);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *val - *exp__;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, "!=", comp_len, (ftnlen)2) == 0) {
	fail = *val == *exp__;
	s_copy(messge, "The value of # should have been different from #./cr"
		" It wasn't. ", (ftnlen)320, (ftnlen)64);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, "~", comp_len, (ftnlen)1) == 0) {
	fail = *tol < (d__1 = *val - *exp__, abs(d__1));
	s_copy(messge, "The value of # was not within # of #. /cr The value "
		"was #./cr The difference between the actual and expected val"
		"ue was #. ", (ftnlen)320, (ftnlen)122);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	d__1 = *val - *exp__;
	repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else if (s_cmp(comp, "~/", comp_len, (ftnlen)2) == 0) {
	if (*val == *exp__) {
	    rel = 0.;
	} else {
/* Computing MAX */
	    d__2 = abs(*val), d__3 = abs(*exp__);
	    rel = (d__1 = *val - *exp__, abs(d__1)) / max(d__2,d__3);
	}
	fail = *tol < rel;
	s_copy(messge, "The value of # was #.  The expected value was #. /cr"
		" The relative difference between # andits expected value was"
		" #./cr The maximum relative difference allowed for a success"
		"ful test is #. ", (ftnlen)320, (ftnlen)187);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", &rel, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
    } else {
	fail = TRUE_;
	s_copy(messge, "The comparison # is not recognized. ", (ftnlen)320, (
		ftnlen)36);
	repmc_(messge, "#", comp, messge, (ftnlen)320, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)320);
    }
    if (! fail) {
	s_copy(messge, "The comparison/cr/cr(3:) '# # #' /cr/cr(-3:) was sat"
		"isfied to the specified tolearance: #./crThe value of # was "
		"#. ", (ftnlen)320, (ftnlen)115);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmc_(messge, "#", comp, messge, (ftnlen)320, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)320);
	repmd_(messge, "#", exp__, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmd_(messge, "#", val, &c__14, messge, (ftnlen)320, (ftnlen)1, (
		ftnlen)320);
	if (verbos_()) {
	    tstlog_(" ", &fail, (ftnlen)1);
	    tstlog_(messge, &fail, (ftnlen)320);
	}
    } else {
	tstlog_(" ", &fail, (ftnlen)1);
	tstlog_(messge, &fail, (ftnlen)320);
    }
    tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
    *ok = ! fail;
    return 0;
} /* chcksd_ */

