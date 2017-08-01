/* f_rdpck.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__14 = 14;
static doublereal c_b31 = 1e-11;
static doublereal c_b37 = 1e-10;
static doublereal c_b40 = 0.;
static integer c__3 = 3;
static integer c__1 = 1;
static integer c__9 = 9;
static integer c__6 = 6;
static integer c__36 = 36;
static integer c__10 = 10;
static integer c_n10 = -10;

/* $Procedure      F_RDPCK ( Text PCK orientation reader tests ) */
/* Subroutine */ int f_rdpck__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double d_mod(doublereal *, doublereal *);

    /* Local variables */
    doublereal xdec;
    char line[200];
    logical skip[75];
    extern /* Subroutine */ int mxmg_(doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *);
    doublereal tipm[9]	/* was [3][3] */, zmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int eul2m_(doublereal *, doublereal *, doublereal 
	    *, integer *, integer *, integer *, doublereal *);
    integer i__, j, k, t;
    doublereal w, delta;
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), repmd_(char *, char *, 
	    doublereal *, integer *, char *, ftnlen, ftnlen, ftnlen), moved_(
	    doublereal *, integer *, doublereal *), repmi_(char *, char *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen)
	    ;
    doublereal tsipm[36]	/* was [6][6] */, tmpxf[36]	/* was [6][6] 
	    */, xtipm[9]	/* was [3][3] */;
    extern doublereal twopi_(void);
    extern /* Subroutine */ int t_success__(logical *), eul2xf_(doublereal *, 
	    integer *, integer *, integer *, doublereal *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal tsipm2[36]	/* was [6][6] */, lambda, ra, et;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chcksd_(
	    char *, doublereal *, char *, doublereal *, doublereal *, logical 
	    *, ftnlen, ftnlen);
    extern doublereal halfpi_(void);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     bodmat_(integer *, doublereal *, doublereal *);
    doublereal xlmbda;
    extern /* Subroutine */ int t_pck08__(char *, logical *, logical *, 
	    ftnlen), bodeul_(integer *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal xw;
    extern /* Subroutine */ int tipbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen), tisbod_(char *, integer *, doublereal *, 
	    doublereal *, ftnlen);
    integer bodlst[75];
    extern /* Subroutine */ int qderiv_(integer *, doublereal *, doublereal *,
	     doublereal *, doublereal *);
    doublereal eulsta[6], b2j[9]	/* was [3][3] */, tmpmat[9]	/* 
	    was [3][3] */, xdtipm[9]	/* was [3][3] */;
    extern /* Subroutine */ int pxform_(char *, char *, doublereal *, 
	    doublereal *, ftnlen, ftnlen), sxform_(char *, char *, doublereal 
	    *, doublereal *, ftnlen, ftnlen);
    doublereal xtsipm[36]	/* was [6][6] */;
    extern doublereal j2000_(void);
    doublereal dec;
    extern doublereal b1950_(void);
    char pck[255];
    extern doublereal rpd_(void), spd_(void);
    doublereal xra;
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    , t_pckeq__(integer *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal rj2e[9]	/* was [3][3] */, tj2e[36]	/* was [6][6] */, 
	    eul0[3], eul2[3];

/* $ Abstract */

/*     This routine tests the SPICELIB routines */

/*        BODEUL */
/*        BODMAT */
/*        TIPBOD */
/*        TISBOD */

/*     Results of computations done by these routines are compared */
/*     with results of computations implemented in-line in the */
/*     test utility routine T_PCKEQ.  This testing approach attempts */
/*     to validate orientation computations done using text PCK data */
/*     by comparing their results to those obtained via an alternate */
/*     computational approach. */

/*     These tests also serve to mininize the chance of transcription */
/*     error when a new PCK version is created.  Entering the PCK */
/*     constants both in the new PCK file and in T_PCKEQ enables */
/*     double-checking of the constants. */

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

/* -    TSPICE Version 2.0.0, 14-DEC-2005 (NJB) */

/*        Upgraded tests: */

/*          - Full tests for TISBOD have been added.  Previously, */
/*            just a sanity check was done on the upper left block */
/*            of TISBOD's output matrix.  (The previous version of */
/*            this routine did not claim to test TISBOD at all.) */

/*          - Tests of TIPBOD and TISBOD for non-native input frames */
/*            have been added. */

/*          - Test for different epochs have been condensed using loops. */


/* -    TSPICE Version 1.1.0, 27-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in MXM calls. */

/* -    TSPICE Version 1.0.0, 13-FEB-2004 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Begin every test family with an open call. */

    topen_("F_RDPCK", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create full text PCK file.", (ftnlen)34);
    s_copy(pck, "test_0008.tpc", (ftnlen)255, (ftnlen)13);

/*     Create the PCK file, load it, and delete it. */

    t_pck08__(pck, &c_true, &c_false, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Initialize the body code list. */

    bodlst[0] = 10;
    bodlst[1] = 199;
    bodlst[2] = 299;
    bodlst[3] = 399;
    bodlst[4] = 301;
    bodlst[5] = 499;
    bodlst[6] = 401;
    bodlst[7] = 402;
    bodlst[8] = 599;
    bodlst[9] = 501;
    bodlst[10] = 502;
    bodlst[11] = 503;
    bodlst[12] = 504;
    bodlst[13] = 505;
    bodlst[14] = 506;
    bodlst[15] = 507;
    bodlst[16] = 508;
    bodlst[17] = 509;
    bodlst[18] = 510;
    bodlst[19] = 511;
    bodlst[20] = 512;
    bodlst[21] = 513;
    bodlst[22] = 514;
    bodlst[23] = 515;
    bodlst[24] = 516;
    bodlst[25] = 699;
    bodlst[26] = 601;
    bodlst[27] = 602;
    bodlst[28] = 603;
    bodlst[29] = 604;
    bodlst[30] = 605;
    bodlst[31] = 606;
    bodlst[32] = 607;
    bodlst[33] = 608;
    bodlst[34] = 609;
    bodlst[35] = 610;
    bodlst[36] = 611;
    bodlst[37] = 612;
    bodlst[38] = 613;
    bodlst[39] = 614;
    bodlst[40] = 615;
    bodlst[41] = 616;
    bodlst[42] = 617;
    bodlst[43] = 618;
    bodlst[44] = 799;
    bodlst[45] = 701;
    bodlst[46] = 702;
    bodlst[47] = 703;
    bodlst[48] = 704;
    bodlst[49] = 705;
    bodlst[50] = 706;
    bodlst[51] = 707;
    bodlst[52] = 708;
    bodlst[53] = 709;
    bodlst[54] = 710;
    bodlst[55] = 711;
    bodlst[56] = 712;
    bodlst[57] = 713;
    bodlst[58] = 714;
    bodlst[59] = 715;
    bodlst[60] = 899;
    bodlst[61] = 801;
    bodlst[62] = 802;
    bodlst[63] = 803;
    bodlst[64] = 804;
    bodlst[65] = 805;
    bodlst[66] = 806;
    bodlst[67] = 807;
    bodlst[68] = 808;
    bodlst[69] = 999;
    bodlst[70] = 901;
    bodlst[71] = 2431010;
    bodlst[72] = 9511010;
    bodlst[73] = 2000004;
    bodlst[74] = 2000433;
    for (i__ = 1; i__ <= 75; ++i__) {
	skip[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : s_rnge("skip", i__1, 
		"f_rdpck__", (ftnlen)249)] = FALSE_;
    }

/*     Certain bodies have no data associated with them. */


/*     Bodies 506-513. */

    skip[14] = TRUE_;
    skip[15] = TRUE_;
    skip[16] = TRUE_;
    skip[17] = TRUE_;
    skip[18] = TRUE_;
    skip[19] = TRUE_;
    skip[20] = TRUE_;
    skip[21] = TRUE_;

/*     Body 607. */

    skip[32] = TRUE_;

/*     Body 802. */

    skip[62] = TRUE_;

/*     Perform BODEUL tests. */

/*     A note concerning the looser tolerance value MEDIUM used */
/*     in these tests:  converting Euler angles to rotation matrices */
/*     involves applying the SIN and COS functions to the angles. */
/*     In the case of the prime meridian angle W, applying trig */
/*     functions increases the relative error, since W may start */
/*     out with magnitude much larger than 2*pi.  The error in W */
/*     is the largest source of error in the matrix TIPM. */

    for (i__ = 1; i__ <= 75; ++i__) {
	if (! skip[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : s_rnge("skip", 
		i__1, "f_rdpck__", (ftnlen)291)]) {
	    for (t = 1; t <= 2; ++t) {

/* --- Case: ------------------------------------------------------ */

		if (t == 1) {
		    et = 0.;
		} else {
		    et = -3.15576e8;
		}
		s_copy(line, "BODEUL test: Check Euler angles for # at ET #.",
			 (ftnlen)200, (ftnlen)46);
		repmi_(line, "#", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ?
			 i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			305)], line, (ftnlen)200, (ftnlen)1, (ftnlen)200);
		repmd_(line, "#", &et, &c__14, line, (ftnlen)200, (ftnlen)1, (
			ftnlen)200);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(line, (ftnlen)200);
		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)312)], &
			et, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		d__1 = twopi_();
		xw = d_mod(&xw, &d__1);
		if (xw < 0.) {
		    xw += twopi_();
		}
		bodeul_(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)321)], &
			et, &ra, &dec, &w, &lambda);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chcksd_("RA", &ra, "~", &xra, &c_b31, ok, (ftnlen)2, (ftnlen)
			1);
		chcksd_("DEC", &dec, "~", &xdec, &c_b31, ok, (ftnlen)3, (
			ftnlen)1);
		chcksd_("W", &w, "~", &xw, &c_b37, ok, (ftnlen)1, (ftnlen)1);
	    }
	}
    }

