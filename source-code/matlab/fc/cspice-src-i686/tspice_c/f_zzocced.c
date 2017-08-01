/* f_zzocced.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__9 = 9;
static logical c_false = FALSE_;
static integer c__0 = 0;
static doublereal c_b677 = 1.;
static doublereal c_b678 = 2.;
static doublereal c_b679 = 3.;
static doublereal c_b681 = 2.1;
static doublereal c_b684 = -2.1;
static logical c_true = TRUE_;
static doublereal c_b692 = -2.;
static doublereal c_b705 = 10.;
static doublereal c_b712 = 1.1;
static doublereal c_b750 = -1.1;

/* $Procedure      F_ZZOCCED ( Test ellipsoid occultation routine ) */
/* Subroutine */ int f_zzocced__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    double sqrt(doublereal);

    /* Local variables */
    integer code;
    doublereal octr1[3], octr2[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer xcode;
    extern /* Subroutine */ int ident_(doublereal *), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    char title[255];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    doublereal oview[3];
    extern /* Subroutine */ int t_success__(logical *);
    doublereal centr1[3], centr2[3], semax1[9]	/* was [3][3] */, semax2[9]	
	    /* was [3][3] */;
    extern /* Subroutine */ int cleard_(integer *, doublereal *), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen);
    doublereal viewpt[3];
    extern /* Subroutine */ int xinput_(doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *);
    extern integer zzocced_(doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *);
    doublereal oax1[9]	/* was [3][3] */, oax2[9]	/* was [3][3] */;

/* $ Abstract */

/*     This routine tests the SPICELIB routine */

/*        ZZOCCED */

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

/* -    TSPICE Version 1.0.0, 08-AUG-2005 (NJB) */

/* -& */

/*     SPICELIB functions */

/* $ Abstract */

/*     Declare ZZOCCED return code parameters, comparison strings */
/*     and other parameters. */

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

/*     GF */

/* $ Keywords */

/*     ELLIPSOID */
/*     GEOMETRY */
/*     GF */
/*     OCCULTATION */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 01-SEP-2005 (NJB) */

/* -& */
/*     The function returns an integer code indicating the geometric */
/*     relationship of the three bodies. */

/*     Codes and meanings are: */

/*        -3                    Total occultation of first target by */
/*                              second. */


/*        -2                    Annular occultation of first target by */
/*                              second.  The second target does not */
/*                              block the limb of the first. */


/*        -1                    Partial occultation of first target by */
/*                              second target. */


/*         0                    No occultation or transit:  both objects */
/*                              are completely visible to the observer. */


/*         1                    Partial occultation of second target by */
/*                              first target. */


/*         2                    Annular occultation of second target by */
/*                              first. */


/*         3                    Total occultation of second target by */
/*                              first. */


/*     End include file zzocced.inc */


/*     Local parameters */


/*     Local variables */


/*     Saved variables */


/*     Initial values */


/*     Begin every test family with an open call. */

    topen_("F_ZZOCCED", (ftnlen)9);

/*     We're going to start out with some very basic cases involving */
/*     spheres.  These will exercise the bounding code logic. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Disjoint spheres.  This should be handled using maximum b"
	    "ounding cones.", (ftnlen)255, (ftnlen)71);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */

    ident_(semax1);
    cleard_(&c__9, semax2);
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;

/*     Assign the centers of the spheres. */

    centr1[0] = 0.;
    centr1[1] = -2.;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 4.;
    centr2[2] = 0.;

/*     Assign the viewing point. */

    viewpt[0] = 10.;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation to be found. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Total occultation of first object by the second. This sho"
	    "uld be handled using minimum and maximum bounding cones.", (
	    ftnlen)255, (ftnlen)113);
    tcase_(title, (ftnlen)255);

/*     Assign the centers of the spheres. */

    centr1[0] = 0.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 5.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first sphere */
/*     by the second to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Total occultation of second object by the first. Switch s"
	    "emi-axis matrices.", (ftnlen)255, (ftnlen)75);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second sphere */
/*     by the first to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Annular transit of first body across the second. This sho"
	    "uld be handled using minimum and maximum bounding cones.", (
	    ftnlen)255, (ftnlen)113);
    tcase_(title, (ftnlen)255);

/*     Assign the centers of the spheres. */

    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit of the first sphere */
/*     across the second to be found. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Annular transit of second body across the first. Switch a"
	    "rguments.", (ftnlen)255, (ftnlen)66);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the first sphere */
/*     by the second to be found. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Partial occultation of first body by the second.", (ftnlen)
	    255, (ftnlen)48);
    tcase_(title, (ftnlen)255);
    centr1[0] = -4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 2.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation of the first sphere */
/*     by the second to be found. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Partial occultation of second body by the first. Switch c"
	    "enters and semi-axis matrices.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation of the second sphere */
/*     by the first to be found. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     At this point, we've done all we can with spherical targets. */
/*     We'll make the smaller ellipsoid prolate with vertical */
/*     sem-axis length 1.5. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  disjoint case", (ftnlen)255, (
	    ftnlen)42);
    tcase_(title, (ftnlen)255);
    semax1[8] = 1.5;
    centr1[0] = 0.;
    centr1[1] = -1.1;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation to be found. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Occultation is total. This is a minimum angular separatio"
	    "n case requiring a call to ZZASRYEL.", (ftnlen)255, (ftnlen)93);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    centr1[0] = -5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first ellipsoid to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Occultation is total. This is a minimum angular separatio"
	    "n case requiring a call to ZZASRYEL.  Switch roles of first and "
	    "second targets.", (ftnlen)255, (ftnlen)136);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second ellipsoid to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of small ellipsoid is annular. This is a minimum a"
	    "ngular separation case requiring a call to ZZASRYEL.", (ftnlen)
	    255, (ftnlen)173);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    semax2[4] = .5;
    semax2[8] = .5;
    centr1[0] = -5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the first ellipsoid to be */
