/* f_spk14.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__4 = 4;
static integer c_n1 = -1;
static logical c_true = TRUE_;
static integer c__2 = 2;
static integer c__3 = 3;
static doublereal c_b73 = 1e-11;
static integer c__0 = 0;
static integer c__6 = 6;
static doublereal c_b123 = 0.;
static integer c__18 = 18;
static integer c__1 = 1;

/* $Procedure F_SPK14 ( SPK type 14 tests ) */
/* Subroutine */ int f_spk14__(logical *ok)
{
    /* Initialized data */

    static doublereal dscepc[5] = { 100.,200.,300.,400.,500. };
    static doublereal chbr14[80]	/* was [20][4] */ = { 150.,50.,1.0101,
	    1.0102,1.0103,1.0201,1.0202,1.0203,1.0301,1.0302,1.0303,1.0401,
	    1.0402,1.0403,1.0501,1.0502,1.0503,1.0601,1.0602,1.0603,250.,50.,
	    2.0101,2.0102,2.0103,2.0201,2.0202,2.0203,2.0301,2.0302,2.0303,
	    2.0401,2.0402,2.0403,2.0501,2.0502,2.0503,2.0601,2.0602,2.0603,
	    350.,50.,3.0101,3.0102,3.0103,3.0201,3.0202,3.0203,3.0301,3.0302,
	    3.0303,3.0401,3.0402,3.0403,3.0501,3.0502,3.0503,3.0601,3.0602,
	    3.0603,450.,50.,4.0101,4.0102,4.0103,4.0201,4.0202,4.0203,4.0301,
	    4.0302,4.0303,4.0401,4.0402,4.0403,4.0501,4.0502,4.0503,4.0601,
	    4.0602,4.0603 };

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
	    doublereal *, integer *), spk14a_(integer *, integer *, 
	    doublereal *, doublereal *), spk14b_(integer *, char *, integer *,
	     integer *, char *, doublereal *, doublereal *, integer *, ftnlen,
	     ftnlen);
    doublereal theta;
    extern /* Subroutine */ int spk14e_(integer *), moved_(doublereal *, 
	    integer *, doublereal *);
    logical found;
    doublereal midpt, state[6];
    integer xbody;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    char segid2[60];
    doublereal chbcfb[181818]	/* was [3][6][10101] */, dc[2], chbcff[18]	
	    /* was [3][6] */;
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
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal packet[20];
    extern /* Subroutine */ int dafopr_(char *, integer *, ftnlen), spklef_(
	    char *, integer *, ftnlen);
    doublereal radius, beplst[10102], intlen;
    extern /* Subroutine */ int spkgeo_(integer *, doublereal *, char *, 
	    integer *, doublereal *, doublereal *, ftnlen), spkuef_(integer *)
	    , spkcls_(integer *);
    integer paksiz, xcentr;
    extern /* Subroutine */ int spksub_(integer *, doublereal *, char *, 
	    doublereal *, doublereal *, integer *, ftnlen);
    doublereal xstate[6];
    extern /* Subroutine */ int spkopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen);
    extern logical exists_(char *, ftnlen);
    extern /* Subroutine */ int tstlsk_(void);

/* $ Abstract */

/*     Exercise routines associated with SPK data type 14. */

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

/*     This routine tests routines specific to SPK data type 14. */

/*     In addition, the type 14 reader and evaluator routines */
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


/*     Chebyshev coefficients for testing SPK type 14 routines: */


/*     Statement functions */


/*     T(n,theta) represents the Chebyshev polynomial */

/*       T ( theta ) */
/*        n */


