/* f_ddhf2h.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static integer c__0 = 0;
static logical c_true = TRUE_;
static integer c__1 = 1;
static integer c__13 = 13;
static integer c__28 = 28;

/* $Procedure F_DDHF2H ( ZZDDHF2H Test Family ) */
/* Subroutine */ int f_ddhf2h__(logical *ok)
{
    /* System generated locals */
    integer i__1, i__2;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_open(olist *), f_clos(cllist *), s_rnge(char *, integer, char *,
	     integer);

    /* Local variables */
    extern /* Subroutine */ int zzddhf2h_(char *, integer *, integer *, 
	    integer *, integer *, integer *, char *, integer *, integer *, 
	    integer *, integer *, logical *, integer *, integer *, logical *, 
	    logical *, integer *, logical *, ftnlen, ftnlen);
    integer i__;
    char fname[255];
    integer ftbff[1000], ftabs[1000], ftamh[1000], ftarc[1000], fthan[1000];
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    char ftnam[255*1000];
    integer index;
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer uthan[23];
    logical utlck[23];
    extern /* Subroutine */ int topen_(char *, ftnlen);
    integer ftrtm[1000];
    extern integer rtrim_(char *, ftnlen);
    integer utcst[23], utlun[23];
    extern /* Subroutine */ int t_success__(logical *);
    integer handle;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    logical opened;
    extern /* Subroutine */ int kilfil_(char *, ftnlen);
    extern integer isrchi_(integer *, integer *, integer *);
    extern /* Subroutine */ int frelun_(integer *), getlun_(integer *);
    char fnmtmp[255];
    integer iostat;
    logical exists;
    extern /* Subroutine */ int tstmsg_(char *, char *, ftnlen, ftnlen), 
	    tstspk_(char *, logical *, integer *, ftnlen);
    integer nft, lun, nut;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHF2H */
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

/*     This routine exercises ZZDDHF2H's logic. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 05-AUG-2002 (FST) */

/*        Promoted module to master file status.  Check that */
/*        read-only files on VAX systems can be opened by */
/*        zzddhf2h if necessary. */

/* -    TSPICE Version 1.0.0, 05-SEP-2001 (FST) */

/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     This parameter defines the number of test files we are going */
/*     to create.  It should be something more than UTSIZE, to */
/*     properly execute logic in ZZDDHF2H. */


/*     Local Variables */

/*     File Table */


/*     Unit Table */


/*     Other Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHF2H", (ftnlen)8);
    s_copy(fnmtmp, "spk#.bsp", (ftnlen)255, (ftnlen)8);

/*     Start by creating NUMFIL files for testing purposes. */

    for (i__ = 1; i__ <= 28; ++i__) {
	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	tstspk_(fname, &c_false, &handle, (ftnlen)255);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("File does not exist exceptional case.", (ftnlen)37);

/*     First, kill the file name we are about to check against, since */
/*     it should not exist. */

    kilfil_("spk0.bsp", (ftnlen)8);

/*     Prepare the inputs and output default values. */

    nut = 0;
    nft = 0;
    exists = TRUE_;
    opened = TRUE_;
    handle = -1;
    found = TRUE_;

/*     Invoke the module. */

    zzddhf2h_("spk0.bsp", ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &
	    nft, utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, 
	    &found, (ftnlen)8, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_false, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("File exists and is opened externally exceptional case.", (ftnlen)
	    54);

/*     Open the first test file we created. */

    getlun_(&lun);
    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnmlen = 8;
    o__1.ofnm = "spk1.bsp";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check the IOSTAT. */

    if (iostat != 0) {
	cl__1.cerr = 0;
	cl__1.cunit = lun;
	cl__1.csta = 0;
	f_clos(&cl__1);
	tstmsg_("#", "This IOSTAT error should never occur.", (ftnlen)1, (
		ftnlen)37);
	chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
    }

/*     Setup the inputs and output default values. */

    nut = 0;
    nft = 0;
    exists = FALSE_;
    opened = FALSE_;
    handle = -1;
    found = TRUE_;

/*     Invoke the module. */

    zzddhf2h_("spk1.bsp", ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &
	    nft, utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, 
	    &found, (ftnlen)8, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_true, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the test file. */

    cl__1.cerr = 0;
    cl__1.cunit = lun;
    cl__1.csta = 0;
    f_clos(&cl__1);

/* --- Case: ------------------------------------------------------ */

    tcase_("File exists and is opened internally and is in the unit table ca"
	    "se.", (ftnlen)67);

/*     Open the first test file we created. */

    getlun_(&lun);
    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnmlen = 8;
    o__1.ofnm = "spk1.bsp";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check the IOSTAT. */

    if (iostat != 0) {
	cl__1.cerr = 0;
	cl__1.cunit = lun;
	cl__1.csta = 0;
	f_clos(&cl__1);
	tstmsg_("#", "This IOSTAT error should never occur.", (ftnlen)1, (
		ftnlen)37);
	chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)
		1);
    }

/*     Setup the inputs and output default values. Create a row for */
/*     spk1.bsp in the file table and unit tables. */

    nft = 1;
    ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", i__1, 
	    "f_ddhf2h__", (ftnlen)327)] = abs(nft);
    ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", i__1, 
	    "f_ddhf2h__", (ftnlen)328)] = 1;
    ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", i__1, 
	    "f_ddhf2h__", (ftnlen)329)] = 1;
    ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", i__1, 
	    "f_ddhf2h__", (ftnlen)330)] = 1;
    fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", i__1, 
	    "f_ddhf2h__", (ftnlen)331)] = nft;
    s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
	    "ftnam", i__1, "f_ddhf2h__", (ftnlen)332)) * 255, "spk1.bsp", (
	    ftnlen)255, (ftnlen)8);
    ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", i__1, 
	    "f_ddhf2h__", (ftnlen)333)] = rtrim_(ftnam + ((i__2 = nft - 1) < 
	    1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, "f_ddhf2h__", (
	    ftnlen)333)) * 255, (ftnlen)255);
    nut = 1;
    utcst[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", i__1, 
	    "f_ddhf2h__", (ftnlen)336)] = 2;
    uthan[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", i__1, 
	    "f_ddhf2h__", (ftnlen)337)] = fthan[(i__2 = nft - 1) < 1000 && 0 
	    <= i__2 ? i__2 : s_rnge("fthan", i__2, "f_ddhf2h__", (ftnlen)337)]
	    ;
    utlck[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", i__1, 
	    "f_ddhf2h__", (ftnlen)338)] = FALSE_;
    utlun[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", i__1, 
	    "f_ddhf2h__", (ftnlen)339)] = lun;
    exists = FALSE_;
    opened = FALSE_;
    handle = -1;
    found = FALSE_;

