/* spke53.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static doublereal c_b19 = 1.;

/* $Procedure      SPKE53 ( Evaluate a type 53 SPK data record) */
/* Subroutine */ int spke53_(doublereal *et, doublereal *recin, doublereal *
	state)
{
    /* Initialized data */

    static logical first = TRUE_;

    /* System generated locals */
    doublereal d__1, d__2;

    /* Builtin functions */
    double sqrt(doublereal), d_mod(doublereal *, doublereal *), d_sign(
	    doublereal *, doublereal *), sin(doublereal), cos(doublereal), 
	    atan2(doublereal, doublereal), tanh(doublereal), atan(doublereal);

    /* Local variables */
    static doublereal near__, dmdt, sine;
    extern /* Subroutine */ int vscl_(doublereal *, doublereal *, doublereal *
	    );
    extern doublereal vdot_(doublereal *, doublereal *);
    static doublereal mypi;
    extern /* Subroutine */ int vequ_(doublereal *, doublereal *);
    static integer j2flg;
    static doublereal p, u[3], dnode, z__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    static doublereal epoch, eanom, dperi, theta, manom;
    extern /* Subroutine */ int errdp_(char *, doublereal *, ftnlen), vlcom_(
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *);
    static doublereal vtemp[3];
    extern /* Subroutine */ int vcrss_(doublereal *, doublereal *, doublereal 
	    *);
    extern doublereal twopi_(void);
    static doublereal tzero;
    extern /* Subroutine */ int vrotv_(doublereal *, doublereal *, doublereal 
	    *, doublereal *);
    static doublereal pa[3], gm, ta;
    extern doublereal pi_(void);
    static doublereal chckpa, tp[3], pv[3], chcktp, chckpv, cosinc, cosine;
    extern /* Subroutine */ int elltof_(doublereal *, doublereal *, 
	    doublereal *), sigerr_(char *, ftnlen), vhatip_(doublereal *), 
	    chkout_(char *, ftnlen), vsclip_(doublereal *, doublereal *), 
	    setmsg_(char *, ftnlen), hyptof_(doublereal *, doublereal *, 
	    doublereal *);
    static doublereal oj2;
    extern logical return_(void);
    static doublereal twopiv, ecc, sma, rpl, k2pi;

/* $ Abstract */

/*     Evaluates a single SPK data record from a segment of type 53 */
/*    (Precessing Conic Propagation). */

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

/*     SPK */

/* $ Keywords */

/*     EPHEMERIS */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     ET         I   Target epoch. */
/*     RECIN      I   Data record. */
/*     STATE      O   State (position and velocity). */

/* $ Detailed_Input */

/*     ET          is a target epoch, specified as ephemeris seconds past */
/*                 J2000, at which a state vector is to be computed. */

/*     RECIN       is a data record which, when evaluated at epoch ET, */
/*                 will give the state (position and velocity) of some */
/*                 body, relative to some center, in some inertial */
/*                 reference frame. */

/*                 The structure of RECIN is: */

/*                 RECIN(1)             epoch of the orbit elements */
/*                                      in ephemeris seconds past J2000. */
/*                 RECIN(2)-RECIN(4)    unit trajectory pole vector */
/*                 RECIN(5)-RECIN(7)    unit periapsis vector */
/*                 RECIN(8)             semi-latus rectum---p in the */
/*                                      equation: */

/*                                      r = p/(1 + ECC*COS(Nu)) */

/*                 RECIN(9)             eccentricity */
/*                 RECIN(10)            time past periapsis at epoch */
/*                                      in seconds */
/*                 RECIN(11)            J2 processing flag describing */
/*                                      what J2 corrections are to be */
/*                                      applied when the orbit is */
/*                                      propagated. */

/*                                      All J2 corrections are applied */
/*                                      if this flag has a value that */
/*                                      is not 1,2 or 3. */

/*                                      If the value of the flag is 3 */
/*                                      no corrections are done. */

/*                                      If the value of the flag is 1 */
/*                                      no corrections are computed for */
/*                                      the precession of the line */
/*                                      of apsides.  However, regression */
/*                                      of the line of nodes is */
/*                                      performed. */

/*                                      If the value of the flag is 2 */
/*                                      no corrections are done for */
/*                                      the regression of the line of */
/*                                      nodes. However, precession of the */
/*                                      line of apsides is performed. */

/*                                      Note that J2 effects are computed */
/*                                      only if the orbit is elliptic and */
/*                                      does not intersect the central */
/*                                      body. */

/*                 RECIN(12)-RECIN(14)  unit central body pole vector */
/*                 RECIN(15)            central body GM */
/*                 RECIN(16)            central body J2 */
/*                 RECIN(17)            central body radius */

/*                 Units are radians, km, seconds */

/* $ Detailed_Output */

/*     STATE       is the state produced by evaluating RECIN at ET. */
/*                 Units are km and km/sec. */

/* $ Parameters */

/*      None. */

/* $ Files */

/*      None. */

/* $ Exceptions */

/*     1) If the eccentricity is 1 or less than zero, the error */
/*        'SPICE(BADECCENTRICITY)' will be signalled. */

/*     2) If the semi-latus rectum is 0, the error */

/*        'SPICE(BADLATUSRECTUM)' is signalled. */

/*     3) If the pole vector, trajectory pole vector or periapsis vector */
/*        have zero length, the error 'SPICE(BADVECTOR)' is signalled. */

/* $ Particulars */

/*     This algorithm applies J2 corrections for precessing the */
/*     node and argument of periapse for an object orbiting an */
/*     oblate spheroid. */

/*     Note the effects of J2 are incorporated only for elliptic */
/*     orbits that do not intersect the central body. */

/*     While the derivation of the effect of the various harmonics */
/*     of gravitational field are beyond the scope of this header */
/*     the effect of the J2 term of the gravity model are as follows */

/*     The line of node precesses and the rate of precession DNode/dt */
/*     is given by */
/*                             3 n J2 */
/*         dNode/dNu =  -  -----------------  DCOS( inc ) */
/*                            2 (P/RPL)**2 */

/*      where n is the mean motion of the orbit. */

/*     (Since this is always less than zero for oblate spheroids, this */
/*      should be called regression of nodes.) */

/*     The line of apsides precesses and the rate of precession DPeri/dt */
/*     is given by */
/*                              3 n J2 */
/*         dPeri/dNu =     ----------------- ( 5*DCOS ( inc ) - 1 ) */
/*                            2 (P/RPL)**2 */

/*     Details of these formula are given in the Danby's book (see */
/*     literature references below). */

/*     It is assumed that this routine is used in conjunction with */
/*     the routine SPKR53 as shown here: */

/*        CALL SPKR53 ( HANDLE, DESCR, ET, RECIN         ) */
/*        CALL SPKE53 (                ET, RECIN, STATE  ) */

/*     where it is known in advance that the HANDLE, DESCR pair points */
/*     to a type 53 data segment. */

/* $ Examples */

/*     The SPKEnn routines are almost always used in conjunction with */
/*     the corresponding SPKRnn routines, which read the records from */
/*     SPK files. */

/*     The data returned by the SPKRnn routine is in its rawest form, */
/*     taken directly from the segment.  As such, it will be meaningless */
/*     to a user unless he/she understands the structure of the data type */
/*     completely.  Given that understanding, however, the SPKRnn */
/*     routines might be used to examine raw segment data before */
/*     evaluating it with the SPKEnn routines. */


/*     C */
/*     C     Get a segment applicable to a specified body and epoch. */
/*     C */
/*           CALL SPKSFS ( BODY, ET, HANDLE, DESCR, IDENT, FOUND ) */

/*     C */
/*     C     Look at parts of the descriptor. */
/*     C */
/*           CALL DAFUS ( DESCR, 2, 6, DCD, ICD ) */
/*           CENTER = ICD( 2 ) */
/*           REF    = ICD( 3 ) */
/*           TYPE   = ICD( 4 ) */

/*           IF ( TYPE .EQ. 53 ) THEN */

/*              CALL SPKR53 ( HANDLE, DESCR, ET, RECORD ) */
/*                  . */
/*                  .  Look at the RECORD data. */
/*                  . */
/*              CALL SPKE53 ( ET, RECORD, STATE ) */
/*                  . */
/*                  .  Check out the evaluated state. */
/*                  . */
/*           END IF */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*      S.   Schlaifer  (JPL) */
/*      W.L. Taber      (JPL) */

/* $ Literature_References */

/*     [1] `Fundamentals of Celestial Mechanics', Second Edition */
/*         by J.M.A. Danby;  Willman-Bell, Inc., P.O. Box 35025 */
/*         Richmond Virginia;  pp 345-347. */

/* $ Version */

/* -    TSPICE Version 1.2.0, 10-NOV-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VCRSS, VHAT, VROTV, and VSCL calls. */

/* -    SPICELIB Version 1.1.0, 20-OCT-1999 (WLT) */

/*        Declared PI to be an EXTERNAL Functions. */

/* -    SPICELIB Version 1.0.0, 15-NOV-1994 (WLT) (SS) */

/* -& */
/* $ Index_Entries */

/*     evaluate type_53 spk segment */

/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    }
    chkin_("SPKE53", (ftnlen)6);
    if (first) {
	first = FALSE_;
	twopiv = twopi_();
	mypi = pi_();
    }