/*     found. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of small ellipsoid is annular. This is a minimum a"
	    "ngular separation case requiring a call to ZZASRYEL. Switch role"
	    "s of first and second targets.", (ftnlen)255, (ftnlen)215);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the second ellipsoid to be */
/*     found. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of large ellipsoid is total. This is a minimum ang"
	    "ular separation case requiring a call to ZZASRYEL.", (ftnlen)255, 
	    (ftnlen)171);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    semax2[4] = .5;
    semax2[8] = .5;
    centr1[0] = 5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second ellipsoid to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of large ellipsoid is total. This is a minimum ang"
	    "ular separation case requiring a call to ZZASRYEL. Switch roles "
	    "of first and second targets.", (ftnlen)255, (ftnlen)213);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first ellipsoid to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by large ellipsoid.", (ftnlen)255, (ftnlen)86);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = .75;
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;
    centr1[0] = 0.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 5.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the large ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by large ellipsoid.  Switch argument positions.", (
	    ftnlen)255, (ftnlen)114);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the large ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.", (ftnlen)255, (ftnlen)86);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = .75;
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;
    centr1[0] = 5.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.  Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)118);
    tcase_(title, (ftnlen)255);
    semax1[8] = .75;
    centr1[0] = 5.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  annular transit of small ell"
	    "ipsoid across large ellipsoid.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    cleard_(&c__9, semax2);
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 4.5;
    centr1[0] = 1.5;
    centr1[1] = 1.1;
    centr1[2] = 0.;
    centr2[0] = -3.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the small ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  annular transit of small ell"
	    "ipsoid across large ellipsoid. Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)118);
    tcase_(title, (ftnlen)255);
    semax1[8] = 1.5;
    semax2[8] = 4.5;
    centr1[0] = 1.5;
    centr1[1] = 1.1;
    centr1[2] = 0.;
    centr2[0] = -3.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the small ellipsoid in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  total occultation of big elli"
	    "psoid by small ellipsoid.  This case requires determination of m"
	    "aximum angular separation.", (ftnlen)255, (ftnlen)147);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = .1;
    semax2[8] = .2;
    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 2.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the small ellipsoid in front. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  total occultation of big elli"
	    "psoid by small ellipsoid.  This case requires determination of m"
	    "aximum angular separation. Switch arguments.", (ftnlen)255, (
	    ftnlen)165);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the small ellipsoid in front. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  annular transit by big ellips"
	    "oid across small ellipsoid.  This case requires determination of"
	    " maximum angular separation.", (ftnlen)255, (ftnlen)149);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = .1;
    semax2[8] = .15;
    centr1[0] = -2.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 4.;
    centr2[1] = 2.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the big ellipsoid in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  annular transit by big ellips"
	    "oid across small ellipsoid.  This case requires determination of"
	    " maximum angular separation.Switch arguments.", (ftnlen)255, (
	    ftnlen)166);
    tcase_(title, (ftnlen)255);
    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the big ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by big ellipsoid.  This case requires determination of"
	    " maximum angular separation.", (ftnlen)255, (ftnlen)149);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = 1.;
    semax2[8] = 2.;
    centr1[0] = -2.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 4.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the big ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by big ellipsoid.  This case requires determination of"
	    " maximum angular separation. Switch arguments.", (ftnlen)255, (
	    ftnlen)167);
    tcase_(title, (ftnlen)255);
/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the big ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.  This case requires determination "
	    "of maximum angular separation.", (ftnlen)255, (ftnlen)151);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = 1.;
    semax2[8] = 2.;
    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.   This case requires determination"
	    " of maximum angular separation. Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)183);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #1:  annular transit across large ellips"
	    "oid by small ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*     Side view of "potato chip" ellipsoids: */


/*        Annular transit: */

/*                               * */
/*                         *   * */
/*                       *   * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */

/*     Observe that the center of the small ellipsoid is actually further */
/*     from the viewing point than the center of the large ellipsoid. */


/*     Set up the semi-axis matrices. */


/*     The first ellipsoid is the small potato chip. */

    semax1[0] = 1e-8;
    semax1[1] = 0.;
    semax1[2] = 1e-8;
    semax1[3] = 0.;
    semax1[4] = sqrt(2.);
    semax1[5] = 0.;
    semax1[6] = -1.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     The large chip is 10 times larger. */

    semax2[0] = 1e-7;
    semax2[1] = 0.;
    semax2[2] = 1e-7;
    semax2[3] = 0.;
    semax2[4] = sqrt(2.) * 10.;
    semax2[5] = 0.;
    semax2[6] = -10.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -3.;
    centr1[1] = 0.;
    centr1[2] = 7.;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point. */

    viewpt[0] = 50.;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #2:  annular transit across large ellips"
	    "oid by small ellipsoid. Switch arguments.", (ftnlen)255, (ftnlen)
	    98);
    tcase_(title, (ftnlen)255);

