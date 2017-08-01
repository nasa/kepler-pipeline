/* f_ddhcls.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__1 = 1;
static integer c__0 = 0;
static integer c__4 = 4;

/* $Procedure F_DDHCLS ( ZZDDHCLS Test Family ) */
/* Subroutine */ int f_ddhcls__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    logical L__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    char arch[20];
    integer unit;
    extern /* Subroutine */ int zzddhcls_(integer *, char *, logical *, 
	    ftnlen), zzddhnfo_(integer *, char *, integer *, integer *, 
	    integer *, logical *, ftnlen), zzddhhlu_(integer *, char *, 
	    logical *, integer *, ftnlen), zzddhopn_(char *, char *, char *, 
	    integer *, ftnlen, ftnlen, ftnlen);
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
    char altarc[20];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    integer intbff;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    char altfnm[255], method[20];
    integer intamh;
    char fnmpat[255];
    integer hanlst[23], intarc;
    extern /* Subroutine */ int frelun_(integer *);
    char tmpfnm[255];
    integer altunt;
    extern /* Subroutine */ int reslun_(integer *);
    extern logical exists_(char *, ftnlen);

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHCLS */
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

/*     This routine exercises ZZDDHCLS's logic. */

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

/* -    TSPICE Version 1.0.0, 06-SEP-2001 (FST) */

/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHCLS", (ftnlen)8);

/*     Set the filename pattern. */

    s_copy(fnmpat, "test#.fil", (ftnlen)255, (ftnlen)9);

/* --- Case: ------------------------------------------------------ */

    tcase_("Handle not found NO-OP exception.", (ftnlen)33);

/*     Setup the inputs and outputs. */

    handle = 0;
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);

/*     Invoke the module. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Alternate-signed handle NO-OP exception.", (ftnlen)40);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open a new file to close. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if the file is closed. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Architecture mismatch Exception.", (ftnlen)32);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    s_copy(altarc, "DAS", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open a new file to close. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhcls_(&handle, altarc, &c_false, (ftnlen)20);

/*     Check for the presence of an exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     See if the file is closed, it should not be. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("INTARC", &intarc, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTAMH", &intamh, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if the file is closed. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid Architecture Mismatch Exception.", (ftnlen)40);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;
    s_copy(altarc, "UNK", (ftnlen)20, (ftnlen)3);

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open a new file to close. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhcls_(&handle, altarc, &c_false, (ftnlen)20);

/*     Check for the presence of an exception. */

    chckxc_(&c_true, "SPICE(FILARCMISMATCH)", ok, (ftnlen)21);

/*     See if the file is closed, it should not be. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksi_("INTARC", &intarc, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("INTAMH", &intamh, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if the file is closed. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("KILL set to TRUE, no UNIT attached exception.", (ftnlen)45);

/*     Setup the inputs and outputs. */

    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhcls__", (ftnlen)
		368)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Open an additional file to bump out the first loaded */
/*     one. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Close the first file with KILL set. */

    zzddhcls_(hanlst, arch, &c_true, (ftnlen)20);

/*     Check for the expected exception. */

    chckxc_(&c_true, "SPICE(FILENOTCONNECTED)", ok, (ftnlen)23);