/*     Perform analogous tests on both BODMAT and TIPBOD. In order to */
/*     compare results against those from T_PCKEQ, we represent results */
/*     from the latter routine as rotation matrices. */

/*     Obtain the position and state transformations from the J2000 */
/*     to the ECLIPJ2000 frame.  These will be used later. */

    pxform_("J2000", "ECLIPJ2000", &c_b40, rj2e, (ftnlen)5, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sxform_("J2000", "ECLIPJ2000", &c_b40, tj2e, (ftnlen)5, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 75; ++i__) {
	if (! skip[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : s_rnge("skip", 
		i__1, "f_rdpck__", (ftnlen)352)]) {
	    for (t = 1; t <= 2; ++t) {

/* --- Case: ------------------------------------------------------ */

		if (t == 1) {
		    et = 0.;
		} else {
		    et = -3.15576e8;
		}
		s_copy(line, "BODMAT test: Check attitude matrix for # at ET"
			" #.", (ftnlen)200, (ftnlen)49);
		repmi_(line, "#", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ?
			 i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			368)], line, (ftnlen)200, (ftnlen)1, (ftnlen)200);
		repmd_(line, "#", &et, &c__14, line, (ftnlen)200, (ftnlen)1, (
			ftnlen)200);
		tcase_(line, (ftnlen)200);
		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)372)], &
			et, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		d__1 = halfpi_() - xdec;
		d__2 = halfpi_() + xra;
		eul2m_(&xw, &d__1, &d__2, &c__3, &c__1, &c__3, xtipm);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Test BODMAT. */

		bodmat_(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)382)], &
			et, tipm);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)
			4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*              Test TIPBOD. */

		s_copy(line, "TIPBOD test: Check attitude matrix for # at ET"
			" #.", (ftnlen)200, (ftnlen)49);
		repmi_(line, "#", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ?
			 i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			396)], line, (ftnlen)200, (ftnlen)1, (ftnlen)200);
		repmd_(line, "#", &et, &c__14, line, (ftnlen)200, (ftnlen)1, (
			ftnlen)200);
		tcase_(line, (ftnlen)200);
		tipbod_("J2000", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? 
			i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			400)], &et, tipm, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)
			4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*              Repeat the TIPBOD test using a non-native inertial */
