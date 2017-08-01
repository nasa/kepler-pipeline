/* t_cptfil.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__3 = 3;
static integer c__1 = 1;

/* $Procedure T_CPTFIL ( Create Partial Test Files ) */
/* Subroutine */ int t_cptfil__(char *name__, integer *arch, integer *fdrec, 
	char *bffid, char *cni, char *cfdrec, char *cnsum, logical *addftp, 
	logical *brkftp, char *newidw, ftnlen name_len, ftnlen bffid_len, 
	ftnlen cni_len, ftnlen cfdrec_len, ftnlen cnsum_len, ftnlen 
	newidw_len)
{
    /* System generated locals */
    address a__1[3];
    integer i__1[3], i__2;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer f_open(olist *), f_clos(cllist *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);
    integer s_wdue(cilist *), do_uio(integer *, char *, ftnlen), e_wdue(void);

    /* Local variables */
    extern /* Subroutine */ int zzftpstr_(char *, char *, char *, char *, 
	    ftnlen, ftnlen, ftnlen, ftnlen);
    char delim[1];
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    char record[1024], lftbkt[6];
    extern /* Subroutine */ int sigerr_(char *, ftnlen);
    char rgtbkt[6];
    extern /* Subroutine */ int getlun_(integer *), chkout_(char *, ftnlen), 
	    errfnm_(char *, integer *, ftnlen);
    integer iostat;
    extern /* Subroutine */ int setmsg_(char *, ftnlen), errint_(char *, 
	    integer *, ftnlen);
    extern logical return_(void);
    char ftpstr[28], tststr[16];
    integer lun;

    /* Fortran I/O blocks */
    static cilist io___9 = { 1, 0, 0, 0, 1 };
    static cilist io___10 = { 1, 0, 0, 0, 0 };
    static cilist io___11 = { 1, 0, 0, 0, 1 };


/* $ Abstract */

/*     Create partial test files to support the low-level handle */
/*     manager interface testing. */

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
/*     NAME       I   Name of the file to create. */
/*     ARCH       I   Integer code indicating the file architecture. */
/*     FDREC      I   Record number of the first descriptor record. */
/*     BFFID      I   BFFID to insert into the file record. */
/*     CNI        I   Character encoding of the value of NI to store. */
/*     CFDREC     I   Character encoding of the value of FDREC to store. */
/*     CNSUM      I   Character encoding of the value of NSUM to store. */
/*     ADDFTP     I   Logical indicating whether to store the FTP string. */
/*     BRKFTP     I   Logical indicating whether to "break" the FTP test. */
/*     NEWIDW     I   File ID word to insert into the file record. */

/* $ Detailed_Input */

/*     NAME       is the name of the DAF file to create. */

/*     ARCH       is the integer code indicating the file architecture */
/*                to use when creating the file.  Acceptable values are: */

/*                   DAF */
/*                   DAS */

/*                as defined in 'zzddhman.inc'. */

/*     BFFID      is the 8 character string that will be written to the */
/*                file record to indicate the binary file format of the */
/*                file created. */

/*     FDREC      is the record number of the first descriptor record */
/*                in the file. */

/*     CNI        is a 4 byte character string that contains the value */
/*                of NI byte by byte as it should be written to the file. */

/*     CFDREC     is a 4 byte character string that contains the value */
/*                of FDREC byte by byte as it should be written to the */
/*                file. */

/*     CNSUM      is a 4 byte character string that contains the value */
/*                of NSUM byte by byte as it should be written to the */
/*                file. */

/*     ADDFTP     is a logical that indicates whether or not to add */
/*                the FTP string to the file. */

/*     BRKFTP     is a logical that indicates whether or not to "break" */
/*                the FTP string before placing it in the file. */

/*     NEWIDW     is a character string, if blank indicates to insert */
/*                the appropriate generic ID word for the requested */
/*                architecture.  If non-blank, the first 8 characters */
/*                are placed at the head of the file record.  This is */
/*                just a hook to create screwed up files for testing */
/*                purposes. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine creates a file named by NAME that has the properties */
/*     specified by the input arguments. */

/* $ Exceptions */

/*     1) SPICE(FILEOPENFAILED) */

/*     2) SPICE(WRITEFAILURE) */

/* $ Particulars */

/*     This routine creates small test files for F_DDHPPF. */

/* $ Examples */

/*     See F_DDHIFF for usage. */

/* $ Restrictions */

/*     1) Characters are byte sized. */

/*     2) The file named by NAME does not exist. */

/*     3) NEWIDW if non-blank must contain at least 8 characters. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 06-NOV-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Parameters */


/*     Local Variables */


/*     Standard SPICE error handling */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_CPTFIL", (ftnlen)8);
    }

