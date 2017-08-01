/* f_slice.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b3 = 3.;
static doublereal c_b4 = .5;
static logical c_false = FALSE_;
static doublereal c_b46 = 1e-14;
static doublereal c_b49 = -290.;
static doublereal c_b50 = 290.;
static doublereal c_b51 = 10.;
static doublereal c_b52 = 1.;
static doublereal c_b53 = 100.;
static doublereal c_b60 = -1.;
static integer c__14 = 14;
static logical c_true = TRUE_;
static integer c__4 = 4;
static integer c__3 = 3;
static doublereal c_b100 = 0.;
static doublereal c_b150 = -20.;
static doublereal c_b151 = 20.;
static doublereal c_b165 = .1;
static doublereal c_b232 = 5e-14;

/* $Procedure F_SLICE ( Ellipsoid/plane intersection routine tests ) */
/* Subroutine */ int f_slice__(logical *ok)
{
    /* Initialized data */

    static doublereal easya[3] = { 100.,200.,4. };
    static doublereal easyb[3] = { 10.,2.,40. };
    static doublereal easyc[3] = { 1.,20.,400. };
    static doublereal easypt[9]	/* was [3][3] */ = { 0.,0.,2.,0.,4.,0.,-8.,0.,
	    0. };
    static doublereal smprad[24]	/* was [3][8] */ = { 1.,1.,1.,2e20,
	    2e20,2e20,4e-20,4e-20,4e-20,.5,1.,4.,1e6,2e6,4e6,1e6,1e6,1e6,1.,
	    1.,1.,1.,1.,1. };
    static doublereal smpn[24]	/* was [3][8] */ = { 0.,0.,1.,0.,1.,0.,-1.,1.,
	    0.,0.,0.,1.,0.,0.,1.,1.,1.,1.,0.,0.,1.,0.,0.,1. };
    static doublereal smpc[8] = { 0.,1e20,2e-20,2.,2e6,5e5,1.,1.0000000001 };
    static logical xfound[8] = { TRUE_,TRUE_,TRUE_,TRUE_,TRUE_,TRUE_,TRUE_,
	    FALSE_ };

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer seed;
    doublereal limb[9], near__[3];
    extern /* Subroutine */ int vhat_(doublereal *, doublereal *), vequ_(
	    doublereal *, doublereal *);
    extern logical t_islimb__(doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, logical *), t_ispxed__(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, logical *)
	    ;
    doublereal a, b, c__;
    integer i__;
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *);
    doublereal plane[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmd_(char *, char *,
	     doublereal *, integer *, char *, ftnlen, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), vlcom_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal const__;
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int t_success__(logical *), el2cgv_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), nvc2pl_(doublereal *, 
	    doublereal *, doublereal *), cleard_(integer *, doublereal *), 
	    edlimb_(doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *), chcksd_(char *, doublereal *, char *, doublereal *,
	     doublereal *, logical *, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    doublereal pt[3], xl[16]	/* was [2][8] */;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), inedpl_(doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, logical *);
    doublereal center[3], pfactr, sfactr;
    logical valell;
    doublereal ellips[9], normal[3];
    extern /* Subroutine */ int nearpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *);
    doublereal smajor[3];
    extern /* Subroutine */ int vhatip_(doublereal *);
    logical iselvl;
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal sminor[3];
    extern /* Subroutine */ int surfnm_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal alt;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);

/* $ Abstract */

/*     Exercise SPICELIB routines that slice ellipsoids with planes. */

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

/*     This routine tests the SPICELIB routines */

/*        INEDPL */
/*        EDLIMB */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 15-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     In this test family, we encapsulate some of the geometric */
/*     tests within functions defined in this file. The function */

/*        T_ISPXED */

/*     test whether an ellipse is the intersection of a specified */
/*     plane and ellipsoid.  It does this by testing the four */
/*     endpoints of the ellipse's axes to see whether they are */

/*        - On the ellipsoid:  a point P = (x,y,z) is "on" the */
/*          ellipsoid with semi-axis lengths a, b, c if */
/*          the "level surface parameter" */

