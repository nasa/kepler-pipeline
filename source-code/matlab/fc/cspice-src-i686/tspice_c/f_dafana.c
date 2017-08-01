/* f_dafana.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c__6 = 6;
static integer c__0 = 0;
static logical c_true = TRUE_;
static integer c__125 = 125;
static logical c_false = FALSE_;
static integer c__385 = 385;
static integer c__509 = 509;
static doublereal c_b49 = 0.;
static integer c__510 = 510;
static integer c__634 = 634;

/* $Procedure F_DAFANA ( DAFANA Test Family ) */
/* Subroutine */ int f_dafana__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    doublereal ones[125], vals[125];
    integer i__;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *, 
	    ftnlen), t_success__(logical *), dafada_(doublereal *, integer *),
	     dafcad_(integer *), dafbna_(integer *, doublereal *, char *, 
	    ftnlen), chckad_(char *, doublereal *, char *, doublereal *, 
	    integer *, doublereal *, logical *, ftnlen, ftnlen), dafena_(void)
	    , dafrda_(integer *, integer *, integer *, doublereal *), cleard_(
	    integer *, doublereal *), dafcls_(integer *), chckxc_(logical *, 
	    char *, logical *, ftnlen), kilfil_(char *, ftnlen), dafonw_(char 
	    *, char *, integer *, integer *, char *, integer *, integer *, 
	    ftnlen, ftnlen, ftnlen);
    integer hanlst[21];
    char fnmtmp[255];
    doublereal sum[125];

/* $ Abstract */

/*     Test family to exercise the logic and code in the DAFANA */
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

/*     This routine exercises a subset of DAFANA's logic that concerns */
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

/* -    TSPICE Version 1.0.0, 15-NOV-2001 (FST) */


/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DAFANA", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DAFANA Initialization", (ftnlen)23);

/*     Set the file name template. */

    s_copy(fnmtmp, "test#.daf", (ftnlen)255, (ftnlen)9);

/*     Initialize the summary record for testing purposes. */

    for (i__ = 1; i__ <= 125; ++i__) {
	sum[(i__1 = i__ - 1) < 125 && 0 <= i__1 ? i__1 : s_rnge("sum", i__1, 
		"f_dafana__", (ftnlen)151)] = 0.;
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFBNA SPICE(STFULL) Exception", (ftnlen)30);

/*     Create and load some test DAFs to use. */

    for (i__ = 1; i__ <= 21; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
	dafonw_(fname, "SPK ", &c__2, &c__6, "TEST DAF", &c__0, &hanlst[(i__1 
		= i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge("hanlst", i__1, 
		"f_dafana__", (ftnlen)165)], (ftnlen)255, (ftnlen)4, (ftnlen)
		8);
    }

/*     Since NUMDAF is 1 more than the number of DAFs DAFANA's */
/*     state table can track, attempt to initiate a search on */
/*     all NUMDAF DAFs and check for the error. */

    for (i__ = 1; i__ <= 21; ++i__) {
	dafbna_(&hanlst[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafana__", (ftnlen)174)], sum, "TEST SEGM"
		"ENT", (ftnlen)12);
    }

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(STFULL)", ok, (ftnlen)13);

/*     Clean up. */

    for (i__ = 1; i__ <= 21; ++i__) {
	dafcls_(&hanlst[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafana__", (ftnlen)186)]);
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("DAFBNA Remove Inactive Entries in State Table", (ftnlen)45);

/*     Create and load some test DAFs to use. */

    for (i__ = 1; i__ <= 21; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
	dafonw_(fname, "SPK ", &c__2, &c__6, "TEST DAF", &c__0, &hanlst[(i__1 
		= i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge("hanlst", i__1, 
		"f_dafana__", (ftnlen)202)], (ftnlen)255, (ftnlen)4, (ftnlen)
		8);
    }

/*     Now start appends on the first NUMDAF-1 DAFs. */

    for (i__ = 1; i__ <= 20; ++i__) {
	dafbna_(&hanlst[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafana__", (ftnlen)209)], sum, "TEST SEGM"
		"ENT", (ftnlen)12);
	dafada_(sum, &c__125);
    }

/*     Conclude writing to the first DAF. */

    dafcad_(hanlst);
    dafena_();

/*     Now attempt to write to the NUMDAF DAF. */

    dafbna_(&hanlst[20], sum, "TEST SEGMENT", (ftnlen)12);
    for (i__ = 1; i__ <= 125; ++i__) {
	ones[(i__1 = i__ - 1) < 125 && 0 <= i__1 ? i__1 : s_rnge("ones", i__1,
		 "f_dafana__", (ftnlen)225)] = 1.;
    }
    dafada_(ones, &c__125);
    dafena_();

/*     Check to see that no exception was signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     And that the data was added appropriately. */

    cleard_(&c__125, vals);
    dafrda_(&hanlst[20], &c__385, &c__509, vals);
    chckad_("VALS", vals, "=", ones, &c__125, &c_b49, ok, (ftnlen)4, (ftnlen)
	    1);

/*     Lastly, begin appending a new array to the file we originally */
/*     bumped. */

    dafbna_(hanlst, sum, "TEST SEGMENT 2", (ftnlen)14);
    dafada_(ones, &c__125);
    dafena_();

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the values of the data we just added. */

    cleard_(&c__125, vals);
    dafrda_(hanlst, &c__510, &c__634, vals);
    chckad_("VALS", vals, "=", ones, &c__125, &c_b49, ok, (ftnlen)4, (ftnlen)
	    1);

/*     Clean up. */

    for (i__ = 1; i__ <= 21; ++i__) {
	dafcls_(&hanlst[(i__1 = i__ - 1) < 21 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_dafana__", (ftnlen)269)]);
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dafana__ */

