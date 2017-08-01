/* zzfrmch0.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;

/* $Procedure      ZZFRMCH0 (Frame Change) */
/* Subroutine */ int zzfrmch0_(integer *frame1, integer *frame2, doublereal *
	et, doublereal *xform)
{
    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7, i__8, i__9, i__10, 
	    i__11, i__12, i__13;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer), s_cmp(char *, char *, 
	    ftnlen, ftnlen);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer node;
    logical done;
    integer cent;
    extern /* Subroutine */ int zzfrmgt0_(integer *, doublereal *, doublereal 
	    *, integer *, logical *);
    integer this__;
    char name1[32], name2[32], name3[32], name4[32];
    integer i__, j, k, l, frame[10];
    extern /* Subroutine */ int chkin_(char *, ftnlen), errch_(char *, char *,
	     ftnlen, ftnlen);
    integer class__;
    logical found;
    integer relto;
    doublereal trans[504]	/* was [6][6][14] */;
    extern integer rtrim_(char *, ftnlen);
    integer r1, r2, r3, r4;
    doublereal trans2[72]	/* was [6][6][2] */;
    integer cmnode;
    extern /* Subroutine */ int frmnam_(integer *, char *, ftnlen);
    extern integer isrchi_(integer *, integer *, integer *);
    integer clssid;
    extern /* Subroutine */ int frinfo_(integer *, integer *, integer *, 
	    integer *, logical *);
    logical gotone;
    extern /* Subroutine */ int sigerr_(char *, ftnlen), chkout_(char *, 
	    ftnlen), setmsg_(char *, ftnlen);
    doublereal tempxf[36]	/* was [6][6] */;
    extern /* Subroutine */ int errint_(char *, integer *, ftnlen);
    extern logical return_(void);
    extern /* Subroutine */ int invstm_(doublereal *, doublereal *), zzmsxf_(
	    doublereal *, integer *, doublereal *);
    integer inc, get, put;

/* $ Abstract */

/*     SPICE Private routine intended solely for the support of SPICE */
/*     routines.  Users should not call this routine directly due */
/*     to the volatile nature of this routine. */

/*     Return the state transformation matrix from one */
/*     frame to another. */

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

/*     FRAMES */

/* $ Declarations */
/* $ Abstract */

/*     The parameters below form an enumerated list of the recognized */
/*     frame types.  They are: INERTL, PCK, CK, TK, DYN.  The meanings */
/*     are outlined below. */

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

/* $ Parameters */

/*     INERTL      an inertial frame that is listed in the routine */
/*                 CHGIRF and that requires no external file to */
/*                 compute the transformation from or to any other */
/*                 inertial frame. */

/*     PCK         is a frame that is specified relative to some */
/*                 INERTL frame and that has an IAU model that */
/*                 may be retrieved from the PCK system via a call */
/*                 to the routine TISBOD. */

/*     CK          is a frame defined by a C-kernel. */

/*     TK          is a "text kernel" frame.  These frames are offset */
/*                 from their associated "relative" frames by a */
/*                 constant rotation. */

/*     DYN         is a "dynamic" frame.  These currently are */
/*                 parameterized, built-in frames where the full frame */
/*                 definition depends on parameters supplied via a */
/*                 frame kernel. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */
/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 3.0.0, 28-MAY-2004 (NJB) */

/*       The parameter DYN was added to support the dynamic frame class. */

/* -    SPICELIB Version 2.0.0, 12-DEC-1996 (WLT) */

/*        Various unused frames types were removed and the */
/*        frame time TK was added. */

/* -    SPICELIB Version 1.0.0, 10-DEC-1995 (WLT) */

/* -& */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     FRAME1     I   the frame id-code for some reference frame */
/*     FRAME2     I   the frame id-code for some reference frame */
/*     ET         I   an epoch in TDB seconds past J2000. */
/*     XFORM      O   a state transformation matrix */

