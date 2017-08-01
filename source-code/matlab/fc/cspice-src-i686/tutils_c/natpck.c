/* natpck.f -- translated by f2c (version 19980913).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* $Procedure   NATPCK (Create a text PCK for Nat's solar system) */
/* Subroutine */ int natpck_(char *namepc, logical *loadpc, logical *keeppc, 
	ftnlen namepc_len)
{
    /* System generated locals */
    integer i__1;
    char ch__1[16];
    cllist cl__1;

    /* Builtin functions */
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);
    integer s_rnge(char *, integer, char *, integer), f_clos(cllist *);

    /* Local variables */
    integer unit, i__;
    extern /* Subroutine */ int chkin_(char *, ftnlen);
    extern /* Character */ VOID begdat_(char *, ftnlen);
    extern /* Subroutine */ int kilfil_(char *, ftnlen), tfiles_(char *, 
	    ftnlen), ldpool_(char *, ftnlen);
    extern /* Character */ VOID begtxt_(char *, ftnlen);
    extern /* Subroutine */ int chkout_(char *, ftnlen), writln_(char *, 
	    integer *, ftnlen), txtopn_(char *, integer *, ftnlen);
    char pck[80*48];

/* $ Abstract */

/*     Create and if appropriate load a text PCK kernel for Nat's */
/*     solar system. */

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

/*     TESTING */

/* $ Declarations */
/* $ Brief_I/O */

/*     VARIABLE  I/O  DESCRIPTION */
/*     --------  ---  -------------------------------------------------- */
/*     NAMEPC     I   The name of the PC-kernel to create. */
/*     LOADPC     I   Load the PC-kernel if .TRUE. */
/*     KEEPPC     I   Keep the PC-kernel if .TRUE., else delete it. */

/* $ Detailed_Input */

/*     NAMEPC      is the name of a PCK to create and load if LOADPC is */
/*                 set to .TRUE.  If a PCK of the same name already */
/*                 exists it is deleted. */

/*     LOADPC      is a logical that indicates whether or not the PCK */
/*                 file should be loaded after it is created.  If LOADPC */
/*                 has the value .TRUE. the PCK is loaded after it is */
/*                 created.  Otherwise it is left un-opened. */

/*     KEEPPC      is a logical that indicates whether or not the PCK */
/*                 file should be deleted after it is loaded.  If KEEPPC */
/*                 is .TRUE. the file is not deleted.  If KEEPPC is */
/*                 .FALSE. the file is deleted after it is loaded. */

/*                 Note this behavior is different from that of TSTPCK, */
/*                 which always keeps the file if the file is not loaded, */
/*                 regardless of the value of KEEPPC. */

/* $ Detailed_Output */

/*     None. */

/* $ Parameters */

/*     None. */

/* $ Files */

/*     This routine creates a PCK file meant for use with the SPK */
/*     file created by the test utility NATSPK.  If that routine */
/*     is changed, the body radii defined here may need to be */
/*     changed as well.  NATSPK contains commented-out lines of code */
/*     that generate appropriate body radii. */

/*     The PCK created by this routine contains */

/*        - Name-ID mappings for bodies ALPHA and BETA */

/*        - Body radii for bodies ALPHA and BETA */

/*        - Rotational elements for bodies ALPHA and BETA */

/*        - PCK frame definitions for the body-fixed frames */

/*             ALPHAFIXED */
/*             BETAFIXED */

/*        - Associations of the bodyfixed frames with the */
/*          bodies ALPHA and BETA */

/*        - GM and radii for the "sun" of this solar system.  The */
/*          GM value is computed by NATSPK; normally the lines of */
/*          code that write out the value are commented out. */

/*          The smaller radii of the sun are provided because the */
/*          original values make the sun too large relative to the */
/*          orbital radii of the planets. */

/* $ Exceptions */

/*     1) Any I/O errors occurring in the creation of the PCK file */
/*        will be signaled by routines in the call tree of this */
/*        routine. */

/*     Since this routine is normally used within the TSPICE system, */
/*     it's up the the caller to call CHCKXC to catch errors signaled by */
/*     this routine. */

/* $ Particulars */

/*     This routine creates a planetary constants file for use in */
/*     testing. */

/* $ Examples */

/*     The normal way to use this routine is shown below. */

/*     CALL NATSPK ( 'nat.bsp', .TRUE., HANDLE  ) */
/*     CALL NATPCK ( 'nat.tpc', .TRUE., .FALSE. ) */

/*        [perform some tests and computations] */

/*     CALL SPKUEF ( HANDLE ) */
/*     CALL KILFIL ( 'nat.bsp' ) */

/* $ Restrictions */

/*     None. */

/* $ Author_and_Institution */

/*     N.J. Bachman    (JPL) */

/* $ Literature_References */

/*     None. */

/* $ Version */

/* -    Test Utilities 1.0.0, 29-SEP-2004 (NJB) */

