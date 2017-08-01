/* ckw02.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static integer c__6 = 6;
static integer c__4 = 4;
static integer c__3 = 3;
static integer c__1 = 1;

/* $Procedure  CKW02 ( C-Kernel, write segment to C-kernel, data type 2 ) */
/* Subroutine */ int ckw02_(integer *handle, doublereal *begtim, doublereal *
	endtim, integer *inst, char *ref, char *segid, integer *nrec, 
	doublereal *start, doublereal *stop, doublereal *quats, doublereal *
	avvs, doublereal *rates, ftnlen ref_len, ftnlen segid_len)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Local variables */
    integer ndir, i__;
    doublereal l;
    extern /* Subroutine */ int chkin_(char *, ftnlen), dafps_(integer *, 
	    integer *, doublereal *, integer *, doublereal *);
    doublereal descr[5];
    extern /* Subroutine */ int errch_(char *, char *, ftnlen, ftnlen);
    integer index, value;
    extern /* Subroutine */ int errdp_(char *, doublereal *, ftnlen), dafada_(
	    doublereal *, integer *), dafbna_(integer *, doublereal *, char *,
	     ftnlen), dafena_(void);
    extern logical failed_(void);
    integer refcod;
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen);
    extern integer lastnb_(char *, ftnlen);
    doublereal dirent;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen);
    extern logical return_(void);
    doublereal dcd[2];
    integer icd[6];

/* $ Abstract */

/*     Write a type 2 segment to a C-kernel. */

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

/*     CK */
/*     DAF */
/*     SCLK */

/* $ Keywords */

/*     POINTING */
/*     UTILITY */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     HANDLE     I   Handle of an open CK file. */
/*     BEGTIM     I   The beginning encoded SCLK of the segment. */
/*     ENDTIM     I   The ending encoded SCLK of the segment. */
/*     INST       I   The NAIF instrument ID code. */
/*     REF        I   The reference frame of the segment. */
/*     SEGID      I   Segment identifier. */
/*     NREC       I   Number of pointing records. */
/*     START      I   Encoded SCLK interval start times. */
/*     STOP       I   Encoded SCLK interval stop times. */
/*     QUATS      I   Quaternions representing instrument pointing. */
/*     AVVS       I   Angular velocity vectors. */
/*     RATES      I   Number of seconds per tick for each interval. */

/* $ Detailed_Input */

/*     HANDLE     is the handle of the CK file to which the segment will */
/*                be written. The file must have been opened with write */
/*                access. */

/*     BEGTIM     is the beginning encoded SCLK time of the segment. This */
/*                value should be less than or equal to the first START */
/*                time in the segment. */

/*     ENDTIM     is the encoded SCLK time at which the segment ends. */
/*                This value should be greater than or equal to the last */
/*                STOP time in the segment. */

/*     INST       is the NAIF integer ID code for the instrument. */

/*     REF        is a character string that specifies the */
/*                reference frame of the segment. This should be one of */
/*                the frames supported by the SPICELIB routine NAMFRM */
/*                which is an entry point to FRAMEX. */

/*     SEGID      is the segment identifier.  A CK segment identifier may */
/*                contain up to 40 characters. */

/*     NREC       is the number of pointing intervals that will be */
/*                written to the segment. */

/*     START      are the start times of each interval in encoded */
/*                spacecraft clock. These times must be strictly */
/*                increasing. */

/*     STOP       are the stop times of each interval in encoded */
/*                spacecraft clock. These times must be greater than */
/*                the START times that they correspond to but less */
/*                than or equal to the START time of the next interval. */

/*     QUATS      are the quaternions representing the C-matrices */
/*                associated with the start times of each interval. */

/*     AVVS       are the angular velocity vectors for each interval. */

/*     RATES      are the number of seconds per encoded spacecraft clock */
/*                tick for each interval. */