/*     Invoke the module. */

    zzddhf2h_("spk1.bsp", ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &
	    nft, utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, 
	    &found, (ftnlen)8, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_true, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the test file. */

    cl__1.cerr = 0;
    cl__1.cunit = lun;
    cl__1.csta = 0;
    f_clos(&cl__1);

/* --- Case: ------------------------------------------------------ */

    tcase_("File exists and is opened internally and is not in the unit tabl"
	    "e case.", (ftnlen)71);

/*     Open the files we want to put in the unit table. */

    nut = 0;
    nft = 0;
    for (i__ = 1; i__ <= 10; ++i__) {

/*        Get a unit. */

	getlun_(&lun);

/*        Compute the filename. */

	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	o__1.oerr = 1;
	o__1.ounit = lun;
	o__1.ofnmlen = 255;
	o__1.ofnm = fname;
	o__1.orl = 1024;
	o__1.osta = "OLD";
	o__1.oacc = "DIRECT";
	o__1.ofm = 0;
	o__1.oblnk = 0;
	iostat = f_open(&o__1);

/*        Check the IOSTAT. */

	if (iostat != 0) {
	    cl__1.cerr = 0;
	    cl__1.cunit = lun;
	    cl__1.csta = 0;
	    f_clos(&cl__1);
	    tstmsg_("#", "This IOSTAT error should never occur.", (ftnlen)1, (
		    ftnlen)37);
	    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	}

/*        Setup the inputs and output default values. Create a row for */
/*        FNAME in the file table and unit tables. */

	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)417)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)418)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)419)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)420)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)421)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)422)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)423)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)423)) * 255, (ftnlen)255);
	++nut;
	utcst[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhf2h__", (ftnlen)426)] = i__ << 1;
	uthan[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhf2h__", (ftnlen)427)] = fthan[(i__2 = nft - 1) < 
		1000 && 0 <= i__2 ? i__2 : s_rnge("fthan", i__2, "f_ddhf2h__",
		 (ftnlen)427)];
	utlck[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhf2h__", (ftnlen)428)] = FALSE_;
	utlun[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhf2h__", (ftnlen)429)] = lun;
    }

/*     Add a few more files to the file table. */

    for (i__ = 1; i__ <= 5; ++i__) {
	i__1 = i__ + 10;
	repmi_(fnmtmp, "#", &i__1, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)441)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)442)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)443)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)444)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)445)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)446)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)447)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)447)) * 255, (ftnlen)255);
    }
    exists = FALSE_;
    opened = TRUE_;
    handle = -1;
    found = FALSE_;

