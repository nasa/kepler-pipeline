/* t_dafwfr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static integer c__3 = 3;
static integer c__1 = 1;

/* $Procedure T_DAFWFR ( Write a DAF file record to a test DAF ) */
/* Subroutine */ int t_dafwfr__(integer *unit, integer *outbff, char *idword, 
	integer *nd, integer *ni, char *ifname, integer *fward, integer *
	bward, integer *free, logical *addftp, ftnlen idword_len, ftnlen 
	ifname_len)
{
    /* Initialized data */

    static logical first = TRUE_;
    static integer natbff = 0;

    /* System generated locals */
    address a__1[3];
    integer i__1, i__2[3];

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen),
	     s_copy(char *, char *, ftnlen, ftnlen);
    integer s_wdue(cilist *), do_uio(integer *, char *, ftnlen), e_wdue(void);

    /* Local variables */
    extern /* Subroutine */ int zzddhgsd_(char *, integer *, char *, ftnlen, 
	    ftnlen), t_xltfwi__(integer *, integer *, integer *, char *, 
	    ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__;
    extern /* Subroutine */ int zzftpstr_(char *, char *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen);
    char delim[1];
    extern /* Subroutine */ int chkin_(char *, ftnlen), ucase_(char *, char *,
	     ftnlen, ftnlen), errch_(char *, char *, ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    char locifn[60];
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    char holder[4], record[1024], locidw[8], locfmt[8], prespc[603];
    static char strbff[8*4];
    char lftbkt[6], rgtbkt[6];
    integer iostat;
    extern /* Subroutine */ int setmsg_(char *, ftnlen), sigerr_(char *, 
	    ftnlen), chkout_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen), errfnm_(char *, integer *, ftnlen);
    extern logical return_(void);
    static char ftpstr[28];
    char tmpstr[8], tststr[16];

    /* Fortran I/O blocks */
    static cilist io___17 = { 1, 0, 0, 0, 1 };
    static cilist io___18 = { 1, 0, 0, 0, 1 };
    static cilist io___20 = { 1, 0, 0, 0, 1 };


/* $ Abstract */

/*     Write file record to a test DAF. */

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

/*     TEST ROUTINE */

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


/*     Include Section:  Private FTP Validation String Parameters */

/*        zzftprms.inc Version 1    01-MAR-1999 (FST) */

/*     This include file centralizes the definition of string sizes */
/*     and other parameters that are necessary to properly implement */
/*     the FTP error detection scheme for binary kernels. */

/*     Before making any alterations to the contents of this file, */
/*     refer to the header of ZZFTPSTR for a detailed discussion of */
/*     the FTP validation string. */

/*     Size of FTP Test String Component: */


/*     Size of Maximum Expanded FTP Validation String: */

/*      (This indicates the size of a buffer to hold the test */
/*       string sequence from a possibly corrupt file. Empirical */
/*       evidence strongly indicates that expansion due to FTP */
/*       corruption at worst doubles the number of characters. */
/*       So take 3*SIZSTR to be on the safe side.) */


/*     Size of FTP Validation String Brackets: */


/*     Size of FTP Validation String: */


/*     Size of DELIM. */


/*     Number of character clusters present in the validation string. */


/*     End Include Section:  Private FTP Validation String Parameters */

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     UNIT       I   Unit attached to DAF to receive new file record. */
/*     OUTBFF     I   Binary file format code for d.p. values in OUTPUT. */
/*     IDWORD     I   DAF ID Word. */
/*     ND         I   Number of double precision components in summaries. */
/*     NI         I   Number of integer components in summaries. */
/*     IFNAME     I   Internal filename. */
/*     FWARD      I   Forward list pointer. */
/*     BWARD      I   Backward list pointer. */
/*     FREE       I   Free address pointer. */
/*     ADDFTP     I   Logical that indicates whether to add FTP string. */

/* $ Detailed_Input */

/*     UNIT       is the logical unit attached to the DAF to receive */
/*                the new file record. */

/*     OUTBFF     is an integer code that indicates the binary file */
/*                format targeted for OUTPUT.  Acceptable values */
/*                are the parameters: */

/*                   BIGI3E */
/*                   LTLI3E */
/*                   VAXGFL */
/*                   VAXDFL */

/*                as defined in the include file 'zzddhman.inc'. */

/*     IDWORD     a string containing the DAF ID word. */

/*     ND, */
/*     NI         are the numbers of double precision and integer */
/*                components, respectively, in each array summary */
/*                in the specified file. */

/*     IFNAME     is the internal file name to be stored in the first */
/*                (or file) record of the specified file. */

/*     FWARD      is the forward list pointer. This points to the */
/*                first summary record in the file. */

/*     BWARD      is the backward list pointer. This points to the */
/*                final summary record in the file. */

/*     FREE       is the free address pointer. This contains the */
/*                first free address in the file. */

/*     ADDFTP     is a string indicating whether to add the FTP */
/*                diagnostic string and the binary file format ID */
/*                string to the file record. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine updates the first record of the file attached */
/*     to UNIT. */

/* $ Exceptions */


/* $ Particulars */

/*     Note: This code is not a model of perfection.  It is hacked */
/*     together from pieces of code written elsewhere to support */
/*     creation of non-native binaries for testing purposes only. */

/* $ Examples */

/*     See F_ZZDGDR for usage. */

/* $ Restrictions */

/*     1) The file was created with T_DAFOPN. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 28-OCT-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Saved Variables */


/*     Data Statements */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_DAFWFR", (ftnlen)8);
    }

