/* f_texpyr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__2025 = 2025;
static integer c__1969 = 1969;

/* $Procedure      F_TEXPYR ( Family of tests for TEXPYR ) */
/* Subroutine */ int f_texpyr__(logical *ok)
{
    integer year, i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    integer expyr;
    extern /* Subroutine */ int t_success__(logical *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), tsetyr_(integer 
	    *), texpyr_(integer *);

/* $ Abstract */

/*     This routine tests the routine TEXPYR and its companion */
/*     entry point TSETYR. */

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

/* $ Version */

/* -    TSPICE Version 2.0.0, 13-DEC-2001 (FST) */

/*        Updated this routine to restore and exercise the */
/*        default value of 1969 for TSETYR. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_TEXPYR", (ftnlen)8);
    tcase_("Make sure that in the default case two digit years range are map"
	    "ped to the interval from 1969 to 2068.", (ftnlen)102);
    for (i__ = 0; i__ <= 99; ++i__) {
	year = i__;
	texpyr_(&year);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (i__ <= 68) {
	    expyr = i__ + 2000;
	} else {
	    expyr = i__ + 1900;
	}
	chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    tcase_("Make sure that when we set the lower bound for the century that "
	    "all two digit years are expanded appropriately. ", (ftnlen)112);
    tsetyr_(&c__2025);
    for (i__ = 0; i__ <= 99; ++i__) {
	year = i__;
	texpyr_(&year);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (i__ <= 24) {
	    expyr = i__ + 2100;
	} else {
	    expyr = i__ + 2000;
	}
	chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }

/*        Reset the lowerbound and re-do the first set of tests. */

    tsetyr_(&c__1969);
    for (i__ = 0; i__ <= 99; ++i__) {
	year = i__;
	texpyr_(&year);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (i__ <= 68) {
	    expyr = i__ + 2000;
	} else {
	    expyr = i__ + 1900;
	}
	chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    tcase_("Make sure that years outside the inclusive range from 0 to 99 ar"
	    "e not altered by TEXPYR. ", (ftnlen)89);
    year = 1928;
    expyr = 1928;
    texpyr_(&year);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    year = 100;
    expyr = 100;
    texpyr_(&year);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    year = -1;
    expyr = -1;
    texpyr_(&year);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &expyr, &c__0, ok, (ftnlen)4, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_texpyr__ */

