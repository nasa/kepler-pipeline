/* f_npedln.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static doublereal c_b37 = -290.;
static doublereal c_b38 = 290.;
static doublereal c_b39 = 10.;
static doublereal c_b40 = 1.;
static doublereal c_b41 = 2.;
static doublereal c_b46 = -1.;
static integer c__14 = 14;
static integer c__3 = 3;
static doublereal c_b85 = 1e-14;
static doublereal c_b88 = 0.;
static doublereal c_b140 = 1e-12;

/* $Procedure F_NPEDLN ( NPEDLN tests ) */
/* Subroutine */ int f_npedln__(logical *ok)
{
    /* Initialized data */

    static doublereal smpa[3] = { 10.,3e30,.01 };
    static doublereal smpb[3] = { 200.,3e30,.01 };
    static doublereal smpc[3] = { 3e3,3e30,.005 };
    static doublereal smppt[9]	/* was [3][3] */ = { 20.,0.,0.,4e30,0.,4e30,
	    0.,1.,1. };
    static doublereal smpdir[9]	/* was [3][3] */ = { 0.,0.,-1.,-1.,0.,2.,0.,
	    -2.,-1. };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double pow_dd(doublereal *, doublereal *);

    /* Local variables */
    integer seed;
    doublereal dist;
    extern logical t_isedpt__(doublereal *, doublereal *, doublereal *, 
	    doublereal *, logical *), t_isnpln__(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, logical *);
    doublereal a, b, c__;
    integer i__;
    extern /* Subroutine */ int filld_(doublereal *, integer *, doublereal *),
	     tcase_(char *, ftnlen);
    doublereal pnear[3];
    extern /* Subroutine */ int repmd_(char *, char *, doublereal *, integer *
	    , char *, ftnlen, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[400];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    logical valpt;
    extern /* Subroutine */ int t_success__(logical *);
    logical found2;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     cleard_(integer *, doublereal *), chcksd_(char *, doublereal *, 
	    char *, doublereal *, doublereal *, logical *, ftnlen, ftnlen), 
	    chckxc_(logical *, char *, logical *, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen);
    doublereal negdir[3], linedr[3];
    extern /* Subroutine */ int npedln_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal sfactr, linept[3];
    extern /* Subroutine */ int vhatip_(doublereal *);
    logical orthog;
    extern /* Subroutine */ int vminus_(doublereal *, doublereal *), surfpt_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, logical *);
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    doublereal xpt[3];

/* $ Abstract */

/*     Exercise the SPICELIB routine NPEDLN.  NPEDLN find the nearest */
/*     point to a specified line on the surface of an ellipsoid. */

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

/*     This routine tests the SPICELIB routine NPEDLN. */

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

/*      INTEGER               NEASY */
/*      PARAMETER           ( NEASY  =  3 ) */
/*      INTEGER               NUMSCL */
/*      PARAMETER           ( NUMSCL =  5 ) */

/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     The simple test cases. */


/*     In this test family, we encapsulate some of the geometric */
/*     tests within functions defined in this file. The function */

/*        T_ISEDPT */

/*     tests a point is on a specified ellipsoid: */

/*        - A point P = (x,y,z) is "on" the ellipsoid with semi-axis */
/*          lengths a, b, c if the "level surface parameter" */

/*             lambda = x**2/a**2 + y**2/b**2 + z**2/c**2 */

/*          is sufficiently close to 1. */


/*     The function */

/*        T_ISNPLN */

/*     test whether the near point found by NPEDLN has the property */
/*     that the outward normal at the near point can be extended to */
/*     intersect the input line at right angles. */

/*     T_ISNPLN also checks the distance of the near point from the line: */
/*     the distance is checked against the value obtained from NPLNPT. */



/*     Open the test family. */

    topen_("F_NPEDLN", (ftnlen)8);

/*     Run some simple tests where the correct results can be */
/*     determined by inspection. */

    for (i__ = 1; i__ <= 3; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "NPEDLN simple case #", (ftnlen)400, (ftnlen)20);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	tcase_(title, (ftnlen)400);
	npedln_(&smpa[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("smpa"
		, i__1, "f_npedln__", (ftnlen)256)], &smpb[(i__2 = i__ - 1) < 
		3 && 0 <= i__2 ? i__2 : s_rnge("smpb", i__2, "f_npedln__", (
		ftnlen)256)], &smpc[(i__3 = i__ - 1) < 3 && 0 <= i__3 ? i__3 :
		 s_rnge("smpc", i__3, "f_npedln__", (ftnlen)256)], &smppt[(
		i__4 = i__ * 3 - 3) < 9 && 0 <= i__4 ? i__4 : s_rnge("smppt", 
		i__4, "f_npedln__", (ftnlen)256)], &smpdir[(i__5 = i__ * 3 - 
		3) < 9 && 0 <= i__5 ? i__5 : s_rnge("smpdir", i__5, "f_npedl"
		"n__", (ftnlen)256)], pnear, &dist);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the intersection ellipse we found is contained in */
/*        both the plane and the surface of the ellipsoid. */

	valpt = t_isedpt__(pnear, &smpa[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? 
		i__1 : s_rnge("smpa", i__1, "f_npedln__", (ftnlen)265)], &
		smpb[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("smpb",
		 i__2, "f_npedln__", (ftnlen)265)], &smpc[(i__3 = i__ - 1) < 
		3 && 0 <= i__3 ? i__3 : s_rnge("smpc", i__3, "f_npedln__", (
		ftnlen)265)], ok);
	chcksl_("Is near point on surface?", &valpt, &c_true, ok, (ftnlen)25);
	orthog = t_isnpln__(&smpa[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : 
		s_rnge("smpa", i__1, "f_npedln__", (ftnlen)269)], &smpb[(i__2 
		= i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("smpb", i__2, 
		"f_npedln__", (ftnlen)269)], &smpc[(i__3 = i__ - 1) < 3 && 0 
		<= i__3 ? i__3 : s_rnge("smpc", i__3, "f_npedln__", (ftnlen)
		269)], &smppt[(i__4 = i__ * 3 - 3) < 9 && 0 <= i__4 ? i__4 : 
		s_rnge("smppt", i__4, "f_npedln__", (ftnlen)269)], &smpdir[(
		i__5 = i__ * 3 - 3) < 9 && 0 <= i__5 ? i__5 : s_rnge("smpdir",
		 i__5, "f_npedln__", (ftnlen)269)], pnear, &dist, ok);
	chcksl_("Does extension of outward normal hit line orthogonally?  Is"
		" distance correct?", &orthog, &c_true, ok, (ftnlen)77);
    }

/*     Now for some more difficult cases.  We'll generate the ellipsoids */
/*     and lines using random numbers.  There are ten components to */
/*     generate: */

/*        - random line direction vectors */
/*        - random line points */
/*        - random ellipsoid axes */
/*        - random scale factors for the ellipsoid and plane; these are */
/*          used to create a wide range of scales */

    seed = -1;
    for (i__ = 1; i__ <= 5000; ++i__) {

/* --- Case: ------------------------------------------------------ */


/*        Get a scale factor. */

	d__1 = t_randd__(&c_b37, &c_b38, &seed);
	sfactr = pow_dd(&c_b39, &d__1);

/*        Make up ellipsoid axes and plane constant. */

	a = sfactr * t_randd__(&c_b40, &c_b41, &seed);
	b = sfactr * t_randd__(&c_b40, &c_b41, &seed);
	c__ = sfactr * t_randd__(&c_b40, &c_b41, &seed);

/*        We gotta have a line direction vector. */

	linedr[0] = sfactr * t_randd__(&c_b46, &c_b40, &seed);
	linedr[1] = sfactr * t_randd__(&c_b46, &c_b40, &seed);
	linedr[2] = sfactr * t_randd__(&c_b46, &c_b40, &seed);
	vhatip_(linedr);

/*        We also need a point on the line.  Scale the point up to */
/*        increase the likelihood of a non-intercept case. */

	linept[0] = sfactr * 10 * t_randd__(&c_b46, &c_b40, &seed);
	linept[1] = sfactr * 10 * t_randd__(&c_b46, &c_b40, &seed);
	linept[2] = sfactr * 10 * t_randd__(&c_b46, &c_b40, &seed);
	s_copy(title, "NPEDLN Random case #.  A, B, C = # # #; LINEDR = (#, "
		"#, #); LINEPT = (#, #, #)", (ftnlen)400, (ftnlen)78);
	repmi_(title, "#", &i__, title, (ftnlen)400, (ftnlen)1, (ftnlen)400);
	repmd_(title, "#", &a, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &b, &c__14, title, (ftnlen)400, (ftnlen)1, (ftnlen)
		400);
	repmd_(title, "#", &c__, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", linedr, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &linedr[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &linedr[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", linept, &c__14, title, (ftnlen)400, (ftnlen)1, (
		ftnlen)400);
	repmd_(title, "#", &linept[1], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	repmd_(title, "#", &linept[2], &c__14, title, (ftnlen)400, (ftnlen)1, 
		(ftnlen)400);
	tcase_(title, (ftnlen)400);

/*        Cross our fingers and toes and let 'er rip. */

	npedln_(&a, &b, &c__, linept, linedr, pnear, &dist);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Make sure the intersection ellipse we found is contained in */
/*        both the plane and the surface of the ellipsoid. */

	valpt = t_isedpt__(pnear, &a, &b, &c__, ok);
	chcksl_("Is near point on surface?", &valpt, &c_true, ok, (ftnlen)25);

/*        Check for surface intercept. */

	surfpt_(linept, linedr, &a, &b, &c__, xpt, &found);
	if (! found) {

/*           See whether the opposite ray hits the ellipsoid. */

	    vminus_(linedr, negdir);
	    surfpt_(linept, negdir, &a, &b, &c__, xpt, &found2);
	}

/*        If we have an intersection case, test the near point */
/*        and distance. */

	if (found || found2) {
	    chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b85, ok, (ftnlen)5, 
		    (ftnlen)3);
	    chcksd_("DIST", &dist, "=", &c_b88, &c_b88, ok, (ftnlen)4, (
		    ftnlen)1);
	} else {

/*           If we have a non-intersection case, test the solution */
/*           for the orthogonality condition.  Also check the distance */
/*           of the near point from the line. */

	    orthog = t_isnpln__(&a, &b, &c__, linept, linedr, pnear, &dist, 
		    ok);
	    chcksl_("Does extension of outward normal hit line orthogonally?"
		    "  Is distance correct?", &orthog, &c_true, ok, (ftnlen)77)
		    ;
	}
    }

/*     NPEDLN error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("NPEDLN: zero direction vector,", (ftnlen)30);
    filld_(&c_b39, &c__3, linept);
    cleard_(&c__3, linedr);
    npedln_(&c_b40, &c_b40, &c_b40, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("NPEDLN: ellipsoid has one zero-length axis.", (ftnlen)43);
    filld_(&c_b39, &c__3, linept);
    filld_(&c_b46, &c__3, linedr);
    npedln_(&c_b88, &c_b40, &c_b40, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    npedln_(&c_b40, &c_b88, &c_b40, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    npedln_(&c_b40, &c_b40, &c_b88, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    tcase_("NPEDLN: ellipsoid has one negative-length axis.", (ftnlen)47);
    npedln_(&c_b46, &c_b40, &c_b40, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    npedln_(&c_b40, &c_b46, &c_b40, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);
    npedln_(&c_b40, &c_b40, &c_b46, linept, linedr, pnear, &dist);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */


/*     This error may not be detected on some systems.  We exclude */
/*     it for now. */
/* CC    CALL TCASE  ( 'NPEDLN: axis length underflow after squaring.' ) */
/* CC    CALL NPEDLN (  1.D255, 1.D0, 1.D0,  LINEPT, LINEDR, PNEAR, DIST ) */
/* CC    CALL CHCKXC ( .TRUE., 'SPICE(DEGENERATECASE)', OK ) */
/* CC    CALL NPEDLN (  1.D0, 1.D255, 1.D0,  LINEPT, LINEDR, PNEAR, DIST ) */
/* CC    CALL CHCKXC ( .TRUE., 'SPICE(DEGENERATECASE)', OK ) */
/* CC    CALL NPEDLN (  1.D0, 1.D0, 1.D255,  LINEPT, LINEDR, PNEAR, DIST ) */
/* CC    CALL CHCKXC ( .TRUE., 'SPICE(DEGENERATECASE)', OK ) */

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_npedln__ */


/*     The utility function T_ISNPLN tests whether the "near point" found */
/*     by NPEDLN satisfies the criterion that the outward surface normal */
/*     at this point can be extended to intersect the input line */
/*     orthogonally. */

logical t_isnpln__(doublereal *a, doublereal *b, doublereal *c__, doublereal *
	linept, doublereal *linedr, doublereal *x, doublereal *d__, logical *
	ok)
{
    /* System generated locals */
    logical ret_val;

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal dist2;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksd_(char *, doublereal *, char *, doublereal *, doublereal *,
	     logical *, ftnlen, ftnlen);
    doublereal linmin[3], normal[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *);
    doublereal approx[3];
    extern /* Subroutine */ int surfnm_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *), nplnpt_(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *);


/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Executable code. */


/*     The point on the line closest to the ellipsoid ( LINMIN ). */

    nplnpt_(linept, linedr, x, linmin, &dist2);

/*     Check the distance.  This is pretty easy to get right. */

    chcksd_("D", d__, "~/", &dist2, &c_b140, ok, (ftnlen)1, (ftnlen)2);
    if (! (*ok)) {
	ret_val = FALSE_;
	return ret_val;
    }

/*     Obtain ellipsoid surface unit normal at the near point. */

    surfnm_(a, b, c__, x, normal);

/*     Approximation to LINMIN using X and D. */

    vsclip_(d__, normal);
    vadd_(x, normal, approx);

/*     Check the relative error in the approximation to LINMIN. */

    chckad_("APPROX", approx, "~~/", linmin, &c__3, &c_b140, ok, (ftnlen)6, (
	    ftnlen)3);
    ret_val = *ok;
    return ret_val;
} /* t_isnpln__ */