/*                In most applications this value will be the same for */
/*                each interval within a segment.  For example, when */
/*                constructing a predict C-kernel for Mars Observer, the */
/*                rate would be 1/256 for each interval since this is */
/*                the smallest time unit expressible by the MO clock. The */
/*                nominal seconds per tick rates for Galileo and Voyager */
/*                are 1/120 and 0.06 respectively. */

/* $ Detailed_Output */

/*     None.  See Files section. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)  If HANDLE is not the handle of a C-kernel opened for writing */
/*         the error will be diagnosed by routines called by this */
/*         routine. */

/*     2)  If SEGID is more than 40 characters long, the error */
/*         SPICE(SEGIDTOOLONG) is signalled. */

/*     3)  If SEGID contains any nonprintable characters, the error */
/*         SPICE(NONPRINTABLECHARS) is signalled. */

/*     4)  If the first START time is negative, the error */
/*         SPICE(INVALIDSCLKTIME) is signalled. If any of the subsequent */
/*         START times are negative the error SPICE(TIMESOUTOFORDER) */
/*         will be signalled. */

/*     5)  If any of the STOP times are negative, the error */
/*         SPICE(DEGENERATEINTERVAL) is signalled. */

/*     6)  If the STOP time of any of the intervals is less than or equal */
/*         to the START time, the error SPICE(DEGENERATEINTERVAL) is */
/*         signalled. */

/*     7)  If the START times are not strictly increasing, the */
/*         error SPICE(TIMESOUTOFORDER) is signalled. */

/*     8)  If the STOP time of one interval is greater than the START */
/*         time of the next interval, the error SPICE(BADSTOPTIME) */
/*         is signalled. */

/*     9)  If BEGTIM is greater than START(1) or ENDTIM is less than */
/*         STOP(NREC), the error SPICE(INVALIDDESCRTIME) is */
/*         signalled. */

/*    10)  If the name of the reference frame is not one of those */
/*         supported by the routine NAMFRM, the error */
/*         SPICE(INVALIDREFFRAME) is signalled. */

/*    11)  If NREC, the number of pointing records, is less than or */
/*         equal to 0, the error SPICE(INVALIDNUMRECS) is signalled. */

/*    12)  If the squared length of any quaternion differes from 1 */
/*         by more than 1.0D-2, the error SPICE(NONUNITQUATERNION) is */
/*         signalled. */

/* $ Files */

/*     This routine adds a type 2 segment to a C-kernel.  The C-kernel */
/*     may be either a new one or an existing one opened for writing. */

/* $ Particulars */

/*     For a detailed description of a type 2 CK segment please see the */
/*     CK Required Reading. */

/*     This routine relieves the user from performing the repetitive */
/*     calls to the DAF routines necessary to construct a CK segment. */

/* $ Examples */

/*  C */
/*  C     This example writes a predict type 2 C-kernel segment for */
/*  C     the Mars Observer spacecraft bus to a previously opened CK file */
/*  C     attached to HANDLE. */

/*  C */
/*  C     Assume arrays of quaternions, angular velocities, and interval */
/*  C     start and stop times are produced elsewhere. */
/*  C */
/*        . */
/*        . */
/*        . */

/*  C */
/*  C     The nominal number of seconds in a tick for MO is 1/256 */
/*  C */
/*        SECTIK = 1.D0 / 256.D0 */

/*        DO I = 1, NREC */
/*           RATE(I) = SECTIK */
/*        END DO */

/*  C */
/*  C     The subroutine CKW02 needs the following components of the */
/*  C     segment descriptor: */
/*  C */
/*  C        1) SCLK limits of the segment. */
/*  C        2) Instrument code. */
/*  C        3) Reference frame. */

/*        BEGTIM = START (    1 ) */
/*        ENDTIM = STOP  ( NREC ) */

/*        INST  = -94000 */
/*        REF   = 'J2000' */

/*        SEGID = 'MO PREDICT SEG TYPE 2' */

/*  C */
/*  C     Write the segment. */
/*  C */
/*        CALL CKW02 ( HANDLE, BEGTIM, ENDTIM, INST, REF, SEGID, */
/*       .             NREC,   START,  STOP,   QUAT, AVV, RATES  ) */


