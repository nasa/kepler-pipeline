/* t_xltfwd.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__4 = 4;
static integer c__1 = 1;

/* $Procedure T_XLTFWD ( Translate For Write, Double Precision Values ) */
/* Subroutine */ int t_xltfwd__(doublereal *input, integer *numdp, integer *
	outbff, char *output, ftnlen output_len)
{
    /* Initialized data */

    static logical first = TRUE_;
    static integer natbff = 0;

    /* System generated locals */
    integer i__1, i__2;
    char ch__1[1];
    static doublereal equiv_0[1];

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), i_len(char *, ftnlen), 
	    lbit_shift(integer, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int zzddhgsd_(char *, integer *, char *, ftnlen, 
	    ftnlen), zzplatfm_(char *, char *, ftnlen, ftnlen);
    integer i__, j, space;
    extern /* Subroutine */ int chkin_(char *, ftnlen), ucase_(char *, char *,
	     ftnlen, ftnlen), errch_(char *, char *, ftnlen, ftnlen), moved_(
	    doublereal *, integer *, doublereal *);
    integer value;
    extern integer isrchc_(char *, integer *, char *, ftnlen, ftnlen);
    static char strbff[8*4];
    extern /* Subroutine */ int sigerr_(char *, ftnlen);
#define dequiv (equiv_0)
    extern /* Subroutine */ int chkout_(char *, ftnlen);
    integer lenopt;
#define iequiv ((integer *)equiv_0)
    extern /* Subroutine */ int setmsg_(char *, ftnlen), errint_(char *, 
	    integer *, ftnlen);
    extern logical return_(void);
    char tmpstr[8];

/* $ Abstract */

/*     Translate double precision values from the native binary file */
/*     format to a non-native format for write. */

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
/*     INPUT      I   List of d.p. values to be translated. */
/*     NUMDP      I   Number of integers in INPUT to convert. */
/*     OUTBFF     I   Binary file format code for d.p. values in OUTPUT. */
/*     OUTPUT     O   Character string containing the translated values. */

/* $ Detailed_Input */

/*     INPUT      is an array of double precision numbers containing the */
/*                values to be translated into a non-native binary format */
/*                and stored in OUTPUT. */

/*     NUMDP      is the number of double precision values to convert to */
/*                non-native binary file format and store in OUTPUT. */

/*     OUTBFF     is an integer code that indicates the binary file */
/*                format targeted for OUTPUT.  Acceptable values */
/*                are the parameters: */

/*                   BIGI3E */
/*                   LTLI3E */
/*                   VAXGFL */
/*                   VAXDFL */

/*                as defined in the include file 'zzddhman.inc'. */

/* $ Detailed_Output */

/*     OUTPUT     is a string containing a group of double precision */
/*                values converted from the native binary file format */
/*                to OUTBFF and encoded byte by byte as characters. */
/*                This string should be at least the number of bytes */
/*                used to store an integer multiplied by NUMDP in */
/*                length. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine may signal SPICE(BUG) if the inputs are not */
/*     proper. */

/* $ Particulars */

/*     This routine converts double precision values from the native */
/*     binary file format to a non-native one.  The results are */
/*     encoded in a character string that can be written directly */
/*     to a file. */

/*     Note: This code is not a model of perfection.  It is hacked */
/*     together from pieces of code written elsewhere to support */
/*     creation of non-native binaries for testing purposes only. */

/* $ Examples */

/*     See F_XLATED for usage. */

/* $ Restrictions */

/*     1) Numeric data when written as characters to a file preserve */
/*        the bit patterns present in memory in the file. */

/*     2) A byte is 8 bits, and a character is some multiple of */
/*        bytes. */

/*     3) The intrinsic ICHAR preserves the bit pattern of the character */
/*        byte read from a file.  Namely if one examines the integer */
/*        found in the character. */

/*     4) The size of integers on the target environment are a multiple */
/*        of some number of bytes. */

/*     5) The length of the OUTPUT string is a multiple of the number */
/*        of bytes for an integer in the OUTBFF format. */

/*     6) OUTBFF is supported for reading on this platform, and not */
/*        equivalent to NATBFF on this platform. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 19-OCT-2001 (FST) */


/* -& */

/*     SPICELIB Functions */


/*     Local Variables */


/*     Equivalence DEQUIV to IEQUIV */


/*     Saved Variables */


/*     Data Statements */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("T_XLTFWD", (ftnlen)8);
    }

/*     Perform some initialization tasks. */

    if (first) {

/*        Populate STRBFF with the appropriate binary file */
/*        format labels. */

	for (i__ = 1; i__ <= 4; ++i__) {
	    zzddhgsd_("BFF", &i__, strbff + (((i__1 = i__ - 1) < 4 && 0 <= 
		    i__1 ? i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (
		    ftnlen)217)) << 3), (ftnlen)3, (ftnlen)8);
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
	    chkout_("T_XLTFWD", (ftnlen)8);
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
	chkout_("T_XLTFWD", (ftnlen)8);
	return 0;
    }

