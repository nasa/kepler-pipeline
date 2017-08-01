/* f_nplnpt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b4 = 1.;
static doublereal c_b6 = 0.;
static doublereal c_b10 = -1.;
static doublereal c_b13 = -.5;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b21 = 1e-14;
static doublereal c_b50 = -306.;
static doublereal c_b51 = 306.;
static doublereal c_b52 = 10.;
static logical c_true = TRUE_;

/* $Procedure F_NPLNPT ( NPLNPT tests ) */
/* Subroutine */ int f_nplnpt__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal), pow_dd(doublereal *, doublereal *);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer seed;
    doublereal dist;
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *), mtxv_(
	    doublereal *, doublereal *, doublereal *);
    doublereal a;
    integer i__, j;
    doublereal x[3], y[3], z__[3];
    extern /* Subroutine */ int frame_(doublereal *, doublereal *, doublereal 
	    *), filld_(doublereal *, integer *, doublereal *), tcase_(char *, 
	    ftnlen), vpack_(doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    doublereal pnear[3];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal trans[9]	/* was [3][3] */;
    extern doublereal vdist_(doublereal *, doublereal *);
    doublereal point[3], xdist;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), cleard_(integer *, doublereal *), 
	    chcksd_(char *, doublereal *, char *, doublereal *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen);
    doublereal linedr[3], sfactr, linept[3];
    extern /* Subroutine */ int vhatip_(doublereal *);
    doublereal ltrans[3], ptrans[3];
    extern /* Subroutine */ int nplnpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal xtrans[3];
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal xpt[3];

/* $ Abstract */

/*     Exercise the SPICELIB routine NPLNPT.  NPLNPT find the nearest */
/*     point on a specified line to a specified point. */

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

/*     This routine tests the SPICELIB routine NPLNPT. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 13-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_NPLNPT", (ftnlen)8);

/*     Run some simple tests where the correct results can be */
/*     determined by inspection. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "NPLNPT simple case:  line is x = y; z = 0.  POINT is  (-1"
	    ", 0, 0 ).", (ftnlen)240, (ftnlen)66);
    tcase_(title, (ftnlen)240);
    vpack_(&c_b4, &c_b4, &c_b6, linedr);
    vpack_(&c_b6, &c_b6, &c_b6, linept);
    vpack_(&c_b10, &c_b6, &c_b6, point);
    a = sqrt(2.) / 2;
    vpack_(&c_b13, &c_b13, &c_b6, xpt);
    nplnpt_(linept, linedr, point, pnear, &dist);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test the near point and distance. */

    chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b21, ok, (ftnlen)5, (ftnlen)
	    3);
    chcksd_("DIST", &dist, "~", &a, &c_b21, ok, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "NPLNPT non-error exception case:  POINT is on the line.", (
	    ftnlen)240, (ftnlen)55);
    tcase_(title, (ftnlen)240);
    vpack_(&c_b4, &c_b4, &c_b6, linedr);
    vpack_(&c_b6, &c_b4, &c_b6, linept);
    vpack_(&c_b10, &c_b6, &c_b6, point);
    vpack_(&c_b10, &c_b6, &c_b6, xpt);
    nplnpt_(linept, linedr, point, pnear, &dist);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Test the near point and distance. */

    chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b21, ok, (ftnlen)5, (ftnlen)
	    3);
    chcksd_("DIST", &dist, "~", &c_b6, &c_b21, ok, (ftnlen)4, (ftnlen)1);

/*     Now for some more difficult cases.  We'll generate the points */
/*     and lines using random numbers.  There are ten components to */
/*     generate: */

/*        - random line direction vectors */
/*        - random line points */
/*        - random points off the line */
/*        - random scale factors for the line and point; these are */
/*          used to create a wide range of scales */

    seed = -1;
    for (i__ = 1; i__ <= 1000; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "NPLNPT random case #", (ftnlen)240, (ftnlen)20);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);

/*        Get a scale factor. */

	d__1 = t_randd__(&c_b50, &c_b51, &seed);
	sfactr = pow_dd(&c_b52, &d__1);

/*        We gotta have a line direction vector. */

	linedr[0] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	linedr[1] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	linedr[2] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	vhatip_(linedr);

/*        We need a point on the line. */

	linept[0] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	linept[1] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	linept[2] = sfactr * t_randd__(&c_b10, &c_b4, &seed);

/*        We also need a point off the line.  Scale the point up to */
/*        increase the likelihood of a non-intercept case. */

	point[0] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	point[1] = sfactr * t_randd__(&c_b10, &c_b4, &seed);
	point[2] = sfactr * t_randd__(&c_b10, &c_b4, &seed);

/*        Find the expected near point.  First define a frame whose */
/*        x-axis is parallel to LINEDR.  Then transform POINT */
/*        into this frame. Also transform LINEPT into the same frame. */

	vequ_(linedr, x);
	frame_(x, y, z__);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	for (j = 1; j <= 3; ++j) {
	    trans[(i__1 = j * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge("trans",
		     i__1, "f_nplnpt__", (ftnlen)289)] = x[(i__2 = j - 1) < 3 
		    && 0 <= i__2 ? i__2 : s_rnge("x", i__2, "f_nplnpt__", (
		    ftnlen)289)];
	    trans[(i__1 = j * 3 - 2) < 9 && 0 <= i__1 ? i__1 : s_rnge("trans",
		     i__1, "f_nplnpt__", (ftnlen)290)] = y[(i__2 = j - 1) < 3 
		    && 0 <= i__2 ? i__2 : s_rnge("y", i__2, "f_nplnpt__", (
		    ftnlen)290)];
	    trans[(i__1 = j * 3 - 1) < 9 && 0 <= i__1 ? i__1 : s_rnge("trans",
		     i__1, "f_nplnpt__", (ftnlen)291)] = z__[(i__2 = j - 1) < 
		    3 && 0 <= i__2 ? i__2 : s_rnge("z", i__2, "f_nplnpt__", (
		    ftnlen)291)];
	}
	mxv_(trans, point, ptrans);
	mxv_(trans, linept, ltrans);

/*        The y-z projection of the resulting point is the closest point */
/*        on the line to the origin. The expected near point has the */
/*        same x-component as PTRANS. */

	vpack_(ptrans, &ltrans[1], &ltrans[2], xtrans);

/*        Map XTRANS back to the base frame. */

	mtxv_(trans, xtrans, xpt);

/*        The distance between XPT and POINT is the expected */
/*        distance from the near point. */

	xdist = vdist_(xpt, point);

/*        Cross our fingers and toes and let 'er rip. */

	nplnpt_(linept, linedr, point, pnear, &dist);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Test the near point and distance. */

	chckad_("PNEAR", pnear, "~~/", xpt, &c__3, &c_b21, ok, (ftnlen)5, (
		ftnlen)3);
	chcksd_("DIST", &dist, "~/", &xdist, &c_b21, ok, (ftnlen)4, (ftnlen)2)
		;
    }

/*     NPLNPT error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("NPLNPT: zero direction vector,", (ftnlen)30);
    filld_(&c_b52, &c__3, linept);
    cleard_(&c__3, linedr);
    vpack_(&c_b4, &c_b4, &c_b4, point);
    nplnpt_(linept, linedr, point, pnear, &dist);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_nplnpt__ */

