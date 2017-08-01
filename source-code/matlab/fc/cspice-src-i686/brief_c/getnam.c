/* getnam.f -- translated by f2c (version 19980913).
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

/* Subroutine */ int getnam_(integer *idcode, char *pattrn, char *name__, 
	ftnlen pattrn_len, ftnlen name_len)
{
    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), bodc2n_(integer *, char *, logical *, 
	    ftnlen), prefix_(char *, integer *, char *, ftnlen, ftnlen), 
	    suffix_(char *, integer *, char *, ftnlen, ftnlen);
    char string[64];
    extern /* Subroutine */ int intstr_(integer *, char *, ftnlen);

    bodc2n_(idcode, string, &found, (ftnlen)64);
    if (! found) {
	intstr_(idcode, name__, name_len);
	return 0;
    }
    if (s_cmp(pattrn, "p1", pattrn_len, (ftnlen)2) == 0) {
	suffix_("(#)", &c__1, string, (ftnlen)3, (ftnlen)64);
	repmi_(string, "#", idcode, string, (ftnlen)64, (ftnlen)1, (ftnlen)64)
		;
	s_copy(name__, string, name_len, (ftnlen)64);
    } else if (s_cmp(pattrn, "p2", pattrn_len, (ftnlen)2) == 0) {
	intstr_(idcode, name__, name_len);
    } else {
	prefix_("#", &c__1, string, (ftnlen)1, (ftnlen)64);
	repmi_(string, "#", idcode, string, (ftnlen)64, (ftnlen)1, (ftnlen)64)
		;
	s_copy(name__, string, name_len, (ftnlen)64);
    }
    return 0;
} /* getnam_ */

