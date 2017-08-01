/* f_zztime.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__3 = 3;
static integer c__1000 = 1000;
static integer c_b436 = 1000000;
static integer c__6 = 6;
static doublereal c_b503 = 0.;
static integer c__5 = 5;

/* $Procedure      F_ZZTIME ( Family of tests for ZZTIME ) */
/* Subroutine */ int f_zztime__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer i_indx(char *, char *, ftnlen, ftnlen), s_rnge(char *, integer, 
	    char *, integer), s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern logical zztokns_(char *, char *, ftnlen, ftnlen);
    char good[80], erep[16];
    doublereal tvec[10];
    integer expn, b, e, i__, j;
    extern /* Subroutine */ int tcase_(char *, ftnlen), ucase_(char *, char *,
	     ftnlen, ftnlen);
    doublereal etvec[10];
    integer ntvec;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[240], m1[2], m2[2], w1[16], w2[16];
    extern /* Subroutine */ int t_success__(logical *);
    extern logical zzist_(char *, ftnlen);
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksc_(char *, char *, char *, char *, logical *, ftnlen, 
	    ftnlen, ftnlen, ftnlen);
    logical shdiag;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char cmline[80], pieces[16*87];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), getcml_(char *, ftnlen);
    logical yabbrv;
    char etrans[16], transl[16], string[80], experr[80];
    extern /* Subroutine */ int suffix_(char *, integer *, char *, ftnlen, 
	    ftnlen);
    extern logical zzcmbt_(char *, char *, logical *, ftnlen, ftnlen);
    extern /* Subroutine */ int nextwd_(char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen), tstlog_(char *, logical *, ftnlen);
    char mstyle[80];
    extern /* Subroutine */ int tstmsc_(char *, ftnlen);
    logical l2r;
    extern logical zzgrep_(char *, ftnlen);
    logical r2l;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstlgs_(char *, char *, ftnlen, ftnlen);
    extern logical zznote_(char *, integer *, integer *, ftnlen), zzvalt_(
	    char *, integer *, integer *, char *, ftnlen, ftnlen), zzremt_(
	    char *, ftnlen), zzrept_(char *, char *, logical *, ftnlen, 
	    ftnlen), zzsubt_(char *, char *, logical *, ftnlen, ftnlen), 
	    zzispt_(char *, integer *, integer *, ftnlen);
    char bad[80];
    extern /* Subroutine */ int tststy_(char *, char *, ftnlen, ftnlen);
    logical did;
    char pic[80], rep[16];
    logical got;
    extern logical zzunpck_(char *, logical *, doublereal *, integer *, char *
	    , char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);

/* $ Abstract */

/*     This is a family of tests for the private routine ZZTIME. */

/*     Part of the utility of ZZTIME is it's ability to diagnose */
/*     problems with an input time string.  Although it is probably */
/*     not desirable to construct expected diagnostic strings, it */
/*     is useful to review them.  This test family has incorporated */
/*     test cases designed to produce every type of diagnostic that */
/*     can be returned from ZZUNPCK.  To see these, you should */
/*     add the following parameter to the command line when */
/*     you run the parent test program that calls F_ZZTIME */

/*        T_<program> [verbosity options] -diags */

