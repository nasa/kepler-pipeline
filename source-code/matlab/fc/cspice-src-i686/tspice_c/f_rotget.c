/* f_rotget.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__66 = 66;
static integer c_b84 = -222222;
static integer c__1 = 1;
static integer c__0 = 0;
static integer c__9 = 9;
static doublereal c_b102 = 0.;
static integer c__99 = 99;
static integer c__6 = 6;
static doublereal c_b190 = 1e-12;
static integer c_b192 = -111111;
static integer c_n9999 = -9999;
static doublereal c_b204 = 1e-14;

/* $Procedure      F_ROTGET ( Family of tests for ROTGET ) */
/* Subroutine */ int f_rotget__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    char ch__1[16];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer cent;
    doublereal tipm[9]	/* was [3][3] */, tpmi[9]	/* was [3][3] */;
    integer i__, j;
    extern /* Subroutine */ int tcase_(char *, ftnlen), cklpf_(char *, 
	    integer *, ftnlen);
    integer class__;
    extern /* Subroutine */ int ckupf_(integer *);
    char lines[80*66];
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
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), namfrm_(char *, integer *, 
	    ftnlen);
    integer clssid;
    extern /* Subroutine */ int tipbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), frinfo_(integer *, integer *, integer *, 
	    integer *, logical *);
    integer xclsid;
    extern /* Subroutine */ int clpool_(void);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    char deftxt[80*15];
    integer xclass;
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), lmpool_(char *, integer *, ftnlen), tstatd_(doublereal *,
	     doublereal *, doublereal *), rotget_(integer *, doublereal *, 
	    doublereal *, integer *, logical *), tstckn_(char *, char *, 
	    logical *, logical *, logical *, integer *, ftnlen, ftnlen), 
	    irfrot_(integer *, integer *, doublereal *), tstpck_(char *, 
	    logical *, logical *, ftnlen);
    integer outfrm;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *);
    doublereal tmprot[9]	/* was [3][3] */;
    extern /* Subroutine */ int tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the primary frame utility ROTGET. */
