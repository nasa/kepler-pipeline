/* f_timout.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__1 = 1;

/* $Procedure      F_TIMOUT ( Family of tests for TIMOUT ) */
/* Subroutine */ int f_timout__(logical *ok)
{
    /* System generated locals */
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char case__[80];
    doublereal hoff, moff;
    integer year;
    doublereal tvec[10];
    logical mods;
    integer last;
    char type__[32];
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen), tcase_(
	    char *, ftnlen);
    integer ntvec;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[240];
    extern /* Subroutine */ int ljust_(char *, char *, ftnlen, ftnlen), 
	    t_success__(logical *);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen);
    char goodkr[80*23];
    logical succes;
    char modify[32*5];
    integer nlines;
    logical yabbrv;
    extern /* Subroutine */ int clpool_(void), prefix_(char *, integer *, 
	    char *, ftnlen, ftnlen);
    char pictur[80], string[80];
    extern /* Subroutine */ int ttrans_(char *, char *, doublereal *, ftnlen, 
	    ftnlen), tpartv_(char *, doublereal *, integer *, char *, char *, 
	    logical *, logical *, logical *, char *, char *, ftnlen, ftnlen, 
	    ftnlen, ftnlen, ftnlen), timout_(doublereal *, char *, char *, 
	    ftnlen, ftnlen), texpyr_(integer *), tsttxt_(char *, char *, 
	    integer *, logical *, logical *, ftnlen, ftnlen);
    extern doublereal j2000_(void), j1950_(void), spd_(void);
    extern /* Subroutine */ int zzutcpm_(char *, integer *, doublereal *, 
	    doublereal *, integer *, logical *, ftnlen);

/* $ Abstract */

/*     This routine runs a number of test formats through */
/*     the routine TIMOUT to compare expected output against */
/*     actual outputs */
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


/*     Local parameters */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_TIMOUT", (ftnlen)8);

/*     The next sequence of test cases use TPARTV to parse a */
/*     string and then call TIMOUT to see if we can duplicate */
/*     the the input to TPARTV. */

