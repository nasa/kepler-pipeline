/* f_lparse.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__10 = 10;
static logical c_false = FALSE_;
static integer c__7 = 7;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__8 = 8;
static integer c__6 = 6;
static integer c__2 = 2;
static integer c__3 = 3;
static integer c__5 = 5;
static logical c_true = TRUE_;
static integer c__100 = 100;

/* $Procedure F_LPARSE ( SPICE list parser tests ) */
/* Subroutine */ int f_lparse__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer nmax;
    char list[80];
    extern integer cardc_(char *, ftnlen);
    integer n;
    char delim[1];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char items[30*10], title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int t_success__(logical *), chckac_(char *, char *
	    , char *, char *, integer *, logical *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), chckxc_(logical *, char *, logical *, ftnlen), chcksi_(
	    char *, integer *, char *, integer *, integer *, logical *, 
	    ftnlen, ftnlen);
    char delims[80], chritm[1*10];
    extern /* Subroutine */ int lparse_(char *, char *, integer *, integer *, 
	    char *, ftnlen, ftnlen, ftnlen);
    char naritm[2*10];
    extern /* Subroutine */ int lparsm_(char *, char *, integer *, integer *, 
	    char *, ftnlen, ftnlen, ftnlen), ssizec_(integer *, char *, 
	    ftnlen);
    char itmset[30*106];
    extern /* Subroutine */ int lparss_(char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen);
    char xitems[30*10];

/* $ Abstract */

/*     Exercise SPICELIB list parsing routines. */

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

/* $ Required_Reading */

/*     None. */

/* $ Keywords */

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine tests the SPICELIB list parsing */
/*     routines: */

/*        LPARSE */
/*        LPARSM */
/*        LPARSS */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 26-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_LPARSE", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 1", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "  A number of words   separated   by spaces   ", (ftnlen)80,
	     (ftnlen)46);
    s_copy(xitems, "A", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "number", (ftnlen)30, (ftnlen)6);
    s_copy(xitems + 60, "of", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, "words", (ftnlen)30, (ftnlen)5);
    s_copy(xitems + 120, "separated", (ftnlen)30, (ftnlen)9);
    s_copy(xitems + 150, "by", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 180, "spaces", (ftnlen)30, (ftnlen)6);
    lparse_(list, " ", &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__7, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 1, with comma as delimiter.", 
	    (ftnlen)240, (ftnlen)56);
    tcase_(title, (ftnlen)240);
    s_copy(xitems, "A number of words   separated   by spaces", (ftnlen)30, (
	    ftnlen)41);
    *(unsigned char *)delim = ',';
    lparse_(list, delim, &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30)
	    ;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 2", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "//option1//option2/ //", (ftnlen)80, (ftnlen)22);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, "option1", (ftnlen)30, (ftnlen)7);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "option2", (ftnlen)30, (ftnlen)7);
    s_copy(xitems + 150, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 180, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 210, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, "/", &c__10, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1,
	     (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__8, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 3", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bob", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 60, "carol", (ftnlen)30, (ftnlen)5);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "ted", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 150, "alice", (ftnlen)30, (ftnlen)5);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, ",", &c__10, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1,
	     (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 3, narrow item array", (
	    ftnlen)240, (ftnlen)49);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bo", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 60, "ca", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "te", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 150, "al", (ftnlen)30, (ftnlen)2);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, ",", &c__10, &n, naritm, rtrim_(list, (ftnlen)80), (ftnlen)
	    1, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", naritm, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)2, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 3, 1-char item array", (
	    ftnlen)240, (ftnlen)49);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "b", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, "c", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "t", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 150, "a", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    *(unsigned char *)delim = ',';
    lparse_(list, delim, &c__10, &n, chritm, rtrim_(list, (ftnlen)80), (
	    ftnlen)1, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", chritm, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)1, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  header example 3, ITEMS dim = 2", (ftnlen)
	    240, (ftnlen)45);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bob", (ftnlen)30, (ftnlen)3);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, ",", &c__2, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1, 
	    (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  list with single non-blank delimiter", (
	    ftnlen)240, (ftnlen)50);
    tcase_(title, (ftnlen)240);
    s_copy(list, ",", (ftnlen)80, (ftnlen)1);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, ",", &c__10, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1,
	     (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  blank list, non-blank delimiter", (ftnlen)
	    240, (ftnlen)45);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ", (ftnlen)80, (ftnlen)1);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, ",", &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  blank list, blank delimiter", (ftnlen)240, (
	    ftnlen)41);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ", (ftnlen)80, (ftnlen)1);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparse_(list, " ", &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  consecutive non-blank delimiters", (ftnlen)
	    240, (ftnlen)46);
    tcase_(title, (ftnlen)240);
    s_copy(list, ",,,,,,,", (ftnlen)80, (ftnlen)7);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 150, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 180, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 210, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    *(unsigned char *)delim = ',';
    lparse_(list, delim, &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30)
	    ;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__8, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);
