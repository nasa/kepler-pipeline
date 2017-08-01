/* chckad.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__14 = 14;

/* $Procedure      CHCKAD ( Check an array of integers ) */
/* Subroutine */ int chckad_(char *name__, doublereal *array, char *comp, 
	doublereal *exp__, integer *size, doublereal *tol, logical *ok, 
	ftnlen name_len, ftnlen comp_len)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2, d__3, d__4;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical fail;
    char good[120];
    doublereal size1, size2;
    integer i__;
    doublereal angle, denom;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmd_(char *, char *, doublereal *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen);
    extern doublereal vsepg_(doublereal *, doublereal *, integer *);
    extern integer rtrim_(char *, ftnlen);
    doublereal defect;
    extern doublereal halfpi_(void);
    char messge[800];
    doublereal howfar;
    extern doublereal vdistg_(doublereal *, doublereal *, integer *);
    extern logical verbos_(void);
    extern doublereal vnormg_(doublereal *, integer *);
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen), tstlgs_(
	    char *, char *, ftnlen, ftnlen);
    char bad[120];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);
    doublereal rel;

/* $ Abstract */

/*     Check the ordering of values in a character array. */

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
/*      TOL        I   the tolerance allowed in comparing. */
/*      OK         O   TRUE if the test passes, FALSE otherwise.. */

/* $ Detailed_Input */

/*     NAME        is the string used to give the name of an array. */

/*     ARRAY       is the actual d.p. array to be examined */

/*     COMP        a string giving the kind of comparison to perform: */

/*                    =    ---   check for strict equality */
/*                    ~    ---   check for ARRAY(I) ~  EXP(I) for each I. */
/*                               This checks that the difference */
/*                               |ARRAY(I) - EXP(I)| <= TOL for all I. */

/*                    ~/   ---   check for ARRAY(I) ~/ EXP(I) ( Relative */
/*                               difference between ARRAY(I) and EXP(I) */
/*                               .LE. TOL for all I. */

/*                    ||   ---   check that the "angle" between ARRAY */
/*                               and EXP is within TOL of zero. */

/*                    ~~   ---   check that the L2 distance between */
/*                               ARRAY and EXP is within TOL of zero. */

/*                    |_   ---   check that the angle between ARRAY */
/*                               and EXP is within TOL of pi/2 radians */

/*                    ~~/  ---   check that the vector relative */
/*                               difference between ARRAY and EXP is */
/*                               within TOL of zero. */

/*     EXP         an expected values or bounds on the values in ARRAY. */


/*     TOL        is a "tolerance" to use when checking for VAL to */
/*                be nearly the same as EXP. */

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
/*        CALL CHCKSD ( 'OUTPUT', OUTPUT, '~/', EXPECT, 1.0D-12, OK ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */
/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Testing Utility Version 1.1.0, 10-MAY-2001 (FST) */

