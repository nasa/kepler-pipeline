/* f_ddhunl.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;

/* $Procedure F_DDHUNL ( ZZDDHUNL Test Family ) */
/* Subroutine */ int f_ddhunl__(logical *ok)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char arch[20];
    integer unit;
    extern /* Subroutine */ int zzddhcls_(integer *, char *, logical *, 
	    ftnlen), zzddhhlu_(integer *, char *, logical *, integer *, 
	    ftnlen), zzddhopn_(char *, char *, char *, integer *, ftnlen, 
	    ftnlen, ftnlen), zzddhunl_(integer *, char *, ftnlen);
    integer i__;
    char fname[255];
    extern /* Subroutine */ int tcase_(char *, ftnlen), repmi_(char *, char *,
	     integer *, char *, ftnlen, ftnlen, ftnlen), topen_(char *, 
	    ftnlen), t_success__(logical *);
    integer handle;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char altarc[20];
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    char method[20], fnmpat[255];
    integer hanlst[23];
    char tmpfnm[255];
    integer altunt;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHUNL */
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

/*     This routine exercises ZZDDHUNL's logic.  A few SPICE(BUG) */
/*     exceptions are not easily diagnosed, since it requires the */
/*     file and unit tables going out of sync in the ZZDDHMAN umbrella. */
/*     (If it is coded correctly, this will never happen.) */

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

/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHUNL", (ftnlen)8);

/*     Set the filename pattern we will use. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/* --- Case: ------------------------------------------------------ */

    tcase_("Zero Handle NO-OP Exception", (ftnlen)27);

/*     Set the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);

/*     Invoke the module. */

    zzddhunl_(&handle, arch, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Missing Handle NO-OP Exception", (ftnlen)30);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open FNAME as a new file, close it and delete it.  This will */
/*     allocate a HANDLE, and once a HANDLE is allocated it will not */
/*     be used again. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/*     Now at this point, HANDLE has been used but is not currently */
/*     in use.  Invoke the module. */

    zzddhunl_(&handle, arch, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Alternate Sign Handle NO-OP Exception", (ftnlen)37);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open FNAME as a new file, but this time close and delete it */
/*     afterwards.  We will go to ZZDDHUNL with -HANDLE. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    i__1 = -handle;
    zzddhunl_(&i__1, arch, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close and delete the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Handle-Unit Not Locked NO-OP Exception", (ftnlen)38);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open FNAME as a new file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhunl_(&handle, altarc, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Architecture Mismatch Exception", (ftnlen)31);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    s_copy(altarc, "DAS", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open FNAME as a new file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     We have to lock the handle to its unit to reach the */
/*     the architecture exception.  (This may be a bad design.) */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Invoke the module. */

    zzddhunl_(&handle, altarc, (ftnlen)20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Bad Architecture Code Exception", (ftnlen)31);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    s_copy(altarc, "UNK", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open FNAME as a new file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     We have to lock the handle to its unit to reach the */
/*     the architecture exception.  (This may be a bad design.) */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Invoke the module. */

    zzddhunl_(&handle, altarc, (ftnlen)20);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Execution", (ftnlen)17);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    unit = 0;
    altunt = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Now to perform this test, we need to verify that the unlock */
/*     actually occurs.  To do this we will create UTSIZE additional */
/*     files and load them, then proceed by making logical unit */
/*     requests for each of them to cycle FNAME out of the unit table. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }

/*     Open test.fil. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Lock HANDLE to it's UNIT and retrieve the unit. */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Check to see that UNIT is not zero. */

    chcksi_("UNIT", &unit, "!=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)2);

/*     Unlock the unit. */

    zzddhunl_(&handle, arch, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now open the UTSIZE files and to cycle through the units. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhunl__", (ftnlen)
		434)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now request the UNIT for HANDLE. */

    zzddhhlu_(&handle, arch, &c_true, &altunt, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that ALTUNT is not UNIT.  What follows is a brief */
/*     discussion as to why this works.  Note it relies heavily */
/*     on the current implementation of ZZDDHMAN and it's */
/*     subroutines: */

/*        At the start of this routine, we assume no files */
/*        are loaded in the handle manager.  This is expected for */
/*        a test family. */

/*        When FNAME is open, it is assigned a unit and placed */
/*        at the head of the unit table. */

/*        Once the UTSIZE files are loaded, the cost bumping */
/*        system works such that the last file loaded into the */
/*        handle manager takes FNAME's place. */

/*        Then when we make the second ZZDDHUNL call the file */
/*        FNAME gets assigned the logical unit that was assigned */
/*        to the first file in the list of UTSIZE files. */


/*     As convoluted as that is, it works.  Do the consistency check. */

    chcksi_("ALTUNT", &altunt, "!=", &unit, &c__0, ok, (ftnlen)6, (ftnlen)2);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);
    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhunl__", (ftnlen)486)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Scratch File Execution", (ftnlen)30);

/*     Setup the inputs and outputs. */

    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    unit = 0;
    altunt = 0;

/*     Now to perform this test, we need to verify that the unlock */
/*     actually occurs.  To do this we will create UTSIZE additional */
/*     files and load them, then proceed by making logical unit */
/*     requests for each of them to cycle FNAME out of the unit table. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }

/*     Open test.fil. */

    zzddhopn_(" ", "SCRATCH", arch, &handle, (ftnlen)1, (ftnlen)7, (ftnlen)20)
	    ;

/*     Retrieve the logical unit.  Scratch files are locked to their */
/*     units by the open routine. */

    zzddhhlu_(&handle, arch, &c_false, &unit, (ftnlen)20);

/*     Check to see that UNIT is not zero. */

    chcksi_("UNIT", &unit, "!=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)2);

/*     Attempt to unlock the unit. */

    zzddhunl_(&handle, arch, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now open the UTSIZE files and to cycle through the units. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhunl__", (ftnlen)
		549)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now request the UNIT for HANDLE. */

    zzddhhlu_(&handle, arch, &c_true, &altunt, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Since SCRATCH files must always be locked to their logical units, */
/*     the call to ZZDDHUNL is effectively a no-op.  From the nominal */
/*     execution case, we know that opening UTSIZE files should force */
/*     the original scratch file to be rotated out of the unit table */
/*     in ZZDDHMAN and be reassigned a different unit.  Since this can */
/*     not happen, check to see if ALTUNT is UNIT (verifying the lock). */

    chcksi_("ALTUNT", &altunt, "=", &unit, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);
    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhunl__", (ftnlen)584)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhunl__ */

