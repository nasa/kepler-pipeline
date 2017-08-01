/* f_pgr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b26 = 1e-14;
static doublereal c_b36 = 1e-11;
static doublereal c_b64 = 1e5;
static integer c__1 = 1;
static doublereal c_b244 = 0.;
static doublereal c_b253 = 1.;
static doublereal c_b262 = 2.;
static integer c__9 = 9;
static integer c__2 = 2;

/* $Procedure      F_PGR ( Planetographic coordinate tests ) */
/* Subroutine */ int f_pgr__(logical *ok)
{
    /* Initialized data */

    static char body[32*18] = "EARTH                           " "EARTH     "
	    "                      " "EARTH                           " "EART"
	    "H                           " "EARTH                           " 
	    "EARTH                           " "EARTH                       "
	    "    " "EARTH                           " "EARTH                 "
	    "          " "MARS                            " "MARS            "
	    "                " "MARS                            " "MARS      "
	    "                      " "MARS                            " "MARS"
	    "                            " "MARS                            " 
	    "MARS                            " "MARS                        "
	    "    ";
    static doublereal rectan[54]	/* was [3][18] */ = { 6378.14,0.,0.,
	    -6378.14,0.,0.,-6388.14,0.,0.,-6368.14,0.,0.,0.,-6378.14,0.,0.,
	    6378.14,0.,0.,0.,6356.75,0.,0.,-6356.75,0.,0.,0.,3397.,0.,0.,
	    -3397.,0.,0.,-3407.,0.,0.,-3387.,0.,0.,0.,-3397.,0.,0.,3397.,0.,
	    0.,0.,3375.,0.,0.,-3375.,0.,0.,0. };
    static doublereal xlon[18] = { 0.,180.,180.,180.,270.,90.,0.,0.,0.,0.,
	    180.,180.,180.,90.,270.,0.,0.,0. };
    static doublereal xlat[18] = { 0.,0.,0.,0.,0.,0.,90.,-90.,90.,0.,0.,0.,0.,
	    0.,0.,90.,-90.,90. };
    static doublereal xalt[18] = { 0.,0.,10.,-10.,0.,0.,0.,0.,-6356.75,0.,0.,
	    10.,-10.,0.,0.,0.,0.,-3375. };
    static char spcial[32*3] = "EARTH                           " "MOON     "
	    "                       " "SUN                             ";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal galt, glat, glon, xrec[3], f;
    integer i__, j, n;
    doublereal radii[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), repmc_(char *, char *, 
	    char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), repmi_(char *, 
	    char *, integer *, char *, ftnlen, ftnlen, ftnlen);
    char title[80];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern doublereal twopi_(void);
    extern logical vzero_(doublereal *);
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    doublereal jacobi[9]	/* was [3][3] */, re;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal rp;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     recgeo_(doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal coeffs[3];
    extern /* Subroutine */ int drdgeo_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *), dgeodr_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), bodvrd_(char *, char *, integer *, 
	    integer *, doublereal *, ftnlen, ftnlen), recpgr_(char *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, ftnlen), pgrrec_(char *, doublereal *,
	     doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, ftnlen), drdpgr_(char *, doublereal *, doublereal *,
	     doublereal *, doublereal *, doublereal *, doublereal *, ftnlen), 
	    dpgrdr_(char *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, ftnlen), pcpool_(char *,
	     integer *, char *, ftnlen, ftnlen), pdpool_(char *, integer *, 
	    doublereal *, ftnlen), dvpool_(char *, ftnlen), tstpck_(char *, 
	    logical *, logical *, ftnlen);
    extern logical vzerog_(doublereal *, integer *);
    doublereal rec[3], alt, lat;
    extern doublereal dpr_(void), rpd_(void);
    doublereal lon, jac2[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the SPICELIB routines */

/*        RECPGR */
/*        PGRREC */
/*        DPGRDR */
/*        DRDPGR */

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

/* -    TSPICE Version 1.0.0, 05-JAN-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_PGR", (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  create full text PCK file.", (ftnlen)34);

/*     Create, load, and delete a PCK kernel. */

    tstpck_("f_recpgr.tpc", &c_true, &c_false, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Loop through the canned cases. */

    for (i__ = 1; i__ <= 18; ++i__) {
	s_copy(title, "Canned case #; BODY = #.", (ftnlen)80, (ftnlen)24);
	repmi_(title, "#", &i__, title, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	repmc_(title, "#", body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 
		: s_rnge("body", i__1, "f_pgr__", (ftnlen)238)) << 5), title, 
		(ftnlen)80, (ftnlen)1, (ftnlen)32, (ftnlen)80);

/* --- Case: ------------------------------------------------------ */

	tcase_(title, (ftnlen)80);
	bodvrd_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)245)) << 5), "RADII", &c__3, 
		&n, radii, (ftnlen)32, (ftnlen)5);
	re = radii[0];
	rp = radii[2];
	f = (re - rp) / re;

