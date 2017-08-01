/* f_zzbdtn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__1000 = 1000;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__2 = 2;
static integer c__3000 = 3000;
static integer c__3 = 3;
static integer c__399 = 399;
static integer c__4 = 4;
static integer c__3001 = 3001;
static integer c__3002 = 3002;

/* $Procedure F_ZZBDTN ( ZZBODTRN Test Family  ) */
/* Subroutine */ int f_zzbdtn__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer code;
    extern /* Subroutine */ int zzbodn2c_(char *, integer *, logical *, 
	    ftnlen), zzbodc2n_(integer *, char *, logical *, ftnlen);
    char name__[32];
    extern /* Subroutine */ int zzboddef_(char *, integer *, ftnlen), 
	    zzbodtrn_(char *, integer *, logical *, ftnlen), zzbodrst_(void), 
	    tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chcksc_(char *, char *, char *, char *, logical *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), chcksi_(char *, integer *, char *, integer *, integer *, 
	    logical *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen);
    char buffer[200*4];
    logical update;
    extern /* Subroutine */ int clpool_(void), lmpool_(char *, integer *, 
	    ftnlen), cvpool_(char *, logical *, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code in ZZBODTRN and its */
/*     entry points. */

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
/*     OK         O   logical indicated test status. */

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

/*     This routine exercises the entry points of ZZBODTRN. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 21-AUG-2002 (FST) */


/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_ZZBDTN", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODTRN - SPICE(BOGUSENTRY) exception", (ftnlen)38);
    zzbodtrn_(name__, &code, &found, (ftnlen)32);
    chckxc_(&c_true, "SPICE(BOGUSENTRY)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODRST - Coverage Test", (ftnlen)24);

