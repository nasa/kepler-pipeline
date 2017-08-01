/* f_xlated.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__256 = 256;
static doublereal c_b13 = 0.;
static integer c__2 = 2;
static logical c_false = FALSE_;
static integer c__512 = 512;
static integer c__15 = 15;
static integer c__482 = 482;

/* $Procedure F_XLATED ( ZZXLATED Test Family ) */
/* Subroutine */ int f_xlated__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    static doublereal equiv_0[256], equiv_1[256];

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), pow_ii(integer *, 
	    integer *), lbit_shift(integer, integer);

    /* Local variables */
    extern /* Subroutine */ int t_xltfwd__(doublereal *, integer *, integer *,
	     char *, ftnlen), zzxlated_(integer *, char *, integer *, 
	    doublereal *, ftnlen);
    integer i__, j, inbff, space;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    extern doublereal dpmin_(void);
#define icomp ((integer *)equiv_1)
    extern doublereal dpmax_(void);
    extern /* Subroutine */ int topen_(char *, ftnlen);
    char input[2048];
#define ioutp ((integer *)equiv_0)
    extern /* Subroutine */ int t_success__(logical *), chckad_(char *, 
	    doublereal *, char *, doublereal *, integer *, doublereal *, 
	    logical *, ftnlen, ftnlen), chckai_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chckxc_(logical 
	    *, char *, logical *, ftnlen);
#define compar (equiv_1)
#define output (equiv_0)

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZXLATED */
/*     routine. */

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

/* $ Abstract */

/*     Parameter declarations for the DAF/DAS handle manager. */

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

/*     DAF, DAS */

/* $ Keywords */

/*     PRIVATE */

/* $ Particulars */

/*     This include file contains parameters defining limits and */
/*     integer codes that are utilized in the DAF/DAS handle manager */
/*     routines. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner       (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.3.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    SPICELIB Version 1.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -    SPICELIB Version 1.1.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    SPICELIB Version 1.0.1, 17-JUL-2002 */

/*        Added MAC-OSX environments. */

/* -    SPICELIB Version 1.0.0, 07-NOV-2001 */

/* -& */

/*     Unit and file table size parameters. */

/*     FTSIZE     is the maximum number of files (DAS and DAF) that a */
/*                user may have open simultaneously. */


/*     RSVUNT     is the number of units protected from being locked */
/*                to a particular handle by ZZDDHHLU. */


/*     SCRUNT     is the number of units protected for use by scratch */
/*                files. */


/*     UTSIZE     is the maximum number of logical units this manager */
/*                will utilize at one time. */


/*     Access method enumeration.  These parameters are used to */
/*     identify which access method is associated with a particular */
/*     handle.  They need to be synchronized with the STRAMH array */
/*     defined in ZZDDHGSD in the following fashion: */

/*        STRAMH ( READ   ) = 'READ' */
/*        STRAMH ( WRITE  ) = 'WRITE' */
/*        STRAMH ( SCRTCH ) = 'SCRATCH' */
/*        STRAMH ( NEW    ) = 'NEW' */

/*     These values are used in the file table variable FTAMH. */


/*     Binary file format enumeration.  These parameters are used to */
/*     identify which binary file format is associated with a */
/*     particular handle.  They need to be synchronized with the STRBFF */
/*     array defined in ZZDDHGSD in the following fashion: */

/*        STRBFF ( BIGI3E ) = 'BIG-IEEE' */
/*        STRBFF ( LTLI3E ) = 'LTL-IEEE' */
/*        STRBFF ( VAXGFL ) = 'VAX-GFLT' */
/*        STRBFF ( VAXDFL ) = 'VAX-DFLT' */

/*     These values are used in the file table variable FTBFF. */


/*     Some random string lengths... more documentation required. */
/*     For now this will have to suffice. */


/*     Architecture enumeration.  These parameters are used to identify */
/*     which file architecture is associated with a particular handle. */
/*     They need to be synchronized with the STRARC array defined in */
/*     ZZDDHGSD in the following fashion: */

/*        STRARC ( DAF ) = 'DAF' */
/*        STRARC ( DAS ) = 'DAS' */

