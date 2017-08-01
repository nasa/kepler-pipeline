/* f_ddhgtu.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static integer c__1 = 1;
static integer c__5 = 5;
static integer c__10 = 10;
static integer c__11 = 11;
static integer c__4 = 4;
static integer c__23 = 23;
static integer c__20 = 20;
static logical c_true = TRUE_;

/* $Procedure F_DDHGTU ( ZZDDHGTU Test Family ) */
/* Subroutine */ int f_ddhgtu__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    olist o__1;
    inlist ioin__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), f_open(olist *), f_inqu(
	    inlist *);

    /* Local variables */
    extern /* Subroutine */ int zzddhgtu_(integer *, integer *, logical *, 
	    integer *, integer *, integer *), t_tstrln__(integer *, logical *)
	    ;
    integer i__;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer uthan[23];
    logical utlck[23];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer utcst[23], utlun[23];
    extern /* Subroutine */ int t_success__(logical *), chckxc_(logical *, 
	    char *, logical *, ftnlen), chcksi_(char *, integer *, char *, 
	    integer *, integer *, logical *, ftnlen, ftnlen), chcksl_(char *, 
	    logical *, logical *, logical *, ftnlen);
    logical opened;
    extern /* Subroutine */ int frelun_(integer *);
    integer uindex;
    extern /* Subroutine */ int getlun_(integer *);
    integer iostat;
    logical resrvd;
    extern /* Subroutine */ int reslun_(integer *);
    integer lun, nut;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHGTU */
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

/*     This routine exercises ZZDDHGTU's logic.  Functionality it */
/*     does not properly test at the moment: */

/*     (1) When GETLUN signals an error, does this routine return */
/*         UINDEX into a row with a -1 value for UTLUN(UINDEX). */

/*     Point (1) could be tested by adding a pile of RESLUN calls */
/*     to this module. */

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


/*     Unit Table */


