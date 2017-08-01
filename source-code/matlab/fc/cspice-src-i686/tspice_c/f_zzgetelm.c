/* f_zzgetelm.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;

/* $Procedure F_ZZGETELM ( Family of tests for ZZGETELM) */
/* Subroutine */ int f_zzgetelm__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzgetelm_(integer *, char *, doublereal *, 
	    doublereal *, logical *, char *, ftnlen, ftnlen);
    doublereal epoch;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    doublereal elems[10];
    char lines[80*2];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char error[128];
    extern /* Subroutine */ int t_success__(logical *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksl_(char *, logical *, logical *, 
	    logical *, ftnlen), getelm_(integer *, char *, doublereal *, 
	    doublereal *, ftnlen);
    logical errsig;
    extern /* Subroutine */ int tstlsk_(void);
    integer frstyr;

/* $ Abstract */

/*     This routine performs a number of tests of the SPICELIB */
/*     routine ZZGETELM */

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

/* $ Author */

/*     E. D. Wright 17-APR-2004 (JPL) */
/* -& */

/*     Begin every test family with an open call. */

    topen_("F_ZZGETELM", (ftnlen)10);

/*     Create and load  leapseconds kernel. */

    tstlsk_();
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Assign test values. */

    frstyr = 1969;

/*     Check for a positive process on a correct TLE set. */

    tcase_("Confirm processing of a good TLE", (ftnlen)32);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 1", &errsig, &c_true, ok, (ftnlen)4);

/*     Call the user level routine. Expect no errors. */

    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now test the error checks. Too long. Longest allowed line: 69. */

    tcase_("TLE too long", (ftnlen)12);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 272.3014 "
	    "16.05443269       101", (ftnlen)80, (ftnlen)73);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 3", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     Now test the error checks. Too short. Shortest allowed line: 68. */

    tcase_("TLE too short", (ftnlen)13);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0 84", (ftnlen)80, (ftnlen)66);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 272.3014 "
	    "16.05443269 101", (ftnlen)80, (ftnlen)67);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 3", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     Check bounds on numerical values. */


/*     Inclination [0,180] */

    tcase_("Inclination low", (ftnlen)15);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544 -51.5947 165.1012 0122649  89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    tcase_("Inclination high", (ftnlen)16);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544 181.5947 165.1012 0122649  89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 5", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     RA ascending node [0,360) */

    tcase_("RA node low", (ftnlen)11);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 -65.1012 0122649  89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    tcase_("RA node high", (ftnlen)12);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 365.1012 0122649  89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     Arg periapsis [0,360) */

    tcase_("Arg periapsis low", (ftnlen)17);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947  65.1012 0122649 -89.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    tcase_("Arg periapsis high", (ftnlen)18);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947  65.1012 0122649 389.2072 272.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     Mean anomoly [0,360) */

    tcase_("Mean anomoly low", (ftnlen)16);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 -72.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    tcase_("Mean anomoly high", (ftnlen)17);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 360.3014 "
	    "16.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);

/*     Mean motion (0,20) */

    tcase_("Mean motion low", (ftnlen)15);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 272.3014 "
	    "-16.05443269   101", (ftnlen)80, (ftnlen)70);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    tcase_("Mean motion high", (ftnlen)16);
    s_copy(lines, "1 25544U 98067A   98324.89267077  .00616830  11572-4  291"
	    "39-3 0    84", (ftnlen)80, (ftnlen)69);
    s_copy(lines + 80, "2 25544  51.5947 165.1012 0122649  89.2072 272.3014 "
	    "20.05443269   101", (ftnlen)80, (ftnlen)69);
    zzgetelm_(&frstyr, lines, &epoch, elems, &errsig, error, (ftnlen)80, (
	    ftnlen)128);
    chcksl_("OK 4", &errsig, &c_false, ok, (ftnlen)4);
    getelm_(&frstyr, lines, &epoch, elems, (ftnlen)80);
    chckxc_(&c_true, "SPICE(BADTLE)", ok, (ftnlen)13);
    t_success__(ok);
    return 0;
} /* f_zzgetelm__ */