/*        Test RECPGR. */

	recpgr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)255)) << 5), &rectan[(i__2 = 
		i__ * 3 - 3) < 54 && 0 <= i__2 ? i__2 : s_rnge("rectan", i__2,
		 "f_pgr__", (ftnlen)255)], &re, &f, &lon, &lat, &alt, (ftnlen)
		32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	lon = dpr_() * lon;
	lat = dpr_() * lat;
	chcksd_("LON", &lon, "~", &xlon[(i__1 = i__ - 1) < 18 && 0 <= i__1 ? 
		i__1 : s_rnge("xlon", i__1, "f_pgr__", (ftnlen)261)], &c_b26, 
		ok, (ftnlen)3, (ftnlen)1);
	chcksd_("LAT", &lat, "~", &xlat[(i__1 = i__ - 1) < 18 && 0 <= i__1 ? 
		i__1 : s_rnge("xlat", i__1, "f_pgr__", (ftnlen)262)], &c_b26, 
		ok, (ftnlen)3, (ftnlen)1);
	chcksd_("ALT", &alt, "~", &xalt[(i__1 = i__ - 1) < 18 && 0 <= i__1 ? 
		i__1 : s_rnge("xalt", i__1, "f_pgr__", (ftnlen)263)], &c_b36, 
		ok, (ftnlen)3, (ftnlen)1);

/*        Test PGRREC. */

	d__1 = rpd_() * xlon[(i__2 = i__ - 1) < 18 && 0 <= i__2 ? i__2 : 
		s_rnge("xlon", i__2, "f_pgr__", (ftnlen)268)];
	d__2 = rpd_() * xlat[(i__3 = i__ - 1) < 18 && 0 <= i__3 ? i__3 : 
		s_rnge("xlat", i__3, "f_pgr__", (ftnlen)268)];
	pgrrec_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)268)) << 5), &d__1, &d__2, &
		xalt[(i__4 = i__ - 1) < 18 && 0 <= i__4 ? i__4 : s_rnge("xalt"
		, i__4, "f_pgr__", (ftnlen)268)], &re, &f, rec, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Test the vector relative error if the test point is not */
/*        at the origin. */

	if (! vzero_(&rectan[(i__1 = i__ * 3 - 3) < 54 && 0 <= i__1 ? i__1 : 
		s_rnge("rectan", i__1, "f_pgr__", (ftnlen)276)])) {
	    chckad_("REC", rec, "~~/", &rectan[(i__1 = i__ * 3 - 3) < 54 && 0 
		    <= i__1 ? i__1 : s_rnge("rectan", i__1, "f_pgr__", (
		    ftnlen)278)], &c__3, &c_b26, ok, (ftnlen)3, (ftnlen)3);
	} else {

/*           Check component-wise differences. */

	    chckad_("REC", rec, "~", &rectan[(i__1 = i__ * 3 - 3) < 54 && 0 <=
		     i__1 ? i__1 : s_rnge("rectan", i__1, "f_pgr__", (ftnlen)
		    284)], &c__3, &c_b26, ok, (ftnlen)3, (ftnlen)1);
	}
    }

