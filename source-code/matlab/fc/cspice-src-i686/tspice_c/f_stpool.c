/* f_stpool.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__11 = 11;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__0 = 0;
static integer c__2 = 2;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c__5 = 5;

/* $Procedure      F_STPOOL ( Family of tests for STPOOL ) */
/* Subroutine */ int f_stpool__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer size;
    char type__[1], text[80*11];
    integer i__, n;
    logical gcfnd;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found, stfnd;
    integer esize;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int t_success__(logical *);
    char mystr[3000];
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen);
    integer gotbck;
    extern /* Subroutine */ int kilfil_(char *, ftnlen), gcpool_(char *, 
	    integer *, integer *, integer *, char *, logical *, ftnlen, 
	    ftnlen);
    char expect[3000*4];
    extern /* Subroutine */ int clpool_(void), dtpool_(char *, logical *, 
	    integer *, char *, ftnlen, ftnlen);
    char estrng[3000];
    extern /* Subroutine */ int stpool_(char *, integer *, char *, char *, 
	    integer *, logical *, ftnlen, ftnlen, ftnlen), tsttxt_(char *, 
	    char *, integer *, logical *, logical *, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine performs rudimentary tests on the routine STPOOL. */

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

    topen_("F_STPOOL", (ftnlen)8);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(text + 80, " MYSTRING = ( 'This is a long string that will be spr"
	    "ead -',", (ftnlen)80, (ftnlen)60);
    s_copy(text + 160, "              'across several lines of a spice text "
	    "kernel -',", (ftnlen)80, (ftnlen)62);
    s_copy(text + 240, "              'for the sake of testing STPOOL.',", (
	    ftnlen)80, (ftnlen)48);
    s_copy(text + 320, "              'This is a second string.',", (ftnlen)
	    80, (ftnlen)41);
    s_copy(text + 400, "              'This is a third long string that will"
	    " span -',", (ftnlen)80, (ftnlen)61);
    s_copy(text + 480, "              'more than one line in a text kernel.',"
	    , (ftnlen)80, (ftnlen)53);
    s_copy(text + 560, "              'Finally this is a last long string th"
	    "at will -'", (ftnlen)80, (ftnlen)62);
    s_copy(text + 640, "              'be more than one line in the text ker"
	    "nel so -'", (ftnlen)80, (ftnlen)61);
    s_copy(text + 720, "              'that we can test the fetching of long"
	    " strings -',", (ftnlen)80, (ftnlen)64);
    s_copy(text + 800, "              'from the kernel pool with STPOOL.' )", 
	    (ftnlen)80, (ftnlen)51);
    s_copy(expect, "This is a long string that will be spread across several"
	    " lines of a spice text kernel for the sake of testing STPOOL. ", (
	    ftnlen)3000, (ftnlen)118);
    s_copy(expect + 3000, "This is a second string. ", (ftnlen)3000, (ftnlen)
	    25);
    s_copy(expect + 6000, "This is a third long string that will span more t"
	    "han one line in a text kernel. ", (ftnlen)3000, (ftnlen)80);
    s_copy(expect + 9000, "Finally this is a last long string that will be m"
	    "ore than one line in the text kernel so that we can test the fet"
	    "ching of long strings from the kernel pool with STPOOL. ", (
	    ftnlen)3000, (ftnlen)169);
    kilfil_("sample.txt", (ftnlen)10);
    tsttxt_("sample.txt", text, &c__11, &c_true, &c_false, (ftnlen)10, (
	    ftnlen)80);
    tcase_("Try to look up a string that isn't there.", (ftnlen)41);
    s_copy(mystr, "xxx", (ftnlen)3000, (ftnlen)3);
    stpool_("MYITEM", &c__1, "-", mystr, &size, &found, (ftnlen)6, (ftnlen)1, 
	    (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksc_("MYSTR", mystr, "=", " ", ok, (ftnlen)5, (ftnlen)3000, (ftnlen)1, 
	    (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("See if we can get the loaded strings.", (ftnlen)37);
    s_copy(mystr, "xxx", (ftnlen)3000, (ftnlen)3);
    esize = rtrim_(expect, (ftnlen)3000);
    stpool_("MYSTRING", &c__1, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &esize, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", expect, ok, (ftnlen)5, (ftnlen)3000, (ftnlen)
	    1, (ftnlen)3000);
    esize = rtrim_(expect + 3000, (ftnlen)3000);
    stpool_("MYSTRING", &c__2, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &esize, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", expect + 3000, ok, (ftnlen)5, (ftnlen)3000, (
	    ftnlen)1, (ftnlen)3000);
    esize = rtrim_(expect + 6000, (ftnlen)3000);
    stpool_("MYSTRING", &c__3, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &esize, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", expect + 6000, ok, (ftnlen)5, (ftnlen)3000, (
	    ftnlen)1, (ftnlen)3000);
    esize = rtrim_(expect + 9000, (ftnlen)3000);
    stpool_("MYSTRING", &c__4, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &esize, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", expect + 9000, ok, (ftnlen)5, (ftnlen)3000, (
	    ftnlen)1, (ftnlen)3000);
    stpool_("MYSTRING", &c__5, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", " ", ok, (ftnlen)5, (ftnlen)3000, (ftnlen)1, 
	    (ftnlen)1);
    stpool_("MYSTRING", &c__0, "-", mystr, &size, &found, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("SIZE", &size, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", " ", ok, (ftnlen)5, (ftnlen)3000, (ftnlen)1, 
	    (ftnlen)1);
    tcase_("Check for compatibility with GCPOOL when there continuation symb"
	    "ol used is not the one specified in STPOOL. ", (ftnlen)108);
    dtpool_("MYSTRING", &found, &n, type__, (ftnlen)8, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	stpool_("MYSTRING", &i__, "*", mystr, &size, &stfnd, (ftnlen)8, (
		ftnlen)1, (ftnlen)3000);
	gcpool_("MYSTRING", &i__, &c__1, &gotbck, estrng, &gcfnd, (ftnlen)8, (
		ftnlen)3000);
	chcksl_("GCFND", &gcfnd, &c_true, ok, (ftnlen)5);
	chcksl_("STFND", &stfnd, &gcfnd, ok, (ftnlen)5);
	chcksc_("MYSTR", mystr, "=", estrng, ok, (ftnlen)5, (ftnlen)3000, (
		ftnlen)1, (ftnlen)3000);
	esize = rtrim_(estrng, (ftnlen)3000);
	chcksi_("SIZE", &size, "=", &esize, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    i__1 = n + 1;
    stpool_("MYSTRING", &i__1, "*", mystr, &size, &stfnd, (ftnlen)8, (ftnlen)
	    1, (ftnlen)3000);
    chcksl_("STFND", &stfnd, &c_false, ok, (ftnlen)5);
    chcksc_("MYSTR", mystr, "=", " ", ok, (ftnlen)5, (ftnlen)3000, (ftnlen)1, 
	    (ftnlen)1);
    chcksi_("SIZE", &size, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Cleanup any debris we may have left around. */

    clpool_();
    t_success__(ok);
    return 0;
} /* f_stpool__ */

