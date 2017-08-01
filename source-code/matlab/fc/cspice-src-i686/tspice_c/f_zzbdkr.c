/* f_zzbdkr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__2 = 2;
static integer c__12001 = 12001;
static integer c__3 = 3;
static integer c__18 = 18;
static integer c__5 = 5;
static integer c__0 = 0;
static integer c__16 = 16;
static integer c__8 = 8;

/* $Procedure F_ZZBDKR ( Body Kernel Pool Initialization Test Family ) */
/* Subroutine */ int f_zzbdkr__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzbodker_(char *, char *, integer *, integer *
	    , integer *, integer *, integer *, logical *, ftnlen, ftnlen);
    integer i__, codes[2000];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char names[36*2000];
    integer nocds;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer nvals;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckac_(char *, char *, char *, char *, integer *, logical *, 
	    ftnlen, ftnlen, ftnlen, ftnlen), chckai_(char *, integer *, char *
	    , integer *, integer *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen);
    integer cmpcod[2000], cmpocd[2000];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    char buffer[80*20], cmpnam[36*2000];
    integer ordcod[2000];
    extern /* Subroutine */ int orderc_(char *, integer *, integer *, ftnlen),
	     orderi_(integer *, integer *, integer *), clpool_(void);
    integer cmponm[2000];
    char nornam[36*2000], cmpnor[36*2000];
    integer ordnom[2000];
    logical extker;
    extern /* Subroutine */ int lmpool_(char *, integer *, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code in the kernel pool */
/*     name-code mapping processing software. */

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

/*     This routine exercises the conformance of the kernel pool name */
/*     to code mapping initialization with intended/designed behavior. */

/*     We need not perform any stress tests here, as F_BODCOD attempts */
/*     to provide these sorts of tests from the higher level interfaces. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 26-AUG-2002 (FST) */


/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     Open the test family. */

    topen_("F_ZZBDKR", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(MISSINGKPV) exception", (ftnlen)27);

/*     First, check behavior if neither of the two kernel pool */
/*     variables are defined. */

    clpool_();
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);

/*     Now load up NAIF_BODY_CODE and call ZZBODKER. */

    s_copy(buffer, "NAIF_BODY_CODE = 1000", (ftnlen)80, (ftnlen)21);
    lmpool_(buffer, &c__1, (ftnlen)80);
    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(MISSINGKPV)", ok, (ftnlen)17);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);

/*     Now try NAIF_BODY_NAME and call ZZBODKER. */

    clpool_();
    s_copy(buffer, "NAIF_BODY_NAME = 'TEST_BODY_ZZBODKER'", (ftnlen)80, (
	    ftnlen)37);
    lmpool_(buffer, &c__1, (ftnlen)80);
    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(MISSINGKPV)", ok, (ftnlen)17);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);

/*     Clean up */

    clpool_();

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(KERVARTOOBIG) exception", (ftnlen)29);

/*     Build up the kernel pool variables to exceed the available */
/*     space.  Start by overflowing NAIF_BODY_NAME. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'NAME_#'", (ftnlen)80, (ftnlen)
		26);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = i__ + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }
    s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
    repmi_(buffer, "#", &c__12001, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    lmpool_(buffer, &c__1, (ftnlen)80);

/*     Invoke ZZBODKER and check for the exception. */

    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(KERVARTOOBIG)", ok, (ftnlen)19);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);
    clpool_();

/*     Build up the kernel pool variables to exceed the available */
/*     space.  Overflow NAIF_BODY_CODE. */

    for (i__ = 1; i__ <= 2000; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'NAME_#'", (ftnlen)80, (ftnlen)
		26);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = i__ + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }
    s_copy(buffer, "NAIF_BODY_NAME += 'NAME_#'", (ftnlen)80, (ftnlen)26);
    repmi_(buffer, "#", &c__12001, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
    lmpool_(buffer, &c__1, (ftnlen)80);

/*     Invoke ZZBODKER and check for the exception. */

    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(KERVARTOOBIG)", ok, (ftnlen)19);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);
    clpool_();

/*     Build up the kernel pool variables to exceed the available */
/*     space.  Overflow both keywords. */

    for (i__ = 1; i__ <= 2001; ++i__) {
	s_copy(buffer, "NAIF_BODY_CODE += #", (ftnlen)80, (ftnlen)19);
	s_copy(buffer + 80, "NAIF_BODY_NAME += 'NAME_#'", (ftnlen)80, (ftnlen)
		26);
	i__1 = i__ + 10000;
	repmi_(buffer, "#", &i__1, buffer, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	i__1 = i__ + 10000;
	repmi_(buffer + 80, "#", &i__1, buffer + 80, (ftnlen)80, (ftnlen)1, (
		ftnlen)80);
	lmpool_(buffer, &c__2, (ftnlen)80);
    }

/*     Invoke ZZBODKER and check for the exception. */

    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(KERVARTOOBIG)", ok, (ftnlen)19);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);
    clpool_();

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(BADDIMENSIONS) exception", (ftnlen)30);

/*     To hit this, we have to have mismatched kernel pool */
/*     arrays with cardinality less than NROOM. */

    s_copy(buffer, "NAIF_BODY_CODE += 10001", (ftnlen)80, (ftnlen)23);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'TEST_BODY_ZZBODKER'", (ftnlen)80, 
	    (ftnlen)38);
    s_copy(buffer + 160, "NAIF_BODY_CODE += 10002", (ftnlen)80, (ftnlen)23);
    lmpool_(buffer, &c__3, (ftnlen)80);

/*     Invoke ZZBODKER and check for the exception. */

    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(BADDIMENSIONS)", ok, (ftnlen)20);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);
    clpool_();

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(BLANKNAMEASSIGNED) exception", (ftnlen)34);

/*     To hit this exception, we need only assign a blank name */
/*     to a code. */

    s_copy(buffer, "NAIF_BODY_CODE += 1000", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += ' '", (ftnlen)80, (ftnlen)21);
    lmpool_(buffer, &c__2, (ftnlen)80);

/*     Invoke ZZBODKER and check for the exception. */

    extker = TRUE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);
    chckxc_(&c_true, "SPICE(BLANKNAMEASSIGNED)", ok, (ftnlen)24);
    chcksl_("EXTKER", &extker, &c_false, ok, (ftnlen)6);
    clpool_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check duplicate removal code", (ftnlen)28);

/*     Mix duplicates and non-duplicates. */

    s_copy(buffer, "NAIF_BODY_CODE += 1000", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'DUPLICATE'", (ftnlen)80, (ftnlen)
	    29);
    s_copy(buffer + 160, "NAIF_BODY_CODE += 1001", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 240, "NAIF_BODY_NAME += 'dUpLiCaTe'", (ftnlen)80, (ftnlen)
	    29);
    s_copy(buffer + 320, "NAIF_BODY_CODE += 1002", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 400, "NAIF_BODY_NAME += 'Not Duplicate 1'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(buffer + 480, "NAIF_BODY_CODE += 1003", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 560, "NAIF_BODY_NAME += 'Duplicate'", (ftnlen)80, (ftnlen)
	    29);
    s_copy(buffer + 640, "NAIF_BODY_CODE += 1004", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 720, "NAIF_BODY_NAME += 'DuPliCaTe'", (ftnlen)80, (ftnlen)
	    29);
    s_copy(buffer + 800, "NAIF_BODY_CODE += 1005", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 880, "NAIF_BODY_NAME += 'Duplicate with spaces'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(buffer + 960, "NAIF_BODY_CODE += 1006", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 1040, "NAIF_BODY_NAME += 'Not Duplicate 2'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(buffer + 1120, "NAIF_BODY_CODE += 1007", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 1200, "NAIF_BODY_NAME += 'Duplicate    with    spaces'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(buffer + 1280, "NAIF_BODY_CODE += 1008", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 1360, "NAIF_BODY_NAME += 'Not Duplicate 3'", (ftnlen)80, (
	    ftnlen)35);
    lmpool_(buffer, &c__18, (ftnlen)80);

/*     Build the comparison arrays. */

    s_copy(cmpnam, "Not Duplicate 1", (ftnlen)36, (ftnlen)15);
    s_copy(cmpnor, "NOT DUPLICATE 1", (ftnlen)36, (ftnlen)15);
    cmpcod[0] = 1002;
    s_copy(cmpnam + 36, "DuPliCaTe", (ftnlen)36, (ftnlen)9);
    s_copy(cmpnor + 36, "DUPLICATE", (ftnlen)36, (ftnlen)9);
    cmpcod[1] = 1004;
    s_copy(cmpnam + 72, "Not Duplicate 2", (ftnlen)36, (ftnlen)15);
    s_copy(cmpnor + 72, "NOT DUPLICATE 2", (ftnlen)36, (ftnlen)15);
    cmpcod[2] = 1006;
    s_copy(cmpnam + 108, "Duplicate    with    spaces", (ftnlen)36, (ftnlen)
	    27);
    s_copy(cmpnor + 108, "DUPLICATE WITH SPACES", (ftnlen)36, (ftnlen)21);
    cmpcod[3] = 1007;
    s_copy(cmpnam + 144, "Not Duplicate 3", (ftnlen)36, (ftnlen)15);
    s_copy(cmpnor + 144, "NOT DUPLICATE 3", (ftnlen)36, (ftnlen)15);
    cmpcod[4] = 1008;

/*     Build the order vectors. */

    orderc_(cmpnor, &c__5, cmponm, (ftnlen)36);
    orderi_(cmpcod, &c__5, cmpocd);

/*     Call ZZBODKER and see what drops out. */

    extker = FALSE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);

