/* f_ltime.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__399 = 399;
static integer c__499 = 499;
static integer c__599 = 599;
static logical c_false = FALSE_;
static doublereal c_b25 = 1e-12;
static doublereal c_b28 = 1e-13;

/* $Procedure      F_LTIME ( Family of light time tests ) */
/* Subroutine */ int f_ltime__(logical *ok)
{
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal elaps;
    extern /* Subroutine */ int ltime_(doublereal *, integer *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen);
    doublereal state[6], expet;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    extern /* Subroutine */ int spkez_(integer *, doublereal *, char *, char *
	    , integer *, doublereal *, doublereal *, ftnlen, ftnlen), 
	    t_success__(logical *);
    doublereal expet2, et;
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     kilfil_(char *, ftnlen), spkuef_(integer *), tparse_(char *, 
	    doublereal *, char *, ftnlen, ftnlen);
    doublereal et2;
    extern /* Subroutine */ int tstspk_(char *, logical *, integer *, ftnlen);

/* $ Abstract */

/*     This routine tests the routine LTIME to make sure that it */
/*     gives results compatible with SPKEZ. */

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

/*     Test Utility Functions */

/*     None. */


/*     SPICELIB Functions */



/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_LTIME", (ftnlen)7);
    tstspk_("test.bsp", &c_true, &handle, (ftnlen)8);
    tcase_("Test the advertised exception", (ftnlen)29);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    ltime_(&et, &c__399, "TO", &c__499, &et2, &elaps, (ftnlen)2);
    chckxc_(&c_true, "SPICE(BADDIRECTION)", ok, (ftnlen)19);
    tcase_("Check to make sure downlink light time matches the light time re"
	    "turned by SPKEZ when the option 'CN' is used in SPKEZ. ", (ftnlen)
	    119);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    ltime_(&et, &c__399, "<-", &c__599, &et2, &elaps, (ftnlen)2);
    spkez_(&c__599, &et, "J2000", "CN", &c__399, state, &lt, (ftnlen)5, (
	    ftnlen)2);
    expet2 = et - lt;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("ELAPS", &elaps, "~", &lt, &c_b25, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("ET2", &et2, "~/", &expet2, &c_b28, ok, (ftnlen)3, (ftnlen)2);
    tcase_("Check to make sure that the uplink time is compatible with the d"
	    "own link time. ", (ftnlen)79);
    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    ltime_(&et, &c__399, "->", &c__599, &et2, &lt, (ftnlen)2);
    ltime_(&et2, &c__599, "<-", &c__399, &expet, &elaps, (ftnlen)2);
    expet2 = et + lt;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("ET2", &et2, "~/", &expet2, &c_b28, ok, (ftnlen)3, (ftnlen)2);
    chcksd_("ELAPS", &elaps, "~/", &lt, &c_b28, ok, (ftnlen)5, (ftnlen)2);
    chcksd_("ET", &et, "~/", &expet, &c_b28, ok, (ftnlen)2, (ftnlen)2);

/*     That's all folks. */

    spkuef_(&handle);
    kilfil_("test.bsp", (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_ltime__ */

