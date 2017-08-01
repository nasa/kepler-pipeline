/* multix.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure MULTIX ( Multiple dimensional index ) */
/* Subroutine */ int multix_(integer *basidx, integer *n, integer *dims__, 
	integer *offset, integer *coords)
{
    /* System generated locals */
    integer dims_dim1, coords_dim1, i__1, i__2, i__3, i__4;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__, m, q;
    extern /* Subroutine */ int chkin_(char *, ftnlen), rmaini_(integer *, 
	    integer *, integer *, integer *);
    integer maxidx;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen);
    integer rem;

/* $ Abstract */

/*     Map an offset into a one-dimensional array to the corresponding */
/*     coordinates of a specified n-dimensional array. The */
/*     lowest-indexed coordinate varies fastest. */

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

/*     MATH */
/*     UTILITY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  ------------------------------------------------- */
/*     BASIDX     I   Start index of array. */
/*     N          I   Number of array dimensions. */
/*     DIMS       I   Array dimensions. */
/*     OFFSET     I   Offset from array base. */
/*     COORDS     O   N-tuple of coordinates corresponding to offset. */

/* $ Detailed_Input */

/*     BASIDX         is the base value used for array indexing. */
/*                    OFFSET should be in the range */

/*                       BASIDX : SIZE-1 */

/*                   where size is the product of the elements of */
/*                   DIMS. */

/*                   For C-style indexing, BASIDX should be set to 0. */
/*                   For default Fortran-style indexing, BASIDX should */
/*                   be set to 1. */

/*     N             is the dimension of the array DIMS. */

/*     DIMS          is an array whose components define the shape and */
/*                   size of a multi-dimensional array; call this array */
/*                   ARR. */

/*     OFFSET        is the index in the array ARR defined by DIMS of an */
/*                   element of interest, when the array is viewed as a */
/*                   one-dimensional array:  in this view, the */
/*                   multidimensional array ARR is considered to have */
/*                   column-major organization: */

/*                      The first DIMS(1) elements of the array are */

/*                        ARR( BASIDX,           BASIDX, ... , BASIDX ) */
/*                               . */
/*                               . */
/*                               . */
/*                        ARR( BASIDX+DIMS(1)-1, BASIDX, ... , BASIDX ) */

/*                      The next DIMS(1) elements of the array are */

/*                        ARR( BASIDX,           BASIDX+1, ... , BASIDX ) */
/*                               . */
/*                               . */
/*                               . */
/*                        ARR( BASIDX+DIMS(1)-1, BASIDX+1, ... , BASIDX ) */

/*                      and so on. */
/* $ Detailed_Output */

/*     COORDS        is an N-tuple containing the coordinates of the */
/*                   array element located at OFFSET positions from */
/*                   BASIDX, when the column-major array ARR defined by */
/*                   DIMS is viewed as a one-dimensional array. */

/*                   The Ith component of COORDS ranges from BASIDX to */
/*                   DIMS(I)-1. */
/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*    1) If N is less than 1, this routine will fail in a system- */
/*        dependent manner. */

/*    2) If OFFSET is less than BASIDX or greater than BASIDX+P-1 */
/*       where */

/*          P = DIMS(1) * DIMS(2) * ... DIMS(N), */

/*       the error SPICE(VALUEOUTOFRANGE) is signaled. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     This routine enables traversal of a many-dimensional cartesian */
/*     product using a single loop.  Suppose the cartesian product C of */
/*     the sets S1, ..., SN is defined by: */

/*        C = S1  x  S2  x ... x SN */

/*     and that each set SI has cardinality DIMS(I). */

/*     Then if we let P be the product */

/*        P = DIMS(1) * DIMS(2) * ... * DIMS(N) */

/*     and we associate with each N-tuple of integers ( x1, ..., xN ), */
/*     the element of C */

/*        ( S1(x1), S2(x2), ..., SN(xn) ) */

/*     where x1, ... xN are in the range 1:N, then this routine */
/*     makes it simple to map the integers 1, ..., P onto C. */

/*     In Fortran, we achieve this with the loop */

/*        DO I = 1, P */

/*           CALL MULTIX ( 1, N, DIMS, I, COORDS ) */

/*           [  Do something with COORDS. */

/*              The Ith element of C is */

/*              ( S1(COORDS(1)), S2(COORDS(2)), ..., SN(COORDS(N)) ) */
/*           ] */

/*        END DO */


/*     See the TSPICE test family F_DYN01 for an example of this */
/*     technique. */

/* $ Examples */

/*     1) Let */

/*           BASIDX = 1 */
/*           N      = 2 */
/*           DIMS   = ( 4, 2 ) */

/*        The following array shows the mapping of OFFSET to elements */
/*        of ARR: */

/*              1 5 */
/*              2 6 */
/*              3 7 */
/*              4 8 */

/*        That is to say, */

/*          OFFSET = 1   yields   COORDS = ( 1, 1 ) */
/*          OFFSET = 2   yields   COORDS = ( 2, 1 ) */
/*                         . */
/*                         . */
/*                         . */
/*          OFFSET = 8   yields   COORDS = ( 4, 2 ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 21-DEC-2004 (NJB) */