/* $ Detailed_Input */

/*     FRAME1      is the frame id-code in which some states are known. */

/*     FRAME2      is the frame id-code for some frame in which you */
/*                 would like to represent states. */

/*     ET          is the epoch at which to compute the state */
/*                 transformation matrix.  This epoch should be */
/*                 in TDB seconds past the ephemeris epoch of J2000. */

/* $ Detailed_Output */

/*     XFORM       is a 6 x 6 state transformation matrix that can */
/*                 be used to transform states relative to the frame */
/*                 correspsonding to frame FRAME2 to states relative */
/*                 to the frame FRAME2.  More explicitely, if STATE */
/*                 is the state of some object relative to the reference */
/*                 frame of FRAME1 then STATE2 is the state of the */
/*                 same object relative to FRAME2 where STATE2 is */
/*                 computed via the subroutine call below */

/*                    CALL MXVG ( XFORM, STATE, 6, 6, STATE2 ) */


/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     1) If either of the reference frames is unrecognized, the error */
/*        SPICE(UNKNOWNFRAME) will be signalled. */

/*     2) If the auxillary information needed to compute a non-inertial */
/*        frame is not available an error will be diagnosed and signalled */
/*        by a routine in the call tree of this routine. */

/* $ Particulars */

/*     This routine allows you to compute the state transformation matrix */
/*     between two reference frames. */

/*     The currently supported reference frames are IAU bodyfixed frames */
/*     and inertial reference frames. */

/* $ Examples */

/*     Example 1.  Suppose that you have a state STATE1 at epoch ET */
/*     relative to  FRAME1 and wish to determine its representation */
/*     STATE2 relative to FRAME2.  The following subroutine calls */
/*     would suffice to make this transformation. */

/*        CALL ZZFRMCH0 ( FRAME1, FRAME2, ET,   XFORM ) */
/*        CALL MXVG   ( XFORM,  STATE1, 6, 6, STATE2 ) */



/*     Example 2.  Suppose that you have the angular velocity, W, of some */
/*     rotation relative to FRAME1 at epoch ET and that you wish to */
/*     express this angular velocity with respect to FRAME2.  The */
/*     following subroutines will suffice to perform this computation. */

/*        CALL ZZFRMCH0 ( FRAME1, FRAME2, ET, STXFRM ) */

/*     Recall that a state transformation matrix has the following form. */


/*            -               - */
/*           |                 | */
/*           |    R        0   | */
/*           |                 | */
/*           |                 | */
/*           |   dR            | */
/*           |   --        R   | */
/*           |   dt            | */
/*           |                 | */
/*            -               - */


/*     The velocity of an arbitrary point P undergoing rotation with the */
/*     angular velocity W is W x P */

/*     Thus the velocity of P in FRAME2 is: */


/*        dR */
/*        --  P    +    R (W x P ) */
/*        dt */

/*           dR  t */
/*     =  (  -- R  R P   +  W  x P  )            ( 1 ) */
/*           dt */


/*           dR  t                                              t */
/*     But   -- R  is skew symmetric  (simply differentiate  R*R to see */
/*           dt */
/*                    dR  t */
/*     this ).  Hence -- R R P  can be written as Ax(R*P) for some fixed */
/*                    dt */

/*     vector A.  Moreover the vector A can be read from the upper */

/*                            dR  t */
/*     triangular portion of  -- R  .  So that equation (1) above can */
/*                            dt */

/*     be re-written as */

/*         dR  t */
/*     = ( -- R  R*P   +  R*(WxP)  ) */
/*         dt */

/*     = Ax(R*P) + R*W x R*P */

/*     = ( [A+R*W] x R*P ) */


/*     From this final expression it follows that in FRAME2 the angular */
/*     velocity vector is given by [A+R*W]. */

/*     The code below implements these ideas. */

/*        CALL ZZFRMCH0 ( FRAME1, FRAME2, ET, STXFRM ) */


