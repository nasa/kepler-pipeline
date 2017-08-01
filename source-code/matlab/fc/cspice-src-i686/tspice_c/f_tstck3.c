/* f_tstck3.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c_n9999 = -9999;
static doublereal c_b10 = 0.;
static integer c__3 = 3;
static doublereal c_b50 = .1;
static doublereal c_b51 = 1e-13;
static doublereal c_b55 = 1e-14;
static integer c_n9 = -9;
static integer c__9 = 9;
static doublereal c_b132 = 1e-11;
static integer c_b144 = -10000;
static integer c_b175 = -10001;

/* $Procedure      F_TSTCK3 ( Family of tests for tstck3 and tstatd ) */
/* Subroutine */ int f_tstck3__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal rate;
    extern /* Subroutine */ int vhat_(doublereal *, doublereal *);
    doublereal axis[60]	/* was [3][20] */, temp[9]	/* was [3][3] */, 
	    cout;
    extern /* Subroutine */ int mtxm_(doublereal *, doublereal *, doublereal *
	    ), mxmt_(doublereal *, doublereal *, doublereal *);
    doublereal sclk1, sclk2;
    extern /* Subroutine */ int sce2t_(integer *, doublereal *, doublereal *);
    doublereal cout1, cout2;
    integer i__;
    doublereal angle;
    extern /* Subroutine */ int tcase_(char *, ftnlen), ckupf_(integer *), 
	    topen_(char *, ftnlen);
    doublereal taxis[3];
    char error[80];
    doublereal uaxis[3];
    extern /* Subroutine */ int t_success__(logical *), tstck3_(char *, char *
	    , logical *, logical *, logical *, integer *, ftnlen, ftnlen), 
	    chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen);
    doublereal av[3], dt, et;
    integer ckhand;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksl_(char *, logical *, 
	    logical *, logical *, ftnlen);
    doublereal minang;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    doublereal maxang, angvel[3];
    extern /* Subroutine */ int ckgpav_(integer *, doublereal *, doublereal *,
	     char *, doublereal *, doublereal *, doublereal *, logical *, 
	    ftnlen);
    doublereal sclkdp;
    extern /* Subroutine */ int raxisa_(doublereal *, doublereal *, 
	    doublereal *), tparse_(char *, doublereal *, char *, ftnlen, 
	    ftnlen), tstatd_(doublereal *, doublereal *, doublereal *);
    doublereal matrix[9]	/* was [3][3] */, av1[3], av2[3], et1, et2, 
	    utaxis[3];
    extern /* Subroutine */ int tstmsd_(doublereal *), tstmsg_(char *, char *,
	     ftnlen, ftnlen);
    doublereal zeropt;
    extern /* Subroutine */ int tstmsi_(integer *);
    logical fnd;
    doublereal off, rot[9]	/* was [3][3] */;
    logical fnd1, fnd2;
    doublereal uav1[3], rot1[9]	/* was [3][3] */, rot2[9]	/* was [3][3] 
	    */;

/* $ Abstract */

/*     This routine checks out the test routines TSTCK3 and TSTATD. */


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

/* -    Version 2.0.0 25-NOV-2001 (NJB) */

