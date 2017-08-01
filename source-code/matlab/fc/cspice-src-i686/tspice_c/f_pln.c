/* f_pln.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static doublereal c_b15 = 0.;
static doublereal c_b25 = 1.;
static doublereal c_b30 = 1e-12;
static integer c__3 = 3;
static logical c_true = TRUE_;

/* $Procedure F_PLN ( SPICE plane constructor/decomposition tests ) */
/* Subroutine */ int f_pln__(logical *ok)
{
    /* Initialized data */

    static doublereal normal[30]	/* was [3][10] */ = { 1.,0.,0.,0.,1.,
	    0.,0.,0.,1.,1e20,2e20,3e20,-1e20,1e10,1e5,-1e5,-1e10,1e20,-1e10,
	    -1e5,-1e20,-1e-20,1e-10,-1e-5,1e-5,-1e-20,-1e-10,1e8,1e-8,-1e-8 };
    static doublereal const__[10] = { -1e35,4e-35,2.,1e20,0.,-1.,1.,1e-10,
	    1e-20,-1. };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer case__;
    doublereal nmag, nhat[3], dist, norm[3];
    extern doublereal vsep_(doublereal *, doublereal *);
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    doublereal plane[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen);
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal point[3];
    extern /* Subroutine */ int unorm_(doublereal *, doublereal *, doublereal 
	    *);
    extern doublereal vnorm_(doublereal *);
    doublereal v1[3], v2[3];
    extern /* Subroutine */ int t_success__(logical *), vlcom3_(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), nvc2pl_(doublereal *, doublereal *, 
	    doublereal *), pl2nvc_(doublereal *, doublereal *, doublereal *);
    doublereal point2[3];
    extern /* Subroutine */ int pl2nvp_(doublereal *, doublereal *, 
	    doublereal *), nvp2pl_(doublereal *, doublereal *, doublereal *), 
	    pl2psv_(doublereal *, doublereal *, doublereal *, doublereal *), 
	    psv2pl_(doublereal *, doublereal *, doublereal *, doublereal *);
    extern doublereal pi_(void);
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chcksd_(
	    char *, doublereal *, char *, doublereal *, doublereal *, logical 
	    *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, ftnlen);
    doublereal sclcon, con, sep;

/* $ Abstract */

/*     Exercise routines that construct SPICELIB planes or */
/*     decompose them. */

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

/*     This routine tests the SPICELIB plane construction and */
/*     decomposition routines.  The routines exercised by this family */
/*     are: */

/*        NVC2PL */
/*        NVP2PL */
/*        PL2NVC */
/*        PL2NVP */
/*        PL2PSV */
/*        PSV2PL */

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


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_PLN", (ftnlen)5);
    for (case__ = 1; case__ <= 10; ++case__) {

/* --- Case: ------------------------------------------------------ */

	s_copy(title, "Pass a plane around and see if it comes back unchange"
		"d; case #.", (ftnlen)240, (ftnlen)63);
	repmi_(title, "#", &case__, title, (ftnlen)240, (ftnlen)1, (ftnlen)
		240);
	tcase_(title, (ftnlen)240);
	nvc2pl_(&normal[(i__1 = case__ * 3 - 3) < 30 && 0 <= i__1 ? i__1 : 
		s_rnge("normal", i__1, "f_pln__", (ftnlen)211)], &const__[(
		i__2 = case__ - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("const", 
		i__2, "f_pln__", (ftnlen)211)], plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        The stored constant must be non-negative. */

	pl2nvc_(plane, norm, &con);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksd_("CON", &con, ">=", &c_b15, &c_b15, ok, (ftnlen)3, (ftnlen)2);
	pl2psv_(plane, point, v1, v2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        The returned point should be the closest one to the origin. */
/*        Check against SCLCON below. */

	dist = vnorm_(point);

/*        While we've got the plane in this form, let's perturb POINT. */
/*        The perturbation shouldn't be too huge compared to POINT, or */
/*        we'll blow away the accuracy of POINT. */

	unorm_(&normal[(i__1 = case__ * 3 - 3) < 30 && 0 <= i__1 ? i__1 : 
		s_rnge("normal", i__1, "f_pln__", (ftnlen)237)], nhat, &nmag);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	sclcon = const__[(i__1 = case__ - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("const", i__1, "f_pln__", (ftnlen)240)] / nmag;
	d__1 = sclcon * 1e3;
	d__2 = sclcon * 1e3;
	vlcom3_(&d__1, v1, &d__2, v2, &c_b25, point, point2);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	vequ_(point2, point);

/*        Test DIST while we're at it. */

	if (dist != 0.) {
	    d__1 = abs(sclcon);
	    chcksd_("DIST", &dist, "~/", &d__1, &c_b30, ok, (ftnlen)4, (
		    ftnlen)2);
	}

/*        Ok, keep going. */

	psv2pl_(point, v1, v2, plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        The stored constant must be non-negative. */

	pl2nvc_(plane, norm, &con);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksd_("CON", &con, ">=", &c_b15, &c_b15, ok, (ftnlen)3, (ftnlen)2);
	pl2nvp_(plane, norm, point);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        The returned point should be the closest one to the origin. */
/*        Check against SCLCON below. */

	dist = vnorm_(point);
	if (dist != 0.) {
	    d__1 = abs(sclcon);
	    chcksd_("DIST", &dist, "~/", &d__1, &c_b30, ok, (ftnlen)4, (
		    ftnlen)2);
	}
	nvp2pl_(norm, point, plane);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	pl2nvc_(plane, norm, &con);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        CON must be non-negative. */

	chcksd_("CON", &con, ">=", &c_b15, &c_b15, ok, (ftnlen)3, (ftnlen)2);

/*        The unit normal must be pretty close in length to 1. */

	d__1 = vnorm_(normal);
	chcksd_("||NORMAL||", &d__1, "~", &c_b25, &c_b30, ok, (ftnlen)10, (
		ftnlen)1);

/*        Check out the relative error in the plane constant and the */
/*        angular separation of the original and final normal vectors. */

	sep = vsep_(norm, nhat);
	if (const__[(i__1 = case__ - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"const", i__1, "f_pln__", (ftnlen)313)] >= 0.) {
	    chcksd_("CON", &con, "~/", &sclcon, &c_b30, ok, (ftnlen)3, (
		    ftnlen)2);
	    chcksd_("SEP", &sep, "~", &c_b15, &c_b30, ok, (ftnlen)3, (ftnlen)
		    1);
	} else {
	    d__1 = -con;
	    chcksd_("-CON", &d__1, "~/", &sclcon, &c_b30, ok, (ftnlen)4, (
		    ftnlen)2);
	    d__1 = pi_();
	    chcksd_("SEP", &sep, "~", &d__1, &c_b30, ok, (ftnlen)3, (ftnlen)1)
		    ;
	}
    }

/*     Now for some error handling tests. */


/* --- Case: ------------------------------------------------------ */

    tcase_("NVC2PL:  pass in zero normal vector", (ftnlen)35);
    cleard_(&c__3, norm);
    nvc2pl_(norm, &c_b15, plane);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("NVP2PL:  pass in zero normal vector", (ftnlen)35);
    nvp2pl_(norm, point, plane);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    tcase_("PSV2PL error case:  dependent spanning vectors.", (ftnlen)47);
    psv2pl_(point, v1, v1, plane);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_pln__ */

