/* f_zzbdtrn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__22 = 22;
static integer c__3 = 3;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__24 = 24;
static integer c__23 = 23;
static integer c__4 = 4;
static integer c_b66 = -170101;
static integer c_b75 = -170102;
static integer c__6 = 6;
static integer c_b98 = -10009;
static integer c_b141 = -30001;
static integer c__2 = 2;
static integer c__20000 = 20000;
static integer c_b257 = -20000;
static integer c_b295 = -30000;

/* $Procedure F_ZZBDTRN (Family of tests for ZZBODTRN) */
/* Subroutine */ int f_zzbdtrn__(logical *ok)
{
    /* System generated locals */
    char ch__1[10];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer code;
    char text[80*6];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen), bodn2c_(char *, 
	    integer *, logical *, ftnlen), bodc2n_(integer *, char *, logical 
	    *, ftnlen), t_success__(logical *), boddef_(char *, integer *, 
	    ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen), kilfil_(char *, ftnlen),
	     clpool_(void), ldpool_(char *, ftnlen), lmpool_(char *, integer *
	    , ftnlen), tsttxt_(char *, char *, integer *, logical *, logical *
	    , ftnlen, ftnlen);
    char get[36];

/* $ Abstract */

/*     This family of tests exercises the ZZBODTRN interfaces */
/*     BODN2C, BODC2N and BODDEF. */

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

/*     Version 3.0.0  22-APR-2003 (EDW) */

/*        Testing of the default SPICE body list removed. */
/*        Those tests now exist in F_ZZBDTRN1. */

/*        This test family now examines precedence with regards */
/*        to masking. */

/*     Version 2.4.0  21-FEB-2003 (BVS) */

/*        Changed MER-A back to MER-1. Added test for MER-2. */

/*     Version 2.3.0  04-DEC-2002 (EDW) */

/*        Added new assignments from the default collection */
/*        to the test arrays ID and NAME: */

/*       -226     ROSETTA */
/*        517     CALLIRRHOE */
/*        518     THEMISTO */
/*        519     MAGACLITE */
/*        520     TAYGETE */
/*        521     CHALDENE */
/*        522     HARPALYKE */
/*        523     KALYKE */
/*        524     IOCASTE */
/*        525     ERINOME */
/*        526     ISONOE */
/*        527     PRAXIDIKE */

/*        These assignments also required a reset of the */
/*        NPAIR parameter to 308. */

/*     Version 2.2.1  14-AUG-2002 (EDW) */

/*        Altered the string "MER-1" to "MER-A" to reflect the */
/*        name change in zzbodtrn.f */

/*        Removed BADMEMBERREASSIGN tests as such errors no longer */
/*        exist. Added first masking tests. */

/*     Version 2.2.0  17-OCT-2001 (EDW) */

/*        Added test for BODDEF, BODC2N string in equals */
/*        string out functionality. Reassign failure tests */
/*        modified to BADMEMBERREASSIGN. */

/*        Additional test to ensure functionality of BODTRN routines */
/*        unaffected after a error condition. */

/*        Removed redundant name/body pairs in test list. */

/* -    Version 2.1.0  24-APR-2001 (EDW) */

/*        Added test to check a name listed in the */
/*        NAIF_BODY_NAME kernel variable is not reassigned */
/*        to a new ID code. Technically, the test operates on */
/*        both the kernel variable and the default name-ID */
/*        list. */

/*        Added test to insure case insensitivity between a */
/*        name to code lookup request and a name in the kernel pool. */

/* -    Version 2.0.0  14 OCT 1999 (WLT) */

/*        Removed a call to BODN2C that passed a number instead */
/*        of a string. */
/* -& */

/*     Test Utility Functions */

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


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_ZZBDTRN", (ftnlen)9);

/*     CASE 1 */

    tcase_("Checking to make sure FOUND comes back FALSE for a bogus name. ", 
	    (ftnlen)63);
    bodn2c_("SPUD", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     CASE 2 */

    tcase_("Checking to make sure that FOUND comes back FALSE for a bogus ID"
	    " code.", (ftnlen)70);
    bodc2n_(&c__22, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     CASE 3 */

    tcase_("Checking to make sure we can load a kernel and add new ID/NAME p"
	    "airs. ", (ftnlen)70);
    begdat_(ch__1, (ftnlen)10);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)10);
    s_copy(text + 80, " NAIF_BODY_CODE  = ( 22, 23, 24, 25 )", (ftnlen)80, (
	    ftnlen)37);
    s_copy(text + 160, " NAIF_BODY_NAME  = ( 'SPUD', 'MOON', 'CURLEY', 'SHEM"
	    "P' )", (ftnlen)80, (ftnlen)56);
    tsttxt_("sample.nam", text, &c__3, &c_true, &c_false, (ftnlen)10, (ftnlen)
	    80);
    bodn2c_("SPUD", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__22, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c__24, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "CURLEY", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1, (
	    ftnlen)6);