/*     Fetch the various entities from the input record, first the epoch. */

    epoch = recin[0];

/*     The trajectory pole vector. */

    tp[0] = recin[1];
    tp[1] = recin[2];
    tp[2] = recin[3];

/*     The periapsis vector. */

    pa[0] = recin[4];
    pa[1] = recin[5];
    pa[2] = recin[6];

/*     Semi-latus rectum ( P in the P/(1 + ECC*COS(Nu)  ), */
/*     eccentricity, and time from periapsis at epoch. */

    p = recin[7];
    ecc = recin[8];
    tzero = recin[9];

/*     J2 processing flag. */

    j2flg = (integer) recin[10];

/*     Central body pole vector. */

    pv[0] = recin[11];
    pv[1] = recin[12];
    pv[2] = recin[13];

/*     The central mass, J2 and radius of the central body. */

    gm = recin[14];
    oj2 = recin[15];
    rpl = recin[16];

/*     Check all the inputs here for obvious failures.  Yes, perhaps */
/*     this is overkill.  However, there is a lot more computation */
/*     going on in this routine so that the small amount of overhead */
/*     here should not be significant. */

    chckpa = abs(pa[0]) + abs(pa[1]) + abs(pa[2]);
    chckpv = abs(pv[0]) + abs(pv[1]) + abs(pv[2]);
    chcktp = abs(tp[0]) + abs(tp[1]) + abs(tp[2]);
    if (p == 0.) {
	setmsg_("The semi-latus rectum supplied to the SPK type 53 evaluator"
		" was zero.  This value must be non-zero. ", (ftnlen)100);
	sigerr_("SPICE(BADLATUSRECTUM)", (ftnlen)21);
	chkout_("SPKE53", (ftnlen)6);
	return 0;
    } else if (ecc == 1. || ecc < 0.) {
	setmsg_("The eccentricity supplied for a type 53 segment is out of t"
		"he range of acceptable values ( 0 <= ecc < 1 or ecc >1). The"
		" value supplied to the type 53 evaluator was #. ", (ftnlen)
		167);
	errdp_("#", &ecc, (ftnlen)1);
	sigerr_("SPICE(BADECCENTRICITY)", (ftnlen)22);
	chkout_("SPKE53", (ftnlen)6);
	return 0;
    } else if (chcktp == 0.) {
	setmsg_("The trajectory pole vector supplied to SPKE53 had length ze"
		"ro. The most likely cause of this problem is a corrupted SPK"
		" (ephemeris) file. ", (ftnlen)138);
	sigerr_("SPICE(BADVECTOR)", (ftnlen)16);
	chkout_("SPKE53", (ftnlen)6);
	return 0;
    } else if (chckpa == 0.) {
	setmsg_("The periapse vector supplied to SPKE53 had length zero. The"
		" most likely cause of this problem is a corrupted SPK (ephem"
		"eris) file. ", (ftnlen)131);
	sigerr_("SPICE(BADVECTOR)", (ftnlen)16);
	chkout_("SPKE53", (ftnlen)6);
	return 0;
    } else if (chckpv == 0.) {
	setmsg_("The central pole vector supplied to SPKE53 had length zero."
		" The most likely cause of this problem is a corrupted SPK (e"
		"phemeris) file. ", (ftnlen)135);
	sigerr_("SPICE(BADVECTOR)", (ftnlen)16);
	chkout_("SPKE53", (ftnlen)6);
	return 0;
    }