/*     Open the test family. */

    topen_("F_SPK14", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup", (ftnlen)5);

/*     Create and load a leapseconds kernel. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test SPK14B:  start out with error handling. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Bad coefficient set count.", (ftnlen)26);
    if (exists_("test14err.bsp", (ftnlen)13)) {
	delfil_("test14err.bsp", (ftnlen)13);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }
    spkopn_("test14err.bsp", "Type 14 SPK internal file name", &c__4, &handle,
	     (ftnlen)13, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 301;
    xcentr = 3;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);
    s_copy(segid, "SPK Type 14 test segment", (ftnlen)60, (ftnlen)24);
    spk14b_(&handle, segid, &xbody, &xcentr, xref, dscepc, &dscepc[4], &c_n1, 
	    (ftnlen)60, (ftnlen)32);
    chckxc_(&c_true, "SPICE(INVALIDARGUMENT)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid reference frame.", (ftnlen)24);
    spk14b_(&handle, segid, &xbody, &xcentr, "SPUD", dscepc, &dscepc[4], &
	    c__4, (ftnlen)60, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Descriptor times out of order.", (ftnlen)30);
    spk14b_(&handle, segid, &xbody, &xcentr, xref, &dscepc[4], dscepc, &c__4, 
	    (ftnlen)60, (ftnlen)32);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);

/*     Close this file.  Note that the file contains no segments, */
/*     so SPKCLS won't close it. */

    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPK14a, SPK14b, SPK14c: write small segment.", (ftnlen)49);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 14 test segment", (ftnlen)60, (ftnlen)24);