/*     Fetch the logical unit we're going to use to create the */
/*     file. */

    getlun_(&lun);

/*     Open the file we are about to construct. */

    o__1.oerr = 1;
    o__1.ounit = lun;
    o__1.ofnmlen = name_len;
    o__1.ofnm = name__;
    o__1.orl = 1024;
    o__1.osta = "NEW";
    o__1.oacc = "DIRECT";
    o__1.ofm = 0;
    o__1.oblnk = 0;
    iostat = f_open(&o__1);

/*     Check IOSTAT for trouble. */


    if (iostat != 0) {
	cl__1.cerr = 0;
	cl__1.cunit = lun;
	cl__1.csta = 0;
	f_clos(&cl__1);
	setmsg_("Attempt to open file, '#', failed. IOSTAT was $.", (ftnlen)
		48);
	errch_("#", name__, (ftnlen)1, name_len);
	errint_("$", &iostat, (ftnlen)1);
	sigerr_("SPICE(FILEOPENFAILED)", (ftnlen)21);
	chkout_("T_CPTFIL", (ftnlen)8);
	return 0;
    }

/*     Initialize RECORD to be a blank string. */

    s_copy(record, " ", (ftnlen)1024, (ftnlen)1);

/*     Do the absolute minimum to produce the necessary test file. */
/*     In this regard we will be placing only the patterns necessary */
/*     to exercise the logic of ZZDDHIFF and not focusing on the creation */
/*     of legitmate DAF and DAS files. */

    if (*arch == 1) {

/*        Assemble the file record. */

	s_copy(record, "DAF/TEST", (ftnlen)8, (ftnlen)8);
	s_copy(record + 12, cni, (ftnlen)4, cni_len);
	s_copy(record + 76, cfdrec, (ftnlen)4, cfdrec_len);
	s_copy(record + 88, bffid, (ftnlen)8, bffid_len);

/*        Before going any further, check to see if we are to replace */
/*        the ID word with NEWIDW. */

	if (s_cmp(newidw, " ", newidw_len, (ftnlen)1) != 0) {
	    s_copy(record, newidw, (ftnlen)8, (ftnlen)8);
	}
	if (*addftp) {

/*           Get the FTP string. */

	    zzftpstr_(tststr, lftbkt, rgtbkt, delim, (ftnlen)16, (ftnlen)6, (
		    ftnlen)6, (ftnlen)1);
/* Writing concatenation */
	    i__1[0] = rtrim_(lftbkt, (ftnlen)6), a__1[0] = lftbkt;
	    i__1[1] = rtrim_(tststr, (ftnlen)16), a__1[1] = tststr;
	    i__1[2] = rtrim_(rgtbkt, (ftnlen)6), a__1[2] = rgtbkt;
	    s_cat(ftpstr, a__1, i__1, &c__3, (ftnlen)28);

/*           Check to see if we are to "break" the FTP string. */

	    if (*brkftp) {

/*              Replace the "<13>" in the first cluster with */
/*              "<10>" to generate the error. */

		i__2 = rtrim_(lftbkt, (ftnlen)6) + 1;
		s_copy(ftpstr + i__2, "\n", rtrim_(lftbkt, (ftnlen)6) + 2 - 
			i__2, (ftnlen)1);
	    }

/*           Add the FTP string at position DASFTP. */

	    s_copy(record + 699, ftpstr, (ftnlen)325, (ftnlen)28);
	}

/*        Write the record. */

	io___9.ciunit = lun;
	iostat = s_wdue(&io___9);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = do_uio(&c__1, record, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = e_wdue();
L100001:

/*        Now create the first descriptor record. */

	s_copy(record, " ", (ftnlen)16, (ftnlen)1);
	s_copy(record + 16, cnsum, (ftnlen)8, cnsum_len);
	s_copy(record + 24, " ", (ftnlen)18, (ftnlen)1);
	io___10.ciunit = lun;
	io___10.cirec = *fdrec;
	iostat = s_wdue(&io___10);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = do_uio(&c__1, record, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = e_wdue();
L100002:

/*        Check IOSTAT for trouble. */

	if (iostat != 0) {
	    setmsg_("Attempt to write file '#' failed. Value of IOSTAT was #"
		    ". The file has been deleted.", (ftnlen)83);
	    errfnm_("#", &lun, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    cl__1.cerr = 0;
	    cl__1.cunit = lun;
	    cl__1.csta = "DELETE";
	    f_clos(&cl__1);
	    sigerr_("SPICE(WRITEFAILURE)", (ftnlen)19);
	    chkout_("T_CPTFIL", (ftnlen)8);
	    return 0;
	}

/*        We've created the test file, close the UNIT since we will be */
/*        re-opening it from the test code driver. */

	cl__1.cerr = 0;
	cl__1.cunit = lun;
	cl__1.csta = 0;
	f_clos(&cl__1);
    } else if (*arch == 2) {

/*        We need only to place the BFF ID string in the appropriate */
/*        place in the file record along with the DAS indentifier. */

	s_copy(record, "DAS/TEST", (ftnlen)8, (ftnlen)8);
	s_copy(record + 84, bffid, (ftnlen)8, bffid_len);

/*        Before going any further, check to see if we are to replace */
/*        the ID word with NEWIDW. */

	if (s_cmp(newidw, " ", newidw_len, (ftnlen)1) != 0) {
	    s_copy(record, newidw, (ftnlen)8, (ftnlen)8);
	}
	if (*addftp) {

/*           Get the FTP string. */

	    zzftpstr_(tststr, lftbkt, rgtbkt, delim, (ftnlen)16, (ftnlen)6, (
		    ftnlen)6, (ftnlen)1);
/* Writing concatenation */
	    i__1[0] = rtrim_(lftbkt, (ftnlen)6), a__1[0] = lftbkt;
	    i__1[1] = rtrim_(tststr, (ftnlen)16), a__1[1] = tststr;
	    i__1[2] = rtrim_(rgtbkt, (ftnlen)6), a__1[2] = rgtbkt;
	    s_cat(ftpstr, a__1, i__1, &c__3, (ftnlen)28);

/*           Check to see if we are to "break" the FTP string. */

	    if (*brkftp) {

/*              Replace the "<13>" in the first cluster with */
/*              "<10>" to generate the error. */

		i__2 = rtrim_(lftbkt, (ftnlen)6) + 1;
		s_copy(ftpstr + i__2, "\n", rtrim_(lftbkt, (ftnlen)6) + 2 - 
			i__2, (ftnlen)1);
	    }

/*           Add the FTP string at position DASFTP. */

	    s_copy(record + 699, ftpstr, (ftnlen)325, (ftnlen)28);
	}

/*        Write the record. */

	io___11.ciunit = lun;
	iostat = s_wdue(&io___11);
	if (iostat != 0) {
	    goto L100003;
	}
	iostat = do_uio(&c__1, record, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100003;
	}
	iostat = e_wdue();
L100003:

/*        Check IOSTAT for trouble. */

	if (iostat != 0) {
	    setmsg_("Attempt to write file '#' failed. Value of IOSTAT was #"
		    ". The file has been deleted.", (ftnlen)83);
	    errfnm_("#", &lun, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    cl__1.cerr = 0;
	    cl__1.cunit = lun;
	    cl__1.csta = "DELETE";
	    f_clos(&cl__1);
	    sigerr_("SPICE(WRITEFAILURE)", (ftnlen)19);
	    chkout_("T_CPTFIL", (ftnlen)8);
	    return 0;
	}

/*        We've created the test file, close the UNIT since we will be */
/*        re-opening it from the test code driver. */

	cl__1.cerr = 0;
	cl__1.cunit = lun;
	cl__1.csta = 0;
	f_clos(&cl__1);
    } else {
	setmsg_("Unknown architecture code.", (ftnlen)26);
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("T_CPTFIL", (ftnlen)8);
	return 0;
    }
    chkout_("T_CPTFIL", (ftnlen)8);
    return 0;
} /* t_cptfil__ */