/*     We expect an annular transit with the second ellipsoid in front. */

    xcode = -2;
    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #3:  total occultation of small ellipsoi"
	    "d by large ellipsoid.", (ftnlen)255, (ftnlen)78);
    tcase_(title, (ftnlen)255);


/*        Total occultation: */

/*                               * */
/*                             *   * */
/*                           *   * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -11.;
    centr1[1] = 0.;
    centr1[2] = 7.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the second ellipsoid in front. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #4:  total occultation of small ellipsoi"
	    "d by large ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)95);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the first ellipsoid in front. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #5:  partial occultation of small ellips"
	    "oid by large ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*        Partial occultation, small chip is in back: */

/*                                   * */
/*                               * * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -13.;
    centr1[1] = 0.;
    centr1[2] = 11.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second ellipsoid in */
/*     front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #6:  partial occultation of small ellips"
	    "oid by large ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)
	    97);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #7:  partial occultation of large ellips"
	    "oid by small ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*        Partial occultation, small chip is in front: */


/*                            *  * */
/*                          *  * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -7.;
    centr1[1] = 0.;
    centr1[2] = 9.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #8:  partial occultation of large ellips"
	    "oid by small ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)
	    97);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second ellipsoid in */
/*     front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #9:  no occultation of large ellipsoid b"
	    "y small ellipsoid.  Small target is in front.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*        No occultation, small chip is in front: */


/*                            * */
/*                          *    * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -7.;
    centr1[1] = 0.;
    centr1[2] = 11.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #10:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in front.Switch arguments.", 
	    (ftnlen)255, (ftnlen)120);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #11:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in back.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*        No occultation, small chip is in back: */


/*                                   * */
/*                                 * */
/*                               * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -13.;
    centr1[1] = 0.;
    centr1[2] = 13.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #12:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in back.Switch arguments.", (
	    ftnlen)255, (ftnlen)119);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     The next series of tests exercises the logical branches of */
/*     ZZOCCED that deal with cases where the maximum angular separation */
/*     between the limb of the small target and the ray from the viewing */
/*     point to center of the large target is sought. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #1:  large ellipsoid tota"
	    "lly occults small ellipsoid.", (ftnlen)255, (ftnlen)85);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */


/*     The first ellipsoid is elongated in the y-direction and flattened */
/*     in the z-direction.  The ellipsoid is situated near the +z */
/*     portion of the limb of the large ellipsoid. This prevents a */
/*     simple bounding cone test from proving the ellipsoid is occulted. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 1.;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = .01;

/*     The large target is a large sphere. This ensures that the linear */
/*     transformation performed by ZZOCCED doesn't change the shape of */
/*     either target. */

    semax2[0] = 10.;
    semax2[1] = 0.;
    semax2[2] = 0.;
    semax2[3] = 0.;
    semax2[4] = 10.;
    semax2[5] = 0.;
    semax2[6] = 0.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point.  We set the viewing point far back */
/*     to reduce parallax. */

    viewpt[0] = 1e3;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the second target. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #2:  large ellipsoid tota"
	    "lly occults small ellipsoid.Switch arguments.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the first target. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #3:  small ellipsoid is i"
	    "n annular transit across large ellipsoid.", (ftnlen)255, (ftnlen)
	    98);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first target in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #4:  small ellipsoid is i"
	    "n annular transit across large ellipsoid.Switch arguments.", (
	    ftnlen)255, (ftnlen)115);
    tcase_(title, (ftnlen)255);
/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the second target in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #5:  small ellipsoid part"
	    "ially occults large ellipsoid.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .001;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 4.5;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = .001;

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #6:  small ellipsoid part"
	    "ially occults large ellipsoid. Switch arguments.", (ftnlen)255, (
	    ftnlen)105);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #7:  small ellipsoid is p"
	    "artially occulted by large ellipsoid.", (ftnlen)255, (ftnlen)94);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #8:  small ellipsoid is p"
	    "artially occulted by large ellipsoid. Switch arguments.", (ftnlen)
	    255, (ftnlen)112);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     The next set of cases all have negative maximum angular */
/*     separation between the limb of the small target and the ray from */
/*     the viewing point to center of the large target:  the ray */
/*     passes through the plane region bounded by the limb of the */
/*     small target. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #9:  large ellipsoid tota"
	    "lly occults small ellipsoid. Maximum angular separation is negat"
	    "ive.", (ftnlen)255, (ftnlen)125);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */

/*     The small ellipsoid is elongated in the y-direction and flattened */
/*     in the z-direction.  The ellipsoid is situated near the x-z plane */
/*     with the center displaced in the +z direction. The small */
/*     ellipsoid is penetrated by the -x axis. The small ellipsoid has */
/*     sufficient extent in the y direction such that, if it were */
/*     rotated 90 degrees about the x-axis, it would not be totally */
/*     occulted.  This prevents a simple bounding cone test from proving */
/*     the ellipsoid is occulted. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 9.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     The large target is a large sphere. This ensures that the linear */
/*     transformation performed by ZZOCCED doesn't change the shape of */
/*     either target. */

    semax2[0] = 10.;
    semax2[1] = 0.;
    semax2[2] = 0.;
    semax2[3] = 0.;
    semax2[4] = 10.;
    semax2[5] = 0.;
    semax2[6] = 0.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 1.;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point.  We set the viewing point far back */
