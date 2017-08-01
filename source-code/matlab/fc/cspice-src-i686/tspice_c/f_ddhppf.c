/* f_ddhppf.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static logical c_false = FALSE_;
static logical c_true = TRUE_;
static integer c__0 = 0;
static integer c__2 = 2;
static integer c__1 = 1;
static integer c__3 = 3;
static integer c__4 = 4;

/* $Procedure F_DDHPPF ( ZZDDHPPF Test Family ) */
/* Subroutine */ int f_ddhppf__(logical *ok)
{
    /* System generated locals */
    integer i__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), f_open(olist *), f_clos(
	    cllist *);

    /* Local variables */
    char null[1];
    integer unit;
    extern /* Subroutine */ int t_cptfil__(char *, integer *, integer *, char 
	    *, char *, char *, char *, logical *, logical *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen), zzddhgsd_(char *, 
	    integer *, char *, ftnlen, ftnlen), zzddhppf_(integer *, integer *
	    , integer *), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__, fdrec;
    extern /* Subroutine */ int tcase_(char *, ftnlen), ucase_(char *, char *,
	     ftnlen, ftnlen);
    char cnsum[8];
    extern /* Subroutine */ int topen_(char *, ftnlen), t_success__(logical *)
	    ;
    char cfdrec[4];
    integer natbff;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), kilfil_(char *, ftnlen);
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    char nulbff[8], native[8], strbff[8*4];
    extern /* Subroutine */ int getlun_(integer *);
    integer iostat, bff, arc;
    char cni[4];

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZDDHPPF */
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

/*     This routine exercises ZZDDHPPF's logic.  There are a few IOSTAT */
/*     driven exceptions that are not readily exercised with the */
/*     delivered source code.  Also, there is a SPICE(BUG) exception */
/*     that requires the substitution of ZZPLATFM.  This testcode */
/*     does not address their execution. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 2.0.0, 06-FEB-2002 (FST) */

/*        This test family was altered to exercise updated logic in */
/*        ZZDDHPPF.  See the Revisions section of its header for a */
/*        detailed discussion of the changes. */

/* -    TSPICE Version 1.0.0, 05-SEP-2001 (FST) */

/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DDHPPF", (ftnlen)8);

/* --- Case: ------------------------------------------------------ */

    tcase_("F_DDHPPF Initialization", (ftnlen)23);

/*     Now retrieve the list of supported binary file formats. */

    for (i__ = 1; i__ <= 4; ++i__) {
	zzddhgsd_("BFF", &i__, strbff + (((i__1 = i__ - 1) < 4 && 0 <= i__1 ? 
		i__1 : s_rnge("strbff", i__1, "f_ddhppf__", (ftnlen)155)) << 
		3), (ftnlen)3, (ftnlen)8);
    }

/*     Setup the null byte character. */

    *(unsigned char *)null = '\0';

/*     Initialize NULBFF. */

    for (i__ = 1; i__ <= 8; ++i__) {
	*(unsigned char *)&nulbff[i__ - 1] = *(unsigned char *)null;
    }