/*     Invoke the module. */

    zzddhf2h_("spk13.bsp", ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &
	    nft, utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, 
	    &found, (ftnlen)9, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__13, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the test files. */

    i__1 = nut;
    for (i__ = 1; i__ <= i__1; ++i__) {
	cl__1.cerr = 0;
	cl__1.cunit = utlun[(i__2 = i__ - 1) < 23 && 0 <= i__2 ? i__2 : 
		s_rnge("utlun", i__2, "f_ddhf2h__", (ftnlen)481)];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }

/*     We need to free the logical unit reserved implicitly by ZZDDHF2H's */
/*     use of ZZDDHRMU. */

    index = isrchi_(&c__0, &nut, uthan);
    if (index > 0) {
	frelun_(&utlun[(i__1 = index - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"utlun", i__1, "f_ddhf2h__", (ftnlen)491)]);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Unit table full, file not found, but in file table case.", (
	    ftnlen)56);

/*     Open the files we want to put in the unit table. */

    nut = 0;
    nft = 0;
    for (i__ = 1; i__ <= 23; ++i__) {

/*        Get a unit. */

	getlun_(&lun);

/*        Compute the filename. */

	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	o__1.oerr = 1;
	o__1.ounit = lun;
	o__1.ofnmlen = 255;
	o__1.ofnm = fname;
	o__1.orl = 1024;
	o__1.osta = "OLD";
	o__1.oacc = "DIRECT";
	o__1.ofm = 0;
	o__1.oblnk = 0;
	iostat = f_open(&o__1);

/*        Check the IOSTAT. */

	if (iostat != 0) {
	    cl__1.cerr = 0;
	    cl__1.cunit = lun;
	    cl__1.csta = 0;
	    f_clos(&cl__1);
	    tstmsg_("#", "This IOSTAT error should never occur.", (ftnlen)1, (
		    ftnlen)37);
	    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	}

/*        Setup the inputs and output default values. Create a row for */
/*        FNAME in the file table and unit tables. */

	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)539)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)540)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)541)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)542)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)543)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)544)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)545)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)545)) * 255, (ftnlen)255);
	++nut;
	utcst[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhf2h__", (ftnlen)548)] = i__ << 1;
	uthan[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhf2h__", (ftnlen)549)] = fthan[(i__2 = nft - 1) < 
		1000 && 0 <= i__2 ? i__2 : s_rnge("fthan", i__2, "f_ddhf2h__",
		 (ftnlen)549)];
	utlck[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhf2h__", (ftnlen)550)] = FALSE_;
	utlun[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhf2h__", (ftnlen)551)] = lun;
    }

/*     Add a few more files to the file table. */

    for (i__ = 1; i__ <= 5; ++i__) {
	i__1 = i__ + 23;
	repmi_(fnmtmp, "#", &i__1, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)563)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)564)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)565)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)566)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)567)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)568)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)569)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)569)) * 255, (ftnlen)255);
    }
    exists = FALSE_;
    opened = TRUE_;
    handle = -1;
    found = FALSE_;
    repmi_(fnmtmp, "#", &c__28, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*     Invoke the module. */

    zzddhf2h_(fname, ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &nft, 
	    utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, &
	    found, (ftnlen)255, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__28, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the test files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	cl__1.cerr = 0;
	cl__1.cunit = utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : 
		s_rnge("utlun", i__1, "f_ddhf2h__", (ftnlen)605)];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }

/*     We need to free the logical unit reserved implicitly by ZZDDHF2H's */
/*     use of ZZDDHRMU. */

    index = isrchi_(&c__0, &nut, uthan);
    if (index > 0) {
	frelun_(&utlun[(i__1 = index - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"utlun", i__1, "f_ddhf2h__", (ftnlen)615)]);
    }

/* --- Case: ------------------------------------------------------ */

    tcase_("Unit table full, file not found case.", (ftnlen)37);

/*     Open the files we want to put in the unit table. */

    nut = 0;
    nft = 0;
    for (i__ = 1; i__ <= 23; ++i__) {

/*        Get a unit. */

	getlun_(&lun);

/*        Compute the filename. */

	repmi_(fnmtmp, "#", &i__, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);
	o__1.oerr = 1;
	o__1.ounit = lun;
	o__1.ofnmlen = 255;
	o__1.ofnm = fname;
	o__1.orl = 1024;
	o__1.osta = "OLD";
	o__1.oacc = "DIRECT";
	o__1.ofm = 0;
	o__1.oblnk = 0;
	iostat = f_open(&o__1);

/*        Check the IOSTAT. */

	if (iostat != 0) {
	    cl__1.cerr = 0;
	    cl__1.cunit = lun;
	    cl__1.csta = 0;
	    f_clos(&cl__1);
	    tstmsg_("#", "This IOSTAT error should never occur.", (ftnlen)1, (
		    ftnlen)37);
	    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (
		    ftnlen)1);
	}

