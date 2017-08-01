/* f_spkw01.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static logical c_true = TRUE_;
static integer c__1 = 1;
static logical c_false = FALSE_;
static integer c__2 = 2;
static integer c__6 = 6;
static doublereal c_b89 = 0.;
static integer c__71 = 71;
static integer c__14 = 14;

/* $Procedure      F_SPKW01 ( SPKW01 routine tests ) */
/* Subroutine */ int f_spkw01__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static integer body;
    static doublereal last, t1rec[71];
    static integer i__, j, n;
    static char label[80];
    extern /* Subroutine */ int dafgs_(doublereal *);
    static char frame[32], segid[80];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    static doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    static doublereal tbuff[10000];
    extern /* Subroutine */ int repmd_(char *, char *, doublereal *, integer *
	    , char *, ftnlen, ftnlen, ftnlen);
    static logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), spkr01_(integer *, doublereal *, 
	    doublereal *, doublereal *), topen_(char *, ftnlen), spkw01_(
	    integer *, integer *, integer *, char *, doublereal *, doublereal 
	    *, char *, integer *, doublereal *, doublereal *, ftnlen, ftnlen);
    static doublereal first;
    extern /* Subroutine */ int t_success__(logical *);
    static doublereal dc[2];
    static integer ic[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     daffna_(logical *), dafbfs_(integer *);
    static doublereal et;
    static integer handle;
    extern /* Subroutine */ int dafcls_(integer *), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), delfil_(char *, ftnlen);
    static doublereal dlbuff[710000]	/* was [71][10000] */;
    static integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), dafopr_(char *, integer *, ftnlen);
    static integer center;
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen), spkopa_(
	    char *, integer *, ftnlen), spkcls_(integer *), spkopn_(char *, 
	    char *, integer *, integer *, ftnlen, ftnlen);

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        SPKW01 */

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

/* -    SPICELIB Version 1.0.2, 19-OCT-2004 (EDW) */

/*       Added SAVE statement for f2c conversion to */
/*       run on Cygwin. */

/* -    SPICELIB Version 1.0.1, 27-FEB-2003 (BVS) */

/*        Changed 0 to 0.D0 in CHCKSD calls. */

/* -    SPICELIB Version 1.0.0, 29-JAN-2003 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPKW01", (ftnlen)8);

/*     Open a new SPK file for writing. */

    tcase_("Setup:  open a new SPK file for writing.", (ftnlen)40);
    spkopn_("spk_test_01.bsp", " ", &c__0, &handle, (ftnlen)15, (ftnlen)1);

/*     Initialize the time and data buffers with values that are */
/*     recognizable but otherwise bogus. */

    for (i__ = 1; i__ <= 10000; ++i__) {
	tbuff[(i__1 = i__ - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", 
		i__1, "f_spkw01__", (ftnlen)144)] = i__ * 1e3;
	for (j = 1; j <= 71; ++j) {
	    dlbuff[(i__1 = j + i__ * 71 - 72) < 710000 && 0 <= i__1 ? i__1 : 
		    s_rnge("dlbuff", i__1, "f_spkw01__", (ftnlen)148)] = 
		    tbuff[(i__2 = i__ - 1) < 10000 && 0 <= i__2 ? i__2 : 
		    s_rnge("tbuff", i__2, "f_spkw01__", (ftnlen)148)] + j;
	}
    }

/*     Pick body, center, and frame. */

    body = 3;
    center = 10;
    s_copy(frame, "J2000", (ftnlen)32, (ftnlen)5);

/*     Initial difference line count. */

    n = 100;

/*     Pick nominal time bounds. */

    first = 0.;
    last = tbuff[(i__1 = n - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", 
	    i__1, "f_spkw01__", (ftnlen)170)];

/*     Initialize segment identifier. */

    s_copy(segid, "spkw01 test segment", (ftnlen)80, (ftnlen)19);

/*     Error test cases follow. */

    tcase_("Invalid frame.", (ftnlen)14);
    spkw01_(&handle, &body, &center, "XXX", &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)3, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);
    tcase_("SEGID too long.", (ftnlen)15);
    s_copy(segid, "1234567890123456789012345678912345678901234567890", (
	    ftnlen)80, (ftnlen)49);
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(SEGIDTOOLONG)", ok, (ftnlen)19);
    tcase_("SEGID contains non-printable characters.", (ftnlen)40);
    s_copy(segid, "spkw01 test segment", (ftnlen)80, (ftnlen)19);
    *(unsigned char *)&segid[4] = '\a';
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(NONPRINTABLECHARS)", ok, (ftnlen)24);
    tcase_("Invalid difference line count", (ftnlen)29);
    s_copy(segid, "spkw01 test segment", (ftnlen)80, (ftnlen)19);
    n = 0;
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDCOUNT)", ok, (ftnlen)19);
    n = -1;
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(INVALIDCOUNT)", ok, (ftnlen)19);
    n = 100;
    tcase_("Descriptor times out of order", (ftnlen)29);
    first = last + 1.;
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);
    first = 0.;
    tcase_("epochs out of order", (ftnlen)19);
    et = tbuff[2];
    tbuff[2] = tbuff[1];
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(TIMESOUTOFORDER)", ok, (ftnlen)22);
    tbuff[2] = et;
    tcase_("Gap following last epoch", (ftnlen)24);
    et = tbuff[(i__1 = n - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", 
	    i__1, "f_spkw01__", (ftnlen)266)];
    tbuff[(i__1 = n - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", i__1, 
	    "f_spkw01__", (ftnlen)267)] = tbuff[(i__2 = n - 1) < 10000 && 0 <=
	     i__2 ? i__2 : s_rnge("tbuff", i__2, "f_spkw01__", (ftnlen)267)] 
	    - 1e-6;
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);
    tbuff[(i__1 = n - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", i__1, 
	    "f_spkw01__", (ftnlen)274)] = et;

