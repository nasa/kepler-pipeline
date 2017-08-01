/* f_spk10.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__1950 = 1950;
static integer c__1000 = 1000;
static integer c__399 = 399;
static integer c__1 = 1;
static logical c_true = TRUE_;
static integer c__8 = 8;
static doublereal c_b31 = 0.;
static integer c__10 = 10;
static integer c__3 = 3;
static integer c__6 = 6;
static integer c__9 = 9;

/* $Procedure      F_SPK10 ( Family of tests for types 10 ) */
/* Subroutine */ int f_spk10__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double cos(doublereal), sin(doublereal);

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal dmob;
    integer body;
    doublereal dwdt, last, dnut[4];
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    integer type__;
    extern /* Subroutine */ int mtxv_(doublereal *, doublereal *, doublereal *
	    );
    char hi2ln[80*2];
    extern /* Subroutine */ int eul2m_(doublereal *, doublereal *, doublereal 
	    *, integer *, integer *, integer *, doublereal *), zzmobliq_(
	    doublereal *, doublereal *, doublereal *);
    doublereal part1[6], part2[6];
    extern /* Subroutine */ int zzeprcss_(doublereal *, doublereal *);
    integer i__;
    doublereal m[9]	/* was [3][3] */, begin, w;
    integer frame;
    doublereal epoch[10];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[6], denom;
    char ident[40];
    extern /* Subroutine */ int spke10_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal elems[100];
    logical found;
    doublereal nuobl, state[6];
    extern /* Subroutine */ int spkr10_(integer *, doublereal *, doublereal *,
	     doublereal *), vlcom_(doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), topen_(char *, ftnlen);
    doublereal numer, first;
    extern /* Subroutine */ int spkw10_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, doublereal *, ftnlen, ftnlen);
    doublereal nulon, tempv[3];
    extern /* Subroutine */ int spkez_(integer *, doublereal *, char *, char *
	    , integer *, doublereal *, doublereal *, ftnlen, ftnlen);
    doublereal expst[6];
    extern /* Subroutine */ int t_success__(logical *), ev2lin_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal nuobl1, nuobl2, nulon1;
    char low2ln[80*20];
    doublereal nulon2;
    integer id;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    doublereal et;
    integer handle;
    doublereal lt;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    doublereal dargdt;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen), getelm_(integer *, char *, 
	    doublereal *, doublereal *, ftnlen);
    doublereal record[50];
    extern /* Subroutine */ int dpspce_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    integer center;
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen), vlcomg_(
	    integer *, doublereal *, doublereal *, doublereal *, doublereal *,
	     doublereal *), spkuef_(integer *), spkcls_(integer *);
    doublereal consts[8];
    extern /* Subroutine */ int spkopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen), spksfs_(integer *, doublereal *, integer *, 
	    doublereal *, char *, logical *, ftnlen), spkuds_(doublereal *, 
	    integer *, integer *, integer *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *), tstlsk_(void), zzwahr_(
	    doublereal *, doublereal *);
    doublereal end, arg, mob;
    extern doublereal spd_(void);
    doublereal vel[3];
    integer spk1, spk2, spk3;

/* $ Abstract */

/*     This routine performs tests on SPK type 10 to make sure that */
/*     the correct routines are called and that subsetting occurs */
/*     correctly. */

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

/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_SPK10", (ftnlen)7);
    tcase_("Preliminaries --- load a leapseconds kernel ", (ftnlen)44);
    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Make sure we can create an SPK type 10 segment from a single set"
	    " of two-line elements. ", (ftnlen)87);
    kilfil_("type10.bsp", (ftnlen)10);

/*        We'll use the two-line elments for Topex that are */
/*        given in the header to GETELM. */

    s_copy(low2ln, "1 22076U 92052A   97173.53461370 -.00000038  00000-0  10"
	    "000-3 0   594", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 80, "2 22076  66.0378 163.4372 0008359 278.7732  81.2337"
	    " 12.80930736227550", (ftnlen)80, (ftnlen)69);

