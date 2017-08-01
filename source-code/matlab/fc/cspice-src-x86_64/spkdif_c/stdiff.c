/* stdiff.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__14 = 14;
static integer c__6 = 6;
static integer c__1 = 1;
static integer c__3 = 3;
static integer c__2 = 2;

/* $Procedure      STDIFF ( State differences ) */
/* Subroutine */ int stdiff_(doublereal *sta, doublereal *stb, integer *nitr, 
	doublereal *times, char *diftyp, char *timfmt, ftnlen diftyp_len, 
	ftnlen timfmt_len)
{
    /* System generated locals */
    address a__1[2];
    integer i__1, i__2, i__3, i__4, i__5, i__6[2];
    doublereal d__1;
    char ch__1[62], ch__2[127];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), s_rnge(char *, integer, 
	    char *, integer);
    double sqrt(doublereal);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);

    /* Local variables */
    static doublereal diff[6], avdt, avve[3], axis[9]	/* was [3][3] */, 
	    avpo[3];
    extern doublereal vrel_(doublereal *, doublereal *), vdot_(doublereal *, 
	    doublereal *);
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    static doublereal sump[3], sumv[3];
    static integer i__, j;
    extern /* Subroutine */ int etcal_(doublereal *, char *, ftnlen);
    static doublereal delta;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    static doublereal avadt, avvea[3], avpoa[3];
    extern doublereal dpmin_(void);
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    static doublereal avvel;
    static char outch[32*4];
    static doublereal avsdt, sumpa[3];
    extern /* Subroutine */ int vsubg_(doublereal *, doublereal *, integer *, 
	    doublereal *);
    static doublereal avpos, sumva[3], sumdt;
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int dpstr_(doublereal *, integer *, char *, 
	    ftnlen), ucrss_(doublereal *, doublereal *, doublereal *);
    extern doublereal vnorm_(doublereal *);
    extern /* Subroutine */ int vcrss_(doublereal *, doublereal *, doublereal 
	    *);
    static doublereal sumps[3], sumvs[3], veldif[3], velmag, mxaadt, posdif[3]
	    , velcmp[3], posmag, velrel, maxpmg, mxavel[3];
    static char dmpstr[1024];
    static doublereal poscmp[3];
    extern logical return_(void);
    static char velstr[80], swdstr[16], hlpstr[80];
    static doublereal mxapos[3];
    static char posstr[80];
    static doublereal mxrpos[3], mxrvel[3], avposq[3], avvesq[3], vcross[3], 
	    tmpvec[3], possum, velsum, sumadt, sumsdt, posrel, relpsm, relvsm,
	     maxvmg, maxprl, maxvrl, mxradt, avrelp, avrelv, mxatim, mxrtim;
    static logical mxatru, mxrtru, nonzer;
    extern /* Subroutine */ int tostdo_(char *, ftnlen), timout_(doublereal *,
	     char *, char *, ftnlen, ftnlen), chkout_(char *, ftnlen), 
	    twovec_(doublereal *, integer *, doublereal *, integer *, 
	    doublereal *), dpstrf_(doublereal *, integer *, char *, char *, 
	    ftnlen, ftnlen), mxv_(doublereal *, doublereal *, doublereal *);

/* $ Abstract */

/*     Computes the differences between the state vectors in STA and */
/*     those in STB and writes summary of requested type to the screen. */

/* $ Required_Reading */

/*     None. */

/* $ Keywords */

/*     EPHEMERIS */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     STA        I   Array of state vectors. */

/*     STB        I   Another array of state vectors that represent */
/*                    the same states as those in STA but generated */
/*                    in a different way. */

/*     NITR       I   The number of states in STA or STB. */

/*     TIMES      I   Epochs of the states. */

/*     DIFTYP     I   Type of report to produce. */

/*     TIMFMT     I   Output time format. */

/* $ Detailed_Input */

/*     STA, */
/*     STB         are arrays of state vectors.  A state vector is a six */
/*                 element array that describes the position and */
/*                 velocity of one body with respect to another at a */
/*                 particular time.  The first three elements are the X, */
/*                 Y, and Z coordinates of the position, and the last */
/*                 three elements are the coordinates of the velocity. */

/*                 The states in STA and STB should be for the same */
/*                 body, with respect to the same center, in the same */
/*                 reference frame, and associated with the same epochs. */
/*                 They differ only in that they come from different */
/*                 sources. */

