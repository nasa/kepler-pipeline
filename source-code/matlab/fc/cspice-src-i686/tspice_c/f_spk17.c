/* f_spk17.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1000 = 1000;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c_n1000 = -1000;
static integer c__0 = 0;
static integer c__399 = 399;
static integer c__2 = 2;
static integer c__17 = 17;
static integer c__12 = 12;
static doublereal c_b48 = -1e9;
static doublereal c_b49 = 0.;
static doublereal c_b52 = 1e9;
static integer c__6 = 6;
static doublereal c_b106 = -1e8;
static doublereal c_b110 = 1e8;

/* $Procedure      F_SPK17 ( Family of tests for the SPK type 17 code) */
/* Subroutine */ int f_spk17__(logical *ok)
{
    /* Builtin functions */
    double sqrt(doublereal), sin(doublereal), cos(doublereal), tan(doublereal)
	    ;
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal node, eqel[9], argp;
    integer body, newh;
    doublereal last;
    integer type__, spkh2;
    doublereal a;
    integer i__;
    doublereal n, p;
    integer begin;
    char frame[32], segid[40];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    logical found;
    doublereal rapol;
    integer nelts;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal first;
    extern /* Subroutine */ int spkw17_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, doublereal *,
	     doublereal *, doublereal *, ftnlen, ftnlen);
    doublereal m0, t0;
    extern /* Subroutine */ int t_success__(logical *);
    doublereal state1[6], state2[6];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal gm, et;
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen);
    doublereal decpol;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    doublereal fivdpd, tendpd;
    integer center, spkhan;
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen), eqncpv_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), spkuef_(integer *), spkcls_(integer *
	    ), spksub_(integer *, doublereal *, char *, doublereal *, 
	    doublereal *, integer *, ftnlen), spksfs_(integer *, doublereal *,
	     integer *, doublereal *, char *, logical *, ftnlen), spkopn_(
	    char *, char *, integer *, integer *, ftnlen, ftnlen), spkuds_(
	    doublereal *, integer *, integer *, integer *, integer *, 
	    doublereal *, doublereal *, integer *, integer *), spkpvn_(
	    integer *, doublereal *, doublereal *, integer *, doublereal *, 
	    integer *);
    doublereal ecc;
    integer end;
    doublereal inc;
    integer ref;
    extern doublereal rpd_(void);

/* $ Abstract */

/*     This routine tests the writing and reading of type 17 */
/*     SPK segments. */

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

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPK17", (ftnlen)7);

/*     First delete our sample files (if they exists) and */
/*     open our first new file for writing. */

    kilfil_("spk17.bsp", (ftnlen)9);
    kilfil_("spk17_2.bsp", (ftnlen)11);
    spkopn_("spk17.bsp", "TEST", &c__1000, &handle, (ftnlen)9, (ftnlen)4);

/*     Here are some constants we'll want later, 10 and */
/*     5 degrees/day. */

    fivdpd = rpd_() * 5.7870370370370373e-5;
    tendpd = rpd_() * 1.1574074074074075e-4;
    tcase_("Make sure that an error is signalled if the semi-major axis is n"
	    "on-positive. ", (ftnlen)77);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    a = -a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd + tendpd;
    eqel[7] = n + fivdpd + tendpd;
    eqel[8] = tendpd;
    rapol = rpd_() * 30.f;
    decpol = rpd_() * 60.f;
    body = -1000;
    s_copy(segid, "PHOENIX", (ftnlen)40, (ftnlen)7);
    center = 399;
    s_copy(frame, "B1950", (ftnlen)32, (ftnlen)5);
    first = -1e9;
    last = 1e9;
    et = 0.;
    spkw17_(&handle, &body, &center, frame, &first, &last, segid, &t0, eqel, &
	    rapol, &decpol, (ftnlen)32, (ftnlen)40);
    chckxc_(&c_true, "SPICE(BADSEMIAXIS)", ok, (ftnlen)18);
    tcase_("Make sure an error is signalled if the eccentricity is greater t"
	    "han 0.9 ", (ftnlen)72);
    p = 1e4;
    gm = 398600.436;
    ecc = .91;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd + tendpd;
    eqel[7] = n + fivdpd + tendpd;
    eqel[8] = tendpd;
    rapol = rpd_() * 30.f;
    decpol = rpd_() * 60.f;
    body = -1000;
    s_copy(segid, "PHOENIX", (ftnlen)40, (ftnlen)7);
    center = 399;
    s_copy(frame, "B1950", (ftnlen)32, (ftnlen)5);
    first = -1e9;
    last = 1e9;
    et = 0.;
    spkw17_(&handle, &body, &center, frame, &first, &last, segid, &t0, eqel, &
	    rapol, &decpol, (ftnlen)32, (ftnlen)40);
    chckxc_(&c_true, "SPICE(BADECCENTRICITY)", ok, (ftnlen)22);
    tcase_("Write and read a type 17 kernel.", (ftnlen)32);
    p = 1e4;
    gm = 398600.436;
    ecc = .1;
    a = p / (1. - ecc);
    n = sqrt(gm / a) / a;
    argp = rpd_() * 30.;
    node = rpd_() * 15.;
    inc = rpd_() * 10.;
    m0 = rpd_() * 45.;
    t0 = -1e8;

