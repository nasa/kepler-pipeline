/* f_spkf15.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__17 = 17;
static logical c_false = FALSE_;
static integer c__2 = 2;
static integer c__6 = 6;
static integer c__16 = 16;
static doublereal c_b76 = 1e-14;

/* $Procedure      F_SPKF15 ( Family of tests for SPKW15 and SPKR15 ) */
/* Subroutine */ int f_spkf15__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    integer body;
    doublereal last;
    integer type__, nums[6];
    doublereal j2flg;
    integer i__;
    doublereal p;
    char frame[8], segid[80];
    extern /* Subroutine */ int dafps_(integer *, integer *, doublereal *, 
	    integer *, doublereal *);
    doublereal epoch;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    logical found;
    doublereal myrec[16];
    extern /* Subroutine */ int topen_(char *, ftnlen), spkr15_(integer *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal first;
    extern /* Subroutine */ int spkw15_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, doublereal *,
	     doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, ftnlen, 
	    ftnlen);
    doublereal j2;
    extern /* Subroutine */ int t_success__(logical *), dafada_(doublereal *, 
	    integer *), dafbna_(integer *, doublereal *, char *, ftnlen), 
	    chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), dafena_(void);
    doublereal pa[3], gm;
    extern doublereal pi_(void);
    doublereal et;
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *), chckxc_(logical *, char *,
	     logical *, ftnlen);
    doublereal tp[3], pv[3];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    doublereal record[20];
    integer center, spkhan;
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen);
    doublereal radius;
    extern /* Subroutine */ int spkuef_(integer *), spcopn_(char *, char *, 
	    integer *, ftnlen, ftnlen), spkpds_(integer *, integer *, char *, 
	    integer *, doublereal *, doublereal *, doublereal *, ftnlen), 
	    spksfs_(integer *, doublereal *, integer *, doublereal *, char *, 
	    logical *, ftnlen);
    doublereal ecc, dps[2];

/* $ Abstract */

/*     This routine test the cited exceptions of SPKW15 and then */
/*     creates an SPK file containing a single segment of type 15. */

/*     This segment is read using SPKSFS to find the segment and */
/*     read its contents via SPKR15. */

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

    topen_("F_SPKF15", (ftnlen)8);

/*     delete any existing test SPK file. */

    kilfil_("t_spkw15.bsp", (ftnlen)12);
    spcopn_("t_spkw15.bsp", "testSPK", &handle, (ftnlen)12, (ftnlen)7);

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
		i__1, "f_spkf15__", (ftnlen)128)] = 1.;
    }
    body = -1000;
    center = 399;
    s_copy(frame, "J2000", (ftnlen)8, (ftnlen)5);
    first = 0.;
    last = 1e5;
    s_copy(segid, " ", (ftnlen)80, (ftnlen)1);
    epoch = 1e3;
    j2flg = 0.;
    j2 = .001082616;

/*     The semi-latus rectum is supposed to be positive.  Start */
/*     out at zero and then set it to something reasonable. */

    tcase_("Semi-latus rectum exception", (ftnlen)27);
    p = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADLATUSRECTUM)", ok, (ftnlen)21);
    p = 1e4;

/*     Negative eccentricities should produce exceptions.  After */
/*     checking that this is so set the eccentricity to something */
/*     yielding a periodic orbit. */

    tcase_("Eccentricity Exception", (ftnlen)22);
    ecc = -1.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADECCENTRICITY)", ok, (ftnlen)22);
    ecc = .1;

/*     The central mass must be positive.  Zero or less should */
/*     trigger an exception. Try zero and -1.  After that we */
/*     use the mass of the earth. */

    tcase_("Central Mass Exception --- mass 0", (ftnlen)33);
    gm = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(NONPOSITIVEMASS)", ok, (ftnlen)22);
    tcase_("Central Mass Exception --- mass -1", (ftnlen)34);
    gm = -1.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(NONPOSITIVEMASS)", ok, (ftnlen)22);
    gm = 398600.447703261138f;

/*     Only a zero trajectory pole can produce a problem.  By */
/*     construction we already have one. */

    tcase_("Trajectory Pole Exception", (ftnlen)25);
    tp[0] = 0.;
    tp[1] = 0.;
    tp[2] = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADVECTOR)", ok, (ftnlen)16);

/*        Set the trajectory pole to 45 degree inclination */

    tp[0] = 0.;
    tp[1] = cos(pi_() / 6.);
    tp[2] = sin(pi_() / 6.);

