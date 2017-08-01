/* f_zzdgfr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;

/* $Procedure F_ZZDGFR ( ZZDAFGFR Test Family ) */
/* Subroutine */ int f_zzdgfr__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_clos(cllist *);

    /* Local variables */
    integer free, rdnd, rdni;
    extern /* Subroutine */ int t_dafopn__(char *, integer *, integer *, 
	    ftnlen), t_dafwfr__(integer *, integer *, char *, integer *, 
	    integer *, char *, integer *, integer *, integer *, logical *, 
	    ftnlen, ftnlen);
    integer unit;
    extern /* Subroutine */ int zzdafgfr_(integer *, char *, integer *, 
	    integer *, char *, integer *, integer *, integer *, logical *, 
	    ftnlen, ftnlen), zzddhini_(integer *, integer *, integer *, char *
	    , char *, char *, ftnlen, ftnlen, ftnlen), zzddhcls_(integer *, 
	    char *, logical *, ftnlen), zzddhopn_(char *, char *, char *, 
	    integer *, ftnlen, ftnlen, ftnlen);
    integer i__;
    char fname[255];
    integer bward;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char rdifn[60];
    integer fward, rdbwd, rdfre, rdfwd;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen);
    char rdidw[8];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen), t_success__(
	    logical *);
    integer nd, ni;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    char ifname[60];
    integer natbff;
    logical addftp;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char casenm[80];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    char idword[8], strbff[8*4];
    integer hanlst[4], supbff[4];
    char stramh[8*4], strarc[8*2], fnmtmp[255];
    integer numsup;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDAFGFR */
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

/*     This routine exercises ZZDAFGFR's logic. */

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

/* -    TSPICE Version 1.0.0, 15-OCT-2001 (FST) */


/* -& */

/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_ZZDGFR", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_ZZDGFR Initialization", (ftnlen)23);

/*     Retrieve the native format and other related information. */

    zzddhini_(&natbff, supbff, &numsup, stramh, strarc, strbff, (ftnlen)8, (
	    ftnlen)8, (ftnlen)8);

/*     Setup the filename template. */

    s_copy(fnmtmp, "daf#.daf", (ftnlen)255, (ftnlen)8);

/*     Construct the contents of the DAF to create. */

    s_copy(idword, "DAF/TEST", (ftnlen)8, (ftnlen)8);
    nd = 12;
    ni = 16;
    s_copy(ifname, "TSPICE Test DAF Striving for 60 Characters Going Once Tw"
	    "ice.", (ftnlen)60, (ftnlen)60);
    fward = -4;
    bward = 12;
    free = 513;
    addftp = TRUE_;

/*     Construct the DAFs for each environment and load them */
/*     into the handle manager. */

    i__1 = numsup;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*        Start a new DAF. */

	t_dafopn__(fname, &supbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("supbff", i__2, "f_zzdgfr__", (ftnlen)192)], &unit, (
		ftnlen)255);

/*        Dump the file record to it. */

	t_dafwfr__(&unit, &supbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
		s_rnge("supbff", i__2, "f_zzdgfr__", (ftnlen)197)], idword, &
		nd, &ni, ifname, &fward, &bward, &free, &addftp, (ftnlen)8, (
		ftnlen)60);

/*        Close the file.  Since we added the FTP string, ZZDDHOPN */
/*        only requires a file record to open the file. */

	cl__1.cerr = 0;
	cl__1.cunit = unit;
	cl__1.csta = 0;
	f_clos(&cl__1);

/*        Open the DAF in the handle manager. */

	zzddhopn_(fname, "READ", "DAF", &hanlst[(i__2 = i__ - 1) < 4 && 0 <= 
		i__2 ? i__2 : s_rnge("hanlst", i__2, "f_zzdgfr__", (ftnlen)
		209)], (ftnlen)255, (ftnlen)4, (ftnlen)3);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);
    }