/*        DO I = 1, 3 */
/*           DO J = 1, 3 */

/*              RT  ( I, J ) = STXFRM ( I,   J ) */
/*              DRDT( I, J ) = STXFRM ( I+3, J ) */

/*           END DO */
/*        END DO */

/*        CALL MXMT ( DRDT, R, AMATRIX ) */

/*        Read the angular velocity of R from the skew symmetric matrix */

/*         dR  t */
/*         -- R */
/*         dt */

/*        Recall that if A has components A1, A2, A3 then the matrix */
/*        cooresponding to the cross product linear mapping is: */

/*            -               - */
/*           |   0  -A3    A2  | */
/*           |                 | */
/*           |  A3   0    -A1  | */
/*           |                 | */
/*           | -A2   A1    0   | */
/*            -               - */

/*        A(1) = -AMATRIX(2,3) */
/*        A(2) =  AMATRIX(1,3) */
/*        A(3) = -AMATRIX(1,2) */

/*        CALL MXV  ( R, W1,  W  ) */
/*        CALL VADD ( A, W,   W2 ) */


/* $ Restrictions */

/*     1) SPICE Private routine. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 12-DEC-2004 (NJB) */

/*        Based on SPICELIB Version 1.1.0, 25-JUL-1996 (WLT) */


/* -& */
/* $ Index_Entries */

/*     Transform states from one frame to another */

/* -& */

/*     SPICE functions */


/*     Local Paramters */


/*     The root of all reference frames is J2000 (Frame ID = 1). */


/*     Local Variables. */


/*     NODE counts the number of transformations needed to go */
/*     from FRAME1 to FRAME2. */


/*     FRAME contains the frames we transform from in going from */
/*     FRAME1 to FRAME2.  FRAME(1) = FRAME1 by  construction. */


/*     TRANS contains the transformations from FRAME1 to FRAME2 */
/*     TRANS(1...6,1...6,I) has the transfromation from FRAME(I) */
/*     to FRAME(I+1).  We make extra room in TRANS because we */
/*     plan to add transformations beyond the obvious chain from */
/*     FRAME1 to a root node. */


/*     TRANS2 is used to store intermediate transformations from */
/*     FRAME2 to some node in the chain from FRAME1 to PCK or */
/*     INERTL frames. */


/*     Standard SPICE error handling. */

    if (return_()) {
	return 0;
    }
    chkin_("ZZFRMCH0", (ftnlen)8);

/*     Do the obvious thing first.  If FRAME1 and FRAME2 are the */
/*     same then we simply return the identity matrix. */

    if (*frame1 == *frame2) {
	for (i__ = 1; i__ <= 6; ++i__) {
	    xform[(i__1 = i__ + i__ * 6 - 7) < 36 && 0 <= i__1 ? i__1 : 
		    s_rnge("xform", i__1, "zzfrmch0_", (ftnlen)369)] = 1.;
	    i__1 = i__ - 1;
	    for (j = 1; j <= i__1; ++j) {
		xform[(i__2 = i__ + j * 6 - 7) < 36 && 0 <= i__2 ? i__2 : 
			s_rnge("xform", i__2, "zzfrmch0_", (ftnlen)372)] = 0.;
		xform[(i__2 = j + i__ * 6 - 7) < 36 && 0 <= i__2 ? i__2 : 
			s_rnge("xform", i__2, "zzfrmch0_", (ftnlen)373)] = 0.;
	    }
	}
	chkout_("ZZFRMCH0", (ftnlen)8);
	return 0;
    }