/*     Open a new SPK file. */

    if (exists_("test14.bsp", (ftnlen)10)) {
	delfil_("test14.bsp", (ftnlen)10);
    }
    spkopn_("test14.bsp", "Type 14 SPK internal file name", &c__4, &handle, (
	    ftnlen)10, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a type 14 segment. */


/*     Begin the segment. */

    spk14b_(&handle, segid, &xbody, &xcentr, xref, dscepc, &dscepc[4], &c__2, 
	    (ftnlen)60, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add data. */

    spk14a_(&handle, &c__4, chbr14, dscepc);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     End the segment. */

    spk14e_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKR014, SPKE014: read small segment.", (ftnlen)42);

/*     Load the SPK file. */

    spklef_("test14.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Look up states for each epoch in our list.  Compare. */

    intlen = dscepc[1] - dscepc[0];
    for (i__ = 1; i__ <= 4; ++i__) {

/*        Generate look-up epoch ET. */

	radius = intlen * .5;
	midpt = dscepc[(i__1 = i__ - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge(
		"dscepc", i__1, "f_spk14__", (ftnlen)493)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Capture the Ith coefficient packet in an array that is */
/*        more easily indexed. */

	paksiz = 18;
	moved_(&chbr14[(i__1 = i__ * 20 - 18) < 80 && 0 <= i__1 ? i__1 : 
		s_rnge("chbr14", i__1, "f_spk14__", (ftnlen)506)], &paksiz, 
		chbcff);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 6; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk14__", (ftnlen)515)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk14__", (ftnlen)519)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk14__", (ftnlen)519)] + chbcff[(i__3 = k + 
			j * 3 - 3) < 18 && 0 <= i__3 ? i__3 : s_rnge("chbcff",
			 i__3, "f_spk14__", (ftnlen)519)] * cos(k * acos((min(
			d__1,d__2))));
	    }
	}
	chckad_("type 14 position", state, "~", xstate, &c__3, &c_b73, ok, (
		ftnlen)16, (ftnlen)1);
	chckad_("type 14 velocity", &state[3], "~", &xstate[3], &c__3, &c_b73,
		 ok, (ftnlen)16, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS14: write new file having a segment created by subsetti"
	    "ng small segment from BSP14.", (ftnlen)92);
    xbody = 3;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 14 test subset segment", (ftnlen)60, (ftnlen)31);

/*     Open a new SPK file. */

    if (exists_("test14sub.bsp", (ftnlen)13)) {
	delfil_("test14sub.bsp", (ftnlen)13);
    }
    spkopn_("test14sub.bsp", "Type 14 SPK internal file name", &c__0, &newh, (
	    ftnlen)13, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open SPK14 and extract segment descriptor and ID of first segment. */

    dafopr_("test14.bsp", &handle, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafgn_(segid2, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a type 14 segment in new file.  Shorten the time */
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

    tcase_("Test SPKS14: check descriptor bounds on subsetted file.", (ftnlen)
	    55);

/*     Open SPK14S and extract segment descriptor and ID of first */
/*     segment. */

    dafopr_("test14sub.bsp", &handle, (ftnlen)13);
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
    chcksd_("Segment start", dc, "=", &dscepc[1], &c_b123, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Segment end", &dc[1], "=", &dscepc[(i__1 = i__ - 1) < 5 && 0 <= 
	    i__1 ? i__1 : s_rnge("dscepc", i__1, "f_spk14__", (ftnlen)652)], &
	    c_b123, ok, (ftnlen)11, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKS14: read states from subsetted file.", (ftnlen)45);

/*     Load the SPK file. */

    spklef_("test14sub.bsp", &handle, (ftnlen)13);
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
		"dscepc", i__1, "f_spk14__", (ftnlen)683)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Capture the Ith coefficient packet in an array that is */
/*        more easily indexed. */

	paksiz = 18;
	moved_(&chbr14[(i__1 = i__ * 20 - 18) < 80 && 0 <= i__1 ? i__1 : 
		s_rnge("chbr14", i__1, "f_spk14__", (ftnlen)697)], &paksiz, 
		chbcff);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 6; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk14__", (ftnlen)706)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk14__", (ftnlen)710)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk14__", (ftnlen)710)] + chbcff[(i__3 = k + 
			j * 3 - 3) < 18 && 0 <= i__3 ? i__3 : s_rnge("chbcff",
			 i__3, "f_spk14__", (ftnlen)710)] * cos(k * acos((min(
			d__1,d__2))));
	    }
	}
	chckad_("type 14 position", state, "~", xstate, &c__3, &c_b73, ok, (
		ftnlen)16, (ftnlen)1);
	chckad_("type 14 velocity", &state[3], "~", &xstate[3], &c__3, &c_b73,
		 ok, (ftnlen)16, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("SPKR14/SPKE14 test:  create a large segment with multiple direct"
	    "ories.", (ftnlen)70);

/*     Create the coefficient and epoch values we'll use. We're going to */
/*     follow a pattern similar to that used for the smaller segments */
/*     created so far: each coefficient will have the value */

/*        I + J*10**-4 + K*10**-8 */

/*     where I is the coefficient set index, J is the component (X,Y, or */
/*     Z) index, and K-1 is the associated degree. */

    for (i__ = 1; i__ <= 10101; ++i__) {
	for (j = 1; j <= 6; ++j) {
	    for (k = 0; k <= 2; ++k) {
		chbcfb[(i__1 = k + (j + i__ * 6) * 3 - 21) < 181818 && 0 <= 
			i__1 ? i__1 : s_rnge("chbcfb", i__1, "f_spk14__", (
			ftnlen)763)] = i__ + j * 1e-4 + k * 1e-8;
	    }
	}
    }
    for (i__ = 1; i__ <= 10102; ++i__) {

/*        Initialize the Ith epoch. */

	beplst[(i__1 = i__ - 1) < 10102 && 0 <= i__1 ? i__1 : s_rnge("beplst",
		 i__1, "f_spk14__", (ftnlen)775)] = (doublereal) (i__ * 100);
    }
    xbody = 14;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);

/*     Create a segment identifier. */

    s_copy(segid, "SPK type 14 big test segment", (ftnlen)60, (ftnlen)28);