/*     CASE 4 */

/*     Test to check we can override a name-ID assignment from the */
/*     default list with an external kernel assignment. */

    tcase_("Checking to make sure we can override an existing NAME/ID pair. ",
	     (ftnlen)64);
    bodn2c_("MOON", &code, &found, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c__23, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 5 */

/*     Test on external name-ID assignments. */

    tcase_("Check to ensure case insensitivity in N2C.", (ftnlen)42);
    begdat_(ch__1, (ftnlen)10);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)10);
    s_copy(text + 80, "NAIF_BODY_CODE =  ( -170101, -170102 )", (ftnlen)80, (
	    ftnlen)38);
    s_copy(text + 160, "NAIF_BODY_NAME =  ( '1701-A', '   1701-b' )", (ftnlen)
	    80, (ftnlen)43);
    s_copy(text + 240, " ", (ftnlen)80, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__4, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)80);
    ldpool_("testdata.ker", (ftnlen)12);
    bodn2c_("1701-a", &code, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b66, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodn2c_(" 1701-B ", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b75, &c__0, ok, (ftnlen)4, (ftnlen)1);
    bodc2n_(&c_b75, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "   1701-b", ok, (ftnlen)3, (ftnlen)36, (ftnlen)
	    1, (ftnlen)9);

/*     CASE 6 */

    tcase_("Checking that we cannot override an existing kernel based NAME/I"
	    "D pair.", (ftnlen)71);
    begdat_(ch__1, (ftnlen)10);
    s_copy(text, ch__1, (ftnlen)80, (ftnlen)10);
    s_copy(text + 80, "NAIF_BODY_CODE =  ( -170101, -170102 )", (ftnlen)80, (
	    ftnlen)38);
    s_copy(text + 160, "NAIF_BODY_NAME =  ( '1701-A', '1701-b' )", (ftnlen)80,
	     (ftnlen)40);
    s_copy(text + 240, "NAIF_BODY_CODE += ( -170105 )", (ftnlen)80, (ftnlen)
	    29);
    s_copy(text + 320, "NAIF_BODY_NAME += ( '1701-a' )", (ftnlen)80, (ftnlen)
	    30);
    s_copy(text + 400, " ", (ftnlen)80, (ftnlen)1);
    kilfil_("testdata.ker", (ftnlen)12);
    tsttxt_("testdata.ker", text, &c__6, &c_false, &c_true, (ftnlen)12, (
	    ftnlen)80);

/*     CASE 7 */

/*     Test of BODDEF. */

    tcase_("Check BODDEF functionality.", (ftnlen)27);
    boddef_("Woof", &c_b98, (ftnlen)4);
    bodc2n_(&c_b98, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "Woof", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1, (
	    ftnlen)4);

/*     Assign a member of the equivalence class to the ID code. */
/*     As last on the stack, a C2N lookup should return the */
/*     same member string. */

    boddef_("woof", &c_b98, (ftnlen)4);
    bodc2n_(&c_b98, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "woof", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1, (
	    ftnlen)4);

/*     Case and space insensitiviy */

    bodn2c_(" WOOF ", &code, &found, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b98, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Functionality unaffected by the previous test's error state? */
/*     Try a BODDEF. */

    boddef_(" WOof ", &c_b98, (ftnlen)6);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now perform a post error case and space insensitiviy test. */

    bodn2c_("   wOOf ", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b98, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 8 */

/*     Test the mapping precedence behavior. */

/*     Assign a mapping via BODDEF. Note: 'Tis very important to call */
/*     CLPOOL an clear the kernel pool before this set of tests. The */
/*     previous tests left the pool in an error signalling state. */

    clpool_();
    tcase_("Check precedence functionality. BODDEF 1", (ftnlen)40);
    boddef_("TestBODEF1", &c_b141, (ftnlen)10);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b141, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestBODEF1", ok, (ftnlen)3, (ftnlen)36, (ftnlen)
	    1, (ftnlen)10);
    bodn2c_("TestBODEF1", &code, &found, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b141, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 9 */

/*     Load a new mapping to the kernel pool using the previous ID value. */
/*     This mapping should override BODDEF. */

    tcase_("Check precedence functionality. TestKer 1", (ftnlen)41);
    s_copy(text, "      NAIF_BODY_NAME += 'TestKer1'", (ftnlen)80, (ftnlen)34)
	    ;
    s_copy(text + 80, "      NAIF_BODY_CODE += -30001", (ftnlen)80, (ftnlen)
	    30);
    lmpool_(text, &c__2, (ftnlen)80);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b141, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestKer1", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1,
	     (ftnlen)8);
    bodn2c_("TestKer1", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b141, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 10 */

/*     Assign another name to the previous ID code. This mapping */
/*     should override all others. */

    tcase_("Check precedence functionality. TestKer 2", (ftnlen)41);
    s_copy(text, "      NAIF_BODY_NAME += 'TestKer2'", (ftnlen)80, (ftnlen)34)
	    ;
    s_copy(text + 80, "      NAIF_BODY_CODE += -30001", (ftnlen)80, (ftnlen)
	    30);
    lmpool_(text, &c__2, (ftnlen)80);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b141, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestKer2", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1,
	     (ftnlen)8);
    bodn2c_("TestKer2", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b141, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 11 */

/*     Clear the kernel pool, test for BODDEF's first mapping for the */
/*     test ID. */

    tcase_("Check precedence functionality. BODDEF 1 retest.", (ftnlen)48);
    clpool_();
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b141, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestBODEF1", ok, (ftnlen)3, (ftnlen)36, (ftnlen)
	    1, (ftnlen)10);
    bodn2c_("TestBODEF1", &code, &found, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b141, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 12 */

/*     Assign another mapping via BODDEF to override the first */
/*     BODDEF mapping. */

    tcase_("Check precedence functionality. BODDEF 2.", (ftnlen)41);
    boddef_("TestBODEF2", &c_b141, (ftnlen)10);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b141, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestBODEF2", ok, (ftnlen)3, (ftnlen)36, (ftnlen)
	    1, (ftnlen)10);
    bodn2c_("TestBODEF2", &code, &found, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b141, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     CASE 13 */

    tcase_("Check precedence functionality. Masking.", (ftnlen)40);
    clpool_();

/*     Assign a mapping via BODDEF, then remap the name to a new */
/*     number. */

    boddef_("TestName", &c__20000, (ftnlen)8);
    s_copy(text, "      NAIF_BODY_NAME = 'TestName'", (ftnlen)80, (ftnlen)33);
    s_copy(text + 80, "      NAIF_BODY_CODE = -20000", (ftnlen)80, (ftnlen)29)
	    ;
    lmpool_(text, &c__2, (ftnlen)80);
    bodn2c_("TestName", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b257, &c__0, ok, (ftnlen)4, (ftnlen)1);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b257, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestName", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1,
	     (ftnlen)8);

/*     The kernel pool assignment should mask the BODDEF assignment */
/*     so a request for the name of body 20000 ought to fail. */

    tcase_("Check precedence functionality. De-masking.", (ftnlen)43);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c__20000, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Destroy the kernel pool entries. The BODDEF assignment should now */
/*     respond; a request for body 20000 should succeed. */

    clpool_();
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c__20000, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestName", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1,
	     (ftnlen)8);

/*     CASE 14 */

/*     Set the kernel assignment using a different body ID than */
/*     previous tests. This should remask the BODDEF assignment. */

    tcase_("Check precedence functionality. Re-masking.", (ftnlen)43);
    s_copy(text, "      NAIF_BODY_NAME = 'TestName'", (ftnlen)80, (ftnlen)33);
    s_copy(text + 80, "      NAIF_BODY_CODE = -30000", (ftnlen)80, (ftnlen)29)
	    ;
    lmpool_(text, &c__2, (ftnlen)80);
    bodn2c_("TestName", &code, &found, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("CODE", &code, "=", &c_b295, &c__0, ok, (ftnlen)4, (ftnlen)1);
    s_copy(get, " ", (ftnlen)36, (ftnlen)1);
    bodc2n_(&c_b295, get, &found, (ftnlen)36);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksc_("GET", get, "=", "TestName", ok, (ftnlen)3, (ftnlen)36, (ftnlen)1,
	     (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_zzbdtrn__ */

