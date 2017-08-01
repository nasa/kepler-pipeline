/* tle2spk.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__399 = 399;
static integer c__0 = 0;
static integer c__1950 = 1950;
static integer c__5000 = 5000;
static integer c__10 = 10;

/* $Procedure TLE2SPK ( Read two-line element set and create type 10 SPK ) */
/* Subroutine */ int tle2spk_(char *inpfn, integer *obidvl, integer *cnidvl, 
	char *frnmvl, char *sgidvl, integer *handle, ftnlen inpfn_len, ftnlen 
	frnmvl_len, ftnlen sgidvl_len)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen), s_rnge(char *, integer, 
	    char *, integer);

    /* Local variables */
    char code[32];
    doublereal endt;
    char type__[1];
    extern /* Subroutine */ int zzgetelm_(integer *, char *, doublereal *, 
	    doublereal *, logical *, char *, ftnlen, ftnlen);
    integer i__, j, k, n;
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen);
    doublereal elems[50010];
    char lines[512*2];
    logical found;
    extern /* Subroutine */ int repmi_(char *, char *, integer *, char *, 
	    ftnlen, ftnlen, ftnlen);
    integer trash;
    extern /* Subroutine */ int spkw10_(integer *, integer *, integer *, char 
	    *, doublereal *, doublereal *, char *, doublereal *, integer *, 
	    doublereal *, doublereal *, ftnlen, ftnlen);
    char error[512*2], outfn[255];
    extern integer rtrim_(char *, ftnlen);
    char chose1[32], chose2[32];
    extern /* Subroutine */ int dafhfn_(integer *, char *, ftnlen);
    logical ok;
    extern /* Subroutine */ int dafcls_(integer *), delfil_(char *, ftnlen);
    extern logical isordv_(integer *, integer *), return_(void);
    integer object, frcode, framid;
    doublereal begint, epochs[5001], geophs[8];
    logical fmodel;
    integer iorder[5000], ordvec[5000];
    char geolst[255];
    extern /* Subroutine */ int setmsg_(char *, ftnlen), errint_(char *, 
	    integer *, ftnlen);
    logical eof;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), namfrm_(char *, 
	    integer *, ftnlen), intstr_(integer *, char *, ftnlen), rdtext_(
	    char *, char *, logical *, ftnlen, ftnlen), dtpool_(char *, 
	    logical *, integer *, char *, ftnlen, ftnlen), suffix_(char *, 
	    integer *, char *, ftnlen, ftnlen), bodvar_(integer *, char *, 
	    integer *, doublereal *, ftnlen), orderd_(doublereal *, integer *,
	     integer *), reordd_(integer *, integer *, doublereal *), reorbd_(
	    integer *, integer *, integer *, doublereal *), tostdo_(char *, 
	    ftnlen), cltext_(char *, ftnlen);
    extern doublereal spd_(void);
    extern /* Subroutine */ int chkout_(char *, ftnlen);
    integer put;

/* $ Abstract */

/*     This routine is a module of the MKSPK program. It creates an SPK */
/*     file from a file containing the NORAD "two-line element sets". */

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

/*     MKSPK User's Guide */

/* $ Keywords */

/*     None. */

/* $ Declarations */
/* $ Abstract */

/*     MKSPK Include File. */

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

/* $ Author_and_Institution */

/*     N.G. Khavenson (IKI RAS, Russia) */
/*     B.V. Semenov   (NAIF, JPL) */

/* $ Version */

/* -    Version 1.1.0, 05-JUN-2001 (BVS). */

/*        Added MAXDEG parameter. */

/* -    Version 1.0.4, 21-MAR-2001 (BVS). */

/*        Added parameter for command line flag '-append' indicating */
/*        that appending to an existing output file was requested. */
/*        Added corresponding setup file keyword ('APPEND_TO_OUTPUT'.) */
/*        Added parameters for yes and no values of this keyword. */

/* -    Version 1.0.3, 28-JAN-2000 (BVS). */

/*        Added parameter specifying number of supported input data */
/*        types and parameter specifying number of supported output SPK */
/*        types */

