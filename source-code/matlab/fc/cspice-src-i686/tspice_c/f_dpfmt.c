/* f_dpfmt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;

/* $Procedure      F_DPFMT ( Family of tests for DPFMT) */
/* Subroutine */ int f_dpfmt__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal x;
    extern /* Subroutine */ int tcase_(char *, ftnlen), dpfmt_(doublereal *, 
	    char *, char *, ftnlen, ftnlen), topen_(char *, ftnlen), 
	    t_success__(logical *), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    char estrng[300], string[300], fmt[300];

/* $ Abstract */

/*     This routine exercises the routine DPFMT to make sure */
/*     that the outputs are as expected. */

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

    topen_("F_DPFMT", (ftnlen)7);
    x = 123400.;
    tcase_("Exception PICTUR = ' ' ", (ftnlen)23);
    s_copy(fmt, " ", (ftnlen)300, (ftnlen)1);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(NOPICTURE)", ok, (ftnlen)16);
    tcase_("Exception PICTUR = '+' ", (ftnlen)23);
    s_copy(fmt, "+", (ftnlen)300, (ftnlen)1);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(BADPICTURE)", ok, (ftnlen)17);
    tcase_("Exception PICTUR = '-' ", (ftnlen)23);
    s_copy(fmt, "-", (ftnlen)300, (ftnlen)1);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(BADPICTURE)", ok, (ftnlen)17);
    tcase_("Exception PICTUR = '.' ", (ftnlen)23);
    s_copy(fmt, ".", (ftnlen)300, (ftnlen)1);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(BADPICTURE)", ok, (ftnlen)17);
    tcase_("Exception PICTUR = '+.' ", (ftnlen)24);
    s_copy(fmt, "+.", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(BADPICTURE)", ok, (ftnlen)17);
    tcase_("Exception PICTUR = '-.' ", (ftnlen)24);
    s_copy(fmt, "-.", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_true, "SPICE(BADPICTURE)", ok, (ftnlen)17);
    tcase_("Exception Long picture/short output string", (ftnlen)42);
    s_copy(fmt, "xxxx.xxxxxxxxx", (ftnlen)300, (ftnlen)14);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)8);
    chckxc_(&c_true, "SPICE(OUTPUTTOOSHORT)", ok, (ftnlen)21);
    tcase_("X = 1.23456789D-37, fmt = 'xxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx' ", 
	    (ftnlen)63);
    x = 1.23456789e-37;
    s_copy(fmt, "xxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx", (ftnlen)300, (ftnlen)34)
	    ;
    s_copy(estrng, "   0.00000000000000000000000000000", (ftnlen)300, (ftnlen)
	    34);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 1.23456789D+32, fmt = xxxx.xxx", (ftnlen)34);
    x = 1.23456789e32;
    s_copy(fmt, "xxxx.xxx", (ftnlen)300, (ftnlen)8);
    s_copy(estrng, "1.23E+32", (ftnlen)300, (ftnlen)8);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 1.28289392D+7 , FMT = +xxxxxxxx.xxx ", (ftnlen)40);
    x = 12828939.2;
    s_copy(fmt, "+xxxxxxxxx.xxx", (ftnlen)300, (ftnlen)14);
    s_copy(estrng, "+ 12828939.200", (ftnlen)300, (ftnlen)14);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 182.938  fmt = xxx", (ftnlen)22);
    x = 182.938;
    s_copy(fmt, "xxx", (ftnlen)300, (ftnlen)3);
    s_copy(estrng, "183", (ftnlen)300, (ftnlen)3);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 182.938  fmt = xx", (ftnlen)21);
    x = 182.938;
    s_copy(fmt, "xx", (ftnlen)300, (ftnlen)2);
    s_copy(estrng, "**", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = -182.938,  fmt = xx.xxxxxx", (ftnlen)30);
    x = -182.938;
    s_copy(fmt, "xx.xxxxxx", (ftnlen)300, (ftnlen)9);
    s_copy(estrng, "-1.83E+02", (ftnlen)300, (ftnlen)9);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 8.50D+0, fmt = 0x", (ftnlen)21);
    x = 8.5;
    s_copy(fmt, "0x", (ftnlen)300, (ftnlen)2);
    s_copy(estrng, "09", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = -80.5D+0, fmt = xx ", (ftnlen)24);
    x = -80.5;
    s_copy(fmt, "xx", (ftnlen)300, (ftnlen)2);
    s_copy(estrng, "**", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = 80.5D+0, fmt = xx ", (ftnlen)23);
    x = 80.5;
    s_copy(fmt, "xx", (ftnlen)300, (ftnlen)2);
    s_copy(estrng, "81", (ftnlen)300, (ftnlen)2);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = -80.5D+0, fmt = xxx ", (ftnlen)25);
    x = -80.5;
    s_copy(fmt, "xxx", (ftnlen)300, (ftnlen)3);
    s_copy(estrng, "-81", (ftnlen)300, (ftnlen)3);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X =  80.5D+0, fmt = -xx ", (ftnlen)25);
    x = 80.5;
    s_copy(fmt, "xxx", (ftnlen)300, (ftnlen)3);
    s_copy(estrng, " 81", (ftnlen)300, (ftnlen)3);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = 9.99,   fmt = x.x", (ftnlen)22);
    x = 9.99;
    s_copy(fmt, "x.x", (ftnlen)300, (ftnlen)3);
    s_copy(estrng, "***", (ftnlen)300, (ftnlen)3);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = 9.99,   fmt = x.xx", (ftnlen)23);
    x = 9.99;
    s_copy(fmt, "x.xx", (ftnlen)300, (ftnlen)4);
    s_copy(estrng, "9.99", (ftnlen)300, (ftnlen)4);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 99.9999999  fmt = xx.xxxxxx", (ftnlen)31);
    x = 99.9999999;
    s_copy(fmt, "xx.xxxxxx", (ftnlen)300, (ftnlen)9);
    s_copy(estrng, "1.000E+02", (ftnlen)300, (ftnlen)9);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 99.9999999  fmt = +xx.xxxxxx", (ftnlen)32);
    x = 99.9999999;
    s_copy(fmt, "+xx.xxxxxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "+1.000E+02", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 99.9999999  fmt = -xx.xxxxxx", (ftnlen)32);
    x = 99.9999999;
    s_copy(fmt, "-xx.xxxxxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, " 1.000E+02", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 0.28910, fmt = +.xxxx", (ftnlen)25);
    x = .2891;
    s_copy(fmt, "+.xxxx", (ftnlen)300, (ftnlen)6);
    s_copy(estrng, "+.2891", (ftnlen)300, (ftnlen)6);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = -0.28910, fmt = x.xxx ", (ftnlen)26);
    x = -.2891;
    s_copy(fmt, "x.xxxx", (ftnlen)300, (ftnlen)6);
    s_copy(estrng, "-.2891", (ftnlen)300, (ftnlen)6);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 0.0D0, fmt = +x.xxxx ", (ftnlen)25);
    x = 0.;
    s_copy(fmt, "+x.xxxx", (ftnlen)300, (ftnlen)7);
    s_copy(estrng, " 0.0000", (ftnlen)300, (ftnlen)7);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 0.0D0, fmt = .xxxx ", (ftnlen)23);
    x = 0.;
    s_copy(fmt, ".xxxx", (ftnlen)300, (ftnlen)5);
    s_copy(estrng, ".0000", (ftnlen)300, (ftnlen)5);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = -1.000D0, fmt = xxxx.xxx ", (ftnlen)30);
    x = -1.;
    s_copy(fmt, "xxxx.xxx", (ftnlen)300, (ftnlen)8);
    s_copy(estrng, "  -1.000", (ftnlen)300, (ftnlen)8);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_(" X = -1.000D0, fmt = -xxxx.xxx ", (ftnlen)31);
    x = -1.;
    s_copy(fmt, "-xxxx.xxx", (ftnlen)300, (ftnlen)9);
    s_copy(estrng, "-   1.000", (ftnlen)300, (ftnlen)9);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = 123.456  fmt = xxxxxx.xxx", (ftnlen)29);
    x = 123.456;
    s_copy(fmt, "xxxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "   123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = -123.456  fmt = xxxxxx.xxx", (ftnlen)30);
    x = -123.456;
    s_copy(fmt, "xxxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "  -123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X = -123.456  fmt = 0xxxxx.xxx", (ftnlen)30);
    x = -123.456;
    s_copy(fmt, "0xxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "-00123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X =  123.456  fmt = 0xxxxx.xxx", (ftnlen)30);
    x = 123.456;
    s_copy(fmt, "0xxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "000123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X =  123.456  fmt = +0xxxx.xxx", (ftnlen)30);
    x = 123.456;
    s_copy(fmt, "+0xxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "+00123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X =  123.456  fmt = -0xxxx.xxx", (ftnlen)30);
    x = 123.456;
    s_copy(fmt, "-0xxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, " 00123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X =  123.456  fmt = -xxxxx.xxx", (ftnlen)30);
    x = 123.456;
    s_copy(fmt, "-xxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "   123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    tcase_("X =  123.456  fmt = +xxxxx.xxx", (ftnlen)30);
    x = 123.456;
    s_copy(fmt, "+xxxxx.xxx", (ftnlen)300, (ftnlen)10);
    s_copy(estrng, "+  123.456", (ftnlen)300, (ftnlen)10);
    dpfmt_(&x, fmt, string, (ftnlen)300, (ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("STRING", string, "=", estrng, ok, (ftnlen)6, (ftnlen)300, (
	    ftnlen)1, (ftnlen)300);
    t_success__(ok);
    return 0;
} /* f_dpfmt__ */