/*     to reduce parallax. */

    viewpt[0] = 1e3;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the second target. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #10:  large ellipsoid tot"
	    "ally occults small ellipsoid. Maximum angular separation is nega"
	    "tive. Switch arguments.", (ftnlen)255, (ftnlen)144);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the first target. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #11:  small ellipsoid is "
	    "in annular transit across large ellipsoid; maximum angular separ"
	    "ation is negative.", (ftnlen)255, (ftnlen)139);
    tcase_(title, (ftnlen)255);
/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first target in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #12:  small ellipsoid is "
	    "in annular transit across large ellipsoid; maximum angular separ"
	    "ation is negative. Switch arguments.", (ftnlen)255, (ftnlen)157);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the second target in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #13:  small ellipsoid par"
	    "tially occults large ellipsoid; maximum angular separation is ne"
	    "gative.", (ftnlen)255, (ftnlen)128);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 10.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #14:  small ellipsoid par"
	    "tially occults large ellipsoid; maximum angular separation is ne"
	    "gative. Switch arguments.", (ftnlen)255, (ftnlen)146);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #15:  small ellipsoid is "
	    "partially occulted by large ellipsoid; maximum angular separatio"
	    "n is negative.", (ftnlen)255, (ftnlen)135);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 10.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #16:  small ellipsoid is "
	    "partially occulted by large ellipsoid; maximum angular separatio"
	    "n is negative. Switch arguments.", (ftnlen)255, (ftnlen)153);
    tcase_(title, (ftnlen)255);

/*     Classify the occultation. */

    code = zzocced_(viewpt, centr2, semax2, centr1, semax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);
/* ******* */
/* ******* */
/* ******* */
/* *******  At this point, we've finished with the simple cases that */
/* *******  exercise all of the classification logic.  These simple */
/* *******  cases had the semi-axis matrices aligned with the standard */
/* *******  basis; they also employed other simplifications such as */
/* *******  placing the viewing location on the x-axis. */
/* ******* */
/* *******  Now we'll repeat the tests with inputs transformed as */
/* *******  follows: */
/* ******* */
/* *******     - The semi-axis matrices of the ellipsoids will have */
/* *******       their columns permuted so that these matrices won't */
/* *******       have diagonal form. */
/* ******* */
/* *******       * The semi-axes of the first ellipsoid will be permuted */
/* *******         by a (312) permutation. */
/* ******* */
/* *******       * The semi-axes of the second ellipsoid will be permuted */
/* *******         by a (231) permutation. */
/* ******* */
/* *******     - All vectors, including the columns of the permuted */
/* *******       semi-axis matrices, will be rotated by a non-trivial */
/* *******       3-1-3 rotation. */
/* ******* */
/* *******     - The viewing location and the ellipsoid centers will */
/* *******       be translated by an offset vector. */
/* ******* */
/* *******  All of these tranformations preserve the viewing geometry, */
/* *******  so each test case should produce the same occultation */
/* *******  classification as the corresponding case above using "simple" */
/* *******  inputs. */
/* ******* */

/*     We're going to start out with some very basic cases involving */
/*     spheres.  These will exercise the bounding code logic. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Disjoint spheres.  This should be handled using maximum b"
	    "ounding cones.", (ftnlen)255, (ftnlen)71);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */

    ident_(semax1);
    cleard_(&c__9, semax2);
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;

/*     Assign the centers of the spheres. */

    centr1[0] = 0.;
    centr1[1] = -2.;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 4.;
    centr2[2] = 0.;

/*     Assign the viewing point. */

    viewpt[0] = 10.;
    viewpt[1] = 0.;
    viewpt[2] = 0.;


/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation to be found. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Total occultation of first object by the second. This sho"
	    "uld be handled using minimum and maximum bounding cones.", (
	    ftnlen)255, (ftnlen)113);
    tcase_(title, (ftnlen)255);

/*     Assign the centers of the spheres. */

    centr1[0] = 0.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 5.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first sphere */
/*     by the second to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Total occultation of second object by the first. Switch t"
	    "argets.", (ftnlen)255, (ftnlen)64);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second sphere */
/*     by the first to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Annular transit of first body across the second. This sho"
	    "uld be handled using minimum and maximum bounding cones.", (
	    ftnlen)255, (ftnlen)113);
    tcase_(title, (ftnlen)255);

/*     Assign the centers of the spheres. */

    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit of the first sphere */
/*     across the second to be found. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Annular transit of second body across the first. Switch a"
	    "rguments.", (ftnlen)255, (ftnlen)66);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the first sphere */
/*     by the second to be found. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Partial occultation of first body by the second.", (ftnlen)
	    255, (ftnlen)48);
    tcase_(title, (ftnlen)255);
    centr1[0] = -4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 2.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation of the first sphere */
/*     by the second to be found. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Partial occultation of second body by the first. Switch c"
	    "enters and semi-axis matrices.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation of the second sphere */
/*     by the first to be found. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     At this point, we've done all we can with spherical targets. */
/*     We'll make the smaller ellipsoid prolate with vertical */
/*     sem-axis length 1.5. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  disjoint case", (ftnlen)255, (
	    ftnlen)42);
    tcase_(title, (ftnlen)255);
    semax1[8] = 1.5;
    centr1[0] = 0.;
    centr1[1] = -1.1;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation to be found. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Occultation is total. This is a minimum angular separatio"
	    "n case requiring a call to ZZASRYEL.", (ftnlen)255, (ftnlen)93);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    centr1[0] = -5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first ellipsoid to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Occultation is total. This is a minimum angular separatio"
	    "n case requiring a call to ZZASRYEL.  Switch roles of first and "
	    "second targets.", (ftnlen)255, (ftnlen)136);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second ellipsoid to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of small ellipsoid is annular. This is a minimum a"
	    "ngular separation case requiring a call to ZZASRYEL.", (ftnlen)
	    255, (ftnlen)173);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    semax2[4] = .5;
    semax2[8] = .5;
    centr1[0] = -5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the first ellipsoid to be */
