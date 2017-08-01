/* ckw03.f -- translated by f2c (version 19980913).
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

/* $Procedure  CKW03 ( C-Kernel, write segment to C-kernel, data type 3 ) */
/* Subroutine */ int ckw03_(integer *handle, doublereal *begtim, doublereal *
	endtim, integer *inst, char *ref, logical *avflag, char *segid, 
	integer *nrec, doublereal *sclkdp, doublereal *quats, doublereal *
	avvs, integer *nints, doublereal *starts, ftnlen ref_len, ftnlen 
	segid_len)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Local variables */
    integer i__;
    doublereal l;
    logical match;
    extern /* Subroutine */ int chkin_(char *, ftnlen), dafps_(integer *, 
	    integer *, doublereal *, integer *, doublereal *);
    doublereal descr[5];
    extern /* Subroutine */ int errch_(char *, char *, ftnlen, ftnlen);
    integer nidir, index, value;
    extern /* Subroutine */ int errdp_(char *, doublereal *, ftnlen);
    integer nrdir;
    extern /* Subroutine */ int dafada_(doublereal *, integer *), dafbna_(
	    integer *, doublereal *, char *, ftnlen), dafena_(void);
    extern logical failed_(void);
    integer refcod;
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen);
    extern integer lastnb_(char *, ftnlen);
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen);
    extern logical return_(void);
    doublereal dcd[2];
    integer icd[6];

/* $ Abstract */

/*     Add a type 3 segment to a C-kernel. */

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
/*     ROTATIONS */
/*     SCLK */

/* $ Keywords */

/*     POINTING */
/*     UTILITY */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     HANDLE     I   Handle of an open CK file. */
/*     BEGTIM     I   Beginning encoded SCLK of the segment. */
/*     ENDTIM     I   Ending encoded SCLK of the segment. */
/*     INST       I   NAIF instrument ID code. */
/*     REF        I   Reference frame of the segment. */
/*     AVFLAG     I   True if the segment will contain angular velocity. */
/*     SEGID      I   Segment identifier. */
/*     NREC       I   Number of pointing records. */
/*     SCLKDP     I   Encoded SCLK times. */
/*     QUATS      I   Quaternions representing instrument pointing. */
/*     AVVS       I   Angular velocity vectors. */
/*     NINTS      I   Number of intervals. */
/*     STARTS     I   Encoded SCLK interval start times. */

/* $ Detailed_Input */

/*     HANDLE     is the handle of the CK file to which the segment will */
/*                be written. The file must have been opened with write */
/*                access. */

/*     BEGTIM,    are the beginning and ending encoded SCLK times for */
/*     ENDTIM     which the segment provides pointing information. */
/*                BEGTIM must be less than or equal to the SCLK time */
/*                associated with the first pointing instance in the */
/*                segment, and ENDTIM must be greater than or equal to */
/*                the time associated with the last pointing instance */
/*                in the segment. */

/*     INST       is the NAIF integer ID code for the instrument that */
/*                this segment will contain pointing information for. */

/*     REF        is a character string which specifies the inertial */
/*                reference frame of the segment. */

/*                The rotation matrices represented by the quaternions */
/*                that are to be written to the segment transform the */
/*                components of vectors from the inertial reference frame */
/*                specified by REF to components in the instrument fixed */
/*                frame. Also, the components of the angular velocity */
/*                vectors to be written to the segment should be given */
/*                with respect to REF. */

/*                REF should be the name of one of the frames supported */
/*                by the SPICELIB routine FRAMEX. */

/*     AVFLAG     is a logical flag which indicates whether or not the */
/*                segment will contain angular velocity. */

/*     SEGID      is the segment identifier. A CK segment identifier may */
/*                contain up to 40 printable characters and spaces. */

/*     NREC       is the number of pointing instances in the segment. */

/*     SCLKDP     are the encoded spacecraft clock times associated with */
/*                each pointing instance. These times must be strictly */
/*                increasing. */

/*     QUATS      are the quaternions representing the C-matrices, as */
/*                defined in the ROTATIONS Required Reading and by the */
/*                SPICELIB routine Q2M ( quaternion to matrix ). */

/*                The C-matrix represented by the Ith quaternion in */
/*                QUATS is a rotation matrix that transforms the */
/*                components of a vector expressed in the inertial */
/*                frame specified by REF to components expressed in */
/*                the instrument fixed frame at the time SCLKDP(I). */