/*     NITR        The number of states in STA or STB. */

/*     TIMES       is an array of epochs for which the states in STA and */
/*                 STB are valid. */

/*     DIFTYP      is the string indicating what type of report is to be */
/*                 displayed. It can have value 'basic', 'stats', */
/*                 'dump', or 'dumpvf'. */

/*                 If DIFTYP is 'basic' then only relative differences */
/*                 in state vectors and magnitude of state difference */
/*                 vectors will be displayed. */

/*                 If DIFTYP is 'stats' then average components of */
/*                 position difference vectors in view frame */
/*                 coordinates, average |components| of position */
/*                 difference vectors in view frame coordinates, */
/*                 Components of the position difference vector (in view */
/*                 frame coordinates) for the states with the MAXIMUM */
/*                 RELATIVE difference in position, and RMS of position */
/*                 difference vectors in view frame coordinates will be */
/*                 displayed. */

/*                 If DIFTYP is 'dump' then a simple table of */
/*                 differences between input state vectors will be */
/*                 displayed. */

/*                 If DIFTYP is 'dumpvf' then a table of differences */
/*                 between input state vectors rotated into into the */
/*                 view frame based on states from STA will be */
/*                 displayed. */

/*     TIMFMT      is the output format for the time tags in the */
/*                 difference table generated for DIFTYP = 'dump'. */
/*                 If it is blank, then times are printed as ET seconds */
/*                 past J2000. If it is non blank, it is passed directly */
/*                 into the TIMOUT. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     See include file. */

/* $ Exceptions */

/*     None. */

/* $ Files */

/*     None. */

/* $ Particulars */

/*     STA and STB are arrays of NITR states of some body with respect */
/*     to some center at epochs given by the array TIMES. This routine */
/*     compares the states given by the two arrays and then print to the */
/*     screen the statistics generated by the comparison tests. */

/*     The following comparison tests are performed on the states from */
/*     the two arrays: */

/*     1) The average, absolute average, RMS and maximum relative */
/*        differences in the position and velocity vectors. */

/*     2) The average, absolute average, RMS and maximum magnitudes */
/*        of the position and velocity difference vectors. */

/*     3) The average, absolute average, RMS and maximum components */
/*        of the position difference vectors are calculated in "view */
/*        frame" coordinates. The output listing includes: */

/*           a) The components in view frame coordinates. */

/*           b) The absolute value of these components. */

/*           c) The components for the difference vector associated with */
/*              the states that had the largest relative difference in */
/*              position. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     B.V. Semenov   (JPL) */

/* $ Version */

/* -    Version 1.0.0, 10-NOV-2006 (BVS) */

/*        Initial version, heavily based on CMPSPK's STDIFF. */

/* -& */

/*     SPICELIB functions */

/* $ Abstract */

/*     Include Section:  SPKDIFF Global Parameters */

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

/* $ Author_and_Institution */

/*     B.V. Semenov   (JPL) */

/* $ Version */

/* -    Version 1.0.0, 20-JUL-2006 (BVS). */

/* -& */

/*     Program name and version. */


/*     Command line keys. */


/*     Max and min number states that the program can handle. */


/*     Default number states. */


/*     Line size parameters. */


/*     Version/usage display parameters. */


/*     Maximum segment buffer size for Nat's ZZGEOSEG. */


/*     DAF descriptor size and component counts. */


/*     Cell lower boundary. */


/*     Maximum allowed number of coverage windows. */


/*     Smallest allowed step. */


/*     Local variables */


/*     Save everything to prevent potential memory problems in f2c'ed */
/*     version. */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("STDIFF", (ftnlen)6);
    }

