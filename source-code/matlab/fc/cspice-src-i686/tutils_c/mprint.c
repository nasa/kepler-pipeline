/* mprint.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure      MPRINT ( Matrix Print ) */
/* Subroutine */ int mprint_(doublereal *mat, integer *rows, integer *cols, 
	char *fmt, ftnlen fmt_len)
{
    /* System generated locals */
    integer mat_dim1, mat_dim2, mat_offset, i__1, i__2, i__3, i__4;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char line[132], temp[132];
    integer c__, i__, j, space;
    extern integer nblen_(char *, ftnlen);
    extern /* Subroutine */ int dpfmt_(doublereal *, char *, char *, ftnlen, 
	    ftnlen);
    integer width;
    logical stars;
    extern integer rtrim_(char *, ftnlen);
    integer sigdig;
    char toobig[8];
    extern /* Subroutine */ int dpstrf_(doublereal *, integer *, char *, char 
	    *, ftnlen, ftnlen), tostdo_(char *, ftnlen);

/* $ Abstract */

/*     Format the contents of a d.p. matrix for printing. */

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

/*      UTILITY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     MAT        I   A d.p. matrix. */
/*     ROWS       I   The number of rows in the matrix. */
/*     COLS       I   The number of columns in the matrix. */
/*     FMT        I   A picture of the format for each in the matrix. */
/*     LINES      O   An arrary of text lines */

/* $ Detailed_Input */

/*     MAT        A matrix of ROWS rows and COLS columns that should */
/*                be converted into a suitable text format. */

/*     ROWS       The number of rows in MAT */

/*     COLS       The number of columns in MAT. */

/*     FMT        The format to use when creating entries. */

/* $ Detailed_Output */

/*     LINES      Array of string which when printed will present the */
/*                matrix in commonly used format for matrices. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine is a utility for those times when you simply want */
/*     to print a matrix. */

/*     Suppose MATRIX contains the inverses of the integers 1 */
/*     through 9.  To print this matrix make the following call */

/*     CALL MPRINT ( MATRIX,  3, 3, '-x.xxxx' ) */

/*     You'll get the following output. */
/*     (you need to view this with a fixed pitch font or things */
/*      may not look so great). */

/*        1.0000     0.5000     0.3333 */
/*        0.2500     0.2000     0.1667 */
/*        0.1429     0.1250     0.1111 */

/*     If the (3,2) entry gets corrupted with a value like */
/*     -1282.291 you'll get the following. */

/*        1.0000     0.5000     0.3333 */
/*        0.2500     0.2000     0.1667 */
/*        0.1429    -1.282E+03  0.1111 */

/*     Notice how the "out of range" guy sticks out calling */
/*     attention to himself.  To print a 6x6 matrix just change */
/*     the 3 to 6 in the calling sequence. */

/*     CALL MPRINT ( MATRIX,  6, 6, '-x.xxxx' ) */


/*        1.0000     0.5000     0.3333     0.2500     0.2000     0.1667 */
/*        0.1429     0.1250     0.1111     0.1000     0.0909     0.0833 */
/*        0.0769    -1.282E+03  0.0667     0.0625     0.0588     0.0556 */
/*        0.0526     0.0500     0.0476     0.0455     0.0435     0.0417 */
/*        0.0400     0.0385     0.0370     0.0357     0.0345     0.0333 */
/*        0.0323     0.0313     0.0303     0.0294     0.0286     0.0278 */

/*     The routine assumes you've got room for 132 characters per */
/*     line on output.  If the matrix runs over that, the output is */
/*     truncated on the right and and star '*' placed in the 132nd */
/*     column. */

/* $ Examples */

/*     Suppose you would like to print the contents of a matrix. */
/*     The following block of code will do this for you. */

/*     ROWS = 3 */
/*     COLS = 3 */

/*     CALL PMATRIX ( MAT, ROWS, COLS, '-##.######' ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*       W.L. Taber      (JPL) */

/* $ Literature_References */

/*       None. */

/* $ Version */

/* -    Testutil Version 1.1.0, 9-JAN-1997 (WLT) */

/*        Replaced calls to DPFMT_1 with DPFMT */

/* -    SPICELIB Version 1.0.0, 1-MAY-1995 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Print a matrix */

/* -& */

/*     Spicelib functions */


/*     Local Variables. */

    /* Parameter adjustments */
    mat_dim1 = *rows;
    mat_dim2 = *cols;
    mat_offset = mat_dim1 + 1;

    /* Function Body */
/* Computing MAX */
    i__1 = 1, i__2 = nblen_(fmt, fmt_len);
    width = max(i__1,i__2);
/* Computing MIN */
/* Computing MAX */
    i__3 = 1, i__4 = (80 - width) / *cols - width;
    i__1 = 4, i__2 = max(i__3,i__4);
    space = min(i__1,i__2);
/* Computing MAX */
    i__1 = 1, i__2 = width - 6 + space - 1;
    sigdig = max(i__1,i__2);
    if (width - 6 + space - 1 < 1) {
	stars = TRUE_;
	s_copy(toobig, "********", (ftnlen)8, (ftnlen)8);
    } else {
	stars = FALSE_;
    }
    i__1 = *rows;
    for (i__ = 1; i__ <= i__1; ++i__) {
	c__ = 1;
	i__2 = *cols;
	for (j = 1; j <= i__2; ++j) {
	    dpfmt_(&mat[(i__3 = i__ + j * mat_dim1 - mat_offset) < mat_dim1 * 
		    mat_dim2 && 0 <= i__3 ? i__3 : s_rnge("mat", i__3, "mpri"
		    "nt_", (ftnlen)221)], fmt, temp, fmt_len, (ftnlen)132);
	    if (rtrim_(temp, (ftnlen)132) > width) {
		if (stars) {
		    s_copy(temp, " ", (ftnlen)132, (ftnlen)1);
		    s_copy(temp, toobig, width, (ftnlen)8);
		} else {
		    dpstrf_(&mat[(i__3 = i__ + j * mat_dim1 - mat_offset) < 
			    mat_dim1 * mat_dim2 && 0 <= i__3 ? i__3 : s_rnge(
			    "mat", i__3, "mprint_", (ftnlen)229)], &sigdig, 
			    "E", temp, (ftnlen)1, (ftnlen)132);
		}
	    }
	    if (c__ < 132) {
		s_copy(line + (c__ - 1), temp, 132 - (c__ - 1), (ftnlen)132);
		if (c__ + width > 132) {
		    *(unsigned char *)&line[131] = '*';
		}
	    } else if (c__ == 132) {
		*(unsigned char *)&line[c__ - 1] = '*';
	    }
	    c__ = c__ + width + space;
	}
	tostdo_(line, rtrim_(line, (ftnlen)132));
    }
    return 0;
} /* mprint_ */