/*     Perform some initialization tasks. */

    if (first) {

/*        Populate STRBFF with the appropriate binary file */
/*        format labels. */

	for (i__ = 1; i__ <= 4; ++i__) {
	    zzddhgsd_("BFF", &i__, strbff + (((i__1 = i__ - 1) < 4 && 0 <= 
		    i__1 ? i__1 : s_rnge("strbff", i__1, "t_dafwfr__", (
		    ftnlen)244)) << 3), (ftnlen)3, (ftnlen)8);
	}

/*        Fetch the native binary file format. */

	zzplatfm_("FILE_FORMAT", tmpstr, (ftnlen)11, (ftnlen)8);
	ucase_(tmpstr, tmpstr, (ftnlen)8, (ftnlen)8);
	natbff = isrchc_(tmpstr, &c__4, strbff, (ftnlen)8, (ftnlen)8);
	if (natbff == 0) {
	    setmsg_("The binary file format, '#', is not supported by this v"
		    "ersion of the toolkit. This is a serious problem, contac"
		    "t NAIF.", (ftnlen)118);
	    errch_("#", tmpstr, (ftnlen)1, (ftnlen)8);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("T_DAFWFR", (ftnlen)8);
	    return 0;
	}

/*        Fetch the FTP string. */

	zzftpstr_(tststr, lftbkt, rgtbkt, delim, (ftnlen)16, (ftnlen)6, (
		ftnlen)6, (ftnlen)1);
/* Writing concatenation */
	i__2[0] = rtrim_(lftbkt, (ftnlen)6), a__1[0] = lftbkt;
	i__2[1] = rtrim_(tststr, (ftnlen)16), a__1[1] = tststr;
	i__2[2] = rtrim_(rgtbkt, (ftnlen)6), a__1[2] = rgtbkt;
	s_cat(ftpstr, a__1, i__2, &c__3, (ftnlen)28);

/*        Do not perform initialization tasks again. */

	first = FALSE_;
    }

/*     Check to see if OUTBFF is valid.  This should never occur if this */
/*     routine is called properly. */

    if (*outbff < 1 || *outbff > 4) {
	setmsg_("The integer code used to indicate the binary file format of"
		" the input integers, #, is out of range.  This error should "
		"never occur.", (ftnlen)131);
	errint_("#", outbff, (ftnlen)1);
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("T_DAFWFR", (ftnlen)8);
	return 0;
    }

/*     Prepare the local string buffers to hold the possible */
/*     string arguments. */

    s_copy(locidw, idword, (ftnlen)8, idword_len);
    s_copy(locifn, ifname, (ftnlen)60, ifname_len);
    s_copy(locfmt, strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ? i__1 : 
	    s_rnge("strbff", i__1, "t_dafwfr__", (ftnlen)306)) << 3), (ftnlen)
	    8, (ftnlen)8);
    s_copy(prespc, " ", (ftnlen)603, (ftnlen)1);

