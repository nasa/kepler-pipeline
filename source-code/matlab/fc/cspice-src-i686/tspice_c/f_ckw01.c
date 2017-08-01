/* f_ckw01.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1000 = 1000;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b52 = 4.;
static doublereal c_b53 = 1.;
static doublereal c_b60 = 0.;
static integer c__9 = 9;
static integer c__3 = 3;

/* $Procedure      F_CKW01 ( Family of checks for CKW01 ) */
/* Subroutine */ int f_ckw01__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    doublereal cmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int ckw01_(integer *, doublereal *, doublereal *, 
	    integer *, char *, logical *, char *, integer *, doublereal *, 
	    doublereal *, doublereal *, ftnlen, ftnlen);
    doublereal emat[9]	/* was [3][3] */;
    integer nrec, inst;
    doublereal avvs[12]	/* was [3][4] */;
    char segid[42];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ckcls_(integer *), 
	    cklpf_(char *, integer *, ftnlen), ckupf_(integer *), ckopn_(char 
	    *, char *, integer *, integer *, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal quats[16]	/* was [4][4] */;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal av[3];
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    logical avflag;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    doublereal begtim;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), ckgpav_(integer *, 
	    doublereal *, doublereal *, char *, doublereal *, doublereal *, 
	    doublereal *, logical *, ftnlen);
    doublereal endtim, sclkdp[4], clkout;
    extern /* Subroutine */ int q2m_(doublereal *, doublereal *);
    char ref[8];

/* $ Abstract */

/*     This family of tests checks all CKW01 exceptions and that a good */
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

/* -    SPICELIB Version 1.1.0, 26-SEP-2005 (BVS) */

/*        This test routine now checks all CKW01 exceptions. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_CKW01", (ftnlen)7);
    kilfil_("ckw01.bc", (ftnlen)8);
    ckopn_("ckw01.bc", "TestCK01", &c__1000, &handle, (ftnlen)8, (ftnlen)8);
    begtim = 1.f;
    endtim = 12.f;
    sclkdp[0] = 2.;
    sclkdp[1] = 4.;
    sclkdp[2] = 8.;
    sclkdp[3] = 10.;
    inst = -1001;
    s_copy(ref, "J2000", (ftnlen)8, (ftnlen)5);
    s_copy(segid, "TEST CKTYPE 01", (ftnlen)42, (ftnlen)14);
    avflag = TRUE_;
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
    nrec = 4;

/*     Check all exceptions. */

    tcase_("Case 1 with invalid number of records.", (ftnlen)38);
    nrec = 0;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDNUMREC)", ok, (ftnlen)20);
    nrec = 4;
    tcase_("Case 2 with invalid number of records.", (ftnlen)38);
    nrec = -1;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDNUMREC)", ok, (ftnlen)20);
    nrec = 4;
    tcase_("Case with invalid descriptor begin time.", (ftnlen)40);
    begtim = 3.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDDESCRTIME)", ok, (ftnlen)23);
    begtim = 2.;
    tcase_("Case with invalid descriptor end time.", (ftnlen)38);
    endtim = 9.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDDESCRTIME)", ok, (ftnlen)23);
    endtim = 10.;
    tcase_("Case with invalid reference frame name.", (ftnlen)39);
    s_copy(ref, "MY_FRAME", (ftnlen)8, (ftnlen)8);
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);
    s_copy(ref, "J2000", (ftnlen)8, (ftnlen)5);
    tcase_("Case with non-printing characters in SEGID.", (ftnlen)43);
    *(unsigned char *)&segid[4] = '\a';
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(NONPRINTABLECHARS)", ok, (ftnlen)24);
    *(unsigned char *)&segid[4] = ' ';
    tcase_("Case with SEGID that is too long.", (ftnlen)33);
    s_copy(segid, "12345678901234567890123456789012345678901", (ftnlen)42, (
	    ftnlen)41);
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(SEGIDTOOLONG)", ok, (ftnlen)19);
    s_copy(segid, "TEST CKTYPE 03", (ftnlen)42, (ftnlen)14);
    tcase_("Case with negative first SCLK time.", (ftnlen)35);
    sclkdp[0] = -2.;
    begtim = -2.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(INVALIDSCLKTIME)", ok, (ftnlen)22);
    sclkdp[0] = 2.;
    begtim = 2.;
    tcase_("Case 1 with SCLK times out of order.", (ftnlen)36);
    sclkdp[1] = 8.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(TIMESOUTOFORDER)", ok, (ftnlen)22);
    sclkdp[1] = 4.;
    tcase_("Case 2 with SCLK times out of order.", (ftnlen)36);
    sclkdp[1] = 9.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(TIMESOUTOFORDER)", ok, (ftnlen)22);
    sclkdp[1] = 4.;
    tcase_("Case with a non-unit quaternion.", (ftnlen)32);
    quats[12] = 0.;
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_true, "SPICE(NONUNITQUATERNION)", ok, (ftnlen)24);
    quats[12] = cos(.25);

/*     Finally, check one good case. */

    tcase_("All quaternions unit length.", (ftnlen)28);
    ckw01_(&handle, &begtim, &endtim, &inst, ref, &avflag, segid, &nrec, 
	    sclkdp, quats, avvs, (ftnlen)8, (ftnlen)42);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckcls_(&handle);
    cklpf_("ckw01.bc", &handle, (ftnlen)8);
    ckgpav_(&inst, &c_b52, &c_b53, "J2000", cmat, av, &clkout, &found, (
	    ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("CLKOUT", &clkout, "=", &c_b52, &c_b60, ok, (ftnlen)6, (ftnlen)1);
    q2m_(&quats[4], emat);
    chckad_("CMAT", cmat, "=", emat, &c__9, &c_b60, ok, (ftnlen)4, (ftnlen)1);
    chckad_("AV", av, "=", &avvs[3], &c__3, &c_b60, ok, (ftnlen)2, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    ckupf_(&handle);
    kilfil_("ckw01.bc", (ftnlen)8);
    t_success__(ok);
    return 0;
} /* f_ckw01__ */