/*        OK is now properly set in all cases before returning */
/*        control to the caller. */

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
		repmd_(messge, "#", &array[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		repmd_(messge, "#", &exp__[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		d__1 = array[i__ - 1] - exp__[i__ - 1];
		repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)800, (
			ftnlen)1, (ftnlen)800);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)800);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(comp, "~", comp_len, (ftnlen)1) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    fail = *tol < (d__1 = array[i__ - 1] - exp__[i__ - 1], abs(d__1));
	    if (fail) {
		s_copy(messge, "Value # of array # was not within # of #. /c"
			"r/cr The value was # ./crThe difference between the "
			"actual and expected value was #. ", (ftnlen)800, (
			ftnlen)129);
		repmi_(messge, "#", &i__, messge, (ftnlen)800, (ftnlen)1, (
			ftnlen)800);
		repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)800);
		repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)
			1, (ftnlen)800);
		repmd_(messge, "#", &exp__[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		repmd_(messge, "#", &array[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		d__1 = array[i__ - 1] - exp__[i__ - 1];
		repmd_(messge, "#", &d__1, &c__14, messge, (ftnlen)800, (
			ftnlen)1, (ftnlen)800);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)800);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(comp, "~/", comp_len, (ftnlen)2) == 0) {
	i__1 = *size;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (array[i__ - 1] == exp__[i__ - 1]) {
		rel = 0.;
	    } else {
/* Computing MAX */
		d__3 = (d__1 = array[i__ - 1], abs(d__1)), d__4 = (d__2 = 
			exp__[i__ - 1], abs(d__2));
		denom = max(d__3,d__4);
		rel = (d__1 = array[i__ - 1] - exp__[i__ - 1], abs(d__1)) / 
			denom;
	    }
	    fail = *tol < rel;
	    if (fail) {
		s_copy(messge, "Value # of array # was #. /cr The expected v"
			"alue was #. /cr/cr The relative difference between t"
			"his component and its expected value was #. /cr/crTh"
			"e maximum relative difference allowed for a successf"
			"ul test is #. ", (ftnlen)800, (ftnlen)214);
		repmi_(messge, "#", &i__, messge, (ftnlen)800, (ftnlen)1, (
			ftnlen)800);
		repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, 
			rtrim_(name__, name_len), (ftnlen)800);
		repmd_(messge, "#", &array[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		repmd_(messge, "#", &exp__[i__ - 1], &c__14, messge, (ftnlen)
			800, (ftnlen)1, (ftnlen)800);
		repmd_(messge, "#", &rel, &c__14, messge, (ftnlen)800, (
			ftnlen)1, (ftnlen)800);
		repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)
			1, (ftnlen)800);
		tstlog_(" ", &fail, (ftnlen)1);
		tstlog_(messge, &fail, (ftnlen)800);
		tstlgs_(good, bad, (ftnlen)120, (ftnlen)120);
		*ok = ! fail;
		return 0;
	    }
	}
    } else if (s_cmp(comp, "||", comp_len, (ftnlen)2) == 0) {
	angle = vsepg_(array, exp__, size);
	fail = angle > *tol;
	s_copy(messge, "The \"angle\" between direction of the #-vector # an"
		"d the expected direction was #./cr/cr The maximum allowed an"
		"gle for a successful test is #. ", (ftnlen)800, (ftnlen)142);
	repmi_(messge, "#", size, messge, (ftnlen)800, (ftnlen)1, (ftnlen)800)
		;
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmd_(messge, "#", &angle, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
    } else if (s_cmp(comp, "~~", comp_len, (ftnlen)2) == 0) {
	howfar = vdistg_(array, exp__, size);
	fail = howfar > *tol;
	s_copy(messge, "The \"distance\" between  the #-vector # and the exp"
		"ected vector was #./cr/cr  The maximum allowed distance for "
		"a successful test is #. ", (ftnlen)800, (ftnlen)134);
	repmi_(messge, "#", size, messge, (ftnlen)800, (ftnlen)1, (ftnlen)800)
		;
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmd_(messge, "#", &howfar, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
    } else if (s_cmp(comp, "~~/", comp_len, (ftnlen)3) == 0) {
	howfar = vdistg_(array, exp__, size);
	size1 = vnormg_(array, size);
	size2 = vnormg_(exp__, size);
	if (size1 == size2) {
	    rel = 0.;
	} else {
	    rel = howfar / max(size1,size2);
	}
	fail = rel > *tol;
	s_copy(messge, "The vector relative difference between the #-vector "
		"# and the expected vector was #./cr/cr The maximum allowed r"
		"elative difference for a successful test is #. ", (ftnlen)800,
		 (ftnlen)159);
	repmi_(messge, "#", size, messge, (ftnlen)800, (ftnlen)1, (ftnlen)800)
		;
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmd_(messge, "#", &rel, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
    } else if (s_cmp(comp, "|_", comp_len, (ftnlen)2) == 0) {
	defect = (d__1 = halfpi_() - vsepg_(array, exp__, size), abs(d__1));
	fail = defect > *tol;
	s_copy(messge, "The \"angle\" between direction of the #-vector # an"
		"d the expected direction was # radians away from being pi/2."
		"/cr/cr The maximum allowed defect in angle allowed for a suc"
		"cessful test is #. ", (ftnlen)800, (ftnlen)189);
	repmi_(messge, "#", size, messge, (ftnlen)800, (ftnlen)1, (ftnlen)800)
		;
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmd_(messge, "#", &defect, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
    } else {
	fail = TRUE_;
	s_copy(messge, "The comparison \"#\" is not recognized. ", (ftnlen)
		800, (ftnlen)38);
	repmc_(messge, "#", comp, messge, (ftnlen)800, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)800);
    }
    if (! fail) {
	s_copy(messge, "The comparison /cr/cr(3:)'# # EXPECTED' /cr/cr(-3:) "
		"was satisfied to the specified tolearance: #.", (ftnlen)800, (
		ftnlen)97);
	repmc_(messge, "#", name__, messge, (ftnlen)800, (ftnlen)1, rtrim_(
		name__, name_len), (ftnlen)800);
	repmc_(messge, "#", comp, messge, (ftnlen)800, (ftnlen)1, rtrim_(comp,
		 comp_len), (ftnlen)800);
	repmd_(messge, "#", tol, &c__14, messge, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
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
} /* chckad_ */

