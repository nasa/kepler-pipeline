/* f_spk18.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__3 = 3;
static integer c__9 = 9;
static logical c_true = TRUE_;
static integer c__25 = 25;
static integer c__0 = 0;
static integer c__6 = 6;
static doublereal c_b100 = 1e-14;
static doublereal c_b116 = 10.;
static integer c_b161 = -10000;
static integer c__5 = 5;
static integer c__10101 = 10101;
static integer c__2 = 2;
static doublereal c_b297 = 0.;

/* $Procedure F_SPK18 ( SPK data type 18 tests ) */
/* Subroutine */ int f_spk18__(logical *ok)
{
    /* Initialized data */

    static doublereal dscepc[9] = { 100.,200.,300.,400.,500.,600.,700.,800.,
	    900. };
    static doublereal dscsts[54]	/* was [6][9] */ = { 101.,201.,301.,
	    401.,501.,601.,102.,202.,302.,402.,502.,602.,103.,203.,303.,403.,
	    503.,603.,104.,204.,304.,404.,504.,604.,105.,205.,305.,405.,505.,
	    605.,106.,206.,306.,406.,506.,606.,107.,207.,307.,407.,507.,607.,
	    108.,208.,308.,408.,508.,608.,109.,209.,309.,409.,509.,609. };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer newh;
    char xref[32];
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal step;
    integer i__, j;
    extern /* Subroutine */ int dafgn_(char *, ftnlen), dafgs_(doublereal *);
    char segid[60];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *), moved_(doublereal *, integer *, 
	    doublereal *);
    logical found;
    extern /* Subroutine */ int vsclg_(doublereal *, doublereal *, integer *, 
	    doublereal *);
    doublereal state[6];
    integer xbody;
    extern /* Subroutine */ int topen_(char *, ftnlen), spkw18_(integer *, 
	    integer *, integer *, integer *, char *, doublereal *, doublereal 
	    *, char *, integer *, integer *, doublereal *, doublereal *, 
	    ftnlen, ftnlen), t_success__(logical *);
    char segid2[60];
    doublereal dc[2], bt0lst[121212]	/* was [12][10101] */, bt1lst[60606]	
	    /* was [6][10101] */;
    integer ic[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     daffna_(logical *), dafbfs_(integer *);
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *);
    doublereal lt;
    extern /* Subroutine */ int delfil_(char *, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal dscpak[108]	/* was [12][9] */;
    extern /* Subroutine */ int dafopr_(char *, integer *, ftnlen), spklef_(
	    char *, integer *, ftnlen);
    doublereal beplst[10101];
    extern /* Subroutine */ int spkgeo_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen), spkuef_(integer *)
	    , spkcls_(integer *);
    integer xcentr;
    extern /* Subroutine */ int spksub_(integer *, doublereal *, char *, 
	    doublereal *, doublereal *, integer *, ftnlen);
    doublereal xstate[6];
    extern /* Subroutine */ int spkopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen);
    extern logical exists_(char *, ftnlen);

/* $ Abstract */

/*     Exercise routines associated with SPK data type 18. */

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

/*     Declare parameters specific to SPK type 18. */

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

/*     SPK */

/* $ Keywords */

/*     SPK */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 18-AUG-2002 (NJB) */

/* -& */

/*     SPK type 18 subtype codes: */


/*     Subtype 0:  Hermite interpolation, 12-element packets, order */
/*                 reduction at boundaries to preceding number */
/*                 equivalent to 3 mod 4. */


/*     Subtype 1:  Lagrange interpolation, 6-element packets, order */
/*                 reduction at boundaries to preceding odd number. */


/*     Packet sizes associated with the various subtypes: */


/*     End of include file spk18.inc. */

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

/*     This routine tests routines that write and read type 18 SPK */
/*     data. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 07-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Epochs and states: */


/*     Open the test family. */

    topen_("F_SPK18", (ftnlen)7);

/*     Test SPKW18:  start out with error handling. */


/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: bad frame name.", (ftnlen)34);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 18 test segment", (ftnlen)60, (ftnlen)24);