/*     These values will be used in the file table variable FTARC. */


/*     For the following environments, record length is measured in */
/*     characters (bytes) with eight characters per double precision */
/*     number. */

/*     Environment: Sun, Sun FORTRAN */
/*     Source:      Sun Fortran Programmer's Guide */

/*     Environment: PC, MS FORTRAN */
/*     Source:      Microsoft Fortran Optimizing Compiler User's Guide */

/*     Environment: Macintosh, Language Systems FORTRAN */
/*     Source:      Language Systems FORTRAN Reference Manual, */
/*                  Version 1.2, page 12-7 */

/*     Environment: PC/Linux, g77 */
/*     Source:      Determined by experiment. */

/*     Environment: PC, Lahey F77 EM/32 Version 4.0 */
/*     Source:      Lahey F77 EM/32 Language Reference Manual, */
/*                  page 144 */

/*     Environment: HP-UX 9000/750, FORTRAN/9000 Series 700 computers */
/*     Source:      FORTRAN/9000 Reference-Series 700 Computers, */
/*                  page 5-110 */

/*     Environment: NeXT Mach OS (Black Hardware), */
/*                  Absoft Fortran Version 3.2 */
/*     Source:      NAIF Program */


/*     The following parameter defines the size of a string used */
/*     to store a filenames on this target platform. */


/*     The following parameter controls the size of the character record */
/*     buffer used to read data from non-native files. */

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

/*     This routine exercises ZZXLATED's logic. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.3.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    TSPICE Version 1.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -    TSPICE Version 1.1.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    TSPICE Version 1.0.1, 17-JUL-2002 (BVS) */

/*        Added MAC-OSX environments. */

/* -    TSPICE Version 1.0.0, 15-OCT-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_XLATED", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("INBFF out of range error", (ftnlen)24);

/*     Setup the inputs and outputs for checking the lower bound. */

    inbff = 0;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)173)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)174)] = 0.;
    }

/*     Invoke the module. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)2048);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/*     Setup the inputs and outputs for checking the upper bound. */

    inbff = 5;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)199)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)200)] = 0.;
    }

/*     Invoke the module. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)2048);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Bad Byte Count BIG-IEEE INPUT", (ftnlen)41);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)231)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)232)] = 0.;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG/LTL-IEEE integers come in 4-byte packages. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)13);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Not enough SPACE to store OUTPUT", (ftnlen)44);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)264)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)265)] = 0.;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG-IEEE integers come in 4-byte packages. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)160);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Unsupported INBFF", (ftnlen)29);

/*     Setup the inputs and outputs. */

    inbff = 4;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)296)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)297)] = 0.;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG-IEEE integers come in 4-byte packages. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)40);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Extreme D.P. Values", (ftnlen)40);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 2;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)329)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)330)] = 0.;
    }
    compar[0] = dpmax_();
    compar[1] = dpmin_();

/*     Prepare the INPUT buffer. */

    t_xltfwd__(compar, &c__2, &inbff, input, (ftnlen)16);

/*     Invoke the module. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)16);

/*     Check for an exception, we expect none. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that OUTPUT is correct. */

    chckad_("OUTPUT", output, "=", compar, &c__256, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Bit-Cycle Sequence", (ftnlen)39);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 256;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)369)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)370)] = 0.;
    }
    for (i__ = 1; i__ <= 31; ++i__) {
	i__2 = i__ - 1;
	icomp[(i__1 = (i__ << 1) - 2) < 512 && 0 <= i__1 ? i__1 : s_rnge(
		"icomp", i__1, "f_xlated__", (ftnlen)374)] = pow_ii(&c__2, &
		i__2);
    }
    for (i__ = 32; i__ <= 62; ++i__) {
	i__2 = i__ - 32;
	icomp[(i__1 = (i__ << 1) - 2) < 512 && 0 <= i__1 ? i__1 : s_rnge(
		"icomp", i__1, "f_xlated__", (ftnlen)378)] = -pow_ii(&c__2, &
		i__2);
    }
    for (i__ = 63; i__ <= 93; ++i__) {
	i__2 = i__ - 63;
	icomp[(i__1 = (i__ << 1) - 1) < 512 && 0 <= i__1 ? i__1 : s_rnge(
		"icomp", i__1, "f_xlated__", (ftnlen)382)] = pow_ii(&c__2, &
		i__2);
    }
    for (i__ = 94; i__ <= 124; ++i__) {
	i__2 = i__ - 94;
	icomp[(i__1 = (i__ << 1) - 1) < 512 && 0 <= i__1 ? i__1 : s_rnge(
		"icomp", i__1, "f_xlated__", (ftnlen)386)] = -pow_ii(&c__2, &
		i__2);
    }

