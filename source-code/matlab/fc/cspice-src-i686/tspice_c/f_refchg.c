/* f_refchg.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__83 = 83;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c_b98 = -222222;
static integer c__1 = 1;
static integer c_b104 = 27687628;
static integer c_b105 = -1987291;
static integer c__9 = 9;
static doublereal c_b116 = 1e-12;
static doublereal c_b129 = 0.;
static integer c__6 = 6;
static integer c_b208 = -111111;
static integer c__399 = 399;
static doublereal c_b217 = 1e-13;
static integer c_b219 = -399999;
static integer c__0 = 0;

/* $Procedure      F_REFCHG ( Family of tests for REFCHG ) */
/* Subroutine */ int f_refchg__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    char ch__1[16];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer cent;
    doublereal tk2j2[9]	/* was [3][3] */, tipm[9]	/* was [3][3] */, 
	    tpmi[9]	/* was [3][3] */, ck2in[9]	/* was [3][3] */, 
	    tk2ck[9]	/* was [3][3] */, tk2in[9]	/* was [3][3] */;
    integer i__, j, frame;
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen), tcase_(
	    char *, ftnlen);
    integer earth, class__;
    extern /* Subroutine */ int ckupf_(integer *);
    char lines[80*83];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer xcent, xpctd[3];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[80];
    doublereal rotat[9]	/* was [3][3] */;
    extern /* Subroutine */ int xpose_(doublereal *, doublereal *);
    integer ntext;
    extern /* Subroutine */ int t_success__(logical *);
    integer id;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    doublereal av[3], et;
    integer handle;
    extern /* Subroutine */ int refchg_(integer *, integer *, doublereal *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical *
	    , ftnlen), kilfil_(char *, ftnlen), namfrm_(char *, integer *, 
	    ftnlen);
    integer clssid;
    extern /* Subroutine */ int tipbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), frinfo_(integer *, integer *, integer *, 
	    integer *, logical *), tkfram_(integer *, doublereal *, integer *,
	     logical *);
    integer xclsid;
    doublereal modify[9]	/* was [3][3] */, expect[9]	/* was [3][3] 
	    */;
    extern /* Subroutine */ int clpool_(void);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    char deftxt[80*15];
    integer xclass;
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), lmpool_(char *, integer *, ftnlen), tstatd_(doublereal *,
	     doublereal *, doublereal *), irfrot_(integer *, integer *, 
	    doublereal *), tstckn_(char *, char *, logical *, logical *, 
	    logical *, integer *, ftnlen, ftnlen), tstpck_(char *, logical *, 
	    logical *, ftnlen);
    doublereal trotat[9]	/* was [3][3] */;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *), tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen), mxm_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the user interface level frame transformation */
/*     software FRMGHG. REFCHG. */

/* -    SPICELIB Version 1.1.0, 15-FEB-2001 (EDW) */