/*     Open a new SPK file. */

    if (exists_("test18err.bsp", (ftnlen)13)) {
	delfil_("test18err.bsp", (ftnlen)13);
    }
    spkopn_("test18err.bsp", "Type 18 SPK internal file name", &c__4, &handle,
	     (ftnlen)13, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    step = dscepc[1] - dscepc[0];
    spkw18_(&handle, &c__1, &xbody, &xcentr, "SPUD", dscepc, &dscepc[8], 
	    segid, &c__3, &c__9, dscsts, dscepc, (ftnlen)4, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: SEGID too long.", (ftnlen)34);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], "X   "
	    "                                            X", &c__3, &c__9, 
	    dscsts, dscepc, (ftnlen)32, (ftnlen)49);
    chckxc_(&c_true, "SPICE(SEGIDTOOLONG)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: unprintable SEGID characters.", (ftnlen)48);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], "\a", &
	    c__3, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)1);
    chckxc_(&c_true, "SPICE(NONPRINTABLECHARS)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: polynomial degree too high.", (ftnlen)46);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], segid, 
	    &c__25, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INVALIDDEGREE)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: polynomial degree too low.", (ftnlen)45);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], segid, 
	    &c__0, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INVALIDDEGREE)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case:  odd window size.", (ftnlen)36);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], segid, 
	    &c__4, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INVALIDDEGREE)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: too few states", (ftnlen)33);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, dscepc, segid, &
	    c__3, &c__0, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(TOOFEWSTATES)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: descriptor times swapped.", (ftnlen)44);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, &dscepc[8], dscepc, segid, 
	    &c__3, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: descriptor start time is too early.", (ftnlen)
	    54);
    d__1 = dscepc[0] - 1.;
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, &d__1, &dscepc[8], segid, &
	    c__3, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 error case: descriptor end time is too late.", (ftnlen)51);
    d__1 = dscepc[8] + 1.;
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &d__1, segid, &
	    c__3, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);

