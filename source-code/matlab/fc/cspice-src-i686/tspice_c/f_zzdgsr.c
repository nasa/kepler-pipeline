/* f_zzdgsr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__128 = 128;
static logical c_false = FALSE_;
static integer c__250 = 250;
static integer c__125 = 125;
static doublereal c_b46 = 0.;
static integer c__2 = 2;
static integer c__124 = 124;
static logical c_true = TRUE_;

/* $Procedure F_ZED'S ( ZZDAFGSR Test Family ) */
/* Subroutine */ int f_zzdgsr__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    doublereal d__1;
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_clos(cllist *);

    /* Local variables */
    doublereal data[128];
    integer free;
    extern /* Subroutine */ int t_dafopn__(char *, integer *, integer *, 
	    ftnlen), t_dafwfr__(integer *, integer *, char *, integer *, 
	    integer *, char *, integer *, integer *, integer *, logical *, 
	    ftnlen, ftnlen);
    integer prev, next, unit, nsum;
    extern /* Subroutine */ int t_dafwsr__(integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, doublereal 
	    *), zzddhini_(integer *, integer *, integer *, char *, char *, 
	    char *, ftnlen, ftnlen, ftnlen), zzddhcls_(integer *, char *, 
	    logical *, ftnlen), zzdafgsr_(integer *, integer *, integer *, 
	    integer *, doublereal *, logical *), zzddhopn_(char *, char *, 
	    char *, integer *, ftnlen, ftnlen, ftnlen);
    integer i__, j, k, l, m;
    char fname[255];
    extern /* Subroutine */ int dafps_(integer *, integer *, doublereal *, 
	    integer *, doublereal *);
    doublereal rdrec[128];
    integer bward;
    extern /* Subroutine */ int tcase_(char *, ftnlen), dafus_(doublereal *, 
	    integer *, integer *, doublereal *, integer *);
    integer fward;
    extern /* Subroutine */ int repmc_(char *, char *, char *, char *, ftnlen,
	     ftnlen, ftnlen, ftnlen), moved_(doublereal *, integer *, 
	    doublereal *);
    logical found;
    doublereal paary[128];
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    doublereal array[128];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    doublereal dc[125];
    integer ic[250];
    extern /* Subroutine */ int chckad_(char *, doublereal *, char *, 
	    doublereal *, integer *, doublereal *, logical *, ftnlen, ftnlen),
	     chckai_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), cleard_(integer *, doublereal *);
    char ifname[60];
    integer natbff;
    extern /* Subroutine */ int cleari_(integer *, integer *);
    logical addftp;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksd_(char *, doublereal *, char *, doublereal *, doublereal *,
	     logical *, ftnlen, ftnlen);
    char casenm[80];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), kilfil_(char *, ftnlen);
    char idword[8], strbff[8*4];
    integer hanlst[4], supbff[4];
    char stramh[8*4], strarc[8*2], fnmtmp[255];
    integer mxnsum, numsup, sumsiz;
    doublereal tdc[125];
    integer tic[250];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDAFGSR */
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

/*     This routine exercises ZZDAFGSR's logic. */