/*     found. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of small ellipsoid is annular. This is a minimum a"
	    "ngular separation case requiring a call to ZZASRYEL. Switch role"
	    "s of first and second targets.", (ftnlen)255, (ftnlen)215);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular occultation of the second ellipsoid to be */
/*     found. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of large ellipsoid is total. This is a minimum ang"
	    "ular separation case requiring a call to ZZASRYEL.", (ftnlen)255, 
	    (ftnlen)171);
    tcase_(title, (ftnlen)255);
    semax1[0] = 4.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    semax2[0] = 5.;
    semax2[4] = .5;
    semax2[8] = .5;
    centr1[0] = 5.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -6.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Set the viewing point far away to avoid parallax problems. */

    viewpt[0] = 50.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the second ellipsoid to be found. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid presents larger limb than large ellipsoid"
	    "; occultation of large ellipsoid is total. This is a minimum ang"
	    "ular separation case requiring a call to ZZASRYEL. Switch roles "
	    "of first and second targets.", (ftnlen)255, (ftnlen)213);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation of the first ellipsoid to be found. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by large ellipsoid.", (ftnlen)255, (ftnlen)86);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = .75;
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;
    centr1[0] = 0.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 5.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the large ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by large ellipsoid.  Switch argument positions.", (
	    ftnlen)255, (ftnlen)114);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the large ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.", (ftnlen)255, (ftnlen)86);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = .75;
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 3.;
    centr1[0] = 5.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.  Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)118);
    tcase_(title, (ftnlen)255);
    semax1[8] = .75;
    centr1[0] = 5.;
    centr1[1] = -.8;
    centr1[2] = 0.;
    centr2[0] = 0.;
    centr2[1] = 3.1;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  annular transit of small ell"
	    "ipsoid across large ellipsoid.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.5;
    cleard_(&c__9, semax2);
    semax2[0] = 3.;
    semax2[4] = 3.;
    semax2[8] = 4.5;
    centr1[0] = 1.5;
    centr1[1] = 1.1;
    centr1[2] = 0.;
    centr2[0] = -3.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the small ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is prolate:  annular transit of small ell"
	    "ipsoid across large ellipsoid. Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)118);
    tcase_(title, (ftnlen)255);
    semax1[8] = 1.5;
    semax2[8] = 4.5;
    centr1[0] = 1.5;
    centr1[1] = 1.1;
    centr1[2] = 0.;
    centr2[0] = -3.;
    centr2[1] = 3.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the small ellipsoid in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  total occultation of big elli"
	    "psoid by small ellipsoid.  This case requires determination of m"
	    "aximum angular separation.", (ftnlen)255, (ftnlen)147);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = .1;
    semax2[8] = .2;
    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 2.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the small ellipsoid in front. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  total occultation of big elli"
	    "psoid by small ellipsoid.  This case requires determination of m"
	    "aximum angular separation. Switch arguments.", (ftnlen)255, (
	    ftnlen)165);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the small ellipsoid in front. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  annular transit by big ellips"
	    "oid across small ellipsoid.  This case requires determination of"
	    " maximum angular separation.", (ftnlen)255, (ftnlen)149);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = .1;
    semax2[8] = .15;
    centr1[0] = -2.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 4.;
    centr2[1] = 2.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the big ellipsoid in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  annular transit by big ellips"
	    "oid across small ellipsoid.  This case requires determination of"
	    " maximum angular separation.Switch arguments.", (ftnlen)255, (
	    ftnlen)166);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the big ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by big ellipsoid.  This case requires determination of"
	    " maximum angular separation.", (ftnlen)255, (ftnlen)149);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = 1.;
    semax2[8] = 2.;
    centr1[0] = -2.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = 4.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the big ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of small "
	    "ellipsoid by big ellipsoid.  This case requires determination of"
	    " maximum angular separation. Switch arguments.", (ftnlen)255, (
	    ftnlen)167);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the big ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.  This case requires determination "
	    "of maximum angular separation.", (ftnlen)255, (ftnlen)151);
    tcase_(title, (ftnlen)255);
    semax1[0] = 1.;
    semax1[4] = 3.;
    semax1[8] = .75;
    semax2[0] = 4.;
    semax2[4] = 1.;
    semax2[8] = 2.;
    centr1[0] = 4.;
    centr1[1] = 0.;
    centr1[2] = 0.;
    centr2[0] = -2.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Small ellipsoid is oblate:  partial occultation of large "
	    "ellipsoid by small ellipsoid.   This case requires determination"
	    " of maximum angular separation. Switch positions of arguments.", (
	    ftnlen)255, (ftnlen)183);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the small ellipsoid in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #1:  annular transit across large ellips"
	    "oid by small ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*     Side view of "potato chip" ellipsoids: */


/*        Annular transit: */

/*                               * */
/*                         *   * */
/*                       *   * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */

/*     Observe that the center of the small ellipsoid is actually further */
/*     from the viewing point than the center of the large ellipsoid. */


