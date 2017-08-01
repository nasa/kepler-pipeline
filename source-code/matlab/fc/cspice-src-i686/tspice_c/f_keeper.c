/* f_keeper.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__29 = 29;
static integer c__3 = 3;
static integer c__7 = 7;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__2 = 2;
static integer c__10 = 10;
static integer c__4 = 4;
static integer c__5 = 5;
static integer c__6 = 6;
static integer c__13 = 13;
static integer c__12 = 12;

/* $Procedure      F_KEEPER ( Test the entry points of KEEPER ) */
/* Subroutine */ int f_keeper__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    char ch__1[16];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char file[80];
    integer i__, n;
    extern integer cardi_(integer *);
    extern /* Subroutine */ int kdata_(integer *, char *, char *, char *, 
	    char *, integer *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    tcase_(char *, ftnlen), kinfo_(char *, char *, char *, integer *, 
	    logical *, ftnlen, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer count;
    extern /* Subroutine */ int t_success__(logical *), tstck3_(char *, char *
	    , logical *, logical *, logical *, integer *, ftnlen, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int dafhof_(integer *);
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), dashof_(integer 
	    *), chcksl_(char *, logical *, logical *, logical *, ftnlen), 
	    kilfil_(char *, ftnlen);
    char zztst1[80*3], zztst2[80*3], zztst3[80*3], zztst4[80*9];
    integer hanset[16];
    extern /* Subroutine */ int unload_(char *, ftnlen);
    char expfil[80*20];
    extern /* Subroutine */ int clpool_(void), ktotal_(char *, integer *, 
	    ftnlen);
    char source[80];
    extern /* Subroutine */ int dtpool_(char *, logical *, integer *, char *, 
	    ftnlen, ftnlen);
    char expsrc[80*20], zzleap[80*29], filtyp[32], dttype[32];
    extern /* Subroutine */ int furnsh_(char *, ftnlen), ssizei_(integer *, 
	    integer *), tstspk_(char *, logical *, integer *, ftnlen);
    char exptyp[32*20];
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    char cmp[32*20];

/* $ Abstract */

/*     Perform a collection of rudimentary tests on the */
/*     KEEPER collection of entry points. */

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

    topen_("F_KEEPER", (ftnlen)8);

/*     Set up the text for the various text kernels we shall */
/*     be loading via FURNSH. */

    begdat_(ch__1, (ftnlen)16);
    s_copy(zzleap, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(zzleap + 80, "DELTET/DELTA_T_A =   32.184", (ftnlen)80, (ftnlen)27)
	    ;
    s_copy(zzleap + 160, "DELTET/K         =    1.657D-3", (ftnlen)80, (
	    ftnlen)30);
    s_copy(zzleap + 240, "DELTET/EB        =    1.671D-2", (ftnlen)80, (
	    ftnlen)30);
    s_copy(zzleap + 320, "DELTET/M         = (  6.239996D0   1.99096871D-7 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(zzleap + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(zzleap + 480, "DELTET/DELTA_AT  = ( 10,   @1972-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 560, "                     11,   @1972-JUL-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 640, "                     12,   @1973-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 720, "                     13,   @1974-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 800, "                     14,   @1975-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 880, "                     15,   @1976-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 960, "                     16,   @1977-JAN-1", (ftnlen)80,
	     (ftnlen)38);
    s_copy(zzleap + 1040, "                     17,   @1978-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1120, "                     18,   @1979-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1200, "                     19,   @1980-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1280, "                     20,   @1981-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1360, "                     21,   @1982-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1440, "                     22,   @1983-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1520, "                     23,   @1985-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1600, "                     24,   @1988-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1680, "                     25,   @1990-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1760, "                     26,   @1991-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1840, "                     27,   @1992-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 1920, "                     28,   @1993-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 2000, "                     29,   @1994-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 2080, "                     30,   @1996-JAN-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 2160, "                     31,   @1997-JUL-1", (ftnlen)
	    80, (ftnlen)38);
    s_copy(zzleap + 2240, "                     32,   @1999-JAN-1 )", (ftnlen)
	    80, (ftnlen)40);
    begdat_(ch__1, (ftnlen)16);
    s_copy(zztst1, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(zztst1 + 80, "ZZTST1_NUMBER += 1", (ftnlen)80, (ftnlen)18);
    s_copy(zztst1 + 160, "ZZTST1_STRING = '1'", (ftnlen)80, (ftnlen)19);
    begdat_(ch__1, (ftnlen)16);
    s_copy(zztst2, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(zztst2 + 80, "ZZTST1_NUMBER += 2", (ftnlen)80, (ftnlen)18);
    s_copy(zztst2 + 160, "ZZTST2_STRING = '2'", (ftnlen)80, (ftnlen)19);
    begdat_(ch__1, (ftnlen)16);
    s_copy(zztst3, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(zztst3 + 80, "ZZTST1_NUMBER += 3", (ftnlen)80, (ftnlen)18);
    s_copy(zztst3 + 160, "ZZTST3_STRING  = '3'", (ftnlen)80, (ftnlen)20);

/*     We have 1 meta-text kernel. */

    begdat_(ch__1, (ftnlen)16);
    s_copy(zztst4, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(zztst4 + 80, "KERNELS_TO_LOAD = ( 'zz3spk$SPK',", (ftnlen)80, (
	    ftnlen)33);
    s_copy(zztst4 + 160, "                    'zzck2$CK',", (ftnlen)80, (
	    ftnlen)31);
    s_copy(zztst4 + 240, "                    'zzsclk2.ker',", (ftnlen)80, (
	    ftnlen)34);
    s_copy(zztst4 + 320, "                    'zztst3$TXT' )", (ftnlen)80, (
	    ftnlen)34);
    s_copy(zztst4 + 400, "PATH_SYMBOLS = ( 'SPK',  'CK',   'TXT' )", (ftnlen)
	    80, (ftnlen)40);
    s_copy(zztst4 + 480, "PATH_VALUES  = ( '.bsp', '.bc', '.txt' )", (ftnlen)
	    80, (ftnlen)40);

/*     Wipe out any existing test kernels.  (There shouldn't */
/*     be any, but just in case.) */

    kilfil_("zz1spk.bsp", (ftnlen)10);
    kilfil_("zz2spk.bsp", (ftnlen)10);
    kilfil_("zz3spk.bsp", (ftnlen)10);
    kilfil_("zzck1.bc", (ftnlen)8);
    kilfil_("zzck2.bc", (ftnlen)8);
    kilfil_("zzsclk1.ker", (ftnlen)11);
    kilfil_("zzsclk2.ker", (ftnlen)11);
    kilfil_("zzleaps.ker", (ftnlen)11);
    kilfil_("zztst1.txt", (ftnlen)10);
    kilfil_("zztst2.txt", (ftnlen)10);
    kilfil_("zztst3.txt", (ftnlen)10);
    kilfil_("zztst4.txt", (ftnlen)10);
    kilfil_("zztstek.be", (ftnlen)10);

/*     Create all of the test kernels we shall need. */

    tstspk_("zz1spk.bsp", &c_false, &handle, (ftnlen)10);
    tstspk_("zz2spk.bsp", &c_false, &handle, (ftnlen)10);
    tstspk_("zz3spk.bsp", &c_false, &handle, (ftnlen)10);
    tstck3_("zzck1.bc", "zzsclk1.ker", &c_false, &c_false, &c_true, &handle, (
	    ftnlen)8, (ftnlen)11);
    tstck3_("zzck2.bc", "zzsclk2.ker", &c_false, &c_false, &c_true, &handle, (
	    ftnlen)8, (ftnlen)11);
    tstspk_("zztstek.be", &c_false, &handle, (ftnlen)10);
    tsttxt_("zzleaps.ker", zzleap, &c__29, &c_false, &c_true, (ftnlen)11, (
	    ftnlen)80);
    tsttxt_("zztst1.txt", zztst1, &c__3, &c_false, &c_true, (ftnlen)10, (
	    ftnlen)80);
    tsttxt_("zztst2.txt", zztst2, &c__3, &c_false, &c_true, (ftnlen)10, (
	    ftnlen)80);
    tsttxt_("zztst3.txt", zztst3, &c__3, &c_false, &c_true, (ftnlen)10, (
	    ftnlen)80);
    tsttxt_("zztst4.txt", zztst4, &c__7, &c_false, &c_true, (ftnlen)10, (
	    ftnlen)80);
    clpool_();
    tcase_("Initialization Check.", (ftnlen)21);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Check Initial Values.", (ftnlen)21);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("PCK", &count, (ftnlen)3);
    chcksi_("PCKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("SPK CK PCK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Check that we can furnish all kernels directly.", (ftnlen)47);
    furnsh_("zz1spk.bsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    furnsh_("zz2spk.bsp", (ftnlen)10);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TESTCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    furnsh_("zzck1.bc", (ftnlen)8);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("APKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dafhof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DAFCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)1);
    furnsh_("zzsclk1.ker", (ftnlen)11);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    furnsh_("zztstek.be", (ftnlen)10);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__5, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dafhof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DASCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);

/*        Now fetch files to see if we can get the correct */
/*        information about them. */

    s_copy(expfil, "zz1spk.bsp", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 80, "zz2spk.bsp", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 160, "zzck1.bc", (ftnlen)80, (ftnlen)8);
    s_copy(expfil + 240, "zzsclk1.ker", (ftnlen)80, (ftnlen)11);
    s_copy(expfil + 320, "zztstek.be", (ftnlen)80, (ftnlen)10);
    s_copy(exptyp, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 32, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 64, "CK", (ftnlen)32, (ftnlen)2);
    s_copy(exptyp + 96, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 128, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(cmp, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 32, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 64, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 96, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 128, "!=", (ftnlen)32, (ftnlen)2);
    for (i__ = 1; i__ <= 5; ++i__) {
	kdata_(&i__, "ALL", file, filtyp, source, &handle, &found, (ftnlen)3, 
		(ftnlen)80, (ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("FILE", file, "=", expfil + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("expfil", i__1, "f_keeper__", (ftnlen)
		356)) * 80, ok, (ftnlen)4, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksc_("FILTYP", filtyp, "=", exptyp + (((i__1 = i__ - 1) < 20 && 0 
		<= i__1 ? i__1 : s_rnge("exptyp", i__1, "f_keeper__", (ftnlen)
		357)) << 5), ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;
	chcksc_("SOURCE", source, "=", " ", ok, (ftnlen)6, (ftnlen)80, (
		ftnlen)1, (ftnlen)1);
	chcksi_("HANDLE", &handle, cmp + (((i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("cmp", i__1, "f_keeper__", (ftnlen)360)) << 5)
		, &c__0, &c__0, ok, (ftnlen)6, (ftnlen)32);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    }
    tcase_("Check that Meta-Kernels load successfully.", (ftnlen)42);
    furnsh_("zztst4.txt", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__10, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__6, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("META", &count, (ftnlen)4);
    chcksi_("METACOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    s_copy(expfil, "zz1spk.bsp", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 80, "zz2spk.bsp", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 160, "zzck1.bc", (ftnlen)80, (ftnlen)8);
    s_copy(expfil + 240, "zzsclk1.ker", (ftnlen)80, (ftnlen)11);
    s_copy(expfil + 320, "zztstek.be", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 400, "zztst4.txt", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 480, "zz3spk.bsp", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 560, "zzck2.bc", (ftnlen)80, (ftnlen)8);
    s_copy(expfil + 640, "zzsclk2.ker", (ftnlen)80, (ftnlen)11);
    s_copy(expfil + 720, "zztst3.txt", (ftnlen)80, (ftnlen)10);
    s_copy(exptyp, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 32, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 64, "CK", (ftnlen)32, (ftnlen)2);
    s_copy(exptyp + 96, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 128, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 160, "META", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 192, "SPK", (ftnlen)32, (ftnlen)3);
    s_copy(exptyp + 224, "CK", (ftnlen)32, (ftnlen)2);
    s_copy(exptyp + 256, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 288, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(cmp, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 32, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 64, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 96, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 128, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 160, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 192, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 224, "!=", (ftnlen)32, (ftnlen)2);
    s_copy(cmp + 256, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 288, "=", (ftnlen)32, (ftnlen)1);
    s_copy(expsrc, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 480, "zztst4.txt", (ftnlen)80, (ftnlen)10);
    s_copy(expsrc + 560, "zztst4.txt", (ftnlen)80, (ftnlen)10);
    s_copy(expsrc + 640, "zztst4.txt", (ftnlen)80, (ftnlen)10);
    s_copy(expsrc + 720, "zztst4.txt", (ftnlen)80, (ftnlen)10);
    for (i__ = 1; i__ <= 10; ++i__) {
	kdata_(&i__, "ALL", file, filtyp, source, &handle, &found, (ftnlen)3, 
		(ftnlen)80, (ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("FILE", file, "=", expfil + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("expfil", i__1, "f_keeper__", (ftnlen)
		437)) * 80, ok, (ftnlen)4, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksc_("FILTYP", filtyp, "=", exptyp + (((i__1 = i__ - 1) < 20 && 0 
		<= i__1 ? i__1 : s_rnge("exptyp", i__1, "f_keeper__", (ftnlen)
		438)) << 5), ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;
	chcksc_("SOURCE", source, "=", expsrc + ((i__1 = i__ - 1) < 20 && 0 <=
		 i__1 ? i__1 : s_rnge("expsrc", i__1, "f_keeper__", (ftnlen)
		439)) * 80, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksi_("HANDLE", &handle, cmp + (((i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("cmp", i__1, "f_keeper__", (ftnlen)441)) << 5)
		, &c__0, &c__0, ok, (ftnlen)6, (ftnlen)32);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    }
    kdata_(&c__4, "SPK CK", file, filtyp, source, &handle, &found, (ftnlen)6, 
	    (ftnlen)80, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("FILE", file, "=", expfil + 320, ok, (ftnlen)4, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksc_("FILTYP", filtyp, "=", exptyp + 128, ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("SOURCE", source, "=", expsrc + 320, ok, (ftnlen)6, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksi_("HANDLE", &handle, cmp + 128, &c__0, &c__0, ok, (ftnlen)6, (
	    ftnlen)32);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    kdata_(&c__2, "TEXT", file, filtyp, source, &handle, &found, (ftnlen)4, (
	    ftnlen)80, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("FILE", file, "=", expfil + 640, ok, (ftnlen)4, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksc_("FILTYP", filtyp, "=", exptyp + 256, ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("SOURCE", source, "=", expsrc + 640, ok, (ftnlen)6, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksi_("HANDLE", &handle, cmp + 256, &c__0, &c__0, ok, (ftnlen)6, (
	    ftnlen)32);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    tcase_("Check that files loaded after a meta-kernel are loaded correctly."
	    , (ftnlen)65);
    furnsh_("zzleaps.ker", (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    furnsh_("zztst1.txt", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    furnsh_("zztst2.txt", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(expfil + 800, "zzleaps.ker", (ftnlen)80, (ftnlen)11);
    s_copy(expfil + 880, "zztst1.txt", (ftnlen)80, (ftnlen)10);
    s_copy(expfil + 960, "zztst2.txt", (ftnlen)80, (ftnlen)10);
    s_copy(exptyp + 320, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 352, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(exptyp + 384, "TEXT", (ftnlen)32, (ftnlen)4);
    s_copy(cmp + 320, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 352, "=", (ftnlen)32, (ftnlen)1);
    s_copy(cmp + 384, "=", (ftnlen)32, (ftnlen)1);
    s_copy(expsrc + 800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(expsrc + 960, " ", (ftnlen)80, (ftnlen)1);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__13, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__6, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__6, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("META", &count, (ftnlen)4);
    chcksi_("METACOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dafhof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DAFCOUNT", &count, "=", &c__6, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dashof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DASCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    for (i__ = 1; i__ <= 13; ++i__) {
	kdata_(&i__, "ALL", file, filtyp, source, &handle, &found, (ftnlen)3, 
		(ftnlen)80, (ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("FILE", file, "=", expfil + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("expfil", i__1, "f_keeper__", (ftnlen)
		537)) * 80, ok, (ftnlen)4, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksc_("FILTYP", filtyp, "=", exptyp + (((i__1 = i__ - 1) < 20 && 0 
		<= i__1 ? i__1 : s_rnge("exptyp", i__1, "f_keeper__", (ftnlen)
		538)) << 5), ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;
	chcksc_("SOURCE", source, "=", expsrc + ((i__1 = i__ - 1) < 20 && 0 <=
		 i__1 ? i__1 : s_rnge("expsrc", i__1, "f_keeper__", (ftnlen)
		539)) * 80, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksi_("HANDLE", &handle, cmp + (((i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("cmp", i__1, "f_keeper__", (ftnlen)541)) << 5)
		, &c__0, &c__0, ok, (ftnlen)6, (ftnlen)32);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    }
    kdata_(&c__4, "SPK CK", file, filtyp, source, &handle, &found, (ftnlen)6, 
	    (ftnlen)80, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("FILE", file, "=", expfil + 320, ok, (ftnlen)4, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksc_("FILTYP", filtyp, "=", exptyp + 128, ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("SOURCE", source, "=", expsrc + 320, ok, (ftnlen)6, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksi_("HANDLE", &handle, cmp + 128, &c__0, &c__0, ok, (ftnlen)6, (
	    ftnlen)32);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    kdata_(&c__2, "TEXT", file, filtyp, source, &handle, &found, (ftnlen)4, (
	    ftnlen)80, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("FILE", file, "=", expfil + 640, ok, (ftnlen)4, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksc_("FILTYP", filtyp, "=", exptyp + 256, ok, (ftnlen)6, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("SOURCE", source, "=", expsrc + 640, ok, (ftnlen)6, (ftnlen)80, (
	    ftnlen)1, (ftnlen)80);
    chcksi_("HANDLE", &handle, cmp + 256, &c__0, &c__0, ok, (ftnlen)6, (
	    ftnlen)32);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    tcase_("See if data is actually present in the kernel pool. ", (ftnlen)52)
	    ;
    dtpool_("ZZTST1_NUMBER", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("DTTYPE", dttype, "=", "N", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);
    dtpool_("ZZTST1_STRING", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("DTTYPE", dttype, "=", "C", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);
    dtpool_("KERNELS_TO_LOAD", &found, &n, dttype, (ftnlen)15, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_SYMBOLS", &found, &n, dttype, (ftnlen)12, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_VALUES", &found, &n, dttype, (ftnlen)11, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Make sure that we can fetch information about files by name. ", (
	    ftnlen)61);
    for (i__ = 1; i__ <= 13; ++i__) {
	kinfo_(expfil + ((i__1 = i__ - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge(
		"expfil", i__1, "f_keeper__", (ftnlen)603)) * 80, filtyp, 
		source, &handle, &found, (ftnlen)80, (ftnlen)32, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("FILTYP", filtyp, "=", exptyp + (((i__1 = i__ - 1) < 20 && 0 
		<= i__1 ? i__1 : s_rnge("exptyp", i__1, "f_keeper__", (ftnlen)
		608)) << 5), ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;
	chcksc_("SOURCE", source, "=", expsrc + ((i__1 = i__ - 1) < 20 && 0 <=
		 i__1 ? i__1 : s_rnge("expsrc", i__1, "f_keeper__", (ftnlen)
		609)) * 80, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	chcksi_("HANDLE", &handle, cmp + (((i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("cmp", i__1, "f_keeper__", (ftnlen)611)) << 5)
		, &c__0, &c__0, ok, (ftnlen)6, (ftnlen)32);
    }
    kinfo_("SPUD", filtyp, source, &handle, &found, (ftnlen)4, (ftnlen)32, (
	    ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("See if we can successfully unload a kernel.", (ftnlen)43);
    unload_("zztst2.txt", (ftnlen)10);
    dtpool_("ZZTST1_NUMBER", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("DTTYPE", dttype, "=", "N", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);
    dtpool_("ZZTST3_STRING", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("DTTYPE", dttype, "=", "C", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);
    dtpool_("KERNELS_TO_LOAD", &found, &n, dttype, (ftnlen)15, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_SYMBOLS", &found, &n, dttype, (ftnlen)12, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_VALUES", &found, &n, dttype, (ftnlen)11, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    ktotal_("ALL", &count, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("ALLCOUNT", &count, "=", &c__12, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__2, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__6, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__5, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("META", &count, (ftnlen)4);
    chcksi_("METACOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    tcase_("See if we can successfully unload a meta-kernel.", (ftnlen)48);
    unload_("zztst4.txt", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__7, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("SPK", &count, (ftnlen)3);
    chcksi_("SPKCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ktotal_("CK", &count, (ftnlen)2);
    chcksi_("CKCOUNT", &count, "=", &c__1, &c__0, ok, (ftnlen)7, (ftnlen)1);
    ktotal_("CK PCK SPK", &count, (ftnlen)10);
    chcksi_("3COUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);
    ktotal_("TEXT", &count, (ftnlen)4);
    chcksi_("TEXTCOUNT", &count, "=", &c__3, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("META", &count, (ftnlen)4);
    chcksi_("METACOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    ktotal_("EK", &count, (ftnlen)2);
    chcksi_("EKCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)7, (ftnlen)1);
    dtpool_("ZZTST1_NUMBER", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("DTTYPE", dttype, "=", "N", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);
    dtpool_("ZZTST3_STRING", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    ssizei_(&c__10, hanset);
    dafhof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DAFCOUNT", &count, "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dashof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DASCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    dtpool_("KERNELS_TO_LOAD", &found, &n, dttype, (ftnlen)15, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_SYMBOLS", &found, &n, dttype, (ftnlen)12, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("PATH_VALUES", &found, &n, dttype, (ftnlen)11, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Unload all of the remaining files", (ftnlen)33);
    unload_("zz1spk.bsp", (ftnlen)10);
    unload_("zz2spk.bsp", (ftnlen)10);
    unload_("zzck1.bc", (ftnlen)8);
    unload_("zztstek.be", (ftnlen)10);
    unload_("zzsclk1.ker", (ftnlen)11);
    unload_("zzleaps.ker", (ftnlen)11);
    unload_("zztst1.txt", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ktotal_("ALL", &count, (ftnlen)3);
    chcksi_("ALLCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    dtpool_("ZZTST1_NUMBER", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    dtpool_("ZZTST3_STRING", &found, &n, dttype, (ftnlen)13, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    ssizei_(&c__10, hanset);
    dafhof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DAFCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    ssizei_(&c__10, hanset);
    dashof_(hanset);
    count = cardi_(hanset);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("DASCOUNT", &count, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);

/*     Cleanup any debris left around from our test files. */

    clpool_();
    kilfil_("zz1spk.bsp", (ftnlen)10);
    kilfil_("zz2spk.bsp", (ftnlen)10);
    kilfil_("zz3spk.bsp", (ftnlen)10);
    kilfil_("zzck1.bc", (ftnlen)8);
    kilfil_("zzck2.bc", (ftnlen)8);
    kilfil_("zzsclk1.ker", (ftnlen)11);
    kilfil_("zzsclk2.ker", (ftnlen)11);
    kilfil_("zzleaps.ker", (ftnlen)11);
    kilfil_("zztst1.txt", (ftnlen)10);
    kilfil_("zztst2.txt", (ftnlen)10);
    kilfil_("zztst3.txt", (ftnlen)10);
    kilfil_("zztst4.txt", (ftnlen)10);
    kilfil_("zztstek.be", (ftnlen)10);
    t_success__(ok);
    return 0;
} /* f_keeper__ */