/*     Get the length of the input string. */

    lenopt = i_len(output, output_len);

/*     Now branch depending on the value of NATBFF. */

    if (natbff == 1) {
	if (*outbff == 2) {

/*           Before we go any further check to see that the length */
/*           of the output string is appropriate and we have enough */
/*           room to store the results.  Since this string is to contain */
/*           LTL-IEEE double precision numbers and this is a BIG-IEEE */
/*           machine, characters are 1-byte and double precision numbers */
/*           are 8-bytes.  So the length of OUTPUT must be a multiple */
/*           of 8. */

	    space = lenopt / 8;
	    if (lenopt - (space << 3) != 0) {
		setmsg_("The output string that is to be translated from the"
			" binary format # to format # has a length that is no"
			"t a multiple of 8 bytes.  This error should never oc"
			"cur.", (ftnlen)159);
		errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
			i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			294)) << 3), (ftnlen)1, (ftnlen)8);
		errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ?
			 i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			295)) << 3), (ftnlen)1, (ftnlen)8);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chkout_("T_XLTFWD", (ftnlen)8);
		return 0;
	    }

/*           Now check to see that there is enough room to store */
/*           the number of integers we are to convert. */

	    if (*numdp > space) {
		setmsg_("The caller specified that # double precision number"
			"s are to be translated from binary format # to #.  H"
			"owever there is only room to hold # numbers in the o"
			"utput array.  This error should never occur.", (
			ftnlen)199);
		errint_("#", numdp, (ftnlen)1);
		errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
			i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			315)) << 3), (ftnlen)1, (ftnlen)8);
		errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ?
			 i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			316)) << 3), (ftnlen)1, (ftnlen)8);
		errint_("#", &space, (ftnlen)1);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chkout_("T_XLTFWD", (ftnlen)8);
		return 0;
	    }

/*           Start looping over each double precision number and */
/*           converting them to the 8-byte character packages to */
/*           be stored in OUTPUT. */

	    i__1 = *numdp;
	    for (i__ = 1; i__ <= i__1; ++i__) {

/*              Compute the substring index of the first character */
/*              in OUTPUT for this double precision number. */

		j = (i__ - 1 << 3) + 1;

/*              Now extract and arrange the bytes properly. */
/*              Since these characters are to be stored in a file */
/*              utilizing LTL-IEEE, we know that J is the */
/*              least significant byte and that (J+7) is the */
/*              most significant. */

/*              INPUT: */

/*                      ------------------------------------- */
/*                 . . .|     |  J  | J+1 | J+2 | J+3 |     |. . . */
/*                      ------------------------------------- */

/*                   OUTPUT(J:J) = CHAR( INPUT(I)'s LSB ) */
/*                      . */
/*                      . */
/*                   OUTPUT(J+7:J+7) = CHAR( INPUT(I)'s MSB ) */

/*              Perform the necessary computations. */

		moved_(&input[i__ - 1], &c__1, dequiv);
		value = iequiv[1] << 24;
		value = lbit_shift(value, (ftnlen)-24);
		*(unsigned char *)&output[j - 1] = (char) value;
		value = iequiv[1] << 16;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 1 - i__2, (ftnlen)1);
		value = iequiv[1] << 8;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 1;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 2 - i__2, (ftnlen)1);
		value = lbit_shift(iequiv[1], (ftnlen)-24);
		i__2 = j + 2;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 3 - i__2, (ftnlen)1);
		value = iequiv[0] << 24;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 3;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 4 - i__2, (ftnlen)1);
		value = iequiv[0] << 16;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 4;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 5 - i__2, (ftnlen)1);
		value = iequiv[0] << 8;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 5;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 6 - i__2, (ftnlen)1);
		value = lbit_shift(iequiv[0], (ftnlen)-24);
		i__2 = j + 6;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 7 - i__2, (ftnlen)1);
	    }
	} else {
	    setmsg_("Unable to translate double precision numbers from binar"
		    "y file format # to #. This error should never occur and "
		    "is indicative of a bug.  Contact NAIF.", (ftnlen)149);
	    errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
		    i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)397)) 
		    << 3), (ftnlen)1, (ftnlen)8);
	    errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ? 
		    i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)398)) 
		    << 3), (ftnlen)1, (ftnlen)8);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("T_XLTFWD", (ftnlen)8);
	    return 0;
	}
    } else if (natbff == 2) {
	if (*outbff == 1) {

/*           Before we go any further check to see that the length */
/*           of the output string is appropriate and we have enough */
/*           room to store the results.  Since this string is to */
/*           contain BIG-IEEE double precision values and this is a */
/*           LTL-IEEE machine, characters are 1-byte and double */
/*           precision values are 8-bytes.  So the length of OUTPUT */
/*           must be a multiple of 8. */

	    space = lenopt / 8;
	    if (lenopt - (space << 3) != 0) {
		setmsg_("The output string that is to be translated from the"
			" binary format # to format # has a length that is no"
			"t a multiple of 8 bytes.  This error should never oc"
			"cur.", (ftnlen)159);
		errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
			i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			427)) << 3), (ftnlen)1, (ftnlen)8);
		errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ?
			 i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			428)) << 3), (ftnlen)1, (ftnlen)8);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chkout_("T_XLTFWD", (ftnlen)8);
		return 0;
	    }

