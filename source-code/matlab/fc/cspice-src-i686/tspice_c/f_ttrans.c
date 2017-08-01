/* f_ttrans.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b147 = 0.;
static doublereal c_b157 = 1e-7;
static doublereal c_b175 = 2.;
static integer c__6 = 6;
static integer c__7 = 7;
static doublereal c_b258 = 57.184;

/* $Procedure      F_TTRANS ( Family of tests for TTRANS ) */
/* Subroutine */ int f_ttrans__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal diff, tvec[7];
    integer size[21], i__, j, k;
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen), tcase_(
	    char *, ftnlen);
    doublereal etvec[7];
    char ntvec[32*7];
    doublereal tvecs[147]	/* was [7][21] */;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char insys[32*21];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal jdutc1, jdutc2;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal jd;
    extern /* Character */ VOID begdat_(char *, ftnlen);
    char badker[80*23];
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), chckxc_(logical *, char *, logical *, ftnlen);
    doublereal secnds;
    char goodkr[80*23];
    integer nlines;
    extern /* Subroutine */ int clpool_(void);
    char estrng[32], string[32];
    extern /* Subroutine */ int ttrans_(char *, char *, doublereal *, ftnlen, 
	    ftnlen), tstmsc_(char *, ftnlen), tstmsg_(char *, char *, ftnlen, 
	    ftnlen);
    char outsys[32*21];
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    extern doublereal j2000_(void);
    doublereal tdt1, tdt2;

/* $ Abstract */