/*     In the process of exercising ZZDAFGSR's logic this module */
/*     creates a series of illegitmately structured DAF files */
/*     that contain legitmate summary/descriptor records.  These */
/*     test files are destroyed after successful execution of this */
/*     test module. */

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

    topen_("F_ZZDGSR", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_ZZDGSR Initialization", (ftnlen)23);

/*     Retrieve the native format and other related information. */

    zzddhini_(&natbff, supbff, &numsup, stramh, strarc, strbff, (ftnlen)8, (
	    ftnlen)8, (ftnlen)8);

/*     Setup the filename template. */

    s_copy(fnmtmp, "daf#.daf", (ftnlen)255, (ftnlen)8);

/*     Construct the contents of the DAF to create.  These values */
/*     are just to satisfy the arguments of T_DAFWFR, as we are only */
/*     creating a test file to exercise ZZDAFGSR. */

    s_copy(idword, "DAF/TEST", (ftnlen)8, (ftnlen)8);
    s_copy(ifname, "TSPICE Test DAF", (ftnlen)60, (ftnlen)15);
    fward = 2;
    bward = 2;
    free = 16001;
    addftp = TRUE_;

/*     Construct the DAFs for each supported architecture, load them */
/*     into the handle manager and perform the necessary tests. */

    i__1 = numsup;
    for (i__ = 1; i__ <= i__1; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*        Now loop over all possible combinations of ND and NI. */
/*        J ranges over the possible values of ND, while K over NI. */

/*         DO J = 0, 124 */
/*            DO K = 2, 2*(125-J) */

/*        In the interest of increasing execution speed on most of */
/*        the test platforms only perform the following, commonly */
/*        used summary tests. */

	for (j = 2; j <= 2; ++j) {
	    for (k = 5; k <= 6; ++k) {

/*              Declare a new test case, since we are constructing them */
/*              dynamically. */

		s_copy(casenm, "# reading # data. ND = #, NI = #.", (ftnlen)
			80, (ftnlen)33);
		repmc_(casenm, "#", strbff + (((i__2 = natbff - 1) < 4 && 0 <=
			 i__2 ? i__2 : s_rnge("strbff", i__2, "f_zzdgsr__", (
			ftnlen)222)) << 3), casenm, (ftnlen)80, (ftnlen)1, (
			ftnlen)8, (ftnlen)80);
		repmc_(casenm, "#", strbff + (((i__3 = supbff[(i__2 = i__ - 1)
			 < 4 && 0 <= i__2 ? i__2 : s_rnge("supbff", i__2, 
			"f_zzdgsr__", (ftnlen)223)] - 1) < 4 && 0 <= i__3 ? 
			i__3 : s_rnge("strbff", i__3, "f_zzdgsr__", (ftnlen)
			223)) << 3), casenm, (ftnlen)80, (ftnlen)1, (ftnlen)8,
			 (ftnlen)80);
		repmi_(casenm, "#", &j, casenm, (ftnlen)80, (ftnlen)1, (
			ftnlen)80);
		repmi_(casenm, "#", &k, casenm, (ftnlen)80, (ftnlen)1, (
			ftnlen)80);
		tcase_(casenm, (ftnlen)80);

/*              Open the new DAF. */

		t_dafopn__(fname, &supbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? 
			i__2 : s_rnge("supbff", i__2, "f_zzdgsr__", (ftnlen)
			232)], &unit, (ftnlen)255);

/*              Dump the semi-bogus file record into the new DAF. */

		t_dafwfr__(&unit, &supbff[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? 
			i__2 : s_rnge("supbff", i__2, "f_zzdgsr__", (ftnlen)
			237)], idword, &j, &k, ifname, &fward, &bward, &free, 
			&addftp, (ftnlen)8, (ftnlen)60);

/*              Compute the maximum number of summaries each summary */
/*              record can hold for these values of ND and NI. */

		mxnsum = 125 / (j + (k + 1) / 2);
		sumsiz = j + (k + 1) / 2;

/*              Now construct the summaries we are going to store */
/*              in each summary record.  We will saturate ARRAY */
/*              with a sequence of packed summaries. */

		i__2 = mxnsum;
		for (l = 1; l <= i__2; ++l) {

/*                 Construct the DP components. */

		    i__3 = j;
		    for (m = 1; m <= i__3; ++m) {
			dc[(i__4 = m - 1) < 125 && 0 <= i__4 ? i__4 : s_rnge(
				"dc", i__4, "f_zzdgsr__", (ftnlen)260)] = (
				doublereal) l * (doublereal) m;
		    }

/*                 Construct the integer components */

		    i__3 = k;
		    for (m = 1; m <= i__3; ++m) {
			ic[(i__4 = m - 1) < 250 && 0 <= i__4 ? i__4 : s_rnge(
				"ic", i__4, "f_zzdgsr__", (ftnlen)267)] = l * 
				m;
		    }
		    dafps_(&j, &k, dc, ic, &array[(i__3 = (l - 1) * sumsiz) < 
			    128 && 0 <= i__3 ? i__3 : s_rnge("array", i__3, 
			    "f_zzdgsr__", (ftnlen)270)]);
		}

/*              Now construct each summary record that is to be */
/*              written into the DAF.  The first L summaries from */
/*              ARRAY will be copied into the target record along */
/*              with bogus values for NEXT, PREV, and L itself as */
/*              NSUM.  The remainder of the record is zeroed out */
/*              for the safety of the reverse conversion module's */
/*              sake. */

		i__2 = mxnsum;
		for (l = 0; l <= i__2; ++l) {

/*                 We are just going to assign bogus values to NEXT and */
/*                 PREV, because we are not really going to be reading */
/*                 this with any of the high level DAF routines. */

		    next = 2;
		    prev = 2;
		    nsum = l;

/*                 We have the baseline ARRAY of MXNSUM packed */
/*                 summaries.  Start populating records, by copying */
/*                 the appropriate number of packed summaries into */
/*                 PAARY. */

		    cleard_(&c__128, paary);
		    i__3 = l * sumsiz;
		    moved_(array, &i__3, paary);

/*                 Write the summary record to the new DAF. */

		    i__4 = l + 2;
		    t_dafwsr__(&unit, &i__4, &supbff[(i__3 = i__ - 1) < 4 && 
			    0 <= i__3 ? i__3 : s_rnge("supbff", i__3, "f_zzd"
			    "gsr__", (ftnlen)307)], &j, &k, &next, &prev, &
			    nsum, paary);
		}

/*              Close the DAF. */

		cl__1.cerr = 0;
		cl__1.cunit = unit;
		cl__1.csta = 0;
		f_clos(&cl__1);

/*              Open the DAF in the handle manager. */

		zzddhopn_(fname, "READ", "DAF", &hanlst[(i__2 = i__ - 1) < 4 
			&& 0 <= i__2 ? i__2 : s_rnge("hanlst", i__2, "f_zzdg"
			"sr__", (ftnlen)320)], (ftnlen)255, (ftnlen)4, (ftnlen)
			3);

/*              Check for the absence of an exception. */

		chckxc_(&c_false, " ", ok, (ftnlen)1);

/*              Now check each record in the file we just created. */

		i__2 = mxnsum;
		for (l = 0; l <= i__2; ++l) {

/*                 Setup the inputs and outputs. */

		    cleari_(&c__250, tic);
		    cleard_(&c__125, tdc);
		    found = FALSE_;

/*                 Invoke the module. */

		    i__4 = l + 2;
		    zzdafgsr_(&hanlst[(i__3 = i__ - 1) < 4 && 0 <= i__3 ? 
			    i__3 : s_rnge("hanlst", i__3, "f_zzdgsr__", (
			    ftnlen)343)], &i__4, &j, &k, data, &found);

/*                 Check for the absence of an exception. */

		    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*                 Now check the results. Start by examining the */
/*                 values stored in the record for NEXT, PREV, */
/*                 and NSUM. */

		    d__1 = (doublereal) next;
		    chcksd_("NEXT", data, "=", &d__1, &c_b46, ok, (ftnlen)4, (
			    ftnlen)1);
		    d__1 = (doublereal) prev;
		    chcksd_("PREV", &data[1], "=", &d__1, &c_b46, ok, (ftnlen)
			    4, (ftnlen)1);
		    d__1 = (doublereal) l;
		    chcksd_("NSUM", &data[2], "=", &d__1, &c_b46, ok, (ftnlen)
			    4, (ftnlen)1);

/*                 Now verify the contents of each summary. */

		    i__3 = l;
		    for (m = 1; m <= i__3; ++m) {

/*                    Unpack the summary for the test array that was */
/*                    written to the file. */

			dafus_(&array[(i__4 = (m - 1) * sumsiz) < 128 && 0 <= 
				i__4 ? i__4 : s_rnge("array", i__4, "f_zzdgs"
				"r__", (ftnlen)371)], &j, &k, dc, ic);

/*                    Unpack the next summary from DATA. */

			dafus_(&data[(i__4 = (m - 1) * sumsiz + 3) < 128 && 0 
				<= i__4 ? i__4 : s_rnge("data", i__4, "f_zzd"
				"gsr__", (ftnlen)380)], &j, &k, tdc, tic);

/*                    Compare the contents of the summaries. */

			chckad_("DC", tdc, "=", dc, &j, &c_b46, ok, (ftnlen)2,
				 (ftnlen)1);
			chckai_("IC", tic, "=", ic, &k, ok, (ftnlen)2, (
				ftnlen)1);
		    }
		}

/*              Close the file, removing it from the handle manager. */

		zzddhcls_(&hanlst[(i__2 = i__ - 1) < 4 && 0 <= i__2 ? i__2 : 
			s_rnge("hanlst", i__2, "f_zzdgsr__", (ftnlen)399)], 
			"DAF", &c_false, (ftnlen)3);

/*              Kill the file, so we can reuse the name safely. */

		kilfil_(fname, (ftnlen)255);
	    }
	}
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("SPICE(HANDLENOTFOUND) Exception", (ftnlen)31);

/*     Setup outputs and expected values. */

    found = TRUE_;
    cleard_(&c__128, data);
    cleard_(&c__128, rdrec);

/*     Since we know we just unloaded HANLST(NUMSUP), attempt to read */
/*     from that handle. */

    zzdafgsr_(&hanlst[(i__1 = numsup - 1) < 4 && 0 <= i__1 ? i__1 : s_rnge(
	    "hanlst", i__1, "f_zzdgsr__", (ftnlen)428)], &c__2, &c__124, &
	    c__2, rdrec, &found);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(HANDLENOTFOUND)", ok, (ftnlen)21);

/*     Check outputs. FOUND should be FALSE, and RDREC should be */
/*     untouched. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chckad_("RDREC", rdrec, "=", data, &c__128, &c_b46, ok, (ftnlen)5, (
	    ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzdgsr__ */

