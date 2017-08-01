/* f_ddhhlu.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_true = TRUE_;
static integer c__0 = 0;
static logical c_false = FALSE_;
static integer c__1 = 1;

/* $Procedure F_DDHHLU ( ZZDDHHLU Test Family ) */
/* Subroutine */ int f_ddhhlu__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    inlist ioin__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_inqu(inlist *);

    /* Local variables */
    char arch[20];
    logical lock;
    integer unit;
    extern /* Subroutine */ int zzddhcls_(integer *, char *, logical *, 
	    ftnlen), zzddhhlu_(integer *, char *, logical *, integer *, 
	    ftnlen), zzddhopn_(char *, char *, char *, integer *, ftnlen, 
	    ftnlen, ftnlen);
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
    integer iostat, altunt;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHHLU */
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

/*     This routine exercises ZZDDHHLU's logic.  A few IOSTAT based */
/*     exceptions are not properly exercised by this test module, as */
/*     well as a few SPICE(BUG) exceptions. */

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

    topen_("F_DDHHLU", (ftnlen)8);

/*     Set the filename pattern. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/* --- Case: ------------------------------------------------------ */

    tcase_("Missing Handle Exception.", (ftnlen)25);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;

/*     Invoke the module. */

    zzddhhlu_(&handle, arch, &lock, &unit, (ftnlen)20);

/*     Now check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(NOSUCHHANDLE)", ok, (ftnlen)19);

/*     Check the value of UNIT, it should be 0. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Alternate Signed Handle Exception.", (ftnlen)34);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open the new test file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Invoke the module. */

    i__1 = -handle;
    zzddhhlu_(&i__1, arch, &lock, &unit, (ftnlen)20);

/*     Now check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(NOSUCHHANDLE)", ok, (ftnlen)19);

/*     Check the value of UNIT, it should be 0. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Architecture Mismatch Exception.", (ftnlen)32);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(altarc, "DAS", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open the new test file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Invoke the module. */

    zzddhhlu_(&handle, altarc, &lock, &unit, (ftnlen)20);

/*     Now check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check the value of UNIT, it should be 0. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid Architecture Mismatch Exception.", (ftnlen)40);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(altarc, "UNK", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open the new test file. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Invoke the module. */

    zzddhhlu_(&handle, altarc, &lock, &unit, (ftnlen)20);

/*     Now check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     Check the value of UNIT, it should be 0. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Handle Lock Failure Exception.", (ftnlen)30);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = TRUE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Open (UTSIZE - RSVUNT - SCRUNT - 1) files, and lock them to */
/*     their units. */

    for (i__ = 1; i__ <= 20; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhhlu__", (ftnlen)
		348)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
	zzddhhlu_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)349)], arch, &lock, &
		unit, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhhlu_(&handle, arch, &lock, &unit, (ftnlen)20);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(HLULOCKFAILED)", ok, (ftnlen)20);

/*     Check that UNIT is 0. */

    chcksi_("UNIT", &unit, "=", &c__0, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    for (i__ = 1; i__ <= 20; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)384)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Non-lock No LUN Rotate HLU Operation.", (ftnlen)45);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     At this point we know FNAME is attached to a UNIT.  Do an */
/*     INQUIRE to determine which one. */

    ioin__1.inerr = 1;
    ioin__1.infilen = 255;
    ioin__1.infile = fname;
    ioin__1.inex = 0;
    ioin__1.inopen = 0;
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

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Invoke the module. */

    zzddhhlu_(&handle, arch, &lock, &unit, (ftnlen)20);

/*     Check for the absence of the exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that UNIT is ALTUNT.  We know this must be true, */
/*     since no other operations have caused HLU to cycle units. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Non-lock LUN Rotate HLU Operation.", (ftnlen)42);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhhlu__", (ftnlen)
		469)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now perform an INQUIRE on the first file opened to retrieve */
/*     it's logical unit.  The cost function system guarentees that */
/*     we will retrieve (as long as this test is run before INTMAX */
/*     requests for logical units have been made...) the unit for */
/*     this file when we open the next one. */

    repmi_(fnmpat, "#", &c__1, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    ioin__1.inerr = 1;
    ioin__1.infilen = 255;
    ioin__1.infile = tmpfnm;
    ioin__1.inex = 0;
    ioin__1.inopen = 0;
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

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhhlu_(&handle, arch, &lock, &unit, (ftnlen)20);

/*     Check for the absence of the exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that UNIT is ALTUNT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)522)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Rotate in no-lock HLU Operation.", (ftnlen)32);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhhlu__", (ftnlen)
		558)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now perform an INQUIRE on the first file opened to retrieve */
/*     it's logical unit.  The cost function system guarentees that */
/*     we will retrieve (as long as this test is run before INTMAX */
/*     requests for logical units have been made...) the unit for */
/*     this file when we request a unit for FNAME. */

    repmi_(fnmpat, "#", &c__1, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    ioin__1.inerr = 1;
    ioin__1.infilen = 255;
    ioin__1.infile = tmpfnm;
    ioin__1.inex = 0;
    ioin__1.inopen = 0;
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

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Invoke the module. */

    zzddhhlu_(&handle, arch, &lock, &unit, (ftnlen)20);

/*     Check for the absence of the exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check that UNIT is ALTUNT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)605)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Lock before cycle HLU Operation.", (ftnlen)32);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Lock the UNIT. */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhhlu__", (ftnlen)
		646)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Since we opened UTSIZE files, if the lock is not functioning, */
/*     then we would have cycled off HANDLE from the unit table. */
/*     Check. */

    zzddhhlu_(&handle, arch, &c_false, &altunt, (ftnlen)20);

/*     Check for the absence of any exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the value of ALTUNT matches UNIT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Lastly cycle the UTSIZE files again to verify that the */
/*     addition of the .FALSE. in the LOCK argument of the last call */
/*     to ZZDDHHLU does not inadvertantly unlock the file. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhhlu_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)678)], arch, &c_false, &
		altunt, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the unit attached to HANDLE. */

    zzddhhlu_(&handle, arch, &c_true, &altunt, (ftnlen)20);

/*     Check for the absence of any exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the value of ALTUNT matches UNIT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)706)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Lock after cycle HLU Operation.", (ftnlen)31);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    lock = FALSE_;
    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);

/*     Now open FNAME. */

    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhhlu__", (ftnlen)
		742)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Since we opened UTSIZE files, we have cycled HANDLE out */
/*     of the unit table.  Restore and lock it in place. */

    zzddhhlu_(&handle, arch, &c_true, &unit, (ftnlen)20);

/*     Check for the absence of any exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now cycle the UTSIZE files to verify that the lock on */
/*     the UNIT for HANDLE is not broken. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhhlu_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)767)], arch, &c_false, &
		altunt, (ftnlen)20);
    }

/*     Check for any rogue exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the unit attached to HANDLE. */

    zzddhhlu_(&handle, arch, &c_true, &altunt, (ftnlen)20);

/*     Check for the absence of any exceptions. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the value of ALTUNT matches UNIT. */

    chcksi_("UNIT", &unit, "=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)1);

/*     Clean up. */

    for (i__ = 1; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhhlu__", (ftnlen)795)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhhlu__ */