/*     Only a zero periapsis vector yields an exception.  We */
/*     already have this by construction.  After testing make */
/*     a periapsis vector that is orthogonal to the trajectory */
/*     pole vector. */

    tcase_("Periapsis Vector Exception", (ftnlen)26);
    pa[0] = 0.;
    pa[1] = 0.;
    pa[2] = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADVECTOR)", ok, (ftnlen)16);
    pa[0] = 0.;
    pa[1] = sin(pi_() / 6.);
    pa[2] = -cos(pi_() / 6.);

/*     Only a zero central body pole vector can yield an exception. */
/*     We have such a situation by construction.  After checking */
/*     this, align the pole with the Z axis. */

    tcase_("Pole Vector Exception", (ftnlen)21);
    pv[0] = 0.;
    pv[1] = 0.;
    pv[2] = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADVECTOR)", ok, (ftnlen)16);
    pv[2] = 1.;

/*     Anything less than zero should trigger an exception.  After */
/*     checking, set the equatorial radius to that of the earth. */

    tcase_("Equatorial Radius Exception", (ftnlen)27);
    radius = -1.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADRADIUS)", ok, (ftnlen)16);
    radius = 6378.184;

/*     If the periapse is not nearly perpepndicular to the */
/*     trajectory pole, we should get an exception.  Create */
/*     a vector that isn't perpendicular to the trajectory pole */
/*     by messing up the sign on the z-component. */

    tcase_("Bad Initial Conditions", (ftnlen)22);
    pa[0] = 0.;
    pa[1] = 1.;
    pa[2] = 0.;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(BADINITSTATE)", ok, (ftnlen)19);
    pa[0] = 0.;
    pa[1] = sin(pi_() / 6.);
    pa[2] = -cos(pi_() / 6.);
    tcase_("Segment Identifier too long", (ftnlen)27);
    s_copy(segid, "This is a very, very, very long segment identifier ", (
	    ftnlen)80, (ftnlen)51);
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(SEGIDTOOLONG)", ok, (ftnlen)19);
    tcase_("Non-Printing Characters Exception", (ftnlen)33);
    s_copy(segid, "This is a \ttest segment", (ftnlen)80, (ftnlen)23);
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);
    chckxc_(&c_true, "SPICE(NONPRINTABLECHARS)", ok, (ftnlen)24);
    s_copy(segid, "Test segment", (ftnlen)80, (ftnlen)12);

/*     That takes care of all noted excpetions in  SPKW15. */
/*     Write a legitimate segment and close the SPK file. */

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
    tcase_("Writing a segment", (ftnlen)17);
    first = 1e3;
    last = 1e5;
    spkw15_(&handle, &body, &center, frame, &first, &last, segid, &epoch, tp, 
	    pa, &p, &ecc, &j2flg, pv, &gm, &j2, &radius, (ftnlen)8, (ftnlen)
	    80);

/*        In addition we write a bogus segment with the wrong amount */
/*        of data in it and call it type 15. */

    first = -1e5;
    last = -1e3;
    type__ = 15;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    dafbna_(&handle, descr, "Bogus Segment", (ftnlen)13);
    dafada_(record, &c__17);
    dafena_();
    dafcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Corrupt the descriptor in the type component of the segment */
/*     and make sure that SPKR15 properly diagnoses the problem. */

    tcase_("SPKR15 bad type exception.", (ftnlen)26);
    et = 2e3;
    spklef_("t_spkw15.bsp", &spkhan, (ftnlen)12);
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)80);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    if (*ok) {
	dafus_(descr, &c__2, &c__6, dps, nums);
	nums[3] = 14;
	dafps_(&c__2, &c__6, dps, nums, descr);
	spkr15_(&handle, descr, &et, record);
	chckxc_(&c_true, "SPICE(WRONGSPKTYPE)", ok, (ftnlen)19);
    }

/*     Recall that the second segment we wrote had too much data. */
/*     and had time bounds from -100000 to -1000.  We find that */
/*     segment next and make sure that the badly formed segment */
/*     is handled properly. */

    tcase_("SPKR15 bad segment exception.", (ftnlen)29);
    et = -2e3;
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)80);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    if (*ok) {
	spkr15_(&handle, descr, &et, record);
	chckxc_(&c_true, "SPICE(MALFORMEDSEGMENT)", ok, (ftnlen)23);
    }
    tcase_("SPKR15 checking segment values.", (ftnlen)31);
    et = 2e3;
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)80);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    if (*ok) {
	spkr15_(&handle, descr, &et, record);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("RECORD", record, "=", myrec, &c__16, &c_b76, ok, (ftnlen)6, (
		ftnlen)1);
    }

/*     When we've finished all tests, delete the .bsp file we created. */

    spkuef_(&spkhan);
    kilfil_("t_spkw15.bsp", (ftnlen)12);
    t_success__(ok);
    return 0;
} /* f_spkf15__ */

