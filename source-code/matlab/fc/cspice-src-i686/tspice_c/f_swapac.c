/* f_swapac.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1000 = 1000;
static logical c_false = FALSE_;
static integer c__2 = 2;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c_n1 = -1;
static integer c_n2 = -2;

/* $Procedure F_SWAPAC ( Test the SPICELIB routine SWAPAC ) */
/* Subroutine */ int f_swapac__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer locm, locn, size;
    extern /* Subroutine */ int t_swapac__(integer *, integer *, integer *, 
	    integer *, integer *, char *, char *, ftnlen, ftnlen);
    char work[80*1000];
    integer i__, m, n;
    extern /* Subroutine */ int tcase_(char *, ftnlen), movec_(char *, 
	    integer *, char *, ftnlen, ftnlen), repmi_(char *, char *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer start;
    extern /* Subroutine */ int t_success__(logical *);
    char array0[80*1000], array1[80*1000];
    extern /* Subroutine */ int clearc_(integer *, char *, ftnlen), chcksc_(
	    char *, char *, char *, char *, logical *, ftnlen, ftnlen, ftnlen,
	     ftnlen), chckxc_(logical *, char *, logical *, ftnlen), swapac_(
	    integer *, integer *, integer *, integer *, char *, ftnlen);
    char xarray[80*1000];
    extern /* Subroutine */ int intstr_(integer *, char *, ftnlen);

/* $ Abstract */

/*     Exercise the SPICELIB sub-array swapping routine SWAPAC. */

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

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine tests the SPICELIB routine SWAPAC. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 14-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_SWAPAC", (ftnlen)8);

/*     We'll do an exhaustive set of tests on a small array. */

    clearc_(&c__1000, array0, (ftnlen)80);
    size = 10;
    i__1 = size;
    for (i__ = 1; i__ <= i__1; ++i__) {
	intstr_(&i__, array0 + ((i__2 = i__ - 1) < 1000 && 0 <= i__2 ? i__2 : 
		s_rnge("array0", i__2, "f_swapac__", (ftnlen)169)) * 80, (
		ftnlen)80);
    }

/*     LOCN is the start of the "upper" slice. */

    i__1 = size;
    for (locn = 1; locn <= i__1; ++locn) {

/*        N is the size of the upper slice. */

	i__2 = size - locn + 1;
	for (n = 0; n <= i__2; ++n) {

/*           LOCM is the start of the "lower" slice. */

	    start = locn + max(1,n);
	    i__3 = size;
	    for (locm = start; locm <= i__3; ++locm) {

/*              M is the size of the lower slice. */

		i__4 = size - locm + 1;
		for (m = 0; m <= i__4; ++m) {

/* --- Case: ------------------------------------------------------ */

		    s_copy(title, "Case: N = #; LOCN = #; M = #; LOCM = #.", (
			    ftnlen)240, (ftnlen)39);
		    repmi_(title, "#", &n, title, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    repmi_(title, "#", &locn, title, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    repmi_(title, "#", &m, title, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    repmi_(title, "#", &locm, title, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    tcase_(title, (ftnlen)240);

/*                 Make two copies of the initial array. */

		    movec_(array0, &size, array1, (ftnlen)80, (ftnlen)80);
		    movec_(array0, &size, xarray, (ftnlen)80, (ftnlen)80);

/*                 Swap the array slices indicated by LOCN, N, LOCM, */
/*                 and M. */

		    swapac_(&n, &locn, &m, &locm, array1, (ftnlen)80);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Produce our expected array. */

		    t_swapac__(&size, &n, &locn, &m, &locm, xarray, work, (
			    ftnlen)80, (ftnlen)80);

/*                 Test our results. */

		    i__5 = size;
		    for (i__ = 1; i__ <= i__5; ++i__) {
			s_copy(title, "swapped array element # (0)", (ftnlen)
				240, (ftnlen)27);
			repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)
				1, (ftnlen)240);
			chcksc_(title, array1 + ((i__6 = i__ - 1) < 1000 && 0 
				<= i__6 ? i__6 : s_rnge("array1", i__6, "f_s"
				"wapac__", (ftnlen)230)) * 80, "=", xarray + ((
				i__7 = i__ - 1) < 1000 && 0 <= i__7 ? i__7 : 
				s_rnge("xarray", i__7, "f_swapac__", (ftnlen)
				230)) * 80, ok, (ftnlen)240, (ftnlen)80, (
				ftnlen)1, (ftnlen)80);
		    }

/*                 Now we'll repeat the test with the order of */
/*                 the arguments swapped. */

		    movec_(array0, &size, array1, (ftnlen)80, (ftnlen)80);
		    movec_(array0, &size, xarray, (ftnlen)80, (ftnlen)80);

/*                 Swap the array slices indicated by LOCN, N, LOCM, */
/*                 and M. */

		    swapac_(&m, &locm, &n, &locn, array1, (ftnlen)80);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Produce our expected array. */

		    t_swapac__(&size, &m, &locm, &n, &locn, xarray, work, (
			    ftnlen)80, (ftnlen)80);

/*                 Test our results. */

		    i__5 = size;
		    for (i__ = 1; i__ <= i__5; ++i__) {
			s_copy(title, "swapped array element # (1)", (ftnlen)
				240, (ftnlen)27);
			repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)
				1, (ftnlen)240);
			chcksc_(title, array1 + ((i__6 = i__ - 1) < 1000 && 0 
				<= i__6 ? i__6 : s_rnge("array1", i__6, "f_s"
				"wapac__", (ftnlen)263)) * 80, "=", xarray + ((
				i__7 = i__ - 1) < 1000 && 0 <= i__7 ? i__7 : 
				s_rnge("xarray", i__7, "f_swapac__", (ftnlen)
				263)) * 80, ok, (ftnlen)240, (ftnlen)80, (
				ftnlen)1, (ftnlen)80);
		    }
		}
	    }
	}
    }

/*     Now for some error handling tests. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SWAPAC: overlapping array slices.", (ftnlen)33);
    swapac_(&c__2, &c__1, &c__2, &c__1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(NOTDISTINCT)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    tcase_("SWAPAC: non-positive value of LOCN, LOCM", (ftnlen)40);
    swapac_(&c__2, &c__0, &c__2, &c__1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);
    swapac_(&c__2, &c_n1, &c__2, &c__1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);
    swapac_(&c__2, &c__1, &c__2, &c_n1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);
    swapac_(&c__2, &c__1, &c__2, &c__0, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDINDEX)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SWAPAC: Negative value of N, M", (ftnlen)30);
    swapac_(&c_n2, &c__0, &c__2, &c__1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);
    swapac_(&c__2, &c__0, &c_n2, &c__1, array1, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_swapac__ */


/*     T_SWAPAC is a utility routine used for testing SWAPAC. T_SWAPAC */
/*     uses an alternate implementation of the swapping algorithm that */
/*     uses work space to build the output array:  the swapping */
/*     algorithm is quite simple when the constraint of in-place */
/*     operation is removed. */

/*     This routine does no error checking. */

/* Subroutine */ int t_swapac__(integer *size, integer *n, integer *locn, 
	integer *m, integer *locm, char *array, char *work, ftnlen array_len, 
	ftnlen work_len)
{
    integer nlow;
    extern /* Subroutine */ int movec_(char *, integer *, char *, ftnlen, 
	    ftnlen);
    integer nmove, lower, upper, to, loc, nup;


/*     Local variables */


/*     We'll build the output array in WORK; then we'll copy the */
/*     result back to ARRAY. */

/*     Identify the start indices of the "top" and "bottom" array slices */
/*     to be swapped.  We consider the lower addresses to be at the */
/*     "top" of the array. */

    upper = min(*locn,*locm);
    lower = max(*locn,*locm);
    if (upper == *locn) {
	nup = *n;
	nlow = *m;
    } else {
	nup = *m;
	nlow = *n;
    }

/*     Move the elements preceding UPPER into WORK. */

    to = 1;
    nmove = upper - 1;
    movec_(array, &nmove, work + (to - 1) * work_len, array_len, work_len);

/*     Move the elements in the lower slice into WORK. */

    to += nmove;
    nmove = nlow;
    movec_(array + (lower - 1) * array_len, &nmove, work + (to - 1) * 
	    work_len, array_len, work_len);

/*     Move the elements between the slices into WORK. */

    to += nmove;
    nmove = lower - 1 - (upper + nup - 1);
    movec_(array + (upper + nup - 1) * array_len, &nmove, work + (to - 1) * 
	    work_len, array_len, work_len);

/*     Move the elements in the upper slice into WORK. */

    to += nmove;
    nmove = nup;
    movec_(array + (upper - 1) * array_len, &nmove, work + (to - 1) * 
	    work_len, array_len, work_len);

/*     Move the elements below the lower slice into WORK. */

    to += nmove;
    loc = lower + nlow;
    nmove = *size - (loc - 1);
    movec_(array + (loc - 1) * array_len, &nmove, work + (to - 1) * work_len, 
	    array_len, work_len);

/*     Copy WORK into ARRAY. */

    movec_(work, size, array, work_len, array_len);
    return 0;
} /* t_swapac__ */

