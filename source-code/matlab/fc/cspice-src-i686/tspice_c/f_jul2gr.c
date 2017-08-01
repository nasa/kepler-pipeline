/* f_jul2gr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__1582 = 1582;
static integer c__0 = 0;
static integer c__10 = 10;
static integer c__5 = 5;
static integer c__15 = 15;
static integer c__1752 = 1752;
static integer c__9 = 9;
static integer c__14 = 14;
static integer c__12 = 12;
static integer c__31 = 31;
static integer c__366 = 366;

/* $Procedure      F_JUL2GR ( Family of tests for Julian and Gregorian */
/* Subroutine */ int f_jul2gr__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    integer year, days, i__, j, k;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer leaps, month;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , gr2jul_(integer *, integer *, integer *, integer *), jul2gr_(
	    integer *, integer *, integer *, integer *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen);
    integer thismo, thisdy, thisyr, day, doy;

/* $ Abstract */

/*     This routine checks to make sure that the conversion between */
/*     the Julian and Gregorian Calendars is performed correctly */
/*     and consistently. */

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


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_JUL2GR", (ftnlen)8);
    tcase_("The Julian Date corresponding to October 15, 1582 should be Octo"
	    "ber 5, 1582 ", (ftnlen)76);
    year = 1582;
    month = 10;
    day = 15;
    gr2jul_(&year, &month, &day, &doy);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &c__1582, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("MONTH", &month, "=", &c__10, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("DAY", &day, "=", &c__5, &c__0, ok, (ftnlen)3, (ftnlen)1);
    tcase_("The Gregorian date corresponding to the Julian date October 5, 1"
	    "582 should be October 15, 1582 ", (ftnlen)95);
    year = 1582;
    month = 10;
    day = 5;
    jul2gr_(&year, &month, &day, &doy);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &c__1582, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("MONTH", &month, "=", &c__10, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("DAY", &day, "=", &c__15, &c__0, ok, (ftnlen)3, (ftnlen)1);
    tcase_("September 3, 1752 Julian, should be September 14, 1752 Gregorian "
	    , (ftnlen)65);
    year = 1752;
    month = 9;
    day = 3;
    jul2gr_(&year, &month, &day, &doy);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("YEAR", &year, "=", &c__1752, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("MONTH", &month, "=", &c__9, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("DAY", &day, "=", &c__14, &c__0, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Make sure that on centuries, the number of days in the year is 3"
	    "66 for each Julian Year. ", (ftnlen)89);
    for (i__ = 0; i__ <= 2000; i__ += 100) {
	year = i__;
	month = 12;
	day = 31;
	jul2gr_(&year, &month, &day, &doy);
	gr2jul_(&year, &month, &day, &doy);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("YEAR", &year, "=", &i__, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chcksi_("MONTH", &month, "=", &c__12, &c__0, ok, (ftnlen)5, (ftnlen)1)
		;
	chcksi_("DAY", &day, "=", &c__31, &c__0, ok, (ftnlen)3, (ftnlen)1);
	chcksi_("DOY", &doy, "=", &c__366, &c__0, ok, (ftnlen)3, (ftnlen)1);
    }
    tcase_("Make sure that the number of days on centuries is 366 only on th"
	    "ose centuries divisible by 400. ", (ftnlen)96);
    for (i__ = 0; i__ <= 2000; i__ += 100) {
	year = i__;
/* Computing MAX */
	i__1 = year / 400 * 400 + 1 - year;
	days = max(i__1,0) + 365;
	month = 12;
	day = 31;
	gr2jul_(&year, &month, &day, &doy);
	jul2gr_(&year, &month, &day, &doy);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("YEAR", &year, "=", &i__, &c__0, ok, (ftnlen)4, (ftnlen)1);
	chcksi_("MONTH", &month, "=", &c__12, &c__0, ok, (ftnlen)5, (ftnlen)1)
		;
	chcksi_("DAY", &day, "=", &c__31, &c__0, ok, (ftnlen)3, (ftnlen)1);
	chcksi_("DOY", &doy, "=", &days, &c__0, ok, (ftnlen)3, (ftnlen)1);
    }
    tcase_("Perform a large set of cases from Julian to Gregorian and back. ",
	     (ftnlen)64);
    for (i__ = 1904; i__ <= 1904; ++i__) {
	year = i__;
/* Computing MAX */
	i__1 = (year / 4 << 2) - year + 1;
	leaps = max(i__1,0);
	for (j = 1; j <= 12; ++j) {
	    month = j;
	    for (k = 1; k <= 31; ++k) {
		if (month == 2) {
/* Computing MIN */
		    i__1 = leaps + 28;
		    day = min(i__1,k);
		} else if (month == 4) {
		    day = min(30,k);
		} else if (month == 6) {
		    day = min(30,k);
		} else if (month == 9) {
		    day = min(30,k);
		} else if (month == 11) {
		    day = min(30,k);
		} else {
		    day = k;
		}
		thisyr = year;
		thismo = month;
		thisdy = day;
		jul2gr_(&year, &month, &day, &doy);
		gr2jul_(&year, &month, &day, &doy);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksi_("YEAR", &year, "=", &thisyr, &c__0, ok, (ftnlen)4, (
			ftnlen)1);
		chcksi_("MONTH", &month, "=", &thismo, &c__0, ok, (ftnlen)5, (
			ftnlen)1);
		chcksi_("DAY", &day, "=", &thisdy, &c__0, ok, (ftnlen)3, (
			ftnlen)1);
	    }
	}
    }
    tcase_("Perform a large set of cases from Gregorian to Julian and back. ",
	     (ftnlen)64);
    for (i__ = 1604; i__ <= 1604; ++i__) {
	year = i__;
/* Computing MAX */
	i__1 = (year / 4 << 2) - year + 1;
	leaps = max(i__1,0);
	for (j = 1; j <= 12; ++j) {
	    month = j;
	    for (k = 1; k <= 31; ++k) {
		if (month == 2) {
/* Computing MIN */
		    i__1 = leaps + 28;
		    day = min(i__1,k);
		} else if (month == 4) {
		    day = min(30,k);
		} else if (month == 6) {
		    day = min(30,k);
		} else if (month == 9) {
		    day = min(30,k);
		} else if (month == 11) {
		    day = min(30,k);
		} else {
		    day = k;
		}
		thisyr = year;
		thismo = month;
		thisdy = day;
		gr2jul_(&year, &month, &day, &doy);
		jul2gr_(&year, &month, &day, &doy);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksi_("YEAR", &year, "=", &thisyr, &c__0, ok, (ftnlen)4, (
			ftnlen)1);
		chcksi_("MONTH", &month, "=", &thismo, &c__0, ok, (ftnlen)5, (
			ftnlen)1);
		chcksi_("DAY", &day, "=", &thisdy, &c__0, ok, (ftnlen)3, (
			ftnlen)1);
	    }
	}
    }
    t_success__(ok);
    return 0;
} /* f_jul2gr__ */

