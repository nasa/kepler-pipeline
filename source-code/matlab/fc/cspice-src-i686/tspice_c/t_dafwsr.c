/* t_dafwsr.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static integer c__1 = 1;
static integer c__3 = 3;

/* $Procedure T_DAFWSR ( Write a DAF summary/descriptor record to file ) */
/* Subroutine */ int t_dafwsr__(integer *unit, integer *recno, integer *
	outbff, integer *nd, integer *ni, integer *next, integer *prev, 
	integer *nsum, doublereal *array)
{
    /* Initialized data */

    static logical first = TRUE_;
    static integer natbff = 0;

    /* System generated locals */
    integer i__1, i__2;
    static doublereal equiv_0[128];

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), s_wdue(cilist *), 
	    do_uio(integer *, char *, ftnlen), e_wdue(void);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzddhgsd_(char *, integer *, char *, ftnlen, 
	    ftnlen), t_xltfwd__(doublereal *, integer *, integer *, char *, 
	    ftnlen), t_xltfwi__(integer *, integer *, integer *, char *, 
	    ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    doublereal dprec[128];
#define dpbuf (equiv_0)
    extern /* Subroutine */ int ucase_(char *, char *, ftnlen, ftnlen);
#define inbuf ((integer *)equiv_0)
    extern /* Subroutine */ int errch_(char *, char *, ftnlen, ftnlen), 
	    moved_(doublereal *, integer *, doublereal *);
    integer cindex;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    integer dindex;
    char record[1024];
    static char strbff[8*4];
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), errfnm_(char *, integer *, ftnlen), setmsg_(char *, 
	    ftnlen);
    integer iostat;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen);
    integer numint;
    extern logical return_(void);
    char tmpstr[8];

    /* Fortran I/O blocks */
    static cilist io___10 = { 1, 0, 0, 0, 0 };
    static cilist io___15 = { 1, 0, 0, 0, 0 };


/* $ Abstract */

/*     Write a descriptor record to a DAF. */

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
/*     UNIT       I   Unit attached to DAF to receive new file record. */
/*     RECNO      I   Record number. */
/*     OUTBFF     I   Binary file format code for d.p. values in OUTPUT. */
/*     ND         I   Number of double precision components in summaries. */
/*     NI         I   Number of integer components in summaries. */
/*     NEXT       I   Record number of the next summary record. */
/*     PREV       I   Record number of the previous summary record. */
/*     NSUM       I   Number of summaries in array. */
/*     ARRAY      I   Sequence of packed summaries to write. */

/* $ Detailed_Input */

/*     UNIT       is the logical unit attached to the DAF to receive */
/*                the new summary record. */

/*     RECNO      is the record number of the record to write the summary */
/*                record. */

/*     OUTBFF     is an integer code that indicates the binary file */
/*                format targeted for OUTPUT.  Acceptable values */
/*                are the parameters: */

/*                   BIGI3E */
/*                   LTLI3E */
/*                   VAXGFL */
/*                   VAXDFL */

/*                as defined in the include file 'zzddhman.inc'. */

/*     ND, */
/*     NI         are the numbers of double precision and integer */
/*                components, respectively, in each array summary */
/*                in the specified file. */

/*     NEXT       is the record number of the next summary record in */
/*                the DAF, or zero if this is the last summary record. */

/*     PREV       is the record number of the previous summary record */
/*                in the DAF, or zero if this is the first summary */
/*                record. */

/*     NSUM       is the number of summary records contained in ARRAY. */

/*     ARRAY      is a double precision array of packed summaries to */
/*                be written to the DAF. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine will update the contents of the record RECNO */
/*     in the file associated with UNIT. */

/* $ Exceptions */


/* $ Particulars */

/*     This routine takes the contents of ARRAY, converts it to the */
/*     appropriate format if necessary, and writes it to RECNO in */
/*     the file attached to UNIT. */

/*     Note: This code is not a model of perfection.  It is hacked */
/*     together from pieces of code written elsewhere to support */
/*     creation of non-native binaries for testing purposes only. */

/* $ Examples */

/*     See F_ZZDGDR for usage. */

/* $ Restrictions */

/*     1) The file was created with T_DAFOPN. */

/*     2) NSUM, ND, NI and the contents of ARRAY are all consistent. */
/*        This means that NSUM*(ND+(NI+1)/2) is precisely the number */
/*        of entries in ARRAY to be written to the DAF. */

/*     3) NEXT and PREV point to actual summary records in the DAF, */
/*        or are 0. */

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


/*     Equivalence DPBUF to INBUF to handle unpacking. */


/*     Saved Variables */


/*     Data Statements */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_DAFWSR", (ftnlen)8);
    }