/*           Now check to see that there is enough room to store */
/*           the number of integers we are to convert. */

	    if (*numdp > space) {
		setmsg_("The caller specified that # double precision number"
			"s are to be translated from binary format # to #. Ho"
			"wever there is only room to hold # numbers in the ou"
			"tput array.  This error should never occur.", (ftnlen)
			198);
		errint_("#", numdp, (ftnlen)1);
		errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
			i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			448)) << 3), (ftnlen)1, (ftnlen)8);
		errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ?
			 i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)
			449)) << 3), (ftnlen)1, (ftnlen)8);
		errint_("#", &space, (ftnlen)1);
		sigerr_("SPICE(BUG)", (ftnlen)10);
		chkout_("T_XLTFWD", (ftnlen)8);
		return 0;
	    }

/*           Start looping over each double precision number and */
/*           converting them to the 8-byte character packages to */
/*           be stored in OUTPUT. */

	    i__1 = *numdp;
	    for (i__ = 1; i__ <= i__1; ++i__) {

/*              Compute the substring index of the first character */
/*              in OUTPUT for this double precision number. */

		j = (i__ - 1 << 3) + 1;

/*              Now extract and arrange the bytes properly. */
/*              Since these characters are to be stored in a file */
/*              utilizing BIG-IEEE, we know that J is the most */
/*              significant byte and that (J+7) is the least */
/*              significant. */

/*              INPUT: */

/*                      ------------------------------------- */
/*                 . . .|     |  J  | J+1 | J+2 | J+3 |     |. . . */
/*                      ------------------------------------- */

/*                   OUTPUT(J:J) = CHAR( INPUT(I)'s MSB ) */
/*                      . */
/*                      . */
/*                   OUTPUT(J+7:J+7) = CHAR( INPUT(I)'s LSB ) */

/*              Perform the necessary computations. */

		moved_(&input[i__ - 1], &c__1, dequiv);
		value = lbit_shift(iequiv[1], (ftnlen)-24);
		*(unsigned char *)&output[j - 1] = (char) value;
		value = iequiv[1] << 8;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 1 - i__2, (ftnlen)1);
		value = iequiv[1] << 16;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 1;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 2 - i__2, (ftnlen)1);
		value = iequiv[1] << 24;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 2;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 3 - i__2, (ftnlen)1);
		value = lbit_shift(iequiv[0], (ftnlen)-24);
		i__2 = j + 3;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 4 - i__2, (ftnlen)1);
		value = iequiv[0] << 8;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 4;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 5 - i__2, (ftnlen)1);
		value = iequiv[0] << 16;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 5;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 6 - i__2, (ftnlen)1);
		value = iequiv[0] << 24;
		value = lbit_shift(value, (ftnlen)-24);
		i__2 = j + 6;
		*(unsigned char *)&ch__1[0] = value;
		s_copy(output + i__2, ch__1, j + 7 - i__2, (ftnlen)1);
	    }
	} else {
	    setmsg_("Unable to translate double precision numbers from binar"
		    "y file format # to #. This error should never occur and "
		    "is indicative of a bug.  Contact NAIF.", (ftnlen)149);
	    errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? 
		    i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)530)) 
		    << 3), (ftnlen)1, (ftnlen)8);
	    errch_("#", strbff + (((i__1 = *outbff - 1) < 4 && 0 <= i__1 ? 
		    i__1 : s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)531)) 
		    << 3), (ftnlen)1, (ftnlen)8);
	    sigerr_("SPICE(BUG)", (ftnlen)10);
	    chkout_("T_XLTFWD", (ftnlen)8);
	    return 0;
	}

/*     The native binary file format on this platform is not supported */
/*     for the conversion of integers.  This is a bug, as this branch */
/*     of code should never be reached in normal operation. */

    } else {
	setmsg_("The native binary file format of this toolkit build, #, is "
		"not currently supported for translation of double precision "
		"numbers from non-native formats.", (ftnlen)151);
	errch_("#", strbff + (((i__1 = natbff - 1) < 4 && 0 <= i__1 ? i__1 : 
		s_rnge("strbff", i__1, "t_xltfwd__", (ftnlen)549)) << 3), (
		ftnlen)1, (ftnlen)8);
	sigerr_("SPICE(BUG)", (ftnlen)10);
	chkout_("T_XLTFWD", (ftnlen)8);
	return 0;
    }
    chkout_("T_XLTFWD", (ftnlen)8);
    return 0;
} /* t_xltfwd__ */

#undef iequiv
#undef dequiv


