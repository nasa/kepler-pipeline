/* f_etcal.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b33 = 0.;

/* $Procedure      F_ETCAL ( Family of tests for ETCAL ) */
/* Subroutine */ int f_etcal__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__, j;
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen), tcase_(
	    char *, ftnlen), repmi_(char *, char *, integer *, char *, ftnlen,
	     ftnlen, ftnlen);
    char title[48];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[48];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal et;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen);
    char string[48];
    doublereal et2;
    extern doublereal j2000_(void), spd_(void);

/* $ Abstract */

/*     This subroutine checks a number simple inputs to ETCAL */
/*     to make sure that values returned are correct. */

/*     Note that since there are no calls to SIGERR in ETCAL */
/*     there will never be any exceptions. We don't check for any. */

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
    topen_("F_ETCAL", (ftnlen)7);
    tcase_("Times out of range --- too big ", (ftnlen)31);
    et = 1e17;
    etcal_(&et, string, (ftnlen)48);
    chcksc_("STRING", string, "=", "Epoch after ", ok, (ftnlen)6, (ftnlen)12, 
	    (ftnlen)1, (ftnlen)12);
    tcase_("Times out of range --- too small ", (ftnlen)33);
    et = -1e17;
    etcal_(&et, string, (ftnlen)48);
    chcksc_("STRING", string, "=", "Epoch before", ok, (ftnlen)6, (ftnlen)12, 
	    (ftnlen)1, (ftnlen)12);
    tcase_("Zero point of the Julian Date Scale", (ftnlen)35);
    et = -j2000_() * spd_();
    etcal_(&et, string, (ftnlen)48);
    chcksc_("STRING", string, "=", "4714 B.C. NOV 24 12:00:00.000", ok, (
	    ftnlen)6, (ftnlen)48, (ftnlen)1, (ftnlen)29);
    tcase_("From a string to ET and back ", (ftnlen)29);
    tparse_("1993 JAN 12, 13:12:28.999", &et, error, (ftnlen)25, (ftnlen)48);
    etcal_(&et, string, (ftnlen)48);
    chcksc_("STRING", string, "=", "1993 JAN 12 13:12:28.999", ok, (ftnlen)6, 
	    (ftnlen)48, (ftnlen)1, (ftnlen)24);
    tcase_("From a string to ET and back ", (ftnlen)29);
    tparse_("893 JAN 12, 13:12:28.999", &et, error, (ftnlen)24, (ftnlen)48);
    etcal_(&et, string, (ftnlen)48);
    chcksc_("STRING", string, "=", "893 A.D. JAN 12 13:12:28.999", ok, (
	    ftnlen)6, (ftnlen)48, (ftnlen)1, (ftnlen)28);

/*     In this case we loop over a large collection of ET values and */
/*     make sure that TPARSE reproduces the ET output from ETCAL. */

    et = -1e8;
    for (i__ = 1; i__ <= 100; ++i__) {
	s_copy(title, "TPARSE - ETCAL Compatibility #", (ftnlen)48, (ftnlen)
		30);
	j = i__;
	repmi_(title, "#", &j, title, (ftnlen)48, (ftnlen)1, (ftnlen)48);
	tcase_(title, (ftnlen)48);
	et += 2e6;
	s_copy(error, " ", (ftnlen)48, (ftnlen)1);
	etcal_(&et, string, (ftnlen)48);
	tparse_(string, &et2, error, (ftnlen)48, (ftnlen)48);
	chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)48, (ftnlen)
		1, (ftnlen)1);
	chcksd_("ET", &et, "=", &et2, &c_b33, ok, (ftnlen)2, (ftnlen)1);
    }
    t_success__(ok);
    return 0;
} /* f_etcal__ */