/*              frame. Right-multiply the matrix obtained from TIPBOD by */
/*              the mapping from J2000 to the non-native frame; this */
/*              should give us the same transformation we'd have had if */
/*              we had looked up the mapping from J2000 to the */
/*              body-fixed frame directly. */

		tipbod_("ECLIPJ2000", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= 
			i__1 ? i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (
			ftnlen)416)], &et, tipm, (ftnlen)10);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxm_(tipm, rj2e, tmpmat);
		moved_(tmpmat, &c__9, tipm);
		chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)
			4, (ftnlen)1);
	    }
	}
    }

/*     Perform analogous tests on TISBOD.  In order to compare */
/*     results against those from T_PCKEQ, we represent results */
/*     from the latter routine as rotation matrices. */

/*     We use discrete derivatives of the Euler angles to examine the */
/*     derivative portion of the state transformation matrix. */

    cleard_(&c__9, zmat);
    for (i__ = 1; i__ <= 75; ++i__) {
	if (! skip[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : s_rnge("skip", 
		i__1, "f_rdpck__", (ftnlen)444)]) {
	    for (t = 1; t <= 2; ++t) {

/* --- Case: ------------------------------------------------------ */

		if (t == 1) {
		    et = 0.;
		} else {
		    et = -3.15576e8;
		}
		s_copy(line, "TISBOD: check state transformation matrix for "
			"# at ET #.", (ftnlen)200, (ftnlen)56);
		repmi_(line, "#", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ?
			 i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			461)], line, (ftnlen)200, (ftnlen)1, (ftnlen)200);
		repmd_(line, "#", &et, &c__14, line, (ftnlen)200, (ftnlen)1, (
			ftnlen)200);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(line, (ftnlen)200);
		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)468)], &
			et, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		d__1 = halfpi_() - xdec;
		d__2 = halfpi_() + xra;
		eul2m_(&xw, &d__1, &d__2, &c__3, &c__1, &c__3, xtipm);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tisbod_("J2000", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? 
			i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			475)], &et, tsipm, (ftnlen)5);
		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              We test the blocks of the state transformation matrix */