/*     Now perform the obvious check to make sure that both */
/*     frames are recognized. */

    frinfo_(frame1, &cent, &class__, &clssid, &found);
    if (! found) {
	setmsg_("The number # is not a recognized id-code for a reference fr"
		"ame. ", (ftnlen)64);
	errint_("#", frame1, (ftnlen)1);
	sigerr_("SPICE(UNKNOWNFRAME)", (ftnlen)19);
	chkout_("ZZFRMCH0", (ftnlen)8);
	return 0;
    }
    frinfo_(frame2, &cent, &class__, &clssid, &found);
    if (! found) {
	setmsg_("The number # is not a recognized id-code for a reference fr"
		"ame. ", (ftnlen)64);
	errint_("#", frame2, (ftnlen)1);
	sigerr_("SPICE(UNKNOWNFRAME)", (ftnlen)19);
	chkout_("ZZFRMCH0", (ftnlen)8);
	return 0;
    }
    node = 1;
    frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("frame", i__1, 
	    "zzfrmch0_", (ftnlen)416)] = *frame1;
    found = TRUE_;

/*     Follow the chain of transformations until we run into */
/*     one that transforms to J2000 (frame id = 1) or we hit FRAME2. */

    while(frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("frame", 
	    i__1, "zzfrmch0_", (ftnlen)422)] != 1 && node < 10 && frame[(i__2 
	    = node - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("frame", i__2, 
	    "zzfrmch0_", (ftnlen)422)] != *frame2 && found) {

/*        Find out what transformation is available for this */
/*        frame. */

	zzfrmgt0_(&frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"frame", i__1, "zzfrmch0_", (ftnlen)430)], et, &trans[(i__2 = 
		(node * 6 + 1) * 6 - 42) < 504 && 0 <= i__2 ? i__2 : s_rnge(
		"trans", i__2, "zzfrmch0_", (ftnlen)430)], &frame[(i__3 = 
		node) < 10 && 0 <= i__3 ? i__3 : s_rnge("frame", i__3, "zzfr"
		"mch0_", (ftnlen)430)], &found);
	if (found) {

/*           We found a transformation matrix.  TRANS(1,1,NODE) */
/*           now contains the transformation from FRAME(NODE) */
/*           to FRAME(NODE+1).  We need to look up the information */
/*           for the next NODE. */

	    ++node;
	}
    }
    done = frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("frame", 
	    i__1, "zzfrmch0_", (ftnlen)446)] == 1 || frame[(i__2 = node - 1) <
	     10 && 0 <= i__2 ? i__2 : s_rnge("frame", i__2, "zzfrmch0_", (
	    ftnlen)446)] == *frame2 || ! found;
    while(! done) {

/*        The only way to get to this point is to have run out of */
/*        room in the array of reference frame transformation */
/*        buffers.  We will now build the transformation from */
/*        the previous NODE to whatever the next node in the */
/*        chain is.  We'll do this until we get to one of the */
/*        root classes or we run into FRAME2. */

	zzfrmgt0_(&frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"frame", i__1, "zzfrmch0_", (ftnlen)460)], et, &trans[(i__2 = 
		(node * 6 + 1) * 6 - 42) < 504 && 0 <= i__2 ? i__2 : s_rnge(
		"trans", i__2, "zzfrmch0_", (ftnlen)460)], &relto, &found);
	if (found) {

/*           Recall that TRANS(1,1,NODE-1) contains the transformation */
/*           from FRAME(NODE-1) to FRAME(NODE).  We are going to replace */
/*           FRAME(NODE) with the frame indicated by RELTO.  This means */
/*           that TRANS(1,1,NODE-1) should be replaced with the */
/*           transformation from FRAME(NODE) to RELTO. */

	    frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("frame",
		     i__1, "zzfrmch0_", (ftnlen)471)] = relto;
	    zzmsxf_(&trans[(i__1 = ((node - 1) * 6 + 1) * 6 - 42) < 504 && 0 
		    <= i__1 ? i__1 : s_rnge("trans", i__1, "zzfrmch0_", (
		    ftnlen)472)], &c__2, tempxf);
	    for (i__ = 1; i__ <= 6; ++i__) {
		for (j = 1; j <= 6; ++j) {
		    trans[(i__1 = i__ + (j + (node - 1) * 6) * 6 - 43) < 504 
			    && 0 <= i__1 ? i__1 : s_rnge("trans", i__1, "zzf"
			    "rmch0_", (ftnlen)476)] = tempxf[(i__2 = i__ + j * 
			    6 - 7) < 36 && 0 <= i__2 ? i__2 : s_rnge("tempxf",
			     i__2, "zzfrmch0_", (ftnlen)476)];
		}
	    }
	}

