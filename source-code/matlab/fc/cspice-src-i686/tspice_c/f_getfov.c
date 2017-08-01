/* f_getfov.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__3 = 3;
static integer c__12 = 12;
static logical c_true = TRUE_;
static integer c__2 = 2;
static integer c__11 = 11;
static integer c__9 = 9;
static integer c__6 = 6;
static logical c_false = FALSE_;
static integer c__0 = 0;
static doublereal c_b124 = 0.;
static integer c__4 = 4;

/* $Procedure      F_GETFOV (Family of tests for GETFOV ) */
/* Subroutine */ int f_getfov__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer room, n;
    char frame[32];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char shape[32];
    doublereal fovbs[3];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    , chckad_(char *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, logical *, ftnlen, ftnlen), chcksc_(char *, char *, 
	    char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    chckxc_(logical *, char *, logical *, ftnlen), chcksi_(char *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen);
    doublereal fovbnd[15]	/* was [3][5] */, bsight[3];
    char kwfram[32];
    extern /* Subroutine */ int clpool_(void);
    char kwbore[32];
    doublereal bounds[15]	/* was [3][5] */;
    integer instid;
    extern /* Subroutine */ int pcpool_(char *, integer *, char *, ftnlen, 
	    ftnlen);
    char kwshap[32];
    extern /* Subroutine */ int pdpool_(char *, integer *, doublereal *, 
	    ftnlen);
    char fovfrm[32];
    extern /* Subroutine */ int getfov_(integer *, integer *, char *, char *, 
	    doublereal *, integer *, doublereal *, ftnlen, ftnlen);
    char fovshp[32], kwboun[32];

/* $ Abstract */

/*     This routine tests the exceptions for the routine GETFOV */
/*     as well as determining whether or not all data specified */
/*     in an I-kernel can be retrieved. */

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


/*     SPICELIB Functions */


/*     Local Variables */


/*     Begin every test family with an open call. */

    topen_("F_GETFOV", (ftnlen)8);
    s_copy(kwboun, "INS-1000_FOV_BOUNDARY", (ftnlen)32, (ftnlen)21);
    s_copy(kwbore, "INS-1000_BORESIGHT", (ftnlen)32, (ftnlen)18);
    s_copy(kwshap, "INS-1000_FOV_SHAPE", (ftnlen)32, (ftnlen)18);
    s_copy(kwfram, "INS-1000_FOV_FRAME", (ftnlen)32, (ftnlen)18);
    room = 3;
    instid = -1000;
    s_copy(shape, "POLYGON", (ftnlen)32, (ftnlen)7);
    s_copy(frame, "CKERNEL", (ftnlen)32, (ftnlen)7);
    bounds[0] = 1.;
    bounds[1] = 1.;
    bounds[2] = 1.;
    bounds[3] = -1.;
    bounds[4] = 1.;
    bounds[5] = 1.;
    bounds[6] = -1.;
    bounds[7] = -1.;
    bounds[8] = 1.;
    bounds[9] = 1.;
    bounds[10] = -1.;
    bounds[11] = 1.;
    bounds[12] = 0.;
    bounds[13] = 0.;
    bounds[14] = 0.;
    bsight[0] = 0.;
    bsight[1] = 0.;
    bsight[2] = 1.;
    tcase_("Check that a an exception is signalled if the frame of the instr"
	    "ument has not been stored in the kernel pool. ", (ftnlen)110);
    clpool_();
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    pcpool_("INS-1001_FOV_FRAME", &c__1, frame, (ftnlen)18, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(FRAMEMISSING)", ok, (ftnlen)19);
    tcase_("Check that a an exception is signalled if the shape of the instr"
	    "ument field of view is not in the kernel pool. ", (ftnlen)111);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_("INS-1001_FOV_SHAPE", &c__1, shape, (ftnlen)18, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(SHAPEMISSING)", ok, (ftnlen)19);
    tcase_("Check that a an exception is signalled if the shape specified is"
	    " not one of the known shapes. ", (ftnlen)94);
    s_copy(shape, "SQUARE", (ftnlen)32, (ftnlen)6);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(SHAPENOTSUPPORTED)", ok, (ftnlen)24);
    tcase_("Check that a an exception is signalled if the boresight informat"
	    "ion has not been stored in the kernel pool. ", (ftnlen)108);
    s_copy(shape, "POLYGON", (ftnlen)32, (ftnlen)7);
    s_copy(kwbore, "INS-1001_BORESIGHT", (ftnlen)32, (ftnlen)18);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BORESIGHTMISSING)", ok, (ftnlen)23);
    tcase_("Check that a an exception is signalled if if the boresight is no"
	    "t a 3-vector. ", (ftnlen)78);
    s_copy(kwbore, "INS-1000_BORESIGHT", (ftnlen)32, (ftnlen)18);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__2, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBORESIGHTSPEC)", ok, (ftnlen)23);
    tcase_("Check that a an exception is signalled if the boundary vectors o"
	    "f the field of view have not been stored in the kernel pool ", (
	    ftnlen)124);
    s_copy(kwboun, "INS-1001_FOV_BOUNDARY", (ftnlen)32, (ftnlen)21);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BOUNDARYMISSING)", ok, (ftnlen)22);
    tcase_("Check that a an exception is signalled if there are too many vec"
	    "tors in the array of corner vectors. ", (ftnlen)101);
    s_copy(kwboun, "INS-1000_FOV_BOUNDARY", (ftnlen)32, (ftnlen)21);
    room = 2;
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BOUNDARYTOOBIG)", ok, (ftnlen)21);
    tcase_("Check that a an exception is signalled if the size of the array "
	    "of boundary numbers is not a multiple of 3. ", (ftnlen)108);
    room = 4;
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__11, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);
    tcase_("Check that an exception is signalled if the number of boundary v"
	    "ectors for a circular field of view is not 1. ", (ftnlen)110);
    s_copy(shape, "CIRCLE", (ftnlen)32, (ftnlen)6);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__9, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);
    tcase_("Check that an exception is signalled if the number of boundary v"
	    "ectors for a elliptical field of view is not 2. ", (ftnlen)112);
    s_copy(shape, "ELLIPSE", (ftnlen)32, (ftnlen)7);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__9, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);
    tcase_("Check that an exception is signalled if the number of boundary v"
	    "ectors for a rectangular field of view is not 4. ", (ftnlen)113);
    s_copy(shape, "RECTANGLE", (ftnlen)32, (ftnlen)9);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__9, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);
    tcase_("Check that an exception is signalled if the number of boundary v"
	    "ectors for a polygonal field of view is not at least 3. ", (
	    ftnlen)120);
    s_copy(shape, "POLYGON", (ftnlen)32, (ftnlen)7);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__6, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_true, "SPICE(BADBOUNDARY)", ok, (ftnlen)18);
    tcase_("Check that we can get back a polygonal field of view. ", (ftnlen)
	    54);
    room = 15;
    s_copy(shape, "POLYGON", (ftnlen)32, (ftnlen)7);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__9, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SHAPE", fovshp, "=", shape, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksc_("FRAME", fovfrm, "=", frame, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksi_("N", &n, "=", &c__3, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("FOVBS", fovbs, "=", bsight, &c__3, &c_b124, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("FOVBND", fovbnd, "=", bounds, &c__9, &c_b124, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Check that we can get back a rectangular field of view. ", (
	    ftnlen)56);
    s_copy(shape, "RECTANGLE", (ftnlen)32, (ftnlen)9);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__12, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SHAPE", fovshp, "=", shape, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksc_("FRAME", fovfrm, "=", frame, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksi_("N", &n, "=", &c__4, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("FOVBS", fovbs, "=", bsight, &c__3, &c_b124, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("FOVBND", fovbnd, "=", bounds, &c__12, &c_b124, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Check that we can get back a circular field of view. ", (ftnlen)
	    53);
    s_copy(shape, "CIRCLE", (ftnlen)32, (ftnlen)6);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__3, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SHAPE", fovshp, "=", shape, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksc_("FRAME", fovfrm, "=", frame, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksi_("N", &n, "=", &c__1, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("FOVBS", fovbs, "=", bsight, &c__3, &c_b124, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("FOVBND", fovbnd, "=", bounds, &c__3, &c_b124, ok, (ftnlen)6, (
	    ftnlen)1);
    tcase_("Check that we can get back a elliptical field of view. ", (ftnlen)
	    55);
    s_copy(shape, "ELLIPSE", (ftnlen)32, (ftnlen)7);
    clpool_();
    pcpool_(kwfram, &c__1, frame, (ftnlen)32, (ftnlen)32);
    pcpool_(kwshap, &c__1, shape, (ftnlen)32, (ftnlen)32);
    pdpool_(kwbore, &c__3, bsight, (ftnlen)32);
    pdpool_(kwboun, &c__6, bounds, (ftnlen)32);
    getfov_(&instid, &room, fovshp, fovfrm, fovbs, &n, fovbnd, (ftnlen)32, (
	    ftnlen)32);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("SHAPE", fovshp, "=", shape, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksc_("FRAME", fovfrm, "=", frame, ok, (ftnlen)5, (ftnlen)32, (ftnlen)1,
	     (ftnlen)32);
    chcksi_("N", &n, "=", &c__2, &c__0, ok, (ftnlen)1, (ftnlen)1);
    chckad_("FOVBS", fovbs, "=", bsight, &c__3, &c_b124, ok, (ftnlen)5, (
	    ftnlen)1);
    chckad_("FOVBND", fovbnd, "=", bounds, &c__6, &c_b124, ok, (ftnlen)6, (
	    ftnlen)1);
    t_success__(ok);
    return 0;
} /* f_getfov__ */