/*     It makes sure that all 4 frame classes are recognized */
/*     and that the routine retrieves the correct frame information */
/*     for each of them. */

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

    topen_("F_ROTGET", (ftnlen)8);
    s_copy(lines, "This is a test I-kernel for the fictional instrument TST_"
	    "PHEONIX ", (ftnlen)80, (ftnlen)65);
    s_copy(lines + 80, "on board the fictional spacecraft PHEONIX. A C-kerne"
	    "l for ", (ftnlen)80, (ftnlen)58);
    s_copy(lines + 160, "the platform on which TST_PHEONIX is mounted can be"
	    " generated ", (ftnlen)80, (ftnlen)62);
    s_copy(lines + 240, "by calling the test utility TSTCKN. ", (ftnlen)80, (
	    ftnlen)36);
    s_copy(lines + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 400, "This kernel describes only the mode independent att"
	    "ributes of the ", (ftnlen)80, (ftnlen)66);
    s_copy(lines + 480, "TST_PHOENIX instrument. ", (ftnlen)80, (ftnlen)24);
    s_copy(lines + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 640, "This kernel is intended only for test purposes.  It"
	    " is primarily ", (ftnlen)80, (ftnlen)65);
    s_copy(lines + 720, "useful for testing the I-kernel data fetching routi"
	    "nes ", (ftnlen)80, (ftnlen)55);
    s_copy(lines + 800, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 880, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 960, "TKFRAME_-111111_SPEC = 'MATRIX' ", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1200, "  ", (ftnlen)80, (ftnlen)2);
    s_copy(lines + 1280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1520, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1600, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1680, "TKFRAME_-111111_RELATIVE     = 'PHOENIX' ", (ftnlen)
	    80, (ftnlen)41);
    s_copy(lines + 1760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2000, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2240, "TKFRAME_-111111_MATRIX    = ( 0.48 ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 2320, "0.60 ", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2400, "0.64 ", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2480, "-0.8 ", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2560, "0.0 ", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 2640, "0.6 ", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 2720, "0.36 ", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 2800, "-0.80 ", (ftnlen)80, (ftnlen)6);
    s_copy(lines + 2880, "0.48 ) ", (ftnlen)80, (ftnlen)7);
    s_copy(lines + 2960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3120, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(lines + 3200, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 3280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3360, "Next we need to supply the various bits of frame i"
	    "dentification for ", (ftnlen)80, (ftnlen)68);
    s_copy(lines + 3440, "this instrument. ", (ftnlen)80, (ftnlen)17);
    s_copy(lines + 3520, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)16);
    s_copy(lines + 3600, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(lines + 3680, "FRAME_-222222_CLASS    =  7 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 3760, "FRAME_-222222_CENTER   = -9 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 3840, "FRAME_-222222_CLASS_ID = -1 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 3920, "FRAME_-222222_NAME     = 'UNSUPPORTED' ", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 4000, "FRAME_UNSUPPORTED      = -222222 ", (ftnlen)80, (
	    ftnlen)33);
    s_copy(lines + 4080, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4160, "FRAME_-111111_CLASS    =  4 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 4240, "FRAME_-111111_CENTER   = -9 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 4320, "FRAME_-111111_CLASS_ID = -111111 ", (ftnlen)80, (
	    ftnlen)33);
    s_copy(lines + 4400, "FRAME_-111111_NAME     = 'TST-PHOENIX' ", (ftnlen)
	    80, (ftnlen)39);
    s_copy(lines + 4480, "FRAME_TST-PHOENIX      = -111111 ", (ftnlen)80, (
	    ftnlen)33);
    s_copy(lines + 4560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4640, "FRAME_-9999_CLASS      =  3 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 4720, "FRAME_-9999_CENTER     = -9 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 4800, "FRAME_-9999_CLASS_ID   = -9999 ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(lines + 4880, "FRAME_-9999_NAME       = 'PHOENIX' ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 4960, "FRAME_PHOENIX          = -9999 ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(lines + 5040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 5120, "CK_-9999_SCLK          =  -9 ", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 5200, "CK_-9999_SPK           =  -9 ", (ftnlen)80, (ftnlen)
	    29);

/*     Clean out the kernel pool. Just in case we have something */
/*     already loaded there. */

    clpool_();

/*     Create and load the test kernels that will be needed during */
/*     this test. */

    tcase_("Make sure we can load everything.", (ftnlen)33);
    tstpck_("test.pck", &c_true, &c_false, (ftnlen)8);
    tstckn_("phoenix.bc", "phoenix.tsc", &c_false, &c_true, &c_false, &handle,
	     (ftnlen)10, (ftnlen)11);
    tsttxt_("phoenix2.ik", lines, &c__66, &c_true, &c_false, (ftnlen)11, (
	    ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cklpf_("phoenix.bc", &handle, (ftnlen)10);
    tparse_("1 Jan 1995", &et, error, (ftnlen)10, (ftnlen)80);
    tcase_("Determine that a frame of unrecognized class causes the correct "
	    "exception to be signalled. ", (ftnlen)91);
    rotget_(&c_b84, &et, rotat, &outfrm, &found);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAMETYPE)", ok, (ftnlen)23);
    tcase_("Verify that all inertial frames are recognized and that they pro"
	    "duce the expected transformation. ", (ftnlen)98);
    for (i__ = 1; i__ <= 18; ++i__) {
	rotget_(&i__, &et, rotat, &outfrm, &found);
	irfrot_(&i__, &c__1, rot);
	j = i__;
	tstmsg_("#", "Subcase. Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&j);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("OUTFRM", &outfrm, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	chckad_("ROTAT", rotat, "=", rot, &c__9, &c_b102, ok, (ftnlen)5, (
		ftnlen)1);
    }

/*        Clear the extra message. */

    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that inertial class frames that are not yet supported are"
	    " not found by ROTGET. ", (ftnlen)86);
    rotget_(&c__99, &et, rotat, &outfrm, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    tcase_("Verify that the planetary frames are recognized. ", (ftnlen)49);
    for (i__ = 10010; i__ <= 10027; ++i__) {
	j = i__;
	tstmsg_("#", "Subcase: Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&j);
	frinfo_(&j, &cent, &class__, &clssid, &found);
	tipbod_("J2000", &clssid, &et, tipm, (ftnlen)5);
	xpose_(tipm, tpmi);
	rotget_(&i__, &et, rotat, &outfrm, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("OUTFRM", &outfrm, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
	chckad_("ROTAT", rotat, "=", tpmi, &c__9, &c_b102, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Verify that loaded C-kernels are recognized.", (ftnlen)44);
    tstatd_(&et, tmprot, av);
    xpose_(tmprot, rot);
    namfrm_("J2000", xpctd, (ftnlen)5);
    namfrm_("FK4", &xpctd[1], (ftnlen)3);
    namfrm_("GALACTIC", &xpctd[2], (ftnlen)8);
    for (i__ = 1; i__ <= 3; ++i__) {
	id = i__ - 10002;
	frinfo_(&xpctd[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"xpctd", i__1, "f_rotget__", (ftnlen)277)], &xcent, &xclass, &
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
		    "deftxt", i__2, "f_rotget__", (ftnlen)306)) * 80, "INSTID"
		    , &id, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? i__3 :
		     s_rnge("deftxt", i__3, "f_rotget__", (ftnlen)306)) * 80, 
		    (ftnlen)80, (ftnlen)6, (ftnlen)80);
	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_rotget__", (ftnlen)307)) * 80, "INSTID"
		    , &id, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? i__3 :
		     s_rnge("deftxt", i__3, "f_rotget__", (ftnlen)307)) * 80, 
		    (ftnlen)80, (ftnlen)6, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Replace the center ID when it comes up. */

	    repmi_(deftxt + ((i__2 = j - 1) < 15 && 0 <= i__2 ? i__2 : s_rnge(
		    "deftxt", i__2, "f_rotget__", (ftnlen)312)) * 80, "XCENT",
		     &xcent, deftxt + ((i__3 = j - 1) < 15 && 0 <= i__3 ? 
		    i__3 : s_rnge("deftxt", i__3, "f_rotget__", (ftnlen)312)) 
		    * 80, (ftnlen)80, (ftnlen)5, (ftnlen)80);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	}

/*           Insert the base frame ID. */

	repmi_(deftxt + ((i__1 = ntext - 1) < 15 && 0 <= i__1 ? i__1 : s_rnge(
		"deftxt", i__1, "f_rotget__", (ftnlen)319)) * 80, "XPCT", &
		xpctd[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("xpc"
		"td", i__2, "f_rotget__", (ftnlen)319)], deftxt + ((i__3 = 
		ntext - 1) < 15 && 0 <= i__3 ? i__3 : s_rnge("deftxt", i__3, 
		"f_rotget__", (ftnlen)319)) * 80, (ftnlen)80, (ftnlen)4, (
		ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Load the CK_-10001 frame definition. */

	lmpool_(deftxt, &c__6, (ftnlen)80);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	tstmsg_("#", "Subcase: Frame ID = # ", (ftnlen)1, (ftnlen)22);
	tstmsi_(&id);
	rotget_(&id, &et, rotat, &outfrm, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("OUTFRM", &outfrm, "=", &xpctd[(i__1 = i__ - 1) < 3 && 0 <= 
		i__1 ? i__1 : s_rnge("xpctd", i__1, "f_rotget__", (ftnlen)336)
		], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chckad_("ROTAT", rotat, "~", rot, &c__9, &c_b190, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tcase_("Verify that I-kernel frames are recognized. ", (ftnlen)44);
    rotget_(&c_b192, &et, rotat, &outfrm, &found);

/*        Construct the expected output state transformation matrix. */

    rot[0] = .48;
    rot[1] = .6;
    rot[2] = .64;
    rot[3] = -.8;
    rot[4] = 0.;
    rot[5] = .6;
    rot[6] = .36;
    rot[7] = -.8;
    rot[8] = .48;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("OUTFRM", &outfrm, "=", &c_n9999, &c__0, ok, (ftnlen)6, (ftnlen)1)
	    ;
    chckad_("ROTAT", rotat, "~", rot, &c__9, &c_b204, ok, (ftnlen)5, (ftnlen)
	    1);

/*     Finally clean up the loaded data. */

    ckupf_(&handle);
    clpool_();
    kilfil_("phoenix.bc", (ftnlen)10);
    t_success__(ok);
    return 0;
} /* f_rotget__ */

