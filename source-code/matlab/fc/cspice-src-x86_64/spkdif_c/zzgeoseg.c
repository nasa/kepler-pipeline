/* zzgeoseg.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__201 = 201;
static integer c__5 = 5;
static integer c__2 = 2;
static integer c__6 = 6;

/* $Procedure  ZZGEOSEG ( Find segments used to compute geometric state ) */
/* Subroutine */ int zzgeoseg_(integer *target, doublereal *et, integer *
	obsrvr, integer *n, integer *hanlst, doublereal *dsclst)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);

    /* Local variables */
    static integer cobs, i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    static doublereal descr[5];
    static integer ctarg[100];
    extern /* Subroutine */ int dafus_(doublereal *, integer *, integer *, 
	    doublereal *, integer *);
    static char ident[40];
    extern /* Subroutine */ int moved_(doublereal *, integer *, doublereal *);
    static logical found;
    static integer ctpos;
    static doublereal dc[2];
    static integer ic[6];
    extern logical failed_(void);
    static integer handle;
    extern integer isrchi_(integer *, integer *, integer *);
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen), errint_(char *, integer *, 
	    ftnlen), spksfs_(integer *, doublereal *, integer *, doublereal *,
	     char *, logical *, ftnlen);
    extern logical return_(void);
    static integer nct;

/* $ Abstract */

/*     Return the list of handles and segment descriptors identifying */
/*     the SPK segments used to produce a specified geometric state */
/*     vector. */

/* $ Copyright */

/*     Copyright (1997), California Institute of Technology. */
/*     U.S. Government sponsorship acknowledged. */

/* $ Required_Reading */

/*     SPK */

/* $ Keywords */

/*     EPHEMERIS */

/* $ Declarations */
/* $ Brief_I/O */

/*     Variable  I/O  Description */
/*     --------  ---  -------------------------------------------------- */
/*     TARGET     I   Target body. */
/*     ET         I   Target epoch. */
/*     OBSRVR     I   Observing body. */
/*     N          O   Number of segments used to construct state. */
/*     HANLST     O   List of SPK handles. */
/*     DSCLST     O   List of SPK segment descriptors. */

/* $ Detailed_Input */

/*     TARGET      is the standard NAIF ID code for a target body. */

/*     ET          is the epoch (ephemeris time) for which the time */
/*                 interval of continuous state data is to be found. */

/*     OBSRVR      is the standard NAIF ID code for an observing body. */


/* $ Detailed_Output */

/*     N           is the number of segments used to construct the */
/*                 geometric state vector defined by TARGET, ET, and */
/*                 OBSRVR. If state cannot be computed, N is set to */
/*                 zero. */

/*     HANLST      is a list of handles of SPK files containing the */
/*                 segments used to construct the specified state. */

/*     DSCLST      is a list of descriptors of the SPK segments used to */
/*                 construct the specified state. */

/* $ Parameters */

/*     MAXSEG      is the maximum number of segments that may be */
/*                 required to construct a state.  Normally, a state */
/*                 can be constructed using four or fewer segments. */

/* $ Exceptions */

/*     1) If the number of segments required to construct the specified */
/*        state exceeds MAXSEG, the error SPICE(PARAMETERTOOSMALL) is */
/*        signaled. */

/* $ Files */

/*     See argument HANDLE. */

/* $ Particulars */

/*     The method used to build a list of segments required to construct */
/*     a state vector is basically that used in SPKGEO. */

/* $ Examples */

/*     See the routine SPKBRK. */

/* $ Restrictions */

/*     1) The parameter MAXSEG limits the number of segments that can */
/*        be used to build a state vector.  Normally, the number of */
/*        segments will be four or fewer, while MAXSEG is at least 200, */
/*        so overflow is not likely. */

/* $ Literature_References */

/*     NAIF Document 168.0, "S- and P- Kernel (SPK) Specification and */
/*     User's Guide" */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Version */

/* -    Beta Version 2.0.0, 14-SEP-2000 (NJB) */

/*        Interface was changed to return N=0 instead of signaling an */
/*        for cases when state could not be computed. */

/* -    Beta Version 1.0.0, 29-APR-1997 (NJB) */

/* -& */

/*     SPICELIB functions */


/*     Local parameters */

/*     CHLEN is the maximum length of a chain.  That is, */
/*     it is the maximum number of bodies in the chain from */
/*     the target or observer to the SSB. */


/*     Local variables */


/*     Save everything to prevent potential memory problems in f2c'ed */
/*     version. */

    if (return_()) {
	return 0;
    } else {
	chkin_("ZZGEOSEG", (ftnlen)8);
    }

/*     Basically, we mimic the logic in SPKGEO.  But we don't need to */
/*     actually compute any states, and we do need to keep track of */
/*     every segment we look up, including those for the observer. */

/*     To start out, the segment list is empty. */

    *n = 0;

/*     We take care of the obvious case first.  If TARGET and OBSRVR are */
/*     the same we can just fill in zero. */

    if (*target == *obsrvr) {
	chkout_("ZZGEOSEG", (ftnlen)8);
	return 0;
    }

/*     CTARG contains the integer codes of the bodies in the */
/*     target body chain, beginning with TARGET itself and then */
/*     the successive centers of motion. */

/*     COBS will contain the centers of the observing body. */

/*     Then we follow the chain, filling up CTARG as we go.  We use */
/*     SPKSFS to search through loaded files to find the first segment */
/*     applicable to CTARG(1) and time ET.  Then we get its center */
/*     CTARG(2). */

