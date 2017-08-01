/* f_ckfrot.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_n9998 = -9998;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c_n9999 = -9999;
static integer c__0 = 0;
static integer c__9 = 9;
static doublereal c_b45 = 1e-14;
static integer c_b51 = -10000;
static integer c_b69 = -10001;

/* $Procedure      F_CKFROT ( Family Test of  CKFROT ) */
/* Subroutine */ int f_ckfrot__(logical *ok)
{
    integer frame;
    extern /* Subroutine */ int tcase_(char *, ftnlen), cklpf_(char *, 
	    integer *, ftnlen), ckupf_(integer *);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    doublereal xform[9]	/* was [3][3] */;
    extern /* Subroutine */ int xpose_(doublereal *, doublereal *), 
	    t_success__(logical *);
    doublereal xform2[9]	/* was [3][3] */;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal av[3], et;
    integer handle, eframe;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), namfrm_(char *, integer *, 
	    ftnlen), ckfrot_(integer *, doublereal *, doublereal *, integer *,
	     logical *), clpool_(void), tparse_(char *, doublereal *, char *, 
	    ftnlen, ftnlen), tstatd_(doublereal *, doublereal *, doublereal *)
	    , tstckn_(char *, char *, logical *, logical *, logical *, 
	    integer *, ftnlen, ftnlen);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     Test the routine CKFROT.  There are several test cases.  Several */
/*     to make sure that nothing is found if an instrument is not */
/*     loaded.  Another to make sure the correct frame is located */
/*     when the instrument is loaded. */

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

/* -    SPICELIB Version 2.0.0, 14-MAR-2000 (WLT) */

/*        Added three test cases to make sure that the case when no */
/*        C-kernel is loaded is dealt with correctly as well as */
/*        the case when no SCLK kernel is loaded. */

/* -    SPICELIB Version 1.0.0, 06-OCT-1999 (WLT) */
/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_CKFROT", (ftnlen)8);
    kilfil_("TEST.CK", (ftnlen)7);
    kilfil_("TEST.SCLK", (ftnlen)9);
    tcase_("Make sure that we do not signal an error when no C or SCLK kerne"
	    "ls have been loaded. ", (ftnlen)85);
    tparse_("1-JAN-1990", &et, error, (ftnlen)10, (ftnlen)80);
    ckfrot_(&c_n9998, &et, xform, &frame, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Make sure nothing is found if we don't have a C-kernel. ", (
	    ftnlen)56);

/*        Create a test (but don't load) C-kernel; load the */
/*        associated SCLK. */

    tstckn_("TEST.CK", "TEST.SCLK", &c_false, &c_true, &c_true, &handle, (
	    ftnlen)7, (ftnlen)9);
    tparse_("1-JAN-1990", &et, error, (ftnlen)10, (ftnlen)80);
    ckfrot_(&c_n9998, &et, xform, &frame, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Make sure nothing is found if we don't have an instrument in the"
	    " C-kernel. ", (ftnlen)75);

/*        Load a test C-kernel. */

    cklpf_("TEST.CK", &handle, (ftnlen)7);
    tparse_("1-JAN-1990", &et, error, (ftnlen)10, (ftnlen)80);
    ckfrot_(&c_n9998, &et, xform, &frame, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Make sure that when data is available, that a frame transformati"
	    "on if found and that it has the correct value. ", (ftnlen)111);
    ckfrot_(&c_n9999, &et, xform, &frame, &found);
    tstatd_(&et, rot, av);
    xpose_(rot, xform2);
    namfrm_("GALACTIC", &eframe, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("FRAME", &frame, "=", &eframe, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckad_("XFORM", xform, "||", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)2);
    chckad_("XFORM", xform, "~~/", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Check to make sure CKMETA is propery used and that we get the ex"
	    "pected frame transformation. (Object -10000)", (ftnlen)108);
    ckfrot_(&c_b51, &et, xform, &frame, &found);
    tstatd_(&et, rot, av);
    xpose_(rot, xform2);
    namfrm_("FK4", &eframe, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("FRAME", &frame, "=", &eframe, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckad_("XFORM", xform, "||", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)2);
    chckad_("XFORM", xform, "~~/", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Same test for object -10001", (ftnlen)27);
    ckfrot_(&c_b69, &et, xform, &frame, &found);
    tstatd_(&et, rot, av);
    xpose_(rot, xform2);
    namfrm_("J2000", &eframe, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("FRAME", &frame, "=", &eframe, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckad_("XFORM", xform, "||", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)2);
    chckad_("XFORM", xform, "~~/", xform2, &c__9, &c_b45, ok, (ftnlen)5, (
	    ftnlen)3);
    tcase_("Perform the same test as before, but clear the kernel pool first"
	    ". We should not find a transformation now, because there is no S"
	    "CLK data available. ", (ftnlen)148);
    clpool_();
    tparse_("1-JAN-1990", &et, error, (ftnlen)10, (ftnlen)80);
    ckfrot_(&c_b69, &et, xform, &frame, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    ckupf_(&handle);
    kilfil_("TEST.CK", (ftnlen)7);
    kilfil_("TEST.SCLK", (ftnlen)9);
    t_success__(ok);
    return 0;
} /* f_ckfrot__ */

