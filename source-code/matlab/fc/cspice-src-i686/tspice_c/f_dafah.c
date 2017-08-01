/* f_dafah.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__2 = 2;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__1 = 1;

/* $Procedure F_DAFAH ( DAFAH Test Family ) */
/* Subroutine */ int f_dafah__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    integer unit;
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhcls_(integer *, 
	    char *, logical *, ftnlen), zzddhhlu_(integer *, char *, logical *
	    , integer *, ftnlen), zzddhopn_(char *, char *, char *, integer *,
	     ftnlen, ftnlen, ftnlen);
    integer i__;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *, 
	    ftnlen), t_success__(logical *), dafhfn_(integer *, char *, 
	    ftnlen), daffnh_(char *, integer *, ftnlen);
    integer handle;
    extern /* Subroutine */ int dafcls_(integer *), chcksc_(char *, char *, 
	    char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen), 
	    dafsih_(integer *, char *, ftnlen);
    char dasnam[255];
    extern /* Subroutine */ int dafhlu_(integer *, integer *), chckxc_(
	    logical *, char *, logical *, ftnlen), chcksi_(char *, integer *, 
	    char *, integer *, integer *, logical *, ftnlen, ftnlen), dafluh_(
	    integer *, integer *), kilfil_(char *, ftnlen), dafopr_(char *, 
	    integer *, ftnlen);
    integer hanlst[28], outhan;
    char fnmtmp[255], outnam[255];
    extern /* Subroutine */ int tstspk_(char *, logical *, integer *, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code in the DAFAH */
/*     umbrella. */

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

/*     This routine exercises a subset of DAFAH's logic that concerns */
/*     the handle manager implementation. */

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

/* -    TSPICE Version 1.0.0, 15-NOV-2001 (FST) */


/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DAFAH", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DAFAH Initialization", (ftnlen)22);

/*     Create some test DAFs to use. */

    s_copy(fnmtmp, "test#.daf", (ftnlen)255, (ftnlen)9);
    for (i__ = 1; i__ <= 28; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	tstspk_(fname, &c_false, &handle, (ftnlen)255);
    }

