/* f_ge01.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__10 = 10;
static integer c__399 = 399;
static doublereal c_b32 = 1e-12;
static integer c__3 = 3;
static doublereal c_b108 = 0.;

/* $Procedure F_GE01 ( SPICE higher-level geometry routine tests ) */
/* Subroutine */ int f_ge01__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal f, radii[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal phase, solar;
    char title[240];
    extern /* Subroutine */ int illum_(char *, doublereal *, char *, char *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, ftnlen, 
	    ftnlen, ftnlen), topen_(char *, ftnlen), subpt_(char *, char *, 
	    doublereal *, char *, char *, doublereal *, doublereal *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), str2et_(char *, doublereal *, ftnlen);
    doublereal re, et;
    integer handle;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal lt;
    extern /* Subroutine */ int delfil_(char *, ftnlen);
    doublereal rp;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     recgeo_(doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), reclat_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), bodvrd_(char *, char *, integer *, 
	    integer *, doublereal *, ftnlen, ftnlen), spkgeo_(integer *, 
	    doublereal *, char *, integer *, doublereal *, doublereal *, 
	    ftnlen);
    doublereal sunrad;
    extern /* Subroutine */ int spkuef_(integer *);
    doublereal emissn, sunalt, sunlat;
    extern /* Subroutine */ int tstpck_(char *, logical *, logical *, ftnlen),
	     subsol_(char *, char *, doublereal *, char *, char *, doublereal 
	    *, ftnlen, ftnlen, ftnlen, ftnlen);
    doublereal spoint[3], sunsta[6], exppnt[3], sunlon;
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen);
    doublereal rad;
    integer dim;
    doublereal alt, lat, lon;

/* $ Abstract */

/*     Exercise higher-level SPICELIB geometry routines. */

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

/* $ Required_Reading */

/*     None. */

/* $ Keywords */

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine tests a subset of the higher-level SPICELIB */
/*     geometry routines: */

/*        ILLUM */
/*        SUBPT */
/*        SUBSOL */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 05-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Local Parameters */


/*     Local Variables */


/*     Initial values */


/*     Open the test family. */

    topen_("F_GE01", (ftnlen)6);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  load kernels.", (ftnlen)21);

