/* f_et2utc.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__3 = 3;
static integer c__5 = 5;
static integer c__7 = 7;

/* $Procedure      F_ET2UTC ( Family of tests for ET2UTC) */
/* Subroutine */ int f_et2utc__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer prec[6];
    logical pass;
    char estr[60*6];
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    char error[80];
    extern /* Subroutine */ int t_success__(logical *), et2utc_(doublereal *, 
	    char *, integer *, char *, ftnlen, ftnlen), utc2et_(char *, 
	    doublereal *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    doublereal et;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen);
    char kernel[80*23];
    integer nlines;
    extern /* Subroutine */ int clpool_(void);
    char pictur[60];
    extern /* Subroutine */ int tpictr_(char *, char *, logical *, char *, 
	    ftnlen, ftnlen, ftnlen), tstmsg_(char *, char *, ftnlen, ftnlen), 
	    timout_(doublereal *, char *, char *, ftnlen, ftnlen), tstmsi_(
	    integer *);
    char utcstr[60*6];
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    char fmt[4*6];

/* $ Abstract */

/*     This routine performs a number of tests of the SPICELIB */
/*     routine ET2UTC */
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


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_ET2UTC", (ftnlen)8);

/*     Set up the leapseconds kernel we'll be needing. */

    begdat_(ch__1, (ftnlen)32);
    s_copy(kernel, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(kernel + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(kernel + 160, "DELTET/DELTA_T_A       =   32.184", (ftnlen)80, (
	    ftnlen)33);
    s_copy(kernel + 240, "DELTET/K               =    1.657D-3", (ftnlen)80, (
	    ftnlen)36);
    s_copy(kernel + 320, "DELTET/EB              =    1.671D-2", (ftnlen)80, (
	    ftnlen)36);
    s_copy(kernel + 400, "DELTET/M               = (  6.239996D0   1.9909687"
	    "1D-7 )", (ftnlen)80, (ftnlen)56);
    s_copy(kernel + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(kernel + 560, "DELTET/DELTA_AT        = ( 10,   @1972-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 640, "                           11,   @1972-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 720, "                           12,   @1973-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 800, "                           13,   @1974-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 880, "                           14,   @1975-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 960, "                           15,   @1976-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1040, "                           16,   @1977-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1120, "                           17,   @1978-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1200, "                           18,   @1979-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1280, "                           19,   @1980-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1360, "                           20,   @1981-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1440, "                           21,   @1982-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1520, "                           22,   @1983-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1600, "                           23,   @1985-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1680, "                           24,   @1988-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(kernel + 1760, "                           25,   @1990-JAN-1 )", (
	    ftnlen)80, (ftnlen)46);
    nlines = 23;
    clpool_();
    tsttxt_("testleap.ker", kernel, &nlines, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)80);
    tcase_("Test that the advertised conversion in the header of ET2UTC beha"
	    "ves as predicted. ", (ftnlen)82);
    et = -527644192.5403653;
    s_copy(estr, "1983 APR 13 12:09:14", (ftnlen)60, (ftnlen)20);
    s_copy(estr + 60, "1983 APR 13 12:09:14.274", (ftnlen)60, (ftnlen)24);
    s_copy(estr + 120, "1983-103 // 12:09:14.27400", (ftnlen)60, (ftnlen)26);
    s_copy(estr + 180, "JD 2445438.0064152", (ftnlen)60, (ftnlen)18);
    s_copy(estr + 240, "1983-103T12:09:14.274", (ftnlen)60, (ftnlen)21);
    s_copy(estr + 300, "1983-04-13T12:09:14.274", (ftnlen)60, (ftnlen)23);
    et2utc_(&et, "C", &c__0, utcstr, (ftnlen)1, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et2utc_(&et, "C", &c__3, utcstr + 60, (ftnlen)1, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et2utc_(&et, "D", &c__5, utcstr + 120, (ftnlen)1, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et2utc_(&et, "J", &c__7, utcstr + 180, (ftnlen)1, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et2utc_(&et, "ISOD", &c__3, utcstr + 240, (ftnlen)4, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et2utc_(&et, "ISOC", &c__3, utcstr + 300, (ftnlen)4, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("UTCSTR(1)", utcstr, "=", estr, ok, (ftnlen)9, (ftnlen)60, (
	    ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(2)", utcstr + 60, "=", estr + 60, ok, (ftnlen)9, (ftnlen)
	    60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(3)", utcstr + 120, "=", estr + 120, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(4)", utcstr + 180, "=", estr + 180, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(5)", utcstr + 240, "=", estr + 240, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(6)", utcstr + 300, "=", estr + 300, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    tcase_("Use the time formatting routine TIMOUT together with the utility"
	    " TPICTR to see that we get consistent strings. ", (ftnlen)111);
    for (i__ = 1; i__ <= 6; ++i__) {
	tstmsg_("#", "Test Case 2, Subcase #.", (ftnlen)1, (ftnlen)23);
	tstmsi_(&i__);
	tpictr_(estr + ((i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge(
		"estr", i__1, "f_et2utc__", (ftnlen)182)) * 60, pictur, &pass,
		 error, (ftnlen)60, (ftnlen)60, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("PASS", &pass, &c_true, ok, (ftnlen)4);
	timout_(&et, pictur, utcstr + ((i__1 = i__ - 1) < 6 && 0 <= i__1 ? 
		i__1 : s_rnge("utcstr", i__1, "f_et2utc__", (ftnlen)186)) * 
		60, (ftnlen)60, (ftnlen)60);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    chcksc_("UTCSTR(1)", utcstr, "=", estr, ok, (ftnlen)9, (ftnlen)60, (
	    ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(2)", utcstr + 60, "=", estr + 60, ok, (ftnlen)9, (ftnlen)
	    60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(3)", utcstr + 120, "=", estr + 120, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(4)", utcstr + 180, "=", estr + 180, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(5)", utcstr + 240, "=", estr + 240, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(6)", utcstr + 300, "=", estr + 300, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    tcase_("Test the invertability of the call UTC2ET.", (ftnlen)42);
    s_copy(estr, "JD 2451712.2829282      ", (ftnlen)60, (ftnlen)24);
    s_copy(estr + 60, "1987 MAR 12 19:28:28.28729  ", (ftnlen)60, (ftnlen)28);
    s_copy(estr + 120, "1989 DEC 31 23:59:60.18291  ", (ftnlen)60, (ftnlen)28)
	    ;
    s_copy(estr + 180, "1990-001 // 00:00:00.1728    ", (ftnlen)60, (ftnlen)
	    29);
    s_copy(estr + 240, "1987-03-18T17:28:28.182        ", (ftnlen)60, (ftnlen)
	    31);
    s_copy(estr + 300, "1986-239T12:29:28.287        ", (ftnlen)60, (ftnlen)
	    29);
    s_copy(fmt, "J", (ftnlen)4, (ftnlen)1);
    s_copy(fmt + 4, "C", (ftnlen)4, (ftnlen)1);
    s_copy(fmt + 8, "C", (ftnlen)4, (ftnlen)1);
    s_copy(fmt + 12, "D", (ftnlen)4, (ftnlen)1);
    s_copy(fmt + 16, "ISOC", (ftnlen)4, (ftnlen)4);
    s_copy(fmt + 20, "ISOD", (ftnlen)4, (ftnlen)4);
    prec[0] = 7;
    prec[1] = 5;
    prec[2] = 5;
    prec[3] = 4;
    prec[4] = 3;
    prec[5] = 3;
    for (i__ = 1; i__ <= 6; ++i__) {
	tstmsg_("#", "Test Case 3, Subcase #.", (ftnlen)1, (ftnlen)23);
	tstmsi_(&i__);
	utc2et_(estr + ((i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge(
		"estr", i__1, "f_et2utc__", (ftnlen)233)) * 60, &et, (ftnlen)
		60);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	et2utc_(&et, fmt + (((i__1 = i__ - 1) < 6 && 0 <= i__1 ? i__1 : 
		s_rnge("fmt", i__1, "f_et2utc__", (ftnlen)236)) << 2), &prec[(
		i__2 = i__ - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("prec", i__2,
		 "f_et2utc__", (ftnlen)236)], utcstr + ((i__3 = i__ - 1) < 6 
		&& 0 <= i__3 ? i__3 : s_rnge("utcstr", i__3, "f_et2utc__", (
		ftnlen)236)) * 60, (ftnlen)4, (ftnlen)60);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    chcksc_("UTCSTR(1)", utcstr, "=", estr, ok, (ftnlen)9, (ftnlen)60, (
	    ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(2)", utcstr + 60, "=", estr + 60, ok, (ftnlen)9, (ftnlen)
	    60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(3)", utcstr + 120, "=", estr + 120, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(4)", utcstr + 180, "=", estr + 180, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(5)", utcstr + 240, "=", estr + 240, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    chcksc_("UTCSTR(6)", utcstr + 300, "=", estr + 300, ok, (ftnlen)9, (
	    ftnlen)60, (ftnlen)1, (ftnlen)60);
    t_success__(ok);
    return 0;
} /* f_et2utc__ */

