/* sgctdf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static integer c__1 = 1;

/* $Procedure SGCTDF ( Generic Segments Create Test DAF ) */
/* Subroutine */ int sgctdf_(char *file, integer *nd, integer *ni, doublereal 
	*value, integer *cases, integer *ncase, integer *handle, ftnlen 
	file_len)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__, j;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal descr[125];
    extern /* Subroutine */ int dafada_(doublereal *, integer *), dafbna_(
	    integer *, doublereal *, char *, ftnlen), dafena_(void), kilfil_(
	    char *, ftnlen), dafonw_(char *, char *, integer *, integer *, 
	    char *, integer *, integer *, ftnlen, ftnlen, ftnlen), chkout_(
	    char *, ftnlen);
    extern logical return_(void);

/* $ Abstract */

/*    Create a simple generic segments DAF for testing purposes. */

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
/*     FILE       I   name of DAF to create. */
/*     ND         I   number of double precision components in descr. */
/*     NI         I   number of integer components in descriptor. */
/*     VALUE      I   double precision value to fill segments with. */
/*     CASES      I   array that describes the segment sizes to create. */
/*     NCASE      I   size of CASES array. */
/*     HANDLE     O   integer DAF handle. */

/* $ Detailed_Input */

/*     FILE       is the name of the DAF to create for testing. */

/*     ND,        are the number of double precision and integer */
/*     NI         components in each segment descriptor respectively. */

/*     VALUE      is the double precision value that is to fill each */
/*                of the segment arrays, except the last value. */

/*     CASES      is an array of integers that prescribe the size of */
/*                each segment that is to be constructed. */

/*     NCASE      is the number of entries in the CASES array. */

/* $ Detailed_Output */

/*     HANDLE     is the DAF handle associated with the file that was */
/*                just created. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Any exceptions signaled will be generated and trapped by */
/*     routines in the call tree of SGCTDF. */

/* $ Particulars */

/*     This routine creates a DAF file suitable for generic segments */
/*     testing.  The DAF consists of multiple segments where each segment */
/*     has a single value encoded in the array, except the final value. */
/*     The final value indicates the number of elements in the segment */
/*     array. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    F_SGMETA Version 1.0.0, 16-JUN-1999 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("SGCTDF", (ftnlen)6);
    }

/*     Initialize DESCR to 0. */

    for (i__ = 1; i__ <= 125; ++i__) {
	descr[(i__1 = i__ - 1) < 125 && 0 <= i__1 ? i__1 : s_rnge("descr", 
		i__1, "sgctdf_", (ftnlen)156)] = 0.;
    }

/*     Create the new DAF. First check to make certain no file of name */
/*     FILE exists. If it does remove it. */

    kilfil_(file, file_len);
    dafonw_(file, "DAF/TST", nd, ni, "Test DAF F_SGMETA", &c__0, handle, 
	    file_len, (ftnlen)7, (ftnlen)17);

/*     Create each of the segments.  Note this is terribly inefficient, */
/*     but will work just fine for test cases. */

    i__1 = *ncase;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Start a new segment.  Note the contents of the descriptor are */
/*        irrelevant, since we are only trying to test the functionality */
/*        of SGMETA. */

	dafbna_(handle, descr, "Test Segment", (ftnlen)12);

/*        Now load up the array.  This is where the serious inefficieny */
/*        comes in. */

	i__2 = cases[i__ - 1] - 1;
	for (j = 1; j <= i__2; ++j) {
	    dafada_(value, &c__1);
	}

/*        Place the number of elements into the last entry in the array */
/*        before ending it's creation. */

	d__1 = (doublereal) cases[i__ - 1];
	dafada_(&d__1, &c__1);
	dafena_();
    }
    chkout_("SGCTDF", (ftnlen)6);
    return 0;
} /* sgctdf_ */