/*        We are done if the class of the last frame is J2000 */
/*        or if the last frame is FRAME2 or if we simply couldn't get */
/*        another transformation. */

	done = frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"frame", i__1, "zzfrmch0_", (ftnlen)486)] == 1 || frame[(i__2 
		= node - 1) < 10 && 0 <= i__2 ? i__2 : s_rnge("frame", i__2, 
		"zzfrmch0_", (ftnlen)486)] == *frame2 || ! found;
    }

/*     Right now we have the following situation.  We have in hand */
/*     a collection of transformations between frames. (Assuming */
/*     that is that NODE .GT. 1.  If NODE .EQ. 1 then we have */
/*     no transformations computed yet. */


/*     TRANS(1...6, 1...6, 1    )    transforms FRAME1   to FRAME(2) */
/*     TRANS(1...6, 1...6, 2    )    transforms FRAME(2) to FRAME(3) */
/*     TRANS(1...6, 1...6, 3    )    transforms FRAME(3) to FRAME(4) */
/*        . */
/*        . */
/*        . */
/*     TRANS(1...6, 1...6, NODE-1 )  transforms FRAME(NODE-1) */
/*                                   to         FRAME(NODE) */


/*     One of the following situations is true. */

/*     1)  FRAME(NODE) is the root of all frames, J2000. */

/*     2)  FRAME(NODE) is the same as FRAME2 */

/*     3)  There is no transformation from FRAME(NODE) to another */
/*         more fundamental frame.  The chain of transformations */
/*         from FRAME1 stops at FRAME(NODE).  This means that the */
/*         "frame atlas" is incomplete because we can't get to the */
/*         root frame. */

/*     We now have to do essentially the same thing for FRAME2. */

    if (frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge("frame", 
	    i__1, "zzfrmch0_", (ftnlen)524)] == *frame2) {

/*        We can handle this one immediately with the private routine */
/*        ZZMSXF which multiplies a series of state transformation */
/*        matrices. */

	i__1 = node - 1;
	zzmsxf_(trans, &i__1, xform);
	chkout_("ZZFRMCH0", (ftnlen)8);
	return 0;
    }

/*     We didn't luck out above.  So we follow the chain of */
/*     transformation for FRAME2.  Note that at the moment the */
/*     chain of transformations from FRAME2 to other frames */
/*     does not share a node in the chain for FRAME1. */
/*    ( GOTONE = .FALSE. ) . */

    this__ = *frame2;
    gotone = FALSE_;

/*     First see if there is any chain to follow. */

    done = this__ == 1;

/*     Set up the matrices TRANS2(,,1) and TRANS(,,2)  and set up */
/*     PUT and GET pointers so that we know where to GET the partial */
/*     transformation from and where to PUT partial results. */

    if (! done) {
	for (k = 1; k <= 2; ++k) {
	    for (i__ = 1; i__ <= 3; ++i__) {
		for (j = 4; j <= 6; ++j) {
		    trans2[(i__1 = i__ + (j + k * 6) * 6 - 43) < 72 && 0 <= 
			    i__1 ? i__1 : s_rnge("trans2", i__1, "zzfrmch0_", 
			    (ftnlen)561)] = 0.;
		}
	    }
	}
	put = 1;
	get = 1;
	inc = 1;
    }

/*     Follow the chain of transformations until we run into */
/*     one that transforms to the root frame or we land in the */
/*     chain of nodes for FRAME1. */