/*        Set the geophysical constants used by SPACE COMMAND in */
/*        the distributed code. */

    consts[0] = .001082616;
    consts[1] = -2.53881e-6;
    consts[2] = -1.65597e-6;
    consts[3] = .0743669161;
    consts[4] = 120.;
    consts[5] = 78.;
    consts[6] = 6378.135;
    consts[7] = 1.;
    getelm_(&c__1950, low2ln, epoch, elems, (ftnlen)80);
    first = epoch[0] - spd_() * 100.;
    last = epoch[0] + spd_() * 100.;
    id = -122076;
    spkopn_("type10.bsp", "TEST_FILE", &c__1000, &handle, (ftnlen)10, (ftnlen)
	    9);
    spkw10_(&handle, &id, &c__399, "J2000", &first, &last, "Test TOPEX", 
	    consts, &c__1, elems, epoch, (ftnlen)5, (ftnlen)10);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tcase_("Make sure we can read read out of the file the data we just inse"
	    "rted. ", (ftnlen)70);
    et = epoch[0];
    spklef_("type10.bsp", &spk1, (ftnlen)10);
    spksfs_(&id, &et, &handle, descr, ident, &found, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Unpack the descriptor and make sure it has the correct */
/*        data in it. */

    spkuds_(descr, &body, &center, &frame, &type__, &first, &last, &begin, &
	    end);
    spkr10_(&handle, descr, &et, record);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("CONSTS", consts, "=", record, &c__8, &c_b31, ok, (ftnlen)6, (
	    ftnlen)1);
    chckad_("ELEM1", elems, "=", &record[8], &c__10, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("ELEM2", elems, "=", &record[22], &c__10, &c_b31, ok, (ftnlen)5, (
	    ftnlen)1);
    tcase_("Make sure the record is evaluated using the routine EV2LIN. ", (
	    ftnlen)60);
    ev2lin_(&et, consts, elems, expst);
    zzwahr_(&elems[9], dnut);
    nulon = dnut[0] + (et - elems[9]) * dnut[2];
    nuobl = dnut[1] + (et - elems[9]) * dnut[3];
    zzmobliq_(&et, &mob, &dmob);
    d__1 = -mob - nuobl;
    d__2 = -nulon;
    eul2m_(&d__1, &d__2, &mob, &c__1, &c__3, &c__1, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    zzeprcss_(&et, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    spke10_(&et, record, state);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    tcase_("Make sure that SPKEZ agrees with the previous computation. ", (
	    ftnlen)59);
    spkez_(&id, &et, "J2000", "NONE", &c__399, state, &lt, (ftnlen)5, (ftnlen)
	    4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    tcase_("Construct a longer file and make sure that we get the correct st"
	    "ates from SPKEZ. ", (ftnlen)81);
    kilfil_("type10_2.bsp", (ftnlen)12);
    s_copy(low2ln, "1 18123U 87 53  A 87324.61041692 -.00000023  00000-0 -75"
	    "103-5 0 00675", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 80, "2 18123  98.8296 152.0074 0014950 168.7820 191.3688"
	    " 14.12912554 21686", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 160, "1 18123U 87 53  A 87326.73487726  .00000045  00000"
	    "-0  28709-4 0 00684", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 240, "2 18123  98.8335 154.1103 0015643 163.5445 196.623"
	    "5 14.12912902 21988", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 320, "1 18123U 87 53  A 87331.40868801  .00000104  00000"
	    "-0  60183-4 0 00690", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 400, "2 18123  98.8311 158.7160 0015481 149.9848 210.222"
	    "0 14.12914624 22644", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 480, "1 18123U 87 53  A 87334.24129978  .00000086  00000"
	    "-0  51111-4 0 00702", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 560, "2 18123  98.8296 161.5054 0015372 142.4159 217.808"
	    "9 14.12914879 23045", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 640, "1 18123U 87 53  A 87336.93227900 -.00000107  00000"
	    "-0 -52860-4 0 00713", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 720, "2 18123  98.8317 164.1627 0014570 135.9191 224.232"
	    "1 14.12910572 23425", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 800, "1 18123U 87 53  A 87337.28635487  .00000173  00000"
	    "-0  10226-3 0 00726", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 880, "2 18123  98.8284 164.5113 0015289 133.5979 226.643"
	    "8 14.12916140 23475", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 960, "1 18123U 87 53  A 87339.05673569  .00000079  00000"
	    "-0  47069-4 0 00738", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 1040, "2 18123  98.8288 166.2585 0015281 127.9985 232.25"
	    "67 14.12916010 24908", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 1120, "1 18123U 87 53  A 87345.43010859  .00000022  0000"
	    "0-0  16481-4 0 00758", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 1200, "2 18123  98.8241 172.5226 0015362 109.1515 251.13"
	    "23 14.12915487 24626", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 1280, "1 18123U 87 53  A 87349.04167543  .00000042  0000"
	    "0-0  27370-4 0 00764", (ftnlen)80, (ftnlen)69);
    s_copy(low2ln + 1360, "2 18123  98.8301 176.1010 0015565 100.0881 260.20"
	    "47 14.12916361 25138", (ftnlen)80, (ftnlen)69);
    for (i__ = 0; i__ <= 8; ++i__) {
	getelm_(&c__1950, low2ln + ((i__1 = i__ << 1) < 20 && 0 <= i__1 ? 
		i__1 : s_rnge("low2ln", i__1, "f_spk10__", (ftnlen)283)) * 80,
		 &epoch[(i__2 = i__) < 10 && 0 <= i__2 ? i__2 : s_rnge("epoch"
		, i__2, "f_spk10__", (ftnlen)283)], &elems[(i__3 = i__ * 10) <
		 100 && 0 <= i__3 ? i__3 : s_rnge("elems", i__3, "f_spk10__", 
		(ftnlen)283)], (ftnlen)80);
    }
    first = epoch[0] - spd_() * .5;
    last = epoch[8] + spd_() * .5;
    id = -118123;
    spkopn_("type10_2.bsp", "TEST_FILE", &c__1000, &handle, (ftnlen)12, (
	    ftnlen)9);
    spkw10_(&handle, &id, &c__399, "J2000", &first, &last, "DMSP F8", consts, 
	    &c__9, elems, epoch, (ftnlen)5, (ftnlen)7);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et = epoch[4] * .6 + epoch[5] * .4;
    spklef_("type10_2.bsp", &spk2, (ftnlen)12);
    ev2lin_(&et, consts, &elems[40], part1);
    ev2lin_(&et, consts, &elems[50], part2);
    zzwahr_(&epoch[4], dnut);
    nulon1 = dnut[0] + (et - epoch[4]) * dnut[2];
    nuobl1 = dnut[1] + (et - epoch[4]) * dnut[3];
    zzwahr_(&epoch[5], dnut);
    nulon2 = dnut[0] + (et - epoch[5]) * dnut[2];
    nuobl2 = dnut[1] + (et - epoch[5]) * dnut[3];
    zzmobliq_(&et, &mob, &dmob);
    numer = et - epoch[4];
    denom = epoch[5] - epoch[4];
    arg = numer * pi_() / denom;
    dargdt = pi_() / denom;
    w = cos(arg) * .5 + .5;
    dwdt = sin(arg) * -.5 * dargdt;
    nuobl = w * nuobl1 + (1. - w) * nuobl2;
    nulon = w * nulon1 + (1. - w) * nulon2;
    d__1 = -mob - nuobl;
    d__2 = -nulon;
    eul2m_(&d__1, &d__2, &mob, &c__1, &c__3, &c__1, m);
    mtxv_(m, part1, tempv);
    vequ_(tempv, part1);
    mtxv_(m, &part1[3], tempv);
    vequ_(tempv, &part1[3]);
    mtxv_(m, part2, tempv);
    vequ_(tempv, part2);
    mtxv_(m, &part2[3], tempv);
    vequ_(tempv, &part2[3]);
    d__1 = 1. - w;
    vlcomg_(&c__6, &w, part1, &d__1, part2, expst);
    d__1 = -dwdt;
    vlcom_(&dwdt, part1, &d__1, part2, vel);
    vadd_(vel, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    zzeprcss_(&et, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    spkez_(&id, &et, "J2000", "NONE", &c__399, state, &lt, (ftnlen)5, (ftnlen)
	    4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    tcase_("Using the previous file, make sure we get the correct state at o"
	    "ne second after the beginning of the segment.", (ftnlen)109);
    et = first + 1.;
    ev2lin_(&et, consts, elems, expst);
    zzwahr_(&elems[9], dnut);
    nulon = dnut[0] + (et - elems[9]) * dnut[2];
    nuobl = dnut[1] + (et - elems[9]) * dnut[3];
    zzmobliq_(&et, &mob, &dmob);
    d__1 = -mob - nuobl;
    d__2 = -nulon;
    eul2m_(&d__1, &d__2, &mob, &c__1, &c__3, &c__1, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    zzeprcss_(&et, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    spkez_(&id, &et, "J2000", "NONE", &c__399, state, &lt, (ftnlen)5, (ftnlen)
	    4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    tcase_("Using the same file make sure we get the correct state at one se"
	    "cond before the end of the segment. ", (ftnlen)100);
    et = last - 1.;
    ev2lin_(&et, consts, &elems[80], expst);
    zzwahr_(&elems[89], dnut);
    nulon = dnut[0] + (et - elems[89]) * dnut[2];
    nuobl = dnut[1] + (et - elems[89]) * dnut[3];
    zzmobliq_(&et, &mob, &dmob);
    d__1 = -mob - nuobl;
    d__2 = -nulon;
    eul2m_(&d__1, &d__2, &mob, &c__1, &c__3, &c__1, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    zzeprcss_(&et, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    spkez_(&id, &et, "J2000", "NONE", &c__399, state, &lt, (ftnlen)5, (ftnlen)
	    4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    tcase_("Make sure we can perform the same experiments using a deep space"
	    " satellite. ", (ftnlen)76);
    kilfil_("type10_3.bsp", (ftnlen)12);
    s_copy(hi2ln, "1 24846U 97031A   97179.08162378 -.00000182  00000-0  000"
	    "00+0 0   129", (ftnlen)80, (ftnlen)69);
    s_copy(hi2ln + 80, "2 24846   4.5222  86.7012 6052628 178.7924 183.5048 "
	    " 2.04105068    52", (ftnlen)80, (ftnlen)69);
    getelm_(&c__1950, hi2ln, epoch, elems, (ftnlen)80);
    first = epoch[0] - spd_() * 10.;
    last = epoch[0] + spd_() * 10.;
    id = -124846;
    spkopn_("type10_3.bsp", "TEST_FILE", &c__1000, &handle, (ftnlen)12, (
	    ftnlen)9);
    spkw10_(&handle, &id, &c__399, "J2000", &first, &last, "Test INTELSAT", 
	    consts, &c__1, elems, epoch, (ftnlen)5, (ftnlen)13);
    spkcls_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    et = epoch[0];
    dpspce_(&et, consts, elems, state);
    dpspce_(&et, consts, elems, expst);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("EXPST", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    zzwahr_(&elems[9], dnut);
    nulon = dnut[0] + (et - elems[9]) * dnut[2];
    nuobl = dnut[1] + (et - elems[9]) * dnut[3];
    zzmobliq_(&et, &mob, &dmob);
    d__1 = -mob - nuobl;
    d__2 = -nulon;
    eul2m_(&d__1, &d__2, &mob, &c__1, &c__3, &c__1, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    zzeprcss_(&et, m);
    mtxv_(m, expst, tempv);
    vequ_(tempv, expst);
    mtxv_(m, &expst[3], tempv);
    vequ_(tempv, &expst[3]);
    spklef_("type10_3.bsp", &spk3, (ftnlen)12);
    spkez_(&id, &et, "J2000", "NONE", &c__399, state, &lt, (ftnlen)5, (ftnlen)
	    4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("STATE", state, "=", expst, &c__6, &c_b31, ok, (ftnlen)5, (ftnlen)
	    1);
    spkuef_(&spk1);
    spkuef_(&spk2);
    spkuef_(&spk3);
    kilfil_("type10.bsp", (ftnlen)10);
    kilfil_("type10_2.bsp", (ftnlen)12);
    kilfil_("type10_3.bsp", (ftnlen)12);
    t_success__(ok);
    return 0;
} /* f_spk10__ */

