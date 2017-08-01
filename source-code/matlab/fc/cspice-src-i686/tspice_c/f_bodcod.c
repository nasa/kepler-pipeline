/* f_bodcod.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static integer c__665 = 665;
static integer c__1001 = 1001;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__2 = 2;
static integer c__1002 = 1002;
static integer c__1003 = 1003;
static integer c__1004 = 1004;
static integer c__1007 = 1007;
static integer c__1008 = 1008;
static integer c__3 = 3;
static integer c__399 = 399;
static integer c__1005 = 1005;
static integer c__1006 = 1006;
static integer c__1011 = 1011;
static integer c__1012 = 1012;
static integer c__1013 = 1013;
static integer c__1014 = 1014;
static integer c__1015 = 1015;
static integer c__1016 = 1016;
static integer c__1017 = 1017;
static integer c__1018 = 1018;
static integer c__10001 = 10001;
static integer c__12000 = 12000;
static integer c__20151 = 20151;
static integer c__6 = 6;
static integer c__1021 = 1021;
static integer c__1020 = 1020;
static integer c__1019 = 1019;
static integer c__1 = 1;
static integer c__599 = 599;
static integer c__777 = 777;
static integer c_b818 = 1000000000;

/* $Procedure F_BODCOD ( Body Code/Name Mapping Test Family ) */
/* Subroutine */ int f_bodcod__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    char ch__1[10];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer code;
    char name__[200], hold[200];
    extern /* Subroutine */ int zzbodget_(integer *, char *, char *, integer *
	    , integer *, ftnlen, ftnlen), zzbodrst_(void);
    integer i__, j;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer nvals;
    extern /* Subroutine */ int topen_(char *, ftnlen), bodc2n_(integer *, 
	    char *, logical *, ftnlen), bodn2c_(char *, integer *, logical *, 
	    ftnlen), t_success__(logical *), bods2c_(char *, integer *, 
	    logical *, ftnlen), boddef_(char *, integer *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    integer bascod[665];
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    char basnam[36*665];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    char buffer[80*10];
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    char tkname[200], basnor[36*665];
    extern /* Subroutine */ int clpool_(void), lmpool_(char *, integer *, 
	    ftnlen), furnsh_(char *, ftnlen);
    integer restor;
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code in the body code to */
/*     name and name to code mapping software. */

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
/* $ Abstract */

/*     This include file lists the parameter collection */
/*     defining the number of SPICE ID -> NAME mappings. */

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

/*     naif_ids.req */

/* $ Keywords */

/*     Body mappings. */

/* $ Author_and_Institution */

/*     E.D. Wright (JPL) */

/* $ Version */

/*     SPICELIB 1.0.0 Tue Nov 15 13:59:42 2005 (EDW) */


/*     A script generates this file. Do not edit by hand. */
/*     Edit the creation script to modify the contents of */
/*     ZZBODTRN.INC. */


/*     Maximum size of a NAME string */


/*     Count of default SPICE mapping assignments. */

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

/*     This routine exercises the conformance of the body name-to-code */
/*     and code-to-name mapping software to the changes implemented */
/*     in N0053. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     1) After a cursory examination of the body ID codes currently in */
/*        use in ZZBODTRN, it seems the range (1000,2000) is reasonable */
/*        to assume as "unused".  This test family makes use of codes */
/*        in this range for testing purposes. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 22-JUL-2004 (NJB) */

/*        Test cases for BODS2C were added. */

/* -    TSPICE Version 1.0.0, 12-AUG-2002 (FST) */


/* -& */

/*     TESTUTIL Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_BODCOD", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check cleared state of test module ID codes.", (ftnlen)44);

/*     Verify that NROOM is even.  It must be otherwise a few of the */
/*     test cases will fail. */

    chcksi_("NROOM-EVEN", &c__0, "=", &c__0, &c__0, ok, (ftnlen)10, (ftnlen)1)
	    ;

/*     Retrieve the built-in code/name arrays. */

    zzbodget_(&c__665, basnam, basnor, bascod, &nvals, (ftnlen)36, (ftnlen)36)
	    ;

/* --- Case: ------------------------------------------------------ */

    tcase_("Multiple NAMES to a single code, BODDEF", (ftnlen)39);
    boddef_("F_BODCOD_TESTA", &c__1001, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1001, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTA", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now assign a new name to the same code using BODDEF. */

    boddef_("F_BODCOD_TEST", &c__1001, (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the newer name takes precedence. */

    bodc2n_(&c__1001, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TEST", ok, (ftnlen)4, (ftnlen)200, 
	    (ftnlen)1, (ftnlen)13);

/*     Depending on the sorting algorithm this could go a number */
/*     of ways.  Check a name that would occur "after" F_BODCOD_TESTA */
/*     in the list as well. */

    boddef_("F_BODCOD_TESTB", &c__1001, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the newer name takes precedence. */

    bodc2n_(&c__1001, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTB", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Multiple NAMES to a single code, TEXT KERNEL", (ftnlen)44);
    s_copy(buffer, "NAIF_BODY_CODE = 1002", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTC'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the assignment worked. */

    bodc2n_(&c__1002, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTC", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now append a new name with the same code. */

    s_copy(buffer, "NAIF_BODY_CODE += 1002", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_ATEST'", (ftnlen)80, (
	    ftnlen)34);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the newer name takes precedence. */

    bodc2n_(&c__1002, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_ATEST", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Depending on the sorting algorithm this could go a number */
/*     of ways.  Check a name that would occur "after" F_BODCOD_TESTC */
/*     in the list as well. */

    s_copy(buffer, "NAIF_BODY_CODE += 1002", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TESTD'", (ftnlen)80, (
	    ftnlen)34);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the newer name takes precedence. */

    bodc2n_(&c__1002, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTD", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Multiple NAMES to a single code, BODDEF then TEXT", (ftnlen)49);
    boddef_("F_BODCOD_TESTE", &c__1003, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1003, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTE", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now add a new name with the text kernel system. */

    s_copy(buffer, "NAIF_BODY_CODE = 1003", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTF'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the text-kernel name takes precedence. */

    bodc2n_(&c__1003, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTF", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Multiple NAMES to a single code, TEXT then BODDEF", (ftnlen)49);
    s_copy(buffer, "NAIF_BODY_CODE = 1004", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTG'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1004, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTG", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now add a new name with the text kernel system. */

    boddef_("F_BODCOD_TESTH", &c__1004, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that the text-kernel name takes precedence. */

    bodc2n_(&c__1004, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTG", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check whitespace/case-sensitivity on name, BODDEF", (ftnlen)49);
    boddef_("F_BODcOd_TestJ  space", &c__1007, (ftnlen)21);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the assignment works properly. */

    bodc2n_(&c__1007, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODcOd_TestJ  space", ok, (ftnlen)4, (
	    ftnlen)200, (ftnlen)1, (ftnlen)21);

/*     Add the same name with different case/spacing. */

    boddef_("F_BoDCoD_TesTj    space", &c__1007, (ftnlen)23);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the assignment worked properly. */

    bodc2n_(&c__1007, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BoDCoD_TesTj    space", ok, (ftnlen)4, (
	    ftnlen)200, (ftnlen)1, (ftnlen)23);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check whitespace/case-sensitivity on name, TEXT", (ftnlen)47);
    s_copy(buffer, "NAIF_BODY_CODE = 1008", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'f_bodCoD_TesTK    blank'", (ftnlen)
	    80, (ftnlen)42);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the assignment works properly. */

    bodc2n_(&c__1008, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "f_bodCoD_TesTK    blank", ok, (ftnlen)4, (
	    ftnlen)200, (ftnlen)1, (ftnlen)23);

/*     Attempt to override this with a BODDEF assignment. */

    boddef_("F_bodCOD_TESTK   space", &c__1008, (ftnlen)22);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that this assignment worked. */

    bodn2c_("F_BODCOD_TESTK SPACE", &code, &found, (ftnlen)20);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1008, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Now see that the latest text-kernel entry takes precedence. */

    bodc2n_(&c__1008, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "f_bodCoD_TesTK    blank", ok, (ftnlen)4, (
	    ftnlen)200, (ftnlen)1, (ftnlen)23);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Test diagnostics on text-kernel load.", (ftnlen)37);

/*     Clear the pool. */

    clpool_();

/*     Construct a text-kernel with name-code assignments that */
/*     will cause FURNSH to signal an error upon loading. */

    s_copy(tkname, "testtk.tk", (ftnlen)200, (ftnlen)9);
    begdat_(ch__1, (ftnlen)10);
    s_copy(buffer, ch__1, (ftnlen)80, (ftnlen)10);
    s_copy(buffer + 80, "NAIF_BODY_CODE = ( 1009, 1010 )", (ftnlen)80, (
	    ftnlen)31);
    s_copy(buffer + 160, "NAIF_BODY_NAME = ( 'SPUD' )", (ftnlen)80, (ftnlen)
	    27);
    tsttxt_(tkname, buffer, &c__3, &c_false, &c_true, (ftnlen)200, (ftnlen)80)
	    ;

/*     Load the kernel and verify that an error has been signaled. */

    furnsh_(tkname, (ftnlen)200);
    chckxc_(&c_true, "SPICE(BADDIMENSIONS)", ok, (ftnlen)20);
    clpool_();
    kilfil_(tkname, (ftnlen)200);

/*     Try a simple code to name conversion to see if the error */
/*     is still floating around. */

    bodc2n_(&c__399, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */


/*     This test case is commented out, because no changes were made */
/*     to BODDEF in N0053. */

    tcase_("BODDEF multiple codes to single name masking.", (ftnlen)45);
    boddef_("F_BODCOD_TESTI", &c__1005, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1005, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTI", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now attempt to assign F_BODCOD_TESTI a new ID code, this */
/*     should be allowed due to masking updates. */

    boddef_("F_BODCOD_TESTI", &c__1006, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the results of the assignment work as expected. */

    bodc2n_(&c__1006, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTI", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1005, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("TEXT multiple codes to single name masking.", (ftnlen)43);
    s_copy(buffer, "NAIF_BODY_CODE = 1011", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTL'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1011, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTL", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now attempt to assign F_BODCOD_TEST_L a new ID code.  This */
/*     should be allowed due to masking updates. */

    s_copy(buffer, "NAIF_BODY_CODE += 1012", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TESTL'", (ftnlen)80, (
	    ftnlen)34);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the results of the assignment work as expected. */

    bodc2n_(&c__1012, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTL", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1011, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Simple BODDEF masked by TEXT case.", (ftnlen)34);
    boddef_("F_BODCOD_TESTM", &c__1013, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1013, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTM", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now load a definition that masks this name. */

    s_copy(buffer, "NAIF_BODY_CODE = 1014", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTM'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Perform all of the necessary state checks at this point. */

    bodn2c_("F_BODCOD_TESTM", &code, &found, (ftnlen)14);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1014, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1014, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTM", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     The original BODDEF code should now be effectively masked. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1013, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Now clear the pool to unload the text kernel assignment. */

    clpool_();
    bodn2c_("F_BODCOD_TESTM", &code, &found, (ftnlen)14);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1013, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1013, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTM", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1014, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("TEXT first, invisible BODDEF", (ftnlen)28);

/*     Load a definition via the text-kernel interface. */

    s_copy(buffer, "NAIF_BODY_CODE = 1015", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'F_BODCOD_TESTN'", (ftnlen)80, (
	    ftnlen)33);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that this assignment worked as expected. */

    bodc2n_(&c__1015, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTN", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     Now make a BODDEF assignment that would appear to be */
/*     invisible as a result of masking. */

    boddef_("F_BODCOD_TESTN", &c__1016, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Perform all of the necessary state checks at this point. */

    bodn2c_("F_BODCOD_TESTN", &code, &found, (ftnlen)14);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1015, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1015, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTN", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);

/*     The BODDEF code should now be effectively masked. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1016, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Now clear the pool to unload the text kernel assignment. */

    clpool_();
    bodn2c_("F_BODCOD_TESTN", &code, &found, (ftnlen)14);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1016, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1016, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TESTN", ok, (ftnlen)4, (ftnlen)200,
	     (ftnlen)1, (ftnlen)14);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1015, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("BODDEF overriding built-in codes", (ftnlen)32);

/*     Obtain the current code for body to override. */

    bodn2c_("EARTH", &restor, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Now override the code for EARTH with a new one. */

    boddef_("EARTH", &c__1017, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the assignment worked. */

    bodn2c_("EARTH", &code, &found, (ftnlen)5);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1017, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1017, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH", ok, (ftnlen)4, (ftnlen)200, (ftnlen)
	    1, (ftnlen)5);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&restor, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Restore the original code for EARTH. */

    boddef_("EARTH", &restor, (ftnlen)5);

/*     Check that it is restored. */

    bodn2c_("EARTH", &code, &found, (ftnlen)5);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &restor, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&restor, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH", ok, (ftnlen)4, (ftnlen)200, (ftnlen)
	    1, (ftnlen)5);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("TEXT overriding built-in codes", (ftnlen)30);
    bodn2c_("MARS", &restor, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Load a definition via the text-kernel interface that blasts */
/*     a built in code. */

    s_copy(buffer, "NAIF_BODY_CODE = 1018", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'MARS'", (ftnlen)80, (ftnlen)23);
    lmpool_(buffer, &c__2, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the assignment worked. */

    bodn2c_("MARS", &code, &found, (ftnlen)4);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1018, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__1018, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "MARS", ok, (ftnlen)4, (ftnlen)200, (ftnlen)
	    1, (ftnlen)4);
    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&restor, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Restore the original assignment. */

    clpool_();

/*     Check that it is restored. */

    bodn2c_("MARS", &code, &found, (ftnlen)4);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &restor, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&restor, name__, &found, (ftnlen)200);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "MARS", ok, (ftnlen)4, (ftnlen)200, (ftnlen)
	    1, (ftnlen)4);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Fill TEXT buffer with unique entries", (ftnlen)36);

/*     Load up many more definitions than ZZBODTRN can handle. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TEST_#'", (ftnlen)80,
		 (ftnlen)35);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = i__ + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }

/*     See what happens... */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(hold, "F_BODCOD_TEST_#", (ftnlen)200, (ftnlen)15);
	s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
	i__1 = i__ + 10000;
	repmi_(hold, "#", &i__1, hold, (ftnlen)200, (ftnlen)1, (ftnlen)200);
	i__1 = i__ + 10000;
	bodc2n_(&i__1, name__, &found, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("NAME", name__, "=", hold, ok, (ftnlen)4, (ftnlen)200, (
		ftnlen)1, (ftnlen)200);
	bodn2c_(hold, &code, &found, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	i__1 = i__ + 10000;
	chcksi_("CODE", &code, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }

/*     Clear the pool, resetting kernel pool variable assignments. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Overflow TEXT buffer with unique entries.", (ftnlen)41);

/*     Load up many more definitions than ZZBODTRN can handle. */

    for (i__ = 1; i__ <= 2001; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TEST_#'", (ftnlen)80,
		 (ftnlen)35);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = i__ + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }

/*     At this point we're set to observe an error signalled by the first */
/*     routine that causes the processing of the NAME/CODE kernel pool */
/*     variable pair. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__10001, name__, &found, (ftnlen)200);
    chckxc_(&c_true, "SPICE(KERVARTOOBIG)", ok, (ftnlen)19);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Clear the pool, resetting kernel pool variable assignments. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Fill TEXT buffer with doubled up entries.", (ftnlen)41);

/*     Load up many more definitions than ZZBODTRN can handle. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TEST_#'", (ftnlen)80,
		 (ftnlen)35);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = (i__ + 1) / 2 + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }

/*     Check results. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(hold, "F_BODCOD_TEST_#", (ftnlen)200, (ftnlen)15);
	s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
	i__1 = (i__ + 1) / 2 + 10000;
	repmi_(hold, "#", &i__1, hold, (ftnlen)200, (ftnlen)1, (ftnlen)200);
	i__1 = i__ + 10000;
	bodc2n_(&i__1, name__, &found, (ftnlen)200);
	if (i__ % 2 == 0) {
	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksc_("NAME", name__, "=", hold, ok, (ftnlen)4, (ftnlen)200, (
		    ftnlen)1, (ftnlen)200);
	} else {
	    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
	    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (
		    ftnlen)200, (ftnlen)1, (ftnlen)11);
	}
	bodn2c_(hold, &code, &found, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	i__1 = i__ + 10000 + i__ % 2;
	chcksi_("CODE", &code, "=", &i__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }

/*     Clear the pool, resetting kernel pool variable assignments. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Fill TEXT buffer with the same masked entries.", (ftnlen)46);

/*     Load up one name with NROOM masks. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'F_BODCOD_TEST_DUPES'", (
		ftnlen)80, (ftnlen)39);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }

/*     Check the state of the system. */

    for (i__ = 1; i__ <= 1999; ++i__) {
	s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
	i__1 = i__ + 10000;
	bodc2n_(&i__1, name__, &found, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
	chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)
		200, (ftnlen)1, (ftnlen)11);
    }
    bodc2n_(&c__12000, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "F_BODCOD_TEST_DUPES", ok, (ftnlen)4, (
	    ftnlen)200, (ftnlen)1, (ftnlen)19);
    bodn2c_("F_BODCOD_TEST_DUPES", &code, &found, (ftnlen)19);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__12000, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clear the pool to reset the variables. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

/*     This test case must be commented out in general, because */
/*     BODDEF assignments (as of yet) can not be removed once made. */

    tcase_("Overflow BODDEF buffer.", (ftnlen)23);

/*     We expect this to result in an error being signaled, although */
/*     when this error is signaled is not exactly known.  This is */
/*     because it is not clear how many unique BODDEF assignments */
/*     prior to this test family's execution have occurred. */

    for (i__ = 1; i__ <= 150; ++i__) {
	s_copy(name__, "F_BODCOD_TEST_#", (ftnlen)200, (ftnlen)15);
	i__1 = i__ + 20000;
	repmi_(name__, "#", &i__1, name__, (ftnlen)200, (ftnlen)1, (ftnlen)
		200);
	i__1 = i__ + 20000;
	boddef_(name__, &i__1, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    s_copy(name__, "F_BODCOD_TEST_#", (ftnlen)200, (ftnlen)15);
    repmi_(name__, "#", &c__20151, name__, (ftnlen)200, (ftnlen)1, (ftnlen)
	    200);
    boddef_(name__, &c__20151, (ftnlen)200);
    chckxc_(&c_true, "SPICE(TOOMANYPAIRS)", ok, (ftnlen)19);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check proper handling of spacing by TEXT", (ftnlen)40);
    s_copy(buffer, "NAIF_BODY_CODE = 1019", (ftnlen)80, (ftnlen)21);
    s_copy(buffer + 80, "NAIF_BODY_NAME = 'TEST ING'", (ftnlen)80, (ftnlen)27)
	    ;
    s_copy(buffer + 160, "NAIF_BODY_CODE += 1020", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 240, "NAIF_BODY_NAME += 'TEST    ING'", (ftnlen)80, (
	    ftnlen)31);
    s_copy(buffer + 320, "NAIF_BODY_CODE += 1021", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 400, "NAIF_BODY_NAME += 'TESTING'", (ftnlen)80, (ftnlen)
	    27);
    lmpool_(buffer, &c__6, (ftnlen)80);

/*     Check 'TESTING' -> 1021 mapping. */

    bodn2c_("TESTING", &code, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1021, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check 'TEST ING' -> 1020 (masked) mapping. */

    bodn2c_("TEST ING", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1020, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check 'TEST    ING' -> 1020 mapping. */

    bodn2c_("TEST    ING", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1020, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lookup up the masked code, 1019. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1019, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Lookup the 1020 -> 'TEST    ING' mapping. */

    bodc2n_(&c__1020, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "TEST    ING", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Lookup the 1021 -> 'TESTING' mapping. */

    bodc2n_(&c__1021, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "TESTING", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)7);

/*     Clean up. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check proper handling of spacing by BODDEF", (ftnlen)42);
    boddef_("TEST ING2", &c__1019, (ftnlen)9);
    boddef_("TEST    ING2", &c__1020, (ftnlen)12);
    boddef_("TESTING2", &c__1021, (ftnlen)8);

/*     Check 'TESTING2' -> 1021 mapping. */

    bodn2c_("TESTING2", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1021, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check 'TEST ING2' -> 1020 (masked) mapping. */

    bodn2c_("TEST ING2", &code, &found, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1020, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check 'TEST    ING2' -> 1020 mapping. */

    bodn2c_("TEST    ING2", &code, &found, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1020, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lookup up the masked code, 1019. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
    bodc2n_(&c__1019, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)11);

/*     Lookup the 1020 -> 'TEST    ING2' mapping. */

    bodc2n_(&c__1020, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "TEST    ING2", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)12);

/*     Lookup the 1021 -> 'TESTING2' mapping. */

    bodc2n_(&c__1021, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "TESTING2", ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)8);

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Replace all built-in assignments with uniques", (ftnlen)45);

/*     Set all built-in codes to point to their position in the */
/*     original sequence. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1262)) * 36, &i__, (
		ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Verify that the changes worked. */

    for (i__ = 1; i__ <= 515; ++i__) {
	bodc2n_(&i__, name__, &found, (ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("NAME", name__, "=", basnam + ((i__1 = i__ - 1) < 665 && 0 <= 
		i__1 ? i__1 : s_rnge("basnam", i__1, "f_bodcod__", (ftnlen)
		1276)) * 36, ok, (ftnlen)4, (ftnlen)200, (ftnlen)1, (ftnlen)
		36);
	bodn2c_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1278)) * 36, &code, &
		found, (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CODE", &code, "=", &i__, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }

/*     Restore built-in codes. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1291)) * 36, &bascod[(
		i__2 = i__ - 1) < 665 && 0 <= i__2 ? i__2 : s_rnge("bascod", 
		i__2, "f_bodcod__", (ftnlen)1291)], (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Point all built-ins at a single code.", (ftnlen)37);

/*     Set all built-in names to point to the code 1. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1310)) * 36, &c__1, (
		ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Verify that the changes worked properly. */

    for (i__ = 1; i__ <= 515; ++i__) {
	bodn2c_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1318)) * 36, &code, &
		found, (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CODE", &code, "=", &c__1, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }
    bodc2n_(&c__1, name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", basnam + 18504, ok, (ftnlen)4, (ftnlen)200, (
	    ftnlen)1, (ftnlen)36);

/*     Restore built-in codes. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1337)) * 36, &bascod[(
		i__2 = i__ - 1) < 665 && 0 <= i__2 ? i__2 : s_rnge("bascod", 
		i__2, "f_bodcod__", (ftnlen)1337)], (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Point all built-ins at a single name.", (ftnlen)37);

/*     Set all built-in codes to point at 'NAME'. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_("NAME", &bascod[(i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : 
		s_rnge("bascod", i__1, "f_bodcod__", (ftnlen)1356)], (ftnlen)
		4);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Verify that the changes worked properly. */

    for (i__ = 1; i__ <= 514; ++i__) {
	bodc2n_(&bascod[(i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"bascod", i__1, "f_bodcod__", (ftnlen)1365)], name__, &found, 
		(ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	found = FALSE_;
	j = 515;
	while(! found && j > i__) {
	    if (bascod[(i__1 = j - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		    "bascod", i__1, "f_bodcod__", (ftnlen)1374)] == bascod[(
		    i__2 = i__ - 1) < 665 && 0 <= i__2 ? i__2 : s_rnge("basc"
		    "od", i__2, "f_bodcod__", (ftnlen)1374)]) {
		found = TRUE_;
	    } else {
		--j;
	    }
	}
	chcksc_("NAME", name__, "=", basnam + ((i__1 = j - 1) < 665 && 0 <= 
		i__1 ? i__1 : s_rnge("basnam", i__1, "f_bodcod__", (ftnlen)
		1381)) * 36, ok, (ftnlen)4, (ftnlen)200, (ftnlen)1, (ftnlen)
		36);
    }
    bodc2n_(&bascod[514], name__, &found, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "NAME", ok, (ftnlen)4, (ftnlen)200, (ftnlen)
	    1, (ftnlen)4);
    bodn2c_("NAME", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &bascod[514], &c__0, ok, (ftnlen)4, (ftnlen)1)
	    ;

/*     Restore built-in codes. */

    for (i__ = 1; i__ <= 515; ++i__) {
	boddef_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1403)) * 36, &bascod[(
		i__2 = i__ - 1) < 665 && 0 <= i__2 ? i__2 : s_rnge("bascod", 
		i__2, "f_bodcod__", (ftnlen)1403)], (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check built-in assignment integrity.", (ftnlen)36);

/*     Verify all of the codes and name pairs that exist in the */
/*     built-in NAME/CODE arrays. */

    for (i__ = 1; i__ <= 515; ++i__) {
	code = 0;
	s_copy(name__, "<UNCHANGED>", (ftnlen)200, (ftnlen)11);
	bodn2c_(basnam + ((i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"basnam", i__1, "f_bodcod__", (ftnlen)1427)) * 36, &code, &
		found, (ftnlen)36);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CODE", &code, "=", &bascod[(i__1 = i__ - 1) < 665 && 0 <= 
		i__1 ? i__1 : s_rnge("bascod", i__1, "f_bodcod__", (ftnlen)
		1432)], &c__0, ok, (ftnlen)4, (ftnlen)1);
	bodc2n_(&bascod[(i__1 = i__ - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		"bascod", i__1, "f_bodcod__", (ftnlen)1434)], name__, &found, 
		(ftnlen)200);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Locate the name that should be found by searching in front */
/*        of the index I for a match. */

	found = FALSE_;
	j = 515;
	while(! found && j > i__) {
	    if (bascod[(i__1 = j - 1) < 665 && 0 <= i__1 ? i__1 : s_rnge(
		    "bascod", i__1, "f_bodcod__", (ftnlen)1447)] == bascod[(
		    i__2 = i__ - 1) < 665 && 0 <= i__2 ? i__2 : s_rnge("basc"
		    "od", i__2, "f_bodcod__", (ftnlen)1447)]) {
		found = TRUE_;
	    } else {
		--j;
	    }
	}

/*        At this point J is either I, or J is pointing at the */
/*        index with the highest precedent assignment for BASCOD(I). */

	chcksc_("NAME", name__, "=", basnam + ((i__1 = j - 1) < 665 && 0 <= 
		i__1 ? i__1 : s_rnge("basnam", i__1, "f_bodcod__", (ftnlen)
		1458)) * 36, ok, (ftnlen)4, (ftnlen)200, (ftnlen)1, (ftnlen)
		36);
    }

/*     Clean up */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check name to ID translation by BODS2C", (ftnlen)38);
    bods2c_("JUPITER", &code, &found, (ftnlen)7);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__599, &c__0, ok, (ftnlen)4, (ftnlen)1);
    code = 777;
    bods2c_("JUP", &code, &found, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__777, &c__0, ok, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check integer to ID translation by BODS2C", (ftnlen)41);
    bods2c_("599", &code, &found, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__599, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bods2c_("1000000000", &code, &found, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b818, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_bodcod__ */

