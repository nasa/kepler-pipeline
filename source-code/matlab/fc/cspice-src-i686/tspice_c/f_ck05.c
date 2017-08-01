/* f_ck05.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__200 = 200;
static logical c_true = TRUE_;
static doublereal c_b37 = 1e-14;
static integer c__4 = 4;

/* $Procedure      F_CK05 ( CK type 5 tests ) */
/* Subroutine */ int f_ck05__(logical *ok)
{
    /* Initialized data */

    static doublereal z__[3] = { 0.,0.,1. };

    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    doublereal cmat[9]	/* was [3][3] */;
    extern /* Subroutine */ int ckw05_(integer *, integer *, integer *, 
	    doublereal *, doublereal *, integer *, char *, logical *, char *, 
	    integer *, doublereal *, doublereal *, doublereal *, integer *, 
	    doublereal *, ftnlen, ftnlen);
    doublereal rate;
    integer inst, i__;
    doublereal q[4], angle, scale;
    char segid[40];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ckcls_(integer *), 
	    ckopn_(char *, char *, integer *, integer *, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    doublereal t1pack[800]	/* was [4][200] */;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen);
    doublereal av[3];
    integer degree, handle;
    extern /* Subroutine */ int delfil_(char *, ftnlen);
    logical avflag;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksl_(char *, logical *, 
	    logical *, logical *, ftnlen), ckgpav_(integer *, doublereal *, 
	    doublereal *, char *, doublereal *, doublereal *, doublereal *, 
	    logical *, ftnlen);
    doublereal epochs[200];
    extern /* Subroutine */ int unload_(char *, ftnlen), axisar_(doublereal *,
	     doublereal *, doublereal *);
    doublereal clkout;
    extern /* Subroutine */ int furnsh_(char *, ftnlen);
    extern logical exists_(char *, ftnlen);
    extern /* Subroutine */ int m2q_(doublereal *, doublereal *), tstlsk_(
	    void);
    doublereal tol;

/* $ Abstract */

/*     This routine tests the SPICELIB CK type 5 routines. */
/*     This is rudimentary set of tests to make sure the routines */
/*     cycle in every environment; thorough tests are performed */
/*     in the tspice_c test package. */

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

/* -    SPICELIB Version 1.0.0, 06-SEP-2002 (NJB) */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */

/* $ Abstract */

/*     Declare parameters specific to CK type 05. */

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

/*     CK */

/* $ Keywords */

/*     CK */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 20-AUG-2002 (NJB) */

/* -& */

/*     CK type 5 subtype codes: */


/*     Subtype 0:  Hermite interpolation, 8-element packets. Quaternion */
/*                 and quaternion derivatives only, no angular velocity */
/*                 vector provided. Quaternion elements are listed */
/*                 first, followed by derivatives. Angular velocity is */
/*                 derived from the quaternions and quaternion */
/*                 derivatives. */


/*     Subtype 1:  Lagrange interpolation, 4-element packets. Quaternion */
/*                 only. Angular velocity is derived by differentiating */
/*                 the interpolating polynomials. */


/*     Subtype 2:  Hermite interpolation, 14-element packets. */
/*                 Quaternion and angular angular velocity vector, as */
/*                 well as derivatives of each, are provided. The */
/*                 quaternion comes first, then quaternion derivatives, */
/*                 then angular velocity and its derivatives. */


/*     Subtype 3:  Lagrange interpolation, 7-element packets. Quaternion */
/*                 and angular velocity vector provided.  The quaternion */
/*                 comes first. */


/*     Packet sizes associated with the various subtypes: */


/*     End of file ck05.inc. */


/*     Local Parameters */


/*     Local Variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_CK05", (ftnlen)6);

/*     Create and load  leapseconds kernel. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Define some CK data sets for use in testing.  First set:  a */
/*     sequence of rotations about the z-axis.  The C-matrix starts */
/*     out as the identity.  The ith attitude is obtained by */
/*     rotating about the z-axis by i microradians relative to the */
/*     (i-1)st attitude. */

/*     The ith epoch is simply i. */

    angle = 0.;
    scale = 1e-9;
    for (i__ = 0; i__ <= 199; ++i__) {
	angle -= i__ * scale;
	axisar_(z__, &angle, cmat);
	m2q_(cmat, &t1pack[(i__1 = i__ << 2) < 800 && 0 <= i__1 ? i__1 : 
		s_rnge("t1pack", i__1, "f_ck05__", (ftnlen)152)]);
	epochs[(i__1 = i__) < 200 && 0 <= i__1 ? i__1 : s_rnge("epochs", i__1,
		 "f_ck05__", (ftnlen)154)] = (doublereal) i__;
    }
    tcase_("CKW05 test:  create a new CK containing segment of subtype 1.", (
	    ftnlen)61);
    avflag = TRUE_;
    rate = 1e3;
    s_copy(segid, "CK type 05 test segment.", (ftnlen)40, (ftnlen)24);
    inst = 1;
    degree = 11;

/*     Open a new CK file. */

    if (exists_("ck05_test.bc", (ftnlen)12)) {
	delfil_("ck05_test.bc", (ftnlen)12);
    }
    ckopn_("ck05_test.bc", " ", &c__0, &handle, (ftnlen)12, (ftnlen)1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckw05_(&handle, &c__1, &degree, epochs, &epochs[199], &inst, "J2000", &
	    avflag, segid, &c__200, epochs, t1pack, &rate, &c__1, epochs, (
	    ftnlen)5, (ftnlen)40);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    ckcls_(&handle);
    tcase_("Recover pointing from segment of subtype 1 in CK file CK05", (
	    ftnlen)58);

/*     Now we'll use the CK user-level readers to look up pointing. */

    furnsh_("ck05_test.bc", (ftnlen)12);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    tol = 0.;
    for (i__ = 0; i__ <= 199; ++i__) {
	ckgpav_(&inst, &epochs[(i__1 = i__) < 200 && 0 <= i__1 ? i__1 : 
		s_rnge("epochs", i__1, "f_ck05__", (ftnlen)204)], &tol, "J20"
		"00", cmat, av, &clkout, &found, (ftnlen)5);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	if (found) {
	    chcksd_("CLKOUT", &clkout, "~", &epochs[(i__1 = i__) < 200 && 0 <=
		     i__1 ? i__1 : s_rnge("epochs", i__1, "f_ck05__", (ftnlen)
		    213)], &c_b37, ok, (ftnlen)6, (ftnlen)1);
	    m2q_(cmat, q);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("Q", q, "~", &t1pack[(i__1 = i__ << 2) < 800 && 0 <= i__1 
		    ? i__1 : s_rnge("t1pack", i__1, "f_ck05__", (ftnlen)219)],
		     &c__4, &c_b37, ok, (ftnlen)1, (ftnlen)1);
	}
    }
    unload_("ck05_test.bc", (ftnlen)12);
    if (exists_("ck05_test.bc", (ftnlen)12)) {
	delfil_("ck05_test.bc", (ftnlen)12);
    }
    t_success__(ok);
    return 0;
} /* f_ck05__ */

