/* f_pool.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__25 = 25;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__1 = 1;
static doublereal c_b60 = 0.;
static integer c__3 = 3;
static integer c__5 = 5;
static integer c__10 = 10;
static integer c__11 = 11;
static integer c__6 = 6;
static doublereal c_b344 = 1e-14;
static doublereal c_b434 = 1e-7;
static doublereal c_b573 = 3.;
static integer c__20 = 20;
static integer c__19 = 19;
static integer c__2 = 2;
static integer c__123 = 123;
static integer c__4 = 4;
static integer c__7 = 7;
static integer c__23 = 23;
static integer c__17 = 17;
static integer c__22 = 22;
static integer c_n1 = -1;
static integer c__9 = 9;
static integer c__14 = 14;
static integer c__29 = 29;
static integer c__8 = 8;

/* $Procedure      F_POOL ( Family of tests for POOL.) */
/* Subroutine */ int f_pool__(logical *ok)
{
    /* System generated locals */
    address a__1[2];
    integer i__1, i__2[2], i__3;
    char ch__1[32];
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_clos(cllist *);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    integer nian;
    char item[32*3];
    integer nnat, unit;
    char type__[1], text[140*100];
    integer i__, n;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer nbill;
    char names[32*10], cvals[140*20];
    doublereal evals[20];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer ivals[20], esize[20];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[140];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckai_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen);
    char bnames[32*2];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), shellc_(integer *, char *, 
	    ftnlen);
    char inames[32*2], cvalue[140*20];
    doublereal mydata[20];
    char nnames[32*2];
    logical update, bupdat;
    char varnam[32];
    extern /* Subroutine */ int gdpool_(char *, integer *, integer *, integer 
	    *, doublereal *, logical *, ftnlen);
    logical iupdat;
    extern /* Subroutine */ int nparsd_(char *, doublereal *, char *, integer 
	    *, ftnlen, ftnlen), clpool_(void), ldpool_(char *, ftnlen), 
	    gipool_(char *, integer *, integer *, integer *, integer *, 
	    logical *, ftnlen);
    logical nupdat;
    extern /* Subroutine */ int gcpool_(char *, integer *, integer *, integer 
	    *, char *, logical *, ftnlen, ftnlen);
    integer intval[20];
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen);
    doublereal values[20];
    extern /* Subroutine */ int prefix_(char *, integer *, char *, ftnlen, 
	    ftnlen), dtpool_(char *, logical *, integer *, char *, ftnlen, 
	    ftnlen), cvpool_(char *, logical *, ftnlen), pdpool_(char *, 
	    integer *, doublereal *, ftnlen), expool_(char *, logical *, 
	    ftnlen), pcpool_(char *, integer *, char *, ftnlen, ftnlen), 
	    pipool_(char *, integer *, integer *, ftnlen), lmpool_(char *, 
	    integer *, ftnlen), gnpool_(char *, integer *, integer *, integer 
	    *, char *, logical *, ftnlen, ftnlen), dvpool_(char *, ftnlen), 
	    rtpool_(char *, integer *, doublereal *, logical *, ftnlen), 
	    tstmsg_(char *, char *, ftnlen, ftnlen), wrpool_(integer *);
    integer myints[20];
    extern /* Subroutine */ int tstmsi_(integer *), swpool_(char *, integer *,
	     char *, ftnlen, ftnlen), szpool_(char *, integer *, logical *, 
	    ftnlen), txtopn_(char *, integer *, ftnlen);
    char mystrs[32*20];
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    integer ptr;

/* $ Abstract */

/*     This routine exercises a number of features of the */
/*     kernel pool. */

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

/* -    Version 3.0.0  06-AUG-2002 (BVS) */

/*        Made environment-independent because PC-LINUX FORTRAN */
/*        was fixed. Added long/trancated string test cases. */

/* -    Version 2.0.0  19-OCT-1999 (WLT) */