/* $ Restrictions */

/*     None. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */
/*     K.R. Gehringer  (JPL) */
/*     J.M. Lynch      (JPL) */

/* $ Version */

/* -    SPICELIB Version 2.1.0, 22-FEB-1999 (WLT) */

/*        Added check to make sure that all quaternions are unit */
/*        length to single precision. */

/* -    SPICELIB Version 2.0.0, 28-DEC-1993 (WLT) */

/*        The routine was upgraded to support non-inertial reference */
/*        frames. */

/* -    SPICELIB Version 1.1.1, 05-SEP-1993 (KRG) */

/*        Removed all references to a specific method of opening the CK */
/*        file in the $ Brief_I/O, $ Detailed_Input, $ Exceptions, */
/*        $ Files, and $ Examples sections of the header. It is assumed */
/*        that a person using this routine has some knowledge of the DAF */
/*        system and the methods for obtaining file handles. */

/* -    SPICELIB Version 1.1.0, 25-NOV-1992 (JML) */

/*        1) If the number of pointing records is not positive an error */
/*           is now signalled. */

/*        2) FAILED is checked after the call to DAFBNA. */

/*        3) The variables HLDBEG and HLDEND were removed from the loop */
/*           where the interval start and stop times are tested. */

/* -    SPICELIB Version 1.0.1, 10-MAR-1992 (WLT) */

/*        Comment section for permuted index source lines was added */
/*        following the header. */

/* -    SPICELIB Version 1.0.0, 30-AUG-1991 (JML) */

/* -& */
/* $ Index_Entries */

/*     write ck type_2 pointing data segment */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 2.1.0, 22-FEB-1999 (WLT) */

/*        Added check to make sure that all quaternions are unit */
/*        length to single precision. */

/* -    SPICELIB Version 1.1.1, 05-SEP-1993 (KRG) */

/*        Removed all references to a specific method of opening the CK */
/*        file in the $ Brief_I/O, $ Detailed_Input, $ Exceptions, */
/*        $ Files, and $ Examples sections of the header. It is assumed */
/*        that a person using this routine has some knowledge of the DAF */
/*        system and the methods for obtaining file handles. */

/* -    SPICELIB Version 1.1.0, 25-NOV-1992 (JML) */

/*        1) If the number of pointing records is not positive an error */
/*           is now signalled. */

/*        2) FAILED is checked after the call to DAFBNA. */

/*        3) The variables HLDBEG and HLDEND were removed from the loop */
/*           where the interval start and stop times are tested. */

/* -    SPICELIB Version 1.0.1, 10-MAR-1992 (WLT) */

/*        Comment section for permuted index source lines was added */
/*        following the header. */

/* -    SPICELIB Version 1.0.0, 30-AUG-1991 (JML) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */

/*     SIDLEN   is the maximum number of characters allowed in a CK */
/*              segment identifier. */

/*     NDC      is the size of a packed CK segment descriptor. */

/*     ND       is the number of double precision components in a CK */
/*              segment descriptor. */

/*     NI       is the number of integer components in a CK segment */
/*              descriptor. */

/*     DTYPE    is the data type of the segment that this routine */
/*              operates on. */

/*     FPRINT   is the integer value of the first printable ASCII */
/*              character. */

/*     LPRINT   is the integer value of the last printable ASCII */
/*              character. */



/*     Local variables */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    } else {
	chkin_("CKW02", (ftnlen)5);
    }

/*     The first thing that we will do is create the segment descriptor. */

/*     The structure of the segment descriptor is as follows. */

/*           DCD( 1 ) and DCD( 2 ) -- SCLK limits of the segment. */
/*           ICD( 1 )              -- Instrument code. */
/*           ICD( 2 )              -- Reference frame ID. */
/*           ICD( 3 )              -- Data type of the segment. */
/*           ICD( 4 )              -- Angular rates flag. */
/*           ICD( 5 )              -- Beginning address of the segment. */
/*           ICD( 6 )              -- Ending address of the segment. */


