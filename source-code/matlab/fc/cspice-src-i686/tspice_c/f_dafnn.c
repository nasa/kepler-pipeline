/* f_dafnn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static integer c__1 = 1;
static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__4 = 4;
static integer c__128 = 128;
static integer c__5 = 5;
static integer c__3 = 3;
static integer c__2 = 2;
static integer c__250 = 250;
static integer c__6 = 6;
static integer c__1205 = 1205;
static integer c__385 = 385;
static integer c__390 = 390;
static integer c__10 = 10;

/* $Procedure F_DAFNN ( DAF Non-Native Test Family ) */
/* Subroutine */ int f_dafnn__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_open(olist *), s_rdue(cilist *), do_uio(integer *, char *, 
	    ftnlen), e_rdue(void), s_wdue(cilist *), e_wdue(void), f_clos(
	    cllist *);

    /* Local variables */
    integer nati, ints[256], unit;
    extern /* Subroutine */ int zzddhini_(integer *, integer *, integer *, 
	    char *, char *, char *, ftnlen, ftnlen, ftnlen);
    integer i__;
    extern /* Subroutine */ int dafra_(integer *, integer *, integer *);
    char fname[255];
    integer nnbff[4];
    extern /* Subroutine */ int dafrn_(char *, ftnlen), tcase_(char *, ftnlen)
	    ;
    char chars[1024];
    extern /* Subroutine */ int dafrs_(doublereal *), dafws_(doublereal *);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen);
    integer numnn;
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int t_success__(logical *), dafcad_(integer *), 
	    dafbna_(integer *, doublereal *, char *, ftnlen), daffna_(logical 
	    *), dafrda_(integer *, integer *, integer *, doublereal *), 
	    dafbfs_(integer *), dafwda_(integer *, integer *, integer *, 
	    doublereal *);
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *), cleard_(integer *, 
	    doublereal *), cleari_(integer *, integer *);
    integer natbff;
    extern /* Subroutine */ int dafarr_(integer *, integer *), dafrdr_(
	    integer *, integer *, integer *, integer *, doublereal *, logical 
	    *), chckxc_(logical *, char *, logical *, ftnlen), chcksi_(char *,
	     integer *, char *, integer *, integer *, logical *, ftnlen, 
	    ftnlen), dafwcr_(integer *, integer *, char *, ftnlen), chcksl_(
	    char *, logical *, logical *, logical *, ftnlen), dafwdr_(integer 
	    *, integer *, doublereal *), dafwfr_(integer *, integer *, 
	    integer *, char *, integer *, integer *, integer *, ftnlen), 
	    kilfil_(char *, ftnlen), dafopr_(char *, integer *, ftnlen), 
	    dafopw_(char *, integer *, ftnlen), dafrrr_(integer *, integer *);
    char native[255], strbff[8*4];
    integer supbff[4], numhan;
    char stramh[8*4], strarc[8*2];
    integer hanlst[4];
    char fnmtmp[255];
    extern /* Subroutine */ int getlun_(integer *);
    integer iostat, numsup;
    extern /* Subroutine */ int tstspk_(char *, logical *, integer *, ftnlen);
    doublereal dps[128];
    extern /* Subroutine */ int t_bingo__(char *, char *, integer *, ftnlen, 
	    ftnlen);

    /* Fortran I/O blocks */
    static cilist io___23 = { 1, 0, 1, 0, 1 };
    static cilist io___24 = { 1, 0, 0, 0, 1 };


/* $ Abstract */

/*     Test family to exercise the logic and code in routines that */
/*     operate on non-native DAF files. */

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

/*     This routine exercises some non-native DAF logic. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 06-FEB-2002 (FST) */

/*        Appended a test that modifies the NATIVE file */
/*        by replacing the binary file format ID word in the */
/*        file record with 8 nulls.  This was done to validate */
/*        changes in ZZDDHPPF.  See the Revisions section of */
/*        its header for details. */

/* -    TSPICE Version 1.0.0, 16-DEC-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DAFNN", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DAFNN Initialization", (ftnlen)22);

/*     Retrieve the native format and other related information. */

    zzddhini_(&natbff, supbff, &numsup, stramh, strarc, strbff, (ftnlen)8, (
	    ftnlen)8, (ftnlen)8);

/*     Check to see if this system supports multiple binary file formats. */
/*     If it does not, then just end the test family here. */

    if (numsup == 1) {
	t_success__(ok);
	return 0;
    }