/*     First, determine if we are to write to the native file format. */

    if (*outbff == natbff) {
	s_copy(record, " ", (ftnlen)1024, (ftnlen)1);
	if (*addftp) {
	    io___17.ciunit = *unit;
	    iostat = s_wdue(&io___17);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, locidw, (ftnlen)8);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, (char *)&(*nd), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, (char *)&(*ni), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, locifn, (ftnlen)60);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, (char *)&(*fward), (ftnlen)sizeof(integer))
		    ;
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, (char *)&(*bward), (ftnlen)sizeof(integer))
		    ;
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, (char *)&(*free), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, locfmt, (ftnlen)8);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, prespc, (ftnlen)603);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, ftpstr, (ftnlen)28);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = do_uio(&c__1, record, (ftnlen)297);
	    if (iostat != 0) {
		goto L100001;
	    }
	    iostat = e_wdue();
L100001:
	    ;
	} else {
	    io___18.ciunit = *unit;
	    iostat = s_wdue(&io___18);
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, locidw, (ftnlen)8);
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, (char *)&(*nd), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, (char *)&(*ni), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, locifn, (ftnlen)60);
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, (char *)&(*fward), (ftnlen)sizeof(integer))
		    ;
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, (char *)&(*bward), (ftnlen)sizeof(integer))
		    ;
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, (char *)&(*free), (ftnlen)sizeof(integer));
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = do_uio(&c__1, record, (ftnlen)936);
	    if (iostat != 0) {
		goto L100002;
	    }
	    iostat = e_wdue();
L100002:
	    ;
	}
	if (iostat != 0) {
	    setmsg_("Unable to write to #. IOSTAT was #", (ftnlen)34);
	    errfnm_("#", unit, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEWRITEFAILED)", (ftnlen)22);
	    chkout_("T_DAFWFR", (ftnlen)8);
	    return 0;
	}

/*     Handle the non-native case. */

    } else {

/*        Clear RECORD. */

	s_copy(record, " ", (ftnlen)1024, (ftnlen)1);

/*        Populate RECORD. */

	s_copy(record, locidw, (ftnlen)8, (ftnlen)8);

/*        Convert and place ND, NI. */

	t_xltfwi__(nd, &c__1, outbff, holder, (ftnlen)4);
	s_copy(record + 8, holder, (ftnlen)4, (ftnlen)4);
	t_xltfwi__(ni, &c__1, outbff, holder, (ftnlen)4);
	s_copy(record + 12, holder, (ftnlen)4, (ftnlen)4);
	s_copy(record + 16, locifn, (ftnlen)60, (ftnlen)60);

/*        Convert and place FWARD, BWARD, and FREE. */

	t_xltfwi__(fward, &c__1, outbff, holder, (ftnlen)4);
	s_copy(record + 76, holder, (ftnlen)4, (ftnlen)4);
	t_xltfwi__(bward, &c__1, outbff, holder, (ftnlen)4);
	s_copy(record + 80, holder, (ftnlen)4, (ftnlen)4);
	t_xltfwi__(free, &c__1, outbff, holder, (ftnlen)4);
	s_copy(record + 84, holder, (ftnlen)4, (ftnlen)4);

/*        Add the FTP string if appropriate. */

	if (*addftp) {
	    s_copy(record + 88, locfmt, (ftnlen)8, (ftnlen)8);
	    s_copy(record + 699, ftpstr, (ftnlen)325, (ftnlen)28);
	}

/*        Dump the record to the file. */

	io___20.ciunit = *unit;
	iostat = s_wdue(&io___20);
	if (iostat != 0) {
	    goto L100003;
	}
	iostat = do_uio(&c__1, record, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100003;
	}
	iostat = e_wdue();
L100003:
	if (iostat != 0) {
	    setmsg_("Unable to write to #. IOSTAT was #", (ftnlen)34);
	    errfnm_("#", unit, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEWRITEFAILED)", (ftnlen)22);
	    chkout_("T_DAFWFR", (ftnlen)8);
	    return 0;
	}
    }
    chkout_("T_DAFWFR", (ftnlen)8);
    return 0;
} /* t_dafwfr__ */