/*     Set up the semi-axis matrices. */


/*     The first ellipsoid is the small potato chip. */

    semax1[0] = 1e-8;
    semax1[1] = 0.;
    semax1[2] = 1e-8;
    semax1[3] = 0.;
    semax1[4] = sqrt(2.);
    semax1[5] = 0.;
    semax1[6] = -1.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     The large chip is 10 times larger. */

    semax2[0] = 1e-7;
    semax2[1] = 0.;
    semax2[2] = 1e-7;
    semax2[3] = 0.;
    semax2[4] = sqrt(2.) * 10.;
    semax2[5] = 0.;
    semax2[6] = -10.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -3.;
    centr1[1] = 0.;
    centr1[2] = 7.;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point. */

    viewpt[0] = 50.;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first ellipsoid in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #2:  annular transit across large ellips"
	    "oid by small ellipsoid. Switch arguments.", (ftnlen)255, (ftnlen)
	    98);
    tcase_(title, (ftnlen)255);

/*     We expect an annular transit with the second ellipsoid in front. */

    xcode = -2;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #3:  total occultation of small ellipsoi"
	    "d by large ellipsoid.", (ftnlen)255, (ftnlen)78);
    tcase_(title, (ftnlen)255);


/*        Total occultation: */

/*                               * */
/*                             *   * */
/*                           *   * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -11.;
    centr1[1] = 0.;
    centr1[2] = 7.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the second ellipsoid in front. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #4:  total occultation of small ellipsoi"
	    "d by large ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)95);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation with the first ellipsoid in front. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #5:  partial occultation of small ellips"
	    "oid by large ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*        Partial occultation, small chip is in back: */

/*                                   * */
/*                               * * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -13.;
    centr1[1] = 0.;
    centr1[2] = 11.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second ellipsoid in */
/*     front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #6:  partial occultation of small ellips"
	    "oid by large ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)
	    97);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #7:  partial occultation of large ellips"
	    "oid by small ellipsoid.", (ftnlen)255, (ftnlen)80);
    tcase_(title, (ftnlen)255);

/*        Partial occultation, small chip is in front: */


/*                            *  * */
/*                          *  * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -7.;
    centr1[1] = 0.;
    centr1[2] = 9.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first ellipsoid in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #8:  partial occultation of large ellips"
	    "oid by small ellipsoid.Switch arguments.", (ftnlen)255, (ftnlen)
	    97);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second ellipsoid in */
/*     front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #9:  no occultation of large ellipsoid b"
	    "y small ellipsoid.  Small target is in front.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*        No occultation, small chip is in front: */


/*                            * */
/*                          *    * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -7.;
    centr1[1] = 0.;
    centr1[2] = 11.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #10:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in front.Switch arguments.", 
	    (ftnlen)255, (ftnlen)120);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #11:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in back.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*        No occultation, small chip is in back: */


/*                                   * */
/*                                 * */
/*                               * */
/*                             * */
/*                           * */
/*                         * */
/*                       * */
/*  * viewing point    * */
/*                   * */
/*                 * */
/*               * */
/*             * */
/*           * */


/*     Assign the center of the small target. */

    centr1[0] = -13.;
    centr1[1] = 0.;
    centr1[2] = 13.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Potato chip test #12:  no occultation of large ellipsoid "
	    "by small ellipsoid.  Small target is in back.Switch arguments.", (
	    ftnlen)255, (ftnlen)119);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect no occultation. */

    xcode = 0;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     The next series of tests exercises the logical branches of */
/*     ZZOCCED that deal with cases where the maximum angular separation */
/*     between the limb of the small target and the ray from the viewing */
/*     point to center of the large target is sought. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #1:  large ellipsoid tota"
	    "lly occults small ellipsoid.", (ftnlen)255, (ftnlen)85);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */


/*     The first ellipsoid is elongated in the y-direction and flattened */
/*     in the z-direction.  The ellipsoid is situated near the +z */
/*     portion of the limb of the large ellipsoid. This prevents a */
/*     simple bounding cone test from proving the ellipsoid is occulted. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 1.;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = .01;

/*     The large target is a large sphere. This ensures that the linear */
/*     transformation performed by ZZOCCED doesn't change the shape of */
/*     either target. */

    semax2[0] = 10.;
    semax2[1] = 0.;
    semax2[2] = 0.;
    semax2[3] = 0.;
    semax2[4] = 10.;
    semax2[5] = 0.;
    semax2[6] = 0.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point.  We set the viewing point far back */
/*     to reduce parallax. */

    viewpt[0] = 1e3;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the second target. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #2:  large ellipsoid tota"
	    "lly occults small ellipsoid.Switch arguments.", (ftnlen)255, (
	    ftnlen)102);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the first target. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #3:  small ellipsoid is i"
	    "n annular transit across large ellipsoid.", (ftnlen)255, (ftnlen)
	    98);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first target in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #4:  small ellipsoid is i"
	    "n annular transit across large ellipsoid.Switch arguments.", (
	    ftnlen)255, (ftnlen)115);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the second target in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #5:  small ellipsoid part"
	    "ially occults large ellipsoid.", (ftnlen)255, (ftnlen)87);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .001;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 4.5;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = .001;

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #6:  small ellipsoid part"
	    "ially occults large ellipsoid. Switch arguments.", (ftnlen)255, (
	    ftnlen)105);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #7:  small ellipsoid is p"
	    "artially occulted by large ellipsoid.", (ftnlen)255, (ftnlen)94);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #8:  small ellipsoid is p"
	    "artially occulted by large ellipsoid. Switch arguments.", (ftnlen)
	    255, (ftnlen)112);
    tcase_(title, (ftnlen)255);

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 9.25;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/*     The next set of cases all have negative maximum angular */
/*     separation between the limb of the small target and the ray from */
/*     the viewing point to center of the large target:  the ray */
/*     passes through the plane region bounded by the limb of the */
/*     small target. */


