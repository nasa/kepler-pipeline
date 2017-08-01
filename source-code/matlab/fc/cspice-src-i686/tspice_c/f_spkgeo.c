/* f_spkgeo.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c_n10 = -10;
static integer c__399 = 399;
static integer c__301 = 301;
static integer c__6 = 6;
static doublereal c_b81 = 1e-10;
static integer c__499 = 499;
static integer c_n9 = -9;
static integer c__401 = 401;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c_b171 = 401001;
static integer c_b173 = 301001;
static integer c__0 = 0;
static doublereal c_b197 = 0.;
static integer c__46 = 46;

/* $Procedure      F_SPKGEO ( Family of tests for SPKGEO ) */
/* Subroutine */ int f_spkgeo__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    char ch__1[40];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer iaue, targ;
    extern /* Subroutine */ int mxvg_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *), spkgeo_o__(integer *, doublereal *, 
	    char *, integer *, doublereal *, doublereal *, ftnlen), 
	    spkgeo_s__(integer *, doublereal *, char *, integer *, doublereal 
	    *, doublereal *, ftnlen);
    integer j, k, ckhan;
    extern /* Subroutine */ int vaddg_(doublereal *, doublereal *, integer *, 
	    doublereal *);
    integer refid;
    char segid[40];
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen), tcase_(
	    char *, ftnlen), ckupf_(integer *);
    char lines[80*46];
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *);
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen), vsubg_(doublereal *, 
	    doublereal *, integer *, doublereal *);
    char error[80];
    doublereal xform[36]	/* was [6][6] */, tsipm[36]	/* was [6][6] 
	    */;
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int t_success__(logical *), tstst_(integer *, 
	    doublereal *, char *, integer *, doublereal *, integer *, 
	    doublereal *, ftnlen);
    doublereal state1[6], state2[6], state3[6], state4[6], state5[6], iaust1[
	    6], iaust2[6], iaust3[6], iaust4[6], iaust5[6], iaust6[6], iaust7[
	    6], state6[6], state7[6], xform1[36]	/* was [6][6] */, 
	    xform2[36]	/* was [6][6] */, xform3[36]	/* was [6][6] */, 
	    xform4[36]	/* was [6][6] */, xform5[36]	/* was [6][6] */, gm, 
	    xform6[36]	/* was [6][6] */;
    extern /* Character */ VOID begdat_(char *, ftnlen);
    integer idcode[46];
    doublereal xform7[36]	/* was [6][6] */, et;
    extern /* Subroutine */ int tstck3_(char *, char *, logical *, logical *, 
	    logical *, integer *, ftnlen, ftnlen), chckad_(char *, doublereal 
	    *, char *, doublereal *, integer *, doublereal *, logical *, 
	    ftnlen, ftnlen), cleard_(integer *, doublereal *), chcksd_(char *,
	     doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     frmchg_(integer *, integer *, doublereal *, doublereal *);
    extern doublereal clight_(void);
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    integer center;
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen), frmnam_(
	    integer *, char *, ftnlen);
    integer spkhan;
    extern /* Subroutine */ int tisbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), spkgeo_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    extern /* Subroutine */ int tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), spkuef_(integer *);
    doublereal tstate[6];
    extern /* Subroutine */ int spkssb_(integer *, doublereal *, char *, 
	    doublereal *, ftnlen), tstpck_(char *, logical *, logical *, 
	    ftnlen), tstmsd_(doublereal *), tstmsc_(char *, ftnlen), sxform_(
	    char *, char *, doublereal *, doublereal *, ftnlen, ftnlen), 
	    tstmsg_(char *, char *, ftnlen, ftnlen);
    doublereal lt2, stxfrm[36]	/* was [6][6] */;
    extern /* Subroutine */ int tstmsi_(integer *), tstspk_(char *, logical *,
	     integer *, ftnlen), tsttxt_(char *, char *, integer *, logical *,
	     logical *, ftnlen, ftnlen);
    char ref[32];
    integer obs, ref1, ref2, ref3, ref4, ref5, ref6, ref7;

/* $ Abstract */

/*     This routine tests the behaviour of the SPICE routine SPKGEO */
/*     with the addition of non-inertial frames. */

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

/* -    TSPICE Version 2.0.0, 10-NOV-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VADDG calls. */

/* -& */

/*     Spicelib Routines. */