/*        Updated to relax tolerance on matrix quotient rotation angle */
/*        from 2.0D-12 to 1.0D-11 for cases 5-7 inclusive.  Original */
/*        tolerance was suitable for all platforms but MS Visual C++/C. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_TSTCK3", (ftnlen)8);
    tcase_("Check to make sure that we can get an attitude back from the C-k"
	    "ernel. ", (ftnlen)71);
    tstck3_("TEST.CK", "TEST.SCLK", &c_true, &c_true, &c_false, &ckhand, (
	    ftnlen)7, (ftnlen)9);
    sclkdp = 0.;
    ckgpav_(&c_n9999, &sclkdp, &c_b10, "J2000", rot, av, &cout, &fnd, (ftnlen)
	    5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
    chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)1);
    sclkdp = 1e9;
    ckgpav_(&c_n9999, &sclkdp, &c_b10, "J2000", rot, av, &cout, &fnd, (ftnlen)
	    5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
    chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)1);
    sclkdp = 1e13;
    ckgpav_(&c_n9999, &sclkdp, &c_b10, "J2000", rot, av, &cout, &fnd, (ftnlen)
	    5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
    chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)1);
    tcase_("Check to see that the rotations returned by TSTATD behave as adv"
	    "ertised. ", (ftnlen)73);
    axis[0] = 1.;
    axis[1] = 2.;
    axis[2] = 4.;
    axis[3] = 2.;
    axis[4] = 4.;
    axis[5] = 1.;
    axis[6] = 4.;
    axis[7] = 1.;
    axis[8] = 2.;
    axis[9] = 4.;
    axis[10] = 2.;
    axis[11] = 1.;
    axis[12] = 2.;
    axis[13] = 1.;
    axis[14] = 4.;
    axis[15] = 1.;
    axis[16] = 4.;
    axis[17] = 2.;
    axis[18] = 1.;
    axis[19] = 2.;
    axis[20] = 3.;
    axis[21] = 2.;
    axis[22] = 3.;
    axis[23] = 1.;
    axis[24] = 3.;
    axis[25] = 1.;
    axis[26] = 2.;
    axis[27] = 3.;
    axis[28] = 2.;
    axis[29] = 1.;
    axis[30] = 2.;
    axis[31] = 1.;
    axis[32] = 3.;
    axis[33] = 1.;
    axis[34] = 3.;
    axis[35] = 2.;
    axis[36] = 2.;
    axis[37] = 3.;
    axis[38] = 6.;
    axis[39] = 3.;
    axis[40] = 6.;
    axis[41] = 2.;
    axis[42] = 6.;
    axis[43] = 2.;
    axis[44] = 3.;
    axis[45] = 6.;
    axis[46] = 3.;
    axis[47] = 2.;
    axis[48] = 3.;
    axis[49] = 2.;
    axis[50] = 6.;
    axis[51] = 2.;
    axis[52] = 6.;
    axis[53] = 3.;
    axis[54] = 1.;
    axis[55] = 1.;
    axis[56] = 1.;
    axis[57] = 0.;
    axis[58] = 0.;
    axis[59] = 1.;
    et = -900000010.;
    for (i__ = 1; i__ <= 20; ++i__) {
	dt = 1e6;

/*           Compute the rotation of the structure over a 1 million */
/*           second interval. */

	d__1 = et - dt;
	tstatd_(&d__1, rot1, av1);
	tstatd_(&et, rot2, av2);
	mtxm_(rot2, rot1, matrix);
	raxisa_(matrix, taxis, &angle);
	vhat_(taxis, utaxis);
	vhat_(av1, uav1);
	vhat_(&axis[(i__1 = i__ * 3 - 3) < 60 && 0 <= i__1 ? i__1 : s_rnge(
		"axis", i__1, "f_tstck3__", (ftnlen)266)], uaxis);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("AV1", av1, "=", av2, &c__3, &c_b10, ok, (ftnlen)3, (ftnlen)1)
		;
	chcksd_("ANGLE", &angle, "~/", &c_b50, &c_b51, ok, (ftnlen)5, (ftnlen)
		2);
	chckad_("UAV1", uav1, "~", uaxis, &c__3, &c_b55, ok, (ftnlen)4, (
		ftnlen)1);
	chckad_("UTAXIS", utaxis, "~", uaxis, &c__3, &c_b51, ok, (ftnlen)6, (
		ftnlen)1);
	chckad_("UAV1", uav1, "||", uaxis, &c__3, &c_b51, ok, (ftnlen)4, (
		ftnlen)2);
	chckad_("UTAXIS", utaxis, "||", uaxis, &c__3, &c_b51, ok, (ftnlen)6, (
		ftnlen)2);
	et += 1e8;
    }
    tcase_("Check for continuity of the C-kernel and TSTATD across the 100 m"
	    "illion second boundaries refered to in TSTATD. ", (ftnlen)111);
    et = -9e8;
    tparse_("1-JAN-1980", &zeropt, error, (ftnlen)10, (ftnlen)80);
    while(et < zeropt) {
	et += 1e8;
    }
    rate = 9.9999999999999995e-8;
    maxang = rate * 2.;
    minang = rate * .1;
    while(et < zeropt + 999999999.) {
	et1 = et - 1.;
	et2 = et + 1.;
	sce2t_(&c_n9, &et1, &sclk1);
	sce2t_(&c_n9, &et2, &sclk2);
	ckgpav_(&c_n9999, &sclk1, &c_b10, "J2000", rot1, av1, &cout1, &fnd1, (
		ftnlen)5);
	ckgpav_(&c_n9999, &sclk2, &c_b10, "J2000", rot2, av2, &cout2, &fnd2, (
		ftnlen)5);
	mtxm_(rot2, rot1, temp);
	raxisa_(temp, taxis, &angle);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FND1", &fnd1, &c_true, ok, (ftnlen)4);
	chcksl_("FND2", &fnd2, &c_true, ok, (ftnlen)4);
	chcksd_("COUT1", &cout1, "=", &sclk1, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("COUT2", &cout2, "=", &sclk2, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("ANGLE", &angle, ">", &minang, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("ANGEL", &angle, "<", &maxang, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	tstatd_(&et1, rot1, av1);
	tstatd_(&et2, rot2, av2);
	mtxm_(rot2, rot1, temp);
	raxisa_(temp, taxis, &angle);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksd_("ANGLE", &angle, ">", &minang, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("ANGEL", &angle, "<", &maxang, &c_b10, ok, (ftnlen)5, (ftnlen)
		1);
	et += 1e8;
    }
    tcase_("Make sure the conversion between ET and ticks works as expected. "
	    , (ftnlen)65);
    tparse_("1-JAN-1980", &zeropt, error, (ftnlen)10, (ftnlen)80);
    et = zeropt;
    for (i__ = 1; i__ <= 999; ++i__) {
	sce2t_(&c_n9, &et, &sclkdp);
	cout = (et - zeropt) * 1e4;
	chcksd_("SCLKDP", &sclkdp, "=", &cout, &c_b10, ok, (ftnlen)6, (ftnlen)
		1);
	et += 1e7;
    }
    tcase_("Check to see if attitudes returned by the C-kernel for are very "
	    "nearly the same as that returned by TSTATD (for body -9999). ", (
	    ftnlen)125);
    tparse_("1-JAN-1980", &et, error, (ftnlen)10, (ftnlen)80);
    for (i__ = 1; i__ <= 100; ++i__) {
	sce2t_(&c_n9, &et, &sclkdp);
	tstatd_(&et, matrix, angvel);
	ckgpav_(&c_n9999, &sclkdp, &c_b10, "GALACTIC", rot, av, &cout, &fnd, (
		ftnlen)8);
	tstmsg_("#", "Subcase: #. Angle between rotations: #  ", (ftnlen)1, (
		ftnlen)40);
	mxmt_(matrix, rot, temp);
	raxisa_(temp, taxis, &angle);
	tstmsi_(&i__);
	tstmsd_(&angle);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
	chcksd_("ANGLE", &angle, "~", &c_b10, &c_b55, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)
		1);
	chckad_("ROT", rot, "~/", matrix, &c__9, &c_b132, ok, (ftnlen)3, (
		ftnlen)2);
	chckad_("AV", av, "||", angvel, &c__3, &c_b132, ok, (ftnlen)2, (
		ftnlen)2);
	chckad_("AV", av, "~/", angvel, &c__3, &c_b55, ok, (ftnlen)2, (ftnlen)
		2);
	et += 1e7;
    }
    tcase_("Check to see if attitudes returned by the C-kernel for agree wit"
	    "h those returned by TSTATD (for body -10000). ", (ftnlen)110);
    tparse_("1-JAN-1980", &et, error, (ftnlen)10, (ftnlen)80);
    off = 0.;
    for (i__ = 1; i__ <= 100; ++i__) {
	sce2t_(&c_n9, &et, &sclkdp);
	d__1 = et + off;
	tstatd_(&d__1, matrix, angvel);
	ckgpav_(&c_b144, &sclkdp, &c_b10, "FK4", rot, av, &cout, &fnd, (
		ftnlen)3);
	tstmsg_("#", "Subcase: #. Angle between rotations: #  ", (ftnlen)1, (
		ftnlen)40);
	mxmt_(matrix, rot, temp);
	raxisa_(temp, taxis, &angle);
	tstmsi_(&i__);
	tstmsd_(&angle);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
	chcksd_("ANGLE", &angle, "~", &c_b10, &c_b55, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)
		1);
	chckad_("ROT", rot, "~/", matrix, &c__9, &c_b132, ok, (ftnlen)3, (
		ftnlen)2);
	chckad_("AV", av, "||", angvel, &c__3, &c_b132, ok, (ftnlen)2, (
		ftnlen)2);
	chckad_("AV", av, "~/", angvel, &c__3, &c_b55, ok, (ftnlen)2, (ftnlen)
		2);
	et += 1e7;
    }
    tcase_("Check to see if attitudes returned by the C-kernel for agree wit"
	    "h those returned by TSTATD (for body -10001 ). ", (ftnlen)111);
    tparse_("1-JAN-1980", &et, error, (ftnlen)10, (ftnlen)80);
    off = 0.;
    for (i__ = 1; i__ <= 100; ++i__) {
	sce2t_(&c_n9, &et, &sclkdp);
	d__1 = et + off;
	tstatd_(&d__1, matrix, angvel);
	ckgpav_(&c_b175, &sclkdp, &c_b10, "J2000", rot, av, &cout, &fnd, (
		ftnlen)5);
	tstmsg_("#", "Subcase: #. Angle between rotations: #  ", (ftnlen)1, (
		ftnlen)40);
	mxmt_(matrix, rot, temp);
	raxisa_(temp, taxis, &angle);
	tstmsi_(&i__);
	tstmsd_(&angle);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &fnd, &c_true, ok, (ftnlen)5);
	chcksd_("ANGLE", &angle, "~", &c_b10, &c_b55, ok, (ftnlen)5, (ftnlen)
		1);
	chcksd_("CLKOUT", &cout, "=", &sclkdp, &c_b10, ok, (ftnlen)6, (ftnlen)
		1);
	chckad_("ROT", rot, "~/", matrix, &c__9, &c_b132, ok, (ftnlen)3, (
		ftnlen)2);
	chckad_("AV", av, "||", angvel, &c__3, &c_b132, ok, (ftnlen)2, (
		ftnlen)2);
	chckad_("AV", av, "~/", angvel, &c__3, &c_b55, ok, (ftnlen)2, (ftnlen)
		2);
	et += 1e7;
    }
    ckupf_(&ckhand);
    kilfil_("TEST.CK", (ftnlen)7);
    t_success__(ok);
    return 0;
} /* f_tstck3__ */

