/* f_ddhisn.f -- translated by f2c (version 19980913).
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

/* $Procedure F_DDHISN ( ZZDDHISN Test Family ) */
/* Subroutine */ int f_ddhisn__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), s_rnge(char *, integer, 
	    char *, integer);

    /* Local variables */
    char arch[20];
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhcls_(integer *, 
	    char *, logical *, ftnlen), zzddhisn_(integer *, logical *, 
	    logical *), zzddhopn_(char *, char *, char *, integer *, ftnlen, 
	    ftnlen, ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), ucase_(char *, char *,
	     ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int t_success__(logical *);
    integer handle[4];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen);
    integer natfid;
    char rdsbff[36];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    char method[20], fnmpat[255];
    integer numfil;
    logical native;
    extern /* Subroutine */ int nextwd_(char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen);
    char strnat[8], strnow[8];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHISN */
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

/*     This routine exercises ZZDDHISN's logic. */

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

/* -    TSPICE Version 1.0.0, 05-SEP-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHISN", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DDHISN Initialization", (ftnlen)23);

/*     Get the native binary file format for this platform. */

    zzplatfm_("FILE_FORMAT", strnat, (ftnlen)11, (ftnlen)8);
    ucase_(strnat, strnat, (ftnlen)8, (ftnlen)8);

/*     Get the list of supported binary file formats for this platform. */

    zzplatfm_("READS_BFF", rdsbff, (ftnlen)9, (ftnlen)36);
    ucase_(rdsbff, rdsbff, (ftnlen)36, (ftnlen)36);

/*     Set the filename pattern we will use. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/*     Now create a file of each supported type.  We are just going to */
/*     trick the system into thinking it's an actual file of this type. */

    i__ = 1;
    nextwd_(rdsbff, strnow, rdsbff, (ftnlen)36, (ftnlen)8, (ftnlen)36);
    while(s_cmp(strnow, " ", (ftnlen)8, (ftnlen)1) != 0) {

/*        Build the name of the file we intend to use. */

	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*        Check to see if this is the native format. */

	if (eqstr_(strnow, strnat, (ftnlen)8, (ftnlen)8)) {
	    natfid = i__;
	}

/*        Create the file. */

	t_cptfil__(fname, &c__1, &c__2, strnow, "ABCD", "EFGH", "IJKL", &
		c_true, &c_false, "DAF/SPK ", (ftnlen)255, (ftnlen)8, (ftnlen)
		4, (ftnlen)4, (ftnlen)4, (ftnlen)8);

/*        Open the file into the handle manager. */

	s_copy(method, "READ", (ftnlen)20, (ftnlen)4);
	s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
	zzddhopn_(fname, method, arch, &handle[(i__1 = i__ - 1) < 4 && 0 <= 
		i__1 ? i__1 : s_rnge("handle", i__1, "f_ddhisn__", (ftnlen)
		205)], (ftnlen)255, (ftnlen)20, (ftnlen)20);

/*        Strip off the next word from RDSBFF and increment I. */

	nextwd_(rdsbff, strnow, rdsbff, (ftnlen)36, (ftnlen)8, (ftnlen)36);
	++i__;
    }

/*     Store the number of files we placed into the handle list. */

    numfil = i__ - 1;

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now that we have finished all of the initialization stuff, */
/*     break the tests into two cases.  NATIVE files and NON-NATIVE */
/*     files. */


/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Native File Logic", (ftnlen)26);

/*     Setup the inputs and outputs. */

    native = FALSE_;
    found = FALSE_;

/*     Invoke the module. */

    zzddhisn_(&handle[(i__1 = natfid - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
	    "handle", i__1, "f_ddhisn__", (ftnlen)245)], &native, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("NATIVE", &native, &c_true, ok, (ftnlen)6);
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Non-Native File Logic", (ftnlen)30);
    i__1 = numfil;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        First check to see that this file is not of the native */
/*        format. */

	if (i__ != natfid) {

/*           Setup the inputs and outputs. */

	    native = TRUE_;
	    found = FALSE_;

/*           Invoke the module. */

	    zzddhisn_(&handle[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		    s_rnge("handle", i__2, "f_ddhisn__", (ftnlen)280)], &
		    native, &found);

/*           Check for the absence of an exception. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*           Check outputs. */

	    chcksl_("NATIVE", &native, &c_false, ok, (ftnlen)6);
	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Unknown Handle Exception Logic", (ftnlen)39);

/*     Setup inputs and outputs for the zero-valued handle test. */

    native = FALSE_;
    found = TRUE_;

/*     Invoke the module. */

    zzddhisn_(&c__0, &native, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the outputs.  Since FOUND is FALSE, NATIVE should remain */
/*     unchanged. */

    chcksl_("NATIVE", &native, &c_false, ok, (ftnlen)6);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Setup the inputs and outputs for the opposite-sign handle test. */

    native = TRUE_;
    found = FALSE_;

/*     Invoke the module. */

    i__1 = -handle[0];
    zzddhisn_(&i__1, &native, &found);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("NATIVE", &native, &c_true, ok, (ftnlen)6);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/* ---------------------------------------------------------------- */

/*     Now clean up. */

    i__1 = numfil;
    for (i__ = 1; i__ <= i__1; ++i__) {
	zzddhcls_(&handle[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"handle", i__2, "f_ddhisn__", (ftnlen)353)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhisn__ */

