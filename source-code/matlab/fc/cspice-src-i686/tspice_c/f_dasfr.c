/* f_dasfr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c_n1 = -1;
static integer c__1 = 1;
static integer c_n2 = -2;
static integer c__2 = 2;
static integer c__0 = 0;
static logical c_false = FALSE_;
static integer c__5 = 5;
static integer c__4 = 4;
static integer c__6 = 6;
static integer c__8 = 8;

/* $Procedure F_DASFR ( DASFR Test Family ) */
/* Subroutine */ int f_dasfr__(logical *ok)
{
    /* System generated locals */
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer f_open(olist *), s_rdue(cilist *), do_uio(integer *, char *, 
	    ftnlen), e_rdue(void), f_clos(cllist *);

    /* Local variables */
    char tail[932];
    extern /* Subroutine */ int zzdasnfr_(integer *, char *, char *, integer *
	    , integer *, integer *, integer *, char *, ftnlen, ftnlen, ftnlen)
	    , zzftpchk_(char *, logical *, ftnlen), zzplatfm_(char *, char *, 
	    ftnlen, ftnlen);
    char fname[255];
    integer ncomc;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    integer ncomr;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int t_success__(logical *);
    integer handle;
    extern /* Subroutine */ int chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    char ifname[60];
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen), chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen), dascls_(integer *), kilfil_(char *, ftnlen), dasrfr_(
	    integer *, char *, char *, integer *, integer *, integer *, 
	    integer *, ftnlen, ftnlen), dashlu_(integer *, integer *);
    char format[8], idword[8];
    extern /* Subroutine */ int dasopn_(char *, char *, integer *, ftnlen, 
	    ftnlen), dasonw_(char *, char *, char *, integer *, integer *, 
	    ftnlen, ftnlen, ftnlen), getlun_(integer *), daswfr_(integer *, 
	    char *, char *, integer *, integer *, integer *, integer *, 
	    ftnlen, ftnlen);
    integer nresvc;
    logical ftperr;
    integer iostat, nresvr;
    char sysfmt[8];
    integer lun;

    /* Fortran I/O blocks */
    static cilist io___12 = { 1, 0, 1, 0, 1 };
    static cilist io___15 = { 1, 0, 1, 0, 1 };


/* $ Abstract */

/*     Test family to exercise the logic and code in the DASFR */
/*     umbrella. */

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

/*     This routine exercises a few simple test cases that verify the */
/*     FTP validation string and the binary file format strings were */
/*     added properly to DAS files. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.0.0, 11-DEC-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     See DASWFR for a detailed explanation of TAILEN. */


/*     Local Variables */


/*     Start the test family with an open call. */

    topen_("F_DASFR", (ftnlen)7);

/* --- Case: ------------------------------------------------------ */

    tcase_("ZZDASNFR Test", (ftnlen)13);

/*     Setup the file. */

    s_copy(fname, "test.das", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    getlun_(&lun);
    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnmlen = rtrim_(fname, (ftnlen)255);
    o__1.ofnm = fname;
    o__1.orl = 1024;
    o__1.osta = "NEW";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);
    zzdasnfr_(&lun, "DAS/TEST", "TEST DAS", &c_n1, &c__1, &c_n2, &c__2, "BFF"
	    "IDWRD", (ftnlen)8, (ftnlen)8, (ftnlen)8);

/*     Initialize the values we are about to read. */

    s_copy(idword, " ", (ftnlen)8, (ftnlen)1);
    s_copy(ifname, " ", (ftnlen)60, (ftnlen)1);
    nresvr = 0;
    nresvc = 0;
    ncomr = 0;
    ncomc = 0;
    s_copy(format, " ", (ftnlen)8, (ftnlen)1);
    s_copy(tail, " ", (ftnlen)932, (ftnlen)1);
    io___12.ciunit = lun;
    iostat = s_rdue(&io___12);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, idword, (ftnlen)8);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, ifname, (ftnlen)60);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, (char *)&nresvr, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, (char *)&nresvc, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, (char *)&ncomr, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, (char *)&ncomc, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, format, (ftnlen)8);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = do_uio(&c__1, tail, (ftnlen)932);
    if (iostat != 0) {
	goto L100001;
    }
    iostat = e_rdue();
L100001:

