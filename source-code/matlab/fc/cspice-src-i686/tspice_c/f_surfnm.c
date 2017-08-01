/* f_surfnm.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b4 = 0.;
static doublereal c_b6 = 1.;
static logical c_false = FALSE_;
static integer c__3 = 3;
static doublereal c_b15 = 1e-14;
static doublereal c_b39 = .3;
static doublereal c_b40 = .5;
static logical c_true = TRUE_;
static doublereal c_b69 = -1.;

/* $Procedure F_SURFNM ( SURFNM tests ) */
/* Subroutine */ int f_surfnm__(logical *ok)
{
    /* Initialized data */

    static doublereal origin[3] = { 0.,0.,0. };

    /* System generated locals */
    doublereal d__1, d__2, d__3, d__4, d__5, d__6;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal);

    /* Local variables */
    doublereal a, b, c__, u[3], scale, x, y;
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    logical found;
    char title[240];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal srfpt[3];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen);
    doublereal normal[3];
    extern /* Subroutine */ int vhatip_(doublereal *), surfnm_(doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *);
    doublereal xnorml[3];
    extern /* Subroutine */ int surfpt_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, logical *)
	    ;

/* $ Abstract */

/*     Exercise the SPICELIB routine SURFNM.  SURFNM find the unit */
/*     outward normal at a specfied point on an ellipsoid. */

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

/*     This routine tests the SPICELIB routine SURFNM. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 21-OCT-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Open the test family. */

    topen_("F_SURFNM", (ftnlen)8);

/*     Run some simple tests where the correct results can be */
/*     determined by inspection. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "SURFNM simple case:  point is at top of unit sphere", (
	    ftnlen)240, (ftnlen)51);
    tcase_(title, (ftnlen)240);
    a = 1.;
    b = 1.;
    c__ = 1.;
    vpack_(&c_b4, &c_b4, &c_b6, srfpt);
    vpack_(&c_b4, &c_b4, &c_b6, xnorml);
    surfnm_(&a, &b, &c__, srfpt, normal);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("NORMAL", normal, "~~/", xnorml, &c__3, &c_b15, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "SURFNM simple case:  point is (sqrt(3)/3,sqrt(3)/3,sqrt(3"
	    ")/3) on unit sphere", (ftnlen)240, (ftnlen)76);
    tcase_(title, (ftnlen)240);
    a = 1.;
    b = 1.;
    c__ = 1.;
    x = sqrt(3.) / 3.;
    vpack_(&x, &x, &x, srfpt);
    vpack_(&x, &x, &x, xnorml);
    surfnm_(&a, &b, &c__, srfpt, normal);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("NORMAL", normal, "~~/", xnorml, &c__3, &c_b15, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "SURFNM simple case: repeat previous case, but scale down "
	    "sphere by 1.D-200", (ftnlen)240, (ftnlen)74);
    tcase_(title, (ftnlen)240);
    scale = 1e-200;
    a = scale;
    b = scale;
    c__ = scale;
    x = sqrt(3.) / 3.;
    y = x * scale;
    vpack_(&y, &y, &y, srfpt);
    vpack_(&x, &x, &x, xnorml);
    surfnm_(&a, &b, &c__, srfpt, normal);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("NORMAL", normal, "~~/", xnorml, &c__3, &c_b15, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "SURFNM simple case: repeat previous case, but scale up sp"
	    "here by 1.D200", (ftnlen)240, (ftnlen)71);
    tcase_(title, (ftnlen)240);
    scale = 1e200;
    a = scale;
    b = scale;
    c__ = scale;
    x = sqrt(3.) / 3.;
    y = x * scale;
    vpack_(&y, &y, &y, srfpt);
    vpack_(&x, &x, &x, xnorml);
    surfnm_(&a, &b, &c__, srfpt, normal);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("NORMAL", normal, "~~/", xnorml, &c__3, &c_b15, ok, (ftnlen)6, (
	    ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Triaxial case: axis lengths are 1, 2, 3.  Point lies alon"
	    "g direction vector (1, 0.3, 0.5)", (ftnlen)240, (ftnlen)89);
    tcase_(title, (ftnlen)240);
    a = 1.;
    b = 2.;
    c__ = 3.;
    vpack_(&c_b6, &c_b39, &c_b40, u);

/*     Find the surface point on the specified line. */

    surfpt_(origin, u, &a, &b, &c__, srfpt, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compute the normal direction; unitize the expected normal vector. */

/* Computing 2nd power */
    d__2 = a;
    d__1 = srfpt[0] / (d__2 * d__2);
/* Computing 2nd power */
    d__4 = b;
    d__3 = srfpt[1] / (d__4 * d__4);
/* Computing 2nd power */
    d__6 = c__;
    d__5 = srfpt[2] / (d__6 * d__6);
    vpack_(&d__1, &d__3, &d__5, xnorml);
    vhatip_(xnorml);

/*     See whether SURFNM agrees. */

    surfnm_(&a, &b, &c__, srfpt, normal);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("NORMAL", normal, "~~/", xnorml, &c__3, &c_b15, ok, (ftnlen)6, (
	    ftnlen)3);

/*     SURFNM error cases: */


/* --- Case: ------------------------------------------------------ */

    tcase_("INEDPL: ellipsoid has one zero-length axis.", (ftnlen)43);
    vpack_(&c_b6, &c_b4, &c_b4, srfpt);
    surfnm_(&c_b4, &c_b6, &c_b6, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    surfnm_(&c_b6, &c_b4, &c_b6, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    surfnm_(&c_b6, &c_b6, &c_b4, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("SURFNM: ellipsoid has one negative-length axis.", (ftnlen)47);
    surfnm_(&c_b69, &c_b6, &c_b6, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    surfnm_(&c_b6, &c_b69, &c_b6, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    surfnm_(&c_b6, &c_b6, &c_b69, srfpt, normal);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_surfnm__ */

