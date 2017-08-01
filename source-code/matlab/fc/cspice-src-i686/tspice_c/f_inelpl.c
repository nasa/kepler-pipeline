/* f_inelpl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static doublereal c_b5 = 2.;
static doublereal c_b6 = 0.;
static doublereal c_b9 = 1.;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c_n1 = -1;
static integer c__1 = 1;
static doublereal c_b85 = 1e-14;
static integer c__2 = 2;
static doublereal c_b109 = .5;
static doublereal c_b121 = -290.;
static doublereal c_b122 = 290.;
static doublereal c_b123 = 10.;
static doublereal c_b124 = -1.;
static integer c__14 = 14;
static logical c_true = TRUE_;
static integer c__4 = 4;
static doublereal c_b196 = 3.;
static doublereal c_b234 = 1e-13;
static doublereal c_b242 = 1e-12;

/* $Procedure F_INELPL ( Ellipse/plane intersection routine tests ) */
/* Subroutine */ int f_inelpl__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal), pow_dd(doublereal *, doublereal *);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal beta;
    integer seed;
    doublereal xpts[6]	/* was [3][2] */;
    extern logical t_ispxel__(doublereal *, doublereal *, integer *, 
	    doublereal *, logical *);
    integer i__, j, n;
    doublereal s, alpha, plane[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), repmd_(char *, char *, 
	    doublereal *, integer *, char *, ftnlen, ftnlen, ftnlen), repmi_(
	    char *, char *, integer *, char *, ftnlen, ftnlen, ftnlen);
    char title[800];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal const__, v1[3], v2[3];
    extern /* Subroutine */ int t_success__(logical *), cgv2el_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), vlcom3_(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), nvc2pl_(doublereal *, doublereal *, 
	    doublereal *), chckad_(char *, doublereal *, char *, doublereal *,
	     integer *, doublereal *, logical *, ftnlen, ftnlen), nvp2pl_(
	    doublereal *, doublereal *, doublereal *), cleard_(integer *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical *
	    , ftnlen);
    doublereal center[3];
    extern /* Subroutine */ int saelgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal sfactr;
    extern /* Subroutine */ int inelpl_(doublereal *, doublereal *, integer *,
	     doublereal *, doublereal *);
    doublereal ellips[9], normal[3], smajor[3];
    extern /* Subroutine */ int vhatip_(doublereal *);
    doublereal sminor[3];
    logical valxpt;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    doublereal ppt[3], xpt[6]	/* was [3][2] */;

/* $ Abstract */

/*     Exercise INELPL, the SPICELIB routine that slices ellipses */
/*     with planes. */

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

/*     This routine tests the SPICELIB routine INELPL. */

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

/*        T_ISPXEL */

/*     test whether a set of points constitute the intersection of a */
/*     specified plane and ellipse.  It does this by testing the points */
/*     to see whether they are */

/*        - On the ellipse:  a 2-d point P = (x,y) is "on" the */
/*          ellipse with semi-axis lengths a, b if */
/*          the "level surface parameter" */

/*             lambda = x**2/a**2 + y**2/b**2 */

/*          is sufficiently close to 1.  In three dimensions, the */
/*          point must lie in the plane of the ellipse and must */
/*          satisfy the above equation when mapped to a basis */
/*          spanned by the ellipse's semi-axes. */


/*        - On the plane:  a point P = (x,y,z) is "on" the */
/*          plane with normal vector N and constant C if */
/*          the dot product */

/*             < N, P > */

/*          is sufficiently close to C. */



/*     Open the test family. */

    topen_("F_INELPL", (ftnlen)8);

/*     Perform a number of simple INELPL tests for which we can compute */
/*     the intersection points in advance. */

/* --- Case: ------------------------------------------------------ */


    s_copy(title, "Ellipse and plane are parallel and disjoint.", (ftnlen)800,
	     (ftnlen)44);
    tcase_(title, (ftnlen)800);
    cleard_(&c__3, center);
    vpack_(&c_b5, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b9, &c_b6, sminor);

/*     Create the ellipse. */

    cgv2el_(center, smajor, sminor, ellips);
    vpack_(&c_b6, &c_b6, &c_b9, normal);
    const__ = 1.;