/*     The diagnostics will then be printed on the screen and in */
/*     the output log file allowing you to inspect these strings */
/*     for grammer, spelling, etc. */
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

    topen_("F_ZZTIME", (ftnlen)8);
    s_copy(mstyle, "LEFT 5 RIGHT 75 FLAG Diagnostic: ", (ftnlen)80, (ftnlen)
	    33);
    l2r = TRUE_;
    r2l = ! l2r;
    yabbrv = FALSE_;
    getcml_(cmline, (ftnlen)80);
    ucase_(cmline, cmline, (ftnlen)80, (ftnlen)80);
    shdiag = i_indx(cmline, "-DIAGS", (ftnlen)80, (ftnlen)6) > 0;
    tcase_("Check that that tokenization process behaves as expected. ", (
	    ftnlen)58);
    s_copy(pieces, "PDT Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 16, "pst Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 32, "CDT Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 48, "CST Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 64, "MST Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 80, "MDT Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 96, "EST Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 112, "EDT Z", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 128, "UTC+ O", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 144, "UTC- o", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 160, "TDT s", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 176, "TDB s", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 192, "JD j", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 208, "JD j", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 224, "( [", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 240, ") ]", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 256, ". .", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 272, ": :", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 288, ":: d", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 304, "// d", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 320, "/ /", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 336, "January m", (ftnlen)16, (ftnlen)9);
    s_copy(pieces + 352, "February m", (ftnlen)16, (ftnlen)10);
    s_copy(pieces + 368, "March m", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 384, "April m", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 400, "May m", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 416, "June m", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 432, "July m", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 448, "August m", (ftnlen)16, (ftnlen)8);
    s_copy(pieces + 464, "September m", (ftnlen)16, (ftnlen)11);
    s_copy(pieces + 480, "October m", (ftnlen)16, (ftnlen)9);
    s_copy(pieces + 496, "November m", (ftnlen)16, (ftnlen)10);
    s_copy(pieces + 512, "December m", (ftnlen)16, (ftnlen)10);
    s_copy(pieces + 528, "jan, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 544, "feb m", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 560, "mar, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 576, "apr m", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 592, "may m", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 608, "jun, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 624, "jul m", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 640, "aug, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 656, "sept, m,", (ftnlen)16, (ftnlen)8);
    s_copy(pieces + 672, "oct, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 688, "nov, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 704, "dec, m,", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 720, "mon. w.", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 736, "tues. w.", (ftnlen)16, (ftnlen)8);
    s_copy(pieces + 752, "wed. w.", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 768, "thu w", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 784, "fri. w.", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 800, "sat. w.", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 816, "sun. w.", (ftnlen)16, (ftnlen)7);
    s_copy(pieces + 832, "a.d. e", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 848, "ad e", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 864, "b.c. e", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 880, "bc e", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 896, "1768 i", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 912, "12 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 928, "1 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 944, "2 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 960, "3 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 976, "4 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 992, "5 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1008, "6 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1024, "7 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1040, "8 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1056, "9 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1072, "0 i", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1088, "10 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1104, "21 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1120, "22 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1136, "23 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1152, "24 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1168, "25 i", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1184, ". .", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1200, ", ,", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1216, "' '", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1232, "- -", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1248, "am N", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1264, "a.m. N", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 1280, "pm N", (ftnlen)16, (ftnlen)4);
    s_copy(pieces + 1296, "p.m. N", (ftnlen)16, (ftnlen)6);
    s_copy(pieces + 1312, "t t", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1328, "T t", (ftnlen)16, (ftnlen)3);
    s_copy(pieces + 1344, "TDB s", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 1360, "TDT s", (ftnlen)16, (ftnlen)5);
    s_copy(pieces + 1376, "UTC s", (ftnlen)16, (ftnlen)5);
    for (i__ = 80; i__ <= 87; ++i__) {
	nextwd_(pieces + (((i__1 = i__ - 1) < 87 && 0 <= i__1 ? i__1 : s_rnge(
		"pieces", i__1, "f_zztime__", (ftnlen)235)) << 4), w1, m1, (
		ftnlen)16, (ftnlen)16, (ftnlen)2);
	for (j = 1; j <= 20; ++j) {
	    nextwd_(pieces + (((i__1 = j - 1) < 87 && 0 <= i__1 ? i__1 : 
		    s_rnge("pieces", i__1, "f_zztime__", (ftnlen)238)) << 4), 
		    w2, m2, (ftnlen)16, (ftnlen)16, (ftnlen)2);
	    s_copy(erep, m1, (ftnlen)16, (ftnlen)2);
	    suffix_(m2, &c__0, erep, (ftnlen)2, (ftnlen)16);
	    s_copy(string, w1, (ftnlen)80, (ftnlen)16);
	    suffix_(w2, &c__0, string, (ftnlen)16, (ftnlen)80);
	    if (s_cmp(erep, "ii", (ftnlen)16, (ftnlen)2) == 0) {
		s_copy(erep, "i", (ftnlen)16, (ftnlen)1);
	    } else if (s_cmp(string, "::", (ftnlen)80, (ftnlen)2) == 0) {
		s_copy(erep, "d", (ftnlen)16, (ftnlen)1);
	    } else if (s_cmp(string, ":::", (ftnlen)80, (ftnlen)3) == 0) {
		s_copy(erep, "d:", (ftnlen)16, (ftnlen)2);
	    } else if (s_cmp(string, "//", (ftnlen)80, (ftnlen)2) == 0) {
		s_copy(erep, "d", (ftnlen)16, (ftnlen)1);
	    } else if (s_cmp(string, "///", (ftnlen)80, (ftnlen)3) == 0) {
		s_copy(erep, "d/", (ftnlen)16, (ftnlen)2);
	    } else if (s_cmp(string, "UTC-", (ftnlen)80, (ftnlen)4) == 0) {
		s_copy(erep, "o", (ftnlen)16, (ftnlen)1);
	    }
	    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
	    got = zzgrep_(rep, (ftnlen)16);
	    tstmsg_("#", "The value of string was: \"#\"", (ftnlen)1, (ftnlen)
		    28);
	    tstmsc_(string, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
	    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
	    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)
		    1, (ftnlen)16);
	    s_copy(erep, m1, (ftnlen)16, (ftnlen)2);
	    suffix_("b", &c__0, erep, (ftnlen)1, (ftnlen)16);
	    suffix_(m2, &c__0, erep, (ftnlen)2, (ftnlen)16);
	    s_copy(string, w1, (ftnlen)80, (ftnlen)16);
	    suffix_(w2, &c__3, string, (ftnlen)16, (ftnlen)80);
	    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
	    got = zzgrep_(rep, (ftnlen)16);
	    tstmsg_("#", "The value of string was: \"#\"", (ftnlen)1, (ftnlen)
		    28);
	    tstmsc_(string, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
	    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
	    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)
		    1, (ftnlen)16);
	}
    }
    tstmsg_(" ", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that ZZNOTE can retrieve components from a date proper"
	    "ly and that the representation is properly reduced. ", (ftnlen)
	    116);
    s_copy(string, "12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)31);
    s_copy(erep, "ibmbibe,bi:i:ibN", (ftnlen)16, (ftnlen)16);
    s_copy(error, "xxx", (ftnlen)240, (ftnlen)3);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zznote_("e", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "ibmbib,bi:i:ibN", (ftnlen)16, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksc_("STRING(B:E)", string + (b - 1), "=", "A.D.", ok, (ftnlen)11, e - 
	    (b - 1), (ftnlen)1, (ftnlen)4);
    tcase_("Make sure that items are properly removed by calls to ZZREMT and"
	    " that ZZNOTE can still locate tokens after such removals. ", (
	    ftnlen)122);
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;
    s_copy(erep, "bibmbibe,bi:i:ibN", (ftnlen)16, (ftnlen)17);
    s_copy(error, "xxx", (ftnlen)240, (ftnlen)3);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID1", &did, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zzremt_("b", (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:i:iN", (ftnlen)16, (ftnlen)11);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID3", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zzremt_("b", (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:i:iN", (ftnlen)16, (ftnlen)11);
    chcksl_("GOT", &got, &c_false, ok, (ftnlen)3);
    chcksl_("DID4", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zznote_("e", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imi,i:i:iN", (ftnlen)16, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID5", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksc_("STRING(B:E)", string + (b - 1), "=", "A.D.", ok, (ftnlen)11, e - 
	    (b - 1), (ftnlen)1, (ftnlen)4);
    tcase_("Make sure that tokens can be combined successfully. ", (ftnlen)52)
	    ;
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;
    s_copy(erep, "bibmbibe,bi:i:ibN", (ftnlen)16, (ftnlen)17);
    s_copy(error, "xxx", (ftnlen)240, (ftnlen)3);

/*        First tokenize the string and make sure it has the */
/*        expected tokenization. */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID1", &did, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP1", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        Now remove 'b' from the tokenization and check the */
/*        representation. */

    got = zzremt_("b", (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:i:iN", (ftnlen)16, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID3", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP2", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        Combine a few tokens and see if we have the expected */
/*        representation. */

    got = zzcmbt_("i:i", "K", &r2l, (ftnlen)3, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:KN", (ftnlen)16, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID4", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP3", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        See if the 'K' in the current tokenization maps to the */
/*        expected substring and check the NOTEd representation. */

    got = zznote_("K", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:N", (ftnlen)16, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID5", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP4", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksc_("STRING(B:E)", string + (b - 1), "=", "12:18", ok, (ftnlen)11, e 
	    - (b - 1), (ftnlen)1, (ftnlen)5);

/*        Combine tokens again and go through the same steps as */
/*        the last block of code. */

    got = zzcmbt_("imie", "K", &l2r, (ftnlen)4, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "K,i:N", (ftnlen)16, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID6", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP5", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zznote_("K", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, ",i:N", (ftnlen)16, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID7", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP6", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksc_("STRING(B:E)", string + (b - 1), "=", "12 JAN 1992 A.D.", ok, (
	    ftnlen)11, e - (b - 1), (ftnlen)1, (ftnlen)16);

/*        Now try combining something that's not present. */

    got = zzcmbt_("i:i", "K", &l2r, (ftnlen)3, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, ",i:N", (ftnlen)16, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_false, ok, (ftnlen)3);
    chcksl_("DID6", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP5", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zznote_("K", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, ",i:N", (ftnlen)16, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_false, ok, (ftnlen)3);
    chcksl_("DID7", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP6", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksi_("B", &b, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksi_("E", &e, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that the entry point ZZSUBT works as expected. ", (
	    ftnlen)57);
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string and remove blanks. */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    got = zzremt_("b", (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,i:i:iN", (ftnlen)16, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID1", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP1", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        Now perform a left to right substitution. */

    got = zzsubt_("i:i", "H:M", &l2r, (ftnlen)3, (ftnlen)3);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,H:M:iN", (ftnlen)16, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP2", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        Try another left to right substitution, this should */
/*        turn up with no substitution. */

    got = zzsubt_("i:i", "M:S", &l2r, (ftnlen)3, (ftnlen)3);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,H:M:iN", (ftnlen)16, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_false, ok, (ftnlen)3);
    chcksl_("DID3", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP3", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);

/*        Get the value associated with H and make sure */
/*        it's the correct value. */

    got = zznote_("H", &b, &e, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "imie,:M:iN", (ftnlen)16, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID4", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP4", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    chcksc_("STRING(B:E)", string + (b - 1), "=", "11", ok, (ftnlen)11, e - (
	    b - 1), (ftnlen)1, (ftnlen)2);

/*        Perform a right to left substitution and make sure the */
/*        representation changes as expected. */

    got = zzsubt_("imi", "YmD", &r2l, (ftnlen)3, (ftnlen)3);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "YmDe,:M:iN", (ftnlen)16, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID5", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP5", rep, "=", erep, ok, (ftnlen)4, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    tcase_("Check to make sure that a pair of consecutinve delimiters is rec"
	    "ognized by ZZISPT. ", (ftnlen)83);
    s_copy(string, " 12 JAN 1992 A.D.,/ 11:12:18 P.M.", (ftnlen)80, (ftnlen)
	    33);

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    got = zzispt_(",/:", &b, &e, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_true, ok, (ftnlen)3);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("STRING(B:E)", string + (b - 1), "=", ",/", ok, (ftnlen)11, e - (
	    b - 1), (ftnlen)1, (ftnlen)2);
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    got = zzispt_(string, &b, &e, (ftnlen)80);
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    got = zzispt_(",/:", &b, &e, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT", &got, &c_false, ok, (ftnlen)3);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksi_("B", &b, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksi_("E", &e, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that the function ZZIST works as expected. ", (ftnlen)
	    53);
    s_copy(string, " 12 JAN 1992 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    got = zzist_("i", (ftnlen)1);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    got = zzist_("m", (ftnlen)1);
    chcksl_("GOT2", &got, &c_true, ok, (ftnlen)4);
    got = zzist_(":", (ftnlen)1);
    chcksl_("GOT3", &got, &c_true, ok, (ftnlen)4);
    got = zzist_("e", (ftnlen)1);
    chcksl_("GOT4", &got, &c_true, ok, (ftnlen)4);
    got = zzist_("q", (ftnlen)1);
    chcksl_("GOT5", &got, &c_false, ok, (ftnlen)4);
    got = zzist_("N", (ftnlen)1);
    chcksl_("GOT6", &got, &c_true, ok, (ftnlen)4);
    got = zzist_("Z", (ftnlen)1);
    chcksl_("GOT7", &got, &c_false, ok, (ftnlen)4);
    tcase_("Verify that ZZVALT replaces tokens when it should and that it le"
	    "aves them alone when there is nothing to do. ", (ftnlen)109);
    s_copy(string, " 12 JAN 2012 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    got = zzvalt_(string, &c__1000, &c_b436, "Y", (ftnlen)80, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "bibmbYbe,bi:i:ibN", (ftnlen)16, (ftnlen)17);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zzvalt_(string, &c__1000, &c_b436, "K", (ftnlen)80, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "bibmbYbe,bi:i:ibN", (ftnlen)16, (ftnlen)17);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    tcase_("Check to make sure that ZZUNPCK can unpack items from a string. ",
	     (ftnlen)64);
    s_copy(string, " 12 JAN 2012 A.D., 11:12:18 P.M.", (ftnlen)80, (ftnlen)32)
	    ;

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    got = zzvalt_(string, &c__1000, &c_b436, "Y", (ftnlen)80, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "bibmbYbe,bi:i:ibN", (ftnlen)16, (ftnlen)17);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    did = zzremt_("b", (ftnlen)1);
    did = zzremt_(":", (ftnlen)1);
    did = zzremt_(",", (ftnlen)1);
    did = zzremt_("e", (ftnlen)1);
    did = zzremt_("N", (ftnlen)1);
    did = zzsubt_("imYiii", "DmYHMS", &l2r, (ftnlen)6, (ftnlen)6);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    etvec[0] = 2012.;
    etvec[1] = 1.;
    etvec[2] = 12.;
    etvec[3] = 11.;
    etvec[4] = 12.;
    etvec[5] = 18.;
    s_copy(experr, " ", (ftnlen)80, (ftnlen)1);
    s_copy(etrans, "YMD", (ftnlen)16, (ftnlen)3);
    expn = 6;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__6, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TRANSL", transl, "=", "YMD", ok, (ftnlen)6, (ftnlen)16, (ftnlen)
	    1, (ftnlen)3);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b503, ok, (ftnlen)4, (ftnlen)
	    1);
    s_copy(string, "2012 A.D. 129// 11:12:18 P.M.", (ftnlen)80, (ftnlen)29);

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    got = zzvalt_(string, &c__1000, &c_b436, "Y", (ftnlen)80, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "Ybebidbi:i:ibN", (ftnlen)16, (ftnlen)14);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    did = zzremt_("b", (ftnlen)1);
    did = zzremt_(":", (ftnlen)1);
    did = zzremt_(",", (ftnlen)1);
    did = zzremt_("e", (ftnlen)1);
    did = zzremt_("d", (ftnlen)1);
    did = zzremt_("N", (ftnlen)1);
    did = zzsubt_("Yiiii", "YyHMS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    etvec[0] = 2012.;
    etvec[1] = 129.;
    etvec[2] = 11.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    s_copy(experr, " ", (ftnlen)80, (ftnlen)1);
    s_copy(etrans, "YMD", (ftnlen)16, (ftnlen)3);
    expn = 6;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("ERROR", error, "=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TRANSL", transl, "=", "YD", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1,
	     (ftnlen)2);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b503, ok, (ftnlen)4, (ftnlen)
	    1);
    tcase_("Check to make sure that an unresolved string is diagnosed as one"
	    " by ZZUNPCK. ", (ftnlen)77);
    s_copy(string, "2012 A.D. 129// 11:12:18 P.M.", (ftnlen)80, (ftnlen)29);

/*        First tokenize the string */

    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    got = zzvalt_(string, &c__1000, &c_b436, "Y", (ftnlen)80, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "Ybebidbi:i:ibN", (ftnlen)16, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    did = zzremt_("b", (ftnlen)1);
    did = zzremt_(":", (ftnlen)1);
    did = zzremt_(",", (ftnlen)1);
    did = zzremt_("e", (ftnlen)1);
    did = zzremt_("d", (ftnlen)1);
    did = zzremt_("N", (ftnlen)1);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YmDHMn", (ftnlen)35);
    s_copy(string, " 1995JAN19 12 13 12", (ftnlen)80, (ftnlen)19);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("imiiii", "YmDHMn", &l2r, (ftnlen)6, (ftnlen)6);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YmYHMS", (ftnlen)35);
    s_copy(string, " 1995JAN1995 12 13 12", (ftnlen)80, (ftnlen)21);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("imiiii", "YmYHMS", &l2r, (ftnlen)6, (ftnlen)6);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDHMS", (ftnlen)34);
    s_copy(string, " 1995 19 12 13 12", (ftnlen)80, (ftnlen)17);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iiiii", "YDHMS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YmDyHMS", (ftnlen)36);
    s_copy(string, " 1995JAN19 95 12 13 12", (ftnlen)80, (ftnlen)22);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("imiiiii", "YmDyHMS", &l2r, (ftnlen)7, (ftnlen)7);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages mDHMS", (ftnlen)34);
    s_copy(string, "JAN 19 12 13 12", (ftnlen)80, (ftnlen)15);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("miiii", "mDHMS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YmmDHMS", (ftnlen)36);
    s_copy(string, "1995JAN 11 5 12 13 12", (ftnlen)80, (ftnlen)21);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("imiiiii", "YmmDHMS", &l2r, (ftnlen)7, (ftnlen)7);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YyyHMS", (ftnlen)35);
    s_copy(string, "1995 12 11 12 13 12", (ftnlen)80, (ftnlen)19);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iiiii", "YyyHMS", &l2r, (ftnlen)5, (ftnlen)6);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmDHMS", (ftnlen)36);
    s_copy(string, "1995 12 JAN 11 12 13 12", (ftnlen)80, (ftnlen)23);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimiiii", "YDmDHMS", &l2r, (ftnlen)7, (ftnlen)7);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmHH", (ftnlen)34);
    s_copy(string, "1995 12 JAN 11 12 ", (ftnlen)80, (ftnlen)18);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimii", "YDmHH", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmSS", (ftnlen)34);
    s_copy(string, "1995 12 JAN 12 13 12", (ftnlen)80, (ftnlen)20);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimii", "YDmSS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmMM", (ftnlen)34);
    s_copy(string, "1995 12 JAN 11 12 ", (ftnlen)80, (ftnlen)18);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimii", "YDmMM", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmMS", (ftnlen)34);
    s_copy(string, "1995 12 JAN 11 12 ", (ftnlen)80, (ftnlen)18);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimii", "YDmMS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Checking Diagnostic Messages YDmHS", (ftnlen)34);
    s_copy(string, "1995 12 JAN 11 12 ", (ftnlen)80, (ftnlen)18);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    did = zzremt_("b", (ftnlen)1);
    did = zzsubt_("iimii", "YDmHS", &l2r, (ftnlen)5, (ftnlen)5);
    got = zzunpck_(string, &yabbrv, tvec, &ntvec, transl, pic, error, (ftnlen)
	    80, (ftnlen)16, (ftnlen)80, (ftnlen)240);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_false, ok, (ftnlen)4);
    chcksc_("TRANSL", transl, "=", " ", ok, (ftnlen)6, (ftnlen)16, (ftnlen)1, 
	    (ftnlen)1);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)240, (ftnlen)2, 
	    (ftnlen)1);
    if (shdiag) {
	tststy_(good, bad, (ftnlen)80, (ftnlen)80);
	tstlgs_(mstyle, mstyle, (ftnlen)80, (ftnlen)80);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlog_(error, &c_false, (ftnlen)240);
	tstlog_(" ", &c_false, (ftnlen)1);
	tstlgs_(good, bad, (ftnlen)80, (ftnlen)80);
    }
    tcase_("Make sure that we can perform the substitution and removal of *'"
	    "d tokens. ", (ftnlen)74);
    s_copy(string, "Monday April 22, 9:24:18.19 PST 1997", (ftnlen)80, (
	    ftnlen)36);
    did = zztokns_(string, error, (ftnlen)80, (ftnlen)240);
    got = zzremt_("b", (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT1", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID1", &did, &c_true, ok, (ftnlen)4);
    got = zzcmbt_("i.i", "n", &l2r, (ftnlen)3, (ftnlen)1);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "wmi,i:i:nZi", (ftnlen)16, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    got = zzrept_("i:i:n", "H*M*S", &r2l, (ftnlen)5, (ftnlen)5);
    did = zzgrep_(rep, (ftnlen)16);
    s_copy(erep, "wmi,HMSZi", (ftnlen)16, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("GOT2", &got, &c_true, ok, (ftnlen)4);
    chcksl_("DID2", &did, &c_true, ok, (ftnlen)4);
    chcksc_("REP", rep, "=", erep, ok, (ftnlen)3, (ftnlen)16, (ftnlen)1, (
	    ftnlen)16);
    t_success__(ok);
    return 0;
} /* f_zztime__ */