/*     Make sure that there is a positive number of pointing records. */

    if (*nrec <= 0) {
	setmsg_("# is an invalid number of pointing instances for type 2.", (
		ftnlen)56);
	errint_("#", nrec, (ftnlen)1);
	sigerr_("SPICE(INVALIDNUMREC)", (ftnlen)20);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }

/*     Check that the SCLK bounds on the segment are reasonable. */

    if (*begtim > start[0]) {
	setmsg_("The first d.p. component of the descriptor is invalid.  DCD"
		"(1) = # and START(1) = # ", (ftnlen)84);
	errdp_("#", begtim, (ftnlen)1);
	errdp_("#", start, (ftnlen)1);
	sigerr_("SPICE(INVALIDDESCRTIME)", (ftnlen)23);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }
    if (*endtim < stop[*nrec - 1]) {
	setmsg_("The second d.p. component of the descriptor is invalid.  DC"
		"D(2) = # and STOP(NREC) = # ", (ftnlen)87);
	errdp_("#", endtim, (ftnlen)1);
	errdp_("#", &stop[*nrec - 1], (ftnlen)1);
	sigerr_("SPICE(INVALIDDESCRTIME)", (ftnlen)23);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }
    dcd[0] = *begtim;
    dcd[1] = *endtim;

/*     Get the NAIF integer code for the reference frame. */

    namfrm_(ref, &refcod, ref_len);
    if (refcod == 0) {
	setmsg_("The reference frame # is not supported.", (ftnlen)39);
	errch_("#", ref, (ftnlen)1, ref_len);
	sigerr_("SPICE(INVALIDREFFRAME)", (ftnlen)22);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }

/*     Assign values to the integer components of the segment descriptor. */
/*     By definition data type two must have angular velocity. */

    icd[0] = *inst;
    icd[1] = refcod;
    icd[2] = 2;
    icd[3] = 1;

/*     Now pack the segment descriptor. */

    dafps_(&c__2, &c__6, dcd, icd, descr);

/*     Now check that all the characters in the segid can be printed. */

    i__1 = lastnb_(segid, segid_len);
    for (i__ = 1; i__ <= i__1; ++i__) {
	value = *(unsigned char *)&segid[i__ - 1];
	if (value < 32 || value > 126) {
	    setmsg_("The segment identifier contains nonprintable characters",
		     (ftnlen)55);
	    sigerr_("SPICE(NONPRINTABLECHARS)", (ftnlen)24);
	    chkout_("CKW02", (ftnlen)5);
	    return 0;
	}
    }

/*     Also check to see if the segment identifier is too long. */

    if (lastnb_(segid, segid_len) > 40) {
	setmsg_("Segment identifier contains more than 40 characters.", (
		ftnlen)52);
	sigerr_("SPICE(SEGIDTOOLONG)", (ftnlen)19);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }

/*     Now check that the START and STOP times on the intervals */
/*     make sense. Three checks will be performed on each interval: */

/*        1)  Check that the STOP time is greater than the START time. */

/*        2)  Check that the START times are strictly increasing. */

/*        3)  Check that the START time is greater than or equal to the */
/*            STOP time from the previous interval. */