/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #9:  large ellipsoid tota"
	    "lly occults small ellipsoid. Maximum angular separation is negat"
	    "ive.", (ftnlen)255, (ftnlen)125);
    tcase_(title, (ftnlen)255);

/*     Set up the semi-axis matrices. */

/*     The small ellipsoid is elongated in the y-direction and flattened */
/*     in the z-direction.  The ellipsoid is situated near the x-z plane */
/*     with the center displaced in the +z direction. The small */
/*     ellipsoid is penetrated by the -x axis. The small ellipsoid has */
/*     sufficient extent in the y direction such that, if it were */
/*     rotated 90 degrees about the x-axis, it would not be totally */
/*     occulted.  This prevents a simple bounding cone test from proving */
/*     the ellipsoid is occulted. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 9.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     The large target is a large sphere. This ensures that the linear */
/*     transformation performed by ZZOCCED doesn't change the shape of */
/*     either target. */

    semax2[0] = 10.;
    semax2[1] = 0.;
    semax2[2] = 0.;
    semax2[3] = 0.;
    semax2[4] = 10.;
    semax2[5] = 0.;
    semax2[6] = 0.;
    semax2[7] = 0.;
    semax2[8] = 10.;

/*     Assign the centers of the targets. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 1.;
    centr2[0] = 0.;
    centr2[1] = 0.;
    centr2[2] = 0.;

/*     Assign the viewing point.  We set the viewing point far back */
/*     to reduce parallax. */

    viewpt[0] = 1e3;
    viewpt[1] = 0.;
    viewpt[2] = 0.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the second target. */

    xcode = -3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #10:  large ellipsoid tot"
	    "ally occults small ellipsoid. Maximum angular separation is nega"
	    "tive. Switch arguments.", (ftnlen)255, (ftnlen)144);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a total occultation by the first target. */

    xcode = 3;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #11:  small ellipsoid is "
	    "in annular transit across large ellipsoid; maximum angular separ"
	    "ation is negative.", (ftnlen)255, (ftnlen)139);
    tcase_(title, (ftnlen)255);
/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the first target in front. */

    xcode = 2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #12:  small ellipsoid is "
	    "in annular transit across large ellipsoid; maximum angular separ"
	    "ation is negative. Switch arguments.", (ftnlen)255, (ftnlen)157);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect an annular transit with the second target in front. */

    xcode = -2;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #13:  small ellipsoid par"
	    "tially occults large ellipsoid; maximum angular separation is ne"
	    "gative.", (ftnlen)255, (ftnlen)128);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 10.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     Assign the center of the small target. */

    centr1[0] = 12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #14:  small ellipsoid par"
	    "tially occults large ellipsoid; maximum angular separation is ne"
	    "gative. Switch arguments.", (ftnlen)255, (ftnlen)146);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #15:  small ellipsoid is "
	    "partially occulted by large ellipsoid; maximum angular separatio"
	    "n is negative.", (ftnlen)255, (ftnlen)135);
    tcase_(title, (ftnlen)255);

/*     Assign the semi-axes of the small target. */

    semax1[0] = .01;
    semax1[1] = 0.;
    semax1[2] = 0.;
    semax1[3] = 0.;
    semax1[4] = 10.25;
    semax1[5] = 0.;
    semax1[6] = 0.;
    semax1[7] = 0.;
    semax1[8] = 1.;

/*     Assign the center of the small target. */

    centr1[0] = -12.;
    centr1[1] = 0.;
    centr1[2] = 1.;

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr1, oax1, octr2, oax2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the second target in front. */

    xcode = -1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Maximum angular separation case #16:  small ellipsoid is "
	    "partially occulted by large ellipsoid; maximum angular separatio"
	    "n is negative. Switch arguments.", (ftnlen)255, (ftnlen)153);
    tcase_(title, (ftnlen)255);

/*     Apply rotations and translations to the inputs. */

    xinput_(viewpt, centr1, semax1, centr2, semax2, oview, octr1, oax1, octr2,
	     oax2);

/*     Classify the occultation. */

    code = zzocced_(oview, octr2, oax2, octr1, oax1);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     We expect a partial occultation with the first target in front. */

    xcode = 1;
    chcksi_("ZZOCCED", &code, "=", &xcode, &c__0, ok, (ftnlen)7, (ftnlen)1);
