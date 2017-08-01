/* f_spkgpx.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_n10 = -10;
static integer c__399 = 399;
static logical c_true = TRUE_;

/* $Procedure      F_SPKGPX (Family of tests for SPKGPS frame exceptions) */
/* Subroutine */ int f_spkgpx__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    doublereal et, lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     spkgps_(integer *, doublereal *, char *, integer *, doublereal *,
	     doublereal *, ftnlen);
    char ref[32];

/* $ Abstract */

/*     This routine tests the behaviour of the SPICE routine SPKGPS */
/*     when a bogus input frame is supplied as an argument. */

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

/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPKGPX", (ftnlen)8);
    et = 0.;
    tcase_("Check that we get reasonable unrecognized frame diagnostics subc"
	    "ase 1.", (ftnlen)70);
    s_copy(ref, "TRANSGALCTIC", (ftnlen)32, (ftnlen)12);
    spkgps_(&c_n10, &et, ref, &c__399, state, &lt, (ftnlen)32);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAME)", ok, (ftnlen)19);
    tcase_("Check that we get reasonable unrecognized frame diagnostics subc"
	    "ase 2.", (ftnlen)70);
    s_copy(ref, " ", (ftnlen)32, (ftnlen)1);
    spkgps_(&c_n10, &et, ref, &c__399, state, &lt, (ftnlen)32);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAME)", ok, (ftnlen)19);
    tcase_("Check that we get reasonable unrecognized frame diagnostics subc"
	    "ase 3.", (ftnlen)70);
    s_copy(ref, "MY\tFRAME", (ftnlen)32, (ftnlen)8);
    spkgps_(&c_n10, &et, ref, &c__399, state, &lt, (ftnlen)32);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAME)", ok, (ftnlen)19);
    t_success__(ok);
    return 0;
} /* f_spkgpx__ */