/*     If requested, dump differences and return. */

    if (eqstr_(diftyp, "dump", diftyp_len, (ftnlen)4)) {
	s_copy(dmpstr, "# time, (x1-x2), (y1-y2), (z1-z2), (vx1-vx2), (vy1-v"
		"y2), (vz1-vz2)", (ftnlen)1024, (ftnlen)66);
	tostdo_(dmpstr, (ftnlen)1024);
	i__1 = *nitr;
	for (j = 1; j <= i__1; ++j) {
	    s_copy(dmpstr, "# # # # # # #", (ftnlen)1024, (ftnlen)13);
	    if (s_cmp(timfmt, " ", timfmt_len, (ftnlen)1) == 0) {
		dpstr_(&times[j - 1], &c__14, hlpstr, (ftnlen)80);
	    } else {
		timout_(&times[j - 1], timfmt, hlpstr, timfmt_len, (ftnlen)80)
			;
	    }
	    repmc_(dmpstr, "#", hlpstr, dmpstr, (ftnlen)1024, (ftnlen)1, (
		    ftnlen)80, (ftnlen)1024);
	    for (i__ = 1; i__ <= 6; ++i__) {
		d__1 = sta[i__ + j * 6 - 7] - stb[i__ + j * 6 - 7];
		dpstr_(&d__1, &c__14, hlpstr, (ftnlen)80);
		if (*(unsigned char *)hlpstr == ' ') {
		    *(unsigned char *)hlpstr = '+';
		}
		repmc_(dmpstr, "#", hlpstr, dmpstr, (ftnlen)1024, (ftnlen)1, (
			ftnlen)80, (ftnlen)1024);
	    }
	    tostdo_(dmpstr, (ftnlen)1024);
	}
	chkout_("STDIFF", (ftnlen)6);
	return 0;
    }

/*     If requested, dump differences in view frame and return. */

    if (eqstr_(diftyp, "dumpvf", diftyp_len, (ftnlen)6)) {

/*        Before doing this dump we need to verify that we can construct */
/*        view frame for every state is STA. */

	nonzer = TRUE_;
	i__1 = *nitr;
	for (j = 1; j <= i__1; ++j) {
	    ucrss_(&sta[j * 6 - 3], &sta[j * 6 - 6], vcross);
	    if (vnorm_(vcross) == 0.) {
		nonzer = FALSE_;
	    }
	}
	if (! nonzer) {
	    tostdo_(" ", (ftnlen)1);
	    tostdo_("No view frame difference table can be generated because"
		    " in one or more cases  ", (ftnlen)78);
	    tostdo_("the state computed from the first SPK has linearly depe"
		    "ndent position and", (ftnlen)73);
	    tostdo_("velocity, which makes constructing the view frame impos"
		    "sible.", (ftnlen)61);
	    tostdo_(" ", (ftnlen)1);
	    chkout_("STDIFF", (ftnlen)6);
	    return 0;
	}

/*        There are no states with linearly dependent position and */
/*        velocity in STA. We can proceed with dumping differences in */
/*        the view frame. */

	s_copy(dmpstr, "# time, down_track_p_diff, normal_to_plane_p_diff, i"
		"n_plane_p_diff, down_track_v_diff, normal_to_plane_v_diff, i"
		"n_plane_v_diff", (ftnlen)1024, (ftnlen)126);
	tostdo_(dmpstr, (ftnlen)1024);
	i__1 = *nitr;
	for (j = 1; j <= i__1; ++j) {

/*           Find the difference vector between the two states (STA-STB). */

	    vsubg_(&sta[j * 6 - 6], &stb[j * 6 - 6], &c__6, diff);

/*           Construct view frame based on the current STA: */

/*             AXIS(1): is parallel to the direction of motion given by */
/*                      STA */

/*             AXIS(2): is normal to the orbit plane defined by STA */

/*             AXIS(3): is AXIS(1) X AXIS(2) */

	    twovec_(&sta[j * 6 - 3], &c__1, &sta[j * 6 - 6], &c__3, axis);

/*           Rotate difference in position and velocity into view frame. */

	    mxv_(axis, diff, tmpvec);
	    vequ_(tmpvec, diff);
	    mxv_(axis, &diff[3], tmpvec);
	    vequ_(tmpvec, &diff[3]);

/*           Format everything for output. */

	    s_copy(dmpstr, "# # # # # # #", (ftnlen)1024, (ftnlen)13);
	    if (s_cmp(timfmt, " ", timfmt_len, (ftnlen)1) == 0) {
		dpstr_(&times[j - 1], &c__14, hlpstr, (ftnlen)80);
	    } else {
		timout_(&times[j - 1], timfmt, hlpstr, timfmt_len, (ftnlen)80)
			;
	    }
	    repmc_(dmpstr, "#", hlpstr, dmpstr, (ftnlen)1024, (ftnlen)1, (
		    ftnlen)80, (ftnlen)1024);
	    for (i__ = 1; i__ <= 6; ++i__) {
		dpstr_(&diff[(i__2 = i__ - 1) < 6 && 0 <= i__2 ? i__2 : 
			s_rnge("diff", i__2, "stdiff_", (ftnlen)394)], &c__14,
			 hlpstr, (ftnlen)80);
		if (*(unsigned char *)hlpstr == ' ') {
		    *(unsigned char *)hlpstr = '+';
		}
		repmc_(dmpstr, "#", hlpstr, dmpstr, (ftnlen)1024, (ftnlen)1, (
			ftnlen)80, (ftnlen)1024);
	    }
	    tostdo_(dmpstr, (ftnlen)1024);
	}
	chkout_("STDIFF", (ftnlen)6);
	return 0;
    }