/*     Local Variables */

    begtxt_(ch__1, (ftnlen)40);
    s_copy(lines, ch__1, (ftnlen)80, (ftnlen)40);
    s_copy(lines + 80, "This PCK file contains definitions for TOPOGRAPHIC r"
	    "eference", (ftnlen)80, (ftnlen)60);
    s_copy(lines + 160, "frames at 3 different observatories around the worl"
	    "d.  Note", (ftnlen)80, (ftnlen)59);
    s_copy(lines + 240, "that the definition of these frames is approximate "
	    "and that", (ftnlen)80, (ftnlen)59);
    s_copy(lines + 320, "they are accurate to only about 0.1 degrees.", (
	    ftnlen)80, (ftnlen)44);
    s_copy(lines + 400, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)40);
    s_copy(lines + 480, ch__1, (ftnlen)80, (ftnlen)40);
    s_copy(lines + 560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 640, "FRAME_CANBERRA_TOPO    = 1000002", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 720, "FRAME_MADRID_TOPO      = 1000019", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 800, "FRAME_GOLDSTONE_TOPO   = 1000023", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 880, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 960, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1040, "FRAME_1000002_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 1120, "FRAME_1000002_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 1200, "FRAME_1000002_CLASS_ID = 1000002", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1280, "FRAME_1000002_NAME     = 'CANBERRA_TOPO'", (ftnlen)
	    80, (ftnlen)40);
    s_copy(lines + 1360, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1440, "FRAME_1000019_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 1520, "FRAME_1000019_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 1600, "FRAME_1000019_CLASS_ID = 1000019", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 1680, "FRAME_1000019_NAME     = 'MADRID_TOPO'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 1760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 1840, "FRAME_1000023_CENTER   =  399", (ftnlen)80, (ftnlen)
	    29);
    s_copy(lines + 1920, "FRAME_1000023_CLASS    =  4", (ftnlen)80, (ftnlen)
	    27);
    s_copy(lines + 2000, "FRAME_1000023_CLASS_ID = 1000023", (ftnlen)80, (
	    ftnlen)32);
    s_copy(lines + 2080, "FRAME_1000023_NAME     = 'GOLDSTONE_TOPO'", (ftnlen)
	    80, (ftnlen)41);
    s_copy(lines + 2160, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2240, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2320, "TKFRAME_1000002_ANGLES   = ( -149.0, -125.3, 180 )",
	     (ftnlen)80, (ftnlen)50);
    s_copy(lines + 2400, "TKFRAME_1000002_AXES     = (       3,        2,   "
	    "3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 2480, "TKFRAME_1000002_RELATIVE = 'IAU_EARTH'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 2560, "TKFRAME_1000002_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 2640, "TKFRAME_1000002_UNITS    = 'DEGREES'", (ftnlen)80, (
	    ftnlen)36);
    s_copy(lines + 2720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 2800, "TKFRAME_1000019_ANGLES   = ( 03.7, -49.6, 180 )", (
	    ftnlen)80, (ftnlen)47);
    s_copy(lines + 2880, "TKFRAME_1000019_AXES     = (       3,        2,   "
	    "3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 2960, "TKFRAME_1000019_RELATIVE = 'IAU_EARTH'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 3040, "TKFRAME_1000019_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3120, "TKFRAME_1000019_UNITS    = 'DEGREES'", (ftnlen)80, (
	    ftnlen)36);
    s_copy(lines + 3200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(lines + 3280, "TKFRAME_1000023_ANGLES   = ( 116.8, -54.6, 180 )", (
	    ftnlen)80, (ftnlen)48);
    s_copy(lines + 3360, "TKFRAME_1000023_AXES     = (       3,        2,   "
	    "3 )", (ftnlen)80, (ftnlen)53);
    s_copy(lines + 3440, "TKFRAME_1000023_RELATIVE = 'IAU_EARTH'", (ftnlen)80,
	     (ftnlen)38);
    s_copy(lines + 3520, "TKFRAME_1000023_SPEC     = 'ANGLES'", (ftnlen)80, (
	    ftnlen)35);
    s_copy(lines + 3600, "TKFRAME_1000023_UNITS    = 'DEGREES'", (ftnlen)80, (
	    ftnlen)36);

/*     Begin every test family with an open call. */

    topen_("F_SPKGEO", (ftnlen)8);

/*     Set up the data needed for testing. */

    kilfil_("test_pck.ker", (ftnlen)12);
    tstpck_("test_pck.ker", &c_true, &c_false, (ftnlen)12);
    tstck3_("phoenix.bc", "phoenix.tsc", &c_false, &c_true, &c_false, &ckhan, 
	    (ftnlen)10, (ftnlen)11);
    cklpf_("phoenix.bc", &ckhan, (ftnlen)10);
    tstspk_("test_spk.bsp", &c_true, &spkhan, (ftnlen)12);
    idcode[0] = 1;
    idcode[1] = 2;
    idcode[2] = 3;
    idcode[3] = 4;
    idcode[4] = 5;
    idcode[5] = 6;
    idcode[6] = 7;
    idcode[7] = 8;
    idcode[8] = 9;
    idcode[9] = 301;
    idcode[10] = 401;
    idcode[11] = 402;
    idcode[12] = 501;
    idcode[13] = 502;
    idcode[14] = 503;
    idcode[15] = 504;
    idcode[16] = 603;
    idcode[17] = 604;
    idcode[18] = 605;
    idcode[19] = 606;
    idcode[20] = 607;
    idcode[21] = 608;
    idcode[22] = 701;
    idcode[23] = 702;
    idcode[24] = 703;
    idcode[25] = 704;
    idcode[26] = 705;
    idcode[27] = 801;
    idcode[28] = 802;
    idcode[29] = 901;
    idcode[30] = 199;
    idcode[31] = 299;
    idcode[32] = 399;
    idcode[33] = 499;
    idcode[34] = 599;
    idcode[35] = 699;
    idcode[36] = 799;
    idcode[37] = 899;
    idcode[38] = 999;
    idcode[39] = 10;
    idcode[40] = 399001;
    idcode[41] = 399002;
    idcode[42] = 399003;
    idcode[43] = -9;
    idcode[44] = 401001;
    idcode[45] = 301001;
    et = 0.;
    tcase_("Check that exceptions behave as expected.", (ftnlen)41);
    spkgeo_(&c_n10, &et, "J2000", &c__399, state, &lt, (ftnlen)5);
    chckxc_(&c_true, "SPICE(SPKINSUFFDATA)", ok, (ftnlen)20);
    tcase_("Get the state of the moon in the earth bodyfixed frame and compa"
	    "re it to the old fashioned way of computing this. ", (ftnlen)114);
    spkgeo_(&c__301, &et, "IAU_EARTH", &c__399, state, &lt, (ftnlen)9);
    spkgeo_o__(&c__301, &et, "J2000", &c__399, state1, &lt2, (ftnlen)5);
    tisbod_("J2000", &c__399, &et, tsipm, (ftnlen)5);
    mxvg_(tsipm, state1, &c__6, &c__6, state2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b81, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &lt2, &c_b81, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Get the state of the moon relative to the earth in the mars body"
	    "fixed frame and compare it to the old fashioned way of computing"
	    " this. ", (ftnlen)135);
    spkgeo_(&c__301, &et, "IAU_MARS", &c__399, state, &lt, (ftnlen)8);
    spkgeo_o__(&c__301, &et, "J2000", &c__399, state1, &lt2, (ftnlen)5);
    tisbod_("J2000", &c__499, &et, xform, (ftnlen)5);
    mxvg_(xform, state1, &c__6, &c__6, state2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b81, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &lt2, &c_b81, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Compute the state of body -9 relative to 401 in the IAU_EARTH fr"
	    "ame using SPKGEO and computed via TSTST. ", (ftnlen)105);
    spkgeo_(&c_n9, &et, "IAU_EARTH", &c__401, state, &lt, (ftnlen)9);
    namfrm_("IAU_EARTH", &iaue, (ftnlen)9);
    tstst_(&c_n9, &et, segid, &ref1, state1, &center, &gm, (ftnlen)40);
    tstst_(&c__301, &et, segid, &ref2, state2, &center, &gm, (ftnlen)40);
    tstst_(&c__399, &et, segid, &ref3, state3, &center, &gm, (ftnlen)40);
    tstst_(&c__3, &et, segid, &ref4, state4, &center, &gm, (ftnlen)40);
    tstst_(&c__401, &et, segid, &ref5, state5, &center, &gm, (ftnlen)40);
    tstst_(&c__499, &et, segid, &ref6, state6, &center, &gm, (ftnlen)40);
    tstst_(&c__4, &et, segid, &ref7, state7, &center, &gm, (ftnlen)40);
    frmchg_(&ref1, &iaue, &et, xform1);
    frmchg_(&ref2, &iaue, &et, xform2);
    frmchg_(&ref3, &iaue, &et, xform3);
    frmchg_(&ref4, &iaue, &et, xform4);
    frmchg_(&ref5, &iaue, &et, xform5);
    frmchg_(&ref6, &iaue, &et, xform6);
    frmchg_(&ref7, &iaue, &et, xform7);
    mxvg_(xform1, state1, &c__6, &c__6, iaust1);
    mxvg_(xform2, state2, &c__6, &c__6, iaust2);
    mxvg_(xform3, state3, &c__6, &c__6, iaust3);
    mxvg_(xform4, state4, &c__6, &c__6, iaust4);
    mxvg_(xform5, state5, &c__6, &c__6, iaust5);
    mxvg_(xform6, state6, &c__6, &c__6, iaust6);
    mxvg_(xform7, state7, &c__6, &c__6, iaust7);
    cleard_(&c__6, state1);
    cleard_(&c__6, state2);
    vaddg_(state1, iaust1, &c__6, tstate);
    vaddg_(tstate, iaust2, &c__6, state1);
    vaddg_(state1, iaust3, &c__6, tstate);
    vaddg_(tstate, iaust4, &c__6, state1);
    vaddg_(state2, iaust5, &c__6, tstate);
    vaddg_(tstate, iaust6, &c__6, state2);
    vaddg_(state2, iaust7, &c__6, tstate);
    moved_(tstate, &c__6, state2);
    vsubg_(state1, state2, &c__6, state3);
    lt2 = vnorm_(state3) / clight_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state3, &c__6, &c_b81, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &lt2, &c_b81, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Compare states as generated with the old version of SPKGEO with "
	    "the current version. This case uses a long ephemeris and a large"
	    " variety of observer-target pairs.", (ftnlen)162);