/*              separately, since we don't use identical tolerances for */
/*              all blocks. */

		for (j = 1; j <= 3; ++j) {
		    for (k = 1; k <= 3; ++k) {
			tipm[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
				s_rnge("tipm", i__1, "f_rdpck__", (ftnlen)485)
				] = tsipm[(i__2 = j + k * 6 - 7) < 36 && 0 <= 
				i__2 ? i__2 : s_rnge("tsipm", i__2, "f_rdpck"
				"__", (ftnlen)485)];
		    }
		}
		chckad_("TSIPM (upper left block)", tipm, "~", xtipm, &c__9, &
			c_b37, ok, (ftnlen)24, (ftnlen)1);
		for (j = 1; j <= 3; ++j) {
		    for (k = 1; k <= 3; ++k) {
			tipm[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 : 
				s_rnge("tipm", i__1, "f_rdpck__", (ftnlen)494)
				] = tsipm[(i__2 = j + 3 + (k + 3) * 6 - 7) < 
				36 && 0 <= i__2 ? i__2 : s_rnge("tsipm", i__2,
				 "f_rdpck__", (ftnlen)494)];
		    }
		}
		chckad_("TSIPM (lower right block)", tipm, "~", xtipm, &c__9, 
			&c_b37, ok, (ftnlen)25, (ftnlen)1);
		for (j = 1; j <= 3; ++j) {
		    for (k = 1; k <= 3; ++k) {
			tmpmat[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 
				: s_rnge("tmpmat", i__1, "f_rdpck__", (ftnlen)
				503)] = tsipm[(i__2 = j + (k + 3) * 6 - 7) < 
				36 && 0 <= i__2 ? i__2 : s_rnge("tsipm", i__2,
				 "f_rdpck__", (ftnlen)503)];
		    }
		}
		chckad_("TSIPM (upper right block)", tmpmat, "~", zmat, &c__9,
			 &c_b37, ok, (ftnlen)25, (ftnlen)1);

/*              To test the derivative block, we'll first estimate the */
/*              derivatives of the Euler angles using a quadratic */
/*              approximation.  We'll sample the angles at +/- 1 second */
/*              from ET. */

		delta = 1.;

