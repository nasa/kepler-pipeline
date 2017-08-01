/* f_tpartv1.f -- translated by f2c (version 19980913).
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
static integer c__1 = 1;

/* $Procedure F_TPARTV1 ( Family of tests for TPARTV ) */
/* Subroutine */ int f_tpartv1__(logical *ok)
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
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char etype[32], error[300];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksc_(char *, char *, char *, char *, logical *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), chcksi_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen);
    char emodfy[32*5];
    integer entvec;
    logical succes, esuccs;
    char modify[32*5];
    logical yabbrv;
    char eerror[300], string[80], pictur[80];
    extern /* Subroutine */ int tpartv_(char *, doublereal *, integer *, char 
	    *, char *, logical *, logical *, logical *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), tstmsg_(char *, char *, 
	    ftnlen, ftnlen);
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


/*     Begin every test family with an open call. */

    topen_("F_TPARTV", (ftnlen)8);

/*     We are first going to check on q group of strings that we */
/*     think should be parsable. */

    tcase_("YMDHMS", (ftnlen)6);
    s_copy(string, "1994 Mar 12 12:28:18.281 ", (ftnlen)80, (ftnlen)25);
    etvec[0] = 1994.;
    etvec[1] = 3.;
    etvec[2] = 12.;
    etvec[3] = 12.;
    etvec[4] = 28.;
    etvec[5] = 18.281;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("YMDHMS", (ftnlen)6);
    s_copy(string, "1994 3 12 12:18:18.282 TDT ", (ftnlen)80, (ftnlen)27);
    etvec[0] = 1994.;
    etvec[1] = 3.;
    etvec[2] = 12.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    etvec[5] = 18.282;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, "TDT", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("DMYHMS", (ftnlen)6);
    s_copy(string, "3/APR/57 A.D. 12:18.1981 TDB ", (ftnlen)80, (ftnlen)29);
    etvec[0] = 57.;
    etvec[1] = 4.;
    etvec[2] = 3.;
    etvec[3] = 12.;
    etvec[4] = 18.1981;
    etvec[5] = 0.;
    entvec = 5;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, "A.D.", (ftnlen)32, (ftnlen)4);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, "TDB", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("MDYHMS", (ftnlen)6);
    s_copy(string, "3/28/'96 18:28:28.289 PDT ", (ftnlen)80, (ftnlen)26);
    etvec[0] = 96.;
    etvec[1] = 3.;
    etvec[2] = 28.;
    etvec[3] = 18.;
    etvec[4] = 28.;
    etvec[5] = 28.289;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, "UTC-7", (ftnlen)32, (ftnlen)5);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("MDHMSY", (ftnlen)6);
    s_copy(string, "Mon Apr 22 09:40:36 PDT 1996 ", (ftnlen)80, (ftnlen)29);
    etvec[0] = 1996.;
    etvec[1] = 4.;
    etvec[2] = 22.;
    etvec[3] = 9.;
    etvec[4] = 40.;
    etvec[5] = 36.;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, "UTC-7", (ftnlen)32, (ftnlen)5);
    s_copy(emodfy + 32, "MON", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("YDHMS", (ftnlen)5);
    s_copy(string, "1918-171/ 03:28:57.1819 (UTC) ", (ftnlen)80, (ftnlen)30);
    etvec[0] = 1918.;
    etvec[1] = 171.;
    etvec[2] = 3.;
    etvec[3] = 28.;
    etvec[4] = 57.1819;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, "UTC", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YDHMS", (ftnlen)5);
    s_copy(string, "1986 32// 02:18:09. CDT ", (ftnlen)80, (ftnlen)24);
    etvec[0] = 1986.;
    etvec[1] = 32.;
    etvec[2] = 2.;
    etvec[3] = 18.;
    etvec[4] = 9.;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, "UTC-5", (ftnlen)32, (ftnlen)5);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("JD", (ftnlen)2);
    s_copy(string, "2441889.18997917 JDUTC ", (ftnlen)80, (ftnlen)23);
    etvec[0] = 2441889.18997917;
    entvec = 1;
    s_copy(etype, "JD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, "UTC", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__1, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("JD", (ftnlen)2);
    s_copy(string, "2451545.5000000 JDTDB ", (ftnlen)80, (ftnlen)22);
    etvec[0] = 2451545.5;
    entvec = 1;
    s_copy(etype, "JD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, "TDB", (ftnlen)32, (ftnlen)3);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__1, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("JD", (ftnlen)2);
    s_copy(string, "2451792.1827191 JD ", (ftnlen)80, (ftnlen)19);
    etvec[0] = 2451792.1827191;
    entvec = 1;
    s_copy(etype, "JD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__1, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("JD", (ftnlen)2);
    s_copy(string, "2431829.28719 (JD) ", (ftnlen)80, (ftnlen)19);
    etvec[0] = 2431829.28719;
    entvec = 1;
    s_copy(etype, "JD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__1, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("ISO1", (ftnlen)4);
    s_copy(string, "1992-12-18T12:18:18 ", (ftnlen)80, (ftnlen)20);
    etvec[0] = 1992.;
    etvec[1] = 12.;
    etvec[2] = 18.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    etvec[5] = 18.;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "YMD", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)3);
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
    tcase_("ISO2", (ftnlen)4);
    s_copy(string, "1995-12T ", (ftnlen)80, (ftnlen)9);
    etvec[0] = 1995.;
    etvec[1] = 12.;
    etvec[2] = 0.;
    etvec[3] = 0.;
    etvec[4] = 0.;
    entvec = 2;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("ISO3", (ftnlen)4);
    s_copy(string, "1996-1-18T ", (ftnlen)80, (ftnlen)11);
    etvec[0] = 1996.;
    etvec[1] = 1.;
    etvec[2] = 18.;
    etvec[3] = 0.;
    etvec[4] = 0.;
    etvec[5] = 0.;
    entvec = 3;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("ISO4", (ftnlen)4);
    s_copy(string, "1996-3-18T12 ", (ftnlen)80, (ftnlen)13);
    etvec[0] = 1996.;
    etvec[1] = 3.;
    etvec[2] = 18.;
    etvec[3] = 12.;
    etvec[4] = 0.;
    etvec[5] = 0.;
    entvec = 4;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    tstmsg_("#", string, (ftnlen)1, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("ISO5", (ftnlen)4);
    s_copy(string, "1996-3-18T12:28.187 ", (ftnlen)80, (ftnlen)20);
    etvec[0] = 1996.;
    etvec[1] = 3.;
    etvec[2] = 18.;
    etvec[3] = 12.;
    etvec[4] = 28.187;
    etvec[5] = 0.;
    entvec = 5;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("ISO6", (ftnlen)4);
    s_copy(string, "1993-172T12:18:18.1879292 ", (ftnlen)80, (ftnlen)26);
    etvec[0] = 1993.;
    etvec[1] = 172.;
    etvec[2] = 12.;
    etvec[3] = 18.;
    etvec[4] = 18.1879292;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YMD", (ftnlen)3);
    s_copy(string, "105 B.C. 3/4 ", (ftnlen)80, (ftnlen)13);
    etvec[0] = 105.;
    etvec[1] = 3.;
    etvec[2] = 4.;
    etvec[3] = 0.;
    etvec[4] = 0.;
    etvec[5] = 0.;
    entvec = 3;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy, "B.C.", (ftnlen)32, (ftnlen)4);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YDM", (ftnlen)3);
    s_copy(string, "18 A.D. 4 March ", (ftnlen)80, (ftnlen)16);
    etvec[0] = 18.;
    etvec[1] = 3.;
    etvec[2] = 4.;
    etvec[3] = 0.;
    etvec[4] = 0.;
    etvec[5] = 0.;
    entvec = 3;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy, "A.D.", (ftnlen)32, (ftnlen)4);
    emods = TRUE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YMDHMS", (ftnlen)6);
    s_copy(string, "1919 12 02 12 18 19.19 ", (ftnlen)80, (ftnlen)23);
    etvec[0] = 1919.;
    etvec[1] = 12.;
    etvec[2] = 2.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    etvec[5] = 19.19;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YHMSDM", (ftnlen)6);
    s_copy(string, "1991 12:18:03.182 7 JAN ", (ftnlen)80, (ftnlen)24);
    etvec[0] = 1991.;
    etvec[1] = 1.;
    etvec[2] = 7.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    etvec[5] = 3.182;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("HMSMDY", (ftnlen)6);
    s_copy(string, "12:18:07 March 18, 1828 ", (ftnlen)80, (ftnlen)24);
    etvec[0] = 1828.;
    etvec[1] = 3.;
    etvec[2] = 18.;
    etvec[3] = 12.;
    etvec[4] = 18.;
    etvec[5] = 7.;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("DYHMS", (ftnlen)5);
    s_copy(string, "261-1998/17:18:21.1879 ", (ftnlen)80, (ftnlen)23);
    etvec[0] = 1998.;
    etvec[1] = 261.;
    etvec[2] = 17.;
    etvec[3] = 18.;
    etvec[4] = 21.1879;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("DYHMS", (ftnlen)5);
    s_copy(string, "217-1998::12:18:21.2987 ", (ftnlen)80, (ftnlen)24);
    etvec[0] = 1998.;
    etvec[1] = 217.;
    etvec[2] = 12.;
    etvec[3] = 18.;
    etvec[4] = 21.2987;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("DYHMS", (ftnlen)5);
    s_copy(string, "178-1872//12:18:17.1879 ", (ftnlen)80, (ftnlen)24);
    etvec[0] = 1872.;
    etvec[1] = 178.;
    etvec[2] = 12.;
    etvec[3] = 18.;
    etvec[4] = 17.1879;
    entvec = 5;
    s_copy(etype, "YD", (ftnlen)32, (ftnlen)2);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__5, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("YMDHMS", (ftnlen)6);
    s_copy(string, "1982-JAN 57 12:72:93.2987 ", (ftnlen)80, (ftnlen)26);
    etvec[0] = 1982.;
    etvec[1] = 1.;
    etvec[2] = 57.;
    etvec[3] = 12.;
    etvec[4] = 72.;
    etvec[5] = 93.2987;
    entvec = 6;
    s_copy(etype, "YMD", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = FALSE_;
    esuccs = TRUE_;
    s_copy(eerror, " ", (ftnlen)300, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TVEC", tvec, "=", etvec, &c__6, &c_b17, ok, (ftnlen)4, (ftnlen)1)
	    ;
    chcksi_("NTVEC", &ntvec, "=", &entvec, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("TYPE", type__, "=", etype, ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)32);
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
    tcase_("UNIX Date/Time", (ftnlen)14);
    s_copy(string, "Tue Apr 30 09:08:46 PDT 1996", (ftnlen)80, (ftnlen)28);
    s_copy(pic, "Wkd Mon DD HR:MN:SC PDT YYYY ::UTC-7", (ftnlen)80, (ftnlen)
	    36);
    entvec = 6;
    etvec[0] = 1996.;
    etvec[1] = 4.;
    etvec[2] = 30.;
    etvec[3] = 9.;
    etvec[4] = 8.;
    etvec[5] = 46.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, "TUE", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy + 64, "UTC-7", (ftnlen)32, (ftnlen)5);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = TRUE_;
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
    tcase_("UNIX MAIL Time Stamp", (ftnlen)20);
    s_copy(string, "Tue, Apr 30 09:08:46 PDT 1996", (ftnlen)80, (ftnlen)29);
    s_copy(pic, "Wkd, Mon DD HR:MN:SC PDT YYYY ::UTC-7", (ftnlen)80, (ftnlen)
	    37);
    entvec = 6;
    etvec[0] = 1996.;
    etvec[1] = 4.;
    etvec[2] = 30.;
    etvec[3] = 9.;
    etvec[4] = 8.;
    etvec[5] = 46.;
    s_copy(emodfy, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 32, "TUE", (ftnlen)32, (ftnlen)3);
    s_copy(emodfy + 64, "UTC-7", (ftnlen)32, (ftnlen)5);
    s_copy(emodfy + 96, " ", (ftnlen)32, (ftnlen)1);
    s_copy(emodfy + 128, " ", (ftnlen)32, (ftnlen)1);
    emods = TRUE_;
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
    tcase_("UNIX Date/Time Abbreviated", (ftnlen)26);
    s_copy(string, "Tue Apr 30 09:08:46 PDT 96", (ftnlen)80, (ftnlen)26);
    s_copy(pic, " ", (ftnlen)80, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_false, ok, (ftnlen)6);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)300, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Leading Delimiter ", (ftnlen)18);
    s_copy(string, "-1996 Jan 12", (ftnlen)80, (ftnlen)12);
    s_copy(pic, " ", (ftnlen)80, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_false, ok, (ftnlen)6);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)300, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("Trailing Delimiter ", (ftnlen)19);
    s_copy(string, "1997 Jan 12 ,", (ftnlen)80, (ftnlen)13);
    s_copy(pic, " ", (ftnlen)80, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_false, ok, (ftnlen)6);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)300, (ftnlen)2, 
	    (ftnlen)1);
    tcase_("YMDT ", (ftnlen)5);
    s_copy(string, "1996-12-18T", (ftnlen)80, (ftnlen)11);
    s_copy(pic, "YYYY-MM-DDT", (ftnlen)80, (ftnlen)11);
    entvec = 3;
    etvec[0] = 1996.;
    etvec[1] = 12.;
    etvec[2] = 18.;
    etvec[3] = 0.;
    etvec[4] = 0.;
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
    tcase_("YMDTHM ", (ftnlen)7);
    s_copy(string, "1827-12-27T02:28", (ftnlen)80, (ftnlen)16);
    s_copy(pic, "YYYY-MM-DDTHR:MN", (ftnlen)80, (ftnlen)16);
    entvec = 5;
    etvec[0] = 1827.;
    etvec[1] = 12.;
    etvec[2] = 27.;
    etvec[3] = 2.;
    etvec[4] = 28.;
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
    tcase_("YMDTHM and trailing colon ", (ftnlen)26);
    s_copy(string, "1827-12-27T02:28:", (ftnlen)80, (ftnlen)17);
    s_copy(pic, " ", (ftnlen)80, (ftnlen)1);
    tpartv_(string, tvec, &ntvec, type__, modify, &mods, &yabbrv, &succes, 
	    pictur, error, (ftnlen)80, (ftnlen)32, (ftnlen)32, (ftnlen)80, (
	    ftnlen)300);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("NTVEC", &ntvec, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksl_("SUCCES", &succes, &c_false, ok, (ftnlen)6);
    chcksc_("PICTUR", pictur, "=", pic, ok, (ftnlen)6, (ftnlen)80, (ftnlen)1, 
	    (ftnlen)80);
    chcksc_("ERROR", error, "!=", " ", ok, (ftnlen)5, (ftnlen)300, (ftnlen)2, 
	    (ftnlen)1);

/*     The test family continues in routine f_tpartv2.f. Do not */
/*     mark the end of the test family with a T_SUCCESS call. */

    return 0;
} /* f_tpartv1__ */