/*                Thus, if a vector V has components x, y, z in the */
/*                inertial frame, then V has components x', y', z' in */
/*                the instrument fixed frame where: */

/*                     [ x' ]     [          ] [ x ] */
/*                     | y' |  =  |   CMAT   | | y | */
/*                     [ z' ]     [          ] [ z ] */

/*     AVVS       are the angular velocity vectors ( optional ). */

/*                The Ith vector in AVVS gives the angular velocity of */
/*                the instrument fixed frame at time SCLKDP(I). The */
/*                components of the angular velocity vectors should */
/*                be given with respect to the inertial reference frame */
/*                specified by REF. */

/*                The direction of an angular velocity vector gives */
/*                the right-handed axis about which the instrument fixed */
/*                reference frame is rotating. The magnitude of the */
/*                vector is the magnitude of the instantaneous velocity */
/*                of the rotation, in radians per second. */

/*                If AVFLAG is FALSE then this array is ignored by the */
/*                routine; however it still must be supplied as part of */
/*                the calling sequence. */

/*     NINTS      is the number of intervals that the pointing instances */
/*                are partitioned into. */

/*     STARTS     are the start times of each of the interpolation */
/*                intervals. These times must be strictly increasing */
/*                and must coincide with times for which the segment */
/*                contains pointing. */

/* $ Detailed_Output */

/*     None.  See Files section. */

/* $ Parameters */

/*     None. */

/* $ Exceptions */

/*     1)  If HANDLE is not the handle of a C-kernel opened for writing */
/*         the error will be diagnosed by routines called by this */
/*         routine. */

/*     2)  If SEGID is more than 40 characters long, the error */
/*         SPICE(SEGIDTOOLONG) is signaled. */

/*     3)  If SEGID contains any non-printable characters, the error */
/*         SPICE(NONPRINTABLECHARS) is signaled. */

/*     4)  If the first encoded SCLK time is negative then the error */
/*         SPICE(INVALIDSCLKTIME) is signaled. If any subsequent times */
/*         are negative the error will be detected in exception (5). */

/*     5)  If the encoded SCLK times are not strictly increasing, */
/*         the error SPICE(TIMESOUTOFORDER) is signaled. */

/*     6)  If BEGTIM is greater than SCLKDP(1) or ENDTIM is less than */
/*         SCLKDP(NREC), the error SPICE(INVALIDDESCRTIME) is */
/*         signaled. */

/*     7)  If the name of the reference frame is not one of those */
/*         supported by the routine FRAMEX, the error */
/*         SPICE(INVALIDREFFRAME) is signaled. */

/*     8)  If NREC, the number of pointing records, is less than or */
/*         equal to 0, the error SPICE(INVALIDNUMREC) is signaled. */

/*     9)  If NINTS, the number of interpolation intervals, is less than */
/*         or equal to 0, the error SPICE(INVALIDNUMINT) is signaled. */

/*    10)  If the encoded SCLK interval start times are not strictly */
/*         increasing, the error SPICE(TIMESOUTOFORDER) is signaled. */

/*    11)  If an interval start time does not coincide with a time for */
/*         which there is an actual pointing instance in the segment, */
/*         then the error SPICE(INVALIDSTARTTIME) is signaled. */

/*    12)  This routine assumes that the rotation between adjacent */
/*         quaternions that are stored in the same interval has a */
/*         rotation angle of THETA radians, where */

/*            0  <  THETA  <  pi. */
/*               _ */

/*         The routines that evaluate the data in the segment produced */
/*         by this routine cannot distinguish between rotations of THETA */
/*         radians, where THETA is in the interval [0, pi), and */
/*         rotations of */

/*            THETA   +   2 * k * pi */

/*         radians, where k is any integer.  These `large' rotations will */
/*         yield invalid results when interpolated.  You must ensure that */
/*         the data stored in the segment will not be subject to this */
/*         sort of ambiguity. */

/*    13)  If the squared length of any quaternion differs from 1 */
/*         by more than 1.0D-2, the error SPICE(NONUNITQUATERNION) is */
/*         signaled. */

/*    14)  If the start time of the first interval and the time of the */
/*         first pointing instance are not the same, the error */
/*         SPICE(TIMESDONTMATCH) is signaled. */

/* $ Files */