/*     Create something that looks like a DAS. */

    s_copy(dasnam, "test.das", (ftnlen)255, (ftnlen)8);
    kilfil_(dasnam, (ftnlen)255);
    t_cptfil__(dasnam, &c__2, &c__2, "        ", "ABCD", "EFGH", "IJKL", &
	    c_false, &c_false, " ", (ftnlen)255, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFHLU Lock Check", (ftnlen)17);

/*     Open UTSIZE - RSVUNT - SCRUNT and lock them to their */
/*     units. */

    for (i__ = 1; i__ <= 20; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	dafopr_(fname, &hanlst[(i__1 = i__ - 1) < 28 && 0 <= i__1 ? i__1 : 
		s_rnge("hanlst", i__1, "f_dafah__", (ftnlen)178)], (ftnlen)
		255);
	dafhlu_(&hanlst[(i__1 = i__ - 1) < 28 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafah__", (ftnlen)179)], &unit);
    }

/*     Now attempt to open and lock one additional file. */
/*     This should generate an error from the handle manager. */

    i__ = 21;
    repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    dafopr_(fname, &handle, (ftnlen)255);

/*     Check to make sure we have no exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now call DAFHLU and generate the exception. */

    dafhlu_(&handle, &unit);

/*     Verify the exception. */

    chckxc_(&c_true, "SPICE(HLULOCKFAILED)", ok, (ftnlen)20);

/*     Check the value of UNIT. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    dafcls_(&handle);
    for (i__ = 1; i__ <= 20; ++i__) {
	dafcls_(&hanlst[(i__1 = i__ - 1) < 28 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafah__", (ftnlen)218)]);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFLUH Exceptions", (ftnlen)17);

/*     First, load up a DAS file and see what DAFLUH does */
/*     with it. */

    zzddhopn_(dasnam, "READ", "DAS", &handle, (ftnlen)255, (ftnlen)4, (ftnlen)
	    3);

/*     Fetch the logical unit assigned to DASNAM. */

    zzddhhlu_(&handle, "DAS", &c_false, &unit, (ftnlen)3);

/*     Toss UNIT into DAFLUH and see what happens. */

    dafluh_(&unit, &outhan);

/*     We expect an error, check for it. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHUNIT)", ok, (ftnlen)20);

/*     Check the value of OUTHAN, it should be 0. */

    chcksi_("HANDLE", &outhan, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Clean up from this exception. */

    zzddhcls_(&handle, "DAS", &c_false, (ftnlen)3);

/*     Now we know HANDLE is no longer known to the handle */
/*     manager.  See what DAFLUH does with UNIT again. */

    dafluh_(&unit, &outhan);

/*     This is a little redundant, check for the same error */
/*     again. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHUNIT)", ok, (ftnlen)20);

/*     Check the value of OUTHAN, it should be 0. */

    chcksi_("HANDLE", &outhan, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFHFN Nominal Execution", (ftnlen)24);

/*     Setup inputs and outputs. */

    s_copy(outnam, " ", (ftnlen)255, (ftnlen)1);

/*     Open a DAF with DAFOPR. */

    repmi_(fnmtmp, "#", &c__1, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    dafopr_(fname, hanlst, (ftnlen)255);

/*     See what file name is associated with HANDLE. */

    dafhfn_(hanlst, outnam, (ftnlen)255);

/*     Check for the exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the output argument. */

    chcksc_("FNAME", outnam, "=", fname, ok, (ftnlen)5, (ftnlen)255, (ftnlen)
	    1, (ftnlen)255);

/*     Clean up from this test case. */

    dafcls_(hanlst);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFHFN Exceptions", (ftnlen)17);

/*     First, load up a DAS file and see what DAFHFN does */
/*     with it. */

    zzddhopn_(dasnam, "READ", "DAS", &handle, (ftnlen)255, (ftnlen)4, (ftnlen)
	    3);

/*     Set OUTNAM. */

    s_copy(outnam, "NOT A FILENAME", (ftnlen)255, (ftnlen)14);

/*     Invoke the module. */

    dafhfn_(&handle, outnam, (ftnlen)255);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHHANDLE)", ok, (ftnlen)22);

/*     Check the value of OUTNAM. */

    chcksc_("FNAME", outnam, "=", "NOT A FILENAME", ok, (ftnlen)5, (ftnlen)
	    255, (ftnlen)1, (ftnlen)14);

/*     Clean up. */

    zzddhcls_(&handle, "DAS", &c_false, (ftnlen)3);

/*     Now try passing HANDLE into DAFHFN again. */

    dafhfn_(&handle, outnam, (ftnlen)255);

/*     Check for the exception again. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHHANDLE)", ok, (ftnlen)22);

/*     Check the value of OUTNAM. */

    chcksc_("FNAME", outnam, "=", "NOT A FILENAME", ok, (ftnlen)5, (ftnlen)
	    255, (ftnlen)1, (ftnlen)14);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFFNH Exceptions", (ftnlen)17);

/*     Load the test DAS, as we are going to use it to exercise */
/*     exceptions in DAFFNH. */

    zzddhopn_(dasnam, "READ", "DAS", &handle, (ftnlen)255, (ftnlen)4, (ftnlen)
	    3);

/*     Set OUTHAN to something ridiculous. */

    outhan = -1;

/*     Now pass DASNAM into DAFFNH and see what happens. */

    daffnh_(dasnam, &outhan, (ftnlen)255);

/*     We expect an exception, check for it. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHFILE)", ok, (ftnlen)20);

/*     Check the value of OUTHAN. */

    chcksi_("HANDLE", &outhan, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now as with half the other test cases, unload the DAS and */
/*     try again. */

    zzddhcls_(&handle, "DAS", &c_false, (ftnlen)3);
    outhan = -1;

/*     Invoke the module with again. */

    daffnh_(dasnam, &outhan, (ftnlen)255);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(DAFNOSUCHFILE)", ok, (ftnlen)20);

/*     Check the value of OUTHAN. */

    chcksi_("HANDLE", &outhan, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFSIH SPICE(DAFINVALIDACCESS) Exception", (ftnlen)40);

/*     Open a DAF with DAFOPR. */

    repmi_(fnmtmp, "#", &c__1, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    dafopr_(fname, hanlst, (ftnlen)255);

/*     See what file name is associated with HANDLE. */

    dafsih_(hanlst, "WRITE", (ftnlen)5);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(DAFINVALIDACCESS)", ok, (ftnlen)23);

/*     Clean up from this test case. */

    dafcls_(hanlst);

/*     Clean up the files we used for this test family. */

    for (i__ = 1; i__ <= 28; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }
    kilfil_(dasnam, (ftnlen)255);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dafah__ */