/*     Convert TP, PV and PA to unit vectors. */
/*     (It won't hurt to polish them up a bit here if they are already */
/*      unit vectors.) */

    vhatip_(pa);
    vhatip_(tp);
    vhatip_(pv);

/*     Compute the semi-major axis, mean motion, and distance a periapse. */

/* Computing 2nd power */
    d__1 = ecc;
    sma = p / (1. - d__1 * d__1);
/* Computing 3rd power */
    d__2 = sma;
    dmdt = sqrt((d__1 = gm / (d__2 * (d__2 * d__2)), abs(d__1)));
    near__ = p / (ecc + 1.);


/*     Next compute the eccentric anomaly and from that, TA, the true */
/*     anomaly. */

    manom = (tzero + *et - epoch) * dmdt;
    if (ecc < 1.) {

/*        Next compute the angle THETA such that THETA is between */
/*        -pi and pi and such than MANOM = THETA + K*2*pi for */
/*        some integer K. */

	theta = d_mod(&manom, &twopiv);
	if (abs(theta) > mypi) {
	    theta -= d_sign(&twopiv, &theta);
	}
	k2pi = manom - theta;

/*        Compute the eccentric anomaly associated with THETA. */

	elltof_(&theta, &ecc, &eanom);
	sine = sin(eanom / 2) * sqrt((ecc + 1) / (1 - ecc));
	cosine = cos(eanom / 2);

/*        Finally, compute the accumulated true anomaly.  That is, */
/*        add in the accumulated angle K2PI (This works because like */
/*        THETA, TA is always between -PI and PI.) */

	ta = atan2(sine, cosine) * 2. + k2pi;
    } else {
	hyptof_(&manom, &ecc, &eanom);
	ta = atan(sqrt((ecc + 1) / (ecc - 1)) * tanh(eanom / 2)) * 2.;
    }