/* -    Version 1.0.2, 22-NOV-1999 (NGK). */

/*        Added parameters for two-line elements processing. */

/* -    Version 1.0.1, 18-MAR-1999 (BVS). */

/*        Added usage, help and template displays. Corrected comments. */

/* -    Version 1.0.0,  8-SEP-1998 (NGK). */

/* -& */

/*     Begin Include Section:  MKSPK generic parameters. */


/*     Maximum number of states allowed per one segment. */


/*     String size allocation parameters */


/*     Length of buffer for input text processing */


/*     Length of a input text line */


/*     Length of file name and comment line */


/*     Length of string for keyword value processing */


/*     Length of string for word processing */


/*     Length of data order parameters string */


/*     Length of string reserved as delimiter */


/*     Numbers of different parameters */



/*     Maximum number of allowed comment lines. */


/*     Reserved number of input parameters */


/*     Full number of delimiters */


/*     Number of delimiters that may appear in time string */


/*     Command line flags */


/*     Setup file keywords reserved values */


/*     Standard YES and NO values for setup file keywords. */


/*     Number of supported input data types and input DATA TYPE */
/*     reserved values. */


/*     Number of supported output SPK data types -- this version */
/*     supports SPK types 5, 8, 9, 10, 12, 13, 15 and 17. */


/*     End of input record marker */


/*     Maximum allowed polynomial degree. The value of this parameter */
/*     is consistent with the ones in SPKW* routines. */


/*     End Include Section:  MKSPK generic parameters. */

/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     INPFN      I   Input file name */
/*     FRNMVL     I   Reference frame name of output SPK */
/*     OBIDVL     I   NORAD satellite code */
/*     CNIDVL     I   Center ID NAIF code */
/*     SGIDVL     I   Segment identifier */
/*     HANDLE     I   Handle of an SPK file open for writing. */

/* $ Detailed_Input */

/*     INPFN       is the name of input file containing the NORAD */
/*                 "two-line element sets" */

/*     FRNMVL      is the reference frame that output states are */
/*                 referenced to. It must be 'J2000'. */

/*     OBIDVL      is the NORAD code of the object whose states */
/*                 are to be recorded in an SPK file. */

/*     CNIDVL      is the NAIF ID for the center body. It must be 399 */
/*                 corresponding to Earth. */

/*     SGIDVL      is identifier of segment stored in output file. */

/*     HANDLE      is the file handle of an SPK file that has been */
/*                 opened for writing. */

/* $ Detailed_Output */

/*     None.       The data input is stored in an SPK segment in the */
/*                 DAF connected to the input HANDLE. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1) If the center body of the motion is not the Earth, then */
/*        the error 'SPICE(INCONSISTCENTERID)' will be signalled. */

/*     2) If the reference frame is not 'J2000', then the error */
/*        'SPICE(INCONSISTFRAME)' will be signalled. */

/*     3) If code of requested space object is not found in the */
/*        input file, then the error 'SPICE(NOTLEDATAFOROBJECT)' */
/*        will be signalled. */

/*     4) If second line of two-line element records does not exist, */
/*        then the error 'SPICE(NOTEXISTSECONDLINE)' will be signalled. */

/*     5) If second line of two-line element record contains incorrect */
/*        object code, then the error 'SPICE(INCONSISTSECONDLINE)' */
/*        will be signalled. */

/*     6) If any one of the required geophysical constants was not */
/*        found in the POOL, then the error SPICE(MISSINGGEOCONSTS) */
/*        will be signalled. */

/* $ Files */

/*     This routine read text data from the input data file INPFN */
/*     containing two-line element set file in standard text format. */

/*     Leapsecond Kernel (LSK) file must be loaded before running */
/*     this routine. */

/*     A geophysical constants file for the Earth must be loaded */
/*     before runnung this routine. */

/*        The geophysical constants kernel should contain */
/*        the following variables: */

