/* f_zzfdat.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__2 = 2;
static logical c_false = FALSE_;
static integer c__0 = 0;
static logical c_true = TRUE_;

/* $Procedure F_ZZFDAT ( ZZFDAT Test Family ) */
/* Subroutine */ int f_zzfdat__(logical *ok)
{
    /* System generated locals */
    address a__1[2];
    integer i__1, i__2, i__3[2], i__4;
    char ch__1[51];

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_cat(char *, char **, integer *, integer *, ftnlen);
    integer s_cmp(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    integer i__, bcode;
    extern /* Subroutine */ int tcase_(char *, ftnlen);
    logical found;
    extern /* Subroutine */ int topen_(char *, ftnlen);
    extern integer rtrim_(char *, ftnlen);
    extern /* Subroutine */ int bodn2c_(char *, integer *, logical *, ftnlen),
	     t_success__(logical *), chcksc_(char *, char *, char *, char *, 
	    logical *, ftnlen, ftnlen, ftnlen, ftnlen);
    integer atcode[117], frcode;
    extern /* Subroutine */ int chckxc_(logical *, char *, logical *, ftnlen),
	     chcksi_(char *, integer *, char *, integer *, integer *, logical 
	    *, ftnlen, ftnlen);
    char atname[32*117];
    extern /* Subroutine */ int chcksl_(char *, logical *, logical *, logical 
	    *, ftnlen);
    char frname[32];
    integer atcent[117];
    extern /* Subroutine */ int namfrm_(char *, integer *, ftnlen);
    integer frcent;
    extern /* Subroutine */ int frmnam_(integer *, char *, ftnlen), frinfo_(
	    integer *, integer *, integer *, integer *, logical *);
    integer ntochk, atclss[117], frclss, attype[117], frtype;

/* $ Abstract */

/*     Test family to exercise the logic and code in the ZZFDAT */
/*     routine. */

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

/*     TEST FAMILY */

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
/* $ Abstract */

/*     This file contains the number of inertial reference */
/*     frames that are currently known by the SPICE toolkit */
/*     software. */

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
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NINERT     P   Number of known inertial reference frames. */

/* $ Parameters */

/*     NINERT     is the number of recognized inertial reference */
/*                frames.  This value is needed by both CHGIRF */
/*                ZZFDAT, and FRAMEX. */

/* $ Author_and_Institution */

/*     W.L. Taber      (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.0.0, 10-OCT-1996 (WLT) */

/* -& */
/* $ Abstract */

/*     This file contains the number of non-inertial reference */
/*     frames that are currently built into the SPICE toolkit */
/*     software. */


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
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NINERT     P   Number of built-in non-inertial reference frames. */

/* $ Parameters */

/*     NINERT     is the number of built-in non-inertial reference */
/*                frames.  This value is needed by both  ZZFDAT, and */
/*                FRAMEX. */

/* $ Author_and_Institution */

/*     B.V. Semenov    (JPL) */
/*     W.L. Taber      (JPL) */
/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    SPICELIB Version 1.3.0, 12-DEC-2002 (BVS) */

/*        Increased the number of non-inertial frames from 85 to 96 */
/*        in order to accomodate the following PCK based frames: */

/*           IAU_CALLIRRHOE */
/*           IAU_THEMISTO */
/*           IAU_MAGACLITE */
/*           IAU_TAYGETE */
/*           IAU_CHALDENE */
/*           IAU_HARPALYKE */
/*           IAU_KALYKE */
/*           IAU_IOCASTE */
/*           IAU_ERINOME */
/*           IAU_ISONOE */
/*           IAU_PRAXIDIKE */

/* -    SPICELIB Version 1.2.0, 02-AUG-2002 (FST) */

/*        Increased the number of non-inertial frames from 81 to 85 */
/*        in order to accomodate the following PCK based frames: */

/*           IAU_PAN */
/*           IAU_GASPRA */
/*           IAU_IDA */
/*           IAU_EROS */

/* -    SPICELIB Version 1.1.0, 20-FEB-1997 (WLT) */

/*        Increased the number of non-inertial frames from 79 to 81 */
/*        in order to accomodate the following earth rotation */
/*        models: */

/*           ITRF93 */
/*           EARTH_FIXED */

/* -    SPICELIB Version 1.0.0, 10-OCT-1996 (WLT) */

/* -& */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     OK         O   logical indicating test status. */

/* $ Detailed_Input */

/*     None. */

/* $ Detailed_Output */

/*     OK         is a logical that indicates the test status to the */
/*                caller. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     None. */

/* $ Exceptions */

/*     This routine does not generate any errors. Routines in its */
/*     call tree may generate errors that are either intentional and */
/*     trapped or unintentional and need reporting.  The test family */
/*     utilities manage this. */

/* $ Particulars */

/*     This routine exercises updates to ZZFDAT through the FRAMEX */
/*     query interfaces. */

/* $ Examples */

/*     None. */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     F.S. Turner     (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    TSPICE Version 1.1.0, 12-DEC-2002 (FST) */

/*        Updated to check for correct PAN frame value 618. Added */
/*        checks for new Jovian satellite frames. */

/* -    TSPICE Version 1.0.0, 02-AUG-2002 (FST) */

/* -& */

/*     Local Parameters */


/*     Local Variables */


/*     SPICELIB functions */


/*     Start the test family with an open call. */

    topen_("F_ZZFDAT", (ftnlen)8);

/*     Set expected values. */

    s_copy(atname, "IAU_PAN", (ftnlen)32, (ftnlen)7);
    atcode[0] = 10082;
    atcent[0] = 618;
    atclss[0] = 618;
    attype[0] = 2;
    s_copy(atname + 32, "IAU_GASPRA", (ftnlen)32, (ftnlen)10);
    atcode[1] = 10083;
    atcent[1] = 9511010;
    atclss[1] = 9511010;
    attype[1] = 2;
    s_copy(atname + 64, "IAU_IDA", (ftnlen)32, (ftnlen)7);
    atcode[2] = 10084;
    atcent[2] = 2431010;
    atclss[2] = 2431010;
    attype[2] = 2;
    s_copy(atname + 96, "IAU_EROS", (ftnlen)32, (ftnlen)8);
    atcode[3] = 10085;
    atcent[3] = 2000433;
    atclss[3] = 2000433;
    attype[3] = 2;
    s_copy(atname + 128, "IAU_CALLIRRHOE", (ftnlen)32, (ftnlen)14);
    atcode[4] = 10086;
    atcent[4] = 517;
    atclss[4] = 517;
    attype[4] = 2;
    s_copy(atname + 160, "IAU_THEMISTO", (ftnlen)32, (ftnlen)12);
    atcode[5] = 10087;
    atcent[5] = 518;
    atclss[5] = 518;
    attype[5] = 2;
    s_copy(atname + 192, "IAU_MAGACLITE", (ftnlen)32, (ftnlen)13);
    atcode[6] = 10088;
    atcent[6] = 519;
    atclss[6] = 519;
    attype[6] = 2;
    s_copy(atname + 224, "IAU_TAYGETE", (ftnlen)32, (ftnlen)11);
    atcode[7] = 10089;
    atcent[7] = 520;
    atclss[7] = 520;
    attype[7] = 2;
    s_copy(atname + 256, "IAU_CHALDENE", (ftnlen)32, (ftnlen)12);
    atcode[8] = 10090;
    atcent[8] = 521;
    atclss[8] = 521;
    attype[8] = 2;
    s_copy(atname + 288, "IAU_HARPALYKE", (ftnlen)32, (ftnlen)13);
    atcode[9] = 10091;
    atcent[9] = 522;
    atclss[9] = 522;
    attype[9] = 2;
    s_copy(atname + 320, "IAU_KALYKE", (ftnlen)32, (ftnlen)10);
    atcode[10] = 10092;
    atcent[10] = 523;
    atclss[10] = 523;
    attype[10] = 2;
    s_copy(atname + 352, "IAU_IOCASTE", (ftnlen)32, (ftnlen)11);
    atcode[11] = 10093;
    atcent[11] = 524;
    atclss[11] = 524;
    attype[11] = 2;
    s_copy(atname + 384, "IAU_ERINOME", (ftnlen)32, (ftnlen)11);
    atcode[12] = 10094;
    atcent[12] = 525;
    atclss[12] = 525;
    attype[12] = 2;
    s_copy(atname + 416, "IAU_ISONOE", (ftnlen)32, (ftnlen)10);
    atcode[13] = 10095;
    atcent[13] = 526;
    atclss[13] = 526;
    attype[13] = 2;
    s_copy(atname + 448, "IAU_PRAXIDIKE", (ftnlen)32, (ftnlen)13);
    atcode[14] = 10096;
    atcent[14] = 527;
    atclss[14] = 527;
    attype[14] = 2;
    ntochk = 15;

/*     Check frames one by one. */

    i__1 = ntochk;
    for (i__ = 1; i__ <= i__1; ++i__) {

/*        Set test case name. */

/* Writing concatenation */
	i__3[0] = 19, a__1[0] = "ZZFDAT Entries for ";
	i__3[1] = 32, a__1[1] = atname + (((i__2 = i__ - 1) < 117 && 0 <= 
		i__2 ? i__2 : s_rnge("atname", i__2, "f_zzfdat__", (ftnlen)
		255)) << 5);
	s_cat(ch__1, a__1, i__3, &c__2, (ftnlen)51);
	tcase_(ch__1, (ftnlen)51);

/*        Check NAME to CODE and CODE to NAME mappings. */

	namfrm_(atname + (((i__2 = i__ - 1) < 117 && 0 <= i__2 ? i__2 : 
		s_rnge("atname", i__2, "f_zzfdat__", (ftnlen)260)) << 5), &
		frcode, (ftnlen)32);
	frmnam_(&atcode[(i__2 = i__ - 1) < 117 && 0 <= i__2 ? i__2 : s_rnge(
		"atcode", i__2, "f_zzfdat__", (ftnlen)261)], frname, (ftnlen)
		32);

/*        Check results. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksi_("FRCODE", &frcode, "=", &atcode[(i__2 = i__ - 1) < 117 && 0 <=
		 i__2 ? i__2 : s_rnge("atcode", i__2, "f_zzfdat__", (ftnlen)
		267)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksc_("FRNAME", frname, "=", atname + (((i__2 = i__ - 1) < 117 && 0 
		<= i__2 ? i__2 : s_rnge("atname", i__2, "f_zzfdat__", (ftnlen)
		268)) << 5), ok, (ftnlen)6, (ftnlen)32, (ftnlen)1, (ftnlen)32)
		;

/*        Now check frame attributes as reported by FRINFO. */

	frinfo_(&atcode[(i__2 = i__ - 1) < 117 && 0 <= i__2 ? i__2 : s_rnge(
		"atcode", i__2, "f_zzfdat__", (ftnlen)273)], &frcent, &frtype,
		 &frclss, &found);

/*        Check results. */

	chckxc_(&c_false, " ", ok, (ftnlen)1);
	chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	chcksi_("CLSSID", &frclss, "=", &atclss[(i__2 = i__ - 1) < 117 && 0 <=
		 i__2 ? i__2 : s_rnge("atclss", i__2, "f_zzfdat__", (ftnlen)
		280)], &c__0, ok, (ftnlen)6, (ftnlen)1);
	chcksi_("CLASS", &frtype, "=", &attype[(i__2 = i__ - 1) < 117 && 0 <= 
		i__2 ? i__2 : s_rnge("attype", i__2, "f_zzfdat__", (ftnlen)
		281)], &c__0, ok, (ftnlen)5, (ftnlen)1);
	chcksi_("CENT", &frcent, "=", &atcent[(i__2 = i__ - 1) < 117 && 0 <= 
		i__2 ? i__2 : s_rnge("atcent", i__2, "f_zzfdat__", (ftnlen)
		282)], &c__0, ok, (ftnlen)4, (ftnlen)1);

/*        If it's an 'IAU_' style PCK frame, check that ID returned */
/*        for the body from the frame name is the same as the frame */
/*        center ID. */

	if (attype[(i__2 = i__ - 1) < 117 && 0 <= i__2 ? i__2 : s_rnge("atty"
		"pe", i__2, "f_zzfdat__", (ftnlen)289)] == 2 && s_cmp(atname + 
		(((i__4 = i__ - 1) < 117 && 0 <= i__4 ? i__4 : s_rnge("atname"
		, i__4, "f_zzfdat__", (ftnlen)289)) << 5), "IAU_", (ftnlen)4, 
		(ftnlen)4) == 0) {
	    bodn2c_(atname + ((((i__2 = i__ - 1) < 117 && 0 <= i__2 ? i__2 : 
		    s_rnge("atname", i__2, "f_zzfdat__", (ftnlen)292)) << 5) 
		    + 4), &bcode, &found, rtrim_(atname + (((i__4 = i__ - 1) <
		     117 && 0 <= i__4 ? i__4 : s_rnge("atname", i__4, "f_zzf"
		    "dat__", (ftnlen)292)) << 5), (ftnlen)32) - 4);

/*           Check results. */

	    chckxc_(&c_false, " ", ok, (ftnlen)1);
	    chcksl_("FOUND", &found, &c_true, ok, (ftnlen)5);
	    chcksi_("BCODE", &bcode, "=", &atcent[(i__2 = i__ - 1) < 117 && 0 
		    <= i__2 ? i__2 : s_rnge("atcent", i__2, "f_zzfdat__", (
		    ftnlen)299)], &c__0, ok, (ftnlen)5, (ftnlen)1);
	}
    }

/*     Close out the test family. */

    t_success__(ok);
    return 0;
} /* f_zzfdat__ */

