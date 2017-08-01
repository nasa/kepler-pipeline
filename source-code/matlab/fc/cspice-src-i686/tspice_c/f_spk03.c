/* f_spk03.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__4 = 4;
static integer c__0 = 0;
static integer c__2 = 2;
static logical c_true = TRUE_;
static integer c__3 = 3;
static doublereal c_b91 = 1e-11;
static integer c__6 = 6;
static doublereal c_b141 = 0.;
static integer c__10101 = 10101;

/* $Procedure F_SPK03 ( SPK type 3 tests ) */
/* Subroutine */ int f_spk03__(logical *ok)
{
    /* Initialized data */

    static doublereal dscepc[5] = { 100.,200.,300.,400.,500. };
    static doublereal chbcf3[72]	/* was [3][6][4] */ = { 1.0101,1.0102,
	    1.0103,1.0201,1.0202,1.0203,1.0301,1.0302,1.0303,-1.0101,-1.0102,
	    -1.0103,-1.0201,-1.0202,-1.0203,-1.0301,-1.0302,-1.0303,2.0101,
	    2.0102,2.0103,2.0201,2.0202,2.0203,2.0301,2.0302,2.0303,-2.0101,
	    -2.0102,-2.0103,-2.0201,-2.0202,-2.0203,-2.0301,-2.0302,-2.0303,
	    3.0101,3.0102,3.0103,3.0201,3.0202,3.0203,3.0301,3.0302,3.0303,
	    -3.0101,-3.0102,-3.0103,-3.0201,-3.0202,-3.0203,-3.0301,-3.0302,
	    -3.0303,4.0101,4.0102,4.0103,4.0201,4.0202,4.0203,4.0301,4.0302,
	    4.0303,-4.0101,-4.0102,-4.0103,-4.0201,-4.0202,-4.0203,-4.0301,
	    -4.0302,-4.0303 };

    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double acos(doublereal), cos(doublereal);

    /* Local variables */
    integer newh;
    char xref[32];
    integer i__, j, k;
    extern /* Subroutine */ int dafgn_(char *, ftnlen), dafgs_(doublereal *);
    char segid[60];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    doublereal theta;
    logical found;
    doublereal midpt, state[6];
    integer xbody;
    extern /* Subroutine */ int topen_(char *, ftnlen), spkw03_(integer *, 
	    integer *, integer *, char *, doublereal *, doublereal *, char *, 
	    doublereal *, integer *, integer *, doublereal *, doublereal *, 
	    ftnlen, ftnlen), t_success__(logical *);
    char segid2[60];
    doublereal chbcfb[181818]	/* was [3][6][10101] */, dc[2];
    integer ic[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     daffna_(logical *), dafbfs_(integer *);
    doublereal et;
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *);
    doublereal lt;
    extern /* Subroutine */ int delfil_(char *, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), dafopr_(
	    char *, integer *, ftnlen), spklef_(char *, integer *, ftnlen);
    doublereal radius, beplst[10102], intlen;
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
    extern /* Subroutine */ int tstlsk_(void);

/* $ Abstract */

/*     Exercise routines associated with SPK data type 3. */

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

/*     This routine tests routines specific to SPK data type 3. */

/*     In addition, the type 3 reader and evaluator routines */
/*     are indirectly exercised by this test family. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 20-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Epochs associated with coefficient sets. */


/*     Chebyshev coefficients for testing SPKW03. */


/*     Statement functions */


/*     T(n,theta) represents the Chebyshev polynomial */

/*       T ( theta ) */
/*        n */


/*     Open the test family. */

    topen_("F_SPK03", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup", (ftnlen)5);

/*     Create and load a leapseconds kernel. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test SPKW03:  start out with error handling. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Bad coefficient set count.", (ftnlen)26);
    if (exists_("test3err.bsp", (ftnlen)12)) {
	delfil_("test3err.bsp", (ftnlen)12);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    spkopn_("test3err.bsp", "Type 3 SPK internal file name", &c__4, &handle, (
	    ftnlen)12, (ftnlen)29);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 301;
    xcentr = 3;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);
    s_copy(segid, "SPK Type 3 test segment", (ftnlen)60, (ftnlen)23);
    intlen = dscepc[1] - dscepc[0];
    spkw03_(&handle, &xbody, &xcentr, xref, dscepc, &dscepc[4], segid, &
	    intlen, &c__0, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(NUMCOEFFSNOTPOS)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid interval length.", (ftnlen)24);
    intlen = dscepc[0] - dscepc[1];
    spkw03_(&handle, &xbody, &xcentr, xref, dscepc, &dscepc[4], segid, &
	    intlen, &c__4, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INTLENNOTPOS)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid reference frame.", (ftnlen)24);
    intlen = dscepc[1] - dscepc[0];
    spkw03_(&handle, &xbody, &xcentr, "SPUD", dscepc, &dscepc[4], segid, &
	    intlen, &c__4, &c__2, chbcf3, dscepc, (ftnlen)4, (ftnlen)60);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Descriptor times out of order.", (ftnlen)30);
    intlen = dscepc[1] - dscepc[0];
    spkw03_(&handle, &xbody, &xcentr, xref, &dscepc[4], dscepc, segid, &
	    intlen, &c__4, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);
    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* --- Case: ------------------------------------------------------ */

    tcase_("Descriptor start time is too early.", (ftnlen)35);
    intlen = dscepc[1] - dscepc[0];
    d__1 = dscepc[0] - .001;
    spkw03_(&handle, &xbody, &xcentr, xref, &d__1, &dscepc[4], segid, &intlen,
	     &c__4, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);
/* --- Case: ------------------------------------------------------ */

    tcase_("Descriptor stop time is too late.", (ftnlen)33);
    intlen = dscepc[1] - dscepc[0];
    d__1 = dscepc[4] + .001;
    spkw03_(&handle, &xbody, &xcentr, xref, dscepc, &d__1, segid, &intlen, &
	    c__4, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);

/*     Close this file.  Note that the file contains no segments, */
/*     so SPKCLS won't close it. */

    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKW03: write small segment.", (ftnlen)33);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 3 test segment", (ftnlen)60, (ftnlen)23);

/*     Open a new SPK file. */

    if (exists_("test3.bsp", (ftnlen)9)) {
	delfil_("test3.bsp", (ftnlen)9);
    }
    spkopn_("test3.bsp", "Type 3 SPK internal file name", &c__4, &handle, (
	    ftnlen)9, (ftnlen)29);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    intlen = dscepc[1] - dscepc[0];

/*     Create a type 3 segment. */

    spkw03_(&handle, &xbody, &xcentr, xref, dscepc, &dscepc[4], segid, &
	    intlen, &c__4, &c__2, chbcf3, dscepc, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKR03, SPKE03: read small segment.", (ftnlen)40);

/*     Load the SPK file. */

    spklef_("test3.bsp", &handle, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 1; i__ <= 4; ++i__) {

/*        Generate look-up epoch ET. */

	radius = intlen * .5;
	midpt = dscepc[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge(
		"dscepc", i__1, "f_spk03__", (ftnlen)545)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 3; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk03__", (ftnlen)559)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)563)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)563)] + chbcf3[(i__3 = k + 
			(j + i__ * 6) * 3 - 21) < 72 && 0 <= i__3 ? i__3 : 
			s_rnge("chbcf3", i__3, "f_spk03__", (ftnlen)563)] * 
			cos(k * acos((min(d__1,d__2))));
		xstate[(i__1 = j + 2) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)564)] = -xstate[(i__2 
			= j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)564)];
	    }
	}
	chckad_("type 3 position", state, "~", xstate, &c__3, &c_b91, ok, (
		ftnlen)15, (ftnlen)1);
	chckad_("type 3 velocity", &state[3], "~", &xstate[3], &c__3, &c_b91, 
		ok, (ftnlen)15, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: write new file having a segment created by subsetti"
	    "ng small segment from SPK3.", (ftnlen)91);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 3 test subset segment", (ftnlen)60, (ftnlen)30);

