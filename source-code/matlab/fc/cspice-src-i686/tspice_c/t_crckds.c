/* t_crckds.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__6 = 6;
static integer c__2 = 2;

/* Subroutine */ int t_crckds__(integer *segno, integer *inst, doublereal *
	start, doublereal *stop, doublereal *descr, logical *gotav)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen), dafps_(integer *, 
	    integer *, doublereal *, integer *, doublereal *);
    doublereal dc[2];
    integer ic[6];
    extern /* Subroutine */ int cleard_(integer *, doublereal *), cleari_(
	    integer *, integer *), chkout_(char *, ftnlen);

/* $ Abstract */

/*     Create a new CK descriptor having specified ID code, angular */
/*     velocity flag, and time bounds.  The segment number is also */
/*     encoded in the integer components of the decriptor having */
/*     indices 2:NI. */

/*        18-NOV-2001 (NJB) */

/*     Support routine for TSPICE test family */

/*       f_ckbsr */
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

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */

    chkin_("T_CRCKDS", (ftnlen)8);
    cleari_(&c__6, ic);
    cleard_(&c__2, dc);
    ic[0] = *inst;
    for (i__ = 2; i__ <= 6; ++i__) {
	ic[(i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("ic", i__1, 
		"t_crckds__", (ftnlen)85)] = *segno * 10000 + i__;
    }
    if (*gotav) {
	ic[3] = 1;
    } else {
	ic[3] = 0;
    }
    dc[0] = *start;
    dc[1] = *stop;
    dafps_(&c__2, &c__6, dc, ic, descr);
    chkout_("T_CRCKDS", (ftnlen)8);
    return 0;
} /* t_crckds__ */