/*     Check for the absence of a rogue exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/* --- Case: ------------------------------------------------------ */

    tcase_("Invalid architecture code exception.", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = -1;
    bff = 1;

/*     Invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNFILARC)", ok, (ftnlen)20);

/*     Check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Setup the inputs and outputs for the other bound. */

    arc = 3;
    bff = 1;

/*     Invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNFILARC)", ok, (ftnlen)20);

/*     Check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);


/*     We have commented this case out because it leaves a "fort.#" */
/*     file around on some systems. */

/* --- Case: ------------------------------------------------------ */

/*     CALL TCASE ( 'File read failure.' ) */


/*     Setup the inputs and outputs. */

/*     CALL GETLUN ( UNIT ) */

/*     ARC = DAF */
/*     BFF = BIGI3E */


/*     Invoke the module. */

/*     CALL ZZDDHPPF ( UNIT, ARC, BFF ) */


/*     Check for the exception. */

/*     CALL CHCKXC ( .TRUE., 'SPICE(FILEREADFAILED)', OK ) */


/*     Check BFF. */

/*     CALL CHCKSI ( 'BFF', BFF, '=', 0, 0, OK ) */



/* --- Case: ------------------------------------------------------ */

    tcase_("Unknown File Architecture.", (ftnlen)26);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 1;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, "TEST/FIL", (ftnlen)11, (ftnlen)8, (ftnlen)4, 
	    (ftnlen)4, (ftnlen)4, (ftnlen)8);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNFILARC)", ok, (ftnlen)20);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAS File Architecture, should be DAF.", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 1;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, "DAS/EK  ", (ftnlen)11, (ftnlen)8, (ftnlen)4, 
	    (ftnlen)4, (ftnlen)4, (ftnlen)8);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FILARCHMISMATCH)", ok, (ftnlen)22);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("DAF File Architecture, should be DAS.", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 1;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, "DAF/SPK ", (ftnlen)11, (ftnlen)8, (ftnlen)4, 
	    (ftnlen)4, (ftnlen)4, (ftnlen)8);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FILARCHMISMATCH)", ok, (ftnlen)22);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Error in FTP check, DAF.", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 1;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_true, "DAF/SPK ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)8);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FTPXFERERROR)", ok, (ftnlen)19);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Error in FTP check, DAS.", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 1;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_true, "DAS/EK  ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)8);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(FTPXFERERROR)", ok, (ftnlen)19);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Unknown Binary File Format.", (ftnlen)39);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 1;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "UNKNOWN-", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the presence of the exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNBFF)", ok, (ftnlen)17);

/*     Now check BFF. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: BIG-IEEE DAF", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__1, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: LTL-IEEE DAF", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "LTL-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: VAX-GFLT DAF", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "VAX-GFLT", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__3, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: VAX-DFLT DAF", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    t_cptfil__("testdaf.daf", &arc, &c__2, "VAX-DFLT", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: BIG-IEEE DAS", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 0;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "BIG-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__1, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: LTL-IEEE DAS", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 0;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "LTL-IEEE", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: VAX-GFLT DAS", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 0;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "VAX-GFLT", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__3, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. BFFID: VAX-DFLT DAS", (ftnlen)31);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 0;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "VAX-DFLT", "ABCD", "EFGH", "IJKL",
	     &c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. DAS", (ftnlen)28);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 2;
    bff = 0;
    kilfil_("testdas.das", (ftnlen)11);
    t_cptfil__("testdas.das", &arc, &c__2, "        ", "ABCD", "EFGH", "IJKL",
	     &c_false, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (
	    ftnlen)4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdas.das";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Fetch the native environment from ZZPLATFM. */

    zzplatfm_("FILE_FORMAT", native, (ftnlen)11, (ftnlen)8);
    ucase_(native, native, (ftnlen)8, (ftnlen)8);