/*     Altered Test case 3 to use an error tolerance of 1.D-14 instead of */
/*     an exact equality. That test failed due to roundoff error (on the */
/*     order of 1.D-16) when compiled under the Macintosh Absoft FORTRAN */
/*     compiler. */

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

    topen_("F_REFCHG", (ftnlen)8);
    s_copy(lines, "This is a test frame kernel for the fictional instrument "
	    "TST_PHEONIX", (ftnlen)80, (ftnlen)68);
    s_copy(lines + 80, "on board the fictional spacecraft PHEONIX. A C-kerne"
	    "l for", (ftnlen)80, (ftnlen)57);
    s_copy(lines + 160, "the platform on which TST_PHEONIX is mounted can be"
	    " generated", (ftnlen)80, (ftnlen)61);
    s_copy(lines + 240, "by calling the test utility TSTCKN.", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 400, "This kernel describes only the orientation attribut"
	    "es of the", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 480, "TST_PHOENIX instrument.", (ftnlen)80, (ftnlen)23);
    s_copy(lines + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 640, "This kernel is intended only for test purposes.  It"
	    " is primarily", (ftnlen)80, (ftnlen)64);
    s_copy(lines + 720, "useful for testing frame routines", (ftnlen)80, (
	    ftnlen)33);
    s_copy(lines + 800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 960, "Next we need to supply the various bits of frame id"
	    "entification for", (ftnlen)80, (ftnlen)67);
    s_copy(lines + 1040, "this instrument.", (ftnlen)80, (ftnlen)16);
    s_copy(lines + 1120, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 1200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 1280, "FRAME_-399999_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 1360, "FRAME_-399999_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 1440, "FRAME_-399999_CLASS_ID = -399999", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1520, "FRAME_-399999_NAME     = 'TOPOCENTRIC'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 1600, "FRAME_TOPOCENTRIC      = -399999", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1680, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1760, "FRAME_-111111_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 1840, "FRAME_-111111_CENTER   = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 1920, "FRAME_-111111_CLASS_ID = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2000, "FRAME_-111111_NAME     = 'TST-PHOENIX'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 2080, "FRAME_TST-PHOENIX      = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2240, "FRAME_-9999_CLASS      =  3", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 2320, "FRAME_-9999_CENTER     = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 2400, "FRAME_-9999_CLASS_ID   = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 2480, "FRAME_-9999_NAME       = 'PHOENIX'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 2560, "FRAME_PHOENIX          = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 2640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2720, "CK_-9999_SCLK          =  -9", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 2800, "CK_-9999_SPK           =  -9", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 2880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2960, "TKFRAME_-111111_SPEC      = 'MATRIX'", (ftnlen)80, (
	    ftnlen)36);
    s_copy(lines + 3040, "TKFRAME_-111111_RELATIVE  = 'PHOENIX'", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 3120, "TKFRAME_-111111_MATRIX    =  ( 0.48", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3200, "                               0.60", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3280, "                               0.64", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3360, "                              -0.8", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 3440, "                               0.0", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 3520, "                               0.6", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 3600, "                               0.36", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3680, "                              -0.80", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3760, "                               0.48 )", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 3840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3920, "TKFRAME_-399999_SPEC       = 'ANGLES'", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 4000, "TKFRAME_-399999_RELATIVE   = 'IAU_EARTH'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 4080, "TKFRAME_-399999_ANGLES     = ( 90, 56.1829, -118.0"
	    " )", (ftnlen)80, (ftnlen)52);
    s_copy(lines + 4160, "TKFRAME_-399999_AXES       = ( 3, 2, 3 )", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 4240, "TKFRAME_-399999_UNITS      = 'DEGREES'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 4320, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(lines + 4400, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 4480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4560, "  ", (ftnlen)80, (ftnlen)2);
    s_copy(lines + 4640, "  ", (ftnlen)80, (ftnlen)2);
    s_copy(lines + 4720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4800, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 4960, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 5040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5120, "FRAME_-222222_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 5200, "FRAME_-222222_CENTER   = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 5280, "FRAME_-222222_CLASS_ID = -222222", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 5360, "FRAME_-222222_NAME     = 'TST_PHOENIX2'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 5440, "FRAME_TST_PHOENIX2     = -222222", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 5520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5680, "TKFRAME_-222222_RELATIVE   =  'PHOENIX'", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 5760, "TKFRAME_-222222_SPEC       =  'MATRIX'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 5840, "TKFRAME_-222222_MATRIX     = ( 0.48", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 5920, "                               0.60", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 6000, "                               0.64", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 6080, "                              -0.8", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 6160, "                               0.0", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 6240, "                               0.6", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 6320, "                               0.36", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 6400, "                              -0.80", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 6480, "                               0.48 )", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 6560, " ", (ftnlen)80, (ftnlen)1);

/*     Clean out the kernel pool. Just in case we have something */
/*     already loaded there. */

    clpool_();

/*     Create and load the test kernels that will be needed during */
/*     this test. */

    tsttxt_("phoenix2.tk", lines, &c__83, &c_true, &c_true, (ftnlen)11, (
	    ftnlen)80);
    tstpck_("test.pck", &c_true, &c_false, (ftnlen)8);
    tstckn_("phoenix.bc", "phoenix.tsc", &c_false, &c_true, &c_false, &handle,
	     (ftnlen)10, (ftnlen)11);
    cklpf_("phoenix.bc", &handle, (ftnlen)10);
    tparse_("1 Jan 2195", &et, error, (ftnlen)10, (ftnlen)80);
    tcase_("Exercise the exception handling for the case in which informatio"
	    "n is not provided that is sufficient to transform from one frame"
	    " to another. ", (ftnlen)141);
    refchg_(&c_b98, &c__1, &et, rotat);
    chckxc_(&c_true, "SPICE(NOFRAMECONNECT)", ok, (ftnlen)21);
    tcase_("Verify that if a frame is not recognized, that an error is signa"
	    "lled that says so. ", (ftnlen)83);
    tparse_("1 Jan 1995", &et, error, (ftnlen)10, (ftnlen)80);
    refchg_(&c_b104, &c_b105, &et, rotat);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAME)", ok, (ftnlen)19);
    tcase_("Verify that all inertial frames are recognized and that they pro"
	    "duce the expected transformation. ", (ftnlen)98);
    for (i__ = 1; i__ <= 18; ++i__) {
	for (j = 1; j <= 18; ++j) {
	    refchg_(&i__, &j, &et, rotat);
	    irfrot_(&i__, &j, rot);
	    tstmsg_("#", "Subcase. Frame 1 = #, Frame 2 = #.", (ftnlen)1, (
		    ftnlen)34);
	    tstmsi_(&i__);
	    tstmsi_(&j);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("ROTAT", rotat, "~", rot, &c__9, &c_b116, ok, (ftnlen)5, (
		    ftnlen)1);
	}
    }

/*        Clear the extra message. */

    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that the transformations from inertial to bodyfixed frame"
	    "s behave as expected. ", (ftnlen)86);
    for (i__ = 10010; i__ <= 10027; ++i__) {
	j = i__;
	tstmsg_("#", "Subcase: Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&j);
	frinfo_(&j, &cent, &class__, &clssid, &found);
	tipbod_("J2000", &clssid, &et, tipm, (ftnlen)5);
	refchg_(&c__1, &j, &et, rotat);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("ROTAT", rotat, "=", tipm, &c__9, &c_b129, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that the transformations from bodyfixed to inertial frame"
	    "s behave as expected. ", (ftnlen)86);
    for (i__ = 10010; i__ <= 10027; ++i__) {
	j = i__;
	tstmsg_("#", "Subcase: Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&j);
	frinfo_(&j, &cent, &class__, &clssid, &found);
	tipbod_("J2000", &clssid, &et, tipm, (ftnlen)5);
	xpose_(tipm, tpmi);
	refchg_(&j, &c__1, &et, rotat);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("ROTAT", rotat, "=", tpmi, &c__9, &c_b129, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that C-kernel frames to inertial frame transformations ar"
	    "e carried out correctly. ", (ftnlen)89);

/*        First construct the transformation from the C-kernel */
/*        frame to its native frame.  And look up the native */
/*        frame for each of the segments in the C-kernel. */

    tstatd_(&et, rot, av);
    xpose_(rot, trotat);
    namfrm_("J2000", xpctd, (ftnlen)5);
    namfrm_("FK4", &xpctd[1], (ftnlen)3);
    namfrm_("GALACTIC", &xpctd[2], (ftnlen)8);
    for (i__ = 1; i__ <= 3; ++i__) {
	id = i__ - 10002;
	frinfo_(&xpctd[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"xpctd", i__1, "f_refchg__", (ftnlen)335)], &xcent, &xclass, &
		xclsid, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("Expected frame info", &found, &c_true, ok, (ftnlen)19);

/*           Define a CK frame associated with instrument having ID code */
/*           "ID"; the pointing for this instrument is given by the CK */
/*           created by the test utility TSTCK3. */

	s_copy(deftxt, "FRAME_CK_INSTID                  =  INSTID", (ftnlen)
		80, (ftnlen)42);
	s_copy(deftxt + 80, "FRAME_INSTID_NAME                = 'CK_INSTID'", 
		(ftnlen)80, (ftnlen)46);
	s_copy(deftxt + 160, "FRAME_INSTID_CLASS               =  3", (ftnlen)
		80, (ftnlen)37);
	s_copy(deftxt + 240, "FRAME_INSTID_CLASS_ID            =  INSTID", (
		ftnlen)80, (ftnlen)42);
	s_copy(deftxt + 320, "FRAME_INSTID_CENTER              =  XCENT", (
		ftnlen)80, (ftnlen)41);
	s_copy(deftxt + 400, "FRAME_INSTID_RELATIVE            =  XPCT", (
		ftnlen)80, (ftnlen)40);
	ntext = 6;
	i__1 = ntext;
	for (j = 1; j <= i__1; ++j) {

/*              Do two replacements for the ID code; if the second */
/*              replacement is unnecessary, no harm's done. */

	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_refchg__", (ftnlen)364)) * 80, "INSTID"
		    , &id, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? i__3 :
		     s_rnge("deftxt", i__3, "f_refchg__", (ftnlen)364)) * 80, 
		    (ftnlen)80, (ftnlen)6, (ftnlen)80);
	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_refchg__", (ftnlen)365)) * 80, "INSTID"
		    , &id, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? i__3 :
		     s_rnge("deftxt", i__3, "f_refchg__", (ftnlen)365)) * 80, 
		    (ftnlen)80, (ftnlen)6, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Replace the center ID when it comes up. */

	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_refchg__", (ftnlen)370)) * 80, "XCENT",
		     &xcent, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? 
		    i__3 : s_rnge("deftxt", i__3, "f_refchg__", (ftnlen)370)) 
		    * 80, (ftnlen)80, (ftnlen)5, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/*           Insert the base frame ID. */

	repmi_(deftxt + ((i__1 = ntext - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"deftxt", i__1, "f_refchg__", (ftnlen)377)) * 80, "XPCT", &
		xpctd[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("xpc"
		"td", i__2, "f_refchg__", (ftnlen)377)], deftxt + ((i__3 = 
		ntext - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("deftxt", i__3, 
		"f_refchg__", (ftnlen)377)) * 80, (ftnlen)80, (ftnlen)4, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Load the CK_-10001 frame definition. */

	lmpool_(deftxt, &c__6, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	tstmsg_("#", "Subcase: Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&id);
	refchg_(&id, &c__1, &et, rotat);

/*           Construct the expected transfromation from the C-kernel */
/*           native frame to J2000. And then construct the transformation */
/*           from the C-kernel frame to J2000. */

	refchg_(&xpctd[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"xpctd", i__1, "f_refchg__", (ftnlen)396)], &c__1, &et, 
		modify);
	mxm_(modify, trotat, expect);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("ROTAT", rotat, "~", expect, &c__9, &c_b116, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that we can perform a complete transformation from an ins"
	    "trument frame to a body fixed frame. TK -> CK ->INERTIAL ->PCK ", 
	    (ftnlen)127);
    namfrm_("IAU_EARTH", &earth, (ftnlen)9);
    refchg_(&c_b208, &earth, &et, rotat);

/*        Construct the expected output state transformation matrix. */

    tk2ck[0] = .48;
    tk2ck[1] = .6;
    tk2ck[2] = .64;
    tk2ck[3] = -.8;
    tk2ck[4] = 0.;
    tk2ck[5] = .6;
    tk2ck[6] = .36;
    tk2ck[7] = -.8;
    tk2ck[8] = .48;
    refchg_(&xpctd[2], &c__1, &et, modify);

/*        TSTATD can reproduce the attitude in the C-kernel so we */
/*        use that instead of CKGPAV. */

    tstatd_(&et, rot, av);
    xpose_(rot, ck2in);
    tipbod_("J2000", &c__399, &et, tipm, (ftnlen)5);
    mxm_(ck2in, tk2ck, tk2in);
    mxm_(modify, tk2in, tk2j2);
    mxm_(tipm, tk2j2, trotat);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("ROTAT", rotat, "~", trotat, &c__9, &c_b217, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Perform test a long chain of transformations on both ends. TK ->"
	    " CK -> INERTIAL -> PCK -> TK ", (ftnlen)93);

/*        Get the transformation from frame -399999 to the */
/*        underlying bodyfixed frame. */

    tkfram_(&c_b219, rot, &frame, &found);
    xpose_(rot, modify);
    mxm_(modify, trotat, expect);
    refchg_(&c_b208, &c_b219, &et, rotat);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("FRAME", &frame, "=", &earth, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chckad_("ROTAT", rotat, "~", expect, &c__9, &c_b217, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Finally clean up the loaded data. */

    ckupf_(&handle);
    kilfil_("phoenix.bc", (ftnlen)10);
    kilfil_("phoenix2.tk", (ftnlen)11);
    clpool_();
    t_success__(ok);
    return 0;
} /* f_refchg__ */

