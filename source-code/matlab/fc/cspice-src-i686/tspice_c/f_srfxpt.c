/* f_srfxpt.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c_n499 = -499;
static integer c__499 = 499;
static integer c__1 = 1;
static integer c_n666 = -666;
static doublereal c_b96 = 1.;
static doublereal c_b111 = 1e-14;
static doublereal c_b118 = 0.;
static doublereal c_b119 = .001;
static integer c__3 = 3;
static doublereal c_b152 = 1e-8;

/* $Procedure      F_SRFXPT ( SRFXPT family tests ) */
/* Subroutine */ int f_srfxpt__(logical *ok)
{
    /* Initialized data */

    static char abcs[10*9] = "None      " "Lt        " "Lt+s      " "Cn     "
	    "   " "Cn+s      " "Xlt       " "Xlt+s     " "Xcn       " "Xcn+s "
	    "    ";
    static char refs[32*3] = "J2000                           " "IAU_MARS   "
	    "                     " "IAU_EARTH                       ";
    static char geoms[80*4] = "POINT_AT_CENTER                              "
	    "                                   " "MISS_BACKWARD             "
	    "                                                      " "LIMB_IN"
	    "SIDE_NEAR                                                       "
	    "         " "MISS_LIMB_NEAR                                      "
	    "                            ";
    static char obsnms[32*2] = "Earth                           " "MARS_ORBI"
	    "TER                    ";

    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen), i_indx(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal frac;
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    );
    char dref[32];
    doublereal dvec[3], limb[9];
    char geom[80];
    doublereal dist, etol, elts[8], tipm[9]	/* was [3][3] */;
    integer nitr;
    extern doublereal vsep_(doublereal *, doublereal *);
    extern /* Subroutine */ int vsub_(doublereal *, doublereal *, doublereal *
	    ), vequ_(doublereal *, doublereal *);
    logical xmit;
    doublereal splt[3], xray[3];
    extern /* Subroutine */ int mtxv_(doublereal *, doublereal *, doublereal *
	    );
    doublereal negj2[3], j2obs[3], obsj2[3], tipj2[3];
    integer i__, n;
    doublereal radii[3], delta;
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    extern doublereal jyear_(void);
    logical found, usecn;
    doublereal spvec[3];
    char title[80];
    extern /* Subroutine */ int vlcom_(doublereal *, doublereal *, doublereal 
	    *, doublereal *, doublereal *), topen_(char *, ftnlen);
    extern doublereal vdist_(doublereal *, doublereal *);
    doublereal tipfx[3], xdist, xform[9]	/* was [3][3] */;
    logical uselt;
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int spkw05_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, doublereal *, ftnlen, ftnlen);
    extern doublereal vnorm_(doublereal *);
    doublereal sppos[3], xrtrg[3];
    extern /* Subroutine */ int bodn2c_(char *, integer *, logical *, ftnlen),
	     t_success__(logical *);
    doublereal xspnt[3], dvecj2[3];
    extern /* Subroutine */ int el2cgv_(doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal state0[6], trgj2m[9]	/* was [3][3] */;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     str2et_(char *, doublereal *, ftnlen);
    doublereal et, te;
    integer abcidx, drefid, handle[2], obscde;
    doublereal lt;
    extern /* Subroutine */ int edlimb_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    doublereal depoch;
    integer frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksd_(char *, doublereal *, char *, doublereal *, doublereal *,
	     logical *, ftnlen, ftnlen), delfil_(char *, ftnlen);
    doublereal negvec[3];
    char abcorr[10];
    integer trgcde;
    extern doublereal clight_(void);
    extern /* Subroutine */ int t_pck08__(char *, logical *, logical *, 
	    ftnlen), chcksl_(char *, logical *, logical *, logical *, ftnlen),
	     conics_(doublereal *, doublereal *, doublereal *);
    doublereal dvecfx[3], obsvec[3];
    integer clssid, geoidx;
    doublereal trgepc;
    integer refctr;
    char target[32];
    doublereal lcentr[3], dvecst[3], xepoch, smajor[3], ssbobs[6], refpos[3];
    integer obsidx;
    char trgfrm[32];
    doublereal dj2[3], obspos[3], sminor[3], ssbtrg[6];
    integer refidx;
    extern /* Subroutine */ int spkopn_(char *, char *, integer *, integer *, 
	    ftnlen, ftnlen), spkcls_(integer *);
    doublereal spoint[3];
    char obsrvr[32];
    doublereal xobsps[3];
    logical usestl;
    extern /* Subroutine */ int spklef_(char *, integer *, ftnlen), pcpool_(
	    char *, integer *, char *, ftnlen, ftnlen), pipool_(char *, 
	    integer *, integer *, ftnlen), cnmfrm_(char *, integer *, char *, 
	    logical *, ftnlen, ftnlen), tstlsk_(void), bodvar_(integer *, 
	    char *, integer *, doublereal *, ftnlen), namfrm_(char *, integer 
	    *, ftnlen), tstspk_(char *, logical *, integer *, ftnlen), 
	    frinfo_(integer *, integer *, integer *, integer *, logical *), 
	    spkezp_(integer *, doublereal *, char *, char *, integer *, 
	    doublereal *, doublereal *, ftnlen, ftnlen), pxform_(char *, char 
	    *, doublereal *, doublereal *, ftnlen, ftnlen), spkpos_(char *, 
	    doublereal *, char *, char *, char *, doublereal *, doublereal *, 
	    ftnlen, ftnlen, ftnlen, ftnlen), vminus_(doublereal *, doublereal 
	    *), spkssb_(integer *, doublereal *, char *, doublereal *, ftnlen)
	    , stlabx_(doublereal *, doublereal *, doublereal *), stelab_(
	    doublereal *, doublereal *, doublereal *), sigerr_(char *, ftnlen)
	    , srfxpt_(char *, char *, doublereal *, char *, char *, char *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, logical *, ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), 
	    spkuef_(integer *);
    logical fnd;
    integer cls;
    doublereal dlt;
    extern doublereal rpd_(void);
    doublereal sep;
    char utc[50];
    doublereal tgt[3], tol, xte, rlt, tlt, xlt;
    extern /* Subroutine */ int mxv_(doublereal *, doublereal *, doublereal *)
	    ;
    doublereal dj2m[9]	/* was [3][3] */, spj2[3];

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        SRFXPT */

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

/* -    TSPICE Version 1.0.0, 23-FEB-2004 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_SRFXPT", (ftnlen)8);
    tcase_("Setup:  create SPK, PCK file.", (ftnlen)29);
    tstspk_("srfxpt_spk.bsp", &c_true, handle, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create the PCK file, load it, and delete it. */

    t_pck08__("test_0008.tpc", &c_true, &c_false, (ftnlen)13);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create LSK, load it, and delete it. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set time. */

    s_copy(utc, "2004 FEB 17", (ftnlen)50, (ftnlen)11);
    str2et_(utc, &et, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Create a Mars orbiter SPK file. */

    spkopn_("orbiter.bsp", "orbiter.bsp", &c__0, &handle[1], (ftnlen)11, (
	    ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Set up elements defining a state.  The elements expected */
/*     by CONICS are: */

/*        RP      Perifocal distance. */
/*        ECC     Eccentricity. */
/*        INC     Inclination. */
/*        LNODE   Longitude of the ascending node. */
/*        ARGP    Argument of periapse. */
/*        M0      Mean anomaly at epoch. */
/*        T0      Epoch. */
/*        MU      Gravitational parameter. */

    elts[0] = 3800.;
    elts[1] = .1;
    elts[2] = rpd_() * 80.;
    elts[3] = 0.;
    elts[4] = rpd_() * 90.;
    elts[5] = 0.;
    elts[6] = et;
    elts[7] = 42828.314;
    conics_(elts, &et, state0);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    d__1 = jyear_() * -10;
    d__2 = jyear_() * 10;
    spkw05_(&handle[1], &c_n499, &c__499, "MARSIAU", &d__1, &d__2, "Mars orb"
	    "iter", &elts[7], &c__1, state0, &et, (ftnlen)7, (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    spkcls_(&handle[1]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Load the new SPK file. */

    spklef_("orbiter.bsp", &handle[1], (ftnlen)11);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add the orbiter's name/ID mapping to the kernel pool. */

    pcpool_("NAIF_BODY_NAME", &c__1, obsnms + 32, (ftnlen)14, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    pipool_("NAIF_BODY_CODE", &c__1, &c_n499, (ftnlen)14);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Add an incomplete frame definition to the kernel pool; */
/*     we'll need this later. */

    pipool_("FRAME_BAD_NAME", &c__1, &c_n666, (ftnlen)14);

/*     Start out with consistency checks:  having found SPOINT, */
/*     find the aberration corrected location of SPOINT by */
/*     direct computation, and compare results to those from */
/*     SRFXPT. */

/*     Test cases for a distant viewer:  ray emanates from earth's */
/*     center, points towards Mars' center. */

/*     Set target.  Get target code, target body-fixed frame */
/*     name. */

    s_copy(target, "Mars", (ftnlen)32, (ftnlen)4);
    bodn2c_(target, &trgcde, &found, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    cnmfrm_(target, &frcode, trgfrm, &found, (ftnlen)32, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Get target radii. */

    bodvar_(&trgcde, "RADII", &n, radii, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Loop over every choice of observer. */

    for (obsidx = 1; obsidx <= 2; ++obsidx) {
	s_copy(obsrvr, obsnms + (((i__1 = obsidx - 1) < 2 && 0 <= i__1 ? i__1 
		: s_rnge("obsnms", i__1, "f_srfxpt__", (ftnlen)372)) << 5), (
		ftnlen)32, (ftnlen)32);

/*        Set the observer ID code. */

	bodn2c_(obsrvr, &obscde, &found, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Loop over every viewing geometry case. */

	for (geoidx = 1; geoidx <= 4; ++geoidx) {
	    s_copy(geom, geoms + ((i__1 = geoidx - 1) < 4 && 0 <= i__1 ? i__1 
		    : s_rnge("geoms", i__1, "f_srfxpt__", (ftnlen)384)) * 80, 
		    (ftnlen)80, (ftnlen)80);

/*           Loop over every aberration correction choice. */

	    for (abcidx = 1; abcidx <= 9; ++abcidx) {
		s_copy(abcorr, abcs + ((i__1 = abcidx - 1) < 9 && 0 <= i__1 ? 
			i__1 : s_rnge("abcs", i__1, "f_srfxpt__", (ftnlen)391)
			) * 10, (ftnlen)10, (ftnlen)10);

/*              Set up some logical variables describing the */
/*              attributes of the selected correction. */

		uselt = s_cmp(abcorr, "None", (ftnlen)10, (ftnlen)4) != 0;
		xmit = *(unsigned char *)abcorr == 'X';
		usecn = s_cmp(abcorr, "Cn", (ftnlen)2, (ftnlen)2) == 0 || 
			s_cmp(abcorr, "Xcn", (ftnlen)3, (ftnlen)3) == 0;
		usestl = i_indx(abcorr, "+s", (ftnlen)10, (ftnlen)2) != 0;

/*              Loop over every direction vector frame choice. */

		for (refidx = 1; refidx <= 3; ++refidx) {
		    s_copy(dref, refs + (((i__1 = refidx - 1) < 3 && 0 <= 
			    i__1 ? i__1 : s_rnge("refs", i__1, "f_srfxpt__", (
			    ftnlen)410)) << 5), (ftnlen)32, (ftnlen)32);

/*                 Set light time RLT from observer to center of frame */
/*                 for the direction vector. */

		    namfrm_(dref, &drefid, (ftnlen)32);
		    frinfo_(&drefid, &refctr, &cls, &clssid, &fnd);
		    spkezp_(&refctr, &et, "J2000", abcorr, &obscde, refpos, &
			    rlt, (ftnlen)5, (ftnlen)10);

/*                 We'll need the epoch DEPOCH associated */
/*                 with the center of DREF.  RLT is the */
/*                 light time from DREF's center to the observer. */

		    if (uselt) {
			if (xmit) {
			    depoch = et + rlt;
			} else {
			    depoch = et - rlt;
			}
		    } else {
			depoch = et;
		    }

/*                 Look up the transformation from frame DREF to J2000. */
/*                 We don't need this right away, but we'll have */
/*                 occasion to use it later. */

		    pxform_(dref, "J2000", &depoch, dj2m, (ftnlen)32, (ftnlen)
			    5);
		    s_copy(title, "Observer = #.  Geometry = #. ABCORR = #; "
			    "DREF = #.", (ftnlen)80, (ftnlen)50);
		    repmc_(title, "#", obsrvr, title, (ftnlen)80, (ftnlen)1, (
			    ftnlen)32, (ftnlen)80);
		    repmc_(title, "#", geom, title, (ftnlen)80, (ftnlen)1, (
			    ftnlen)80, (ftnlen)80);
		    repmc_(title, "#", abcorr, title, (ftnlen)80, (ftnlen)1, (
			    ftnlen)10, (ftnlen)80);
		    repmc_(title, "#", dref, title, (ftnlen)80, (ftnlen)1, (
			    ftnlen)32, (ftnlen)80);
		    tcase_(title, (ftnlen)80);
		    if (s_cmp(geom, "POINT_AT_CENTER", (ftnlen)80, (ftnlen)15)
			     == 0) {

/*                    Look up direction vector using current frame and */
/*                    aberration correction.  The direction vector is */
/*                    going to point to the target's center, so we */
/*                    should hit the target. */

			spkpos_(target, &et, dref, abcorr, obsrvr, dvec, &dlt,
				 (ftnlen)32, (ftnlen)32, (ftnlen)10, (ftnlen)
				32);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    } else if (s_cmp(geom, "MISS_BACKWARD", (ftnlen)80, (
			    ftnlen)13) == 0) {

/*                    Set the pointing direction to the inverse */
/*                    of that obtained in the 'POINT_AT_CENTER' */
/*                    case. */

			spkpos_(target, &et, dref, abcorr, obsrvr, negvec, &
				dlt, (ftnlen)32, (ftnlen)32, (ftnlen)10, (
				ftnlen)32);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			vminus_(negvec, dvec);
		    } else if (s_cmp(geom, "LIMB_INSIDE_NEAR", (ftnlen)80, (
			    ftnlen)16) == 0 || s_cmp(geom, "MISS_LIMB_NEAR", (
			    ftnlen)80, (ftnlen)14) == 0) {

/*                    Find the limb of the target based on */
/*                    the aberration-corrected target center position. */
/*                    Select ray to hit limb along major axis, slightly */
/*                    inside or slightly outside the ellipse, depending */
/*                    on the geometry case. */

/*                    Note we're looking up the target state in */
/*                    the target's body-fixed frame, not in the */
/*                    DREF frame. */

			spkpos_(target, &et, trgfrm, abcorr, obsrvr, negvec, &
				tlt, (ftnlen)32, (ftnlen)32, (ftnlen)10, (
				ftnlen)32);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
			vminus_(negvec, obsvec);

/*                    Get the limb's center and semi-axis vectors. */

			edlimb_(radii, &radii[1], &radii[2], obsvec, limb);
			el2cgv_(limb, lcentr, smajor, sminor);

/*                    To get an accurate limb, we'll find the light */
/*                    time from observer to tip of semi-major axis */
/*                    and get an improved light time estimate. */

			vadd_(lcentr, smajor, tipfx);
			if (uselt) {
			    if (xmit) {
				te = et + tlt;
			    } else {
				te = et - tlt;
			    }
			} else {
			    te = et;
			}

/*                    Get the "tip" in the J2000 frame at epoch TE. */

			pxform_("J2000", trgfrm, &te, tipm, (ftnlen)5, (
				ftnlen)32);
			mtxv_(tipm, tipfx, tipj2);

/*                    Get state of observer relative to SSB at */
/*                    ET and state of target relative to SSB at */
/*                    TE. */

			spkssb_(&obscde, &et, "J2000", ssbobs, (ftnlen)5);
			spkssb_(&trgcde, &te, "J2000", ssbtrg, (ftnlen)5);

/*                    Get the position of the tip.  Compute a */
/*                    new light time value and target epoch. */

			vadd_(ssbtrg, tipj2, tgt);
			tlt = vdist_(ssbobs, tgt) / clight_();
			if (uselt) {
			    if (xmit) {
				te = et + tlt;
			    } else {
				te = et - tlt;
			    }
			} else {
			    te = et;
			}

/*                    Re-compute TIPM. */

			pxform_("J2000", trgfrm, &te, tipm, (ftnlen)5, (
				ftnlen)32);

/*                    Get the observer position in the target body-fixed */
/*                    frame at TE. */

			vsub_(ssbobs, ssbtrg, obsj2);
			mxv_(tipm, obsj2, obsvec);

/*                    Get the limb's center and semi-axis vectors. */

			edlimb_(radii, &radii[1], &radii[2], obsvec, limb);
			el2cgv_(limb, lcentr, smajor, sminor);

/*                    Pick our target point near the limb.  The */
/*                    point is 1+/- DELTA of the semi-major axis length */
/*                    out from the center, along one of the semi- */
/*                    major axes. */

			delta = .001;
			if (s_cmp(geom, "MISS", (ftnlen)4, (ftnlen)4) == 0) {
			    frac = delta + 1.;
			} else {
			    frac = 1. - delta;
			}
			vlcom_(&c_b96, lcentr, &frac, smajor, tgt);

/*                    Our ray extends from the observer to the target */
/*                    point. */

			vsub_(tgt, obsvec, dvecfx);
			sep = vsep_(negvec, dvecfx);

/*                    Convert the ray from the target body fixed */
/*                    frame to J2000, then from J2000 to the DREF */
/*                    frame.  We need the target frame epoch TE */
/*                    to find the first transformation matrix TIPM. */

			if (uselt) {
			    if (xmit) {
				te = et + tlt;
			    } else {
				te = et - tlt;
			    }
			} else {
			    te = et;
			}
			pxform_("J2000", trgfrm, &te, tipm, (ftnlen)5, (
				ftnlen)32);
			mtxv_(tipm, dvecfx, dvecj2);

/*                    If we're using stellar aberration correction, */
/*                    apply the correction to our ray direction. */

			if (usestl) {
			    if (xmit) {
				stlabx_(dvecj2, &ssbobs[3], dvecst);
			    } else {
				stelab_(dvecj2, &ssbobs[3], dvecst);
			    }
			    vequ_(dvecst, dvecj2);
			}

/*                    The matrix DJ2M maps from DREF to J2000, so */
/*                    apply the transpose of this matrix to obtain */
/*                    DVEC. */

			mtxv_(dj2m, dvecj2, dvec);
		    } else {

/*                    Oops!  Name mismatch. */

			sigerr_("SPICE(BUG)", (ftnlen)10);
			chckxc_(&c_false, " ", ok, (ftnlen)1);
		    }

/*                 Find the surface intercept point. */

		    srfxpt_("Ellipsoid", target, &et, abcorr, obsrvr, dref, 
			    dvec, spoint, &dist, &trgepc, obspos, &found, (
			    ftnlen)9, (ftnlen)32, (ftnlen)10, (ftnlen)32, (
			    ftnlen)32);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Check the results. */

		    if (! found) {
			if (s_cmp(geom, "MISS", (ftnlen)4, (ftnlen)4) == 0) {

/*                       FOUND should be .FALSE.; the other outputs */
/*                       are undefined. */

			    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
			} else {

/*                       We're supposed to have an intercept. */

			    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
			}
		    } else {

/*                    FOUND is true. */

/*                    Form the vector from the observer to the target */
/*                    intercept. */

			vsub_(spoint, obspos, spvec);

/*                    The length of SPVEC had better be DIST. */

			d__1 = vnorm_(spvec);
			chcksd_("DIST", &dist, "~", &d__1, &c_b111, ok, (
				ftnlen)4, (ftnlen)1);

/*                    The target epoch had better be consistent with */
/*                    DIST and ABCORR. */

			xlt = dist / clight_();
			if (uselt) {
			    if (xmit) {
				xepoch = et + xlt;
			    } else {
				xepoch = et - xlt;
			    }
			} else {
			    xepoch = et;
			}

/*                    This is a relative error check. */

			if (usecn) {
			    etol = 1e-12;
			} else {
			    etol = 1e-8;
			}
			chcksd_("TRGEPC", &trgepc, "~/", &xepoch, &etol, ok, (
				ftnlen)6, (ftnlen)2);

/*                    Get the transformation from the target frame */
/*                    to J2000. */

			pxform_(trgfrm, "J2000", &trgepc, trgj2m, (ftnlen)32, 
				(ftnlen)5);

/*                    Now transform DVEC to the J2000 frame. */

			mxv_(dj2m, dvec, dj2);

/*                    The following check applies only to the case in */
/*                    which the pointing direction is toward the */
/*                    target's center. */

			if (s_cmp(geom, "POINT_AT_CENTER", (ftnlen)80, (
				ftnlen)15) == 0) {

/*                       The angular separation of -OBSPOS and DVEC */
/*                       should be pretty small when these vectors are */
/*                       compared in compatible reference frames.  We */
/*                       don't expect these vectors to be identical */
/*                       (even theoretically) because they've been */
/*                       computed with different target epochs. */
/*                       Furthermore, if stellar aberration correction */
/*                       is used, DVEC will be corrected for stellar */
/*                       aberration but OBSPOS will not, leading to even */
/*                       greater disparity. */

/*                       First step:  get -OBSPOS in the J2000 frame. */

			    vminus_(obspos, negvec);
			    mxv_(trgj2m, negvec, negj2);

/*                       Find the angular separation and make sure it's */
/*                       not too large. */

			    sep = vsep_(negj2, dj2);
			    chcksd_("DJ2 vs NEG2 SEP", &sep, "~", &c_b118, &
				    c_b119, ok, (ftnlen)15, (ftnlen)1);
			}

/*                    End of sanity check test for the POINT_AT_CENTER */
/*                    case. */

/*                    Having made it this far, we're ready for some more */
/*                    rigorous tests.  In particular, we're going treat */
/*                    SPOINT as an ephemeris object and find its */
/*                    aberration-corrected position relative to the */
/*                    observer in J2000 coordinates. This computation */
/*                    will allow us to derive expected values of TRGEPC, */
/*                    OBSPOS, the transformation from the J2000 frame to */
/*                    the target body-fixed frame at TRGEPC.  We will */
/*                    verify that the aberration-corrected location */
/*                    of SPOINT, lies on the ray DVEC:  this is the */
/*                    the criterion we used to define SPOINT. */

/*                    These tests make sense only when aberration */
/*                    corrections are used. */

			if (uselt) {

/*                       We're expecting to get good agreement between */
/*                       all of these items and their counterparts */
/*                       obtained from SRFXPT, especially when use use */
/*                       converged Newtonian corrections. */

			    if (eqstr_(obsrvr, "EARTH", (ftnlen)32, (ftnlen)5)
				    ) {
				if (usecn) {
				    tol = 1e-12;
				} else {
				    tol = 1e-8;
				}
			    } else {

/*                          Use looser tolerances for the Mars */
/*                          orbiter.  For the orbiter, small errors */
/*                          in SPOINT lead to larger relative errors */
/*                          in DIST and SEP. */

				if (usecn) {
				    tol = 1e-10;
				} else {
				    tol = 1e-5;
				}
			    }

/*                       Find the aberration-corrected location of */
/*                       SPOINT. */

/*                       We need the J2000 state of the observer relative */
/*                       to the solar system barycenter at ET. */

			    spkssb_(&obscde, &et, "J2000", ssbobs, (ftnlen)5);
			    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                       The SPOINT re-computation is done iteratively. */
/*                       Since we're starting with a geometric target */
/*                       position, the light time value obtained from */
/*                       the normal light time correction corresponds to */
/*                       the light time found on the *second* iteration. */
/*                       We increment our iteration counts by 1 for both */
/*                       the normal and CN cases. */

			    if (usecn) {
				nitr = 5;
			    } else {
				nitr = 2;
			    }

/*                       The initial target position relative to the */
/*                       solar system barycenter is found by summing the */
/*                       target center position relative to the solar */
/*                       system barycenter at ET with SPOINT, after */
/*                       SPOINT has been converted to the J2000 frame at */
/*                       ET. */

			    spkssb_(&trgcde, &et, "J2000", ssbtrg, (ftnlen)5);
			    chckxc_(&c_false, " ", ok, (ftnlen)1);
			    pxform_("J2000", trgfrm, &et, tipm, (ftnlen)5, (
				    ftnlen)32);
			    chckxc_(&c_false, " ", ok, (ftnlen)1);
			    mtxv_(tipm, spoint, spj2);
			    vadd_(ssbtrg, spj2, sppos);
			    i__1 = nitr;
			    for (i__ = 1; i__ <= i__1; ++i__) {

/*                          Make a new estimate of the target epoch XTE. */

				lt = vdist_(ssbobs, sppos) / clight_();
				if (xmit) {
				    xte = et + lt;
				} else {
				    xte = et - lt;
				}

/*                          Compute the J2000 state of SPOINT relative */
/*                          to the solar system barycenter at XTE. */

				spkssb_(&trgcde, &xte, "J2000", ssbtrg, (
					ftnlen)5);
				chckxc_(&c_false, " ", ok, (ftnlen)1);
				pxform_("J2000", trgfrm, &xte, tipm, (ftnlen)
					5, (ftnlen)32);
				chckxc_(&c_false, " ", ok, (ftnlen)1);
				chckxc_(&c_false, " ", ok, (ftnlen)1);
				mtxv_(tipm, spoint, spj2);
				vadd_(ssbtrg, spj2, sppos);
			    }

/*                       Compute the light-time corrected position of */
/*                       SPOINT as seen by the observer. */

			    vsub_(sppos, ssbobs, splt);

/*                       Correct SPLT for stellar aberration, if ABCORR */
/*                       so indicates. */

			    if (usestl) {
				if (xmit) {
				    stlabx_(splt, &ssbobs[3], xray);
				} else {
				    stelab_(splt, &ssbobs[3], xray);
				}
			    } else {

/*                          XRAY is our expected result. */

				vequ_(splt, xray);
			    }

/*                       Moment of truth:  XRAY is the J2000 vector from */
/*                       the observer to the aberration-corrected */
/*                       position of our "ephemeris object" located on */
/*                       the target surface at location SPOINT.  If */
/*                       SPOINT were correct in the first place, then */
/*                       XRAY should be lined up with our boresight */
/*                       direction DVEC, when DVEC is rotated to the */
/*                       J2000 frame. */

/*                       Actually, we computed DVEC in the J2000 frame */
/*                       long ago:  this vector is called DJ2. */

			    chcksd_("TRGEPC vs XTE", &trgepc, "~/", &xte, &
				    tol, ok, (ftnlen)13, (ftnlen)2);
			    sep = vsep_(dj2, xray);
			    chcksd_("XRAY vs DJ2 sep", &sep, "~", &c_b118, &
				    tol, ok, (ftnlen)15, (ftnlen)1);

/*                       Check DIST against its predicted value. */

			    d__1 = vnorm_(xray);
			    chcksd_("DIST", &dist, "~/", &d__1, &tol, ok, (
				    ftnlen)4, (ftnlen)2);

/*                       Create a predicted value for OBSPOS:  the */
/*                       difference of SSBOBS and SSBTRG from our last */
/*                       loop iteration gives us OBSPOS in the J2000 */
/*                       frame.  Use XTE to get the transformation to */
/*                       target body-fixed coordinates at epoch XTE. */

			    vsub_(ssbobs, ssbtrg, j2obs);
			    pxform_("J2000", trgfrm, &xte, xform, (ftnlen)5, (
				    ftnlen)32);
			    mxv_(xform, j2obs, xobsps);
			    chckad_("OBSPOS", obspos, "~/", xobsps, &c__3, &
				    tol, ok, (ftnlen)6, (ftnlen)2);

/*                       The following test only makes sense */
/*                       when stellar aberration is not used. */
/*                       (When stellar aberration IS used, SPOINT */
/*                       does not lie on the ray; the image of */
/*                       SPOINT under the stellar aberration correction */
/*                       lies on the ray. */

			    if (! usestl) {

/*                          Create a predicted value for SPOINT:  convert */
/*                          XRAY to target body-fixed coordinates at */
/*                          epoch XTE and add to XOBSPS to form XSPNT. */

				mxv_(xform, xray, xrtrg);
				vadd_(xrtrg, xobsps, xspnt);
				chckad_("SPOINT", spoint, "~/", xspnt, &c__3, 
					&c_b152, ok, (ftnlen)6, (ftnlen)2);
			    }
			}

/*                    We're finished with the consistency checks for */
/*                    the aberration correction cases. */

		    }

/*                 End of the checks for the intercept cases. */

		}

/*              End of the aberration correction loop. */

	    }

/*           End of the reference frame loop. */

	}

/*        End of the geometry case loop. */

    }

/*     End of the observer loop. */


/*     Input handling tests:  make sure target and observer */
/*     can be identified using integer "names." */

    tcase_("Use integer observer and target names.", (ftnlen)38);

/*     Set up the ray first. */

    spkpos_("499", &et, dref, abcorr, "399", dvec, &dlt, (ftnlen)3, (ftnlen)
	    32, (ftnlen)10, (ftnlen)3);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    srfxpt_("Ellipsoid", "MARS", &et, abcorr, "Earth", dref, dvec, xspnt, &
	    xdist, &xepoch, xobsps, &found, (ftnlen)9, (ftnlen)4, (ftnlen)10, 
	    (ftnlen)5, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    srfxpt_("Ellipsoid", "499", &et, abcorr, "399", dref, dvec, spoint, &dist,
	     &trgepc, obspos, &found, (ftnlen)9, (ftnlen)3, (ftnlen)10, (
	    ftnlen)3, (ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chckad_("SPOINT", spoint, "=", xspnt, &c__3, &c_b118, ok, (ftnlen)6, (
	    ftnlen)1);
    chckad_("OBSPOS", obspos, "=", xobsps, &c__3, &c_b118, ok, (ftnlen)6, (
	    ftnlen)1);
    chcksd_("TRGEPC", &trgepc, "=", &xepoch, &c_b118, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksd_("DIST", &dist, "=", &dist, &c_b118, ok, (ftnlen)4, (ftnlen)1);

/*     Error handling tests follow. */

    tcase_("Target name not translated", (ftnlen)26);

/*     Find the surface intercept point. */

    srfxpt_("Ellipsoid", "xyz", &et, abcorr, obsrvr, dref, dvec, spoint, &
	    dist, &trgepc, obspos, &found, (ftnlen)9, (ftnlen)3, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);
    tcase_("Observer name not translated", (ftnlen)28);

/*     Find the surface intercept point. */

    srfxpt_("Ellipsoid", target, &et, abcorr, "xyz", dref, dvec, spoint, &
	    dist, &trgepc, obspos, &found, (ftnlen)9, (ftnlen)32, (ftnlen)10, 
	    (ftnlen)3, (ftnlen)32);
    chckxc_(&c_true, "SPICE(IDCODENOTFOUND)", ok, (ftnlen)21);
    tcase_("Observer coincides with target", (ftnlen)30);

/*     Find the surface intercept point. */

    srfxpt_("Ellipsoid", target, &et, abcorr, target, dref, dvec, spoint, &
	    dist, &trgepc, obspos, &found, (ftnlen)9, (ftnlen)32, (ftnlen)10, 
	    (ftnlen)32, (ftnlen)32);
    chckxc_(&c_true, "SPICE(BODIESNOTDISTINCT)", ok, (ftnlen)24);
    tcase_("Unsupported computation method", (ftnlen)30);

/*     Find the surface intercept point. */

    srfxpt_("xyz", target, &et, abcorr, obsrvr, dref, dvec, spoint, &dist, &
	    trgepc, obspos, &found, (ftnlen)3, (ftnlen)32, (ftnlen)10, (
	    ftnlen)32, (ftnlen)32);
    chckxc_(&c_true, "SPICE(INVALIDMETHOD)", ok, (ftnlen)20);
    tcase_("No body-fixed frame associated with target", (ftnlen)42);

/*     Find the surface intercept point. */

    srfxpt_("Ellipsoid", "Mars_orbiter", &et, abcorr, "EARTH", dref, dvec, 
	    spoint, &dist, &trgepc, obspos, &found, (ftnlen)9, (ftnlen)12, (
	    ftnlen)10, (ftnlen)5, (ftnlen)32);
    chckxc_(&c_true, "SPICE(NOFRAME)", ok, (ftnlen)14);
    tcase_("Frame name maps to code but FRINFO can't find frame info.", (
	    ftnlen)57);

/*     Find the surface intercept point.  Use reference frame 'BAD' */
/*     for direction vector. */

    srfxpt_("Ellipsoid", "Mars_orbiter", &et, abcorr, "EARTH", "BAD", dvec, 
	    spoint, &dist, &trgepc, obspos, &found, (ftnlen)9, (ftnlen)12, (
	    ftnlen)10, (ftnlen)5, (ftnlen)3);
    chckxc_(&c_true, "SPICE(NOFRAME)", ok, (ftnlen)14);

/*     Clean up. */

    spkuef_(handle);
    delfil_("srfxpt_spk.bsp", (ftnlen)14);
    spkuef_(&handle[1]);
    delfil_("orbiter.bsp", (ftnlen)11);
    t_success__(ok);
    return 0;
} /* f_srfxpt__ */

