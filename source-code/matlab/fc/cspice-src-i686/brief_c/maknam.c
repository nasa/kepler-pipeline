/* maknam.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;

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

/* Subroutine */ int maknam_(integer *object, integer *objsiz, logical *
	namord, char *objnam, ftnlen objnam_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char name__[48];
    integer i__;
    doublereal x;
    extern /* Subroutine */ int dpfmt_(doublereal *, char *, char *, ftnlen, 
	    ftnlen);
    logical found;
    extern /* Subroutine */ int bodc2n_(integer *, char *, logical *, ftnlen),
	     replch_(char *, char *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), suffix_(char *, integer *, char *, ftnlen, ftnlen);

    s_copy(objnam, " ", objnam_len, (ftnlen)1);
    i__1 = *objsiz - 1;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(name__, " ", (ftnlen)48, (ftnlen)1);
	if (*namord) {
	    bodc2n_(&object[i__ - 1], name__, &found, (ftnlen)48);
	    if (! found) {
		x = (doublereal) object[i__ - 1];
		dpfmt_(&x, "+0XXXXXXXXXXX", name__, (ftnlen)13, (ftnlen)48);
		replch_(name__, "-", "$", name__, (ftnlen)48, (ftnlen)1, (
			ftnlen)1, (ftnlen)48);
	    }
	} else {
	    x = (doublereal) object[i__ - 1];
	    dpfmt_(&x, "+0XXXXXXXXXXX", name__, (ftnlen)13, (ftnlen)48);
	    replch_(name__, "-", "$", name__, (ftnlen)48, (ftnlen)1, (ftnlen)
		    1, (ftnlen)48);
	}
	suffix_(name__, &c__1, objnam, (ftnlen)48, objnam_len);
    }
    return 0;
} /* maknam_ */

