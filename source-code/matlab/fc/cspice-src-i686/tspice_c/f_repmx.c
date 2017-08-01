/* f_repmx.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__2 = 2;

/* $Procedure      F_REPMX («meaning») */
/* Subroutine */ int f_repmx__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    char line[80], word[32], wexp[32];
    integer i__;
    doublereal x;
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), repmd_(char *, 
	    char *, doublereal *, integer *, char *, ftnlen, ftnlen, ftnlen), 
	    repmf_(char *, char *, doublereal *, integer *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer *,
	     char *, ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), 
	    t_success__(logical *), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    char result[80], sub[32], exp__[80];

/* $ Abstract */

/*     Perform a series of tests on the routine REPMC, REPMD, */
/*     REPMF, REPMI */

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

    topen_("F_REPMX", (ftnlen)7);
    tcase_("Character substitution  -- check REPMC", (ftnlen)38);
    s_copy(line, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is 'ok'.", (ftnlen)80, (ftnlen)18);
    s_copy(sub, "ok", (ftnlen)32, (ftnlen)2);
    repmc_(line, "#", sub, result, (ftnlen)80, (ftnlen)1, (ftnlen)32, (ftnlen)
	    80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Character substitution in-place -- check REPMC", (ftnlen)46);
    s_copy(result, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is 'ok'.", (ftnlen)80, (ftnlen)18);
    s_copy(sub, "ok", (ftnlen)32, (ftnlen)2);
    repmc_(result, "#", sub, result, (ftnlen)80, (ftnlen)1, (ftnlen)32, (
	    ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Character substitution truncated -- check REPMC", (ftnlen)47);
    s_copy(line, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(wexp, "The value is 'a very long string indeed'.", (ftnlen)32, (
	    ftnlen)41);
    s_copy(sub, "a very long string indeed", (ftnlen)32, (ftnlen)25);
    repmc_(line, "#", sub, word, (ftnlen)80, (ftnlen)1, (ftnlen)32, (ftnlen)
	    32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("WORD", word, "=", wexp, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Character substitution inplace truncated -- check REPMC", (ftnlen)
	    55);
    s_copy(word, "The value is '#'.", (ftnlen)32, (ftnlen)17);
    s_copy(wexp, "The value is 'a very long string indeed'.", (ftnlen)32, (
	    ftnlen)41);
    s_copy(sub, "a very long string indeed", (ftnlen)32, (ftnlen)25);
    repmc_(word, "#", sub, word, (ftnlen)32, (ftnlen)1, (ftnlen)32, (ftnlen)
	    32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("WORD", word, "=", wexp, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Integer substitution -- check REPMI", (ftnlen)35);
    s_copy(line, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '3'.", (ftnlen)80, (ftnlen)17);
    i__ = 3;
    repmi_(line, "#", &i__, result, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Integer substitution in-place -- check REPMI", (ftnlen)44);
    s_copy(result, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '3'.", (ftnlen)80, (ftnlen)17);
    i__ = 3;
    repmi_(result, "#", &i__, result, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Double precision substitution (scientific) -- REPMD", (ftnlen)51);
    s_copy(line, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '4.0E+00'.", (ftnlen)80, (ftnlen)23);
    x = 4.f;
    repmd_(line, "#", &x, &c__2, result, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Double precision substitution in-place (scientific) -- REPMD", (
	    ftnlen)60);
    s_copy(result, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '4.0E+00'.", (ftnlen)80, (ftnlen)23);
    x = 4.f;
    repmd_(line, "#", &x, &c__2, result, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Double precision substitution (float) -- REPMF", (ftnlen)46);
    s_copy(line, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '4.0'.", (ftnlen)80, (ftnlen)19);
    x = 4.f;
    repmf_(line, "#", &x, &c__2, "f", result, (ftnlen)80, (ftnlen)1, (ftnlen)
	    1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    tcase_("Double precision substitution in-place (float) -- REPMD", (ftnlen)
	    55);
    s_copy(result, "The value is '#'.", (ftnlen)80, (ftnlen)17);
    s_copy(exp__, "The value is '4.0'.", (ftnlen)80, (ftnlen)19);
    x = 4.f;
    repmf_(result, "#", &x, &c__2, "g", result, (ftnlen)80, (ftnlen)1, (
	    ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("RESULT", result, "=", exp__, ok, (ftnlen)6, (ftnlen)80, (ftnlen)
	    1, (ftnlen)80);
    t_success__(ok);
    return 0;
} /* f_repmx__ */

