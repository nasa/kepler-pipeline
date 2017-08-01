/* f_inrypl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__3 = 3;
static doublereal c_b27 = 1e-12;
static doublereal c_b32 = 10.;
static doublereal c_b33 = -306.;
static doublereal c_b34 = 306.;
static doublereal c_b35 = -2.;
static doublereal c_b36 = 2.;
static doublereal c_b65 = 1.;
static logical c_true = TRUE_;

/* $Procedure F_INRYPL ( INRYPL tests ) */
/* Subroutine */ int f_inrypl__(logical *ok)
{
    /* Initialized data */

    static doublereal plcons[11] = { 0.,10.,0.,0.,0.,0.,0.,1e306,-1e306,
	    -1e-306,1. };
    static doublereal plnorm[33]	/* was [3][11] */ = { 0.,0.,1.,0.,0.,
	    1.,0.,0.,1.,0.,1.,0.,0.,0.,1.,0.,0.,1.,0.,0.,1.,0.,0.,1.,0.,0.,1.,
	    0.,0.,1.,0.,0.,1. };
    static doublereal vertex[33]	/* was [3][11] */ = { 0.,0.,2.,0.,0.,
	    20.,0.,0.,0.,0.,0.,0.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,2e306,
	    1e306,0.,0.,1e-306,0.,0.,0.,0.,0. };
    static doublereal dir[33]	/* was [3][11] */ = { 0.,0.,-1.,0.,3.,-1.,0.,
	    0.,-1.,1.,0.,1.,1.,0.,0.,0.,1e16,-1.,0.,1e308,-1.,0.,100.,-1.,1.,
	    0.,-1.,1.,0.,-1.,1.,0.,-1. };
    static integer expno[11] = { 1,1,1,-1,0,1,0,0,1,1,0 };
    static doublereal expxpt[33]	/* was [3][11] */ = { 0.,0.,0.,0.,30.,
	    10.,0.,0.,0.,0.,0.,0.,0.,0.,0.,1.,1e16,0.,0.,0.,0.,0.,0.,0.,2e306,
	    0.,-1e306,2e-306,0.,1e-306,0.,0.,0. };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    double pow_dd(doublereal *, doublereal *), atan2(doublereal, doublereal);

    /* Local variables */
    doublereal diff[3];
    integer seed;
    doublereal errc, errd[3], cons, errn[3];
    extern doublereal vsep_(doublereal *, doublereal *);
    doublereal errv[3];
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    );
    doublereal vprj[3], c__, d__[3];
    integer i__;
    doublereal n[3], v[3], scale, plane[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    extern doublereal dpmax_(void);
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), vlcom_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    char title[240];
    logical sepok;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal error[3];
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int vprjp_(doublereal *, doublereal *, doublereal 
	    *);
    doublereal v2[3];
    extern /* Subroutine */ int t_success__(logical *);
    integer nxpts;
    extern /* Subroutine */ int nvc2pl_(doublereal *, doublereal *, 
	    doublereal *), pl2nvc_(doublereal *, doublereal *, doublereal *), 
	    chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), cleard_(integer *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical *
	    , ftnlen);
    doublereal toobig, normal[3];
    extern /* Subroutine */ int vhatip_(doublereal *), vsclip_(doublereal *, 
	    doublereal *), inrypl_(doublereal *, doublereal *, doublereal *, 
	    integer *, doublereal *);
    extern doublereal dpr_(void);
    doublereal sep;
    extern doublereal t_randd__(doublereal *, doublereal *, integer *);
    doublereal xpt[3];

/* $ Abstract */

/*     Exercise the SPICELIB ray-plane intersection routine */

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

/*     This routine tests the SPICELIB routine INRYPL. */

/*     Overview of test procedure */
/*     -------------------------- */

/*     There are three general kinds of tests applied to whack the */
/*     candidate SPICELIB subroutine around.  The categories are: */

/*        -- Normal (non-exceptional) test cases whose results are */
/*           easy to check by hand.  These allow a tester to verify */
/*           that the tested routine is at least doing reasonable-looking */
/*           things.  (Expected results are shown for comparison.) */

/*        -- Normal test cases based on random inputs.  These */
/*           allow testing of a large number of cases.  Results will */
/*           be checked as follows: */

/*                The distance between the ray's vertex VERTEX and */
/*                the intercept point XPT will be computed.  This */
/*                distance will be used to scale the negative of the */
/*                ray's unit direction vector.  The scaled vector */
/*                will be added to XPT.  The difference between the */
/*                resulting vector and VERTEX will be divided by */
/*                the distance between VERTEX and XPT, and this scaled */
/*                difference will be used a measure of the error made */
/*                in computing the intercept point. */


/*        -- Exceptional cases.  All of the error detection code will */
/*           be exercised by these cases. */


/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 20-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Normal test cases: */


/*     1) */

/*     Planes' normal vector:                  ( 0,   0,   1 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 0,   0,   2 ) */
/*     Ray's direction vector:                 ( 0,   0,  -1 ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 0,   0,   0 ) */



