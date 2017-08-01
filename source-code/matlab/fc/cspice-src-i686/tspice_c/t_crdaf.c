/* t_crdaf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;

/* Subroutine */ int t_crdaf__(char *type__, char *name__, integer *nseg, 
	integer *ids, doublereal *tbegs, doublereal *tends, char *segids, 
	ftnlen type_len, ftnlen name_len, ftnlen segids_len)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int t_crdesc__(char *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, ftnlen);
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int ucase_(char *, char *, ftnlen, ftnlen), 
	    ckopn_(char *, char *, integer *, integer *, ftnlen, ftnlen), 
	    ljust_(char *, char *, ftnlen, ftnlen), dafbna_(integer *, 
	    doublereal *, char *, ftnlen), dafena_(void);
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *), pckopn_(char *, char *, 
	    integer *, integer *, ftnlen, ftnlen), chkout_(char *, ftnlen);
    char loctyp[3];
    extern /* Subroutine */ int spkopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen);

/* $ Abstract */

/*     Create a new DAF with specifed segments. */

/*        07-NOV-2001 (NJB) */

/*     Support routine for TSPICE test families */

/*       f_ckbsr */
/*       f_pckbsr */
/*       f_spkbsr */

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

    chkin_("T_CRDAF", (ftnlen)7);
    ljust_(type__, loctyp, type_len, (ftnlen)3);
    ucase_(loctyp, loctyp, (ftnlen)3, (ftnlen)3);
    if (s_cmp(loctyp, "SPK", (ftnlen)3, (ftnlen)3) == 0) {
	spkopn_(name__, " ", &c__0, &handle, name_len, (ftnlen)1);
    } else if (s_cmp(loctyp, "CK", (ftnlen)3, (ftnlen)2) == 0) {
	ckopn_(name__, " ", &c__0, &handle, name_len, (ftnlen)1);
    } else {
	pckopn_(name__, " ", &c__0, &handle, name_len, (ftnlen)1);
    }
    i__1 = *nseg;
    for (i__ = 1; i__ <= i__1; ++i__) {
	t_crdesc__(loctyp, &i__, &ids[i__ - 1], &tbegs[i__ - 1], &tends[i__ - 
		1], descr, (ftnlen)3);
	dafbna_(&handle, descr, segids + (i__ - 1) * segids_len, segids_len);
	dafena_();
    }
    dafcls_(&handle);
    chkout_("T_CRDAF", (ftnlen)7);
    return 0;
} /* t_crdaf__ */