/*     Run a non-axis test case. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Test non-axis case against RECGEO for oblate body.", (ftnlen)50);
    vpack_(&c_b64, &c_b64, &c_b64, xrec);
    bodvrd_("Mars", "RADII", &c__3, &n, radii, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    re = radii[0];
    rp = radii[2];
    f = (re - rp) / re;

/*     Test RECPGR. */

    recpgr_("MARS", xrec, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recgeo_(xrec, &re, &f, &glon, &glat, &galt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Mars is prograde, so flip the sign of the longitude. */

    glon = -glon;
    if (glon < 0.) {
	glon += twopi_();
    }
    chcksd_("LON", &lon, "~", &glon, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("LAT", &lat, "~", &glat, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &galt, &c_b36, ok, (ftnlen)3, (ftnlen)1);

/*     Now test PGRREC. */

    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rec, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("REC", rec, "~~/", xrec, &c__3, &c_b26, ok, (ftnlen)3, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    tcase_("Repeat previous test with Mars longitude set to positive east.", (
	    ftnlen)62);
    pcpool_("BODY499_PGR_POSITIVE_LON", &c__1, "EAST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test RECPGR. */

    recpgr_("MARS", xrec, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recgeo_(xrec, &re, &f, &glon, &glat, &galt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    if (glon < 0.) {
	glon += twopi_();
    }
    chcksd_("LON", &lon, "~", &glon, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("LAT", &lat, "~", &glat, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &galt, &c_b36, ok, (ftnlen)3, (ftnlen)1);

/*     Now test PGRREC. */

    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rec, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("REC", rec, "~~/", xrec, &c__3, &c_b26, ok, (ftnlen)3, (ftnlen)3);

/*     Clear the override value from the pool. */

    dvpool_("BODY499_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Repeat previous test with Mars PM values absent from the kernel "
	    "pool.", (ftnlen)69);

/*     Capture the correct values before starting. */

    bodvrd_("Mars", "PM", &c__3, &n, coeffs, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dvpool_("BODY499_PM", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcpool_("BODY499_PGR_POSITIVE_LON", &c__1, "EAST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test RECPGR. */

    recpgr_("MARS", xrec, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recgeo_(xrec, &re, &f, &glon, &glat, &galt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    if (glon < 0.) {
	glon += twopi_();
    }
    chcksd_("LON", &lon, "~", &glon, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("LAT", &lat, "~", &glat, &c_b26, ok, (ftnlen)3, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &galt, &c_b36, ok, (ftnlen)3, (ftnlen)1);

/*     Now test PGRREC. */

    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rec, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("REC", rec, "~~/", xrec, &c__3, &c_b26, ok, (ftnlen)3, (ftnlen)3);

/*     Clear the override value from the pool. */

    dvpool_("BODY499_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Restore the Mars PM coefficients. */

    pdpool_("BODY499_PM", &c__3, coeffs, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check longitude sense for earth, moon, and sun.", (ftnlen)47);
    for (i__ = 1; i__ <= 3; ++i__) {

/*        Test RECPGR. */

	recpgr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)451)) << 5), xrec, &re, &f,
		 &lon, &lat, &alt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	recgeo_(xrec, &re, &f, &glon, &glat, &galt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (glon < 0.) {
	    glon += twopi_();
	}
	chcksd_("LON", &lon, "~", &glon, &c_b26, ok, (ftnlen)3, (ftnlen)1);
	chcksd_("LAT", &lat, "~", &glat, &c_b26, ok, (ftnlen)3, (ftnlen)1);
	chcksd_("ALT", &alt, "~", &galt, &c_b36, ok, (ftnlen)3, (ftnlen)1);

/*        Now test PGRREC. */

	pgrrec_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)469)) << 5), &lon, &lat, &
		alt, &re, &f, rec, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("REC", rec, "~~/", xrec, &c__3, &c_b26, ok, (ftnlen)3, (
		ftnlen)3);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Repeat tests with longitudes set to positive west.", (ftnlen)50);
    pcpool_("BODY399_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcpool_("BODY301_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcpool_("BODY10_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)23, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {

/*        Test RECPGR. */

	recpgr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)497)) << 5), xrec, &re, &f,
		 &lon, &lat, &alt, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	recgeo_(xrec, &re, &f, &glon, &glat, &galt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	glon = -glon;
	if (glon < 0.) {
	    glon += twopi_();
	}
	chcksd_("LON", &lon, "~", &glon, &c_b26, ok, (ftnlen)3, (ftnlen)1);
	chcksd_("LAT", &lat, "~", &glat, &c_b26, ok, (ftnlen)3, (ftnlen)1);
	chcksd_("ALT", &alt, "~", &galt, &c_b36, ok, (ftnlen)3, (ftnlen)1);

/*        Now test PGRREC. */

	pgrrec_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)516)) << 5), &lon, &lat, &
		alt, &re, &f, rec, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("REC", rec, "~~/", xrec, &c__3, &c_b26, ok, (ftnlen)3, (
		ftnlen)3);
    }
    dvpool_("BODY399_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dvpool_("BODY301_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dvpool_("BODY10_PGR_POSITIVE_LON", (ftnlen)23);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Error cases. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: equatorial radius is zero.", (ftnlen)38);

/*     Capture the correct values before starting. */

    bodvrd_("Earth", "RADII", &c__3, &n, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    re = radii[0];
    rp = radii[2];
    f = (re - rp) / re;
    recpgr_("EARTH", rectan, &c_b244, &f, &lon, &lat, &alt, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("EARTH", &lon, &lat, &alt, &c_b244, &f, rectan, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: flattening factor is 1.", (ftnlen)35);
    recpgr_("EARTH", rectan, &re, &c_b253, &lon, &lat, &alt, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("EARTH", &lon, &lat, &alt, &re, &c_b253, rectan, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: flattening factor is > 1.", (ftnlen)37);
    recpgr_("EARTH", rectan, &re, &c_b262, &lon, &lat, &alt, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("EARTH", &lon, &lat, &alt, &re, &c_b262, rectan, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: no Mars PM terms in pool.", (ftnlen)37);

/*     Capture the correct values before starting. */

    bodvrd_("Mars", "PM", &c__3, &n, coeffs, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Delete Mars' PM coefficients from the kernel pool. */

    dvpool_("BODY499_PM", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recpgr_("MARS", rectan, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rectan, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: no rate term for Mars PM.", (ftnlen)37);

/*     Overwrite Mars' PM coefficients in the kernel pool. */

    pdpool_("BODY499_PM", &c__1, &c_b244, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recpgr_("MARS", rectan, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rectan, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);

/*     Restore the good PM coefficients. */

    pdpool_("BODY499_PM", &c__3, coeffs, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: invalid override spec.", (ftnlen)34);
    pcpool_("BODY499_PGR_POSITIVE_LON", &c__1, "EST", (ftnlen)24, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recpgr_("MARS", rectan, &re, &f, &lon, &lat, &alt, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDOPTION)", ok, (ftnlen)20);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    pgrrec_("MARS", &lon, &lat, &alt, &re, &f, rectan, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDOPTION)", ok, (ftnlen)20);

/*     Clean up. */

    dvpool_("BODY499_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/* ***************************************************************** */
/* ***************************************************************** */
/* ***************************************************************** */
/*     Jacobian matrix routine tests */
/* ***************************************************************** */
/* ***************************************************************** */
/* ***************************************************************** */

/*     Loop through the canned cases. */

    for (i__ = 1; i__ <= 18; ++i__) {
	s_copy(title, "Canned DPGRDR case #; BODY = #.", (ftnlen)80, (ftnlen)
		31);
	repmi_(title, "#", &i__, title, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	repmc_(title, "#", body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 
		: s_rnge("body", i__1, "f_pgr__", (ftnlen)694)) << 5), title, 
		(ftnlen)80, (ftnlen)1, (ftnlen)32, (ftnlen)80);

/* --- Case: ------------------------------------------------------ */

	tcase_(title, (ftnlen)80);
	bodvrd_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)701)) << 5), "RADII", &c__3, 
		&n, radii, (ftnlen)32, (ftnlen)5);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	re = radii[0];
	rp = radii[2];
	f = (re - rp) / re;
	drdpgr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)709)) << 5), &xlon[(i__2 = 
		i__ - 1) < 18 && 0 <= i__2 ? i__2 : s_rnge("xlon", i__2, 
		"f_pgr__", (ftnlen)709)], &xlat[(i__3 = i__ - 1) < 18 && 0 <= 
		i__3 ? i__3 : s_rnge("xlat", i__3, "f_pgr__", (ftnlen)709)], &
		xalt[(i__4 = i__ - 1) < 18 && 0 <= i__4 ? i__4 : s_rnge("xalt"
		, i__4, "f_pgr__", (ftnlen)709)], &re, &f, jacobi, (ftnlen)32)
		;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (eqstr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : 
		s_rnge("body", i__1, "f_pgr__", (ftnlen)716)) << 5), "Mars", (
		ftnlen)32, (ftnlen)4)) {
	    xlon[(i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge("xlon", 
		    i__1, "f_pgr__", (ftnlen)717)] = -xlon[(i__2 = i__ - 1) < 
		    18 && 0 <= i__2 ? i__2 : s_rnge("xlon", i__2, "f_pgr__", (
		    ftnlen)717)];
	}
	drdgeo_(&xlon[(i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"xlon", i__1, "f_pgr__", (ftnlen)720)], &xlat[(i__2 = i__ - 1)
		 < 18 && 0 <= i__2 ? i__2 : s_rnge("xlat", i__2, "f_pgr__", (
		ftnlen)720)], &xalt[(i__3 = i__ - 1) < 18 && 0 <= i__3 ? i__3 
		: s_rnge("xalt", i__3, "f_pgr__", (ftnlen)720)], &re, &f, 
		jac2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        For comparison, negate the partials w.r.t. geodetic longitude */
/*        for Mars. */

	if (eqstr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : 
		s_rnge("body", i__1, "f_pgr__", (ftnlen)728)) << 5), "Mars", (
		ftnlen)32, (ftnlen)4)) {
	    for (j = 1; j <= 3; ++j) {
		jac2[(i__1 = j - 1) < 9 && 0 <= i__1 ? i__1 : s_rnge("jac2", 
			i__1, "f_pgr__", (ftnlen)731)] = -jac2[(i__2 = j - 1) 
			< 9 && 0 <= i__2 ? i__2 : s_rnge("jac2", i__2, "f_pg"
			"r__", (ftnlen)731)];
	    }
	}
	chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6, (
		ftnlen)1);
    }

/*     Loop through the canned cases for DRDPGR. */

    for (i__ = 1; i__ <= 18; ++i__) {
	s_copy(title, "Canned DRDPGR case #; BODY = #.", (ftnlen)80, (ftnlen)
		31);
	repmi_(title, "#", &i__, title, (ftnlen)80, (ftnlen)1, (ftnlen)80);
	repmc_(title, "#", body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 
		: s_rnge("body", i__1, "f_pgr__", (ftnlen)748)) << 5), title, 
		(ftnlen)80, (ftnlen)1, (ftnlen)32, (ftnlen)80);

/* --- Case: ------------------------------------------------------ */

	tcase_(title, (ftnlen)80);
	bodvrd_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)755)) << 5), "RADII", &c__3, 
		&n, radii, (ftnlen)32, (ftnlen)5);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	re = radii[0];
	rp = radii[2];
	f = (re - rp) / re;
	dpgrdr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : s_rnge(
		"body", i__1, "f_pgr__", (ftnlen)763)) << 5), &rectan[(i__2 = 
		i__ * 3 - 3) < 54 && 0 <= i__2 ? i__2 : s_rnge("rectan", i__2,
		 "f_pgr__", (ftnlen)763)], &rectan[(i__3 = i__ * 3 - 2) < 54 
		&& 0 <= i__3 ? i__3 : s_rnge("rectan", i__3, "f_pgr__", (
		ftnlen)763)], &rectan[(i__4 = i__ * 3 - 1) < 54 && 0 <= i__4 ?
		 i__4 : s_rnge("rectan", i__4, "f_pgr__", (ftnlen)763)], &re, 
		&f, jacobi, (ftnlen)32);
	if (vzerog_(&rectan[(i__1 = i__ * 3 - 3) < 54 && 0 <= i__1 ? i__1 : 
		s_rnge("rectan", i__1, "f_pgr__", (ftnlen)767)], &c__2)) {
	    chckxc_(&c_true, "SPICE(POINTONZAXIS)", ok, (ftnlen)19);
	} else {
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    dgeodr_(&rectan[(i__1 = i__ * 3 - 3) < 54 && 0 <= i__1 ? i__1 : 
		    s_rnge("rectan", i__1, "f_pgr__", (ftnlen)775)], &rectan[(
		    i__2 = i__ * 3 - 2) < 54 && 0 <= i__2 ? i__2 : s_rnge(
		    "rectan", i__2, "f_pgr__", (ftnlen)775)], &rectan[(i__3 = 
		    i__ * 3 - 1) < 54 && 0 <= i__3 ? i__3 : s_rnge("rectan", 
		    i__3, "f_pgr__", (ftnlen)775)], &re, &f, jac2);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           For comparison, negate the gradient of geodetic longitude */
/*           for Mars. */
	    if (eqstr_(body + (((i__1 = i__ - 1) < 18 && 0 <= i__1 ? i__1 : 
		    s_rnge("body", i__1, "f_pgr__", (ftnlen)783)) << 5), 
		    "Mars", (ftnlen)32, (ftnlen)4)) {
		for (j = 1; j <= 3; ++j) {
		    jac2[(i__1 = j * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
			    "jac2", i__1, "f_pgr__", (ftnlen)786)] = -jac2[(
			    i__2 = j * 3 - 3) < 9 && 0 <= i__2 ? i__2 : 
			    s_rnge("jac2", i__2, "f_pgr__", (ftnlen)786)];
		}
	    }
	    chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6,
		     (ftnlen)1);
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Check longitude sense for earth, moon, and sun.", (ftnlen)47);
    vpack_(&c_b64, &c_b64, &c_b64, xrec);
    for (i__ = 1; i__ <= 3; ++i__) {

/*        Test DPGRDR. */

	dpgrdr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)810)) << 5), xrec, &xrec[1]
		, &xrec[2], &re, &f, jacobi, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dgeodr_(xrec, &xrec[1], &xrec[2], &re, &f, jac2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6, (
		ftnlen)1);