/*     2) */

/*     Planes' normal vector:                  ( 0,     0,     1     ) */
/*     Plane constant:                           10 */
/*     Ray's vertex:                           ( 0,     0,     20    ) */
/*     Ray's direction vector:                 ( 0,     3,    -1     ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 0,     30     10    ) */



/*     3) */

/*     Planes' normal vector:                  ( 0,   0,   1 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 1,   1,   0 ) */
/*     Ray's direction vector:                 ( 0,   0,  -1 ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 1,   1,   0 ) */



/*     4) */

/*     Planes' normal vector:                  ( 0,   1,   0 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 0,   0,   0 ) */
/*     Ray's direction vector:                 ( 1,   0,   0 ) */
/*     Expected number of intercept points:     -1 (infinite) */
/*     Expected intercept point:               ( 0,   0,   0 ) */



/*     5) */

/*     Planes' normal vector:                  ( 0,   0,   1 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 1,   1,   1 ) */
/*     Ray's direction vector:                 ( 1,   0,   0 ) */
/*     Expected number of intercept points:      0 */
/*     Expected intercept point:               ( 0,   0,   0 ) */



/*     6) */

/*     Planes' normal vector:                  ( 0,     0,       1 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 1,     1,       1 ) */
/*     Ray's direction vector:                 ( 0,     1.D16,  -1 ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 1,     1.D16,   0 ) */



/*     7) */

/*     Planes' normal vector:                  ( 0,     0,       1 ) */
/*     Plane constant:                           0 */
/*     Ray's vertex:                           ( 1,     1,       1 ) */
/*     Ray's direction vector:                 ( 0,     1.D308, -1 ) */
/*     Expected number of intercept points:      0 */
/*     Expected intercept point:               ( 0,     0,       0 ) */



/*     8) */

/*     Planes' normal vector:                  ( 0,     0,       1     ) */
/*     Plane constant:                           EBIG */
/*     Ray's vertex:                           ( 1,     1,      2*EBIG ) */
/*     Ray's direction vector:                 ( 0,     100,    -1     ) */
/*     Expected number of intercept points:      0 */
/*     Expected intercept point:               ( 0,     0,       0 ) */



/*     9) */

/*     Planes' normal vector:                  ( 0,      0,       1    ) */
/*     Plane constant:                          -1.D306 */
/*     Ray's vertex:                           ( 1.D306,  0,      0    ) */
/*     Ray's direction vector:                 ( 1,      0,      -1    ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 2.D306,  0,   -1.D306 ) */



/*     10) */

/*     Planes' normal vector:                  ( 0,       0,       1    ) */
/*     Plane constant:                          -1.D-306 */
/*     Ray's vertex:                           ( 1.D-306,  0,      0    ) */
/*     Ray's direction vector:                 ( 1,       0,      -1    ) */
/*     Expected number of intercept points:      1 */
/*     Expected intercept point:               ( 2.D-306,  0,   -1.D306 ) */



/*     11) */

/*     Planes' normal vector:                  ( 0,       0,       1    ) */
/*     Plane constant:                           1 */
/*     Ray's vertex:                           ( 0     ,  0,       0    ) */
/*     Ray's direction vector:                 ( 1,       0,      -1    ) */
/*     Expected number of intercept points:      0 */
/*     Expected intercept point:               ( 0,       0,       0    ) */



/*     Open the test family. */

    topen_("F_INRYPL", (ftnlen)8);