/*     Perform some initialization tasks. */

    if (first) {

/*        Populate STRBFF with the appropriate binary file */
/*        format labels. */

	for (i__ = 1; i__ <= 4; ++i__) {
	    zzddhgsd_("BFF", &i__, strbff + (((i__1 = i__ - 1) < 4 && 0 <= 
		    i__1 ? i__1 : s_rnge("strbff", i__1, "t_dafwsr__", (
		    ftnlen)243)) << 3), (ftnlen)3, (ftnlen)8);
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
	    chkout_("T_DAFWSR", (ftnlen)8);
	    return 0;
	}

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
	chkout_("T_DAFWSR", (ftnlen)8);
	return 0;
    }

/*     First, determine if we are to write to the native file format. */

    if (*outbff == natbff) {
	dprec[0] = (doublereal) (*next);
	dprec[1] = (doublereal) (*prev);
	dprec[2] = (doublereal) (*nsum);
	i__1 = *nsum * (*nd + (*ni + 1) / 2);
	moved_(array, &i__1, &dprec[3]);
	io___10.ciunit = *unit;
	io___10.cirec = *recno;
	iostat = s_wdue(&io___10);
	if (iostat != 0) {
	    goto L100001;
	}
	for (i__ = 1; i__ <= 128; ++i__) {
	    iostat = do_uio(&c__1, (char *)&dprec[(i__1 = i__ - 1) < 128 && 0 
		    <= i__1 ? i__1 : s_rnge("dprec", i__1, "t_dafwsr__", (
		    ftnlen)301)], (ftnlen)sizeof(doublereal));
	    if (iostat != 0) {
		goto L100001;
	    }
	}
	iostat = e_wdue();
L100001:
	if (iostat != 0) {
	    setmsg_("Unable to write to #. IOSTAT was #", (ftnlen)34);
	    errfnm_("#", unit, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEWRITEFAILED)", (ftnlen)22);
	    chkout_("T_DAFWSR", (ftnlen)8);
	    return 0;
	}

/*     Handle the non-native case. */

    } else {

/*        Clear RECORD. */

	s_copy(record, " ", (ftnlen)1024, (ftnlen)1);

/*        Populate RECORD. */

	dprec[0] = (doublereal) (*next);
	dprec[1] = (doublereal) (*prev);
	dprec[2] = (doublereal) (*nsum);
	t_xltfwd__(dprec, &c__3, outbff, record, (ftnlen)24);

/*        Set the index into RECORD to start placing summaries. */

	cindex = 25;

/*        Now process the summaries. */

	i__1 = *nsum;
	for (i__ = 1; i__ <= i__1; ++i__) {

/*           Set the starting index into ARRAY for the next summary. */

	    dindex = (i__ - 1) * (*nd + (*ni + 1) / 2) + 1;

/*           Convert the DPs. */

	    t_xltfwd__(&array[dindex - 1], nd, outbff, record + (cindex - 1), 
		    cindex + (*nd << 3) - 1 - (cindex - 1));

/*           Increment CINDEX and DINDEX to the position where the */
/*           integers will be placed and located. */

	    dindex += *nd;
	    cindex += *nd << 3;

/*           Unpack the integer components. */

	    i__2 = (*ni + 1) / 2;
	    moved_(&array[dindex - 1], &i__2, dpbuf);

/*           Translate the integers. We are translating 2*((NI+1)/2) */
/*           integers, which is not always NI integers.  Rather than */
/*           introduce special exception for the two cases (NI odd and */
/*           NI even, we will just translate the garbage in the last */
/*           integer in the odd case. */

	    numint = (*ni + 1) / 2 << 1;
	    t_xltfwi__(inbuf, &numint, outbff, record + (cindex - 1), cindex 
		    + (numint << 2) - 1 - (cindex - 1));

/*           Increment CINDEX.  We ignore DINDEX because it will be */
/*           set properly at the start of the loop. */

	    cindex += numint << 2;
	}

/*        Dump the record to the file. */

	io___15.ciunit = *unit;
	io___15.cirec = *recno;
	iostat = s_wdue(&io___15);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = do_uio(&c__1, record, (ftnlen)1024);
	if (iostat != 0) {
	    goto L100002;
	}
	iostat = e_wdue();
L100002:
	if (iostat != 0) {
	    setmsg_("Unable to write to #. IOSTAT was #", (ftnlen)34);
	    errfnm_("#", unit, (ftnlen)1);
	    errint_("#", &iostat, (ftnlen)1);
	    sigerr_("SPICE(FILEWRITEFAILED)", (ftnlen)22);
	    chkout_("T_DAFWSR", (ftnlen)8);
	    return 0;
	}
    }
    chkout_("T_DAFWSR", (ftnlen)8);
    return 0;
} /* t_dafwsr__ */

#undef inbuf
#undef dpbuf


