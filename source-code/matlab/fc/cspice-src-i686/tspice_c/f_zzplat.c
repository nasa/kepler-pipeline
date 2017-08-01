/* f_zzplat.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_b8 = 1072693248;
static integer c__0 = 0;
static integer c__16400 = 16400;
static integer c__16512 = 16512;
static integer c__1 = 1;

/* $Procedure F_ZZPLAT ( Test Fortran Intrinsics ) */
/* Subroutine */ int f_zzplat__(logical *ok)
{
    /* System generated locals */
    static doublereal equiv_0[1];

    /* Local variables */
    extern /* Subroutine */ int zzplatfm_(char *, char *, ftnlen, ftnlen);
    char bffid[8];
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int t_success__(logical *), chcksi_(char *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen);
#define dequiv (equiv_0)
#define iequiv ((integer *)equiv_0)
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen);

/* $ Abstract */

/*     Test family to verify that ZZPLATFM returns proper values. */

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

/*     None. */

/* $ Keywords */

/*     TEST FAMILY */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine checks to make certain that values returned from */
/*     ZZPLATFM are correct.  Not all values are checked. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 18-DEC-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     EQUIVALENCE statements */


/*     Start the test family with an open call. */

    topen_("F_ZZPLAT", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Binary File Format Consistency Check", (ftnlen)36);

/*     Fetch the binary file format ID string. */

    zzplatfm_("FILE_FORMAT", bffid, (ftnlen)11, (ftnlen)8);

/*     Set the test value. */

    *dequiv = 1.;

/*     Branch based on the value returned; check equivalenced */
/*     integers for the appropriate values. */

    if (eqstr_(bffid, "BIG-IEEE", (ftnlen)8, (ftnlen)8)) {
	chcksi_("IEQUIV(1)", iequiv, "=", &c_b8, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
	chcksi_("IEQUIV(2)", &iequiv[1], "=", &c__0, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
    } else if (eqstr_(bffid, "LTL-IEEE", (ftnlen)8, (ftnlen)8)) {
	chcksi_("IEQUIV(1)", iequiv, "=", &c__0, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
	chcksi_("IEQUIV(2)", &iequiv[1], "=", &c_b8, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
    } else if (eqstr_(bffid, "VAX-GFLT", (ftnlen)8, (ftnlen)8)) {
	chcksi_("IEQUIV(1)", iequiv, "=", &c__16400, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
	chcksi_("IEQUIV(2)", &iequiv[1], "=", &c__0, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
    } else if (eqstr_(bffid, "VAX-DFLT", (ftnlen)8, (ftnlen)8)) {
	chcksi_("IEQUIV(1)", iequiv, "=", &c__16512, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
	chcksi_("IEQUIV(2)", &iequiv[1], "=", &c__0, &c__0, ok, (ftnlen)9, (
		ftnlen)1);
    } else {
	tstmsg_("#", "This test does not support this format.", (ftnlen)1, (
		ftnlen)39);
	chcksi_("ERROR", &c__0, "=", &c__1, &c__0, ok, (ftnlen)5, (ftnlen)1);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzplat__ */

#undef iequiv
#undef dequiv


