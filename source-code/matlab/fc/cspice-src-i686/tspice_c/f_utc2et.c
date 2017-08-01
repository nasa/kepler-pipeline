/* f_utc2et.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b78 = 1e-13;
static doublereal c_b83 = 1e-11;

/* $Procedure      F_UTC2ET ( A family of tests for UTC2ET ) */
/* Subroutine */ int f_utc2et__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    , t_success__(logical *), utc2et_(char *, doublereal *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    doublereal et;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    char kernel[80*23];
    extern /* Subroutine */ int tparch_(char *, ftnlen);
    integer nlines;
    doublereal expdet[22];
    extern /* Subroutine */ int clpool_(void);
    char tstrng[80*22];
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *), tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine uses a fixed leapseconds kernel (hard coded */
/*     in this routine and tests the routine UTC2ET against */
/*     fixed values */
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

    topen_("F_UTC2ET", (ftnlen)8);
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
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Check that an exception is generated if an A.M. or P.M. is speci"
	    "fied in the time string. ", (ftnlen)89);
    s_copy(tstrng, "1994 JAN 12 8:43 A.M.", (ftnlen)80, (ftnlen)21);
    utc2et_(tstrng, &et, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDTIMESTRING)", ok, (ftnlen)24);
    tcase_("Check that an exception is generated if a time zone is included "
	    "as part of the string. ", (ftnlen)87);
    s_copy(tstrng, "1994 JAN 12 8:43 PDT", (ftnlen)80, (ftnlen)20);
    utc2et_(tstrng, &et, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDTIMESTRING)", ok, (ftnlen)24);
    tcase_("Check that an exception is generated if a time system is include"
	    "d in the time string. ", (ftnlen)86);
    s_copy(tstrng, "1994 JAN 12 8:43 TDT", (ftnlen)80, (ftnlen)20);
    utc2et_(tstrng, &et, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDTIMESTRING)", ok, (ftnlen)24);
    tcase_("Make sure that when checking is enabled that an exception is gen"
	    "erated when a component of the time string is out of range. ", (
	    ftnlen)124);
    s_copy(tstrng, "1994 JAN 32 08:43:12", (ftnlen)80, (ftnlen)20);
    tparch_("YES", (ftnlen)3);
    utc2et_(tstrng, &et, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDTIMESTRING)", ok, (ftnlen)24);
    tcase_("Check UTC2ET against a collection of times for which the outcome"
	    " has been computed and hardcoded in advance. ", (ftnlen)109);
    s_copy(tstrng, " 1/9/1986 3:12:59.2", (ftnlen)80, (ftnlen)19);
    expdet[0] = -441103565.61583340168;
    s_copy(tstrng + 80, "9 JAN 1986 03:12:59.2", (ftnlen)80, (ftnlen)21);
    expdet[1] = -441103565.61583340168;
    s_copy(tstrng + 160, "1 9 1986 3:12:59.2", (ftnlen)80, (ftnlen)18);
    expdet[2] = -441103565.61583340168;
    s_copy(tstrng + 240, "9 JAN 1986 03:12:59.2", (ftnlen)80, (ftnlen)21);
    expdet[3] = -441103565.61583340168;
    s_copy(tstrng + 320, "2 jan 1991 3:00:12.2", (ftnlen)80, (ftnlen)20);
    expdet[4] = -283942730.6160448789597;
    s_copy(tstrng + 400, "2 JAN 1991 03:00:12.2", (ftnlen)80, (ftnlen)21);
    expdet[5] = -283942730.6160448789597;
    s_copy(tstrng + 480, "1991 MAR 10 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[6] = -278121542.8144892454147;
    s_copy(tstrng + 560, "10 MAR 1991 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[7] = -278121542.8144892454147;
    s_copy(tstrng + 640, "1 March 1975 3:00", (ftnlen)80, (ftnlen)17);
    expdet[8] = -783853153.8146169185638;
    s_copy(tstrng + 720, "1 MAR 1975 03:00:00", (ftnlen)80, (ftnlen)19);
    expdet[9] = -783853153.8146169185638;
    s_copy(tstrng + 800, "2010 October 29 3:58", (ftnlen)80, (ftnlen)20);
    expdet[10] = 341596737.1824791431427;
    s_copy(tstrng + 880, "29 OCT 2010 03:58:00", (ftnlen)80, (ftnlen)20);
    expdet[11] = 341596737.1824791431427;
    s_copy(tstrng + 960, "dec 31 86 12", (ftnlen)80, (ftnlen)12);
    expdet[12] = -410313544.8160908222198;
    s_copy(tstrng + 1040, "31 DEC 1986 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[13] = -410313544.8160908222198;
    s_copy(tstrng + 1120, "86-365 // 12:00", (ftnlen)80, (ftnlen)15);
    expdet[14] = -410313544.8160908222198;
    s_copy(tstrng + 1200, "31 DEC 1986 12:00:00", (ftnlen)80, (ftnlen)20);
    expdet[15] = -410313544.8160908222198;
    s_copy(tstrng + 1280, "JD 2451545.", (ftnlen)80, (ftnlen)11);
    expdet[16] = 57.1839272823238;
    s_copy(tstrng + 1360, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[17] = 57.1839272823238;
    s_copy(tstrng + 1440, "jd 2451545.", (ftnlen)80, (ftnlen)11);
    expdet[18] = 57.1839272823238;
    s_copy(tstrng + 1520, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[19] = 57.1839272823238;
    s_copy(tstrng + 1600, "JD2451545.", (ftnlen)80, (ftnlen)10);
    expdet[20] = 57.1839272823238;
    s_copy(tstrng + 1680, "1 JAN 2000 12:00:00", (ftnlen)80, (ftnlen)19);
    expdet[21] = 57.1839272823238;
    for (i__ = 1; i__ <= 22; ++i__) {
	tstmsg_("#", "Test subcase #.", (ftnlen)1, (ftnlen)15);
	tstmsi_(&i__);
	utc2et_(tstrng + ((i__1 = i__ - 1) < 22 && 0 <= i__1 ? i__1 : s_rnge(
		"tstrng", i__1, "f_utc2et__", (ftnlen)239)) * 80, &et, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (i__ < 17) {
	    chcksd_("ET", &et, "~/", &expdet[(i__1 = i__ - 1) < 22 && 0 <= 
		    i__1 ? i__1 : s_rnge("expdet", i__1, "f_utc2et__", (
		    ftnlen)242)], &c_b78, ok, (ftnlen)2, (ftnlen)2);
	} else {
	    chcksd_("ET", &et, "~/", &expdet[(i__1 = i__ - 1) < 22 && 0 <= 
		    i__1 ? i__1 : s_rnge("expdet", i__1, "f_utc2et__", (
		    ftnlen)244)], &c_b83, ok, (ftnlen)2, (ftnlen)2);
	}
    }
    tcase_("Step accross a leapsecond making sure that ET has the expected b"
	    "ehavior. ", (ftnlen)73);
    s_copy(tstrng, "31 DEC 1989 23:59:55.01", (ftnlen)80, (ftnlen)23);
    expdet[0] = -315575948.8060699105263;
    s_copy(tstrng + 80, "31 DEC 1989 23:59:56.02", (ftnlen)80, (ftnlen)23);
    expdet[1] = -315575947.796069920063;
    s_copy(tstrng + 160, "31 DEC 1989 23:59:57.03", (ftnlen)80, (ftnlen)23);
    expdet[2] = -315575946.7860699295998;
    s_copy(tstrng + 240, "31 DEC 1989 23:59:58.04", (ftnlen)80, (ftnlen)23);
    expdet[3] = -315575945.7760698795319;
    s_copy(tstrng + 320, "31 DEC 1989 23:59:59.05", (ftnlen)80, (ftnlen)23);
    expdet[4] = -315575944.7660698890686;
    s_copy(tstrng + 400, "31 DEC 1989 23:59:60.06", (ftnlen)80, (ftnlen)23);
    expdet[5] = -315575943.7560698986053;
    s_copy(tstrng + 480, "1  JAN 1990 00:00:00.07", (ftnlen)80, (ftnlen)23);
    expdet[6] = -315575942.7460699081421;
    s_copy(tstrng + 560, "1  JAN 1990 00:00:01.08", (ftnlen)80, (ftnlen)23);
    expdet[7] = -315575941.7360699176788;
    for (i__ = 1; i__ <= 8; ++i__) {
	tstmsg_("#", "Test subcase #.", (ftnlen)1, (ftnlen)15);
	tstmsi_(&i__);
	utc2et_(tstrng + ((i__1 = i__ - 1) < 22 && 0 <= i__1 ? i__1 : s_rnge(
		"tstrng", i__1, "f_utc2et__", (ftnlen)283)) * 80, &et, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksd_("ET", &et, "~/", &expdet[(i__1 = i__ - 1) < 22 && 0 <= i__1 ? 
		i__1 : s_rnge("expdet", i__1, "f_utc2et__", (ftnlen)285)], &
		c_b78, ok, (ftnlen)2, (ftnlen)2);
    }
    tparch_("NO", (ftnlen)2);
    t_success__(ok);
    return 0;
} /* f_utc2et__ */