/*     Start the test family with an open call. */

    topen_("F_DDHGTU", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("Empty unit table insertion.", (ftnlen)27);

/*     Prepare the inputs and output default values. */

    utcst[0] = 1;
    uthan[0] = 1;
    utlck[0] = TRUE_;
    utlun[0] = 1;
    nut = 0;
    uindex = -1;

/*     Invoke the module. */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the values. */

    chcksi_("UTCST(1)", utcst, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksi_("UTHAN(1)", uthan, "=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)1);
    chcksl_("UTLCK(1)", utlck, &c_false, ok, (ftnlen)8);
    chcksi_("UTLUN(1)", utlun, ">=", &c__0, &c__0, ok, (ftnlen)8, (ftnlen)2);
    chcksi_("NUT", &nut, "=", &c__1, &c__0, ok, (ftnlen)3, (ftnlen)1);
    chcksi_("UINDEX", &uindex, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Zero cost row exists in the unit table", (ftnlen)38);

/*     Prepare the inputs and output default values. */

    nut = 10;
    for (i__ = 1; i__ <= 10; ++i__) {
	utcst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhgtu__", (ftnlen)193)] = i__ * 10;
	uthan[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhgtu__", (ftnlen)194)] = i__;
	utlck[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhgtu__", (ftnlen)195)] = FALSE_;
	utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhgtu__", (ftnlen)196)] = i__;
    }

/*     Create the zero cost row. */

    utcst[4] = 0;

/*     Actually get a logical unit from GETLUN and lock it down. */

    getlun_(&lun);
    reslun_(&lun);
    utlun[4] = lun;
    uindex = -1;

/*     Exercise the module. (Note: It will 'FRELUN' UTLUN(5) ) */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception, one should not have been signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the relevant values. */

    chcksi_("UINDEX", &uindex, "=", &c__5, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("UTCST(UINDEX)", &utcst[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utcst", i__1, "f_ddhgtu__", (ftnlen)229)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTHAN(UINDEX)", &uthan[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("uthan", i__1, "f_ddhgtu__", (ftnlen)230)], "=", &
	    c__5, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksl_("UTLCK(UINDEX)", &utlck[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlck", i__1, "f_ddhgtu__", (ftnlen)232)], &
	    c_false, ok, (ftnlen)13);
    chcksi_("NUT", &nut, "=", &c__10, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Check to see if LUN is still reserved with RESLUN. */

    t_tstrln__(&lun, &resrvd);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check the value of RESRVD. */

    chcksl_("RESRVD", &resrvd, &c_false, ok, (ftnlen)6);

/*     Just to be safe, free LUN. */

    frelun_(&lun);

/* --- Case: ------------------------------------------------------ */

    tcase_("No zero cost rows, expand table case.", (ftnlen)37);

/*     Prepare the inputs and output default values. */

    nut = 10;
    for (i__ = 1; i__ <= 10; ++i__) {
	utcst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhgtu__", (ftnlen)268)] = i__ * 10;
	uthan[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhgtu__", (ftnlen)269)] = i__;
	utlck[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhgtu__", (ftnlen)270)] = FALSE_;
	utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhgtu__", (ftnlen)271)] = i__;
    }
    uindex = -1;

/*     Prepare the initial values for the row that will be returned. */

    utcst[10] = -1;
    uthan[10] = -1;
    utlck[10] = TRUE_;
    utlun[10] = -1;

/*     Exercise the module. */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception, one should not have been signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the relevant values. */

    chcksi_("UINDEX", &uindex, "=", &c__11, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("UTCST(UINDEX)", &utcst[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utcst", i__1, "f_ddhgtu__", (ftnlen)300)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTHAN(UINDEX)", &uthan[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("uthan", i__1, "f_ddhgtu__", (ftnlen)301)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksl_("UTLCK(UINDEX)", &utlck[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlck", i__1, "f_ddhgtu__", (ftnlen)303)], &
	    c_false, ok, (ftnlen)13);
    chcksi_("UTLUN(UINDEX)", &utlun[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlun", i__1, "f_ddhgtu__", (ftnlen)305)], ">=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)2);
    chcksi_("NUT", &nut, "=", &c__11, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Full table, no zero-cost rows.", (ftnlen)30);

/*     Prepare the inputs and output default values. */

    nut = 23;
    for (i__ = 1; i__ <= 23; ++i__) {
	utcst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhgtu__", (ftnlen)321)] = i__ * 10;
	uthan[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhgtu__", (ftnlen)322)] = i__;
	utlck[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhgtu__", (ftnlen)323)] = FALSE_;
	utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhgtu__", (ftnlen)324)] = i__;
    }
    uindex = -1;

/*     Lock a few low cost rows to exercise that logic. */

    utlck[0] = TRUE_;
    utlck[1] = TRUE_;
    utlck[2] = TRUE_;

/*     Since the fourth row will be selected by ZZDDHGTU, retrieve a */
/*     logical unit for it. */

    getlun_(&lun);
    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Store this unit in the LUN column of the unit table. */

    utlun[3] = lun;

/*     Now open a scratch file to connect to the unit. */

    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnm = 0;
    o__1.orl = 1024;
    o__1.osta = "SCRATCH";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);
    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Exercise the module. */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception, one should not have been signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the relevant values. */

    chcksi_("UINDEX", &uindex, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Determine if ZZDDHGTU properly closed the unit. */

    ioin__1.inerr = 1;
    ioin__1.inunit = lun;
    ioin__1.infile = 0;
    ioin__1.inex = 0;
    ioin__1.inopen = &opened;
    ioin__1.innum = 0;
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
    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksi_("UTCST(UINDEX)", &utcst[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utcst", i__1, "f_ddhgtu__", (ftnlen)387)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTHAN(UINDEX)", &uthan[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("uthan", i__1, "f_ddhgtu__", (ftnlen)388)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTLUN(UINDEX)", &utlun[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlun", i__1, "f_ddhgtu__", (ftnlen)389)], "=", &
	    lun, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksl_("UTLCK(UINDEX)", &utlck[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlck", i__1, "f_ddhgtu__", (ftnlen)391)], &
	    c_false, ok, (ftnlen)13);
    chcksi_("NUT", &nut, "=", &c__23, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Full table, monotonic decreasing cost, no zero.", (ftnlen)47);

/*     Prepare the inputs and output default values. */

    nut = 23;
    for (i__ = 1; i__ <= 23; ++i__) {
	utcst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhgtu__", (ftnlen)407)] = (24 - i__) * 10;
	uthan[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhgtu__", (ftnlen)408)] = i__;
	utlck[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhgtu__", (ftnlen)409)] = FALSE_;
	utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhgtu__", (ftnlen)410)] = i__;
    }
    uindex = -1;

/*     Lock a few low cost rows to exercise that logic. */

    utlck[20] = TRUE_;
    utlck[21] = TRUE_;
    utlck[22] = TRUE_;

/*     Since the fourth row will be selected by ZZDDHGTU, retrieve a */
/*     logical unit for it and open a scratch file. */

    getlun_(&lun);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    utlun[19] = lun;
    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnm = 0;
    o__1.orl = 1024;
    o__1.osta = "SCRATCH";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);
    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Exercise the module. */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception, one should not have been signaled. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Now check the relevant values. */

    chcksi_("UINDEX", &uindex, "=", &c__20, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Determine if ZZDDHGTU properly closed the unit. */

    ioin__1.inerr = 1;
    ioin__1.inunit = lun;
    ioin__1.infile = 0;
    ioin__1.inex = 0;
    ioin__1.inopen = &opened;
    ioin__1.innum = 0;
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
    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksi_("UTCST(UINDEX)", &utcst[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utcst", i__1, "f_ddhgtu__", (ftnlen)467)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTHAN(UINDEX)", &uthan[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("uthan", i__1, "f_ddhgtu__", (ftnlen)468)], "=", &
	    c__0, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksi_("UTLUN(UINDEX)", &utlun[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlun", i__1, "f_ddhgtu__", (ftnlen)469)], "=", &
	    lun, &c__0, ok, (ftnlen)13, (ftnlen)1);
    chcksl_("UTLCK(UINDEX)", &utlck[(i__1 = uindex - 1) < 23 && 0 <= i__1 ? 
	    i__1 : s_rnge("utlck", i__1, "f_ddhgtu__", (ftnlen)471)], &
	    c_false, ok, (ftnlen)13);
    chcksi_("NUT", &nut, "=", &c__23, &c__0, ok, (ftnlen)3, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Full table, all rows locked exception.", (ftnlen)38);

/*     Prepare the inputs and output default values. */

    nut = 23;
    for (i__ = 1; i__ <= 23; ++i__) {
	utcst[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhgtu__", (ftnlen)487)] = i__ * 10;
	uthan[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhgtu__", (ftnlen)488)] = i__;
	utlck[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhgtu__", (ftnlen)489)] = TRUE_;
	utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhgtu__", (ftnlen)490)] = i__;
    }
    uindex = -1;

/*     Exercise the module. */

    zzddhgtu_(utcst, uthan, utlck, utlun, &nut, &uindex);

/*     Check for an exception, SPICE(BUG) should have been signaled. */

    chckxc_(&c_true, "SPICE(BUG)", ok, (ftnlen)10);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhgtu__ */