/*        Now test DRDPGR. */

	drdpgr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)822)) << 5), &lon, &lat, &
		alt, &re, &f, jacobi, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	drdgeo_(&lon, &lat, &alt, &re, &f, jac2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6, (
		ftnlen)1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Repeat tests with longitudes set to positive west.", (ftnlen)50);
    pcpool_("BODY399_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcpool_("BODY301_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)24, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pcpool_("BODY10_PGR_POSITIVE_LON", &c__1, "WEST", (ftnlen)23, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    for (i__ = 1; i__ <= 3; ++i__) {

/*        Test DPGRDR. */

	dpgrdr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)853)) << 5), xrec, &xrec[1]
		, &xrec[2], &re, &f, jacobi, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	dgeodr_(xrec, &xrec[1], &xrec[2], &re, &f, jac2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Negate the gradient of geodetic longitude. */

	for (j = 1; j <= 3; ++j) {
	    jac2[(i__1 = j * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge("jac2", 
		    i__1, "f_pgr__", (ftnlen)865)] = -jac2[(i__2 = j * 3 - 3) 
		    < 9 && 0 <= i__2 ? i__2 : s_rnge("jac2", i__2, "f_pgr__", 
		    (ftnlen)865)];
	}
	chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6, (
		ftnlen)1);

/*        Now test DRDPGR. */

	drdpgr_(spcial + (((i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		"spcial", i__1, "f_pgr__", (ftnlen)873)) << 5), &lon, &lat, &
		alt, &re, &f, jacobi, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	drdgeo_(&lon, &lat, &alt, &re, &f, jac2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Negate all partials with respect to geodetic longitude. */

	for (j = 1; j <= 3; ++j) {
	    jac2[(i__1 = j - 1) < 9 && 0 <= i__1 ? i__1 : s_rnge("jac2", i__1,
		     "f_pgr__", (ftnlen)883)] = -jac2[(i__2 = j - 1) < 9 && 0 
		    <= i__2 ? i__2 : s_rnge("jac2", i__2, "f_pgr__", (ftnlen)
		    883)];
	}
	chckad_("JACOBI", jacobi, "~", jac2, &c__9, &c_b26, ok, (ftnlen)6, (
		ftnlen)1);
    }

/*     Error cases. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: equatorial radius is zero.", (ftnlen)38);

/*     Capture the correct values before starting. */

    bodvrd_("Earth", "RADII", &c__3, &n, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    re = radii[0];
    rp = radii[2];
    f = (re - rp) / re;
    dpgrdr_("EARTH", rectan, &rectan[1], &rectan[2], &c_b244, &f, jacobi, (
	    ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("EARTH", &lon, &lat, &alt, &c_b244, &f, jacobi, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: flattening factor is 1.", (ftnlen)35);
    dpgrdr_("EARTH", rectan, &rectan[1], &rectan[2], &re, &c_b253, jacobi, (
	    ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("EARTH", &lon, &lat, &alt, &re, &c_b253, jacobi, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: flattening factor is > 1.", (ftnlen)37);
    dpgrdr_("EARTH", rectan, &rectan[1], &rectan[2], &re, &c_b262, jacobi, (
	    ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("EARTH", &lon, &lat, &alt, &re, &c_b262, jacobi, (ftnlen)5);
    chckxc_(&c_true, "SPICE(VALUEOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: no Mars PM terms in pool.", (ftnlen)37);

/*     Capture the correct values before starting. */

    bodvrd_("Mars", "PM", &c__3, &n, coeffs, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Delete Mars' PM coefficients from the kernel pool. */

    dvpool_("BODY499_PM", (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dpgrdr_("MARS", rectan, &rectan[1], &rectan[2], &re, &f, jacobi, (ftnlen)
	    4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("MARS", &lon, &lat, &alt, &re, &f, jacobi, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: no rate term for Mars PM.", (ftnlen)37);

/*     Overwrite Mars' PM coefficients in the kernel pool. */

    pdpool_("BODY499_PM", &c__1, &c_b244, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dpgrdr_("MARS", rectan, &rectan[1], &rectan[2], &re, &f, jacobi, (ftnlen)
	    4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("MARS", &lon, &lat, &alt, &re, &f, jacobi, (ftnlen)4);
    chckxc_(&c_true, "SPICE(MISSINGDATA)", ok, (ftnlen)18);

/*     Restore the good PM coefficients. */

    pdpool_("BODY499_PM", &c__3, coeffs, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error case: invalid override spec.", (ftnlen)34);
    pcpool_("BODY499_PGR_POSITIVE_LON", &c__1, "EST", (ftnlen)24, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dpgrdr_("MARS", rectan, &rectan[1], &rectan[2], &re, &f, jacobi, (ftnlen)
	    4);
    chckxc_(&c_true, "SPICE(INVALIDOPTION)", ok, (ftnlen)20);
    lon = 0.;
    lat = 0.;
    alt = 1e5;
    drdpgr_("MARS", &lon, &lat, &alt, &re, &f, jacobi, (ftnlen)4);
    chckxc_(&c_true, "SPICE(INVALIDOPTION)", ok, (ftnlen)20);

/*     Clean up. */

    dvpool_("BODY499_PGR_POSITIVE_LON", (ftnlen)24);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_pgr__ */

