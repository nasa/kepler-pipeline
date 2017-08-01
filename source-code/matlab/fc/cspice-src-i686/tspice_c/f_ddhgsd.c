/* f_ddhgsd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__0 = 0;
static logical c_false = FALSE_;
static integer c__1 = 1;
static integer c__2 = 2;
static integer c__3 = 3;
static integer c__4 = 4;

/* $Procedure F_DDHGSD ( ZZDDHGSD Test Family ) */
/* Subroutine */ int f_ddhgsd__(logical *ok)
{
    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzddhgsd_(char *, integer *, char *, ftnlen, 
	    ftnlen), tcase_(char *, ftnlen), topen_(char *, ftnlen), 
	    t_success__(logical *), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen), chckxc_(logical *, 
	    char *, logical *, ftnlen);
    char outary[32*4], output[32];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHGSD */
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

/*     This routine exercises ZZDDHGSD's logic. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 05-SEP-2001 (FST) */

/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHGSD", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Unknown Class and ID Exceptions", (ftnlen)31);

/*     Prepare the inputs and output default values. */

    s_copy(output, " ", (ftnlen)32, (ftnlen)1);

/*     Invoke the module. */

    zzddhgsd_("UNKNOWN", &c__0, output, (ftnlen)7, (ftnlen)32);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksc_("OUTPUT", output, "=", " ", ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, 
	    (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Abnormal Input (case) and (justification)", (ftnlen)41);

/*     Prepare the inputs and output default values. */

    s_copy(output, " ", (ftnlen)32, (ftnlen)1);

/*     Invoke the module. */

    zzddhgsd_("   MEthOd", &c__1, output, (ftnlen)9, (ftnlen)32);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksc_("OUTPUT", output, "=", "READ", ok, (ftnlen)6, (ftnlen)32, (ftnlen)
	    1, (ftnlen)4);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Method Label Lookups", (ftnlen)28);

/*     Prepare the inputs and output default values. */

    s_copy(outary, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 96, " ", (ftnlen)32, (ftnlen)1);

/*     Invoke the module. */

    zzddhgsd_("METHOD", &c__1, outary, (ftnlen)6, (ftnlen)32);
    zzddhgsd_("METHOD", &c__2, outary + 32, (ftnlen)6, (ftnlen)32);
    zzddhgsd_("METHOD", &c__3, outary + 64, (ftnlen)6, (ftnlen)32);
    zzddhgsd_("METHOD", &c__4, outary + 96, (ftnlen)6, (ftnlen)32);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksc_("METHOD(READ)", outary, "=", "READ", ok, (ftnlen)12, (ftnlen)32, (
	    ftnlen)1, (ftnlen)4);
    chcksc_("METHOD(WRITE)", outary + 32, "=", "WRITE", ok, (ftnlen)13, (
	    ftnlen)32, (ftnlen)1, (ftnlen)5);
    chcksc_("METHOD(SCRTCH)", outary + 64, "=", "SCRATCH", ok, (ftnlen)14, (
	    ftnlen)32, (ftnlen)1, (ftnlen)7);
    chcksc_("METHOD(NEW)", outary + 96, "=", "NEW", ok, (ftnlen)11, (ftnlen)
	    32, (ftnlen)1, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Architecture Label Lookups", (ftnlen)34);

/*     Prepare the inputs and output default values. */

    s_copy(outary, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 32, " ", (ftnlen)32, (ftnlen)1);

/*     Invoke the module. */

    zzddhgsd_("ARCH", &c__1, outary, (ftnlen)4, (ftnlen)32);
    zzddhgsd_("ARCH", &c__2, outary + 32, (ftnlen)4, (ftnlen)32);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksc_("ARCH(DAF)", outary, "=", "DAF", ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)3);
    chcksc_("ARCH(DAS)", outary + 32, "=", "DAS", ok, (ftnlen)9, (ftnlen)32, (
	    ftnlen)1, (ftnlen)3);

/* --- Case: ------------------------------------------------------ */

    tcase_("Nominal Binary File Format Label Lookups", (ftnlen)40);

/*     Prepare the inputs and output default values. */

    s_copy(outary, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 32, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 64, " ", (ftnlen)32, (ftnlen)1);
    s_copy(outary + 96, " ", (ftnlen)32, (ftnlen)1);

/*     Invoke the module. */

    zzddhgsd_("BFF", &c__1, outary, (ftnlen)3, (ftnlen)32);
    zzddhgsd_("BFF", &c__2, outary + 32, (ftnlen)3, (ftnlen)32);
    zzddhgsd_("BFF", &c__3, outary + 64, (ftnlen)3, (ftnlen)32);
    zzddhgsd_("BFF", &c__4, outary + 96, (ftnlen)3, (ftnlen)32);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksc_("BFF(BIGI3E)", outary, "=", "BIG-IEEE", ok, (ftnlen)11, (ftnlen)
	    32, (ftnlen)1, (ftnlen)8);
    chcksc_("BFF(LTLI3E)", outary + 32, "=", "LTL-IEEE", ok, (ftnlen)11, (
	    ftnlen)32, (ftnlen)1, (ftnlen)8);
    chcksc_("BFF(VAXGFL)", outary + 64, "=", "VAX-GFLT", ok, (ftnlen)11, (
	    ftnlen)32, (ftnlen)1, (ftnlen)8);
    chcksc_("BFF(VAXDFL)", outary + 96, "=", "VAX-DFLT", ok, (ftnlen)11, (
	    ftnlen)32, (ftnlen)1, (ftnlen)8);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhgsd__ */