/*     This routine adds a type 3 segment to a C-kernel. The C-kernel */
/*     may be either a new one or an existing one opened for writing. */

/* $ Particulars */

/*     For a detailed description of a type 3 CK segment please see the */
/*     CK Required Reading. */

/*     This routine relieves the user from performing the repetitive */
/*     calls to the DAF routines necessary to construct a CK segment. */

/* $ Examples */

/*  C */
/*  C     This example code fragment writes a type 3 C-kernel segment */
/*  C     for the Mars Observer spacecraft bus to a previously opened CK */
/*  C     file attached to HANDLE. */
/*  C */

/*  C */
/*  C     Assume arrays of quaternions, angular velocities, and the */
/*  C     associated SCLK times are produced elsewhere.  The software */
/*  C     that calls CKW03 must then decide how to partition these */
/*  C     pointing instances into intervals over which linear */
/*  C     interpolation between adjacent points is valid. */
/*  C */
/*        . */
/*        . */
/*        . */

/*  C */
/*  C     The subroutine CKW03 needs the following items for the */
/*  C     segment descriptor: */
/*  C */
/*  C        1) SCLK limits of the segment. */
/*  C        2) Instrument code. */
/*  C        3) Reference frame. */
/*  C        4) The angular velocity flag. */
/*  C */
/*        BEGTIM = SCLK (    1 ) */
/*        ENDTIM = SCLK ( NREC ) */

/*        INST   = -94000 */
/*        REF    = 'J2000' */
/*        AVFLAG = .TRUE. */

/*        SEGID  = 'MO SPACECRAFT BUS - DATA TYPE 3' */

/*  C */
/*  C     Write the segment. */
/*  C */
/*        CALL CKW03 ( HANDLE, BEGTIM, ENDTIM, INST,  REF,  AVFLAG, */
/*       .             SEGID,  NREC,   SCLKDP, QUATS, AVVS, NINTS, */
/*       .             STARTS                                       ) */

/* $ Restrictions */

/*     1) The creator of the segment is given the responsibility for */
/*        determining whether it is reasonable to interpolate between */
/*        two given pointing values. */

/*    2)  This routine assumes that the rotation between adjacent */
/*        quaternions that are stored in the same interval has a */
/*        rotation angle of THETA radians, where */

/*            0  <  THETA  <  pi. */
/*               _ */

/*        The routines that evaluate the data in the segment produced */
/*        by this routine cannot distinguish between rotations of THETA */
/*        radians, where THETA is in the interval [0, pi), and */
/*        rotations of */

/*            THETA   +   2 * k * pi */

/*        radians, where k is any integer.  These `large' rotations will */
/*        yield invalid results when interpolated.  You must ensure that */
/*        the data stored in the segment will not be subject to this */
/*        sort of ambiguity. */

/*     3) All pointing instances in the segment must belong to one and */
/*        only one of the intervals. */

/* $ Literature_References */

/*     None. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */
/*     K.R. Gehringer  (JPL) */
/*     J.M. Lynch      (JPL) */
/*     B.V. Semenov    (JPL) */

/* $ Version */

/* -    SPICELIB Version 2.2.0, 26-SEP-2005 (BVS) */

/*        Added check to ensure that the start time of the first */
/*        interval is the same as the time of the first pointing */
/*        instance. */

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

/* -    SPICELIB Version 1.0.0, 25-NOV-1992 (JML) */

/* -& */
/* $ Index_Entries */

/*     write ck type_3 pointing data segment */

/* -& */
/* $ Revisions */

/* -    SPICELIB Version 2.2.0, 26-SEP-2005 (BVS) */

/*        Added check to ensure that the start time of the first */
/*        interval is the same as the time of the first pointing */
/*        instance. */

/* -    SPICELIB Version 2.1.0, 22-FEB-1999 (WLT) */

/*        Added check to make sure that all quaternions are unit */
/*        length to single precision. */

/* -    SPICELIB Version 1.1.1, 05-SEP-1993 (KRG) */

/*        Removed all references to a specific method of opening the CK */
/*        file in the $ Brief_I/O, $ Detailed_Input, $ Exceptions, */
/*        $ Files, and $ Examples sections of the header. It is assumed */
/*        that a person using this routine has some knowledge of the DAF */
/*        system and the methods for obtaining file handles. */

