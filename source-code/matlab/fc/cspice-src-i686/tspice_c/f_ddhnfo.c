/* f_ddhnfo.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static logical c_true = TRUE_;
static logical c_false = FALSE_;
static integer c__0 = 0;

/* $Procedure F_DDHNFO ( ZZDDHNFO Test Family ) */
/* Subroutine */ int f_ddhnfo__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7;
    inlist ioin__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_inqu(inlist *);

    /* Local variables */
    integer unit;
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhini_(integer *, 
	    integer *, integer *, char *, char *, char *, ftnlen, ftnlen, 
	    ftnlen), zzddhcls_(integer *, char *, logical *, ftnlen), 
	    zzddhnfo_(integer *, char *, integer *, integer *, integer *, 
	    logical *, ftnlen), zzddhhlu_(integer *, char *, logical *, 
	    integer *, ftnlen), zzddhopn_(char *, char *, char *, integer *, 
	    ftnlen, ftnlen, ftnlen);
    integer i__, j, k;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmc_(char *, char *,
	     char *, char *, ftnlen, ftnlen, ftnlen, ftnlen);
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen), topen_(char *, ftnlen);
    char tcstr[80];
    extern /* Subroutine */ int t_success__(logical *), chcksc_(char *, char *
	    , char *, char *, logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    integer tblbff[16], natbff;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    integer tblamh[16], tblarc[16], tblhan[16], intbff;
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    integer filcnt, intamh;
    char tblfnm[255*16];
    integer intarc;
    char fnmpat[255], strbff[8*4];
    integer supbff[2];
    char stramh[8*4], strarc[8*2];
    integer iostat, numsup;
    char tststr[255];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHNFO */
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

/*     This routine exercises ZZDDHNFO's logic. */

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

/*     Local Parameters */

/*     NUMFIL is the maximum number of different possible types of files */
/*     that this system may open in the ZZDDHMAN interface.  It is */
/*     computed based on the following: */

/*        There are NUMARC architectures.  Each method is valid for */
/*        either architecture. */

/*        All non-native files may only be opened for 'READ' access. */


/*     Test Table */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHNFO", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DDHNFO Initialization", (ftnlen)23);

/*     Set the filename pattern we will use. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/*     Fetch some initialization data. */

    zzddhini_(&natbff, supbff, &numsup, stramh, strarc, strbff, (ftnlen)8, (
	    ftnlen)8, (ftnlen)8);

/*     Now create entries in the test table for each of the native */
/*     binary file format files of each architecture and access method. */

    for (i__ = 1; i__ <= 8; ++i__) {
	repmi_(fnmpat, "#", &i__, tblfnm + ((i__1 = i__ - 1) < 16 && 0 <= 
		i__1 ? i__1 : s_rnge("tblfnm", i__1, "f_ddhnfo__", (ftnlen)
		188)) * 255, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	tblarc[(i__1 = i__ - 1) < 16 && 0 <= i__1 ? i__1 : s_rnge("tblarc", 
		i__1, "f_ddhnfo__", (ftnlen)189)] = i__ % 2 + 1;
	tblamh[(i__1 = i__ - 1) < 16 && 0 <= i__1 ? i__1 : s_rnge("tblamh", 
		i__1, "f_ddhnfo__", (ftnlen)190)] = (i__ - 1) / 2 + 1;
	tblbff[(i__1 = i__ - 1) < 16 && 0 <= i__1 ? i__1 : s_rnge("tblbff", 
		i__1, "f_ddhnfo__", (ftnlen)191)] = natbff;
    }

/*     Create entries in the test table for each of the non-native */
/*     binary file format files of each architecture with 'READ' access. */

    i__ = 8;
    i__1 = numsup;
    for (j = 1; j <= i__1; ++j) {

/*        We are going to ignore the native binary file format, since */
/*        we addressed it in the preceding loop. */

	if (supbff[(i__2 = j - 1) < 2 && 0 <= i__2 ? i__2 : s_rnge("supbff", 
		i__2, "f_ddhnfo__", (ftnlen)207)] != natbff) {

/*           Loop over every possible architecture, preparing the */
/*           list of files for 'READ' access. */

	    for (k = 1; k <= 2; ++k) {
		++i__;
		repmi_(fnmpat, "#", &i__, tblfnm + ((i__2 = i__ - 1) < 16 && 
			0 <= i__2 ? i__2 : s_rnge("tblfnm", i__2, "f_ddhnfo__"
			, (ftnlen)217)) * 255, (ftnlen)255, (ftnlen)1, (
			ftnlen)255);
		tblarc[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
			"tblarc", i__2, "f_ddhnfo__", (ftnlen)218)] = i__ % 2 
			+ 1;
		tblamh[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
			"tblamh", i__2, "f_ddhnfo__", (ftnlen)219)] = 1;
		tblbff[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
			"tblbff", i__2, "f_ddhnfo__", (ftnlen)220)] = supbff[(
			i__3 = j - 1) < 2 && 0 <= i__3 ? i__3 : s_rnge("supb"
			"ff", i__3, "f_ddhnfo__", (ftnlen)220)];
	    }
	}
    }