/* ************************************************************* */


/*     LPARSM tests follow. */


/* ************************************************************* */

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  header example 1", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "  A number of words   separated   by spaces   ", (ftnlen)80,
	     (ftnlen)46);
    s_copy(xitems, "A", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "number", (ftnlen)30, (ftnlen)6);
    s_copy(xitems + 60, "of", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, "words", (ftnlen)30, (ftnlen)5);
    s_copy(xitems + 120, "separated", (ftnlen)30, (ftnlen)9);
    s_copy(xitems + 150, "by", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 180, "spaces", (ftnlen)30, (ftnlen)6);
    lparsm_(list, " ", &c__10, &n, items, (ftnlen)80, (ftnlen)1, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__7, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  header example 2", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "  1986-187// 13:15:12.184 ", (ftnlen)80, (ftnlen)26);
    s_copy(delims, " ,/-:", (ftnlen)80, (ftnlen)5);

/*     Use NMAX rather than the "standard" MAXN. */

    nmax = 20;
    s_copy(xitems, "1986", (ftnlen)30, (ftnlen)4);
    s_copy(xitems + 30, "187", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 60, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 90, "13", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 120, "15", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 150, "12.184", (ftnlen)30, (ftnlen)6);
    lparsm_(list, delims, &nmax, &n, items, (ftnlen)80, (ftnlen)80, (ftnlen)
	    30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  LPARSE header example 3", (ftnlen)240, (
	    ftnlen)37);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bob", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 60, "carol", (ftnlen)30, (ftnlen)5);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "ted", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 150, "alice", (ftnlen)30, (ftnlen)5);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparsm_(list, ",", &c__10, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1,
	     (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  LPARSE header example 3 with narrow item ar"
	    "ray", (ftnlen)240, (ftnlen)60);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bo", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 60, "ca", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "te", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 150, "al", (ftnlen)30, (ftnlen)2);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparsm_(list, ",", &c__10, &n, naritm, rtrim_(list, (ftnlen)80), (ftnlen)
	    1, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", naritm, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)2, (
	    ftnlen)1, (ftnlen)30);


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  LPARSE header example 3, with blank and com"
	    "ma both considered delimiters", (ftnlen)240, (ftnlen)86);
    tcase_(title, (ftnlen)240);
    s_copy(list, " ,bob,   carol,, ted,  alice", (ftnlen)80, (ftnlen)28);
    s_copy(delims, " ,", (ftnlen)80, (ftnlen)2);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "bob", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 60, "carol", (ftnlen)30, (ftnlen)5);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, "ted", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 150, "alice", (ftnlen)30, (ftnlen)5);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparsm_(list, delims, &c__10, &n, items, rtrim_(list, (ftnlen)80), (
	    ftnlen)80, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSE test:  list with single non-blank delimiter", (
	    ftnlen)240, (ftnlen)50);
    tcase_(title, (ftnlen)240);
    s_copy(list, ",", (ftnlen)80, (ftnlen)1);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparsm_(list, ",", &c__10, &n, items, rtrim_(list, (ftnlen)80), (ftnlen)1,
	     (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  list starting and ending with single non-bl"
	    "ank delimiter", (ftnlen)240, (ftnlen)70);
    tcase_(title, (ftnlen)240);
    s_copy(delims, ",:", (ftnlen)80, (ftnlen)2);
    s_copy(list, ", :", (ftnlen)80, (ftnlen)3);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    lparsm_(list, delims, &c__10, &n, items, rtrim_(list, (ftnlen)80), (
	    ftnlen)80, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSM test:  consecutive non-blank delimiters", (ftnlen)
	    240, (ftnlen)46);
    tcase_(title, (ftnlen)240);
    s_copy(list, ",,,,,,,", (ftnlen)80, (ftnlen)7);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 90, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 120, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 150, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 180, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 210, " ", (ftnlen)30, (ftnlen)1);

/*     Use RTRIM to remove trailing blanks from the list. */

    s_copy(delims, ",", (ftnlen)80, (ftnlen)1);
    lparsm_(list, delims, &c__10, &n, items, (ftnlen)80, (ftnlen)80, (ftnlen)
	    30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N", &n, "=", &c__8, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckac_("ITEMS", items, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30, (
	    ftnlen)1, (ftnlen)30);
/* ************************************************************* */


/*     LPARSS tests follow. */


/* ************************************************************* */

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 1", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);

