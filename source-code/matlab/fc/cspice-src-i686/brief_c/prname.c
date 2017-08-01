/* prname.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
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

/*     Construct the printname for an object. */

/* Subroutine */ int prname_(integer *object, integer *sobj, char *p1, char *
	wd, char *p2, integer *size, char *name__, ftnlen p1_len, ftnlen 
	wd_len, ftnlen p2_len, ftnlen name_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), i_len(char *, ftnlen);

    /* Local variables */
    integer r__;
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int getnam_(integer *, char *, char *, ftnlen, 
	    ftnlen), suffix_(char *, integer *, char *, ftnlen, ftnlen);

    s_copy(name__, " ", name_len, (ftnlen)1);
    getnam_(object, p1, name__, p1_len, name_len);
    if (object[(i__1 = *sobj - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("object", 
	    i__1, "prname_", (ftnlen)46)] != 1) {
	suffix_("*", &c__0, name__, (ftnlen)1, name_len);
    }
    if (*size > 1) {
	suffix_(wd, &c__1, name__, wd_len, name_len);
	r__ = rtrim_(name__, name_len) + 2;
	if (r__ < i_len(name__, name_len)) {
	    getnam_(&object[1], p2, name__ + (r__ - 1), p2_len, name_len - (
		    r__ - 1));
	}
    }
    return 0;
} /* prname_ */