/*     Store the number of files we placed into the handle list. */

    filcnt = i__;

/*     Now create the files. */

    i__1 = filcnt;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Only create files for access methods that are not 'NEW' */
/*        or 'SCRATCH'. */

	if (tblamh[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge("tblamh"
		, i__2, "f_ddhnfo__", (ftnlen)242)] != 4 && tblamh[(i__3 = 
		i__ - 1) < 16 && 0 <= i__3 ? i__3 : s_rnge("tblamh", i__3, 
		"f_ddhnfo__", (ftnlen)242)] != 3) {

/*           Create the file. */

	    t_cptfil__(tblfnm + ((i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : 
		    s_rnge("tblfnm", i__2, "f_ddhnfo__", (ftnlen)248)) * 255, 
		    &tblarc[(i__3 = i__ - 1) < 16 && 0 <= i__3 ? i__3 : 
		    s_rnge("tblarc", i__3, "f_ddhnfo__", (ftnlen)248)], &c__2,
		     strbff + (((i__5 = tblbff[(i__4 = i__ - 1) < 16 && 0 <= 
		    i__4 ? i__4 : s_rnge("tblbff", i__4, "f_ddhnfo__", (
		    ftnlen)248)] - 1) < 4 && 0 <= i__5 ? i__5 : s_rnge("strb"
		    "ff", i__5, "f_ddhnfo__", (ftnlen)248)) << 3), "ABCD", 
		    "EFGH", "IJKL", &c_true, &c_false, " ", (ftnlen)255, (
		    ftnlen)8, (ftnlen)4, (ftnlen)4, (ftnlen)4, (ftnlen)1);
	}

/*        Open the file into the handle manager. */

	zzddhopn_(tblfnm + ((i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : 
		s_rnge("tblfnm", i__2, "f_ddhnfo__", (ftnlen)264)) * 255, 
		stramh + (((i__4 = tblamh[(i__3 = i__ - 1) < 16 && 0 <= i__3 ?
		 i__3 : s_rnge("tblamh", i__3, "f_ddhnfo__", (ftnlen)264)] - 
		1) < 4 && 0 <= i__4 ? i__4 : s_rnge("stramh", i__4, "f_ddhnf"
		"o__", (ftnlen)264)) << 3), strarc + (((i__6 = tblarc[(i__5 = 
		i__ - 1) < 16 && 0 <= i__5 ? i__5 : s_rnge("tblarc", i__5, 
		"f_ddhnfo__", (ftnlen)264)] - 1) < 2 && 0 <= i__6 ? i__6 : 
		s_rnge("strarc", i__6, "f_ddhnfo__", (ftnlen)264)) << 3), &
		tblhan[(i__7 = i__ - 1) < 16 && 0 <= i__7 ? i__7 : s_rnge(
		"tblhan", i__7, "f_ddhnfo__", (ftnlen)264)], (ftnlen)255, (
		ftnlen)8, (ftnlen)8);
    }

/*     Now that we have finished all of the initialization stuff, */
/*     Perform the checks on each of the files in the test table. */

    i__1 = filcnt;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Treat each file as an individual case.  Generate the */
/*        TCASE string automatically from the data in the table. */

	s_copy(tcstr, "Exercise - # # # Nominal Logic", (ftnlen)80, (ftnlen)
		30);
	repmc_(tcstr, "#", stramh + (((i__3 = tblamh[(i__2 = i__ - 1) < 16 && 
		0 <= i__2 ? i__2 : s_rnge("tblamh", i__2, "f_ddhnfo__", (
		ftnlen)283)] - 1) < 4 && 0 <= i__3 ? i__3 : s_rnge("stramh", 
		i__3, "f_ddhnfo__", (ftnlen)283)) << 3), tcstr, (ftnlen)80, (
		ftnlen)1, (ftnlen)8, (ftnlen)80);
	repmc_(tcstr, "#", strbff + (((i__3 = tblbff[(i__2 = i__ - 1) < 16 && 
		0 <= i__2 ? i__2 : s_rnge("tblbff", i__2, "f_ddhnfo__", (
		ftnlen)284)] - 1) < 4 && 0 <= i__3 ? i__3 : s_rnge("strbff", 
		i__3, "f_ddhnfo__", (ftnlen)284)) << 3), tcstr, (ftnlen)80, (
		ftnlen)1, (ftnlen)8, (ftnlen)80);
	repmc_(tcstr, "#", strarc + (((i__3 = tblarc[(i__2 = i__ - 1) < 16 && 
		0 <= i__2 ? i__2 : s_rnge("tblarc", i__2, "f_ddhnfo__", (
		ftnlen)285)] - 1) < 2 && 0 <= i__3 ? i__3 : s_rnge("strarc", 
		i__3, "f_ddhnfo__", (ftnlen)285)) << 3), tcstr, (ftnlen)80, (
		ftnlen)1, (ftnlen)8, (ftnlen)80);
	tcase_(tcstr, (ftnlen)80);

/*        Now setup the inputs and outputs. */

	s_copy(fname, " ", (ftnlen)255, (ftnlen)1);
	intarc = 0;
	intbff = 0;
	intamh = 0;
	found = FALSE_;

/*        Invoke the module. */

	zzddhnfo_(&tblhan[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
		"tblhan", i__2, "f_ddhnfo__", (ftnlen)301)], fname, &intarc, &
		intbff, &intamh, &found, (ftnlen)255);

