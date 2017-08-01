/* f_stlabx.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b4 = 3e8;
static doublereal c_b5 = 2e8;
static doublereal c_b6 = -4e8;
static doublereal c_b7 = 1e10;
static doublereal c_b8 = 1e9;
static logical c_true = TRUE_;
static doublereal c_b13 = 10.;
static doublereal c_b14 = 3.;
static doublereal c_b15 = 9.;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b27 = 1e-14;

/* $Procedure  F_STLABX ( Family of tests for STLABX ) */
/* Subroutine */ int f_stlabx__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    doublereal axis[3];
    extern doublereal vsep_(doublereal *, doublereal *);
    doublereal angle;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal savec[3];
    extern /* Subroutine */ int vpack_(doublereal *, doublereal *, doublereal 
	    *, doublereal *), topen_(char *, ftnlen), ucrss_(doublereal *, 
	    doublereal *, doublereal *), t_success__(logical *), vrotv_(
	    doublereal *, doublereal *, doublereal *, doublereal *), chckad_(
	    char *, doublereal *, char *, doublereal *, integer *, doublereal 
	    *, logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical 
	    *, ftnlen), stelab_(doublereal *, doublereal *, doublereal *);
    doublereal obsvel[3];
    extern /* Subroutine */ int stlabx_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal corpos[3], trgpos[3], exppos[3];

/* $ Abstract */

/*     This routine tests STLABX. */

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

/*     Test STLABX by comparing its results to those obtained by */
/*     an alternate method. */

/* $ Version */

/* -    Version 1.0.0 12-NOV-2001 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */



/*     Begin every test family with an open call. */

    topen_("F_STLABX", (ftnlen)8);

/*     Case 1. */

    tcase_("Check error handling for excessive speed.", (ftnlen)41);
    vpack_(&c_b4, &c_b5, &c_b6, trgpos);
    vpack_(&c_b7, &c_b8, &c_b7, obsvel);
    stlabx_(trgpos, obsvel, corpos);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/*     Case 2. */

    tcase_("Try a routine computation.", (ftnlen)26);

/*     Set up a reasonable velocity vector. */

    vpack_(&c_b13, &c_b14, &c_b15, obsvel);

/*     Get the transmission stellar aberration correction from */
/*     STLABX. */

    stlabx_(trgpos, obsvel, corpos);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Obtain the target position vector, corrected for the usual */
/*     stellar aberration effect. */

    stelab_(trgpos, obsvel, savec);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the rotation axis about which POJB was rotated to */
/*     obtain SAVEC.  Find the angular separation between TRGPOS */
/*     and SAVEC as well. */

    ucrss_(trgpos, savec, axis);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    angle = vsep_(trgpos, savec);

/*     The corrected vector we seek is obtained by rotating TRGPOS */
/*     about AXIS in the opposite direction required to obtain */
/*     SAVEC. */

    d__1 = -angle;
    vrotv_(trgpos, axis, &d__1, exppos);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("CORPOS", corpos, "~~/", exppos, &c__3, &c_b27, ok, (ftnlen)6, (
	    ftnlen)3);
    t_success__(ok);
    return 0;
} /* f_stlabx__ */