/*     Initialize item set. */

    ssizec_(&c__10, itmset, (ftnlen)30);
    s_copy(list, "  A number of words   separated   by spaces.", (ftnlen)80, (
	    ftnlen)44);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "A", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 60, "by", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, "number", (ftnlen)30, (ftnlen)6);
    s_copy(xitems + 120, "of", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 150, "separated", (ftnlen)30, (ftnlen)9);
    s_copy(xitems + 180, "spaces", (ftnlen)30, (ftnlen)6);
    s_copy(xitems + 210, "words", (ftnlen)30, (ftnlen)5);
    s_copy(delims, " ,.", (ftnlen)80, (ftnlen)3);
    lparss_(list, delims, itmset, (ftnlen)80, (ftnlen)80, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    n = cardc_(itmset, (ftnlen)30);
    chcksi_("CARDC(ITMSET)", &n, "=", &c__8, &c__0, ok, (ftnlen)13, (ftnlen)1)
	    ;
    chckac_("ITEMS", itmset + 180, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30,
	     (ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 2", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "  1986-187// 13:15:12.184 ", (ftnlen)80, (ftnlen)26);
    s_copy(delims, " ,/-:", (ftnlen)80, (ftnlen)5);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "12.184", (ftnlen)30, (ftnlen)6);
    s_copy(xitems + 60, "13", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, "15", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 120, "187", (ftnlen)30, (ftnlen)3);
    s_copy(xitems + 150, "1986", (ftnlen)30, (ftnlen)4);
    lparss_(list, delims, itmset, (ftnlen)80, (ftnlen)80, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    n = cardc_(itmset, (ftnlen)30);
    chcksi_("CARDC(ITMSET)", &n, "=", &c__6, &c__0, ok, (ftnlen)13, (ftnlen)1)
	    ;
    chckac_("ITEMS", itmset + 180, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30,
	     (ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 3", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "  ,This,  is, ,an,, example, ", (ftnlen)80, (ftnlen)29);
    s_copy(delims, " ,", (ftnlen)80, (ftnlen)2);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "This", (ftnlen)30, (ftnlen)4);
    s_copy(xitems + 60, "an", (ftnlen)30, (ftnlen)2);
    s_copy(xitems + 90, "example", (ftnlen)30, (ftnlen)7);
    s_copy(xitems + 120, "is", (ftnlen)30, (ftnlen)2);
    lparss_(list, delims, itmset, (ftnlen)80, (ftnlen)80, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    n = cardc_(itmset, (ftnlen)30);
    chcksi_("CARDC(ITMSET)", &n, "=", &c__5, &c__0, ok, (ftnlen)13, (ftnlen)1)
	    ;
    chckac_("ITEMS", itmset + 180, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30,
	     (ftnlen)1, (ftnlen)30);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 4", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "Mary had a little lamb, little lamb whose fleece was white"
	    "      as snow.", (ftnlen)80, (ftnlen)72);
    s_copy(delims, " ,.", (ftnlen)80, (ftnlen)3);
    ssizec_(&c__6, itmset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lparss_(list, delims, itmset, (ftnlen)80, (ftnlen)80, (ftnlen)30);
    chckxc_(&c_true, "SPICE(SETEXCESS)", ok, (ftnlen)16);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 5", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    s_copy(list, "1 2 3 4 5 6 7 8 9 10.", (ftnlen)80, (ftnlen)21);
    s_copy(delims, " .", (ftnlen)80, (ftnlen)2);
    ssizec_(&c__10, itmset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    lparss_(list, delims, itmset, (ftnlen)80, (ftnlen)80, (ftnlen)30);
    chckxc_(&c_true, "SPICE(SETEXCESS)", ok, (ftnlen)16);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "LPARSS test:  header example 6", (ftnlen)240, (ftnlen)30);
    tcase_(title, (ftnlen)240);
    ssizec_(&c__100, itmset, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(list, "1 2 3 4 5 6 7 8 9 10.", (ftnlen)80, (ftnlen)21);
    s_copy(delims, ".", (ftnlen)80, (ftnlen)1);
    s_copy(xitems, " ", (ftnlen)30, (ftnlen)1);
    s_copy(xitems + 30, "1 2 3 4 5 6 7 8 9 10", (ftnlen)30, (ftnlen)20);
    lparss_(list, delims, itmset, (ftnlen)80, rtrim_(delims, (ftnlen)80), (
	    ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    n = cardc_(itmset, (ftnlen)30);
    chcksi_("CARDC(ITMSET)", &n, "=", &c__2, &c__0, ok, (ftnlen)13, (ftnlen)1)
	    ;
    chckac_("ITEMS", itmset + 180, "=", xitems, &n, ok, (ftnlen)5, (ftnlen)30,
	     (ftnlen)1, (ftnlen)30);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_lparse__ */