/*     Dynamically construct the test cases based on the contents */
/*     of SUPBFF. */

    i__1 = numsup;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_copy(casenm, "# reading # file record data.", (ftnlen)80, (ftnlen)
		29);
	repmc_(casenm, "#", strbff + (((i__2 = natbff - 1) < 4 && 0 <= i__2 ? 
		i__2 : s_rnge("strbff", i__2, "f_zzdgfr__", (ftnlen)225)) << 
		3), casenm, (ftnlen)80, (ftnlen)1, (ftnlen)8, (ftnlen)80);
	repmc_(casenm, "#", strbff + (((i__3 = supbff[(i__2 = i__ - 1) < 4 && 
		0 <= i__2 ? i__2 : s_rnge("supbff", i__2, "f_zzdgfr__", (
		ftnlen)226)] - 1) < 4 && 0 <= i__3 ? i__3 : s_rnge("strbff", 
		i__3, "f_zzdgfr__", (ftnlen)226)) << 3), casenm, (ftnlen)80, (
		ftnlen)1, (ftnlen)8, (ftnlen)80);
	tcase_(casenm, (ftnlen)80);

/*        Setup the inputs and outputs. */

	rdnd = 0;
	rdni = 0;
	s_copy(rdidw, " ", (ftnlen)8, (ftnlen)1);
	s_copy(rdifn, " ", (ftnlen)60, (ftnlen)1);
	rdfwd = 0;
	rdbwd = 0;
	rdfre = 0;
	found = FALSE_;

/*        We have all the pieces, invoke the module. */

	zzdafgfr_(&hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_zzdgfr__", (ftnlen)246)], rdidw, &rdnd, &
		rdni, rdifn, &rdfwd, &rdbwd, &rdfre, &found, (ftnlen)8, (
		ftnlen)60);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check outputs. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksc_("IDWORD", rdidw, "=", idword, ok, (ftnlen)6, (ftnlen)8, (
		ftnlen)1, (ftnlen)8);
	chcksi_("ND", &rdnd, "=", &nd, &c__0, ok, (ftnlen)2, (ftnlen)1);
	chcksi_("NI", &rdni, "=", &ni, &c__0, ok, (ftnlen)2, (ftnlen)1);
	chcksc_("IFNAME", rdifn, "=", ifname, ok, (ftnlen)6, (ftnlen)60, (
		ftnlen)1, (ftnlen)60);
	chcksi_("FWARD", &rdfwd, "=", &fward, &c__0, ok, (ftnlen)5, (ftnlen)1)
		;
	chcksi_("BWARD", &rdbwd, "=", &bward, &c__0, ok, (ftnlen)5, (ftnlen)1)
		;
	chcksi_("FREE", &rdfre, "=", &free, &c__0, ok, (ftnlen)4, (ftnlen)1);
    }

/*     Clean up by unloading and removing the test files. */

    i__1 = numsup;
    for (i__ = 1; i__ <= i__1; ++i__) {
	zzddhcls_(&hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : s_rnge(
		"hanlst", i__2, "f_zzdgfr__", (ftnlen)283)], "DAF", &c_false, 
		(ftnlen)3);
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	kilfil_(fname, (ftnlen)255);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(HANDLENOTFOUND) Exception", (ftnlen)31);

/*     Setup outputs. */

    found = TRUE_;
    s_copy(rdidw, " ", (ftnlen)8, (ftnlen)1);
    rdnd = 0;
    rdni = 0;
    s_copy(rdifn, " ", (ftnlen)60, (ftnlen)1);
    rdfwd = 0;
    rdbwd = 0;
    rdfre = 0;

/*     Since we know we just unloaded HANLST(1), attempt to read */
/*     from that handle. */

    zzdafgfr_(&hanlst[(i__1 = i__ - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge("han"
	    "lst", i__1, "f_zzdgfr__", (ftnlen)310)], rdidw, &rdnd, &rdni, 
	    rdifn, &rdfwd, &rdbwd, &rdfre, &found, (ftnlen)8, (ftnlen)60);

/*     Check for the presence of an exception. */

    chckxc_(&c_true, "SPICE(HANDLENOTFOUND)", ok, (ftnlen)21);

/*     Check outputs. FOUND should be FALSE, and RDREC should be */
/*     untouched. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("IDWORD", rdidw, "=", " ", ok, (ftnlen)6, (ftnlen)8, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("ND", &rdnd, "=", &c__0, &c__0, ok, (ftnlen)2, (ftnlen)1);
    chcksi_("NI", &rdni, "=", &c__0, &c__0, ok, (ftnlen)2, (ftnlen)1);
    chcksc_("IFNAME", rdifn, "=", " ", ok, (ftnlen)6, (ftnlen)60, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("FWARD", &rdfwd, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("BWARD", &rdbwd, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("FREE", &rdfre, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzdgfr__ */

