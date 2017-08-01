/* f_npelpt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b5 = 1.;
static doublereal c_b6 = 0.;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b22 = 1e-14;
static doublereal c_b28 = 4.;
static doublereal c_b39 = 5.;
static logical c_true = TRUE_;
static doublereal c_b70 = -290.;
static doublereal c_b71 = 290.;
static doublereal c_b72 = 10.;
static doublereal c_b73 = -1.;
static integer c__14 = 14;
static doublereal c_b134 = 2.;
static integer c__1 = 1;
static integer c__2 = 2;
static doublereal c_b147 = 1e-12;

/* $Procedure F_NPELPT ( NPELPT tests ) */
/* Subroutine */ int f_npelpt__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double pow_dd(doublereal *, doublereal *);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer seed;
    doublereal dist;
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    extern logical t_isnpel__(doublereal *, doublereal *, doublereal *, 
	    doublereal *, logical *);
    integer i__, j;
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *),
	     tcase_(char *, ftnlen), vpack_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal pnear[3];
    extern /* Subroutine */ int repmd_(char *, char *, doublereal *, integer *
	    , char *, ftnlen, ftnlen, ftnlen), repmi_(char *, char *, integer 
	    *, char *, ftnlen, ftnlen, ftnlen);
    char title[400];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    logical valpt;
    doublereal point[3], xdist, v1[3], v2[3];
    extern /* Subroutine */ int t_success__(logical *), cgv2el_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksl_(char *, logical *, 
	    logical *, logical *, ftnlen);
    doublereal center[3];
    extern /* Subroutine */ int saelgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal sfactr, ellips[9], smajor[3];
    extern /* Subroutine */ int npelpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal sminor[3];
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    doublereal xpt[3];

/* $ Abstract */

/*     Exercise the SPICELIB routine NPELPT.  NPELPT find the nearest */
/*     point on an ellipse to a specified point. */

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

/*     This routine tests the SPICELIB routine NPELPT. */

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

/*        T_ISNPEL */

/*     tests whether a 3-dpoint is on a specified ellipse embedded in */
/*     3-dimensional space: */

/*        - A point P = (p1,p2,p3) is "on" the ellipse with center C */
/*          and semi-axes SMAJOR and SMINOR if P lies in the plane */
/*          of the ellipse and if the "level surface parameter" */

/*             lambda =  x**2/A**2 + y**2/B**2 */

/*          is sufficiently close to 1, where */

/*             A = ||SMAJOR|| */
/*             B = ||SMINOR|| */

/*             x = <P-C, SMAJOR/A> * SMAJOR / A */
/*             y = <P-C, SMINOR/B> * SMINOR / B */


/*     The function */

/*        T_ISNPEL */

/*     test whether the near point found by NPELPT has the property */
/*     that the outward normal at the near point can be extended to */
/*     intersect the input line at right angles. */

/*     T_ISNPEL also checks the distance of the near point from the line: */
/*     the distance is checked against the value obtained from NPLNPT. */



/*     Open the test family. */

    topen_("F_NPELPT", (ftnlen)8);

/*     Run some simple tests where the correct results can be */
/*     determined by inspection. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Ellipse is unit circle in x-y plane.  Point is (1,0,1)", (
	    ftnlen)400, (ftnlen)54);
    repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
    tcase_(title, (ftnlen)400);
    vpack_(&c_b5, &c_b6, &c_b5, point);
    vpack_(&c_b5, &c_b6, &c_b6, v1);
    vpack_(&c_b6, &c_b5, &c_b6, v2);
    vpack_(&c_b6, &c_b6, &c_b6, center);
    cgv2el_(center, v1, v2, ellips);
    npelpt_(point, ellips, pnear, &dist);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test results. */

    vequ_(v1, xpt);
    xdist = 1.;
    chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b22, ok, (ftnlen)5, (ftnlen)
	    3);
    chcksd_("DIST", &dist, "~", &xdist, &c_b6, ok, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Ellipse is unit circle in z=5 plane.  Point is (4,0,1)", (
	    ftnlen)400, (ftnlen)54);
    repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
    tcase_(title, (ftnlen)400);
    vpack_(&c_b28, &c_b6, &c_b5, point);
    vpack_(&c_b5, &c_b6, &c_b6, v1);
    vpack_(&c_b6, &c_b5, &c_b6, v2);
    vpack_(&c_b6, &c_b6, &c_b39, center);
    cgv2el_(center, v1, v2, ellips);
    npelpt_(point, ellips, pnear, &dist);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test results. */

    vpack_(&c_b5, &c_b6, &c_b39, xpt);
    xdist = 5.;
    chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b22, ok, (ftnlen)5, (ftnlen)
	    3);
    chcksd_("DIST", &dist, "~", &xdist, &c_b6, ok, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Ellipse is unit circle in z=5 plane.  Point is (0,0,5)", (
	    ftnlen)400, (ftnlen)54);
    repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
    tcase_(title, (ftnlen)400);
    vpack_(&c_b6, &c_b6, &c_b39, point);
    vpack_(&c_b5, &c_b6, &c_b6, v1);
    vpack_(&c_b6, &c_b5, &c_b6, v2);
    vpack_(&c_b6, &c_b6, &c_b39, center);
    cgv2el_(center, v1, v2, ellips);
    npelpt_(point, ellips, pnear, &dist);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test results. */

