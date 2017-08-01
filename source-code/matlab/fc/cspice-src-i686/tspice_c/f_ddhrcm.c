/* f_ddhrcm.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__10001 = 10001;
static integer c__0 = 0;
static integer c_b33 = 101000001;
static integer c__10 = 10;

/* $Procedure F_DDHRCM ( ZZDDHRCM Test Family ) */
/* Subroutine */ int f_ddhrcm__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int zzddhrcm_(integer *, integer *, integer *);
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer ckcst[23];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer utcst[23];
    extern /* Subroutine */ int t_success__(logical *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen);
    integer reqcnt;
    extern integer intmax_(void);
    integer nut;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHRCM */
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

/*     This routine exercises ZZDDHRCM's logic. */

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

/*     SPICELIB Functions */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHRCM", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Empty table with REQCNT less than INTMAX.", (ftnlen)41);

/*     Prepare the inputs and output default values. */

    utcst[0] = 500;
    nut = 0;
    reqcnt = 10000;

/*     Invoke the module. */

    zzddhrcm_(&nut, utcst, &reqcnt);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksi_("REQCNT", &reqcnt, "=", &c__10001, &c__0, ok, (ftnlen)6, (ftnlen)
	    1);
    chcksi_("NUT", &nut, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Empty table with REQCNT at INTMAX.", (ftnlen)34);

/*     Prepare the inputs and output default values. */

    utcst[0] = 500;
    nut = 0;
    reqcnt = intmax_();

/*     Invoke the module. */

    zzddhrcm_(&nut, utcst, &reqcnt);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    i__1 = intmax_() / 2 + 1;
    chcksi_("REQCNT", &reqcnt, "=", &i__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NUT", &nut, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Non-empty table, REQCNT less than INTMAX.", (ftnlen)41);

/*     Prepare the inputs and output default values. */

    nut = 10;
    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	utcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utcst", 
		i__2, "f_ddhrcm__", (ftnlen)199)] = i__ * 10000;
	ckcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("ckcst", 
		i__2, "f_ddhrcm__", (ftnlen)200)] = i__ * 10000;
    }
    reqcnt = 101000000;

/*     Invoke the module. */

    zzddhrcm_(&nut, utcst, &reqcnt);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksi_("REQCNT", &reqcnt, "=", &c_b33, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("UTCST(1)", utcst, "=", ckcst, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTCST(2)", &utcst[1], "=", &ckcst[1], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(3)", &utcst[2], "=", &ckcst[2], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(4)", &utcst[3], "=", &ckcst[3], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(5)", &utcst[4], "=", &ckcst[4], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(6)", &utcst[5], "=", &ckcst[5], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(7)", &utcst[6], "=", &ckcst[6], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(8)", &utcst[7], "=", &ckcst[7], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(9)", &utcst[8], "=", &ckcst[8], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(10)", &utcst[9], "=", &ckcst[9], &c__0, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("NUT", &nut, "=", &c__10, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Non-empty table, REQCNT is INTMAX.", (ftnlen)34);

/*     Prepare the inputs and output default values. */

    nut = 10;
    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	utcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utcst", 
		i__2, "f_ddhrcm__", (ftnlen)246)] = i__ * 10000;
	ckcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("ckcst", 
		i__2, "f_ddhrcm__", (ftnlen)247)] = i__ * 5000;
    }

/*     Set REQCNT to INTMAX and UTCST(7) to 1 to test the */
/*     MAX(1,...) logic. */

    reqcnt = intmax_();
    utcst[6] = 1;
    ckcst[6] = 1;

/*     Invoke the module. */

    zzddhrcm_(&nut, utcst, &reqcnt);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    i__1 = intmax_() / 2 + 1;
    chcksi_("REQCNT", &reqcnt, "=", &i__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("UTCST(1)", utcst, "=", ckcst, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTCST(2)", &utcst[1], "=", &ckcst[1], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(3)", &utcst[2], "=", &ckcst[2], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(4)", &utcst[3], "=", &ckcst[3], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(5)", &utcst[4], "=", &ckcst[4], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(6)", &utcst[5], "=", &ckcst[5], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(7)", &utcst[6], "=", &ckcst[6], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(8)", &utcst[7], "=", &ckcst[7], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(9)", &utcst[8], "=", &ckcst[8], &c__0, ok, (ftnlen)8, (
	    ftnlen)1);
    chcksi_("UTCST(10)", &utcst[9], "=", &ckcst[9], &c__0, ok, (ftnlen)9, (
	    ftnlen)1);
    chcksi_("NUT", &nut, "=", &c__10, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhrcm__ */