/*     Create the plane. */

    nvc2pl_(normal, &const__, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the intersection. */

    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the number of intersection points. */

    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


    s_copy(title, "Ellipse and plane are orthogonal and disjoint.", (ftnlen)
	    800, (ftnlen)46);
    tcase_(title, (ftnlen)800);
    cleard_(&c__3, center);
    vpack_(&c_b5, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b9, &c_b6, sminor);

/*     Create the ellipse. */

    cgv2el_(center, smajor, sminor, ellips);
    vpack_(&c_b9, &c_b6, &c_b6, normal);
    const__ = 3.;

/*     Create the plane. */

    nvc2pl_(normal, &const__, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the intersection. */

    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the number of intersection points. */

    chcksi_("N", &n, "=", &c__0, &c__0, ok, (ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


    s_copy(title, "Plane contains ellipse.", (ftnlen)800, (ftnlen)23);
    tcase_(title, (ftnlen)800);
    cleard_(&c__3, center);
    vpack_(&c_b5, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b9, &c_b6, sminor);

/*     Create the ellipse. */

    cgv2el_(center, smajor, sminor, ellips);
    vpack_(&c_b6, &c_b6, &c_b9, normal);
    const__ = 0.;

/*     Create the plane. */

    nvc2pl_(normal, &const__, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the intersection. */

    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the number of intersection points. */

    chcksi_("N", &n, "=", &c_n1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */


    s_copy(title, "Plane and ellipse intersect in a single point.", (ftnlen)
	    800, (ftnlen)46);
    tcase_(title, (ftnlen)800);
    cleard_(&c__3, center);
    vpack_(&c_b9, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b9, &c_b6, sminor);

/*     Create the ellipse. */

    cgv2el_(center, smajor, sminor, ellips);
    vpack_(&c_b9, &c_b6, &c_b6, normal);
    const__ = 1.;

/*     Create the plane. */

    nvc2pl_(normal, &const__, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the intersection. */

    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the number of intersection points. */

    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the intersection points. */

    vpack_(&c_b9, &c_b6, &c_b6, xpt);
    chckad_("XPT1", xpts, "~", xpt, &c__3, &c_b85, ok, (ftnlen)4, (ftnlen)1);
    chckad_("XPT2", &xpts[3], "~", xpt, &c__3, &c_b85, ok, (ftnlen)4, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */


    s_copy(title, "Plane and ellipse intersect along the line x = 0.5.", (
	    ftnlen)800, (ftnlen)51);
    tcase_(title, (ftnlen)800);
    cleard_(&c__3, center);
    vpack_(&c_b9, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b9, &c_b6, sminor);

/*     Create the ellipse. */

    cgv2el_(center, smajor, sminor, ellips);
    vpack_(&c_b9, &c_b6, &c_b6, normal);
    const__ = .5;

/*     Create the plane. */

    nvc2pl_(normal, &const__, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Find the intersection. */

    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the number of intersection points. */

    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);

/*     Check the intersection points. */

    if (xpts[1] < 0.) {
	s = -1.;
    } else {
	s = 1.;
    }
    d__1 = s * sqrt(3.) / 2.;
    vpack_(&c_b109, &d__1, &c_b6, xpt);
    chckad_("XPT1", xpts, "~", xpt, &c__3, &c_b85, ok, (ftnlen)4, (ftnlen)1);
    d__1 = -s * sqrt(3.) / 2.;
    vpack_(&c_b109, &d__1, &c_b6, xpt);
    chckad_("XPT2", &xpts[3], "~", xpt, &c__3, &c_b85, ok, (ftnlen)4, (ftnlen)
	    1);

/*     Now for some more difficult cases.  We'll generate the ellipses */
/*     and planes using random numbers.  There are four components to */
/*     generate: */

/*        - random plane normal vectors */
/*        - random ellipse axes */
/*        - random plane constants */
/*        - random scale factors for the ellipse and plane; these are */
/*          used to create a wide range of scales */

    seed = -1;
    for (i__ = 1; i__ <= 2000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Get a scale factor. */

	d__1 = t_randd__(&c_b121, &c_b122, &seed);
	sfactr = pow_dd(&c_b123, &d__1);

/*        Make up ellipse vectors. */

	for (j = 1; j <= 3; ++j) {
	    center[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("center", 
		    i__1, "f_inelpl__", (ftnlen)468)] = sfactr * t_randd__(&
		    c_b124, &c_b9, &seed);
	    v1[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("v1", i__1, 
		    "f_inelpl__", (ftnlen)469)] = sfactr * t_randd__(&c_b124, 
		    &c_b9, &seed);
	    v2[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("v2", i__1, 
		    "f_inelpl__", (ftnlen)470)] = sfactr * t_randd__(&c_b124, 
		    &c_b9, &seed);
	}

/*        Pack the ellipse. */

	cgv2el_(center, v1, v2, ellips);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Find the semi-axes of this ellipse. */

	saelgv_(v1, v2, smajor, sminor);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Generate a random point in the rectangle spanned by */
/*        the linear combinations */

/*           CENTER + alpha*SMAJOR + beta*SMINOR, */

/*               -1 <  alpha, beta  <  1 */
/*                  -               - */

	alpha = t_randd__(&c_b124, &c_b9, &seed);
	beta = t_randd__(&c_b124, &c_b9, &seed);
	vlcom3_(&c_b9, center, &alpha, smajor, &beta, sminor, ppt);

/*        We gotta have a plane normal vector. */

	normal[0] = t_randd__(&c_b124, &c_b9, &seed);
	normal[1] = t_randd__(&c_b124, &c_b9, &seed);
	normal[2] = t_randd__(&c_b124, &c_b9, &seed);
	vhatip_(normal);
	s_copy(title, "INELPL Random case #.  CENTER = (#, #, #); V1 = (#, #"
		", #); V2 = (#, #, #); PPT = (#, #, #); NORMAL = (#, #, #)", (
		ftnlen)800, (ftnlen)110);
	repmi_(title, "#", &i__, title, (ftnlen)800, (ftnlen)1, (ftnlen)800);
	repmd_(title, "#", center, &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &center[1], &c__14, title, (ftnlen)800, (ftnlen)1, 
		(ftnlen)800);
	repmd_(title, "#", &center[2], &c__14, title, (ftnlen)800, (ftnlen)1, 
		(ftnlen)800);
	repmd_(title, "#", v1, &c__14, title, (ftnlen)800, (ftnlen)1, (ftnlen)
		800);
	repmd_(title, "#", &v1[1], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &v1[2], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", v2, &c__14, title, (ftnlen)800, (ftnlen)1, (ftnlen)
		800);
	repmd_(title, "#", &v2[1], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &v2[2], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", ppt, &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &ppt[1], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &ppt[2], &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", normal, &c__14, title, (ftnlen)800, (ftnlen)1, (
		ftnlen)800);
	repmd_(title, "#", &normal[1], &c__14, title, (ftnlen)800, (ftnlen)1, 
		(ftnlen)800);
	repmd_(title, "#", &normal[2], &c__14, title, (ftnlen)800, (ftnlen)1, 
		(ftnlen)800);
	tcase_(title, (ftnlen)800);

/*        Form the plane. */

	nvp2pl_(normal, ppt, plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Cross our fingers and toes and let 'er rip. */

	inelpl_(ellips, plane, &n, xpts, &xpts[3]);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	if (n > 0) {

/*           Make sure the intersection points we found are */
/*           contained in both the plane and the the */
/*           ellipse. */

	    valxpt = t_ispxel__(ellips, plane, &n, xpts, ok);
	    chcksl_("Is intersection valid?", &valxpt, &c_true, ok, (ftnlen)
		    22);
	}
    }

/*     INELPL error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("INELPL: invalid plane", (ftnlen)21);
    cleard_(&c__4, plane);
    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("INELPL: ellipse has one zero-length axis.", (ftnlen)41);
    vpack_(&c_b9, &c_b5, &c_b196, center);
    vpack_(&c_b9, &c_b6, &c_b6, smajor);
    vpack_(&c_b6, &c_b6, &c_b6, sminor);
    cgv2el_(center, smajor, sminor, ellips);
    inelpl_(ellips, plane, &n, xpts, &xpts[3]);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_inelpl__ */


/*     Supporting function T_ISPXEL */

logical t_ispxel__(doublereal *ellips, doublereal *plane, integer *n, 
	doublereal *xpts, logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2, d__3, d__4;
    logical ret_val;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal scla, sclb, rmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal sclx[6]	/* was [3][2] */;
    extern doublereal vdot_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    doublereal a, b, c__;
    integer i__;
    doublereal scale, level;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[240];
    doublereal const__;
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), pl2nvc_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal pc;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal center[3], offset[6]	/* was [3][2] */, normal[3], smajor[3]
	    ;
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal sminor[3];
    extern /* Subroutine */ int twovec_(doublereal *, integer *, doublereal *,
	     integer *, doublereal *);
    doublereal xax[6]	/* was [3][2] */;
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;


/*     Test whether a set of points constitute the intersection of a */
/*     specified plane and ellipse. */


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Give the function an initial return value. */

    ret_val = FALSE_;

/*     Scale ellipse and plane. */

    el2cgv_(ellips, center, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    a = vnorm_(smajor);
    b = vnorm_(sminor);
    c__ = vnorm_(center);
    pl2nvc_(plane, normal, &const__);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    if (! (*ok)) {
	return ret_val;
    }

/*     Scale the ellipse and plane constant for safer computation. */

/* Computing MAX */
    d__1 = abs(a), d__2 = abs(b), d__1 = max(d__1,d__2), d__2 = abs(c__), 
	    d__1 = max(d__1,d__2), d__2 = abs(const__);
    scale = max(d__1,d__2);
    d__1 = 1.f / scale;
    vsclip_(&d__1, center);
    d__1 = 1.f / scale;
    vsclip_(&d__1, smajor);
    d__1 = 1.f / scale;
    vsclip_(&d__1, sminor);
    scla = a / scale;
    sclb = b / scale;
    const__ /= scale;

/*     Scale the input points. */

    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	d__1 = 1.f / scale;
	vscl_(&d__1, &xpts[(i__2 = i__ * 3 - 3) < 6 && 0 <= i__2 ? i__2 : 
		s_rnge("xpts", i__2, "t_ispxel__", (ftnlen)708)], &sclx[(i__3 
		= i__ * 3 - 3) < 6 && 0 <= i__3 ? i__3 : s_rnge("sclx", i__3, 
		"t_ispxel__", (ftnlen)708)]);
    }

/*     Subtract the scaled ellipse center from the intersection */
/*     points. */

    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	vsub_(&sclx[(i__2 = i__ * 3 - 3) < 6 && 0 <= i__2 ? i__2 : s_rnge(
		"sclx", i__2, "t_ispxel__", (ftnlen)716)], center, &offset[(
		i__3 = i__ * 3 - 3) < 6 && 0 <= i__3 ? i__3 : s_rnge("offset",
		 i__3, "t_ispxel__", (ftnlen)716)]);
    }

/*     Transform the input points into the semi-axis frame. */

    twovec_(smajor, &c__1, sminor, &c__2, rmat);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	mxv_(rmat, &offset[(i__2 = i__ * 3 - 3) < 6 && 0 <= i__2 ? i__2 : 
		s_rnge("offset", i__2, "t_ispxel__", (ftnlen)726)], &xax[(
		i__3 = i__ * 3 - 3) < 6 && 0 <= i__3 ? i__3 : s_rnge("xax", 
		i__3, "t_ispxel__", (ftnlen)726)]);
    }

/*     Check the `level' of each point. */

    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* Computing 2nd power */
	d__1 = xax[(i__2 = i__ * 3 - 3) < 6 && 0 <= i__2 ? i__2 : s_rnge(
		"xax", i__2, "t_ispxel__", (ftnlen)734)];
/* Computing 2nd power */
	d__2 = scla;
/* Computing 2nd power */
	d__3 = xax[(i__3 = i__ * 3 - 2) < 6 && 0 <= i__3 ? i__3 : s_rnge(
		"xax", i__3, "t_ispxel__", (ftnlen)734)];
/* Computing 2nd power */
	d__4 = sclb;
	level = d__1 * d__1 / (d__2 * d__2) + d__3 * d__3 / (d__4 * d__4);
	s_copy(title, "Level of point #", (ftnlen)240, (ftnlen)16);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	chcksd_(title, &level, "~", &c_b9, &c_b234, ok, (ftnlen)240, (ftnlen)
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
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	pc = vdot_(&sclx[(i__2 = i__ * 3 - 3) < 6 && 0 <= i__2 ? i__2 : 
		s_rnge("sclx", i__2, "t_ispxel__", (ftnlen)760)], normal);
	s_copy(title, "Plane constant of point #", (ftnlen)240, (ftnlen)25);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	chcksd_(title, &pc, "~/", &const__, &c_b242, ok, (ftnlen)240, (ftnlen)
		2);
	if (! (*ok)) {
	    ret_val = FALSE_;
	    return ret_val;
	}
    }
    ret_val = TRUE_;
    return ret_val;
} /* t_ispxel__ */

