/* f_ckw02.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1000 = 1000;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b67 = 4.;
static doublereal c_b68 = 1.;
static doublereal c_b75 = 0.;
static integer c__9 = 9;
static doublereal c_b79 = 1e-14;
static integer c__3 = 3;

/* $Procedure      F_CKW02 ( Family of checks for CKW02 ) */
/* Subroutine */ int f_ckw02__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    doublereal cmat[9]	/* was [3][3] */, emat[9]	/* was [3][3] */;
    integer nrec;
    extern /* Subroutine */ int ckw02_(integer *, doublereal *, doublereal *, 
	    integer *, char *, char *, integer *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, ftnlen, ftnlen);
    integer inst;
    doublereal avvs[12]	/* was [3][4] */, stop[4];
    char segid[42];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ckcls_(integer *), 
	    cklpf_(char *, integer *, ftnlen), ckupf_(integer *), ckopn_(char 
	    *, char *, integer *, integer *, ftnlen, ftnlen);
    logical found;
    doublereal rates[4];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal start[4], quats[16]	/* was [4][4] */;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal av[3];
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal begtim;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), ckgpav_(integer *, 
	    doublereal *, doublereal *, char *, doublereal *, doublereal *, 
	    doublereal *, logical *, ftnlen);
    doublereal endtim, clkout;
    extern /* Subroutine */ int q2m_(doublereal *, doublereal *);
    char ref[8];

/* $ Abstract */

/*     This family of tests checks all CKW02 exceptions and that a good */
/*     Type 1 segment does indeed get written to a file. */

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

/* -    SPICELIB Version 1.2.0, 26-SEP-2005 (BVS) */

/*        This test routine now checks all CKW02 exceptions. */

/* -    SPICELIB Version 1.1.0, 15-FEB-2001 (EDW) */

