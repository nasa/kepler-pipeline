/* f_q2m.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b9 = 1e-14;

/* $Procedure      F_Q2M (Family of tests for Q2M ) */
/* Subroutine */ int f_q2m__(logical *ok)
{
    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    doublereal mexp[9]	/* was [3][3] */, m[9]	/* was [3][3] */, q[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ident_(doublereal *), 
	    topen_(char *, ftnlen), t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), q2m_(doublereal *, doublereal *);

/* $ Abstract */

/*     This performs a set of rudimentary tests of the */
/*     SPICE subroutine Q2M */

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

/* -& */

/*     Test Utility Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_Q2M", (ftnlen)5);
    tcase_("Identity Transformation", (ftnlen)23);
    q[0] = 1.;
    q[1] = 0.;
    q[2] = 0.;
    q[3] = 0.;
    q2m_(q, m);
    ident_(mexp);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 90 degrees about Z", (ftnlen)30);
    q[0] = sqrt(2.) / 2.;
    q[1] = 0.;
    q[2] = 0.;
    q[3] = q[0];
    mexp[0] = 0.;
    mexp[1] = 1.;
    mexp[2] = 0.;
    mexp[3] = -1.;
    mexp[4] = 0.;
    mexp[5] = 0.;
    mexp[6] = 0.;
    mexp[7] = 0.;
    mexp[8] = 1.;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 90 degrees about Y", (ftnlen)30);
    q[0] = sqrt(2.) / 2.;
    q[1] = 0.;
    q[2] = q[0];
    q[3] = 0.;
    mexp[0] = 0.;
    mexp[1] = 0.;
    mexp[2] = -1.;
    mexp[3] = 0.;
    mexp[4] = 1.;
    mexp[5] = 0.;
    mexp[6] = 1.;
    mexp[7] = 0.;
    mexp[8] = 0.;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 90 degrees about X", (ftnlen)30);
    q[0] = sqrt(2.) / 2.;
    q[1] = q[0];
    q[2] = 0.;
    q[3] = 0.;
    mexp[0] = 1.;
    mexp[1] = 0.;
    mexp[2] = 0.;
    mexp[3] = 0.;
    mexp[4] = 0.;
    mexp[5] = 1.;
    mexp[6] = 0.;
    mexp[7] = -1.;
    mexp[8] = 0.;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 90 degrees about X with non-unit input quaternion. ", 
	    (ftnlen)63);
    q[0] = 1.;
    q[1] = q[0];
    q[2] = 0.;
    q[3] = 0.;
    mexp[0] = 1.;
    mexp[1] = 0.;
    mexp[2] = 0.;
    mexp[3] = 0.;
    mexp[4] = 0.;
    mexp[5] = 1.;
    mexp[6] = 0.;
    mexp[7] = -1.;
    mexp[8] = 0.;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 60 degrees about Z", (ftnlen)30);

/*        Recall that we need to put in the COS and SIN of 30 degrees */
/*        into the various components of the quaternion.  But these */
/*        values are SQRT(3)/2 and 0.5 respectively. */

    q[0] = sqrt(3.) / 2.;
    q[1] = 0.;
    q[2] = 0.;
    q[3] = .5;
    mexp[0] = .5;
    mexp[1] = q[0];
    mexp[2] = 0.;
    mexp[3] = -q[0];
    mexp[4] = .5;
    mexp[5] = 0.;
    mexp[6] = 0.;
    mexp[7] = 0.;
    mexp[8] = 1.;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 60 degrees about Y", (ftnlen)30);
    q[0] = sqrt(3.) / 2.;
    q[1] = 0.;
    q[2] = .5;
    q[3] = 0.;
    mexp[0] = .5;
    mexp[1] = 0.;
    mexp[2] = -q[0];
    mexp[3] = 0.;
    mexp[4] = 1.;
    mexp[5] = 0.;
    mexp[6] = q[0];
    mexp[7] = 0.;
    mexp[8] = .5;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    tcase_("Rotation by 60 degrees about X", (ftnlen)30);
    q[0] = sqrt(3.) / 2.;
    q[1] = .5;
    q[2] = 0.;
    q[3] = 0.;
    mexp[0] = 1.;
    mexp[1] = 0.;
    mexp[2] = 0.;
    mexp[3] = 0.;
    mexp[4] = .5;
    mexp[5] = q[0];
    mexp[6] = 0.;
    mexp[7] = -q[0];
    mexp[8] = .5;
    q2m_(q, m);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("M", m, "~", mexp, &c__9, &c_b9, ok, (ftnlen)1, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_q2m__ */

