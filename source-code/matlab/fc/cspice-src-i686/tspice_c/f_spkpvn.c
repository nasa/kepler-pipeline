/* f_spkpvn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__6 = 6;
static doublereal c_b50 = 1e-13;
static integer c__301 = 301;

/* $Procedure      F_SPKPVN ( Family of routine tests for SPKPVN ) */
/* Subroutine */ int f_spkpvn__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    char ch__1[12];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer body[14];
    extern /* Subroutine */ int mxvg_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *);
    integer i__, ckhan, frame;
    extern /* Subroutine */ int cklpf_(char *, integer *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char ident[40];
    extern /* Subroutine */ int ckupf_(integer *);
    logical found;
    doublereal state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal xform[36]	/* was [6][6] */;
    extern /* Subroutine */ int spkpv_(integer *, doublereal *, doublereal *, 
	    char *, doublereal *, integer *, ftnlen), t_success__(logical *), 
	    tstst_(integer *, doublereal *, char *, integer *, doublereal *, 
	    integer *, doublereal *, ftnlen), tstck3_(char *, char *, logical 
	    *, logical *, logical *, integer *, ftnlen, ftnlen), chckad_(char 
	    *, doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal gm;
    extern /* Character */ VOID begdat_(char *, ftnlen);
    doublereal et;
    integer handle, eframe;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), frmchg_(integer *, integer *, doublereal *, 
	    doublereal *), chcksl_(char *, logical *, logical *, logical *, 
	    ftnlen);
    char buffer[80*20];
    integer oframe;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    integer ecentr, center;
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen);
    doublereal cstate[6];
    integer spkhan;
    doublereal estate[6];
    integer nlines;
    extern /* Subroutine */ int clpool_(void), spkuef_(integer *);
    char thsfrm[32*5];
    extern /* Subroutine */ int tstpck_(char *, logical *, logical *, ftnlen),
	     spksfs_(integer *, doublereal *, integer *, doublereal *, char *,
	     logical *, ftnlen), spkpvn_(integer *, doublereal *, doublereal *
	    , integer *, doublereal *, integer *), tstspk_(char *, logical *, 
	    integer *, ftnlen), tsttxt_(char *, char *, integer *, logical *, 
	    logical *, ftnlen, ftnlen);
    integer nframes;

/* $ Abstract */

/*     Exercise the various aspects of SPKPVN to make sure everything */
/*     is working as planned. */

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

    topen_("F_SPKPVN", (ftnlen)8);