/*     Initial values. */

    for (i__ = 1; i__ <= 3; ++i__) {
	sump[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sump", i__1, 
		"stdiff_", (ftnlen)417)] = 0.;
	sumv[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sumv", i__1, 
		"stdiff_", (ftnlen)418)] = 0.;
	sumpa[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sumpa", i__1,
		 "stdiff_", (ftnlen)419)] = 0.;
	sumva[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sumva", i__1,
		 "stdiff_", (ftnlen)420)] = 0.;
	sumps[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sumps", i__1,
		 "stdiff_", (ftnlen)421)] = 0.;
	sumvs[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("sumvs", i__1,
		 "stdiff_", (ftnlen)422)] = 0.;
	mxapos[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("mxapos", 
		i__1, "stdiff_", (ftnlen)423)] = 0.;
	mxavel[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("mxavel", 
		i__1, "stdiff_", (ftnlen)424)] = 0.;
	mxrpos[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("mxrpos", 
		i__1, "stdiff_", (ftnlen)425)] = 0.;
	mxrvel[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("mxrvel", 
		i__1, "stdiff_", (ftnlen)426)] = 0.;
    }
    sumdt = 0.;
    sumadt = 0.;
    sumsdt = 0.;
    possum = 0.;
    velsum = 0.;
    relpsm = 0.;
    relvsm = 0.;
    maxpmg = dpmin_();
    maxvmg = dpmin_();
    maxprl = dpmin_();
    maxvrl = dpmin_();
    mxaadt = 0.;
    mxradt = 0.;
    nonzer = TRUE_;

/*     After subtracting the state vectors for the Jth time, first */
/*     compare the individual components of the difference vector and */
/*     then perform the tests on the vector itself. */

    i__1 = *nitr;
    for (j = 1; j <= i__1; ++j) {

/*        Find the difference vector between the two states (STA-STB). */

	vsubg_(&sta[j * 6 - 6], &stb[j * 6 - 6], &c__6, diff);

/*        Now perform tests on the actual difference vectors. */

	vequ_(diff, posdif);
	vequ_(&diff[3], veldif);

/*        Find the magnitudes and relative error of the position and */
/*        velocity difference vectors. */

	posmag = vnorm_(posdif);
	velmag = vnorm_(veldif);
	posrel = vrel_(&sta[j * 6 - 6], &stb[j * 6 - 6]);
	velrel = vrel_(&sta[j * 6 - 3], &stb[j * 6 - 3]);
	possum += posmag;
	velsum += velmag;
	relpsm += posrel;
	relvsm += velrel;
	mxatru = FALSE_;
	mxrtru = FALSE_;
	if (posmag > maxpmg) {

/*           We are going to return information on the case with the */
/*           largest absolute difference in position. */

	    mxatru = TRUE_;
	    maxpmg = posmag;
	}
	if (velmag > maxvmg) {
	    maxvmg = velmag;
	}
	if (posrel > maxprl) {

/*           We are going to return information on the case with the */
/*           largest relative difference in position. */

	    mxrtru = TRUE_;
	    maxprl = posrel;
	}
	if (velrel > maxvrl) {
	    maxvrl = velrel;
	}

/*        Compute the components of the position and velocity difference */
/*        vectors in view frame coordinates. */

/*           AXIS(1): is parallel to the direction of motion given by */
/*                    STA */

/*           AXIS(2): is normal to the orbit plane defined by STA */

/*           AXIS(3): is AXIS(1) X AXIS(2) */

/*        We could have called TWOVEC like this: */

/*           CALL TWOVEC( STA(4,J), 1, STA(1,J), 3, AXIS ) */

/*        to build this frame but it signals an error if input vectors */
/*        are linearly dependent and we don't want this to happen. So we */
/*        build this matrix by hand. */

	vequ_(&sta[j * 6 - 3], axis);
	vcrss_(&sta[j * 6 - 6], axis, &axis[3]);
	vcrss_(axis, &axis[3], &axis[6]);

/*        Can't do the tests if any of the axis are zero. */

	if (vnorm_(axis) == 0. || vnorm_(&axis[3]) == 0. || vnorm_(&axis[6]) 
		== 0.) {
	    nonzer = FALSE_;
	}
	if (nonzer) {

/*           Find the components of the difference vector w/r to view */
/*           frame axes. If our AXIS matrix was a rotation matrix, we */
/*           could have called MXV to do this, but since it is not we */
/*           will multiply vector by hand. */

	    for (i__ = 1; i__ <= 3; ++i__) {
		poscmp[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			"poscmp", i__2, "stdiff_", (ftnlen)559)] = vdot_(
			posdif, &axis[(i__3 = i__ * 3 - 3) < 9 && 0 <= i__3 ? 
			i__3 : s_rnge("axis", i__3, "stdiff_", (ftnlen)559)]) 
			/ vnorm_(&axis[(i__4 = i__ * 3 - 3) < 9 && 0 <= i__4 ?
			 i__4 : s_rnge("axis", i__4, "stdiff_", (ftnlen)559)])
			;
		velcmp[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			"velcmp", i__2, "stdiff_", (ftnlen)561)] = vdot_(
			veldif, &axis[(i__3 = i__ * 3 - 3) < 9 && 0 <= i__3 ? 
			i__3 : s_rnge("axis", i__3, "stdiff_", (ftnlen)561)]) 
			/ vnorm_(&axis[(i__4 = i__ * 3 - 3) < 9 && 0 <= i__4 ?
			 i__4 : s_rnge("axis", i__4, "stdiff_", (ftnlen)561)])
			;
	    }

