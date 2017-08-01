/* f_saelgv.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b17 = 1e-13;
static doublereal c_b18 = -1.;
static doublereal c_b59 = 1.;
static doublereal c_b70 = -306.;
static doublereal c_b71 = 306.;
static doublereal c_b72 = 10.;
static doublereal c_b77 = 0.;

/* $Procedure F_SAELGV ( SAELGV tests ) */
/* Subroutine */ int f_saelgv__(logical *ok)
{
    /* Initialized data */

    static doublereal center[3] = { 0.,0.,0. };

    /* System generated locals */
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal), pow_dd(doublereal *, doublereal *), cos(
	    doublereal), sin(doublereal);

    /* Local variables */
    integer case__, seed;
    doublereal dist;
    extern doublereal vsep_(doublereal *, doublereal *);
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    integer j;
    doublereal angle, scale;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal pnear[3];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), vlcom_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal point[3];
    extern doublereal vnorm_(doublereal *), twopi_(void);
    extern /* Subroutine */ int t_success__(logical *), cgv2el_(doublereal *, 
	    doublereal *, doublereal *, doublereal *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), saelgv_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal expmaj[3], ellips[9], smajor[3];
    extern /* Subroutine */ int vhatip_(doublereal *);
    doublereal expmin[3];
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *), npelpt_(
	    doublereal *, doublereal *, doublereal *, doublereal *);
    doublereal sminor[3], ev1, ev2, sep;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    doublereal vec1[3], vec2[3];

/* $ Abstract */

/*     Exercise SAELGV: the SPICELIB routine that finds semi-axes */
/*     of an ellipse defined by two generating vectors. */

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

/*     This routine tests the SPICELIB routine SAELGV.  The */
/*     underlying routine DIAGS2 is exercised by these tests. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 20-SEP-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_SAELGV", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "A case that can be checked by inspection.", (ftnlen)240, (
	    ftnlen)41);
    tcase_(title, (ftnlen)240);
    vec1[0] = 1.;
    vec1[1] = 1.;
    vec1[2] = 0.;
    vec2[0] = 1.;
    vec2[1] = 0.;
    vec2[2] = 0.;

/*     The equation of this ellipse is */

/*                 2       2 */
/*        ( x - y )    +  y       =   1 */

/*     or */

/*         2                   2 */
/*        x    -   2xy   +   2y   =  1 */

/*     The left hand side is */

/*        ( x  y ) (  1   -1 ) ( x ) */
/*                 ( -1    2 ) ( y ) */

/*     The eigenvalues of the matrix are */

/*                       ___ */
/*         3     +     \/ 5 */
/*        ---    _     ------ */
/*         2              2 */

/*     Letting these be EV1 and EV2, some orthogonal eigenvectors are */

/*        (    1    )     ( EV1 - 1 ) */
/*        ( 1 - EV1 )     (    1    ) */

/*     A rotation to a basis formed from the eigenvectors gives */
/*     us the ellipse equation */

/*              2             2 */
/*        EV1  u    +    EV2 v    =   1 */

/*     The semi-major axis length is the square root of 1/EV2; */
/*     The semi-minor axis length is the square root of 1/EV1. */

    ev1 = (sqrt(5.) + 3.) / 2.;
    ev2 = (3. - sqrt(5.)) / 2.;
    expmaj[0] = ev1 - 1.;
    expmaj[1] = 1.;
    expmaj[2] = 0.;
    vhatip_(expmaj);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = 1. / sqrt(ev2);
    vsclip_(&d__1, expmaj);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    expmin[0] = -1.;
    expmin[1] = ev1 - 1.;
    expmin[2] = 0.;
    vhatip_(expmin);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = 1. / sqrt(ev1);
    vsclip_(&d__1, expmin);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    saelgv_(vec1, vec2, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    sep = vsep_(smajor, expmaj);
    if (sep < pi_()) {
	chckad_("SMAJOR", smajor, "~~/", expmaj, &c__3, &c_b17, ok, (ftnlen)6,
		 (ftnlen)3);
    } else {
	vsclip_(&c_b18, expmaj);
	chckad_("SMAJOR", smajor, "~~/", expmaj, &c__3, &c_b17, ok, (ftnlen)6,
		 (ftnlen)3);
    }
    sep = vsep_(sminor, expmin);
    if (sep < pi_()) {
	chckad_("SMINOR", sminor, "~~/", expmin, &c__3, &c_b17, ok, (ftnlen)6,
		 (ftnlen)3);
    } else {
	vsclip_(&c_b18, expmin);
	chckad_("SMINOR", sminor, "~~/", expmin, &c__3, &c_b17, ok, (ftnlen)6,
		 (ftnlen)3);
    }

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Exceptional case: one zero-length generating vector.", (
	    ftnlen)240, (ftnlen)52);
    tcase_(title, (ftnlen)240);
    vec1[0] = 0.;
    vec1[1] = 0.;
    vec1[2] = 0.;
    vec2[0] = 1.;
    vec2[1] = 2.;
    vec2[2] = 3.;
    saelgv_(vec1, vec2, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    vequ_(vec1, expmin);
    vequ_(vec2, expmaj);
    chckad_("SMAJOR", smajor, "~~/", expmaj, &c__3, &c_b17, ok, (ftnlen)6, (
	    ftnlen)3);
    chckad_("SMINOR", sminor, "~~/", expmin, &c__3, &c_b17, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Exceptional case: two zero-length generating vectors.", (
	    ftnlen)240, (ftnlen)53);
    tcase_(title, (ftnlen)240);
    vec1[0] = 0.;
    vec1[1] = 0.;
    vec1[2] = 0.;
    vequ_(vec1, vec2);
    saelgv_(vec1, vec2, smajor, sminor);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    vequ_(vec1, expmin);
    vequ_(vec2, expmaj);
    chckad_("SMAJOR", smajor, "~~/", expmaj, &c__3, &c_b17, ok, (ftnlen)6, (
	    ftnlen)3);
    chckad_("SMINOR", sminor, "~~/", expmin, &c__3, &c_b17, ok, (ftnlen)6, (
	    ftnlen)3);