/*     Check to see that the file is actually closed. */

    zzddhnfo_(hanlst, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255);
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    repmi_(fnmpat, "#", &c__1, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    kilfil_(tmpfnm, (ftnlen)255);
    for (i__ = 2; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhcls__", (ftnlen)404)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Execution.", (ftnlen)18);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open a new file to close. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if the file is closed. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Execution - KILL set to TRUE.", (ftnlen)37);

/*     Setup the inputs and outputs. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);
    handle = 0;

/*     Kill FNAME. */

    kilfil_(fname, (ftnlen)255);

/*     Open a new file to close. */

    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Invoke the module. */

    zzddhcls_(&handle, arch, &c_true, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     See if the file is closed. */

    zzddhnfo_(&handle, altfnm, &intarc, &intbff, &intamh, &found, (ftnlen)255)
	    ;
    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);

/*     See if the file was properly deleted. */

    L__1 = exists_(fname, (ftnlen)255);
    chcksl_("EXISTS", &L__1, &c_false, ok, (ftnlen)6);

/*     Clean up. */

    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("Unit Table Clean Up Execution.", (ftnlen)30);

/*     This test case is a bit unusual... so I am going to list */
/*     the steps we will take out here before getting started. */

/*     (1) Open UTSIZE files. */
/*     (2) Use ZZDDHHLU to fetch the unit assigned to the first */
/*         file loaded. */
/*     (3) Open one additional file to bump out the first loaded */
/*         file from the unit table. */
/*     (4) Close this additional file.  Now at this point we have */
/*         UTSIZE files loaded in the file table, and UTSIZE-1 */
/*         "active" rows in the unit table and one inactive one. */
/*     (5) Close the first file loaded.  This will force ZZDDHCLS */
/*         to clean up the unit table and remove the row created */
/*         when the first file was opened. */
/*     (6) Using RESLUN reserve the unit originally assigned to */
/*         the first file. */
/*     (7) Open a new file. */
/*     (8) Fetch its unit using ZZDDHHLU. */
/*     (9) This unit must disagree with the unit we reserved, */
/*         and this disagreement indicates the zero handle row */
/*         was properly compressed out of the unit table. */
/*     (-) Clean up. */


/*     Setup the inputs and outputs. */

    s_copy(method, "NEW", (ftnlen)20, (ftnlen)3);
    s_copy(arch, "DAF", (ftnlen)20, (ftnlen)3);

/*     Open UTSIZE files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
	zzddhopn_(tmpfnm, method, arch, &hanlst[(i__1 = i__ - 1) < 23 && 0 <= 
		i__1 ? i__1 : s_rnge("hanlst", i__1, "f_ddhcls__", (ftnlen)
		551)], (ftnlen)255, (ftnlen)20, (ftnlen)20);
    }

/*     Retrieve the unit assigned to the first file. */

    zzddhhlu_(hanlst, arch, &c_false, &unit, (ftnlen)20);

/*     Open an additional file to bump out the first loaded */
/*     one. */

    s_copy(fname, "test.fil", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    zzddhopn_(fname, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Close this file. */

    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);

/*     Close the first loaded file. */

    zzddhcls_(hanlst, arch, &c_false, (ftnlen)20);

/*     Reserve the original unit. */

    reslun_(&unit);

/*     Open another new file. */

    s_copy(altfnm, "alt.fil", (ftnlen)255, (ftnlen)7);
    kilfil_(altfnm, (ftnlen)255);
    zzddhopn_(altfnm, method, arch, &handle, (ftnlen)255, (ftnlen)20, (ftnlen)
	    20);

/*     Retrieve the unit to which it was assigned. */

    zzddhhlu_(&handle, arch, &c_false, &altunt, (ftnlen)20);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Verify that UNIT and ALTUNT do not agree. */

    chcksi_("UNIT", &unit, "!=", &altunt, &c__0, ok, (ftnlen)4, (ftnlen)2);

/*     Clean up. */

    for (i__ = 2; i__ <= 23; ++i__) {
	zzddhcls_(&hanlst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"hanlst", i__1, "f_ddhcls__", (ftnlen)609)], arch, &c_false, (
		ftnlen)20);
	repmi_(fnmpat, "#", &i__, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	kilfil_(tmpfnm, (ftnlen)255);
    }
    zzddhcls_(&handle, arch, &c_false, (ftnlen)20);
    kilfil_(altfnm, (ftnlen)255);
    kilfil_(fname, (ftnlen)255);
    repmi_(fnmpat, "#", &c__1, tmpfnm, (ftnlen)255, (ftnlen)1, (ftnlen)255);
    kilfil_(tmpfnm, (ftnlen)255);
    frelun_(&unit);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhcls__ */

