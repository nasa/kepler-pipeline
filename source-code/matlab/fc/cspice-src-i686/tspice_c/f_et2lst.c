/* f_et2lst.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__6 = 6;
static integer c__14 = 14;
static doublereal c_b36 = 0.;
static doublereal c_b38 = 1e6;
static doublereal c_b40 = 3600.;
static doublereal c_b41 = 60.;
static integer c__0 = 0;
static integer c__12 = 12;

/* $Procedure F_ET2LST ( Test the SPICELIB routine ET2LST ) */
/* Subroutine */ int f_et2lst__(logical *ok)
{
    /* Initialized data */

    static integer bodies[5] = { 199,399,301,599,501 };
    static char corsys[30*2] = "  PLANetocentRIC              " " planETOGRA"
	    "Phic               ";
    static doublereal longs[4] = { -90.,0.,90.,180. };

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer i_dnnt(doublereal *);

    /* Local variables */
    char ampm[50];
    integer body;
    char time[50];
    doublereal long__;
    extern /* Subroutine */ int t_subsol__(char *, char *, doublereal *, char 
	    *, char *, doublereal *, ftnlen, ftnlen, ftnlen, ftnlen);
    doublereal q, r__, x[3], delta, range;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer bodno;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), repmd_(char *, char *, doublereal *, 
	    integer *, char *, ftnlen, ftnlen, ftnlen), repmf_(char *, char *,
	     doublereal *, integer *, char *, char *, ftnlen, ftnlen, ftnlen, 
	    ftnlen), dpfmt_(doublereal *, char *, char *, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    char title[240], xampm[50];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char xtime[50];
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern doublereal twopi_(void);
    extern /* Subroutine */ int bodc2n_(integer *, char *, logical *, ftnlen),
	     t_success__(logical *);
    integer sysno;
    extern /* Subroutine */ int et2lst_(doublereal *, integer *, doublereal *,
	     char *, integer *, integer *, integer *, char *, char *, ftnlen, 
	    ftnlen, ftnlen);
    integer sc;
    extern doublereal pi_(void);
    doublereal et;
    integer handle, hr, mn;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    char bodnam[36];
    extern /* Subroutine */ int delfil_(char *, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), reclat_(
	    doublereal *, doublereal *, doublereal *, doublereal *), rmaind_(
	    doublereal *, doublereal *, doublereal *, doublereal *), pgrrec_(
	    char *, doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, ftnlen);
    integer offset;
    doublereal sunrad;
    integer longno;
    extern /* Subroutine */ int spkuef_(integer *);
    doublereal srflon, sunlat, soltim;
    extern /* Subroutine */ int tstpck_(char *, logical *, logical *, ftnlen);
    char sysnam[30];
    doublereal spoint[3], sunlon;
    extern /* Subroutine */ int tstlsk_(void), tstspk_(char *, logical *, 
	    integer *, ftnlen);
    doublereal lat;
    extern doublereal rpd_(void);
    integer xsc, xhr, xmn;

/* $ Abstract */

/*     Exercise the SPICELIB routine ET2LST. */

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

/*     This routine tests the SPICELIB routine ET2LST.  ET2LST */
/*     converts ET to local solar time for a specified body and */
/*     location. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 01-NOV-2005 (NJB) */


/* -& */

/*     SPICELIB functions */


/*     Other functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved values */


/*     Initial values */


/*     Test case insensitivity while we're at it. */


/*     Open the test family. */

    topen_("F_ET2LST", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Setup:  load LSK, PCK, SPK kernels.", (ftnlen)35);
    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstpck_("test.tpc", &c_true, &c_false, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tstspk_("test.bsp", &c_true, &handle, (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check time computations for each body, longitude, and supported */
/*     coordinate system. */

    for (bodno = 1; bodno <= 5; ++bodno) {
	body = bodies[(i__1 = bodno - 1) < 5 && 0 <= i__1 ? i__1 : s_rnge(
		"bodies", i__1, "f_et2lst__", (ftnlen)257)];
	for (sysno = 1; sysno <= 2; ++sysno) {
	    s_copy(sysnam, corsys + ((i__1 = sysno - 1) < 2 && 0 <= i__1 ? 
		    i__1 : s_rnge("corsys", i__1, "f_et2lst__", (ftnlen)261)) 
		    * 30, (ftnlen)30, (ftnlen)30);
	    for (longno = 1; longno <= 4; ++longno) {
		long__ = longs[(i__1 = longno - 1) < 4 && 0 <= i__1 ? i__1 : 
			s_rnge("longs", i__1, "f_et2lst__", (ftnlen)265)] * 
			rpd_();
		for (offset = 1; offset <= 25; ++offset) {

/*                 Set the ET value. */

		    et = offset * 3600.;

/* --- Case: ------------------------------------------------------ */

		    s_copy(title, "Normal case: body = #; system = #; longit"
			    "ude = #; ET = #.", (ftnlen)240, (ftnlen)57);
		    repmi_(title, "#", &body, title, (ftnlen)240, (ftnlen)1, (
			    ftnlen)240);
		    repmc_(title, "#", sysnam, title, (ftnlen)240, (ftnlen)1, 
			    (ftnlen)30, (ftnlen)240);
		    repmf_(title, "#", &long__, &c__6, "F", title, (ftnlen)
			    240, (ftnlen)1, (ftnlen)1, (ftnlen)240);
		    repmd_(title, "#", &et, &c__14, title, (ftnlen)240, (
			    ftnlen)1, (ftnlen)240);
		    tcase_(title, (ftnlen)240);

/*                 Compute the expected result directly. */

/*                 First, find the rectangular coordinates of */
/*                 the apparent sub-solar point at ET. */

		    bodc2n_(&body, bodnam, &found, (ftnlen)36);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    t_subsol__("INTERCEPT", bodnam, &et, "LT+S", bodnam, 
			    spoint, (ftnlen)9, (ftnlen)36, (ftnlen)4, (ftnlen)
			    36);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Find planetocentric coordinates of the sub-solar */
/*                 point. */

		    reclat_(spoint, &sunrad, &sunlon, &sunlat);


/*                 If the surface point's longitude is given in */
/*                 the planetographic system, convert it to the */
/*                 planetocentric system. */

		    if (eqstr_(sysnam, "PLANETOGRAPHIC", (ftnlen)30, (ftnlen)
			    14)) {
			pgrrec_(bodnam, &long__, &c_b36, &c_b36, &c_b38, &
				c_b36, x, (ftnlen)36);

/*                    The output SRFLON is planetocentric longitude. */

			reclat_(x, &range, &srflon, &lat);
		    } else {
			srflon = long__;
		    }

/*                 The offset from noon of solar time at the point */
/*                 is the planetocentric */
/*                 longitude offset from the sub-solar point, expressed */
/*                 as a fraction of 2*pi and scaled by 86400. */

		    delta = srflon - sunlon;
		    if (delta > pi_()) {
			delta -= twopi_();
		    } else if (delta < -pi_()) {
			delta += twopi_();
		    }
		    soltim = delta * 86400. / twopi_();

/*                 SOLTIM represents a time past noon.  Convert */
/*                 SOLTIM to seconds past midnight. */

		    soltim += 43200.;

/*                 Convert the solar time to hours, minutes, and */
/*                 seconds.  These are our expected numeric values. */

		    rmaind_(&soltim, &c_b40, &q, &r__);
		    xhr = i_dnnt(&q);
		    soltim -= i_dnnt(&q) * 3600.;
		    rmaind_(&soltim, &c_b41, &q, &r__);
		    xmn = i_dnnt(&q);
		    xsc = (integer) r__;

/*                 See whether ET2LST agrees. */

		    et2lst_(&et, &body, &long__, sysnam, &hr, &mn, &sc, time, 
			    ampm, (ftnlen)30, (ftnlen)50, (ftnlen)50);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Check results. */

		    chcksi_("HR", &hr, "=", &xhr, &c__0, ok, (ftnlen)2, (
			    ftnlen)1);
		    chcksi_("MN", &mn, "=", &xmn, &c__0, ok, (ftnlen)2, (
			    ftnlen)1);
		    chcksi_("SC", &sc, "=", &xsc, &c__0, ok, (ftnlen)2, (
			    ftnlen)1);

/*                 Create the expected time strings.  Leading */
/*                 zeros are required. */

		    s_copy(xtime, "  :  :", (ftnlen)50, (ftnlen)6);
		    d__1 = (doublereal) hr;
		    dpfmt_(&d__1, "0X", xtime, (ftnlen)2, (ftnlen)2);
		    d__1 = (doublereal) mn;
		    dpfmt_(&d__1, "0X", xtime + 3, (ftnlen)2, (ftnlen)2);
		    d__1 = (doublereal) sc;
		    dpfmt_(&d__1, "0X", xtime + 6, (ftnlen)2, (ftnlen)2);
		    chckxc_(&c_false, " ", ok, (ftnlen)1);
		    chcksc_("TIME", time, "=", xtime, ok, (ftnlen)4, (ftnlen)
			    50, (ftnlen)1, (ftnlen)50);

/*                 Create the 12-hour clock string. */

		    s_copy(xampm, xtime, (ftnlen)50, (ftnlen)50);
		    if (hr < 12) {
			s_copy(xampm + 9, "A.M.", (ftnlen)4, (ftnlen)4);
			if (hr == 0) {
			    s_copy(xampm, "12", (ftnlen)2, (ftnlen)2);
			}
		    } else {
			hr += -12;
			if (hr == 0) {
			    s_copy(xampm, "12", (ftnlen)2, (ftnlen)2);
			} else {
			    d__1 = (doublereal) hr;
			    dpfmt_(&d__1, "0X", xampm, (ftnlen)2, (ftnlen)2);
			}
			s_copy(xampm + 9, "P.M.", (ftnlen)4, (ftnlen)4);
		    }
		    chcksc_("AMPM", ampm, "=", xampm, ok, (ftnlen)4, (ftnlen)
			    50, (ftnlen)1, (ftnlen)50);
		}
	    }
	}
    }

/*     Now for some exception handling tests. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Exception:  body is sun.", (ftnlen)24);
    et = 0.;
    body = 10;
    s_copy(sysnam, "PLANETOCENTRIC", (ftnlen)30, (ftnlen)14);
    long__ = pi_() / 4.;
    et2lst_(&et, &body, &long__, sysnam, &hr, &mn, &sc, time, ampm, (ftnlen)
	    30, (ftnlen)50, (ftnlen)50);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     According to the routine's specification, the time is always */
/*     12 noon on the sun. */

    chcksi_("HR", &hr, "=", &c__12, &c__0, ok, (ftnlen)2, (ftnlen)1);
    chcksi_("MN", &mn, "=", &c__0, &c__0, ok, (ftnlen)2, (ftnlen)1);
    chcksi_("SC", &sc, "=", &c__0, &c__0, ok, (ftnlen)2, (ftnlen)1);
    chcksc_("TIME", time, "=", "12:00:00", ok, (ftnlen)4, (ftnlen)50, (ftnlen)
	    1, (ftnlen)8);
    chcksc_("AMPM", ampm, "=", "12:00:00 P.M.", ok, (ftnlen)4, (ftnlen)50, (
	    ftnlen)1, (ftnlen)13);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error:  unrecognized coordinate system.", (ftnlen)39);
    et = 0.;
    body = 399;
    s_copy(sysnam, "MAGNETOSPHERIC", (ftnlen)30, (ftnlen)14);
    long__ = pi_() / 4.;
    et2lst_(&et, &body, &long__, sysnam, &hr, &mn, &sc, time, ampm, (ftnlen)
	    30, (ftnlen)50, (ftnlen)50);
    chckxc_(&c_true, "SPICE(UNKNOWNSYSTEM)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Error:  no frame associated with body.", (ftnlen)38);
    et = 0.;
    body = -77;
    s_copy(sysnam, "PLANETOCENTRIC", (ftnlen)30, (ftnlen)14);
    long__ = pi_() / 4.;
    et2lst_(&et, &body, &long__, sysnam, &hr, &mn, &sc, time, ampm, (ftnlen)
	    30, (ftnlen)50, (ftnlen)50);
    chckxc_(&c_true, "SPICE(CANTFINDFRAME)", ok, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Clean up:  delete SPK file.", (ftnlen)27);
    spkuef_(&handle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    delfil_("test.bsp", (ftnlen)8);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_et2lst__ */