/*     Open a new SPK file. */

    if (exists_("test14big.bsp", (ftnlen)13)) {
	delfil_("test14big.bsp", (ftnlen)13);
    }
    spkopn_("test14big.bsp", "Type 14 SPK internal file name", &c__0, &handle,
	     (ftnlen)13, (ftnlen)30);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/*     Begin the segment. */

    spk14b_(&handle, segid, &xbody, &xcentr, xref, beplst, &beplst[10101], &
	    c__2, (ftnlen)60, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add data. */

    intlen = beplst[1] - beplst[0];
    for (i__ = 1; i__ <= 10101; ++i__) {
	radius = intlen * .5;
	midpt = beplst[(i__1 = i__ - 1) < 10102 && 0 <= i__1 ? i__1 : s_rnge(
		"beplst", i__1, "f_spk14__", (ftnlen)823)] + radius;
	packet[0] = midpt;
	packet[1] = radius;
	moved_(&chbcfb[(i__1 = (i__ * 6 + 1) * 3 - 21) < 181818 && 0 <= i__1 ?
		 i__1 : s_rnge("chbcfb", i__1, "f_spk14__", (ftnlen)828)], &
		c__18, &packet[2]);
	spk14a_(&handle, &c__1, packet, &beplst[(i__1 = i__ - 1) < 10102 && 0 
		<= i__1 ? i__1 : s_rnge("beplst", i__1, "f_spk14__", (ftnlen)
		830)]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     End the segment. */

    spk14e_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the SPK file. */

    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test SPKR14, SPKE14: read states from large file.", (ftnlen)49);

/*     Load the SPK file. */

    spklef_("test14big.bsp", &handle, (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    xbody = 14;
    xcentr = 10;
    s_copy(xref, "J2000", (ftnlen)32, (ftnlen)5);
    intlen = beplst[1] - beplst[0];

/*     Look up states for each epoch in our list.  Compare. */

    for (i__ = 1; i__ <= 10101; ++i__) {

/*        Generate look-up epoch ET. */

	radius = intlen * .5;
	midpt = beplst[(i__1 = i__ - 1) < 10102 && 0 <= i__1 ? i__1 : s_rnge(
		"beplst", i__1, "f_spk14__", (ftnlen)874)] + radius;
	et = midpt + radius * .5;
	spkgeo_(&xbody, &et, xref, &xcentr, state, &lt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Capture the Ith coefficient packet in an array that is */
/*        more easily indexed. */

	paksiz = 18;
	moved_(&chbcfb[(i__1 = (i__ * 6 + 1) * 3 - 21) < 181818 && 0 <= i__1 ?
		 i__1 : s_rnge("chbcfb", i__1, "f_spk14__", (ftnlen)887)], &
		paksiz, chbcff);

/*        Evaluate the position "manually." */

	theta = (et - midpt) / radius;
	for (j = 1; j <= 6; ++j) {
	    xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xstate", 
		    i__1, "f_spk14__", (ftnlen)896)] = 0.;
	    for (k = 0; k <= 2; ++k) {
/* Computing MIN */
		d__1 = 1., d__2 = max(-1.,theta);
		xstate[(i__1 = j - 1) < 6 && 0 <= i__1 ? i__1 : s_rnge("xsta"
			"te", i__1, "f_spk14__", (ftnlen)900)] = xstate[(i__2 =
			 j - 1) < 6 && 0 <= i__2 ? i__2 : s_rnge("xstate", 
			i__2, "f_spk14__", (ftnlen)900)] + chbcff[(i__3 = k + 
			j * 3 - 3) < 18 && 0 <= i__3 ? i__3 : s_rnge("chbcff",
			 i__3, "f_spk14__", (ftnlen)900)] * cos(k * acos((min(
			d__1,d__2))));
	    }
	}
	chckad_("type 14 position", state, "~", xstate, &c__3, &c_b73, ok, (
		ftnlen)16, (ftnlen)1);
	chckad_("type 14 velocity", &state[3], "~", &xstate[3], &c__3, &c_b73,
		 ok, (ftnlen)16, (ftnlen)1);
    }

/*     Unload the SPK file. */

    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Deleting SPK files at clean-up time.", (ftnlen)36);

/*     Clean up the SPK files. */

    delfil_("test14.bsp", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test14err.bsp", (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test14sub.bsp", (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test14big.bsp", (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_spk14__ */

