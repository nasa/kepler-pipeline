/* f_bodvar.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static logical c_false = FALSE_;
static doublereal c_b10 = 6378.14;
static doublereal c_b12 = 6356.75;
static integer c__3 = 3;
static integer c__0 = 0;
static doublereal c_b25 = 1e-14;
static integer c__2 = 2;
static integer c__399 = 399;

/* $Procedure      F_BODVAR ( BODVAR family tests ) */
/* Subroutine */ int f_bodvar__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer n;
    doublereal radii[3];
    extern /* Subroutine */ int tcase_(char *, ftnlen), vpack_(doublereal *, 
	    doublereal *, doublereal *, doublereal *);
    char cvals[80*3];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), cleard_(integer *, 
	    doublereal *), chckxc_(logical *, char *, logical *, ftnlen), 
	    chcksi_(char *, integer *, char *, integer *, integer *, logical *
	    , ftnlen, ftnlen), t_pck08__(char *, logical *, logical *, ftnlen)
	    , bodvar_(integer *, char *, integer *, doublereal *, ftnlen);
    doublereal xradii[3];
    extern /* Subroutine */ int bodvrd_(char *, char *, integer *, integer *, 
	    doublereal *, ftnlen, ftnlen), pcpool_(char *, integer *, char *, 
	    ftnlen, ftnlen);
    char pck[255];

/* $ Abstract */

/*     This routine tests the SPICELIB routines */

/*        BODVAR */
/*        BODVRD */

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

/* -    TSPICE Version 1.0.0, 11-FEB-2004 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */


/*     Local variables */


/*     Begin every test family with an open call. */

    topen_("F_BODVAR", (ftnlen)8);
    tcase_("Setup:  create full text PCK file.", (ftnlen)34);
    s_copy(pck, "test_0008.tpc", (ftnlen)255, (ftnlen)13);

/*     Create the PCK file, load it, and delete it. */

    t_pck08__(pck, &c_true, &c_false, (ftnlen)255);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Get the radii of the earth from the kernel pool using */
/*     BODVRD. */

    tcase_("Look up earth radii using BODVRD", (ftnlen)32);
    vpack_(&c_b10, &c_b10, &c_b12, xradii);
    bodvrd_("EARTH", "RADII", &c__3, &n, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("radii count", &n, "=", &c__3, &c__0, ok, (ftnlen)11, (ftnlen)1);
    chckad_("Earth radii", radii, "~", xradii, &c__3, &c_b25, ok, (ftnlen)11, 
	    (ftnlen)1);
    tcase_("Look up earth radii using BODVRD.  Name = 399", (ftnlen)45);
    vpack_(&c_b10, &c_b10, &c_b12, xradii);
    bodvrd_("399", "RADII", &c__3, &n, radii, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("radii count", &n, "=", &c__3, &c__0, ok, (ftnlen)11, (ftnlen)1);
    chckad_("Earth radii", radii, "~", xradii, &c__3, &c_b25, ok, (ftnlen)11, 
	    (ftnlen)1);

/*     Error cases for BODVRD: */

    tcase_("Output array too small", (ftnlen)22);
    bodvrd_("EARTH", "RADII", &c__2, &n, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_true, "SPICE(ARRAYTOOSMALL)", ok, (ftnlen)20);
    tcase_("Data type mismatch", (ftnlen)18);
    s_copy(cvals, "A", (ftnlen)80, (ftnlen)1);
    s_copy(cvals + 80, "B", (ftnlen)80, (ftnlen)1);
    s_copy(cvals + 160, "C", (ftnlen)80, (ftnlen)1);
    pcpool_("BODY399_SYMBOLIC_RADII", &c__3, cvals, (ftnlen)22, (ftnlen)80);
    bodvrd_("EARTH", "SYMBOLIC_RADII", &c__3, &n, radii, (ftnlen)5, (ftnlen)
	    14);
    chckxc_(&c_true, "SPICE(TYPEMISMATCH)", ok, (ftnlen)19);
    tcase_("Variable not present", (ftnlen)20);
    bodvrd_("EARTH", "radii", &c__2, &n, radii, (ftnlen)5, (ftnlen)5);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
    tcase_("Body name not associated with code", (ftnlen)34);
    bodvrd_("XYZ", "RADII", &c__2, &n, radii, (ftnlen)3, (ftnlen)5);
    chckxc_(&c_true, "SPICE(NOTRANSLATION)", ok, (ftnlen)20);

/*     Try again with BODVAR. */

    tcase_("Look up earth radii using BODVAR", (ftnlen)32);
    cleard_(&c__3, radii);
    bodvar_(&c__399, "RADII", &n, radii, (ftnlen)5);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chckad_("Earth radii", radii, "~", xradii, &c__3, &c_b25, ok, (ftnlen)11, 
	    (ftnlen)1);
    tcase_("Variable not present", (ftnlen)20);
    bodvar_(&c__399, "radii", &n, radii, (ftnlen)5);
    chckxc_(&c_true, "SPICE(KERNELVARNOTFOUND)", ok, (ftnlen)24);
    t_success__(ok);
    return 0;
} /* f_bodvar__ */