/*     Close the SPK file at the DAF level; SPKCLS won't close */
/*     a file without segments. */

    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Enough with the error cases; write a segment already. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Create a type 18 subtype 1 segment.", (ftnlen)35);
    spkopn_("sp18t1.bsp", "Type 18 SPK internal file name", &c__4, &handle, (
	    ftnlen)10, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkw18_(&handle, &c__1, &xbody, &xcentr, xref, dscepc, &dscepc[8], segid, 
	    &c__3, &c__9, dscsts, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load the SPK file. */

    spklef_("sp18t1.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 1; i__ <= 9; ++i__) {
	spkgeo_(&xbody, &dscepc[(i__1 = i__ - 1) < 9 && 0 <= i__1 ? i__1 : 
		s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)564)], xref, &
		xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("type 18 state", state, "~", &dscsts[(i__1 = i__ * 6 - 6) < 
		54 && 0 <= i__1 ? i__1 : s_rnge("dscsts", i__1, "f_spk18__", (
		ftnlen)567)], &c__6, &c_b100, ok, (ftnlen)13, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Repeat this test using subtype 0. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Create a type 18 subtype 0 segment.", (ftnlen)35);
    spkopn_("sp18t0.bsp", "Type 18 SPK internal file name", &c__4, &handle, (
	    ftnlen)10, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fill in the packets using the discrete state set.  Make the */
/*     velocity/accleration data 10x the position/velocity data.  Note */
/*     that these two data sets are independent; realistic correspondence */
/*     between them is not required. */

    for (i__ = 1; i__ <= 9; ++i__) {
	moved_(&dscsts[(i__1 = i__ * 6 - 6) < 54 && 0 <= i__1 ? i__1 : s_rnge(
		"dscsts", i__1, "f_spk18__", (ftnlen)607)], &c__6, &dscpak[(
		i__2 = i__ * 12 - 12) < 108 && 0 <= i__2 ? i__2 : s_rnge(
		"dscpak", i__2, "f_spk18__", (ftnlen)607)]);
	vsclg_(&c_b116, &dscsts[(i__1 = i__ * 6 - 3) < 54 && 0 <= i__1 ? i__1 
		: s_rnge("dscsts", i__1, "f_spk18__", (ftnlen)609)], &c__6, &
		dscpak[(i__2 = i__ * 12 - 6) < 108 && 0 <= i__2 ? i__2 : 
		s_rnge("dscpak", i__2, "f_spk18__", (ftnlen)609)]);
    }
    spkw18_(&handle, &c__0, &xbody, &xcentr, xref, dscepc, &dscepc[8], segid, 
	    &c__3, &c__9, dscpak, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load the SPK file. */

    spklef_("sp18t0.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 1; i__ <= 9; ++i__) {
	spkgeo_(&xbody, &dscepc[(i__1 = i__ - 1) < 9 && 0 <= i__1 ? i__1 : 
		s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)645)], xref, &
		xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	moved_(&dscsts[(i__1 = i__ * 6 - 6) < 54 && 0 <= i__1 ? i__1 : s_rnge(
		"dscsts", i__1, "f_spk18__", (ftnlen)649)], &c__3, xstate);
	vscl_(&c_b116, &dscsts[(i__1 = i__ * 6 - 3) < 54 && 0 <= i__1 ? i__1 :
		 s_rnge("dscsts", i__1, "f_spk18__", (ftnlen)650)], &xstate[3]
		);
	chckad_("type 18 state", state, "~", xstate, &c__6, &c_b100, ok, (
		ftnlen)13, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 test:  create a large subtype 1 segment with multiple dir"
	    "ectories.", (ftnlen)73);

/*     Create the state and epoch values we'll use. */

    for (i__ = 1; i__ <= 10101; ++i__) {
	for (j = 1; j <= 6; ++j) {
	    bt1lst[(i__1 = j + i__ * 6 - 7) < 60606 && 0 <= i__1 ? i__1 : 
		    s_rnge("bt1lst", i__1, "f_spk18__", (ftnlen)685)] = i__ * 
		    10. + j;
	}
	beplst[(i__1 = i__ - 1) < 10101 && 0 <= i__1 ? i__1 : s_rnge("beplst",
		 i__1, "f_spk18__", (ftnlen)689)] = i__ * 10.;
    }

/*     Open a new type 18 SPK file. */

    if (exists_("sp18big1.bsp", (ftnlen)12)) {
	delfil_("sp18big1.bsp", (ftnlen)12);
    }
    spkopn_("sp18big1.bsp", "Type 18 SPK internal file name", &c__0, &handle, 
	    (ftnlen)12, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkw18_(&handle, &c__1, &c_b161, &c__5, xref, beplst, &beplst[10100], 
	    segid, &c__3, &c__10101, bt1lst, beplst, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load the SPK file. */

    spklef_("sp18big1.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each midpoint of adjacent epochs in our list. */
/*     Compare. */

    for (i__ = 1; i__ <= 10100; ++i__) {
	d__1 = beplst[(i__1 = i__ - 1) < 10101 && 0 <= i__1 ? i__1 : s_rnge(
		"beplst", i__1, "f_spk18__", (ftnlen)738)] + 5.;
	spkgeo_(&c_b161, &d__1, xref, &c__5, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected state vector. */

	moved_(&bt1lst[(i__1 = i__ * 6 - 6) < 60606 && 0 <= i__1 ? i__1 : 
		s_rnge("bt1lst", i__1, "f_spk18__", (ftnlen)751)], &c__6, 
		xstate);
	for (j = 1; j <= 6; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk18__", (ftnlen)755)] = xstate[(i__2 = j - 1) <
		     6 && 0 <= i__2 ? i__2 : s_rnge("xstate", i__2, "f_spk18"
		    "__", (ftnlen)755)] + 5.;
	}
	chckad_("type 18 position", state, "~", xstate, &c__3, &c_b100, ok, (
		ftnlen)16, (ftnlen)1);
	chckad_("type 18 velocity", &state[3], "~", &xstate[3], &c__3, &
		c_b100, ok, (ftnlen)16, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKW18 test:  create a large subtype 0 segment with multiple dir"
	    "ectories.", (ftnlen)73);

/*     Create the state and epoch values we'll use. We're going to set */
/*     all velocities to zero to create a rounded stair-step sort of */
/*     pattern in the position components. This will ensure that the */
/*     correct states cannot be obtained without selecting the correct */
/*     window of states in the reader. */

/*     For velocity and acceleration, we'll use the same idea, but we'll */
/*     scale the values to distinguish them. */

    for (i__ = 1; i__ <= 10101; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    bt0lst[(i__1 = j + i__ * 12 - 13) < 121212 && 0 <= i__1 ? i__1 : 
		    s_rnge("bt0lst", i__1, "f_spk18__", (ftnlen)804)] = i__ * 
		    10. + j;
	    bt0lst[(i__1 = j + 3 + i__ * 12 - 13) < 121212 && 0 <= i__1 ? 
		    i__1 : s_rnge("bt0lst", i__1, "f_spk18__", (ftnlen)805)] =
		     0.;
	    bt0lst[(i__1 = j + 6 + i__ * 12 - 13) < 121212 && 0 <= i__1 ? 
		    i__1 : s_rnge("bt0lst", i__1, "f_spk18__", (ftnlen)806)] =
		     bt0lst[(i__2 = j + i__ * 12 - 13) < 121212 && 0 <= i__2 ?
		     i__2 : s_rnge("bt0lst", i__2, "f_spk18__", (ftnlen)806)] 
		    * 1e6;
	    bt0lst[(i__1 = j + 9 + i__ * 12 - 13) < 121212 && 0 <= i__1 ? 
		    i__1 : s_rnge("bt0lst", i__1, "f_spk18__", (ftnlen)807)] =
		     0.;
	}
	beplst[(i__1 = i__ - 1) < 10101 && 0 <= i__1 ? i__1 : s_rnge("beplst",
		 i__1, "f_spk18__", (ftnlen)811)] = i__ * 10.;
    }

/*     Open a new type 18 SPK file. */

    if (exists_("sp18big0.bsp", (ftnlen)12)) {
	delfil_("sp18big0.bsp", (ftnlen)12);
    }
    spkopn_("sp18big0.bsp", "Type 18 SPK internal file name", &c__0, &handle, 
	    (ftnlen)12, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkw18_(&handle, &c__0, &c_b161, &c__5, xref, beplst, &beplst[10100], 
	    segid, &c__3, &c__10101, bt0lst, beplst, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load the SPK file. */

    spklef_("sp18big0.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each midpoint of adjacent epochs in our list. */
/*     Compare. */

    for (i__ = 1; i__ <= 10100; ++i__) {
	d__1 = beplst[(i__1 = i__ - 1) < 10101 && 0 <= i__1 ? i__1 : s_rnge(
		"beplst", i__1, "f_spk18__", (ftnlen)860)] + 5.;
	spkgeo_(&c_b161, &d__1, xref, &c__5, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Set up the expected state vector. */

	moved_(&bt0lst[(i__1 = i__ * 12 - 12) < 121212 && 0 <= i__1 ? i__1 : 
		s_rnge("bt0lst", i__1, "f_spk18__", (ftnlen)873)], &c__3, 
		xstate);
	for (j = 1; j <= 3; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk18__", (ftnlen)877)] = xstate[(i__2 = j - 1) <
		     6 && 0 <= i__2 ? i__2 : s_rnge("xstate", i__2, "f_spk18"
		    "__", (ftnlen)877)] + 5.;
	    xstate[(i__1 = j + 2) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk18__", (ftnlen)878)] = xstate[(i__2 = j - 1) <
		     6 && 0 <= i__2 ? i__2 : s_rnge("xstate", i__2, "f_spk18"
		    "__", (ftnlen)878)] * 1e6;
	}
	chckad_("type 18 position", state, "~", xstate, &c__3, &c_b100, ok, (
		ftnlen)16, (ftnlen)1);
	chckad_("type 18 velocity", &state[3], "~", &xstate[3], &c__3, &
		c_b100, ok, (ftnlen)16, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS18: write new file having a segment created by subsetti"
	    "ng small segment from SP18T1.", (ftnlen)93);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 18 test subset segment", (ftnlen)60, (ftnlen)31);

/*     Open a new SPK file. */

    if (exists_("sp18sub1.bsp", (ftnlen)12)) {
	delfil_("sp18sub1.bsp", (ftnlen)12);
    }
    spkopn_("sp18sub1.bsp", "Type 18 SPK internal file name", &c__0, &newh, (
	    ftnlen)12, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open SP18T1 and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("sp18t1.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgn_(segid2, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a type 18 segment in new file.  Shorten the time */
/*     coverage by knocking off the coverage contributed by */
/*     the first and last packets of the source segment. */

    spksub_(&handle, descr, segid, &dscepc[1], &dscepc[7], &newh, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the new SPK file. */

    spkcls_(&newh);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the old SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS18: check descriptor bounds on subsetted file.", (ftnlen)
	    55);

/*     Open SP18S1 and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("sp18sub1.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafus_(descr, &c__2, &c__6, dc, ic);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the time bounds. */

    i__ = 8;
    chcksd_("Segment start", dc, "=", &dscepc[1], &c_b297, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Segment end", &dc[1], "=", &dscepc[(i__1 = i__ - 1) < 9 && 0 <= 
	    i__1 ? i__1 : s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)1010)], 
	    &c_b297, ok, (ftnlen)11, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: read states from subsetted file.", (ftnlen)45);

/*     Load the SPK file. */

    spklef_("sp18sub1.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 2; i__ <= 8; ++i__) {
	spkgeo_(&xbody, &dscepc[(i__1 = i__ - 1) < 9 && 0 <= i__1 ? i__1 : 
		s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)1037)], xref, &
		xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("type 18 state", state, "~", &dscsts[(i__1 = i__ * 6 - 6) < 
		54 && 0 <= i__1 ? i__1 : s_rnge("dscsts", i__1, "f_spk18__", (
		ftnlen)1040)], &c__6, &c_b100, ok, (ftnlen)13, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Repeat subsetting tests for a subtype 0 segment. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS18: write new file having a segment created by subsetti"
	    "ng small segment from SP18T0.", (ftnlen)93);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 18 test subset segment", (ftnlen)60, (ftnlen)31);

/*     Open a new SPK file. */

    if (exists_("sp18sub0.bsp", (ftnlen)12)) {
	delfil_("sp18sub0.bsp", (ftnlen)12);
    }
    spkopn_("sp18sub0.bsp", "Type 18 SPK internal file name", &c__0, &newh, (
	    ftnlen)12, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open SP18T0 and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("sp18t0.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgn_(segid2, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a type 18 segment in new file.  Shorten the time */
/*     coverage by knocking off the coverage contributed by */
/*     the first and last packets of the source segment. */

    spksub_(&handle, descr, segid, &dscepc[1], &dscepc[7], &newh, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the new SPK file. */

    spkcls_(&newh);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the old SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS18: check descriptor bounds on subsetted file.", (ftnlen)
	    55);

/*     Open SP18S0 and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("sp18sub0.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafus_(descr, &c__2, &c__6, dc, ic);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the time bounds. */

    i__ = 8;
    chcksd_("Segment start", dc, "=", &dscepc[1], &c_b297, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Segment end", &dc[1], "=", &dscepc[(i__1 = i__ - 1) < 9 && 0 <= 
	    i__1 ? i__1 : s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)1164)], 
	    &c_b297, ok, (ftnlen)11, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: read states from subsetted file.", (ftnlen)45);

/*     Load the SPK file. */

    spklef_("sp18sub1.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 2; i__ <= 8; ++i__) {
	spkgeo_(&xbody, &dscepc[(i__1 = i__ - 1) < 9 && 0 <= i__1 ? i__1 : 
		s_rnge("dscepc", i__1, "f_spk18__", (ftnlen)1191)], xref, &
		xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("type 18 state", state, "~", &dscsts[(i__1 = i__ * 6 - 6) < 
		54 && 0 <= i__1 ? i__1 : s_rnge("dscsts", i__1, "f_spk18__", (
		ftnlen)1194)], &c__6, &c_b100, ok, (ftnlen)13, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Clean up:  delete SPK files.", (ftnlen)28);
    delfil_("test18err.bsp", (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18t0.bsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18t1.bsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18big0.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18big1.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18sub0.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("sp18sub1.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_spk18__ */