/*     Open a new SPK file. */

    if (exists_("test3sub.bsp", (ftnlen)12)) {
	delfil_("test3sub.bsp", (ftnlen)12);
    }
    spkopn_("test3sub.bsp", "Type 3 SPK internal file name", &c__0, &newh, (
	    ftnlen)12, (ftnlen)29);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open SPK3 and extract segment descriptor and ID of first segment. */

    dafopr_("test3.bsp", &handle, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgn_(segid2, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a type 3 segment in new file.  Shorten the time */
/*     coverage by knocking off the coverage contributed by */
/*     the first and last packets of the source segment. */

    spksub_(&handle, descr, segid, &dscepc[1], &dscepc[3], &newh, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the new SPK file. */

    spkcls_(&newh);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the old SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: check descriptor bounds on subsetted file.", (ftnlen)
	    55);

/*     Open SPK3S and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("test3sub.bsp", &handle, (ftnlen)12);
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

    i__ = 4;
    chcksd_("Segment start", dc, "=", &dscepc[1], &c_b141, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Segment end", &dc[1], "=", &dscepc[(i__1 = i__ - 1) < 5 && 0 <= 
	    i__1 ? i__1 : s_rnge("dscepc", i__1, "f_spk03__", (ftnlen)697)], &
	    c_b141, ok, (ftnlen)11, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: read states from subsetted file.", (ftnlen)45);

/*     Load the SPK file. */

    spklef_("test3sub.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);
    intlen = dscepc[1] - dscepc[0];

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 2; i__ <= 3; ++i__) {

/*        Generate look-up epoch ET. */

	radius = intlen * .5;
	midpt = dscepc[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge(
		"dscepc", i__1, "f_spk03__", (ftnlen)728)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 3; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk03__", (ftnlen)742)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)746)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)746)] + chbcf3[(i__3 = k + 
			(j + i__ * 6) * 3 - 21) < 72 && 0 <= i__3 ? i__3 : 
			s_rnge("chbcf3", i__3, "f_spk03__", (ftnlen)746)] * 
			cos(k * acos((min(d__1,d__2))));
		xstate[(i__1 = j + 2) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)747)] = -xstate[(i__2 
			= j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)747)];
	    }
	}
	chckad_("type 3 position", state, "~", xstate, &c__3, &c_b91, ok, (
		ftnlen)15, (ftnlen)1);
	chckad_("type 3 velocity", &state[3], "~", &xstate[3], &c__3, &c_b91, 
		ok, (ftnlen)15, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKR03/SPKE03 test:  create a large segment with multiple direct"
	    "ories.", (ftnlen)70);