/*           Divide the downtrack difference in the position by the */
/*           speed to give the error in time along the flight path. */

	    delta = poscmp[0] / vnorm_(axis);

/*           Keep track of the differences. */

	    sumdt += delta;
	    sumadt += abs(delta);
	    sumsdt += delta * delta;
	    for (i__ = 1; i__ <= 3; ++i__) {
		sump[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sump",
			 i__2, "stdiff_", (ftnlen)582)] = sump[(i__3 = i__ - 
			1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sump", i__3, 
			"stdiff_", (ftnlen)582)] + poscmp[(i__4 = i__ - 1) < 
			3 && 0 <= i__4 ? i__4 : s_rnge("poscmp", i__4, "stdi"
			"ff_", (ftnlen)582)];
		sumv[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sumv",
			 i__2, "stdiff_", (ftnlen)584)] = sumv[(i__3 = i__ - 
			1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sumv", i__3, 
			"stdiff_", (ftnlen)584)] + velcmp[(i__4 = i__ - 1) < 
			3 && 0 <= i__4 ? i__4 : s_rnge("velcmp", i__4, "stdi"
			"ff_", (ftnlen)584)];
		sumpa[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sum"
			"pa", i__2, "stdiff_", (ftnlen)586)] = sumpa[(i__3 = 
			i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sumpa", 
			i__3, "stdiff_", (ftnlen)586)] + (d__1 = poscmp[(i__4 
			= i__ - 1) < 3 && 0 <= i__4 ? i__4 : s_rnge("poscmp", 
			i__4, "stdiff_", (ftnlen)586)], abs(d__1));
		sumva[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sum"
			"va", i__2, "stdiff_", (ftnlen)588)] = sumva[(i__3 = 
			i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sumva", 
			i__3, "stdiff_", (ftnlen)588)] + (d__1 = velcmp[(i__4 
			= i__ - 1) < 3 && 0 <= i__4 ? i__4 : s_rnge("velcmp", 
			i__4, "stdiff_", (ftnlen)588)], abs(d__1));
		sumps[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sum"
			"ps", i__2, "stdiff_", (ftnlen)590)] = sumps[(i__3 = 
			i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sumps", 
			i__3, "stdiff_", (ftnlen)590)] + poscmp[(i__4 = i__ - 
			1) < 3 && 0 <= i__4 ? i__4 : s_rnge("poscmp", i__4, 
			"stdiff_", (ftnlen)590)] * poscmp[(i__5 = i__ - 1) < 
			3 && 0 <= i__5 ? i__5 : s_rnge("poscmp", i__5, "stdi"
			"ff_", (ftnlen)590)];
		sumvs[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sum"
			"vs", i__2, "stdiff_", (ftnlen)592)] = sumvs[(i__3 = 
			i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge("sumvs", 
			i__3, "stdiff_", (ftnlen)592)] + velcmp[(i__4 = i__ - 
			1) < 3 && 0 <= i__4 ? i__4 : s_rnge("velcmp", i__4, 
			"stdiff_", (ftnlen)592)] * velcmp[(i__5 = i__ - 1) < 
			3 && 0 <= i__5 ? i__5 : s_rnge("velcmp", i__5, "stdi"
			"ff_", (ftnlen)592)];
	    }