/*             lambda = x**2/a**2 + y**2/b**2 + z**2/c**2 */

/*          is sufficiently close to 1. */


/*        - On the plane:  a point P = (x,y,z) is "on" the */
/*          plane with normal vector N and constant C if */
/*          the dot product */

/*             < N, P > */

/*          is sufficiently close to C. */


/*     The function */

/*        T_ISLIMB */

/*     test whether an ellipse is the limb defined by a specified */
/*     viewing point and ellipsoid.  It does this by testing the */
/*     four endpoints of the ellipse's axes to see whether, for each */
/*     endpoint, the ray from the viewing point to the endpoint is */
/*     orthogonal to the ellipsoid's outward normal direction at the */
/*     endpoint. */


/*     Open the test family. */

    topen_("F_SLICE", (ftnlen)7);

/*     Perform a number of simple INEDPL tests for which we can compute */
/*     the intersection ellipse in advance. */


/*     Set up expected semi-axis lengths for the "simple" tests. */

    xl[0] = 1.;
    xl[1] = 1.;
    xl[2] = pow_dd(&c_b3, &c_b4) * 1e20;
    xl[3] = pow_dd(&c_b3, &c_b4) * 1e20;
    xl[4] = pow_dd(&c_b3, &c_b4) * 2. * 1e-20;
    xl[5] = pow_dd(&c_b3, &c_b4) * 2. * 1e-20;
    xl[6] = pow_dd(&c_b3, &c_b4) * .5;
    xl[7] = pow_dd(&c_b3, &c_b4);
    xl[8] = pow_dd(&c_b3, &c_b4) * 1e6;
    xl[9] = pow_dd(&c_b3, &c_b4) * .5 * 1e6;
    xl[10] = pow_dd(&c_b3, &c_b4) * .5 * 1e6;
    xl[11] = pow_dd(&c_b3, &c_b4) * .5 * 1e6;
    xl[12] = 0.;
    xl[13] = 0.;
    for (i__ = 1; i__ <= 8; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "An INEDPL case that can be checked by inspection; cas"
		"e #.", (ftnlen)240, (ftnlen)57);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);
	vhat_(&smpn[(i__1 = i__ * 3 - 3) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"smpn", i__1, "f_slice__", (ftnlen)325)], normal);
	const__ = smpc[(i__1 = i__ - 1) < 8 && 0 <= i__1 ? i__1 : s_rnge(
		"smpc", i__1, "f_slice__", (ftnlen)327)];
	a = smprad[(i__1 = i__ * 3 - 3) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"smprad", i__1, "f_slice__", (ftnlen)329)];
	b = smprad[(i__1 = i__ * 3 - 2) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"smprad", i__1, "f_slice__", (ftnlen)330)];
	c__ = smprad[(i__1 = i__ * 3 - 1) < 24 && 0 <= i__1 ? i__1 : s_rnge(
		"smprad", i__1, "f_slice__", (ftnlen)331)];
	nvc2pl_(normal, &const__, plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	inedpl_(&a, &b, &c__, plane, ellips, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (i__ != 7) {

/*           Check the FOUND flag on all cases but case 7.  Case */
/*           7 is a boundary case that may fail on some platforms. */

	    chcksl_("FOUND", &found, &xfound[(i__1 = i__ - 1) < 8 && 0 <= 
		    i__1 ? i__1 : s_rnge("xfound", i__1, "f_slice__", (ftnlen)
		    344)], ok, (ftnlen)5);
	}
	if (found) {

/*           Check the ellipse to make sure it is in the plane */
/*           and on the surface of the ellipsoid. */

	    valell = t_ispxed__(ellips, &a, &b, &c__, plane, ok);
	    el2cgv_(ellips, center, smajor, sminor);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check the lengths of the semi-axes. */

	    d__1 = vnorm_(smajor);
	    chcksd_("||SMAJOR||", &d__1, "~/", &xl[(i__1 = (i__ << 1) - 2) < 
		    16 && 0 <= i__1 ? i__1 : s_rnge("xl", i__1, "f_slice__", (
		    ftnlen)361)], &c_b46, ok, (ftnlen)10, (ftnlen)2);
	}
    }

/*     Now for some more difficult cases.  We'll generate the ellipsoids */
/*     and planes using random numbers.  There are four components to */
/*     generate: */

/*        - random plane normal vectors */
/*        - random ellipsoid axes */
/*        - random plane constants */
/*        - random scale factors for the ellipsoid and plane; these are */
/*          used to create a wide range of scales */

    seed = -1;
    for (i__ = 1; i__ <= 1000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Get a scale factor. */

	d__1 = t_randd__(&c_b49, &c_b50, &seed);
	sfactr = pow_dd(&c_b51, &d__1);

/*        Make up ellipsoid axes and plane constant. */

	a = sfactr * t_randd__(&c_b52, &c_b53, &seed);
	b = sfactr * t_randd__(&c_b52, &c_b53, &seed);
	c__ = sfactr * t_randd__(&c_b52, &c_b53, &seed);
	const__ = sfactr * t_randd__(&c_b52, &c_b53, &seed);

/*        We gotta have a plane normal vector. */

	normal[0] = t_randd__(&c_b60, &c_b52, &seed);
	normal[1] = t_randd__(&c_b60, &c_b52, &seed);
	normal[2] = t_randd__(&c_b60, &c_b52, &seed);
	vhatip_(normal);
	s_copy(title, "INEDPL Random case #.  A, B, C = # # #; CONST = #; NO"
		"RMAL = (#, #, #)", (ftnlen)240, (ftnlen)69);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	repmd_(title, "#", &a, &c__14, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	repmd_(title, "#", &b, &c__14, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	repmd_(title, "#", &c__, &c__14, title, (ftnlen)240, (ftnlen)1, (
		ftnlen)240);
	repmd_(title, "#", &const__, &c__14, title, (ftnlen)240, (ftnlen)1, (
		ftnlen)240);
	repmd_(title, "#", normal, &c__14, title, (ftnlen)240, (ftnlen)1, (
		ftnlen)240);
	repmd_(title, "#", &normal[1], &c__14, title, (ftnlen)240, (ftnlen)1, 
		(ftnlen)240);
	repmd_(title, "#", &normal[2], &c__14, title, (ftnlen)240, (ftnlen)1, 
		(ftnlen)240);
	tcase_(title, (ftnlen)240);

/*        Cross our fingers and toes and let 'er rip. */

	nvc2pl_(normal, &const__, plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	inedpl_(&a, &b, &c__, plane, ellips, &found);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	el2cgv_(ellips, center, smajor, sminor);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (found) {

/*           Make sure the intersection ellipse we found is */
/*           contained in both the plane and the surface of the */
/*           ellipsoid. */

	    valell = t_ispxed__(ellips, &a, &b, &c__, plane, ok);
	    chcksl_("Is ellipse valid?", &valell, &c_true, ok, (ftnlen)17);
	}
    }

/*     INELPL error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("INEDPL: invalid plane", (ftnlen)21);
    cleard_(&c__4, plane);
    inedpl_(&c_b52, &c_b52, &c_b52, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(INVALIDPLANE)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("INEDPL: ellipsoid has one zero-length axis.", (ftnlen)43);
    filld_(&c_b52, &c__3, normal);
    nvc2pl_(normal, &c_b100, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inedpl_(&c_b100, &c_b52, &c_b52, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);
    inedpl_(&c_b52, &c_b100, &c_b52, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);
    inedpl_(&c_b52, &c_b52, &c_b100, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("INEDPL: ellipsoid has one negative-length axis.", (ftnlen)47);
    inedpl_(&c_b60, &c_b52, &c_b52, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);
    inedpl_(&c_b52, &c_b60, &c_b52, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);
    inedpl_(&c_b52, &c_b52, &c_b60, plane, ellips, &found);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Now for the EDLIMB tests. */


/*     Start out with easy cases for which the answers can be found */
/*     by inspection. */

    for (i__ = 1; i__ <= 3; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "An EDLIMB case that can be checked by inspection; cas"
		"e #.", (ftnlen)240, (ftnlen)57);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);
	a = easya[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("easya", 
		i__1, "f_slice__", (ftnlen)517)];
	b = easyb[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("easyb", 
		i__1, "f_slice__", (ftnlen)518)];
	c__ = easyc[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("easyc",
		 i__1, "f_slice__", (ftnlen)519)];
	vequ_(&easypt[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		"easypt", i__1, "f_slice__", (ftnlen)521)], pt);
	edlimb_(&a, &b, &c__, pt, limb);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	iselvl = t_islimb__(limb, &a, &b, &c__, pt, ok);
	if (*ok) {
	    valell = iselvl && *ok;
	    chcksl_("Is ellipse valid?", &valell, &c_true, ok, (ftnlen)17);
	}
    }

/*     Random cases for EDLIMB follow: */

    for (i__ = 1; i__ <= 1000; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "EDLIMB Random case #", (ftnlen)240, (ftnlen)20);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);

