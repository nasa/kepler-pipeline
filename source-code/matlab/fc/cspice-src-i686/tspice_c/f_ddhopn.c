/* f_ddhopn.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__0 = 0;
static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__2 = 2;

/* $Procedure F_DDHOPN ( ZZDDHOPN Test Family ) */
/* Subroutine */ int f_ddhopn__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    olist o__1;
    cllist cl__1;
    inlist ioin__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_open(olist *), f_clos(
	    cllist *), f_inqu(inlist *);

    /* Local variables */
    char arch[20];
    integer unit;
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhini_(integer *, 
	    integer *, integer *, char *, char *, char *, ftnlen, ftnlen, 
	    ftnlen), zzddhcls_(integer *, char *, logical *, ftnlen), 
	    zzddhhlu_(integer *, char *, logical *, integer *, ftnlen), 
	    zzddhopn_(char *, char *, char *, integer *, ftnlen, ftnlen, 
	    ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__, j;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen), repmi_(char *, 
	    char *, integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *,
	     ftnlen), t_success__(logical *);
    integer handle, hanlck[21], natbff;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char altarc[20];
    integer althan;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    logical opened;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    char binfmt[20];
    extern integer isrchi_(integer *, integer *, integer *);
    char altfnm[255], method[20], altmth[20], fnmpat[255], strbff[8*4];
    integer supbff[4];
    char stramh[8*4], idwary[8*2], strarc[8*2];
    integer hantst[1000];
    extern /* Subroutine */ int getlun_(integer *);
    integer iostat, altunt;
    logical exists;
    integer numsup;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHOPN */
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

/*     This routine exercises ZZDDHOPN's logic.  There are a few IOSTAT */
/*     driven exceptions that are not readily exercised with the */
/*     delivered source code. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     1) Assumes that the string labels for any supported architecture */
/*        are no more than 3 characters in length. */

/*     2) An acceptable file ID word for any supported file architecture */
/*        is of the form: */

/*           ARC/TYPE */

/*        where ARC is the at most 3 character string code for the */
/*        architecture, and TYPE is the 4 character type string. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.3.0, 26-OCT-2005 (BVS) */

/*        Updated for SUN-SOLARIS-64BIT-GCC_C. */

/* -    TSPICE Version 2.2.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN_C. */

/* -    TSPICE Version 2.1.0, 03-JAN-2005 (BVS) */

/*        Updated for PC-CYGWIN. */

/* -    TSPICE Version 2.0.0, 07-AUG-2002 (FST) */

/*        Updated module as the result of changes to the handle */
/*        manager interface, ZZDDHCLS. */

/*        Add MAC OS/X environments. */

/* -    TSPICE Version 1.0.0, 13-NOV-2001 (FST) */

/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHOPN", (ftnlen)8);

/*     Setup the filename pattern for loop tests. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/*     Retrieve the native binary file format string to use */
/*     when creating test files. */

    zzplatfm_("FILE_FORMAT", binfmt, (ftnlen)11, (ftnlen)20);

/*     Retrieve other initialization data. */

    zzddhini_(&natbff, supbff, &numsup, stramh, strarc, strbff, (ftnlen)8, (
	    ftnlen)8, (ftnlen)8);

/*     Setup IDWARY, an array that contains an acceptable file ID word */
/*     for each supported architecture. */

    for (i__ = 1; i__ <= 2; ++i__) {
	repmc_("#/TEST", "#", strarc + (((i__1 = i__ - 1) < 2 && 0 <= i__1 ? 
		i__1 : s_rnge("strarc", i__1, "f_ddhopn__", (ftnlen)200)) << 
		3), idwary + (((i__2 = i__ - 1) < 2 && 0 <= i__2 ? i__2 : 
		s_rnge("idwary", i__2, "f_ddhopn__", (ftnlen)200)) << 3), (
		ftnlen)6, (ftnlen)1, (ftnlen)8, (ftnlen)8);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Unsupported Access Method Exception.", (ftnlen)36);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "FAILURE-TEST", (ftnlen)20, (ftnlen)12);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNSUPPORTEDMETHOD)", ok, (ftnlen)24);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid File Architecture Exception.", (ftnlen)36);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "FAILURE-TEST", (ftnlen)20, (ftnlen)12);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNSUPPORTEDARCH)", ok, (ftnlen)22);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("No free lockable units on SCRATCH Open Exception.", (ftnlen)49);