/*     We repeat the process for CTARG(2) and so on, until */
/*     there is no data found for some CTARG(I) or until we */
/*     reach the SSB. */

/*     Next, we find centers and states in a similar manner */
/*     for the observer.  It's a similar construction as */
/*     described above, but COBS is overwritten with each new center, */
/*     beginning at OBSRVR.  However, we stop when we encounter */
/*     a common center of motion, that is when COBS is equal */
/*     to CTARG(I) for some I. */

/*     CTPOS is the position in CTARG of the common node. */

/*     Fill in CTARG until no more data is found or until we reach the */
/*     SSB. */

/*     Note the check for FAILED in the loop.  If SPKSFS happens to fail */
/*     during execution, and the current error handling action is to NOT */
/*     abort, then FOUND may be stuck at TRUE, CTARG(I) will never */
/*     become zero, and the loop would otherwise execute indefinitely. */


    i__ = 1;
    ctarg[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("ctarg", i__1, 
	    "zzgeoseg_", (ftnlen)241)] = *target;
    found = TRUE_;
    while(found && i__ < 100 && ctarg[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? 
	    i__1 : s_rnge("ctarg", i__1, "zzgeoseg_", (ftnlen)244)] != *
	    obsrvr && ctarg[(i__2 = i__ - 1) < 100 && 0 <= i__2 ? i__2 : 
	    s_rnge("ctarg", i__2, "zzgeoseg_", (ftnlen)244)] != 0) {

/*        Find a file and segment that has state */
/*        data for CTARG(I). */

	spksfs_(&ctarg[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge(
		"ctarg", i__1, "zzgeoseg_", (ftnlen)253)], et, &handle, descr,
		 ident, &found, (ftnlen)40);
	if (failed_()) {
	    chkout_("ZZGEOSEG", (ftnlen)8);
	    return 0;
	}
	if (found) {

/*           DESCR designates a segment giving the state of CTARG(I) */
/*           relative to some center of motion.  This new center goes in */
/*           CTARG(I+1).  The handle and descriptor get added to our */
/*           lists. */

	    ++i__;
	    ++(*n);
	    if (*n > 200) {
		setmsg_("Segment list is full, requires at # least segments.",
			 (ftnlen)51);
		errint_("#", &c__201, (ftnlen)1);
		sigerr_("SPICE(PARAMETERTOOSMALL)", (ftnlen)24);
		chkout_("ZZGEOSEG", (ftnlen)8);
		return 0;
	    }
	    hanlst[*n - 1] = handle;
	    moved_(descr, &c__5, &dsclst[*n * 5 - 5]);

/*           The center of motion of COBS becomes the new COBS. */

	    dafus_(descr, &c__2, &c__6, dc, ic);
	    ctarg[(i__1 = i__ - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("ctarg",
		     i__1, "zzgeoseg_", (ftnlen)289)] = ic[1];
	}
    }

/*     NCT is the number of elements in CTARG, */
/*     the chain length. */

    nct = i__;

/*     Now follow the observer's chain.  Assign */
/*     the first values for COBS and SOBS. */

    cobs = *obsrvr;

/*     Perhaps we have a common node already. */
/*     If so it will be the last node on the */
/*     list CTARG. */

/*     We let CTPOS will be the position of the common */
/*     node in CTARG if one is found.  It will */
/*     be zero if COBS is not found in CTARG. */

    if (ctarg[(i__1 = nct - 1) < 100 && 0 <= i__1 ? i__1 : s_rnge("ctarg", 
	    i__1, "zzgeoseg_", (ftnlen)316)] == cobs) {
	ctpos = nct;
    } else {
	ctpos = 0;
    }

/*     Repeat the same loop as above, but each time */
/*     we encounter a new center of motion, check to */
/*     see if it is a common node. */

    found = TRUE_;
    while(found && cobs != 0 && ctpos == 0) {

/*        Find a file and segment that has state */
/*        data for COBS. */

	spksfs_(&cobs, et, &handle, descr, ident, &found, (ftnlen)40);

/*        Check failed.  We don't want to loop indefinitely. */

	if (failed_()) {
	    chkout_("ZZGEOSEG", (ftnlen)8);
	    return 0;
	}
	if (found) {

/*           Add the handle and descriptor of the new segment to */
/*           our lists. */

	    ++(*n);
	    if (*n > 200) {
		setmsg_("Segment list is full, requires at # least segments.",
			 (ftnlen)51);
		errint_("#", &c__201, (ftnlen)1);
		sigerr_("SPICE(PARAMETERTOOSMALL)", (ftnlen)24);
		chkout_("ZZGEOSEG", (ftnlen)8);
		return 0;
	    }
	    hanlst[*n - 1] = handle;
	    moved_(descr, &c__5, &dsclst[*n * 5 - 5]);

/*           The center of motion of COBS becomes the new COBS. */

	    dafus_(descr, &c__2, &c__6, dc, ic);
	    cobs = ic[1];

/*           See if the new center is a common node. If not, repeat the */
/*           loop. */

	    ctpos = isrchi_(&cobs, &nct, ctarg);
	}
    }

/*     If CTPOS is zero at this point, it means we */
/*     have not found a common node though we have */
/*     searched through all the available data. */

    if (ctpos == 0) {
	*n = 0;
    }
    chkout_("ZZGEOSEG", (ftnlen)8);
    return 0;
} /* zzgeoseg_ */