/*        Get a scale factor. */

	d__1 = t_randd__(&c_b150, &c_b151, &seed);
	sfactr = pow_dd(&c_b51, &d__1);

/*        Make up ellipsoid axes and viewing point. */

	a = sfactr * t_randd__(&c_b52, &c_b53, &seed);
	b = sfactr * t_randd__(&c_b52, &c_b53, &seed);
	c__ = sfactr * t_randd__(&c_b52, &c_b53, &seed);

/*        The viewing point must be outside the ellipsoid. */

	pt[0] = sfactr * t_randd__(&c_b60, &c_b52, &seed);
	pt[1] = sfactr * t_randd__(&c_b60, &c_b52, &seed);
	pt[2] = sfactr * t_randd__(&c_b60, &c_b52, &seed);

/*        In half of the cases, we'll scale PT by widely varying */
/*        scale factors.  In the other half, we'll keep PT close to */
/*        the ellipsoid, since these cases are more demanding. */

	if (i__ <= 500) {
	    d__1 = t_randd__(&c_b165, &c_b51, &seed);
	    pfactr = pow_dd(&c_b51, &d__1);
	} else {
	    pfactr = 1.;
	}
	vsclip_(&pfactr, pt);
	nearpt_(pt, &a, &b, &c__, near__, &alt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        If ALT is negative, just reflect PT about the tangent */
/*        plane at NEAR. */

	if (alt < 0.) {
	    surfnm_(&a, &b, &c__, near__, normal);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    vhatip_(normal);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = -alt;
	    vlcom_(&c_b52, near__, &d__1, normal, pt);
	}

/*        Cross our fingers and toes and let 'er rip. */

	edlimb_(&a, &b, &c__, pt, limb);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	iselvl = t_islimb__(limb, &a, &b, &c__, pt, ok);
	if (*ok) {
	    valell = iselvl && *ok;
	    chcksl_("Is ellipse valid?", &valell, &c_true, ok, (ftnlen)17);
	}
    }

