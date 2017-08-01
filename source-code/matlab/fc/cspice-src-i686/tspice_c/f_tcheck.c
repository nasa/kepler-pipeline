/* f_tcheck.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;

/* $Procedure      F_TCHECK ( Test the routine TCHECK ) */
/* Subroutine */ int f_tcheck__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer year;
    doublereal tvec[6];
    logical mods, pass;
    char type__[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *, 
	    ftnlen);
    char error[240], yesno[3];
    extern /* Subroutine */ int t_success__(logical *);
    integer hr;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), tchckd_(char *, 
	    ftnlen), tcheck_(doublereal *, char *, logical *, char *, logical 
	    *, char *, ftnlen, ftnlen, ftnlen), chckxc_(logical *, char *, 
	    logical *, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), tparch_(char *, ftnlen);
    char messge[240], modify[5*5];
    extern /* Subroutine */ int tstlog_(char *, logical *, ftnlen);
    integer sec, day, min__, mon;

/* $ Abstract */

/*     Test the routine TCHECK and its associated entry points. */
/*     TPARCK and */
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

    topen_("F_TCHECK", (ftnlen)8);
    tcase_("Make sure we can set and get the checking status. ", (ftnlen)50);
    tparch_("NO", (ftnlen)2);
    tchckd_(yesno, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("YESNO", yesno, "=", "NO", ok, (ftnlen)5, (ftnlen)3, (ftnlen)1, (
	    ftnlen)2);
    tparch_("yes", (ftnlen)3);
    tchckd_(yesno, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("YESNO", yesno, "=", "YES", ok, (ftnlen)5, (ftnlen)3, (ftnlen)1, (
	    ftnlen)3);
    tparch_("NO", (ftnlen)2);
    tchckd_(yesno, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("YESNO", yesno, "=", "NO", ok, (ftnlen)5, (ftnlen)3, (ftnlen)1, (
	    ftnlen)2);
    tcase_("With checking turned off make sure that no checks are performed. "
	    , (ftnlen)65);
    tvec[0] = 1.993e12;
    tvec[1] = 23.;
    tvec[2] = 1024.;
    tvec[3] = -2.;
    tvec[4] = 127.;
    tvec[5] = -12.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Checking on:  JAN -1, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 1.;
    tvec[2] = -1.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  JAN 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 1.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Feb 30, 1996 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1996.;
    tvec[1] = 2.;
    tvec[2] = 30.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Feb 29, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 2.;
    tvec[2] = 29.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Mar 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 3.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Apr 31, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 4.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  May 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 5.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jun 31, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 6.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Aug 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 8.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Sep 31, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 9.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Oct 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 10.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Nov 31, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 11.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Dec 32, 1995 12:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 12.;
    tvec[2] = 32.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 24:13:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 24.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 12:60:29", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 60.;
    tvec[5] = 29.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 12:13:60", (ftnlen)35);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 60.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 13:13:29 A.M.", (ftnlen)40);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 13.;
    tvec[4] = 13.;
    tvec[5] = 29.;
    mods = TRUE_;
    s_copy(modify + 15, "A.M.", (ftnlen)5, (ftnlen)4);
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  \"Jul.3\" 1, 1995 00:00:00", (ftnlen)38);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.3;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31.3, 1995 12:13:59", (ftnlen)37);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.3;
    tvec[3] = 12.;
    tvec[4] = 13.;
    tvec[5] = 59.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 12.3:13:59", (ftnlen)37);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 12.3;
    tvec[4] = 13.;
    tvec[5] = 59.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jul 31, 1995 12:13.3:59", (ftnlen)37);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 7.;
    tvec[2] = 31.;
    tvec[3] = 12.;
    tvec[4] = 13.3;
    tvec[5] = 59.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  Jan  1, 1995.2 00:00:00", (ftnlen)37);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.2;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    mods = FALSE_;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Checking on:  1995-366// 00:00:00", (ftnlen)33);
    tparch_("YES", (ftnlen)3);
    tvec[0] = 1995.;
    tvec[1] = 366.;
    tvec[2] = 0.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    mods = FALSE_;
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_false, ok, (ftnlen)4);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("With checking turned on, make sure that normal items are not rej"
	    "ected. (YMD) ", (ftnlen)77);
    tparch_("YES", (ftnlen)3);
    mods = FALSE_;
    s_copy(type__, "YMD", (ftnlen)3, (ftnlen)3);
    sec = 0;
    min__ = 0;