/*        Check for the absence of an exception. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);

/*        Check outputs. */

	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);

/*        Handle the case of scratch filenames separately. */
/*        Since their names are constructed automatically. */

	if (tblamh[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge("tblamh"
		, i__2, "f_ddhnfo__", (ftnlen)322)] == 3) {

/*           INQUIRE on the UNIT associated with the scratch */
/*           handle. */

	    zzddhhlu_(&tblhan[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : 
		    s_rnge("tblhan", i__2, "f_ddhnfo__", (ftnlen)328)], 
		    strarc + (((i__4 = tblarc[(i__3 = i__ - 1) < 16 && 0 <= 
		    i__3 ? i__3 : s_rnge("tblarc", i__3, "f_ddhnfo__", (
		    ftnlen)328)] - 1) < 2 && 0 <= i__4 ? i__4 : s_rnge("stra"
		    "rc", i__4, "f_ddhnfo__", (ftnlen)328)) << 3), &c_false, &
		    unit, (ftnlen)8);

/*           Set the default value of the filename, in case the */
/*           INQUIRE does not change it. */

	    s_copy(tststr, "# SCRATCH FILE", (ftnlen)255, (ftnlen)14);
	    repmc_(tststr, "#", strarc + (((i__3 = tblarc[(i__2 = i__ - 1) < 
		    16 && 0 <= i__2 ? i__2 : s_rnge("tblarc", i__2, "f_ddhnf"
		    "o__", (ftnlen)336)] - 1) < 2 && 0 <= i__3 ? i__3 : s_rnge(
		    "strarc", i__3, "f_ddhnfo__", (ftnlen)336)) << 3), tststr,
		     (ftnlen)255, (ftnlen)1, (ftnlen)8, (ftnlen)255);
	    ioin__1.inerr = 1;
	    ioin__1.inunit = unit;
	    ioin__1.infile = 0;
	    ioin__1.inex = 0;
	    ioin__1.inopen = 0;
	    ioin__1.innum = 0;
	    ioin__1.innamed = 0;
	    ioin__1.innamlen = 255;
	    ioin__1.inname = tststr;
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

/*           Check the IOSTAT from the INQUIRE. */

	    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	} else {
	    s_copy(tststr, tblfnm + ((i__2 = i__ - 1) < 16 && 0 <= i__2 ? 
		    i__2 : s_rnge("tblfnm", i__2, "f_ddhnfo__", (ftnlen)349)) 
		    * 255, (ftnlen)255, (ftnlen)255);
	}
	chcksc_("FNAME", fname, "=", tststr, ok, (ftnlen)5, (ftnlen)255, (
		ftnlen)1, (ftnlen)255);
	chcksi_("INTARC", &intarc, "=", &tblarc[(i__2 = i__ - 1) < 16 && 0 <= 
		i__2 ? i__2 : s_rnge("tblarc", i__2, "f_ddhnfo__", (ftnlen)
		355)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksi_("INTBFF", &intbff, "=", &tblbff[(i__2 = i__ - 1) < 16 && 0 <= 
		i__2 ? i__2 : s_rnge("tblbff", i__2, "f_ddhnfo__", (ftnlen)
		356)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksi_("INTAMH", &intamh, "=", &tblamh[(i__2 = i__ - 1) < 16 && 0 <= 
		i__2 ? i__2 : s_rnge("tblamh", i__2, "f_ddhnfo__", (ftnlen)
		357)], &c__0, ok, (ftnlen)6, (ftnlen)1);
    }

/*     Check for the absence of a rogue exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Handle Not Found Exception Logic", (ftnlen)41);

/*     Setup inputs and outputs. */

    s_copy(fname, "BOGUS FILENAME", (ftnlen)255, (ftnlen)14);
    intarc = 1;
    intbff = 1;
    intamh = 1;
    found = TRUE_;

/*     Invoke the module on the zero-valued handle. */

    zzddhnfo_(&c__0, fname, &intarc, &intbff, &intamh, &found, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("FNAME", fname, "=", " ", ok, (ftnlen)5, (ftnlen)255, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("INTARC", &intarc, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTBFF", &intbff, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTAMH", &intamh, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Exercise Handle Opposite Sign Exception Logic", (ftnlen)45);

/*     Setup inputs and outputs. */

    s_copy(fname, "BOGUS FILENAME", (ftnlen)255, (ftnlen)14);
    intarc = 1;
    intbff = 1;
    intamh = 1;
    found = TRUE_;

/*     Invoke the module on the negative of an existing, in-use handle. */

    i__1 = -tblhan[0];
    zzddhnfo_(&i__1, fname, &intarc, &intbff, &intamh, &found, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksc_("FNAME", fname, "=", " ", ok, (ftnlen)5, (ftnlen)255, (ftnlen)1, (
	    ftnlen)1);
    chcksi_("INTARC", &intarc, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTBFF", &intbff, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTAMH", &intamh, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* ---------------------------------------------------------------- */

/*     Now clean up. */

    i__1 = filcnt;
    for (i__ = 1; i__ <= i__1; ++i__) {
	zzddhcls_(&tblhan[(i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
		"tblhan", i__2, "f_ddhnfo__", (ftnlen)447)], strarc + (((i__4 
		= tblarc[(i__3 = i__ - 1) < 16 && 0 <= i__3 ? i__3 : s_rnge(
		"tblarc", i__3, "f_ddhnfo__", (ftnlen)447)] - 1) < 2 && 0 <= 
		i__4 ? i__4 : s_rnge("strarc", i__4, "f_ddhnfo__", (ftnlen)
		447)) << 3), &c_false, (ftnlen)8);
	kilfil_(tblfnm + ((i__2 = i__ - 1) < 16 && 0 <= i__2 ? i__2 : s_rnge(
		"tblfnm", i__2, "f_ddhnfo__", (ftnlen)448)) * 255, (ftnlen)
		255);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhnfo__ */

