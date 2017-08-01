/* f_m2q.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__4 = 4;
static doublereal c_b9 = 1e-14;

/* $Procedure      F_M2Q ( Family of tests for the SPICE routine M2Q) */
/* Subroutine */ int f_m2q__(logical *ok)
{
    doublereal q[4];
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    doublereal q1[4], q2[4], q3[4], q4[4], r1[9]	/* was [3][3] */, r2[
	    9]	/* was [3][3] */, r3[9]	/* was [3][3] */, r4[9]	/* was [3][3] 
	    */;
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckxc_(logical *, char *, logical *, 
	    ftnlen), q2m_(doublereal *, doublereal *), m2q_(doublereal *, 
	    doublereal *);

/* $ Abstract */

/*     This routine performs a series of test on matrices generated */
/*     from quaternions to ensure that the original quaternion can */
/*     be recovered and that each branch in the quaternion construction */
/*     code is exercised. */

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

/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_M2Q", (ftnlen)5);
    q1[0] = .9;
    q1[1] = .3;
    q1[2] = .3;
    q1[3] = .1;
    q2[0] = .1;
    q2[1] = .9;
    q2[2] = .3;
    q2[3] = .3;
    q3[0] = .3;
    q3[1] = .1;
    q3[2] = .9;
    q3[3] = .3;
    q4[0] = .3;
    q4[1] = .3;
    q4[2] = .1;
    q4[3] = .9;
    q2m_(q1, r1);
    q2m_(q2, r2);
    q2m_(q3, r3);
    q2m_(q4, r4);
    tcase_("Expecting real component to be .9", (ftnlen)33);
    m2q_(r1, q);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("Q1", q, "~", q1, &c__4, &c_b9, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Expecting I component to be 0.9", (ftnlen)31);
    m2q_(r2, q);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("Q2", q, "~", q2, &c__4, &c_b9, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Expecting J component to be 0.9", (ftnlen)31);
    m2q_(r3, q);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("Q3", q, "~", q3, &c__4, &c_b9, ok, (ftnlen)2, (ftnlen)1);
    tcase_("Expecting K component to be 0.9", (ftnlen)31);
    m2q_(r4, q);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("Q4", q, "~", q4, &c__4, &c_b9, ok, (ftnlen)2, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_m2q__ */