/*              Get the left side angles... */

		d__1 = et - delta;
		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)521)], &
			d__1, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		eul0[0] = xw;
		eul0[1] = halfpi_() - xdec;
		eul0[2] = halfpi_() + xra;

/*              The right side angles... */

		d__1 = et + delta;
		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)531)], &
			d__1, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		eul2[0] = xw;
		eul2[1] = halfpi_() - xdec;
		eul2[2] = halfpi_() + xra;

/*              Find the derivatives. */

		qderiv_(&c__3, eul0, eul2, &delta, &eulsta[3]);

/*              Complete the Euler angle state vector by filling in the */
/*              first three components with the angles at ET. */

		t_pckeq__(&bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ? i__1 : 
			s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)547)], &
			et, &xra, &xdec, &xw);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		d__1 = halfpi_() - xdec;
		d__2 = halfpi_() + xra;
		vpack_(&xw, &d__1, &d__2, eulsta);

/*              Now find the expected state transformation at ET. */

		eul2xf_(eulsta, &c__3, &c__1, &c__3, xtsipm);

/*              Extract the derivative block from the expected state */
/*              transformation. */

		for (j = 1; j <= 3; ++j) {
		    for (k = 1; k <= 3; ++k) {
			xdtipm[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 
				: s_rnge("xdtipm", i__1, "f_rdpck__", (ftnlen)
				563)] = xtsipm[(i__2 = j + 3 + k * 6 - 7) < 
				36 && 0 <= i__2 ? i__2 : s_rnge("xtsipm", 
				i__2, "f_rdpck__", (ftnlen)563)];
		    }
		}

/*              Do the same for the transformation returned from TISBOD. */

		for (j = 1; j <= 3; ++j) {
		    for (k = 1; k <= 3; ++k) {
			tmpmat[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 
				: s_rnge("tmpmat", i__1, "f_rdpck__", (ftnlen)
				572)] = tsipm[(i__2 = j + 3 + k * 6 - 7) < 36 
				&& 0 <= i__2 ? i__2 : s_rnge("tsipm", i__2, 
				"f_rdpck__", (ftnlen)572)];
		    }
		}
		chckad_("TSIPM derivative (lower left block)", tmpmat, "~", 
			xdtipm, &c__9, &c_b37, ok, (ftnlen)35, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


/*              Repeat the TISBOD test using a non-native input frame. */

		s_copy(line, "TISBOD: check state transformation matrix for "
			"# at ET #.  Use ECLIPJ2000 as input frame.", (ftnlen)
			200, (ftnlen)88);
		repmi_(line, "#", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= i__1 ?
			 i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (ftnlen)
			589)], line, (ftnlen)200, (ftnlen)1, (ftnlen)200);
		repmd_(line, "#", &et, &c__14, line, (ftnlen)200, (ftnlen)1, (
			ftnlen)200);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(line, (ftnlen)200);
		tisbod_("ECLIPJ2000", &bodlst[(i__1 = i__ - 1) < 75 && 0 <= 
			i__1 ? i__1 : s_rnge("bodlst", i__1, "f_rdpck__", (
			ftnlen)594)], &et, tsipm2, (ftnlen)10);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		mxmg_(tsipm2, tj2e, &c__6, &c__6, &c__6, tmpxf);
		moved_(tmpxf, &c__36, tsipm2);

/*              Compare against TSIPM from the previous test. */

		chckad_("TSIPM2", tsipm2, "~", tsipm, &c__9, &c_b37, ok, (
			ftnlen)6, (ftnlen)1);
	    }

/*           We've tested TISBOD for the current time value. */

	}

/*        We've tested TISBOD for the current body. */

    }

/* --- Case: ------------------------------------------------------ */


/*     Now check TIPBOD'S ability to deal with non-standard epochs and */
/*     frames.  Look up data for body -10 (these data are created by the */
/*     test utility T_PCK08) at the J1950 epoch in the B1950 frame. */
/*     Object -10 uses the same constants as those for the sun, but for */
/*     body -10, the native frame is B1950 and the reference epoch is */
/*     J1950.  The output should match the standard numbers for the sun. */

    tcase_("TIPBOD lookup of matrix for body -10", (ftnlen)36);
    et = (b1950_() - j2000_()) * spd_();
    bodmat_(&c__10, &c_b40, xtipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tipbod_("B1950", &c_n10, &et, tipm, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)4, (ftnlen)1)
	    ;