/*     Setup the inputs and outputs.  The easiest way to do this is */
/*     open (UTSIZE-RSVUNT) scratch files in a loop. */

    for (i__ = 1; i__ <= 21; ++i__) {
	zzddhopn_(" ", "SCRATCH", "DAS", &hanlck[(i__1 = i__ - 1) < 21 && 0 <=
		 i__1 ? i__1 : s_rnge("hanlck", i__1, "f_ddhopn__", (ftnlen)
		269)], (ftnlen)1, (ftnlen)7, (ftnlen)3);
    }
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "SCRATCH", (ftnlen)20, (ftnlen)7);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UTFULL)", ok, (ftnlen)13);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Clean up the locked files. */

    for (i__ = 1; i__ <= 21; ++i__) {
	zzddhcls_(&hanlck[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlck", i__1, "f_ddhopn__", (ftnlen)296)], "DAS", &c_false, 
		(ftnlen)3);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("READ Blank Filename Exception.", (ftnlen)30);

/*     Setup the inputs and outputs. */

    s_copy(fname, " ", (ftnlen)255, (ftnlen)1);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BLANKFILENAME)", ok, (ftnlen)20);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("NEW Blank Filename Exception.", (ftnlen)29);

/*     Setup the inputs and outputs. */

    s_copy(fname, " ", (ftnlen)255, (ftnlen)1);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BLANKFILENAME)", ok, (ftnlen)20);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("WRITE Blank Filename Exception.", (ftnlen)31);

/*     Setup the inputs and outputs. */

    s_copy(fname, " ", (ftnlen)255, (ftnlen)1);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(BLANKFILENAME)", ok, (ftnlen)20);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("READ Non-Existant File Exception.", (ftnlen)33);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILENOTFOUND)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("WRITE Non-Existant File Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILENOTFOUND)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("READ File Already Connected Exception.", (ftnlen)38);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME and attach it to a logical unit. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);
    getlun_(&unit);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 255;
    o__1.ofnm = fname;
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(IMPROPEROPEN)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("WRITE File Already Connected Exception.", (ftnlen)39);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME and attach it to a logical unit. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);
    getlun_(&unit);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 255;
    o__1.ofnm = fname;
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(IMPROPEROPEN)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("READ DAF Architecture Mismatch Exception.", (ftnlen)41);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, method, (ftnlen)20, (ftnlen)20);
    s_copy(altarc, "DAS", (ftnlen)20, (ftnlen)3);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(altfnm, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, 
	    &c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file as a DAS to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("WRITE DAF Architecture Mismatch Exception.", (ftnlen)42);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, method, (ftnlen)20, (ftnlen)20);
    s_copy(altarc, "DAS", (ftnlen)20, (ftnlen)3);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file as a DAS to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("READ DAS Architecture Mismatch Exception.", (ftnlen)41);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, method, (ftnlen)20, (ftnlen)20);
    s_copy(altarc, "DAF", (ftnlen)20, (ftnlen)3);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file as a DAF to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("WRITE DAS Architecture Mismatch Exception.", (ftnlen)42);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, method, (ftnlen)20, (ftnlen)20);
    s_copy(altarc, "DAF", (ftnlen)20, (ftnlen)3);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file as a DAF to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAF WRITE Open Conflict Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(altarc, arch, (ftnlen)20, (ftnlen)20);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file for READ access to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILEOPENCONFLICT)", ok, (ftnlen)23);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAS WRITE Open Conflict Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(altarc, arch, (ftnlen)20, (ftnlen)20);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file for READ access to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILEOPENCONFLICT)", ok, (ftnlen)23);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAF READ/WRITE Conflict Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(altarc, arch, (ftnlen)20, (ftnlen)20);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file for READ access to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(RWCONFLICT)", ok, (ftnlen)17);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAS READ/WRITE Conflict Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);
    s_copy(altfnm, fname, (ftnlen)255, (ftnlen)255);
    s_copy(altmth, "WRITE", (ftnlen)20, (ftnlen)5);
    s_copy(altarc, arch, (ftnlen)20, (ftnlen)20);
    althan = 0;

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file for READ access to prepare for the conflict. */

    zzddhopn_(altfnm, altmth, altarc, &althan, (ftnlen)255, (ftnlen)20, (
	    ftnlen)20);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(RWCONFLICT)", ok, (ftnlen)17);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&althan, altarc, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("File Table Full Exception.", (ftnlen)26);

/*     Setup the inputs and outputs. */

    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    for (i__ = 1; i__ <= 1000; ++i__) {
	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	zzddhopn_(fname, "NEW", arch, &hantst[(i__1 = i__ - 1) < 1000 && 0 <= 
		i__1 ? i__1 : s_rnge("hantst", i__1, "f_ddhopn__", (ftnlen)
		1073)], (ftnlen)255, (ftnlen)3, (ftnlen)20);
    }
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FTFULL)", ok, (ftnlen)13);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close and remove the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/*     Close and remove all the files used to put the system */
/*     into the FTFULL state. */

    for (i__ = 1; i__ <= 1000; ++i__) {
	zzddhcls_(&hantst[(i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : 
		s_rnge("hantst", i__1, "f_ddhopn__", (ftnlen)1107)], arch, &
		c_false, (ftnlen)20);
	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("NEW File Open IOSTAT Exception.", (ftnlen)31);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILEOPENFAIL)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Remove the file. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP Error Exception.", (ftnlen)20);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAS", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_true, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)4,
	     (ftnlen)4, (ftnlen)8);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FTPXFERERROR)", ok, (ftnlen)19);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Remove the file. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("ID Word, Architecture Input Mismatch Exception.", (ftnlen)47);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 1;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__2, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAS/EK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCHMISMATCH)", ok, (ftnlen)22);

