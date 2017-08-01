/* f_nearpt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b3 = -1.;
static doublereal c_b4 = 1.;
static doublereal c_b5 = 10.;
static doublereal c_b12 = -3.;
static doublereal c_b13 = 100.;
static doublereal c_b21 = 2.;
static doublereal c_b24 = 1.0000000000000011;
static integer c__14 = 14;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static doublereal c_b43 = 1e-15;
static doublereal c_b44 = 1e-11;
static doublereal c_b65 = 0.;
static doublereal c_b66 = .99999899999999997;
static doublereal c_b99 = 3.;
static doublereal c_b135 = 1e-13;
static doublereal c_b136 = 1e-9;
static integer c__3 = 3;

/* $Procedure F_NEARPT ( NEARPT tests ) */
/* Subroutine */ int f_nearpt__(logical *ok)
{
    /* Initialized data */

    static doublereal origin[3] = { 0.,0.,0. };

    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2, d__3;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer i_dnnt(doublereal *);
    double cos(doublereal), sin(doublereal);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer seed;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal srfx[3];
    extern logical t_isedpt__(doublereal *, doublereal *, doublereal *, 
	    doublereal *, logical *), t_isnppt__(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, logical *);
    doublereal a, b, c__;
    integer i__;
    doublereal scale;
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *),
	     tcase_(char *, ftnlen), vpack_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal pnear[3], theta, level;
    extern /* Subroutine */ int repmd_(char *, char *, doublereal *, integer *
	    , char *, ftnlen, ftnlen, ftnlen);
    doublereal ipalt;
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[400];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    logical valpt;
    extern /* Subroutine */ int t_success__(logical *), cgv2el_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    extern doublereal pi_(void);
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chcksd_(
	    char *, doublereal *, char *, doublereal *, doublereal *, logical 
	    *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    doublereal ipnear[3];
    logical isnear;
    doublereal sfactr, ellips[9];
    integer pindex;
    extern /* Subroutine */ int nearpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *), vsclip_(
	    doublereal *, doublereal *), npelpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal gv1[3], gv2[3], viewpt[3];
    extern /* Subroutine */ int surfpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, logical *)
	    ;
    doublereal alt;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);

/* $ Abstract */

/*     Exercise the SPICELIB routine NEARPT.  NEARPT find the nearest */
/*     point on the surface of an ellipsoid to a specified point. */

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

/*     This routine tests the SPICELIB routine NEARPT. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 14-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local parameters */


/*     SPICELIB ellipse upper bound. */


/*     Altitude tolerance:  this is applied to the sum of */
/*     altitude of the view point and the maximum of the */
/*     ellipsoid's axis lengths.  The reason the tolerance is not */
/*     applied to the altitude directly is that the altitude may have */
/*     large relative errors, but still be accurate, when the view point */
/*     is close to the surface. */


/*     Angular separation tolerance:  this applies to the angular */
/*     separation between the near point-to-view point vector and */
/*     the properly signed normal vector at the near point. */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     In this test family, we encapsulate some of the geometric */
/*     tests within functions defined in this file. The function */

/*        T_ISEDPT */

/*     tests a point is on a specified ellipsoid: */

/*        - A point P = (x,y,z) is "on" the ellipsoid with semi-axis */
/*          lengths a, b, c if the "level surface parameter" */

/*             lambda = x**2/a**2 + y**2/b**2 + z**2/c**2 */

/*          is sufficiently close to 1. */


/*     The function */

/*        T_ISNPPT */

/*     test whether the near point found by NEARPT has the property */
/*     that the outward normal at the near point can be extended to */
/*     touch the input point. */

/*     T_ISNPPT also checks the distance of the near point from the */
/*     point: the distance is checked against the value obtained from */
/*     NPLNPT. */


/*     Open the test family. */

    topen_("F_NEARPT", (ftnlen)8);

/*     First set of test cases:  random ellipsoids and random */
/*     *exterior* viewing points. */

    seed = -1;
    for (i__ = 1; i__ <= 4000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Make up ellipsoid axis lengths. */

	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	a = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	b = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	c__ = pow_dd(&c_b5, &d__1);

/*        Create viewing point. */

	d__1 = t_randd__(&c_b12, &c_b13, &seed);
	viewpt[0] = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b12, &c_b13, &seed);
	viewpt[1] = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b12, &c_b13, &seed);
	viewpt[2] = pow_dd(&c_b5, &d__1);