/*     Convert it to the appropriate integer code. */

    natbff = isrchc_(native, &c__4, strbff, (ftnlen)8, (ftnlen)8);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &natbff, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdas.das", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. BIG-IEEE DAF", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = *(unsigned char *)null;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = 128;
    t_cptfil__("testdaf.daf", &arc, &c__2, "       ", cni, "EFGH", "IJKL", &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__1, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Null BFFID. BIG-IEEE DAF", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = *(unsigned char *)null;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = 128;
    t_cptfil__("testdaf.daf", &arc, &c__2, nulbff, cni, "EFGH", "IJKL", &
	    c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (ftnlen)
	    4, (ftnlen)4, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__1, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. LTL-IEEE DAF", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 12;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = *(unsigned char *)null;
    *(unsigned char *)&cnsum[1] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = 128;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = '@';
    *(unsigned char *)&cnsum[7] = 'P';
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Null BFFID. LTL-IEEE DAF", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 12;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = *(unsigned char *)null;
    *(unsigned char *)&cnsum[1] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = 128;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = '@';
    *(unsigned char *)&cnsum[7] = 'P';
    t_cptfil__("testdaf.daf", &arc, &fdrec, nulbff, cni, cfdrec, cnsum, &
	    c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__2, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. VAX-GFLT DAF", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = '\20';
    *(unsigned char *)&cnsum[1] = '@';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = '@';
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__3, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Null BFFID. VAX-GFLT DAF", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = '\20';
    *(unsigned char *)&cnsum[1] = '@';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = '@';
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, nulbff, cni, cfdrec, cnsum, &
	    c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__3, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. VAX-DFLT DAF", (ftnlen)37);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = *(unsigned char *)null;
    *(unsigned char *)&cnsum[1] = 'A';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Null BFFID. VAX-DFLT DAF", (ftnlen)36);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = *(unsigned char *)null;
    *(unsigned char *)&cnsum[1] = 'A';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, nulbff, cni, cfdrec, cnsum, &
	    c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. VAX-DFLT (Exception) DAF", (ftnlen)49);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = 128;
    *(unsigned char *)&cnsum[1] = '@';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("FTP String. Null BFFID. VAX-DFLT (Exception) DAF", (ftnlen)48);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = 0;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = 128;
    *(unsigned char *)&cnsum[1] = '@';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, nulbff, cni, cfdrec, cnsum, &
	    c_true, &c_false, " ", (ftnlen)11, (ftnlen)8, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__4, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. Zero-Sized DAF", (ftnlen)39);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = -1;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = *(unsigned char *)null;
    *(unsigned char *)&cnsum[1] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNBFF)", ok, (ftnlen)17);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/* --- Case: ------------------------------------------------------ */

    tcase_("No FTP String. No BFFID. Fall-through ARCH DAF", (ftnlen)46);

/*     Setup the inputs and outputs. */

    getlun_(&unit);
    arc = 1;
    bff = -1;
    kilfil_("testdaf.daf", (ftnlen)11);
    *(unsigned char *)cni = 128;
    *(unsigned char *)&cni[1] = *(unsigned char *)null;
    *(unsigned char *)&cni[2] = *(unsigned char *)null;
    *(unsigned char *)&cni[3] = *(unsigned char *)null;

/*     As long as we keep FDREC byte-sized we can do the following. */

    fdrec = 20;
    *(unsigned char *)cfdrec = (char) fdrec;
    *(unsigned char *)&cfdrec[1] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[2] = *(unsigned char *)null;
    *(unsigned char *)&cfdrec[3] = *(unsigned char *)null;

/*     Now construct the character NSUM values.  Recall that the first */
/*     two bytes must be NULL in order to properly represent LTL-IEEE. */

    *(unsigned char *)cnsum = 144;
    *(unsigned char *)&cnsum[1] = '@';
    *(unsigned char *)&cnsum[2] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[3] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[4] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[5] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[6] = *(unsigned char *)null;
    *(unsigned char *)&cnsum[7] = *(unsigned char *)null;
    t_cptfil__("testdaf.daf", &arc, &fdrec, "       ", cni, cfdrec, cnsum, &
	    c_false, &c_false, " ", (ftnlen)11, (ftnlen)7, (ftnlen)4, (ftnlen)
	    4, (ftnlen)8, (ftnlen)1);
    o__1.oerr = 1;
    o__1.ounit = unit;
    o__1.ofnmlen = 11;
    o__1.ofnm = "testdaf.daf";
    o__1.orl = 1024;
    o__1.osta = "OLD";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);

/*     Now invoke the module. */

    zzddhppf_(&unit, &arc, &bff);

/*     Check for the absence of an exception. */

    chckxc_(&c_true, "SPICE(UNKNOWNBFF)", ok, (ftnlen)17);

/*     Check BFF for the appropriate value. */

    chcksi_("BFF", &bff, "=", &c__0, &c__0, ok, (ftnlen)3, (ftnlen)1);

/*     Close and remove the file. */

    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_("testdaf.daf", (ftnlen)11);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_ddhppf__ */