/*           For the worst absolute difference in the position, record */
/*           the components in view frame coordinates. */

	    if (mxatru) {
		for (i__ = 1; i__ <= 3; ++i__) {
		    mxapos[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			    "mxapos", i__2, "stdiff_", (ftnlen)603)] = poscmp[
			    (i__3 = i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			    "poscmp", i__3, "stdiff_", (ftnlen)603)];
		    mxavel[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			    "mxavel", i__2, "stdiff_", (ftnlen)604)] = velcmp[
			    (i__3 = i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			    "velcmp", i__3, "stdiff_", (ftnlen)604)];
		}
		mxaadt = delta;
		mxatim = times[j - 1];
	    }

/*           For the worst relative difference in the position, record */
/*           the components in view frame coordinates. */

	    if (mxrtru) {
		for (i__ = 1; i__ <= 3; ++i__) {
		    mxrpos[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			    "mxrpos", i__2, "stdiff_", (ftnlen)619)] = poscmp[
			    (i__3 = i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			    "poscmp", i__3, "stdiff_", (ftnlen)619)];
		    mxrvel[(i__2 = i__ - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge(
			    "mxrvel", i__2, "stdiff_", (ftnlen)620)] = velcmp[
			    (i__3 = i__ - 1) < 3 && 0 <= i__3 ? i__3 : s_rnge(
			    "velcmp", i__3, "stdiff_", (ftnlen)620)];
		}
		mxradt = delta;
		mxrtim = times[j - 1];
	    }
	}
    }

/*     Find the average values of all the statistics computed. */

    avpos = possum / (doublereal) (*nitr);
    avvel = velsum / (doublereal) (*nitr);
    avrelp = relpsm / (doublereal) (*nitr);
    avrelv = relvsm / (doublereal) (*nitr);
    if (nonzer) {
	for (i__ = 1; i__ <= 3; ++i__) {
	    avpo[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avpo", 
		    i__1, "stdiff_", (ftnlen)646)] = sump[(i__2 = i__ - 1) < 
		    3 && 0 <= i__2 ? i__2 : s_rnge("sump", i__2, "stdiff_", (
		    ftnlen)646)] / (doublereal) (*nitr);
	    avve[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avve", 
		    i__1, "stdiff_", (ftnlen)647)] = sumv[(i__2 = i__ - 1) < 
		    3 && 0 <= i__2 ? i__2 : s_rnge("sumv", i__2, "stdiff_", (
		    ftnlen)647)] / (doublereal) (*nitr);
	    avpoa[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avpoa", 
		    i__1, "stdiff_", (ftnlen)648)] = sumpa[(i__2 = i__ - 1) < 
		    3 && 0 <= i__2 ? i__2 : s_rnge("sumpa", i__2, "stdiff_", (
		    ftnlen)648)] / (doublereal) (*nitr);
	    avvea[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avvea", 
		    i__1, "stdiff_", (ftnlen)649)] = sumva[(i__2 = i__ - 1) < 
		    3 && 0 <= i__2 ? i__2 : s_rnge("sumva", i__2, "stdiff_", (
		    ftnlen)649)] / (doublereal) (*nitr);
	    avposq[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avposq",
		     i__1, "stdiff_", (ftnlen)650)] = sqrt(sumps[(i__2 = i__ 
		    - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sumps", i__2, 
		    "stdiff_", (ftnlen)650)] / (doublereal) (*nitr));
	    avvesq[(i__1 = i__ - 1) < 3 && 0 <= i__1 ? i__1 : s_rnge("avvesq",
		     i__1, "stdiff_", (ftnlen)651)] = sqrt(sumvs[(i__2 = i__ 
		    - 1) < 3 && 0 <= i__2 ? i__2 : s_rnge("sumvs", i__2, 
		    "stdiff_", (ftnlen)651)] / (doublereal) (*nitr));
	}
	avdt = sumdt / (doublereal) (*nitr);
	avadt = sumadt / (doublereal) (*nitr);
	avsdt = sqrt(sumsdt / (doublereal) (*nitr));
    }

