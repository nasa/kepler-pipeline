/* f_dvops.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static doublereal c_b8 = 0.;
static integer c__6 = 6;

/* $Procedure      F_DVOPS (Family of vector operations derivative tests) */
/* Subroutine */ int f_dvops__(logical *ok)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    ), vscl_(doublereal *, doublereal *, doublereal *), vequ_(
	    doublereal *, doublereal *);
    doublereal expv[6], sout[6];
    extern /* Subroutine */ int tcase_(char *, ftnlen), dvhat_(doublereal *, 
	    doublereal *);
    extern doublereal dvdot_(doublereal *, doublereal *);
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal vtemp[3];
    extern /* Subroutine */ int vperp_(doublereal *, doublereal *, doublereal 
	    *), vcrss_(doublereal *, doublereal *, doublereal *), unorm_(
	    doublereal *, doublereal *, doublereal *);
    doublereal s1[6], s2[6];
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen);
    doublereal length;
    extern /* Subroutine */ int vsclip_(doublereal *, doublereal *), ducrss_(
	    doublereal *, doublereal *, doublereal *), dvcrss_(doublereal *, 
	    doublereal *, doublereal *);
    doublereal cmp, exp__, prt1[3], prt2[3];

/* $ Abstract */

/*     This routine performs rudimentary tests on a collection */
/*     of derivative of vector operation */


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

/* -    TSPICE Version 2.0.0, 27-SEP-2005 (NJB) */

/*        Updated to remove non-standard use of duplicate arguments */
/*        in VSCL, VPERP, and UNORM. */

/* -& */

/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_DVOPS", (ftnlen)7);
    s1[0] = 1.;
    s1[1] = 2.;
    s1[2] = 1.;
    s1[3] = 1.;
    s1[4] = -1.;
    s1[5] = 3.;
    s2[0] = 2.;
    s2[1] = 3.;
    s2[2] = 4.;
    s2[3] = 1.;
    s2[4] = 2.;
    s2[5] = 3.;
    tcase_("Test DVDOT.", (ftnlen)11);
    exp__ = s1[0] * s2[3] + s1[3] * s2[0] + s1[1] * s2[4] + s1[4] * s2[1] + 
	    s1[2] * s2[5] + s1[5] * s2[2];
    cmp = dvdot_(s1, s2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("DVDOT", &cmp, "=", &exp__, &c_b8, ok, (ftnlen)5, (ftnlen)1);
    tcase_("Test DVCRSS.", (ftnlen)12);
    vcrss_(s1, s2, expv);
    vcrss_(s1, &s2[3], prt1);
    vcrss_(&s1[3], s2, prt2);
    vadd_(prt1, prt2, &expv[3]);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dvcrss_(s1, s2, sout);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("SOUT", sout, "=", expv, &c__6, &c_b8, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Test DVHAT with a state having non-zero position.", (ftnlen)49);
    unorm_(s1, expv, &length);
    vperp_(&s1[3], expv, &expv[3]);
    d__1 = 1. / length;
    vsclip_(&d__1, &expv[3]);
    dvhat_(s1, sout);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("SOUT", sout, "=", expv, &c__6, &c_b8, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Test DVHAT with a state having zero position.", (ftnlen)45);
    s1[0] = 0.;
    s1[1] = 0.;
    s1[2] = 0.;
    expv[0] = 0.;
    expv[1] = 0.;
    expv[2] = 0.;
    expv[3] = s1[3];
    expv[4] = s1[4];
    expv[5] = s1[5];
    dvhat_(s1, sout);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("SOUT", sout, "=", expv, &c__6, &c_b8, ok, (ftnlen)4, (ftnlen)1);
    tcase_("Test DUCRSS", (ftnlen)11);
    s1[0] = 1.;
    s1[1] = 2.;
    s1[2] = 1.;
    vcrss_(s1, s2, expv);
    vcrss_(s1, &s2[3], prt1);
    vcrss_(&s1[3], s2, prt2);
    vadd_(prt1, prt2, &expv[3]);
    unorm_(expv, vtemp, &length);
    vequ_(vtemp, expv);
    vperp_(&expv[3], expv, vtemp);
    d__1 = 1. / length;
    vscl_(&d__1, vtemp, &expv[3]);
    ducrss_(s1, s2, sout);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("SOUT", sout, "=", expv, &c__6, &c_b8, ok, (ftnlen)4, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_dvops__ */

