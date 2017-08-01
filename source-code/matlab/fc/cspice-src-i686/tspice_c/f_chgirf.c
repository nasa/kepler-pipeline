/* f_chgirf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__9 = 9;
static doublereal c_b12 = 1e-15;
static doublereal c_b15 = 0.;
static integer c__100 = 100;
static integer c__0 = 0;
static integer c__21 = 21;
static integer c_n1 = -1;
static doublereal c_b71 = 1e-14;
static doublereal c_b75 = 1e-13;
static doublereal c_b84 = 2e-14;

/* $Procedure      F_CHGIRF (Family of tests for CHGIRF ) */
/* Subroutine */ int f_chgirf__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char name__[32];
    doublereal axis[3];
    extern /* Subroutine */ int irfnam_o__(integer *, char *, ftnlen), mtxm_(
	    doublereal *, doublereal *, doublereal *), mxmt_(doublereal *, 
	    doublereal *, doublereal *);
    doublereal rott[9]	/* was [3][3] */;
    extern /* Subroutine */ int irfrot_o__(integer *, integer *, doublereal *)
	    ;
    doublereal a[3];
    integer i__, j, k;
    extern integer cardc_(char *, ftnlen);
    doublereal angle;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char expct[32];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer count;
    doublereal xform[9]	/* was [3][3] */;
    extern /* Subroutine */ int t_success__(logical *);
    integer id;
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chcksc_(char *, char *, char *, char *, logical *, ftnlen, 
	    ftnlen, ftnlen, ftnlen), chcksd_(char *, doublereal *, char *, 
	    doublereal *, doublereal *, logical *, ftnlen, ftnlen), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen), irfnam_(
	    integer *, char *, ftnlen);
    char newnam[32*20];
    extern /* Subroutine */ int raxisa_(doublereal *, doublereal *, 
	    doublereal *);
    doublereal rotate[9]	/* was [3][3] */;
    extern /* Subroutine */ int ssizec_(integer *, char *, ftnlen), irfnum_(
	    char *, integer *, ftnlen), insrtc_(char *, char *, ftnlen, 
	    ftnlen);
    doublereal matrix[9]	/* was [3][3] */;
    extern /* Subroutine */ int irfrot_(integer *, integer *, doublereal *), 
	    tstmsc_(char *, ftnlen), tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstmsi_(integer *);
    doublereal quotnt[9]	/* was [3][3] */;
    char new__[32*106];
    doublereal rot[9]	/* was [3][3] */;

/* $ Abstract */

/*     This test performs regressions on the SPICE routine CHGIRF. */
/*     To update it you should retrieve the last version of CHGIRF */
/*     and append an underscore O "Oh" to each entry point.  This */
/*     is the OLD version of the routine. */

/*     You should also update the number of previously known frames */
/*     to the values in the old version of CHGIRF. */

/*     Add whatever tests are appropriate for the new reference */
/*     frames or entry points. */

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

/*     The parameter ONAMES is the number of recognized reference */
/*     frames that were present in the previous version of CHGIRF */


/*     The parameter NNAMES is the number of recognized reference */
/*     frames that are present in the updated version of CHGIRF */
/*     that you are attempting to test. */


/*     The array NEWNAM contains the names of the reference frames */
/*     that are in the updated version of CHGIRF that were not */
/*     in the previous version of CHGIRF. */

/*     Set the values of the entries of this array in the first block */
/*     of executable code below. */


/*     Bad is an ID code for a frame that should not be recognized */
/*     by CHGIRF. */


/*     Test Utility Functions */


/*     SPICELIB Functions */


/*     Local Variables */


/*     The names that are new to CHGIRF should be placed here. */

    s_copy(newnam, "DE-143", (ftnlen)32, (ftnlen)6);