/*     Install a new mapping. */

    zzboddef_("NAME", &c__1000, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that the mapping is installed. */

    zzbodn2c_("NAME", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1000, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Reset the body name-code system. */

    clpool_();
    zzbodrst_();

/*     Now verify that NAME<->1000 is not currently assigned. */

    zzbodn2c_("NAME", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    zzbodc2n_(&c__1000, "NAME", &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODTRN - Check watchers are properly set", (ftnlen)42);

/*     Make certain that the initialization block is executed */
/*     prior to attempting to check the watcher's set status. */
/*     It is difficult to verify that each initialization block */
/*     functions properly in a test family, since once INIT is */
/*     set the code will not execute again. */

    zzbodn2c_("EARTH", &code, &found, (ftnlen)5);
    s_copy(buffer, "NAIF_BODY_CODE = 3000", (ftnlen)200, (ftnlen)21);
    s_copy(buffer + 200, "NAIF_BODY_NAME = 'ZZBODTRN_TEST_BODY'", (ftnlen)200,
	     (ftnlen)37);
    lmpool_(buffer, &c__2, (ftnlen)200);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that the watchers are activated. */

    cvpool_("ZZBODTRN", &update, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("UPDATE", &update, &c_true, ok, (ftnlen)6);

/*     Clean up. */

    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODN2C - Coverage Test - UPDATE", (ftnlen)33);

/*     Cause CVPOOL to set UPDATE to .TRUE. */

    s_copy(buffer, "NAIF_BODY_CODE = 3000", (ftnlen)200, (ftnlen)21);
    s_copy(buffer + 200, "NAIF_BODY_NAME = 'ZZBODTRN_TEST_BODY_2'", (ftnlen)
	    200, (ftnlen)39);
    lmpool_(buffer, &c__2, (ftnlen)200);
    code = 0;
    found = TRUE_;

/*     Now invoke the module with an unknown name. */

    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Verify that ZZBODTRN_TEST_BODY_2 is available now. EXTKER */
/*     success path. */

    lmpool_(buffer, &c__2, (ftnlen)200);
    zzbodn2c_("ZZBODTRN_TEST_BODY_2", &code, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__3000, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check a built-in assignment, EXTKER failure path.  Make LJUST */
/*     UCASE, and COMPRSS perform non-trivial operations. */

    lmpool_(buffer, &c__2, (ftnlen)200);
    zzbodn2c_("    earth    barycenter", &code, &found, (ftnlen)23);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__3, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Set UPDATE and force EXTKER to be .FALSE., look for unknown name. */

    clpool_();
    code = 0;
    found = TRUE_;
    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check to see that ZZBODTRN_TEST_BODY_2 is no longer available. */

    clpool_();
    code = 0;
    found = TRUE_;
    zzbodn2c_("ZZBODTRN_TEST_BODY_2", &code, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lastly look up a built-in name's code. */

    clpool_();
    zzbodn2c_("EARTH", &code, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODN2C - Coverage Test - no UPDATE", (ftnlen)36);

/*     Force EXTKER to be set. */

    s_copy(buffer, "NAIF_BODY_CODE = 3000", (ftnlen)200, (ftnlen)21);
    s_copy(buffer + 200, "NAIF_BODY_NAME = 'ZZBODTRN_TEST_BODY_3'", (ftnlen)
	    200, (ftnlen)39);
    lmpool_(buffer, &c__2, (ftnlen)200);

/*     Make sure no watchers set UPDATE. */

    code = 0;
    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Now invoke ZZBODN2C with the name defined in the kernel pool. */

    zzbodn2c_("ZZBODTRN_TEST_BODY_3", &code, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__3000, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Now invoke ZZBODN2C with a built-in name. */

    zzbodn2c_("EARTH", &code, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lastly invoke it with an unknown name. */

    code = 0;
    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clear the pool and remove EXTKER's .TRUE. status. */

    clpool_();
    code = 0;
    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Now check the previously defined name in the kernel pool. */

    code = 0;
    zzbodn2c_("ZZBODTRN_TEST_BODY_3", &code, &found, (ftnlen)20);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Check a built-in code. */

    zzbodn2c_("EARTH", &code, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lastly invoke it with an undefined name. */

    code = 0;
    zzbodn2c_("<UNDEFINED>", &code, &found, (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODC2N - Coverage Test - UPDATE", (ftnlen)33);

/*     Cause CVPOOL to set UPDATE to .TRUE. */

    s_copy(buffer, "NAIF_BODY_CODE = 3000", (ftnlen)200, (ftnlen)21);
    s_copy(buffer + 200, "NAIF_BODY_NAME = 'ZZBODTRN_TEST_BODY_4'", (ftnlen)
	    200, (ftnlen)39);
    s_copy(buffer + 400, "NAIF_BODY_CODE += 3002", (ftnlen)200, (ftnlen)22);
    s_copy(buffer + 600, "NAIF_BODY_NAME += 'EARTH'", (ftnlen)200, (ftnlen)25)
	    ;
    lmpool_(buffer, &c__4, (ftnlen)200);
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    found = TRUE_;

/*     Now invoke the module with an unknown code. */

    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Verify that 3001 is available now. EXTKER success path. */

    lmpool_(buffer, &c__4, (ftnlen)200);
    zzbodc2n_(&c__3000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "ZZBODTRN_TEST_BODY_4", ok, (ftnlen)4, (
	    ftnlen)32, (ftnlen)1, (ftnlen)20);

/*     Check a built-in assignment, EXTKER failure path no "kernel */
/*     pool" masking. */

    lmpool_(buffer, &c__4, (ftnlen)200);
    zzbodc2n_(&c__3, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH BARYCENTER", ok, (ftnlen)4, (ftnlen)
	    32, (ftnlen)1, (ftnlen)16);

/*     Check a built-in assignment, EXTKER failure path with "kernel */
/*     pool" masking. */

    lmpool_(buffer, &c__4, (ftnlen)200);
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__399, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Set UPDATE and force EXTKER to be .FALSE., look for unknown code. */

    clpool_();
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    found = TRUE_;
    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Check to see that 3000 is no longer available. */

    clpool_();
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    found = TRUE_;
    zzbodc2n_(&c__3000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Lastly look up a built-in code's name. */

    clpool_();
    zzbodc2n_(&c__399, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
	    1, (ftnlen)5);
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODC2N - Coverage Test - no UPDATE", (ftnlen)36);

/*     Force EXTKER to be set. */

    s_copy(buffer, "NAIF_BODY_CODE = 3000", (ftnlen)200, (ftnlen)21);
    s_copy(buffer + 200, "NAIF_BODY_NAME = 'ZZBODTRN_TEST_BODY_5'", (ftnlen)
	    200, (ftnlen)39);
    s_copy(buffer + 400, "NAIF_BODY_CODE += 3002", (ftnlen)200, (ftnlen)22);
    s_copy(buffer + 600, "NAIF_BODY_NAME += 'EARTH'", (ftnlen)200, (ftnlen)25)
	    ;
    lmpool_(buffer, &c__4, (ftnlen)200);

/*     Make sure no watchers set UPDATE. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Now invoke ZZBODN2C with a code defined in the kernel pool. */

    zzbodc2n_(&c__3000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "ZZBODTRN_TEST_BODY_5", ok, (ftnlen)4, (
	    ftnlen)32, (ftnlen)1, (ftnlen)20);

/*     Check a built-in code, EXTKER is .TRUE., with no "kernel pool" */
/*     masking. */

    zzbodc2n_(&c__3, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH BARYCENTER", ok, (ftnlen)4, (ftnlen)
	    32, (ftnlen)1, (ftnlen)16);

/*     Check a built-in code, EXTER is .TRUE., with "kernel pool" */
/*     masking. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__399, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Check for an unknown code. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Now clear the pool to remove EXTKER's .TRUE. status. */

    clpool_();
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);

/*     Look up an unknown code, to clear UPDATE's status. */

    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Now check the previously defined codes in the kernel pool. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__3000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);
    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__3002, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);

/*     Now look up the built-in codes. */

    zzbodc2n_(&c__399, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
	    1, (ftnlen)5);
    zzbodc2n_(&c__3, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EARTH BARYCENTER", ok, (ftnlen)4, (ftnlen)
	    32, (ftnlen)1, (ftnlen)16);

/*     Lastly invoke it with an unknown code. */

    s_copy(name__, "<UNCHANGED>", (ftnlen)32, (ftnlen)11);
    zzbodc2n_(&c__3001, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "<UNCHANGED>", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)11);
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODDEF - Exception SPICE(BLANKNAMEASSIGNED)", (ftnlen)45);
    zzboddef_(" ", &c__1000, (ftnlen)1);
    chckxc_(&c_true, "SPICE(BLANKNAMEASSIGNED)", ok, (ftnlen)24);

/*     Check that it did nothing to the name-code mapping */
/*     system. */

    zzbodn2c_(" ", &code, &found, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    zzbodc2n_(&c__1000, name__, &found, (ftnlen)32);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODDEF - Coverage Tests - Name Replace Case", (ftnlen)45);

/*     Replace the name for EARTH with the same code.  This forces a */
/*     simple replace, rather than a sort/update. */

    zzboddef_("eArTh", &c__399, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if it worked. */

    zzbodc2n_(&c__399, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "eArTh", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
	    1, (ftnlen)5);
    zzbodn2c_("eArTh", &code, &found, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__399, &c__0, ok, (ftnlen)4, (ftnlen)1);
    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODDEF - Coverage Tests - Name Replace Sort", (ftnlen)45);

/*     Replace the name for EARTH with a new code.  This forces a */
/*     compression and append operation. */

    zzboddef_("EaRtH", &c__1000, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if it worked. */

    zzbodc2n_(&c__1000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "EaRtH", ok, (ftnlen)4, (ftnlen)32, (ftnlen)
	    1, (ftnlen)5);
    zzbodn2c_("EaRtH", &code, ok, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1000, &c__0, ok, (ftnlen)4, (ftnlen)1);
    clpool_();
    zzbodrst_();

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZBODDEF - Coverage Tests - Append New", (ftnlen)38);

/*     Replace the name for EARTH with a new code.  This forces a */
/*     compression and append operation. */

    zzboddef_("SPUDSpam", &c__1000, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if it worked. */

    zzbodc2n_(&c__1000, name__, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("NAME", name__, "=", "SPUDSpam", ok, (ftnlen)4, (ftnlen)32, (
	    ftnlen)1, (ftnlen)8);
    zzbodn2c_("spudspam", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__1000, &c__0, ok, (ftnlen)4, (ftnlen)1);
    clpool_();
    zzbodrst_();

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzbdtn__ */