/*     Check HANDLE. */

    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Remove the file. */

    kilfil_(fname, (ftnlen)255);

/*     At this point we have exercised most of the readily available */
/*     exceptions that signal errors.  Now address exceptions that */
/*     do not signal errors. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Multiple OPEN for READ access.", (ftnlen)30);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    althan = 0;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/CK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Try to open the file for read again.  This time store the */
/*     handle returned in ALTHAN. */

    zzddhopn_(fname, method, arch, &althan, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check HANDLE. */

    chcksi_("ALTHAN", &althan, "=", &handle, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Remove the file. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Check UNIT connected to newly opened file.", (ftnlen)42);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/CK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Invoke the module. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     INQUIRE on FNAME to see if it is attached to UNIT. */

    ioin__1.inerr = 1;
    ioin__1.infilen = 255;
    ioin__1.infile = fname;
    ioin__1.inex = &exists;
    ioin__1.inopen = &opened;
    ioin__1.innum = &altunt;
    ioin__1.innamed = 0;
    ioin__1.inname = 0;
    ioin__1.inacc = 0;
    ioin__1.inseq = 0;
    ioin__1.indir = 0;
    ioin__1.infmt = 0;
    ioin__1.inform = 0;
    ioin__1.inunf = 0;
    ioin__1.inrecl = 0;
    ioin__1.innrec = 0;
    ioin__1.inblank = 0;
    iostat = f_inqu(&ioin__1);

/*     Check open and exists to make certain that they are appropriate */
/*     values. */

    chcksl_("OPENED", &opened, &c_true, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);

/*     Get the UNIT associated with HANDLE. */

    zzddhhlu_(&handle, arch, &c_false, &unit, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check IOSTAT for failure. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Compare ALTUNT to UNIT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Remove the file. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Unsupported BFF Exception.", (ftnlen)35);

/*     Loop over all possible non-native configurations guarenteed */
/*     to fail. */

    for (i__ = 1; i__ <= 4; ++i__) {

/*        Start by handling WRITE access.  All non-native formats */
/*        are not supported for writing. */

	if (i__ != natbff) {
	    for (j = 1; j <= 2; ++j) {

/*              Create a test file for each architecture. */

		s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
		kilfil_(fname, (ftnlen)255);

/*              Create FNAME. */

		t_cptfil__(fname, &j, &c__2, strbff + (((i__1 = i__ - 1) < 4 
			&& 0 <= i__1 ? i__1 : s_rnge("strbff", i__1, "f_ddho"
			"pn__", (ftnlen)1455)) << 3), "ABCD", "EFGH", "IJKL", &
			c_true, &c_false, idwary + (((i__2 = j - 1) < 2 && 0 
			<= i__2 ? i__2 : s_rnge("idwary", i__2, "f_ddhopn__", 
			(ftnlen)1455)) << 3), (ftnlen)255, (ftnlen)8, (ftnlen)
			4, (ftnlen)4, (ftnlen)4, (ftnlen)8);

/*              Begin the test by attempting to open the */
/*              non-native file for WRITE access. */

		s_copy(arch, strarc + (((i__1 = j - 1) < 2 && 0 <= i__1 ? 
			i__1 : s_rnge("strarc", i__1, "f_ddhopn__", (ftnlen)
			1470)) << 3), (ftnlen)20, (ftnlen)8);
		s_copy(method, "WRITE", (ftnlen)20, (ftnlen)5);
		handle = 1;

/*              Invoke the module. */

		zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)
			20, (ftnlen)20);

/*              Check for the exception. */

		chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);

/*              Check the value of HANDLE. */

		chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (
			ftnlen)1);

/*              Now if I is not in SUPBFF, attempt to open it for */
/*              READ access. */

		if (isrchi_(&i__, &numsup, supbff) == 0) {
		    s_copy(arch, strarc + (((i__1 = j - 1) < 2 && 0 <= i__1 ? 
			    i__1 : s_rnge("strarc", i__1, "f_ddhopn__", (
			    ftnlen)1495)) << 3), (ftnlen)20, (ftnlen)8);
		    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
		    handle = 1;

/*                 Invoke the module. */

		    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (
			    ftnlen)20, (ftnlen)20);

/*                 Check for the exception. */

		    chckxc_(&c_true, "SPICE(UNSUPPORTEDBFF)", ok, (ftnlen)21);

/*                 Check the value of HANDLE. */

		    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)
			    6, (ftnlen)1);
		}

/*              All tests related to FNAME are complete.  Delete it. */

		kilfil_(fname, (ftnlen)255);
	    }
	}
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhopn__ */