/*     Normal cases: */

    tcase_("Make sure segment containing one difference line is readable.", (
	    ftnlen)61);
    last = tbuff[0];
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &c__1, 
	    dlbuff, tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafopr_("spk_test_01.bsp", &handle, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("Segment found", &found, &c_true, ok, (ftnlen)13);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafus_(descr, &c__2, &c__6, dc, ic);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the descriptor. */

    namfrm_(frame, &frcode, (ftnlen)32);
    chcksi_("Body", ic, "=", &body, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("Center", &ic[1], "=", &center, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("Frame", &ic[2], "=", &frcode, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("Data type", &ic[3], "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    chcksd_("Start time", dc, "=", &first, &c_b89, ok, (ftnlen)10, (ftnlen)1);
    chcksd_("Stop time", &dc[1], "=", &last, &c_b89, ok, (ftnlen)9, (ftnlen)1)
	    ;

/*     Look up the data and compare it to what we put in.  We */
/*     expect an exact match. */

    spkr01_(&handle, descr, tbuff, t1rec);
    chckad_("Diff line", t1rec, "=", dlbuff, &c__71, &c_b89, ok, (ftnlen)9, (
	    ftnlen)1);
    spkcls_(&handle);

/*     Repeat the test with DLMAX records.  The new segment will mask */
/*     the previous one. */

    spkopa_("spk_test_01.bsp", &handle, (ftnlen)15);
    n = 10000;
    last = tbuff[(i__1 = n - 1) < 10000 && 0 <= i__1 ? i__1 : s_rnge("tbuff", 
	    i__1, "f_spkw01__", (ftnlen)348)];
    spkw01_(&handle, &body, &center, frame, &first, &last, segid, &n, dlbuff, 
	    tbuff, (ftnlen)32, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Open the file for read access; find the 2nd descriptor. */

    dafopr_("spk_test_01.bsp", &handle, (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafbfs_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    daffna_(&found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("Segment found", &found, &c_true, ok, (ftnlen)13);
    dafgs_(descr);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafus_(descr, &c__2, &c__6, dc, ic);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the descriptor. */

    namfrm_(frame, &frcode, (ftnlen)32);
    chcksi_("Body", ic, "=", &body, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("Center", &ic[1], "=", &center, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("Frame", &ic[2], "=", &frcode, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("Data type", &ic[3], "=", &c__1, &c__0, ok, (ftnlen)9, (ftnlen)1);
    chcksd_("Start time", dc, "=", &first, &c_b89, ok, (ftnlen)10, (ftnlen)1);
    chcksd_("Stop time", &dc[1], "=", &last, &c_b89, ok, (ftnlen)9, (ftnlen)1)
	    ;

/*     Look up the data and compare it to what we put in.  We */
/*     expect an exact match. */

    i__1 = n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(label, "Difference line number *, time *", (ftnlen)80, (ftnlen)
		32);
	repmi_(label, "*", &i__, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	repmd_(label, "*", &tbuff[(i__2 = i__ - 1) < 10000 && 0 <= i__2 ? 
		i__2 : s_rnge("tbuff", i__2, "f_spkw01__", (ftnlen)405)], &
		c__14, label, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	spkr01_(&handle, descr, &tbuff[(i__2 = i__ - 1) < 10000 && 0 <= i__2 ?
		 i__2 : s_rnge("tbuff", i__2, "f_spkw01__", (ftnlen)407)], 
		t1rec);
	chckad_(label, t1rec, "=", &dlbuff[(i__2 = i__ * 71 - 71) < 710000 && 
		0 <= i__2 ? i__2 : s_rnge("dlbuff", i__2, "f_spkw01__", (
		ftnlen)409)], &c__71, &c_b89, ok, (ftnlen)80, (ftnlen)1);
    }

/*     Close and delete the SPK file. */

    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("spk_test_01.bsp", (ftnlen)15);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_spkw01__ */

