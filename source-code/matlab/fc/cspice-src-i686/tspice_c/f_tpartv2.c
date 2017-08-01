/* f_tpartv2.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__6 = 6;
static doublereal c_b17 = 0.;
static integer c__0 = 0;
static integer c__5 = 5;

/* $Procedure F_TPARTV2 ( Family of tests for TPARTV ) */
/* Subroutine */ int f_tpartv2__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal tvec[7];
    logical mods;
    char type__[32];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal etvec[7];
    logical emods;
    integer ntvec;
    char etype[32], error[300];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chcksc_(char *, char *, char *, char *
	    , logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen);
    char emodfy[32*5];
    integer entvec;
    logical succes, esuccs;
    char modify[32*5];
    logical yabbrv;
    char eerror[300], string[80], pictur[80];
    extern /* Subroutine */ int tpartv_(char *, doublereal *, integer *, char 
	    *, char *, logical *, logical *, logical *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen);
    char pic[80];

/* $ Abstract */

/*     This routine checks that TPARTV can parse the strings */
/*     that were originally recognized by TPARSE as well as */
/*     a host of other standard time representations. */

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

/* $ Revisions */

/*     T_SPICE Version 1.1.0, 20-AUG-2000  (EDW) */

/*        F_TAPRTV split into routine F_TPARTV1 & F_TPARTV2 */
/*        in order to avoid a compiler problem with the Absoft */
/*        FORTRAN compiler on a Macintosh PPC. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     This routine is a continuation of the F_TAPRTV test */
/*     family begun in f_tpartv1.f. Do not make another call */
/*     to TOPEN. Continue tests with the next test case. */

    tcase_("Y-M-DTH-M-S ", (ftnlen)12);
    s_copy(string, "1827-12-27T02:28:27", (ftnlen)80, (ftnlen)19);
    s_copy(pic, "YYYY-MM-DDTHR:MN:SC", (ftnlen)80, (ftnlen)19);
    entvec = 6;
    etvec[0] = 1827.;
    etvec[1] = 12.;
    etvec[2] = 27.;
    etvec[3] = 2.;
    etvec[4] = 28.;
    etvec[5] = 27.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "=", eerror, ok, (ftnlen)5, (ftnlen)300, (ftnlen)
	    1, (ftnlen)300);
    chcksl_("MODS", &mods, &emods, ok, (ftnlen)4);
    chcksl_("SUCCES", &succes, &esuccs, ok, (ftnlen)6);
    chcksc_("MODIFY(1)", modify, "=", emodfy, ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(2)", modify + 32, "=", emodfy + 32, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(3)", modify + 64, "=", emodfy + 64, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(4)", modify + 96, "=", emodfy + 96, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(5)", modify + 128, "=", emodfy + 128, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    tcase_("Y-M-DTH-M.xxx ", (ftnlen)14);
    s_copy(string, "1827-12-27T02:28.281", (ftnlen)80, (ftnlen)20);
    s_copy(pic, "YYYY-MM-DDTHR:MN.### ::RND", (ftnlen)80, (ftnlen)26);
    entvec = 5;
    etvec[0] = 1827.;
    etvec[1] = 12.;
    etvec[2] = 27.;
    etvec[3] = 2.;
    etvec[4] = 28.281;
    etvec[5] = 0.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "=", eerror, ok, (ftnlen)5, (ftnlen)300, (ftnlen)
	    1, (ftnlen)300);
    chcksl_("MODS", &mods, &emods, ok, (ftnlen)4);
    chcksl_("SUCCES", &succes, &esuccs, ok, (ftnlen)6);
    chcksc_("MODIFY(1)", modify, "=", emodfy, ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(2)", modify + 32, "=", emodfy + 32, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(3)", modify + 64, "=", emodfy + 64, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(4)", modify + 96, "=", emodfy + 96, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(5)", modify + 128, "=", emodfy + 128, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    tcase_("Y-M-DTH-M.xxx (2)", (ftnlen)17);
    s_copy(string, "1827-12-27T02:28.277", (ftnlen)80, (ftnlen)20);
    s_copy(pic, "YYYY-MM-DDTHR:MN.### ::RND", (ftnlen)80, (ftnlen)26);
    entvec = 5;
    etvec[0] = 1827.;
    etvec[1] = 12.;
    etvec[2] = 27.;
    etvec[3] = 2.;
    etvec[4] = 28.277;
    etvec[5] = 0.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "=", eerror, ok, (ftnlen)5, (ftnlen)300, (ftnlen)
	    1, (ftnlen)300);
    chcksl_("MODS", &mods, &emods, ok, (ftnlen)4);
    chcksl_("SUCCES", &succes, &esuccs, ok, (ftnlen)6);
    chcksc_("MODIFY(1)", modify, "=", emodfy, ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(2)", modify + 32, "=", emodfy + 32, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(3)", modify + 64, "=", emodfy + 64, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(4)", modify + 96, "=", emodfy + 96, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(5)", modify + 128, "=", emodfy + 128, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    tcase_("Y-DOY/", (ftnlen)6);
    s_copy(string, "1996-27/", (ftnlen)80, (ftnlen)8);
    s_copy(pic, "YYYY-DOY/", (ftnlen)80, (ftnlen)9);
    entvec = 2;
    etvec[0] = 1996.;
    etvec[1] = 27.;
    etvec[2] = 0.;
    etvec[3] = 0.;
    etvec[4] = 0.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "=", eerror, ok, (ftnlen)5, (ftnlen)300, (ftnlen)
	    1, (ftnlen)300);
    chcksl_("MODS", &mods, &emods, ok, (ftnlen)4);
    chcksl_("SUCCES", &succes, &esuccs, ok, (ftnlen)6);
    chcksc_("MODIFY(1)", modify, "=", emodfy, ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(2)", modify + 32, "=", emodfy + 32, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(3)", modify + 64, "=", emodfy + 64, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(4)", modify + 96, "=", emodfy + 96, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(5)", modify + 128, "=", emodfy + 128, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    tcase_("YYYY-DOY/H:M ", (ftnlen)13);
    s_copy(string, "1996-288/16:03", (ftnlen)80, (ftnlen)14);
    s_copy(pic, "YYYY-DOY/HR:MN", (ftnlen)80, (ftnlen)14);
    entvec = 4;
    etvec[0] = 1996.;
    etvec[1] = 288.;
    etvec[2] = 16.;
    etvec[3] = 3.;
    etvec[4] = 0.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "=", eerror, ok, (ftnlen)5, (ftnlen)300, (ftnlen)
	    1, (ftnlen)300);
    chcksl_("MODS", &mods, &emods, ok, (ftnlen)4);
    chcksl_("SUCCES", &succes, &esuccs, ok, (ftnlen)6);
    chcksc_("MODIFY(1)", modify, "=", emodfy, ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(2)", modify + 32, "=", emodfy + 32, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(3)", modify + 64, "=", emodfy + 64, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(4)", modify + 96, "=", emodfy + 96, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);
    chcksc_("MODIFY(5)", modify + 128, "=", emodfy + 128, ok, (ftnlen)9, (
	    ftnlen)32, (ftnlen)1, (ftnlen)32);

/*     Test family F_TPARTV finished. */

    t_success__(ok);
    return 0;
} /* f_tpartv2__ */