/* -    SPICELIB Version 1.0.0, 25-NOV-1992 (JML) */

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
	chkin_("CKW03", (ftnlen)5);
    }

/*     The first thing that we will do is create the segment descriptor. */

/*     The structure of the segment descriptor is as follows. */

/*           DCD( 1 ) and DCD( 2 ) -- SCLK limits of the segment. */
/*           ICD( 1 )              -- Instrument code. */
/*           ICD( 2 )              -- Reference frame ID. */
/*           ICD( 3 )              -- Data type of the segment. */
/*           ICD( 4 )              -- Angular rates flag. */
/*           ICD( 5 )              -- Beginning address of segment. */
/*           ICD( 6 )              -- Ending address of segment. */


/*     Make sure that there is a positive number of pointing records. */

    if (*nrec <= 0) {
	setmsg_("# is an invalid number of pointing instances for type 3.", (
		ftnlen)56);
	errint_("#", nrec, (ftnlen)1);
	sigerr_("SPICE(INVALIDNUMREC)", (ftnlen)20);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Make sure that there is a positive number of interpolation */
/*     intervals. */

    if (*nints <= 0) {
	setmsg_("# is an invalid number of interpolation intervals for type "
		"3.", (ftnlen)61);
	errint_("#", nints, (ftnlen)1);
	sigerr_("SPICE(INVALIDNUMINT)", (ftnlen)20);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Check that the SCLK bounds on the segment are reasonable. */

    if (*begtim > sclkdp[0]) {
	setmsg_("The segment begin time is greater than the time associated "
		"with the first pointing instance in the segment. DCD(1) = # "
		"and SCLKDP(1) = # ", (ftnlen)137);
	errdp_("#", begtim, (ftnlen)1);
	errdp_("#", sclkdp, (ftnlen)1);
	sigerr_("SPICE(INVALIDDESCRTIME)", (ftnlen)23);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }
    if (*endtim < sclkdp[*nrec - 1]) {
	setmsg_("The segment end time is less than the time associated with "
		"the last pointing instance in the segment. DCD(2) = # and SC"
		"LKDP(#) = #", (ftnlen)130);
	errdp_("#", endtim, (ftnlen)1);
	errint_("#", nrec, (ftnlen)1);
	errdp_("#", &sclkdp[*nrec - 1], (ftnlen)1);
	sigerr_("SPICE(INVALIDDESCRTIME)", (ftnlen)23);
	chkout_("CKW03", (ftnlen)5);
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
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Assign values to the integer components of the segment descriptor. */

    icd[0] = *inst;
    icd[1] = refcod;
    icd[2] = 3;
    if (*avflag) {
	icd[3] = 1;
    } else {
	icd[3] = 0;
    }

/*     Now pack the segment descriptor. */

    dafps_(&c__2, &c__6, dcd, icd, descr);

/*     Check that all the characters in the segid can be printed. */

    i__1 = lastnb_(segid, segid_len);
    for (i__ = 1; i__ <= i__1; ++i__) {
	value = *(unsigned char *)&segid[i__ - 1];
	if (value < 32 || value > 126) {
	    setmsg_("The segment identifier contains nonprintable characters",
		     (ftnlen)55);
	    sigerr_("SPICE(NONPRINTABLECHARS)", (ftnlen)24);
	    chkout_("CKW03", (ftnlen)5);
	    return 0;
	}
    }

/*     Also check to see if the segment identifier is too long. */

    if (lastnb_(segid, segid_len) > 40) {
	setmsg_("Segment identifier contains more than 40 characters.", (
		ftnlen)52);
	sigerr_("SPICE(SEGIDTOOLONG)", (ftnlen)19);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Now check that the encoded SCLK times are positive and strictly */
/*     increasing. */

/*     Check that the first time is nonnegative. */

    if (sclkdp[0] < 0.) {
	setmsg_("The first SCLKDP time: # is negative.", (ftnlen)37);
	errdp_("#", sclkdp, (ftnlen)1);
	sigerr_("SPICE(INVALIDSCLKTIME)", (ftnlen)22);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Now check that the times are ordered properly. */

    i__1 = *nrec;
    for (i__ = 2; i__ <= i__1; ++i__) {
	if (sclkdp[i__ - 1] <= sclkdp[i__ - 2]) {
	    setmsg_("The SCLKDP times are not strictly increasing. SCLKDP(#)"
		    " = # and SCLKDP(#) = #.", (ftnlen)78);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &sclkdp[i__ - 1], (ftnlen)1);
	    i__2 = i__ - 1;
	    errint_("#", &i__2, (ftnlen)1);
	    errdp_("#", &sclkdp[i__ - 2], (ftnlen)1);
	    sigerr_("SPICE(TIMESOUTOFORDER)", (ftnlen)22);
	    chkout_("CKW03", (ftnlen)5);
	    return 0;
	}
    }

/*     Now check that the start time of the first interval is the */
/*     same as the time of the first pointing instance. */

    if (sclkdp[0] != starts[0]) {
	setmsg_("The start time of the first interval # and the time of the "
		"first pointing instance # are not the same.", (ftnlen)102);
	errdp_("#", starts, (ftnlen)1);
	errdp_("#", sclkdp, (ftnlen)1);
	sigerr_("SPICE(TIMESDONTMATCH)", (ftnlen)21);
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Now check that the interval start times are ordered properly. */

    i__1 = *nints;
    for (i__ = 2; i__ <= i__1; ++i__) {
	if (starts[i__ - 1] <= starts[i__ - 2]) {
	    setmsg_("The interval start times are not strictly increasing. S"
		    "TARTS(#) = # and STARTS(#) = #.", (ftnlen)86);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("#", &starts[i__ - 1], (ftnlen)1);
	    i__2 = i__ - 1;
	    errint_("#", &i__2, (ftnlen)1);
	    errdp_("#", &starts[i__ - 2], (ftnlen)1);
	    sigerr_("SPICE(TIMESOUTOFORDER)", (ftnlen)22);
	    chkout_("CKW03", (ftnlen)5);
	    return 0;
	}
    }

/*     Now make sure that all of the interval start times coincide with */
/*     one of the times associated with the actual pointing. */

    index = 0;
    i__1 = *nints;
    for (i__ = 1; i__ <= i__1; ++i__) {
	match = FALSE_;
	while(! match && index < *nrec) {
	    ++index;
	    match = starts[i__ - 1] == sclkdp[index - 1];
	}
	if (! match) {
	    setmsg_("Interval start time number # is invalid. STARTS(#) = *", 
		    (ftnlen)54);
	    errint_("#", &i__, (ftnlen)1);
	    errint_("#", &i__, (ftnlen)1);
	    errdp_("*", &starts[i__ - 1], (ftnlen)1);
	    sigerr_("SPICE(INVALIDSTARTTIME)", (ftnlen)23);
	    chkout_("CKW03", (ftnlen)5);
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
	    chkout_("CKW03", (ftnlen)5);
	    return 0;
	}
    }

/*     No more checks, begin writing the segment. */

    dafbna_(handle, descr, segid, segid_len);
    if (failed_()) {
	chkout_("CKW03", (ftnlen)5);
	return 0;
    }

/*     Now add the quaternions and optionally, the angular velocity */
/*     vectors. */

    if (*avflag) {
	i__1 = *nrec;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    dafada_(&quats[(i__ << 2) - 4], &c__4);
	    dafada_(&avvs[i__ * 3 - 3], &c__3);
	}
    } else {
	i__1 = *nrec << 2;
	dafada_(quats, &i__1);
    }

/*     Add the SCLK times. */

    dafada_(sclkdp, nrec);

/*     The time tag directory.  The Ith element is defined to be the */
/*     (I*100)th SCLK time. */

    nrdir = (*nrec - 1) / 100;
    index = 100;
    i__1 = nrdir;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dafada_(&sclkdp[index - 1], &c__1);
	index += 100;
    }

/*     Now add the interval start times. */

    dafada_(starts, nints);

/*     And the directory of interval start times.  The directory of */
/*     start times will simply be every 100th start time. */

    nidir = (*nints - 1) / 100;
    index = 100;
    i__1 = nidir;
    for (i__ = 1; i__ <= i__1; ++i__) {
	dafada_(&starts[index - 1], &c__1);
	index += 100;
    }

/*     Finally, the number of intervals and records. */

    d__1 = (doublereal) (*nints);
    dafada_(&d__1, &c__1);
    d__1 = (doublereal) (*nrec);
    dafada_(&d__1, &c__1);

/*     End the segment. */

    dafena_();
    chkout_("CKW03", (ftnlen)5);
    return 0;
} /* ckw03_ */

