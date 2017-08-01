/* t_bingo.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;

/* $Procedure T_BINGO ( BINGO: Process binary kernels to alternate BFFs ) */
/* Subroutine */ int t_bingo__(char *iname, char *oname, integer *obff, 
	ftnlen iname_len, ftnlen oname_len)
{
    /* System generated locals */
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer f_open(olist *), s_rdue(cilist *), do_uio(integer *, char *, 
	    ftnlen), e_rdue(void), f_clos(cllist *);

    /* Local variables */
    integer ibff;
    char arch[8];
    integer iamh, iarc;
    extern /* Subroutine */ int t_bgodaf__(char *, char *, integer *, ftnlen, 
	    ftnlen);
    integer unit;
    char type__[8];
    extern /* Subroutine */ int zzddhfnh_(char *, integer *, logical *, 
	    ftnlen), zzddhnfo_(integer *, char *, integer *, integer *, 
	    integer *, logical *, ftnlen);
    char fname[255];
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen);
    logical found;
    extern integer rtrim_(char *, ftnlen);
    extern logical eqstr_(char *, char *, ftnlen, ftnlen);
    extern /* Subroutine */ int idw2at_(char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen);
    integer handle;
    char idword[8];
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), getlun_(integer *), setmsg_(char *, ftnlen);
    integer iostat;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen);
    extern logical return_(void);

    /* Fortran I/O blocks */
    static cilist io___9 = { 1, 0, 1, 0, 1 };


/* $ Abstract */

/*     Convert SPICE binary kernels from one supported binary file */
/*     format to another. */

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

/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     INAME      I   Name of source binary kernel to convert. */
/*     ONAME      I   Name of output binary kernel to create. */
/*     OBFF       I   Integer code for binary file format of ONAME. */

/* $ Detailed_Input */

/*     INAME      is the name of the binary kernel to convert to */
/*                an alternate binary file format. */

/*     ONAME      is the name of the converted binary kernel to create. */
/*                The file named by ONAME will be destroyed and */
/*                replaced with the converted file. */

/*     OBFF       is an integer code that indicates the binary file */
/*                format targeted for ONAME.  Acceptable values are */
/*                the parameters: */

/*                   BIGI3E */
/*                   LTLI3E */
/*                   VAXGFL */
/*                   VAXDFL */

/*                as defined in the include file 'zzddhman.inc'. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine opens the file named by INAME for read access, and */
/*     creates (destroying any pre-existing file if necessary) the */
/*     file named by ONAME. */

/* $ Exceptions */

/*     1) */

/* $ Particulars */

/*     This test routine allows existing test software that creates */
/*     DAFs using the high level writers to create native format */
/*     files and convert them to supported non-native formats formats */
/*     for testing purposes. */

/*     As new binary file formats for existing kernels are added to */
/*     the list of those officially supported, this routine and */
/*     the routines it calls may require significant updates. */

/* $ Examples */

/*     See some TBD test family routine. */

/* $ Restrictions */

/*     This code is cobbled together in a rather non-robust way. */
/*     Do not attempt to convert binary kernels that are not 100% */
/*     correct in their structure and composition.  Using this */
/*     routine on files with questionable construction will yield */
/*     unpredictable results at best. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 28-NOV-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Standard SPICE error handling */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_BINGO", (ftnlen)7);
    }

/*     First things first, check to see if the handle manager has */
/*     an entry for ONAME. */

    zzddhfnh_(oname, &handle, &found, oname_len);
    if (found) {
	setmsg_("Can not create file, '#'.  It is currently loaded and assoc"
		"iated with handle, #.  This routine may only create files no"
		"t currently loaded.", (ftnlen)138);
	errch_("#", oname, (ftnlen)1, oname_len);
	errint_("#", &handle, (ftnlen)1);
	sigerr_("SPICE(CANTCREATEFILE)", (ftnlen)21);
	chkout_("T_BINGO", (ftnlen)7);
	return 0;
    }

/*     Now, see if IFNAME is loaded in the handle manager. */

    zzddhfnh_(iname, &handle, &found, iname_len);

/*     If it is loaded, then use the value of IARC to indicate the */
/*     file architecture. */

    if (found) {
	zzddhnfo_(&handle, fname, &iarc, &ibff, &iamh, &found, (ftnlen)255);

/*     Otherwise, open the file and extract the 8 character IDWORD. */

    } else {
	getlun_(&unit);
	o__1.oerr = 1;
	o__1.ounit = unit;
	o__1.ofnmlen = rtrim_(iname, iname_len);
	o__1.ofnm = iname;
	o__1.orl = 1024;
	o__1.osta = "OLD";
	o__1.oacc = "DIRECT";
	o__1.ofm = 0;
	o__1.oblnk = 0;
	iostat = f_open(&o__1);
	if (iostat != 0) {
	    setmsg_("Unable to open file, '#'. IOSTAT = #.", (ftnlen)37);
	    errch_("#", iname, (ftnlen)1, iname_len);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEOPENFAILED)", (ftnlen)21);
	    chkout_("T_BINGO", (ftnlen)7);
	    return 0;
	}
	io___9.ciunit = unit;
	iostat = s_rdue(&io___9);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = do_uio(&c__1, idword, (ftnlen)8);
	if (iostat != 0) {
	    goto L100001;
	}
	iostat = e_rdue();
L100001:
	if (iostat != 0) {
	    setmsg_("Unable to read ID word from file, '#'.  IOSTAT = #.", (
		    ftnlen)51);
	    errch_("#", iname, (ftnlen)1, iname_len);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEREADFAILED)", (ftnlen)21);
	    chkout_("T_BINGO", (ftnlen)7);
	    return 0;
	}
	idw2at_(idword, arch, type__, (ftnlen)8, (ftnlen)8, (ftnlen)8);
	if (eqstr_(arch, "DAF", (ftnlen)8, (ftnlen)3)) {
	    iarc = 1;
	} else if (eqstr_(arch, "DAS", (ftnlen)8, (ftnlen)3)) {
	    iarc = 2;
	} else {
	    iarc = 0;
	}
	cl__1.cerr = 0;
	cl__1.cunit = unit;
	cl__1.csta = 0;
	f_clos(&cl__1);
    }

/*     IARC is set properly, branch appropriately. */

    if (iarc == 1) {
	t_bgodaf__(iname, oname, obff, iname_len, oname_len);
    } else if (iarc == 2) {
	setmsg_("DAS file conversion not supported at this time.", (ftnlen)47)
		;
	sigerr_("SPICE(UNSUPPORTEDARCH)", (ftnlen)22);
	chkout_("T_BINGO", (ftnlen)7);
	return 0;
    } else {
	setmsg_("The architecture of file, '#', is unknown.  No conversion p"
		"ossible.", (ftnlen)67);
	sigerr_("SPICE(UNKNOWNARCH)", (ftnlen)18);
	chkout_("T_BINGO", (ftnlen)7);
	return 0;
    }
    chkout_("T_BINGO", (ftnlen)7);
    return 0;
} /* t_bingo__ */