/* --- Case: ------------------------------------------------------ */


/*     Repeat the test for TISBOD. */

    tcase_("TISBOD lookup of matrix for body -10", (ftnlen)36);
    tisbod_("B1950", &c_n10, &et, tsipm, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (j = 1; j <= 3; ++j) {
	for (k = 1; k <= 3; ++k) {
	    tipm[(i__1 = j + k * 3 - 4) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		    "tipm", i__1, "f_rdpck__", (ftnlen)656)] = tsipm[(i__2 = 
		    j + k * 6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("tsipm", 
		    i__2, "f_rdpck__", (ftnlen)656)];
	}
    }
    chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)4, (ftnlen)1)
	    ;

/*     Now check BODMAT's ability to deal with non-standard epochs and */
/*     frames.  Look up data for body -10 at the B1950 epoch in the */
/*     B1950 frame.  Since the numbers in the PCK match the standard */
/*     numbers for the sun, applying the B1950-to-J2000 transformation */
/*     to the output via right multiplication */
/*     should yield the standard matrix for the sun. */
    tcase_("BODMAT lookup of matrix for body -10", (ftnlen)36);
    et = (b1950_() - j2000_()) * spd_();
    bodmat_(&c__10, &c_b40, xtipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    bodmat_(&c_n10, &et, tipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("B1950", "J2000", &c_b40, b2j, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxm_(tipm, b2j, tmpmat);
    moved_(tmpmat, &c__9, tipm);
    chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)4, (ftnlen)1)
	    ;

/*     Now check BODEUL's ability to deal with non-standard epochs and */
/*     frames.  Look up data for body -10 at the B1950 epoch in the */
/*     B1950 frame.  Convert the resulting Euler angles to a matrix. */

/*     Since the numbers in the PCK match the standard */
/*     numbers for the sun, applying the B1950-to-J2000 transformation */
/*     to the output via right multiplication */
/*     should yield the standard matrix for the sun. */

    tcase_("BODEUL lookup of angles for body -10, epoch B9150", (ftnlen)49);
    et = (b1950_() - j2000_()) * spd_();
    bodmat_(&c__10, &c_b40, xtipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    bodeul_(&c_n10, &et, &ra, &dec, &w, &lambda);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = halfpi_() - dec;
    d__2 = halfpi_() + ra;
    eul2m_(&w, &d__1, &d__2, &c__3, &c__1, &c__3, tipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("B1950", "J2000", &c_b40, b2j, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxm_(tipm, b2j, tmpmat);
    moved_(tmpmat, &c__9, tipm);
    chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)4, (ftnlen)1)
	    ;

/*     Repeat test for epoch J2000. */

    tcase_("BODEUL lookup of angles for body -10, epoch J2000", (ftnlen)49);
    et = (j2000_() - b1950_()) * spd_();
    bodmat_(&c__10, &et, xtipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    bodeul_(&c_n10, &c_b40, &ra, &dec, &w, &lambda);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = halfpi_() - dec;
    d__2 = halfpi_() + ra;
    eul2m_(&w, &d__1, &d__2, &c__3, &c__1, &c__3, tipm);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pxform_("B1950", "J2000", &c_b40, b2j, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    mxm_(tipm, b2j, tmpmat);
    moved_(tmpmat, &c__9, tipm);
    chckad_("TIPM", tipm, "~", xtipm, &c__9, &c_b37, ok, (ftnlen)4, (ftnlen)1)
	    ;

/*     Check the LAMBDA value associated with body -10.  We */
/*     expect the value to be 99 degrees *RPD().  (The value */
/*     459 degrees is set by T_PCK08, which writes the PCK file */
/*     we're using.  We expect BODEUL to mod this value by 2*pi.) */

    xlmbda = rpd_() * 99.;
    chcksd_("LAMBDA", &lambda, "~", &xlmbda, &c_b37, ok, (ftnlen)6, (ftnlen)1)
	    ;
    t_success__(ok);
    return 0;
} /* f_rdpck__ */

