/* f_spkpds.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__2 = 2;
static integer c__6 = 6;
static logical c_false = FALSE_;
static doublereal c_b30 = 0.;
static integer c__0 = 0;

/* $Procedure      F_SPKPDS ( Test routine for SPKPDS ) */
/* Subroutine */ int f_spkpds__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer body;
    doublereal last;
    integer type__, nums[6];
    char frame[8];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal descr[5];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    char chtmp[8];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal first;
    integer intmp;
    extern /* Subroutine */ int t_success__(logical *);
    doublereal dptmp1, dptmp2;
    extern /* Subroutine */ int chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen);
    integer refcod;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    integer center;
    extern /* Subroutine */ int spkpds_(integer *, integer *, char *, integer 
	    *, doublereal *, doublereal *, doublereal *, ftnlen);
    doublereal dps[2];

/* $ Abstract */

/*     This routine tests the behavior of the routine SPKPDS. */

/*     First all of the cited exceptions are checked. */
/*     Finally, we do a simple check to make sure the descriptor */
/*     has the expected values when we unpack it. */

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
    topen_("F_SPKPDS", (ftnlen)8);

/*     Set up a legitimate set of inputs and then corrupt them */
/*     one at a time to trigger errors. */

    body = 399;
    center = 3;
    s_copy(frame, "J2000", (ftnlen)8, (ftnlen)5);
    refcod = 1;
    type__ = 3;
    first = -1e6;
    last = 1e6;

/*     Now we modify one of each value to trigger an exception.  We */
/*     always set the value back to the original value when we get */
/*     done with a test case so that we only have to modify a single */
/*     term in the next test case. */

    tcase_("Exception: Ephemeris for Solar System Barycenter", (ftnlen)48);
    intmp = body;
    body = 0;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(BARYCENTEREPHEM)", ok, (ftnlen)22);
    body = intmp;
    tcase_("Exception: Body and Center the same.", (ftnlen)36);
    intmp = center;
    center = body;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(BODYANDCENTERSAME)", ok, (ftnlen)24);
    center = intmp;
    tcase_("Exception: Invalid Reference Frame", (ftnlen)34);
    s_copy(chtmp, frame, (ftnlen)8, (ftnlen)8);
    s_copy(frame, "J3000", (ftnlen)8, (ftnlen)5);
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(INVALIDREFFRAME)", ok, (ftnlen)22);
    s_copy(frame, chtmp, (ftnlen)8, (ftnlen)8);
    tcase_("Exception: Start and Stop times out of order", (ftnlen)44);
    dptmp1 = first;
    dptmp2 = last;
    first = 1e6;
    last = -1e6;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(BADDESCRTIMES)", ok, (ftnlen)20);
    first = dptmp1;
    last = dptmp2;
    tcase_("Exception: Unknown SPK data type 1001.", (ftnlen)38);
    intmp = type__;
    type__ = 1001;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(UNKNOWNSPKTYPE)", ok, (ftnlen)21);
    type__ = intmp;
    tcase_("Exception: Unknown SPK data type 0.", (ftnlen)35);
    intmp = type__;
    type__ = 0;
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    chckxc_(&c_true, "SPICE(UNKNOWNSPKTYPE)", ok, (ftnlen)21);
    type__ = intmp;
    tcase_("Check Contents of descriptor", (ftnlen)28);
    spkpds_(&body, &center, frame, &type__, &first, &last, descr, (ftnlen)8);
    dafus_(descr, &c__2, &c__6, dps, nums);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksd_("FIRST", &first, "=", dps, &c_b30, ok, (ftnlen)5, (ftnlen)1);
    chcksd_("LAST", &last, "=", &dps[1], &c_b30, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("BODY", &body, "=", nums, &c__0, ok, (ftnlen)4, (ftnlen)1);
    chcksi_("CENTER", &center, "=", &nums[1], &c__0, ok, (ftnlen)6, (ftnlen)1)
	    ;
    chcksi_("REFCOD", &refcod, "=", &nums[2], &c__0, ok, (ftnlen)6, (ftnlen)1)
	    ;
    chcksi_("TYPE", &type__, "=", &nums[3], &c__0, ok, (ftnlen)4, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_spkpds__ */

