/* f_zzasryel.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b4 = 2.;
static doublereal c_b5 = 0.;
static doublereal c_b7 = -1.;
static logical c_false = FALSE_;
static doublereal c_b16 = 1e-14;
static doublereal c_b17 = .5;
static integer c__3 = 3;
static doublereal c_b22 = 1e-7;
static doublereal c_b83 = 1e-4;
static doublereal c_b108 = 1e-10;
static logical c_true = TRUE_;

/* $Procedure  F_ZZASRYEL ( Test ray-ellipse angular separation routine ) */
/* Subroutine */ int f_zzasryel__(logical *ok)
{
    /* System generated locals */
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal), atan(doublereal);

    /* Local variables */
    doublereal limb[9], xang, a, b, c__, d__[3];
    extern /* Subroutine */ int zzasryel_(char *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, ftnlen);
    doublereal angle, v[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal raise;
    extern /* Subroutine */ int vpack_(doublereal *, doublereal *, doublereal 
	    *, doublereal *);
    char title[255];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern doublereal vnorm_(doublereal *);
    doublereal extpt[3];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen);
    extern doublereal pi_(void);
    extern /* Subroutine */ int cleard_(integer *, doublereal *), edlimb_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *), chcksd_(char *, doublereal *, char *, doublereal *,
	     doublereal *, logical *, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    doublereal ptperp[3], xpt[3];

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        ZZASRYEL */

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

/* $ Version */

/* -    TSPICE Version 1.0.0, 09-NOV-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_ZZASRYEL", (ftnlen)10);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is along +x axis.  Ray lies in th"
	    "e x-z plane and slants up at a 60 degree angle, passing over sph"
	    "ere. Find min.", (ftnlen)255, (ftnlen)199);
    tcase_(title, (ftnlen)255);

/*     Assign vertex and direction of ray. */

    vpack_(&c_b4, &c_b5, &c_b5, v);
    d__1 = sqrt(3.);
    vpack_(&c_b7, &c_b5, &d__1, d__);

/*     Semi-axis lengths of "ellipsoid" whose limb is to be found. */

    a = 1.;
    b = 1.;
    c__ = 1.;
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MIN", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb is 30 degrees. */

    xang = pi_() / 6.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs is at ( 1/2, 0, sqrt(3)/2 ).  Since we find the point */
/*     by searching for a minimum, we expect only about single */
/*     precision agreement. */

    d__1 = sqrt(3.) / 2.;
    vpack_(&c_b17, &c_b5, &d__1, xpt);
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b22, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is along +x axis.  Ray lies in th"
	    "e x-z plane and slants up at a 60 degree angle, passing over sph"
	    "ere.  Find max.", (ftnlen)255, (ftnlen)200);
    tcase_(title, (ftnlen)255);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb is 90 degrees. */

    xang = pi_() / 2.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs is at ( 1/2, 0, -sqrt(3)/2 ).  Since we find the point */
/*     by searching for a minimum, we expect only about single */
/*     precision agreement. */

    d__1 = -sqrt(3.) / 2.;
    vpack_(&c_b17, &c_b5, &d__1, xpt);
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b22, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is along +x axis.  Ray lies along"
	    " the -x axis.  Find min.", (ftnlen)255, (ftnlen)145);
    tcase_(title, (ftnlen)255);

/*     Now take the ray along the x-axis, pointing in the -x direction. */

    vpack_(&c_b4, &c_b5, &c_b5, v);
    vpack_(&c_b7, &c_b5, &c_b5, d__);
    zzasryel_("MIN", limb, v, d__, &angle, extpt, (ftnlen)3);

/*     The expected angular separation from the limb is 30 degrees. */
/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

    xang = -pi_() / 6.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs could be anywhere on the limb.  All limb points have */
/*     x-component -1/2 and an orthogonal component with length */
/*     sqrt(3)/2. */

    chcksd_("EXTPT(1)", extpt, "~", &c_b17, &c_b22, ok, (ftnlen)8, (ftnlen)1);
    vpack_(&c_b5, &xpt[1], &xpt[2], ptperp);
    d__1 = vnorm_(ptperp);
    d__2 = sqrt(3.) / 2.;
    chcksd_("||perp||", &d__1, "~", &d__2, &c_b22, ok, (ftnlen)8, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is along +x axis.  Ray lies along"
	    " the -x axis.  Find max.", (ftnlen)255, (ftnlen)145);
    tcase_(title, (ftnlen)255);

/*     In this case, all limb points correspond to both minima and */
/*     maxima. */

    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);

/*     The expected angular separation from the limb is 30 degrees. */
/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

    xang = -pi_() / 6.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs could be anywhere on the limb.  All limb points have */