/*     We will need a leapsecond kernel to do this. */

    begdat_(ch__1, (ftnlen)32);
    s_copy(goodkr, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(goodkr + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(goodkr + 160, "DELTET/DELTA_T_A       =   32.184", (ftnlen)80, (
	    ftnlen)33);
    s_copy(goodkr + 240, "DELTET/K               =    1.657D-3", (ftnlen)80, (
	    ftnlen)36);
    s_copy(goodkr + 320, "DELTET/EB              =    1.671D-2", (ftnlen)80, (
	    ftnlen)36);
    s_copy(goodkr + 400, "DELTET/M               = (  6.239996D0   1.9909687"
	    "1D-7 )", (ftnlen)80, (ftnlen)56);
    s_copy(goodkr + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(goodkr + 560, "DELTET/DELTA_AT        = ( 10,   @1972-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 640, "                           11,   @1972-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 720, "                           12,   @1973-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 800, "                           13,   @1974-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 880, "                           14,   @1975-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 960, "                           15,   @1976-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1040, "                           16,   @1977-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1120, "                           17,   @1978-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1200, "                           18,   @1979-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1280, "                           19,   @1980-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1360, "                           20,   @1981-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1440, "                           21,   @1982-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1520, "                           22,   @1983-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1600, "                           23,   @1985-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1680, "                           24,   @1988-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(goodkr + 1760, "                           25,   @1990-JAN-1 )", (
	    ftnlen)80, (ftnlen)46);
    nlines = 23;
    clpool_();
    tsttxt_("testleap.ker", goodkr, &nlines, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)80);
    s_copy(case__, "1996 JAN 12 13:00:15.0 ", (ftnlen)80, (ftnlen)23);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "1996 JAN 12 02:00:15.0 A.M.", (ftnlen)80, (ftnlen)27);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "13 APR 1996 11:12:11.0", (ftnlen)80, (ftnlen)22);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "1996-122/ 13:00:15.0 ", (ftnlen)80, (ftnlen)21);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "1996-03-17T15:12:18.9 ", (ftnlen)80, (ftnlen)22);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "Mon Jun 17 10:45:26 PDT 1996", (ftnlen)80, (ftnlen)28);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    prefix_("::", &c__0, modify + 64, (ftnlen)2, (ftnlen)32);
    zzutcpm_(modify + 64, &c__1, &hoff, &moff, &last, &succes, (ftnlen)32);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    tvec[3] -= hoff;
    tvec[4] -= moff;
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "Wednesday June 19, 01:12:29.19 P.M. 1996", (ftnlen)80, (
	    ftnlen)40);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    tvec[3] += 12.;
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "Weekday Month DD, AP:MN:SC.## AMPM YYYY ::RND", (ftnlen)
	    80, (ftnlen)45);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "Wednesday June 19, 01:12:29.19 1996 (From Gregorian to J"
	    "ulian)", (ftnlen)80, (ftnlen)62);
    tcase_(case__, (ftnlen)80);
    s_copy(case__, "Wednesday June 19, 01:12:29.19 1996", (ftnlen)80, (ftnlen)
	    35);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    s_copy(case__, "Wednesday June 06, 01:12:29.19 1996 (Julian)", (ftnlen)80,
	     (ftnlen)44);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "Weekday Month DD, HR:MN:SC.## YYYY (Julian)::RND::JCAL", (
	    ftnlen)80, (ftnlen)54);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "Mon Jun 17 10:45:26 PDT '96", (ftnlen)80, (ftnlen)27);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    year = (integer) tvec[0];
    texpyr_(&year);
    tvec[0] = (doublereal) year;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    prefix_("::", &c__0, modify + 64, (ftnlen)2, (ftnlen)32);
    zzutcpm_(modify + 64, &c__1, &hoff, &moff, &last, &succes, (ftnlen)32);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    tvec[3] -= hoff;
    tvec[4] -= moff;
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Check to make sure time zones have their leapseconds at the righ"
	    "t time. ", (ftnlen)72);
    s_copy(case__, "1989 DEC 31 23:59:60.5 ", (ftnlen)80, (ftnlen)23);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "YYYY MON DD HR:MN:SC.# PDT ::RND::UTC-7", (ftnlen)80, (
	    ftnlen)39);
    s_copy(case__, "1989 DEC 31 16:59:60.5 PDT", (ftnlen)80, (ftnlen)26);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "Oct 12, 1492 A.D.", (ftnlen)80, (ftnlen)17);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "Mon DD, YYYY ERA ::JCAL ", (ftnlen)80, (ftnlen)24);
    s_copy(case__, "Oct 03, 1492 A.D.", (ftnlen)80, (ftnlen)17);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "1995 MAY 13 12:28:29.281 TDB ", (ftnlen)80, (ftnlen)29);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "YYYY MON DD HR:MN:SC.### ::TDB::TRNC", (ftnlen)80, (
	    ftnlen)36);
    etcal_(tvec, case__, (ftnlen)80);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("-10000000.123 seconds past J2000.", (ftnlen)33);
    tvec[0] = -10000000.123;
    s_copy(case__, "  -10000000.123", (ftnlen)80, (ftnlen)15);
    s_copy(pictur, "SP2000.### ::RND::TDB", (ftnlen)80, (ftnlen)21);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "  123456789.123 ", (ftnlen)80, (ftnlen)16);
    tcase_("123456789.123 seconds past 1950", (ftnlen)31);
    tvec[0] = spd_() * (j1950_() - j2000_()) + 123456789.123;
    s_copy(pictur, "SP1950.### ::RND::TDB", (ftnlen)80, (ftnlen)21);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, " 321 B.C. MAR 15 12:00:00", (ftnlen)80, (ftnlen)25);
    tcase_("The ephemeris epoch of 321 B.C. MAR 15 12:00:00", (ftnlen)47);
    tvec[0] = -73205683200.;
    s_copy(pictur, "YYYY ERA MON DD HR:MN:SC ::TDB", (ftnlen)80, (ftnlen)30);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, " 321 B.C. MAR 15 12:00:00", (ftnlen)80, (ftnlen)25);
    tcase_("The ephemeris epoch of 321 B.C. MAR 15 12:00:00", (ftnlen)47);
    tvec[0] = -73205683200.;
    s_copy(pictur, "YYYY ERA MON DD HR:MN:SC ::TDB", (ftnlen)80, (ftnlen)30);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, " 321 B.C. MAR 15 12:00:00", (ftnlen)80, (ftnlen)25);
    tcase_("The ephemeris epoch of 321 B.C. MAR 15 12:00:00", (ftnlen)47);
    tvec[0] = -73205683200.;
    s_copy(pictur, "YYYY?ERA?MON DD HR:MN:SC ::TDB", (ftnlen)80, (ftnlen)30);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "1998 MAY 13 12:28:29.281 TDB ", (ftnlen)80, (ftnlen)29);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "YYYY?ERA?MON DD HR:MN:SC.### ::TDB::TRNC", (ftnlen)80, (
	    ftnlen)40);
    etcal_(tvec, case__, (ftnlen)80);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    s_copy(case__, "398 A.D. MAY 13 12:28:29.281 TDB ", (ftnlen)80, (ftnlen)
	    33);
    tcase_(case__, (ftnlen)80);
    tpartv_(case__, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_true, ok, (ftnlen)6);
    ttrans_(type__, "ET", tvec, (ftnlen)32, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(pictur, "YYYY?ERA?MON DD HR:MN:SC.### ::TDB::TRNC", (ftnlen)80, (
	    ftnlen)40);
    etcal_(tvec, case__, (ftnlen)80);
    timout_(tvec, pictur, string, (ftnlen)80, (ftnlen)80);
    ljust_(string, string, (ftnlen)80, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", case__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    t_success__(ok);
    return 0;
} /* f_timout__ */

