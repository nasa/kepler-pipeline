/* f_vstrng.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c__0 = 0;
static integer c_n2 = -2;
static integer c__27 = 27;
static integer c_n34 = -34;
static integer c__257 = 257;
static integer c_n103 = -103;
static integer c_n3 = -3;
static integer c_n1 = -1;
static integer c__1 = 1;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c__5 = 5;
static integer c__6 = 6;
static integer c__7 = 7;
static integer c__8 = 8;
static integer c__9 = 9;
static integer c__10 = 10;
static integer c__15 = 15;
static integer c_n4 = -4;
static integer c__25 = 25;
static integer c_n8 = -8;
static integer c__12 = 12;
static logical c_true = TRUE_;
static logical c_false = FALSE_;

/* $Procedure      F_VSTRNG ( Tests for the virtual string routine ) */
/* Subroutine */ int f_vstrng__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char word[32];
    integer i__;
    extern /* Subroutine */ int zzvsbstr_(integer *, integer *, logical *, 
	    char *, logical *, ftnlen);
    doublereal x;
    extern /* Subroutine */ int tcase_(char *, ftnlen), zzvststr_(doublereal *
	    , char *, integer *, ftnlen);
    char eword[32];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    extern doublereal pi_(void);
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chcksi_(char *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen), chcksl_(char *, logical *, logical *, logical *, ftnlen);
    integer expect;
    char letter[1];
    logical did, rnd;
    integer exp__;

/* $ Abstract */

/*     This exercises the virtual string routine. */

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

/* $ Version */

/* -    SPICELIB Version 1.4.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    SPICELIB Version 1.3.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -    SPICELIB Version 1.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    SPICELIB Version 1.1.1, 17-JUL-2002 (BVS) */

/*        Added MAC-OSX environments. */