/*     If called for, handle precession needed due to the J2 term. */

    if (j2flg != 3 && oj2 != 0. && ecc < 1. && near__ > rpl) {

/*        Determine how far the line of nodes and periapsis have moved. */

	cosinc = vdot_(pv, tp);
/* Computing 2nd power */
	d__1 = rpl / p;
	z__ = ta * 1.5 * oj2 * (d__1 * d__1);
	dnode = -z__ * cosinc;
/* Computing 2nd power */
	d__1 = cosinc;
	dperi = z__ * (d__1 * d__1 * 2.5 - .5);

/*        Regress the line of nodes by rotating the periapsis and */
/*        trajectory pole vectors about the the pole of the central */
/*        body. */

	if (j2flg != 2) {
	    vrotv_(tp, pv, &dnode, vtemp);
	    vequ_(vtemp, tp);
	    vrotv_(pa, pv, &dnode, vtemp);
	    vequ_(vtemp, pa);
	}

/*        Precess periapsis by rotating the periapsis vector about the */
/*        trajectory pole */

	if (j2flg != 1) {
	    vrotv_(pa, tp, &dperi, vtemp);
	    vequ_(vtemp, pa);
	}
    }

/*     That's it finish the state computation.  Rotate the periapsis */
/*     vector by the true anomaly about the trajectory pole vector. */
/*     This gives a unit vector that points towards the position at ET. */

    vrotv_(pa, tp, &ta, u);

/*     Compute the range from the central body and scale up the */
/*     position vector to get the direction vector. */

    z__ = p / (ecc * cos(ta) + 1.);
    vscl_(&z__, u, state);


/*     Finally, the velocity. Recall that the velocity is given by */
/*     adding the position direction to an eccentricity vector, */
/*     rotating by 90 degrees in the plane of the orbit, and */
/*     scaling by the appropriate factor.  The "eccentricity */
/*     vector" is ECC times the the unit vector parallel to the */
/*     position at periapse.  Thus, up to scale, the velocity is: */

/*        TP x ( U + ECC * PA ) */

    vlcom_(&c_b19, u, &ecc, pa, &state[3]);
    vcrss_(tp, &state[3], vtemp);
    vequ_(vtemp, &state[3]);

/*     Finally, scale up the direction of the velocity to */
/*     get the velocity. */

    z__ = sqrt(gm / p);
    vsclip_(&z__, &state[3]);
    chkout_("SPKE53", (ftnlen)6);
    return 0;
} /* spke53_ */