/*        BODY399_J2 --- J2 gravitational harmonic for earth */
/*        BODY399_J3 --- J3 gravitational harmonic for earth */
/*        BODY399_J4 --- J4 gravitational harmonic for earth */
/*        BODY399_KE --- Square root of the GM for earth where GM */
/*                       is expressed in earth radii cubed */
/*                       per minutes squared */
/*        BODY399_ER --- Equatorial radius of the earth in km */
/*        BODY399_S0 --- Low altitude bound for atmospheric model in km */
/*        BODY399_Q0 --- High altitude bound for atmospheric model in km */
/*        BODY399_AE --- Distance units/earth radius (normally 1). */


/*     The program creates SPK file connected to HANDLE. */
/*     This file must be opened for writing before running this */
/*     routine. */

/* $ Particulars */

/*     None. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     N.G. Khavenson (IKI RAS, Russia) */

/* $ Version */

/* -    Version 2.1.0, 18-MAR-2005 (EDW). */

/*        Corrected a logic error that prevent processing of TLEs */
/*        for vehicles with ID codes four characters or shorter. */

/* -    Version 2.0.0, 06-APR-2004 (EDW). */

/*        Modified algorithm to call ZZGETELM, a modified version of */
/*        GETELM. ZZGETELM returns a flag and explanation string */
/*        for any TLE processing error. */

/*        Correct a typo: */

/*           ENDT   = EPOCHS(I) */

/*        to */

/*           ENDT   = EPOCHS(PUT) */

/*        This type could cause a TLE segment summary to report the */
/*        wrong end time for the segment data. */

/* -    Version 1.0.1, 27-JAN-2000 (BVS). */

/*        Added a little better error message for the case when */
/*        geophysical constants weren't loaded. */

/* -    Version 1.0.0, 22-NOV-1999 (NGK). */

/*        Initial release based on the  MKSPK10 utility program */
/*        Version 1.0.0, 18-JUL-1997 (WLT) */

/* -& */
/* $ Index_Entries */

/*     Creates an SPK file from a file containing the NORAD */
/*     "two-line element sets. */

/* -& */

/*     SPICELIB functions */


/*     Local variables */


/*     Size WDSIZE, LINLEN, FILSIZE are defined in include file. */



/*     The following integers are used to mark the various */
/*     slots in the array for geophysical constants. */

/*        J2 */
/*        J3 */
/*        J4 */
/*        KE */
/*        QO */
/*        SO */
/*        ER */
/*        AE */


/*     An enumeration of the various components of the */
/*     elements array---ELEMS */

/*        KNDT20 */
/*        KNDD60 */
/*        KBSTAR */
/*        KINCL */
/*        KNODE0 */
/*        KECC */
/*        KOMEGA */
/*        KMO */
/*        KNO */


/*     The next set of parameters govern how many items will */
/*     go into a segment. */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("TLE2SPK", (ftnlen)7);
    }

/*     Get filename of output file. */

    dafhfn_(handle, outfn, (ftnlen)255);

/*     Check center ID. */

    if (*cnidvl != 399) {

/*        The center body is not the Earth. Complain. KCENID is defined */
/*        in include file. */

	dafcls_(handle);
	delfil_(outfn, (ftnlen)255);
	setmsg_("Processing of two-line element data requires the setup file"
		" keyword '#' to be set to #.", (ftnlen)87);
	errint_("#", &c__399, (ftnlen)1);
	errch_("#", "CENTER_ID", (ftnlen)1, (ftnlen)9);
	sigerr_("SPICE(INCONSISTCENTERID)", (ftnlen)24);
    }

/*     Check reference frame. */

    namfrm_(frnmvl, &frcode, frnmvl_len);
    namfrm_("J2000", &framid, (ftnlen)5);
    if (frcode != framid) {

/*        The frame is not J2000. Complain. KRFRNM is defined in include */
/*        file. */

	dafcls_(handle);
	delfil_(outfn, (ftnlen)255);
	setmsg_("Processing of two-line element data requires the setup file"
		" keyword '#' to be set to '#'.", (ftnlen)89);
	errch_("#", "J2000", (ftnlen)1, (ftnlen)5);
	errch_("#", "REF_FRAME_NAME", (ftnlen)1, (ftnlen)14);
	sigerr_("SPICE(INCONSISTFRAME)", (ftnlen)21);
    }