/*        Made environment specific to handle bug in PC-LINUX */
/*        implementation of FORTRAN. */
/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_POOL", (ftnlen)6);
    tcase_("Load and check types for numeric values.", (ftnlen)40);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( 5, 4, 3, 2 )", (ftnlen)140, (
	    ftnlen)34);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    s_copy(text + 3360, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__25, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    esize[0] = 1;
    esize[1] = 1;
    esize[2] = 1;
    esize[3] = 1;
    esize[4] = 1;
    esize[5] = 1;
    esize[6] = 1;
    esize[7] = 1;
    esize[8] = 1;
    esize[9] = 10;
    esize[10] = 6;
    for (i__ = 1; i__ <= 11; ++i__) {
	s_copy(varnam, "VALUE#", (ftnlen)32, (ftnlen)6);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("N", &n, "=", &esize[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? 
		i__1 : s_rnge("esize", i__1, "f_pool__", (ftnlen)171)], &c__0,
		 ok, (ftnlen)1, (ftnlen)1);
	chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1,
		 (ftnlen)1);
    }
    tcase_("Check that loaded values are as expected.", (ftnlen)41);
    tstmsg_("#", "Checking Value 1", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE1", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("1", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE1", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    tstmsg_("#", "Checking Value 2", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE2", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("2", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE2", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 3", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE3", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("PI", evals, error, &ptr, (ftnlen)2, (ftnlen)140);
    chckad_("VALUE3", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 4", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE4", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("3", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE4", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 5", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE5", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("4", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE5", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 6", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE6", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("5", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE6", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 7", (ftnlen)1, (ftnlen)16);
    nparsd_("1.276828E+11", evals, error, &ptr, (ftnlen)12, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE7", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE7", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 8", (ftnlen)1, (ftnlen)16);
    nparsd_("-28.19729871E+12", evals, error, &ptr, (ftnlen)16, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE8", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE8", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 9", (ftnlen)1, (ftnlen)16);
    tparse_("1-JAN-1994", evals, error, (ftnlen)10, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE9", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE9", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 1.;
    evals[1] = 2.;
    evals[2] = 3.;
    evals[3] = 4.;
    evals[4] = 5.;
    evals[5] = 6.;
    evals[6] = 7.;
    evals[7] = 8.;
    evals[8] = 9.;
    evals[9] = 10.;
    tstmsg_("#", "Checking Value 10", (ftnlen)1, (ftnlen)17);
    gdpool_("VALUE10", &c__3, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", &evals[2], &c__5, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 2.", (ftnlen)1, (ftnlen)25);
    gdpool_("VALUE10", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", evals, &c__10, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__10, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 3", (ftnlen)1, (ftnlen)24);
    gdpool_("VALUE10", &c__11, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 5.;
    evals[1] = 4.;
    evals[2] = 3.;
    evals[3] = 2.;
    evals[4] = 1.;
    evals[5] = 0.;
    tstmsg_("#", "Checking Value 11", (ftnlen)1, (ftnlen)17);
    gdpool_("VALUE11", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("VALUE11", values, "=", evals, &c__6, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Write the kernel pool out and clear the kernel pool.  Then read "
	    "in the output from the preceding write and make sure everything "
	    "matches. ", (ftnlen)137);
    kilfil_("writdata.ker", (ftnlen)12);
    txtopn_("writdata.ker", &unit, (ftnlen)12);
    wrpool_(&unit);
    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    clpool_();
    ldpool_("writdata.ker", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    esize[0] = 1;
    esize[1] = 1;
    esize[2] = 1;
    esize[3] = 1;
    esize[4] = 1;
    esize[5] = 1;
    esize[6] = 1;
    esize[7] = 1;
    esize[8] = 1;
    esize[9] = 10;
    esize[10] = 6;
    tstmsg_("#", "Checking type and size of values.", (ftnlen)1, (ftnlen)33);
    for (i__ = 1; i__ <= 11; ++i__) {
	tstmsg_("#", "I is #", (ftnlen)1, (ftnlen)6);
	tstmsi_(&i__);
	s_copy(varnam, "VALUE#", (ftnlen)32, (ftnlen)6);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("N", &n, "=", &esize[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? 
		i__1 : s_rnge("esize", i__1, "f_pool__", (ftnlen)344)], &c__0,
		 ok, (ftnlen)1, (ftnlen)1);
	chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1,
		 (ftnlen)1);
    }
    tstmsg_("#", "Checking Value 1", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE1", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("1", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE1", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    tstmsg_("#", "Checking Value 2", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE2", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("2", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE2", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 3", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE3", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("PI", evals, error, &ptr, (ftnlen)2, (ftnlen)140);
    chckad_("VALUE3", values, "~/", evals, &c__1, &c_b344, ok, (ftnlen)6, (
	    ftnlen)2);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 4", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE4", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("3", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE4", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 5", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE5", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("4", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE5", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 6", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE6", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("5", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE6", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 7", (ftnlen)1, (ftnlen)16);
    nparsd_("1.276828E+11", evals, error, &ptr, (ftnlen)12, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE7", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE7", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 8", (ftnlen)1, (ftnlen)16);
    nparsd_("-28.19729871E+12", evals, error, &ptr, (ftnlen)16, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE8", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE8", values, "~/", evals, &c__1, &c_b434, ok, (ftnlen)6, (
	    ftnlen)2);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 9", (ftnlen)1, (ftnlen)16);
    tparse_("1-JAN-1994", evals, error, (ftnlen)10, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE9", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE9", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 1.;
    evals[1] = 2.;
    evals[2] = 3.;
    evals[3] = 4.;
    evals[4] = 5.;
    evals[5] = 6.;
    evals[6] = 7.;
    evals[7] = 8.;
    evals[8] = 9.;
    evals[9] = 10.;
    tstmsg_("#", "Checking Value 10", (ftnlen)1, (ftnlen)17);
    gdpool_("VALUE10", &c__3, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", &evals[2], &c__5, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 2", (ftnlen)1, (ftnlen)24);
    gdpool_("VALUE10", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", evals, &c__10, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__10, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 3", (ftnlen)1, (ftnlen)24);
    gdpool_("VALUE10", &c__11, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 5.;
    evals[1] = 4.;
    evals[2] = 3.;
    evals[3] = 2.;
    evals[4] = 1.;
    evals[5] = 0.;
    tstmsg_("#", "Checking Value 11 ", (ftnlen)1, (ftnlen)18);
    gdpool_("VALUE11", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("VALUE11", values, "=", evals, &c__6, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    tcase_("Make sure that CLPOOL really empties the kernel pool. ", (ftnlen)
	    54);
    clpool_();
    for (i__ = 1; i__ <= 11; ++i__) {
	s_copy(varnam, "VALUE#", (ftnlen)32, (ftnlen)6);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
	chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
	chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
	chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1,
		 (ftnlen)1);
    }
    tcase_("Check out the routine RTPOOL to make sure it still works as befo"
	    "re. ", (ftnlen)68);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( 5, 4, 3, 2 )", (ftnlen)140, (
	    ftnlen)34);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    s_copy(text + 3360, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__25, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    rtpool_("VALUE4", &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N      for VALUE4", &n, "=", &c__1, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    chcksd_("Values for VALUE4", values, "=", &c_b573, &c_b60, ok, (ftnlen)17,
	     (ftnlen)1);
    chcksl_("FOUND  for VALUE4", &found, &c_true, ok, (ftnlen)17);
    rtpool_("VALUE11", &n, values, &found, (ftnlen)7);
    evals[0] = 5.;
    evals[1] = 4.;
    evals[2] = 3.;
    evals[3] = 2.;
    evals[4] = 1.;
    evals[5] = 0.;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N      for VALUE11", &n, "=", &c__6, &c__0, ok, (ftnlen)18, (
	    ftnlen)1);
    chckad_("Values for VALUE11", values, "=", evals, &c__6, &c_b60, ok, (
	    ftnlen)18, (ftnlen)1);
    chcksl_("FOUND  for VALUE4", &found, &c_true, ok, (ftnlen)17);
    tcase_("Make sure we can get integer values out of the kernel pool. ", (
	    ftnlen)60);
    gipool_("VALUE11", &c__1, &c__20, &n, intval, &found, (ftnlen)7);
    ivals[0] = 5;
    ivals[1] = 4;
    ivals[2] = 3;
    ivals[3] = 2;
    ivals[4] = 1;
    ivals[5] = 0;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N for VALUE11", &n, "=", &c__6, &c__0, ok, (ftnlen)13, (ftnlen)1)
	    ;
    chckai_("VALUE11", intval, "=", ivals, &n, ok, (ftnlen)7, (ftnlen)1);
    tcase_("Make sure we can load and retrieve text values. ", (ftnlen)48);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 280, "   SVALUE1  = 'String 1'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 420, "   SVALUE2  = 'String 2'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 560, "   SVALUE3  = 'String 3'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 700, "   SVALUE4  = 'String 4'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 840, "   SVALUE5  = 'String 5'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 980, "   SVALUE6  = 'String 6.1', 'String 6.2', 'String 6."
	    "3'", (ftnlen)140, (ftnlen)54);
    s_copy(text + 1120, "   SVALUE6  = 'String 6'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 1260, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 1400, "   SVALUE7 += 'String 7.0'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1540, "   SVALUE7 += 'String 7.1'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1680, "   SVALUE7 += 'String 7.2'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1820, "   SVALUE7 += 'String 7.3'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1960, "   SVALUE7 += 'String 7.4'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 2100, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 2240, "   SVALUE8 = ( 'String 8.0', 'String 8.1',", (ftnlen)
	    140, (ftnlen)42);
    s_copy(text + 2380, "               'String 8.2', 'String 8.3' )", (
	    ftnlen)140, (ftnlen)43);
    s_copy(text + 2520, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__19, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    esize[0] = 1;
    esize[1] = 1;
    esize[2] = 1;
    esize[3] = 1;
    esize[4] = 1;
    esize[5] = 1;
    esize[6] = 5;
    esize[7] = 4;
    for (i__ = 1; i__ <= 8; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "FOUND for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "N     for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 32, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "TYPE  for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 64, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(item, &found, &c_true, ok, (ftnlen)32);
	chcksi_(item + 32, &n, "=", &esize[(i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("esize", i__1, "f_pool__", (ftnlen)627)], &
		c__0, ok, (ftnlen)32, (ftnlen)1);
	chcksc_(item + 64, type__, "=", "C", ok, (ftnlen)32, (ftnlen)1, (
		ftnlen)1, (ftnlen)1);
    }
    tcase_("Check that the text items loaded in the previous test have the e"
	    "xpected values. ", (ftnlen)80);
    s_copy(cvals, "String 7.0", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 140, "String 7.1", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 280, "String 7.2", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 420, "String 7.3", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 560, "String 7.4", (ftnlen)140, (ftnlen)10);
    gcpool_("SVALUE7", &c__1, &c__20, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND for SVALUE7", &found, &c_true, ok, (ftnlen)17);
    chcksi_("N     for SVALUE7", &n, "=", &c__5, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    chcksc_("Value 1 of SVALUE7", cvalue, "=", cvals, ok, (ftnlen)18, (ftnlen)
	    140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 2 of SVALUE7", cvalue + 140, "=", cvals + 140, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 3 of SVALUE7", cvalue + 280, "=", cvals + 280, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 4 of SVALUE7", cvalue + 420, "=", cvals + 420, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 5 of SVALUE7", cvalue + 560, "=", cvals + 560, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    s_copy(cvals, "String 8.0", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 140, "String 8.1", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 280, "String 8.2", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 420, "String 8.3", (ftnlen)140, (ftnlen)10);
    gcpool_("SVALUE8", &c__3, &c__20, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND for SVALUE7", &found, &c_true, ok, (ftnlen)17);
    chcksi_("N     for SVALUE7", &n, "=", &c__2, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    chcksc_("Value 3 of SVALUE8", cvalue, "=", cvals + 280, ok, (ftnlen)18, (
	    ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 4 of SVALUE8", cvalue + 140, "=", cvals + 420, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    tcase_("Make sure we don't get string and numeric values confused. ", (
	    ftnlen)59);
    gdpool_("SVALUE8", &c__1, &c__20, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N for d.p.", &n, "=", &c__0, &c__0, ok, (ftnlen)10, (ftnlen)1);
    chcksl_("D.P. FOUND for SVALUE8", &found, &c_false, ok, (ftnlen)22);
    gipool_("SVALUE8", &c__1, &c__20, &n, ivals, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N for Int", &n, "=", &c__0, &c__0, ok, (ftnlen)9, (ftnlen)1);
    chcksl_("Integer FOUND for SVALUE8", &found, &c_false, ok, (ftnlen)25);
    gcpool_("VALUE1", &c__1, &c__20, &n, cvalue, &found, (ftnlen)6, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N for Char", &n, "=", &c__0, &c__0, ok, (ftnlen)10, (ftnlen)1);
    chcksl_("Char FOUND for VALUE1", &found, &c_false, ok, (ftnlen)21);
    tcase_("Make sure that we can write out string data via WRPOOL ", (ftnlen)
	    55);
    kilfil_("write.dat", (ftnlen)9);
    txtopn_("write.dat", &unit, (ftnlen)9);
    wrpool_(&unit);
    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    clpool_();
    dtpool_("SVALUE1", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("SVALUE2", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("SVALUE3", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE4", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE5", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE6", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE7", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE8", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    ldpool_("write.dat", (ftnlen)9);
    dtpool_("SVALUE1", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "C", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("SVALUE2", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "C", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("SVALUE7", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "C", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE4", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE5", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE6", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE10", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__10, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE11", &found, &n, type__, (ftnlen)7, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    s_copy(cvals, "String 7.0", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 140, "String 7.1", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 280, "String 7.2", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 420, "String 7.3", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 560, "String 7.4", (ftnlen)140, (ftnlen)10);
    gcpool_("SVALUE7", &c__1, &c__20, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND for SVALUE7", &found, &c_true, ok, (ftnlen)17);
    chcksi_("N     for SVALUE7", &n, "=", &c__5, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    rtpool_("VALUE11", &n, values, &found, (ftnlen)7);
    evals[0] = 5.;
    evals[1] = 4.;
    evals[2] = 3.;
    evals[3] = 2.;
    evals[4] = 1.;
    evals[5] = 0.;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("N      for VALUE11", &n, "=", &c__6, &c__0, ok, (ftnlen)18, (
	    ftnlen)1);
    chckad_("Values for VALUE11", values, "=", evals, &c__6, &c_b60, ok, (
	    ftnlen)18, (ftnlen)1);
    tcase_("Make sure we can set watchers and that they get triggered at the"
	    " appropriate times. ", (ftnlen)84);

/*        Create a list of variables to be watched. */

    s_copy(names, "SVALUE8", (ftnlen)32, (ftnlen)7);
    s_copy(names + 32, "VALUE10", (ftnlen)32, (ftnlen)7);
    s_copy(names + 64, "SPUD", (ftnlen)32, (ftnlen)4);

/*        Establish a watcher on the string variable and on the */
/*        numeric variable. */

    swpool_("S_POOL", &c__1, names, (ftnlen)6, (ftnlen)32);
    swpool_("D_POOL", &c__1, names + 32, (ftnlen)6, (ftnlen)32);
    swpool_("DUMMY", &c__1, names + 64, (ftnlen)5, (ftnlen)32);

/*        Check to see that S_POOL, D_POOL and DUMMY have notifications */
/*        pending. */

    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for D_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_true, ok, (ftnlen)16);

/*        Now check that S_POOL, D_POOL and DUMMY do not have */
/*        notifications pending. */

    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_false, ok, (ftnlen)16);
    cvpool_("UNDECLAGENT", &update, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UNDECLAGENT", &update, &c_false, ok, (ftnlen)11);

/*        Clear the kernel pool and see if everything behaves as */
/*        expected. */

    clpool_();
    tstmsg_("#", "Same tests after clearing the pool.", (ftnlen)1, (ftnlen)35)
	    ;

/*        Check to see that S_POOL, D_POOL and DUMMY have notifications */
/*        pending. */

    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for D_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_true, ok, (ftnlen)16);

/*        Now check that S_POOL, D_POOL and DUMMY do not have */
/*        notifications pending. */

    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_false, ok, (ftnlen)16);
    cvpool_("UNDECLAGENT", &update, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UNDECLAGENT", &update, &c_false, ok, (ftnlen)11);

/*        Now load a kernel and see if these items get updated */
/*        as expected */

    ldpool_("write.dat", (ftnlen)9);
    tstmsg_("#", "Same watcher tests after loading a file.", (ftnlen)1, (
	    ftnlen)40);
    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for D_POOL", &update, &c_true, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_false, ok, (ftnlen)16);

/*        Now check that S_POOL, D_POOL and DUMMY do not have */
/*        notifications pending. */

    cvpool_("S_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("D_POOL", &update, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for S_POOL", &update, &c_false, ok, (ftnlen)17);
    cvpool_("DUMMY", &update, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE for DUMMY", &update, &c_false, ok, (ftnlen)16);
    cvpool_("UNDECLAGENT", &update, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UNDECLAGENT", &update, &c_false, ok, (ftnlen)11);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that RTPOOL does not work on string valued variables. ",
	     (ftnlen)64);
    n = 123;
    rtpool_("SVALUE4", &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N    ", &n, "=", &c__123, &c__0, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Make sure that the entry point EXPOOL works only on numeric data"
	    " types. ", (ftnlen)72);

/*        EXPOOL should not find any of the string variables. */

    for (i__ = 1; i__ <= 8; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	expool_(varnam, &found, (ftnlen)32);
	prefix_("FOUND for ", &c__1, varnam, (ftnlen)10, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(varnam, &found, &c_false, ok, (ftnlen)32);
    }

/*        EXPOOL should find values for all of the numeric variables */

    for (i__ = 1; i__ <= 11; ++i__) {
	s_copy(varnam, "VALUE#", (ftnlen)32, (ftnlen)6);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	expool_(varnam, &found, (ftnlen)32);
	prefix_("FOUND for ", &c__1, varnam, (ftnlen)10, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(varnam, &found, &c_true, ok, (ftnlen)32);
    }
    tcase_("Make sure that GIPOOL doesn't try to swallow integers that are t"
	    "oo big. ", (ftnlen)72);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 280, "      VALUE12 = 1.0D15", (ftnlen)140, (ftnlen)22);
    s_copy(text + 420, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__4, &c_true, &c_false, (ftnlen)12, (
	    ftnlen)140);
    gipool_("VALUE12", &c__1, &c__10, &n, ivals, &found, (ftnlen)7);
    chckxc_(&c_true, "SPICE(INTOUTOFRANGE)", ok, (ftnlen)20);
    tcase_("Make sure that an error is signalled if we give a non-positive r"
	    "oom size to GCPOOL ", (ftnlen)83);
    gcpool_("SVALUE1", &c__1, &c__0, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_true, "SPICE(BADARRAYSIZE)", ok, (ftnlen)19);
    tcase_("Make sure that an error is signalled if we give a non-positive r"
	    "oom size to GIPOOL ", (ftnlen)83);
    gipool_("VALUE1", &c__1, &c__0, &n, ivals, &found, (ftnlen)6);
    chckxc_(&c_true, "SPICE(BADARRAYSIZE)", ok, (ftnlen)19);
    tcase_("Make sure that an error is signalled if we give a non-positive r"
	    "oom size to GDPOOL ", (ftnlen)83);
    gdpool_("VALUE10", &c__1, &c__0, &n, values, &found, (ftnlen)7);
    chckxc_(&c_true, "SPICE(BADARRAYSIZE)", ok, (ftnlen)19);
    tcase_("Make sure an error is triggered if we try to load a string and n"
	    "umeric value into a variable. ", (ftnlen)94);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "      VALUE13 = 123, '123'", (ftnlen)140, (ftnlen)26);
    s_copy(text + 280, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__4, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
/*        CALL GETMSG ( 'LONG',  LONG ) */
    chckxc_(&c_true, "SPICE(TYPEMISMATCH)", ok, (ftnlen)19);
/*        CALL TSTLOG (  LONG, .FALSE. ) */
    tcase_("Make sure an error is triggered if we try to load a numeric valu"
	    "e and a string value (in that order) into a variable. ", (ftnlen)
	    118);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "   SVALUE9 = '123', 123", (ftnlen)140, (ftnlen)23);
    s_copy(text + 280, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__4, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
/*        CALL GETMSG ( 'LONG',  LONG ) */
    chckxc_(&c_true, "SPICE(TYPEMISMATCH)", ok, (ftnlen)19);
/*        CALL TSTLOG (  LONG, .FALSE. ) */
    tcase_("Add d.p. data to the kernel pool through the PDPOOL interface. ", 
	    (ftnlen)63);
    mydata[0] = 1.;
    mydata[1] = 2.;
    mydata[2] = 3.;
    mydata[3] = 4.;
    mydata[4] = 5.;
    mydata[5] = 6.;
    pdpool_("MYDPS", &c__6, mydata, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dtpool_("MYDPS", &found, &n, type__, (ftnlen)5, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    gdpool_("MYDPS", &c__1, &c__7, &n, values, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("VALUES", values, "=", mydata, &c__6, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Add string data through the PCPOOL interface.", (ftnlen)45);
    s_copy(mystrs, "String 1", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 32, "String 2", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 64, "String 3", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 96, "String 4", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 128, "String 5", (ftnlen)32, (ftnlen)8);
    pcpool_("MYSTRS", &c__5, mystrs, (ftnlen)6, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dtpool_("MYSTRS", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "C", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    gcpool_("MYSTRS", &c__1, &c__7, &n, cvalue, &found, (ftnlen)6, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("CVALUE(1)", cvalue, "=", mystrs, ok, (ftnlen)9, (ftnlen)140, (
	    ftnlen)1, (ftnlen)32);
    chcksc_("CVALUE(2)", cvalue + 140, "=", mystrs + 32, ok, (ftnlen)9, (
	    ftnlen)140, (ftnlen)1, (ftnlen)32);
    chcksc_("CVALUE(3)", cvalue + 280, "=", mystrs + 64, ok, (ftnlen)9, (
	    ftnlen)140, (ftnlen)1, (ftnlen)32);
    chcksc_("CVALUE(4)", cvalue + 420, "=", mystrs + 96, ok, (ftnlen)9, (
	    ftnlen)140, (ftnlen)1, (ftnlen)32);
    chcksc_("CVALUE(5)", cvalue + 560, "=", mystrs + 128, ok, (ftnlen)9, (
	    ftnlen)140, (ftnlen)1, (ftnlen)32);
    tcase_("Add integer data through the PIPOOL interface", (ftnlen)45);
    myints[0] = 5;
    myints[1] = 6;
    myints[2] = 7;
    myints[3] = 8;
    myints[4] = 9;
    myints[5] = 10;
    pipool_("MYINTS", &c__4, myints, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dtpool_("MYINTS", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    gipool_("MYINTS", &c__1, &c__7, &n, ivals, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckai_("IVALS", ivals, "=", myints, &c__4, ok, (ftnlen)5, (ftnlen)1);
    tcase_("See if we can still clear the kernel pool. ", (ftnlen)43);
    clpool_();
    dtpool_("MYDPS", &found, &n, type__, (ftnlen)5, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    dtpool_("MYSTRS", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksc_("TYPE", type__, "=", "X", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Check that loading from a text buffer works.Note that these test"
	    "s are the same as test case 1 and 2 but for variables loaded fro"
	    "m an internal text buffer. ", (ftnlen)155);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( 5, 4, 3, 2 )", (ftnlen)140, (
	    ftnlen)34);
    s_copy(text + 2800, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 2940, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    lmpool_(text + 140, &c__23, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    esize[0] = 1;
    esize[1] = 1;
    esize[2] = 1;
    esize[3] = 1;
    esize[4] = 1;
    esize[5] = 1;
    esize[6] = 1;
    esize[7] = 1;
    esize[8] = 1;
    esize[9] = 10;
    esize[10] = 6;
    for (i__ = 1; i__ <= 11; ++i__) {
	s_copy(varnam, "VALUE#", (ftnlen)32, (ftnlen)6);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
	tstmsg_("#", varnam, (ftnlen)1, (ftnlen)32);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("N", &n, "=", &esize[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? 
		i__1 : s_rnge("esize", i__1, "f_pool__", (ftnlen)1288)], &
		c__0, ok, (ftnlen)1, (ftnlen)1);
	chcksc_("TYPE", type__, "=", "N", ok, (ftnlen)4, (ftnlen)1, (ftnlen)1,
		 (ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 1", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE1", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("1", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE1", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    tstmsg_("#", "Checking Value 2", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE2", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("2", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE2", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 3", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE3", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("PI", evals, error, &ptr, (ftnlen)2, (ftnlen)140);
    chckad_("VALUE3", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 4", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE4", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("3", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE4", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 5", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE5", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("4", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE5", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 6", (ftnlen)1, (ftnlen)16);
    gdpool_("VALUE6", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    nparsd_("5", evals, error, &ptr, (ftnlen)1, (ftnlen)140);
    chckad_("VALUE6", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 7", (ftnlen)1, (ftnlen)16);
    nparsd_("1.276828E+11", evals, error, &ptr, (ftnlen)12, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE7", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE7", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 8", (ftnlen)1, (ftnlen)16);
    nparsd_("-28.19729871E+12", evals, error, &ptr, (ftnlen)16, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE8", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE8", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 9", (ftnlen)1, (ftnlen)16);
    tparse_("1-JAN-1994", evals, error, (ftnlen)10, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gdpool_("VALUE9", &c__1, &c__1, &n, values, &found, (ftnlen)6);
    chckad_("VALUE9", values, "=", evals, &c__1, &c_b60, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 1.;
    evals[1] = 2.;
    evals[2] = 3.;
    evals[3] = 4.;
    evals[4] = 5.;
    evals[5] = 6.;
    evals[6] = 7.;
    evals[7] = 8.;
    evals[8] = 9.;
    evals[9] = 10.;
    tstmsg_("#", "Checking Value 10", (ftnlen)1, (ftnlen)17);
    gdpool_("VALUE10", &c__3, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", &evals[2], &c__5, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 2.", (ftnlen)1, (ftnlen)25);
    gdpool_("VALUE10", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("VALUE10", values, "=", evals, &c__10, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__10, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tstmsg_("#", "Checking Value 10 part 3", (ftnlen)1, (ftnlen)24);
    gdpool_("VALUE10", &c__11, &c__5, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    evals[0] = 5.;
    evals[1] = 4.;
    evals[2] = 3.;
    evals[3] = 2.;
    evals[4] = 1.;
    evals[5] = 0.;
    tstmsg_("#", "Checking Value 11", (ftnlen)1, (ftnlen)17);
    gdpool_("VALUE11", &c__1, &c__10, &n, values, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__6, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("VALUE11", values, "=", evals, &c__6, &c_b60, ok, (ftnlen)7, (
	    ftnlen)1);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure we can read strings in from a text buffer. This is the"
	    " same set of checks as used when we loaded string valued variabl"
	    "es from a text file.  This time we load directly from a text buf"
	    "fer. ", (ftnlen)197);
    s_copy(text + 140, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 280, "   SVALUE1  = 'String 1'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 420, "   SVALUE2  = 'String 2'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 560, "   SVALUE3  = 'String 3'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 700, "   SVALUE4  = 'String 4'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 840, "   SVALUE5  = 'String 5'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 980, "   SVALUE6  = 'String 6.1', 'String 6.2', 'String 6."
	    "3'", (ftnlen)140, (ftnlen)54);
    s_copy(text + 1120, "   SVALUE6  = 'String 6'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 1260, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 1400, "   SVALUE7 += 'String 7.0'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1540, "   SVALUE7 += 'String 7.1'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1680, "   SVALUE7 += 'String 7.2'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1820, "   SVALUE7 += 'String 7.3'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1960, "   SVALUE7 += 'String 7.4'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 2100, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 2240, "   SVALUE8 = ( 'String 8.0', 'String 8.1',", (ftnlen)
	    140, (ftnlen)42);
    s_copy(text + 2380, "               'String 8.2', 'String 8.3' )", (
	    ftnlen)140, (ftnlen)43);
    lmpool_(text + 140, &c__17, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    esize[0] = 1;
    esize[1] = 1;
    esize[2] = 1;
    esize[3] = 1;
    esize[4] = 1;
    esize[5] = 1;
    esize[6] = 5;
    esize[7] = 4;
    for (i__ = 1; i__ <= 8; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "FOUND for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "N     for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 32, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "TYPE  for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 64, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(item, &found, &c_true, ok, (ftnlen)32);
	chcksi_(item + 32, &n, "=", &esize[(i__1 = i__ - 1) < 20 && 0 <= i__1 
		? i__1 : s_rnge("esize", i__1, "f_pool__", (ftnlen)1477)], &
		c__0, ok, (ftnlen)32, (ftnlen)1);
	chcksc_(item + 64, type__, "=", "C", ok, (ftnlen)32, (ftnlen)1, (
		ftnlen)1, (ftnlen)1);
    }
    s_copy(cvals, "String 7.0", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 140, "String 7.1", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 280, "String 7.2", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 420, "String 7.3", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 560, "String 7.4", (ftnlen)140, (ftnlen)10);
    gcpool_("SVALUE7", &c__1, &c__20, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND for SVALUE7", &found, &c_true, ok, (ftnlen)17);
    chcksi_("N     for SVALUE7", &n, "=", &c__5, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    chcksc_("Value 1 of SVALUE7", cvalue, "=", cvals, ok, (ftnlen)18, (ftnlen)
	    140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 2 of SVALUE7", cvalue + 140, "=", cvals + 140, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 3 of SVALUE7", cvalue + 280, "=", cvals + 280, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 4 of SVALUE7", cvalue + 420, "=", cvals + 420, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 5 of SVALUE7", cvalue + 560, "=", cvals + 560, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    s_copy(cvals, "String 8.0", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 140, "String 8.1", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 280, "String 8.2", (ftnlen)140, (ftnlen)10);
    s_copy(cvals + 420, "String 8.3", (ftnlen)140, (ftnlen)10);
    gcpool_("SVALUE8", &c__3, &c__20, &n, cvalue, &found, (ftnlen)7, (ftnlen)
	    140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND for SVALUE7", &found, &c_true, ok, (ftnlen)17);
    chcksi_("N     for SVALUE7", &n, "=", &c__2, &c__0, ok, (ftnlen)17, (
	    ftnlen)1);
    chcksc_("Value 3 of SVALUE8", cvalue, "=", cvals + 280, ok, (ftnlen)18, (
	    ftnlen)140, (ftnlen)1, (ftnlen)140);
    chcksc_("Value 4 of SVALUE8", cvalue + 140, "=", cvals + 420, ok, (ftnlen)
	    18, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    tcase_("Make sure that watchers work when a direct write to the kernel p"
	    "ool takes place. ", (ftnlen)81);
    s_copy(bnames, "SVALUE1", (ftnlen)32, (ftnlen)7);
    s_copy(bnames + 32, "MYDPS", (ftnlen)32, (ftnlen)5);
    s_copy(nnames, "MYSTRS", (ftnlen)32, (ftnlen)6);
    s_copy(nnames + 32, "MYDPS", (ftnlen)32, (ftnlen)5);
    s_copy(inames, "SVALUE1", (ftnlen)32, (ftnlen)7);
    s_copy(inames + 32, "MYINTS", (ftnlen)32, (ftnlen)6);
    nbill = 2;
    nnat = 2;
    nian = 2;
    swpool_("BILL", &nbill, bnames, (ftnlen)4, (ftnlen)32);
    swpool_("NAT", &nnat, nnames, (ftnlen)3, (ftnlen)32);
    swpool_("IAN", &nian, inames, (ftnlen)3, (ftnlen)32);
    tstmsg_("#", "Initial check of watchers.", (ftnlen)1, (ftnlen)26);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_true, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_true, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_true, ok, (ftnlen)6);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_false, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_false, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_false, ok, (ftnlen)6);
    mydata[0] = 1.;
    mydata[1] = 2.;
    mydata[2] = 3.;
    mydata[3] = 4.;
    mydata[4] = 5.;
    mydata[5] = 6.;
    pdpool_("MYDPS", &c__6, mydata, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstmsg_("#", "Check of watchers after call to PDPOOL.", (ftnlen)1, (
	    ftnlen)39);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_true, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_true, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_false, ok, (ftnlen)6);
    s_copy(text + 140, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 280, "   SVALUE1  = 'String 1'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 420, "   SVALUE2  = 'String 2'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 560, "   SVALUE3  = 'String 3'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 700, "   SVALUE4  = 'String 4'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 840, "   SVALUE5  = 'String 5'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 980, "   SVALUE6  = 'String 6.1', 'String 6.2', 'String 6."
	    "3'", (ftnlen)140, (ftnlen)54);
    s_copy(text + 1120, "   SVALUE6  = 'String 6'", (ftnlen)140, (ftnlen)24);
    s_copy(text + 1260, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 1400, "   SVALUE7 += 'String 7.0'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1540, "   SVALUE7 += 'String 7.1'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1680, "   SVALUE7 += 'String 7.2'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1820, "   SVALUE7 += 'String 7.3'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 1960, "   SVALUE7 += 'String 7.4'", (ftnlen)140, (ftnlen)26)
	    ;
    s_copy(text + 2100, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 2240, "   SVALUE8 = ( 'String 8.0', 'String 8.1',", (ftnlen)
	    140, (ftnlen)42);
    s_copy(text + 2380, "               'String 8.2', 'String 8.3' )", (
	    ftnlen)140, (ftnlen)43);
    lmpool_(text + 140, &c__17, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstmsg_("#", "Check of watchers after call to LMPOOL.", (ftnlen)1, (
	    ftnlen)39);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_true, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_false, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_true, ok, (ftnlen)6);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_false, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_false, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_false, ok, (ftnlen)6);
    myints[0] = 5;
    myints[1] = 6;
    myints[2] = 7;
    myints[3] = 8;
    myints[4] = 9;
    myints[5] = 10;
    tstmsg_("#", "Check of watchers after call to PIPOOL.", (ftnlen)1, (
	    ftnlen)39);
    pipool_("MYINTS", &c__4, myints, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_false, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_false, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_true, ok, (ftnlen)6);
    tstmsg_("#", "Check of watchers after call to PCPOOL.", (ftnlen)1, (
	    ftnlen)39);
    s_copy(mystrs, "String 1", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 32, "String 2", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 64, "String 3", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 96, "String 4", (ftnlen)32, (ftnlen)8);
    s_copy(mystrs + 128, "String 5", (ftnlen)32, (ftnlen)8);
    pcpool_("MYSTRS", &c__5, mystrs, (ftnlen)6, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    cvpool_("IAN", &iupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_false, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_true, ok, (ftnlen)6);
    chcksl_("IUPDAT", &iupdat, &c_false, ok, (ftnlen)6);
    tcase_("Make a cursory examination of SZPOOL", (ftnlen)36);
    szpool_("MAXVAR", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("maxval", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("Maxlin", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("MAXCHR", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("MXNOTE", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("maxlen", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("MAXAGT", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, ">", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("STELLA", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    szpool_("stella", &n, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Check 1. for the empty vector assignment exception. ", (ftnlen)52)
	    ;
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( )", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    s_copy(text + 3360, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__25, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    chckxc_(&c_true, "SPICE(BADVARASSIGN)", ok, (ftnlen)19);
    tcase_("Check 2. for the empty vector assignment exception. ", (ftnlen)52)
	    ;
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = 'PI' ", (ftnlen)140, (ftnlen)24);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( 1 2 )", (ftnlen)140, (ftnlen)
	    27);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    s_copy(text + 3360, " ", (ftnlen)140, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__25, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    s_copy(text + 2660, "         VALUE11  += ( )", (ftnlen)140, (ftnlen)24);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__25, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    ldpool_("testdata.ker", (ftnlen)12);
    chckxc_(&c_true, "SPICE(BADVARASSIGN)", ok, (ftnlen)19);
    tcase_("Check 3 for the empty vector assignment exception. ", (ftnlen)51);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11  = ( )", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    lmpool_(text + 140, &c__22, (ftnlen)140);
    chckxc_(&c_true, "SPICE(BADVARASSIGN)", ok, (ftnlen)19);
    tcase_("Check 4 for the empty vector assignment exception. ", (ftnlen)51);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11 += ( )", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    lmpool_(text + 140, &c__22, (ftnlen)140);
    chckxc_(&c_true, "SPICE(BADVARASSIGN)", ok, (ftnlen)19);
    tcase_("See if we can fetch variable names from the kernel pool via the "
	    "interface GNPOOL ", (ftnlen)81);
    s_copy(text + 2660, "         VALUE11 += ( 10 )", (ftnlen)140, (ftnlen)26)
	    ;
    clpool_();
    s_copy(cvals, "VALUE1", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 140, "VALUE2", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 280, "VALUE3", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 420, "VALUE4", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 560, "VALUE5", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 700, "VALUE6", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 840, "VALUE7", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 980, "VALUE8", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 1120, "VALUE9", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 1260, "VALUE10", (ftnlen)140, (ftnlen)7);
    s_copy(cvals + 1400, "VALUE11", (ftnlen)140, (ftnlen)7);
    lmpool_(text + 140, &c__22, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    gnpool_("*", &c__1, &c__22, &n, text, &found, (ftnlen)1, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__11, &c__0, ok, (ftnlen)1, (ftnlen)1);
    shellc_(&c__11, cvals, (ftnlen)140);
    shellc_(&c__11, text, (ftnlen)140);
    for (i__ = 1; i__ <= 11; ++i__) {
	chcksc_("TEXT", text + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		s_rnge("text", i__1, "f_pool__", (ftnlen)1890)) * 140, "=", 
		cvals + ((i__3 = i__ - 1) < 20 && 0 <= i__3 ? i__3 : s_rnge(
		"cvals", i__3, "f_pool__", (ftnlen)1890)) * 140, ok, (ftnlen)
		4, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    gnpool_("*", &c__1, &c__5, &n, text, &found, (ftnlen)1, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__5, &c__0, ok, (ftnlen)1, (ftnlen)1);
    gnpool_("*X*", &c__1, &c__22, &n, text, &found, (ftnlen)3, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);
    gnpool_("%%%%%%%", &c__1, &c__22, &n, text, &found, (ftnlen)7, (ftnlen)
	    140);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    s_copy(cvals, "VALUE10", (ftnlen)140, (ftnlen)7);
    s_copy(cvals + 140, "VALUE11", (ftnlen)140, (ftnlen)7);
    shellc_(&c__2, cvals, (ftnlen)140);
    shellc_(&c__2, text, (ftnlen)140);
    for (i__ = 1; i__ <= 2; ++i__) {
	chcksc_("TEXT", text + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		s_rnge("text", i__1, "f_pool__", (ftnlen)1916)) * 140, "=", 
		cvals + ((i__3 = i__ - 1) < 20 && 0 <= i__3 ? i__3 : s_rnge(
		"cvals", i__3, "f_pool__", (ftnlen)1916)) * 140, ok, (ftnlen)
		4, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    gnpool_("%%%%%%", &c_n1, &c__22, &n, text, &found, (ftnlen)6, (ftnlen)140)
	    ;
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__9, &c__0, ok, (ftnlen)1, (ftnlen)1);
    s_copy(cvals, "VALUE1", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 140, "VALUE2", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 280, "VALUE3", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 420, "VALUE4", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 560, "VALUE5", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 700, "VALUE6", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 840, "VALUE7", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 980, "VALUE8", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 1120, "VALUE9", (ftnlen)140, (ftnlen)6);
    shellc_(&c__9, cvals, (ftnlen)140);
    shellc_(&c__9, text, (ftnlen)140);
    for (i__ = 1; i__ <= 9; ++i__) {
	chcksc_("TEXT", text + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : 
		s_rnge("text", i__1, "f_pool__", (ftnlen)1938)) * 140, "=", 
		cvals + ((i__3 = i__ - 1) < 20 && 0 <= i__3 ? i__3 : s_rnge(
		"cvals", i__3, "f_pool__", (ftnlen)1938)) * 140, ok, (ftnlen)
		4, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    gnpool_("%%%%%%", &c__3, &c__22, &n, text, &found, (ftnlen)6, (ftnlen)140)
	    ;
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__7, &c__0, ok, (ftnlen)1, (ftnlen)1);
    gnpool_("VALUE", &c__1, &c_n1, &n, text, &found, (ftnlen)5, (ftnlen)140);
    chckxc_(&c_true, "SPICE(BADARRAYSIZE)", ok, (ftnlen)19);
    tcase_("Test to see if we can remove kernel pool variables using DVPOOL. "
	    , (ftnlen)65);
    s_copy(text + 140, "         VALUE1  = 1", (ftnlen)140, (ftnlen)20);
    s_copy(text + 280, "         VALUE2  = 2", (ftnlen)140, (ftnlen)20);
    s_copy(text + 420, "         VALUE3  = PI", (ftnlen)140, (ftnlen)21);
    s_copy(text + 560, "         VALUE4  = 3", (ftnlen)140, (ftnlen)20);
    s_copy(text + 700, "         VALUE5  = 4", (ftnlen)140, (ftnlen)20);
    s_copy(text + 840, "         VALUE6  = 5", (ftnlen)140, (ftnlen)20);
    s_copy(text + 980, "         VALUE7  = 1.276828E+11", (ftnlen)140, (
	    ftnlen)31);
    s_copy(text + 1120, "         VALUE8  = -28.19729871E+12", (ftnlen)140, (
	    ftnlen)35);
    s_copy(text + 1260, "         VALUE9  = @1-JAN-1994", (ftnlen)140, (
	    ftnlen)30);
    s_copy(text + 1400, "         VALUE10 = (", (ftnlen)140, (ftnlen)20);
    s_copy(text + 1540, "                     1,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1680, "                     2,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1820, "                     3,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 1960, "                     4,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2100, "                     5,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2240, "                     6,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2380, "                     7,", (ftnlen)140, (ftnlen)23);
    s_copy(text + 2520, "                     8 )", (ftnlen)140, (ftnlen)24);
    s_copy(text + 2660, "         VALUE11 += ( 5 )", (ftnlen)140, (ftnlen)25);
    s_copy(text + 2800, "         VALUE10 +=  9", (ftnlen)140, (ftnlen)22);
    s_copy(text + 2940, " ", (ftnlen)140, (ftnlen)1);
    s_copy(text + 3080, "         VALUE11 += ( 1, 0 )", (ftnlen)140, (ftnlen)
	    28);
    s_copy(text + 3220, "         VALUE10 += 10", (ftnlen)140, (ftnlen)22);
    clpool_();
    lmpool_(text + 140, &c__22, (ftnlen)140);
    nbill = 1;
    s_copy(bnames, "VALUE1", (ftnlen)32, (ftnlen)6);
    nnat = 1;
    s_copy(nnames, "VALUE2", (ftnlen)32, (ftnlen)6);
    s_copy(nnames + 32, "VALUE3", (ftnlen)32, (ftnlen)6);
    swpool_("BILL", &nbill, bnames, (ftnlen)4, (ftnlen)32);
    swpool_("NAT", &nnat, nnames, (ftnlen)3, (ftnlen)32);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_true, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_true, ok, (ftnlen)6);
    gnpool_("*", &c__1, &c__22, &n, text, &found, (ftnlen)1, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__11, &c__0, ok, (ftnlen)1, (ftnlen)1);
    dtpool_("VALUE1", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    dvpool_("VALUE1", (ftnlen)6);
    dtpool_("VALUE1", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    gnpool_("*", &c__1, &c__22, &n, text, &found, (ftnlen)1, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__10, &c__0, ok, (ftnlen)1, (ftnlen)1);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_true, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_false, ok, (ftnlen)6);
    s_copy(cvals, "VALUE2", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 140, "VALUE3", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 280, "VALUE4", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 420, "VALUE5", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 560, "VALUE6", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 700, "VALUE7", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 840, "VALUE8", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 980, "VALUE9", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 1120, "VALUE10", (ftnlen)140, (ftnlen)7);
    s_copy(cvals + 1260, "VALUE11", (ftnlen)140, (ftnlen)7);
    shellc_(&c__10, cvals, (ftnlen)140);
    shellc_(&c__10, text, (ftnlen)140);
    for (i__ = 1; i__ <= 10; ++i__) {
	chcksc_("TEXT(I)", text + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 
		: s_rnge("text", i__1, "f_pool__", (ftnlen)2042)) * 140, 
		"=", cvals + ((i__3 = i__ - 1) < 20 && 0 <= i__3 ? i__3 : 
		s_rnge("cvals", i__3, "f_pool__", (ftnlen)2042)) * 140, ok, (
		ftnlen)7, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    dtpool_("VALUE2", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    dvpool_("VALUE2", (ftnlen)6);
    dtpool_("VALUE2", &found, &n, type__, (ftnlen)6, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    gnpool_("*", &c__1, &c__22, &n, text, &found, (ftnlen)1, (ftnlen)140);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("N", &n, "=", &c__9, &c__0, ok, (ftnlen)1, (ftnlen)1);
    cvpool_("BILL", &bupdat, (ftnlen)4);
    cvpool_("NAT", &nupdat, (ftnlen)3);
    chcksl_("BUPDAT", &bupdat, &c_false, ok, (ftnlen)6);
    chcksl_("NUPDAT", &nupdat, &c_true, ok, (ftnlen)6);
    s_copy(cvals, "VALUE3", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 140, "VALUE4", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 280, "VALUE5", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 420, "VALUE6", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 560, "VALUE7", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 700, "VALUE8", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 840, "VALUE9", (ftnlen)140, (ftnlen)6);
    s_copy(cvals + 980, "VALUE10", (ftnlen)140, (ftnlen)7);
    s_copy(cvals + 1120, "VALUE11", (ftnlen)140, (ftnlen)7);
    shellc_(&c__9, cvals, (ftnlen)140);
    shellc_(&c__9, text, (ftnlen)140);
    for (i__ = 1; i__ <= 9; ++i__) {
	chcksc_("TEXT(I)", text + ((i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 
		: s_rnge("text", i__1, "f_pool__", (ftnlen)2082)) * 140, 
		"=", cvals + ((i__3 = i__ - 1) < 20 && 0 <= i__3 ? i__3 : 
		s_rnge("cvals", i__3, "f_pool__", (ftnlen)2082)) * 140, ok, (
		ftnlen)7, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    tcase_("Test to see if long string values are processed correctly. ", (
	    ftnlen)59);
    begdat_(ch__1, (ftnlen)32);
    s_copy(text, ch__1, (ftnlen)140, (ftnlen)32);
    s_copy(text + 140, "SVALUE1  = 'Seventy-nine character long string -----"
	    "-------------------------------------89'", (ftnlen)140, (ftnlen)
	    92);
    s_copy(text + 280, "SVALUE2  = 'Eighty character long string -----------"
	    "-------------------------------------890'", (ftnlen)140, (ftnlen)
	    93);
    s_copy(text + 420, "SVALUE3  = 'Eighty-one character long string -------"
	    "-------------------------------------8901'", (ftnlen)140, (ftnlen)
	    94);
    s_copy(text + 560, "SVALUE4  = 'Seventy-nine character long string with "
	    "middle quote ''-----------------------89'", (ftnlen)140, (ftnlen)
	    93);
    s_copy(text + 700, "SVALUE5  = 'Seventy-nine character long string with "
	    "closing quote -----------------------8'''", (ftnlen)140, (ftnlen)
	    93);
    s_copy(text + 840, "SVALUE6  = 'Eighty character long string with middle"
	    " quote ''-----------------------------890'", (ftnlen)140, (ftnlen)
	    94);
    s_copy(text + 980, "SVALUE7  = 'Eighty character long string with closin"
	    "g quote -----------------------------89'''", (ftnlen)140, (ftnlen)
	    94);
    s_copy(text + 1120, "SVALUE8  = 'Eighty-one character long string with m"
	    "iddle quote ''-------------------------8901'", (ftnlen)140, (
	    ftnlen)95);
    s_copy(text + 1260, "SVALUE9  = 'Eighty-one character long string with c"
	    "losing quote -------------------------890'''", (ftnlen)140, (
	    ftnlen)95);
    s_copy(text + 1400, "SVALUE10 = 'Seventy-nine character long string with"
	    " two closing quotes -----------------7'''''", (ftnlen)140, (
	    ftnlen)94);
    s_copy(text + 1540, "SVALUE11 = 'Eighty character long string with two c"
	    "losing quotes -----------------------78'''''", (ftnlen)140, (
	    ftnlen)95);
    s_copy(text + 1680, "SVALUE12 = 'Eighty-one character long string with t"
	    "wo closing quotes -------------------789'''''", (ftnlen)140, (
	    ftnlen)96);
    s_copy(text + 1820, "SVALUE13 = 'Ten space-separated quotes string '' ''"
	    " '' '' '' '' '' '' '' '''", (ftnlen)140, (ftnlen)76);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__14, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    clpool_();
    ldpool_("testdata.ker", (ftnlen)12);
    s_copy(cvals, "Seventy-nine character long string ----------------------"
	    "--------------------89", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 140, "Eighty character long string ----------------------"
	    "--------------------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 280, "Eighty-one character long string ------------------"
	    "--------------------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 420, "Seventy-nine character long string with middle quot"
	    "e '-----------------------89", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 560, "Seventy-nine character long string with closing quo"
	    "te -----------------------8'", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 700, "Eighty character long string with middle quote '---"
	    "--------------------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 840, "Eighty character long string with closing quote ---"
	    "--------------------------89'", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 980, "Eighty-one character long string with middle quote "
	    "'-------------------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 1120, "Eighty-one character long string with closing quot"
	    "e -------------------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 1260, "Seventy-nine character long string with two closin"
	    "g quotes -----------------7''", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 1400, "Eighty character long string with two closing quot"
	    "es -----------------------78''", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 1540, "Eighty-one character long string with two closing "
	    "quotes -------------------789'", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 1680, "Ten space-separated quotes string ' ' ' ' ' ' ' ' "
	    "' '", (ftnlen)140, (ftnlen)53);
    for (i__ = 1; i__ <= 13; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "FOUND for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "N     for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 32, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "TYPE  for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 64, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(item, &found, &c_true, ok, (ftnlen)32);
	chcksi_(item + 32, &n, "=", &c__1, &c__0, ok, (ftnlen)32, (ftnlen)1);
	chcksc_(item + 64, type__, "=", "C", ok, (ftnlen)32, (ftnlen)1, (
		ftnlen)1, (ftnlen)1);
	gcpool_(varnam, &c__1, &c__1, &n, cvalue, &found, (ftnlen)32, (ftnlen)
		140);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "VALUE for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
	chcksc_(item, cvalue, "=", cvals + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("cvals", i__1, "f_pool__", (ftnlen)2193))
		 * 140, ok, (ftnlen)32, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    tcase_("Test to see if long/truncated kernel file lines containing strin"
	    "g array assignments are processed correctly. ", (ftnlen)109);
    s_copy(text + 140, "SVALUE1 = (                           ", (ftnlen)140, 
	    (ftnlen)38);
    s_copy(text + 280, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 420, "                                                 'Ei"
	    "ghty character long string under 132-character line limit ------"
	    "-----------890'", (ftnlen)140, (ftnlen)131);
    s_copy(text + 560, "          )                           ", (ftnlen)140, 
	    (ftnlen)38);
    s_copy(text + 700, "SVALUE2 = (                           ", (ftnlen)140, 
	    (ftnlen)38);
    s_copy(text + 840, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 980, "                                                  'E"
	    "ighty character long string at 132-character line limit (a)-----"
	    "------------890'", (ftnlen)140, (ftnlen)132);
    s_copy(text + 1120, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 1260, "SVALUE3 = (                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 1400, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 1540, "                                                   "
	    "'Eighty character long string at 132-character line limit (b)---"
	    "--------------890'", (ftnlen)140, (ftnlen)133);
    s_copy(text + 1680, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 1820, "SVALUE4 = (                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 1960, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 2100, "                                                   "
	    " 'Eighty character long string over 132-character line limit (a)"
	    "---------------890'", (ftnlen)140, (ftnlen)134);
    s_copy(text + 2240, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 2380, "SVALUE5 = (                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 2520, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 2660, "                                                   "
	    "  'Eighty character long string over 132-character line limit (b"
	    ")---------------890'", (ftnlen)140, (ftnlen)135);
    s_copy(text + 2800, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 2940, "SVALUE6 = (                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 3080, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 3220, "                                                  '"
	    "Eighty character long string at 132-character line limit (a)----"
	    "-------------8'''", (ftnlen)140, (ftnlen)132);
    s_copy(text + 3360, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 3500, "SVALUE7 = (                           ", (ftnlen)140,
	     (ftnlen)38);
    s_copy(text + 3640, "           'short value'            ", (ftnlen)140, (
	    ftnlen)36);
    s_copy(text + 3780, "                                                  '"
	    "Eighty character long string at 132-character line limit (a)----"
	    "-------------89'''", (ftnlen)140, (ftnlen)133);
    s_copy(text + 3920, "          )                           ", (ftnlen)140,
	     (ftnlen)38);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__29, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    clpool_();
    ldpool_("testdata.ker", (ftnlen)12);
    s_copy(cvals, "Eighty character long string under 132-character line lim"
	    "it -----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 140, "Eighty character long string at 132-character line "
	    "limit (a)-----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 280, "Eighty character long string at 132-character line "
	    "limit (b)-----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 420, "Eighty character long string over 132-character lin"
	    "e limit (a)---------------89", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 560, "Eighty character long string over 132-character lin"
	    "e limit (b)---------------8", (ftnlen)140, (ftnlen)78);
    s_copy(cvals + 700, "Eighty character long string at 132-character line "
	    "limit (a)-----------------8'", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 840, "Eighty character long string at 132-character line "
	    "limit (a)-----------------89'", (ftnlen)140, (ftnlen)80);
    for (i__ = 1; i__ <= 7; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "FOUND for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "N     for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 32, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "TYPE  for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 64, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(item, &found, &c_true, ok, (ftnlen)32);
	chcksi_(item + 32, &n, "=", &c__2, &c__0, ok, (ftnlen)32, (ftnlen)1);
	chcksc_(item + 64, type__, "=", "C", ok, (ftnlen)32, (ftnlen)1, (
		ftnlen)1, (ftnlen)1);
	gcpool_(varnam, &c__2, &c__1, &n, cvalue, &found, (ftnlen)32, (ftnlen)
		140);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "VALUE for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
	chcksc_(item, cvalue, "=", cvals + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("cvals", i__1, "f_pool__", (ftnlen)2298))
		 * 140, ok, (ftnlen)32, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    tcase_("Test to see if long/truncated kernel file lines containing strin"
	    "g value assignments are processed correctly. ", (ftnlen)109);
    s_copy(text + 140, "SVALUE1 =                                        'Ei"
	    "ghty character long string under 132-character line limit ------"
	    "-----------890'", (ftnlen)140, (ftnlen)131);
    s_copy(text + 280, "SVALUE2 =                                         'E"
	    "ighty character long string at 132-character line limit (a)-----"
	    "------------890'", (ftnlen)140, (ftnlen)132);
    s_copy(text + 420, "SVALUE3 =                                          '"
	    "Eighty character long string at 132-character line limit (b)----"
	    "-------------890'", (ftnlen)140, (ftnlen)133);
    s_copy(text + 560, "SVALUE4 =                                           "
	    "'Eighty character long string over 132-character line limit (a)-"
	    "--------------890'", (ftnlen)140, (ftnlen)134);
    s_copy(text + 700, "SVALUE5 =                                           "
	    " 'Eighty character long string over 132-character line limit (b)"
	    "---------------890'", (ftnlen)140, (ftnlen)135);
    s_copy(text + 840, "SVALUE6 =                                         'E"
	    "ighty character long string at 132-character line limit (a)-----"
	    "------------8'''", (ftnlen)140, (ftnlen)132);
    s_copy(text + 980, "SVALUE7 =                                         'E"
	    "ighty character long string at 132-character line limit (a)-----"
	    "------------89'''", (ftnlen)140, (ftnlen)133);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__8, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)140);
    clpool_();
    ldpool_("testdata.ker", (ftnlen)12);
    s_copy(cvals, "Eighty character long string under 132-character line lim"
	    "it -----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 140, "Eighty character long string at 132-character line "
	    "limit (a)-----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 280, "Eighty character long string at 132-character line "
	    "limit (b)-----------------890", (ftnlen)140, (ftnlen)80);
    s_copy(cvals + 420, "Eighty character long string over 132-character lin"
	    "e limit (a)---------------89", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 560, "Eighty character long string over 132-character lin"
	    "e limit (b)---------------8", (ftnlen)140, (ftnlen)78);
    s_copy(cvals + 700, "Eighty character long string at 132-character line "
	    "limit (a)-----------------8'", (ftnlen)140, (ftnlen)79);
    s_copy(cvals + 840, "Eighty character long string at 132-character line "
	    "limit (a)-----------------89'", (ftnlen)140, (ftnlen)80);
    for (i__ = 1; i__ <= 7; ++i__) {
	s_copy(varnam, "SVALUE#", (ftnlen)32, (ftnlen)7);
	repmi_(varnam, "#", &i__, varnam, (ftnlen)32, (ftnlen)1, (ftnlen)32);
	dtpool_(varnam, &found, &n, type__, (ftnlen)32, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "FOUND for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "N     for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 32, a__1, i__2, &c__2, (ftnlen)32);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "TYPE  for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item + 64, a__1, i__2, &c__2, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_(item, &found, &c_true, ok, (ftnlen)32);
	chcksi_(item + 32, &n, "=", &c__1, &c__0, ok, (ftnlen)32, (ftnlen)1);
	chcksc_(item + 64, type__, "=", "C", ok, (ftnlen)32, (ftnlen)1, (
		ftnlen)1, (ftnlen)1);
	gcpool_(varnam, &c__1, &c__1, &n, cvalue, &found, (ftnlen)32, (ftnlen)
		140);
/* Writing concatenation */
	i__2[0] = 10, a__1[0] = "VALUE for ";
	i__2[1] = 32, a__1[1] = varnam;
	s_cat(item, a__1, i__2, &c__2, (ftnlen)32);
	chcksc_(item, cvalue, "=", cvals + ((i__1 = i__ - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("cvals", i__1, "f_pool__", (ftnlen)2382))
		 * 140, ok, (ftnlen)32, (ftnlen)140, (ftnlen)1, (ftnlen)140);
    }
    kilfil_("testdata.ker", (ftnlen)12);
    kilfil_("writdata.ker", (ftnlen)12);
    kilfil_("write.dat", (ftnlen)9);
    t_success__(ok);
    return 0;
} /* f_pool__ */