/*     x-component -1/2 and an orthogonal component with length */
/*     sqrt(3)/2. */

    chcksd_("EXTPT(1)", extpt, "~", &c_b17, &c_b22, ok, (ftnlen)8, (ftnlen)1);
    vpack_(&c_b5, &xpt[1], &xpt[2], ptperp);
    d__1 = vnorm_(ptperp);
    d__2 = sqrt(3.) / 2.;
    chcksd_("||perp||", &d__1, "~", &d__2, &c_b22, ok, (ftnlen)8, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is on the +x axis.  Ray points sl"
	    "ightly above parallel to the -x axis.  Find min.", (ftnlen)255, (
	    ftnlen)169);
    tcase_(title, (ftnlen)255);

/*     Raise the vertex a bit and repeat. */

    raise = 1e-6;
    vpack_(&c_b4, &c_b5, &c_b5, v);
    vpack_(&c_b7, &c_b5, &raise, d__);
    zzasryel_("MIN", limb, v, d__, &angle, extpt, (ftnlen)3);

/*     The expected magnitude of the angular separation from the limb is */
/*     still about 30 degrees, since the limb shifts slightly when */
/*     the view point is raised. */

/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

    xang = -(pi_() / 6. - atan(raise / 1.));
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point is again at the top of the limb.  Because */
/*     this is a near-degenerate case, the determination of the extreme */
/*     point will be quite inaccurate. */

    d__1 = sqrt(3.) / 2.;
    vpack_(&c_b17, &c_b5, &d__1, xpt);
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b83, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case using sphere. Unit sphere is cente"
	    "red at the origin.  View point is on the +x axis.  Ray points sl"
	    "ightly above parallel to the -x axis.  Find max.", (ftnlen)255, (
	    ftnlen)169);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);

/*     The expected magnitude of the angular separation from the limb is */
/*     still about 30 degrees, since the limb shifts slightly when */
/*     the view point is raised. */

/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

/*     This time the extreme point we seek is at the bottom of the limb. */
/*     Recall that "max" refers to maximum *magnitude* in this context. */

    xang = -(pi_() / 6. + atan(raise / 1.));
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b16, ok, (ftnlen)6, (ftnlen)1);

/*     Because this is a near-degenerate case, the determination of the */
/*     extreme point will be quite inaccurate. */

    d__1 = -sqrt(3.) / 2.;
    vpack_(&c_b17, &c_b5, &d__1, xpt);
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b83, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Simple inspection case derived from first unit sphere cas"
	    "e.  This time ellipsoid is very wide in the +/- y directions.  F"
	    "ind min.", (ftnlen)255, (ftnlen)129);
    tcase_(title, (ftnlen)255);

/*     Assign vertex and direction of ray. */

    vpack_(&c_b4, &c_b5, &c_b5, v);
    d__1 = sqrt(3.);
    vpack_(&c_b7, &c_b5, &d__1, d__);

/*     Semi-axis lengths of ellipsoid whose limb is to be found. */
/*     Note length of y semi-axis. */

    a = 1.;
    b = 1e3;
    c__ = 1.;
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MIN", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb is 30 degrees. */

    xang = pi_() / 6.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b108, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs is at ( 1/2, 0, sqrt(3)/2 ).  Since we find the point */
/*     by searching for a minimum, and because of the rather extreme */
/*     geometry, we expect less than single precision agreement. */

    d__1 = sqrt(3.) / 2.;
    vpack_(&c_b17, &c_b5, &d__1, xpt);
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b83, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Extreme case:  this time ellipsoid is very wide in the +/"
	    "- y directions and flat in z-direction. Find max.", (ftnlen)255, (
	    ftnlen)106);
    tcase_(title, (ftnlen)255);

/*     Assign vertex and direction of ray. */

    vpack_(&c_b4, &c_b5, &c_b5, v);
    d__1 = sqrt(3.);
    vpack_(&c_b7, &c_b5, &d__1, d__);