/*     Create the coefficient and epoch values we'll use. We're going to */
/*     follow a pattern similar to that used for the smaller segments */
/*     created so far: each coefficient will have the value */

/*        I + J*10**-4 + K*10**-8 */

/*     where I is the coefficient set index, J is the component (X,Y, or */
/*     Z) index, and K-1 is the associated degree. */

    for (i__ = 1; i__ <= 10101; ++i__) {
	for (j = 1; j <= 3; ++j) {
	    for (k = 0; k <= 2; ++k) {
		chbcfb[(i__1 = k + (j + i__ * 6) * 3 - 21) < 181818 && 0 <= 
			i__1 ? i__1 : s_rnge("chbcfb", i__1, "f_spk03__", (
			ftnlen)800)] = i__ + j * 1e-4 + k * 1e-8;
		chbcfb[(i__1 = k + (j + 3 + i__ * 6) * 3 - 21) < 181818 && 0 
			<= i__1 ? i__1 : s_rnge("chbcfb", i__1, "f_spk03__", (
			ftnlen)802)] = -chbcfb[(i__2 = k + (j + i__ * 6) * 3 
			- 21) < 181818 && 0 <= i__2 ? i__2 : s_rnge("chbcfb", 
			i__2, "f_spk03__", (ftnlen)802)];
	    }
	}
    }
    for (i__ = 1; i__ <= 10102; ++i__) {

/*        Initialize the Ith epoch. */

	beplst[(i__1 = i__ - 1) < 10102 && 0 <= i__1 ? i__1 : s_rnge("beplst",
		 i__1, "f_spk03__", (ftnlen)814)] = (doublereal) (i__ * 100);
    }
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 3 big test segment", (ftnlen)60, (ftnlen)27);

/*     Open a new SPK file. */

    if (exists_("test3big.bsp", (ftnlen)12)) {
	delfil_("test3big.bsp", (ftnlen)12);
    }
    spkopn_("test3big.bsp", "Type 3 SPK internal file name", &c__0, &handle, (
	    ftnlen)12, (ftnlen)29);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    intlen = dscepc[1] - dscepc[0];

/*     Create a type 3 segment. */

    spkw03_(&handle, &xbody, &xcentr, xref, beplst, &beplst[10101], segid, &
	    intlen, &c__10101, &c__2, chbcfb, beplst, (ftnlen)32, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS03: read states from large file.", (ftnlen)41);

/*     Load the SPK file. */

    spklef_("test3big.bsp", &handle, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);
    intlen = dscepc[1] - dscepc[0];

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 1; i__ <= 10101; ++i__) {

/*        Generate look-up epoch ET. */

	radius = intlen * .5;
	midpt = beplst[(i__1 = i__ - 1) < 10102 && 0 <= i__1 ? i__1 : s_rnge(
		"beplst", i__1, "f_spk03__", (ftnlen)890)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 3; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk03__", (ftnlen)904)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)908)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)908)] + chbcfb[(i__3 = k + 
			(j + i__ * 6) * 3 - 21) < 181818 && 0 <= i__3 ? i__3 :
			 s_rnge("chbcfb", i__3, "f_spk03__", (ftnlen)908)] * 
			cos(k * acos((min(d__1,d__2))));
		xstate[(i__1 = j + 2) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk03__", (ftnlen)909)] = -xstate[(i__2 
			= j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk03__", (ftnlen)909)];
	    }
	}
	chckad_("type 3 position", state, "~", xstate, &c__3, &c_b91, ok, (
		ftnlen)15, (ftnlen)1);
	chckad_("type 3 velocity", &state[3], "~", &xstate[3], &c__3, &c_b91, 
		ok, (ftnlen)15, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Deleting SPK files at clean-up time.", (ftnlen)36);

/*     Clean up the SPK files. */

    delfil_("test3.bsp", (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test3err.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test3sub.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test3big.bsp", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_spk03__ */