/*        Find the level surface parameter of the view point. */

	d__1 = viewpt[0] / a;
	d__2 = viewpt[1] / b;
	d__3 = viewpt[2] / c__;
	level = pow_dd(&d__1, &c_b21) + pow_dd(&d__2, &c_b21) + pow_dd(&d__3, 
		&c_b21);

/*        If the viewing point is inside the ellipsoid, replace it */
/*        with the surface point found by scaling up the viewing */
/*        point. */

	if (level < 1.) {

/*           FOUND will always be .TRUE. in this case. */

	    surfpt_(origin, viewpt, &a, &b, &c__, srfx, &found);

/*           Scale the point up a tad for safety. */

	    vscl_(&c_b24, srfx, viewpt);
	}
	s_copy(title, "Initial NEARPT exterior random case #. For this set o"
		"f cases, we don't use extreme scale differences for the axis"
		" lengths:  range is [0.1 : 10]. VIEWPT components are in ran"
		"ge [0.001 : 1.e150]. A = #; B = #; C = #; VIEWPT = (#,#,#).", 
		(ftnlen)400, (ftnlen)232);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	repmd_(title, "#", &a, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &b, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &c__, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", viewpt, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &viewpt[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &viewpt[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	tcase_(title, (ftnlen)400);

/*        Cross our fingers and toes and let 'er rip. */

	nearpt_(viewpt, &a, &b, &c__, pnear, &alt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (*ok) {

/*           Make sure the near point we found belongs to */
/*           the surface of the ellipsoid. */

	    valpt = t_isedpt__(pnear, &a, &b, &c__, ok);
	    chcksl_("Is near point on surface?", &valpt, &c_true, ok, (ftnlen)
		    25);

/*           The outward normal at the near point should point towards */
/*           the view point. */

	    isnear = t_isnppt__(viewpt, &a, &b, &c__, pnear, &alt, &c_b43, &
		    c_b44, ok);
	    chcksl_("Is signed outward normal parallel to  near point-view p"
		    "oint vector?  Is distance correct?", &isnear, &c_true, ok,
		     (ftnlen)89);
	}
    }

/*     Second set of test cases:  random ellipsoids and random */
/*     *interior* viewing points.  At this point, we don't verify */
/*     that the solutions are absolute minima, but we do verify */
/*     that they are critical points. */

    seed = -1;
    for (i__ = 1; i__ <= 4000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Make up ellipsoid axis lengths. */

	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	a = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	b = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	c__ = pow_dd(&c_b5, &d__1);

/*        Create viewing point. */

	viewpt[0] = t_randd__(&c_b3, &c_b4, &seed);
	viewpt[1] = t_randd__(&c_b3, &c_b4, &seed);
	viewpt[2] = t_randd__(&c_b3, &c_b4, &seed);

/*        Find the level surface parameter of the view point. */

	d__1 = viewpt[0] / a;
	d__2 = viewpt[1] / b;
	d__3 = viewpt[2] / c__;
	level = pow_dd(&d__1, &c_b21) + pow_dd(&d__2, &c_b21) + pow_dd(&d__3, 
		&c_b21);

/*        If the viewing point is outside the ellipsoid, replace it */
/*        with an interior point found by scaling down the surface */
/*        point corresponding to the viewing point. */

	if (level >= 1.) {

/*           FOUND will always be .TRUE. in this case. */

	    surfpt_(origin, viewpt, &a, &b, &c__, srfx, &found);

/*           Scale the point down to make it usable. */

	    sfactr = t_randd__(&c_b65, &c_b66, &seed);
	    vscl_(&sfactr, srfx, viewpt);
	}
	s_copy(title, "Initial NEARPT interior random case #. For this set o"
		"f cases, we don't use extreme scale differences for the axis"
		" lengths:  range is [0.1 : 10]. VIEWPT components are in ran"
		"ge [0.001 : 1.e150]. A = #; B = #; C = #; VIEWPT = (#,#,#).", 
		(ftnlen)400, (ftnlen)232);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	repmd_(title, "#", &a, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &b, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &c__, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", viewpt, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &viewpt[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &viewpt[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	tcase_(title, (ftnlen)400);

/*        Cross our fingers and toes and let 'er rip. */

	nearpt_(viewpt, &a, &b, &c__, pnear, &alt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the near point we found is contained in */
/*        both the plane and the surface of the ellipsoid. */

	if (*ok) {

/*           Make sure the near point we found belongs to */
/*           the surface of the ellipsoid. */

	    valpt = t_isedpt__(pnear, &a, &b, &c__, ok);
	    chcksl_("Is near point on surface?", &valpt, &c_true, ok, (ftnlen)
		    25);

/*           The inward normal at the near point should point towards */
/*           the view point. */

	    isnear = t_isnppt__(viewpt, &a, &b, &c__, pnear, &alt, &c_b43, &
		    c_b44, ok);
	    chcksl_("Is signed normal parallel to  near point-view point vec"
		    "tor?  Is distance correct?", &isnear, &c_true, ok, (
		    ftnlen)81);
	}
    }

/*     Third set of test cases:  random ellipsoids and random */
/*     viewing points lying on principal planes. */

    seed = -1;
    for (i__ = 1; i__ <= 4000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Make up ellipsoid axis lengths. */

	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	a = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	b = pow_dd(&c_b5, &d__1);
	d__1 = t_randd__(&c_b3, &c_b4, &seed);
	c__ = pow_dd(&c_b5, &d__1);

/*        Do a few tests to check for problems in the special */
/*        cases where the axes are not distinct. */

	if (i__ < 200) {

/*           Turn the ellipsoid into a sphere. */

	    b = a;
	    c__ = a;
	} else if (i__ < 400) {

/*           The ellipsoid is symmetric about X. */

	    b = c__;
	} else if (i__ < 600) {

/*           The ellipsoid is symmetric about Y. */

	    c__ = a;
	} else if (i__ < 800) {

/*           The ellipsoid is symmetric about Z. */

	    b = a;
	}

/*        Create viewing point.  We pick a plane index, a scale factor */
/*        to give us the radius of the point, and an angular argument. */

	d__1 = t_randd__(&c_b4, &c_b99, &seed);
	pindex = i_dnnt(&d__1);
	scale = t_randd__(&c_b65, &c_b4, &seed);
	d__1 = -pi_();
	d__2 = pi_();
	theta = t_randd__(&d__1, &d__2, &seed);
	if (pindex == 1) {

/*           The point lies in the y-z plane. */

	    viewpt[0] = 0.;
	    viewpt[1] = scale * b * cos(theta);
	    viewpt[2] = scale * c__ * sin(theta);

/*           In addition to creating a viewing point, create generating */
/*           vectors for the intersection ellipse defined by the */
/*           ellipsoid and the y-z plane.  We'll use this ellipse later. */

	    vpack_(&c_b65, &b, &c_b65, gv1);
	    vpack_(&c_b65, &c_b65, &c__, gv2);
	} else if (pindex == 2) {

/*           The point lies in the x-z plane. */

	    viewpt[0] = scale * a * cos(theta);
	    viewpt[1] = 0.;
	    viewpt[2] = scale * c__ * sin(theta);
	    vpack_(&a, &c_b65, &c_b65, gv1);
	    vpack_(&c_b65, &c_b65, &c__, gv2);
	} else {

/*           The point lies in the x-Y plane. */

	    viewpt[0] = scale * a * cos(theta);
	    viewpt[1] = scale * b * sin(theta);
	    viewpt[2] = 0.;
	    vpack_(&a, &c_b65, &c_b65, gv1);
	    vpack_(&c_b65, &b, &c_b65, gv2);
	}

/*        Create the ellipse from the generating vectors. */

	cgv2el_(origin, gv1, gv2, ellips);

/*        If the viewing point is outside the ellipsoid, replace it */
/*        with an interior point found by scaling down the surface */
/*        point corresponding to the viewing point. */

/*        Find the level surface parameter of the view point. */

	d__1 = viewpt[0] / a;
	d__2 = viewpt[1] / b;
	d__3 = viewpt[2] / c__;
	level = pow_dd(&d__1, &c_b21) + pow_dd(&d__2, &c_b21) + pow_dd(&d__3, 
		&c_b21);
	if (level >= 1.) {
	    sfactr = .99999899999999997;
	    vsclip_(&sfactr, viewpt);
	}
	s_copy(title, "NEARPT interior principal plane random case #.  For t"
		"his set of cases, we don't use extreme scale differences for"
		" the axis lengths:  range is [0.1 : 10]. VIEWPT components a"
		"re in range [0.001 : 1.e150]. A = #; B = #; C = #; VIEWPT = "
		"(#,#,#).", (ftnlen)400, (ftnlen)241);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	repmd_(title, "#", &a, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &b, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &c__, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", viewpt, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &viewpt[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &viewpt[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	tcase_(title, (ftnlen)400);

/*        Cross our fingers and toes and let 'er rip. */

	nearpt_(viewpt, &a, &b, &c__, pnear, &alt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the near point we found is contained in */
/*        both the plane and the surface of the ellipsoid. */

	if (*ok) {

/*           Make sure the near point we found belongs to */
/*           the surface of the ellipsoid. */

	    valpt = t_isedpt__(pnear, &a, &b, &c__, ok);
	    chcksl_("Is near point on surface?", &valpt, &c_true, ok, (ftnlen)
		    25);

/*           The inward normal at the near point should point towards */
/*           the view point.  For these cases we use a more lenient */
/*           tolerance for the angular separation.  We also use a */
/*           slightly looser altitude tolerance. */

	    isnear = t_isnppt__(viewpt, &a, &b, &c__, pnear, &alt, &c_b135, &
		    c_b136, ok);
	    chcksl_("Is signed normal parallel to  near point-view point vec"
		    "tor?  Is distance correct?", &isnear, &c_true, ok, (
		    ftnlen)81);
	    if (pnear[(i__1 = pindex - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge(
		    "pnear", i__1, "f_nearpt__", (ftnlen)631)] != 0.) {

/*              We have a solution that doesn't lie in the same plane */
/*              as the viewing point.  This may well be correct, but */
/*              we'll check it.  Find the in-plane solution and */
/*              compare altitudes. */

		npelpt_(viewpt, ellips, ipnear, &ipalt);

/*              We expect the in-plane "altitude" to be greater than */
/*              or equal to that of the out-of-plane near point. */

		chcksd_("IPALT", &ipalt, ">=", &alt, &c_b65, ok, (ftnlen)5, (
			ftnlen)2);
/*               WRITE (*,*) 'IPALT - ALT = ', IPALT - ALT */
/*               WRITE (*,*) 'Out-of-plane solution' */
/*               WRITE (*,*) 'view point = ', VIEWPT */
/*               WRITE (*,*) 'near point = ', PNEAR */
/*               WRITE (*,*) 'altitude   = ', ALT */
/*               WRITE (*,*) '=======================' */
	    }
	}
    }

/*     NEARPT special cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ellipsoid is sphere; point is at origin.", (ftnlen)48);
    cleard_(&c__3, viewpt);
    nearpt_(viewpt, &c_b4, &c_b4, &c_b4, pnear, &alt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &c_b3, &c_b43, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ellipsoid is bi-axial; point is at origin.", (ftnlen)50);
    cleard_(&c__3, viewpt);
    nearpt_(viewpt, &c_b21, &c_b21, &c_b4, pnear, &alt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &c_b3, &c_b43, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ellipsoid is tri-axial; point is at origin.", (ftnlen)51);
    cleard_(&c__3, viewpt);
    nearpt_(viewpt, &c_b99, &c_b21, &c_b4, pnear, &alt);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("ALT", &alt, "~", &c_b3, &c_b43, ok, (ftnlen)3, (ftnlen)1);

/*     NEARPT error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ellipsoid has one zero-length axis.", (ftnlen)43);
    filld_(&c_b5, &c__3, viewpt);
    nearpt_(viewpt, &c_b65, &c_b4, &c_b4, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &c_b4, &c_b65, &c_b4, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &c_b4, &c_b4, &c_b65, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ellipsoid has one negative-length axis.", (ftnlen)47);
    nearpt_(viewpt, &c_b3, &c_b4, &c_b4, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &c_b4, &c_b3, &c_b4, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &c_b4, &c_b4, &c_b3, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: ratio of longest to shortest axes is too large.", (ftnlen)
	    55);
    a = 1e-6;
    b = 1e150;
    c__ = 1.;
    nearpt_(viewpt, &a, &b, &c__, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &c__, &a, &b, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    nearpt_(viewpt, &b, &c__, &a, pnear, &alt);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEARPT: product of scaled axis magnitude and scaled POSITN compo"
	    "nent is too large.", (ftnlen)82);
    a = 1e-6;
    b = 1e75;
    c__ = 1.;
    d__1 = pow_dd(&b, &c_b99);
    vpack_(&a, &d__1, &c__, viewpt);
    nearpt_(viewpt, &a, &b, &c__, pnear, &alt);
    chckxc_(&c_true, "SPICE(INPUTSTOOLARGE)", ok, (ftnlen)21);
    d__1 = pow_dd(&b, &c_b99);
    vpack_(&c__, &a, &d__1, viewpt);
    nearpt_(viewpt, &c__, &a, &b, pnear, &alt);
    chckxc_(&c_true, "SPICE(INPUTSTOOLARGE)", ok, (ftnlen)21);
    d__1 = pow_dd(&b, &c_b99);
    vpack_(&d__1, &c__, &a, viewpt);
    nearpt_(viewpt, &b, &c__, &a, pnear, &alt);
    chckxc_(&c_true, "SPICE(INPUTSTOOLARGE)", ok, (ftnlen)21);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_nearpt__ */


/*     The utility function T_ISNPPT tests whether the "near point" */
/*     found by NEARPT satisfies the criterion that the appropriately */
/*     signed surface normal at the near point has small angular */
/*     separation from the vector from the near point to view point. */

logical t_isnppt__(doublereal *v, doublereal *a, doublereal *b, doublereal *
	c__, doublereal *x, doublereal *alt, doublereal *atol, doublereal *
	stol, logical *ok)
{
    /* System generated locals */
    doublereal d__1, d__2, d__3;
    logical ret_val;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *);

    /* Local variables */
    doublereal pvec[3], xalt;
    extern doublereal vsep_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    doublereal level, maxax;
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal altsgn, normal[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *), surfnm_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal sep;


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Executable code. */


/*     Find the level surface parameter of the view point. */

    d__1 = v[0] / *a;
    d__2 = v[1] / *b;
    d__3 = v[2] / *c__;
    level = pow_dd(&d__1, &c_b21) + pow_dd(&d__2, &c_b21) + pow_dd(&d__3, &
	    c_b21);

/*     Set the sign of the altitude of the near point. */

    if (level >= 1.) {
	altsgn = 1.;
    } else {
	altsgn = -1.;
    }

/*     Find the vector from the near point to the view point. */

    vsub_(v, x, pvec);

/*     Checking the altitude can be problematic, since small altitudes */
/*     can be accurate but have a large relative error.  Instead, */
/*     check the relative error in the sum of the altitude and */
/*     the maximum axis. */

/* Computing MAX */
    d__1 = max(*a,*b);
    maxax = max(d__1,*c__);
    xalt = maxax + altsgn * vnorm_(pvec);
    d__1 = maxax + *alt;
    chcksd_("MAXAX+ALT", &d__1, "~/", &xalt, atol, ok, (ftnlen)9, (ftnlen)2);
    if (! (*ok)) {
	ret_val = FALSE_;
	return ret_val;
    }

/*     Obtain outward ellipsoid surface unit normal at the near point. */

    surfnm_(a, b, c__, x, normal);

/*     Adjust sign of normal vector according to whether view point is */
/*     inside or outside the ellipsoid. */

    vsclip_(&altsgn, normal);

/*     Find angular separation of sign-adjusted normal and PVEC. */

    sep = vsep_(normal, pvec);

/*     Check the angular separation. */

    chcksd_("SEP", &sep, "~", &c_b65, stol, ok, (ftnlen)3, (ftnlen)1);
    ret_val = *ok;
    return ret_val;
} /* t_isnppt__ */