/* -& */
/* $ Index_Entries */

/*     Create a "Nat's solar system" PCK file */

/* -& */

/*     Test Utility Functions */


/*     Local Parameters */


/*     Local Variables */

    chkin_("NATPCK", (ftnlen)6);

/*     Delete any existing file of the same name. */

    kilfil_(namepc, namepc_len);

/*     Fill the PCK buffer with the PCK kernel variable assignments. */

    begdat_(ch__1, (ftnlen)16);
    s_copy(pck, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 80, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 160, "      NAIF_BODY_NAME += ( 'ALPHA', 'BETA' )", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 240, "      NAIF_BODY_CODE += ( 1000,     2000  )", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 400, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 480, "      BODY1000_RADII = ( 0.36624698766937712E+05,", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 560, "                         0.36624698766937712E+05,", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 640, "                         0.36624698766937712E+05  )", (
	    ftnlen)80, (ftnlen)51);
    s_copy(pck + 720, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 800, "      BODY2000_RADII = ( 0.22891526271046937E+04,", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 880, "                         0.22891526271046937E+04,", (
	    ftnlen)80, (ftnlen)49);
    s_copy(pck + 960, "                         0.22891526271046937E+04, )", (
	    ftnlen)80, (ftnlen)51);
    s_copy(pck + 1040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1120, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1200, "      BODY1000_POLE_RA        = (    0.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1280, "      BODY1000_POLE_DEC       = (  +90.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1360, "      BODY1000_PM             = (    0.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1520, "      BODY2000_POLE_RA        = (    0.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1600, "      BODY2000_POLE_DEC       = (  +90.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1680, "      BODY2000_PM             = (    0.       0.    "
	    "     0. )", (ftnlen)80, (ftnlen)61);
    s_copy(pck + 1760, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1840, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 1920, "      FRAME_ALPHAFIXED        =  1000001", (ftnlen)80,
	     (ftnlen)40);
    s_copy(pck + 2000, "      FRAME_1000001_NAME      = 'ALPHAFIXED'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 2080, "      FRAME_1000001_CLASS     =  2", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 2160, "      FRAME_1000001_CLASS_ID  =  1000", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 2240, "      FRAME_1000001_CENTER    =  1000", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 2320, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2400, "      OBJECT_1000_FRAME       = 'ALPHAFIXED'", (
	    ftnlen)80, (ftnlen)44);
    s_copy(pck + 2480, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2560, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 2640, "      FRAME_BETAFIXED         =  1000002", (ftnlen)80,
	     (ftnlen)40);
    s_copy(pck + 2720, "      FRAME_1000002_NAME      = 'BETAFIXED'", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 2800, "      FRAME_1000002_CLASS     =  2", (ftnlen)80, (
	    ftnlen)34);
    s_copy(pck + 2880, "      FRAME_1000002_CLASS_ID  =  2000", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 2960, "      FRAME_1000002_CENTER    =  2000", (ftnlen)80, (
	    ftnlen)37);
    s_copy(pck + 3040, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3120, "      OBJECT_2000_FRAME       = 'BETAFIXED'", (ftnlen)
	    80, (ftnlen)43);
    s_copy(pck + 3200, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3280, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3360, "      BODY10_RADII            = ( 1000, 1000, 1000 )",
	     (ftnlen)80, (ftnlen)52);
    s_copy(pck + 3440, " ", (ftnlen)80, (ftnlen)1);
    s_copy(pck + 3520, "      BODY10_GM               =  0.99745290739151156"
	    "E+09", (ftnlen)80, (ftnlen)56);
    s_copy(pck + 3600, " ", (ftnlen)80, (ftnlen)1);
    begtxt_(ch__1, (ftnlen)16);
    s_copy(pck + 3680, ch__1, (ftnlen)80, (ftnlen)16);
    s_copy(pck + 3760, " ", (ftnlen)80, (ftnlen)1);

/*     Create the PCK. */

    txtopn_(namepc, &unit, namepc_len);
    for (i__ = 1; i__ <= 48; ++i__) {
	writln_(pck + ((i__1 = i__ - 1) < 48 && 0 <= i__1 ? i__1 : s_rnge(
		"pck", i__1, "natpck_", (ftnlen)282)) * 80, &unit, (ftnlen)80)
		;
    }
    cl__1.cerr = 0;
    cl__1.cunit = unit;
    cl__1.csta = 0;
    f_clos(&cl__1);

/*     If this file needs to be loaded, do it. */

    if (*loadpc) {
	ldpool_(namepc, namepc_len);
    }
    if (*keeppc) {

/*        If we are keeping this file, we need to register it */
/*        with FILREG. */

	tfiles_(namepc, namepc_len);
    } else {

/*        Lose the file. */

	kilfil_(namepc, namepc_len);
    }
    chkout_("NATPCK", (ftnlen)6);
    return 0;
} /* natpck_ */