/*     If requested, write basic report. */

    if (eqstr_(diftyp, "basic", diftyp_len, (ftnlen)5)) {

/*        Construct and print maximum and average relative differences */
/*        block. */

	s_copy(posstr, "  Position:             #      # ", (ftnlen)80, (
		ftnlen)33);
	s_copy(velstr, "  Velocity:             #      # ", (ftnlen)80, (
		ftnlen)33);
	dpstr_(&maxprl, &c__14, outch, (ftnlen)32);
	dpstr_(&avrelp, &c__14, outch + 32, (ftnlen)32);
	dpstr_(&maxvrl, &c__14, outch + 64, (ftnlen)32);
	dpstr_(&avrelv, &c__14, outch + 96, (ftnlen)32);
	repmc_(posstr, "#", outch, posstr, (ftnlen)80, (ftnlen)1, (ftnlen)32, 
		(ftnlen)80);
	repmc_(posstr, "#", outch + 32, posstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	repmc_(velstr, "#", outch + 64, velstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	repmc_(velstr, "#", outch + 96, velstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	tostdo_(" ", (ftnlen)1);
	tostdo_("Relative differences in state vectors: ", (ftnlen)39);
	tostdo_(" ", (ftnlen)1);
	tostdo_("                              maximum                 avera"
		"ge", (ftnlen)61);
	tostdo_(" ", (ftnlen)1);
	tostdo_(posstr, (ftnlen)80);
	tostdo_(velstr, (ftnlen)80);
	tostdo_(" ", (ftnlen)1);

/*        Construct and print maximum and average relative differences */
/*        block. */

	s_copy(posstr, "  Position (km):        #      # ", (ftnlen)80, (
		ftnlen)33);
	s_copy(velstr, "  Velocity (km/s):      #      # ", (ftnlen)80, (
		ftnlen)33);
	dpstr_(&maxpmg, &c__14, outch, (ftnlen)32);
	dpstr_(&avpos, &c__14, outch + 32, (ftnlen)32);
	dpstr_(&maxvmg, &c__14, outch + 64, (ftnlen)32);
	dpstr_(&avvel, &c__14, outch + 96, (ftnlen)32);
	repmc_(posstr, "#", outch, posstr, (ftnlen)80, (ftnlen)1, (ftnlen)32, 
		(ftnlen)80);
	repmc_(posstr, "#", outch + 32, posstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	repmc_(velstr, "#", outch + 64, velstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	repmc_(velstr, "#", outch + 96, velstr, (ftnlen)80, (ftnlen)1, (
		ftnlen)32, (ftnlen)80);
	tostdo_(" ", (ftnlen)1);
	tostdo_("Absolute differences in state vectors:", (ftnlen)38);
	tostdo_(" ", (ftnlen)1);
	tostdo_("                              maximum                 avera"
		"ge", (ftnlen)61);
	tostdo_(" ", (ftnlen)1);
	tostdo_(posstr, (ftnlen)80);
	tostdo_(velstr, (ftnlen)80);
	tostdo_(" ", (ftnlen)1);
    }

/*     If requested and if states are different, write stats report. */

    if (nonzer && eqstr_(diftyp, "stats", diftyp_len, (ftnlen)5)) {

/*        Print the average of difference values stats block. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("1) Average components of position difference vectors in vie"
		"w ", (ftnlen)61);
	tostdo_("   frame coordinates:", (ftnlen)21);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(avpo, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   1a) Down track (km):                    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avpo[2], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   1b) In orbit plane (km):                "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avpo[1], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   1c) Normal to orbit plane (km):         "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avdt, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   1d) Average delta time down track (sec):"
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);

/*        Print the average of absolute difference values stats block. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("2) Average |components| of position difference vectors in ", 
		(ftnlen)58);
	tostdo_("   view frame coordinates:", (ftnlen)26);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(avpoa, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   2a) Down track (km):                    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avpoa[2], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   2b) In orbit plane (km):                "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avpoa[1], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   2c) Normal to orbit plane (km):         "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avadt, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   2d) Average |delta time| down track (sec"
		"): ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);

/*        Print the RMS stats block. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("3) RMS of position difference vectors in view frame coordin"
		"ates:", (ftnlen)64);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(avposq, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   3a) Down track (km):                    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avposq[2], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   3b) In orbit plane (km):                "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avposq[1], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   3c) Normal to orbit plane (km):         "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&avsdt, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   3d) RMS delta time down track (sec):    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);

/*        Print the maximum relative difference block. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("4) Components of the position difference vector in view fra"
		"me", (ftnlen)61);
	tostdo_("   coordinates for the states with the MAXIMUM RELATIVE ", (
		ftnlen)56);
	tostdo_("   difference in position: ", (ftnlen)27);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(mxrpos, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   4a) Down track (km):                    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxrpos[2], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   4b) In orbit plane (km):                "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxrpos[1], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   4c) Normal to orbit plane (km):         "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxradt, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   4d) Delta time down track (sec):        "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxrtim, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   4e) Epoch (TDB, seconds past J2000):    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	etcal_(&mxrtim, hlpstr, (ftnlen)80);
	i__1 = rtrim_(hlpstr, (ftnlen)80);
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (*(unsigned char *)&hlpstr[i__ - 1] == ' ') {
		*(unsigned char *)&hlpstr[i__ - 1] = '-';
	    }
	}
/* Writing concatenation */
	i__6[0] = 47, a__1[0] = "   4f) Epoch (TDB, calendar format):       "
		"    ";
	i__6[1] = 80, a__1[1] = hlpstr;
	s_cat(ch__2, a__1, i__6, &c__2, (ftnlen)127);
	tostdo_(ch__2, (ftnlen)127);
	tostdo_(" ", (ftnlen)1);

/*        Print the maximum absolute difference block. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("5) Components of the position difference vector in view fra"
		"me", (ftnlen)61);
	tostdo_("   coordinates for the states with the MAXIMUM ABSOLUTE ", (
		ftnlen)56);
	tostdo_("   difference in position: ", (ftnlen)27);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(mxapos, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   5a) Down track (km):                    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxapos[2], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   5b) In orbit plane (km):                "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxapos[1], &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   5c) Normal to orbit plane (km):         "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxaadt, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   5d) Delta time down track (sec):        "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	dpstrf_(&mxatim, &c__14, "F", swdstr, (ftnlen)1, (ftnlen)16);
/* Writing concatenation */
	i__6[0] = 46, a__1[0] = "   5e) Epoch (TDB, seconds past J2000):    "
		"   ";
	i__6[1] = 16, a__1[1] = swdstr;
	s_cat(ch__1, a__1, i__6, &c__2, (ftnlen)62);
	tostdo_(ch__1, (ftnlen)62);
	tostdo_(" ", (ftnlen)1);
	etcal_(&mxatim, hlpstr, (ftnlen)80);
	i__1 = rtrim_(hlpstr, (ftnlen)80);
	for (i__ = 1; i__ <= i__1; ++i__) {
	    if (*(unsigned char *)&hlpstr[i__ - 1] == ' ') {
		*(unsigned char *)&hlpstr[i__ - 1] = '-';
	    }
	}
/* Writing concatenation */
	i__6[0] = 47, a__1[0] = "   5f) Epoch (TDB, calendar format):       "
		"    ";
	i__6[1] = 80, a__1[1] = hlpstr;
	s_cat(ch__2, a__1, i__6, &c__2, (ftnlen)127);
	tostdo_(ch__2, (ftnlen)127);
	tostdo_(" ", (ftnlen)1);
    } else if (eqstr_(diftyp, "stats", diftyp_len, (ftnlen)5)) {

/*        View frame could not be constructed for one or more states */
/*        from STA. Report this instead of printing stats. */

	tostdo_(" ", (ftnlen)1);
	tostdo_("No view frame statistical data can be generated because in "
		"one or more cases  ", (ftnlen)78);
	tostdo_("the state computed from the first SPK has linearly dependen"
		"t position and", (ftnlen)73);
	tostdo_("velocity, which makes constructing the view frame impossibl"
		"e.", (ftnlen)61);
	tostdo_(" ", (ftnlen)1);
    }
    chkout_("STDIFF", (ftnlen)6);
    return 0;
} /* stdiff_ */