/*     Note that this time we will simply keep track of the full */
/*     translation from FRAME2 to the last node. */

    while(! done) {

/*        Find out what transformation is available for this */
/*        frame. */

	if (this__ == *frame2) {

/*           This is the first pass, just put the transformation */
/*           directly into TRANS2(,,PUT). */

	    zzfrmgt0_(&this__, et, &trans2[(i__1 = (put * 6 + 1) * 6 - 42) < 
		    72 && 0 <= i__1 ? i__1 : s_rnge("trans2", i__1, "zzfrmch"
		    "0_", (ftnlen)590)], &relto, &found);
	    if (found) {
		this__ = relto;
		get = put;
		put += inc;
		inc = -inc;
		cmnode = isrchi_(&this__, &node, frame);
		gotone = cmnode > 0;
	    }
	} else {

/*           Fetch the transformation into a temporary spot TEMPXF */

	    zzfrmgt0_(&this__, et, tempxf, &relto, &found);
	    if (found) {

/*              Next multiply TEMPXF on the right by the last partial */
/*              product (in TRANS2(,,GET) ).  We do this in line because */
/*              we can cut down the number of multiplies to 3/8 of the */
/*              normal result of MXMG.  For a discussion of why this */
/*              works see ZZMSXF. */

		for (i__ = 1; i__ <= 3; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			trans2[(i__1 = i__ + (j + put * 6) * 6 - 43) < 72 && 
				0 <= i__1 ? i__1 : s_rnge("trans2", i__1, 
				"zzfrmch0_", (ftnlen)619)] = tempxf[(i__2 = 
				i__ - 1) < 36 && 0 <= i__2 ? i__2 : s_rnge(
				"tempxf", i__2, "zzfrmch0_", (ftnlen)619)] * 
				trans2[(i__3 = (j + get * 6) * 6 - 42) < 72 &&
				 0 <= i__3 ? i__3 : s_rnge("trans2", i__3, 
				"zzfrmch0_", (ftnlen)619)] + tempxf[(i__4 = 
				i__ + 5) < 36 && 0 <= i__4 ? i__4 : s_rnge(
				"tempxf", i__4, "zzfrmch0_", (ftnlen)619)] * 
				trans2[(i__5 = (j + get * 6) * 6 - 41) < 72 &&
				 0 <= i__5 ? i__5 : s_rnge("trans2", i__5, 
				"zzfrmch0_", (ftnlen)619)] + tempxf[(i__6 = 
				i__ + 11) < 36 && 0 <= i__6 ? i__6 : s_rnge(
				"tempxf", i__6, "zzfrmch0_", (ftnlen)619)] * 
				trans2[(i__7 = (j + get * 6) * 6 - 40) < 72 &&
				 0 <= i__7 ? i__7 : s_rnge("trans2", i__7, 
				"zzfrmch0_", (ftnlen)619)];
		    }
		}
		for (i__ = 4; i__ <= 6; ++i__) {
		    for (j = 1; j <= 3; ++j) {
			trans2[(i__1 = i__ + (j + put * 6) * 6 - 43) < 72 && 
				0 <= i__1 ? i__1 : s_rnge("trans2", i__1, 
				"zzfrmch0_", (ftnlen)628)] = tempxf[(i__2 = 
				i__ - 1) < 36 && 0 <= i__2 ? i__2 : s_rnge(
				"tempxf", i__2, "zzfrmch0_", (ftnlen)628)] * 
				trans2[(i__3 = (j + get * 6) * 6 - 42) < 72 &&
				 0 <= i__3 ? i__3 : s_rnge("trans2", i__3, 
				"zzfrmch0_", (ftnlen)628)] + tempxf[(i__4 = 
				i__ + 5) < 36 && 0 <= i__4 ? i__4 : s_rnge(
				"tempxf", i__4, "zzfrmch0_", (ftnlen)628)] * 
				trans2[(i__5 = (j + get * 6) * 6 - 41) < 72 &&
				 0 <= i__5 ? i__5 : s_rnge("trans2", i__5, 
				"zzfrmch0_", (ftnlen)628)] + tempxf[(i__6 = 
				i__ + 11) < 36 && 0 <= i__6 ? i__6 : s_rnge(
				"tempxf", i__6, "zzfrmch0_", (ftnlen)628)] * 
				trans2[(i__7 = (j + get * 6) * 6 - 40) < 72 &&
				 0 <= i__7 ? i__7 : s_rnge("trans2", i__7, 
				"zzfrmch0_", (ftnlen)628)] + tempxf[(i__8 = 
				i__ + 17) < 36 && 0 <= i__8 ? i__8 : s_rnge(
				"tempxf", i__8, "zzfrmch0_", (ftnlen)628)] * 
				trans2[(i__9 = (j + get * 6) * 6 - 39) < 72 &&
				 0 <= i__9 ? i__9 : s_rnge("trans2", i__9, 
				"zzfrmch0_", (ftnlen)628)] + tempxf[(i__10 = 
				i__ + 23) < 36 && 0 <= i__10 ? i__10 : s_rnge(
				"tempxf", i__10, "zzfrmch0_", (ftnlen)628)] * 
				trans2[(i__11 = (j + get * 6) * 6 - 38) < 72 
				&& 0 <= i__11 ? i__11 : s_rnge("trans2", 
				i__11, "zzfrmch0_", (ftnlen)628)] + tempxf[(
				i__12 = i__ + 29) < 36 && 0 <= i__12 ? i__12 :
				 s_rnge("tempxf", i__12, "zzfrmch0_", (ftnlen)
				628)] * trans2[(i__13 = (j + get * 6) * 6 - 
				37) < 72 && 0 <= i__13 ? i__13 : s_rnge("tra"
				"ns2", i__13, "zzfrmch0_", (ftnlen)628)];
		    }
		}

/*              Note that we don't have to compute the upper right */
/*              hand block.  It's already set to zero by construction. */

/*              Finally we can just copy the lower right hand block */
/*              from the upper left hand block of the matrix. */

		for (i__ = 4; i__ <= 6; ++i__) {
		    k = i__ - 3;
		    for (j = 4; j <= 6; ++j) {
			l = j - 3;
			trans2[(i__1 = i__ + (j + put * 6) * 6 - 43) < 72 && 
				0 <= i__1 ? i__1 : s_rnge("trans2", i__1, 
				"zzfrmch0_", (ftnlen)647)] = trans2[(i__2 = k 
				+ (l + put * 6) * 6 - 43) < 72 && 0 <= i__2 ? 
				i__2 : s_rnge("trans2", i__2, "zzfrmch0_", (
				ftnlen)647)];
		    }
		}

/*              Adjust GET and PUT so that GET points to the slots */
/*              where we just stored the result of our multiply and */
/*              so that PUT points to the next available storage */
/*              locations. */

		get = put;
		put += inc;
		inc = -inc;
		this__ = relto;
		cmnode = isrchi_(&this__, &node, frame);
		gotone = cmnode > 0;
	    }
	}