/*     Prepare the INPUT buffer. */

    t_xltfwd__(compar, &c__256, &inbff, input, (ftnlen)2048);

/*     Invoke the module. */

    zzxlated_(&inbff, input, &space, output, (ftnlen)2048);

/*     Check for an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that OUTPUT is as expected.  We will perform */
/*     the comparison in the equivalenced integers.  The patterns */
/*     we inserted into the double precision arrays may not represent */
/*     real double precision numbers. */

    chckai_("IOUTP", ioutp, "=", icomp, &c__512, ok, (ftnlen)5, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Byte-Cycle Sequence", (ftnlen)40);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 256;
    for (j = 1; j <= 8; ++j) {
	i__1 = space;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    output[(i__2 = i__ - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("outp"
		    "ut", i__2, "f_xlated__", (ftnlen)427)] = 0.;
	    compar[(i__2 = i__ - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("comp"
		    "ar", i__2, "f_xlated__", (ftnlen)428)] = 0.;
	}
	if (j <= 4) {
	    i__1 = space;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		icomp[(i__2 = (i__ << 1) - 2) < 512 && 0 <= i__2 ? i__2 : 
			s_rnge("icomp", i__2, "f_xlated__", (ftnlen)433)] = 
			lbit_shift(i__ - 1, j - 1 << 3);
	    }
	} else {
	    i__1 = space;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		icomp[(i__2 = (i__ << 1) - 1) < 512 && 0 <= i__2 ? i__2 : 
			s_rnge("icomp", i__2, "f_xlated__", (ftnlen)437)] = 
			lbit_shift(i__ - 1, j - 5 << 3);
	    }
	}

/*        Prepare the INPUT buffer. */

	t_xltfwd__(compar, &space, &inbff, input, space << 3);

/*        Invoke the module. */

	zzxlated_(&inbff, input, &space, output, space << 3);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Verify that OUTPUT was converted properly. */

	chckai_("IOUTP", ioutp, "=", icomp, &c__512, ok, (ftnlen)5, (ftnlen)1)
		;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Miscellaneous Patterns", (ftnlen)43);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 16;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlated__", (ftnlen)476)] = 0.;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlated__", (ftnlen)477)] = 0.;
    }
    compar[0] = 1.;
    compar[1] = -1.;
    compar[2] = 0.;
    compar[3] = 1e10;
    compar[4] = 1e-10;
    compar[5] = -1e10;
    compar[6] = -1e-10;
    compar[7] = 1e100;
    compar[8] = 1e-100;
    compar[9] = -1e100;
    compar[10] = -1e-100;
    compar[11] = 1e300;
    compar[12] = 1e-300;
    compar[13] = -1e300;
    compar[14] = -1e-300;

/*     And the MOVED problematic pattern... */

    icomp[30] = -771000;
    icomp[31] = -771900;

/*     Prepare the INPUT buffer. */

    t_xltfwd__(compar, &space, &inbff, input, space << 3);

/*     Invoke the module. */

    zzxlated_(&inbff, input, &space, output, space << 3);

/*     Check for an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Compare OUTPUT with the expected results. */

    chckad_("OUTPUT", output, "=", compar, &c__15, &c_b13, ok, (ftnlen)6, (
	    ftnlen)1);
    chckai_("IOUTP", &ioutp[30], "=", &icomp[30], &c__482, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_xlated__ */

#undef output
#undef compar
#undef ioutp
#undef icomp


