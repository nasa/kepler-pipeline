/* f_xlatei.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__256 = 256;
static integer c__2 = 2;
static logical c_false = FALSE_;

/* $Procedure F_XLATEI ( ZZXLATEI Test Family ) */
/* Subroutine */ int f_xlatei__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), pow_ii(integer *, 
	    integer *), lbit_shift(integer, integer);

    /* Local variables */
    extern /* Subroutine */ int t_xltfwi__(integer *, integer *, integer *, 
	    char *, ftnlen), zzxlatei_(integer *, char *, integer *, integer *
	    , ftnlen);
    integer i__, j, inbff, space;
    extern /* Subroutine */ int tcase_(char *, ftnlen), topen_(char *, ftnlen)
	    ;
    char input[1024];
    extern /* Subroutine */ int t_success__(logical *), chckai_(char *, 
	    integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen), chckxc_(logical *, char *, logical *, ftnlen);
    integer compar[256];
    extern integer intmin_(void), intmax_(void);
    integer output[256];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZXLATEI */
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

/*     This routine exercises ZZXLATEI's logic. */

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

    topen_("F_XLATEI", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("INBFF out of range error", (ftnlen)24);

/*     Setup the inputs and outputs for checking the lower bound. */

    inbff = 0;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)166)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)167)] = 0;
    }

/*     Invoke the module. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)1024);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/*     Setup the inputs and outputs for checking the upper bound. */

    inbff = 5;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)192)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)193)] = 0;
    }

/*     Invoke the module. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)1024);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Bad Byte Count BIG-IEEE INPUT", (ftnlen)41);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)224)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)225)] = 0;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG-IEEE integers come in 4-byte packages. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)13);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Not enough SPACE to store OUTPUT", (ftnlen)44);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)257)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)258)] = 0;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG-IEEE integers come in 4-byte packages. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)80);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- Unsupported INBFF", (ftnlen)29);

/*     Setup the inputs and outputs. */

    inbff = 4;
    space = 10;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)289)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)290)] = 0;
    }

/*     Invoke the module. Restrict INPUT to 1:13 range, since */
/*     BIG-IEEE integers come in 4-byte packages. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)40);

/*     Check for an exception. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Check to see that OUTPUT was unmodified. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Extreme Integer Values", (ftnlen)43);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 2;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)322)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)323)] = 0;
    }
    compar[0] = intmax_();
    compar[1] = intmin_();

/*     Get the smallest possible integer bit pattern in memory, */
/*     even if INTMIN does not cooperate. */

    if (compar[1] == -2147483647) {
	--compar[1];
    }

/*     Prepare the INPUT buffer. */

    t_xltfwi__(compar, &c__2, &inbff, input, (ftnlen)8);

/*     Invoke the module. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)8);

/*     Check for an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that OUTPUT is reasonable. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Integral Sequence", (ftnlen)38);

/*     Setup the inputs and outputs. */

    inbff = 1;
    space = 256;
    for (i__ = 1; i__ <= 256; ++i__) {
	output[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("output", 
		i__1, "f_xlatei__", (ftnlen)370)] = 0;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)371)] = 0;
    }
    for (i__ = 1; i__ <= 31; ++i__) {
	i__2 = i__ - 1;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)375)] = pow_ii(&c__2, &i__2);
    }
    for (i__ = 32; i__ <= 62; ++i__) {
	i__2 = i__ - 32;
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)379)] = -pow_ii(&c__2, &i__2);
    }
    for (i__ = 62; i__ <= 256; ++i__) {
	compar[(i__1 = i__ - 1) < 256 && 0 <= i__1 ? i__1 : s_rnge("compar", 
		i__1, "f_xlatei__", (ftnlen)383)] = i__ * 1000;
    }

/*     Prepare the INPUT buffer. */

    t_xltfwi__(compar, &c__256, &inbff, input, (ftnlen)1024);

/*     Invoke the module. */

    zzxlatei_(&inbff, input, &space, output, (ftnlen)1024);

/*     Check for an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check to see that OUTPUT is as expected. */

    chckai_("OUTPUT", output, "=", compar, &c__256, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("LTL-IEEE -- BIG-IEEE Byte Value Cycle", (ftnlen)37);

/*     Setup the inputs and outputs for the LSB byte case. */

    inbff = 1;
    space = 256;
    for (j = 1; j <= 4; ++j) {
	i__1 = space;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    output[(i__2 = i__ - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("outp"
		    "ut", i__2, "f_xlatei__", (ftnlen)421)] = 0;
	    compar[(i__2 = i__ - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("comp"
		    "ar", i__2, "f_xlatei__", (ftnlen)422)] = 0;
	}
	i__1 = space;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    compar[(i__2 = i__ - 1) < 256 && 0 <= i__2 ? i__2 : s_rnge("comp"
		    "ar", i__2, "f_xlatei__", (ftnlen)426)] = lbit_shift(i__ - 
		    1, j - 1 << 3);
	}

/*        Prepare the INPUT buffer. */

	t_xltfwi__(compar, &space, &inbff, input, space << 2);

/*        Invoke the module. */

	zzxlatei_(&inbff, input, &space, output, space << 2);

/*        Check for an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check to see that OUTPUT was unmodified. */

	chckai_("OUTPUT", output, "=", compar, &space, ok, (ftnlen)6, (ftnlen)
		1);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_xlatei__ */

