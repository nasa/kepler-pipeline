/* f_timcvr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;

/* $Procedure      F_TIMCVR ( TIMOUT tests to exercise branch coverage) */
/* Subroutine */ int f_timcvr__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char name__[32];
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char ftime[80];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char times[80*48];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , str2et_(char *, doublereal *, ftnlen);
    doublereal et;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), timdef_(char *, char *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char expctd[80*48];
    extern /* Subroutine */ int clpool_(void);
    char pictur[80];
    extern /* Subroutine */ int timout_(doublereal *, char *, char *, ftnlen, 
	    ftnlen), tstlsk_(void);

/* $ Abstract */

/*     This routine generates a sufficiently large set of test cases */
/*     to exercise every reachable branch in TIMOUT. */

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

    topen_("F_TIMCVR", (ftnlen)8);
    s_copy(times, "12 B.C. JAN 01 10:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 80, "12 B.C. FEB 05 11:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 160, "12 B.C. MAR 10 12:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 240, "12 B.C. APR 15 13:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 320, "12 B.C. MAY 20 14:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 400, "12 B.C. JUN 25 15:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 480, "12 B.C. JUL 01 16:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 560, "12 B.C. AUG 10 17:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 640, "12 B.C. SEP 15 18:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 720, "12 B.C. OCT 20 19:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 800, "12 B.C. NOV 25 20:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 880, "12 B.C. DEC 31 21:00:00 ", (ftnlen)80, (ftnlen)24);
    s_copy(times + 960, "141 A.D. JAN 01 10:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1040, "141 A.D. FEB 05 11:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1120, "141 A.D. MAR 10 12:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1200, "141 A.D. APR 15 13:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1280, "141 A.D. MAY 20 14:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1360, "141 A.D. JUN 25 15:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1440, "141 A.D. JUL 01 16:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1520, "141 A.D. AUG 10 17:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1600, "141 A.D. SEP 15 18:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1680, "141 A.D. OCT 20 19:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1760, "141 A.D. NOV 25 20:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1840, "141 A.D. DEC 31 21:00:00 ", (ftnlen)80, (ftnlen)25);
    s_copy(times + 1920, "1582 JAN 01  10:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2000, "1582 FEB 05  11:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2080, "1582 MAR 10  12:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2160, "1582 APR 15  13:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2240, "1582 MAY 20  14:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2320, "1582 JUN 25  15:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2400, "1582 JUL 01  16:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2480, "1582 AUG 10  17:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2560, "1582 SEP 15  18:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2640, "1582 OCT 12  19:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2720, "1582 OCT 25  20:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2800, "1582 DEC 31  21:00:00 ", (ftnlen)80, (ftnlen)22);
    s_copy(times + 2880, "1986 JAN 01 10:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 2960, "1986 FEB 05 11:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3040, "1986 MAR 10 12:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3120, "1986 APR 15 13:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3200, "1986 MAY 20 14:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3280, "1986 JUN 25 15:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3360, "1986 JUL 01 16:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3440, "1986 AUG 10 17:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3520, "1986 SEP 15 18:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3600, "1986 OCT 20 19:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3680, "1986 NOV 25 20:00:00 ", (ftnlen)80, (ftnlen)21);
    s_copy(times + 3760, "1986 DEC 31 21:00:00 ", (ftnlen)80, (ftnlen)21);

/*     Clear the kernel pool and then load a leapseconds kernel. */

    clpool_();
    tstlsk_();
    s_copy(pictur, "YYYY ERA MON DD AP:MN:SC.### ampm PDT ::RND", (ftnlen)80, 
	    (ftnlen)43);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "  12 B.C. JAN 01 10:00:00.000 a.m. PDT", (ftnlen)80, (
	    ftnlen)38);
    s_copy(expctd + 80, "  12 B.C. FEB 05 11:00:00.000 a.m. PDT", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(expctd + 160, "  12 B.C. MAR 10 12:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 240, "  12 B.C. APR 15 01:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 320, "  12 B.C. MAY 20 02:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 400, "  12 B.C. JUN 25 03:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 480, "  12 B.C. JUL 01 04:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 560, "  12 B.C. AUG 10 05:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 640, "  12 B.C. SEP 15 06:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 720, "  12 B.C. OCT 20 07:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 800, "  12 B.C. NOV 25 08:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 880, "  12 B.C. DEC 31 09:00:00.000 p.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 960, " 141 A.D. JAN 01 10:00:00.000 a.m. PDT", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 1040, " 141 A.D. FEB 05 11:00:00.000 a.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1120, " 141 A.D. MAR 10 12:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1200, " 141 A.D. APR 15 01:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1280, " 141 A.D. MAY 20 02:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1360, " 141 A.D. JUN 25 03:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1440, " 141 A.D. JUL 01 04:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1520, " 141 A.D. AUG 10 05:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1600, " 141 A.D. SEP 15 06:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1680, " 141 A.D. OCT 20 07:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1760, " 141 A.D. NOV 25 08:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1840, " 141 A.D. DEC 31 09:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1920, "1582 A.D. JAN 01 10:00:00.000 a.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2000, "1582 A.D. FEB 05 11:00:00.000 a.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2080, "1582 A.D. MAR 10 12:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2160, "1582 A.D. APR 15 01:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2240, "1582 A.D. MAY 20 02:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2320, "1582 A.D. JUN 25 03:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2400, "1582 A.D. JUL 01 04:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2480, "1582 A.D. AUG 10 05:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2560, "1582 A.D. SEP 15 06:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2640, "1582 A.D. OCT 12 07:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2720, "1582 A.D. OCT 25 08:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2800, "1582 A.D. DEC 31 09:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2880, "1986 A.D. JAN 01 10:00:00.000 a.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2960, "1986 A.D. FEB 05 11:00:00.000 a.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3040, "1986 A.D. MAR 10 12:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3120, "1986 A.D. APR 15 01:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3200, "1986 A.D. MAY 20 02:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3280, "1986 A.D. JUN 25 03:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3360, "1986 A.D. JUL 01 04:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3440, "1986 A.D. AUG 10 05:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3520, "1986 A.D. SEP 15 06:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3600, "1986 A.D. OCT 20 07:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3680, "1986 A.D. NOV 25 08:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3760, "1986 A.D. DEC 31 09:00:00.000 p.m. PDT", (ftnlen)
	    80, (ftnlen)38);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)197)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		203)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY MM DD Weekday HR:MN:SC.## ::TRNC ::TDT", (ftnlen)80, 
	    (ftnlen)43);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 01 01 Sunday 10:00:41.18", (ftnlen)80, (ftnlen)29);
    s_copy(expctd + 80, " -11 02 05 Sunday 11:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 160, " -11 03 10 Friday 12:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 240, " -11 04 15 Saturday 13:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 320, " -11 05 20 Saturday 14:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 400, " -11 06 25 Sunday 15:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 480, " -11 07 01 Saturday 16:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 560, " -11 08 10 Thursday 17:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 640, " -11 09 15 Friday 18:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 720, " -11 10 20 Friday 19:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 800, " -11 11 25 Saturday 20:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 880, " -11 12 31 Sunday 21:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 960, " 141 01 01 Sunday 10:00:41.18", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 1040, " 141 02 05 Sunday 11:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1120, " 141 03 10 Friday 12:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1200, " 141 04 15 Saturday 13:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1280, " 141 05 20 Saturday 14:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1360, " 141 06 25 Sunday 15:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1440, " 141 07 01 Saturday 16:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1520, " 141 08 10 Thursday 17:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1600, " 141 09 15 Friday 18:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1680, " 141 10 20 Friday 19:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1760, " 141 11 25 Saturday 20:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1840, " 141 12 31 Sunday 21:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1920, "1582 01 01 Friday 10:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2000, "1582 02 05 Friday 11:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2080, "1582 03 10 Wednesday 12:00:41.18", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2160, "1582 04 15 Thursday 13:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2240, "1582 05 20 Thursday 14:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2320, "1582 06 25 Friday 15:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2400, "1582 07 01 Thursday 16:00:41.18", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2480, "1582 08 10 Tuesday 17:00:41.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2560, "1582 09 15 Wednesday 18:00:41.18", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2640, "1582 10 12 Tuesday 19:00:41.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2720, "1582 10 25 Monday 20:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2800, "1582 12 31 Friday 21:00:41.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2880, "1986 01 01 Wednesday 10:00:55.18", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2960, "1986 02 05 Wednesday 11:00:55.18", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3040, "1986 03 10 Monday 12:00:55.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3120, "1986 04 15 Tuesday 13:00:55.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3200, "1986 05 20 Tuesday 14:00:55.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3280, "1986 06 25 Wednesday 15:00:55.18", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3360, "1986 07 01 Tuesday 16:00:55.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3440, "1986 08 10 Sunday 17:00:55.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3520, "1986 09 15 Monday 18:00:55.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3600, "1986 10 20 Monday 19:00:55.18", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3680, "1986 11 25 Tuesday 20:00:55.18", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3760, "1986 12 31 Wednesday 21:00:55.18", (ftnlen)80, (
	    ftnlen)32);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)264)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		270)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY Mon DD HR:MN:SC.## Wkd", (ftnlen)80, (ftnlen)27);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "JULIAN", (ftnlen)3, (ftnlen)8, (ftnlen)6);
    timdef_("SET", "SYSTEM", "TDB", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 Jan 01 10:00:00.00 Fri", (ftnlen)80, (ftnlen)27);
    s_copy(expctd + 80, " -11 Feb 05 11:00:00.00 Fri", (ftnlen)80, (ftnlen)27)
	    ;
    s_copy(expctd + 160, " -11 Mar 10 12:00:00.00 Wed", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 240, " -11 Apr 15 13:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 320, " -11 May 20 14:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 400, " -11 Jun 25 15:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 480, " -11 Jul 01 16:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 560, " -11 Aug 10 17:00:00.00 Tue", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 640, " -11 Sep 15 18:00:00.00 Wed", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 720, " -11 Oct 20 19:00:00.00 Wed", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 800, " -11 Nov 25 20:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 880, " -11 Dec 31 21:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 960, " 141 Jan 01 10:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1040, " 141 Feb 05 11:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1120, " 141 Mar 10 12:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1200, " 141 Apr 15 13:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1280, " 141 May 20 14:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1360, " 141 Jun 25 15:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1440, " 141 Jul 01 16:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1520, " 141 Aug 10 17:00:00.00 Wed", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1600, " 141 Sep 15 18:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1680, " 141 Oct 20 19:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1760, " 141 Nov 25 20:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1840, " 141 Dec 31 21:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1920, "1582 Jan 01 10:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2000, "1582 Feb 05 11:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2080, "1582 Mar 10 12:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2160, "1582 Apr 15 13:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2240, "1582 May 20 14:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2320, "1582 Jun 25 15:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2400, "1582 Jul 01 16:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2480, "1582 Aug 10 17:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2560, "1582 Sep 15 18:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2640, "1582 Oct 12 19:00:00.00 Fri", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2720, "1582 Oct 25 20:00:00.00 Thu", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2800, "1582 Dec 31 21:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2880, "1986 Jan 01 10:00:00.00 Tue", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2960, "1986 Feb 05 11:00:00.00 Tue", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3040, "1986 Mar 10 12:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3120, "1986 Apr 15 13:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3200, "1986 May 20 14:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3280, "1986 Jun 25 15:00:00.00 Tue", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3360, "1986 Jul 01 16:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3440, "1986 Aug 10 17:00:00.00 Sat", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3520, "1986 Sep 15 18:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3600, "1986 Oct 20 19:00:00.00 Sun", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3680, "1986 Nov 25 20:00:00.00 Mon", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3760, "1986 Dec 31 21:00:00.00 Tue", (ftnlen)80, (ftnlen)
	    27);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)331)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		337)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY Mon DD HR:MN:SC.### Wkd ::TDB", (ftnlen)80, (ftnlen)
	    34);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "MIXED", (ftnlen)3, (ftnlen)8, (ftnlen)5);
    timdef_("SET", "SYSTEM", "TDB", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 Jan 01 10:00:00.000 Fri", (ftnlen)80, (ftnlen)28);
    s_copy(expctd + 80, " -11 Feb 05 11:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 160, " -11 Mar 10 12:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 240, " -11 Apr 15 13:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 320, " -11 May 20 14:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 400, " -11 Jun 25 15:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 480, " -11 Jul 01 16:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 560, " -11 Aug 10 17:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 640, " -11 Sep 15 18:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 720, " -11 Oct 20 19:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 800, " -11 Nov 25 20:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 880, " -11 Dec 31 21:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 960, " 141 Jan 01 10:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1040, " 141 Feb 05 11:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1120, " 141 Mar 10 12:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1200, " 141 Apr 15 13:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1280, " 141 May 20 14:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1360, " 141 Jun 25 15:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1440, " 141 Jul 01 16:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1520, " 141 Aug 10 17:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1600, " 141 Sep 15 18:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1680, " 141 Oct 20 19:00:00.000 Thu", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1760, " 141 Nov 25 20:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1840, " 141 Dec 31 21:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1920, "1582 Jan 01 10:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2000, "1582 Feb 05 11:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2080, "1582 Mar 10 12:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2160, "1582 Apr 15 13:00:00.000 Sun", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2240, "1582 May 20 14:00:00.000 Sun", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2320, "1582 Jun 25 15:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2400, "1582 Jul 01 16:00:00.000 Sun", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2480, "1582 Aug 10 17:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2560, "1582 Sep 15 18:00:00.000 Sat", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2640, "1582 Oct 02 19:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2720, "1582 Oct 25 20:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2800, "1582 Dec 31 21:00:00.000 Fri", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2880, "1986 Jan 01 10:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2960, "1986 Feb 05 11:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3040, "1986 Mar 10 12:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3120, "1986 Apr 15 13:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3200, "1986 May 20 14:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3280, "1986 Jun 25 15:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3360, "1986 Jul 01 16:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3440, "1986 Aug 10 17:00:00.000 Sun", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3520, "1986 Sep 15 18:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3600, "1986 Oct 20 19:00:00.000 Mon", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3680, "1986 Nov 25 20:00:00.000 Tue", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3760, "1986 Dec 31 21:00:00.000 Wed", (ftnlen)80, (ftnlen)
	    28);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)398)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		404)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY mon DD wkd HR:MN:SC.### AMPM", (ftnlen)80, (ftnlen)
	    33);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "TDB", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 jan 01 sun 10:00:00.000 A.M.", (ftnlen)80, (ftnlen)
	    33);
    s_copy(expctd + 80, " -11 feb 05 sun 11:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 160, " -11 mar 10 fri 12:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 240, " -11 apr 15 sat 13:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 320, " -11 may 20 sat 14:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 400, " -11 jun 25 sun 15:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 480, " -11 jul 01 sat 16:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 560, " -11 aug 10 thu 17:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 640, " -11 sep 15 fri 18:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 720, " -11 oct 20 fri 19:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 800, " -11 nov 25 sat 20:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 880, " -11 dec 31 sun 21:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 960, " 141 jan 01 sun 10:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1040, " 141 feb 05 sun 11:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1120, " 141 mar 10 fri 12:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1200, " 141 apr 15 sat 13:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1280, " 141 may 20 sat 14:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1360, " 141 jun 25 sun 15:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1440, " 141 jul 01 sat 16:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1520, " 141 aug 10 thu 17:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1600, " 141 sep 15 fri 18:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1680, " 141 oct 20 fri 19:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1760, " 141 nov 25 sat 20:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1840, " 141 dec 31 sun 21:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1920, "1582 jan 01 fri 10:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2000, "1582 feb 05 fri 11:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2080, "1582 mar 10 wed 12:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2160, "1582 apr 15 thu 13:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2240, "1582 may 20 thu 14:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2320, "1582 jun 25 fri 15:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2400, "1582 jul 01 thu 16:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2480, "1582 aug 10 tue 17:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2560, "1582 sep 15 wed 18:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2640, "1582 oct 12 tue 19:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2720, "1582 oct 25 mon 20:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2800, "1582 dec 31 fri 21:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2880, "1986 jan 01 wed 10:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2960, "1986 feb 05 wed 11:00:00.000 A.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3040, "1986 mar 10 mon 12:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3120, "1986 apr 15 tue 13:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3200, "1986 may 20 tue 14:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3280, "1986 jun 25 wed 15:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3360, "1986 jul 01 tue 16:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3440, "1986 aug 10 sun 17:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3520, "1986 sep 15 mon 18:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3600, "1986 oct 20 mon 19:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3680, "1986 nov 25 tue 20:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3760, "1986 dec 31 wed 21:00:00.000 P.M.", (ftnlen)80, (
	    ftnlen)33);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)465)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		471)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY Mon DD WKD", (ftnlen)80, (ftnlen)15);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "TDT", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 Jan 01 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 80, " -11 Feb 05 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 160, " -11 Mar 10 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 240, " -11 Apr 15 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 320, " -11 May 20 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 400, " -11 Jun 25 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 480, " -11 Jul 01 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 560, " -11 Aug 10 THU", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 640, " -11 Sep 15 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 720, " -11 Oct 20 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 800, " -11 Nov 25 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 880, " -11 Dec 31 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 960, " 141 Jan 01 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1040, " 141 Feb 05 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1120, " 141 Mar 10 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1200, " 141 Apr 15 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1280, " 141 May 20 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1360, " 141 Jun 25 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1440, " 141 Jul 01 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1520, " 141 Aug 10 THU", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1600, " 141 Sep 15 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1680, " 141 Oct 20 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1760, " 141 Nov 25 SAT", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1840, " 141 Dec 31 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1920, "1582 Jan 01 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2000, "1582 Feb 05 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2080, "1582 Mar 10 WED", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2160, "1582 Apr 15 THU", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2240, "1582 May 20 THU", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2320, "1582 Jun 25 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2400, "1582 Jul 01 THU", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2480, "1582 Aug 10 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2560, "1582 Sep 15 WED", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2640, "1582 Oct 12 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2720, "1582 Oct 25 MON", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2800, "1582 Dec 31 FRI", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2880, "1986 Jan 01 WED", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2960, "1986 Feb 05 WED", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3040, "1986 Mar 10 MON", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3120, "1986 Apr 15 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3200, "1986 May 20 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3280, "1986 Jun 25 WED", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3360, "1986 Jul 01 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3440, "1986 Aug 10 SUN", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3520, "1986 Sep 15 MON", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3600, "1986 Oct 20 MON", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3680, "1986 Nov 25 TUE", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3760, "1986 Dec 31 WED", (ftnlen)80, (ftnlen)15);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)532)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		538)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY month weekday DD HR:MN.###", (ftnlen)80, (ftnlen)31);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "ZONE", "UTC+8", (ftnlen)3, (ftnlen)4, (ftnlen)5);
    s_copy(expctd, " -11 january sunday 01 10:00.000", (ftnlen)80, (ftnlen)32)
	    ;
    s_copy(expctd + 80, " -11 february sunday 05 11:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 160, " -11 march friday 10 12:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 240, " -11 april saturday 15 13:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 320, " -11 may saturday 20 14:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 400, " -11 june sunday 25 15:00.000", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 480, " -11 july saturday 01 16:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 560, " -11 august thursday 10 17:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 640, " -11 september friday 15 18:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 720, " -11 october friday 20 19:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 800, " -11 november saturday 25 20:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 880, " -11 december sunday 31 21:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 960, " 141 january sunday 01 10:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1040, " 141 february sunday 05 11:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1120, " 141 march friday 10 12:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1200, " 141 april saturday 15 13:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1280, " 141 may saturday 20 14:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1360, " 141 june sunday 25 15:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1440, " 141 july saturday 01 16:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1520, " 141 august thursday 10 17:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1600, " 141 september friday 15 18:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 1680, " 141 october friday 20 19:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1760, " 141 november saturday 25 20:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 1840, " 141 december sunday 31 21:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1920, "1582 january friday 01 10:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2000, "1582 february friday 05 11:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2080, "1582 march wednesday 10 12:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2160, "1582 april thursday 15 13:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2240, "1582 may thursday 20 14:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2320, "1582 june friday 25 15:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2400, "1582 july thursday 01 16:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2480, "1582 august tuesday 10 17:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2560, "1582 september wednesday 15 18:00.000", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 2640, "1582 october tuesday 12 19:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2720, "1582 october monday 25 20:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2800, "1582 december friday 31 21:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2880, "1986 january wednesday 01 10:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 2960, "1986 february wednesday 05 11:00.000", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 3040, "1986 march monday 10 12:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3120, "1986 april tuesday 15 13:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3200, "1986 may tuesday 20 14:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3280, "1986 june wednesday 25 15:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3360, "1986 july tuesday 01 16:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3440, "1986 august sunday 10 17:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3520, "1986 september monday 15 18:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 3600, "1986 october monday 20 19:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3680, "1986 november tuesday 25 20:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 3760, "1986 december wednesday 31 21:00.000", (ftnlen)80, 
	    (ftnlen)36);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)599)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		605)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY MONTH DD::UTC+07:30-HR:MN ::MCAL", (ftnlen)80, (
	    ftnlen)37);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 JANUARY 03-17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 80, " -11 FEBRUARY 07-18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 160, " -11 MARCH 12-19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 240, " -11 APRIL 17-20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 320, " -11 MAY 22-21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 400, " -11 JUNE 27-22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 480, " -11 JULY 03-23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 560, " -11 AUGUST 13-00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 640, " -11 SEPTEMBER 18-01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 720, " -11 OCTOBER 23-02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 800, " -11 NOVEMBER 28-03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 880, " -10 JANUARY 03-04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 960, " 141 JANUARY 02-17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1040, " 141 FEBRUARY 06-18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1120, " 141 MARCH 11-19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 1200, " 141 APRIL 16-20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 1280, " 141 MAY 21-21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 1360, " 141 JUNE 26-22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 1440, " 141 JULY 02-23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 1520, " 141 AUGUST 12-00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 1600, " 141 SEPTEMBER 17-01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 1680, " 141 OCTOBER 22-02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1760, " 141 NOVEMBER 27-03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1840, " 142 JANUARY 02-04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1920, "1581 DECEMBER 22-17:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 2000, "1582 JANUARY 26-18:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2080, "1582 FEBRUARY 28-19:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 2160, "1582 APRIL 05-20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 2240, "1582 MAY 10-21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 2320, "1582 JUNE 15-22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 2400, "1582 JUNE 21-23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 2480, "1582 AUGUST 01-00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 2560, "1582 SEPTEMBER 06-01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 2640, "1582 OCTOBER 03-02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2720, "1582 OCTOBER 26-03:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2800, "1583 JANUARY 01-04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2880, "1986 JANUARY 01-17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2960, "1986 FEBRUARY 05-18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 3040, "1986 MARCH 10-19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 3120, "1986 APRIL 15-20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 3200, "1986 MAY 20-21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 3280, "1986 JUNE 25-22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 3360, "1986 JULY 01-23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 3440, "1986 AUGUST 11-00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 3520, "1986 SEPTEMBER 16-01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 3600, "1986 OCTOBER 21-02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3680, "1986 NOVEMBER 26-03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 3760, "1987 JANUARY 01-04:30", (ftnlen)80, (ftnlen)21);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)666)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		672)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY MONTH DD HR:MN ::UTC+07:30::MCAL", (ftnlen)80, (
	    ftnlen)37);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 JANUARY 03 17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 80, " -11 FEBRUARY 07 18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 160, " -11 MARCH 12 19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 240, " -11 APRIL 17 20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 320, " -11 MAY 22 21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 400, " -11 JUNE 27 22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 480, " -11 JULY 03 23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 560, " -11 AUGUST 13 00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 640, " -11 SEPTEMBER 18 01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 720, " -11 OCTOBER 23 02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 800, " -11 NOVEMBER 28 03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 880, " -10 JANUARY 03 04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 960, " 141 JANUARY 02 17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1040, " 141 FEBRUARY 06 18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1120, " 141 MARCH 11 19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 1200, " 141 APRIL 16 20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 1280, " 141 MAY 21 21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 1360, " 141 JUNE 26 22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 1440, " 141 JULY 02 23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 1520, " 141 AUGUST 12 00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 1600, " 141 SEPTEMBER 17 01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 1680, " 141 OCTOBER 22 02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1760, " 141 NOVEMBER 27 03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1840, " 142 JANUARY 02 04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1920, "1581 DECEMBER 22 17:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 2000, "1582 JANUARY 26 18:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2080, "1582 FEBRUARY 28 19:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 2160, "1582 APRIL 05 20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 2240, "1582 MAY 10 21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 2320, "1582 JUNE 15 22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 2400, "1582 JUNE 21 23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 2480, "1582 AUGUST 01 00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 2560, "1582 SEPTEMBER 06 01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 2640, "1582 OCTOBER 03 02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2720, "1582 OCTOBER 26 03:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2800, "1583 JANUARY 01 04:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2880, "1986 JANUARY 01 17:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2960, "1986 FEBRUARY 05 18:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 3040, "1986 MARCH 10 19:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 3120, "1986 APRIL 15 20:30", (ftnlen)80, (ftnlen)19);
    s_copy(expctd + 3200, "1986 MAY 20 21:30", (ftnlen)80, (ftnlen)17);
    s_copy(expctd + 3280, "1986 JUNE 25 22:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 3360, "1986 JULY 01 23:30", (ftnlen)80, (ftnlen)18);
    s_copy(expctd + 3440, "1986 AUGUST 11 00:30", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 3520, "1986 SEPTEMBER 16 01:30", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 3600, "1986 OCTOBER 21 02:30", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3680, "1986 NOVEMBER 26 03:30", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 3760, "1987 JANUARY 01 04:30", (ftnlen)80, (ftnlen)21);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)733)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		739)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY MONTH DD ::UTC-07:30HR:MN.# .# SC. ::RND::JULIAN", (
	    ftnlen)80, (ftnlen)53);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 JANUARY 01 02:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)39);
    s_copy(expctd + 80, " -11 FEBRUARY 05 03:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 160, " -11 MARCH 10 04:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(expctd + 240, " -11 APRIL 15 05:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(expctd + 320, " -11 MAY 20 06:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 400, " -11 JUNE 25 07:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)36);
    s_copy(expctd + 480, " -11 JULY 01 08:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)36);
    s_copy(expctd + 560, " -11 AUGUST 10 09:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)38);
    s_copy(expctd + 640, " -11 SEPTEMBER 15 10:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)41);
    s_copy(expctd + 720, " -11 OCTOBER 20 11:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 800, " -11 NOVEMBER 25 12:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 880, " -11 DECEMBER 31 13:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 960, " 141 JANUARY 01 02:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 1040, " 141 FEBRUARY 05 03:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 1120, " 141 MARCH 10 04:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 1200, " 141 APRIL 15 05:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 1280, " 141 MAY 20 06:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 1360, " 141 JUNE 25 07:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 1440, " 141 JULY 01 08:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 1520, " 141 AUGUST 10 09:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 1600, " 141 SEPTEMBER 15 10:30.0 .# 00. ::JULIAN", (
	    ftnlen)80, (ftnlen)41);
    s_copy(expctd + 1680, " 141 OCTOBER 20 11:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 1760, " 141 NOVEMBER 25 12:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 1840, " 141 DECEMBER 31 13:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 1920, "1582 JANUARY 01 02:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 2000, "1582 FEBRUARY 05 03:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 2080, "1582 MARCH 10 04:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 2160, "1582 APRIL 15 05:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 2240, "1582 MAY 20 06:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 2320, "1582 JUNE 25 07:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 2400, "1582 JULY 01 08:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 2480, "1582 AUGUST 10 09:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 2560, "1582 SEPTEMBER 15 10:30.0 .# 00. ::JULIAN", (
	    ftnlen)80, (ftnlen)41);
    s_copy(expctd + 2640, "1582 OCTOBER 12 11:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 2720, "1582 OCTOBER 25 12:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 2800, "1582 DECEMBER 31 13:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 2880, "1986 JANUARY 01 02:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 2960, "1986 FEBRUARY 05 03:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 3040, "1986 MARCH 10 04:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 3120, "1986 APRIL 15 05:30.0 .# 00. ::JULIAN", (ftnlen)80,
	     (ftnlen)37);
    s_copy(expctd + 3200, "1986 MAY 20 06:30.0 .# 00. ::JULIAN", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 3280, "1986 JUNE 25 07:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 3360, "1986 JULY 01 08:30.0 .# 00. ::JULIAN", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 3440, "1986 AUGUST 10 09:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)38);
    s_copy(expctd + 3520, "1986 SEPTEMBER 15 10:30.0 .# 00. ::JULIAN", (
	    ftnlen)80, (ftnlen)41);
    s_copy(expctd + 3600, "1986 OCTOBER 20 11:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)39);
    s_copy(expctd + 3680, "1986 NOVEMBER 25 12:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    s_copy(expctd + 3760, "1986 DECEMBER 31 13:30.0 .# 00. ::JULIAN", (ftnlen)
	    80, (ftnlen)40);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)800)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		806)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "YYYY MONTH DD HR:MN.SC.### #", (ftnlen)80, (ftnlen)28);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 JANUARY 01 10:00.00.000 #", (ftnlen)80, (ftnlen)30);
    s_copy(expctd + 80, " -11 FEBRUARY 05 11:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 160, " -11 MARCH 10 12:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 240, " -11 APRIL 15 13:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 320, " -11 MAY 20 14:00.00.000 #", (ftnlen)80, (ftnlen)26)
	    ;
    s_copy(expctd + 400, " -11 JUNE 25 15:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 480, " -11 JULY 01 16:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 560, " -11 AUGUST 10 17:00.00.000 #", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 640, " -11 SEPTEMBER 15 18:00.00.000 #", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 720, " -11 OCTOBER 20 19:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 800, " -11 NOVEMBER 25 20:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 880, " -11 DECEMBER 31 21:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 960, " 141 JANUARY 01 10:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1040, " 141 FEBRUARY 05 11:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1120, " 141 MARCH 10 12:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1200, " 141 APRIL 15 13:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1280, " 141 MAY 20 14:00.00.000 #", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 1360, " 141 JUNE 25 15:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1440, " 141 JULY 01 16:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1520, " 141 AUGUST 10 17:00.00.000 #", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1600, " 141 SEPTEMBER 15 18:00.00.000 #", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1680, " 141 OCTOBER 20 19:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1760, " 141 NOVEMBER 25 20:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1840, " 141 DECEMBER 31 21:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1920, "1582 JANUARY 01 10:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2000, "1582 FEBRUARY 05 11:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2080, "1582 MARCH 10 12:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2160, "1582 APRIL 15 13:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2240, "1582 MAY 20 14:00.00.000 #", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 2320, "1582 JUNE 25 15:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2400, "1582 JULY 01 16:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2480, "1582 AUGUST 10 17:00.00.000 #", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2560, "1582 SEPTEMBER 15 18:00.00.000 #", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2640, "1582 OCTOBER 12 19:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2720, "1582 OCTOBER 25 20:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2800, "1582 DECEMBER 31 21:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2880, "1986 JANUARY 01 10:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2960, "1986 FEBRUARY 05 11:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3040, "1986 MARCH 10 12:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3120, "1986 APRIL 15 13:00.00.000 #", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3200, "1986 MAY 20 14:00.00.000 #", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 3280, "1986 JUNE 25 15:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3360, "1986 JULY 01 16:00.00.000 #", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3440, "1986 AUGUST 10 17:00.00.000 #", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3520, "1986 SEPTEMBER 15 18:00.00.000 #", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3600, "1986 OCTOBER 20 19:00.00.000 #", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3680, "1986 NOVEMBER 25 20:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3760, "1986 DECEMBER 31 21:00.00.000 #", (ftnlen)80, (
	    ftnlen)31);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)867)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		873)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "SP2000.####  ::TDB", (ftnlen)80, (ftnlen)18);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "-6.346097996E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 80, "-6.345795236E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 160, "-6.345509756E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 240, "-6.345198356E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 320, "-6.344895596E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 400, "-6.344584196E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 480, "-6.344531996E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 560, "-6.344186036E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 640, "-6.343874636E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 720, "-6.343571876E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 800, "-6.343260476E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 880, "-6.342949076E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 960, "-5.866431116E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1040, "-5.866128356E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1120, "-5.865842876E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1200, "-5.865531476E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1280, "-5.865228716E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1360, "-5.864917316E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1440, "-5.864865116E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1520, "-5.864519156E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1600, "-5.864207756E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1680, "-5.863904996E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1760, "-5.863593596E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1840, "-5.863282196E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1920, "-1.319078156E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2000, "-1.318775396E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2080, "-1.318489916E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2160, "-1.318178516E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2240, "-1.317875756E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2320, "-1.317564356E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2400, "-1.317512156E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2480, "-1.317166196E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2560, "-1.316854796E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2640, "-1.316621156E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2720, "-1.316508476E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2800, "-1.315929236E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2880, " -441770344.8161", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2960, " -438742744.8151", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3040, " -435887944.8145", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3120, " -432773944.8144", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3200, " -429746344.8149", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3280, " -426632344.8158", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3360, " -426110344.8160", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3440, " -422650744.8170", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3520, " -419536744.8176", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3600, " -416509144.8176", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3680, " -413395144.8171", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3760, " -410281144.8161", (ftnlen)80, (ftnlen)16);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)934)) * 80, &et, (ftnlen)
		80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		940)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)80)
		;
    }
    s_copy(pictur, "SP1950.####", (ftnlen)80, (ftnlen)11);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "-6.188310000E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 80, "-6.188007240E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 160, "-6.187721760E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 240, "-6.187410360E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 320, "-6.187107600E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 400, "-6.186796200E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 480, "-6.186744000E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 560, "-6.186398040E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 640, "-6.186086640E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 720, "-6.185783880E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 800, "-6.185472480E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 880, "-6.185161080E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 960, "-5.708643120E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1040, "-5.708340360E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1120, "-5.708054880E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1200, "-5.707743480E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1280, "-5.707440720E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1360, "-5.707129320E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1440, "-5.707077120E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1520, "-5.706731160E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1600, "-5.706419760E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1680, "-5.706117000E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1760, "-5.705805600E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1840, "-5.705494200E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1920, "-1.161290160E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2000, "-1.160987400E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2080, "-1.160701920E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2160, "-1.160390520E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2240, "-1.160087760E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2320, "-1.159776360E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2400, "-1.159724160E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2480, "-1.159378200E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2560, "-1.159066800E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2640, "-1.158833160E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2720, "-1.158720480E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2800, "-1.158141240E+10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2880, " 1136109600.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2960, " 1139137200.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3040, " 1141992000.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3120, " 1145106000.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3200, " 1148133600.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3280, " 1151247600.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3360, " 1151769600.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3440, " 1155229200.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3520, " 1158343200.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3600, " 1161370800.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3680, " 1164484800.0000", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3760, " 1167598800.0000", (ftnlen)80, (ftnlen)16);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1001)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1007)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY MONTH DD HR:MN:SC ::JCAL", (ftnlen)80, (ftnlen)29);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 JANUARY 03 10:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 80, " -11 FEBRUARY 07 11:00:00", (ftnlen)80, (ftnlen)25);
    s_copy(expctd + 160, " -11 MARCH 12 12:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 240, " -11 APRIL 17 13:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 320, " -11 MAY 22 14:00:00", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 400, " -11 JUNE 27 15:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 480, " -11 JULY 03 16:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 560, " -11 AUGUST 12 17:00:00", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 640, " -11 SEPTEMBER 17 18:00:00", (ftnlen)80, (ftnlen)26)
	    ;
    s_copy(expctd + 720, " -11 OCTOBER 22 19:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 800, " -11 NOVEMBER 27 20:00:00", (ftnlen)80, (ftnlen)25);
    s_copy(expctd + 880, " -10 JANUARY 02 21:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 960, " 141 JANUARY 02 10:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 1040, " 141 FEBRUARY 06 11:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 1120, " 141 MARCH 11 12:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1200, " 141 APRIL 16 13:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 1280, " 141 MAY 21 14:00:00", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 1360, " 141 JUNE 26 15:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1440, " 141 JULY 02 16:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1520, " 141 AUGUST 11 17:00:00", (ftnlen)80, (ftnlen)23);
    s_copy(expctd + 1600, " 141 SEPTEMBER 16 18:00:00", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 1680, " 141 OCTOBER 21 19:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 1760, " 141 NOVEMBER 26 20:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 1840, " 142 JANUARY 01 21:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 1920, "1581 DECEMBER 22 10:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 2000, "1582 JANUARY 26 11:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 2080, "1582 FEBRUARY 28 12:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 2160, "1582 APRIL 05 13:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 2240, "1582 MAY 10 14:00:00", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 2320, "1582 JUNE 15 15:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2400, "1582 JUNE 21 16:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2480, "1582 JULY 31 17:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2560, "1582 SEPTEMBER 05 18:00:00", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 2640, "1582 OCTOBER 02 19:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 2720, "1582 OCTOBER 15 20:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 2800, "1582 DECEMBER 21 21:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 2880, "1985 DECEMBER 19 10:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 2960, "1986 JANUARY 23 11:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 3040, "1986 FEBRUARY 25 12:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 3120, "1986 APRIL 02 13:00:00", (ftnlen)80, (ftnlen)22);
    s_copy(expctd + 3200, "1986 MAY 07 14:00:00", (ftnlen)80, (ftnlen)20);
    s_copy(expctd + 3280, "1986 JUNE 12 15:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3360, "1986 JUNE 18 16:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3440, "1986 JULY 28 17:00:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3520, "1986 SEPTEMBER 02 18:00:00", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 3600, "1986 OCTOBER 07 19:00:00", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 3680, "1986 NOVEMBER 12 20:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 3760, "1986 DECEMBER 18 21:00:00", (ftnlen)80, (ftnlen)25)
	    ;
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1068)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1074)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "JULIAND.#####", (ftnlen)80, (ftnlen)13);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "1717042.91666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 80, "1717077.95833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 160, "1717111.00000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 240, "1717147.04166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 320, "1717182.08333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 400, "1717218.12500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 480, "1717224.16666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 560, "1717264.20833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 640, "1717300.25000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 720, "1717335.29166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 800, "1717371.33333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 880, "1717407.37500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 960, "1772559.91666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1040, "1772594.95833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1120, "1772628.00000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1200, "1772664.04166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1280, "1772699.08333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1360, "1772735.12500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1440, "1772741.16666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1520, "1772781.20833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1600, "1772817.25000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1680, "1772852.29166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1760, "1772888.33333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1840, "1772924.37500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 1920, "2298873.91666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2000, "2298908.95833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2080, "2298942.00000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2160, "2298978.04166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2240, "2299013.08333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2320, "2299049.12500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2400, "2299055.16666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2480, "2299095.20833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2560, "2299131.25000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2640, "2299158.29166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2720, "2299171.33333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2800, "2299238.37500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2880, "2446431.91666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 2960, "2446466.95833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3040, "2446500.00000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3120, "2446536.04166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3200, "2446571.08333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3280, "2446607.12500", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3360, "2446613.16666", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3440, "2446653.20833", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3520, "2446689.25000", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3600, "2446724.29166", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3680, "2446760.33333", (ftnlen)80, (ftnlen)13);
    s_copy(expctd + 3760, "2446796.37500", (ftnlen)80, (ftnlen)13);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1135)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1141)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY Month DD HR:MN:SC Weekday", (ftnlen)80, (ftnlen)30);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, " -11 January 01 10:00:00 Sunday", (ftnlen)80, (ftnlen)31);
    s_copy(expctd + 80, " -11 February 05 11:00:00 Sunday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 160, " -11 March 10 12:00:00 Friday", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 240, " -11 April 15 13:00:00 Saturday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 320, " -11 May 20 14:00:00 Saturday", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 400, " -11 June 25 15:00:00 Sunday", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 480, " -11 July 01 16:00:00 Saturday", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 560, " -11 August 10 17:00:00 Thursday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 640, " -11 September 15 18:00:00 Friday", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 720, " -11 October 20 19:00:00 Friday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 800, " -11 November 25 20:00:00 Saturday", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 880, " -11 December 31 21:00:00 Sunday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 960, " 141 January 01 10:00:00 Sunday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1040, " 141 February 05 11:00:00 Sunday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1120, " 141 March 10 12:00:00 Friday", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1200, " 141 April 15 13:00:00 Saturday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1280, " 141 May 20 14:00:00 Saturday", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1360, " 141 June 25 15:00:00 Sunday", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1440, " 141 July 01 16:00:00 Saturday", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1520, " 141 August 10 17:00:00 Thursday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1600, " 141 September 15 18:00:00 Friday", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1680, " 141 October 20 19:00:00 Friday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1760, " 141 November 25 20:00:00 Saturday", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 1840, " 141 December 31 21:00:00 Sunday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1920, "1582 January 01 10:00:00 Friday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2000, "1582 February 05 11:00:00 Friday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2080, "1582 March 10 12:00:00 Wednesday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2160, "1582 April 15 13:00:00 Thursday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2240, "1582 May 20 14:00:00 Thursday", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2320, "1582 June 25 15:00:00 Friday", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2400, "1582 July 01 16:00:00 Thursday", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2480, "1582 August 10 17:00:00 Tuesday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2560, "1582 September 15 18:00:00 Wednesday", (ftnlen)80, 
	    (ftnlen)36);
    s_copy(expctd + 2640, "1582 October 12 19:00:00 Tuesday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2720, "1582 October 25 20:00:00 Monday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2800, "1582 December 31 21:00:00 Friday", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2880, "1986 January 01 10:00:00 Wednesday", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 2960, "1986 February 05 11:00:00 Wednesday", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 3040, "1986 March 10 12:00:00 Monday", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3120, "1986 April 15 13:00:00 Tuesday", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3200, "1986 May 20 14:00:00 Tuesday", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 3280, "1986 June 25 15:00:00 Wednesday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3360, "1986 July 01 16:00:00 Tuesday", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3440, "1986 August 10 17:00:00 Sunday", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3520, "1986 September 15 18:00:00 Monday", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3600, "1986 October 20 19:00:00 Monday", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3680, "1986 November 25 20:00:00 Tuesday", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3760, "1986 December 31 21:00:00 Wednesday", (ftnlen)80, (
	    ftnlen)35);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1202)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1208)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY ERA Month DD HR:MN:SC.###", (ftnlen)80, (ftnlen)30);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "  12 B.C. January 01 10:00:00.000", (ftnlen)80, (ftnlen)
	    33);
    s_copy(expctd + 80, "  12 B.C. February 05 11:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 160, "  12 B.C. March 10 12:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 240, "  12 B.C. April 15 13:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 320, "  12 B.C. May 20 14:00:00.000", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 400, "  12 B.C. June 25 15:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 480, "  12 B.C. July 01 16:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 560, "  12 B.C. August 10 17:00:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 640, "  12 B.C. September 15 18:00:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 720, "  12 B.C. October 20 19:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 800, "  12 B.C. November 25 20:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 880, "  12 B.C. December 31 21:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 960, " 141 A.D. January 01 10:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1040, " 141 A.D. February 05 11:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 1120, " 141 A.D. March 10 12:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1200, " 141 A.D. April 15 13:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 1280, " 141 A.D. May 20 14:00:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1360, " 141 A.D. June 25 15:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1440, " 141 A.D. July 01 16:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1520, " 141 A.D. August 10 17:00:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 1600, " 141 A.D. September 15 18:00:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 1680, " 141 A.D. October 20 19:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 1760, " 141 A.D. November 25 20:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 1840, " 141 A.D. December 31 21:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 1920, "1582 A.D. January 01 10:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2000, "1582 A.D. February 05 11:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 2080, "1582 A.D. March 10 12:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2160, "1582 A.D. April 15 13:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 2240, "1582 A.D. May 20 14:00:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 2320, "1582 A.D. June 25 15:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2400, "1582 A.D. July 01 16:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2480, "1582 A.D. August 10 17:00:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2560, "1582 A.D. September 15 18:00:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 2640, "1582 A.D. October 12 19:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2720, "1582 A.D. October 25 20:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2800, "1582 A.D. December 31 21:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 2880, "1986 A.D. January 01 10:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 2960, "1986 A.D. February 05 11:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 3040, "1986 A.D. March 10 12:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3120, "1986 A.D. April 15 13:00:00.000", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3200, "1986 A.D. May 20 14:00:00.000", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3280, "1986 A.D. June 25 15:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3360, "1986 A.D. July 01 16:00:00.000", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 3440, "1986 A.D. August 10 17:00:00.000", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 3520, "1986 A.D. September 15 18:00:00.000", (ftnlen)80, (
	    ftnlen)35);
    s_copy(expctd + 3600, "1986 A.D. October 20 19:00:00.000", (ftnlen)80, (
	    ftnlen)33);
    s_copy(expctd + 3680, "1986 A.D. November 25 20:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    s_copy(expctd + 3760, "1986 A.D. December 31 21:00:00.000", (ftnlen)80, (
	    ftnlen)34);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1269)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1275)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY ERA MM/DD HR:MN ::TRNC", (ftnlen)80, (ftnlen)27);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "  12 B.C. 01/01 10:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 80, "  12 B.C. 02/05 11:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 160, "  12 B.C. 03/10 12:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 240, "  12 B.C. 04/15 13:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 320, "  12 B.C. 05/20 14:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 400, "  12 B.C. 06/25 15:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 480, "  12 B.C. 07/01 16:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 560, "  12 B.C. 08/10 17:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 640, "  12 B.C. 09/15 18:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 720, "  12 B.C. 10/20 19:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 800, "  12 B.C. 11/25 20:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 880, "  12 B.C. 12/31 21:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 960, " 141 A.D. 01/01 10:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1040, " 141 A.D. 02/05 11:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1120, " 141 A.D. 03/10 12:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1200, " 141 A.D. 04/15 13:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1280, " 141 A.D. 05/20 14:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1360, " 141 A.D. 06/25 15:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1440, " 141 A.D. 07/01 16:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1520, " 141 A.D. 08/10 17:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1600, " 141 A.D. 09/15 18:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1680, " 141 A.D. 10/20 19:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1760, " 141 A.D. 11/25 20:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1840, " 141 A.D. 12/31 21:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 1920, "1582 A.D. 01/01 10:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2000, "1582 A.D. 02/05 11:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2080, "1582 A.D. 03/10 12:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2160, "1582 A.D. 04/15 13:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2240, "1582 A.D. 05/20 14:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2320, "1582 A.D. 06/25 15:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2400, "1582 A.D. 07/01 16:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2480, "1582 A.D. 08/10 17:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2560, "1582 A.D. 09/15 18:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2640, "1582 A.D. 10/12 19:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2720, "1582 A.D. 10/25 20:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2800, "1582 A.D. 12/31 21:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2880, "1986 A.D. 01/01 10:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 2960, "1986 A.D. 02/05 11:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3040, "1986 A.D. 03/10 12:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3120, "1986 A.D. 04/15 13:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3200, "1986 A.D. 05/20 14:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3280, "1986 A.D. 06/25 15:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3360, "1986 A.D. 07/01 16:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3440, "1986 A.D. 08/10 17:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3520, "1986 A.D. 09/15 18:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3600, "1986 A.D. 10/20 19:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3680, "1986 A.D. 11/25 20:00", (ftnlen)80, (ftnlen)21);
    s_copy(expctd + 3760, "1986 A.D. 12/31 21:00", (ftnlen)80, (ftnlen)21);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1336)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1342)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY ERA MONTH DD WEEKDAY", (ftnlen)80, (ftnlen)25);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "  12 B.C. JANUARY 01 SUNDAY", (ftnlen)80, (ftnlen)27);
    s_copy(expctd + 80, "  12 B.C. FEBRUARY 05 SUNDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 160, "  12 B.C. MARCH 10 FRIDAY", (ftnlen)80, (ftnlen)25);
    s_copy(expctd + 240, "  12 B.C. APRIL 15 SATURDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 320, "  12 B.C. MAY 20 SATURDAY", (ftnlen)80, (ftnlen)25);
    s_copy(expctd + 400, "  12 B.C. JUNE 25 SUNDAY", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 480, "  12 B.C. JULY 01 SATURDAY", (ftnlen)80, (ftnlen)26)
	    ;
    s_copy(expctd + 560, "  12 B.C. AUGUST 10 THURSDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 640, "  12 B.C. SEPTEMBER 15 FRIDAY", (ftnlen)80, (ftnlen)
	    29);
    s_copy(expctd + 720, "  12 B.C. OCTOBER 20 FRIDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 800, "  12 B.C. NOVEMBER 25 SATURDAY", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 880, "  12 B.C. DECEMBER 31 SUNDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 960, " 141 A.D. JANUARY 01 SUNDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1040, " 141 A.D. FEBRUARY 05 SUNDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1120, " 141 A.D. MARCH 10 FRIDAY", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 1200, " 141 A.D. APRIL 15 SATURDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1280, " 141 A.D. MAY 20 SATURDAY", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 1360, " 141 A.D. JUNE 25 SUNDAY", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 1440, " 141 A.D. JULY 01 SATURDAY", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 1520, " 141 A.D. AUGUST 10 THURSDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1600, " 141 A.D. SEPTEMBER 15 FRIDAY", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 1680, " 141 A.D. OCTOBER 20 FRIDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 1760, " 141 A.D. NOVEMBER 25 SATURDAY", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 1840, " 141 A.D. DECEMBER 31 SUNDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 1920, "1582 A.D. JANUARY 01 FRIDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2000, "1582 A.D. FEBRUARY 05 FRIDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2080, "1582 A.D. MARCH 10 WEDNESDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2160, "1582 A.D. APRIL 15 THURSDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2240, "1582 A.D. MAY 20 THURSDAY", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 2320, "1582 A.D. JUNE 25 FRIDAY", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 2400, "1582 A.D. JULY 01 THURSDAY", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 2480, "1582 A.D. AUGUST 10 TUESDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2560, "1582 A.D. SEPTEMBER 15 WEDNESDAY", (ftnlen)80, (
	    ftnlen)32);
    s_copy(expctd + 2640, "1582 A.D. OCTOBER 12 TUESDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2720, "1582 A.D. OCTOBER 25 MONDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 2800, "1582 A.D. DECEMBER 31 FRIDAY", (ftnlen)80, (ftnlen)
	    28);
    s_copy(expctd + 2880, "1986 A.D. JANUARY 01 WEDNESDAY", (ftnlen)80, (
	    ftnlen)30);
    s_copy(expctd + 2960, "1986 A.D. FEBRUARY 05 WEDNESDAY", (ftnlen)80, (
	    ftnlen)31);
    s_copy(expctd + 3040, "1986 A.D. MARCH 10 MONDAY", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 3120, "1986 A.D. APRIL 15 TUESDAY", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 3200, "1986 A.D. MAY 20 TUESDAY", (ftnlen)80, (ftnlen)24);
    s_copy(expctd + 3280, "1986 A.D. JUNE 25 WEDNESDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3360, "1986 A.D. JULY 01 TUESDAY", (ftnlen)80, (ftnlen)25)
	    ;
    s_copy(expctd + 3440, "1986 A.D. AUGUST 10 SUNDAY", (ftnlen)80, (ftnlen)
	    26);
    s_copy(expctd + 3520, "1986 A.D. SEPTEMBER 15 MONDAY", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3600, "1986 A.D. OCTOBER 20 MONDAY", (ftnlen)80, (ftnlen)
	    27);
    s_copy(expctd + 3680, "1986 A.D. NOVEMBER 25 TUESDAY", (ftnlen)80, (
	    ftnlen)29);
    s_copy(expctd + 3760, "1986 A.D. DECEMBER 31 WEDNESDAY", (ftnlen)80, (
	    ftnlen)31);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1403)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1409)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "YYYY era MON DD", (ftnlen)80, (ftnlen)15);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "  12 b.c. JAN 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 80, "  12 b.c. FEB 05", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 160, "  12 b.c. MAR 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 240, "  12 b.c. APR 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 320, "  12 b.c. MAY 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 400, "  12 b.c. JUN 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 480, "  12 b.c. JUL 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 560, "  12 b.c. AUG 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 640, "  12 b.c. SEP 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 720, "  12 b.c. OCT 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 800, "  12 b.c. NOV 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 880, "  12 b.c. DEC 31", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 960, " 141 a.d. JAN 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1040, " 141 a.d. FEB 05", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1120, " 141 a.d. MAR 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1200, " 141 a.d. APR 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1280, " 141 a.d. MAY 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1360, " 141 a.d. JUN 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1440, " 141 a.d. JUL 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1520, " 141 a.d. AUG 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1600, " 141 a.d. SEP 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1680, " 141 a.d. OCT 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1760, " 141 a.d. NOV 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1840, " 141 a.d. DEC 31", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 1920, "1582 a.d. JAN 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2000, "1582 a.d. FEB 05", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2080, "1582 a.d. MAR 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2160, "1582 a.d. APR 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2240, "1582 a.d. MAY 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2320, "1582 a.d. JUN 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2400, "1582 a.d. JUL 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2480, "1582 a.d. AUG 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2560, "1582 a.d. SEP 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2640, "1582 a.d. OCT 12", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2720, "1582 a.d. OCT 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2800, "1582 a.d. DEC 31", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2880, "1986 a.d. JAN 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 2960, "1986 a.d. FEB 05", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3040, "1986 a.d. MAR 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3120, "1986 a.d. APR 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3200, "1986 a.d. MAY 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3280, "1986 a.d. JUN 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3360, "1986 a.d. JUL 01", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3440, "1986 a.d. AUG 10", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3520, "1986 a.d. SEP 15", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3600, "1986 a.d. OCT 20", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3680, "1986 a.d. NOV 25", (ftnlen)80, (ftnlen)16);
    s_copy(expctd + 3760, "1986 a.d. DEC 31", (ftnlen)80, (ftnlen)16);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1470)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1476)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "JULIAND.####### ::TDB", (ftnlen)80, (ftnlen)21);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "1717042.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 80, "1717077.9588100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 160, "1717111.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 240, "1717147.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 320, "1717182.0838100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 400, "1717218.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 480, "1717224.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 560, "1717264.2088099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 640, "1717300.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 720, "1717335.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 800, "1717371.3338099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 880, "1717407.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 960, "1772559.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1040, "1772594.9588100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1120, "1772628.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1200, "1772664.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1280, "1772699.0838100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1360, "1772735.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1440, "1772741.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1520, "1772781.2088099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1600, "1772817.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1680, "1772852.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1760, "1772888.3338099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1840, "1772924.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1920, "2298873.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2000, "2298908.9588100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2080, "2298942.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2160, "2298978.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2240, "2299013.0838100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2320, "2299049.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2400, "2299055.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2480, "2299095.2088099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2560, "2299131.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2640, "2299158.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2720, "2299171.3338099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2800, "2299238.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2880, "2446431.9173053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2960, "2446466.9589720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3040, "2446500.0006387", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3120, "2446536.0423053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3200, "2446571.0839720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3280, "2446607.1256387", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3360, "2446613.1673053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3440, "2446653.2089720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3520, "2446689.2506386", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3600, "2446724.2923053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3680, "2446760.3339720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3760, "2446796.3756387", (ftnlen)80, (ftnlen)15);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1537)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1543)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }
    s_copy(pictur, "JULIAND.####### ::TDT", (ftnlen)80, (ftnlen)21);
    tcase_(pictur, (ftnlen)80);
    timdef_("SET", "CALENDAR", "GREGORIAN", (ftnlen)3, (ftnlen)8, (ftnlen)9);
    timdef_("SET", "SYSTEM", "UTC", (ftnlen)3, (ftnlen)6, (ftnlen)3);
    s_copy(expctd, "1717042.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 80, "1717077.9588099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 160, "1717111.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 240, "1717147.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 320, "1717182.0838099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 400, "1717218.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 480, "1717224.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 560, "1717264.2088099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 640, "1717300.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 720, "1717335.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 800, "1717371.3338099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 880, "1717407.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 960, "1772559.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1040, "1772594.9588099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1120, "1772628.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1200, "1772664.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1280, "1772699.0838099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1360, "1772735.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1440, "1772741.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1520, "1772781.2088099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1600, "1772817.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1680, "1772852.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1760, "1772888.3338099", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1840, "1772924.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 1920, "2298873.9171433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2000, "2298908.9588100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2080, "2298942.0004766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2160, "2298978.0421433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2240, "2299013.0838100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2320, "2299049.1254766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2400, "2299055.1671433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2480, "2299095.2088100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2560, "2299131.2504766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2640, "2299158.2921433", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2720, "2299171.3338100", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2800, "2299238.3754766", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2880, "2446431.9173053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 2960, "2446466.9589720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3040, "2446500.0006387", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3120, "2446536.0423053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3200, "2446571.0839720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3280, "2446607.1256387", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3360, "2446613.1673053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3440, "2446653.2089720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3520, "2446689.2506387", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3600, "2446724.2923053", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3680, "2446760.3339720", (ftnlen)80, (ftnlen)15);
    s_copy(expctd + 3760, "2446796.3756387", (ftnlen)80, (ftnlen)15);
    for (i__ = 1; i__ <= 48; ++i__) {
	str2et_(times + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"times", i__1, "f_timcvr__", (ftnlen)1604)) * 80, &et, (
		ftnlen)80);
	timout_(&et, pictur, ftime, (ftnlen)80, (ftnlen)80);
	s_copy(name__, "FTIME(#)", (ftnlen)32, (ftnlen)8);
	repmi_(name__, "#", &i__, name__, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_(name__, ftime, "=", expctd + ((i__1 = i__ - 1) < 48 && 0 <= 
		i__1 ? i__1 : s_rnge("expctd", i__1, "f_timcvr__", (ftnlen)
		1610)) * 80, ok, (ftnlen)32, (ftnlen)80, (ftnlen)1, (ftnlen)
		80);
    }

/*     All 'DO Loops' have been executed. */
/*     All 'IF branches' have been executed. */


/*     Clean up after ourselves.  Clear the kernel pool. */

    clpool_();
    t_success__(ok);
    return 0;
} /* f_timcvr__ */

