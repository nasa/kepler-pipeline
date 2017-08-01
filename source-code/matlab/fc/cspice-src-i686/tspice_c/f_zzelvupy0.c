/* f_zzelvupy0.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b3 = -1.;
static doublereal c_b7 = 1.;
static doublereal c_b16 = 0.;
static doublereal c_b25 = .5;
static doublereal c_b92 = -.5;
static logical c_false = FALSE_;
static doublereal c_b132 = -9.5;
static doublereal c_b133 = 10.;
static doublereal c_b146 = -10.999;
static doublereal c_b150 = -5.5;
static doublereal c_b160 = -30.;
static doublereal c_b168 = 2.00050001;
static doublereal c_b169 = 2.;
static doublereal c_b171 = -2.00050001;
static doublereal c_b173 = .001;
static doublereal c_b176 = -15.;
static logical c_true = TRUE_;

/* $Procedure      F_ZZELVUPY0 ( Test ZZELVUPY ) */
/* Subroutine */ int f_zzelvupy0__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Builtin functions */
    double sqrt(doublereal);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    doublereal ectr[3], axis[3];
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    ), vequ_(doublereal *, doublereal *);
    integer i__, j, n;
    extern /* Subroutine */ int zzelvupy_(doublereal *, doublereal *, 
	    doublereal *, integer *, doublereal *, logical *);
    doublereal esmaj[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal esmin[3];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[255];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , cgv2el_(doublereal *, doublereal *, doublereal *, doublereal *);
    doublereal hafrt2;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksl_(char *, logical *, logical *, logical *, ftnlen);
    doublereal center[3], offset[3], ellips[9], smajor[3];
    logical xfound;
    doublereal sminor[3], vertex[3], fov[300]	/* was [3][100] */;

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        ZZELVUPY */

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

/* -    TSPICE Version 1.0.0, 11-AUG-2005 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_ZZELVUPY0", (ftnlen)11);

/*     Test all ellipse/FOV combinations. */

    for (i__ = 1; i__ <= 7; ++i__) {

/*        Set the default FOV shape. */


/*        WRITE (*,*) '================================================' */
/*        WRITE (*,*) '================================================' */
/*        WRITE (*,*) '================================================' */
/*        WRITE (*,*) '================================================' */
	if (i__ == 1) {

/*           The first case is a square FOV. */

	    n = 4;
	    vpack_(&c_b3, &c_b3, &c_b3, fov);
	    vpack_(&c_b3, &c_b7, &c_b3, &fov[3]);
	    vpack_(&c_b3, &c_b7, &c_b7, &fov[6]);
	    vpack_(&c_b3, &c_b3, &c_b7, &fov[9]);
	    vpack_(&c_b3, &c_b16, &c_b16, axis);
	    vpack_(&c_b7, &c_b16, &c_b16, vertex);

/*           The default ellipse is oriented with the major axis */
/*           vertical and is parallel to the x-z plane. */

	    vpack_(&c_b16, &c_b16, &c_b7, smajor);
	    vpack_(&c_b16, &c_b25, &c_b16, sminor);
	    vpack_(&c_b3, &c_b16, &c_b16, center);
	} else if (i__ == 2) {

/*           Rotate the FOV starting index counterclockwise by pi/2. */

	    vpack_(&c_b3, &c_b7, &c_b3, fov);
	    vpack_(&c_b3, &c_b7, &c_b7, &fov[3]);
	    vpack_(&c_b3, &c_b3, &c_b7, &fov[6]);
	    vpack_(&c_b3, &c_b3, &c_b3, &fov[9]);
	} else if (i__ == 3) {

/*           Rotate the FOV starting index clockwise by pi/2. */

	    vpack_(&c_b3, &c_b3, &c_b7, fov);
	    vpack_(&c_b3, &c_b3, &c_b3, &fov[3]);
	    vpack_(&c_b3, &c_b7, &c_b3, &fov[6]);
	    vpack_(&c_b3, &c_b7, &c_b7, &fov[9]);
	} else if (i__ == 4) {

/*           Rotate the FOV starting index clockwise by pi. */

	    vpack_(&c_b3, &c_b7, &c_b7, fov);
	    vpack_(&c_b3, &c_b3, &c_b7, &fov[3]);
	    vpack_(&c_b3, &c_b3, &c_b3, &fov[6]);
	    vpack_(&c_b3, &c_b7, &c_b3, &fov[9]);
	} else if (i__ == 5) {

/*           Reverse ordering of FOV boundary vectors. */

	    vpack_(&c_b3, &c_b3, &c_b3, &fov[9]);
	    vpack_(&c_b3, &c_b7, &c_b3, &fov[6]);
	    vpack_(&c_b3, &c_b7, &c_b7, &fov[3]);
	    vpack_(&c_b3, &c_b3, &c_b7, fov);
	} else if (i__ == 6) {

/*           For this case, we use an ellipse that is seen */
/*           edge-on from the apex of the pyramid.  This */
/*           ellipse lies in the x-y plane. */

	    vpack_(&c_b7, &c_b16, &c_b16, smajor);
	    vpack_(&c_b16, &c_b25, &c_b16, sminor);
	    vpack_(&c_b3, &c_b16, &c_b16, center);
	} else if (i__ == 7) {

/*           Now we make the FOV into a four-pointed star.  The */
/*           star is formed by taking our original square FOV and */
/*           "pinching" it at the midpoints of each edge. */

	    n = 8;
	    vpack_(&c_b3, &c_b3, &c_b3, fov);
	    vpack_(&c_b3, &c_b16, &c_b92, &fov[3]);
	    vpack_(&c_b3, &c_b7, &c_b3, &fov[6]);
	    vpack_(&c_b3, &c_b25, &c_b16, &fov[9]);
	    vpack_(&c_b3, &c_b7, &c_b7, &fov[12]);
	    vpack_(&c_b3, &c_b16, &c_b25, &fov[15]);
	    vpack_(&c_b3, &c_b3, &c_b7, &fov[18]);
	    vpack_(&c_b3, &c_b92, &c_b16, &fov[21]);

/*           Use the same axis and vertex as before. */

	    vpack_(&c_b3, &c_b16, &c_b16, axis);
	    vpack_(&c_b7, &c_b16, &c_b16, vertex);

/*           The default ellipse is oriented with the major axis slanted */
/*           in the z=y direction and is parallel to the x-z plane. */

	    hafrt2 = sqrt(2.) / 2.;
	    vpack_(&c_b16, &hafrt2, &hafrt2, smajor);
	    d__1 = -hafrt2 / 2;
	    vpack_(&c_b16, &d__1, &hafrt2, sminor);
	    vpack_(&c_b3, &c_b16, &c_b16, center);
	}

/*        Test for geometric cases: */

/*           1) Ellipse inside FOV */
/*           2) FOV inside ellipse */
/*           3) FOV chops ellipse */
/*           4) No intersection */

	for (j = 1; j <= 5; ++j) {
	    if (j == 1) {

/* --- Case: ------------------------------------------------------ */

		s_copy(title, "Combo = #; geometric case = ellipse in FOV.", (
			ftnlen)255, (ftnlen)43);
		repmi_(title, "#", &i__, title, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(title, (ftnlen)255);

/*              The ellipse is defined by the default components. */

		vequ_(center, ectr);
		vequ_(smajor, esmaj);
		vequ_(sminor, esmin);

/*              We expect the intersection to be found. */

		xfound = TRUE_;
	    } else if (j == 2) {

/* --- Case: ------------------------------------------------------ */

		s_copy(title, "Combo = #; geometric case = ellipse is not co"
			"ntained in FOV but contains center of FOV.", (ftnlen)
			255, (ftnlen)87);
		repmi_(title, "#", &i__, title, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(title, (ftnlen)255);
		if (i__ <= 5) {

/*                 The ellipse is scaled up by a factor of 10 and */
/*                 shifted in the -z direction so the center of the */
/*                 ellipse is not in the FOV. */

		    vpack_(&c_b16, &c_b16, &c_b132, offset);
		    vadd_(center, offset, ectr);
		    vscl_(&c_b133, smajor, esmaj);
		    vscl_(&c_b133, sminor, esmin);
		} else if (i__ == 6) {
		    vpack_(&c_b16, &c_b132, &c_b16, offset);
		    vadd_(center, offset, ectr);
		    vscl_(&c_b133, smajor, esmaj);
		    vscl_(&c_b133, sminor, esmin);
		}

/*              We expect the intersection to be found. */

		xfound = TRUE_;
	    } else if (j == 3) {

/* --- Case: ------------------------------------------------------ */

		s_copy(title, "Combo = #; geometric case = ellipse is choppe"
			"d by FOV.", (ftnlen)255, (ftnlen)54);
		repmi_(title, "#", &i__, title, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(title, (ftnlen)255);
		if (i__ <= 5) {

/*                 The ellipse is scaled up by a factor of 10 and */
/*                 shifted in the -z direction so the center is not in */
/*                 the FOV and the center of the FOV is not in the */
/*                 ellipse. */

		    vpack_(&c_b16, &c_b16, &c_b146, offset);
		    vadd_(center, offset, ectr);
		    vscl_(&c_b133, smajor, esmaj);
		    vscl_(&c_b133, sminor, esmin);
		} else if (i__ == 6) {
/*                 The ellipse is scaled up by a factor of 10 and */
/*                 shifted in the -y direction so the center is not in */
/*                 the FOV and the center of the FOV is not in the */
/*                 ellipse. */

		    vpack_(&c_b16, &c_b150, &c_b16, offset);
		    vadd_(center, offset, ectr);
		    vscl_(&c_b133, smajor, esmaj);
		    vscl_(&c_b133, sminor, esmin);
		}

/*              We expect the intersection to be found. */

		xfound = TRUE_;
	    } else if (j == 4) {

/* --- Case: ------------------------------------------------------ */

		s_copy(title, "Combo = #; geometric case = bounding cones of"
			" ellipse and FOV are disjoint.", (ftnlen)255, (ftnlen)
			75);
		repmi_(title, "#", &i__, title, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(title, (ftnlen)255);

/*              The ellipse is scaled up by a factor of 10 and */
/*              shifted in the -z direction so the bounding cones */
/*              are disjoint. */

		vpack_(&c_b16, &c_b16, &c_b160, offset);
		vadd_(center, offset, ectr);
		vscl_(&c_b133, smajor, esmaj);
		vscl_(&c_b133, sminor, esmin);

/*              We expect the intersection NOT to be found. */

		xfound = FALSE_;
	    } else if (j == 5) {

/* --- Case: ------------------------------------------------------ */

		s_copy(title, "Combo = #; geometric case = bounding cones of"
			" ellipse and FOV are not disjoint, but there is no i"
			"ntersection.", (ftnlen)255, (ftnlen)109);
		repmi_(title, "#", &i__, title, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		chckxc_(&c_false, " ", ok, (ftnlen)1);
		tcase_(title, (ftnlen)255);
		if (i__ <= 5) {

/*                 Make the ellipse very thin and position it */
/*                 so that it doesn't intersect the FOV, but so */
/*                 that the plane containing the apex and the top */
/*                 edge of the FOV does intersect the ellipse. */

		    if (i__ <= 3) {
			vpack_(&c_b16, &c_b168, &c_b169, offset);
		    } else {
			vpack_(&c_b16, &c_b171, &c_b169, offset);
		    }
		    vadd_(center, offset, ectr);
		    vequ_(smajor, esmaj);
		    vscl_(&c_b173, sminor, esmin);
		} else {

/*                 The ellipse is scaled up by a factor of 10 and */
/*                 shifted in the -z direction so the bounding cones */
/*                 are non disjoint, but the ellipse is outside the */
/*                 FOV. */

		    vpack_(&c_b16, &c_b16, &c_b176, offset);
		    vadd_(center, offset, ectr);
		    vscl_(&c_b133, smajor, esmaj);
		    vscl_(&c_b133, sminor, esmin);
		}

/*              We expect the intersection NOT to be found. */

		xfound = FALSE_;
	    }

/*           Pack the ellipse components. */

	    cgv2el_(ectr, esmaj, esmin, ellips);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_("FOUND", &found, &xfound, ok, (ftnlen)5);
	}
    }

/*     Test error cases. */

    n = 4;
    vpack_(&c_b3, &c_b3, &c_b3, fov);
    vpack_(&c_b3, &c_b7, &c_b3, &fov[3]);
    vpack_(&c_b3, &c_b7, &c_b7, &fov[6]);
    vpack_(&c_b3, &c_b3, &c_b7, &fov[9]);
    vpack_(&c_b3, &c_b16, &c_b16, axis);
    vpack_(&c_b7, &c_b16, &c_b16, vertex);

/*     The default ellipse is oriented with the major axis */
/*     vertical and is parallel to the x-z plane. */

    vpack_(&c_b16, &c_b16, &c_b7, smajor);
    vpack_(&c_b16, &c_b25, &c_b16, sminor);
    vpack_(&c_b3, &c_b16, &c_b16, center);
    tcase_("Axis is the zero vector.", (ftnlen)24);
    vpack_(&c_b16, &c_b16, &c_b16, axis);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);
    tcase_("Second and third boundary vectors are the same.", (ftnlen)47);

/*     Restore the orginal axis vector. */

    vpack_(&c_b3, &c_b16, &c_b16, axis);
    vpack_(&c_b3, &c_b7, &c_b3, &fov[6]);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(INVALIDFOV)", ok, (ftnlen)17);
    tcase_("Third boundary vector is the zero vector.", (ftnlen)41);
    vpack_(&c_b16, &c_b16, &c_b16, &fov[6]);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);
    tcase_("Ellipse generating vectors are linearly dependent.  The semi-min"
	    "or axis is therefore zero.", (ftnlen)90);
    n = 4;
    vpack_(&c_b3, &c_b3, &c_b3, fov);
    vpack_(&c_b3, &c_b7, &c_b3, &fov[3]);
    vpack_(&c_b3, &c_b7, &c_b7, &fov[6]);
    vpack_(&c_b3, &c_b3, &c_b7, &fov[9]);
    vpack_(&c_b16, &c_b16, &c_b7, smajor);
    vpack_(&c_b16, &c_b16, &c_b7, sminor);
    cgv2el_(center, smajor, sminor, ellips);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);
    tcase_("Ellipse semi-minor axis is zero.", (ftnlen)32);
    n = 4;
    vpack_(&c_b3, &c_b3, &c_b3, fov);
    vpack_(&c_b3, &c_b7, &c_b3, &fov[3]);
    vpack_(&c_b3, &c_b7, &c_b7, &fov[6]);
    vpack_(&c_b3, &c_b3, &c_b7, &fov[9]);
    vpack_(&c_b16, &c_b16, &c_b7, smajor);
    vpack_(&c_b16, &c_b16, &c_b16, sminor);
    cgv2el_(center, smajor, sminor, ellips);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);

    tcase_("Ellipse semi-axes are both zero.", (ftnlen)32);
    n = 4;
    vpack_(&c_b3, &c_b3, &c_b3, fov);
    vpack_(&c_b3, &c_b7, &c_b3, &fov[3]);
    vpack_(&c_b3, &c_b7, &c_b7, &fov[6]);
    vpack_(&c_b3, &c_b3, &c_b7, &fov[9]);
    vpack_(&c_b16, &c_b16, &c_b16, smajor);
    vpack_(&c_b16, &c_b16, &c_b16, sminor);
    cgv2el_(center, smajor, sminor, ellips);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    zzelvupy_(ellips, vertex, axis, &n, fov, &found);
    chckxc_(&c_true, "SPICE(ZEROVECTOR)", ok, (ftnlen)17);
/*     This commented-out block is used for timing tests. */
/*     We set up the square FOV and ellipse in the x-z plane. */

/*     CALL VPACK ( -1.D0,  -1.D0, -1.D0,  FOV(1,1) ) */
/*     CALL VPACK ( -1.D0,   1.D0, -1.D0,  FOV(1,2) ) */
/*     CALL VPACK ( -1.D0,   1.D0,  1.D0,  FOV(1,3) ) */
/*     CALL VPACK ( -1.D0,  -1.D0,  1.D0,  FOV(1,4) ) */

/*     CALL VPACK ( -1.D0,   0.D0,  0.D0,  AXIS     ) */
/*     CALL VPACK (  1.D0,   0.D0,  0.D0,  VERTEX   ) */

/*     The default ellipse is oriented with the major axis */
/*     vertical and is parallel to the x-z plane. */

/*     CALL VPACK (  0.D0,   0.D0,  1.D0,   SMAJOR ) */
/*     CALL VPACK (  0.D0,   5.D-1, 0.D0,   SMINOR ) */
/*     CALL VPACK ( -1.D0,   0.D0,  0.D0,   CENTER ) */

/*     This  block is used for the case where the bounding cones are */
/*     disjoint. This is the fastest case, but the one that should be */
/*     encountered most often. */

/*     CALL VPACK ( 0.D0, 0.D0, -30.D0, OFFSET ) */

/*     CALL VADD  ( CENTER,  OFFSET, ECTR  ) */
/*     CALL VSCL  ( 10.D0,   SMAJOR, ESMAJ ) */
/*     CALL VSCL  ( 10.D0,   SMINOR, ESMIN ) */

/*     This commented-out block is for the fall-through */
/*     non-intersection case, which is the slowest. */

/*     CALL VPACK ( 0.D0, 0.D0, -15.D0, OFFSET ) */

/*     CALL VADD  ( CENTER,  OFFSET, ECTR  ) */
/*     CALL VSCL  ( 10.D0,   SMAJOR, ESMAJ ) */
/*     CALL VSCL  ( 10.D0,   SMINOR, ESMIN ) */


/*     CALL CGV2EL ( ECTR, ESMAJ, ESMIN, ELLIPS ) */


/*     DO I = 1, 100000 */
/*        CALL ZZELVUPY ( ELLIPS, VERTEX, AXIS, N, FOV, FOUND ) */
/*     END DO */

    t_success__(ok);
    return 0;
} /* f_zzelvupy0__ */