/*     Now locate the native file format in SUPBFF and construct the */
/*     list of non-native format codes. */

    nati = 0;
    numnn = 0;
    i__1 = numsup;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (supbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge("supbff",
		 i__2, "f_dafnn__", (ftnlen)196)] == natbff) {
	    nati = i__;
	} else {
	    ++numnn;
	    nnbff[(i__2 = numnn - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge("nnbff",
		     i__2, "f_dafnn__", (ftnlen)200)] = supbff[(i__3 = i__ - 
		    1) < 4 && 0 <= i__3 ? i__3 : s_rnge("supbff", i__3, "f_d"
		    "afnn__", (ftnlen)200)];
	}
    }

/*     Check the value of NATI, it should be non-zero. */

    chcksi_("NATIVE_INDEX", &nati, "!=", &c__0, &c__0, ok, (ftnlen)12, (
	    ftnlen)2);

/*     Check the value of NUMNN, it should be at least 1. */

    chcksi_("NUMBER_NN_BFFS", &numnn, ">=", &c__1, &c__0, ok, (ftnlen)14, (
	    ftnlen)2);

/*     Construct a native file first. */

    s_copy(native, "daf.daf", (ftnlen)255, (ftnlen)7);
    tstspk_(native, &c_false, &handle, (ftnlen)255);

/*     Setup the non-native filename template. */

    s_copy(fnmtmp, "nndaf#.daf", (ftnlen)255, (ftnlen)10);

/*     Construct the DAFs for each non-native file format. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*        Convert the native source DAF into the appropriate */
/*        format. */

	t_bingo__(native, fname, &nnbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? 
		i__2 : s_rnge("nnbff", i__2, "f_dafnn__", (ftnlen)237)], (
		ftnlen)255, (ftnlen)255);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFOPW on Native and Non-Native Formats", (ftnlen)39);

/*     Attempt to open the native format for write, this should work. */

    handle = 0;
    dafopw_(native, &handle, (ftnlen)255);

/*     Check for the absence of errors. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &handle, "!=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)2);

/*     Unload the file. */

    dafcls_(&handle);

/*     Now attempt the same for each of the non-native files. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	dafopw_(fname, &handle, (ftnlen)255);

/*        Check for the exception. */

	chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);
	chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Check DAF routines requiring write access", (ftnlen)41);

/*     Clear the handle list. */

    cleari_(&c__4, hanlst);

/*     Open all the non-native files for read access. */
/*     This should work. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	dafopr_(fname, &hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("hanlst", i__2, "f_dafnn__", (ftnlen)295)], (ftnlen)
		255);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("HANDLE", &hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("hanlst", i__2, "f_dafnn__", (ftnlen)301)], "!=", &
		c__0, &c__0, ok, (ftnlen)6, (ftnlen)2);
    }

/*     Now append the native file to the handle list. */

    numhan = numnn + 1;
    dafopr_(native, &hanlst[(i__1 = numhan - 1) < 4 && 0 <= i__1 ? i__1 : 
	    s_rnge("hanlst", i__1, "f_dafnn__", (ftnlen)310)], (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &hanlst[(i__1 = numhan - 1) < 4 && 0 <= i__1 ? i__1 : 
	    s_rnge("hanlst", i__1, "f_dafnn__", (ftnlen)316)], "!=", &c__0, &
	    c__0, ok, (ftnlen)6, (ftnlen)2);

/*     Now loop over every file in the handle list, checking each */
/*     of the routines and entry points that require write access */
/*     for DAFs. */

    s_copy(chars, " ", (ftnlen)1024, (ftnlen)1);
    cleard_(&c__128, dps);
    i__1 = numhan;
    for (i__ = 1; i__ <= i__1; ++i__) {
	handle = hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_dafnn__", (ftnlen)328)];
	dafbfs_(&handle);
	daffna_(&found);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	dafrs_(dps);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	dafrn_("NONE", (ftnlen)4);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	dafws_(dps);
	chckxc_(&c_true, "SPICE(DAFILLEGWRITE)", ok, (ftnlen)20);
	dafbna_(&handle, dps, chars, (ftnlen)1024);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	dafcad_(&handle);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	dafarr_(&handle, &c__5);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	ints[0] = 1;
	ints[1] = 3;
	ints[2] = 2;
	dafra_(&handle, ints, &c__3);
	chckxc_(&c_true, "SPICE(DAFILLEGWRITE)", ok, (ftnlen)20);
	dafrrr_(&handle, &c__5);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
	dafwdr_(&handle, &c__2, dps);
	chckxc_(&c_true, "SPICE(DAFILLEGWRITE)", ok, (ftnlen)20);
	dafwcr_(&handle, &c__2, chars, (ftnlen)1024);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);

/*        The following routine signals different errors depending */
/*        on whether or not the HANDLE is associated with a native */
/*        or non-native file. */

	dafwda_(&handle, &c__128, &c__250, dps);
	if (i__ != numhan) {
	    chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);
	} else {
	    chckxc_(&c_true, "SPICE(DAFILLEGWRITE)", ok, (ftnlen)20);
	}
	dafwfr_(&handle, &c__2, &c__6, "NONE", &c__2, &c__2, &c__1205, (
		ftnlen)4);
	chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);
    }