/*     For this case, we don't know which point will be selected */
/*     as the near point.  Just check that it's a valid solution. */


    valpt = t_isnpel__(point, ellips, pnear, &dist, ok);
    chcksl_("Is near point on ellipse?", &valpt, &c_true, ok, (ftnlen)25);

/*     Now for some more difficult cases.  We'll generate the ellipses */
/*     and planes using random numbers.  There are four components to */
/*     generate: */

/*        - random points */
/*        - random ellipse axes */
/*        - random ellipse centers */
/*        - random scale factors for the ellipse and point; these are */
/*          used to create a wide range of scales */

    seed = -1;
    for (i__ = 1; i__ <= 5000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Get a scale factor. */

	d__1 = t_randd__(&c_b70, &c_b71, &seed);
	sfactr = pow_dd(&c_b72, &d__1);

/*        Make up ellipse vectors. */

	for (j = 1; j <= 3; ++j) {
	    center[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("center", 
		    i__1, "f_npelpt__", (ftnlen)326)] = sfactr * t_randd__(&
		    c_b73, &c_b5, &seed);
	    v1[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("v1", i__1, 
		    "f_npelpt__", (ftnlen)327)] = sfactr * t_randd__(&c_b73, &
		    c_b5, &seed);
	    v2[(i__1 = j - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("v2", i__1, 
		    "f_npelpt__", (ftnlen)328)] = sfactr * t_randd__(&c_b73, &
		    c_b5, &seed);
	}

/*        Pack the ellipse. */

	cgv2el_(center, v1, v2, ellips);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Find the semi-axes of this ellipse. */

	saelgv_(v1, v2, smajor, sminor);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        We also need a point. */

	point[0] = sfactr * t_randd__(&c_b73, &c_b5, &seed);
	point[1] = sfactr * t_randd__(&c_b73, &c_b5, &seed);
	point[2] = sfactr * t_randd__(&c_b73, &c_b5, &seed);
	s_copy(title, "NPELPT Random case #.  CENTER = (#, #, #); V1 = (#, #"
		", #); V2 = (#, #, #); POINT = (#, #, #)", (ftnlen)400, (
		ftnlen)92);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	repmd_(title, "#", center, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &center[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &center[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", v1, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &v1[1], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &v1[2], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", v2, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &v2[1], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &v2[2], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", point, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &point[1], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &point[2], &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	tcase_(title, (ftnlen)400);

/*        Cross our fingers and toes and let 'er rip. */

	npelpt_(point, ellips, pnear, &dist);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure point we found lies on the ellipse. */

	valpt = t_isnpel__(point, ellips, pnear, &dist, ok);
	chcksl_("Is near point on ellipse?", &valpt, &c_true, ok, (ftnlen)25);
    }

/*     NPELPT error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("NPELPT: ellipse has one zero-length axis.", (ftnlen)41);
    filld_(&c_b72, &c__3, point);
    vpack_(&c_b6, &c_b6, &c_b6, v1);
    vpack_(&c_b6, &c_b5, &c_b6, v2);
    vpack_(&c_b134, &c_b134, &c_b134, center);
    cgv2el_(center, v1, v2, ellips);
    npelpt_(point, ellips, pnear, &dist);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Swap the semi-axes and repeat. */

    cgv2el_(center, v2, v1, ellips);
    npelpt_(point, ellips, pnear, &dist);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_npelpt__ */



/*     Supporting function T_ISNPEL */

logical t_isnpel__(doublereal *viewpt, doublereal *ellips, doublereal *pnear, 
	doublereal *d__, logical *ok)
{
    /* System generated locals */
    doublereal d__1, d__2, d__3, d__4;
    logical ret_val;

    /* Local variables */
    doublereal scla, sclb;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    extern doublereal vdot_(doublereal *, doublereal *);
    doublereal axpt[3], vpax[3];
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    doublereal scale, level, axmat[9]	/* was [3][3] */, sclpt[3], vpscl[3], 
	    vtemp[3];
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *), chcksd_(char *, doublereal *, char *,
	     doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal center[3], offset[3], smajor[3], tangnt[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal axview[3], sminor[3];
    extern /* Subroutine */ int twovec_(doublereal *, integer *, doublereal *,
	     integer *, doublereal *), mxv_(doublereal *, doublereal *, 
	    doublereal *);


/*     The utility function T_ISNPEL tests whether the "near point" */
/*     found by NPELPT satisfies the criterion that the line segment */
/*     connecting this point to the viewing point is orthogonal to the */
/*     ellipse's tangent vector at the near point.  The function also */
/*     test the viewpoint-ellipse distance and verifies that the */
/*     near point lies on the ellipse. */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Set an initial return value. */

    ret_val = FALSE_;

/*     We're going to express the vector from the ellipse's center */
/*     to the near point in a frame whose axes are parallel to the */
/*     ellipse's semi-axes. */

/*     Unpack ellipse. */

    el2cgv_(ellips, center, smajor, sminor);

/*     Scale view point, ellipse and near point. */

/* Computing MAX */
    d__1 = vnorm_(center), d__2 = vnorm_(smajor), d__1 = max(d__1,d__2), d__2 
	    = vnorm_(sminor);
    scale = max(d__1,d__2);
    d__1 = 1.f / scale;
    vscl_(&d__1, viewpt, vpscl);
    d__1 = 1.f / scale;
    vsclip_(&d__1, center);
    d__1 = 1.f / scale;
    vsclip_(&d__1, smajor);
    d__1 = 1.f / scale;
    vsclip_(&d__1, sminor);
    d__1 = 1.f / scale;
    vscl_(&d__1, pnear, sclpt);
    scla = vnorm_(smajor);
    sclb = vnorm_(sminor);

/*     Find the vector from the near point to the center. */

    vsub_(sclpt, center, offset);

/*     Create the matrix that maps from the base frame to */
/*     a frame where the semi-axes are the x and y axes. */

    twovec_(smajor, &c__1, sminor, &c__2, axmat);

/*     Map the offset vector into the semi-axis frame. */

    mxv_(axmat, offset, axpt);

/*     Check the `level' of the near point. */

/* Computing 2nd power */
    d__1 = axpt[0];
/* Computing 2nd power */
    d__2 = scla;
/* Computing 2nd power */
    d__3 = axpt[1];
/* Computing 2nd power */
    d__4 = sclb;
    level = d__1 * d__1 / (d__2 * d__2) + d__3 * d__3 / (d__4 * d__4);
    chcksd_("LEVEL", &level, "~", &c_b5, &c_b147, ok, (ftnlen)5, (ftnlen)1);
    if (! (*ok)) {
	return ret_val;
    }

/*     The z-component of AXPT should be zero. */

    chcksd_("AXPT(3)", &axpt[2], "~", &c_b6, &c_b147, ok, (ftnlen)7, (ftnlen)
	    1);
    if (! (*ok)) {
	return ret_val;
    }

/*     If we're still here, the near point is considered to be on */
/*     the ellipse. */

/*     Next step:  find the tangent direction at the near point. */

/* Computing 2nd power */
    d__1 = sclb;
    tangnt[0] = -axpt[1] / (d__1 * d__1);
/* Computing 2nd power */
    d__1 = scla;
    tangnt[1] = axpt[0] / (d__1 * d__1);
    tangnt[2] = 0.;

/*     Map the scaled view point into the semi-axis frame.  To do */
/*     this we must shift the origin to the ellipse's center, then */
/*     rotate the vector. */

    vsub_(vpscl, center, vtemp);
    mxv_(axmat, vtemp, vpax);

/*     Find the vector from the near point to the view point. */

    vsub_(vpax, axpt, axview);

/*     AXVIEW should be orthogonal to the tangent vector. */

    d__1 = vdot_(axview, tangnt);
    chcksd_("<AXVIEW,TANGNT>", &d__1, "~", &c_b6, &c_b147, ok, (ftnlen)15, (
	    ftnlen)1);
    if (! (*ok)) {
	return ret_val;
    }

/*     Check the distance to the near point. */

    d__1 = vnorm_(axview) * scale;
    chcksd_("Distance", d__, "~/", &d__1, &c_b147, ok, (ftnlen)8, (ftnlen)2);
    if (! (*ok)) {
	return ret_val;
    }

/*     The tests passed if we made it this far. */

    ret_val = TRUE_;
    return ret_val;
} /* t_isnpel__ */

