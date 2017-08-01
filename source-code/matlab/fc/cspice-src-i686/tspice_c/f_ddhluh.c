/* f_ddhluh.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__2 = 2;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;

/* $Procedure F_DDHLUH ( ZZDDHLUH Test Family ) */
/* Subroutine */ int f_ddhluh__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char arch[20];
    integer unit;
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhcls_(integer *, 
	    char *, logical *, ftnlen), zzddhhlu_(integer *, char *, logical *
	    , integer *, ftnlen), zzddhluh_(integer *, integer *, logical *), 
	    zzddhopn_(char *, char *, char *, integer *, ftnlen, ftnlen, 
	    ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), t_success__(
	    logical *);
    integer handle;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    integer althan;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    char binfmt[20], method[20], fnmpat[255];
    extern /* Subroutine */ int getlun_(integer *);
    integer hantst[1000];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHLUH */
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

/*     This routine exercises ZZDDHLUH's logic. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 07-AUG-2002 (FST) */

/*        Updated module as the result of changes to the handle */
/*        manager interface, ZZDDHCLS. */

/* -    TSPICE Version 1.0.0, 06-NOV-2001 (FST) */

/* -& */

/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHLUH", (ftnlen)8);

/*     Setup the filename pattern for loop tests. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/*     Retrive the native binary file format string to use */
/*     when creating test files. */

    zzplatfm_("FILE_FORMAT", binfmt, (ftnlen)11, (ftnlen)20);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Nominal Logic", (ftnlen)22);

/*     Load a file into the handle manager. */

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

/*     Open the file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fetch the UNIT for HANDLE. */

    zzddhhlu_(&handle, arch, &c_false, &unit, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now retrieve the HANDLE for this UNIT. */

    zzddhluh_(&unit, &althan, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the values. */

    chcksi_("HANDLE", &handle, "=", &althan, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*     Close the file and clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Exceptional Case Logic", (ftnlen)31);

/*     Open a handful of files. */

    for (i__ = 1; i__ <= 28; ++i__) {
	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	zzddhopn_(fname, "NEW", "DAF", &hantst[(i__1 = i__ - 1) < 1000 && 0 <=
		 i__1 ? i__1 : s_rnge("hantst", i__1, "f_ddhluh__", (ftnlen)
		228)], (ftnlen)255, (ftnlen)3, (ftnlen)3);
    }
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
    handle = 0;
    found = TRUE_;
    kilfil_(fname, (ftnlen)255);

/*     Create FNAME. */

    t_cptfil__(fname, &c__1, &c__2, binfmt, "ABCD", "EFGH", "IJKL", &c_true, &
	    c_false, "DAF/CK  ", (ftnlen)255, (ftnlen)20, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)8);

/*     Open the file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Lock HANDLE to its unit. */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Now close HANDLE, since we have more than UTSIZE files loaded, */
/*     UNIT will end up being reserved by ZZDDHCLS. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Now ask for the handle associated with UNIT. */

    zzddhluh_(&unit, &althan, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("HANDLE", &althan, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);
    for (i__ = 1; i__ <= 28; ++i__) {
	zzddhcls_(&hantst[(i__1 = i__ - 1) < 1000 && 0 <= i__1 ? i__1 : 
		s_rnge("hantst", i__1, "f_ddhluh__", (ftnlen)296)], arch, &
		c_false, (ftnlen)20);
	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/*     Lastly, check to see if we send it a unit that is not in use by */
/*     the handle manager it returns the appropriate values. */

    getlun_(&unit);
    found = TRUE_;
    handle = 1;

/*     Invoke the module. */

    zzddhluh_(&unit, &handle, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the values. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhluh__ */