/*        See if we have a common node and determine whether or not */
/*        we are done with this loop. */

	done = this__ == 1 || gotone || ! found;
    }

/*     There are two possible scenarios.  Either the chain of */
/*     transformations from FRAME2 ran into a node in the chain for */
/*     FRAME1 or it didn't.  (The common node might very well be */
/*     the root node.)  If we didn't run into a common one, then */
/*     the two chains don't intersect and there is no way to */
/*     get from FRAME1 to FRAME2. */

    if (! gotone) {
	frmnam_(frame1, name1, (ftnlen)32);
	frmnam_(frame2, name2, (ftnlen)32);
	frmnam_(&frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : s_rnge(
		"frame", i__1, "zzfrmch0_", (ftnlen)693)], name3, (ftnlen)32);
	frmnam_(&this__, name4, (ftnlen)32);
	if (s_cmp(name1, " ", (ftnlen)32, (ftnlen)1) == 0) {
	    s_copy(name1, "?", (ftnlen)32, (ftnlen)1);
	}
	if (s_cmp(name2, " ", (ftnlen)32, (ftnlen)1) == 0) {
	    s_copy(name2, "?", (ftnlen)32, (ftnlen)1);
	}
	if (s_cmp(name3, " ", (ftnlen)32, (ftnlen)1) == 0) {
	    s_copy(name3, "?", (ftnlen)32, (ftnlen)1);
	}
	if (s_cmp(name4, " ", (ftnlen)32, (ftnlen)1) == 0) {
	    s_copy(name4, "?", (ftnlen)32, (ftnlen)1);
	}
	r1 = rtrim_(name1, (ftnlen)32);
	r2 = rtrim_(name2, (ftnlen)32);
	r3 = rtrim_(name3, (ftnlen)32);
	r4 = rtrim_(name4, (ftnlen)32);
	setmsg_("There is insufficient information available to transform fr"
		"om # (@) to frame # (@).  Frame # could be transformed to # "
		"(@).  Frame # could be transformed to # (@).' ", (ftnlen)165);
	errint_("#", frame1, (ftnlen)1);
	errint_("#", frame2, (ftnlen)1);
	errint_("#", frame1, (ftnlen)1);
	errint_("#", &frame[(i__1 = node - 1) < 10 && 0 <= i__1 ? i__1 : 
		s_rnge("frame", i__1, "zzfrmch0_", (ftnlen)726)], (ftnlen)1);
	errint_("#", frame2, (ftnlen)1);
	errint_("#", &this__, (ftnlen)1);
	errch_("@", name1, (ftnlen)1, r1);
	errch_("@", name2, (ftnlen)1, r2);
	errch_("@", name3, (ftnlen)1, r3);
	errch_("@", name4, (ftnlen)1, r4);
	sigerr_("SPICE(NOFRAMECONNECT)", (ftnlen)21);
	chkout_("ZZFRMCH0", (ftnlen)8);
	return 0;
    }

