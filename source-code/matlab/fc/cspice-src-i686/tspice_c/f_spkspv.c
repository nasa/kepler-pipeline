/* f_spkspv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__16 = 16;
static doublereal c_b29 = 0.;
static integer c__2 = 2;
static integer c__6 = 6;

/* $Procedure      F_SPKSPV ( Family of tests for SPKS15 ) */
/* Subroutine */ int f_spkspv__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    integer oldh, body, newh;
    doublereal last;
    integer nums[6];
    doublereal j2flg;
    integer i__;
    doublereal p;
    char frame[8], segid[80];
    doublereal epoch;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *), spke15_(doublereal *, doublereal *, 
	    doublereal *);
    logical found;
    doublereal myrec[16], state[6];
    extern /* Subroutine */ int topen_(char *, ftnlen), spkr15_(integer *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal first;
    extern /* Subroutine */ int spkw15_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, doublereal *,
	     doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, ftnlen, 
	    ftnlen);
    doublereal j2;
    extern /* Subroutine */ int spkpv_(integer *, doublereal *, doublereal *, 
	    char *, doublereal *, integer *, ftnlen), t_success__(logical *);
    doublereal state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal pa[3], gm;
    extern doublereal pi_(void);
    doublereal et;
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *), chcksd_(char *, 
	    doublereal *, char *, doublereal *, doublereal *, logical *, 
	    ftnlen, ftnlen), chckxc_(logical *, char *, logical *, ftnlen);
    doublereal tp[3], pv[3];
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    doublereal record[20];
    integer center;
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen);
    doublereal radius;
    extern /* Subroutine */ int spkuef_(integer *), spcopn_(char *, char *, 
	    integer *, ftnlen, ftnlen), spksub_(integer *, doublereal *, char 
	    *, doublereal *, doublereal *, integer *, ftnlen), spksfs_(
	    integer *, doublereal *, integer *, doublereal *, char *, logical 
	    *, ftnlen);
    doublereal ecc, dps[2];

/* $ Abstract */

/*     This routine creates an SPK file containing a sinlge SPK type 15 */
/*     segment.  From this it extracts a subsegment.  This subsegment */
/*     is examined for correctness and a state is extracted from */
/*     and compared with an expected state. */

/*     Routines exercised: */

/*        SPKE15 */
/*        SPKR15 */
/*        SPKS15 */
/*        SPKSUB */
/*        SPKW15 */


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

/* -    SPICELIB Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Functions. */

/* -& */

/*     Spicelib Functions */


/*     Local Variables. */

    topen_("F_SPKSPV", (ftnlen)8);

/*     Set up a bunch of initial values. */

    body = -1000;
    center = 399;
    s_copy(frame, "J2000", (ftnlen)8, (ftnlen)5);
    first = 0.;
    last = 1e5;
    s_copy(segid, " ", (ftnlen)80, (ftnlen)1);
    epoch = 1e3;
    j2flg = 0.;
    j2 = .001082616;
    for (i__ = 1; i__ <= 20; ++i__) {
	record[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge("record", 
		i__1, "f_spkspv__", (ftnlen)136)] = 1.;
    }

/*     Set up the data needed for creating a legitimate segment. */

    body = -1000;
    center = 399;
    s_copy(frame, "J2000", (ftnlen)8, (ftnlen)5);
    first = 0.;
    last = 1e5;
    s_copy(segid, " ", (ftnlen)80, (ftnlen)1);
    epoch = 1e3;
    j2flg = 0.;
    j2 = .001082616;
    p = 1e4;
    ecc = .1;
    gm = 398600.447703261138f;
    tp[0] = 0.;
    tp[1] = cos(pi_() / 6.);
    tp[2] = sin(pi_() / 6.);
    pa[0] = 0.;
    pa[1] = sin(pi_() / 6.);
    pa[2] = -cos(pi_() / 6.);
    pv[0] = 0.;
    pv[1] = 0.;
    pv[2] = 1.;
    radius = 6378.184;
    s_copy(segid, "Test segment", (ftnlen)80, (ftnlen)12);

/*     Copy the record we expect to be in the SPK file. */

    myrec[0] = epoch;
    myrec[1] = tp[0];
    myrec[2] = tp[1];
    myrec[3] = tp[2];
    myrec[4] = pa[0];
    myrec[5] = pa[1];
    myrec[6] = pa[2];
    myrec[7] = p;
    myrec[8] = ecc;
    myrec[9] = j2flg;
    myrec[10] = pv[0];
    myrec[11] = pv[1];
    myrec[12] = pv[2];
    myrec[13] = gm;
    myrec[14] = j2;
    myrec[15] = radius;
    tcase_("Bad Time range exception.", (ftnlen)25);

/*        delete any existing test SPK file. */

    kilfil_("t_spks15.bsp", (ftnlen)12);
    spcopn_("t_spks15.bsp", "testSPK", &handle, (ftnlen)12, (ftnlen)7);
    first = 1e3;
    last = 1e5;
    et = (first + last) / 2.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spklef_("t_spks15.bsp", &oldh, (ftnlen)12);
    spksfs_(&body, &et, &oldh, descr, segid, &found, (ftnlen)80);
    kilfil_("spksub15.bsp", (ftnlen)12);
    spcopn_("spksub15.bsp", "testSPK", &newh, (ftnlen)12, (ftnlen)7);
    first += -1e3;
    last += 1e3;
    spksub_(&oldh, descr, segid, &first, &last, &newh, (ftnlen)80);
    chckxc_(&c_true, "SPICE(SPKNOTASUBSET)", ok, (ftnlen)20);
    tcase_("Extracting a subsegment", (ftnlen)23);
    first += 2e3;
    last += -2e3;
    spksub_(&oldh, descr, segid, &first, &last, &newh, (ftnlen)80);
    dafcls_(&newh);

/*        No errors should have been signalled so far. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Load the subsetted ephemeris. */

    spkuef_(&oldh);
    spklef_("spksub15.bsp", &newh, (ftnlen)12);

/*        Look for data for this item. */

    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)80);
    spkr15_(&handle, descr, &et, record);

/*        The data in the record should be identical to the one we */
/*        stored earlier. */

    chckad_("RECORD", record, "=", myrec, &c__16, &c_b29, ok, (ftnlen)6, (
	    ftnlen)1);

/*        The stop and end times should be what we set them to earlier. */

    dafus_(descr, &c__2, &c__6, dps, nums);
    chcksd_("FIRST", &first, "=", dps, &c_b29, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("LAST", &last, "=", &dps[1], &c_b29, ok, (ftnlen)4, (ftnlen)1);
    tcase_("State Evaluation using SPKPV", (ftnlen)28);
    spkpv_(&handle, descr, &et, "J2000", state, &center, (ftnlen)5);
    spke15_(&et, record, state2);
    chckad_("STATE", state, "=", state2, &c__6, &c_b29, ok, (ftnlen)5, (
	    ftnlen)1);

/*     When we've finished all tests, delete the .bsp files we created. */

    spkuef_(&newh);
    kilfil_("t_spks15.bsp", (ftnlen)12);
    kilfil_("spksub15.bsp", (ftnlen)12);
    t_success__(ok);
    return 0;
} /* f_spkspv__ */

