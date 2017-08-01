/* tstatd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__20 = 20;
static doublereal c_b31 = 1e-7;

/* $Procedure      TSTATD ( Test Attitude ) */
/* Subroutine */ int tstatd_(doublereal *et, doublereal *matrix, doublereal *
	angvel)
{
    /* Initialized data */

    static logical first = TRUE_;

    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int vhat_(doublereal *, doublereal *);
    static doublereal axis[60]	/* was [3][20] */, temp[9]	/* was [3][3] 
	    */;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    static integer i__;
    extern /* Subroutine */ int xpose_(doublereal *, doublereal *);
    static doublereal dtheta, reftim[20];
    extern integer lstled_(doublereal *, integer *, doublereal *);
    extern /* Subroutine */ int axisar_(doublereal *, doublereal *, 
	    doublereal *);
    static doublereal tempax[3], ref[180]	/* was [3][3][20] */;
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    ;
    static doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine produces attitude and angular velocity values */
/*     that should duplicate the values for the test spacecraft */
/*     with id-code -10001. */

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

/*      None. */

/* $ Keywords */

/*       TESTING */

/* $ Declarations */
/* $ Brief_I/O */

/*      VARIABLE  I/O  DESCRIPTION */
/*      --------  ---  -------------------------------------------------- */
/*      ET         I   An ephemeris epoch in seconds past J2000 */
/*      MATRIX     O   A rotation from J2000 to the frame of -10001 */
/*      ANGVEL     O   The angular velocity of the rotation. */

/* $ Detailed_Input */

/*     ET          an epoch given in terms of TDB seconds past the */
/*                 epoch of J2000. */

/* $ Detailed_Output */

/*     MATRIX      is the expected orientation of the test body -10001 */
/*                 relative to the J2000 frame. */

/*     ANGVEL      is the expected angular velocity of the test body */
/*                 -10001 relative to the J2000 frame. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     Error free. */

/* $ Particulars */

/*     This routine creates a model for the attitude and angular */
/*     velocity of the fictitious body -10001  used in testing SPICE */
/*     SPK, CK, SCLK, and IK systems. */

/*     The attitude is perfectly aligned with the Galactic axes at the */
/*     epoch of J2000. */

/*     The body rotates at a constant rate of 1 radian every 10 million */
/*     seconds.  Every 100 million seconds the axis of rotation changes. */

/*     The axes of rotation are: */

/*     From           To                Axis of rotation    Time Interval */
/*     ------------  ------------       ----------------    ------------- */
/*     -Infinity     -900,000,000       ( 1, 2, 4 )            1 */
/*     -900,000,000  -800,000,000       ( 2, 1, 4 )            2 */
/*     -800,000,000  -700,000,000       ( 4, 1, 2 )            3 */

/*     -700,000,000  -600,000,000       ( 4, 2, 1 )            4 */
/*     -600,000,000  -500,000,000       ( 2, 1, 4 )            5 */
/*     -500,000,000  -400,000,000       ( 1, 4, 2 )            6 */

/*     -400,000,000  -300,000,000       ( 1, 2, 3 )            7 */
/*     -300,000,000  -200,000,000       ( 2, 3, 1 )            8 */
/*     -200,000,000  -100,000,000       ( 3, 1, 2 )            9 */

/*     -100,000,000   000,000,000       ( 3, 2, 1 )            10 */
/*      000,000,000   100,000,000       ( 2, 1, 3 )            11 */
/*      100,000,000   200,000,000       ( 1, 3, 2 )            12 */

/*      200,000,000   300,000,000       ( 2, 3, 6 )            13 */
/*      300,000,000   400,000,000       ( 3, 6, 2 )            14 */
/*      400,000,000   500,000,000       ( 6, 2, 3 )            15 */

/*      500,000,000   600,000,000       ( 6, 3, 2 )            16 */
/*      600,000,000   700,000,000       ( 3, 2, 6 )            17 */
/*      700,000,000   800,000,000       ( 2, 6, 3 )            18 */

/*      800,000,000   900,000,000       ( 1, 1, 1 )            19 */
/*      900,000,000   +Infinity         ( 0, 0, 1 )            20 */


/* $ Examples */

/*     This routine can be used in conjunction with the routine */
/*     TSTCK3 to perform tests on components of the CK system. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*      None. */

/* $ Version */

/* -    Test Utilities Version 1.0.0, 24-JAN-1995 (WLT) */

/* -& */
/* $ Index_Entries */

/*     Attitude of the test body -10001 */

/* -& */

/*     Spicelib Functions */


/*     Local Variables */

    if (first) {
	first = FALSE_;

/*        Setup.  Here we create the rotation matrices at the */
/*        boundaries of the intervals described in the header. */

	axis[0] = 1.;
	axis[1] = 2.;
	axis[2] = 4.;
	axis[3] = 2.;
	axis[4] = 4.;
	axis[5] = 1.;
	axis[6] = 4.;
	axis[7] = 1.;
	axis[8] = 2.;
	axis[9] = 4.;
	axis[10] = 2.;
	axis[11] = 1.;
	axis[12] = 2.;
	axis[13] = 1.;
	axis[14] = 4.;
	axis[15] = 1.;
	axis[16] = 4.;
	axis[17] = 2.;
	axis[18] = 1.;
	axis[19] = 2.;
	axis[20] = 3.;
	axis[21] = 2.;
	axis[22] = 3.;
	axis[23] = 1.;
	axis[24] = 3.;
	axis[25] = 1.;
	axis[26] = 2.;
	axis[27] = 3.;
	axis[28] = 2.;
	axis[29] = 1.;
	axis[30] = 2.;
	axis[31] = 1.;
	axis[32] = 3.;
	axis[33] = 1.;
	axis[34] = 3.;
	axis[35] = 2.;
	axis[36] = 2.;
	axis[37] = 3.;
	axis[38] = 6.;
	axis[39] = 3.;
	axis[40] = 6.;
	axis[41] = 2.;
	axis[42] = 6.;
	axis[43] = 2.;
	axis[44] = 3.;
	axis[45] = 6.;
	axis[46] = 3.;
	axis[47] = 2.;
	axis[48] = 3.;
	axis[49] = 2.;
	axis[50] = 6.;
	axis[51] = 2.;
	axis[52] = 6.;
	axis[53] = 3.;
	axis[54] = 1.;
	axis[55] = 1.;
	axis[56] = 1.;
	axis[57] = 0.;
	axis[58] = 0.;
	axis[59] = 1.;

/*        The 11'th reference matrix should be the identity matrix. */

	ref[90] = 1.;
	ref[91] = 0.;
	ref[92] = 0.;
	ref[93] = 0.;
	ref[94] = 1.;
	ref[95] = 0.;
	ref[96] = 0.;
	ref[97] = 0.;
	ref[98] = 1.;
	reftim[10] = 0.;
	for (i__ = 12; i__ <= 20; ++i__) {

/*           Recall that the rate of rotation is 1 radian every */
/*           10 million seconds.  The axis of rotation changes */
/*           every 100 million seconds.  Hence a DTHETA of 10 radians. */

	    dtheta = 10.;
	    reftim[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge("reftim"
		    , i__1, "tstatd_", (ftnlen)316)] = reftim[(i__2 = i__ - 2)
		     < 20 && 0 <= i__2 ? i__2 : s_rnge("reftim", i__2, "tsta"
		    "td_", (ftnlen)316)] + 1e8;
	    axisar_(&axis[(i__1 = (i__ - 1) * 3 - 3) < 60 && 0 <= i__1 ? i__1 
		    : s_rnge("axis", i__1, "tstatd_", (ftnlen)318)], &dtheta, 
		    temp);
	    mxm_(temp, &ref[(i__1 = ((i__ - 1) * 3 + 1) * 3 - 12) < 180 && 0 
		    <= i__1 ? i__1 : s_rnge("ref", i__1, "tstatd_", (ftnlen)
		    319)], &ref[(i__2 = (i__ * 3 + 1) * 3 - 12) < 180 && 0 <= 
		    i__2 ? i__2 : s_rnge("ref", i__2, "tstatd_", (ftnlen)319)]
		    );
	}
	for (i__ = 10; i__ >= 1; --i__) {
	    reftim[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge("reftim"
		    , i__1, "tstatd_", (ftnlen)325)] = reftim[(i__2 = i__) < 
		    20 && 0 <= i__2 ? i__2 : s_rnge("reftim", i__2, "tstatd_",
		     (ftnlen)325)] - 1e8;
	    dtheta = -10.;
	    axisar_(&axis[(i__1 = i__ * 3 - 3) < 60 && 0 <= i__1 ? i__1 : 
		    s_rnge("axis", i__1, "tstatd_", (ftnlen)328)], &dtheta, 
		    temp);
	    mxm_(temp, &ref[(i__1 = ((i__ + 1) * 3 + 1) * 3 - 12) < 180 && 0 
		    <= i__1 ? i__1 : s_rnge("ref", i__1, "tstatd_", (ftnlen)
		    329)], &ref[(i__2 = (i__ * 3 + 1) * 3 - 12) < 180 && 0 <= 
		    i__2 ? i__2 : s_rnge("ref", i__2, "tstatd_", (ftnlen)329)]
		    );
	}
    }

/*     Compute the offset from the appropriate reference time and */
/*     simply rotate about the appropriate axis. */

/* Computing MAX */
    i__1 = 1, i__2 = lstled_(et, &c__20, reftim);
    i__ = max(i__1,i__2);
    dtheta = (*et - reftim[(i__1 = i__ - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge(
	    "reftim", i__1, "tstatd_", (ftnlen)340)]) / 1e7;
    axisar_(&axis[(i__1 = i__ * 3 - 3) < 60 && 0 <= i__1 ? i__1 : s_rnge(
	    "axis", i__1, "tstatd_", (ftnlen)342)], &dtheta, temp);
    mxm_(temp, &ref[(i__1 = (i__ * 3 + 1) * 3 - 12) < 180 && 0 <= i__1 ? i__1 
	    : s_rnge("ref", i__1, "tstatd_", (ftnlen)343)], rot);
    xpose_(rot, matrix);
    vhat_(&axis[(i__1 = i__ * 3 - 3) < 60 && 0 <= i__1 ? i__1 : s_rnge("axis",
	     i__1, "tstatd_", (ftnlen)346)], tempax);
    vscl_(&c_b31, tempax, angvel);
    return 0;
} /* tstatd_ */