/*     Check the results. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksc_("IDWORD", idword, "=", "DAS/TEST", ok, (ftnlen)6, (ftnlen)8, (
	    ftnlen)1, (ftnlen)8);
    chcksc_("IFNAME", ifname, "=", "TEST DAS", ok, (ftnlen)6, (ftnlen)60, (
	    ftnlen)1, (ftnlen)8);
    chcksi_("NRESVR", &nresvr, "=", &c_n1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NRESVC", &nresvc, "=", &c__1, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NCOMR", &ncomr, "=", &c_n2, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NCOMC", &ncomc, "=", &c__2, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksc_("FORMAT", format, "=", "BFFIDWRD", ok, (ftnlen)6, (ftnlen)8, (
	    ftnlen)1, (ftnlen)8);
    zzftpchk_(tail, &ftperr, (ftnlen)932);
    chcksl_("FTPERR", &ftperr, &c_false, ok, (ftnlen)6);
    chcksc_("FTPSTR", tail + 607, "=", "FTPSTR", ok, (ftnlen)6, (ftnlen)6, (
	    ftnlen)1, (ftnlen)6);
    cl__1.cerr = 0;
    cl__1.cunit = lun;
    cl__1.csta = 0;
    f_clos(&cl__1);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DASOPN Test", (ftnlen)11);
    s_copy(fname, "test.das", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    dasopn_(fname, "TEST DASOPN", &handle, (ftnlen)255, (ftnlen)11);
    dasrfr_(&handle, idword, ifname, &nresvr, &nresvc, &ncomr, &ncomc, (
	    ftnlen)8, (ftnlen)60);

/*     Check the results.  We don't need to worry about FORMAT or */
/*     the FTP string since DASOPN invokes ZZDASNFR which we just */
/*     checked. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("IDWORD", idword, "=", "NAIF/DAS", ok, (ftnlen)6, (ftnlen)8, (
	    ftnlen)1, (ftnlen)8);
    chcksc_("IFNAME", ifname, "=", "TEST DASOPN", ok, (ftnlen)6, (ftnlen)60, (
	    ftnlen)1, (ftnlen)11);
    chcksi_("NRESVR", &nresvr, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NRESVC", &nresvc, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NCOMR", &ncomr, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NCOMC", &ncomc, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    dascls_(&handle);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DASONW Test", (ftnlen)11);
    s_copy(fname, "test.das", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    dasonw_(fname, "TEST", "TEST DASONW", &c__5, &handle, (ftnlen)255, (
	    ftnlen)4, (ftnlen)11);
    dasrfr_(&handle, idword, ifname, &nresvr, &nresvc, &ncomr, &ncomc, (
	    ftnlen)8, (ftnlen)60);

/*     Check the results.  We don't need to worry about FORMAT or */
/*     the FTP string since DASONW invokes ZZDASNFR which we just */
/*     checked. */

    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("IDWORD", idword, "=", "DAS/TEST", ok, (ftnlen)6, (ftnlen)8, (
	    ftnlen)1, (ftnlen)8);
    chcksc_("IFNAME", ifname, "=", "TEST DASONW", ok, (ftnlen)6, (ftnlen)60, (
	    ftnlen)1, (ftnlen)11);
    chcksi_("NRESVR", &nresvr, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NRESVC", &nresvc, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NCOMR", &ncomr, "=", &c__5, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NCOMC", &ncomc, "=", &c__0, &c__0, ok, (ftnlen)5, (ftnlen)1);
    dascls_(&handle);
    kilfil_(fname, (ftnlen)255);

/* --- Case: ------------------------------------------------------ */

    tcase_("DASWFR Test", (ftnlen)11);
    s_copy(fname, "test.das", (ftnlen)255, (ftnlen)8);
    kilfil_(fname, (ftnlen)255);
    dasonw_(fname, "TEST", "TEST DASWFR", &c__5, &handle, (ftnlen)255, (
	    ftnlen)4, (ftnlen)11);
    daswfr_(&handle, "DAS/WORD", "DASWFR UPDATE", &c__2, &c__4, &c__6, &c__8, 
	    (ftnlen)8, (ftnlen)13);

/*     Check the results. */

    dasrfr_(&handle, idword, ifname, &nresvr, &nresvc, &ncomr, &ncomc, (
	    ftnlen)8, (ftnlen)60);
    chckxc_(&c_false, " ", ok, (ftnlen)1);
    chcksc_("IDWORD", idword, "=", "DAS/WORD", ok, (ftnlen)6, (ftnlen)8, (
	    ftnlen)1, (ftnlen)8);
    chcksc_("IFNAME", ifname, "=", "DASWFR UPDATE", ok, (ftnlen)6, (ftnlen)60,
	     (ftnlen)1, (ftnlen)13);
    chcksi_("NRESVR", &nresvr, "=", &c__2, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NRESVC", &nresvc, "=", &c__4, &c__0, ok, (ftnlen)6, (ftnlen)1);
    chcksi_("NCOMR", &ncomr, "=", &c__6, &c__0, ok, (ftnlen)5, (ftnlen)1);
    chcksi_("NCOMC", &ncomc, "=", &c__8, &c__0, ok, (ftnlen)5, (ftnlen)1);

/*     Check that DASWFR perserved the binary file format and FTP */
/*     strings. */

    dashlu_(&handle, &lun);
    io___15.ciunit = lun;
    iostat = s_rdue(&io___15);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, idword, (ftnlen)8);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, ifname, (ftnlen)60);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, (char *)&nresvr, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, (char *)&nresvc, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, (char *)&ncomr, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, (char *)&ncomc, (ftnlen)sizeof(integer));
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, format, (ftnlen)8);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = do_uio(&c__1, tail, (ftnlen)932);
    if (iostat != 0) {
	goto L100002;
    }
    iostat = e_rdue();
L100002:

/*     Check the results. */

    chcksi_("IOSTAT", &iostat, "=", &c__0, &c__0, ok, (ftnlen)6, (ftnlen)1);
    zzplatfm_("FILE_FORMAT", sysfmt, (ftnlen)11, (ftnlen)8);
    chcksc_("FORMAT", format, "=", sysfmt, ok, (ftnlen)6, (ftnlen)8, (ftnlen)
	    1, (ftnlen)8);
    zzftpchk_(tail, &ftperr, (ftnlen)932);
    chcksl_("FTPERR", &ftperr, &c_false, ok, (ftnlen)6);
    chcksc_("FTPSTR", tail + 607, "=", "FTPSTR", ok, (ftnlen)6, (ftnlen)6, (
	    ftnlen)1, (ftnlen)6);
    dascls_(&handle);
    kilfil_(fname, (ftnlen)255);

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_dasfr__ */