/*     Supporting function T_ISEDPT */

logical t_isedpt__(doublereal *pt, doublereal *a, doublereal *b, doublereal *
	c__, logical *ok)
{
    /* System generated locals */
    doublereal d__1, d__2, d__3, d__4, d__5, d__6;
    logical ret_val;

    /* Local variables */
    doublereal scla, sclb, sclc, elpt[3];
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    doublereal scale, level;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);


/*     Test whether a point is on a specified ellipsoid. */


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
    d__1 = 1.f / scale;
    vscl_(&d__1, pt, elpt);

/*     Check the `level' of the point. */

/* Computing 2nd power */
    d__1 = elpt[0];
/* Computing 2nd power */
    d__2 = scla;
/* Computing 2nd power */
    d__3 = elpt[1];
/* Computing 2nd power */
    d__4 = sclb;
/* Computing 2nd power */
    d__5 = elpt[2];
/* Computing 2nd power */
    d__6 = sclc;
    level = d__1 * d__1 / (d__2 * d__2) + d__3 * d__3 / (d__4 * d__4) + d__5 *
	     d__5 / (d__6 * d__6);
    chcksd_("LEVEL", &level, "~", &c_b40, &c_b140, ok, (ftnlen)5, (ftnlen)1);
    ret_val = *ok;
    return ret_val;
} /* t_isedpt__ */