/*     Semi-axis lengths of ellipsoid whose limb is to be found. */
/*     Note length of y and z semi-axes. */

    a = 1.;
    b = 1e3;
    c__ = 1e-5;
    vpack_(&c_b7, &c_b5, &c_b83, d__);
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb is close to the */
/*     angular extent of the largest semi-axis of the limb.  This */
/*     is a rough estimate. */

    xang = atan(b * sqrt(3.) / 2. / 1.5);
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b108, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the maximum angular separation */
/*     occurs is roughly at either of ( 1/2, +/- B*sqrt(3)/2, 0 ). */
/*     Since the actual point will have negative z-component, this is a */
/*     very rough estimate. */

    if (extpt[1] > 0.) {
	d__1 = b * sqrt(3.) / 2.;
	vpack_(&c_b17, &d__1, &c_b5, xpt);
    } else {
	d__1 = -b * sqrt(3.) / 2.;
	vpack_(&c_b17, &d__1, &c_b5, xpt);
    }
    chckad_("EXTPT,", extpt, "~~/", xpt, &c__3, &c_b83, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Interior case with ray pointing in -x direction. This tim"
	    "e ellipsoid is very wide in the +/- y directions.  Find min.", (
	    ftnlen)255, (ftnlen)117);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b4, &c_b5, &c_b5, v);
    vpack_(&c_b7, &c_b5, &c_b5, d__);
    a = 1.;
    b = 1e3;
    c__ = 1.;
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MIN", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb is 30 degrees. */
/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

    xang = -pi_() / 6.;
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b108, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs is at either of ( 1/2, 0, +/- sqrt(3)/2 ).  Since we find */
/*     the point by searching for a minimum, and because of the rather */
/*     extreme geometry, we expect less than single precision agreement. */

    if (extpt[2] > 0.) {
	d__1 = sqrt(3.) / 2.;
	vpack_(&c_b17, &c_b5, &d__1, xpt);
    } else {
	d__1 = -sqrt(3.) / 2.;
	vpack_(&c_b17, &c_b5, &d__1, xpt);
    }
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b83, ok, (ftnlen)6, (ftnlen)
	    1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Interior case with ray pointing in -x direction. This tim"
	    "e ellipsoid is very wide in the +/- y directions.  Find max.", (
	    ftnlen)255, (ftnlen)117);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b4, &c_b5, &c_b5, v);
    vpack_(&c_b7, &c_b5, &c_b5, d__);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     The expected angular separation from the limb the angular */
/*     extent of the largest-semi-axis, which lies on the y-axis. */
/*     Since the ray penetrates the interior of the plane region */
/*     bounded by the limb, the sign of the angle is negative. */

    xang = -atan(b * sqrt(3.) / 2. / 1.5);
    chcksd_("ANGLE,", &angle, "~", &xang, &c_b108, ok, (ftnlen)6, (ftnlen)1);

/*     The expected limb point at which the minimum angular separation */
/*     occurs is at either of ( 1/2, +/- B*sqrt(3)/2, 0 ).  Since we */
/*     find the point by searching for a minimum, and because of the */
/*     rather extreme geometry, we expect less than single precision */
/*     agreement. */

    if (extpt[1] > 0.) {
	d__1 = b * sqrt(3.) / 2.;
	vpack_(&c_b17, &d__1, &c_b5, xpt);
    } else {
	d__1 = -b * sqrt(3.) / 2.;
	vpack_(&c_b17, &d__1, &c_b5, xpt);
    }
    chckad_("EXTPT,", extpt, "~", xpt, &c__3, &c_b83, ok, (ftnlen)6, (ftnlen)
	    1);

/*     Error cases: */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Direction vector is zero vector.", (ftnlen)255, (ftnlen)32)
	    ;
    tcase_(title, (ftnlen)255);

/*     Assign vertex and direction of ray. */

    vpack_(&c_b4, &c_b5, &c_b5, v);
    cleard_(&c__3, d__);

/*     Semi-axis lengths of "ellipsoid" whose limb is to be found. */

    a = 1.;
    b = 1.;
    c__ = 1.;
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Limb has zero-length semi-minor axis", (ftnlen)255, (
	    ftnlen)36);
    tcase_(title, (ftnlen)255);
    limb[6] = 0.;
    limb[7] = 0.;
    limb[8] = 0.;
    d__1 = sqrt(3.);
    vpack_(&c_b7, &c_b5, &d__1, d__);
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_true, "SPICE(INVALIDAXISLENGTH)", ok, (ftnlen)24);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Vertex lies in plane of ellipse.", (ftnlen)255, (ftnlen)32)
	    ;
    limb[3] = 0.;
    limb[4] = 2.;
    limb[5] = 0.;
    limb[6] = 1.;
    limb[7] = 0.;
    limb[8] = 0.;
    zzasryel_("MAX", limb, v, d__, &angle, extpt, (ftnlen)3);
    chckxc_(&c_true, "SPICE(DEGENERATECASE)", ok, (ftnlen)21);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Unrecognized extremum specifier", (ftnlen)255, (ftnlen)31);
    a = 1.;
    b = 1.;
    c__ = 1.;
    edlimb_(&a, &b, &c__, v, limb);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzasryel_("MX", limb, v, d__, &angle, extpt, (ftnlen)2);
    chckxc_(&c_true, "SPICE(NOTSUPPORTED)", ok, (ftnlen)19);
    t_success__(ok);
    return 0;
} /* f_zzasryel__ */