/*        Here's the deal for every hour of every day in 1995 and */
/*        1996 we generate a time vector that should be legal */
/*        and then check it. */

    for (year = 1995; year <= 1996; ++year) {
	tvec[0] = (doublereal) year;
	for (mon = 1; mon <= 12; ++mon) {
	    tvec[1] = (doublereal) mon;
	    for (day = 1; day <= 31; ++day) {
		if (mon == 2 && year == 1996 && day > 29) {
		    tvec[2] = 29.;
		} else if (mon == 2 && day > 28) {
		    tvec[2] = 28.;
		} else if (day == 31 && (mon == 4 || mon == 6 || mon == 9 || 
			mon == 11)) {
		    tvec[2] = 30.;
		} else {
		    tvec[2] = (doublereal) day;
		}
		for (hr = 0; hr <= 23; ++hr) {
		    min__ += 23;
		    if (min__ >= 60) {
			min__ += -60;
		    }
		    sec += 17;
		    if (sec >= 60) {
			sec += -60;
		    }
		    tvec[3] = (doublereal) hr;
		    tvec[4] = (doublereal) min__;
		    tvec[5] = (doublereal) sec;
		    tcheck_(tvec, type__, &mods, modify, &pass, error, (
			    ftnlen)3, (ftnlen)5, (ftnlen)240);
		    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
		    if (! (*ok)) {
			s_copy(messge, "Year #, Month #, Day #, Hour #, Minu"
				"te #, Second #. ", (ftnlen)240, (ftnlen)52);
			repmi_(messge, "#", &year, messge, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(messge, "#", &mon, messge, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(messge, "#", &day, messge, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(messge, "#", &hr, messge, (ftnlen)240, (ftnlen)
				1, (ftnlen)240);
			repmi_(messge, "#", &min__, messge, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			repmi_(messge, "#", &sec, messge, (ftnlen)240, (
				ftnlen)1, (ftnlen)240);
			tstlog_(messge, &c_true, (ftnlen)240);
			chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (
				ftnlen)240, (ftnlen)1, (ftnlen)1);
		    }
		}
	    }
	}
    }
    tcase_("With checking turned on, make sure that normal items are not rej"
	    "ected. (YD) ", (ftnlen)76);
    tparch_("YES", (ftnlen)3);
    mods = FALSE_;
    s_copy(type__, "YD", (ftnlen)3, (ftnlen)2);
    for (year = 1995; year <= 1996; ++year) {
	tvec[0] = (doublereal) year;
	for (day = 1; day <= 366; ++day) {
	    if (day == 366 && year == 1995) {
		tvec[1] = 365.;
	    } else {
		tvec[1] = (doublereal) day;
	    }
	    for (hr = 0; hr <= 23; ++hr) {
		min__ += 23;
		if (min__ >= 60) {
		    min__ += -60;
		}
		sec += 17;
		if (sec >= 60) {
		    sec += -60;
		}
		tvec[2] = (doublereal) hr;
		tvec[3] = (doublereal) min__;
		tvec[4] = (doublereal) sec;
		tcheck_(tvec, type__, &mods, modify, &pass, error, (ftnlen)3, 
			(ftnlen)5, (ftnlen)240);
		chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
		if (! (*ok)) {
		    s_copy(messge, "Year #, Day #, Hour #, Minute #, Second "
			    "#. ", (ftnlen)240, (ftnlen)43);
		    repmi_(messge, "#", &year, messge, (ftnlen)240, (ftnlen)1,
			     (ftnlen)240);
		    repmi_(messge, "#", &day, messge, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)240);
		    repmi_(messge, "#", &hr, messge, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    repmi_(messge, "#", &min__, messge, (ftnlen)240, (ftnlen)
			    1, (ftnlen)240);
		    repmi_(messge, "#", &sec, messge, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)240);
		    tstlog_(messge, &c_true, (ftnlen)240);
		    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)
			    240, (ftnlen)1, (ftnlen)1);
		}
	    }
	}
    }
    tcase_("Make sure that an epoch during a potential leapsecond is not reg"
	    "arded as erroneous. ", (ftnlen)84);
    tvec[0] = 1995.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995 DEC 31 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1995.;
    tvec[1] = 6.;
    tvec[2] = 30.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995 JUN 30 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1996.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996 DEC 31 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1996.;
    tvec[1] = 6.;
    tvec[2] = 30.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996 JUN 30 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1995.;
    tvec[1] = 365.;
    tvec[2] = 23.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-365 // 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1996.;
    tvec[1] = 366.;
    tvec[2] = 23.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996-366 // 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1995.;
    tvec[1] = 181.;
    tvec[2] = 23.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-182 // 23:59:60.1", &c_true, (ftnlen)22);
    }
    tvec[0] = 1996.;
    tvec[1] = 182.;
    tvec[2] = 23.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-183 // 23:59:60.1", &c_true, (ftnlen)22);
    }
    tcase_("Make sure that an epoch during a potential leapsecond is not reg"
	    "arded as erroneous. ( 11:00 P.M. subcase.", (ftnlen)105);
    tvec[0] = 1995.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 11.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    mods = TRUE_;
    s_copy(modify + 15, "P.M.", (ftnlen)5, (ftnlen)4);
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995 DEC 31 P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1995.;
    tvec[1] = 6.;
    tvec[2] = 30.;
    tvec[3] = 11.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995 JUN 30 P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1996.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 11.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996 DEC 31 P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1996.;
    tvec[1] = 6.;
    tvec[2] = 30.;
    tvec[3] = 11.;
    tvec[4] = 59.;
    tvec[5] = 60.1;
    tcheck_(tvec, "YMD", &mods, modify, &pass, error, (ftnlen)3, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996 JUN 30 P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1995.;
    tvec[1] = 365.;
    tvec[2] = 11.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-365 // P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1996.;
    tvec[1] = 366.;
    tvec[2] = 11.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1996-366 // P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1995.;
    tvec[1] = 181.;
    tvec[2] = 11.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-182 // P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tvec[0] = 1996.;
    tvec[1] = 182.;
    tvec[2] = 11.;
    tvec[3] = 59.;
    tvec[4] = 60.1;
    tparch_("YES", (ftnlen)3);
    tcheck_(tvec, "YD", &mods, modify, &pass, error, (ftnlen)2, (ftnlen)5, (
	    ftnlen)240);
    chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    if (! (*ok)) {
	tstlog_("1995-183 // P.M. 11:59:60.1", &c_true, (ftnlen)27);
    }
    tparch_("NO", (ftnlen)2);
    t_success__(ok);
    return 0;
} /* f_tcheck__ */