/*     EDLIMB error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("EDLIMB: view point inside ellipsoid.", (ftnlen)36);
    cleard_(&c__3, pt);
    edlimb_(&c_b52, &c_b52, &c_b52, pt, limb);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    tcase_("EDLIMB: ellipsoid has one zero-length axis.", (ftnlen)43);
    filld_(&c_b51, &c__3, pt);
    edlimb_(&c_b100, &c_b52, &c_b52, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    edlimb_(&c_b52, &c_b100, &c_b52, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    edlimb_(&c_b52, &c_b52, &c_b100, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("EDLIMB: ellipsoid has one negative-length axis.", (ftnlen)47);
    edlimb_(&c_b60, &c_b52, &c_b52, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    edlimb_(&c_b52, &c_b60, &c_b52, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    edlimb_(&c_b52, &c_b52, &c_b60, pt, limb);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */


/*     This error may not be detected on some systems.  We exclude */
/*     it for now. */

/* CC   CALL TCASE  ( 'EDLIMB: squared, scaled axis length underflows.' ) */
/* CC      PT(1) = 1.D256 */
/* CC      PT(2) = 1.D0 */
/* CC      PT(3) = 1.D0 */
/* CC      CALL EDLIMB ( 1.D0, 1.D0, 1.D255, PT, LIMB ) */
/* CC      CALL CHCKXC ( .TRUE., 'SPICE(DEGENERATECASE)', OK ) */

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_slice__ */