/*     Leapseconds:  Note that the LSK is deleted after loading, so we */
/*     don't have to clean it up later. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create and load a PCK file. Delete the file afterwards. */

    tstpck_("test.tpc", &c_true, &c_false, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load an SPK file as well. */

    tstspk_("test.bsp", &c_true, &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test SUBPT.  Find the sub-solar point of the sun on the E"
	    "arth using the INTERCEPT definition.", (ftnlen)240, (ftnlen)93);
    tcase_(title, (ftnlen)240);
    str2et_("1999 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subpt_("INTERCEPT", "EARTH", &et, "NONE", "SUN", spoint, &alt, (ftnlen)9, 
	    (ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    reclat_(spoint, &rad, &lon, &lat);

/*     Get the state of the sun in Earth bodyfixed coordinates at ET. */

    spkgeo_(&c__10, &et, "IAU_EARTH", &c__399, sunsta, &lt, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    reclat_(sunsta, &sunrad, &sunlon, &sunlat);

/*     Make sure the directional coordinates match up. */

    chcksd_("Sub point lon", &lon, "~", &sunlon, &c_b32, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Sub point lat", &lat, "~", &sunlat, &c_b32, ok, (ftnlen)13, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test SUBPT.  Find the sub-solar point of the sun on the E"
	    "arth using the NEAR POINT definition.", (ftnlen)240, (ftnlen)94);
    tcase_(title, (ftnlen)240);
    str2et_("1999 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure that strings representing integers are parsed correctly. */

    subpt_("NEAR POINT", "399", &et, "NONE", "10", spoint, &alt, (ftnlen)10, (
	    ftnlen)3, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We'll need the radii of the earth. */

    bodvrd_("EARTH", "RADII", &c__3, &dim, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    re = radii[0];
    rp = radii[2];
    f = (re - rp) / re;
    recgeo_(spoint, &re, &f, &lon, &lat, &alt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the state of the sun in Earth bodyfixed coordinates at ET. */

    spkgeo_(&c__10, &et, "IAU_EARTH", &c__399, sunsta, &lt, (ftnlen)9);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    recgeo_(sunsta, &re, &f, &sunlon, &sunlat, &sunalt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Make sure the directional coordinates match up. */

    chcksd_("Sub point lon", &lon, "~", &sunlon, &c_b32, ok, (ftnlen)13, (
	    ftnlen)1);
    chcksd_("Sub point lat", &lat, "~", &sunlat, &c_b32, ok, (ftnlen)13, (
	    ftnlen)1);

/*     SUBPT error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid method.", (ftnlen)15);
    subpt_("NARPOINT", "399", &et, "NONE", "10", spoint, &alt, (ftnlen)8, (
	    ftnlen)3, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_true, "SPICE(DUBIOUSMETHOD)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid observer name.", (ftnlen)22);
    subpt_("Nearpoint", "earth", &et, "NONE", "sn", spoint, &alt, (ftnlen)9, (
	    ftnlen)5, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid target name.", (ftnlen)20);
    subpt_("Nearpoint", "erth", &et, "NONE", "sun", spoint, &alt, (ftnlen)9, (
	    ftnlen)4, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Observer is target.", (ftnlen)19);
    subpt_("Nearpoint", "earth", &et, "NONE", "earth", spoint, &alt, (ftnlen)
	    9, (ftnlen)5, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_true, "SPICE(BODIESNOTDISTINCT)", ok, (ftnlen)24);

/*     ILLUM tests follow. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test ILLUM.  Find the illumination angles on the earth as"
	    " seen from the moon, evaluated at the sub-moon point (NEARPOINT "
	    "method).", (ftnlen)240, (ftnlen)129);
    tcase_(title, (ftnlen)240);
    subpt_("Nearpoint", "earth", &et, "NONE", "moon", spoint, &alt, (ftnlen)9,
	     (ftnlen)5, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    illum_("EARTH", &et, "NONE", "MOON", spoint, &phase, &solar, &emissn, (
	    ftnlen)5, (ftnlen)4, (ftnlen)4);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We should have an emission angle of zero. */

    chcksd_("Emission angle", &emissn, "~", &c_b108, &c_b32, ok, (ftnlen)14, (
	    ftnlen)1);

/*     The phase angle should match the solar incidence angle. */

    chcksd_("Phase angle", &phase, "~", &solar, &c_b32, ok, (ftnlen)11, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Repeat tests with integer codes.", (ftnlen)32);
    subpt_("Nearpoint", "399", &et, "NONE", "301", spoint, &alt, (ftnlen)9, (
	    ftnlen)3, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    illum_("399", &et, "NONE", "301", spoint, &phase, &solar, &emissn, (
	    ftnlen)3, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We should have an emission angle of zero. */

    chcksd_("Emission angle", &emissn, "~", &c_b108, &c_b32, ok, (ftnlen)14, (
	    ftnlen)1);

/*     The phase angle should match the solar incidence angle. */

    chcksd_("Phase angle", &phase, "~", &solar, &c_b32, ok, (ftnlen)11, (
	    ftnlen)1);

/*     Now make the sun the observer:  test the solar incidence */
/*     angle. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test ILLUM.  Find the illumination angles on the earth as"
	    " seen from the sun, evaluated at the sub-sun point (NEARPOINT me"
	    "thod).", (ftnlen)240, (ftnlen)127);
    tcase_(title, (ftnlen)240);
    subpt_("Nearpoint", "earth", &et, "NONE", "sun", spoint, &alt, (ftnlen)9, 
	    (ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    illum_("EARTH", &et, "NONE", "sun", spoint, &phase, &solar, &emissn, (
	    ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We should have an solar incidence angle of zero. */

    chcksd_("Solar inc. angle", &solar, "~", &c_b108, &c_b32, ok, (ftnlen)16, 
	    (ftnlen)1);

/*     The phase angle should match the solar incidence angle. */

    chcksd_("Phase angle", &phase, "~", &solar, &c_b32, ok, (ftnlen)11, (
	    ftnlen)1);

/*     ILLUM error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid observer name.", (ftnlen)22);
    illum_("earth", &et, "NONE", "son", spoint, &phase, &solar, &emissn, (
	    ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid target name.", (ftnlen)20);
    illum_("erth", &et, "NONE", "sun", spoint, &phase, &solar, &emissn, (
	    ftnlen)4, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Observer is target.", (ftnlen)19);
    illum_("SUN", &et, "NONE", "sun", spoint, &phase, &solar, &emissn, (
	    ftnlen)3, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(BODIESNOTDISTINCT)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("No body-fixed frame associated with target.", (ftnlen)43);
    illum_("mars express", &et, "NONE", "sun", spoint, &phase, &solar, &
	    emissn, (ftnlen)12, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(NOFRAME)", ok, (ftnlen)14);

/*     SUBSOL tests follow. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test SUBSOL.  Find the sub-solar point of the sun on the "
	    "Earth using the NEARPOINT definition.", (ftnlen)240, (ftnlen)94);
    tcase_(title, (ftnlen)240);
    str2et_("1999 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subsol_("NEARPOINT", "EARTH", &et, "NONE", "SUN", spoint, (ftnlen)9, (
	    ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subpt_("NEARPOINT", "EARTH", &et, "NONE", "SUN", exppnt, &alt, (ftnlen)9, 
	    (ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    reclat_(spoint, &rad, &lon, &lat);

/*     Make sure the surface points match up. */

    chckad_("Geometric sub solar point", spoint, "~~/", exppnt, &c__3, &c_b32,
	     ok, (ftnlen)25, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test SUBSOL.  Repeat test using integer codes.", (ftnlen)
	    240, (ftnlen)46);
    tcase_(title, (ftnlen)240);
    str2et_("1999 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subsol_("NEARPOINT", "399", &et, "NONE", "10", spoint, (ftnlen)9, (ftnlen)
	    3, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subpt_("NEARPOINT", "EARTH", &et, "NONE", "SUN", exppnt, &alt, (ftnlen)9, 
	    (ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    reclat_(spoint, &rad, &lon, &lat);

/*     Make sure the surface points match up. */

    chckad_("Geometric sub solar point", spoint, "~~/", exppnt, &c__3, &c_b32,
	     ok, (ftnlen)25, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Test SUBSOL.  Find the sub-solar point of the sun on the "
	    "Earth using the INTERCEPT definition.", (ftnlen)240, (ftnlen)94);
    tcase_(title, (ftnlen)240);
    str2et_("1999 JAN 1", &et, (ftnlen)10);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subsol_("INTERCEPT", "EARTH", &et, "NONE", "SUN", spoint, (ftnlen)9, (
	    ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    subpt_("INTERCEPT", "EARTH", &et, "NONE", "SUN", exppnt, &alt, (ftnlen)9, 
	    (ftnlen)5, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    reclat_(spoint, &rad, &lon, &lat);

/*     Make sure the surface points match up. */

    chckad_("Geometric sub solar point", spoint, "~~/", exppnt, &c__3, &c_b32,
	     ok, (ftnlen)25, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid method.", (ftnlen)15);
    subsol_("NARPOINT", "399", &et, "NONE", "10", spoint, (ftnlen)8, (ftnlen)
	    3, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_true, "SPICE(DUBIOUSMETHOD)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid observer name.", (ftnlen)22);
    subsol_("Nearpoint", "earth", &et, "NONE", "sn", spoint, (ftnlen)9, (
	    ftnlen)5, (ftnlen)4, (ftnlen)2);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid target name.", (ftnlen)20);
    subsol_("Nearpoint", "erth", &et, "NONE", "sun", spoint, (ftnlen)9, (
	    ftnlen)4, (ftnlen)4, (ftnlen)3);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("Observer is target.", (ftnlen)19);
    subsol_("Nearpoint", "earth", &et, "NONE", "earth", spoint, (ftnlen)9, (
	    ftnlen)5, (ftnlen)4, (ftnlen)5);
    chckxc_(&c_true, "SPICE(BODIESNOTDISTINCT)", ok, (ftnlen)24);



/* --- Case: ------------------------------------------------------ */

    tcase_("Clean up:  delete kernels.", (ftnlen)26);
    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test.bsp", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ge01__ */