/*        Altered Test case 2 to use an error tolerance of 1.D-14 */
/*        instead of an exact equality. That test failed due to roundoff */
/*        error (on the order of 1.D-16) when compiled under the */
/*        Macintosh Absoft FORTRAN compiler. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_CKW02", (ftnlen)7);
    kilfil_("ckw02.bc", (ftnlen)8);
    ckopn_("ckw02.bc", "TestCK02", &c__1000, &handle, (ftnlen)8, (ftnlen)8);
    begtim = 2.f;
    endtim = 12.f;
    start[0] = 2.;
    start[1] = 4.;
    start[2] = 8.;
    start[3] = 10.;
    stop[0] = start[1];
    stop[1] = start[2];
    stop[2] = start[3];
    stop[3] = endtim;
    rates[0] = 1.;
    rates[1] = .75;
    rates[2] = .5;
    rates[3] = .25;
    inst = -1002;
    s_copy(ref, "J2000", (ftnlen)8, (ftnlen)5);
    s_copy(segid, "TEST CKTYPE 02", (ftnlen)42, (ftnlen)14);
    nrec = 4;
    quats[0] = 1.;
    quats[1] = 0.;
    quats[2] = 0.;
    quats[3] = 0.;
    quats[4] = cos(.1);
    quats[5] = sin(.1);
    quats[6] = 0.;
    quats[7] = 0.;
    quats[8] = cos(.15);
    quats[9] = sin(.15);
    quats[10] = 0.;
    quats[11] = 0.;
    quats[12] = cos(.25);
    quats[13] = sin(.25);
    quats[14] = 0.;
    quats[15] = 0.;
    avvs[0] = 1.;
    avvs[1] = 0.;
    avvs[2] = 0.;
    avvs[3] = .5;
    avvs[4] = 0.;
    avvs[5] = 0.;
    avvs[6] = .3;
    avvs[7] = 0.;
    avvs[8] = 0.;
    avvs[9] = .2;
    avvs[10] = 0.;
    avvs[11] = 0.;

/*     Check all exceptions. */

    tcase_("Case 1 with invalid number of records.", (ftnlen)38);
    nrec = 0;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDNUMREC)", ok, (ftnlen)20);
    nrec = 4;
    tcase_("Case 2 with invalid number of records.", (ftnlen)38);
    nrec = -1;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDNUMREC)", ok, (ftnlen)20);
    nrec = 4;
    tcase_("Case with invalid descriptor begin time.", (ftnlen)40);
    begtim = 3.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDDESCRTIME)", ok, (ftnlen)23);
    begtim = 2.;
    tcase_("Case with invalid descriptor end time.", (ftnlen)38);
    endtim = 11.f;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDDESCRTIME)", ok, (ftnlen)23);
    endtim = 12.f;
    tcase_("Case with invalid reference frame name.", (ftnlen)39);
    s_copy(ref, "MY_FRAME", (ftnlen)8, (ftnlen)8);
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);
    s_copy(ref, "J2000", (ftnlen)8, (ftnlen)5);
    tcase_("Case with non-printing characters in SEGID.", (ftnlen)43);
    *(unsigned char *)&segid[4] = '\a';
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(NONPRINTABLECHARS)", ok, (ftnlen)24);
    *(unsigned char *)&segid[4] = ' ';
    tcase_("Case with SEGID that is too long.", (ftnlen)33);
    s_copy(segid, "12345678901234567890123456789012345678901", (ftnlen)42, (
	    ftnlen)41);
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(SEGIDTOOLONG)", ok, (ftnlen)19);
    s_copy(segid, "TEST CKTYPE 03", (ftnlen)42, (ftnlen)14);
    tcase_("Case with negative first SCLK time.", (ftnlen)35);
    start[0] = -2.;
    begtim = -2.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDSCLKTIME)", ok, (ftnlen)22);
    start[0] = 2.;
    begtim = 2.;
    tcase_("Case 1 with degenerate first interval.", (ftnlen)38);
    stop[0] = start[0];
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(DEGENERATEINTERVAL)", ok, (ftnlen)25);
    stop[0] = start[1];
    tcase_("Case 2 with degenerate first interval.", (ftnlen)38);
    stop[0] = start[0] - 1.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(DEGENERATEINTERVAL)", ok, (ftnlen)25);
    stop[0] = start[1];
    tcase_("Case 1 with degenerate interval.", (ftnlen)32);
    stop[1] = start[1];
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(DEGENERATEINTERVAL)", ok, (ftnlen)25);
    stop[1] = start[2];
    tcase_("Case 2 with degenerate interval.", (ftnlen)32);
    stop[1] = start[1] - 1.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(DEGENERATEINTERVAL)", ok, (ftnlen)25);
    stop[1] = start[2];
    tcase_("Case 1 with times out of order.", (ftnlen)31);
    start[2] = start[1];
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(TIMESOUTOFORDER)", ok, (ftnlen)22);
    start[2] = 8.;
    tcase_("Case 2 with times out of order.", (ftnlen)31);
    start[2] = start[1] - 1.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(TIMESOUTOFORDER)", ok, (ftnlen)22);
    start[2] = 8.;
    tcase_("Case 2 with bad stop time.", (ftnlen)26);
    stop[1] = start[2] + 1.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(BADSTOPTIME)", ok, (ftnlen)18);
    stop[1] = start[2];
    tcase_("Case with a non-unit quaternion.", (ftnlen)32);
    quats[12] = 0.;
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(NONUNITQUATERNION)", ok, (ftnlen)24);
    quats[12] = cos(.25);

/*     Finally, check one good case. */

    tcase_("All quaternions unit length.", (ftnlen)28);
    ckw02_(&handle, &begtim, &endtim, &inst, ref, segid, &nrec, start, stop, 
	    quats, avvs, rates, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckcls_(&handle);
    cklpf_("ckw02.bc", &handle, (ftnlen)8);
    ckgpav_(&inst, &c_b67, &c_b68, "J2000", cmat, av, &clkout, &found, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("CLKOUT", &clkout, "=", &c_b67, &c_b75, ok, (ftnlen)6, (ftnlen)1);
    q2m_(&quats[4], emat);
    chckad_("CMAT", cmat, "~", emat, &c__9, &c_b79, ok, (ftnlen)4, (ftnlen)1);
    chckad_("AV", av, "~", &avvs[3], &c__3, &c_b79, ok, (ftnlen)2, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    ckupf_(&handle);
    kilfil_("ckw02.bc", (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_ckw02__ */

