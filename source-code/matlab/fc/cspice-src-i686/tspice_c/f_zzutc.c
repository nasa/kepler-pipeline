/* f_zzutc.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static integer c__6 = 6;
static doublereal c_b14 = 0.;
static integer c__14 = 14;

/* $Procedure      F_ZZUTC ( Family of tests for ZZUTCPM ) */
/* Subroutine */ int f_zzutc__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal hoff, moff;
    integer last;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical esucc;
    integer elast;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer start;
    extern /* Subroutine */ int t_success__(logical *), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), chcksi_(char *, integer *, char *, integer *, 
	    integer *, logical *, ftnlen, ftnlen), chcksl_(char *, logical *, 
	    logical *, logical *, ftnlen);
    logical succes;
    doublereal exphof, expmof;
    char string[80];
    extern /* Subroutine */ int zzutcpm_(char *, integer *, doublereal *, 
	    doublereal *, integer *, logical *, ftnlen);

/* $ Abstract */

/*     This routine is a family of tests for the routine ZZUTCPM. */

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

    topen_("F_ZZUTC.", (ftnlen)8);
    tcase_("Positive Hours only.", (ftnlen)20);
    s_copy(string, "Some ::UTC+10 hours", (ftnlen)80, (ftnlen)19);
    start = 6;
    exphof = 10.;
    expmof = 0.;
    elast = 13;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__6, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Negative Hours only.", (ftnlen)20);
    s_copy(string, "Some ::UTC-8 hours", (ftnlen)80, (ftnlen)18);
    start = 6;
    exphof = -8.;
    expmof = 0.;
    elast = 12;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__6, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Postive Hours and Minutes.", (ftnlen)26);
    s_copy(string, "An offset of ::UTC+11:17 hours and minutes", (ftnlen)80, (
	    ftnlen)42);
    start = 14;
    exphof = 11.;
    expmof = 17.;
    elast = 24;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Negative Hours and Minutes.", (ftnlen)27);
    s_copy(string, "An offset of ::UTC-05:33 hours and minutes", (ftnlen)80, (
	    ftnlen)42);
    start = 14;
    exphof = -5.;
    expmof = -33.;
    elast = 24;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Out of range Hours.", (ftnlen)19);
    s_copy(string, "An offset of ::UTC-15:33 hours and minutes", (ftnlen)80, (
	    ftnlen)42);
    start = 14;
    exphof = 0.;
    expmof = 0.;
    elast = 13;
    esucc = FALSE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Out of range Minutes.", (ftnlen)21);
    s_copy(string, "An offset of ::UTC+05:63 hours and minutes", (ftnlen)80, (
	    ftnlen)42);
    start = 14;
    exphof = 5.;
    expmof = 0.;
    elast = 21;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Unparsable Hours.", (ftnlen)17);
    s_copy(string, "An offset of ::UTC+ONE:33 hours and minutes", (ftnlen)80, 
	    (ftnlen)43);
    start = 14;
    exphof = 0.;
    expmof = 0.;
    elast = 13;
    esucc = FALSE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    tcase_("Unparsable Minutes.", (ftnlen)19);
    s_copy(string, "An offset of ::UTC+01:TWELVE hours and minutes", (ftnlen)
	    80, (ftnlen)46);
    start = 14;
    exphof = 1.;
    expmof = 0.;
    elast = 21;
    esucc = TRUE_;
    zzutcpm_(string, &start, &hoff, &moff, &last, &succes, (ftnlen)80);
    chcksi_("LAST", &last, "=", &elast, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("START", &start, "=", &c__14, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("MOFF", &moff, "=", &expmof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksd_("HOFF", &hoff, "=", &exphof, &c_b14, ok, (ftnlen)4, (ftnlen)1);
    chcksl_("SUCCES", &succes, &esucc, ok, (ftnlen)6);
    t_success__(ok);
    return 0;
} /* f_zzutc__ */