/* ******* */
/* ******* */
/* ******* */
/* ******* */
/* ******* */
/* *******  Error handling cases: */
/* ******* */
/* ******* */
/* ******* */
/* ******* */
/* ******* */

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Viewing point is inside first ellipsoid.", (ftnlen)255, (
	    ftnlen)40);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b677, &c_b678, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b684, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = 1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(NOTDISJOINT)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Viewing point is inside second ellipsoid.", (ftnlen)255, (
	    ftnlen)41);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b677, &c_b692, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b684, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = 1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(NOTDISJOINT)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Target bodies intersect", (ftnlen)255, (ftnlen)23);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b705, &c_b692, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b712, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = 1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(NOTDISJOINT)", ok, (ftnlen)18);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Non-positive radii", (ftnlen)255, (ftnlen)18);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b705, &c_b692, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b712, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = 0.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = 1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax1[0] = 1.;
    semax1[4] = 0.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax1[4] = 1.;
    semax1[8] = 0.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax1[8] = 1.;
    semax2[0] = 0.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax2[0] = 1.;
    semax2[4] = 0.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax2[4] = 1.;
    semax2[8] = 0.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(BADAXISLENGTH)", ok, (ftnlen)20);
    semax2[8] = 1.;

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "First matrix is not a rotation", (ftnlen)255, (ftnlen)30);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b705, &c_b692, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b750, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = -1.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = 1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(NOTAROTATION)", ok, (ftnlen)19);

/* --- Case: ------------------------------------------------------ */

    s_copy(title, "Second matrix is not a rotation", (ftnlen)255, (ftnlen)31);
    tcase_(title, (ftnlen)255);
    vpack_(&c_b705, &c_b692, &c_b679, viewpt);
    vpack_(&c_b677, &c_b681, &c_b679, centr1);
    vpack_(&c_b677, &c_b712, &c_b679, centr2);
    cleard_(&c__9, semax1);
    semax1[0] = 1.;
    semax1[4] = 1.;
    semax1[8] = 1.;
    cleard_(&c__9, semax2);
    semax2[0] = 1.;
    semax2[4] = 1.;
    semax2[8] = -1.;
    code = zzocced_(viewpt, centr1, semax1, centr2, semax2);
    chckxc_(&c_true, "SPICE(NOTAROTATION)", ok, (ftnlen)19);
    t_success__(ok);
    return 0;
} /* f_zzocced__ */


/*     Utility for "deranging" inputs to more fully exercise */
/*     the frame transformation code in ZZOCCED. */

/* Subroutine */ int xinput_(doublereal *viewpt, doublereal *centr1, 
	doublereal *semax1, doublereal *centr2, doublereal *semax2, 
	doublereal *oview, doublereal *octr1, doublereal *oax1, doublereal *
	octr2, doublereal *oax2)
{
    /* Initialized data */

    static doublereal angles[3] = { 30.,-50.,85. };
    static integer axes[3] = { 3,1,3 };
    static doublereal p231[9]	/* was [3][3] */ = { 0.,1.,0.,0.,0.,1.,1.,0.,
	    0. };
    static doublereal p312[9]	/* was [3][3] */ = { 0.,0.,1.,1.,0.,0.,0.,1.,
	    0. };
    static logical pass1 = TRUE_;
    static doublereal offset[3] = { 1e3,-7e4,3e10 };

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2, d__3;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int vadd_(doublereal *, doublereal *, doublereal *
	    ), vequ_(doublereal *, doublereal *), eul2m_(doublereal *, 
	    doublereal *, doublereal *, integer *, integer *, integer *, 
	    doublereal *);
    integer i__;
    static doublereal r__[9]	/* was [3][3] */;
    doublereal vtemp[3], m1[9]	/* was [3][3] */, m2[9]	/* was [3][3] */;
    extern doublereal rpd_(void);
    extern /* Subroutine */ int mxm_(doublereal *, doublereal *, doublereal *)
	    , mxv_(doublereal *, doublereal *, doublereal *);


/*     SPICELIB functions */


/*     Local variables */


/*     Initial values */


/*     Saved variables */


/*     Initial values */

    if (pass1) {

/*        Create the rotation matrix that we'll use to transform */
/*        all input vectors. */

	d__1 = angles[2] * rpd_();
	d__2 = angles[1] * rpd_();
	d__3 = angles[0] * rpd_();
	eul2m_(&d__1, &d__2, &d__3, &axes[2], &axes[1], axes, r__);
	pass1 = FALSE_;
    }

/*     Permute the columns of the first semi-axis matrix using */
/*     the matrix P312.  Apply P231 to the second matrix. */

    mxm_(semax1, p312, m1);
    mxm_(semax2, p231, m2);

/*     Rotate all input vectors using R. */

    mxv_(r__, viewpt, oview);
    mxv_(r__, centr1, octr1);
    mxv_(r__, centr2, octr2);
    for (i__ = 1; i__ <= 3; ++i__) {
	mxv_(r__, &m1[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		"m1", i__1, "xinput_", (ftnlen)4827)], &oax1[(i__2 = i__ * 3 
		- 3) < 9 && 0 <= i__2 ? i__2 : s_rnge("oax1", i__2, "xinput_",
		 (ftnlen)4827)]);
	mxv_(r__, &m2[(i__1 = i__ * 3 - 3) < 9 && 0 <= i__1 ? i__1 : s_rnge(
		"m2", i__1, "xinput_", (ftnlen)4828)], &oax2[(i__2 = i__ * 3 
		- 3) < 9 && 0 <= i__2 ? i__2 : s_rnge("oax2", i__2, "xinput_",
		 (ftnlen)4828)]);
    }

/*     Translate all position vectors using OFFSET. */

    vadd_(offset, oview, vtemp);
    vequ_(vtemp, oview);
    vadd_(offset, octr1, vtemp);
    vequ_(vtemp, octr1);
    vadd_(offset, octr2, vtemp);
    vequ_(vtemp, octr2);
    return 0;
} /* xinput_ */