/*        We want a rate for the node of 10 degrees/day and */
/*        for the argument of periapse of 5 degrees/day. */

    fivdpd = rpd_() * 5.7870370370370373e-5;
    tendpd = rpd_() * 1.1574074074074075e-4;
    eqel[0] = a;
    eqel[1] = ecc * sin(argp + node);
    eqel[2] = ecc * cos(argp + node);
    eqel[3] = m0 + argp + node;
    eqel[4] = tan(inc / 2.) * sin(node);
    eqel[5] = tan(inc / 2.) * cos(node);
    eqel[6] = fivdpd + tendpd;
    eqel[7] = n + fivdpd + tendpd;
    eqel[8] = tendpd;
    rapol = rpd_() * 30.f;
    decpol = rpd_() * 60.f;
    body = -1000;
    s_copy(segid, "PHOENIX", (ftnlen)40, (ftnlen)7);
    center = 399;
    s_copy(frame, "B1950", (ftnlen)32, (ftnlen)5);
    first = -1e9;
    last = 1e9;
    et = 0.;
    spkw17_(&handle, &body, &center, frame, &first, &last, segid, &t0, eqel, &
	    rapol, &decpol, (ftnlen)32, (ftnlen)40);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spklef_("spk17.bsp", &spkhan, (ftnlen)9);
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)40);
    spkuds_(descr, &body, &center, &ref, &type__, &first, &last, &begin, &end)
	    ;
    nelts = end - begin + 1;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("BODY", &body, "=", &c_n1000, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENTER", &center, "=", &c__399, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("FRAME", &ref, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("TYPE", &type__, "=", &c__17, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("NELTS", &nelts, "=", &c__12, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("FIRST", &first, "=", &c_b48, &c_b49, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("LAST", &last, "=", &c_b52, &c_b49, ok, (ftnlen)4, (ftnlen)1);
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state1);
	spkpvn_(&handle, descr, &et, &ref, state2, &center);
	chcksi_("CENTER", &center, "=", &c__399, &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	chcksi_("FRAME", &ref, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
	chckad_("STATE", state1, "=", state2, &c__6, &c_b49, ok, (ftnlen)5, (
		ftnlen)1);
    }
    spkuef_(&spkhan);
    tcase_("Make sure we can successfully subset this the segment we just cr"
	    "eated. ", (ftnlen)71);
    kilfil_("spk17_2.bsp", (ftnlen)11);
    spklef_("spk17.bsp", &spkhan, (ftnlen)9);
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)40);
    spkopn_("spk17_2.bsp", "TEST2", &c__1000, &newh, (ftnlen)11, (ftnlen)5);
    s_copy(segid, "PHOENIX-2", (ftnlen)40, (ftnlen)9);
    first = -1e8;
    last = 1e8;
    spksub_(&handle, descr, segid, &first, &last, &newh, (ftnlen)40);
    spkcls_(&newh);
    spkuef_(&spkhan);

/*        Make sure no errors have occured in the subsetting */
/*        portion of the code. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Now load the new file and make sure we get correct states. */

    spklef_("spk17_2.bsp", &spkh2, (ftnlen)11);

/*        First make sure that we don't find a segment when one */
/*        is not available. */

    et = 1.1e8;
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)40);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    et = -1.1e8;
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)40);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*        Next make sure we get correct states. */

    et = 0.;
    spksfs_(&body, &et, &handle, descr, segid, &found, (ftnlen)40);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    spkuds_(descr, &body, &center, &ref, &type__, &first, &last, &begin, &end)
	    ;
    nelts = end - begin + 1;
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("BODY", &body, "=", &c_n1000, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENTER", &center, "=", &c__399, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("FRAME", &ref, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("TYPE", &type__, "=", &c__17, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("NELTS", &nelts, "=", &c__12, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("FIRST", &first, "=", &c_b106, &c_b49, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("LAST", &last, "=", &c_b110, &c_b49, ok, (ftnlen)4, (ftnlen)1);
    et = t0 - 1e4;
    for (i__ = 1; i__ <= 100; ++i__) {
	et += 250.;
	eqncpv_(&et, &t0, eqel, &rapol, &decpol, state1);
	spkpvn_(&handle, descr, &et, &ref, state2, &center);
	chcksi_("CENTER", &center, "=", &c__399, &c__0, ok, (ftnlen)6, (
		ftnlen)1);
	chcksi_("FRAME", &ref, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
	chckad_("STATE", state1, "=", state2, &c__6, &c_b49, ok, (ftnlen)5, (
		ftnlen)1);
    }
    spkuef_(&spkh2);
    spkuef_(&spkhan);
    kilfil_("spk17.bsp", (ftnlen)9);
    kilfil_("spk17_2.bsp", (ftnlen)11);
    t_success__(ok);
    return 0;
} /* f_spk17__ */