/*     Close the files. */

    i__1 = numhan;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dafcls_(&hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_dafnn__", (ftnlen)391)]);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Check obsolete DAF routines requiring native", (ftnlen)44);

/*     Clear the handle list. */

    cleari_(&c__4, hanlst);

/*     Open all the non-native files for read access. */
/*     This should work. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	dafopr_(fname, &hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("hanlst", i__2, "f_dafnn__", (ftnlen)410)], (ftnlen)
		255);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("HANDLE", &hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("hanlst", i__2, "f_dafnn__", (ftnlen)416)], "!=", &
		c__0, &c__0, ok, (ftnlen)6, (ftnlen)2);
    }

/*     Now append the native file to the handle list. */

    numhan = numnn + 1;
    dafopr_(native, &hanlst[(i__1 = numhan - 1) < 4 && 0 <= i__1 ? i__1 : 
	    s_rnge("hanlst", i__1, "f_dafnn__", (ftnlen)425)], (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksi_("HANDLE", &hanlst[(i__1 = numhan - 1) < 4 && 0 <= i__1 ? i__1 : 
	    s_rnge("hanlst", i__1, "f_dafnn__", (ftnlen)431)], "!=", &c__0, &
	    c__0, ok, (ftnlen)6, (ftnlen)2);

/*     Loop over all non-native files, checking for the appropriate */
/*     exceptions. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	handle = hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_dafnn__", (ftnlen)439)];
	dafrda_(&handle, &c__128, &c__250, dps);
	chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);
	dafrdr_(&handle, &c__1, &c__1, &c__128, dps, &found);
	chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);
	chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    }

/*     Verify that we can still use these routines on native files. */

    handle = hanlst[(i__1 = numhan - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
	    "hanlst", i__1, "f_dafnn__", (ftnlen)453)];
    dafrda_(&handle, &c__385, &c__390, dps);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    dafrdr_(&handle, &c__4, &c__2, &c__10, dps, &found);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Close the files. */

    i__1 = numhan;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dafcls_(&hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_dafnn__", (ftnlen)466)]);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Check native NULL BFFID File Records Load", (ftnlen)41);

/*     Note: This test modifies the file record of the file */
/*     referenced by the name NATIVE.  If you need to add tests, */
/*     add them before this one. */

    getlun_(&unit);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = rtrim_(native, (ftnlen)255);
    o__1.ofnm = native;
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("OPEN IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)11, (
	    ftnlen)1);

/*     Read the file record into the CHARS buffer. */

    io___23.ciunit = unit;
    iostat = s_rdue(&io___23);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, chars, (ftnlen)1024);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = e_rdue();
L100001:

/*     Check IOSTAT. */

    chcksi_("READ IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)11, (
	    ftnlen)1);

/*     Replace the BFF ID with nulls. */

    for (i__ = 89; i__ <= 96; ++i__) {
	*(unsigned char *)&chars[i__ - 1] = '\0';
    }
    io___24.ciunit = unit;
    iostat = s_wdue(&io___24);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, chars, (ftnlen)1024);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = e_wdue();
L100002:

/*     Check IOSTAT. */

    chcksi_("WRITE IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)12, (
	    ftnlen)1);

/*     Close the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);

/*     Check for any exceptions; there should be none. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Attempt to open the file with DAFOPR. */

    dafopr_(native, &handle, (ftnlen)255);

/*     Check for an exception; again we expect none. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the file and try DAFOPW. */

    dafcls_(&handle);

/*     Now try DAFOPW. */

    dafopw_(native, &handle, (ftnlen)255);

/*     Check for any exceptions; again we expect none. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close the file. */

    dafcls_(&handle);

/*     Clean up by removing the test files. */

    i__1 = numnn;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }
    kilfil_(native, (ftnlen)255);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dafnn__ */

