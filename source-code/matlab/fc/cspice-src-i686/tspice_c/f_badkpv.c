/* f_badkpv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__6 = 6;
static logical c_true = TRUE_;
static integer c__5 = 5;
static integer c__1 = 1;
static integer c__7 = 7;
static integer c__4 = 4;
static integer c__2 = 2;
static logical c_false = FALSE_;

/* $Procedure      F_BADKPV (Family of tests for BADKPV ) */
/* Subroutine */ int f_badkpv__(logical *ok)
{
    /* System generated locals */
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    logical lnum, lstr;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char lines[80*6];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    extern logical badkpv_(char *, char *, char *, integer *, integer *, char 
	    *, ftnlen, ftnlen, ftnlen, ftnlen);
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine checks all of the various tests possible */
/*     in the routine BADKPV. */

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

    topen_("F_BADKPV", (ftnlen)8);
    begtxt_(ch__1, (ftnlen)32);
    s_copy(lines, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(lines + 80, "This text kernel is for test purposes only.  It serv"
	    "es no", (ftnlen)80, (ftnlen)57);
    s_copy(lines + 160, "other purpose", (ftnlen)80, (ftnlen)13);
    begdat_(ch__1, (ftnlen)32);
    s_copy(lines + 240, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(lines + 320, "NUM = ( 1, 2, 3, 4, 5 )", (ftnlen)80, (ftnlen)23);
    s_copy(lines + 400, "STR = ( 'This', 'is', 'a', 'string', 'of', 'words.'"
	    " )", (ftnlen)80, (ftnlen)53);
    kilfil_("sample.txt", (ftnlen)10);
    tsttxt_("sample.txt", lines, &c__6, &c_true, &c_true, (ftnlen)10, (ftnlen)
	    80);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a character variable has in"
	    "teger values. ", (ftnlen)78);
    lnum = badkpv_("TEST", "NUM", "=", &c__5, &c__1, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when an numeric variable has cha"
	    "racter values ", (ftnlen)78);
    lstr = badkpv_("TEST", "STR", "=", &c__6, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLETYPE)", ok, (ftnlen)22);
    chcksl_("LSTR", &lstr, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable has a dimension "
	    "that is not the exact expected value ", (ftnlen)101);
    lnum = badkpv_("TEST", "NUM", "=", &c__6, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable has a dimension "
	    "that is not more than an expected value. ", (ftnlen)105);
    lnum = badkpv_("TEST", "NUM", ">", &c__5, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable has a dimension "
	    "that is not at least an expected value. ", (ftnlen)104);
    lstr = badkpv_("TEST", "STR", "=>", &c__7, &c__1, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LSTR", &lstr, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable has a dimension "
	    "that is not at most an expected value. ", (ftnlen)103);
    lnum = badkpv_("TEST", "NUM", "<=", &c__4, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable has a dimension "
	    "that is not less than some expected value. ", (ftnlen)107);
    lstr = badkpv_("TEST", "STR", "<", &c__6, &c__1, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LSTR", &lstr, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when the dimension of a variable"
	    " is not divisible by the prescribed value. ", (ftnlen)107);
    lstr = badkpv_("TEST", "STR", "=", &c__6, &c__4, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BADVARIABLESIZE)", ok, (ftnlen)22);
    chcksl_("LSTR", &lstr, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when a variable is not found in "
	    "the kernel pool. ", (ftnlen)81);
    lnum = badkpv_("TEST", "SPK", "=", &c__1, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(VARIABLENOTFOUND)", ok, (ftnlen)23);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure an error is signalled when the comparison operator is "
	    "not recognized. ", (ftnlen)80);
    lnum = badkpv_("TEST", "NUM", "?", &c__5, &c__1, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_true, "SPICE(UNKNOWNCOMPARE)", ok, (ftnlen)21);
    chcksl_("LNUM", &lnum, &c_true, ok, (ftnlen)4);
    lnum = FALSE_;
    lstr = FALSE_;
    tcase_("Make sure the '=' operator behaves as expected ", (ftnlen)47);
    lstr = badkpv_("TEST", "STR", "=", &c__6, &c__2, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    lnum = badkpv_("TEST", "NUM", "=", &c__5, &c__5, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("LNUM", &lnum, &c_false, ok, (ftnlen)4);
    chcksl_("LSTR", &lstr, &c_false, ok, (ftnlen)4);
    lnum = TRUE_;
    lstr = TRUE_;
    tcase_("Make sure the '>' operator behaves as expected ", (ftnlen)47);
    lstr = badkpv_("TEST", "STR", ">", &c__4, &c__2, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    lnum = badkpv_("TEST", "NUM", ">", &c__4, &c__5, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("LNUM", &lnum, &c_false, ok, (ftnlen)4);
    chcksl_("LSTR", &lstr, &c_false, ok, (ftnlen)4);
    lnum = TRUE_;
    lstr = TRUE_;
    tcase_("Make sure the '=>' operator behaves as expected ", (ftnlen)48);
    lstr = badkpv_("TEST", "STR", "=>", &c__6, &c__2, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    lnum = badkpv_("TEST", "NUM", "=>", &c__5, &c__5, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("LNUM", &lnum, &c_false, ok, (ftnlen)4);
    chcksl_("LSTR", &lstr, &c_false, ok, (ftnlen)4);
    lnum = TRUE_;
    lstr = TRUE_;
    tcase_("Make sure the '<' operator behaves as expected ", (ftnlen)47);
    lstr = badkpv_("TEST", "STR", "<", &c__7, &c__2, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    lnum = badkpv_("TEST", "NUM", "<", &c__6, &c__5, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)1, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("LNUM", &lnum, &c_false, ok, (ftnlen)4);
    chcksl_("LSTR", &lstr, &c_false, ok, (ftnlen)4);
    lnum = TRUE_;
    lstr = TRUE_;
    tcase_("Make sure the '<=' operator behaves as expected ", (ftnlen)48);
    lstr = badkpv_("TEST", "STR", "<=", &c__6, &c__2, "C", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    lnum = badkpv_("TEST", "NUM", "<=", &c__5, &c__5, "N", (ftnlen)4, (ftnlen)
	    3, (ftnlen)2, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("LNUM", &lnum, &c_false, ok, (ftnlen)4);
    chcksl_("LSTR", &lstr, &c_false, ok, (ftnlen)4);
    lnum = TRUE_;
    lstr = TRUE_;
    kilfil_("sample.txt", (ftnlen)10);
    t_success__(ok);
    return 0;
} /* f_badkpv__ */