/*     This routine test the functionality of the main SPICE */
/*     time translation routine TTRANS. */

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

    nlines = 23;
    begdat_(ch__1, (ftnlen)32);
    s_copy(badker, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(badker + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(badker + 160, "DELTET/DELTA_T_A       =   32.184", (ftnlen)80, (
	    ftnlen)33);
    s_copy(badker + 240, "DELTET/K               =    1.657D-3", (ftnlen)80, (
	    ftnlen)36);
    s_copy(badker + 320, "DELTET/EB              =    1.671D-2", (ftnlen)80, (
	    ftnlen)36);
    s_copy(badker + 400, "DELTET/M               = (  6.239996D0   1.9909687"
	    "1D-7 )", (ftnlen)80, (ftnlen)56);
    s_copy(badker + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(badker + 560, "DELTET/DELTA_AT        = ( 10,   @1972-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 640, "                           11,   @1972-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 720, "                           12,   @1973-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 800, "                           13,   @1974-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 880, "                           14,   @1975-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 960, "                           15,   @1976-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1040, "                           16,   @1977-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1120, "                           17,   @1978-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1200, "                           18,   @1979-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1280, "                           20,   @1981-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1360, "                           19,   @1980-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1440, "                           21,   @1982-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1520, "                           22,   @1983-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1600, "                           23,   @1985-JUL-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1680, "                           24,   @1988-JAN-1", (
	    ftnlen)80, (ftnlen)44);
    s_copy(badker + 1760, "                           25,   @1990-JAN-1 )", (
	    ftnlen)80, (ftnlen)46);
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

/*     Begin every test family with an open call. */

    topen_("F_TTRANS", (ftnlen)8);
    tvec[0] = 1995.;
    tvec[1] = 2.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    tvec[6] = 0.;
    tcase_("Check the 'NOLEAPSECONDS' exception. ", (ftnlen)37);
    clpool_();
    ttrans_("ET", "YMD", tvec, (ftnlen)2, (ftnlen)3);
    chckxc_(&c_true, "SPICE(NOLEAPSECONDS)", ok, (ftnlen)20);
    tcase_("Check to make sure a leapsecond out of order error is properly d"
	    "iagnosed. ", (ftnlen)74);
    tsttxt_("testleap.ker", badker, &nlines, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)80);
    ttrans_("ET", "YMD", tvec, (ftnlen)2, (ftnlen)3);
    chckxc_(&c_true, "SPICE(BADLEAPSECONDS)", ok, (ftnlen)21);
    tcase_("Make sure that an unknown time system is properly diagnosed when"
	    " the first system is unknown. ", (ftnlen)94);
    clpool_();
    tsttxt_("testleap.ker", goodkr, &nlines, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)80);
    ttrans_("ETF", "YMD", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_true, "SPICE(UNKNONWNTIMESYSTEM)", ok, (ftnlen)25);
    tcase_("Make sure that an unknown time system is properly diagnosed when"
	    " the second system is unknown. ", (ftnlen)95);
    ttrans_("YMD", "DMY", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_true, "SPICE(UNKNONWNTIMESYSTEM)", ok, (ftnlen)25);
    tcase_("Without checking the validity of TTRANS, make sure that all of t"
	    "he advertised time systems are recognized and that TVEC changes "
	    "from it's input value to a different output value. ", (ftnlen)179)
	    ;
    s_copy(insys, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 32, "YMDF", (ftnlen)32, (ftnlen)4);
    s_copy(insys + 64, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(insys + 96, "YDF", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 128, "YD.D", (ftnlen)32, (ftnlen)4);
    s_copy(insys + 160, "YD.DF", (ftnlen)32, (ftnlen)5);
    s_copy(insys + 192, "DAYSEC", (ftnlen)32, (ftnlen)6);
    s_copy(insys + 224, "DP2000", (ftnlen)32, (ftnlen)6);
    s_copy(insys + 256, "JDUTC", (ftnlen)32, (ftnlen)5);
    s_copy(insys + 288, "FORMAL", (ftnlen)32, (ftnlen)6);
    s_copy(insys + 320, "YWD", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 352, "YWDF", (ftnlen)32, (ftnlen)4);
    s_copy(insys + 384, "YMWD", (ftnlen)32, (ftnlen)4);
    s_copy(insys + 416, "YMWDF", (ftnlen)32, (ftnlen)5);
    s_copy(insys + 448, "TAI", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 480, "TDT", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 512, "TDB", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 544, "JED", (ftnlen)32, (ftnlen)3);
    s_copy(insys + 576, "ET", (ftnlen)32, (ftnlen)2);
    s_copy(insys + 608, "JDTDB", (ftnlen)32, (ftnlen)5);
    s_copy(insys + 640, "JDTDT", (ftnlen)32, (ftnlen)5);
    for (i__ = 1; i__ <= 21; ++i__) {
	s_copy(outsys + (((i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"outsys", i__1, "f_ttrans__", (ftnlen)251)) << 5), insys + (((
		i__2 = i__ - 1) < 21 && 0 <= i__2 ? i__2 : s_rnge("insys", 
		i__2, "f_ttrans__", (ftnlen)251)) << 5), (ftnlen)32, (ftnlen)
		32);
    }
    for (j = 1; j <= 21; ++j) {
	for (i__ = 1; i__ <= 7; ++i__) {
	    tvecs[(i__1 = i__ + j * 7 - 8) < 147 && 0 <= i__1 ? i__1 : s_rnge(
		    "tvecs", i__1, "f_ttrans__", (ftnlen)256)] = 0.;
	}
    }

/*        Set up the test values for YMD */

    tvecs[0] = 1995.;
    tvecs[1] = 1.;
    tvecs[2] = 2.;
    size[0] = 6;

/*        ... for YMDF */

    tvecs[7] = 1995.;
    tvecs[8] = 1.;
    tvecs[9] = 2.;
    size[1] = 6;

/*        ... for YD */

    tvecs[14] = 1995.;
    tvecs[15] = 2.;
    size[2] = 5;

/*        ... for YDF */

    tvecs[21] = 1995.;
    tvecs[22] = 2.;
    size[3] = 5;

/*        ... for YD.D */

    tvecs[28] = 1995.;
    tvecs[29] = 2.;
    size[4] = 2;

/*        ... for YD.DF */

    tvecs[35] = 1995.;
    tvecs[36] = 2.;
    size[5] = 2;

/*        ... for DAYSEC */

    tvecs[42] = 729039.;
    tvecs[43] = 20.;
    size[6] = 2;

/*        ... for DP2000 */

    tvecs[49] = -1850.;
    tvecs[50] = 20.;
    size[7] = 2;

/*        ... for JDUTC and FORMAL */

    tvecs[56] = 2451525.;
    tvecs[63] = -3.1e7;
    size[8] = 1;
    size[9] = 1;

/*        ... for YWD */

    tvecs[70] = 1995.;
    tvecs[71] = 2.;
    tvecs[72] = 2.;
    size[10] = 6;

/*        ... for YWDF */

    tvecs[77] = 1995.;
    tvecs[78] = 2.;
    tvecs[79] = 2.;
    size[11] = 6;

/*        ... for YMWD */

    tvecs[84] = 1995.;
    tvecs[85] = 2.;
    tvecs[86] = 2.;
    tvecs[87] = 1.;
    size[12] = 7;

/*        ... for YMWDF */

    tvecs[91] = 1995.;
    tvecs[92] = 2.;
    tvecs[93] = 2.;
    tvecs[94] = 2.;
    size[13] = 7;

/*        ... for TAI, TDT, TDB, JED, ET, JDTDB, JDTDT */

    tvecs[98] = -3.1e7;
    tvecs[105] = -3.1e7;
    tvecs[112] = -3.1e7;
    tvecs[119] = 2451545.;
    tvecs[126] = -3.1e7;
    tvecs[133] = 2451545.;
    tvecs[140] = 2451545.;
    size[14] = 1;
    size[15] = 1;
    size[16] = 1;
    size[17] = 1;
    size[18] = 1;
    size[19] = 1;
    size[20] = 1;
    for (i__ = 1; i__ <= 21; ++i__) {
	for (j = 1; j <= 21; ++j) {
	    for (k = 1; k <= 7; ++k) {
		tvec[(i__1 = k - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge("tvec", 
			i__1, "f_ttrans__", (ftnlen)369)] = tvecs[(i__2 = k + 
			i__ * 7 - 8) < 147 && 0 <= i__2 ? i__2 : s_rnge("tve"
			"cs", i__2, "f_ttrans__", (ftnlen)369)];
	    }
	    ttrans_(insys + (((i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : 
		    s_rnge("insys", i__1, "f_ttrans__", (ftnlen)372)) << 5), 
		    outsys + (((i__2 = j - 1) < 21 && 0 <= i__2 ? i__2 : 
		    s_rnge("outsys", i__2, "f_ttrans__", (ftnlen)372)) << 5), 
		    tvec, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}
    }
    tcase_("This test checks for internal consistency. Each pair is of possi"
	    "ble input and output systems are converted \"there and back again"
	    "\". ", (ftnlen)131);
    s_copy(ntvec, "TVEC(1)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 32, "TVEC(2)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 64, "TVEC(3)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 96, "TVEC(4)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 128, "TVEC(5)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 160, "TVEC(6)", (ftnlen)32, (ftnlen)7);
    s_copy(ntvec + 192, "TVEC(7)", (ftnlen)32, (ftnlen)7);
    for (i__ = 1; i__ <= 21; ++i__) {
	for (j = 1; j <= 21; ++j) {
	    if (*(unsigned char *)&outsys[((i__1 = j - 1) < 21 && 0 <= i__1 ? 
		    i__1 : s_rnge("outsys", i__1, "f_ttrans__", (ftnlen)396)) 
		    * 32] != 'J') {
		tstmsg_("#", "Input system #, Output System #", (ftnlen)1, (
			ftnlen)31);
		tstmsc_(insys + (((i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : 
			s_rnge("insys", i__1, "f_ttrans__", (ftnlen)399)) << 
			5), (ftnlen)32);
		tstmsc_(outsys + (((i__1 = j - 1) < 21 && 0 <= i__1 ? i__1 : 
			s_rnge("outsys", i__1, "f_ttrans__", (ftnlen)400)) << 
			5), (ftnlen)32);
		for (k = 1; k <= 7; ++k) {
		    tvec[(i__1 = k - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge(
			    "tvec", i__1, "f_ttrans__", (ftnlen)403)] = tvecs[
			    (i__2 = k + i__ * 7 - 8) < 147 && 0 <= i__2 ? 
			    i__2 : s_rnge("tvecs", i__2, "f_ttrans__", (
			    ftnlen)403)];
		}
		ttrans_(insys + (((i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : 
			s_rnge("insys", i__1, "f_ttrans__", (ftnlen)406)) << 
			5), outsys + (((i__2 = j - 1) < 21 && 0 <= i__2 ? 
			i__2 : s_rnge("outsys", i__2, "f_ttrans__", (ftnlen)
			406)) << 5), tvec, (ftnlen)32, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		ttrans_(outsys + (((i__1 = j - 1) < 21 && 0 <= i__1 ? i__1 : 
			s_rnge("outsys", i__1, "f_ttrans__", (ftnlen)408)) << 
			5), insys + (((i__2 = i__ - 1) < 21 && 0 <= i__2 ? 
			i__2 : s_rnge("insys", i__2, "f_ttrans__", (ftnlen)
			408)) << 5), tvec, (ftnlen)32, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		i__2 = size[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : 
			s_rnge("size", i__1, "f_ttrans__", (ftnlen)412)] - 1;
		for (k = 1; k <= i__2; ++k) {
		    chcksd_(ntvec + (((i__1 = k - 1) < 7 && 0 <= i__1 ? i__1 :
			     s_rnge("ntvec", i__1, "f_ttrans__", (ftnlen)414))
			     << 5), &tvec[(i__3 = k - 1) < 7 && 0 <= i__3 ? 
			    i__3 : s_rnge("tvec", i__3, "f_ttrans__", (ftnlen)
			    414)], "=", &tvecs[(i__4 = k + i__ * 7 - 8) < 147 
			    && 0 <= i__4 ? i__4 : s_rnge("tvecs", i__4, "f_t"
			    "trans__", (ftnlen)414)], &c_b147, ok, (ftnlen)32, 
			    (ftnlen)1);
		}
		k = size[(i__2 = i__ - 1) < 21 && 0 <= i__2 ? i__2 : s_rnge(
			"size", i__2, "f_ttrans__", (ftnlen)419)];
		chcksd_(ntvec + (((i__2 = k - 1) < 7 && 0 <= i__2 ? i__2 : 
			s_rnge("ntvec", i__2, "f_ttrans__", (ftnlen)420)) << 
			5), &tvec[(i__1 = k - 1) < 7 && 0 <= i__1 ? i__1 : 
			s_rnge("tvec", i__1, "f_ttrans__", (ftnlen)420)], 
			"~", &tvecs[(i__3 = k + i__ * 7 - 8) < 147 && 0 <= 
			i__3 ? i__3 : s_rnge("tvecs", i__3, "f_ttrans__", (
			ftnlen)420)], &c_b157, ok, (ftnlen)32, (ftnlen)1);
	    }
	}
    }
    tcase_("Check to make sure that when we cross a leapsecond boundary in U"
	    "TC components that the corresponding TDT change by the right amo"
	    "unt.", (ftnlen)132);
    tvec[0] = 1989.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 59.;
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tdt1 = tvec[0];
    tvec[0] = 1990.;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tdt2 = tvec[0];
    diff = tdt2 - tdt1;
    chcksd_("DIFF", &diff, "=", &c_b175, &c_b147, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Continuing the last case, make sure that TDT epochs that occur d"
	    "uring leapseconds are properly transformed when returning to YMD"
	    " UTC format. ", (ftnlen)141);
    tvec[0] = tdt2 - .5;
    ttrans_("TDT", "YMD", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    etvec[0] = 1989.;
    etvec[1] = 12.;
    etvec[2] = 31.;
    etvec[3] = 23.;
    etvec[4] = 59.;
    etvec[5] = 60.5;
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b147, ok, (ftnlen)4, (ftnlen)
	    1);
    tcase_("Make sure that we can get the day of the week and week of the mo"
	    "nth correct. ", (ftnlen)77);
    tvec[0] = 1996.;
    tvec[1] = 5.;
    tvec[2] = 23.;
    tvec[3] = 12.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    etvec[0] = 1996.;
    etvec[1] = 5.;
    etvec[2] = 4.;
    etvec[3] = 5.;
    etvec[4] = 12.;
    etvec[5] = 0.;
    etvec[6] = 0.;
    ttrans_("YMD", "YMWD", tvec, (ftnlen)3, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__7, &c_b147, ok, (ftnlen)4, (ftnlen)
	    1);
    tcase_("The value of JDUTC should not change during a leapsecond, make s"
	    "ure that it doesn't. ", (ftnlen)85);
    tvec[0] = 1989.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.;
    ttrans_("YMD", "JDUTC", tvec, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    jdutc1 = tvec[0];
    tvec[0] = 1989.;
    tvec[1] = 12.;
    tvec[2] = 31.;
    tvec[3] = 23.;
    tvec[4] = 59.;
    tvec[5] = 60.5;
    ttrans_("YMD", "JDUTC", tvec, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    jdutc2 = tvec[0];
    chcksd_("JDUTC", &jdutc2, "=", &jdutc1, &c_b147, ok, (ftnlen)5, (ftnlen)1)
	    ;
    tvec[0] = 1990.;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMD", "JDUTC", tvec, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    jdutc2 = tvec[0];
    chcksd_("JDUTC", &jdutc2, "=", &jdutc1, &c_b147, ok, (ftnlen)5, (ftnlen)1)
	    ;
    tcase_("Using a format time system we should be able to convert to FORMA"
	    "L and then predict the string that will be returned by ETCAL. ", (
	    ftnlen)126);
    tvec[0] = 1996.;
    tvec[1] = 5.;
    tvec[2] = 24.;
    tvec[3] = 3.;
    tvec[4] = 11.;
    tvec[5] = 12.;
    s_copy(estrng, "1996 MAY 24 03:11:12.000", (ftnlen)32, (ftnlen)24);
    ttrans_("YMDF", "FORMAL", tvec, (ftnlen)4, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    etcal_(tvec, string, (ftnlen)32);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)32, (ftnlen)
	    1, (ftnlen)32);
    tcase_("We can also predict the TDT time string associated with an epoch"
	    " and use ETCAL to check this prediction. ", (ftnlen)105);
    tvec[0] = 1996.;
    tvec[1] = 5.;
    tvec[2] = 24.;
    tvec[3] = 3.;
    tvec[4] = 11.;
    tvec[5] = 12.;
    s_copy(estrng, "1996 MAY 24 03:12:09.184", (ftnlen)32, (ftnlen)24);
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    etcal_(tvec, string, (ftnlen)32);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)32, (ftnlen)
	    1, (ftnlen)32);
    tcase_("There were two leapseconds in 1972, make sure that we can comput"
	    "e the actual number of seconds in 1972. ", (ftnlen)104);
    tvec[0] = 1972.;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tdt1 = tvec[0];
    tvec[0] = 1973.;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 0.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tdt2 = tvec[0];
    diff = tdt2 - tdt1;
    secnds = 31622402.;
    chcksd_("DIFF", &diff, "=", &secnds, &c_b147, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Make sure that the FORMAL time associated with 2000 Jan 1 12:00:"
	    "00 is zero. ", (ftnlen)76);
    tvec[0] = 2e3;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 12.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMDF", "FORMAL", tvec, (ftnlen)4, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("TVEC(1)", tvec, "=", &c_b147, &c_b147, ok, (ftnlen)7, (ftnlen)1);
    tcase_("Make sure that the TDT time associated with 2000 Jan 1 12:00:00 "
	    "is zero. 57.184", (ftnlen)79);
    tvec[0] = 2e3;
    tvec[1] = 1.;
    tvec[2] = 1.;
    tvec[3] = 12.;
    tvec[4] = 0.;
    tvec[5] = 0.;
    ttrans_("YMD", "TDT", tvec, (ftnlen)3, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("TVEC(1)", tvec, "=", &c_b258, &c_b147, ok, (ftnlen)7, (ftnlen)1);
    tcase_("Make sure that we get the correct julian date for 0.0D0 ET. ", (
	    ftnlen)60);
    tvec[0] = 0.;
    ttrans_("TDT", "JDTDT", tvec, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    jd = j2000_();
    chcksd_("JD", &jd, "=", tvec, &c_b147, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Make sure that ancient epochs are handled according to specifica"
	    "tion.  We use ETCAL to assist with this. ", (ftnlen)105);
    tvec[0] = -333.;
    tvec[1] = 5.;
    tvec[2] = 24.;
    tvec[3] = 3.;
    tvec[4] = 11.;
    tvec[5] = 12.;
    s_copy(estrng, "334 B.C. MAY 24 03:11:12.000", (ftnlen)32, (ftnlen)28);
    ttrans_("YMD", "FORMAL", tvec, (ftnlen)3, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    etcal_(tvec, string, (ftnlen)32);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)32, (ftnlen)
	    1, (ftnlen)32);
    t_success__(ok);
    return 0;
} /* f_ttrans__ */

