/* f_moved.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__17 = 17;
static logical c_false = FALSE_;
static doublereal c_b10 = 0.;
static integer c__1 = 1;
static integer c__2 = 2;
static integer c__10 = 10;
static integer c_n1 = -1;
static doublereal c_b31 = 1.;
static integer c__0 = 0;

/* $Procedure  F_MOVED ( Family of tests for MOVED ) */
/* Subroutine */ int f_moved__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;
    static doublereal equiv_0[17], equiv_1[17];

    /* Builtin functions */
    double d_lg10(doublereal *);
    integer pow_ii(integer *, integer *);

    /* Local variables */
#define buff (equiv_0)
    integer maxp;
#define buff2 (equiv_1)
    integer h__, i__, j, k;
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *),
	     tcase_(char *, ftnlen);
    extern doublereal dpmin_(void), dpmax_(void);
    doublereal xbuff[17];
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *),
	     movei_(integer *, integer *, integer *), topen_(char *, ftnlen), 
	    t_success__(logical *);
#define ic ((integer *)equiv_0)
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckai_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), cleard_(integer *, doublereal *), chckxc_(
	    logical *, char *, logical *, ftnlen);
#define ic2 ((integer *)equiv_1)
    extern integer intmax_(void);
    integer xic[2];

/* $ Abstract */

/*     This routine tests MOVED. */


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

/* $ Particulars */

/*     This routine has already been used to detect a bug (NDIM = -1 */
/*     resulted in a segmentation fault for the PC-LINUX and NeXT */
/*     platforms, on which memmove is used to effect the copy). */

/*     So don't laugh. */

/* $ Version */

/* -     Version 1.3.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -     Version 1.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -     Version 1.1.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    Version 1.0.1 17-JUL-2002 (BVS) */

/*        Added MAC-OSX environments. */

/* -    Version 1.0.0 12-NOV-2001 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     EQUIVALENCE statements */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_MOVED", (ftnlen)7);

/*     Case 1. */

    tcase_("Test MOVED for a selection of standard d.p. numbers.", (ftnlen)52)
	    ;
    buff[0] = 1.;
    buff[1] = -1.;
    buff[2] = 0.;
    buff[3] = 1e10;
    buff[4] = 1.0000000000000011e-10;
    buff[5] = -1e10;
    buff[6] = -1.0000000000000011e-10;
    buff[7] = 1.0000000000000002e100;
    buff[8] = 1.0000000000000108e-100;
    buff[9] = -1.0000000000000002e100;
    buff[10] = -1.0000000000000002e100;
    buff[11] = 1.0000000000000006e300;
    buff[12] = 1.0000000000000324e-300;
    buff[13] = -1.0000000000000006e300;
    buff[14] = -1.0000000000000324e-300;
    buff[15] = dpmax_();
    buff[16] = dpmin_();
    xbuff[0] = 1.;
    xbuff[1] = -1.;
    xbuff[2] = 0.;
    xbuff[3] = 1e10;
    xbuff[4] = 1.0000000000000011e-10;
    xbuff[5] = -1e10;
    xbuff[6] = -1.0000000000000011e-10;
    xbuff[7] = 1.0000000000000002e100;
    xbuff[8] = 1.0000000000000108e-100;
    xbuff[9] = -1.0000000000000002e100;
    xbuff[10] = -1.0000000000000002e100;
    xbuff[11] = 1.0000000000000006e300;
    xbuff[12] = 1.0000000000000324e-300;
    xbuff[13] = -1.0000000000000006e300;
    xbuff[14] = -1.0000000000000324e-300;
    xbuff[15] = dpmax_();
    xbuff[16] = dpmin_();
    moved_(buff, &c__17, buff2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("BUFF2", buff2, "=", xbuff, &c__17, &c_b10, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Case 2. */

    tcase_("Test MOVED for a case known to be problematic.", (ftnlen)46);
    ic[0] = -771000;
    ic[1] = -771900;
    xic[0] = -771000;
    xic[1] = -771900;
    moved_(buff, &c__1, buff2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckai_("IC2", ic2, "=", xic, &c__2, ok, (ftnlen)3, (ftnlen)1);

/*     Case 3. */

    tcase_("Test MOVED for a selection of bit patterns generated by equivale"
	    "ncing 2-integer arrays with dp. numbers.", (ftnlen)104);
    d__1 = (doublereal) intmax_();
    maxp = (integer) d_lg10(&d__1);
    i__1 = maxp + 1;
    for (i__ = -1; i__ <= i__1; ++i__) {

/*        Assign the first element of the IC array. */

	if (i__ == -1) {
	    ic[0] = 0;
	} else if (i__ == maxp + 1) {
	    ic[0] = intmax_();
	} else {
	    ic[0] = pow_ii(&c__10, &i__);
	}
	i__2 = maxp + 1;
	for (j = -1; j <= i__2; ++j) {

/*           Assign the second element of the IC array. */

	    if (j == -1) {
		ic[1] = 0;
	    } else if (j == maxp + 1) {
		ic[1] = intmax_();
	    } else {
		ic[1] = pow_ii(&c__10, &j);
	    }

/*           Try every sign combination. */

	    for (k = 1; k <= 2; ++k) {
		ic[0] *= pow_ii(&c_n1, &k);
		for (h__ = 1; h__ <= 2; ++h__) {
		    ic[1] *= pow_ii(&c_n1, &h__);

/*                 Test MOVED on the current artificially constructed */
/*                 d.p. variable. */

		    movei_(ic, &c__2, xic);
		    moved_(buff, &c__1, buff2);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    chckai_("IC2", ic2, "=", xic, &c__2, ok, (ftnlen)3, (
			    ftnlen)1);
		}
	    }

/*           We're done testing the current pair of integers for each */
/*           sign combination. */

	}
    }

/*     Case 4. */

    tcase_("Test MOVED for NDIM = 0 and -1.", (ftnlen)31);
    filld_(&c_b31, &c__17, buff);
    cleard_(&c__17, buff2);
    cleard_(&c__17, xbuff);
    moved_(buff, &c__0, buff2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("BUFF2", buff2, "=", xbuff, &c__17, &c_b10, ok, (ftnlen)5, (
	    ftnlen)1);
    moved_(buff, &c_n1, buff2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("BUFF2", buff2, "=", xbuff, &c__17, &c_b10, ok, (ftnlen)5, (
	    ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_moved__ */

#undef ic2
#undef ic
#undef buff2
#undef buff