/*        This routine tests determines the states of every object */
/*        in a pair of SPK files with every other object in every */
/*        available inertial reference frame. */

/*        This test is probably overkill, but is intended to demonstrate */
/*        that under normal circumstances, nothing has changed in the */
/*        latest upgrade of the SPK system. */

    tparse_("1 JAN 1995", &et, error, (ftnlen)10, (ftnlen)80);
    for (refid = 1; refid <= 18; refid += 5) {
	frmnam_(&refid, ref, (ftnlen)32);
	for (j = 1; j <= 46; j += 10) {
	    for (k = 46; k >= 1; k += -3) {
		tstmsg_("#", "ET: #, Frame: #, Target: #, Observer: #. ", (
			ftnlen)1, (ftnlen)41);
		targ = idcode[(i__1 = j - 1) < 46 && 0 <= i__1 ? i__1 : 
			s_rnge("idcode", i__1, "f_spkgeo__", (ftnlen)380)];
		obs = idcode[(i__1 = k - 1) < 46 && 0 <= i__1 ? i__1 : s_rnge(
			"idcode", i__1, "f_spkgeo__", (ftnlen)381)];
		tstmsd_(&et);
		tstmsc_(ref, (ftnlen)32);
		tstmsi_(&targ);
		tstmsi_(&obs);
		spkgeo_(&targ, &et, ref, &obs, state, &lt, (ftnlen)32);
		spkgeo_o__(&targ, &et, ref, &obs, state2, &lt2, (ftnlen)32);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chckad_("STATE", state, "~/", state2, &c__6, &c_b81, ok, (
			ftnlen)5, (ftnlen)2);
		chcksd_("LT", &lt, "~/", &lt2, &c_b81, ok, (ftnlen)2, (ftnlen)
			2);
	    }
	}
    }
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    tcase_("Check to make sure that the logic that handles long chains of ta"
	    "rget center pairs functions as expected. ", (ftnlen)105);
    spkgeo_(&c_b171, &et, "IAU_EARTH", &c_b173, state, &lt, (ftnlen)9);
    spkgeo_s__(&c_b171, &et, "IAU_EARTH", &c_b173, state2, &lt2, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b81, ok, (ftnlen)5, (
	    ftnlen)2);
    chcksd_("LT", &lt, "~/", &lt2, &c_b81, ok, (ftnlen)2, (ftnlen)2);
    tcase_("Check to make sure that SPKSSB returns the same state as SPKGEO "
	    "when the observer in SPKGEO is set to be the solar system baryce"
	    "nter ", (ftnlen)133);
    spkgeo_(&c__401, &et, "J2000", &c__0, state2, &lt, (ftnlen)5);
    spkssb_(&c__401, &et, "J2000", state, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", state2, &c__6, &c_b197, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Make sure we can get the state of an object relative to a topoce"
	    "ntric frame. ", (ftnlen)77);
    kilfil_("topo.txt", (ftnlen)8);
    tsttxt_("topo.txt", lines, &c__46, &c_true, &c_true, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkgeo_(&c_b171, &et, "IAU_EARTH", &c_b173, state, &lt, (ftnlen)9);
    sxform_("IAU_EARTH", "GOLDSTONE_TOPO", &et, stxfrm, (ftnlen)9, (ftnlen)14)
	    ;
    mxvg_(stxfrm, state, &c__6, &c__6, state2);
    spkgeo_(&c_b171, &et, "GOLDSTONE_TOPO", &c_b173, state, &lt, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "~/", state2, &c__6, &c_b81, ok, (ftnlen)5, (
	    ftnlen)2);

/*     That's all folks. */

    spkuef_(&spkhan);
    ckupf_(&ckhan);
    kilfil_("phoenix.bc", (ftnlen)10);
    kilfil_("test_spk.bsp", (ftnlen)12);
    kilfil_("topo.txt", (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_spkgeo__ */