/* -& */
/* $ Index_Entries */

/*       Compute multidimensional array index from offset */

/* -& */

/*     Local variables */


/*     Use discovery check-in. */

    /* Parameter adjustments */
    coords_dim1 = *n;
    dims_dim1 = *n;

    /* Function Body */
    if (*n < 1) {

/*        If N is less than 1, this routine may crash before */
/*        reaching these lines.  In case it doesn't.... */

	chkin_("MULTIX", (ftnlen)6);
	setmsg_("N must be at least 1;  N = #", (ftnlen)28);
	errint_("#", n, (ftnlen)1);
	sigerr_("SPICE(VALUEOUTOFRANGE)", (ftnlen)22);
	chkout_("MULTIX", (ftnlen)6);
	return 0;
    }
    if (*offset < *basidx) {
	chkin_("MULTIX", (ftnlen)6);
	setmsg_("OFFSET must not be less than BASIDX, which is #;  OFFSET = #"
		, (ftnlen)60);
	errint_("#", basidx, (ftnlen)1);
	errint_("#", offset, (ftnlen)1);
	sigerr_("SPICE(VALUEOUTOFRANGE)", (ftnlen)22);
	chkout_("MULTIX", (ftnlen)6);
	return 0;
    }

/*     We're going to use the output array COORDS as work space. */
/*     Later, we'll fill in the output values. */

/*     Compute the products of the first I dimensions, I = 1 to N-1. */
/*     The Ith product will go into element I+1 of COORDS. */

    coords[(i__1 = 0) < coords_dim1 ? i__1 : s_rnge("coords", i__1, "multix_",
	     (ftnlen)274)] = 1;
    i__1 = *n;
    for (i__ = 2; i__ <= i__1; ++i__) {
	coords[(i__2 = i__ - 1) < coords_dim1 && 0 <= i__2 ? i__2 : s_rnge(
		"coords", i__2, "multix_", (ftnlen)278)] = dims__[(i__3 = i__ 
		- 2) < dims_dim1 && 0 <= i__3 ? i__3 : s_rnge("dims", i__3, 
		"multix_", (ftnlen)278)] * coords[(i__4 = i__ - 2) < 
		coords_dim1 && 0 <= i__4 ? i__4 : s_rnge("coords", i__4, 
		"multix_", (ftnlen)278)];
    }

/*     Convert to 0-relative indexing.  We assume OFFSET ranges from */
/*     BASIDX to MAXIDX, where MAXIDX is */

/*        <the array size>   -  1  +  BASIDX. */

    m = *offset - *basidx;

/*     At this point we can check to make sure OFFSET is not too large. */

    maxidx = coords[(i__1 = *n - 1) < coords_dim1 && 0 <= i__1 ? i__1 : 
	    s_rnge("coords", i__1, "multix_", (ftnlen)293)] * dims__[(i__2 = *
	    n - 1) < dims_dim1 && 0 <= i__2 ? i__2 : s_rnge("dims", i__2, 
	    "multix_", (ftnlen)293)] - 1 + *basidx;
    if (*offset > maxidx) {
	chkin_("MULTIX", (ftnlen)6);
	setmsg_("OFFSET must not exceed #;  OFFSET = #", (ftnlen)37);
	errint_("#", &maxidx, (ftnlen)1);
	errint_("#", offset, (ftnlen)1);
	sigerr_("SPICE(VALUEOUTOFRANGE)", (ftnlen)22);
	chkout_("MULTIX", (ftnlen)6);
	return 0;
    }

/*     Pick off the coordinates, starting with the highest-indexed. */

    for (i__ = *n; i__ >= 2; --i__) {

/*        After the RMAINI call, we no longer need the work space */
/*        value of COORDS(I).  At this point, we overwrite that */
/*        value with the output value of COORDS(I). */

	rmaini_(&m, &coords[(i__1 = i__ - 1) < coords_dim1 && 0 <= i__1 ? 
		i__1 : s_rnge("coords", i__1, "multix_", (ftnlen)316)], &q, &
		rem);
	m = rem;
	coords[(i__1 = i__ - 1) < coords_dim1 && 0 <= i__1 ? i__1 : s_rnge(
		"coords", i__1, "multix_", (ftnlen)319)] = q;
    }
    coords[(i__1 = 0) < coords_dim1 ? i__1 : s_rnge("coords", i__1, "multix_",
	     (ftnlen)323)] = rem;

/*     If the index base is non-zero, map each coordinate back to */
/*     the original representation. */

    if (*basidx != 0) {
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    coords[(i__2 = i__ - 1) < coords_dim1 && 0 <= i__2 ? i__2 : 
		    s_rnge("coords", i__2, "multix_", (ftnlen)332)] = coords[(
		    i__3 = i__ - 1) < coords_dim1 && 0 <= i__3 ? i__3 : 
		    s_rnge("coords", i__3, "multix_", (ftnlen)332)] + *basidx;
	}
    }
    return 0;
} /* multix_ */