/*     Supporting function T_ISLIMB */

logical t_islimb__(doublereal *limb, doublereal *a, doublereal *b, doublereal 
	*c__, doublereal *viewpt, logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2, d__3, d__4, d__5, d__6;
    logical ret_val;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal diff[3];
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal scla, sclb, sclc, elpt[12]	/* was [3][4] */;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    extern doublereal vsep_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    integer i__;
    doublereal scale, level;
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), chcksd_(char *, doublereal *, char *,
	     doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    extern doublereal halfpi_(void);
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    doublereal vp[3], center[3], normal[3], smajor[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal sminor[3];
    extern /* Subroutine */ int surfnm_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal sep;


/*     Test whether an ellipse is the limb of an ellipsoid as seen */
/*     from a specified viewing location. */


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Scale ellipse and viewing point. */

/* Computing MAX */
    d__1 = abs(*a), d__2 = abs(*b), d__1 = max(d__1,d__2), d__2 = abs(*c__), 
	    d__1 = max(d__1,d__2), d__2 = vnorm_(viewpt);
    scale = max(d__1,d__2);
    scla = *a / scale;
    sclb = *b / scale;
    sclc = *c__ / scale;
    d__1 = 1. / scale;
    vscl_(&d__1, viewpt, vp);
    el2cgv_(limb, center, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = 1.f / scale;
    vsclip_(&d__1, center);
    d__1 = 1.f / scale;
    vsclip_(&d__1, smajor);
    d__1 = 1.f / scale;
    vsclip_(&d__1, sminor);

/*     Construct the endpoints of the major and minor axes. */

    vadd_(center, smajor, elpt);
    vsub_(center, smajor, &elpt[3]);
    vadd_(center, sminor, &elpt[6]);
    vsub_(center, sminor, &elpt[9]);

/*     Check the `level' of each point. */

    for (i__ = 1; i__ <= 4; ++i__) {
/* Computing 2nd power */
	d__1 = elpt[(i__1 = i__ * 3 - 3) < 12 && 0 <= i__1 ? i__1 : s_rnge(
		"elpt", i__1, "t_islimb__", (ftnlen)781)];
/* Computing 2nd power */
	d__2 = scla;
/* Computing 2nd power */
	d__3 = elpt[(i__2 = i__ * 3 - 2) < 12 && 0 <= i__2 ? i__2 : s_rnge(
		"elpt", i__2, "t_islimb__", (ftnlen)781)];
/* Computing 2nd power */
	d__4 = sclb;
/* Computing 2nd power */
	d__5 = elpt[(i__3 = i__ * 3 - 1) < 12 && 0 <= i__3 ? i__3 : s_rnge(
		"elpt", i__3, "t_islimb__", (ftnlen)781)];
/* Computing 2nd power */
	d__6 = sclc;
	level = d__1 * d__1 / (d__2 * d__2) + d__3 * d__3 / (d__4 * d__4) + 
		d__5 * d__5 / (d__6 * d__6);
	chcksd_("LEVEL", &level, "~", &c_b52, &c_b232, ok, (ftnlen)5, (ftnlen)
		1);
	if (! (*ok)) {

/*           The putative limb point is not on the ellipsoid. */

	    ret_val = FALSE_;
	}
    }

/*     For each endpoint, find the surface normal and its */
/*     angular separation from the difference vector between it and */
/*     the viewing point. */

    for (i__ = 1; i__ <= 4; ++i__) {
	vsub_(vp, &elpt[(i__1 = i__ * 3 - 3) < 12 && 0 <= i__1 ? i__1 : 
		s_rnge("elpt", i__1, "t_islimb__", (ftnlen)804)], diff);
	surfnm_(a, b, c__, &elpt[(i__1 = i__ * 3 - 3) < 12 && 0 <= i__1 ? 
		i__1 : s_rnge("elpt", i__1, "t_islimb__", (ftnlen)806)], 
		normal);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	sep = vsep_(normal, diff);
	d__1 = halfpi_();
	chcksd_("SEP", &sep, "~", &d__1, &c_b232, ok, (ftnlen)3, (ftnlen)1);
	if (! (*ok)) {
	    return ret_val;
	}
    }
    ret_val = TRUE_;
    return ret_val;
} /* t_islimb__ */


/*     Supporting function T_ISPXED */

logical t_ispxed__(doublereal *ellips, doublereal *a, doublereal *b, 
	doublereal *c__, doublereal *plane, logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2, d__3, d__4, d__5, d__6;
    logical ret_val;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal scla, sclb, sclc, elpt[12]	/* was [3][4] */;
    extern doublereal vdot_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    integer i__;
    doublereal scale, level, const__;
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), pl2nvc_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal pc;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal center[3], normal[3], smajor[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal sminor[3];


/*     Test whether an ellipse is the intersection of a specified */
/*     plane and ellipsoid. */


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Scale ellipse and plane. */

/* Computing MAX */
    d__1 = abs(*a), d__2 = abs(*b), d__1 = max(d__1,d__2), d__2 = abs(*c__);
    scale = max(d__1,d__2);
    scla = *a / scale;
    sclb = *b / scale;
    sclc = *c__ / scale;
    el2cgv_(ellips, center, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = 1.f / scale;
    vsclip_(&d__1, center);
    d__1 = 1.f / scale;
    vsclip_(&d__1, smajor);
    d__1 = 1.f / scale;
    vsclip_(&d__1, sminor);

/*     Construct the endpoints of the major and minor axes. */

    vadd_(center, smajor, elpt);
    vsub_(center, smajor, &elpt[3]);
    vadd_(center, sminor, &elpt[6]);
    vsub_(center, sminor, &elpt[9]);

/*     Check the `level' of each point. */

    for (i__ = 1; i__ <= 4; ++i__) {
/* Computing 2nd power */
	d__1 = elpt[(i__1 = i__ * 3 - 3) < 12 && 0 <= i__1 ? i__1 : s_rnge(
		"elpt", i__1, "t_ispxed__", (ftnlen)914)];
/* Computing 2nd power */
	d__2 = scla;
/* Computing 2nd power */
	d__3 = elpt[(i__2 = i__ * 3 - 2) < 12 && 0 <= i__2 ? i__2 : s_rnge(
		"elpt", i__2, "t_ispxed__", (ftnlen)914)];
/* Computing 2nd power */
	d__4 = sclb;
/* Computing 2nd power */
	d__5 = elpt[(i__3 = i__ * 3 - 1) < 12 && 0 <= i__3 ? i__3 : s_rnge(
		"elpt", i__3, "t_ispxed__", (ftnlen)914)];
/* Computing 2nd power */
	d__6 = sclc;
	level = d__1 * d__1 / (d__2 * d__2) + d__3 * d__3 / (d__4 * d__4) + 
		d__5 * d__5 / (d__6 * d__6);
	chcksd_("LEVEL", &level, "~", &c_b52, &c_b232, ok, (ftnlen)5, (ftnlen)
		1);
	if (! (*ok)) {
	    ret_val = FALSE_;
	    return ret_val;
	}
    }

/*     Check each point to see if it's in the plane. */

    pl2nvc_(plane, normal, &const__);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    const__ /= scale;
    for (i__ = 1; i__ <= 4; ++i__) {
	pc = vdot_(&elpt[(i__1 = i__ * 3 - 3) < 12 && 0 <= i__1 ? i__1 : 
		s_rnge("elpt", i__1, "t_ispxed__", (ftnlen)939)], normal);
	chcksd_("PC", &pc, "~/", &const__, &c_b232, ok, (ftnlen)2, (ftnlen)2);
	if (! (*ok)) {
	    ret_val = FALSE_;
	    return ret_val;
	}
    }
    ret_val = TRUE_;
    return ret_val;
} /* t_ispxed__ */