/*     Convert object ID to string code that allows to chose the object */
/*     data from input file. */

    intstr_(obidvl, code, (ftnlen)32);

/*     Initialize CHOSE1 and CHOSE2 to seven characters, with */
/*     the TLE line ID as the first character. */

    s_copy(chose1, "1", (ftnlen)32, (ftnlen)1);
    s_copy(chose2, "2", (ftnlen)32, (ftnlen)1);

/*     Write the ID string CODE to CHOSE1 and CHOSE2 so that the */
/*     last RTRIM(CODE) characters of the CHOSE1(1:7) and */
/*     CHOSE2(1:7) contain the code. */

    i__1 = 7 - rtrim_(code, (ftnlen)32);
    s_copy(chose1 + i__1, code, 7 - i__1, rtrim_(code, (ftnlen)32));
    i__1 = 7 - rtrim_(code, (ftnlen)32);
    s_copy(chose2 + i__1, code, 7 - i__1, rtrim_(code, (ftnlen)32));

/*     Form standard negative object ID. */

    object = -100000 - *obidvl;

/*     Read first line from TLE data file */

    rdtext_(inpfn, lines, &eof, inpfn_len, (ftnlen)512);

/*     Check the NORAD ID value matches Find the first requested */
/*     line of the TLE file. */

    while(s_cmp(lines, chose1, (ftnlen)7, (ftnlen)7) != 0 && ! eof) {
	rdtext_(inpfn, lines, &eof, inpfn_len, (ftnlen)512);
    }
    if (eof) {

/*        Requested data did not found. Complain. */

	dafcls_(handle);
	delfil_(outfn, (ftnlen)255);
	setmsg_("No data for the object with NORAD ID # were found in the in"
		"put two-line element file.", (ftnlen)85);
	errint_("#", obidvl, (ftnlen)1);
	sigerr_("SPICE(NOTLEDATAFOROBJECT)", (ftnlen)25);
    }