/*     We'll start out with some easy-to-check cases (11 of them). */

    for (i__ = 1; i__ <= 11; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Basic case #", (ftnlen)240, (ftnlen)12);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);

/*        Make a SPICELIB plane from the plane constant and normal */
/*        vector. */

	nvc2pl_(&plnorm[(i__1 = i__ * 3 - 3) < 33 && 0 <= i__1 ? i__1 : 
		s_rnge("plnorm", i__1, "f_inrypl__", (ftnlen)568)], &plcons[(
		i__2 = i__ - 1) < 11 && 0 <= i__2 ? i__2 : s_rnge("plcons", 
		i__2, "f_inrypl__", (ftnlen)568)], plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	pl2nvc_(plane, normal, &cons);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Call the routine to be tested. */

	inrypl_(&vertex[(i__1 = i__ * 3 - 3) < 33 && 0 <= i__1 ? i__1 : 
		s_rnge("vertex", i__1, "f_inrypl__", (ftnlen)576)], &dir[(
		i__2 = i__ * 3 - 3) < 33 && 0 <= i__2 ? i__2 : s_rnge("dir", 
		i__2, "f_inrypl__", (ftnlen)576)], plane, &nxpts, xpt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("NXPTS---number of intercept points", &nxpts, "=", &expno[(
		i__1 = i__ - 1) < 11 && 0 <= i__1 ? i__1 : s_rnge("expno", 
		i__1, "f_inrypl__", (ftnlen)580)], &c__0, ok, (ftnlen)34, (
		ftnlen)1);
	chckad_("XPT---intercept", xpt, "~~/", &expxpt[(i__1 = i__ * 3 - 3) < 
		33 && 0 <= i__1 ? i__1 : s_rnge("expxpt", i__1, "f_inrypl__", 
		(ftnlen)587)], &c__3, &c_b27, ok, (ftnlen)15, (ftnlen)3);
    }

/*     Random cases follow. */

    seed = -1;
    for (i__ = 1; i__ <= 5000; ++i__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Random case #", (ftnlen)240, (ftnlen)13);
	repmi_(title, "#", &i__, title, (ftnlen)240, (ftnlen)1, (ftnlen)240);
	tcase_(title, (ftnlen)240);

/*        Generate a random scale factor. */

	d__1 = t_randd__(&c_b33, &c_b34, &seed);
	scale = pow_dd(&c_b32, &d__1);

/*        Generate a normal vector and plane constant, and from these */
/*        a SPICELIB plane. */

	n[0] = t_randd__(&c_b35, &c_b36, &seed);
	n[1] = t_randd__(&c_b35, &c_b36, &seed);
	n[2] = t_randd__(&c_b35, &c_b36, &seed);
	vhatip_(n);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	c__ = t_randd__(&c_b35, &c_b36, &seed) * scale;
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	nvc2pl_(n, &c__, plane);

/*        Now generate a random ray vertex and ray direction vector. */

	v[0] = t_randd__(&c_b35, &c_b36, &seed);
	v[1] = t_randd__(&c_b35, &c_b36, &seed);
	v[2] = t_randd__(&c_b35, &c_b36, &seed);
	vsclip_(&scale, v);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	d__[0] = t_randd__(&c_b35, &c_b36, &seed);
	d__[1] = t_randd__(&c_b35, &c_b36, &seed);
	d__[2] = t_randd__(&c_b35, &c_b36, &seed);

/*        The call. */

	inrypl_(v, d__, plane, &nxpts, xpt);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        We can pretty safely assume that we won't see a value of */
/*        -1 for NXPTS.  If the value is 1, we'll try to get back from */
/*        XPT to the ray's vertex. */

	if (nxpts == 1) {
	    vsub_(v, xpt, diff);
	    vhatip_(d__);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    d__1 = -vnorm_(diff);
	    vlcom_(&c_b65, xpt, &d__1, d__, v2);
	    chckad_("V2", v2, "~~/", v, &c__3, &c_b27, ok, (ftnlen)2, (ftnlen)
		    3);
	    vsub_(v, v2, error);
	} else {

/*           Check the angular separation between the ray */
/*           and the vector from the ray's vertex to its orthogonal */
/*           projection to the plane. */

	    vprjp_(v, plane, vprj);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    vsub_(vprj, v, diff);
	    sep = vsep_(diff, d__);
	    toobig = dpmax_() / 3;
	    if (sep * dpr_() >= 90.) {

/*              The ray is parallel to or points away from the plane. */

		sepok = TRUE_;
	    } else if (sep > atan2(toobig, vnorm_(diff))) {

/*              It doesn't happen often, but we might have a case */
/*              where the ray is too close to being parallel with */
/*              the plane for an intersection to occur. */

		sepok = TRUE_;
	    } else {

/*              This shouldn't happen. */

		sepok = FALSE_;
	    }
	    chcksl_("SEPOK---is angular separation of ray and plane consiste"
		    "nt with return code?", &sepok, &c_true, ok, (ftnlen)75);
	}
    }

/*     Now for the exceptions. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Exception:  ray's direction is the zero vector.", (ftnlen)47);
    cleard_(&c__3, errv);
    cleard_(&c__3, errd);
    cleard_(&c__3, errn);
    errn[2] = 1.;
    errc = 0.;
    nvc2pl_(errn, &errc, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inrypl_(errv, errd, plane, &nxpts, xpt);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exception:  ray's vertex is just too big.", (ftnlen)41);
    cleard_(&c__3, errv);
    cleard_(&c__3, errd);
    cleard_(&c__3, errn);
    errv[2] = 1e308;
    errd[2] = -1.;
    errn[2] = 1.;
    errc = 0.;
    nvc2pl_(errn, &errc, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inrypl_(errv, errd, plane, &nxpts, xpt);
    chckxc_(&c_true, "SPICE(VECTORTOOBIG)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exception:  Plane is too far from the origin.", (ftnlen)45);
    cleard_(&c__3, errv);
    cleard_(&c__3, errd);
    cleard_(&c__3, errn);
    errv[2] = 1.;
    errd[2] = -1.;
    errn[2] = 1.;
    errc = 1e308;
    nvc2pl_(errn, &errc, plane);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    inrypl_(errv, errd, plane, &nxpts, xpt);
    chckxc_(&c_true, "SPICE(VECTORTOOBIG)", ok, (ftnlen)19);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_inrypl__ */

