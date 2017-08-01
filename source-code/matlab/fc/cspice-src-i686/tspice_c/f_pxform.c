/* f_pxform.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__56 = 56;
static integer c__9 = 9;
static doublereal c_b92 = 1e-14;
static doublereal c_b194 = 0.;

/* $Procedure      F_PXFORM ( Family of tests for PXFORM ) */
/* Subroutine */ int f_pxform__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    char ch__1[32];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char name__[32*24];
    integer phnx, topo, i__, j, k, l;
    char namei[32], namej[32];
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen), tcase_(
	    char *, ftnlen);
    doublereal eform[9]	/* was [3][3] */;
    extern /* Subroutine */ int ckupf_(integer *);
    char lines[80*56];
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *),
	     topen_(char *, ftnlen);
    doublereal xform[9]	/* was [3][3] */, tsipm[9]	/* was [3][3] */, 
	    tspmi[9]	/* was [3][3] */;
    extern /* Subroutine */ int xpose_(doublereal *, doublereal *), 
	    t_success__(logical *), chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    integer idcode[24];
    doublereal et;
    integer handle;
    extern /* Subroutine */ int refchg_(integer *, integer *, doublereal *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    kilfil_(char *, ftnlen), irfnam_(integer *, char *, ftnlen), 
	    namfrm_(char *, integer *, ftnlen), tipbod_(char *, integer *, 
	    doublereal *, doublereal *, ftnlen), clpool_(void);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    doublereal tmpmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int tstckn_(char *, char *, logical *, logical *, 
	    logical *, integer *, ftnlen, ftnlen), irfrot_(integer *, integer 
	    *, doublereal *), tstpck_(char *, logical *, logical *, ftnlen), 
	    pxform_(char *, char *, doublereal *, doublereal *, ftnlen, 
	    ftnlen), tstmsc_(char *, ftnlen), tstmsg_(char *, char *, ftnlen, 
	    ftnlen), tsttxt_(char *, char *, integer *, logical *, logical *, 
	    ftnlen, ftnlen);
    integer idi, idj;
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the routine PXFORM checkin both exceptional */
/*     and normal cases. */

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

/* -    SPICELIB Version 1.2.0, 27-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in XPOSEG calls. */

/* -    SPICELIB Version 1.1.0, 15-FEB-2001 (EDW) */

/*     Altered Test case 2 to use an error tolerance of 1.D-14 instead of */
/*     an exact equality. That test failed due to roundoff error (on the */
/*     order of 1.D-16) when compiled under the Macintosh Absoft FORTRAN */
/*     compiler. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */

    s_copy(lines, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 80, "This is a test kernel for the fictional instrument T"
	    "ST_PHEONIX", (ftnlen)80, (ftnlen)62);
    s_copy(lines + 160, "on board the fictional spacecraft PHEONIX. A C-kern"
	    "el for", (ftnlen)80, (ftnlen)57);
    s_copy(lines + 240, "the platform on which TST_PHEONIX is mounted can be"
	    " generated", (ftnlen)80, (ftnlen)61);
    s_copy(lines + 320, "by calling the test utility TSTCK3.", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 480, "This kernel describes only the orientation attribut"
	    "es of the", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 560, "TST_PHOENIX instrument.", (ftnlen)80, (ftnlen)23);
    s_copy(lines + 640, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 720, "This kernel is intended only for test purposes.  It"
	    " is primarily", (ftnlen)80, (ftnlen)64);
    s_copy(lines + 800, "useful for testing the TK-frames data fetching rout"
	    "ines", (ftnlen)80, (ftnlen)55);
    s_copy(lines + 880, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)32);
    s_copy(lines + 960, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(lines + 1040, "TKFRAME_-111111_SPEC              = 'MATRIX'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(lines + 1120, "TKFRAME_-111111_RELATIVE =  'PHOENIX'", (ftnlen)80, 
	    (ftnlen)37);
    s_copy(lines + 1200, "TKFRAME_-111111_MATRIX   = ( 0.48", (ftnlen)80, (
	    ftnlen)33);
    s_copy(lines + 1280, "0.60", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1360, "0.64", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1440, "-0.8", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1520, "0.0", (ftnlen)80, (ftnlen)3);
    s_copy(lines + 1600, "0.6", (ftnlen)80, (ftnlen)3);
    s_copy(lines + 1680, "0.36", (ftnlen)80, (ftnlen)4);
    s_copy(lines + 1760, "-0.80", (ftnlen)80, (ftnlen)5);
    s_copy(lines + 1840, "0.48 )", (ftnlen)80, (ftnlen)6);
    s_copy(lines + 1920, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2000, "TKFRAME_-399999_SPEC              = 'ANGLES'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(lines + 2080, "TKFRAME_-399999_RELATIVE          = 'IAU_EARTH'", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 2160, "TKFRAME_-399999_AXES              = ( 3, 2, 3 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 2240, "TKFRAME_-399999_ANGLES            = ( 90, 56.1829,"
	    " -118.0 )", (ftnlen)80, (ftnlen)59);
    s_copy(lines + 2320, "TKFRAME_-399999_UNITS             = 'DEGREES'", (
	    ftnlen)80, (ftnlen)45);
    begtxt_(ch__1, (ftnlen)32);
    s_copy(lines + 2400, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(lines + 2480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2560, "Next we need to supply the various bits of frame i"
	    "dentification for", (ftnlen)80, (ftnlen)67);
    s_copy(lines + 2640, "this instrument.", (ftnlen)80, (ftnlen)16);
    s_copy(lines + 2720, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)32);
    s_copy(lines + 2800, ch__1, (ftnlen)80, (ftnlen)32);
    s_copy(lines + 2880, "FRAME_-399999_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 2960, "FRAME_-399999_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 3040, "FRAME_-399999_CLASS_ID = -399999", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 3120, "FRAME_-399999_NAME     = 'TOPOCENTRIC'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 3200, "FRAME_TOPOCENTRIC      = -399999", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 3280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3360, "FRAME_-111111_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3440, "FRAME_-111111_CENTER   = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3520, "FRAME_-111111_CLASS_ID = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 3600, "FRAME_-111111_NAME     = 'TST-PHOENIX'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 3680, "FRAME_TST-PHOENIX      = -111111", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 3760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3840, "FRAME_-9999_CLASS      =  3", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 3920, "FRAME_-9999_CENTER     = -9", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 4000, "FRAME_-9999_CLASS_ID   = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 4080, "FRAME_-9999_NAME       = 'PHOENIX'", (ftnlen)80, (
	    ftnlen)34);
    s_copy(lines + 4160, "FRAME_PHOENIX          = -9999", (ftnlen)80, (
	    ftnlen)30);
    s_copy(lines + 4240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 4320, "CK_-9999_SCLK          =  -9", (ftnlen)80, (ftnlen)
	    28);
    s_copy(lines + 4400, "CK_-9999_SPK           =  -9", (ftnlen)80, (ftnlen)
	    28);

/*     Begin every test family with an open call. */

    topen_("F_PXFORM", (ftnlen)8);

/*     Create the C-kernels and PCK files needed for the */
/*     rest of this test. */

    clpool_();
    kilfil_("phoenix.bc", (ftnlen)10);
    kilfil_("phoenix.tsc", (ftnlen)11);
    kilfil_("phoenix.ik", (ftnlen)10);
    kilfil_("test_pck.ker", (ftnlen)12);
    tstckn_("phoenix.bc", "phoenix.tsc", &c_false, &c_true, &c_false, &handle,
	     (ftnlen)10, (ftnlen)11);
    tstpck_("test_pck.ker", &c_true, &c_false, (ftnlen)12);
    cklpf_("phoenix.bc", &handle, (ftnlen)10);
    tsttxt_("phoenix.ik", lines, &c__56, &c_true, &c_false, (ftnlen)10, (
	    ftnlen)80);
    tcase_("Examine the exception produced by PXFORM", (ftnlen)40);
    et = -1e8;
    pxform_("SPUD", "SPAM", &et, xform, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_true, "SPICE(UNKNOWNFRAME)", ok, (ftnlen)19);
    tcase_("Make sure that a sample of inertial frame transformations behave"
	    " as expected. ", (ftnlen)78);
    for (i__ = 1; i__ <= 18; ++i__) {
	for (j = 1; j <= 18; ++j) {
	    idi = i__;
	    idj = j;
	    s_copy(namei, " ", (ftnlen)32, (ftnlen)1);
	    s_copy(namej, " ", (ftnlen)32, (ftnlen)1);
	    irfnam_(&idi, namei, (ftnlen)32);
	    irfnam_(&idj, namej, (ftnlen)32);
	    tstmsg_("#", "Frames: #, # ", (ftnlen)1, (ftnlen)13);
	    tstmsc_(namei, (ftnlen)32);
	    tstmsc_(namej, (ftnlen)32);
	    pxform_(namei, namej, &et, xform, (ftnlen)32, (ftnlen)32);
	    irfrot_(&idi, &idj, rot);
	    for (k = 1; k <= 3; ++k) {
		for (l = 1; l <= 3; ++l) {
		    eform[(i__1 = k + l * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
			    s_rnge("eform", i__1, "f_pxform__", (ftnlen)238)] 
			    = rot[(i__2 = k + l * 3 - 4) < 9 && 0 <= i__2 ? 
			    i__2 : s_rnge("rot", i__2, "f_pxform__", (ftnlen)
			    238)];
		}
	    }
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("XFORM", xform, "~", eform, &c__9, &c_b92, ok, (ftnlen)5, 
		    (ftnlen)1);
	}
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that the PCK frames are recognized ", (ftnlen)45);
    s_copy(name__, "IAU_MERCURY", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 32, "IAU_VENUS", (ftnlen)32, (ftnlen)9);
    s_copy(name__ + 64, "IAU_EARTH", (ftnlen)32, (ftnlen)9);
    s_copy(name__ + 96, "IAU_MARS", (ftnlen)32, (ftnlen)8);
    s_copy(name__ + 128, "IAU_JUPITER", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 160, "IAU_SATURN", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 192, "IAU_URANUS", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 224, "IAU_NEPTUNE", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 256, "IAU_PLUTO", (ftnlen)32, (ftnlen)9);
    s_copy(name__ + 288, "IAU_MOON", (ftnlen)32, (ftnlen)8);
    s_copy(name__ + 320, "IAU_PHOBOS", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 352, "IAU_DEIMOS", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 384, "IAU_IO", (ftnlen)32, (ftnlen)6);
    s_copy(name__ + 416, "IAU_EUROPA", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 448, "IAU_GANYMEDE", (ftnlen)32, (ftnlen)12);
    s_copy(name__ + 480, "IAU_CALLISTO", (ftnlen)32, (ftnlen)12);
    s_copy(name__ + 512, "IAU_ARIEL", (ftnlen)32, (ftnlen)9);
    s_copy(name__ + 544, "IAU_OBERON", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 576, "IAU_MIRANDA", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 608, "IAU_UMBRIEL", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 640, "IAU_TITANIA", (ftnlen)32, (ftnlen)11);
    s_copy(name__ + 672, "IAU_TITAN", (ftnlen)32, (ftnlen)9);
    s_copy(name__ + 704, "IAU_TRITON", (ftnlen)32, (ftnlen)10);
    s_copy(name__ + 736, "IAU_CHARON", (ftnlen)32, (ftnlen)10);
    idcode[0] = 199;
    idcode[1] = 299;
    idcode[2] = 399;
    idcode[3] = 499;
    idcode[4] = 599;
    idcode[5] = 699;
    idcode[6] = 799;
    idcode[7] = 899;
    idcode[8] = 999;
    idcode[9] = 301;
    idcode[10] = 401;
    idcode[11] = 402;
    idcode[12] = 501;
    idcode[13] = 502;
    idcode[14] = 503;
    idcode[15] = 504;
    idcode[16] = 701;
    idcode[17] = 704;
    idcode[18] = 705;
    idcode[19] = 702;
    idcode[20] = 703;
    idcode[21] = 606;
    idcode[22] = 801;
    idcode[23] = 901;
    for (i__ = 1; i__ <= 24; ++i__) {
	tstmsg_("#", "Body: # ", (ftnlen)1, (ftnlen)8);
	tstmsc_(name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"name", i__1, "f_pxform__", (ftnlen)308)) << 5), (ftnlen)32);
	pxform_("J2000", name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 
		: s_rnge("name", i__1, "f_pxform__", (ftnlen)311)) << 5), &et,
		 xform, (ftnlen)5, (ftnlen)32);
	tipbod_("J2000", &idcode[(i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : 
		s_rnge("idcode", i__1, "f_pxform__", (ftnlen)312)], &et, 
		tsipm, (ftnlen)5);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("XFORM", xform, "~", tsipm, &c__9, &c_b92, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure the transformation from bodyfixed to J2000 works. ", (
	    ftnlen)60);
    for (i__ = 1; i__ <= 24; ++i__) {
	tstmsg_("#", "Body: # ", (ftnlen)1, (ftnlen)8);
	tstmsc_(name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"name", i__1, "f_pxform__", (ftnlen)327)) << 5), (ftnlen)32);
	pxform_(name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"name", i__1, "f_pxform__", (ftnlen)329)) << 5), "J2000", &et,
		 xform, (ftnlen)32, (ftnlen)5);
	tipbod_("J2000", &idcode[(i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : 
		s_rnge("idcode", i__1, "f_pxform__", (ftnlen)330)], &et, 
		tsipm, (ftnlen)5);
	xpose_(tsipm, tmpmat);
	moved_(tmpmat, &c__9, tsipm);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("XFORM", xform, "~", tsipm, &c__9, &c_b92, ok, (ftnlen)5, (
		ftnlen)1);
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure that we can tranform from one bodyfixed frame to anoth"
	    "er. ", (ftnlen)68);
    for (i__ = 1; i__ <= 24; ++i__) {
	for (j = 1; j <= 24; ++j) {
	    tstmsg_("#", "Body  # to Body #", (ftnlen)1, (ftnlen)17);
	    tstmsc_(name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : 
		    s_rnge("name", i__1, "f_pxform__", (ftnlen)348)) << 5), (
		    ftnlen)32);
	    tstmsc_(name__ + (((i__1 = j - 1) < 24 && 0 <= i__1 ? i__1 : 
		    s_rnge("name", i__1, "f_pxform__", (ftnlen)349)) << 5), (
		    ftnlen)32);
	    tipbod_("J2000", &idcode[(i__1 = i__ - 1) < 24 && 0 <= i__1 ? 
		    i__1 : s_rnge("idcode", i__1, "f_pxform__", (ftnlen)351)],
		     &et, tspmi, (ftnlen)5);
	    xpose_(tspmi, tmpmat);
	    moved_(tmpmat, &c__9, tspmi);
	    tipbod_("J2000", &idcode[(i__1 = j - 1) < 24 && 0 <= i__1 ? i__1 :
		     s_rnge("idcode", i__1, "f_pxform__", (ftnlen)355)], &et, 
		    tsipm, (ftnlen)5);
	    mxm_(tsipm, tspmi, eform);
	    pxform_(name__ + (((i__1 = i__ - 1) < 24 && 0 <= i__1 ? i__1 : 
		    s_rnge("name", i__1, "f_pxform__", (ftnlen)359)) << 5), 
		    name__ + (((i__2 = j - 1) < 24 && 0 <= i__2 ? i__2 : 
		    s_rnge("name", i__2, "f_pxform__", (ftnlen)359)) << 5), &
		    et, xform, (ftnlen)32, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("XFORM", xform, "~", eform, &c__9, &c_b92, ok, (ftnlen)5, 
		    (ftnlen)1);
	}
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Make sure a long tranformation chain is properly computed. ", (
	    ftnlen)59);
    namfrm_("TOPOCENTRIC", &topo, (ftnlen)11);
    namfrm_("TST-PHOENIX", &phnx, (ftnlen)11);
    pxform_("TOPOCENTRIC", "TST-PHOENIX", &et, xform, (ftnlen)11, (ftnlen)11);
    refchg_(&topo, &phnx, &et, eform);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("XFORM", xform, "=", eform, &c__9, &c_b194, ok, (ftnlen)5, (
	    ftnlen)1);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    ckupf_(&handle);
    clpool_();
    kilfil_("phoenix.bc", (ftnlen)10);
    t_success__(ok);
    return 0;
} /* f_pxform__ */