/*     Begin every test family with an open call. */

    topen_("F_CHGIRF", (ftnlen)8);
    tcase_("Comparison of old and new transformations.", (ftnlen)42);
    for (i__ = 1; i__ <= 20; ++i__) {
	for (j = 1; j <= 20; ++j) {
	    tstmsg_("#", "Subcase I = #, J = #", (ftnlen)1, (ftnlen)20);
	    tstmsi_(&i__);
	    tstmsi_(&j);
	    irfrot_(&i__, &j, rotate);
	    irfrot_o__(&i__, &j, matrix);
	    mtxm_(matrix, rotate, quotnt);
	    raxisa_(quotnt, axis, &angle);
	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chckad_("ROTATE", rotate, "~", matrix, &c__9, &c_b12, ok, (ftnlen)
		    6, (ftnlen)1);
	    chcksd_("ANGLE", &angle, "~", &c_b15, &c_b12, ok, (ftnlen)5, (
		    ftnlen)1);
	}
    }
    tcase_("Converting from id to name and back.", (ftnlen)36);
    ssizec_(&c__100, new__, (ftnlen)32);
    for (i__ = 1; i__ <= 21; ++i__) {
	j = i__;
	irfnam_(&j, name__, (ftnlen)32);
	irfnum_(name__, &k, (ftnlen)32);
	insrtc_(name__, new__, (ftnlen)32, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("J", &j, "=", &k, &c__0, ok, (ftnlen)1, (ftnlen)1);
    }
    count = cardc_(new__, (ftnlen)32);
    chcksi_("NameCount", &count, "=", &c__21, &c__0, ok, (ftnlen)9, (ftnlen)1)
	    ;
    tcase_("Converting old names to ID's.", (ftnlen)29);
    for (i__ = 1; i__ <= 20; ++i__) {
	j = i__;
	irfnam_o__(&j, name__, (ftnlen)32);
	irfnum_(name__, &k, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("ID Code", &k, "=", &j, &c__0, ok, (ftnlen)7, (ftnlen)1);
    }
    tcase_("Comparing new and old names.", (ftnlen)28);
    for (i__ = 1; i__ <= 20; ++i__) {
	j = i__;
	irfnam_(&j, name__, (ftnlen)32);
	irfnam_o__(&j, expct, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("NAME", name__, "=", expct, ok, (ftnlen)4, (ftnlen)32, (
		ftnlen)1, (ftnlen)32);
    }
    tcase_("Checking new names. ", (ftnlen)20);

/*        To update this case simply put the new names in the array below */
/*        in the order of their id-codes. */

    k = 0;
    for (i__ = 21; i__ <= 21; ++i__) {
	j = i__;
	++k;
	tstmsg_("#", "Subcase ID = #, NEWNAM = #", (ftnlen)1, (ftnlen)26);
	tstmsi_(&j);
	tstmsc_(newnam + (((i__1 = k - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge(
		"newnam", i__1, "f_chgirf__", (ftnlen)214)) << 5), (ftnlen)32)
		;
	irfnam_(&j, name__, (ftnlen)32);
	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksc_("NAME", name__, "=", newnam + (((i__1 = k - 1) < 20 && 0 <= 
		i__1 ? i__1 : s_rnge("newnam", i__1, "f_chgirf__", (ftnlen)
		218)) << 5), ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;
    }
    tcase_("Unknown ID-code", (ftnlen)15);
    irfnam_(&c_n1, name__, (ftnlen)32);
    tstmsg_("#", " ", (ftnlen)1, (ftnlen)1);
    chcksc_("NAME", name__, "=", " ", ok, (ftnlen)4, (ftnlen)32, (ftnlen)1, (
	    ftnlen)1);
    tcase_("Unknown Name", (ftnlen)12);
    irfnum_("BOGUS", &id, (ftnlen)5);
    chcksi_("ID", &id, "=", &c__0, &c__0, ok, (ftnlen)2, (ftnlen)1);
    tcase_("DE-140 check", (ftnlen)12);
    xform[0] = .9999256765384668;
    xform[1] = -.0111817701797229;
    xform[2] = -.004858952020483;
    xform[3] = .0111817701197967;
    xform[4] = .9999374816848701;
    xform[5] = -2.71791849815e-5;
    xform[6] = .0048589521583895;
    xform[7] = -2.71545195858e-5;
    xform[8] = .9999881948535965;
    irfnum_("J2000", &j, (ftnlen)5);
    irfnum_("DE-140", &i__, (ftnlen)6);
    irfrot_(&j, &i__, rott);
    mxmt_(xform, rott, rot);
    raxisa_(rot, a, &angle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("ROTATE", rott, "~", xform, &c__9, &c_b71, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksd_("ANGLE", &angle, "~", &c_b15, &c_b75, ok, (ftnlen)5, (ftnlen)1);
    tcase_("DE-142 check", (ftnlen)12);
    xform[0] = .9999256765402605;
    xform[1] = -.0111817697907755;
    xform[2] = -.0048589525464121;
    xform[3] = .0111817697320531;
    xform[4] = .9999374816892126;
    xform[5] = -2.71789392288e-5;
    xform[6] = .0048589526815484;
    xform[7] = -2.7154769317e-5;
    xform[8] = .9999881948510477;
    irfnum_("J2000", &j, (ftnlen)5);
    irfnum_("DE-142", &i__, (ftnlen)6);
    irfrot_(&j, &i__, rott);
    mxmt_(xform, rott, rot);
    raxisa_(rot, a, &angle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("ROTATE", rott, "~", xform, &c__9, &c_b84, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksd_("ANGLE", &angle, "~", &c_b15, &c_b75, ok, (ftnlen)5, (ftnlen)1);
    tcase_("DE-143 check", (ftnlen)12);
    xform[0] = .9999256765435852;
    xform[1] = -.0111817743300355;
    xform[2] = -.0048589414161348;
    xform[3] = .0111817743077255;
    xform[4] = .9999374816382505;
    xform[5] = -2.71713942366e-5;
    xform[6] = .0048589414674762;
    xform[7] = -2.71622115251e-5;
    xform[8] = .9999881949053349;
    irfnum_("J2000", &j, (ftnlen)5);
    irfnum_("DE-143", &i__, (ftnlen)6);
    irfrot_(&j, &i__, rott);
    mxmt_(xform, rott, rot);
    raxisa_(rot, a, &angle);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("ROTATE", rott, "~", xform, &c__9, &c_b84, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksd_("ANGLE", &angle, "~", &c_b15, &c_b75, ok, (ftnlen)5, (ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_chgirf__ */

