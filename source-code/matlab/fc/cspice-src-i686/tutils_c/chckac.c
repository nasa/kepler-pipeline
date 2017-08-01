/* chckac.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure CHCKAC ( Check an array of characters ) */
/* Subroutine */ int chckac_(char *name__, char *array, char *comp, char *
	exp__, integer *size, logical *ok, ftnlen name_len, ftnlen array_len, 
	ftnlen comp_len, ftnlen exp_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer i_len(char *, ftnlen), s_cmp(char *, char *, ftnlen, ftnlen);
    logical l_le(char *, char *, ftnlen, ftnlen), l_ge(char *, char *, ftnlen,
	     ftnlen), l_lt(char *, char *, ftnlen, ftnlen), l_gt(char *, char 
	    *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    integer lval, lexp, i__;
    extern /* Subroutine */ int ucase_(char *, char *, ftnlen, ftnlen), 
	    repmc_(char *, char *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), repmi_(char *, char *, integer *, char *, ftnlen, ftnlen,
	     ftnlen);
    char mycmp[2], myval[4000];
    extern integer rtrim_(char *, ftnlen);
    char myexp[4000];
    logical sn2cas;
    char messge[320];
    extern logical verbos_(void);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     Check the values in two character arrays. */

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

/*     None. */

/* $ Keywords */

/*     TESTING */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAME       I   the name of the array to be examined. */
/*     ARRAY      I   the actual array. */
/*     COMP       I   the kind of comparison to perform. */
/*     EXP        I   the comparison values for the array. */
/*     SIZE       I   the size of the input array */
/*     OK         O   TRUE if the test passes, FALSE otherwise... */

/* $ Detailed_Input */

/*     NAME       is the string used to give the name of an array. */

/*     ARRAY      is the actual array of strings to be examined. */

/*     COMP       a string giving the kind of comparison to perform: */

/*                    =    ---   check for strict equality */
/*                    >    ---   check for VAL >  EXP */
/*                    <    ---   check for VAL <  EXP */
/*                    >=   ---   check for VAL >= EXP ( LGE (VAL, EXP) ) */
/*                    <=   ---   check for VAL <= EXP ( LLE (VAL, EXP) ) */
/*                    !=   ---   check for VAL != EXP ( VAL .NE. EXP   ) */

/*                    The following are the case insensitive versions */
/*                    of the previous checks. */

/*                    ~=    ---   check for strict equality */
/*                    ~>    ---   check for VAL >  EXP */
/*                    ~<    ---   check for VAL <  EXP */
/*                    ~>=   ---   check for VAL >= EXP */
/*                    ~<=   ---   check for VAL <= EXP */
/*                    ~!=   ---   check for VAL != EXP */

/*     EXP            the array of expected values or bounds on values */
/*                    in ARRAY. */

/* $ Detailed_Output */

/*     OK         if the check of the input array is successful then */
/*                OK is given the value TRUE.  Otherwise OK is given the */
/*                value FALSE and a diagnostic message is sent to the */
/*                test logger. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine handles a wide variety of comparisons between */
/*     character string arrays. */

/* $ Examples */

/*     Suppose that you have just made a call to a subroutine that */
/*     you wish to test (call the routine SPUD) and you would like */
/*     to test an array of output strings matches your expectations. */
/*     Using this routine you can automatically have the test */
/*     result logged in via the testing utitities. */

/*        CALL SPUD   (  INPUT,   OUTPUT ) */
/*        CALL CHCKAC ( 'OUTPUT', OUTPUT, '=', EXPECT, OK ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    Testing Utility Version 1.0.0, 24-DEC-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Testing Utility Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Setup style strings? */

    tststy_(good, bad, (ftnlen)120, (ftnlen)120);
    tstlgs_("LEFT 3 RIGHT 75 NEWLINE /cr ", "LEFT 3 RIGHT 75 NEWLINE /cr FLA"
	    "G --- LEADER ---", (ftnlen)28, (ftnlen)47);

/*     Set FAIL to FALSE */

    fail = FALSE_;

/*     Are we doing case-insensitive checks? */

    if (*(unsigned char *)comp == '~') {
	sn2cas = FALSE_;
	s_copy(mycmp, comp + 1, (ftnlen)2, comp_len - 1);
    } else {
	sn2cas = TRUE_;
	s_copy(mycmp, comp, (ftnlen)2, comp_len);
    }

/*     Set the length parameters. */

    lval = i_len(array, array_len);
    lexp = i_len(exp__, exp_len);

/*     Do the comparisons. */

    if (s_cmp(mycmp, "=", (ftnlen)2, (ftnlen)1) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = s_cmp(myval, myexp, lval, lexp) != 0;
	    if (fail) {
		s_copy(messge, "Value # of array # was not the value expecte"
			"d. /cr(3:)/cr The value was:         # /crthe expect"
			"ed value was #./cr", (ftnlen)320, (ftnlen)114);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(mycmp, ">", (ftnlen)2, (ftnlen)1) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = l_le(myval, myexp, lval, lexp);
	    if (fail) {
		s_copy(messge, "Value # of array # was not greater than the "
			"value expected. /cr(3:)/cr The value was:         # "
			"/crthe expected value was #./cr", (ftnlen)320, (
			ftnlen)127);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(mycmp, "<", (ftnlen)2, (ftnlen)1) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = l_ge(myval, myexp, lval, lexp);
	    if (fail) {
		s_copy(messge, "Value # of array # was not less than the val"
			"ue expected. /cr(3:)/cr The value was:         # /cr"
			"the expected value was #./cr", (ftnlen)320, (ftnlen)
			124);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(mycmp, ">=", (ftnlen)2, (ftnlen)2) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = l_lt(myval, myexp, lval, lexp);
	    if (fail) {
		s_copy(messge, "Value # of array # was not greater than or e"
			"qual to the value expected. /cr(3:)/cr The value was"
			":         # /crthe expected value was #./cr", (ftnlen)
			320, (ftnlen)139);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(mycmp, "<=", (ftnlen)2, (ftnlen)2) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = l_gt(myval, myexp, lval, lexp);
	    if (fail) {
		s_copy(messge, "Value # of array # was not less than or equa"
			"l to the value expected. /cr(3:)/cr The value was:  "
			"       # /crthe expected value was #./cr", (ftnlen)
			320, (ftnlen)136);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(mycmp, "!=", (ftnlen)2, (ftnlen)2) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (! sn2cas) {
		ucase_(array + (i__ - 1) * array_len, myval, array_len, (
			ftnlen)4000);
		ucase_(exp__ + (i__ - 1) * exp_len, myexp, exp_len, (ftnlen)
			4000);
	    } else {
		s_copy(myval, array + (i__ - 1) * array_len, (ftnlen)4000, 
			array_len);
		s_copy(myexp, exp__ + (i__ - 1) * exp_len, (ftnlen)4000, 
			exp_len);
	    }
	    fail = s_cmp(myval, myexp, lval, lexp) == 0;
	    if (fail) {
		s_copy(messge, "Value # of array # should have been differen"
			"t from the expected value. /cr(3:)/cr The value was:"
			"         # /crthe expected value was #./cr", (ftnlen)
			320, (ftnlen)138);
		repmi_(messge, "#", &i__, messge, (ftnlen)320, (ftnlen)1, (
			ftnlen)320);
		repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)320);
		repmc_(messge, "#", array + (i__ - 1) * array_len, messge, (
			ftnlen)320, (ftnlen)1, array_len, (ftnlen)320);
		repmc_(messge, "#", exp__ + (i__ - 1) * exp_len, messge, (
			ftnlen)320, (ftnlen)1, exp_len, (ftnlen)320);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)320);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else {
	fail = TRUE_;
	s_copy(messge, "The comparison \"#\" is not recognized. ", (ftnlen)
		320, (ftnlen)38);
	repmc_(messge, "#", comp, messge, (ftnlen)320, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)320);
    }
    if (! fail) {
	s_copy(messge, "The comparison /cr/cr(3:)'# # EXPECTED' /cr/cr(-3:) "
		"was satisfied.", (ftnlen)320, (ftnlen)66);
	repmc_(messge, "#", name__, messge, (ftnlen)320, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)320);
	repmc_(messge, "#", comp, messge, (ftnlen)320, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)320);
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
} /* chckac_ */