/*     Create a test kernels for use with this test family. */

    s_copy(buffer, " ", (ftnlen)80, (ftnlen)1);
    s_copy(buffer + 80, "This is a test frame kernel for use in testing vari"
	    "ous ", (ftnlen)80, (ftnlen)55);
    s_copy(buffer + 160, "aspects of the SPK system.  It is intended for tes"
	    "ting ", (ftnlen)80, (ftnlen)55);
    s_copy(buffer + 240, "purposes only. ", (ftnlen)80, (ftnlen)15);
    s_copy(buffer + 320, " ", (ftnlen)80, (ftnlen)1);
    begdat_(ch__1, (ftnlen)12);
    s_copy(buffer + 400, ch__1, (ftnlen)80, (ftnlen)12);
    s_copy(buffer + 480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(buffer + 560, "FRAME_-9999_CLASS      =  3 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(buffer + 640, "FRAME_-9999_CENTER     = -9 ", (ftnlen)80, (ftnlen)
	    28);
    s_copy(buffer + 720, "FRAME_-9999_CLASS_ID   = -9999 ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(buffer + 800, "FRAME_-9999_NAME       = 'PHOENIX' ", (ftnlen)80, (
	    ftnlen)35);
    s_copy(buffer + 880, "FRAME_PHOENIX          = -9999 ", (ftnlen)80, (
	    ftnlen)31);
    s_copy(buffer + 960, " ", (ftnlen)80, (ftnlen)1);
    nlines = 13;
    clpool_();
    kilfil_("test_pck.ker", (ftnlen)12);
    tsttxt_("frames.ker", buffer, &nlines, &c_true, &c_false, (ftnlen)10, (
	    ftnlen)80);
    tstspk_("test_spk.bsp", &c_true, &spkhan, (ftnlen)12);
    tstpck_("test_pck.ker", &c_true, &c_false, (ftnlen)12);
    tstck3_("test_ck.bc", "test_sclk.ker", &c_false, &c_true, &c_false, &
	    ckhan, (ftnlen)10, (ftnlen)13);
    cklpf_("test_ck.bc", &ckhan, (ftnlen)10);
    tcase_("Make sure that we can get the recorded states that are written f"
	    "rom TSTSPK. ", (ftnlen)76);
    body[0] = 1;
    body[1] = 2;
    body[2] = 3;
    body[3] = 4;
    body[4] = 5;
    body[5] = 6;
    body[6] = 7;
    body[7] = 8;
    body[8] = 9;
    body[9] = 301;
    body[10] = 401;
    body[11] = 501;
    body[12] = -9;
    body[13] = 399001;
    et = -1e7;
    for (i__ = 1; i__ <= 14; ++i__) {

/*           Fetch a predicted state from the test SPK file generator. */

	tstst_(&body[(i__1 = i__ - 1) < 14 && 0 <= i__1 ? i__1 : s_rnge("body"
		, i__1, "f_spkpvn__", (ftnlen)148)], &et, ident, &eframe, 
		estate, &ecentr, &gm, (ftnlen)40);
	spksfs_(&body[(i__1 = i__ - 1) < 14 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_spkpvn__", (ftnlen)149)], &et, &handle, 
		descr, ident, &found, (ftnlen)40);
	if (! found) {
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	} else {
	    spkpvn_(&handle, descr, &et, &frame, state, &center);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksi_("CENTER", &center, "=", &ecentr, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	    chcksi_("FRAME", &frame, "=", &eframe, &c__0, ok, (ftnlen)5, (
		    ftnlen)1);
	    chckad_("STATE", state, "~", estate, &c__6, &c_b50, ok, (ftnlen)5,
		     (ftnlen)1);
	}
    }
    tcase_("Examine the results of SPKPV to make sure that they are compatib"
	    "le with what is expected using the states returned by TSTST ", (
	    ftnlen)124);
    s_copy(thsfrm, "J2000", (ftnlen)32, (ftnlen)5);
    s_copy(thsfrm + 32, "B1950", (ftnlen)32, (ftnlen)5);
    s_copy(thsfrm + 64, "J2000", (ftnlen)32, (ftnlen)5);
    s_copy(thsfrm + 96, "IAU_EARTH", (ftnlen)32, (ftnlen)9);
    s_copy(thsfrm + 128, "PHOENIX", (ftnlen)32, (ftnlen)7);
    nframes = 5;
    tstst_(&c__301, &et, ident, &eframe, estate, &ecentr, &gm, (ftnlen)40);
    spksfs_(&c__301, &et, &handle, descr, ident, &found, (ftnlen)40);
    if (! found) {
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    } else {
	i__1 = nframes;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    namfrm_(thsfrm + (((i__2 = i__ - 1) < 5 && 0 <= i__2 ? i__2 : 
		    s_rnge("thsfrm", i__2, "f_spkpvn__", (ftnlen)196)) << 5), 
		    &oframe, (ftnlen)32);
	    frmchg_(&eframe, &oframe, &et, xform);
	    mxvg_(xform, estate, &c__6, &c__6, cstate);
	    spkpv_(&handle, descr, &et, thsfrm + (((i__2 = i__ - 1) < 5 && 0 
		    <= i__2 ? i__2 : s_rnge("thsfrm", i__2, "f_spkpvn__", (
		    ftnlen)202)) << 5), state, &center, (ftnlen)32);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksi_("CENTER", &center, "=", &ecentr, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	    chckad_("STATE", state, "~", cstate, &c__6, &c_b50, ok, (ftnlen)5,
		     (ftnlen)1);
	}
    }

/*     That's it.  Unload the SPK and CK files. */

    spkuef_(&spkhan);
    ckupf_(&ckhan);
    kilfil_("test_spk.bsp", (ftnlen)12);
    kilfil_("test_ck.bc", (ftnlen)10);
    t_success__(ok);
    return 0;
} /* f_spkpvn__ */

