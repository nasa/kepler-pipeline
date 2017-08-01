/* f_ddhrmu.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__10 = 10;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__30 = 30;
static integer c__3 = 3;
static integer c__40 = 40;
static integer c__4 = 4;

/* $Procedure F_DDHRMU ( ZZDDHRMU Test Family ) */
/* Subroutine */ int f_ddhrmu__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    extern /* Subroutine */ int zzddhrmu_(integer *, integer *, integer *, 
	    integer *, logical *, integer *, integer *), t_tstrln__(integer *,
	     logical *);
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer uthan[23];
    logical utlck[23];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer utcst[23], utlun[23];
    extern /* Subroutine */ int t_success__(logical *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen), frelun_(integer *);
    integer uindex;
    extern /* Subroutine */ int getlun_(integer *);
    logical resrvd;
    integer nft, lun, nut;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHRMU */
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

/*     This routine exercises ZZDDHRMU's logic. */

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

/*     Local Variables */


/*     The unit table columns */


/*     Start the test family with an open call. */

    topen_("F_DDHRMU", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Empty unit table exceptional case.", (ftnlen)34);

/*     Prepare the inputs and output default values. */

    uindex = 1;
    nut = 0;
    nft = 1;

/*     Invoke the module. */

    zzddhrmu_(&uindex, &nft, utcst, uthan, utlck, utlun, &nut);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("UINDEX out of range exception.", (ftnlen)30);

/*     Prepare the inputs and output default values. */

    nut = 10;
    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	utcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utcst", 
		i__2, "f_ddhrmu__", (ftnlen)166)] = i__ * 10;
	uthan[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("uthan", 
		i__2, "f_ddhrmu__", (ftnlen)167)] = i__;
	utlck[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlck", 
		i__2, "f_ddhrmu__", (ftnlen)168)] = FALSE_;
	utlun[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlun", 
		i__2, "f_ddhrmu__", (ftnlen)169)] = i__;
    }
    uindex = 5000;
    nft = 12;

/*     Invoke the module. */

    zzddhrmu_(&uindex, &nft, utcst, uthan, utlck, utlun, &nut);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(INDEXOUTOFRANGE)", ok, (ftnlen)22);

/* --- Case: ------------------------------------------------------ */

    tcase_("Test table compression case.", (ftnlen)28);

/*     Prepare the inputs and output default values. */

    nut = 4;
    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	utcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utcst", 
		i__2, "f_ddhrmu__", (ftnlen)199)] = i__ * 10;
	uthan[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("uthan", 
		i__2, "f_ddhrmu__", (ftnlen)200)] = i__;
	utlck[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlck", 
		i__2, "f_ddhrmu__", (ftnlen)201)] = FALSE_;
	utlun[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlun", 
		i__2, "f_ddhrmu__", (ftnlen)202)] = i__;
    }
    uindex = 2;
    nft = 3;

/*     Invoke the module. */

    zzddhrmu_(&uindex, &nft, utcst, uthan, utlck, utlun, &nut);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksi_("UTCST(1)", utcst, "=", &c__10, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTHAN(1)", uthan, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksl_("UTLCK(1)", utlck, &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(1)", utlun, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTCST(2)", &utcst[1], "=", &c__30, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTHAN(2)", &uthan[1], "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksl_("UTLCK(2)", &utlck[1], &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(2)", &utlun[1], "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTCST(3)", &utcst[2], "=", &c__40, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTHAN(3)", &uthan[2], "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksl_("UTLCK(3)", &utlck[2], &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(3)", &utlun[2], "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("NUT", &nut, "=", &c__3, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Zero row test case.", (ftnlen)19);

/*     Prepare the inputs and output default values. */

    nut = 4;
    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	utcst[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utcst", 
		i__2, "f_ddhrmu__", (ftnlen)252)] = i__ * 10;
	uthan[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("uthan", 
		i__2, "f_ddhrmu__", (ftnlen)253)] = i__;
	utlck[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlck", 
		i__2, "f_ddhrmu__", (ftnlen)254)] = FALSE_;
	utlun[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : s_rnge("utlun", 
		i__2, "f_ddhrmu__", (ftnlen)255)] = i__;
    }
    uindex = 2;
    nft = 4;

/*     Setup row 2 with an actual logical unit. */

    getlun_(&lun);
    utlun[1] = lun;

/*     Invoke the module. */

    zzddhrmu_(&uindex, &nft, utcst, uthan, utlck, utlun, &nut);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs */

    chcksi_("UTCST(1)", utcst, "=", &c__10, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTHAN(1)", uthan, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksl_("UTLCK(1)", utlck, &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(1)", utlun, "=", &c__1, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTCST(2)", &utcst[1], "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTHAN(2)", &uthan[1], "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksl_("UTLCK(2)", &utlck[1], &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(2)", &utlun[1], "=", &lun, &c__0, ok, (ftnlen)8, (ftnlen)1)
	    ;
    chcksi_("UTCST(3)", &utcst[2], "=", &c__30, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTHAN(3)", &uthan[2], "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksl_("UTLCK(3)", &utlck[2], &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(3)", &utlun[2], "=", &c__3, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTCST(4)", &utcst[3], "=", &c__40, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("UTHAN(4)", &uthan[3], "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksl_("UTLCK(4)", &utlck[3], &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(4)", &utlun[3], "=", &c__4, &c__0, ok, (ftnlen)8, (ftnlen)
	    1);
    chcksi_("NUT", &nut, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Check to see if LUN is reserved. */

    t_tstrln__(&lun, &resrvd);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the value of RESRVD. */

    chcksl_("RESRVD", &resrvd, &c_true, ok, (ftnlen)6);

/*     Free up the logical unit. */

    frelun_(&lun);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhrmu__ */