/* -    SPICELIB Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Function. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_VSTRNG", (ftnlen)8);
    rnd = FALSE_;
    tcase_("Make sure that exponents are returned with the correct value. ", (
	    ftnlen)62);
    x = 128.2792;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);
    x = .01282792;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c_n2, &c__0, ok, (ftnlen)3, (ftnlen)1);
    x = 1.282792e27;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__27, &c__0, ok, (ftnlen)3, (ftnlen)1);
    x = 1.282792e-34;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c_n34, &c__0, ok, (ftnlen)3, (ftnlen)1);
    x = 1.282792e257;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__257, &c__0, ok, (ftnlen)3, (ftnlen)1);
    x = 1.282792e-103;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c_n103, &c__0, ok, (ftnlen)3, (ftnlen)1);
    tcase_("Perform an exhaustive check on the exponent properties of ZZVSTS"
	    "TR. ", (ftnlen)68);
    x = 1.2e-257;
    expect = -257;
    for (i__ = 1; i__ <= 500; ++i__) {
	zzvststr_(&x, " ", &exp__, (ftnlen)1);
	chcksi_("EXP", &exp__, "=", &expect, &c__0, ok, (ftnlen)3, (ftnlen)1);
	x *= 10.;
	++expect;
    }
    tcase_("Make sure we get the correct virtual characters over a wide rang"
	    "e of characters. ", (ftnlen)81);
    x = 123.281928291;
    zzvststr_(&x, "*", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);
    for (i__ = -10; i__ <= -4; ++i__) {
	zzvsbstr_(&i__, &i__, &rnd, letter, &did, (ftnlen)1);
	chcksc_("LETTER", letter, "=", "*", ok, (ftnlen)6, (ftnlen)1, (ftnlen)
		1, (ftnlen)1);
    }
    zzvsbstr_(&c_n3, &c_n3, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_-3", letter, "=", "1", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c_n2, &c_n2, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_-2", letter, "=", "2", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c_n1, &c_n1, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_-1", letter, "=", "3", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c__0, &c__0, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_0", letter, "=", ".", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__1, &c__1, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_1", letter, "=", "2", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__2, &c__2, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_2", letter, "=", "8", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__3, &c__3, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_3", letter, "=", "1", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__4, &c__4, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_4", letter, "=", "9", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__5, &c__5, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_5", letter, "=", "2", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__6, &c__6, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_6", letter, "=", "8", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__7, &c__7, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_7", letter, "=", "2", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__8, &c__8, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_8", letter, "=", "9", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__9, &c__9, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_9", letter, "=", "1", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__10, &c__10, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_10", letter, "=", "0", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c__15, &c__15, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_15", letter, "=", "0", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    tcase_("Make sure we get the correct virtual characters over a wide rang"
	    "e of characters. ", (ftnlen)81);
    x = 1.23281928291e-4;
    zzvststr_(&x, "&", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c_n4, &c__0, ok, (ftnlen)3, (ftnlen)1);
    for (i__ = -10; i__ <= -2; ++i__) {
	zzvsbstr_(&i__, &i__, &rnd, letter, &did, (ftnlen)1);
	chcksc_("LETTER", letter, "=", "&", ok, (ftnlen)6, (ftnlen)1, (ftnlen)
		1, (ftnlen)1);
    }
    zzvsbstr_(&c_n1, &c_n1, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_-1", letter, "=", "0", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c__0, &c__0, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_0", letter, "=", ".", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__1, &c__1, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_1", letter, "=", "0", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__2, &c__2, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_2", letter, "=", "0", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__3, &c__3, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_3", letter, "=", "0", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__4, &c__4, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_4", letter, "=", "1", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__5, &c__5, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_5", letter, "=", "2", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__6, &c__6, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_6", letter, "=", "3", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__7, &c__7, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_7", letter, "=", "2", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__8, &c__8, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_8", letter, "=", "8", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__9, &c__9, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_9", letter, "=", "1", ok, (ftnlen)8, (ftnlen)1, (ftnlen)1,
	     (ftnlen)1);
    zzvsbstr_(&c__10, &c__10, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_10", letter, "=", "9", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    zzvsbstr_(&c__25, &c__25, &rnd, letter, &did, (ftnlen)1);
    chcksc_("LETTER_25", letter, "=", "0", ok, (ftnlen)9, (ftnlen)1, (ftnlen)
	    1, (ftnlen)1);
    tcase_("Retrieve a substring of the virtual string ", (ftnlen)43);
    x = pi_() * 100.;
    zzvststr_(&x, "&", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);
    zzvsbstr_(&c_n8, &c__3, &rnd, word, &did, (ftnlen)32);
    s_copy(eword, "&&&&&314.159", (ftnlen)32, (ftnlen)12);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    tcase_("Retrieve a substring of the virtual string ", (ftnlen)43);
    x = pi_() * .01;
    zzvststr_(&x, "&", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c_n2, &c__0, ok, (ftnlen)3, (ftnlen)1);
    zzvsbstr_(&c_n8, &c__12, &rnd, word, &did, (ftnlen)32);
    s_copy(eword, "&&&&&&&0.031415926535", (ftnlen)32, (ftnlen)21);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    tcase_("Check to see if virtual string round works.", (ftnlen)43);
    x = 4.999995;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);
    zzvsbstr_(&c_n1, &c__5, &c_true, word, &did, (ftnlen)32);
    s_copy(eword, "5.00000", (ftnlen)32, (ftnlen)7);
    chcksl_("DID", &did, &c_false, ok, (ftnlen)3);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    x = 9.999995;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);
    zzvsbstr_(&c_n1, &c__5, &c_true, word, &did, (ftnlen)32);
    s_copy(eword, "0.00000", (ftnlen)32, (ftnlen)7);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    x = 9.5;
    zzvststr_(&x, " ", &exp__, (ftnlen)1);
    chcksi_("EXP", &exp__, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);
    zzvsbstr_(&c_n1, &c__0, &c_true, word, &did, (ftnlen)32);
    s_copy(eword, "0.", (ftnlen)32, (ftnlen)2);
    chcksl_("DID", &did, &c_true, ok, (ftnlen)3);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    zzvsbstr_(&c_n3, &c__0, &c_true, word, &did, (ftnlen)32);
    s_copy(eword, " 10.", (ftnlen)32, (ftnlen)4);
    chcksl_("DID", &did, &c_false, ok, (ftnlen)3);
    chcksc_("WORD", word, "=", eword, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    t_success__(ok);
    return 0;
} /* f_vstrng__ */