/*     Now we perform the pseudo-random test cases. */

    seed = -1;

/*     Determine the number of general cases from the dimensions */
/*     of the parameter set. */

    for (case__ = 1; case__ <= 500; ++case__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Create two generating vectors whose components range "
		"over the unit sphere; also select a scale factor in the rang"
		"e 1.e-306: 1.e306; case #.", (ftnlen)240, (ftnlen)139);
	repmi_(title, "#", &case__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	tcase_(title, (ftnlen)240);

/*        Make up some generating vectors. */

	vec1[0] = t_randd__(&c_b18, &c_b59, &seed);
	vec1[1] = t_randd__(&c_b18, &c_b59, &seed);
	vec1[2] = t_randd__(&c_b18, &c_b59, &seed);
	vec2[0] = t_randd__(&c_b18, &c_b59, &seed);
	vec2[1] = t_randd__(&c_b18, &c_b59, &seed);
	vec2[2] = t_randd__(&c_b18, &c_b59, &seed);
/*            WRITE (*,*) 'VEC1  = ', VEC1 */
/*            WRITE (*,*) 'VEC2  = ', VEC2 */
	sep = vsep_(vec1, vec2);
	if (sep > 1e-13 && (d__1 = pi_() - sep, abs(d__1)) > 1e-13) {

/*           Now let's get a scale factor. */

	    d__1 = t_randd__(&c_b70, &c_b71, &seed);
	    scale = pow_dd(&c_b72, &d__1);
/*            WRITE (*,*) 'VEC1  = ', VEC1 */
/*            WRITE (*,*) 'VEC2  = ', VEC2 */
/*            WRITE (*,*) 'SCALE = ', SCALE */

/*           Scale the generating vectors. */

	    vsclip_(&scale, vec1);
	    vsclip_(&scale, vec2);

/*           The call. */

	    saelgv_(vec1, vec2, smajor, sminor);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Make sure the semi-axes are ordered properly. */

	    d__1 = vnorm_(smajor) - vnorm_(sminor);
	    chcksd_("VNORM(SMAJOR)-VNORM(SMINOR)", &d__1, ">=", &c_b77, &
		    c_b77, ok, (ftnlen)27, (ftnlen)2);

/*           Make an ellipse out of the center and generating vectors. */
/*           This involves a call to SAELGV. */

	    cgv2el_(center, vec1, vec2, ellips);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Take a sample of points on the original ellipse, and */
/*           find the scaled distance of each one from ELLIPS.  The */
/*           scaled distances should not exceed our chosen limit. */

	    for (j = 0; j <= 9; ++j) {
		angle = j * twopi_() / 10;
		d__1 = cos(angle);
		d__2 = sin(angle);
		vlcom_(&d__1, vec1, &d__2, vec2, point);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		npelpt_(point, ellips, pnear, &dist);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		d__1 = dist / scale;
		chcksd_("DIST/SCALE", &d__1, "~", &c_b77, &c_b17, ok, (ftnlen)
			10, (ftnlen)1);
	    }
	}
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_saelgv__ */