/*     Check whether all geophysical constants needed for the SGP4 */
/*     propagation model are present in the kernel pool. */

    s_copy(geolst, " ", (ftnlen)255, (ftnlen)1);
    dtpool_("BODY399_J2", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_J2,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_J3", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_J3,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_J4", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_J4,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_KE", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_KE,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_QO", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_QO,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_SO", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_SO,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_ER", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_ER,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    dtpool_("BODY399_AE", &found, &n, type__, (ftnlen)10, (ftnlen)1);
    if (! found || n != 1 || *(unsigned char *)type__ != 'N') {
	suffix_(" BODY399_AE,", &c__0, geolst, (ftnlen)12, (ftnlen)255);
    }
    if (s_cmp(geolst, " ", (ftnlen)255, (ftnlen)1) != 0) {

/*        On of the geophysical constants was not found or wasn't */
/*        of the right type. Complain. */

	dafcls_(handle);
	delfil_(outfn, (ftnlen)255);
	setmsg_("The following geophysical constants were not provided to th"
		"e program or their values were not scalar DP numbers: #. Che"
		"ck whether the name of a geophysical constants PCK file was "
		"provided in the setup file keyword '#', and if so, whether t"
		"he file contains appropriate values for the keywords listed "
		"above. ", (ftnlen)306);
	errch_("#", geolst, (ftnlen)1, rtrim_(geolst, (ftnlen)255) - 1);
	errch_("#", "PCK_FILE", (ftnlen)1, (ftnlen)8);
	sigerr_("SPICE(MISSINGGEOCONSTS)", (ftnlen)23);
    }

/*     Fetch the geophysical constants needed for the SGP4 propagation */
/*     model from the kernel pool. */

    bodvar_(&c__399, "J2", &n, geophs, (ftnlen)2);
    bodvar_(&c__399, "J3", &n, &geophs[1], (ftnlen)2);
    bodvar_(&c__399, "J4", &n, &geophs[2], (ftnlen)2);
    bodvar_(&c__399, "KE", &n, &geophs[3], (ftnlen)2);
    bodvar_(&c__399, "QO", &n, &geophs[4], (ftnlen)2);
    bodvar_(&c__399, "SO", &n, &geophs[5], (ftnlen)2);
    bodvar_(&c__399, "ER", &n, &geophs[6], (ftnlen)2);
    bodvar_(&c__399, "AE", &n, &geophs[7], (ftnlen)2);

/*     Read next line of found TLE data. */

    rdtext_(inpfn, lines + 512, &eof, inpfn_len, (ftnlen)512);
    if (eof) {

/*        Next line does not exist. Complain. */

	dafcls_(handle);
	delfil_(outfn, (ftnlen)255);
	setmsg_("Second line of two-line element data for object # does not "
		"exist", (ftnlen)64);
	errint_("#", obidvl, (ftnlen)1);
	sigerr_("SPICE(NOTEXISTSECONDLINE)", (ftnlen)25);
    }

/*     Track the number of TLE's read, I. */

    i__ = 0;
    j = -9;
    fmodel = TRUE_;
    while(s_cmp(lines, chose1, (ftnlen)7, (ftnlen)7) == 0 && ! eof) {
	++i__;
	j += 10;

/*        Try to process the TLE. If an error occurs during processing, */
/*        ZZGETELM will have value .FALSE. and ERROR will contain a */
/*        description of the error. */

	zzgetelm_(&c__1950, lines, &epochs[(i__1 = i__ - 1) < 5001 && 0 <= 
		i__1 ? i__1 : s_rnge("epochs", i__1, "tle2spk_", (ftnlen)608)]
		, &elems[(i__2 = j - 1) < 50010 && 0 <= i__2 ? i__2 : s_rnge(
		"elems", i__2, "tle2spk_", (ftnlen)608)], &ok, error + 512, (
		ftnlen)512, (ftnlen)512);

/*        If we find an error, signal a standard SPICE error. */

	if (! ok) {
	    dafcls_(handle);
	    delfil_(outfn, (ftnlen)255);
	    setmsg_("Error in TLE set #1. #2", (ftnlen)23);
	    errint_("#1", &i__, (ftnlen)2);
	    errch_("#2", error + 512, (ftnlen)2, (ftnlen)512);
	    sigerr_("SPICE(BADTLE)", (ftnlen)13);
	}

/*        If we fill up the EPOCHS buffer, then we need to complete this */
/*        segment. If the TLE read failed, no reason to evaluate this */
/*        block. Wait for the next iteration of the loop. */

	if (i__ == 5000 && ok) {

/*        It may occasionally happen that the epochs may are out */
/*        of order and may contain duplicate entries.  We need to */
/*        sort them, shift duplicates to the end of the EPOCHS array */
/*        and then rearrange the elements.  Getting the correct */
/*        order is easy. Just get an order vector. */

	    orderd_(epochs, &c__5000, iorder);

/*           Re-arrange the order vector so that duplicates are placed */
/*           at the end of the array. */

	    trash = 5000;
	    put = 1;
	    ordvec[(i__1 = put - 1) < 5000 && 0 <= i__1 ? i__1 : s_rnge("ord"
		    "vec", i__1, "tle2spk_", (ftnlen)647)] = iorder[0];
	    for (k = 2; k <= 5000; ++k) {
		if (epochs[(i__2 = ordvec[(i__1 = put - 1) < 5000 && 0 <= 
			i__1 ? i__1 : s_rnge("ordvec", i__1, "tle2spk_", (
			ftnlen)651)] - 1) < 5001 && 0 <= i__2 ? i__2 : s_rnge(
			"epochs", i__2, "tle2spk_", (ftnlen)651)] == epochs[(
			i__4 = iorder[(i__3 = k - 1) < 5000 && 0 <= i__3 ? 
			i__3 : s_rnge("iorder", i__3, "tle2spk_", (ftnlen)651)
			] - 1) < 5001 && 0 <= i__4 ? i__4 : s_rnge("epochs", 
			i__4, "tle2spk_", (ftnlen)651)]) {
		    ordvec[(i__1 = trash - 1) < 5000 && 0 <= i__1 ? i__1 : 
			    s_rnge("ordvec", i__1, "tle2spk_", (ftnlen)653)] =
			     iorder[(i__2 = k - 1) < 5000 && 0 <= i__2 ? i__2 
			    : s_rnge("iorder", i__2, "tle2spk_", (ftnlen)653)]
			    ;
		    --trash;
		} else {
		    ++put;
		    ordvec[(i__1 = put - 1) < 5000 && 0 <= i__1 ? i__1 : 
			    s_rnge("ordvec", i__1, "tle2spk_", (ftnlen)657)] =
			     iorder[(i__2 = k - 1) < 5000 && 0 <= i__2 ? i__2 
			    : s_rnge("iorder", i__2, "tle2spk_", (ftnlen)657)]
			    ;
		}
	    }
	    reordd_(ordvec, &c__5000, epochs);
	    reorbd_(ordvec, &c__5000, &c__10, elems);
	    if (fmodel) {

/*              We shall allow propagation backwards and forward by */
/*              one half day. */

		begint = epochs[0] - spd_() / 2.;
		fmodel = FALSE_;
	    } else {
		begint = epochs[0];
	    }

/*           Assign the final epoch time. */

	    endt = epochs[(i__1 = put - 1) < 5001 && 0 <= i__1 ? i__1 : 
		    s_rnge("epochs", i__1, "tle2spk_", (ftnlen)680)];

/*           Report that we write next SPK segment. */

	    tostdo_(" ", (ftnlen)1);
	    tostdo_("Buffer is filled, writing SPK segment...", (ftnlen)40);
	    spkw10_(handle, &object, cnidvl, frnmvl, &begint, &endt, sgidvl, 
		    geophs, &put, elems, epochs, frnmvl_len, sgidvl_len);

/*           We will continue processing of the input data and therefore */
/*           we need to achieve continuity of the data between segments. */
/*           To do that, we move one record from the end of the buffer */
/*           to the beginning of the buffer and reset all indexes */
/*           correspondingly. */

	    epochs[0] = epochs[(i__1 = put - 1) < 5001 && 0 <= i__1 ? i__1 : 
		    s_rnge("epochs", i__1, "tle2spk_", (ftnlen)699)];
	    for (i__ = 1; i__ <= 10; ++i__) {
		elems[(i__1 = i__ - 1) < 50010 && 0 <= i__1 ? i__1 : s_rnge(
			"elems", i__1, "tle2spk_", (ftnlen)702)] = elems[(
			i__2 = (put - 1) * 10 + i__ - 1) < 50010 && 0 <= i__2 
			? i__2 : s_rnge("elems", i__2, "tle2spk_", (ftnlen)
			702)];
	    }
	    i__ = 1;
	    j = 1;
	}

/*        Try to read the next TLE set. */

	rdtext_(inpfn, lines, &eof, inpfn_len, (ftnlen)512);
	rdtext_(inpfn, lines + 512, &eof, inpfn_len, (ftnlen)512);
    }

/*     We either ran out of file, or we ran out of elements. */
/*     In either case if there are any remaining element sets */
/*     to be written, now is the time to do it. */

    if (i__ > 1) {

/*        It may occasionally happen that the epochs may are out */
/*        of order and may contain duplicate entries.  We need to */
/*        sort them, shift duplicates to the end of the EPOCHS array */
/*        and then rearrange the elements.  Getting the correct */
/*        order is easy. Just get an order vector. */

	orderd_(epochs, &i__, iorder);

/*        Re-arrange the order vector so that duplicates are placed */
/*        at the end of the array. */

	trash = i__;
	put = 1;
	ordvec[(i__1 = put - 1) < 5000 && 0 <= i__1 ? i__1 : s_rnge("ordvec", 
		i__1, "tle2spk_", (ftnlen)740)] = iorder[0];
	i__1 = i__;
	for (k = 2; k <= i__1; ++k) {
	    if (epochs[(i__3 = ordvec[(i__2 = put - 1) < 5000 && 0 <= i__2 ? 
		    i__2 : s_rnge("ordvec", i__2, "tle2spk_", (ftnlen)744)] - 
		    1) < 5001 && 0 <= i__3 ? i__3 : s_rnge("epochs", i__3, 
		    "tle2spk_", (ftnlen)744)] == epochs[(i__5 = iorder[(i__4 =
		     k - 1) < 5000 && 0 <= i__4 ? i__4 : s_rnge("iorder", 
		    i__4, "tle2spk_", (ftnlen)744)] - 1) < 5001 && 0 <= i__5 ?
		     i__5 : s_rnge("epochs", i__5, "tle2spk_", (ftnlen)744)]) 
		    {
		ordvec[(i__2 = trash - 1) < 5000 && 0 <= i__2 ? i__2 : s_rnge(
			"ordvec", i__2, "tle2spk_", (ftnlen)746)] = iorder[(
			i__3 = k - 1) < 5000 && 0 <= i__3 ? i__3 : s_rnge(
			"iorder", i__3, "tle2spk_", (ftnlen)746)];
		--trash;
	    } else {
		++put;
		ordvec[(i__2 = put - 1) < 5000 && 0 <= i__2 ? i__2 : s_rnge(
			"ordvec", i__2, "tle2spk_", (ftnlen)750)] = iorder[(
			i__3 = k - 1) < 5000 && 0 <= i__3 ? i__3 : s_rnge(
			"iorder", i__3, "tle2spk_", (ftnlen)750)];
	    }
	}
	if (isordv_(ordvec, &i__)) {
	    s_copy(lines, "Found # duplicates", (ftnlen)512, (ftnlen)18);
	    i__1 = i__ - trash;
	    repmi_(lines, "#", &i__1, lines, (ftnlen)512, (ftnlen)1, (ftnlen)
		    512);
	    tostdo_(" ", (ftnlen)1);
	    tostdo_("The order vector is ready to go. ", (ftnlen)33);
	    tostdo_(lines, (ftnlen)512);
	    tostdo_(" ", (ftnlen)1);
	} else {
	    tostdo_(" ", (ftnlen)1);
	    tostdo_("A bug exists in the order vector ", (ftnlen)33);
	    tostdo_("construction code.", (ftnlen)18);
	    tostdo_(" ", (ftnlen)1);
	}
	reordd_(ordvec, &i__, epochs);
	reorbd_(ordvec, &i__, &c__10, elems);
	if (fmodel) {
	    begint = epochs[0] - spd_() / 2.;
	    fmodel = FALSE_;
	} else {
	    begint = epochs[0];
	}

/*        Since this is the last segment we shall create we */
/*        will allow the state to be propagated forward beyond */
/*        the last epoch. */

	endt = epochs[(i__1 = put - 1) < 5001 && 0 <= i__1 ? i__1 : s_rnge(
		"epochs", i__1, "tle2spk_", (ftnlen)787)] + spd_() / 2.;
	tostdo_(" ", (ftnlen)1);
	tostdo_("Writing  SPK segment...", (ftnlen)23);
	spkw10_(handle, &object, cnidvl, frnmvl, &begint, &endt, sgidvl, 
		geophs, &put, elems, epochs, frnmvl_len, sgidvl_len);
    } else {
	put = 1;
	if (fmodel) {
	    begint = epochs[0] - spd_() / 2.;
	    fmodel = FALSE_;
	} else {
	    begint = epochs[0];
	}
	endt = epochs[(i__1 = put - 1) < 5001 && 0 <= i__1 ? i__1 : s_rnge(
		"epochs", i__1, "tle2spk_", (ftnlen)807)] + spd_() / 2.;
	tostdo_(" ", (ftnlen)1);
	tostdo_("Writing  SPK segment...", (ftnlen)23);
	spkw10_(handle, &object, cnidvl, frnmvl, &begint, &endt, sgidvl, 
		geophs, &put, elems, epochs, frnmvl_len, sgidvl_len);
    }
    cltext_(inpfn, inpfn_len);
    chkout_("TLE2SPK", (ftnlen)7);
    return 0;
} /* tle2spk_ */