/*        Setup the inputs and output default values. Create a row for */
/*        FNAME in the file table and unit tables. */

	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)662)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)663)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)664)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)665)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)666)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)667)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)668)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)668)) * 255, (ftnlen)255);
	++nut;
	utcst[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utcst", 
		i__1, "f_ddhf2h__", (ftnlen)671)] = i__ << 1;
	uthan[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("uthan", 
		i__1, "f_ddhf2h__", (ftnlen)672)] = fthan[(i__2 = nft - 1) < 
		1000 && 0 <= i__2 ? i__2 : s_rnge("fthan", i__2, "f_ddhf2h__",
		 (ftnlen)672)];
	utlck[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlck", 
		i__1, "f_ddhf2h__", (ftnlen)673)] = FALSE_;
	utlun[(i__1 = nut - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge("utlun", 
		i__1, "f_ddhf2h__", (ftnlen)674)] = lun;
    }

/*     Add a few more files to the file table. */

    for (i__ = 1; i__ <= 4; ++i__) {
	i__1 = i__ + 23;
	repmi_(fnmtmp, "#", &i__1, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255)
		;
	++nft;
	ftabs[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftabs", 
		i__1, "f_ddhf2h__", (ftnlen)686)] = abs(nft);
	ftamh[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftamh", 
		i__1, "f_ddhf2h__", (ftnlen)687)] = 1;
	ftarc[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftarc", 
		i__1, "f_ddhf2h__", (ftnlen)688)] = 1;
	ftbff[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftbff", 
		i__1, "f_ddhf2h__", (ftnlen)689)] = 1;
	fthan[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("fthan", 
		i__1, "f_ddhf2h__", (ftnlen)690)] = nft;
	s_copy(ftnam + ((i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge(
		"ftnam", i__1, "f_ddhf2h__", (ftnlen)691)) * 255, fname, (
		ftnlen)255, (ftnlen)255);
	ftrtm[(i__1 = nft - 1) < 1000 && 0 <= i__1 ? i__1 : s_rnge("ftrtm", 
		i__1, "f_ddhf2h__", (ftnlen)692)] = rtrim_(ftnam + ((i__2 = 
		nft - 1) < 1000 && 0 <= i__2 ? i__2 : s_rnge("ftnam", i__2, 
		"f_ddhf2h__", (ftnlen)692)) * 255, (ftnlen)255);
    }
    exists = FALSE_;
    opened = TRUE_;
    handle = -1;
    found = FALSE_;
    repmi_(fnmtmp, "#", &c__28, fname, (ftnlen)255, (ftnlen)1, (ftnlen)255);

/*     Invoke the module. */

    zzddhf2h_(fname, ftabs, ftamh, ftarc, ftbff, fthan, ftnam, ftrtm, &nft, 
	    utcst, uthan, utlck, utlun, &nut, &exists, &opened, &handle, &
	    found, (ftnlen)255, (ftnlen)255);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check outputs. */

    chcksl_("FOUND", &found, &c_false, ok, (ftnlen)5);
    chcksl_("OPENED", &opened, &c_false, ok, (ftnlen)6);
    chcksl_("EXISTS", &exists, &c_true, ok, (ftnlen)6);
    chcksi_("HANDLE", &handle, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Close the test files. */

    for (i__ = 1; i__ <= 23; ++i__) {
	cl__1.cerr = 0;
	cl__1.cunit = utlun[(i__1 = i__ - 1) < 23 && 0 <= i__1 ? i__1 : 
		s_rnge("utlun", i__1, "f_ddhf2h__", (ftnlen)728)];
	cl__1.csta = 0;
	f_clos(&cl__1);
    }

/*     We need to free the logical unit reserved implicitly by ZZDDHF2H's */
/*     use of ZZDDHRMU. */

    index = isrchi_(&c__0, &nut, uthan);
    if (index > 0) {
	frelun_(&utlun[(i__1 = index - 1) < 23 && 0 <= i__1 ? i__1 : s_rnge(
		"utlun", i__1, "f_ddhf2h__", (ftnlen)738)]);
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhf2h__ */