/*     For the first interval also make sure that the START time is */
/*     nonnegative. */

    if (start[0] < 0.) {
	setmsg_("The first START time: # is negative.", (ftnlen)36);
	errdp_("#", start, (ftnlen)1);
	sigerr_("SPICE(INVALIDSCLKTIME)", (ftnlen)22);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }
    if (stop[0] <= start[0]) {
	setmsg_("The STOP time is less than or equal to the START time for i"
		"nterval number 1. START time is # and STOP time is #.", (
		ftnlen)112);
	errdp_("#", start, (ftnlen)1);
	errdp_("#", stop, (ftnlen)1);
	sigerr_("SPICE(DEGENERATEINTERVAL)", (ftnlen)25);
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }
    i__1 = *nrec;
    for (i__ = 2; i__ <= i__1; ++i__) {
	if (stop[i__ - 1] <= start[i__ - 1]) {
	    setmsg_("The STOP time is less than or equal to the START time f"
		    "or interval number #. START time is # and STOP time is #."
		    , (ftnlen)112);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &start[i__ - 1], (ftnlen)1);
	    errdp_("#", &stop[i__ - 1], (ftnlen)1);
	    sigerr_("SPICE(DEGENERATEINTERVAL)", (ftnlen)25);
	    chkout_("CKW02", (ftnlen)5);
	    return 0;
	}
	if (start[i__ - 1] <= start[i__ - 2]) {
	    setmsg_("The START times are not strictly increasing.  START(#) "
		    "= # and START(#) = #.", (ftnlen)76);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &start[i__ - 1], (ftnlen)1);
	    i__2 = i__ - 1;
	    errint_("#", &i__2, (ftnlen)1);
	    errdp_("#", &start[i__ - 2], (ftnlen)1);
	    sigerr_("SPICE(TIMESOUTOFORDER)", (ftnlen)22);
	    chkout_("CKW02", (ftnlen)5);
	    return 0;
	}
	if (stop[i__ - 2] > start[i__ - 1]) {
	    setmsg_("The STOP time for interval # is greater than the follow"
		    "ing START time. STOP(#) = # and START(#) = #.", (ftnlen)
		    100);
	    i__2 = i__ - 1;
	    errint_("#", &i__2, (ftnlen)1);
	    i__2 = i__ - 1;
	    errint_("#", &i__2, (ftnlen)1);
	    errdp_("#", &stop[i__ - 2], (ftnlen)1);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &start[i__ - 1], (ftnlen)1);
	    sigerr_("SPICE(BADSTOPTIME)", (ftnlen)18);
	    chkout_("CKW02", (ftnlen)5);
	    return 0;
	}
    }

/*     Make sure that the quaternions all have unit length. */

    i__1 = *nrec;
    for (i__ = 1; i__ <= i__1; ++i__) {
	l = quats[(i__ << 2) - 4] * quats[(i__ << 2) - 4] + quats[(i__ << 2) 
		- 3] * quats[(i__ << 2) - 3] + quats[(i__ << 2) - 2] * quats[(
		i__ << 2) - 2] + quats[(i__ << 2) - 1] * quats[(i__ << 2) - 1]
		;

/*        This is only a sanity check.  We make sure that */
/*        we have a unit quaternion to single precision. */

	if ((d__1 = 1. - l, abs(d__1)) > .01) {
	    setmsg_("The #'th quaternion is not a unit quaternion. It's squa"
		    "red length is #. ", (ftnlen)72);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &l, (ftnlen)1);
	    sigerr_("SPICE(NONUNITQUATERNION)", (ftnlen)24);
	    chkout_("CKW02", (ftnlen)5);
	    return 0;
	}
    }

/*     No more checks, begin writing the segment. */

    dafbna_(handle, descr, segid, segid_len);
    if (failed_()) {
	chkout_("CKW02", (ftnlen)5);
	return 0;
    }

/*     Now add the quaternions, angular velocity vectors, and time */
/*     conversion factors for each interval. */

    i__1 = *nrec;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dafada_(&quats[(i__ << 2) - 4], &c__4);
	dafada_(&avvs[i__ * 3 - 3], &c__3);
	dafada_(&rates[i__ - 1], &c__1);
    }

/*     The SCLK start times. */

    dafada_(start, nrec);

/*     The SCLK stop times. */

    dafada_(stop, nrec);

/*     The time tag directory.  The Ith element is defined to be the */
/*     average of the (I*100)th STOP time and the (I*100+1)th START time. */

    ndir = (*nrec - 1) / 100;
    index = 100;
    i__1 = ndir;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dirent = (stop[index - 1] + start[index]) / 2.;
	dafada_(&dirent, &c__1);
	index += 100;
    }

/*     End the segment. */

    dafena_();
    chkout_("CKW02", (ftnlen)5);
    return 0;
} /* ckw02_ */