/*     Check results. */

    chcksl_("EXTKER", &extker, &c_true, ok, (ftnlen)6);
    chcksi_("NVALS", &nvals, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NOCDS", &nocds, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckac_("NAMES", names, "=", cmpnam, &nvals, ok, (ftnlen)5, (ftnlen)36, (
	    ftnlen)1, (ftnlen)36);
    chckac_("NORNAM", nornam, "=", cmpnor, &nvals, ok, (ftnlen)6, (ftnlen)36, 
	    (ftnlen)1, (ftnlen)36);
    chckai_("CODES", codes, "=", cmpcod, &nvals, ok, (ftnlen)5, (ftnlen)1);
    chckai_("ORDNOM", ordnom, "=", cmponm, &nvals, ok, (ftnlen)6, (ftnlen)1);
    chckai_("ORDCOD", ordcod, "=", cmpocd, &nocds, ok, (ftnlen)6, (ftnlen)1);
    clpool_();

/* --- Case: ------------------------------------------------------ */

    tcase_("Check alias prioritization (ZZBODINI)", (ftnlen)37);

/*     Build a list of name-code mappings that contains */
/*     aliases. */

    s_copy(buffer, "NAIF_BODY_CODE += 1000", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 80, "NAIF_BODY_NAME += 'ALIAS 1'", (ftnlen)80, (ftnlen)27)
	    ;
    s_copy(buffer + 160, "NAIF_BODY_CODE += 1000", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 240, "NAIF_BODY_NAME += 'ALIAS 2'", (ftnlen)80, (ftnlen)
	    27);
    s_copy(buffer + 320, "NAIF_BODY_CODE += 1001", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 400, "NAIF_BODY_NAME += 'NOT AN ALIAS'", (ftnlen)80, (
	    ftnlen)32);
    s_copy(buffer + 480, "NAIF_BODY_CODE += 1000", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 560, "NAIF_BODY_NAME += 'ALIAS 3'", (ftnlen)80, (ftnlen)
	    27);
    s_copy(buffer + 640, "NAIF_BODY_CODE += 1002", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 720, "NAIF_BODY_NAME += 'NOT AN ALIAS 2'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(buffer + 800, "NAIF_BODY_CODE += 1003", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 880, "NAIF_BODY_NAME += 'ALIAS A'", (ftnlen)80, (ftnlen)
	    27);
    s_copy(buffer + 960, "NAIF_BODY_CODE += 1004", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 1040, "NAIF_BODY_NAME += 'NOT AN ALIAS 3'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(buffer + 1120, "NAIF_BODY_CODE += 1003", (ftnlen)80, (ftnlen)22);
    s_copy(buffer + 1200, "NAIF_BODY_NAME += 'ALIAS B'", (ftnlen)80, (ftnlen)
	    27);
    lmpool_(buffer, &c__16, (ftnlen)80);

/*     Build the comparison arrays. */

    s_copy(cmpnam, "ALIAS 1", (ftnlen)36, (ftnlen)7);
    s_copy(cmpnor, "ALIAS 1", (ftnlen)36, (ftnlen)7);
    cmpcod[0] = 1000;
    s_copy(cmpnam + 36, "ALIAS 2", (ftnlen)36, (ftnlen)7);
    s_copy(cmpnor + 36, "ALIAS 2", (ftnlen)36, (ftnlen)7);
    cmpcod[1] = 1000;
    s_copy(cmpnam + 72, "NOT AN ALIAS", (ftnlen)36, (ftnlen)12);
    s_copy(cmpnor + 72, "NOT AN ALIAS", (ftnlen)36, (ftnlen)12);
    cmpcod[2] = 1001;
    s_copy(cmpnam + 108, "ALIAS 3", (ftnlen)36, (ftnlen)7);
    s_copy(cmpnor + 108, "ALIAS 3", (ftnlen)36, (ftnlen)7);
    cmpcod[3] = 1000;
    s_copy(cmpnam + 144, "NOT AN ALIAS 2", (ftnlen)36, (ftnlen)14);
    s_copy(cmpnor + 144, "NOT AN ALIAS 2", (ftnlen)36, (ftnlen)14);
    cmpcod[4] = 1002;
    s_copy(cmpnam + 180, "ALIAS A", (ftnlen)36, (ftnlen)7);
    s_copy(cmpnor + 180, "ALIAS A", (ftnlen)36, (ftnlen)7);
    cmpcod[5] = 1003;
    s_copy(cmpnam + 216, "NOT AN ALIAS 3", (ftnlen)36, (ftnlen)14);
    s_copy(cmpnor + 216, "NOT AN ALIAS 3", (ftnlen)36, (ftnlen)14);
    cmpcod[6] = 1004;
    s_copy(cmpnam + 252, "ALIAS B", (ftnlen)36, (ftnlen)7);
    s_copy(cmpnor + 252, "ALIAS B", (ftnlen)36, (ftnlen)7);
    cmpcod[7] = 1003;

/*     Build the CMPNOM order vector. */

    orderc_(cmpnor, &c__8, cmponm, (ftnlen)36);

/*     Construct the CMPCOD "modified" order vector by hand. */

    cmpocd[0] = 4;
    cmpocd[1] = 3;
    cmpocd[2] = 5;
    cmpocd[3] = 8;
    cmpocd[4] = 7;

/*     Call ZZBODKER and see what drops out. */

    extker = FALSE_;
    zzbodker_(names, nornam, codes, &nvals, ordnom, ordcod, &nocds, &extker, (
	    ftnlen)36, (ftnlen)36);

/*     Check results */

    chcksl_("EXTKER", &extker, &c_true, ok, (ftnlen)6);
    chcksi_("NVALS", &nvals, "=", &c__8, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NOCDS", &nocds, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckac_("NAMES", names, "=", cmpnam, &nvals, ok, (ftnlen)5, (ftnlen)36, (
	    ftnlen)1, (ftnlen)36);
    chckac_("NORNAM", nornam, "=", cmpnor, &nvals, ok, (ftnlen)6, (ftnlen)36, 
	    (ftnlen)1, (ftnlen)36);
    chckai_("CODES", codes, "=", cmpcod, &nvals, ok, (ftnlen)5, (ftnlen)1);
    chckai_("ORDNOM", ordnom, "=", cmponm, &nvals, ok, (ftnlen)6, (ftnlen)1);
    chckai_("ORDCOD", ordcod, "=", cmpocd, &nocds, ok, (ftnlen)6, (ftnlen)1);
    clpool_();

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzbdkr__ */