/*     Recall that we have the following. */

/*     TRANS(1...6, 1...6, 1    )    transforms FRAME(1) to FRAME(2) */
/*     TRANS(1...6, 1...6, 2    )    transforms FRAME(2) to FRAME(3) */
/*     TRANS(1...6, 1...6, 3    )    transforms FRAME(3) to FRAME(4) */

/*     TRANS(1...6, 1...6, CMNODE-1) transforms FRAME(CMNODE-1) */
/*                                   to         FRAME(CMNODE) */

/*     and that TRANS2(1,1,GET) transforms from FRAME2 to CMNODE. */
/*     Hence the inverse of TRANS2(1,1,GET) transforms from CMNODE */
/*     to FRAME2. */

/*     If we compute the inverse of TRANS2 and store it in */
/*     the next available slot of TRANS (.i.e. TRANS(1,1,CMNODE) */
/*     we can simply apply our custom routine that multiplies a */
/*     sequence of transformation matrices together to get the */
/*     result from FRAME1 to FRAME2. */

    invstm_(&trans2[(i__1 = (get * 6 + 1) * 6 - 42) < 72 && 0 <= i__1 ? i__1 :
	     s_rnge("trans2", i__1, "zzfrmch0_", (ftnlen)761)], &trans[(i__2 =
	     (cmnode * 6 + 1) * 6 - 42) < 504 && 0 <= i__2 ? i__2 : s_rnge(
	    "trans", i__2, "zzfrmch0_", (ftnlen)761)]);
    zzmsxf_(trans, &cmnode, xform);
    chkout_("ZZFRMCH0", (ftnlen)8);
    return 0;
} /* zzfrmch0_ */

